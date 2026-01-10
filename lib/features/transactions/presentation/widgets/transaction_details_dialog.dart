import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/edit_transaction_screen.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/whatsapp/presentation/providers/whatsapp_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class TransactionDetailsDialog extends ConsumerWidget {
  final TransactionWithDetails item;

  const TransactionDetailsDialog({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final transaction = item.transaction;
    final category = item.category;
    final contact = item.contact;
    final linkedPayable = item.linkedPayable;
    final linkedReceivable = item.linkedReceivable;
    final isExpense = transaction.type == 'EXPENSE';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () =>
                _shareTransaction(context, transaction, category, contact),
          ),
          // Edit button (disabled if marked)
          if (!item.isLinkedEntryMarked)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditTransactionScreen(
                      transaction: transaction,
                      category: category,
                      contact: contact,
                    ),
                  ),
                );
              },
            ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteTransaction(context, ref, transaction.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isExpense
                      ? [
                          AppColors.expenseColor,
                          AppColors.expenseColor.withValues(alpha: 0.7)
                        ]
                      : [
                          AppColors.incomeColor,
                          AppColors.incomeColor.withValues(alpha: 0.7)
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isExpense
                            ? AppColors.expenseColor
                            : AppColors.incomeColor)
                        .withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    isExpense ? 'Expense' : 'Income',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${isExpense ? '-' : '+'} ${AmountFormatter.formatWithCurrency(transaction.amount)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          AmountFormatter.getFontSize(transaction.amount) + 6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (transaction.paidRelationship != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.isLinkedEntryMarked)
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.white,
                            ),
                          if (item.isLinkedEntryMarked)
                            const SizedBox(width: 6),
                          Text(
                            _getStatusLabel(transaction.paidRelationship!,
                                item.isLinkedEntryMarked),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
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

            const SizedBox(height: 24),

            // Contact & Category Header Section
            if (contact != null || category != null) ...[
              Row(
                children: [
                  // Contact Section
                  if (contact != null) ...[
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppColors.getContactGradient(contact.name),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.getContactColor(contact.name)
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        contact.name.isNotEmpty
                            ? contact.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (contact.phone != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  contact.phone!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (contact.phone != null)
                      IconButton(
                        icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                        onPressed: () => _sendWhatsAppMessage(
                            context, ref, contact, transaction),
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              // Category Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: category != null
                      ? Color(int.parse(
                              category.color!.replaceAll('#', '0xFF')))
                          .withValues(alpha: 0.1)
                      : (isExpense
                              ? AppColors.expenseColor
                              : AppColors.incomeColor)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: category != null
                        ? Color(int.parse(
                                category.color!.replaceAll('#', '0xFF')))
                            .withValues(alpha: 0.3)
                        : (isExpense
                                ? AppColors.expenseColor
                                : AppColors.incomeColor)
                            .withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: category != null
                            ? Color(int.parse(
                                    category.color!.replaceAll('#', '0xFF')))
                                .withValues(alpha: 0.2)
                            : (isExpense
                                    ? AppColors.expenseColor
                                    : AppColors.incomeColor)
                                .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        category != null && category.icon != null
                            ? IconData(int.parse(category.icon!),
                                fontFamily: 'MaterialIcons')
                            : (isExpense
                                ? Icons.arrow_circle_down
                                : Icons.arrow_circle_up),
                        color: category != null
                            ? Color(int.parse(
                                category.color!.replaceAll('#', '0xFF')))
                            : (isExpense
                                ? AppColors.expenseColor
                                : AppColors.incomeColor),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            category?.name ??
                                (isExpense ? 'Expense' : 'Income'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: category != null
                                  ? Color(int.parse(
                                      category.color!.replaceAll('#', '0xFF')))
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
            ],

            // Details Section
            _buildDetailRow(
              context,
              icon: Icons.calendar_today,
              label: 'Date',
              value: DateFormat.yMMMd().add_jm().format(transaction.date),
            ),

            if (transaction.description != null &&
                transaction.description!.isNotEmpty)
              _buildDetailRow(
                context,
                icon: Icons.description,
                label: 'Description',
                value: transaction.description!,
              ),

            // Linked Entry Section
            if (linkedPayable != null || linkedReceivable != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Linked Entry',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (linkedPayable != null)
                _buildLinkedPayableCard(context, ref, linkedPayable),
              if (linkedReceivable != null)
                _buildLinkedReceivableCard(context, ref, linkedReceivable),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildLinkedPayableCard(
      BuildContext context, WidgetRef ref, dynamic payable) {
    final theme = Theme.of(context);
    final isPending = payable.status == 'PENDING';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.payableColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.payableColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPending ? Icons.schedule : Icons.check_circle,
                color: AppColors.payableColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isPending ? 'Payable (Pending)' : 'Paid',
                style: TextStyle(
                  color: AppColors.payableColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (payable.dueDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Due: ${DateFormat.yMMMd().format(payable.dueDate)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _markAsPaid(context, ref, payable.id),
                icon: const Icon(Icons.check_circle),
                label: const Text('Mark as Paid'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.payableColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinkedReceivableCard(
      BuildContext context, WidgetRef ref, dynamic receivable) {
    final theme = Theme.of(context);
    final isPending = receivable.status == 'PENDING';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.receivableColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.receivableColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPending ? Icons.schedule : Icons.check_circle,
                color: AppColors.receivableColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isPending ? 'Receivable (Pending)' : 'Received',
                style: TextStyle(
                  color: AppColors.receivableColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (receivable.dueDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Due: ${DateFormat.yMMMd().format(receivable.dueDate)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _markAsReceived(context, ref, receivable.id),
                icon: const Icon(Icons.check_circle),
                label: const Text('Mark as Received'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.receivableColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusLabel(String relationship, bool isMarked) {
    switch (relationship) {
      case 'PAID_FOR':
        return isMarked ? 'Received' : 'Receivable';
      case 'PAID_BY':
        return isMarked ? 'Paid' : 'Payable';
      case 'RECEIVED_FROM':
        return isMarked ? 'Paid' : 'Payable';
      case 'WILL_RECEIVE':
        return isMarked ? 'Received' : 'Receivable';
      default:
        return '';
    }
  }

  void _shareTransaction(BuildContext context, dynamic transaction,
      dynamic category, dynamic contact) {
    final isExpense = transaction.type == 'EXPENSE';
    final message = '''
${isExpense ? 'Expense' : 'Income'} Details
Amount: ${AmountFormatter.formatWithCurrency(transaction.amount)}
Date: ${DateFormat.yMMMd().format(transaction.date)}
${category != null ? 'Category: ${category.name}\n' : ''}${contact != null ? 'Contact: ${contact.name}\n' : ''}${transaction.description != null && transaction.description.isNotEmpty ? 'Description: ${transaction.description}\n' : ''}
    ''';

    Share.share(message);
  }

  Future<void> _deleteTransaction(
      BuildContext context, WidgetRef ref, int transactionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
            'Are you sure you want to delete this transaction? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final service = ref.read(transactionServiceProvider);
        await service.deleteTransaction(transactionId);

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting transaction: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _markAsPaid(
      BuildContext context, WidgetRef ref, int payableId) async {
    try {
      final repository = ref.read(payablesRepositoryProvider);
      await repository.markAsPaid(payableId);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marked as paid'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsReceived(
      BuildContext context, WidgetRef ref, int receivableId) async {
    try {
      final repository = ref.read(receivablesRepositoryProvider);
      await repository.markAsReceived(receivableId);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marked as received'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendWhatsAppMessage(
    BuildContext context,
    WidgetRef ref,
    dynamic contact,
    dynamic transaction,
  ) async {
    if (contact.phone == null || contact.phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No phone number available for this contact'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final whatsAppService = ref.read(whatsAppServiceProvider);
      final isExpense = transaction.type == 'EXPENSE';
      final message = '''
Hi ${contact.name},

This is regarding the ${isExpense ? 'expense' : 'income'} of ${AmountFormatter.formatWithCurrency(transaction.amount)} on ${DateFormat.yMMMd().format(transaction.date)}.

${transaction.description != null && transaction.description.isNotEmpty ? 'Details: ${transaction.description}' : ''}

Thank you!
      ''';

      // Clean phone number - remove spaces and non-digit characters except +
      final cleanPhone =
          contact.phone.replaceAll(' ', '').replaceAll(RegExp(r'[^\d+]'), '');
      final success = await whatsAppService.sendMessage(cleanPhone, message);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening WhatsApp...'),
            backgroundColor: Color(0xFF25D366),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
