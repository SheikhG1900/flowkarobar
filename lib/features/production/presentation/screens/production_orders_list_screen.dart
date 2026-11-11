import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flowpaisa/features/production/domain/production_models.dart';
import 'package:flowpaisa/features/production/presentation/providers/production_provider.dart';
import 'package:flowpaisa/features/production/presentation/screens/add_production_order_screen.dart';
import 'package:flowpaisa/features/production/presentation/screens/production_order_detail_screen.dart';
import 'package:flowpaisa/features/production/presentation/screens/recipes_list_screen.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/app_floating_action_button.dart';

class ProductionOrdersListScreen extends ConsumerWidget {
  const ProductionOrdersListScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case ProductionStatus.completed:
        return AppColors.success;
      case ProductionStatus.cancelled:
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case ProductionStatus.completed:
        return l10n.productionCompleted;
      case ProductionStatus.cancelled:
        return l10n.productionCancelled;
      default:
        return l10n.productionDraft;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ordersAsync = ref.watch(productionOrdersStreamProvider);
    final dateFormat = ref.watch(userProfileProvider).dateFormat;

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tab = DefaultTabController.of(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.productionOrders),
              bottom: TabBar(
                tabs: [
                  Tab(text: l10n.productionOrders),
                  Tab(text: l10n.recipes),
                ],
              ),
            ),
            floatingActionButton: AnimatedBuilder(
              animation: tab,
              builder: (context, _) {
                if (tab.index == 1) {
                  return const SizedBox.shrink();
                }
                return AppFloatingActionButton(
                  heroTag: 'production_fab',
                  backgroundColor: AppColors.incomeColor,
                  foregroundColor: Colors.white,
                  tooltip: l10n.newProductionOrder,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddProductionOrderScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                );
              },
            ),
            body: TabBarView(
              children: [
                ordersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text(l10n.errorOccurred(e.toString()))),
                  data: (orders) {
                    if (orders.isEmpty) {
                      return OrderEmptyState(
                        icon: Icons.precision_manufacturing_outlined,
                        message: l10n.noProductionOrdersYet,
                        color: AppColors.incomeColor,
                      );
                    }
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 720 ? 2 : 1;
                        final rowCount = (orders.length / columns).ceil();
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                          itemCount: rowCount,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, rowIndex) {
                            final start = rowIndex * columns;
                            Widget cardAt(int index) {
                              final order = orders[index];
                              return _ProductionOrderCard(
                                order: order,
                                dateFormat: dateFormat,
                                statusColor: _statusColor(order.status),
                                statusLabel:
                                    _statusLabel(l10n, order.status),
                                onOpen: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ProductionOrderDetailScreen(
                                        orderUuid: order.uuid,
                                      ),
                                    ),
                                  );
                                },
                                onEdit: order.status == ProductionStatus.draft
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                AddProductionOrderScreen(
                                              existingUuid: order.uuid,
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                              );
                            }

                            if (columns == 1) {
                              return cardAt(start);
                            }

                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (var i = 0; i < columns; i++) ...[
                                    if (i > 0) const SizedBox(width: 12),
                                    Expanded(
                                      child: start + i < orders.length
                                          ? cardAt(start + i)
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const RecipesListScreen(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProductionOrderCard extends ConsumerWidget {
  final ProductionOrder order;
  final String dateFormat;
  final Color statusColor;
  final String statusLabel;
  final VoidCallback onOpen;
  final VoidCallback? onEdit;

  const _ProductionOrderCard({
    required this.order,
    required this.dateFormat,
    required this.statusColor,
    required this.statusLabel,
    required this.onOpen,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final muted = theme.colorScheme.onSurfaceVariant;
    final outputsAsync =
        ref.watch(productionOutputsStreamProvider(order.uuid));
    final inputsAsync = ref.watch(productionInputsStreamProvider(order.uuid));
    final outputs = outputsAsync.value ?? const <ProductionOrderOutput>[];
    final inputs = inputsAsync.value ?? const <ProductionOrderInput>[];
    final recipeLabel = order.recipeNameSnapshot?.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onOpen,
        child: Container(
          decoration:
              AppColors.transactionListItemDecoration(theme, statusColor),
          clipBehavior: Clip.none,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.productionNumber,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            AppDateFormatter.formatDate(
                              order.productionDate,
                              pattern: dateFormat,
                            ),
                            if (recipeLabel != null && recipeLabel.isNotEmpty)
                              l10n.recipeScaledNote(
                                AmountFormatter.formatQuantity(
                                    order.scaleFactor),
                                recipeLabel,
                              ),
                          ].join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _StatusBadge(
                        label: statusLabel,
                        color: statusColor,
                      ),
                      if (outputs.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _CountBadge(
                          count: outputs.length,
                          accent: statusColor,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.sectionOutputs,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: muted,
                ),
              ),
              const SizedBox(height: 8),
              if (outputsAsync.isLoading && outputs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (outputs.isEmpty)
                Text(
                  l10n.noResultsFound,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                )
              else
                for (var i = 0; i < outputs.length; i++) ...[
                  if (i > 0) const SizedBox(height: 6),
                  _OutputQtyRow(
                    name: outputs[i].productNameSnapshot,
                    quantity: order.status == ProductionStatus.completed &&
                            outputs[i].actualQuantity > 0
                        ? outputs[i].actualQuantity
                        : outputs[i].plannedQuantity,
                    unit: outputs[i].unit,
                    accent: AppColors.incomeColor,
                  ),
                ],
              if (inputs.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '${l10n.sectionInputs}: ${inputs.length}',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onEdit != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onEdit,
                        child: Text(l10n.editProductionOrder),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: onOpen,
                      style: FilledButton.styleFrom(
                        backgroundColor: statusColor,
                      ),
                      child: Text(l10n.orderDetails),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutputQtyRow extends StatelessWidget {
  final String name;
  final double quantity;
  final String unit;
  final Color accent;

  const _OutputQtyRow({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AmountFormatter.formatQuantity(quantity),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            unit,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color accent;

  const _CountBadge({required this.count, required this.accent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: accent,
        ),
      ),
    );
  }
}
