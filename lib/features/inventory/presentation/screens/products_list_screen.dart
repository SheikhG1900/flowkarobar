import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:flowpaisa/features/inventory/presentation/screens/add_product_screen.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/app_floating_action_button.dart';

class ProductsListScreen extends ConsumerWidget {
  const ProductsListScreen({super.key});

  Future<bool> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProduct),
        content: Text(l10n.deleteProductConfirm(product.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    try {
      await ref.read(inventoryRepositoryProvider).deleteProduct(product.uuid);
      if (context.mounted) {
        ToastUtils.showSuccessToast(context, ref, l10n.productDeleted);
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
      return false;
    }
  }

  void _openEditor(BuildContext context, {Product? product}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(existing: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.products)),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorOccurred(e.toString()))),
        data: (products) {
          if (products.isEmpty) {
            return OrderEmptyState(
              icon: Icons.inventory_2_outlined,
              message: l10n.noProductsYet,
              color: theme.colorScheme.primary,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return Dismissible(
                key: ValueKey(product.uuid),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDelete(context, ref, product),
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.delete_outline,
                      color: theme.colorScheme.onError),
                ),
                child: _ProductCard(
                  product: product,
                  onTap: () => _openEditor(context, product: product),
                  onLongPress: () => _confirmDelete(context, ref, product),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: AppFloatingActionButton(
        heroTag: 'products_fab',
        tooltip: l10n.addProduct,
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final minAlert = product.minStockAlert;
    final isLowStock = !product.isService &&
        minAlert != null &&
        product.stockQuantity <= minAlert;
    final accent = isLowStock ? AppColors.warning : AppColors.incomeColor;

    return Container(
      decoration: AppColors.transactionListItemDecoration(theme, accent),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: accent.withValues(alpha: 0.15),
                  child: Icon(
                    product.isService
                        ? Icons.miscellaneous_services_outlined
                        : Icons.inventory_2_outlined,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!product.isService) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${l10n.stockLabel(AmountFormatter.formatQuantity(product.stockQuantity))} ${product.unit}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (isLowStock) ...[
                        const SizedBox(height: 6),
                        OrderStatusChip(
                          label: l10n.lowStock,
                          color: AppColors.warning,
                          icon: Icons.warning_amber_rounded,
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  formatOrderAmount(ref, product.retailPrice),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.incomeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
