import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/currencies/presentation/providers/currencies_provider.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';

class AddCurrencyScreen extends ConsumerStatefulWidget {
  const AddCurrencyScreen({super.key});

  @override
  ConsumerState<AddCurrencyScreen> createState() => _AddCurrencyScreenState();
}

class _AddCurrencyScreenState extends ConsumerState<AddCurrencyScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _codeController = TextEditingController();
  int _decimalPlaces = 2;
  double _scaleFactor = 1.0;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _saveCurrency() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(currenciesRepositoryProvider);
      final newUuid = const Uuid().v4();

      await repository.createCurrency(
        AppCurrenciesCompanion.insert(
          uuid: newUuid,
          name: _nameController.text,
          symbol: _symbolController.text,
          code: _codeController.text.toUpperCase(),
          decimalPlaces: drift.Value(_decimalPlaces),
          scaleFactor: drift.Value(_scaleFactor),
          isDefault: const drift.Value(false),
        ),
      );

      // Invalidate providers to refresh the UI immediately
      ref.invalidate(currentCurrencyProvider);
      ref.invalidate(selectedCurrencyIdProvider);
      ref.invalidate(currenciesListProvider);
      ref.invalidate(currencyScaleFactorProvider);
      ref.invalidate(currencySymbolProvider);
      ref.invalidate(currencyDecimalPlacesProvider);

      if (mounted) {
        Navigator.pop(context);
        ToastUtils.showSuccessToast(
            context, ref, l10n.currencyAdded);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
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
        title: Text(l10n.addCurrency),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          children: [
            // Currency Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.currencyNameLabel,
                hintText: l10n.currencyNameHint,
                prefixIcon: const Icon(Icons.label),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterCurrencyName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Currency Symbol
            TextFormField(
              controller: _symbolController,
              decoration: InputDecoration(
                labelText: l10n.currencySymbolLabel,
                hintText: l10n.currencySymbolHint,
                helperText: l10n.currencySymbolHelper,
                prefixIcon: const Icon(Icons.currency_exchange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value != null && value.length > 10) {
                  return l10n.symbolLengthError;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Currency Code
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: l10n.currencyCodeLabel,
                hintText: l10n.currencyCodeHint,
                helperText: l10n.currencyCodeHelper,
                prefixIcon: const Icon(Icons.code),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterCurrencyCode;
                }
                if (value.length != 3) {
                  return l10n.codeLengthError;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Decimal Places Selector
            DropdownButtonFormField<int>(
              value: _decimalPlaces,
              decoration: InputDecoration(
                labelText: l10n.decimalPlacesLabel,
                helperText: l10n.decimalPlacesHelper,
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                DropdownMenuItem(value: 0, child: Text(l10n.noDecimals)),
                DropdownMenuItem(value: 1, child: Text(l10n.oneDecimal)),
                DropdownMenuItem(value: 2, child: Text(l10n.twoDecimals)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _decimalPlaces = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Scale Factor Selector
            DropdownButtonFormField<double>(
              value: _scaleFactor,
              decoration: InputDecoration(
                labelText: l10n.scaleFactorLabel,
                helperText: l10n.scaleFactorHelper,
                prefixIcon: const Icon(Icons.scale_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                DropdownMenuItem(value: 1.0, child: Text(l10n.scaleWhole)),
                DropdownMenuItem(value: 1000.0, child: Text(l10n.scaleThousands)),
                DropdownMenuItem(value: 100000.0, child: Text(l10n.scaleLakhs)),
                DropdownMenuItem(value: 1000000.0, child: Text(l10n.scaleMillions)),
                DropdownMenuItem(value: 10000000.0, child: Text(l10n.scaleCrores)),
                DropdownMenuItem(value: 1000000000.0, child: Text(l10n.scaleBillions)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _scaleFactor = value;
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
                    l10n.preview,
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
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: _symbolController.text.isEmpty
                            ? const Icon(Icons.money_off, size: 20, color: Colors.grey)
                            : Text(
                                _symbolController.text,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: theme.colorScheme.primary,
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
                              _nameController.text.isEmpty
                                  ? l10n.currencyNameLabel
                                  : _nameController.text,
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              _codeController.text.isEmpty
                                  ? 'XXX'
                                  : _codeController.text.toUpperCase(),
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
                    l10n.positiveAmount(AmountFormatter.formatAmount(1234567.89, _decimalPlaces, scaleFactor: _scaleFactor)),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.negativeAmount(AmountFormatter.formatAmount(-567890.12, _decimalPlaces, scaleFactor: _scaleFactor)),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            GradientButton(
              onPressed: _isLoading ? null : _saveCurrency,
              gradient: AppColors.getPrimaryGradient(theme.colorScheme.primary),
              label: l10n.saveCurrency,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
