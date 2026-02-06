import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/receipt_scan/domain/receipt_parser.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';

class ScanReceiptScreen extends ConsumerStatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  ConsumerState<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends ConsumerState<ScanReceiptScreen> {
  final ImagePicker _picker = ImagePicker();
  final ReceiptParser _parser = ReceiptParser();

  File? _image;
  bool _isScanning = false;
  ReceiptData? _receiptData;

  // Editable fields for review
  late TextEditingController _amountController;
  late TextEditingController _merchantController;
  late TextEditingController _dateController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _merchantController = TextEditingController();
    _dateController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dateController.text = AppDateFormatter.formatDate(_selectedDate);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    try {
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

      // Parse the receipt
      final receiptData = _parser.parse(recognizedText);

      setState(() {
        _receiptData = receiptData;
        _amountController.text = receiptData.amount?.toStringAsFixed(2) ?? '';
        _merchantController.text = receiptData.merchantName ?? '';
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencySymbol = ref.watch(currencySymbolProvider);
    final l10n = AppLocalizations.of(context)!;
    final activeCashbookColor = ref.watch(activeCashbookProvider).color;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanReceipt),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
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
        child: _isScanning
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(activeCashbookColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.scanningReceipt,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : _receiptData != null
                ? Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Amount Input (Large & Prominent)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: activeCashbookColor.withValues(
                                        alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    l10n.totalAmount,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _amountController,
                                    textAlign: TextAlign.center,
                                    style:
                                        theme.textTheme.displayLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: activeCashbookColor,
                                    ),
                                    decoration: InputDecoration(
                                      prefixText: '$currencySymbol ',
                                      prefixStyle: theme.textTheme.displayMedium
                                          ?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                      border: InputBorder.none,
                                      hintText: l10n.amountHint,
                                      hintStyle: theme.textTheme.displayLarge
                                          ?.copyWith(
                                        color:
                                            Colors.grey.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                  ),
                                ],
                              ),
                            ),
                            // Amount Chips
                            if (_receiptData?.amountCandidates.isNotEmpty ==
                                    true &&
                                _receiptData!.amountCandidates.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children:
                                      _receiptData!.amountCandidates.map((amt) {
                                    final isSelected = _amountController.text ==
                                        amt.toStringAsFixed(2);
                                    return _buildSuggestionChip(
                                      label:
                                          '$currencySymbol${amt.toStringAsFixed(2)}',
                                      isSelected: isSelected,
                                      activeColor: activeCashbookColor,
                                      isDark: isDark,
                                      onPressed: () => setState(() =>
                                          _amountController.text =
                                              amt.toStringAsFixed(2)),
                                    );
                                  }).toList(),
                                ),
                              ),
                            const SizedBox(height: 24),
                            // Merchant Name
                            TextFormField(
                              controller: _merchantController,
                              decoration: InputDecoration(
                                labelText: l10n.merchantName,
                                hintText: l10n.merchantName,
                                prefixIcon: const Icon(Icons.store_rounded),
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
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
                                      colorScheme: theme.colorScheme.copyWith(
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
                                  children:
                                      _receiptData!.dateCandidates.map((date) {
                                    final isSelected =
                                        AppDateFormatter.formatDate(
                                                _selectedDate) ==
                                            AppDateFormatter.formatDate(date);
                                    return _buildSuggestionChip(
                                      label: AppDateFormatter.formatDate(date),
                                      isSelected: isSelected,
                                      activeColor: activeCashbookColor,
                                      isDark: isDark,
                                      onPressed: () => setState(() {
                                        _selectedDate = date;
                                        _dateController.text =
                                            AppDateFormatter.formatDate(date);
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
                          bottom: MediaQuery.of(context).padding.bottom + 16,
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
                          label: l10n.proceedToAddTransaction,
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
                          bottom: MediaQuery.of(context).padding.bottom + 16,
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
                                onPressed: () => _pickImage(ImageSource.camera),
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
    );
  }

  Widget _buildSuggestionChip({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required bool isDark,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return ActionChip(
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
}
