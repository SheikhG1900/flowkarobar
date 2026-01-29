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
        ToastUtils.showErrorToast(context, ref, l10n.errorPickingImage(e.toString()));
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
        ToastUtils.showErrorToast(context, ref, l10n.errorScanningReceipt(e.toString()));
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
    final currencySymbol = ref.watch(currencySymbolProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanReceipt),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview
            if (_image != null)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_image!, fit: BoxFit.cover),
                ),
              )
            else
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.primary),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long,
                        size: 80, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noReceiptSelected,
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Camera/Gallery Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isScanning
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(l10n.camera),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isScanning
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text(l10n.gallery),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Scanning Indicator
            if (_isScanning)
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.scanningReceipt),
                  ],
                ),
              ),

            // Editable Fields
            if (_receiptData != null && !_isScanning) ...[
              Text(
                l10n.reviewAndEdit,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Merchant Field
              TextField(
                controller: _merchantController,
                decoration: InputDecoration(
                  labelText: l10n.merchantName,
                  prefixIcon: const Icon(Icons.store),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Amount Field with Chips
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.totalAmount,
                  prefixIcon: const Icon(Icons.attach_money),
                  border: const OutlineInputBorder(),
                ),
              ),
              // Suggestion Chips for Amount
              if (_receiptData?.amountCandidates.isNotEmpty == true &&
                  _receiptData!.amountCandidates.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    children: _receiptData!.amountCandidates.map((amt) {
                      final isSelected =
                          _amountController.text == amt.toStringAsFixed(2);
                      return ActionChip(
                        label: Text(
                          '$currencySymbol${amt.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        backgroundColor: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.surfaceContainerHighest,
                        side: isSelected
                            ? BorderSide(color: theme.colorScheme.primary)
                            : BorderSide(color: theme.colorScheme.outline),
                        onPressed: () {
                          setState(() {
                            _amountController.text = amt.toStringAsFixed(2);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 16),

              // Date Field with Chips
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                      _dateController.text = AppDateFormatter.formatDate(picked);
                    });
                  }
                },
                child: IgnorePointer(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: l10n.date,
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              // Suggestion Chips for Date
              if (_receiptData?.dateCandidates.isNotEmpty == true &&
                  _receiptData!.dateCandidates.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    children: _receiptData!.dateCandidates.map((date) {
                      final isSelected = AppDateFormatter.formatDate(
                          _selectedDate) ==
                          AppDateFormatter.formatDate(date);
                      return ActionChip(
                        label: Text(
                          AppDateFormatter.formatDate(date),
                          style: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        backgroundColor: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.surfaceVariant,
                        side: isSelected
                            ? BorderSide(color: theme.colorScheme.primary)
                            : BorderSide(color: theme.colorScheme.outline),
                        onPressed: () {
                          setState(() {
                            _selectedDate = date;
                            _dateController.text = AppDateFormatter.formatDate(
                                date);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 24),

              // Proceed Button
              GradientButton(
                onPressed: _proceedToAddTransaction,
                gradient: AppColors.getPrimaryGradient(theme.colorScheme.primary),
                label: l10n.proceedToAddTransaction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
