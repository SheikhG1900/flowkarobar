import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/payables/presentation/screens/add_payable_screen.dart';
import 'package:flowpaisa/features/payables/presentation/widgets/payable_details_dialog.dart';
import 'package:flowpaisa/shared/widgets/swipeable_list_item.dart';
import 'package:intl/intl.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:material_symbols_icons/symbols.dart';

class PayablesListScreen extends ConsumerStatefulWidget {
  const PayablesListScreen({super.key});

  @override
  ConsumerState<PayablesListScreen> createState() => _PayablesListScreenState();
}

class _PayablesListScreenState extends ConsumerState<PayablesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payables'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.payableColor,
          labelColor: AppColors.payableColor,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Paid'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPayablesList('PENDING'),
          _buildPayablesList('PAID'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
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
    // Use new provider with linked data (contact + transaction + category)
    final payablesAsync = ref.watch(payablesWithLinkedDataProvider(status));
    final theme = Theme.of(context);
    final repository = ref.read(payablesRepositoryProvider);
    final currency = ref.watch(currentCurrencyProvider).value;
    
    if (currency == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return payablesAsync.when(
      data: (payables) {
        if (payables.isEmpty) {
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
                  status == 'PENDING' ? 'No pending payables' : 'No paid bills',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  status == 'PENDING'
                      ? 'Add a payable to track money you owe'
                      : 'Mark pending payables as paid',
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
        for (final item in payables) {
          final dateKey = DateFormat.yMMMd().format(item.payable.date);
          groupedPayables.putIfAbsent(dateKey, () => []);
          groupedPayables[dateKey]!.add(item);
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: groupedPayables.length,
          itemBuilder: (context, index) {
            final dateKey = groupedPayables.keys.elementAt(index);
            final dateItems = groupedPayables[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    dateKey,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Items
                ...dateItems.map((item) {
                  // Restrict editing/deleting paid payables
                  final isRestricted = item.payable.status == 'PAID';
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: SwipeableListItem(
                      enableEdit: !isRestricted,
                      enableDelete: !isRestricted,
                      borderRadius: 20,
                      onEdit: isRestricted ? null : () {
                        // TODO: Navigate to edit screen
                      },
                      onDelete: isRestricted ? null : () async {
                        await repository.deletePayable(item.payable.id);
                        if (context.mounted) {
                          ToastUtils.showSuccessToast(context, 'Payable deleted');
                        }
                      },
                      child: _buildPayableCard(item, currency),
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildPayableCard(dynamic item, AppCurrency currency) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final payable = item.payable;
    final contact = item.contact;
    final linkedCategory = item.linkedCategory;
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
                builder: (context) => PayableDetailsDialog(item: item),
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
                      // Linked category tag
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
                                  : AppColors.expenseColor.withValues(alpha: 0.3),
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
                                    : AppColors.expenseColor,
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
                                        : AppColors.expenseColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                                  ? Colors.red
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Due: ${DateFormat.yMMMd().format(payable.dueDate!)}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isPending
                                    ? Colors.red
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
                      AmountFormatter.formatWithCurrency(payable.amount, currency.symbol, currency.decimalPlaces),
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
                            isPending ? 'Payable' : 'Paid',
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
