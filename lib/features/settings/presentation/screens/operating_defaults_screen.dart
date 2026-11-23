import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/form_section_card.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/shared/widgets/ltr_number_field.dart';

/// Business operating constants (default sales tax, future defaults).
class OperatingDefaultsScreen extends ConsumerStatefulWidget {
  const OperatingDefaultsScreen({super.key});

  @override
  ConsumerState<OperatingDefaultsScreen> createState() =>
      _OperatingDefaultsScreenState();
}

class _OperatingDefaultsScreenState
    extends ConsumerState<OperatingDefaultsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taxRateController = TextEditingController();
  bool _hydrated = false;
  bool _saving = false;

  @override
  void dispose() {
    _taxRateController.dispose();
    super.dispose();
  }

  void _hydrateFromState(OperatingDefaultsState defaults) {
    if (_hydrated) return;
    _taxRateController.text = defaults.defaultSalesTaxRate <= 0
        ? ''
        : AmountFormatter.formatQuantity(defaults.defaultSalesTaxRate);
    _hydrated = true;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final rate = double.tryParse(_taxRateController.text.trim()) ?? 0;
    setState(() => _saving = true);
    try {
      await ref
          .read(operatingDefaultsProvider.notifier)
          .setDefaultSalesTaxRate(rate);
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, ref, l10n.operatingDefaultsSaved);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final defaults = ref.watch(operatingDefaultsProvider);
    _hydrateFromState(defaults);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.operatingDefaults),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              l10n.operatingDefaultsHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FormSectionCard(
              title: l10n.orders,
              icon: Icons.receipt_long_outlined,
              accentColor: AppColors.receivableColor,
              children: [
                LtrNumberField(
                  controller: _taxRateController,
                  decoration: InputDecoration(
                    labelText: l10n.defaultSalesTaxPercent,
                    helperText: l10n.defaultSalesTaxPercentHint,
                    prefixIcon: const Icon(Icons.percent_outlined),
                    suffixText: '%',
                    filled: true,
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return null;
                    final number = double.tryParse(text);
                    if (number == null || number < 0) {
                      return l10n.invalidNumber;
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: l10n.save,
              icon: Icons.check_rounded,
              isLoading: _saving,
              width: double.infinity,
              gradient: AppColors.getPrimaryGradient(
                AppColors.settingsSectionColor,
              ),
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
