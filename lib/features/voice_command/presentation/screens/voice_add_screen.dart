import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/voice_command/domain/voice_command_parser.dart';
import 'package:flowpaisa/features/transactions/domain/models/parsed_transaction_input.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/ml/model_download_service.dart';
import 'package:flowpaisa/features/receipt_scan/domain/transaction_text_parser.dart';

class VoiceAddScreen extends ConsumerStatefulWidget {
  const VoiceAddScreen({super.key});

  @override
  ConsumerState<VoiceAddScreen> createState() => _VoiceAddScreenState();
}

class _VoiceAddScreenState extends ConsumerState<VoiceAddScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final VoiceCommandParser _fallbackParser = VoiceCommandParser();
  final ModelDownloadService _modelService = ModelDownloadService();
  late final TransactionAiParser _aiParser;

  bool _isListening = false;
  String _text = '';
  ParsedTransactionInput? _parsedResult;
  bool _isProcessing = false;
  bool _usedAi = false;
  double _downloadProgress = 0;
  bool _isDownloading = false;
  bool _modelDownloaded = false;
  bool _includeTextAsDescription = true;

  late TextEditingController _transcriptController;

  @override
  void initState() {
    super.initState();
    _aiParser = TransactionAiParser(_modelService);
    _transcriptController = TextEditingController();
    _checkModelStatus();
  }

  Future<void> _checkModelStatus() async {
    final downloaded = await _modelService.isModelDownloaded(ModelDownloadService.transactionParserModel);
    if (mounted) {
      setState(() => _modelDownloaded = downloaded);
      if (!downloaded) {
        // Show dialog on first visit if not downloaded
        WidgetsBinding.instance.addPostFrameCallback((_) => _showInitialDownloadDialog());
      }
    }
  }

  Future<void> _showInitialDownloadDialog() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final shouldDownload = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.smartExtraction),
        content: Text(l10n.smartAiDownloadMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.basicExtraction),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.downloadNow),
          ),
        ],
      ),
    );
    if (shouldDownload == true) {
      _startDownload();
    }
  }

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });
    try {
      final success = await _modelService.downloadModel(
        ModelDownloadService.transactionParserModel,
        onProgress: (progress) {
          if (mounted) {
            setState(() => _downloadProgress = progress);
          }
        },
      );
      if (success) {
        setState(() => _modelDownloaded = true);
      } else if (mounted) {
        ToastUtils.showErrorToast(context, ref, "Failed to download AI model. Please check your connection.");
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(context, ref, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (kDebugMode) {
            debugPrint('onStatus: $val');
          }
        },
        onError: (val) {
          if (kDebugMode) {
            debugPrint('onError: $val');
          }
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            _transcriptController.text = _text;
            if (val.finalResult) {
              _isListening = false;
              _processText(_text);
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _processText(String text) async {
    if (text.isEmpty) return;
    setState(() => _isProcessing = true);

    try {
      ParsedTransactionInput? result;
      bool usedAi = false;

      final isModelReady = await _modelService.isModelDownloaded(ModelDownloadService.transactionParserModel);
      final limits = await PremiumGate.getSmartParsingLimits(ref);

      if (isModelReady && limits.canAdd) {
        result = await _aiParser.parse(text, isReceipt: false);
        if (result != null && !result.isEmpty) {
          usedAi = true;
        }
      } else if (isModelReady && !limits.canAdd) {
        if (mounted) {
          ToastUtils.showWarningToast(context, ref, "Monthly smart parsing limit reached. Using basic extraction.");
        }
      }

      if (result == null || result.isEmpty) {
        result = _fallbackParser.parse(text);
      }

      setState(() {
        _parsedResult = result;
        _usedAi = usedAi;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ToastUtils.showErrorToast(context, ref, e.toString());
      }
    }
  }

  void _showHints() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.voiceGuideTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildHintSection(context, "Simple Expenses", [
                "Spent 500 on fuel",
                "Dinner per 1000 kharch kiye",
              ]),
              _buildHintSection(context, "Giving Money (Payable/Receivable)", [
                "I gave 1000 to Ashfaq for dinner",
                "Ashfaq ko 500 dinner ke liye diye",
              ]),
              _buildHintSection(context, "Receiving Money / Loans", [
                "Received 2000 from Kashif",
                "Kashif Ne ₹500 Udhar Diye",
                "Maine Kashif se ₹50 Udhar Liye",
              ]),
              _buildHintSection(context, "Someone Else Paid for You", [
                "Someone paid 500 for me",
                "Ashfaq purchased dinner for me",
                "Ashfaq Ne Mere dinner ke ₹500 Diye",
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHintSection(BuildContext context, String title, List<String> examples) {
    final activeCashbookColor = ref.read(activeCashbookProvider).color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: activeCashbookColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...examples.map((ex) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(child: Text(ex, style: const TextStyle(fontStyle: FontStyle.italic))),
            ],
          ),
        )),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final activeCashbookColor = ref.watch(activeCashbookProvider).color;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.voiceAdd),
        actions: [
          if (!_modelDownloaded && !_isDownloading)
            IconButton(
              icon: const Icon(Icons.auto_awesome_outlined),
              tooltip: l10n.smartExtraction,
              onPressed: () async {
                final shouldDownload = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.smartExtraction),
                    content: Text(l10n.smartAiDownloadMessage),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l10n.downloadNow),
                      ),
                    ],
                  ),
                );
                if (shouldDownload == true) {
                  _startDownload();
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n.hints,
            onPressed: _showHints,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              
              // Mic Button
              GestureDetector(
                onTap: _listen,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _isListening ? Colors.red : activeCashbookColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? Colors.red : activeCashbookColor).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isListening ? l10n.listening : l10n.tapToSpeak,
                style: theme.textTheme.titleMedium,
              ),
              
              if (_isDownloading) ...[
                const SizedBox(height: 24),
                Text(
                  "Downloading Smart AI Model... ${(_downloadProgress * 100).toStringAsFixed(0)}%",
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    value: _downloadProgress,
                    backgroundColor: activeCashbookColor.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(activeCashbookColor),
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Transcript Field
              if (_text.isNotEmpty || _isProcessing)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.whatWeHeard, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Text(l10n.includeTextAsDescription, style: theme.textTheme.bodySmall),
                            Transform.scale(
                              scale: 0.7,
                              child: Switch(
                                value: _includeTextAsDescription,
                                onChanged: (val) => setState(() => _includeTextAsDescription = val),
                                activeColor: activeCashbookColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _transcriptController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () => _processText(_transcriptController.text),
                        ),
                      ),
                    ),
                  ],
                ),
                
              const SizedBox(height: 32),
              
              // Review Section
              if (_parsedResult != null && !_isProcessing)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      // AI Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: _usedAi ? Colors.blue.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_usedAi ? Icons.auto_awesome : Icons.rule_rounded, size: 14, color: _usedAi ? Colors.blue : Colors.grey),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _usedAi ? l10n.smartExtraction : l10n.basicExtraction,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _usedAi ? Colors.blue : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      _buildDetailRow(l10n.amount, "${_parsedResult!.amount ?? 0}"),
                      _buildDetailRow(l10n.type, _parsedResult!.type == "INCOME" ? l10n.income : l10n.expense),
                      if (_parsedResult!.categoryName != null) _buildDetailRow(l10n.category, _parsedResult!.categoryName!),
                      if (_parsedResult!.contactName != null) _buildDetailRow(l10n.contact, _parsedResult!.contactName!),
                      if (_parsedResult!.paidRelationship != null) _buildDetailRow(l10n.relationship, _getLocalizedRelationship(_parsedResult!.paidRelationship!, l10n)),
                      
                      const SizedBox(height: 24),
                      GradientButton(
                        onPressed: () async {
                          if (_usedAi) {
                            await ref.read(usageTrackerRepositoryProvider).incrementSmartParsingCount();
                          }
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTransactionScreen(
                                initialAmount: _parsedResult!.amount,
                                initialDescription: _includeTextAsDescription 
                                    ? (_transcriptController.text.isNotEmpty ? _transcriptController.text : _parsedResult!.description)
                                    : null,
                                initialType: _parsedResult!.type,
                                initialCategoryName: _parsedResult!.categoryName,
                                initialContactName: _parsedResult!.contactName,
                                initialRelationship: _parsedResult!.paidRelationship,
                              ),
                            ),
                          );
                        },
                        label: l10n.proceed,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLocalizedRelationship(String relationship, AppLocalizations l10n) {
    switch (relationship) {
      case 'PAID_FOR':
        return l10n.paidFor;
      case 'PAID_BY':
        return l10n.paidBy;
      case 'RECEIVED_FROM':
        return l10n.receivedLabel;
      case 'WILL_RECEIVE':
        return l10n.willReceive;
      default:
        return relationship;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
