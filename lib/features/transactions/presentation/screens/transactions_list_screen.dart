import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_undraw/flutter_undraw.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/schedule_list_item.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/schedule_service_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/bulk_import_screen.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/edit_schedule_screen.dart';
import 'package:flowpaisa/shared/widgets/filter_bottom_sheet.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:flowpaisa/shared/widgets/collapsible_list_summary.dart';
import 'package:flowpaisa/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:flowpaisa/shared/widgets/app_floating_action_button.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_speed_dial.dart';
import 'package:flowpaisa/shared/widgets/faded_bottom_logo.dart';
import 'package:flowpaisa/features/receipt_scan/presentation/screens/scan_receipt_screen.dart';
import 'package:flowpaisa/features/voice_command/presentation/screens/voice_add_screen.dart';

import 'package:flowpaisa/features/transactions/presentation/widgets/schedule_details_dialog.dart';

import 'package:flowpaisa/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flowpaisa/shared/widgets/contextual_guide.dart';
import 'package:material_symbols_icons/symbols.dart';

class TransactionsListScreen extends ConsumerStatefulWidget {
  final bool startTour;
  final DateTime? initialDate;
  const TransactionsListScreen(
      {super.key, this.startTour = false, this.initialDate});

  @override
  ConsumerState<TransactionsListScreen> createState() =>
      _TransactionsListScreenState();
}

class _TransactionsListScreenState extends ConsumerState<TransactionsListScreen>
    with SingleTickerProviderStateMixin {
  /// Lets the bottom sheet (and loading dialog) finish closing before the next step.
  static const Duration _bulkImportSheetCloseDelay =
      Duration(milliseconds: 320);

  late ScrollController _scrollController;
  late TabController _tabController;
  late TextEditingController _searchController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowGuide();
      if (widget.initialDate != null) {
        final startOfDay = DateTime(
          widget.initialDate!.year,
          widget.initialDate!.month,
          widget.initialDate!.day,
          0,
          0,
          0,
        );
        final endOfDay = DateTime(
          widget.initialDate!.year,
          widget.initialDate!.month,
          widget.initialDate!.day,
          23,
          59,
          59,
        );
        ref.read(transactionsPaginatedProvider.notifier).applyFilters(
              ref
                  .read(transactionsPaginatedProvider.notifier)
                  .currentFilters
                  .copyWith(
                    startDate: startOfDay,
                    endDate: endOfDay,
                  ),
            );
      }
    });
  }

  void _checkAndShowGuide() {
    final hasSeen = ref.read(transactionsGuideSeenProvider);
    if (!hasSeen) {
      final l10n = AppLocalizations.of(context)!;
      ContextualGuide.show(
        context,
        title: l10n.transactions,
        items: [
          GuideItem(
            illustration: UndrawIllustration.fileBundle,
            title: l10n.guideBulkImportTitle,
            description: l10n.guideBulkImportBody,
          ),
          GuideItem(
            illustration: UndrawIllustration.cloudSync,
            title: l10n.guideAutoSettleTitle,
            description: l10n.guideAutoSettleBody,
          ),
          GuideItem(
            illustration: UndrawIllustration.teamCollaboration,
            title: l10n.guideSplitSettleTitle,
            description: l10n.guideSplitSettleBody,
          ),
          GuideItem(
            illustration: UndrawIllustration.activeOptions,
            title: l10n.guideBudgetsTitle,
            description: l10n.guideBudgetsBody,
          ),
        ],
        onDismiss: () {
          ref.read(transactionsGuideSeenProvider.notifier).setSeen();
        },
      );
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

  void _showImportOptions(BuildContext parentContext) {
    final l10n = AppLocalizations.of(parentContext)!;
    final isPremium = ref.read(premiumProvider).isPremium;
    final theme = Theme.of(parentContext);
    final loadingBarrierColor = theme.brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.26)
        : Colors.black.withValues(alpha: 0.06);

    showModalBottomSheet(
      context: parentContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    l10n.bulkImport,
                    style: Theme.of(sheetContext)
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
                Navigator.pop(sheetContext);
                await Future<void>.delayed(_bulkImportSheetCloseDelay);
                if (!parentContext.mounted) {
                  return;
                }
                if (!isPremium) {
                  Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                          builder: (context) => const PremiumScreen()));
                  return;
                }
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data?.text != null) {
                  final text = data!.text!;
                  if (text.length > 4000 && parentContext.mounted) {
                    showDialog<void>(
                      context: parentContext,
                      barrierDismissible: false,
                      barrierColor: loadingBarrierColor,
                      builder: (dialogContext) =>
                          const _BulkImportLoadingDialog(),
                    );
                    await Future<void>.delayed(Duration.zero);
                    if (!parentContext.mounted) {
                      return;
                    }
                    Navigator.of(parentContext).pop();
                    await Future<void>.delayed(_bulkImportSheetCloseDelay);
                    if (!parentContext.mounted) {
                      return;
                    }
                  }
                  if (!parentContext.mounted) {
                    return;
                  }
                  Navigator.push(
                    parentContext,
                    MaterialPageRoute(
                      builder: (context) =>
                          BulkImportScreen(initialContent: text),
                    ),
                  );
                } else {
                  ToastUtils.showInfoToast(
                      parentContext, ref, 'Clipboard is empty');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_open),
              title: Text(l10n.pickCsvFile),
              onTap: () async {
                Navigator.pop(sheetContext);
                await Future<void>.delayed(_bulkImportSheetCloseDelay);
                if (!parentContext.mounted) {
                  return;
                }
                if (!isPremium) {
                  Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                          builder: (context) => const PremiumScreen()));
                  return;
                }
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['csv', 'txt'],
                );

                if (result != null && result.files.single.path != null) {
                  if (!parentContext.mounted) {
                    return;
                  }
                  showDialog<void>(
                    context: parentContext,
                    barrierDismissible: false,
                    barrierColor: loadingBarrierColor,
                    builder: (dialogContext) =>
                        const _BulkImportLoadingDialog(),
                  );
                  try {
                    final file = File(result.files.single.path!);
                    final content = await file.readAsString();
                    if (!parentContext.mounted) {
                      return;
                    }
                    Navigator.of(parentContext).pop();
                    await Future<void>.delayed(_bulkImportSheetCloseDelay);
                    if (!parentContext.mounted) {
                      return;
                    }
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (context) =>
                            BulkImportScreen(initialContent: content),
                      ),
                    );
                  } catch (e) {
                    if (parentContext.mounted) {
                      Navigator.of(parentContext).pop();
                      ToastUtils.showErrorToast(
                          parentContext, ref, e.toString());
                    }
                  }
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
    final ref = this.ref;
    final l10n = AppLocalizations.of(context)!;
    // Use the paginated provider
    final paginatedState = ref.watch(transactionsPaginatedProvider);
    final theme = Theme.of(context);
    final schedulesAsync = ref.watch(allSchedulesWithDetailsProvider);
    final hasSchedules = schedulesAsync.value?.isNotEmpty ?? false;
    final currentFilters =
        ref.watch(transactionsPaginatedProvider.notifier).currentFilters;
    final hasActiveFilters = !currentFilters.isEmpty;

    return Scaffold(
      key: const ValueKey('transactions-list-scaffold'),
      appBar: AppBar(
            key: const ValueKey('transactions-list-appbar'),
            title: _isSearching
                ? TextField(
                    key: const ValueKey('tx-search-field'),
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
                : Text(key: const ValueKey('tx-title'), l10n.transactions),
            bottom: hasSchedules && !_isSearching
                ? TabBar(
                    key: const ValueKey('tx-tab-bar'),
                    controller: _tabController,
                    tabs: [
                      Tab(key: const ValueKey('tx-tab-tx'), text: l10n.transactions),
                      Tab(key: const ValueKey('tx-tab-sched'), text: l10n.schedules),
                    ],
                  )
                : null,
            actions: [
              IconButton(
                key: const ValueKey('tx-filter-btn'),
                icon: Stack(
                  children: [
                    const Icon(Icons.filter_list),
                    if (hasActiveFilters)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          key: const ValueKey('tx-filter-badge'),
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
              IconButton(
                key: const ValueKey('tx-search-btn'),
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
              if (!_isSearching && kDebugMode)
                PopupMenuButton<String>(
                  key: const ValueKey('tx-more-btn'),
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
          body: Stack(
            key: const ValueKey('tx-body-stack'),
            children: [
              hasSchedules
                  ? TabBarView(
                      key: const ValueKey('tx-tab-view'),
                      controller: _tabController,
                      children: [
                        _buildBody(paginatedState, theme),
                        _buildSchedulesTab(schedulesAsync.value ?? []),
                      ],
                    )
                  : _buildBody(paginatedState, theme),
              Positioned.fill(
                child: TransactionSpeedDial(
                  key: const ValueKey('tx-speed-dial'),
                  activeColor: AppColors.transactionsSectionColor,
                  onAddTransaction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTransactionScreen(),
                      ),
                    );
                  },
                  onVoiceAdd: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VoiceAddScreen(),
                      ),
                    );
                  },
                  onScanReceipt: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScanReceiptScreen(),
                      ),
                    );
                  },
                  onBulkImport: () => _showImportOptions(context),
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildBody(
      PaginatedState<TransactionWithDetails> paginatedState, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    if (paginatedState.isLoading && paginatedState.items.isEmpty) {
      return const AppLoadingIndicator(key: ValueKey('tx-loading-indicator'), size: 60);
    }

    if (paginatedState.error != null && paginatedState.items.isEmpty) {
      return Center(
        key: const ValueKey('tx-error-view'),
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
        key: const ValueKey('tx-empty-view'),
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

    // Group transactions by date and calculate daily stats
    final groupedTransactions = <String, List<TransactionWithDetails>>{};
    final dailyStats = <String, ({int count, double netAmount})>{};
    final userProfile = ref.watch(userProfileProvider);

    for (final item in paginatedState.items) {
      if (item == null ||
          item.transaction == null ||
          item.transaction.date == null) continue;

      try {
        final dateKey = AppDateFormatter.formatDate(item.transaction.date,
            pattern: userProfile.dateFormat ?? 'MMM dd, yyyy');

        // Grouping
        groupedTransactions.putIfAbsent(dateKey, () => []);
        groupedTransactions[dateKey]!.add(item);

        // Stats calculation
        final current = dailyStats[dateKey] ?? (count: 0, netAmount: 0.0);
        final isExpense = item.transaction.type == 'EXPENSE';
        dailyStats[dateKey] = (
          count: current.count + 1,
          netAmount: current.netAmount +
              (isExpense ? -item.transaction.amount : item.transaction.amount),
        );
      } catch (e) {
        const fallbackKey = 'Other';
        groupedTransactions.putIfAbsent(fallbackKey, () => []);
        groupedTransactions[fallbackKey]!.add(item);

        final current = dailyStats[fallbackKey] ?? (count: 0, netAmount: 0.0);
        final isExpense = item.transaction.type == 'EXPENSE';
        dailyStats[fallbackKey] = (
          count: current.count + 1,
          netAmount: current.netAmount +
              (isExpense ? -item.transaction.amount : item.transaction.amount),
        );
      }
    }

    final service = ref.read(transactionServiceProvider);
    final keys = groupedTransactions.keys.toList();

    return CustomScrollView(
      key: const ValueKey('tx-list-scrollview'),
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          key: const ValueKey('tx-list-summary-adapter'),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: CollapsibleListSummary(
              key: const ValueKey('tx-list-summary-collapsible'),
              title: l10n.financialSummary,
              child: _TransactionListSummaryContent(
                  key: const ValueKey('tx-list-summary-content-inner')),
            ),
          ),
        ),
        // Date sections with sticky headers
        for (int i = 0; i < keys.length; i++)
          SliverStickyHeader(
            key: ValueKey('tx-sticky-header-${keys[i]}'),
            header: _buildDateHeader(
              theme,
              keys[i],
              _monthForDateGroup(groupedTransactions[keys[i]]!),
              count: dailyStats[keys[i]]?.count ?? 0,
              netAmount: dailyStats[keys[i]]?.netAmount ?? 0.0,
              isConfirmed: i < keys.length - 1 || !paginatedState.hasMore,
            ),
            sliver: SliverList(
              key: ValueKey('tx-sliver-list-${keys[i]}'),
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
                    key: ValueKey('tx-row-${item.transaction.uuid}'),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: SwipeableListItem(
                      key: ValueKey('tx-swipe-${item.transaction.uuid}'),
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
                                    account: item.account,
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
                        ref,
                        item,
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
          SliverToBoxAdapter(
            key: const ValueKey('tx-loading-more-adapter'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SizedBox(
                height: 3,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          )
        else if (!paginatedState.hasMore && paginatedState.items.isNotEmpty)
          SliverToBoxAdapter(
            key: const ValueKey('tx-no-more-adapter'),
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
        SliverToBoxAdapter(
          key: const ValueKey('tx-bottom-logo-adapter'),
          child: FadedBottomLogo(
            key: const ValueKey('tx-bottom-logo'),
            bottomPadding: 100 + MediaQuery.of(context).padding.bottom,
          ),
        ),
      ],
    );
  }

  /// Calendar month for the group (from first row) to tint the date chip.
  int? _monthForDateGroup(List<dynamic> items) {
    if (items.isEmpty) return null;
    final tx = items.first.transaction;
    if (tx == null || tx.date == null) return null;
    return tx.date.month;
  }

  Widget _buildDateHeader(
    ThemeData theme,
    String dateKey,
    int? month, {
    required int count,
    required double netAmount,
    required bool isConfirmed,
  }) {
    final chipBg = AppColors.transactionDateChipBackground(theme, month);
    final chipFg = AppColors.transactionDateChipForeground(theme, month);
    final chipShadow = AppColors.transactionDateChipShadow(theme, month);
    final currency = ref.watch(currentCurrencyProvider).value;

    return Container(
      key: ValueKey('tx-date-header-$dateKey'),
      height: 50,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Container(
        key: ValueKey('tx-date-header-inner-$dateKey'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              key: ValueKey('tx-date-header-text-$dateKey'),
              dateKey,
              style: theme.textTheme.titleSmall?.copyWith(
                color: chipFg,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 12,
                color: chipFg.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 8),
              Opacity(
                opacity: isConfirmed ? 1.0 : 0.6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AmountFormatter.formatWithCurrency(
                        netAmount,
                        currency!,
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: netAmount >= 0
                            ? AppColors.incomeColor
                            : AppColors.expenseColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '|',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: chipFg.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$count',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: chipFg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
      BuildContext context, WidgetRef ref, TransactionWithDetails item) {
    return TransactionListItem(item: item);
  }

  Widget _buildSchedulesTab(List<ScheduleWithDetails> schedules) {
    final l10n = AppLocalizations.of(context)!;
    if (schedules.isEmpty) {
      return Center(
        key: const ValueKey('tx-schedules-empty'),
        child: Text(l10n.noSchedulesFound),
      );
    }

    return ListView.builder(
      key: const ValueKey('tx-schedules-list'),
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: schedules.length + 1,
      itemBuilder: (context, index) {
        if (index == schedules.length) {
          return const FadedBottomLogo(key: ValueKey('tx-schedules-bottom-logo'), bottomPadding: 40);
        }
        final item = schedules[index];
        final schedule = item.schedule;
        final isPremium = ref.watch(premiumProvider).isPremium;
        final isLocked = !isPremium &&
            (schedule.addSeq ?? 0) > PremiumGate.scheduleTotalLimit;

        return Padding(
          key: ValueKey('tx-schedule-row-${schedule.uuid}'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: SwipeableListItem(
            key: ValueKey('tx-schedule-swipe-${schedule.uuid}'),
            enableEdit: !isLocked,
            enableDelete: !isLocked,
            borderRadius: 20,
            onEdit: isLocked
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditScheduleScreen(
                          schedule: schedule,
                        ),
                      ),
                    );
                  },
            onDelete: isLocked
                ? null
                : () async {
                    final service = ref.read(scheduleServiceProvider);
                    await service.deleteSchedule(schedule.uuid);
                    if (context.mounted) {
                      ToastUtils.showSuccessToast(
                          context, ref, l10n.scheduleDeleted);
                    }
                  },
            child: Stack(
              key: ValueKey('tx-schedule-stack-${schedule.uuid}'),
              children: [
                Opacity(
                  key: ValueKey('tx-schedule-opacity-${schedule.uuid}'),
                  opacity: isLocked ? 0.5 : 1.0,
                  child: ScheduleListItem(
                    key: ValueKey('tx-schedule-item-${schedule.uuid}'),
                    item: item,
                  ),
                ),
                if (isLocked)
                  Positioned(
                    key: ValueKey('tx-schedule-lock-pos-${schedule.uuid}'),
                    top: 12,
                    right: 12,
                    child: Container(
                      key: ValueKey('tx-schedule-lock-container-${schedule.uuid}'),
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        key: ValueKey('tx-schedule-lock-icon'),
                        Icons.lock,
                        size: 16,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TransactionListSummaryContent extends ConsumerWidget {
  const _TransactionListSummaryContent({super.key});

  static Widget _buildBalanceRow({
    Key? key,
    required ThemeData theme,
    required AppCurrency currency,
    required bool isReceivableHigher,
    required double amount,
    required String labelWhenHigher,
    required String labelWhenLower,
    required LinearGradient gradientWhenHigher,
    required LinearGradient gradientWhenLower,
  }) {
    final isHigher = isReceivableHigher;
    final label = isHigher ? labelWhenHigher : labelWhenLower;
    final gradient = isHigher ? gradientWhenHigher : gradientWhenLower;

    final transparentGradient = LinearGradient(
      colors: gradient.colors.map((c) => c.withValues(alpha: .8)).toList(),
      begin: gradient.begin,
      end: gradient.end,
      stops: gradient.stops,
    );

    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: transparentGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gradient.colors.first.withValues(alpha: 9),
          width: .5,
        ),
      ),
      child: Row(
        key: key != null ? ValueKey('${(key as ValueKey).value}-row') : null,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key: key != null ? ValueKey('${(key as ValueKey).value}-label') : null,
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            key: key != null ? ValueKey('${(key as ValueKey).value}-amount') : null,
            AmountFormatter.formatWithCurrency(
                amount, currency),
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(transactionListSummaryProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currency = ref.watch(currentCurrencyProvider).value;

    if (currency == null) return const SizedBox.shrink();

    return summaryAsync.when(
      skipLoadingOnRefresh: true,
      data: (s) => Column(
        key: const ValueKey('tx-list-summary-content-column'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            key: const ValueKey('tx-list-summary-row-1'),
            children: [
              Expanded(
                child: _SummaryTile(
                  key: const ValueKey('tx-summary-payable'),
                  label: l10n.payableTag,
                  amount: s.totalPayable,
                  color: AppColors.payableColor,
                  currency: currency,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryTile(
                  key: const ValueKey('tx-summary-receivable'),
                  label: l10n.receivableTag,
                  amount: s.totalReceivable,
                  color: AppColors.receivableColor,
                  currency: currency,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            key: const ValueKey('tx-list-summary-row-2'),
            children: [
              Expanded(
                child: _SummaryTile(
                  key: const ValueKey('tx-summary-expense'),
                  label: l10n.expenses,
                  amount: s.totalExpense,
                  color: AppColors.expenseColor,
                  currency: currency,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryTile(
                  key: const ValueKey('tx-summary-income'),
                  label: l10n.income,
                  amount: s.totalIncome,
                  color: AppColors.incomeColor,
                  currency: currency,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildBalanceRow(
            key: const ValueKey('tx-summary-net-receivable-payable'),
            theme: theme,
            currency: currency,
            isReceivableHigher: s.totalReceivable >= s.totalPayable,
            amount: (s.totalReceivable - s.totalPayable).abs(),
            labelWhenHigher: l10n.netReceivable,
            labelWhenLower: l10n.netPayable,
            gradientWhenHigher: AppColors.receivableGradient,
            gradientWhenLower: AppColors.payableGradient,
          ),
          const SizedBox(height: 8),
          _buildBalanceRow(
            key: const ValueKey('tx-summary-net-income-expense'),
            theme: theme,
            currency: currency,
            isReceivableHigher: s.totalIncome >= s.totalExpense,
            amount: (s.totalIncome - s.totalExpense).abs(),
            labelWhenHigher: l10n.netIncome,
            labelWhenLower: l10n.netExpenses,
            gradientWhenHigher: AppColors.incomeGradient,
            gradientWhenLower: AppColors.expenseGradient,
          ),
        ],
      ),
      loading: () => SizedBox(
        key: const ValueKey('tx-list-summary-loading'),
        height: 4,
        child: LinearProgressIndicator(
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Lightweight dim + floating panel (avoids default dark [Colors.black54] dialog barrier).
class _BulkImportLoadingDialog extends StatelessWidget {
  const _BulkImportLoadingDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Material(
          elevation: 6,
          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.18),
          surfaceTintColor: theme.colorScheme.surfaceTint,
          borderRadius: BorderRadius.circular(20),
          color: theme.colorScheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppLoadingIndicator(
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.bulkImportLoadingContent,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

class _SummaryTile extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final AppCurrency currency;

  const _SummaryTile({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        key: ValueKey('summary-tile-col-$label'),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            key: ValueKey('summary-tile-label-$label'),
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            key: ValueKey('summary-tile-amount-$label'),
            AmountFormatter.formatWithCurrency(
                amount, currency),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
