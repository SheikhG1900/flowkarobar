import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/screens/add_receivable_screen.dart';
import 'package:flowpaisa/features/receivables/presentation/screens/edit_receivable_screen.dart';
import 'package:flowpaisa/features/receivables/presentation/widgets/receivable_details_dialog.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/shared/widgets/swipeable_list_item.dart';
import 'package:intl/intl.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:material_symbols_icons/symbols.dart';

class ReceivablesListScreen extends ConsumerStatefulWidget {
  const ReceivablesListScreen({super.key});

  @override
  ConsumerState<ReceivablesListScreen> createState() =>
      _ReceivablesListScreenState();
}

class _ReceivablesListScreenState extends ConsumerState<ReceivablesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Reset pagination when tab changes
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      // Reset scroll position when tab changes
      _scrollController.jumpTo(0);
      // Refresh pagination for the new tab
      final status = _tabController.index == 0 ? 'PENDING' : 'RECEIVED';
      ref.read(receivablesPaginatedProvider(status).notifier).refresh();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom
      final status = _tabController.index == 0 ? 'PENDING' : 'RECEIVED';
      ref.read(receivablesPaginatedProvider(status).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receivables'),
        actions: [
          // Debug button to generate dummy receivables (only in debug mode)
          if (kDebugMode)
            PopupMenuButton<String>(
            icon: const Icon(Icons.bug_report),
            onSelected: (value) async {
              if (value == 'generate_dummy') {
                final repository = ref.read(receivablesRepositoryProvider);
                final contactsRepo = ref.read(contactsRepositoryProvider);
                try {
                  final contacts = await contactsRepo.watchAllContacts().first;
                  int defaultContactId;
                  if (contacts.isNotEmpty) {
                    defaultContactId = contacts[0].id;
                  } else {
                    // Create a default contact if none exists
                    defaultContactId = await contactsRepo.createContact(
                      ContactsCompanion(
                        name: const Value('Default Contact'),
                        createdAt: Value(DateTime.now()),
                        updatedAt: Value(DateTime.now()),
                      ),
                    );
                  }
                  
                  for (int i = 0; i < 100; i++) {
                    final daysAgo = i ~/ 2;
                    final date = DateTime.now().subtract(Duration(days: daysAgo));
                    final amount = (50.0 + (i * 15.3) % 2000).roundToDouble();
                    final contactId = contacts.isNotEmpty 
                        ? contacts[i % contacts.length].id 
                        : defaultContactId;
                    
                    await repository.createReceivable(
                      ReceivablesCompanion(
                        contactId: Value(contactId),
                        amount: Value(amount),
                        description: Value('Dummy Receivable #${i + 1}'),
                        date: Value(date),
                        status: Value(i % 3 == 0 ? 'RECEIVED' : 'PENDING'),
                        createdAt: Value(DateTime.now()),
                        updatedAt: Value(DateTime.now()),
                      ),
                    );
                  }
                  if (context.mounted) {
                    ToastUtils.showSuccessToast(context, 'Generated 100 dummy receivables');
                    // Refresh pagination
                    ref.read(receivablesPaginatedProvider('PENDING').notifier).refresh();
                    ref.read(receivablesPaginatedProvider('RECEIVED').notifier).refresh();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ToastUtils.showErrorToast(context, 'Error: $e');
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generate_dummy',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: 8),
                    Text('Generate 100 Dummy Receivables'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.receivableColor,
          labelColor: AppColors.receivableColor,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Received'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReceivablesList('PENDING'),
          _buildReceivablesList('RECEIVED'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddReceivableScreen(),
            ),
          );
        },
        backgroundColor: AppColors.receivablesSectionColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReceivablesList(String status) {
    // Use paginated provider
    final paginatedState = ref.watch(receivablesPaginatedProvider(status));
    final theme = Theme.of(context);
    final currency = ref.watch(currentCurrencyProvider).value;
    
    if (currency == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (paginatedState.isLoading && paginatedState.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (paginatedState.error != null && paginatedState.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading receivables',
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
                ref.read(receivablesPaginatedProvider(status).notifier).refresh();
              },
              child: const Text('Retry'),
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
                  : Icons.check_circle_outline,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              status == 'PENDING'
                  ? 'No pending receivables'
                  : 'No received payments',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              status == 'PENDING'
                  ? 'Add a receivable to track money owed to you'
                  : 'Mark pending receivables as received',
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
    for (final item in paginatedState.items) {
      final dateKey = DateFormat.yMMMd().format(item.receivable.date);
      groupedReceivables.putIfAbsent(dateKey, () => []);
      groupedReceivables[dateKey]!.add(item);
    }

    final keys = groupedReceivables.keys.toList();

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Date sections with sticky headers
        for (final dateKey in keys)
          SliverStickyHeader(
            header: Container(
              height: 50,
              color: theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              alignment: Alignment.centerLeft,
              child: Text(
                dateKey,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, itemIndex) {
                  final dateItems = groupedReceivables[dateKey]!;
                  if (itemIndex >= dateItems.length) return null;
                  
                  final item = dateItems[itemIndex];
                  // Restrict editing/deleting for received or linked receivables
                  final canEdit = item.receivable.status == 'PENDING' && 
                                  item.receivable.linkedExpenseId == null && 
                                  item.receivable.linkedIncomeId == null;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: SwipeableListItem(
                      enableEdit: canEdit,
                      enableDelete: canEdit,
                      borderRadius: 20,
                      onEdit: canEdit ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditReceivableScreen(receivableId: item.receivable.id),
                          ),
                        );
                      } : null,
                      onDelete: canEdit ? () async {
                        final repository = ref.read(receivablesRepositoryProvider);
                        await repository.deleteReceivable(item.receivable.id);
                        if (context.mounted) {
                          ToastUtils.showSuccessToast(context, 'Receivable deleted');
                        }
                      } : null,
                      child: _buildReceivableCard(item, currency),
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
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (!paginatedState.hasMore && paginatedState.items.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No more receivables',
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

  Widget _buildReceivableCard(dynamic item, AppCurrency currency) {
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
          color: AppColors.receivableColor.withValues(alpha: isDark ? 0.2 : 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.receivableColor.withValues(alpha: isDark ? 0.05 : 0.08),
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
                builder: (context) => ReceivableDetailsDialog(item: item),
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
                const SizedBox(width: 16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact?.name ?? 'Unknown',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                                  : AppColors.incomeColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                linkedCategory.icon != null
                                    ? IconHelper.getIconData(linkedCategory.icon)
                                    : Symbols.category,
                                color: linkedCategory.color != null
                                    ? Color(int.parse(linkedCategory.color!
                                        .replaceAll('#', '0xFF')))
                                    : AppColors.incomeColor,
                                size: 10,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  linkedCategory.name,
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
                                  ? AppColors.expenseColor.withValues(alpha: 0.3)
                                  : AppColors.incomeColor.withValues(alpha: 0.3),
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
                                    ? 'Expense'
                                    : 'Income',
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
                                  ? Colors.orange
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Due: ${DateFormat.yMMMd().format(receivable.dueDate!)}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isPending
                                    ? Colors.orange
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: isPending ? FontWeight.bold : null,
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
                      AmountFormatter.formatWithCurrency(receivable.amount, currency.symbol, currency.decimalPlaces),
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
                          color: AppColors.receivableColor.withValues(alpha: 0.3),
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
                            isPending ? 'Receivable' : 'Received',
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
    );
  }
}

