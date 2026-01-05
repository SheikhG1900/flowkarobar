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
    final transactionsAsync = ref.watch(allTransactionsProvider);
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
          for (final transaction in transactions) {
            final dateKey = DateFormat.yMMMd().format(transaction.date);
            groupedTransactions.putIfAbsent(dateKey, () => []);
            groupedTransactions[dateKey]!.add(transaction);
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
                  ...dateTransactions.map((transaction) {
                    final isExpense = transaction.type == 'EXPENSE';
                    
                    return _buildTransactionCard(
                      context,
                      transaction: transaction,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context, {
    required dynamic transaction,
    required bool isExpense,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExpense 
            ? isDark
                ? [const Color(0xFF2A2038), AppColors.darkCard] // Purple tint
                : [const Color(0xFFFFF1F2), const Color(0xFFFFF5F5)] // Light pink shades
            : isDark
                ? [const Color(0xFF1A2E2A), AppColors.darkCard] // Green tint
                : [const Color(0xFFF0FDF4), const Color(0xFFF0F9FF)], // Light green-blue shades
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpense 
            ? AppColors.expenseColor.withValues(alpha: isDark ? 0.3 / 1.0 : 0.15 / 1.0)
            : AppColors.incomeColor.withValues(alpha: isDark ? 0.3 / 1.0 : 0.15 / 1.0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isExpense ? AppColors.expenseColor : AppColors.incomeColor)
                .withValues(alpha: isDark ? 0.2 / 1.0 : 0.12 / 1.0),
            blurRadius: isDark ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: isExpense ? AppColors.expenseGradient : AppColors.incomeGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isExpense ? AppColors.expenseColor : AppColors.incomeColor)
                    .withValues(alpha: 0.4 / 1.0),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            isExpense 
              ? Icons.shopping_bag_outlined 
              : Icons.account_balance_wallet_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          transaction.description ?? (isExpense ? 'Expense' : 'Income'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: transaction.categoryId != null
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Category', // TODO: Load actual category name
                style: theme.textTheme.bodySmall,
              ),
            )
          : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isExpense ? '-' : '+'} ₹${transaction.amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleLarge?.copyWith(
                color: isExpense ? AppColors.expenseColor : AppColors.incomeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to transaction details
        },
      ),
    );
  }
}

