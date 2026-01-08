import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/receipt_scan/domain/receipt_parser.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';

class ScanReceiptScreen extends StatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  State<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends State<ScanReceiptScreen> {
  final ImagePicker _picker = ImagePicker();
  final ReceiptParser _parser = ReceiptParser();
  
  File? _image;
  bool _isScanning = false;
  ReceiptData? _receiptData;
  
  // Editable fields for review
  late TextEditingController _amountController;
  late TextEditingController _merchantController;
  late TextEditingController _categoryController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _merchantController = TextEditingController();
    _categoryController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _image = File(image.path);
          _isScanning = true;
          _receiptData = null;
        });
        
        await _scanImage(_image!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
      setState(() => _isScanning = false);
    }
  }

  Future<void> _scanImage(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
      
      final data = _parser.parse(recognizedText);
      
      setState(() {
        _receiptData = data;
        _isScanning = false;
        
        // Pre-fill fields
        if (data.amount != null) {
          _amountController.text = data.amount!.toStringAsFixed(2);
        }
        if (data.merchantName != null) {
          _merchantController.text = data.merchantName!;
        }
        if (data.categoryName != null) {
          _categoryController.text = data.categoryName!;
        }
        _selectedDate = data.date ?? DateTime.now();
      });
      
      textRecognizer.close();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning receipt: $e')),
      );
      setState(() => _isScanning = false);
    }
  }

  void _confirmAndContinue() {
    if (_image == null) return;
    
    // Parse amount safely
    double? amount;
    try {
      amount = double.parse(_amountController.text);
    } catch (_) {}

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          initialAmount: amount,
          initialDate: _selectedDate,
          initialDescription: _merchantController.text,
          initialCategoryName: _categoryController.text.isNotEmpty 
              ? _categoryController.text 
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
      ),
      body: _image == null
          ? _buildPlaceholder(theme)
          : _buildReviewUI(theme),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Scan a receipt to auto-fill',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _OptionButton(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: 24),
              _OptionButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewUI(ThemeData theme) {
    if (_isScanning) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Analyzing receipt...'),
            const SizedBox(height: 8),
            Text(
              'Looking for Merchant, Date & Amount',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 200,
              child: Image.file(_image!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Review Details',
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
                    label: Text('₹${amt.toStringAsFixed(2)}'),
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
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              child: Text(
                _selectedDate != null 
                    ? DateFormat.yMMMd().format(_selectedDate!) 
                    : 'Select Date',
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
                  final formatted = DateFormat.yMMMd().format(date);
                  final isSelected = _selectedDate == date;
                  return ActionChip(
                    label: Text(formatted),
                    backgroundColor: isSelected 
                        ? AppColors.brightCyan.withValues(alpha: 0.1)
                        : null,
                    side: isSelected 
                        ? const BorderSide(color: AppColors.brightCyan)
                        : null,
                    onPressed: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 16),

          // Category Field
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: 'Category Prediction',
              prefixIcon: Icon(Icons.category),
              border: OutlineInputBorder(),
              helperText: 'Will be auto-matched in next screen',
            ),
          ),
          
          const SizedBox(height: 32),
          
          GradientButton(
            label: 'Confirm & Create',
            onPressed: _confirmAndContinue,
            gradient: AppColors.primaryGradient,
            icon: Icons.check,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => setState(() => _image = null),
            icon: const Icon(Icons.refresh),
            label: const Text('Retake Photo'),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.brightCyan),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

