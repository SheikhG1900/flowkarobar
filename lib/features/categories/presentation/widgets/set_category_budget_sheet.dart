import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/shared/widgets/limit_countdown_badge.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

Future<void> showSetCategoryBudgetSheet(
  BuildContext context, {
  required Category category,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _SetCategoryBudgetSheetContent(
      category: category,
      outerContext: context,
    ),
  );
}

class _SetCategoryBudgetSheetContent extends ConsumerStatefulWidget {
  final Category category;
  final BuildContext outerContext;

  const _SetCategoryBudgetSheetContent({
    required this.category,
    required this.outerContext,
  });

  @override
  ConsumerState<_SetCategoryBudgetSheetContent> createState() =>
      _SetCategoryBudgetSheetContentState();
}

class _SetCategoryBudgetSheetContentState
    extends ConsumerState<_SetCategoryBudgetSheetContent> {
  late final TextEditingController _monthlyController;
  late final TextEditingController _quarterlyController;
  late final TextEditingController _yearlyController;
  late final TextEditingController _overallController;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _monthlyController = TextEditingController(
      text: c.monthlyBudget != null ? _formatNum(c.monthlyBudget!) : '',
    );
    _quarterlyController = TextEditingController(
      text: c.quarterlyBudget != null ? _formatNum(c.quarterlyBudget!) : '',
    );
    _yearlyController = TextEditingController(
      text: c.yearlyBudget != null ? _formatNum(c.yearlyBudget!) : '',
    );
    _overallController = TextEditingController(
      text: c.overallBudget != null ? _formatNum(c.overallBudget!) : '',
    );
  }

  @override
  void dispose() {
    _monthlyController.dispose();
    _quarterlyController.dispose();
    _yearlyController.dispose();
    _overallController.dispose();
    super.dispose();
  }

  double? _parseAmount(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t.replaceAll(',', ''));
  }

  Future<void> _onSave() async {
    final l10n = AppLocalizations.of(context)!;
    final outer = widget.outerContext;
    final repo = ref.read(categoriesRepositoryProvider);
    final m = _parseAmount(_monthlyController.text);
    final q = _parseAmount(_quarterlyController.text);
    final y = _parseAmount(_yearlyController.text);
    final o = _parseAmount(_overallController.text);

    // Check limits if setting a NEW budget (all were null before)
    final wasBudgetSet = widget.category.monthlyBudget != null ||
        widget.category.quarterlyBudget != null ||
        widget.category.yearlyBudget != null ||
        widget.category.overallBudget != null;
    final isSettingNewBudget = !wasBudgetSet && (m != null || q != null || y != null || o != null);

    if (isSettingNewBudget) {
      final isPremium = PremiumGate.isPremium(ref);
      if (!isPremium) {
        final limits = await PremiumGate.getCategoryBudgetLimits(ref);
        if (!limits.canAdd) {
          if (mounted) {
            PremiumGate.showPremiumDialog(context);
          }
          return;
        }
      }
    }

    try {
      await repo.updateCategoryBudgetFields(
        widget.category,
        monthlyBudget: Value(m),
        quarterlyBudget: Value(q),
        yearlyBudget: Value(y),
        overallBudget: Value(o),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      // Run after this route is unmounted; use parent context + defer invalidation.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!outer.mounted) return;
        ref.invalidate(categoriesByTypeProvider);
        ref.invalidate(categoryDetailBudgetProvider(widget.category.uuid));
        invalidateCategoryPeriodNets(ref, widget.category.type);
        ToastUtils.showSuccessToast(outer, ref, l10n.budgetSaved);
      });
    } catch (e) {
      if (outer.mounted) {
        ToastUtils.showErrorToast(
          outer,
          ref,
          l10n.errorOccurred(e.toString()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = widget.category;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    c.type == 'EXPENSE'
                        ? Icons.account_balance_wallet_outlined
                        : Icons.savings_outlined,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.setBudget,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              c.type == 'EXPENSE'
                  ? l10n.spendingBudgetDescription
                  : l10n.savingsTargetDescription,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _monthlyController,
              decoration: InputDecoration(
                labelText: l10n.monthlyBudget,
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quarterlyController,
              decoration: InputDecoration(
                labelText: l10n.quarterlyBudget,
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _yearlyController,
              decoration: InputDecoration(
                labelText: l10n.yearlyBudget,
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _overallController,
              decoration: InputDecoration(
                labelText: l10n.overallBudget,
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
            ),
            const SizedBox(height: 20),

            // Countdown Badge (show until limit reached)
            FutureBuilder<TotalLimits>(
              future: PremiumGate.getCategoryBudgetLimits(ref),
              builder: (context, snapshot) {
                final limits = snapshot.data;
                final wasBudgetSet = widget.category.monthlyBudget != null ||
                    widget.category.quarterlyBudget != null ||
                    widget.category.yearlyBudget != null ||
                    widget.category.overallBudget != null;

                if (!wasBudgetSet &&
                    limits != null &&
                    !limits.isUnlimited &&
                    limits.canAdd) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Center(
                      child: LimitCountdownBadge(
                        totalUsed: limits.used,
                        totalLimit: limits.total,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Save button with lock icon
            Stack(
              alignment: Alignment.topRight,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.save_outlined, size: 20),
                  label: Text(l10n.save),
                  onPressed: _onSave,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                FutureBuilder<TotalLimits>(
                  future: PremiumGate.getCategoryBudgetLimits(ref),
                  builder: (context, snapshot) {
                    final limits = snapshot.data;
                    final wasBudgetSet = widget.category.monthlyBudget != null ||
                        widget.category.quarterlyBudget != null ||
                        widget.category.yearlyBudget != null ||
                        widget.category.overallBudget != null;

                    if (!wasBudgetSet &&
                        limits != null &&
                        !limits.isUnlimited &&
                        !limits.canAdd) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 8, right: 8),
                        child: Icon(Icons.lock, size: 16, color: Colors.white),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatNum(double v) {
  if (v == v.roundToDouble()) return v.round().toString();
  return v.toString();
}
