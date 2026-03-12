import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/core/database/database.dart' as db;
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/core/utils/string_similarity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/voice_command/domain/voice_command_parser.dart';
import 'package:flowpaisa/features/transactions/domain/models/parsed_transaction_input.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/currencies/presentation/providers/currencies_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/features/voice_command/domain/voice_ai_parser.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';

class VoiceAddScreen extends ConsumerStatefulWidget {
  const VoiceAddScreen({super.key});

  @override
  ConsumerState<VoiceAddScreen> createState() => _VoiceAddScreenState();
}

class _VoiceAddScreenState extends ConsumerState<VoiceAddScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final VoiceCommandParser _fallbackParser = VoiceCommandParser();
  final VoiceAiParser _aiParser = VoiceAiParser();
  final EntityExtractorModelManager _modelManager =
      EntityExtractorModelManager();

  bool _isListening = false;
  String _text = '';
  ParsedTransactionInput? _parsedResult;
  bool _isProcessing = false;
  bool _usedAi = false;
  bool _isDownloading = false;
  bool _modelDownloaded = false;
  bool _includeTextAsDescription = true;
  String? _selectedCategoryName;
  String? _selectedCategoryColor;
  String? _selectedCategoryIcon;
  String? _selectedContactName;

  late TextEditingController _transcriptController;

  @override
  void initState() {
    super.initState();
    _transcriptController = TextEditingController();
    _checkModelStatus();
  }

  Future<void> _checkModelStatus() async {
    final downloaded = await _modelManager
        .isModelDownloaded(EntityExtractorLanguage.english.name);
    if (mounted) {
      setState(() {
        _modelDownloaded = downloaded;
      });
      // Start download immediately when screen opens (model is not big); other screens keep their triggers.
      if (!downloaded && !_isDownloading) {
        _startDownload();
      }
    }
  }

  @override
  void dispose() {
    _transcriptController.dispose();
    _aiParser.close();
    super.dispose();
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
    });
    try {
      final success = await _modelManager
          .downloadModel(EntityExtractorLanguage.english.name);
      if (success && mounted) {
        await _checkModelStatus();
      } else if (mounted && !success) {
        ToastUtils.showErrorToast(context, ref,
            "Failed to download AI model. Please check your connection.");
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
    // Auto-start download if not downloaded and not already downloading
    if (!_modelDownloaded && !_isDownloading) {
      _startDownload();
    }

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

      final isModelReady = await _modelManager
          .isModelDownloaded(EntityExtractorLanguage.english.name);
      final limits = await PremiumGate.getSmartParsingLimits(ref);

      // Get all active currency symbols from database
      final currencies =
          await ref.read(currenciesRepositoryProvider).getAllCurrencies();
      final dbSymbols = currencies.map((c) => c.symbol).toList();

      if (isModelReady && limits.canAdd) {
        result = await _aiParser.parse(
          text,
          customSymbols: dbSymbols,
        );
        if (result != null && !result.isEmpty) {
          usedAi = true;
        }
      } else if (isModelReady && !limits.canAdd) {
        if (mounted) {
          ToastUtils.showWarningToast(context, ref,
              "Monthly smart parsing limit reached. Using basic extraction.");
        }
      }

      if (result == null || result.isEmpty) {
        result = _fallbackParser.parse(text);
      }

      setState(() {
        _parsedResult = result;
        _usedAi = usedAi;
        _selectedCategoryName = result?.categoryName;
        _selectedContactName = result?.contactName;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ToastUtils.showErrorToast(context, ref, e.toString());
      }
    }
  }

  Future<bool> _isSmartModeActive() async {
    final isModelReady = await _modelManager
        .isModelDownloaded(EntityExtractorLanguage.english.name);
    if (!isModelReady) return false;

    final limits = await PremiumGate.getSmartParsingLimits(ref);
    return limits.canAdd;
  }

  void _showHints() async {
    final l10n = AppLocalizations.of(context)!;
    final isSmart = await _isSmartModeActive();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (sheetContext, scrollController) {
          void testExample(String example) {
            Navigator.pop(sheetContext);
            setState(() {
              _text = example;
              _transcriptController.text = example;
            });
            _processText(example);
          }

          return SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(sheetContext).padding.bottom + 24,
            ),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.voiceGuideTitle,
                        style: Theme.of(sheetContext)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isSmart ? Colors.blue : Colors.grey)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: (isSmart ? Colors.blue : Colors.grey)
                                .withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        isSmart ? l10n.smartExtraction : l10n.basicExtraction,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSmart ? Colors.blue : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                    isSmart
                        ? "Smart extraction understands natural phrasing in English, Hindi, and Urdu."
                        : "Basic mode works best with structured phrases like 'Paid [Amount] for [Category]'.",
                    style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                        color: Theme.of(sheetContext)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.7))),
                const SizedBox(height: 24),
                if (isSmart) ...[
                  _buildHintSection(
                      sheetContext,
                      "Simple Expenses",
                      [
                        "Spent 500 on fuel",
                        "Dinner per 1000 kharch kiye",
                      ],
                      onTest: (ex) => () => testExample(ex)),
                  _buildHintSection(
                      sheetContext,
                      "Giving Money (Receivable)",
                      [
                        "I gave 1000 to Ashfaq for dinner",
                        "Ashfaq ko 500 dinner ke liye diye",
                        "Kashif ne 500 dinner ke liye",
                      ],
                      onTest: (ex) => () => testExample(ex)),
                  _buildHintSection(
                      sheetContext,
                      "Other Paid (Payable)",
                      [
                        "Kashif gave 1000 for dinner",
                        "Ashfaq ne 500 dinner ke liye diye",
                        "Kashif se 500 dinner ke liye",
                      ],
                      onTest: (ex) => () => testExample(ex)),
                  _buildHintSection(
                      sheetContext,
                      "Receiving Money / Loans",
                      [
                        "Received 2000 from Kashif",
                        "Kashif Ne ₹500 Udhar Diye",
                        "Kashif Ne ₹500 Diye",
                        "Kashif se ₹50 Udhar Liye",
                      ],
                      onTest: (ex) => () => testExample(ex)),
                  _buildHintSection(
                      sheetContext,
                      "Will Receive Money",
                      [
                        "Will receive 500 from Shujaat",
                        "Ashfaq se 100 loon ga",
                        "Hamza se 5000 lene he",
                        "Kashif se 5000 milay ga",
                      ],
                      onTest: (ex) => () => testExample(ex)),
                ] else ...[
                  _buildHintSection(
                      sheetContext,
                      "Expenses (Basic)",
                      [
                        "Spent 500 on Fuel",
                        "Paid 1000 on Dinner",
                        "Expense 250 on Snacks",
                      ],
                      onTest: (ex) => () => testExample(ex)),
                  _buildHintSection(
                      sheetContext,
                      "Income (Basic)",
                      [
                        "2000 Received from Kashif (Payable)",
                        "5000 Income from Salary",
                        "Received 1000 for Bonus",
                        "Will receive 2000 from Ali",
                      ],
                      onTest: (ex) => () => testExample(ex)),
                  _buildHintSection(
                      sheetContext,
                      "Giving/Lending Money",
                      [
                        "Gave 1000 to Ashfaq",
                        "Paid for Usman 500",
                      ],
                      onTest: (ex) => () => testExample(ex)),
                  _buildHintSection(
                      sheetContext,
                      "Borrowing Money",
                      [
                        "1000 paid by Ashfaq for dinner",
                        "Will give 5000 to Ashfaq for dinner",
                      ],
                      onTest: (ex) => () => testExample(ex)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHintSection(
      BuildContext context, String title, List<String> examples,
      {required VoidCallback Function(String example) onTest}) {
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 18, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(ex,
                          style: const TextStyle(fontStyle: FontStyle.italic))),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onTest(ex),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: activeCashbookColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: activeCashbookColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Test',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: activeCashbookColor,
                        ),
                      ),
                    ),
                  ),
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
    final activeCashbook = ref.watch(activeCashbookProvider);
    final activeCashbookBackColor = activeCashbook.backColor(context);
    final activeCashbookForeColor = activeCashbook.foreColor(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.voiceAdd),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Opacity(
              opacity: (_isProcessing && _parsedResult == null) ? 0 : 1.0,
              child: AbsorbPointer(
                absorbing: _isProcessing && _parsedResult == null,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _listen,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: _isListening
                                ? Colors.red
                                : activeCashbookForeColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_isListening
                                        ? Colors.red
                                        : activeCashbookForeColor)
                                    .withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening ? Icons.stop : Icons.mic,
                            color: _isListening
                                ? Colors.white
                                : activeCashbookBackColor,
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isListening ? l10n.listening : l10n.tapToSpeak,
                        style: theme.textTheme.titleMedium,
                      ),

                      const SizedBox(height: 20),
                      // Instruction card: reflect actual mode (Smart only when model + quota)
                      Consumer(
                        builder: (context, ref, _) {
                          final limitsAsync =
                              ref.watch(smartParsingLimitsProvider);
                          final effectiveSmartMode = _modelDownloaded &&
                              limitsAsync.maybeWhen(
                                data: (limits) => limits.canAdd,
                                orElse: () => false,
                              );
                          final simpleDueToQuota = _modelDownloaded &&
                              limitsAsync.maybeWhen(
                                data: (limits) => !limits.canAdd,
                                orElse: () => false,
                              );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: _showHints,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: effectiveSmartMode
                                        ? Colors.blue.withValues(alpha: 0.08)
                                        : Colors.grey.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: effectiveSmartMode
                                          ? Colors.blue.withValues(alpha: 0.25)
                                          : Colors.grey.withValues(alpha: 0.25),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        effectiveSmartMode
                                            ? Icons.auto_awesome
                                            : Icons.rule_rounded,
                                        size: 22,
                                        color: effectiveSmartMode
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          effectiveSmartMode
                                              ? l10n.voiceInstructionSmart
                                              : l10n.voiceInstructionBasic,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: effectiveSmartMode
                                                ? Colors.blue.shade800
                                                : theme.colorScheme
                                                    .onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: effectiveSmartMode
                                            ? Colors.blue
                                            : Colors.grey,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // When in simple mode due to quota expired, prompt for Smart extraction (same as receipt screen)
                              if (simpleDueToQuota) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          l10n.useSmartExtractionForBetterResults,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const PremiumScreen(),
                                            ),
                                          );
                                        },
                                        child: Text(l10n.getIt),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),

                      if (_isDownloading) ...[
                        const SizedBox(height: 24),
                        Text(
                          "Downloading Smart AI Model...",
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            backgroundColor:
                                activeCashbookBackColor.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                activeCashbookForeColor),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Transcript Field
                      if (_text.isNotEmpty || _isProcessing)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.whatWeHeard,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(l10n.includeTextAsDescription,
                                    style: theme.textTheme.bodySmall),
                                Transform.scale(
                                  scale: 0.7,
                                  child: Switch(
                                    value: _includeTextAsDescription,
                                    onChanged: (val) => setState(
                                        () => _includeTextAsDescription = val),
                                    activeThumbColor: activeCashbookForeColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _transcriptController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () =>
                                      _processText(_transcriptController.text),
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 32),

                      // Review Section
                      if (_parsedResult != null || _isProcessing)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Opacity(
                              opacity: _isProcessing ? 0.3 : 1.0,
                              child: AbsorbPointer(
                                absorbing: _isProcessing,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border:
                                        Border.all(color: theme.dividerColor),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Extraction badge (centered)
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          margin:
                                              const EdgeInsets.only(bottom: 6),
                                          decoration: BoxDecoration(
                                            color: _usedAi
                                                ? Colors.blue
                                                    .withValues(alpha: 0.1)
                                                : Colors.grey
                                                    .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                  _usedAi
                                                      ? Icons.auto_awesome
                                                      : Icons.rule_rounded,
                                                  size: 14,
                                                  color: _usedAi
                                                      ? Colors.blue
                                                      : Colors.grey),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  _usedAi
                                                      ? l10n.smartExtraction
                                                      : l10n.basicExtraction,
                                                  style: theme
                                                      .textTheme.labelSmall
                                                      ?.copyWith(
                                                    color: _usedAi
                                                        ? Colors.blue
                                                        : Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Quota chip (small, below badge)
                                      Consumer(
                                        builder: (context, ref, _) {
                                          final limitsAsync = ref.watch(
                                              smartParsingLimitsProvider);
                                          return limitsAsync.when(
                                            data: (limits) {
                                              return Center(
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 16),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme
                                                        .surfaceContainerHighest
                                                        .withValues(alpha: 0.8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    limits.isUnlimited
                                                        ? l10n
                                                            .smartExtractionUnlimited
                                                        : l10n
                                                            .smartExtractionQuotaLeft(
                                                            limits
                                                                .monthlyRemaining,
                                                            limits.monthlyTotal,
                                                          ),
                                                    style: theme
                                                        .textTheme.labelSmall
                                                        ?.copyWith(
                                                      color: theme.colorScheme
                                                          .onSurfaceVariant,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            loading: () =>
                                                const SizedBox(height: 32),
                                            error: (_, __) =>
                                                const SizedBox(height: 32),
                                          );
                                        },
                                      ),

                                      // Receivable/Payable badge centered below quota (when relationship present)
                                      if (_parsedResult?.paidRelationship !=
                                          null) ...[
                                        Center(
                                          child: _buildRelationshipBadge(
                                              theme, l10n),
                                        ),
                                        const SizedBox(height: 12),
                                      ],

                                      _buildDetailRow(
                                          l10n.amount,
                                          "${_parsedResult?.amount ?? 0}",
                                          theme,
                                          valueColor:
                                              (_parsedResult?.type == 'INCOME')
                                                  ? AppColors.incomeColor
                                                  : AppColors.expenseColor),
                                      _buildDetailRow(
                                          l10n.type,
                                          _parsedResult?.type == "INCOME"
                                              ? l10n.income
                                              : l10n.expense,
                                          theme,
                                          valueColor:
                                              (_parsedResult?.type == 'INCOME')
                                                  ? AppColors.incomeColor
                                                  : AppColors.expenseColor),

                                      // Category selection
                                      _buildCategorySuggestions(
                                          theme, activeCashbook, l10n),

                                      // Contact selection
                                      _buildContactSuggestions(
                                          theme, activeCashbook, l10n),

                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        child: GradientButton(
                                          onPressed: () async {
                                            if (_usedAi) {
                                              await ref
                                                  .read(
                                                      usageTrackerRepositoryProvider)
                                                  .incrementSmartParsingCount();
                                            }
                                            if (!mounted) return;
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddTransactionScreen(
                                                  initialAmount:
                                                      _parsedResult?.amount,
                                                  initialDescription:
                                                      _includeTextAsDescription
                                                          ? (_transcriptController
                                                                  .text
                                                                  .isNotEmpty
                                                              ? _transcriptController
                                                                  .text
                                                              : _parsedResult
                                                                  ?.description)
                                                          : null,
                                                  initialType:
                                                      _parsedResult?.type ??
                                                          "EXPENSE",
                                                  initialCategoryName:
                                                      _selectedCategoryName,
                                                  initialCategoryColor:
                                                      _selectedCategoryColor,
                                                  initialCategoryIcon:
                                                      _selectedCategoryIcon,
                                                  initialContactName:
                                                      _selectedContactName,
                                                  initialRelationship:
                                                      _parsedResult
                                                          ?.paidRelationship,
                                                ),
                                              ),
                                            );
                                          },
                                          label: l10n.proceed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (_isProcessing)
                              Positioned.fill(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const AppLoadingIndicator(size: 60),
                                      const SizedBox(height: 16),
                                      Text(
                                        l10n.processing,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isProcessing && _parsedResult == null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLoadingIndicator(size: 80),
                  const SizedBox(height: 24),
                  Text(
                    l10n.processing,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRelationshipBadge(ThemeData theme, AppLocalizations l10n) {
    final rel = _parsedResult?.paidRelationship;
    if (rel == null) return const SizedBox.shrink();
    final isReceivable = rel == 'PAID_FOR' || rel == 'WILL_RECEIVE';
    final color =
        isReceivable ? AppColors.receivableColor : AppColors.payableColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        isReceivable ? l10n.receivable : l10n.payable,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySuggestions(
      ThemeData theme, Cashbook activeCashbook, AppLocalizations l10n) {
    final activeCashbookBackColor = activeCashbook.backColor(context);
    final activeCashbookForeColor = activeCashbook.foreColor(context);

    final type = _parsedResult?.type ?? 'EXPENSE';
    final categoriesAsync = ref.watch(categoriesByTypeProvider(type));

    return categoriesAsync.when(
      data: (categories) {
        final List<db.Category> suggested = [];
        final extractedName = _parsedResult?.categoryName?.toLowerCase();

        if (extractedName != null) {
          // Find similar categories (fuzzy so e.g. misheard names still match)
          suggested.addAll(categories.where((c) {
            return stringsMatchFuzzy(extractedName!, c.name);
          }));
          // Sort by similarity so best match first
          suggested.sort((a, b) {
            final scoreA = fuzzyScore(extractedName!, a.name);
            final scoreB = fuzzyScore(extractedName!, b.name);
            return scoreB.compareTo(scoreA);
          });
        }

        if (suggested.isEmpty && _parsedResult?.categoryName == null) {
          return const SizedBox.shrink();
        }

        // Auto-select first suggested if nothing selected yet or if selection not in suggested
        if (_selectedCategoryName == null && suggested.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _selectedCategoryName = suggested.first.name;
              _selectedCategoryColor = suggested.first.color;
              _selectedCategoryIcon = suggested.first.icon;
            });
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              l10n.category,
              style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Extracted one (if not in suggested)
                if (_parsedResult?.categoryName != null &&
                    !suggested.any((c) =>
                        c.name.toLowerCase() ==
                        _parsedResult!.categoryName!.toLowerCase()))
                  _buildSuggestionChip(
                      label: _parsedResult!.categoryName!,
                      isSelected:
                          _selectedCategoryName == _parsedResult!.categoryName,
                      onPressed: () => setState(() {
                            _selectedCategoryName = _parsedResult!.categoryName;
                            _selectedCategoryColor = null;
                            _selectedCategoryIcon = null;
                          }),
                      activeForeColor: activeCashbookBackColor,
                      activeBackColor: activeCashbookForeColor),
                // Suggested ones from list
                ...suggested.map((c) {
                  final isSelected = _selectedCategoryName == c.name;
                  Color chipColor = activeCashbookForeColor;
                  if (c.color != null) {
                    try {
                      chipColor =
                          Color(int.parse(c.color!.replaceFirst('#', '0xFF')));
                    } catch (_) {}
                  }

                  return _buildSuggestionChip(
                    label: c.name,
                    isSelected: isSelected,
                    onPressed: () => setState(() {
                      _selectedCategoryName = c.name;
                      _selectedCategoryColor = c.color;
                      _selectedCategoryIcon = c.icon;
                    }),
                    activeBackColor: chipColor,
                    activeForeColor: isSelected ? Colors.white : chipColor,
                    avatar: c.icon != null
                        ? Icon(
                            IconHelper.getIconData(c.icon),
                            size: 14,
                            color: isSelected ? Colors.white : chipColor,
                          )
                        : null,
                  );
                }),
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildContactSuggestions(
      ThemeData theme, Cashbook activeCashbook, AppLocalizations l10n) {
    final contactsAsync = ref.watch(contactsListProvider);
    final activeCashbookBackColor = activeCashbook.backColor(context);
    final activeCashbookForeColor = activeCashbook.foreColor(context);

    return contactsAsync.when(
      data: (contacts) {
        final List<db.Contact> suggested = [];
        final extractedName = _parsedResult?.contactName?.toLowerCase();

        if (extractedName != null) {
          // Find similar contacts (fuzzy so e.g. "Afsar" matches "Absar Ahmed")
          suggested.addAll(contacts.where((c) {
            return stringsMatchFuzzy(extractedName!, c.name);
          }));
          // Sort by similarity so best match first
          suggested.sort((a, b) {
            final scoreA = fuzzyScore(extractedName!, a.name);
            final scoreB = fuzzyScore(extractedName!, b.name);
            return scoreB.compareTo(scoreA);
          });
        }

        if (suggested.isEmpty && _parsedResult?.contactName == null) {
          return const SizedBox.shrink();
        }

        // Auto-select first suggested if nothing selected yet
        if (_selectedContactName == null && suggested.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _selectedContactName = suggested.first.name;
            });
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              l10n.contact,
              style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Extracted one
                if (_parsedResult?.contactName != null &&
                    !suggested.any((c) =>
                        c.name.toLowerCase() ==
                        _parsedResult!.contactName!.toLowerCase()))
                  _buildSuggestionChip(
                    label: _parsedResult!.contactName!,
                    isSelected:
                        _selectedContactName == _parsedResult!.contactName,
                    onPressed: () => setState(() {
                      _selectedContactName = _parsedResult!.contactName;
                    }),
                    activeBackColor: activeCashbookForeColor,
                    activeForeColor: activeCashbookBackColor,
                  ),
                // Suggested ones
                ...suggested.map((c) {
                  final isSelected = _selectedContactName == c.name;
                  Color contactColor = activeCashbookForeColor;

                  return _buildSuggestionChip(
                    label: c.name,
                    isSelected: isSelected,
                    onPressed: () => setState(() {
                      _selectedContactName = c.name;
                    }),
                    activeBackColor: contactColor,
                    activeForeColor: activeCashbookBackColor,
                    avatar: CircleAvatar(
                      radius: 8,
                      backgroundColor: isSelected
                          ? Colors.white.withValues(alpha: 0.3)
                          : contactColor.withValues(alpha: 0.1),
                      child: Text(
                        c.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : contactColor,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSuggestionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
    required Color activeBackColor,
    required Color activeForeColor,
    Widget? avatar,
  }) {
    return ActionChip(
      avatar: avatar,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? activeForeColor : activeForeColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onPressed: onPressed,
      backgroundColor: isSelected
          ? activeBackColor
          : activeBackColor.withValues(alpha: 0.05),
      side: BorderSide(
        color: isSelected
            ? activeForeColor
            : activeForeColor.withValues(alpha: 0.2),
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
