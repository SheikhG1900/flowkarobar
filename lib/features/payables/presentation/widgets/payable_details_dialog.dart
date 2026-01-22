import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/features/payables/domain/models.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/core/utils/share_helper.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/payables/presentation/screens/edit_payable_screen.dart';
import 'package:flowpaisa/features/whatsapp/presentation/providers/whatsapp_provider.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
        title: Text(l10n.payableDetails),
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () =>
                ShareHelper.sharePayable(context, ref, payable, contact),
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
                    isPending ? l10n.payablePending : l10n.paidTag,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\u200E${AmountFormatter.formatWithCurrency(payable.amount,
                        currency.symbol, currency.decimalPlaces)}',
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.paidTag,
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
                      onPressed: () => ShareHelper.sharePayable(
                          context, ref, payable, contact),
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
              label: l10n.date,
              value: AppDateFormatter.formatDate(payable.date),
            ),

            if (payable.dueDate != null)
              _buildDetailRow(
                context,
                icon: Icons.event,
                label: l10n.dueDate,
                value: AppDateFormatter.formatDate(payable.dueDate!),
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
                label: l10n.description,
                value: payable.description!,
              ),

            // Linked Transaction Section
            if (linkedTransaction != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                l10n.linkedTransaction,
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
                  label: Text(l10n.markAsPaid),
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
    final l10n = AppLocalizations.of(context)!;
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
                          Icons.category)
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
                          ? LocalizationHelper.localizeCategory(
                              context, category.name)
                          : (isExpense ? l10n.expense : l10n.income),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                    Text(
                      isExpense ? l10n.expense : l10n.income,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '${isExpense ? '\u200E-' : '\u200E+'} ${AmountFormatter.formatWithCurrency(transaction.amount, currency.symbol, currency.decimalPlaces)}',
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
            AppDateFormatter.formatDate(transaction.date),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePayable(
      BuildContext context, WidgetRef ref, int payableId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePayableTitle),
        content: Text(l10n.deletePayableMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
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
          ToastUtils.showSuccessToast(context, ref, l10n.payableDeleted);
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtils.showErrorToast(
              context, ref, l10n.errorOccurred(e.toString()));
        }
      }
    }
  }

  Future<void> _markAsPaid(
      BuildContext context, WidgetRef ref, int payableId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final repository = ref.read(payablesRepositoryProvider);
      await repository.markAsPaid(payableId);

      if (context.mounted) {
        // Refresh item to get updated status and externalLinkId
        final updatedItem =
            await repository.getPayableWithLinkedDataById(payableId);

        if (context.mounted) {
          final activeColor = ref.read(activeCashbookProvider).color;
          final currency = ref.read(currentCurrencyProvider).value!;
          final userProfile = ref.read(userProfileProvider);
          final transactionService = ref.read(transactionServiceProvider);
          final whatsAppService = ref.read(whatsAppServiceProvider);

          ToastUtils.showSuccessToast(context, ref, l10n.markedAsPaid,
              color: activeColor);

          if (updatedItem != null) {
            _showSettlementShareOption(
              context,
              ref,
              updatedItem.payable,
              updatedItem.contact,
              activeColor: activeColor,
              currency: currency,
              userProfile: userProfile,
              transactionService: transactionService,
              whatsAppService: whatsAppService,
            );
          }
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  void _showSettlementShareOption(
    BuildContext context,
    WidgetRef ref,
    Payable payable,
    dynamic contact, {
    Color? activeColor,
    dynamic currency,
    dynamic userProfile,
    dynamic transactionService,
    dynamic whatsAppService,
  }) {
    final l10n = AppLocalizations.of(context)!;
    ToastUtils.showSuccessToast(
      context,
      ref,
      l10n.informContactSettlementPayable,
      actionLabel: l10n.share,
      onActionPressed: (snackContext) => ShareHelper.sharePayable(
        snackContext,
        ref,
        payable,
        contact,
        currencyOverride: currency,
        userProfileOverride: userProfile,
        transactionServiceOverride: transactionService,
        whatsAppServiceOverride: whatsAppService,
      ),
      color: activeColor,
    );
  }
}
