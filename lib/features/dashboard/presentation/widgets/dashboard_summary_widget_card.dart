import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/dashboard/domain/dashboard_widget_models.dart';
import 'package:flowpaisa/features/dashboard/domain/models.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_widget_provider.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/transactions_list_screen.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/contacts_list_screen.dart';
import 'package:flowpaisa/features/categories/presentation/screens/categories_list_screen.dart';
import 'package:flowpaisa/features/receivables/presentation/screens/receivables_list_screen.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/receivables/domain/models.dart';
import 'package:flowpaisa/features/payables/presentation/screens/payables_list_screen.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/payables/domain/models.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:flowpaisa/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/voice_command/presentation/screens/voice_add_screen.dart';
import 'package:flowpaisa/features/receipt_scan/presentation/screens/scan_receipt_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/user_guide_screen.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:flowpaisa/features/tour/domain/tour_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:material_symbols_icons/symbols.dart' show Symbols;

/// A summary-type widget card on the dashboard (balance, cash flow, receivables, etc.).
class DashboardSummaryWidgetCard extends ConsumerWidget {
  final DashboardWidgetConfig config;
  final int layoutIndex;
  final Key? reorderKey;

  const DashboardSummaryWidgetCard({
    super.key,
    required this.config,
    required this.layoutIndex,
    this.reorderKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (config.kind.isEntity) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;
    final filter = ref.watch(dashboardFilterProvider);
    final isPremium = PremiumGate.isPremium(ref);
    final reorderMode = ref.watch(dashboardReorderModeProvider);

    switch (config.kind) {
      case DashboardWidgetKind.balance:
        return _buildFromStats(
          context,
          ref,
          theme,
          l10n,
          currency,
          filter,
          title: l10n.availableCash,
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.dashboardSectionColor,
          builder: (stats) => AmountFormatter.formatWithCurrency(
              stats.totalBalance, currency!.symbol, currency.decimalPlaces),
          onTap: () {},
          onRemove: () => _removeAt(ref, layoutIndex),
          reorderKey: reorderKey,
        );
      case DashboardWidgetKind.cashFlow:
        return _buildFromStats(
          context,
          ref,
          theme,
          l10n,
          currency,
          filter,
          title: l10n.cashFlow,
          icon: Icons.trending_up,
          color: AppColors.incomeColor,
          builder: (stats) => AmountFormatter.formatWithCurrency(
              stats.netCash(filter), currency!.symbol, currency.decimalPlaces),
          onTap: () => _openTransactionsFiltered(ref, context, filter),
          onRemove: () => _removeAt(ref, layoutIndex),
          reorderKey: reorderKey,
        );
      case DashboardWidgetKind.receivablesSummary:
        return _buildFromStats(
          context,
          ref,
          theme,
          l10n,
          currency,
          filter,
          title: l10n.receivableTag,
          icon: Icons.call_received,
          color: AppColors.receivableColor,
          builder: (stats) => AmountFormatter.formatWithCurrency(
              stats.receivable(filter), currency!.symbol, currency.decimalPlaces),
          onTap: () => _openReceivables(ref, context, filter),
          onRemove: () => _removeAt(ref, layoutIndex),
          reorderKey: reorderKey,
        );
      case DashboardWidgetKind.payablesSummary:
        return _buildFromStats(
          context,
          ref,
          theme,
          l10n,
          currency,
          filter,
          title: l10n.payableTag,
          icon: Icons.call_made,
          color: AppColors.payableColor,
          builder: (stats) => AmountFormatter.formatWithCurrency(
              stats.payable(filter), currency!.symbol, currency.decimalPlaces),
          onTap: () => _openPayables(ref, context, filter),
          onRemove: () => _removeAt(ref, layoutIndex),
          reorderKey: reorderKey,
        );
      case DashboardWidgetKind.contactsSummary:
        return _buildCountCard(
          context,
          ref,
          theme,
          l10n,
          title: l10n.contacts,
          icon: Icons.people_outline,
          color: theme.colorScheme.primary,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactsListScreen())),
          onRemove: () => _removeAt(ref, layoutIndex),
          reorderKey: reorderKey,
        );
      case DashboardWidgetKind.categoriesSummary:
        return _buildCategoriesCountCard(
          context,
          ref,
          theme,
          l10n,
          onRemove: () => _removeAt(ref, layoutIndex),
          reorderKey: reorderKey,
        );
      case DashboardWidgetKind.netWorth:
        final accountsAsync = ref.watch(accountsWithBalanceProvider);
        return accountsAsync.when(
          data: (accounts) {
            double totalAssets = 0;
            double totalLiabilities = 0;
            for (final awb in accounts) {
              if (awb.type.isCreditCard) {
                if (awb.balance < 0) {
                  totalLiabilities += awb.balance.abs();
                }
              } else {
                if (awb.balance > 0) {
                  totalAssets += awb.balance;
                } else {
                  totalLiabilities += awb.balance.abs();
                }
              }
            }
            final netWorth = totalAssets - totalLiabilities;
            final label = currency != null
                ? AmountFormatter.formatWithCurrency(
                    netWorth, currency.symbol, currency.decimalPlaces)
                : '—';
            return _buildSummaryCard(
              context,
              ref,
              theme,
              l10n,
              title: l10n.netWorth,
              subtitle: null,
              amountLabel: label,
              icon: Symbols.account_balance_wallet,
              color: AppColors.dashboardSectionColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AccountsScreen()),
                );
              },
              onRemove: () => _removeAt(ref, layoutIndex),
              reorderKey: reorderKey,
              copyOpenLinkEntityType: 'networth',
              copyOpenLinkUuid: 'summary',
            );
          },
          loading: () => _buildCardPlaceholder(theme, reorderKey),
          error: (_, __) => const SizedBox.shrink(),
        );
      case DashboardWidgetKind.quickActions:
        return _buildQuickActions(context, ref, l10n, isPremium, reorderMode);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFromStats(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
    dynamic currency,
    DashboardFilter filter, {
    required String title,
    required IconData icon,
    required Color color,
    required String Function(DashboardStats stats) builder,
    String Function(DashboardStats stats)? subtitle,
    required VoidCallback onTap,
    required VoidCallback onRemove,
    Key? reorderKey,
  }) {
    final async = ref.watch(dashboardStatsProvider);
    return async.when(
      data: (stats) => _buildSummaryCard(
        context,
        ref,
        theme,
        l10n,
        title: title,
        subtitle: subtitle != null ? subtitle(stats) : null,
        amountLabel: builder(stats),
        icon: icon,
        color: color,
        onTap: onTap,
        onRemove: onRemove,
        reorderKey: reorderKey,
      ),
      loading: () => _buildCardPlaceholder(theme, reorderKey),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n, {
    required String title,
    String? subtitle,
    required String amountLabel,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required VoidCallback onRemove,
    Key? reorderKey,
    String? copyOpenLinkEntityType,
    String? copyOpenLinkUuid,
  }) {
    return _wrapCard(
      reorderKey: reorderKey,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            onLongPress: () => _showSummaryActionsSheet(
              context,
              ref,
              onRemove,
              l10n,
              copyOpenLinkEntityType: copyOpenLinkEntityType,
              copyOpenLinkUuid: copyOpenLinkUuid,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    amountLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required VoidCallback onRemove,
    Key? reorderKey,
  }) {
    final async = ref.watch(contactsListProvider);
    return async.when(
      data: (list) => _buildSummaryCard(
        context,
        ref,
        theme,
        l10n,
        title: title,
        amountLabel: '${list.length}',
        icon: icon,
        color: color,
        onTap: onTap,
        onRemove: onRemove,
        reorderKey: reorderKey,
      ),
      loading: () => _buildCardPlaceholder(theme, reorderKey),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCategoriesCountCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n, {
    required VoidCallback onRemove,
    Key? reorderKey,
  }) {
    final async = ref.watch(categoriesListProvider);
    return async.when(
      data: (list) => _buildSummaryCard(
        context,
        ref,
        theme,
        l10n,
        title: l10n.categories,
        amountLabel: '${list.length}',
        icon: Icons.category_outlined,
        color: theme.colorScheme.secondary,
        onTap: () {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CategoriesListScreen(),
              ),
            );
          }
        },
        onRemove: onRemove,
        reorderKey: reorderKey,
      ),
      loading: () => _buildCardPlaceholder(theme, reorderKey),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _wrapCard({Key? reorderKey, required Widget child}) {
    if (reorderKey != null) return KeyedSubtree(key: reorderKey, child: child);
    return child;
  }

  Widget _buildCardPlaceholder(ThemeData theme, Key? reorderKey) {
    return _wrapCard(
      reorderKey: reorderKey,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  void _showSummaryActionsSheet(
    BuildContext context,
    WidgetRef ref,
    VoidCallback onRemove,
    AppLocalizations l10n, {
    String? copyOpenLinkEntityType,
    String? copyOpenLinkUuid,
  }) {
    final copyType = copyOpenLinkEntityType;
    final copyUuid = copyOpenLinkUuid;
    final hasCopy = copyType != null &&
        copyType.isNotEmpty &&
        copyUuid != null &&
        copyUuid.isNotEmpty;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasCopy)
              ListTile(
                leading: const Icon(Icons.link),
                title: Text(l10n.copyLink),
                onTap: () {
                  final link = DeepLinkService().generateEntityOpenLinkHttps(
                    copyType,
                    copyUuid,
                  );
                  Clipboard.setData(ClipboardData(text: link));
                  Navigator.pop(ctx);
                  ToastUtils.showSuccessToast(context, ref, l10n.linkCopied);
                },
              ),
            ListTile(
              leading: const Icon(Icons.push_pin),
              title: Text(l10n.unpinFromDashboard),
              onTap: () {
                Navigator.pop(ctx);
                onRemove();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeAt(WidgetRef ref, int index) async {
    await ref.read(dashboardWidgetLayoutProvider.notifier).removeAt(index);
  }

  static Future<void> _showQuickActionSelectionSheetForWidget(
      BuildContext context,
      WidgetRef ref,
      AppLocalizations l10n,
      ThemeData theme,
      DashboardWidgetConfig config,
      int layoutIndex) async {
    final actions = [
      ('voice_add', l10n.voiceAdd, Icons.mic_none_rounded),
      ('add_transaction', l10n.add, Icons.add),
      ('scan_receipt', l10n.scan, Icons.document_scanner_outlined),
      ('accounts', l10n.accounts, Symbols.account_balance),
      ('contacts', l10n.contacts, Icons.people_outline_rounded),
      ('receivables', l10n.receivableTag, Symbols.account_balance_wallet),
      ('payables', l10n.payables, Icons.payment_outlined),
      ('categories', l10n.categories, Icons.category_outlined),
      ('analytics', l10n.analytics, Icons.bar_chart_rounded),
      ('user_guide', l10n.userGuide, Icons.help_outline_rounded),
      ('app_tour', l10n.appTour, Icons.tour_outlined),
    ];

    final layoutAsync = ref.read(dashboardWidgetLayoutProvider);
    final allConfigs = layoutAsync.value ?? [];

    // Summary widgets that are already on dashboard (excluding THIS widget)
    final existingSummaryKinds = allConfigs
        .where((c) => !c.kind.isEntity && c != config)
        .map((c) => c.kind)
        .toSet();

    final actionToKind = {
      'accounts': DashboardWidgetKind.netWorth,
      'contacts': DashboardWidgetKind.contactsSummary,
      'receivables': DashboardWidgetKind.receivablesSummary,
      'payables': DashboardWidgetKind.payablesSummary,
      'categories': DashboardWidgetKind.categoriesSummary,
    };

    // Filter out actions that are already used as individual summary widgets elsewhere
    final availableActions = actions.where((a) {
      final kind = actionToKind[a.$1];
      if (kind != null && existingSummaryKinds.contains(kind)) return false;
      return true;
    }).toList();

    final currentActions = config.quickActionCodes?.toSet() ??
        actions.map((e) => e.$1).toSet(); // Default to all if null

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.quickActions,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: availableActions.map((e) {
                      final isSelected = currentActions.contains(e.$1);
                      return CheckboxListTile(
                        secondary: Icon(e.$3),
                        title: Text(e.$2),
                        value: isSelected,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              currentActions.add(e.$1);
                            } else {
                              currentActions.remove(e.$1);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    await ref
                        .read(dashboardWidgetLayoutProvider.notifier)
                        .updateWidget(
                          layoutIndex,
                          config.copyWith(
                              quickActionCodes: currentActions.toList()),
                        );
                    if (context.mounted) Navigator.pop(ctx);
                  },
                  child: Text(l10n.save),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openTransactionsFiltered(
      WidgetRef ref, BuildContext context, DashboardFilter filter) {
    final isMonthly = filter == DashboardFilter.monthly;
    final now = DateTime.now();
    final startDate =
        isMonthly ? DateTime(now.year, now.month, 1) : null;
    final endDate =
        isMonthly ? DateTime(now.year, now.month + 1, 0) : null;
    ref.read(transactionsPaginatedProvider.notifier).applyFilters(
          TransactionFilters(
            startDate: startDate,
            endDate: endDate,
          ),
        );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TransactionsListScreen()),
    );
  }

  void _openReceivables(
      WidgetRef ref, BuildContext context, DashboardFilter filter) {
    final isMonthly = filter == DashboardFilter.monthly;
    final now = DateTime.now();
    final startDate =
        isMonthly ? DateTime(now.year, now.month, 1) : null;
    final endDate =
        isMonthly ? DateTime(now.year, now.month + 1, 0) : null;
    ref
        .read(receivablesPaginatedProvider('PENDING').notifier)
        .applyFilters(ReceivableFilters(startDate: startDate, endDate: endDate));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReceivablesListScreen()),
    );
  }

  void _openPayables(
      WidgetRef ref, BuildContext context, DashboardFilter filter) {
    final isMonthly = filter == DashboardFilter.monthly;
    final now = DateTime.now();
    final startDate =
        isMonthly ? DateTime(now.year, now.month, 1) : null;
    final endDate =
        isMonthly ? DateTime(now.year, now.month + 1, 0) : null;
    ref
        .read(payablesPaginatedProvider('PENDING').notifier)
        .applyFilters(PayableFilters(startDate: startDate, endDate: endDate));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PayablesListScreen()),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, bool isPremium, bool reorderMode) {
    final theme = Theme.of(context);
    final activeCashbook = ref.watch(activeCashbookProvider);
    final activeColor = activeCashbook.color;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reorderMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.quickActions,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    onPressed: () => _showQuickActionSelectionSheetForWidget(
                      context,
                      ref,
                      l10n,
                      theme,
                      config,
                      layoutIndex,
                    ),
                  ),
                ],
              ),
            ),
          if (reorderMode) const SizedBox(height: 12),
          // Grid layout for quick actions (responsive)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate optimal item width based on available space
                const double minItemWidth = 100; // Minimum width per item
                final double availableWidth = constraints.maxWidth;

                // Calculate how many items can fit
                int crossAxisCount = (availableWidth / minItemWidth).floor();
                crossAxisCount =
                    crossAxisCount.clamp(2, 6); // Min 2, Max 6 columns

                // Calculate actual item width
                final double itemWidth = availableWidth / crossAxisCount;
                final double childAspectRatio =
                    itemWidth / 110; // Height is fixed at ~110px

                return GridView.count(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: childAspectRatio,
                  children: [
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('voice_add'))
                      _QuickActionButton(
                        icon: Icons.mic_none_rounded,
                        label: l10n.voiceAdd,
                        gradient: AppColors.transactionsSectionGradient,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VoiceAddScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('add_transaction'))
                      _QuickActionButton(
                        icon: Icons.add,
                        label: l10n.add,
                        gradient: AppColors.transactionsSectionGradient,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AddTransactionScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('scan_receipt'))
                      _QuickActionButton(
                        icon: Icons.document_scanner_outlined,
                        label: l10n.scan,
                        gradient: AppColors.transactionsSectionGradient,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScanReceiptScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('accounts'))
                      _QuickActionButton(
                        icon: Symbols.account_balance,
                        label: l10n.accounts,
                        gradient: AppColors.dashboardSectionGradient,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AccountsScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('contacts'))
                      _QuickActionButton(
                        icon: Icons.people_outline_rounded,
                        label: l10n.contacts,
                        gradient: AppColors.getPrimaryGradient(
                            theme.colorScheme.primary),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ContactsListScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('receivables'))
                      _QuickActionButton(
                        icon: Symbols.account_balance_wallet,
                        label: l10n.receivableTag,
                        gradient: AppColors.receivablesSectionGradient,
                        onTap: () {
                          // Clear filters and search before navigating
                          final pendingNotifier = ref.read(
                              receivablesPaginatedProvider('PENDING').notifier);
                          pendingNotifier.updateSearchQuery('');
                          pendingNotifier.applyFilters(ReceivableFilters());

                          final overdueNotifier = ref.read(
                              receivablesPaginatedProvider('OVERDUE').notifier);
                          overdueNotifier.updateSearchQuery('');
                          overdueNotifier.applyFilters(ReceivableFilters());

                          final receivedNotifier = ref.read(
                              receivablesPaginatedProvider('RECEIVED')
                                  .notifier);
                          receivedNotifier.updateSearchQuery('');
                          receivedNotifier.applyFilters(ReceivableFilters());

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ReceivablesListScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('payables'))
                      _QuickActionButton(
                        icon: Icons.payment_outlined,
                        label: l10n.payables,
                        gradient: AppColors.payablesSectionGradient,
                        onTap: () {
                          // Clear filters and search before navigating
                          final pendingNotifier = ref.read(
                              payablesPaginatedProvider('PENDING').notifier);
                          pendingNotifier.updateSearchQuery('');
                          pendingNotifier.applyFilters(PayableFilters());

                          final overdueNotifier = ref.read(
                              payablesPaginatedProvider('OVERDUE').notifier);
                          overdueNotifier.updateSearchQuery('');
                          overdueNotifier.applyFilters(PayableFilters());

                          final paidNotifier = ref
                              .read(payablesPaginatedProvider('PAID').notifier);
                          paidNotifier.updateSearchQuery('');
                          paidNotifier.applyFilters(PayableFilters());

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PayablesListScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('categories'))
                      _QuickActionButton(
                        icon: Icons.category_outlined,
                        label: l10n.categories,
                        gradient: AppColors.getSecondaryGradient(
                            theme.colorScheme.primary),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CategoriesListScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('analytics'))
                      _QuickActionButton(
                        icon: Icons.bar_chart_rounded,
                        label: l10n.analytics,
                        gradient: AppColors.analyticsSectionGradient,
                        showLock: !isPremium,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AnalyticsScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('user_guide'))
                      _QuickActionButton(
                        icon: Icons.help_outline_rounded,
                        label: l10n.userGuide,
                        gradient: AppColors.getSecondaryGradient(
                            theme.colorScheme.secondary),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserGuideScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('app_tour'))
                      _QuickActionButton(
                        icon: Icons.tour_outlined,
                        label: l10n.appTour,
                        gradient: AppColors.getPrimaryGradient(activeColor),
                        onTap: () {
                          // Start the dashboard tour
                          try {
                            final showcaseState = ShowCaseWidget.of(context);
                            showcaseState
                                .startShowCase(TourService.dashboardTourKeys);
                          } catch (e) {
                            debugPrint('Error starting tour: $e');
                          }
                        },
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;
  final bool showLock;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    this.showLock = false,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedPressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
        decoration: BoxDecoration(
          gradient: gradient.withOpacity(0.2),
          border: Border.all(
              color: gradient.colors.first.withValues(alpha: 0.5), width: 1),
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(20),
            bottomEnd: Radius.circular(20),
          ),
          // Diagonal beveled
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: gradient.colors.first.withValues(alpha: 0.8),
                        width: 1),
                    color: gradient.colors.first.withValues(alpha: 0.2 / 1.0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24),
                ),
                if (showLock)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(Icons.lock, size: 12, color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 2,
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

/// Helper widget for press & scale micro-animation
class _AnimatedPressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedPressScale({required this.child, required this.onTap});

  @override
  State<_AnimatedPressScale> createState() => _AnimatedPressScaleState();
}

class _AnimatedPressScaleState extends State<_AnimatedPressScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
