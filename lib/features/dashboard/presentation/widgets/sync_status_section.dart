import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/backup/presentation/screens/backup_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:flowpaisa/features/businesses/presentation/providers/business_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/documents_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/transactions_list_screen.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:flowpaisa/features/payables/presentation/screens/payables_list_screen.dart';
import 'package:flowpaisa/features/receivables/presentation/screens/receivables_list_screen.dart';
import 'package:flowpaisa/features/categories/presentation/screens/categories_list_screen.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/contacts_list_screen.dart';
import 'package:flowpaisa/features/inventory/presentation/screens/products_list_screen.dart';
import 'package:flowpaisa/features/orders/presentation/screens/orders_list_screen.dart';
import 'package:flowpaisa/features/production/presentation/screens/production_orders_list_screen.dart';
import 'package:material_symbols_icons/symbols.dart';

bool _isDatabaseLockedError(String status) {
  return status.contains('database is locked') ||
      status.contains('1555') ||
      status.contains('code 5') ||
      status.contains('SQLITE_BUSY');
}

class _SyncTableDetail {
  final String table;
  final String label;
  final int count;

  const _SyncTableDetail({
    required this.table,
    required this.label,
    required this.count,
  });
}

class _SyncChangeGroup {
  final String id;
  final String label;
  final IconData icon;
  final int count;
  final List<_SyncTableDetail> details;

  const _SyncChangeGroup({
    required this.id,
    required this.label,
    required this.icon,
    required this.count,
    required this.details,
  });
}

String _syncTableLabel(String table, AppLocalizations l10n) {
  switch (table) {
    case 'categories':
    case 'product_categories':
      return l10n.categories;
    case 'contacts':
      return l10n.contacts;
    case 'accounts':
      return l10n.accounts;
    case 'account_transfers':
      return l10n.transfers;
    case 'transactions':
      return l10n.transactions;
    case 'transaction_tags':
      return l10n.transactionTags;
    case 'transaction_documents':
      return l10n.documents;
    case 'transaction_schedules':
      return l10n.schedules;
    case 'receivables':
      return l10n.receivables;
    case 'payables':
      return l10n.payables;
    case 'reminders':
      return l10n.reminders;
    case 'app_currencies':
      return l10n.currencies;
    case 'user_preferences':
      return l10n.preferences;
    case 'tags':
      return l10n.tags;
    case 'products':
      return l10n.products;
    case 'product_batches':
      return l10n.batches;
    case 'catalogs':
      return l10n.catalogs;
    case 'catalog_items':
      return l10n.catalogItems;
    case 'catalog_assignments':
      return l10n.catalogAssignments;
    case 'catalog_tiered_discounts':
      return l10n.catalogTieredDiscounts;
    case 'orders':
      return l10n.orders;
    case 'order_items':
      return l10n.orderItems;
    case 'goods_receipts':
      return l10n.goodsReceipts;
    case 'goods_receipt_lines':
      return l10n.goodsReceiptLines;
    case 'order_returns':
      return l10n.returns;
    case 'order_return_items':
      return l10n.orderReturnItems;
    case 'recipes':
      return l10n.recipes;
    case 'recipe_inputs':
      return l10n.recipeInputs;
    case 'recipe_outputs':
      return l10n.recipeOutputs;
    case 'recipe_charges':
      return l10n.recipeCharges;
    case 'production_orders':
      return l10n.productionOrders;
    case 'production_order_inputs':
      return l10n.productionOrderInputs;
    case 'production_order_outputs':
      return l10n.productionOrderOutputs;
    case 'production_order_charges':
      return l10n.productionOrderCharges;
    case 'production_consumptions':
      return l10n.productionConsumptions;
    default:
      return table;
  }
}

/// Maps raw table counts into user-facing feature groups (with drill-down rows).
List<_SyncChangeGroup> _groupUnsyncedBreakdown(
  Map<String, int> breakdown,
  AppLocalizations l10n,
) {
  String groupIdFor(String table) {
    switch (table) {
      case 'categories':
      case 'product_categories':
        return 'categories';
      case 'contacts':
        return 'contacts';
      case 'accounts':
      case 'account_transfers':
        return 'accounts';
      case 'transactions':
      case 'transaction_tags':
        return 'transactions';
      case 'transaction_documents':
        return 'documents';
      case 'transaction_schedules':
        return 'schedules';
      case 'receivables':
        return 'receivables';
      case 'payables':
        return 'payables';
      case 'reminders':
        return 'reminders';
      case 'app_currencies':
        return 'currencies';
      case 'user_preferences':
        return 'preferences';
      case 'tags':
        return 'tags';
      case 'products':
      case 'product_batches':
        return 'products';
      case 'catalogs':
      case 'catalog_items':
      case 'catalog_assignments':
      case 'catalog_tiered_discounts':
        return 'catalogs';
      case 'orders':
      case 'order_items':
      case 'goods_receipts':
      case 'goods_receipt_lines':
      case 'order_returns':
      case 'order_return_items':
        return 'orders';
      case 'recipes':
      case 'recipe_inputs':
      case 'recipe_outputs':
      case 'recipe_charges':
        return 'recipes';
      case 'production_orders':
      case 'production_order_inputs':
      case 'production_order_outputs':
      case 'production_order_charges':
      case 'production_consumptions':
        return 'production';
      default:
        return table;
    }
  }

  (String label, IconData icon) metaFor(String groupId) {
    switch (groupId) {
      case 'categories':
        return (l10n.categories, Icons.category_rounded);
      case 'contacts':
        return (l10n.contacts, Icons.people_rounded);
      case 'accounts':
        return (l10n.accounts, Icons.account_balance_wallet_rounded);
      case 'transactions':
        return (l10n.transactions, Icons.receipt_long_rounded);
      case 'documents':
        return (l10n.documents, Icons.insert_drive_file_rounded);
      case 'schedules':
        return (l10n.schedules, Icons.schedule_rounded);
      case 'receivables':
        return (l10n.receivables, Icons.call_received_rounded);
      case 'payables':
        return (l10n.payables, Icons.call_made_rounded);
      case 'reminders':
        return (l10n.reminders, Icons.notifications_active_rounded);
      case 'currencies':
        return (l10n.currencies, Icons.monetization_on_rounded);
      case 'preferences':
        return (l10n.preferences, Icons.settings_rounded);
      case 'tags':
        return (l10n.tags, Icons.local_offer_rounded);
      case 'products':
        return (l10n.products, Icons.inventory_2_rounded);
      case 'catalogs':
        return (l10n.catalogs, Icons.price_change_rounded);
      case 'orders':
        return (l10n.orders, Icons.shopping_cart_rounded);
      case 'recipes':
        return (l10n.recipes, Icons.menu_book_rounded);
      case 'production':
        return (l10n.productionOrders, Icons.precision_manufacturing_rounded);
      default:
        return (groupId, Icons.info_outline_rounded);
    }
  }

  final grouped = <String, List<_SyncTableDetail>>{};
  for (final entry in breakdown.entries) {
    if (entry.value <= 0) continue;
    final id = groupIdFor(entry.key);
    (grouped[id] ??= []).add(
      _SyncTableDetail(
        table: entry.key,
        label: _syncTableLabel(entry.key, l10n),
        count: entry.value,
      ),
    );
  }

  final groups = grouped.entries.map((e) {
    final details = e.value.toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final meta = metaFor(e.key);
    final total = details.fold<int>(0, (sum, d) => sum + d.count);
    return _SyncChangeGroup(
      id: e.key,
      label: meta.$1,
      icon: meta.$2,
      count: total,
      details: details,
    );
  }).toList()
    ..sort((a, b) => b.count.compareTo(a.count));

  return groups;
}

class SyncStatusSection extends ConsumerStatefulWidget {
  const SyncStatusSection({super.key});

  @override
  ConsumerState<SyncStatusSection> createState() => _SyncStatusSectionState();
}

class _SyncStatusSectionState extends ConsumerState<SyncStatusSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Scale animation with stronger bounce effect
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_animationController);

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Start animation after a small delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showUnsyncedBreakdownSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: theme.colorScheme.surface,
      builder: (sheetContext) {
        return FutureBuilder<Map<String, int>>(
          future: ref.read(backupProvider.notifier).getUnsyncedBreakdown(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final breakdown = snapshot.data ?? {};
            if (breakdown.isEmpty) {
              return SizedBox(
                height: 150,
                child: Center(
                  child: Text(
                    l10n.dataSynced,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              );
            }

            final groups = _groupUnsyncedBreakdown(breakdown, l10n);
            VoidCallback? groupNavigation(_SyncChangeGroup group) {
              switch (group.id) {
                case 'categories':
                  return () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CategoriesListScreen()),
                      );
                case 'contacts':
                  return () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ContactsListScreen()),
                      );
                case 'accounts':
                  return () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AccountsScreen()),
                      );
                case 'transactions':
                  return () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionsListScreen(
                            initialFilters: TransactionFilters(
                              statusCodes: ['CHANGES'],
                            ),
                          ),
                        ),
                      );
                case 'receivables':
                  return () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ReceivablesListScreen()),
                      );
                case 'payables':
                  return () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PayablesListScreen()),
                      );
                case 'documents':
                  return () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DocumentsScreen()),
                      );
                case 'products':
                case 'catalogs':
                  return () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProductsListScreen()),
                      );
                case 'orders':
                  return () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const OrdersListScreen()),
                      );
                case 'recipes':
                  return () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ProductionOrdersListScreen(initialTab: 1),
                        ),
                      );
                case 'production':
                  return () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const ProductionOrdersListScreen()),
                      );
                default:
                  return null;
              }
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.orange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.unsyncedChanges,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          final navigationAction = groupNavigation(group);
                          final muted = theme.colorScheme.onSurfaceVariant;

                          Widget countBadge(int count) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$count',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Theme(
                              data: theme.copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                leading: Icon(
                                  group.icon,
                                  color: theme.colorScheme.primary,
                                ),
                                title: Text(
                                  group.label,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    countBadge(group.count),
                                    if (navigationAction != null)
                                      IconButton(
                                        tooltip: group.label,
                                        visualDensity: VisualDensity.compact,
                                        icon: Icon(
                                          Icons.open_in_new_rounded,
                                          size: 18,
                                          color: muted.withValues(alpha: 0.8),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(sheetContext);
                                          navigationAction();
                                        },
                                      ),
                                    Icon(
                                      Icons.expand_more_rounded,
                                      color: muted.withValues(alpha: 0.7),
                                    ),
                                  ],
                                ),
                                children: [
                                  for (final detail in group.details)
                                    ListTile(
                                      dense: true,
                                      contentPadding:
                                          const EdgeInsets.fromLTRB(72, 0, 16, 0),
                                      title: Text(
                                        detail.label,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        detail.table,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: muted.withValues(alpha: 0.75),
                                          fontFamily: 'monospace',
                                          fontSize: 10,
                                        ),
                                      ),
                                      trailing: countBadge(detail.count),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep sync status polling active while this section is visible (reactive approach).
    ref.watch(syncStatusPollingProvider);
    final backupState = ref.watch(backupProvider);
    final activeCashbookId = ref.watch(activeBusinessIdProvider);

    // Ignore cross-cashbook status updates by returning early if the
    // sync state does not belong to the currently active cashbook.
    if (backupState.selectedCloudCashbookId != null &&
        backupState.selectedCloudCashbookId != activeCashbookId) {
      if (_animationController.value != 0) {
        _animationController.reset();
      }
      return const SizedBox.shrink();
    }

    final isPremium = PremiumGate.isPremium(ref);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isSyncing = backupState.syncStatus == 'Syncing...' ||
        backupState.syncStatus == 'Processing...' ||
        backupState.syncStatus == 'Pulling...' ||
        backupState.syncStatus == 'Pushing...';
    final bool isSuccess = backupState.syncStatus == 'Success';
    final bool hasUnsynced = backupState.unsyncedCount > 0;

    // Recalculate these values on every build to ensure reactivity
    final int localVer = backupState.localVersion;
    final int cloudVer = backupState.cloudVersion;
    final int updatesCount = cloudVer - localVer;
    final bool hasCloudUpdates = updatesCount > 0;

    final bool isSignedIn = backupState.currentUser != null;
    final bool documentSyncRequired = ref.watch(documentSyncRequiredProvider);

    if (kDebugMode &&
        (isSyncing || isSuccess || hasUnsynced || hasCloudUpdates)) {
      print('[SyncStatusSection] Active Cashbook: $activeCashbookId');
      print('[SyncStatusSection] Sync Status: ${backupState.syncStatus}');
      print('[SyncStatusSection] Local Ver: $localVer | Cloud Ver: $cloudVer');
      print('[SyncStatusSection] Unsynced Count: ${backupState.unsyncedCount}');
    }

    final bool isSyncAlreadyInProgress =
        backupState.syncStatus == 'Sync already in progress';
    final bool isLockError = backupState.syncStatus.contains('Error') &&
        _isDatabaseLockedError(backupState.syncStatus);

    // Hide section if nothing to sync, no updates, not success/syncing, and no special status
    if (!isSyncing &&
        !isSuccess &&
        !hasUnsynced &&
        !hasCloudUpdates &&
        !isSyncAlreadyInProgress &&
        !isLockError &&
        !documentSyncRequired) {
      if (_animationController.value != 0) {
        _animationController.reset();
      }
      return const SizedBox.shrink();
    }

    // Start animation if it hasn't started yet
    if (_animationController.status == AnimationStatus.dismissed) {
      _animationController.forward();
    }

    String statusText;
    IconData statusIcon;
    Color statusColor;

    if (isSyncAlreadyInProgress) {
      statusText = l10n.syncAlreadyInProgress;
      statusIcon = Platform.isWindows ? Icons.sync : Symbols.sync;
      statusColor = Colors.orange;
    } else if (isLockError) {
      statusText = l10n.syncDelayedRetryShortly;
      statusIcon = Platform.isWindows ? Icons.sync : Symbols.sync;
      statusColor = Colors.orange;
    } else if (isSyncing) {
      statusText = l10n.processing;
      statusIcon = Platform.isWindows ? Icons.sync : Symbols.sync;
      statusColor = theme.colorScheme.primary;
    } else if (hasUnsynced) {
      statusText = l10n.changesToPush(backupState.unsyncedCount);
      statusIcon = Platform.isWindows ? Icons.cloud_upload : Symbols.cloud_upload;
      statusColor = Colors.orange;
    } else if (hasCloudUpdates) {
      statusText = updatesCount == 1
          ? l10n.oneUpdateAvailable
          : l10n.multipleUpdatesAvailable(updatesCount);
      statusIcon = Platform.isWindows ? Icons.cloud_download : Symbols.cloud_download;
      statusColor = Colors.lightBlue;
    } else {
      statusText = l10n.dataSynced;
      statusIcon = Platform.isWindows ? Icons.cloud_done : Symbols.cloud_done;
      statusColor = Colors.green;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withValues(alpha: isDark ? 0.3 : 0.1),
                statusColor.withValues(alpha: isDark ? 0.4 : 0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withValues(alpha: 0.3),
                          statusColor.withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSyncing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: AppLoadingIndicator(size: 20),
                          )
                        : (Platform.isWindows && statusIcon == Symbols.cloud_done)
                            ? Icon(
                                Icons.check_circle_outline,
                                color: statusColor,
                                size: 24,
                              )
                            : Icon(
                                statusIcon,
                                color: statusColor,
                                size: 24,
                              ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: hasUnsynced ? () => _showUnsyncedBreakdownSheet(context) : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.syncStatusTitle,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: statusColor.withValues(alpha: 0.8),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    statusText,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 14,
                                      decoration: hasUnsynced ? TextDecoration.underline : null,
                                      decorationColor: statusColor.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                                if (hasUnsynced) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 14,
                                    color: statusColor.withValues(alpha: 0.7),
                                  ),
                                ],
                              ],
                            ),
                            if (localVer > 0 || backupState.lastSyncTime != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  if (localVer > 0)
                                    Text(
                                      'Version: $localVer',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  if (localVer > 0 && backupState.lastSyncTime != null)
                                    Text(
                                      '  •  ',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                                        fontSize: 11,
                                      ),
                                    ),
                                  if (backupState.lastSyncTime != null)
                                    Expanded(
                                      child: Text(
                                        'Synced: ${AppDateFormatter.formatRelativeTime(backupState.lastSyncTime!, context)}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if ((hasUnsynced || hasCloudUpdates) && !isSyncing)
                    Container(
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          if (Platform.isWindows || isPremium) {
                            if (isSignedIn) {
                              ref
                                  .read(backupProvider.notifier)
                                  .triggerSync(l10n);
                            } else {
                              final success = await ref
                                  .read(backupProvider.notifier)
                                  .signInIfNeeded();
                              if (success) {
                                ref
                                    .read(backupProvider.notifier)
                                    .triggerSync(l10n);
                              }
                            }
                          } else {
                            PremiumGate.showPremiumDialog(context);
                          }
                        },
                        icon: Icon(
                          Platform.isWindows ? Icons.sync : Symbols.sync,
                          color: statusColor,
                          size: 24,
                        ),
                        tooltip: l10n.syncNow,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  if (isSuccess && !hasUnsynced && !hasCloudUpdates)
                    Container(
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          // Manually check for any new cloud updates or local changes
                          try {
                            // Show standard checking feedback
                            ref.read(backupProvider.notifier).refreshVersions();
                          } catch (_) {}
                        },
                        icon: Icon(
                          Platform.isWindows ? Icons.sync : Symbols.sync,
                          color: statusColor,
                          size: 24,
                        ),
                        tooltip: 'Check for updates',
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  if (isSyncing)
                    Icon(
                      Platform.isWindows ? Icons.sync : Symbols.clock_loader_20_rounded,
                      color: statusColor.withValues(alpha: 0.7),
                      size: 28,
                    ),
                ],
              ),
              if (documentSyncRequired) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DocumentsScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.documentSyncRequired,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.documentSyncRequiredSubtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: statusColor.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 4),
              Consumer(
                builder: (context, ref, child) {
                  final autoSync = ref.watch(autoSyncOnStartupProvider);
                  return InkWell(
                    onTap: () {
                      ref
                          .read(autoSyncOnStartupProvider.notifier)
                          .setAutoSync(!autoSync);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Row(
                        children: [
                          Icon(
                            autoSync
                                ? (Platform.isWindows ? Icons.sync_lock : Symbols.sync_lock)
                                : (Platform.isWindows ? Icons.sync_disabled : Symbols.sync_disabled),
                            size: 18,
                            color: autoSync
                                ? statusColor.withValues(alpha: 0.8)
                                : theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.autoSyncOnStartup,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 24,
                            child: Transform.scale(
                              scale: 0.7,
                              child: Switch(
                                value: autoSync,
                                onChanged: (value) {
                                  ref
                                      .read(autoSyncOnStartupProvider.notifier)
                                      .setAutoSync(value);
                                },
                                activeColor: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
