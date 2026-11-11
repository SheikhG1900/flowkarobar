import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flowpaisa/features/production/data/production_repository.dart';
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
  /// Stays true after the first full data reveal so refreshes don't re-dim.
  bool _contentRevealed = false;

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
        final previewAsync = isDraft
            ? ref.watch(productionCompletionPreviewProvider(order.uuid))
            : null;
        final preview = previewAsync?.value;
        final linesReady = inputsAsync.hasValue &&
            outputsAsync.hasValue &&
            chargesAsync.hasValue;
        final calcReady = !isDraft ||
            preview != null ||
            (previewAsync?.hasError ?? false);
        final contentReady = linesReady && calcReady;
        // First paint stays dull; reveal on the next frame so the fade always runs.
        if (contentReady && !_contentRevealed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_contentRevealed) {
              setState(() => _contentRevealed = true);
            }
          });
        }
        final revealed = _contentRevealed;
        final previewRefreshing =
            isDraft && (previewAsync?.isLoading ?? false) && preview != null;
        final impactByInput = <String, ProductionInputImpact>{
          for (final i in preview?.inputs ?? const <ProductionInputImpact>[])
            i.inputUuid: i,
        };
        final outputImpactById = <String, ProductionOutputImpact>{
          for (final o in preview?.outputs ?? const <ProductionOutputImpact>[])
            o.outputUuid: o,
        };

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.productionOrder),
            actions: [
              if (isDraft)
                IconButton(
                  tooltip: l10n.editProductionOrder,
                  onPressed: _busy || !revealed
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
          body: AnimatedOpacity(
            opacity: revealed ? 1 : 0.34,
            duration: const Duration(milliseconds: 480),
            curve: Curves.easeOutCubic,
            child: AnimatedSlide(
              offset: revealed ? Offset.zero : const Offset(0, 0.02),
              duration: const Duration(milliseconds: 480),
              curve: Curves.easeOutCubic,
              child: ListView(
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
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: (!revealed || previewRefreshing)
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(4, 10, 4, 2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                minHeight: 2.5,
                                color: AppColors.incomeColor,
                                backgroundColor: AppColors.incomeColor
                                    .withValues(alpha: 0.12),
                              ),
                            ),
                          )
                        : const SizedBox(width: double.infinity),
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
                      if (!inputsAsync.hasValue)
                        const _SectionPlaceholder(accent: AppColors.expenseColor)
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
                          Builder(
                            builder: (context) {
                              final input = inputs[i];
                              final impact = impactByInput[input.uuid];
                              final qty = order.status ==
                                          ProductionStatus.completed &&
                                      input.actualQuantity > 0
                                  ? input.actualQuantity
                                  : input.plannedQuantity;
                              final mode = input.consumeMode ==
                                      ProductionConsumeMode.batch
                                  ? '${l10n.consumeModeBatch}: ${input.batchNumber ?? '—'}'
                                  : l10n.consumeModeAuto;
                              final showInputCosts =
                                  impact != null && !impact.missingBatch;
                              return _ProductionLineCard(
                                name: input.productNameSnapshot,
                                unit: input.unit,
                                meta: impact?.missingBatch == true
                                    ? l10n.selectBatch
                                    : mode,
                                costLabel: null,
                                costAmount: null,
                                accent: impact?.insufficient == true
                                    ? AppColors.error
                                    : AppColors.expenseColor,
                                quantity: impact == null ? qty : null,
                                stockMath: impact == null ||
                                        impact.missingBatch
                                    ? null
                                    : (
                                        base: impact.available,
                                        delta: impact.required,
                                        result: impact.remainingAfter,
                                        isAdd: false,
                                        baseCost: showInputCosts &&
                                                impact.available > 1e-9
                                            ? formatOrderAmount(
                                                ref, impact.currentUnitCost)
                                            : null,
                                        deltaCost: showInputCosts &&
                                                impact.required > 1e-9 &&
                                                impact.consumeUnitCost > 0
                                            ? formatOrderAmount(
                                                ref, impact.consumeUnitCost)
                                            : null,
                                        resultCost: showInputCosts &&
                                                impact.remainingAfter > 1e-9
                                            ? formatOrderAmount(
                                                ref, impact.unitCostAfter)
                                            : null,
                                      ),
                                warn: impact?.insufficient == true,
                              );
                            },
                          ),
                        ],
                    ],
                  ),
                  FormSectionCard(
                    title: l10n.sectionCharges,
                    icon: Icons.payments_outlined,
                    accentColor: AppColors.payableColor,
                    trailing: _CountPill(
                      count: charges.length,
                      color: AppColors.payableColor,
                    ),
                    children: [
                      if (!chargesAsync.hasValue)
                        const _SectionPlaceholder(
                            accent: AppColors.payableColor)
                      else if (charges.isEmpty)
                        Text(
                          l10n.noResultsFound,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      else
                        for (var i = 0; i < charges.length; i++) ...[
                          if (i > 0) const SizedBox(height: 8),
                          _ChargeLineCard(
                            description: charges[i].description,
                            amountLabel:
                                formatOrderAmount(ref, charges[i].amount),
                          ),
                        ],
                    ],
                  ),
                  _CalcReveal(
                    revealKey: isDraft && preview != null
                        ? 'cost-${preview.materialCost}-${preview.chargesTotal}-${preview.totalCost}'
                        : 'cost-hidden',
                    child: isDraft && preview != null
                        ? FormSectionCard(
                            title: l10n.productionCostSummary,
                            icon: Icons.calculate_outlined,
                            accentColor: AppColors.payableColor,
                            children: [
                              _CostSummaryPanel(
                                materialLabel: l10n.materialCost,
                                materialValue: formatOrderAmount(
                                    ref, preview.materialCost),
                                chargesLabel: l10n.sectionCharges,
                                chargesValue: formatOrderAmount(
                                    ref, preview.chargesTotal),
                                totalLabel: l10n.totalProductionCost,
                                totalValue: formatOrderAmount(
                                    ref, preview.totalCost),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
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
                      if (!outputsAsync.hasValue)
                        const _SectionPlaceholder(
                            accent: AppColors.incomeColor)
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
                          Builder(
                            builder: (context) {
                              final output = outputs[i];
                              final impact = outputImpactById[output.uuid];
                              final qty = order.status ==
                                          ProductionStatus.completed &&
                                      output.actualQuantity > 0
                                  ? output.actualQuantity
                                  : output.plannedQuantity;
                              final batch = output.batchNumber.trim();
                              final String? costLbl;
                              final String? costAmt;
                              if (order.status ==
                                  ProductionStatus.completed) {
                                costLbl = l10n.effectiveCostLabel;
                                costAmt = formatOrderAmount(
                                    ref, output.unitCostSnapshot);
                              } else if (impact == null) {
                                costLbl = l10n.costWeight;
                                costAmt = AmountFormatter.formatQuantity(
                                    output.costWeight);
                              } else {
                                costLbl = null;
                                costAmt = null;
                              }
                              return _ProductionLineCard(
                                name: output.productNameSnapshot,
                                unit: output.unit,
                                meta: batch.isEmpty
                                    ? ''
                                    : '${l10n.consumeModeBatch}: $batch',
                                costLabel: costLbl,
                                costAmount: costAmt,
                                accent: AppColors.incomeColor,
                                quantity: impact == null ? qty : null,
                                stockMath: impact == null
                                    ? null
                                    : (
                                        base: impact.currentStock,
                                        delta: impact.quantity,
                                        result: impact.stockAfter,
                                        isAdd: true,
                                        baseCost: impact.currentStock > 1e-9
                                            ? formatOrderAmount(
                                                ref, impact.currentUnitCost)
                                            : null,
                                        deltaCost: formatOrderAmount(
                                            ref, impact.unitCost),
                                        resultCost: formatOrderAmount(
                                            ref, impact.unitCostAfter),
                                      ),
                              );
                            },
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
                      gradient: AppColors.getPrimaryGradient(
                          AppColors.incomeColor),
                      onPressed: (_busy || !revealed) ? null : _complete,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: (_busy || !revealed) ? null : _cancel,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(l10n.cancelProduction),
                    ),
                  ],
                ],
              ),
            ),
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

class _SectionPlaceholder extends StatelessWidget {
  final Color accent;

  const _SectionPlaceholder({required this.accent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget bar({required double widthFactor, required double height}) {
      return FractionallySizedBox(
        widthFactor: widthFactor,
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < 2; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bar(widthFactor: 0.55, height: 12),
                const SizedBox(height: 10),
                bar(widthFactor: 0.35, height: 10),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Soft fade + slide when calculated blocks appear or refresh.
class _CalcReveal extends StatelessWidget {
  final String revealKey;
  final Widget child;

  const _CalcReveal({
    required this.revealKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: KeyedSubtree(
        key: ValueKey(revealKey),
        child: child,
      ),
    );
  }
}

class _CostSummaryPanel extends StatelessWidget {
  final String materialLabel;
  final String materialValue;
  final String chargesLabel;
  final String chargesValue;
  final String totalLabel;
  final String totalValue;

  const _CostSummaryPanel({
    required this.materialLabel,
    required this.materialValue,
    required this.chargesLabel,
    required this.chargesValue,
    required this.totalLabel,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppColors.payableColor;
    final muted = theme.colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Column(
              children: [
                _CostSummaryRow(
                  label: materialLabel,
                  value: materialValue,
                  labelColor: muted,
                ),
                const SizedBox(height: 8),
                _CostSummaryRow(
                  label: chargesLabel,
                  value: chargesValue,
                  labelColor: muted,
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: accent.withValues(alpha: 0.1),
            child: _CostSummaryRow(
              label: totalLabel,
              value: totalValue,
              labelColor: accent,
              valueColor: accent,
              emphasize: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _CostSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color? valueColor;
  final bool emphasize;

  const _CostSummaryRow({
    required this.label,
    required this.value,
    required this.labelColor,
    this.valueColor,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountColor = valueColor ?? theme.colorScheme.onSurface;
    final leaderColor = theme.colorScheme.onSurface.withValues(alpha: 0.18);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: (emphasize
                  ? theme.textTheme.titleSmall
                  : theme.textTheme.bodyMedium)
              ?.copyWith(
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            color: labelColor,
            height: 1.2,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: 12,
              child: CustomPaint(
                painter: _DotLeaderPainter(color: leaderColor),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        Text(
          value,
          textDirection: TextDirection.ltr,
          style: (emphasize
                  ? theme.textTheme.titleMedium
                  : theme.textTheme.titleSmall)
              ?.copyWith(
            fontWeight: FontWeight.w800,
            color: amountColor,
            height: 1.2,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _DotLeaderPainter extends CustomPainter {
  final Color color;

  const _DotLeaderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    const step = 5.0;
    final y = size.height / 2;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawCircle(Offset(x, y), 0.7, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DotLeaderPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ProductionLineCard extends StatelessWidget {
  final String name;
  final String unit;
  final String meta;
  final String? costLabel;
  final String? costAmount;
  final Color accent;
  final double? quantity;
  final ({
    double base,
    double delta,
    double result,
    bool isAdd,
    String? baseCost,
    String? deltaCost,
    String? resultCost,
  })? stockMath;
  final bool warn;

  const _ProductionLineCard({
    required this.name,
    required this.unit,
    required this.meta,
    required this.accent,
    this.costLabel,
    this.costAmount,
    this.quantity,
    this.stockMath,
    this.warn = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final lineColor = warn ? AppColors.error : accent;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: lineColor.withValues(alpha: 0.2)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: lineColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Start-aligned group; LTR glyph order so RTL still reads
                  // as (kg)Apple without Flutter reversing the pair.
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text.rich(
                      TextSpan(
                        children: isRtl
                            ? [
                                TextSpan(
                                  text: '($unit) ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: muted,
                                  ),
                                ),
                                TextSpan(
                                  text: name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ]
                            : [
                                TextSpan(
                                  text: name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ($unit)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: muted,
                                  ),
                                ),
                              ],
                      ),
                      textDirection: TextDirection.ltr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (meta.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: warn ? AppColors.error : muted,
                        height: 1.25,
                      ),
                    ),
                  ],
                  if (costLabel != null &&
                      costAmount != null &&
                      costAmount!.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                        children: [
                          TextSpan(text: '${costLabel!}: '),
                          // Keep currency symbol on the left of the amount.
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: Text(
                              costAmount!,
                              textDirection: TextDirection.ltr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: muted,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final offset = Tween<Offset>(
                  begin: const Offset(0.08, 0),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: offset, child: child),
                );
              },
              child: stockMath != null
                  ? KeyedSubtree(
                      key: ValueKey(
                        'math-${stockMath!.base}-${stockMath!.delta}-'
                        '${stockMath!.result}-${stockMath!.baseCost}-'
                        '${stockMath!.deltaCost}-${stockMath!.resultCost}',
                      ),
                      child: _StockMathColumn(
                        base: stockMath!.base,
                        delta: stockMath!.delta,
                        result: stockMath!.result,
                        isAdd: stockMath!.isAdd,
                        accent: lineColor,
                        warn: warn,
                        baseCost: stockMath!.baseCost,
                        deltaCost: stockMath!.deltaCost,
                        resultCost: stockMath!.resultCost,
                      ),
                    )
                  : quantity != null
                      ? KeyedSubtree(
                          key: ValueKey('qty-$quantity'),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              AmountFormatter.formatQuantity(quantity!),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: lineColor,
                                height: 1.1,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockMathColumn extends StatelessWidget {
  final double base;
  final double delta;
  final double result;
  final bool isAdd;
  final Color accent;
  final bool warn;
  final String? baseCost;
  final String? deltaCost;
  final String? resultCost;

  const _StockMathColumn({
    required this.base,
    required this.delta,
    required this.result,
    required this.isAdd,
    required this.accent,
    required this.warn,
    this.baseCost,
    this.deltaCost,
    this.resultCost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final opColor = isAdd ? AppColors.incomeColor : AppColors.expenseColor;
    const signWidth = 14.0;
    const digitWidth = 52.0;
    final showCosts =
        baseCost != null || deltaCost != null || resultCost != null;

    Widget qty(double value, {Color? color, bool bold = false}) => SizedBox(
          width: digitWidth,
          child: Text(
            AmountFormatter.formatQuantity(value),
            textAlign: TextAlign.end,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: color ?? muted,
              height: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        );

    Widget signSlot(String? glyph, Color? color) => SizedBox(
          width: signWidth,
          child: Text(
            glyph ?? '',
            textAlign: TextAlign.right,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
        );

    // Always: sign on the left of the number (− 25). Force LTR so RTL
    // mirroring does not swap them. Qty + cost share one alphabetic baseline.
    Widget mathRow({
      required double value,
      String? sign,
      Color? valueColor,
      Color? signColor,
      bool bold = false,
      String? cost,
    }) {
      return Row(
        textDirection: TextDirection.ltr,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          signSlot(sign, signColor),
          qty(value, color: valueColor, bold: bold),
          if (showCosts)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 6),
              child: Text(
                cost ?? '—',
                textDirection: TextDirection.ltr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: valueColor ?? muted,
                  height: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
        ],
      );
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: IntrinsicWidth(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: mathRow(value: base, cost: baseCost),
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: mathRow(
                value: delta,
                sign: isAdd ? '+' : '−',
                valueColor: opColor,
                signColor: opColor,
                cost: deltaCost,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                height: 1.2,
                color: muted.withValues(alpha: 0.45),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: mathRow(
                value: result,
                valueColor: warn ? AppColors.error : accent,
                bold: true,
                cost: resultCost,
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
