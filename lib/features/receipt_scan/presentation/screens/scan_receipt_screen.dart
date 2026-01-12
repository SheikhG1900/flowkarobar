import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/receipt_scan/domain/receipt_parser.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';

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
    _dateController = TextEditingController(
      text: DateFormat.yMMMd().format(_selectedDate),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
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
        ToastUtils.showErrorToast(context, 'Error picking image: $e');
      }
    }
  }

  Future<void> _scanReceipt() async {
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
          _dateController.text = DateFormat.yMMMd().format(_selectedDate);
        }
        _isScanning = false;
      });

      textRecognizer.close();
    } catch (e) {
      setState(() => _isScanning = false);
      if (mounted) {
        ToastUtils.showErrorToast(context, 'Error scanning receipt: $e');
      }
    }
  }

  void _proceedToAddTransaction() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ToastUtils.showErrorToast(context, 'Please enter a valid amount');
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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        backgroundColor: AppColors.brightCyan,
        foregroundColor: Colors.white,
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
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No receipt selected',
                      style: TextStyle(color: Colors.grey.shade600),
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
                    onPressed: _isScanning ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
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
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Scanning receipt...'),
                  ],
                ),
              ),

            // Editable Fields
            if (_receiptData != null && !_isScanning) ...[
              Text(
                'Review & Edit',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Merchant Field
              TextField(
                controller: _merchantController,
                decoration: const InputDecoration(
                  labelText: 'Merchant Name',
                  prefixIcon: Icon(Icons.store),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Amount Field with Chips
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Total Amount',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
              ),
              // Suggestion Chips for Amount
              if (_receiptData?.amountCandidates.isNotEmpty == true && _receiptData!.amountCandidates.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    children: _receiptData!.amountCandidates.map((amt) {
                      final isSelected = _amountController.text == amt.toStringAsFixed(2);
                      return ActionChip(
                        label: Text('$currencySymbol${amt.toStringAsFixed(2)}'),
                        backgroundColor: isSelected 
                            ? AppColors.brightCyan.withValues(alpha: 0.1)
                            : null,
                        side: isSelected 
                            ? const BorderSide(color: AppColors.brightCyan)
                            : null,
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
                      _dateController.text = DateFormat.yMMMd().format(picked);
                    });
                  }
                },
                child: IgnorePointer(
                  child: TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              // Suggestion Chips for Date
              if (_receiptData?.dateCandidates.isNotEmpty == true && _receiptData!.dateCandidates.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    children: _receiptData!.dateCandidates.map((date) {
                      final isSelected = DateFormat.yMMMd().format(_selectedDate) == 
                                        DateFormat.yMMMd().format(date);
                      return ActionChip(
                        label: Text(DateFormat.yMMMd().format(date)),
                        backgroundColor: isSelected 
                            ? AppColors.brightCyan.withValues(alpha: 0.1)
                            : null,
                        side: isSelected 
                            ? const BorderSide(color: AppColors.brightCyan)
                            : null,
                        onPressed: () {
                          setState(() {
                            _selectedDate = date;
                            _dateController.text = DateFormat.yMMMd().format(date);
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
                gradient: AppColors.primaryGradient,
                label: 'Proceed to Add Transaction',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
