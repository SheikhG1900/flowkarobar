import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/features/currencies/presentation/providers/currencies_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';

class EditCurrencyScreen extends ConsumerStatefulWidget {
  final AppCurrency currency;

  const EditCurrencyScreen({
    super.key,
    required this.currency,
  });

  @override
  ConsumerState<EditCurrencyScreen> createState() => _EditCurrencyScreenState();
}

class _EditCurrencyScreenState extends ConsumerState<EditCurrencyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _symbolController;
  late TextEditingController _codeController;
  late int _decimalPlaces;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currency.name);
    _symbolController = TextEditingController(text: widget.currency.symbol);
    _codeController = TextEditingController(text: widget.currency.code);
    _decimalPlaces = widget.currency.decimalPlaces;
    
    // Add listeners to update preview instantly
    _nameController.addListener(() => setState(() {}));
    _symbolController.addListener(() => setState(() {}));
    _codeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _updateCurrency() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(currenciesRepositoryProvider);

      final updatedCurrency = widget.currency.copyWith(
        name: _nameController.text,
        symbol: _symbolController.text,
        code: _codeController.text.toUpperCase(),
        decimalPlaces: _decimalPlaces,
      );

      await repository.updateCurrency(updatedCurrency);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Currency updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Currency'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Currency Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Currency Name',
                hintText: 'e.g., Euro, British Pound',
                prefixIcon: const Icon(Icons.label),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter currency name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Currency Symbol
            TextFormField(
              controller: _symbolController,
              decoration: InputDecoration(
                labelText: 'Currency Symbol',
                hintText: 'e.g., €, £, ¥',
                helperText: 'You can use emoji, letters, or symbols',
                prefixIcon: const Icon(Icons.currency_exchange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter currency symbol';
                }
                if (value.length > 10) {
                  return 'Symbol must be 10 characters or less';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Currency Code
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Currency Code',
                hintText: 'e.g., EUR, GBP, JPY',
                helperText: 'ISO 4217 code (3 letters)',
                prefixIcon: const Icon(Icons.code),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter currency code';
                }
                if (value.length != 3) {
                  return 'Code must be exactly 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Decimal Places Selector
            DropdownButtonFormField<int>(
              value: _decimalPlaces,
              decoration: InputDecoration(
                labelText: 'Decimal Places',
                helperText: 'Number of digits after decimal point',
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('0 (No decimals)')),
                DropdownMenuItem(value: 1, child: Text('1 decimal place')),
                DropdownMenuItem(value: 2, child: Text('2 decimal places')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _decimalPlaces = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.brightCyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.brightCyan.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _symbolController.text,
                          style: TextStyle(
                            fontSize: 24,
                            color: AppColors.brightCyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text,
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              _codeController.text.toUpperCase(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Positive: ${AmountFormatter.formatWithCurrency(1234.56, _symbolController.text, _decimalPlaces)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Negative: -${AmountFormatter.formatWithCurrency(567.89, _symbolController.text, _decimalPlaces)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Update Button
            GradientButton(
              onPressed: _isLoading ? null : _updateCurrency,
              gradient: AppColors.primaryGradient,
              label: 'Update Currency',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
