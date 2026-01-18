import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/features/payables/domain/models.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/payables/presentation/screens/edit_payable_screen.dart';
import 'package:flowpaisa/features/whatsapp/presentation/providers/whatsapp_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';

class PayableDetailsDialog extends ConsumerWidget {
  final PayableWithLinkedData item;

  const PayableDetailsDialog({
    super.key,
    required this.item,
  });

  bool _canEditPayable(Payable payable) {
    // Can edit only if PENDING and not linked to any transaction
    return payable.status == 'PENDING' &&
        payable.linkedExpenseId == null &&
        payable.linkedIncomeId == null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;
    final payable = item.payable;
    final contact = item.contact;
    final linkedTransaction = item.linkedTransaction;

    if (currency == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final linkedCategory = item.linkedCategory;
    final isPending = payable.status == 'PENDING';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payable Details'),
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePayable(context, ref, payable, contact),
          ),
          // Edit button (hide if paid or linked)
          if (_canEditPayable(payable))
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditPayableScreen(payableId: payable.id),
                  ),
                );
              },
            ),
          // Delete button (hide if paid)
          if (payable.status != 'PAID')
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deletePayable(context, ref, payable.id),
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
                  colors: [
                    AppColors.payableColor,
                    AppColors.payableColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.payableColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    isPending ? 'Payable (Pending)' : 'Paid',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AmountFormatter.formatWithCurrency(payable.amount,
                        currency.symbol, currency.decimalPlaces),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AmountFormatter.getFontSize(payable.amount,
                              decimalPlaces: currency.decimalPlaces) +
                          6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isPending) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Paid',
                            style: TextStyle(
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

            // Contact Header Section
            if (contact != null) ...[
              Row(
                children: [
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
                      onPressed: () =>
                          _sendWhatsAppMessage(context, ref, contact, payable),
                    ),
                ],
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
              value: DateFormat.yMMMd().format(payable.date),
            ),

            if (payable.dueDate != null)
              _buildDetailRow(
                context,
                icon: Icons.event,
                label: 'Due Date',
                value: DateFormat.yMMMd().format(payable.dueDate!),
                valueColor: isPending
                    ? (payable.dueDate!.isBefore(DateTime.now())
                        ? Colors.red
                        : Colors.orange)
                    : null,
              ),

            if (payable.description != null && payable.description!.isNotEmpty)
              _buildDetailRow(
                context,
                icon: Icons.description,
                label: 'Description',
                value: payable.description!,
              ),

            // Linked Transaction Section
            if (linkedTransaction != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Linked Transaction',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildLinkedTransactionCard(
                  context, ref, linkedTransaction, linkedCategory),
            ],

            // Actions
            if (isPending) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _markAsPaid(context, ref, payable.id),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark as Paid'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.payableColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
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

  Widget _buildLinkedTransactionCard(BuildContext context, WidgetRef ref,
      dynamic transaction, dynamic category) {
    final theme = Theme.of(context);
    final currency = ref.read(currentCurrencyProvider).value!;
    final isExpense = transaction.type == 'EXPENSE';
    final categoryColor = category != null && category.color != null
        ? Color(int.parse(category.color!.replaceAll('#', '0xFF')))
        : (isExpense ? AppColors.expenseColor : AppColors.incomeColor);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isExpense ? AppColors.expenseColor : AppColors.incomeColor)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isExpense ? AppColors.expenseColor : AppColors.incomeColor)
              .withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category != null && category.icon != null
                      ? (IconHelper.getIconData(category.icon) ??
                          Symbols.category)
                      : (isExpense ? Icons.payment : Icons.monetization_on),
                  color: categoryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category != null
                          ? category.name
                          : (isExpense ? 'Expense' : 'Income'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                    Text(
                      isExpense ? 'Expense' : 'Income',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '${isExpense ? '-' : '+'} ${AmountFormatter.formatWithCurrency(transaction.amount, currency.symbol, currency.decimalPlaces)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isExpense
                      ? AppColors.expenseColor
                      : AppColors.incomeColor,
                ),
              ),
            ],
          ),
          if (transaction.description != null &&
              transaction.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              transaction.description,
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            DateFormat.yMMMd().add_jm().format(transaction.date),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _sharePayable(
      BuildContext context, WidgetRef ref, dynamic payable, dynamic contact) {
    final currency = ref.read(currentCurrencyProvider).value!;
    final message = '''
Payable Details
Amount: ${AmountFormatter.formatWithCurrency(payable.amount, currency.symbol, currency.decimalPlaces)}
Contact: ${contact?.name ?? 'Unknown'}
Date: ${DateFormat.yMMMd().format(payable.date)}
${payable.dueDate != null ? 'Due Date: ${DateFormat.yMMMd().format(payable.dueDate)}\n' : ''}${payable.description != null && payable.description.isNotEmpty ? 'Description: ${payable.description}\n' : ''}Status: ${payable.status == 'PENDING' ? 'Pending' : 'Paid'}
    ''';

    Share.share(message);
  }

  Future<void> _deletePayable(
      BuildContext context, WidgetRef ref, int payableId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payable'),
        content: const Text(
            'Are you sure you want to delete this payable? This action cannot be undone.'),
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
        final repository = ref.read(payablesRepositoryProvider);
        await repository.deletePayable(payableId);

        if (context.mounted) {
          Navigator.pop(context);
          ToastUtils.showSuccessToast(
              context, ref, 'Payable deleted successfully');
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtils.showErrorToast(
              context, ref, 'Error deleting payable: ${e.toString()}');
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
        ToastUtils.showSuccessToast(context, ref, 'Marked as paid');
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(context, ref, 'Error: ${e.toString()}');
      }
    }
  }

  Future<void> _sendWhatsAppMessage(
    BuildContext context,
    WidgetRef ref,
    dynamic contact,
    dynamic payable,
  ) async {
    final currency = ref.read(currentCurrencyProvider).value!;
    if (contact.phone == null || contact.phone.isEmpty) {
      ToastUtils.showWarningToast(
          context, ref, 'No phone number available for this contact');
      return;
    }

    try {
      final whatsAppService = ref.read(whatsAppServiceProvider);
      final message = '''
Hi ${contact.name},

This is a reminder regarding the payable amount of ${AmountFormatter.formatWithCurrency(payable.amount, currency.symbol, currency.decimalPlaces)} dated ${DateFormat.yMMMd().format(payable.date)}.

${payable.dueDate != null ? 'Due Date: ${DateFormat.yMMMd().format(payable.dueDate)}\n' : ''}${payable.description != null && payable.description.isNotEmpty ? 'Details: ${payable.description}\n' : ''}
Thank you!
      ''';

      // Clean phone number - remove spaces and non-digit characters except +
      final cleanPhone =
          contact.phone.replaceAll(' ', '').replaceAll(RegExp(r'[^\d+]'), '');
      final success = await whatsAppService.sendMessage(cleanPhone, message);

      if (success && context.mounted) {
        ToastUtils.showSuccessToast(context, ref, 'Opening WhatsApp...');
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(context, ref, 'Error: ${e.toString()}');
      }
    }
  }
}
