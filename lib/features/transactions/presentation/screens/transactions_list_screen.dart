import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class TransactionsListScreen extends ConsumerWidget {
  const TransactionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final transactionsAsync = ref.watch(transactionsWithCategoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactions),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 120,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No transactions yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap + to add your first transaction',
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
          for (final item in transactions) {
            final dateKey = DateFormat.yMMMd().format(item.transaction.date);
            groupedTransactions.putIfAbsent(dateKey, () => []);
            groupedTransactions[dateKey]!.add(item);
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: groupedTransactions.length,
            itemBuilder: (context, index) {
              final dateKey = groupedTransactions.keys.elementAt(index);
              final dateTransactions = groupedTransactions[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      dateKey,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Transactions for this date
                  ...dateTransactions.map((item) {
                    final isExpense = item.transaction.type == 'EXPENSE';

                    return _buildTransactionCard(
                      context,
                      item: item,
                      isExpense: isExpense,
                    );
                  }),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading transactions',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
    );
  }

  Widget _buildTransactionCard(
    BuildContext context, {
    required dynamic item, // TransactionWithCategory
    required bool isExpense,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final transaction = item.transaction;
    final category = item.category;

    // Check if it's a "credit" transaction (Paid BY or Will Receive)
    final isCredit = transaction.paidRelationship == 'PAID_BY' || 
                     transaction.paidRelationship == 'WILL_RECEIVE';

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

    // Apply dull effect if credit
    final displayColor = isCredit ? categoryColor.withValues(alpha: 0.5) : categoryColor;
    final textColor = isCredit ? theme.colorScheme.onSurface.withValues(alpha: 0.6) : theme.colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: isCredit ? 0.6 : 1.0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: displayColor.withValues(alpha: isDark ? 0.2 : 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: displayColor.withValues(alpha: isDark ? 0.05 : 0.08),
            blurRadius: isCredit ? 4 : 12,
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
          child: _buildCategoryIcon(category?.icon, displayColor, isExpense),
        ),
        title: Text(
          transaction.description ?? (isExpense ? 'Expense' : 'Income'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
            decoration: isCredit ? null : null, // Could add strikethrough if cancelled
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category?.name ?? 'Uncategorized',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: isCredit ? 0.5 : 1.0),
              ),
            ),
            if (isCredit) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time, 
                      size: 10, 
                      color: theme.colorScheme.onSurfaceVariant
                    ),
                    const SizedBox(width: 4),
                    Text(
                      transaction.paidRelationship == 'PAID_BY' 
                          ? 'Paid by others' 
                          : 'Receive later',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        trailing: Text(
          '${isExpense ? '-' : '+'} ₹${transaction.amount.toStringAsFixed(2)}',
          style: theme.textTheme.titleLarge?.copyWith(
            color: isExpense 
                ? (isCredit ? AppColors.expenseColor.withValues(alpha: 0.5) : AppColors.expenseColor)
                : (isCredit ? AppColors.incomeColor.withValues(alpha: 0.5) : AppColors.incomeColor),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        onTap: () {
          // TODO: Navigate to transaction details
        },
      ),
    );
  }

  Widget _buildCategoryIcon(String? iconString, Color color, bool isExpense) {
    if (iconString == null) {
      return Icon(
        isExpense ? Icons.money_off : Icons.attach_money,
        color: color,
        size: 24,
      );
    }

    // Try to parse as integer (code point for IconData)
    final int? codePoint = int.tryParse(iconString);
    if (codePoint != null) {
      return Icon(
        IconData(codePoint, fontFamily: 'MaterialIcons'),
        color: color,
        size: 24,
      );
    }

    // Fallback to text (emoji)
    return Text(
      iconString,
      style: const TextStyle(fontSize: 24),
    );
  }
}
