import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/features/receivables/domain/models.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/screens/edit_receivable_screen.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/features/whatsapp/domain/models/shared_data_models.dart';
import 'package:flowpaisa/features/whatsapp/presentation/providers/whatsapp_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';

class ReceivableDetailsDialog extends ConsumerWidget {
  final ReceivableWithLinkedData item;

  const ReceivableDetailsDialog({
    super.key,
    required this.item,
  });

  bool _canEditReceivable(Receivable receivable) {
    // Can edit only if PENDING and not linked to any transaction
    return receivable.status == 'PENDING' &&
        receivable.linkedExpenseId == null &&
        receivable.linkedIncomeId == null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;
    final receivable = item.receivable;
    final contact = item.contact;
    final linkedTransaction = item.linkedTransaction;

    if (currency == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final linkedCategory = item.linkedCategory;
    final isPending = receivable.status == 'PENDING';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receivable Details'),
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () =>
                _shareReceivable(context, ref, receivable, contact),
          ),
          // Edit button (hide if received or linked)
          if (_canEditReceivable(receivable))
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditReceivableScreen(receivableId: receivable.id),
                  ),
                );
              },
            ),
          // Delete button (hide if received)
          if (receivable.status != 'RECEIVED')
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteReceivable(context, ref, receivable.id),
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
                    AppColors.receivableColor,
                    AppColors.receivableColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.receivableColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    isPending ? 'Receivable (Pending)' : 'Received',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AmountFormatter.formatWithCurrency(receivable.amount,
                        currency.symbol, currency.decimalPlaces),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AmountFormatter.getFontSize(receivable.amount,
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
                            'Received',
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
                      onPressed: () => _sendWhatsAppMessage(
                          context, ref, contact, receivable),
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
              value: AppDateFormatter.formatDate(receivable.date,
                  pattern: ref.watch(userProfileProvider).dateFormat),
            ),

            if (receivable.dueDate != null)
              _buildDetailRow(
                context,
                icon: Icons.event,
                label: 'Due Date',
                value: AppDateFormatter.formatDate(receivable.dueDate!,
                    pattern: ref.watch(userProfileProvider).dateFormat),
                valueColor: isPending
                    ? (receivable.dueDate!.isBefore(DateTime.now())
                        ? Colors.red
                        : Colors.orange)
                    : null,
              ),

            if (receivable.description != null &&
                receivable.description!.isNotEmpty)
              _buildDetailRow(
                context,
                icon: Icons.description,
                label: 'Description',
                value: receivable.description!,
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
                  onPressed: () => _markAsReceived(context, ref, receivable.id),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark as Received'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.receivableColor,
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
            AppDateFormatter.formatDate(transaction.date,
                pattern: ref.watch(userProfileProvider).dateFormat),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareReceivable(BuildContext context, WidgetRef ref, dynamic receivable,
      dynamic contact) async {
    final currency = ref.read(currentCurrencyProvider).value!;
    final userProfile = ref.read(userProfileProvider);
    final deepLinkService = DeepLinkService();
    final transactionService = ref.read(transactionServiceProvider);
    final isReceived = receivable.status == 'RECEIVED';

    // Ensure external ID is persisted before sharing
    final effectiveExternalId = await transactionService.ensureExternalLinkId(
      receivableId: receivable.id,
    );

    final link = deepLinkService.generatePayableLink(PayableShareData(
      amount: receivable.amount,
      date: receivable.date,
      description: receivable.description,
      dueDate: receivable.dueDate,
      senderName: userProfile.name ?? 'Someone',
      senderPhone: userProfile.phone ?? '',
      externalLinkId: effectiveExternalId,
      status: receivable.status,
    ));

    String message;
    if (isReceived) {
      message = '''
Greetings! 

The payment of ${AmountFormatter.formatWithCurrency(receivable.amount, currency.symbol, currency.decimalPlaces)} has been received and recorded. 

If you haven't updated this in your records, please use the link below to sync it in FlowPaisa:
$link

Thank you!
''';
    } else {
      message = '''
Receivable Details
Amount: ${AmountFormatter.formatWithCurrency(receivable.amount, currency.symbol, currency.decimalPlaces)}
Contact: ${contact?.name ?? 'Unknown'}
Date: ${AppDateFormatter.formatDate(receivable.date, pattern: userProfile.dateFormat)}
${receivable.dueDate != null ? 'Due Date: ${AppDateFormatter.formatDate(receivable.dueDate, pattern: userProfile.dateFormat)}\n' : ''}${receivable.description != null && receivable.description.isNotEmpty ? 'Description: ${receivable.description}\n' : ''}Status: Pending

View and record this in FlowPaisa:
$link
''';
    }

    Share.share(message);
  }

  Future<void> _deleteReceivable(
      BuildContext context, WidgetRef ref, int receivableId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Receivable'),
        content: const Text(
            'Are you sure you want to delete this receivable? This action cannot be undone.'),
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
        final repository = ref.read(receivablesRepositoryProvider);
        await repository.deleteReceivable(receivableId);

        if (context.mounted) {
          Navigator.pop(context);
          ToastUtils.showSuccessToast(
              context, ref, 'Receivable deleted successfully');
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtils.showErrorToast(
              context, ref, 'Error deleting receivable: ${e.toString()}');
        }
      }
    }
  }

  Future<void> _markAsReceived(
      BuildContext context, WidgetRef ref, int receivableId) async {
    try {
      final repository = ref.read(receivablesRepositoryProvider);
      await repository.markAsReceived(receivableId);

      if (context.mounted) {
        // Refresh item to get updated status and externalLinkId
        final updatedItem = await repository.getReceivableWithLinkedDataById(receivableId);
        
        if (context.mounted) {
          Navigator.pop(context);
          ToastUtils.showSuccessToast(context, ref, 'Marked as received');
          
          if (updatedItem != null) {
            _showSettlementShareOption(context, ref, updatedItem.receivable, updatedItem.contact);
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(context, ref, 'Error: ${e.toString()}');
      }
    }
  }

  void _showSettlementShareOption(BuildContext context, WidgetRef ref, Receivable receivable, dynamic contact) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Receivable marked as received. Inform the contact?'),
        action: SnackBarAction(
          label: 'SHARE',
          onPressed: () => _shareReceivable(context, ref, receivable, contact),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _sendWhatsAppMessage(
    BuildContext context,
    WidgetRef ref,
    dynamic contact,
    dynamic receivable,
  ) async {
    final currency = ref.read(currentCurrencyProvider).value!;
    if (contact.phone == null || contact.phone.isEmpty) {
      ToastUtils.showWarningToast(
          context, ref, 'No phone number available for this contact');
      return;
    }

    try {
      final whatsAppService = ref.read(whatsAppServiceProvider);
      final userProfile = ref.read(userProfileProvider);
      final deepLinkService = DeepLinkService();
      final transactionService = ref.read(transactionServiceProvider);
      final isReceived = receivable.status == 'RECEIVED';

      final senderName = userProfile.name ?? 'Someone';
      final senderPhone = userProfile.phone ?? '';

      // Ensure external ID is persisted before sharing
      final effectiveExternalId = await transactionService.ensureExternalLinkId(
        receivableId: receivable.id,
      );

      // Create reciprocal link (Payable link for the recipient)
      final link = deepLinkService.generatePayableLink(PayableShareData(
        amount: receivable.amount,
        date: receivable.date,
        description: receivable.description,
        dueDate: receivable.dueDate,
        senderName: senderName,
        senderPhone: senderPhone,
        externalLinkId: effectiveExternalId,
        status: receivable.status,
      ));

      String message;
      if (isReceived) {
        message = '''
Hi ${contact.name},

Greetings! 

Your payment of ${AmountFormatter.formatWithCurrency(receivable.amount, currency.symbol, currency.decimalPlaces)} dated ${AppDateFormatter.formatDate(receivable.date, pattern: userProfile.dateFormat)} has been received and recorded. 

If you haven't updated this payment in FlowPaisa, please follow the link below to sync your records:
$link

Thank you!
''';
      } else {
        message = '''
Hi ${contact.name},

This is a reminder regarding the receivable amount of ${AmountFormatter.formatWithCurrency(receivable.amount, currency.symbol, currency.decimalPlaces)} dated ${AppDateFormatter.formatDate(receivable.date, pattern: userProfile.dateFormat)}.

${receivable.dueDate != null ? 'Due Date: ${AppDateFormatter.formatDate(receivable.dueDate, pattern: userProfile.dateFormat)}\n' : ''}${receivable.description != null && receivable.description.isNotEmpty ? 'Details: ${receivable.description}\n' : ''}
View and import this in FlowPaisa:
$link

Thank you!
''';
      }

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
