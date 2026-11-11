import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flowpaisa/features/production/domain/production_models.dart';
import 'package:flowpaisa/features/production/presentation/providers/production_provider.dart';
import 'package:flowpaisa/features/production/presentation/screens/add_production_order_screen.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/form_section_card.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';

class ProductionOrderDetailScreen extends ConsumerStatefulWidget {
  final String orderUuid;

  const ProductionOrderDetailScreen({super.key, required this.orderUuid});

  @override
  ConsumerState<ProductionOrderDetailScreen> createState() =>
      _ProductionOrderDetailScreenState();
}

class _ProductionOrderDetailScreenState
    extends ConsumerState<ProductionOrderDetailScreen> {
  bool _busy = false;

  Future<void> _complete() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(productionRepositoryProvider);

    final shortfalls = await repo.validateStock(widget.orderUuid);
    if (!mounted) return;
    if (shortfalls.isNotEmpty) {
      final missingBatch = shortfalls.any((s) => s.missingBatch);
      final msg = shortfalls
          .map((s) {
            if (s.missingBatch) {
              return '${s.productName}: ${l10n.selectBatch}';
            }
            final scope = s.batchNumber == null || s.batchNumber!.isEmpty
                ? ''
                : ' [${s.batchNumber}]';
            return '${s.productName}$scope: '
                '${AmountFormatter.formatQuantity(s.available)} / '
                '${AmountFormatter.formatQuantity(s.required)}';
          })
          .join('\n');
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            missingBatch
                ? l10n.selectBatch
                : l10n.insufficientStockToComplete,
          ),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.completeProduction),
        content: Text(l10n.completeProductionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.completeProduction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await repo.complete(widget.orderUuid);
      if (!mounted) return;
      ToastUtils.showSuccessToast(
          context, ref, l10n.productionCompletedToast);
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelProduction),
        content: Text(l10n.productionCancelledToast),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.cancelProduction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(productionRepositoryProvider).cancel(widget.orderUuid);
      if (!mounted) return;
      ToastUtils.showSuccessToast(
          context, ref, l10n.productionCancelledToast);
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final orderAsync =
        ref.watch(productionOrderStreamProvider(widget.orderUuid));
    final inputsAsync =
        ref.watch(productionInputsStreamProvider(widget.orderUuid));
    final outputsAsync =
        ref.watch(productionOutputsStreamProvider(widget.orderUuid));
    final chargesAsync =
        ref.watch(productionChargesStreamProvider(widget.orderUuid));
    final dateFormat = ref.watch(userProfileProvider).dateFormat;

    return orderAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.productionOrder)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.productionOrder)),
        body: Center(child: Text(l10n.errorOccurred(e.toString()))),
      ),
      data: (order) {
        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.productionOrder)),
            body: Center(child: Text(l10n.noResultsFound)),
          );
        }
        final isDraft = order.status == ProductionStatus.draft;
        final statusColor = switch (order.status) {
          ProductionStatus.completed => AppColors.success,
          ProductionStatus.cancelled => AppColors.error,
          _ => AppColors.warning,
        };
        final statusLabel = switch (order.status) {
          ProductionStatus.completed => l10n.productionCompleted,
          ProductionStatus.cancelled => l10n.productionCancelled,
          _ => l10n.productionDraft,
        };
        final inputs = inputsAsync.value ?? const <ProductionOrderInput>[];
        final outputs = outputsAsync.value ?? const <ProductionOrderOutput>[];
        final charges = chargesAsync.value ?? const <ProductionOrderCharge>[];

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.productionOrder),
            actions: [
              if (isDraft)
                IconButton(
                  tooltip: l10n.editProductionOrder,
                  onPressed: _busy
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddProductionOrderScreen(
                                existingUuid: order.uuid,
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.edit_outlined),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _ProductionHero(
                productionNumber: order.productionNumber,
                statusLabel: statusLabel,
                statusColor: statusColor,
                dateText: AppDateFormatter.formatDate(
                  order.productionDate,
                  pattern: dateFormat,
                ),
                recipeText: order.recipeNameSnapshot != null &&
                        order.recipeNameSnapshot!.isNotEmpty
                    ? l10n.recipeScaledNote(
                        AmountFormatter.formatQuantity(order.scaleFactor),
                        order.recipeNameSnapshot!,
                      )
                    : null,
                notes: order.notes?.trim().isNotEmpty == true
                    ? order.notes!.trim()
                    : null,
              ),
              const SizedBox(height: 14),
              FormSectionCard(
                title: l10n.sectionInputs,
                icon: Icons.input_rounded,
                accentColor: AppColors.expenseColor,
                trailing: _CountPill(
                  count: inputs.length,
                  color: AppColors.expenseColor,
                ),
                children: [
                  if (inputsAsync.isLoading && inputs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (inputs.isEmpty)
                    Text(
                      l10n.noResultsFound,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    for (var i = 0; i < inputs.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _ProductionLineCard(
                        name: inputs[i].productNameSnapshot,
                        meta: inputs[i].consumeMode ==
                                ProductionConsumeMode.batch
                            ? '${l10n.consumeModeBatch}: ${inputs[i].batchNumber ?? '—'}'
                            : l10n.consumeModeAuto,
                        quantity: order.status == ProductionStatus.completed &&
                                inputs[i].actualQuantity > 0
                            ? inputs[i].actualQuantity
                            : inputs[i].plannedQuantity,
                        unit: inputs[i].unit,
                        accent: AppColors.expenseColor,
                      ),
                    ],
                ],
              ),
              FormSectionCard(
                title: l10n.sectionOutputs,
                icon: Icons.output_rounded,
                accentColor: AppColors.incomeColor,
                trailing: _CountPill(
                  count: outputs.length,
                  color: AppColors.incomeColor,
                ),
                children: [
                  if (outputsAsync.isLoading && outputs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (outputs.isEmpty)
                    Text(
                      l10n.noResultsFound,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    for (var i = 0; i < outputs.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _ProductionLineCard(
                        name: outputs[i].productNameSnapshot,
                        meta: order.status == ProductionStatus.completed
                            ? '${l10n.effectiveCostLabel}: ${formatOrderAmount(ref, outputs[i].unitCostSnapshot)}'
                            : '${l10n.costWeight}: ${AmountFormatter.formatQuantity(outputs[i].costWeight)}',
                        quantity: order.status == ProductionStatus.completed &&
                                outputs[i].actualQuantity > 0
                            ? outputs[i].actualQuantity
                            : outputs[i].plannedQuantity,
                        unit: outputs[i].unit,
                        accent: AppColors.incomeColor,
                        batchHint: outputs[i].batchNumber.trim().isEmpty
                            ? null
                            : outputs[i].batchNumber.trim(),
                      ),
                    ],
                ],
              ),
              if (charges.isNotEmpty)
                FormSectionCard(
                  title: l10n.sectionCharges,
                  icon: Icons.payments_outlined,
                  accentColor: AppColors.payableColor,
                  trailing: _CountPill(
                    count: charges.length,
                    color: AppColors.payableColor,
                  ),
                  children: [
                    for (var i = 0; i < charges.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _ChargeLineCard(
                        description: charges[i].description,
                        amountLabel: formatOrderAmount(ref, charges[i].amount),
                      ),
                    ],
                  ],
                ),
              if (isDraft) ...[
                const SizedBox(height: 8),
                GradientButton(
                  label: l10n.completeProduction,
                  isLoading: _busy,
                  width: double.infinity,
                  gradient:
                      AppColors.getPrimaryGradient(AppColors.incomeColor),
                  onPressed: _busy ? null : _complete,
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _busy ? null : _cancel,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(l10n.cancelProduction),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ProductionHero extends StatelessWidget {
  final String productionNumber;
  final String statusLabel;
  final Color statusColor;
  final String dateText;
  final String? recipeText;
  final String? notes;

  const _ProductionHero({
    required this.productionNumber,
    required this.statusLabel,
    required this.statusColor,
    required this.dateText,
    this.recipeText,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = AppColors.getPrimaryGradient(statusColor);
    const onGradient = Colors.white;
    final muted = Colors.white.withValues(alpha: 0.88);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.42),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            PositionedDirectional(
              end: -18,
              bottom: -22,
              child: Icon(
                Icons.precision_manufacturing_outlined,
                size: 128,
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusLabel.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    productionNumber,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: onGradient,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (recipeText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      recipeText!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: muted,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                  if (notes != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      notes!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final int count;
  final Color color;

  const _CountPill({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _ProductionLineCard extends StatelessWidget {
  final String name;
  final String meta;
  final double quantity;
  final String unit;
  final Color accent;
  final String? batchHint;

  const _ProductionLineCard({
    required this.name,
    required this.meta,
    required this.quantity,
    required this.unit,
    required this.accent,
    this.batchHint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: muted,
                      height: 1.25,
                    ),
                  ),
                  if (batchHint != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      batchHint!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AmountFormatter.formatQuantity(quantity),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: accent,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    unit,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: muted,
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
}

class _ChargeLineCard extends StatelessWidget {
  final String description;
  final String amountLabel;

  const _ChargeLineCard({
    required this.description,
    required this.amountLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppColors.payableColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            amountLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
