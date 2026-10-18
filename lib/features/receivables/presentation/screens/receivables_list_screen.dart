import 'package:flutter_svg/flutter_svg.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/shared/widgets/faded_bottom_logo.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/widgets/receivable_details_dialog.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/shared/widgets/swipeable_list_item.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/filter_bottom_sheet.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:flowpaisa/shared/widgets/collapsible_list_summary.dart';
import 'package:flowpaisa/shared/widgets/app_floating_action_button.dart';

class ReceivablesListScreen extends ConsumerStatefulWidget {
  final bool startTour;
  const ReceivablesListScreen({super.key, this.startTour = false});

  @override
  ConsumerState<ReceivablesListScreen> createState() =>
      _ReceivablesListScreenState();
}

class _ReceivablesListScreenState extends ConsumerState<ReceivablesListScreen>
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
      // Use a small delay to dispose to avoid "used after being disposed" if a build is in progress
      Future.microtask(() {
        try {
          oldController.dispose();
        } catch (e) {
          debugPrint('Error disposing old TabController: $e');
        }
      });
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
      // Tabs: Pending (0), Overdue (1), Received (2)
      return index == 0 ? 'PENDING' : (index == 1 ? 'OVERDUE' : 'RECEIVED');
    } else {
      // Tabs: Pending (0), Received (1)
      return index == 0 ? 'PENDING' : 'RECEIVED';
    }
  }

  void _onTabChanged() {
    if (_tabController?.indexIsChanging ?? false) {
      // Reset scroll position when tab changes (only if attached)
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      // Refresh pagination for the new tab
      final overdueCountAsync = ref.read(overdueReceivablesCountProvider);
      final hasOverdueTab = (overdueCountAsync.value ?? 0) > 0;
      final status =
          _getStatusForTabIndex(_tabController!.index, hasOverdueTab);
      ref.read(receivablesPaginatedProvider(status).notifier).refresh();
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom
      final overdueCountAsync = ref.read(overdueReceivablesCountProvider);
      final hasOverdueTab = (overdueCountAsync.value ?? 0) > 0;
      final status =
          _getStatusForTabIndex(_tabController?.index ?? 0, hasOverdueTab);
      ref.read(receivablesPaginatedProvider(status).notifier).loadMore();
    }
  }

  void _showFilterBottomSheet() {
    final overdueCountAsync = ref.read(overdueReceivablesCountProvider);
    final hasOverdueTab = (overdueCountAsync.value ?? 0) > 0;
    final status =
        _getStatusForTabIndex(_tabController?.index ?? 0, hasOverdueTab);
    final notifier = ref.read(receivablesPaginatedProvider(status).notifier);

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
          type: FilterType.receivables,
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
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isOverdue
                    ? Colors.red.withValues(alpha: 0.2)
                    : AppColors.receivableColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isOverdue ? Colors.red : AppColors.receivableColor,
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
    final pendingCountAsync = ref.watch(pendingReceivablesCountProvider);
    final overdueCountAsync = ref.watch(overdueReceivablesCountProvider);
    final pendingCount = pendingCountAsync.value ?? 0;
    final overdueCount = overdueCountAsync.value ?? 0;
    final hasOverdueTab = overdueCount > 0;
    final tabCount = hasOverdueTab ? 3 : 2;

    // Initialize or update TabController when tab count changes
    if (_previousOverdueCount != overdueCount) {
      _previousOverdueCount = overdueCount;
      _initializeTabController(tabCount);
    }

    if (_tabController == null) {
      _initializeTabController(tabCount);
      _previousOverdueCount = overdueCount;
    }

    final l10n = AppLocalizations.of(context)!;
    final currentTabIndex = _tabController?.index ?? 0;
    // Ensure index is within bounds for the current tabCount
    final safeTabIndex = currentTabIndex < tabCount ? currentTabIndex : 0;

    // Safety check for tab controller index mismatch
    if (_tabController != null && _tabController!.index >= tabCount) {
      _tabController!.index = 0;
    }

    final status = _getStatusForTabIndex(safeTabIndex, hasOverdueTab);

    // Use ref.read for the notifier to avoid rebuild loops, but watch the state
    // final paginatedState = ref.watch(receivablesPaginatedProvider(status)); // Removed to avoid duplicate watch
    final paginatedNotifier =
        ref.read(receivablesPaginatedProvider(status).notifier);

    final currentFilters = paginatedNotifier.currentFilters;
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
                      paginatedNotifier.updateSearchQuery(value);
                    },
                  )
                : Text(l10n.receivables),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    if (_isSearching) {
                      ref
                          .read(receivablesPaginatedProvider(status).notifier)
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
              // Debug button to generate dummy receivables (only in debug mode)
              if (kDebugMode)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.bug_report),
                  onSelected: (value) async {
                    if (value == 'generate_dummy') {
                      final repository =
                          ref.read(receivablesRepositoryProvider);
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

                          await repository.createReceivable(
                            ReceivablesCompanion(
                              contactUuid: Value(contactUuid),
                              amount: Value(amount),
                              description: Value('Dummy Receivable #${i + 1}'),
                              date: Value(date),
                              status:
                                  Value(i % 3 == 0 ? 'RECEIVED' : 'PENDING'),
                              createdAt: Value(DateTime.now()),
                              updatedAt: Value(DateTime.now()),
                            ),
                          );
                        }
                        if (context.mounted) {
                          ToastUtils.showSuccessToast(
                              context, ref, l10n.dummyGenerated(100));
                          // Refresh pagination
                          ref
                              .read(receivablesPaginatedProvider('PENDING')
                                  .notifier)
                              .refresh();
                          ref
                              .read(receivablesPaginatedProvider('RECEIVED')
                                  .notifier)
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
                          Text(l10n.dummyGenerated(100)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
            bottom: _tabController == null || _tabController!.length != tabCount
                ? null
                : TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.receivableColor,
                    labelColor: AppColors.receivableColor,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                    tabs: [
                      _buildTabWithCount(l10n.pending, pendingCount),
                      if (hasOverdueTab)
                        _buildTabWithCount(l10n.overdue, overdueCount,
                            isOverdue: true),
                      Tab(text: l10n.receivedLabel),
                    ],
                  ),
          ),
          body: _tabController == null ||
                  _tabController!.length != tabCount ||
                  _tabController!.index >= tabCount
              ? const AppLoadingIndicator(size: 60)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReceivablesList('PENDING'),
                    if (hasOverdueTab) _buildReceivablesList('OVERDUE'),
                    _buildReceivablesList('RECEIVED'),
                  ],
                ),
    );
  }

  Widget _buildReceivablesList(String status) {
    final l10n = AppLocalizations.of(context)!;
    // Use ref.watch for state to ensure rebuilds on data changes
    final paginatedState = ref.watch(receivablesPaginatedProvider(status));
    final theme = Theme.of(context);
    final currency = ref.watch(currentCurrencyProvider).value;

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
              l10n.errorLoadingReceivables,
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
                ref
                    .read(receivablesPaginatedProvider(status).notifier)
                    .refresh();
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
                  ? l10n.noPendingReceivables
                  : status == 'OVERDUE'
                      ? l10n.noOverdueReceivables
                      : l10n.noReceivedPayments,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              status == 'PENDING'
                  ? l10n.addReceivableSubtitle
                  : status == 'OVERDUE'
                      ? l10n.receivablesUpToDate
                      : l10n.markReceivedSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Group by Date
    final groupedReceivables = <String, List<dynamic>>{};
    final userProfile = ref.watch(userProfileProvider);
    final dateFormat = userProfile.dateFormat;
    for (final item in paginatedState.items) {
      // Safety check: ensure receivable and date are not null
      if (item == null ||
          item.receivable == null ||
          item.receivable.date == null) continue;

      try {
        final dateKey = AppDateFormatter.formatDate(item.receivable.date,
            pattern: dateFormat ?? 'MMM dd, yyyy');
        groupedReceivables.putIfAbsent(dateKey, () => []);
        groupedReceivables[dateKey]!.add(item);
      } catch (e) {
        const fallbackKey = 'Other';
        groupedReceivables.putIfAbsent(fallbackKey, () => []);
        groupedReceivables[fallbackKey]!.add(item);
      }
    }

    final keys = groupedReceivables.keys.toList();

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: CollapsibleListSummary(
              title: l10n.summary,
              child: _ReceivablesListSummaryContent(status: status),
            ),
          ),
        ),
        // Date sections with sticky headers
        for (final dateKey in keys)
          SliverStickyHeader(
            header: _buildReceivableDateSectionHeader(
              theme,
              dateKey,
              _monthFromReceivableGroup(groupedReceivables[dateKey]!),
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, itemIndex) {
                  final dateItems = groupedReceivables[dateKey]!;
                  if (itemIndex >= dateItems.length) return null;

                  final item = dateItems[itemIndex];
                  // Restrict editing/deleting for received or linked receivables
                  final canEdit = item.receivable.status == 'PENDING' &&
                      item.receivable.linkedExpenseUuid == null &&
                      item.receivable.linkedIncomeUuid == null;

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: SwipeableListItem(
                      enableEdit: false,
                      enableDelete: false,
                      borderRadius: 20,
                      confirmTitle: l10n.deleteReceivable,
                      confirmMessage: l10n.deleteReceivableConfirm,
                      deleteLabel: l10n.delete,
                      onEdit: null,
                      onDelete: null,
                      child: _ReceivableCard(item: item, currency: currency),
                    ),
                  );
                },
                childCount: groupedReceivables[dateKey]!.length,
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
                  l10n.noMoreItems,
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

  int? _monthFromReceivableGroup(List<dynamic> items) {
    if (items.isEmpty) return null;
    final first = items.first;
    if (first == null ||
        first.receivable == null ||
        first.receivable.date == null) {
      return null;
    }
    return first.receivable.date.month;
  }

  Widget _buildReceivableDateSectionHeader(
    ThemeData theme,
    String dateKey,
    int? month,
  ) {
    final chipBg = AppColors.transactionDateChipBackground(theme, month);
    final chipFg = AppColors.transactionDateChipForeground(theme, month);
    final chipShadow = AppColors.transactionDateChipShadow(theme, month);
    return Container(
      key: ValueKey('receivable-date-header-$dateKey'),
      height: 50,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Container(
        key: ValueKey('receivable-date-header-inner-$dateKey'),
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
          key: ValueKey('receivable-date-header-text-$dateKey'),
          dateKey,
          style: theme.textTheme.titleSmall?.copyWith(
            color: chipFg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ReceivableCard extends ConsumerStatefulWidget {
  final dynamic item;
  final AppCurrency currency;

  const _ReceivableCard({
    required this.item,
    required this.currency,
  });

  @override
  ConsumerState<_ReceivableCard> createState() => _ReceivableCardState();
}

class _ReceivableCardState extends ConsumerState<_ReceivableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final currency = widget.currency;
    if (item == null || item.receivable == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final userProfile = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final receivable = item.receivable;
    final contact = item.contact;
    final linkedCategory = item.linkedCategory;
    final linkedTransaction = item.linkedTransaction;
    final isPending = receivable.status == 'PENDING';

    // Dynamic font size based on amount
    final amountFontSize = AmountFormatter.getFontSize(receivable.amount);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isHovered
              ? AppColors.receivableColor
              : AppColors.receivableColor.withValues(alpha: isDark ? 0.2 : 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.receivableColor
                .withValues(alpha: isDark ? 0.05 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onHover: (hovering) {
              setState(() {
                _isHovered = hovering;
              });
            },
            hoverColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ReceivableDetailsDialog(receivableUuid: receivable.uuid),
                ),
              );
            },
            borderRadius: BorderRadius.circular(19),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Contact Avatar
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
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
                      if (receivable.isNotSynced == true)
                        Positioned(
                          right: -3,
                          bottom: -3,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.cloud_upload_outlined,
                              size: 12,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),

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
                                  : AppColors.incomeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: linkedCategory.color != null
                                    ? Color(int.parse(linkedCategory.color!
                                            .replaceAll('#', '0xFF')))
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
                                  linkedCategory.icon != null
                                      ? IconHelper.getIconData(
                                          linkedCategory.icon)
                                      : Symbols.category,
                                  color: linkedCategory.color != null
                                      ? Color(int.parse(linkedCategory.color!
                                          .replaceAll('#', '0xFF')))
                                      : AppColors.incomeColor,
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
                                          : AppColors.incomeColor,
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
                        if (receivable.description != null &&
                            receivable.description!.isNotEmpty)
                          Text(
                            receivable.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (receivable.dueDate != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.event,
                                size: 12,
                                color: isPending
                                    ? (receivable.dueDate!
                                            .isBefore(DateTime.now())
                                        ? Colors.red
                                        : Colors.orange)
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  l10n.dueAt(AppDateFormatter.formatDate(
                                      receivable.dueDate!,
                                      pattern: userProfile.dateFormat ??
                                          'MMM dd, yyyy')),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isPending
                                        ? (receivable.dueDate!
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

                  // Amount and Tags
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\u200E${AmountFormatter.formatWithCurrency(receivable.amount, currency)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.receivableColor,
                          fontWeight: FontWeight.bold,
                          fontSize: amountFontSize,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Status badge (Receivable or Received)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.receivableColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color:
                                AppColors.receivableColor.withValues(alpha: 0.3),
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
                                color: AppColors.receivableColor,
                              ),
                              const SizedBox(width: 3),
                            ],
                            Text(
                              isPending ? l10n.receivableTag : l10n.receivedTag,
                              style: TextStyle(
                                color: AppColors.receivableColor,
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
      ),
    );
  }
}

class _ReceivablesListSummaryContent extends ConsumerWidget {
  final String status;

  const _ReceivablesListSummaryContent({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAsync = ref.watch(receivablesListTotalProvider(status));
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const SizedBox.shrink();
    }

    return totalAsync.when(
      data: (total) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.receivableColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppColors.receivableColor.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              status == 'RECEIVED'
                  ? l10n.receivedLabel
                  : status == 'OVERDUE'
                      ? l10n.overdue
                      : l10n.receivableTag,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              AmountFormatter.formatWithCurrency(
                  total, currency),
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.receivableColor,
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
