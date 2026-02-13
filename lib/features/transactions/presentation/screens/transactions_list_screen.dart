import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/edit_transaction_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_details_dialog.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/swipeable_list_item.dart';
import 'package:flowpaisa/shared/models/paginated_state.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/schedule_icon_badge.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/split_icon_badge.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/schedule_list_item.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/schedule_service_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/bulk_import_screen.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/edit_schedule_screen.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/shared/widgets/filter_bottom_sheet.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';

import 'package:flowpaisa/features/tour/domain/tour_service.dart';
import 'package:flowpaisa/features/tour/presentation/providers/tour_provider.dart';
import 'package:showcaseview/showcaseview.dart';

class TransactionsListScreen extends ConsumerStatefulWidget {
  final bool startTour;
  const TransactionsListScreen({super.key, this.startTour = false});

  @override
  ConsumerState<TransactionsListScreen> createState() =>
      _TransactionsListScreenState();
}

class _TransactionsListScreenState extends ConsumerState<TransactionsListScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  late TextEditingController _searchController;
  bool _isSearching = false;
  bool _tourStarted = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();

    // Auto-start tour on first visit to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartTour();
    });
  }

  Future<void> _checkAndStartTour() async {
    // We can add a delay to ensure the screen is fully rendered
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      // For now, we'll just provide a way to start it manually or auto-start once
      // In a real app, you might want to track if THIS specific tour was shown
      // TourService.startTransactionsTour(context);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom
      ref.read(transactionsPaginatedProvider.notifier).loadMore();
    }
  }

  void _showFilterBottomSheet() {
    final notifier = ref.read(transactionsPaginatedProvider.notifier);
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
          type: FilterType.transactions,
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

  void _showImportOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = ref.read(premiumProvider).isPremium;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    l10n.bulkImport,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  if (!isPremium)
                    const Icon(Icons.lock, color: Colors.orange, size: 20),
                  if (isPremium)
                    const Icon(Icons.verified, color: Colors.blue, size: 20),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.content_paste),
              title: Text(l10n.pasteFromClipboard),
              onTap: () async {
                Navigator.pop(context);
                if (!isPremium) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PremiumScreen()));
                  return;
                }
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data?.text != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BulkImportScreen(initialContent: data!.text),
                    ),
                  );
                } else {
                  ToastUtils.showInfoToast(context, ref, 'Clipboard is empty');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_open),
              title: Text(l10n.pickCsvFile),
              onTap: () async {
                Navigator.pop(context);
                if (!isPremium) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PremiumScreen()));
                  return;
                }
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['csv', 'txt'],
                );

                if (result != null && result.files.single.path != null) {
                  final file = File(result.files.single.path!);
                  final content = await file.readAsString();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BulkImportScreen(initialContent: content),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Use the paginated provider
    final paginatedState = ref.watch(transactionsPaginatedProvider);
    final theme = Theme.of(context);
    final schedulesAsync = ref.watch(allSchedulesProvider);
    final hasSchedules = schedulesAsync.value?.isNotEmpty ?? false;
    final currentFilters =
        ref.watch(transactionsPaginatedProvider.notifier).currentFilters;
    final hasActiveFilters = !currentFilters.isEmpty;

    return ShowCaseWidget(
      onFinish: () {
        final tourNotifier = ref.read(tourNotifierProvider);
        tourNotifier.markTourCompleted(tourNotifier.transactionsKey);
      },
      builder: (context) {
        // Start tour if requested and we haven't started it yet
        if (widget.startTour && !_tourStarted) {
          _tourStarted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              try {
                final showcaseState = ShowCaseWidget.of(context);
                showcaseState.startShowCase(TourService.transactionsTourKeys);
              } catch (e) {
                debugPrint('Error starting transactions tour: $e');
              }
            }
          });
        }
        return Scaffold(
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l10n.searchTransactions,
                      border: InputBorder.none,
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    style: theme.textTheme.bodyLarge,
                    onChanged: (value) {
                      ref
                          .read(transactionsPaginatedProvider.notifier)
                          .search(value);
                    },
                  )
                : Text(l10n.transactions),
            bottom: hasSchedules && !_isSearching
                ? TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: l10n.transactions),
                      Tab(text: l10n.schedules),
                    ],
                  )
                : null,
            actions: [
              Showcase(
                key: TourService.transactionsFilterKey,
                title: l10n.tourTransactionsFilterTitle,
                description: l10n.tourTransactionsFilterDesc,
                targetShapeBorder: const CircleBorder(),
                tooltipBackgroundColor: AppColors.transactionsSectionColor,
                textColor: Colors.white,
                tooltipPosition: TooltipPosition.bottom,
                child: IconButton(
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
              ),
              Showcase(
                key: TourService.transactionsSearchKey,
                title: l10n.tourTransactionsSearchTitle,
                description: l10n.tourTransactionsSearchDesc,
                targetShapeBorder: const CircleBorder(),
                tooltipBackgroundColor: AppColors.transactionsSectionColor,
                textColor: Colors.white,
                tooltipPosition: TooltipPosition.bottom,
                child: IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      if (_isSearching) {
                        _isSearching = false;
                        _searchController.clear();
                        ref
                            .read(transactionsPaginatedProvider.notifier)
                            .search('');
                      } else {
                        _isSearching = true;
                      }
                    });
                  },
                ),
              ),
              if (!_isSearching)
                IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: () => _showImportOptions(context),
                ),
              if (!_isSearching)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'generate_dummy') {
                      final service = ref.read(transactionServiceProvider);
                      try {
                        await service.generateDummyTransactions(count: 100);
                        if (context.mounted) {
                          ToastUtils.showSuccessToast(
                              context, ref, l10n.generated100DummyTransactions);
                          // Refresh the paginated list
                          ref
                              .read(transactionsPaginatedProvider.notifier)
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
                    if (kDebugMode)
                      PopupMenuItem(
                        value: 'generate_dummy',
                        child: Row(
                          children: [
                            const Icon(Icons.add_circle_outline),
                            const SizedBox(width: 8),
                            Text(l10n.generate100DummyTransactions),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
          body: hasSchedules
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBody(paginatedState, theme),
                    _buildSchedulesTab(schedulesAsync.value ?? []),
                  ],
                )
              : _buildBody(paginatedState, theme),
          floatingActionButton: Showcase(
            key: TourService.transactionsFabKey,
            title: l10n.tourTransactionsFabTitle,
            description: l10n.tourTransactionsFabDesc,
            targetShapeBorder: const CircleBorder(),
            tooltipBackgroundColor: AppColors.transactionsSectionColor,
            textColor: Colors.white,
            tooltipPosition: TooltipPosition.top,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.transactionsSectionColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
      PaginatedState<TransactionWithDetails> paginatedState, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
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
              l10n.errorLoadingTransactions,
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
                ref.read(transactionsPaginatedProvider.notifier).refresh();
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
              _isSearching ? Icons.search_off : Icons.receipt_long_outlined,
              size: 120,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              _isSearching ? l10n.noTransactions : l10n.noTransactionsYet,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isSearching
                  ? l10n.trySearchingDifferentName
                  : l10n.tapToAddFirst,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Group transactions by date
    final groupedTransactions = <String, List>{};
    final userProfile = ref.watch(userProfileProvider);
    for (final item in paginatedState.items) {
      if (item == null ||
          item.transaction == null ||
          item.transaction.date == null) continue;

      try {
        final dateKey = AppDateFormatter.formatDate(item.transaction.date,
            pattern: userProfile.dateFormat ?? 'MMM dd, yyyy');
        groupedTransactions.putIfAbsent(dateKey, () => []);
        groupedTransactions[dateKey]!.add(item);
      } catch (e) {
        const fallbackKey = 'Other';
        groupedTransactions.putIfAbsent(fallbackKey, () => []);
        groupedTransactions[fallbackKey]!.add(item);
      }
    }

    final service = ref.read(transactionServiceProvider);
    final keys = groupedTransactions.keys.toList();

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Date sections with sticky headers
        for (int i = 0; i < keys.length; i++)
          SliverStickyHeader(
            header: i == 0
                ? Showcase(
                    key: TourService.transactionsListKey,
                    title: l10n.tourTransactionsListTitle,
                    description: l10n.tourTransactionsListDesc,
                    targetShapeBorder: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    tooltipBackgroundColor: AppColors.transactionsSectionColor,
                    textColor: Colors.white,
                    tooltipPosition: TooltipPosition.bottom,
                    child: _buildDateHeader(theme, keys[i]),
                  )
                : _buildDateHeader(theme, keys[i]),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, itemIndex) {
                  final dateKey = keys[i];
                  final dateTransactions = groupedTransactions[dateKey]!;
                  if (itemIndex >= dateTransactions.length) return null;

                  final item = dateTransactions[itemIndex];
                  final isExpense = item.transaction.type == 'EXPENSE';

                  // Determine if transaction is restricted from editing/deleting
                  final isRestricted =
                      item.transaction.isAutoGenerated == true ||
                          item.isLinkedEntryMarked;

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: SwipeableListItem(
                      enableEdit: !isRestricted,
                      enableDelete: !isRestricted,
                      borderRadius: 20,
                      onEdit: isRestricted
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTransactionScreen(
                                    transaction: item.transaction,
                                    category: item.category,
                                    contact: item.contact,
                                  ),
                                ),
                              );
                            },
                      onDelete: isRestricted
                          ? null
                          : () async {
                              final l10n = AppLocalizations.of(context)!;
                              try {
                                await service
                                    .deleteTransaction(item.transaction.uuid);
                                if (context.mounted) {
                                  ToastUtils.showSuccessToast(
                                      context, ref, l10n.transactionDeleted);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ToastUtils.showErrorToast(
                                      context,
                                      ref,
                                      l10n.errorDeletingTransaction(
                                          e.toString()));
                                }
                              }
                            },
                      child: _buildTransactionCard(
                        context,
                        ref: ref,
                        item: item,
                        isExpense: isExpense,
                      ),
                    ),
                  );
                },
                childCount: groupedTransactions[keys[i]]!.length,
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
                  l10n.noMoreTransactions,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildDateHeader(ThemeData theme, String dateKey) {
    return Container(
      height: 50,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.transactionsSectionColor.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.transactionsSectionColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          dateKey,
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context, {
    required WidgetRef ref,
    required dynamic item, // TransactionWithDetails
    required bool isExpense,
  }) {
    if (item == null || item.transaction == null)
      return const SizedBox.shrink();
    final theme = Theme.of(context);
    final currency = ref.watch(currentCurrencyProvider).value;
    final isDark = theme.brightness == Brightness.dark;

    if (currency == null) {
      return const SizedBox.shrink();
    }
    final transaction = item.transaction;
    final category = item.category;
    final contact = item.contact;
    final l10n = AppLocalizations.of(context)!;

    // Check if it's an "inactive" transaction (Paid BY or Will Receive that hasn't been marked yet)
    final isInactive = (transaction.paidRelationship == 'PAID_BY' ||
            transaction.paidRelationship == 'WILL_RECEIVE') &&
        !item.isLinkedEntryMarked;

    // Resolve category color and icon
    Color categoryColor;
    if (category?.color != null) {
      try {
        categoryColor =
            Color(int.parse(category!.color!.replaceAll('#', '0xFF')));
      } catch (_) {
        categoryColor =
            isExpense ? AppColors.expenseColor : AppColors.incomeColor;
      }
    } else {
      categoryColor =
          isExpense ? AppColors.expenseColor : AppColors.incomeColor;
    }

    // Apply dull effect if inactive
    final displayColor =
        isInactive ? categoryColor.withValues(alpha: 0.5) : categoryColor;
    final textColor = isInactive
        ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
        : theme.colorScheme.onSurface;

    // Dynamic font size based on amount
    final amountFontSize = AmountFormatter.getFontSize(transaction.amount);

    final linkedGroupId = transaction.linkedGroupId;
    final showSplitBadge = linkedGroupId != null && linkedGroupId.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: isInactive ? 0.6 : 1.0),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: displayColor.withValues(alpha: isDark ? 0.2 : 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: displayColor.withValues(alpha: isDark ? 0.05 : 0.08),
                blurRadius: isInactive ? 4 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: displayColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: displayColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: CategoryHelper.buildCategoryIcon(
                  category?.icon, displayColor, isExpense),
            ),
            title: Text(
              category != null
                  ? LocalizationHelper.getLocalizedCategoryName(
                      context, category.name)
                  : l10n.uncategorized,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ??
                      (isExpense ? l10n.expense : l10n.income),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: isInactive ? 0.5 : 1.0),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                // Contact tag - styled like payable/receivable tags
                if (contact != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.getContactColor(contact.name)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.getContactColor(contact.name)
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            gradient:
                                AppColors.getContactGradient(contact.name),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            contact.name.isNotEmpty
                                ? contact.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            contact.name,
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? '\u200E-' : '\u200E+'} ${AmountFormatter.formatWithCurrency(transaction.amount, currency.symbol, currency.decimalPlaces)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: isExpense
                        ? (isInactive
                            ? AppColors.expenseColor.withValues(alpha: 0.5)
                            : AppColors.expenseColor)
                        : (isInactive
                            ? AppColors.incomeColor.withValues(alpha: 0.5)
                            : AppColors.incomeColor),
                    fontWeight: FontWeight.bold,
                    fontSize: amountFontSize,
                  ),
                ),
                // Show status badge below amount for linked transactions
                if (transaction.paidRelationship != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(transaction.paidRelationship!)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getStatusColor(transaction.paidRelationship!)
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.isLinkedEntryMarked) ...[
                          Icon(
                            Icons.check_circle,
                            size: 10,
                            color:
                                _getStatusColor(transaction.paidRelationship!),
                          ),
                          const SizedBox(width: 3),
                        ],
                        Text(
                          _getStatusLabel(l10n, transaction.paidRelationship!,
                              item.isLinkedEntryMarked),
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                _getStatusColor(transaction.paidRelationship!),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Show "Auto" badge for auto-generated transactions
                if (transaction.isAutoGenerated == true) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 10,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            l10n.autoBadge,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionDetailsDialog(
                      transactionUuid: transaction.uuid),
                ),
              );
            },
          ),
        ),
        // Schedule icon badge (top-right corner)
        if (transaction.isScheduled == true) const ScheduleIconBadge(),
        // Split icon badge (top-right corner); same transaction has linkedGroupId from DB
        if (showSplitBadge) SplitIconBadge(groupId: linkedGroupId!),
      ],
    );
  }

  Widget _buildSchedulesTab(List<TransactionSchedule> schedules) {
    final l10n = AppLocalizations.of(context)!;
    if (schedules.isEmpty) {
      return Center(
        child: Text(l10n.noSchedulesFound),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
          child: SwipeableListItem(
            enableEdit: true,
            enableDelete: true,
            borderRadius: 20,
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditScheduleScreen(
                    schedule: schedule,
                  ),
                ),
              ).then((updated) {
                if (updated == true) {
                  ref.invalidate(allSchedulesProvider);
                }
              });
            },
            onDelete: () async {
              final service = ref.read(scheduleServiceProvider);
              await service.deleteSchedule(schedule.uuid);
              if (context.mounted) {
                ToastUtils.showSuccessToast(context, ref, l10n.scheduleDeleted);
              }
              ref.invalidate(allSchedulesProvider);
            },
            child: ScheduleListItem(
              schedule: schedule,
              onToggle: () async {
                final service = ref.read(scheduleServiceProvider);
                if (schedule.isPaused) {
                  await service.resumeSchedule(schedule.uuid, DateTime.now());
                } else {
                  await service.pauseSchedule(schedule.uuid);
                }
                ref.invalidate(allSchedulesProvider);
              },
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String relationship) {
    switch (relationship) {
      case 'PAID_FOR':
        return AppColors.receivableColor;
      case 'PAID_BY':
        return AppColors.payableColor;
      case 'RECEIVED_FROM':
        return AppColors.payableColor;
      case 'WILL_RECEIVE':
        return AppColors.receivableColor;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(
      AppLocalizations l10n, String relationship, bool isMarked) {
    switch (relationship) {
      case 'PAID_FOR':
        return isMarked ? l10n.receivedTag : l10n.receivableTag;
      case 'PAID_BY':
        return isMarked ? l10n.paidTag : l10n.payableTag;
      case 'RECEIVED_FROM':
        return isMarked ? l10n.paidTag : l10n.payableTag;
      case 'WILL_RECEIVE':
        return isMarked ? l10n.receivedTag : l10n.receivableTag;
      default:
        return '';
    }
  }
}
