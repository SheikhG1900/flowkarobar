import 'dart:async';
import 'package:flowpaisa/features/businesses/domain/models/business.dart';
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
import 'package:flowpaisa/features/businesses/presentation/providers/business_provider.dart';
import 'package:flowpaisa/features/currencies/presentation/providers/currencies_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/features/voice_command/domain/voice_ai_parser.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';
import 'package:flowpaisa/core/utils/windows_dictation_stub.dart'
    if (dart.library.io) 'package:flowpaisa/core/utils/windows_dictation_io.dart';

class VoiceAddScreen extends ConsumerStatefulWidget {
  const VoiceAddScreen({super.key});

  @override
  ConsumerState<VoiceAddScreen> createState() => _VoiceAddScreenState();
}

class _VoiceAddScreenState extends ConsumerState<VoiceAddScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final VoiceCommandParser _fallbackParser = VoiceCommandParser();
  final VoiceAiParser _aiParser = VoiceAiParser();

  bool _isListening = false;
  String _text = '';
  ParsedTransactionInput? _parsedResult;
  bool _isProcessing = false;
  bool _usedAi = false;
  bool _includeTextAsDescription = true;
  String? _selectedCategoryName;
  String? _selectedCategoryColor;
  String? _selectedCategoryIcon;
  String? _selectedContactName;
  bool _hasAutoSelectedCategory = false;
  bool _hasAutoSelectedContact = false;

  late TextEditingController _transcriptController;
  final FocusNode _transcriptFocusNode = FocusNode();
  Timer? _debounceTimer;

  static const String _includeDescKey = 'voice_include_text_as_description';

  @override
  void initState() {
    super.initState();
    _transcriptController = TextEditingController();
    _loadSettings();

    // Listen to text changes to auto-process typed/dictated text
    _transcriptController.addListener(_onTextChanged);
    
    // Auto-start listening when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _listen();
      }
    });
  }

  void _onTextChanged() {
    final text = _transcriptController.text.trim();
    if (text.isEmpty) return;

    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // Debounce for 1.5 seconds of inactivity before parsing automatically
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && !_isProcessing) {
        _processText(text);
      }
    });
  }

  Future<void> _loadSettings() async {
    final prefs = ref.read(sharedPreferencesProvider);
    setState(() {
      _includeTextAsDescription = prefs.getBool(_includeDescKey) ?? true;
    });
  }

  Future<void> _saveSettings(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_includeDescKey, value);
    setState(() {
      _includeTextAsDescription = value;
    });
  }

  @override
  void dispose() {
    _transcriptController.dispose();
    _transcriptFocusNode.dispose();
    _debounceTimer?.cancel();
    _aiParser.close();
    super.dispose();
  }

  Future<void> _listen() async {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      _transcriptFocusNode.requestFocus();
      await Future.delayed(const Duration(milliseconds: 150));
      triggerWindowsDictation();
      return;
    }

    if (!_isListening) {
      try {
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
            if (mounted) {
              ToastUtils.showErrorToast(
                context,
                ref,
                "Voice recognition error: ${val.errorMsg}. Please check if your microphone is connected and enabled.",
              );
              setState(() => _isListening = false);
            }
          },
          debugLogging: kDebugMode,
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
        } else {
          if (mounted) {
            ToastUtils.showErrorToast(
              context,
              ref,
              "Voice recognition is not available on this device. Please ensure a microphone is connected and microphone permissions are granted.",
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showErrorToast(
            context,
            ref,
            "Failed to initialize voice recognition: $e",
          );
        }
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

      final limits = await PremiumGate.getSmartParsingLimits(ref);

      // Get all active currency symbols from database
      final currencies =
          await ref.read(currenciesRepositoryProvider).getAllCurrencies();
      final dbSymbols = currencies.map((c) => c.symbol).toList();

      if (limits.canAdd) {
        result = await _aiParser.parse(
          text,
          customSymbols: dbSymbols,
        );
        if (result != null && !result.isEmpty) {
          usedAi = true;
        }
      } else {
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
        _hasAutoSelectedCategory = false;
        _hasAutoSelectedContact = false;
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
    final activeCashbookColor = ref.read(activeBusinessProvider).color;
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
    final activeCashbook = ref.watch(activeBusinessProvider);
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
                      // Instruction card: reflect actual mode (Smart only when quota)
                      Consumer(
                        builder: (context, ref, _) {
                          final limitsAsync =
                              ref.watch(smartParsingLimitsProvider);
                          final effectiveSmartMode =
                              limitsAsync.maybeWhen(
                                data: (limits) => limits.canAdd,
                                orElse: () => false,
                              );
                          final simpleDueToQuota =
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

                      const SizedBox(height: 32),

                      // Transcript Field
                      if (_text.isNotEmpty || _isProcessing || (defaultTargetPlatform == TargetPlatform.windows))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (defaultTargetPlatform == TargetPlatform.windows) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        l10n.windowsDictationTip,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
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
                                    onChanged: _saveSettings,
                                    activeThumbColor: activeCashbookForeColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _transcriptController,
                              focusNode: _transcriptFocusNode,
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
                                child: _buildExtractedResultCard(theme, l10n, activeCashbook),
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

  Widget _buildExtractedResultCard(ThemeData theme, AppLocalizations l10n, Business activeCashbook) {
    final isIncome = _parsedResult?.type == 'INCOME';
    final hasContact = _selectedContactName != null && _selectedContactName!.isNotEmpty;
    final rel = _parsedResult?.paidRelationship;
    final isLinked = hasContact && rel != null;
    
    // If linked, use relationship colors, otherwise use standard income/expense colors
    Color baseColor;
    if (isLinked) {
      final isReceivable = rel == 'PAID_FOR' || rel == 'WILL_RECEIVE';
      baseColor = isReceivable ? AppColors.receivableColor : AppColors.payableColor;
    } else {
      baseColor = isIncome ? AppColors.incomeColor : AppColors.expenseColor;
    }
    
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: baseColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Badge & Quota
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildExtractionBadge(l10n),
                _buildQuotaChip(theme, l10n),
              ],
            ),
          ),

          // Main Amount & Type Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: baseColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLinked 
                      ? (rel == 'PAID_FOR' || rel == 'WILL_RECEIVE' ? Icons.call_made : Icons.call_received)
                      : (isIncome ? Icons.trending_up : Icons.trending_down),
                    color: baseColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLinked 
                          ? (rel == 'PAID_FOR' || rel == 'WILL_RECEIVE' ? l10n.receivable : l10n.payable)
                          : (isIncome ? l10n.income : l10n.expense),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        "${_parsedResult?.amount ?? 0}",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: baseColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLinked)
                  _buildRelationshipBadge(theme, l10n),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Divider(height: 1),
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionContainer(
                  theme: theme,
                  icon: Icons.category_outlined,
                  label: l10n.category,
                  child: _buildCategorySuggestions(theme, activeCashbook, l10n),
                ),
                const SizedBox(height: 16),
                _buildSectionContainer(
                  theme: theme,
                  icon: Icons.person_outline,
                  label: l10n.contact,
                  child: _buildContactSuggestions(theme, l10n),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: GradientButton(
                onPressed: () async {
                  if (_usedAi) {
                    await ref
                        .read(usageTrackerRepositoryProvider)
                        .incrementSmartParsingCount();
                  }
                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTransactionScreen(
                        initialAmount: _parsedResult?.amount,
                        initialDescription: _includeTextAsDescription
                            ? (_transcriptController.text.isNotEmpty
                                ? _transcriptController.text
                                : _parsedResult?.description)
                            : null,
                        initialType: _parsedResult?.type ?? "EXPENSE",
                        initialCategoryName: _selectedCategoryName,
                        initialCategoryColor: _selectedCategoryColor,
                        initialCategoryIcon: _selectedCategoryIcon,
                        initialContactName: _selectedContactName,
                        initialRelationship: (_selectedContactName != null && _selectedContactName!.isNotEmpty)
                            ? _parsedResult?.paidRelationship
                            : null,
                      ),
                    ),
                  );
                },
                label: l10n.proceed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractionBadge(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _usedAi ? Colors.blue.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _usedAi ? Colors.blue.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _usedAi ? Icons.auto_awesome : Icons.rule_rounded,
            size: 12,
            color: _usedAi ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            _usedAi ? l10n.smartExtraction : l10n.basicExtraction,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _usedAi ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaChip(ThemeData theme, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, _) {
        final limitsAsync = ref.watch(smartParsingLimitsProvider);
        return limitsAsync.maybeWhen(
          data: (limits) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              limits.isUnlimited
                  ? l10n.smartExtractionUnlimited
                  : l10n.smartExtractionQuotaLeft(
                      limits.monthlyRemaining,
                      limits.monthlyTotal,
                    ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildRelationshipBadge(ThemeData theme, AppLocalizations l10n) {
    final rel = _parsedResult?.paidRelationship;
    if (rel == null) return const SizedBox.shrink();
    final isReceivable = rel == 'PAID_FOR' || rel == 'WILL_RECEIVE';
    final color = isReceivable ? AppColors.receivableColor : AppColors.payableColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        isReceivable ? l10n.receivable : l10n.payable,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
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

  Widget _buildSectionContainer({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: isDark ? 0.3 : 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCategorySuggestions(
      ThemeData theme, Business activeCashbook, AppLocalizations l10n) {
    final activeCashbookForeColor = activeCashbook.foreColor(context);

    final type = _parsedResult?.type ?? 'EXPENSE';
    final categoriesAsync = ref.watch(categoriesByTypeProvider(type));

    return categoriesAsync.when(
      data: (categories) {
        final extractedName = _parsedResult?.categoryName;
        final List<({String label, double score, db.Category? category, bool isRaw})> candidates = [];

        if (extractedName != null && extractedName.isNotEmpty) {
          // 1. Add the raw extracted name
          candidates.add((
            label: extractedName,
            score: 0.99, // Just below a perfect 1.0 DB match
            category: null,
            isRaw: true,
          ));

          // 2. Add fuzzy matches from DB
          for (final c in categories) {
            final score = fuzzyScore(extractedName, c.name);
            if (score >= kFuzzyMatchThreshold) {
              candidates.add((
                label: c.name,
                score: score,
                category: c,
                isRaw: false,
              ));
            }
          }
        } else {
          // No category in command, show first few as suggestions
          for (final c in categories.take(10)) {
            candidates.add((
              label: c.name,
              score: 0.0,
              category: c,
              isRaw: false,
            ));
          }
        }

        // Sort by score descending
        candidates.sort((a, b) => b.score.compareTo(a.score));

        // Remove duplicates (prefer DB category over raw if names match)
        final seenLabels = <String>{};
        final uniqueCandidates = <({String label, double score, db.Category? category, bool isRaw})>[];
        for (final cand in candidates) {
          final normalizedLabel = cand.label.toLowerCase().trim();
          if (!seenLabels.contains(normalizedLabel)) {
            seenLabels.add(normalizedLabel);
            uniqueCandidates.add(cand);
          } else if (!cand.isRaw) {
            // If we already saw this label but this one is a DB category, replace it
            final idx = uniqueCandidates.indexWhere((element) => element.label.toLowerCase().trim() == normalizedLabel);
            if (idx != -1 && uniqueCandidates[idx].isRaw) {
              uniqueCandidates[idx] = cand;
            }
          }
        }

        if (uniqueCandidates.isEmpty) {
          return Text(
            l10n.uncategorized,
            style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          );
        }

        // Auto-select logic: pick the first one
        if (!_hasAutoSelectedCategory) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              final first = uniqueCandidates.first;
              _selectedCategoryName = first.label;
              _selectedCategoryColor = first.category?.color;
              _selectedCategoryIcon = first.category?.icon;
              _hasAutoSelectedCategory = true;
            });
          });
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: uniqueCandidates.map((cand) {
            final isSelected = _selectedCategoryName == cand.label;
            Color chipColor = activeCashbookForeColor;
            
            if (cand.category != null) {
              if (cand.category!.color != null) {
                try {
                  chipColor = Color(int.parse(cand.category!.color!.replaceFirst('#', '0xFF')));
                } catch (_) {}
              }
            } else {
              chipColor = AppColors.brightCyan;
            }

            return _buildSuggestionChip(
              label: cand.label,
              isSelected: isSelected,
              onPressed: () => setState(() {
                if (isSelected) {
                  _selectedCategoryName = null;
                  _selectedCategoryColor = null;
                  _selectedCategoryIcon = null;
                } else {
                  _selectedCategoryName = cand.label;
                  _selectedCategoryColor = cand.category?.color;
                  _selectedCategoryIcon = cand.category?.icon;
                }
              }),
              selectedColor: chipColor,
              avatar: cand.category?.icon != null
                  ? Icon(
                      IconHelper.getIconData(cand.category!.icon),
                      size: 14,
                      color: isSelected ? Colors.white : chipColor,
                    )
                  : null,
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildContactSuggestions(ThemeData theme, AppLocalizations l10n) {
    final contactsAsync = ref.watch(contactsListProvider);

    return contactsAsync.when(
      data: (contacts) {
        final extractedName = _parsedResult?.contactName;
        final List<({String label, double score, db.Contact? contact, bool isRaw})> candidates = [];

        if (extractedName != null && extractedName.isNotEmpty) {
          // 1. Add the raw extracted name
          candidates.add((
            label: extractedName,
            score: 0.99,
            contact: null,
            isRaw: true,
          ));

          // 2. Add fuzzy matches from DB
          for (final c in contacts) {
            final score = fuzzyScore(extractedName, c.name);
            if (score >= kFuzzyMatchThreshold) {
              candidates.add((
                label: c.name,
                score: score,
                contact: c,
                isRaw: false,
              ));
            }
          }
        } else {
          // No contact in command, show first few as suggestions
          for (final c in contacts.take(10)) {
            candidates.add((
              label: c.name,
              score: 0.0,
              contact: c,
              isRaw: false,
            ));
          }
        }

        // Sort by score descending
        candidates.sort((a, b) => b.score.compareTo(a.score));

        // Remove duplicates
        final seenLabels = <String>{};
        final uniqueCandidates = <({String label, double score, db.Contact? contact, bool isRaw})>[];
        for (final cand in candidates) {
          final normalizedLabel = cand.label.toLowerCase().trim();
          if (!seenLabels.contains(normalizedLabel)) {
            seenLabels.add(normalizedLabel);
            uniqueCandidates.add(cand);
          } else if (!cand.isRaw) {
            final idx = uniqueCandidates.indexWhere((element) => element.label.toLowerCase().trim() == normalizedLabel);
            if (idx != -1 && uniqueCandidates[idx].isRaw) {
              uniqueCandidates[idx] = cand;
            }
          }
        }

        if (uniqueCandidates.isEmpty) {
          return Text(
            l10n.noContactsFound,
            style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          );
        }

        // Auto-select logic: pick the first one
        if (!_hasAutoSelectedContact) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              final first = uniqueCandidates.first;
              _selectedContactName = first.label;
              _hasAutoSelectedContact = true;
            });
          });
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: uniqueCandidates.map((cand) {
            final isSelected = _selectedContactName == cand.label;
            final contactColor = AppColors.getContactColor(cand.label);

            return _buildSuggestionChip(
              label: cand.label,
              isSelected: isSelected,
              onPressed: () => setState(() {
                if (isSelected) {
                  _selectedContactName = null;
                } else {
                  _selectedContactName = cand.label;
                }
              }),
              selectedColor: contactColor,
              avatar: CircleAvatar(
                radius: 10,
                backgroundColor: isSelected ? Colors.white : contactColor,
                child: Text(
                  cand.label[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? contactColor : Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
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
    required Color selectedColor,
    Widget? avatar,
  }) {
    final theme = Theme.of(context);
    return FilterChip(
      selected: isSelected,
      avatar: avatar,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onSelected: (_) => onPressed(),
      selectedColor: selectedColor,
      checkmarkColor: Colors.white,
      showCheckmark: false,
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(
        color: isSelected ? Colors.transparent : theme.dividerColor,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
