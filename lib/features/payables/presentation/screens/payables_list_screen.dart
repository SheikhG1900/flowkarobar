import 'package:flutter_svg/flutter_svg.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/shared/widgets/faded_bottom_logo.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/payables/presentation/screens/add_payable_screen.dart';
import 'package:flowpaisa/features/payables/presentation/screens/edit_payable_screen.dart';
import 'package:flowpaisa/features/payables/presentation/widgets/payable_details_dialog.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/shared/widgets/swipeable_list_item.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/filter_bottom_sheet.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:flowpaisa/shared/widgets/collapsible_list_summary.dart';
import 'package:flowpaisa/shared/widgets/app_floating_action_button.dart';

class PayablesListScreen extends ConsumerStatefulWidget {
  final bool startTour;
  const PayablesListScreen({super.key, this.startTour = false});

  @override
  ConsumerState<PayablesListScreen> createState() => _PayablesListScreenState();
}

class _PayablesListScreenState extends ConsumerState<PayablesListScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  late ScrollController _scrollController;
  int _previousOverdueCount = -1;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _initializeTabController(int tabCount) {
    if (_tabController != null) {
      if (_tabController!.length == tabCount) return;
      _tabController!.removeListener(_onTabChanged);
      final oldController = _tabController!;
      // Use a microtask to dispose to avoid disposing during build
      Future.microtask(() => oldController.dispose());
    }
    _tabController = TabController(length: tabCount, vsync: this);
    _tabController!.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getStatusForTabIndex(int index, bool hasOverdueTab) {
    if (hasOverdueTab) {
      // Tabs: Pending (0), Overdue (1), Paid (2)
      return index == 0 ? 'PENDING' : (index == 1 ? 'OVERDUE' : 'PAID');
    } else {
      // Tabs: Pending (0), Paid (1)
      return index == 0 ? 'PENDING' : 'PAID';
    }
  }

  void _onTabChanged() {
    if (_tabController?.indexIsChanging ?? false) {
      // Reset scroll position when tab changes (only if attached)
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      // Refresh pagination for the new tab
      final overdueCountAsync = ref.read(overduePayablesCountProvider);
      final hasOverdueTab = (overdueCountAsync.value ?? 0) > 0;
      final status =
          _getStatusForTabIndex(_tabController!.index, hasOverdueTab);
      ref.read(payablesPaginatedProvider(status).notifier).refresh();
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom
      final overdueCountAsync = ref.read(overduePayablesCountProvider);
      final hasOverdueTab = (overdueCountAsync.value ?? 0) > 0;
      final status =
          _getStatusForTabIndex(_tabController?.index ?? 0, hasOverdueTab);
      ref.read(payablesPaginatedProvider(status).notifier).loadMore();
    }
  }

  void _showFilterBottomSheet() {
    final overdueCountAsync = ref.read(overduePayablesCountProvider);
    final hasOverdueTab = (overdueCountAsync.value ?? 0) > 0;
    final status =
        _getStatusForTabIndex(_tabController?.index ?? 0, hasOverdueTab);
    final notifier = ref.read(payablesPaginatedProvider(status).notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => FilterBottomSheet(
          type: FilterType.payables,
          initialFilters: notifier.currentFilters,
          scrollController: scrollController,
          onApply: (filters) {
            notifier.applyFilters(filters);
            setState(() {}); // Force rebuild to update badge
          },
        ),
      ),
    );
  }

  Widget _buildTabWithCount(String label, int count, {bool isOverdue = false}) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isOverdue
                    ? Colors.red.withValues(alpha: 0.2)
                    : AppColors.payableColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isOverdue ? Colors.red : AppColors.payableColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCountAsync = ref.watch(pendingPayablesCountProvider);
    final overdueCountAsync = ref.watch(overduePayablesCountProvider);
    final pendingCount = pendingCountAsync.value ?? 0;
    final overdueCount = overdueCountAsync.value ?? 0;
    final hasOverdueTab = overdueCount > 0;
    final tabCount = hasOverdueTab ? 3 : 2;

    // Initialize or update TabController when tab count changes
    if (_previousOverdueCount != overdueCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializeTabController(tabCount);
          _previousOverdueCount = overdueCount;
        }
      });
    }

    if (_tabController == null) {
      _initializeTabController(tabCount);
      _previousOverdueCount = overdueCount;
    }

    final l10n = AppLocalizations.of(context)!;
    final status =
        _getStatusForTabIndex(_tabController?.index ?? 0, hasOverdueTab);
    final currentFilters =
        ref.watch(payablesPaginatedProvider(status).notifier).currentFilters;
    final hasActiveFilters = !currentFilters.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
                ? TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '${l10n.search}...',
                      border: InputBorder.none,
                      hintStyle: const TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      ref
                          .read(payablesPaginatedProvider(status).notifier)
                          .updateSearchQuery(value);
                    },
                  )
                : Text(l10n.payables),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    if (_isSearching) {
                      ref
                          .read(payablesPaginatedProvider(status).notifier)
                          .updateSearchQuery('');
                    }
                    _isSearching = !_isSearching;
                  });
                },
              ),
              IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.filter_list),
                    if (hasActiveFilters)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 8,
                            minHeight: 8,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: _showFilterBottomSheet,
              ),
              // Debug button to generate dummy payables (only in debug mode)
              if (kDebugMode)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.bug_report),
                  onSelected: (value) async {
                    if (value == 'generate_dummy') {
                      final repository = ref.read(payablesRepositoryProvider);
                      final contactsRepo = ref.read(contactsRepositoryProvider);
                      try {
                        final contacts =
                            await contactsRepo.watchAllContacts().first;
                        String defaultContactUuid;
                        if (contacts.isNotEmpty) {
                          defaultContactUuid = contacts[0].uuid;
                        } else {
                          // Create a default contact if none exists
                          defaultContactUuid = await contactsRepo.createContact(
                            ContactsCompanion(
                              name: const Value('Default Contact'),
                              createdAt: Value(DateTime.now()),
                              updatedAt: Value(DateTime.now()),
                            ),
                          );
                        }

                        for (int i = 0; i < 100; i++) {
                          final daysAgo = i ~/ 2;
                          final date =
                              DateTime.now().subtract(Duration(days: daysAgo));
                          final amount =
                              (50.0 + (i * 15.3) % 2000).roundToDouble();
                          final contactUuid = contacts.isNotEmpty
                              ? contacts[i % contacts.length].uuid
                              : defaultContactUuid;

                          await repository.createPayable(
                            PayablesCompanion(
                              contactUuid: Value(contactUuid),
                              amount: Value(amount),
                              description: Value('Dummy Payable #${i + 1}'),
                              date: Value(date),
                              status: Value(i % 3 == 0 ? 'PAID' : 'PENDING'),
                              createdAt: Value(DateTime.now()),
                              updatedAt: Value(DateTime.now()),
                            ),
                          );
                        }
                        if (context.mounted) {
                          ToastUtils.showSuccessToast(
                              context, ref, l10n.dummyPayablesGenerated);
                          // Refresh pagination
                          ref
                              .read(
                                  payablesPaginatedProvider('PENDING').notifier)
                              .refresh();
                          ref
                              .read(payablesPaginatedProvider('PAID').notifier)
                              .refresh();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ToastUtils.showErrorToast(
                              context, ref, l10n.errorOccurred(e.toString()));
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'generate_dummy',
                      child: Row(
                        children: [
                          const Icon(Icons.add_circle_outline),
                          const SizedBox(width: 8),
                          Text(l10n.generateDummyPayables),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
            bottom: _tabController == null
                ? null
                : TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.payableColor,
                    labelColor: AppColors.payableColor,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                    tabs: [
                      _buildTabWithCount(l10n.pending, pendingCount),
                      if (hasOverdueTab)
                        _buildTabWithCount(l10n.overdue, overdueCount,
                            isOverdue: true),
                      Tab(text: l10n.paid),
                    ],
                  ),
          ),
          body: _tabController == null
              ? const AppLoadingIndicator(size: 60)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPayablesList('PENDING'),
                    if (hasOverdueTab) _buildPayablesList('OVERDUE'),
                    _buildPayablesList('PAID'),
                  ],
                ),
          floatingActionButton: AppFloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPayableScreen(),
                ),
              );
            },
            backgroundColor: AppColors.payablesSectionColor,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
    );
  }

  Widget _buildPayablesList(String status) {
    // Use paginated provider
    final paginatedState = ref.watch(payablesPaginatedProvider(status));
    final theme = Theme.of(context);
    final repository = ref.read(payablesRepositoryProvider);
    final currency = ref.watch(currentCurrencyProvider).value;

    final l10n = AppLocalizations.of(context)!;
    if (currency == null) {
      return const AppLoadingIndicator(size: 60);
    }

    if (paginatedState.isLoading && paginatedState.items.isEmpty) {
      return const AppLoadingIndicator(size: 60);
    }

    if (paginatedState.error != null && paginatedState.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingPayables,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              paginatedState.error!,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(payablesPaginatedProvider(status).notifier).refresh();
              },
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (paginatedState.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'PENDING'
                  ? Icons.hourglass_empty
                  : status == 'OVERDUE'
                      ? Icons.warning
                      : Icons.check_circle_outline,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              status == 'PENDING'
                  ? l10n.noPendingPayables
                  : status == 'OVERDUE'
                      ? l10n.noOverduePayables
                      : l10n.noPaidBills,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              status == 'PENDING'
                  ? l10n.addPayableSubtitle
                  : status == 'OVERDUE'
                      ? l10n.allPayablesUpToDate
                      : l10n.markPendingAsPaidSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Group by Date
    final groupedPayables = <String, List>{};
    final userProfile = ref.watch(userProfileProvider);

    for (final item in paginatedState.items) {
      if (item == null || item.payable == null) continue;

      // Ensure date is not null before formatting
      final dateToFormat = item.payable.date;
      final pattern = userProfile.dateFormat ?? 'MMM dd, yyyy';

      try {
        final dateKey =
            AppDateFormatter.formatDate(dateToFormat, pattern: pattern);
        groupedPayables.putIfAbsent(dateKey, () => []);
        groupedPayables[dateKey]!.add(item);
      } catch (e) {
        const fallbackKey = 'Other';
        groupedPayables.putIfAbsent(fallbackKey, () => []);
        groupedPayables[fallbackKey]!.add(item);
      }
    }

    final keys = groupedPayables.keys.toList();

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: CollapsibleListSummary(
              title: l10n.summary,
              child: _PayablesListSummaryContent(status: status),
            ),
          ),
        ),
        // Date sections with sticky headers
        for (final dateKey in keys)
          SliverStickyHeader(
            header: _buildPayableDateSectionHeader(
              theme,
              dateKey,
              _monthFromPayableGroup(groupedPayables[dateKey]!),
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, itemIndex) {
                  final dateItems = groupedPayables[dateKey]!;
                  if (itemIndex >= dateItems.length) return null;

                  final item = dateItems[itemIndex];
                  // Restrict editing/deleting for paid or linked payables
                  final canEdit = item.payable.status == 'PENDING' &&
                      item.payable.linkedExpenseUuid == null &&
                      item.payable.linkedIncomeUuid == null;

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: SwipeableListItem(
                      enableEdit: canEdit,
                      enableDelete: canEdit,
                      borderRadius: 20,
                      confirmTitle: l10n.deletePayable,
                      confirmMessage: l10n.deletePayableConfirm,
                      deleteLabel: l10n.delete,
                      onEdit: canEdit
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditPayableScreen(
                                      payableUuid: item.payable.uuid),
                                ),
                              );
                            }
                          : null,
                      onDelete: canEdit
                          ? () async {
                              await repository.deletePayable(item.payable.uuid);
                              if (context.mounted) {
                                ToastUtils.showSuccessToast(
                                    context, ref, l10n.payableDeleted);
                              }
                            }
                          : null,
                      child: _buildPayableCard(item, currency),
                    ),
                  );
                },
                childCount: groupedPayables[dateKey]!.length,
              ),
            ),
          ),
        // Loading indicator or "No more items"
        if (paginatedState.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: AppLoadingIndicator(size: 30),
            ),
          )
        else if (!paginatedState.hasMore && paginatedState.items.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  l10n.noMorePayables,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        // Bottom padding
        SliverToBoxAdapter(
          child: FadedBottomLogo(
            bottomPadding: 80 + MediaQuery.of(context).padding.bottom,
          ),
        ),
      ],
    );
  }

  int? _monthFromPayableGroup(List<dynamic> items) {
    if (items.isEmpty) return null;
    final first = items.first;
    if (first == null || first.payable == null) return null;
    return first.payable.date.month;
  }

  Widget _buildPayableDateSectionHeader(
    ThemeData theme,
    String dateKey,
    int? month,
  ) {
    final chipBg = AppColors.transactionDateChipBackground(theme, month);
    final chipFg = AppColors.transactionDateChipForeground(theme, month);
    final chipShadow = AppColors.transactionDateChipShadow(theme, month);
    return Container(
      key: ValueKey('payable-date-header-$dateKey'),
      height: 50,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Container(
        key: ValueKey('payable-date-header-inner-$dateKey'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: chipShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          key: ValueKey('payable-date-header-text-$dateKey'),
          dateKey,
          style: theme.textTheme.titleSmall?.copyWith(
            color: chipFg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPayableCard(dynamic item, AppCurrency currency) {
    if (item == null || item.payable == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final payable = item.payable;
    final contact = item.contact;
    final linkedCategory = item.linkedCategory;
    final linkedTransaction = item.linkedTransaction;
    final isPending = payable.status == 'PENDING';

    // Dynamic font size based on amount
    final amountFontSize = AmountFormatter.getFontSize(payable.amount);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.payableColor.withValues(alpha: isDark ? 0.2 : 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppColors.payableColor.withValues(alpha: isDark ? 0.05 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PayableDetailsDialog(payableUuid: payable.uuid),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Contact Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.getContactGradient(contact?.name ?? ''),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.getContactColor(contact?.name ?? '')
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    contact?.name.isNotEmpty == true
                        ? contact!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact?.name ?? l10n.unknown,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Linked category or transaction type tag
                      if (linkedCategory != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: linkedCategory.color != null
                                ? Color(int.parse(linkedCategory.color!
                                        .replaceAll('#', '0xFF')))
                                    .withValues(alpha: 0.1)
                                : AppColors.expenseColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: linkedCategory.color != null
                                  ? Color(int.parse(linkedCategory.color!
                                          .replaceAll('#', '0xFF')))
                                      .withValues(alpha: 0.3)
                                  : AppColors.expenseColor
                                      .withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                linkedCategory.icon != null
                                    ? IconHelper.getIconData(
                                        linkedCategory.icon)
                                    : Symbols.category,
                                color: linkedCategory.color != null
                                    ? Color(int.parse(linkedCategory.color!
                                        .replaceAll('#', '0xFF')))
                                    : AppColors.expenseColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  LocalizationHelper.getLocalizedCategoryName(
                                      context, linkedCategory.name),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: linkedCategory.color != null
                                        ? Color(int.parse(linkedCategory.color!
                                            .replaceAll('#', '0xFF')))
                                        : AppColors.expenseColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (linkedTransaction != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: linkedTransaction.type == 'EXPENSE'
                                ? AppColors.expenseColor.withValues(alpha: 0.1)
                                : AppColors.incomeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: linkedTransaction.type == 'EXPENSE'
                                  ? AppColors.expenseColor
                                      .withValues(alpha: 0.3)
                                  : AppColors.incomeColor
                                      .withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                linkedTransaction.type == 'EXPENSE'
                                    ? Icons.payment
                                    : Icons.monetization_on,
                                color: linkedTransaction.type == 'EXPENSE'
                                    ? AppColors.expenseColor
                                    : AppColors.incomeColor,
                                size: 10,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                linkedTransaction.type == 'EXPENSE'
                                    ? l10n.expense
                                    : l10n.income,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: linkedTransaction.type == 'EXPENSE'
                                      ? AppColors.expenseColor
                                      : AppColors.incomeColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (payable.description != null &&
                          payable.description!.isNotEmpty)
                        Text(
                          payable.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (payable.dueDate != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.event,
                              size: 12,
                              color: isPending
                                  ? (payable.dueDate!.isBefore(DateTime.now())
                                      ? Colors.red
                                      : Colors.orange)
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                l10n.dueAt(AppDateFormatter.formatDate(
                                    payable.dueDate!,
                                    pattern: ref
                                            .watch(userProfileProvider)
                                            .dateFormat ??
                                        'MMM dd, yyyy')),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isPending
                                      ? (payable.dueDate!
                                              .isBefore(DateTime.now())
                                          ? Colors.red
                                          : Colors.orange)
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontWeight:
                                      isPending ? FontWeight.bold : null,
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
                const SizedBox(width: 8),

                // Amount and Tags
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\u200E${AmountFormatter.formatWithCurrency(payable.amount, currency.symbol, currency.decimalPlaces)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.payableColor,
                        fontWeight: FontWeight.bold,
                        fontSize: amountFontSize,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Status badge (Payable or Paid)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.payableColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.payableColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isPending) ...[
                            Icon(
                              Icons.check_circle,
                              size: 10,
                              color: AppColors.payableColor,
                            ),
                            const SizedBox(width: 3),
                          ],
                          Text(
                            isPending ? l10n.payableTag : l10n.paidTag,
                            style: TextStyle(
                              color: AppColors.payableColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PayablesListSummaryContent extends ConsumerWidget {
  final String status;

  const _PayablesListSummaryContent({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAsync = ref.watch(payablesListTotalProvider(status));
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final decimalPlaces = ref.watch(currencyDecimalPlacesProvider);

    return totalAsync.when(
      data: (total) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.payableColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: AppColors.payableColor.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              status == 'PAID'
                  ? l10n.paidTag
                  : status == 'OVERDUE'
                      ? l10n.overdue
                      : l10n.payableTag,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              AmountFormatter.formatWithCurrency(
                  total, currencySymbol, decimalPlaces),
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.payableColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
