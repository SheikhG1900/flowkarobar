import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/receipt_scan/domain/receipt_ai_parser.dart';
import 'package:flowpaisa/features/currencies/presentation/providers/currencies_provider.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:flowpaisa/features/transactions/domain/models/parsed_transaction_input.dart';
import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'
    show InputImage, TextRecognizer;
import 'package:image_picker/image_picker.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/receipt_scan/domain/receipt_parser.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/core/database/database.dart' as db;
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';

class ScanReceiptScreen extends ConsumerStatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  ConsumerState<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends ConsumerState<ScanReceiptScreen> {
  final ImagePicker _picker = ImagePicker();
  final ReceiptParser _parser = ReceiptParser();
  final ReceiptAiParser _aiParser = ReceiptAiParser();
  final EntityExtractorModelManager _modelManager =
      EntityExtractorModelManager();

  File? _image;
  bool _isScanning = false;
  bool _usedAi = false;
  bool _isDownloading = false;
  bool _modelDownloaded = false;
  bool _showRuleBasedCandidates = false;
  ReceiptData? _receiptData;
  ReceiptData? _aiRawResult;
  ReceiptData? _ruleBasedRawResult;

  // Editable fields for review
  late TextEditingController _amountController;
  late TextEditingController _merchantController;
  late TextEditingController _dateController;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryName;
  String? _selectedCategoryColor;
  String? _selectedCategoryIcon;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _merchantController = TextEditingController();
    _dateController = TextEditingController();
    _checkModelDownloaded();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dateController.text = AppDateFormatter.formatDate(_selectedDate);
      }
    });
  }

  Future<void> _checkModelDownloaded() async {
    final downloaded = await _modelManager
        .isModelDownloaded(EntityExtractorLanguage.english.name);
    if (mounted) setState(() => _modelDownloaded = downloaded);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _dateController.dispose();
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
        await _checkModelDownloaded();
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

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    if (kIsWeb) {
      ToastUtils.showErrorToast(context, ref, "Scanning not available on Web");
      return;
    }
    try {
      if (source == ImageSource.camera) {
        // Use Document Scanner for Camera
        final options = DocumentScannerOptions(
          mode: ScannerMode.filter,
          pageLimit: 1,
        );
        final documentScanner = DocumentScanner(options: options);
        final result = await documentScanner.scanDocument();
        documentScanner.close();

        final images = result.images;
        if (images != null && images.isNotEmpty) {
          setState(() {
            _image = File(images.first);
            _isScanning = true;
          });
          await _scanReceipt();
        }
        return;
      }

      // Use Image Picker for Gallery
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isScanning = true;
        });

        await _scanReceipt();
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorPickingImage(e.toString()));
      }
    }
  }

  Future<void> _scanReceipt() async {
    final l10n = AppLocalizations.of(context)!;
    if (_image == null) return;

    try {
      final inputImage = InputImage.fromFile(_image!);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Get all active currency symbols from database
      final currencies =
          await ref.read(currenciesRepositoryProvider).getAllCurrencies();
      final dbSymbols = currencies.map((c) => c.symbol).toList();

      // 1. Try AI Parser first
      ParsedTransactionInput? aiResult;
      bool usedAi = false;

      // Check if model is downloaded and limit not reached
      final isModelReady = await _modelManager
          .isModelDownloaded(EntityExtractorLanguage.english.name);
      final limits = await PremiumGate.getSmartParsingLimits(ref);

      // On first scan, download ML Kit model in background for next time (no explicit button).
      if (!isModelReady && !_isDownloading) {
        _startDownload();
      }

      if (isModelReady && limits.canAdd) {
        aiResult = await _aiParser.parse(
          recognizedText.text,
          customSymbols: dbSymbols,
          recognizedText: recognizedText,
        );
        if (aiResult != null && !aiResult.isEmpty) {
          usedAi = true;
          // Increment usage
          await ref
              .read(usageTrackerRepositoryProvider)
              .incrementSmartParsingCount();
        }
      } else if (isModelReady && !limits.canAdd) {
        if (mounted) {
          ToastUtils.showWarningToast(
              context, ref, l10n.smartParsingLimitReached);
        }
      }

      // 2. Fallback to rule-based parser if AI failed or not available
      final ruleBasedData = _parser.parse(recognizedText);
      
      final receiptData = usedAi
          ? ReceiptData(
              merchantName: aiResult!.description,
              amount: aiResult.amount,
              date: aiResult.date,
              categoryName: aiResult.categoryName,
              // AI candidates only (with labels when available)
              amountCandidates: [...aiResult.amountCandidates],
              descriptionCandidates: {
                ...aiResult.descriptionCandidates,
                ...ruleBasedData.descriptionCandidates,
              }.toList(),
            )
          : ruleBasedData;

      setState(() {
        _receiptData = receiptData;
        _aiRawResult = usedAi ? receiptData : null;
        _ruleBasedRawResult = ruleBasedData;
        _usedAi = usedAi;
        _showRuleBasedCandidates = false; // Reset collapse state
        _amountController.text = receiptData.amount?.toStringAsFixed(2) ?? '';
        // Auto-select most relevant description from suggested list (first candidate) or merchant
        _merchantController.text = receiptData.descriptionCandidates.isNotEmpty
            ? receiptData.descriptionCandidates.first
            : (receiptData.merchantName ?? '');
        _selectedCategoryName = receiptData.categoryName;
        _selectedCategoryColor = null;
        _selectedCategoryIcon = null;
        if (receiptData.date != null) {
          _selectedDate = receiptData.date!;
          _dateController.text = AppDateFormatter.formatDate(_selectedDate);
        }
        _isScanning = false;
      });

      textRecognizer.close();
    } catch (e) {
      setState(() => _isScanning = false);
      if (mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorScanningReceipt(e.toString()));
      }
    }
  }

  void _proceedToAddTransaction() {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ToastUtils.showErrorToast(context, ref, l10n.pleaseEnterValidNumber);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          initialAmount: amount,
          initialDescription: _merchantController.text.isNotEmpty
              ? _merchantController.text
              : null,
          initialDate: _selectedDate,
          initialCategoryName: _selectedCategoryName,
          initialCategoryColor: _selectedCategoryColor,
          initialCategoryIcon: _selectedCategoryIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencySymbol = ref.watch(currencySymbolProvider);
    final decimalPlaces = ref.watch(currencyDecimalPlacesProvider);
    final l10n = AppLocalizations.of(context)!;
    final activeCashbookColor = ref.watch(activeCashbookProvider).color;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanReceipt),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              activeCashbookColor.withValues(alpha: 0.05),
              Colors.transparent
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Opacity(
              opacity: (_isScanning && _receiptData == null) ? 0 : 1.0,
              child: AbsorbPointer(
                absorbing: _isScanning && _receiptData == null,
                child: _receiptData != null
                    ? Column(
                        children: [
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                Stack(
                                  children: [
                                    Opacity(
                                      opacity: _isScanning ? 0.3 : 1.0,
                                      child: AbsorbPointer(
                                        absorbing: _isScanning,
                                        child: Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: theme.cardColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: activeCashbookColor
                                                    .withValues(alpha: 0.1),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              // Extraction badge (centered)
                                              Center(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6),
                                                  margin: const EdgeInsets.only(
                                                      bottom: 6),
                                                  decoration: BoxDecoration(
                                                    color: _usedAi
                                                        ? Colors.blue.withValues(
                                                            alpha: 0.1)
                                                        : Colors.grey.withValues(
                                                            alpha: 0.1),
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
                                                            : Colors.grey,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        _usedAi
                                                            ? l10n.smartExtraction
                                                            : l10n.basicExtraction,
                                                        style: theme
                                                            .textTheme.labelSmall
                                                            ?.copyWith(
                                                          color: _usedAi
                                                              ? Colors.blue
                                                              : Colors.grey,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // Quota chip (small, below badge)
                                              Consumer(
                                                builder: (context, ref, _) {
                                                  final limitsAsync =
                                                      ref.watch(smartParsingLimitsProvider);
                                                  return limitsAsync.when(
                                                    data: (limits) {
                                                      return Center(
                                                        child: Container(
                                                          margin: const EdgeInsets.only(bottom: 16),
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: theme.colorScheme.surfaceContainerHighest
                                                                .withValues(alpha: 0.8),
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
                                                              fontSize: 11,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    loading: () => const SizedBox(height: 32),
                                                    error: (_, __) => const SizedBox(height: 32),
                                                  );
                                                },
                                              ),
                                              // When simple extraction was used, prompt for Smart extraction
                                              if (!_usedAi && _receiptData != null)
                                                Container(
                                                  margin: const EdgeInsets.only(bottom: 16),
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          l10n.useSmartExtractionForBetterResults,
                                                          style: theme.textTheme.bodySmall?.copyWith(
                                                            color: theme.colorScheme.onSurface,
                                                          ),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => const PremiumScreen(),
                                                            ),
                                                          );
                                                        },
                                                        child: Text(l10n.getIt),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              Text(
                                                l10n.totalAmount,
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              TextFormField(
                                                controller: _amountController,
                                                textAlign: TextAlign.center,
                                                style: theme
                                                    .textTheme.displayLarge
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: activeCashbookColor,
                                                ),
                                                decoration: InputDecoration(
                                                  prefixText:
                                                      '$currencySymbol ',
                                                  prefixStyle: theme
                                                      .textTheme.displayMedium
                                                      ?.copyWith(
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                  border: InputBorder.none,
                                                  hintText: l10n.amountHint,
                                                  hintStyle: theme
                                                      .textTheme.displayLarge
                                                      ?.copyWith(
                                                    color: Colors.grey
                                                        .withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_isScanning)
                                      Positioned.fill(
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const AppLoadingIndicator(
                                                  size: 60),
                                              const SizedBox(height: 16),
                                              Text(
                                                l10n.scanningReceipt,
                                                style: theme
                                                    .textTheme.labelMedium
                                                    ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                if (_isDownloading) ...[
                                  const SizedBox(height: 24),
                                  Text(
                                    "Downloading Smart AI Model...",
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: LinearProgressIndicator(
                                      backgroundColor: activeCashbookColor
                                          .withValues(alpha: 0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          activeCashbookColor),
                                    ),
                                  ),
                                ],

                                // Amount candidates grouped by label (one card per label)
                                if (_receiptData?.amountCandidates.isNotEmpty ==
                                        true &&
                                    _receiptData!.amountCandidates.length >= 1)
                                  _buildAmountCandidatesByLabel(
                                    theme,
                                    _receiptData!.amountCandidates,
                                    currencySymbol,
                                    decimalPlaces,
                                    activeCashbookColor,
                                    isDark,
                                    l10n,
                                  ),

                                // Rule-based (Simple Extraction) Candidates - Collapsed by default
                                if (_usedAi &&
                                    _ruleBasedRawResult != null &&
                                    _ruleBasedRawResult!
                                        .amountCandidates.isNotEmpty)
                                  _buildRuleBasedSection(
                                      theme, currencySymbol, decimalPlaces, isDark, activeCashbookColor, l10n),

                                const SizedBox(height: 24),
                                // Description (from receipt / merchant)
                                TextFormField(
                                  controller: _merchantController,
                                  decoration: InputDecoration(
                                    labelText: l10n.description,
                                    hintText: l10n.descriptionHint,
                                    prefixIcon:
                                        const Icon(Icons.description_rounded),
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                ),
                                // Description suggestion chips from scanned text
                                if (_receiptData
                                        ?.descriptionCandidates.isNotEmpty ==
                                    true)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: _receiptData!
                                          .descriptionCandidates
                                          .map((desc) {
                                        final isSelected =
                                            _merchantController.text == desc;
                                        return _buildSuggestionChip(
                                          label: desc,
                                          isSelected: isSelected,
                                          activeColor: activeCashbookColor,
                                          isDark: isDark,
                                          onPressed: () => setState(() =>
                                              _merchantController.text = desc),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                const SizedBox(height: 24),
                                // Category suggestions (from description + parsed category)
                                _buildCategorySuggestions(
                                    theme, isDark, activeCashbookColor, l10n),
                                const SizedBox(height: 24),
                                // Date Field
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                      builder: (context, child) => Theme(
                                        data: theme.copyWith(
                                          colorScheme: theme.colorScheme
                                              .copyWith(
                                                  primary: activeCashbookColor),
                                        ),
                                        child: child!,
                                      ),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _selectedDate = picked;
                                        _dateController.text =
                                            AppDateFormatter.formatDate(picked);
                                      });
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.dividerColor,
                                      ),
                                    ),
                                    child: IgnorePointer(
                                      child: TextFormField(
                                        controller: _dateController,
                                        decoration: InputDecoration(
                                          labelText: l10n.date,
                                          prefixIcon: const Icon(
                                              Icons.calendar_today_rounded),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Date Chips
                                if (_receiptData?.dateCandidates.isNotEmpty ==
                                        true &&
                                    _receiptData!.dateCandidates.length > 1)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: _receiptData!.dateCandidates
                                          .map((date) {
                                        final isSelected = AppDateFormatter
                                                .formatDate(_selectedDate) ==
                                            AppDateFormatter.formatDate(date);
                                        return _buildSuggestionChip(
                                          label:
                                              AppDateFormatter.formatDate(date),
                                          isSelected: isSelected,
                                          activeColor: activeCashbookColor,
                                          isDark: isDark,
                                          onPressed: () => setState(() {
                                            _selectedDate = date;
                                            _dateController.text =
                                                AppDateFormatter.formatDate(
                                                    date);
                                          }),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                const SizedBox(height: 100), // Space for button
                              ],
                            ),
                          ),
                          // Docked Floating Button Panel
                          Container(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 16,
                              bottom:
                                  MediaQuery.of(context).padding.bottom + 16,
                            ),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: GradientButton(
                              onPressed: _proceedToAddTransaction,
                              label: l10n.proceed,
                              width: double.infinity,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 120,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    l10n.noReceiptSelected,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Docked Floating Button Panel
                          Container(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 16,
                              bottom:
                                  MediaQuery.of(context).padding.bottom + 16,
                            ),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GradientButton(
                                    onPressed: () =>
                                        _pickImage(ImageSource.camera),
                                    icon: Icons.camera_alt_rounded,
                                    label: l10n.camera,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GradientButton(
                                    onPressed: () =>
                                        _pickImage(ImageSource.gallery),
                                    icon: Icons.photo_library_rounded,
                                    label: l10n.gallery,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (_isScanning && _receiptData == null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppLoadingIndicator(size: 80),
                    const SizedBox(height: 24),
                    Text(
                      l10n.scanningReceipt,
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
      ),
    );
  }

  /// Categories that match the current description or the receipt's parsed category.
  List<db.Category> _getSuggestedCategories(
      List<db.Category> expenseCategories) {
    if (_receiptData == null || expenseCategories.isEmpty) return [];
    final descriptionLower = (_merchantController.text +
            ' ' +
            (_receiptData!.descriptionCandidates.join(' ')))
        .toLowerCase();
    final receiptCategoryLower = _receiptData!.categoryName?.toLowerCase();
    final matched = expenseCategories.where((db.Category c) {
      final nameLower = c.name.toLowerCase();
      return descriptionLower.contains(nameLower) ||
          (receiptCategoryLower != null && nameLower == receiptCategoryLower);
    }).toList();
    // Put parsed receipt category first if it matches
    if (receiptCategoryLower != null) {
      final exact = matched
          .where((c) => c.name.toLowerCase() == receiptCategoryLower)
          .toList();
      final rest = matched
          .where((c) => c.name.toLowerCase() != receiptCategoryLower)
          .toList();
      return [...exact, ...rest];
    }
    return matched;
  }

  Widget _buildCategorySuggestions(
    ThemeData theme,
    bool isDark,
    Color activeCashbookColor,
    AppLocalizations l10n,
  ) {
    final categoriesAsync = ref.watch(categoriesByTypeProvider('EXPENSE'));
    return categoriesAsync.when(
      data: (expenseCategories) {
        final suggested = _getSuggestedCategories(expenseCategories);
        if (suggested.isEmpty) return const SizedBox.shrink();
        // Auto-select first suggested category if current selection is not in the list
        final selectedInList =
            suggested.any((db.Category c) => c.name == _selectedCategoryName);
        if (!selectedInList) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final first = suggested.first;
            setState(() {
              _selectedCategoryName = first.name;
              _selectedCategoryColor = first.color;
              _selectedCategoryIcon = first.icon;
            });
          });
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.category,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: suggested.map((c) {
                final isSelected = _selectedCategoryName != null &&
                    c.name == _selectedCategoryName;
                Color chipColor = activeCashbookColor;
                if (c.color != null && c.color!.isNotEmpty) {
                  try {
                    chipColor =
                        Color(int.parse(c.color!.replaceFirst('#', '0xFF')));
                  } catch (_) {}
                } else {
                  chipColor = AppColors.expenseColor;
                }
                final iconColor = isSelected ? Colors.white : chipColor;
                return _buildSuggestionChip(
                  label: c.name,
                  isSelected: isSelected,
                  activeColor: chipColor,
                  isDark: isDark,
                  avatar: CategoryHelper.buildCategoryIcon(
                    c.icon,
                    iconColor,
                    true,
                    size: 18,
                  ),
                  onPressed: () => setState(() {
                    _selectedCategoryName = c.name;
                    _selectedCategoryColor = c.color;
                    _selectedCategoryIcon = c.icon;
                  }),
                );
              }).toList(),
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
    required Color activeColor,
    required bool isDark,
    Widget? avatar,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return ActionChip(
      avatar: avatar,
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
      backgroundColor: isSelected ? activeColor : theme.colorScheme.surface,
      side: BorderSide(
        color: isSelected ? activeColor : theme.dividerColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onPressed: onPressed,
    );
  }

  /// Groups amount candidates by normalized label and shows each group in a card.
  /// Same label on multiple lines (e.g. split "Net" / "Amount") is grouped together.
  Widget _buildAmountCandidatesByLabel(
    ThemeData theme,
    List<AmountCandidate> candidates,
    String currencySymbol,
    int decimalPlaces,
    Color activeCashbookColor,
    bool isDark,
    AppLocalizations l10n,
  ) {
    if (candidates.isEmpty) return const SizedBox.shrink();

    // Group by normalized label (trim + lowercase) so "Net Amount" and "net amount" merge
    final Map<String, List<AmountCandidate>> byLabel = {};
    for (final c in candidates) {
      final key = (c.label ?? '').trim().toLowerCase();
      byLabel.putIfAbsent(key, () => []).add(c);
    }

    // Within each group, dedupe by value (same amount from right/left/up/down)
    final List<Widget> cards = [];
    for (final entry in byLabel.entries) {
      final displayLabel = entry.key.isEmpty
          ? l10n.amount
          : entry.value.first.label!.trim();
      final seen = <double>{};
      final uniqueInGroup = entry.value
          .where((c) => seen.add(c.value))
          .toList();
      if (uniqueInGroup.isEmpty) continue;

      cards.add(
        SizedBox(
          width: double.infinity,
          child: Card(
            margin: const EdgeInsets.only(top: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      displayLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...uniqueInGroup.map((candidate) {
                    final formatted = AmountFormatter.formatAmount(
                        candidate.value, decimalPlaces);
                    final controllerVal = double.tryParse(
                        _amountController.text.replaceAll(',', ''));
                    final isSelected = controllerVal != null &&
                        (controllerVal - candidate.value).abs() < 0.001;
                    return _buildSuggestionChip(
                      label: '$currencySymbol$formatted',
                      isSelected: isSelected,
                      activeColor: activeCashbookColor,
                      isDark: isDark,
                      onPressed: () => setState(
                          () => _amountController.text = formatted),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cards,
      ),
    );
  }

  Widget _buildRuleBasedSection(
    ThemeData theme,
    String currencySymbol,
    int decimalPlaces,
    bool isDark,
    Color activeCashbookColor,
    AppLocalizations l10n,
  ) {
    // Filter out amounts already present in AI candidates to avoid duplicates
    final aiAmounts = _aiRawResult?.amountCandidates ?? [];
    final ruleBasedCandidates = _ruleBasedRawResult!.amountCandidates
        .where((c) => !aiAmounts.any((aiC) => aiC.value == c.value))
        .toList();

    if (ruleBasedCandidates.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        InkWell(
          onTap: () => setState(
              () => _showRuleBasedCandidates = !_showRuleBasedCandidates),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  _showRuleBasedCandidates
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.simpleExtractionResults,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    ruleBasedCandidates.length.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showRuleBasedCandidates)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 24),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ruleBasedCandidates.map((candidate) {
                final formatted = AmountFormatter.formatAmount(
                    candidate.value, decimalPlaces);
                final controllerVal = double.tryParse(
                    _amountController.text.replaceAll(',', ''));
                final isSelected = controllerVal != null &&
                    (controllerVal - candidate.value).abs() < 0.001;
                final labelText = candidate.label != null &&
                        candidate.label!.trim().isNotEmpty
                    ? '${candidate.label!.trim()}: $currencySymbol$formatted'
                    : '$currencySymbol$formatted';
                return _buildSuggestionChip(
                  label: labelText,
                  isSelected: isSelected,
                  activeColor: activeCashbookColor,
                  isDark: isDark,
                  onPressed: () => setState(
                      () => _amountController.text = formatted),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
