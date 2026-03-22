import 'package:flowpaisa/features/transactions/presentation/widgets/linked_settlement_account_sheet.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_details_dialog.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/contact_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/features/payables/domain/models.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/core/utils/share_helper.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/payables/presentation/screens/add_payable_screen.dart';
import 'package:flowpaisa/features/payables/presentation/screens/edit_payable_screen.dart';
import 'package:flowpaisa/features/messages/presentation/providers/message_template_provider.dart';
import 'package:flowpaisa/features/whatsapp/presentation/providers/whatsapp_provider.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flutter/services.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/features/dashboard/domain/dashboard_widget_models.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_widget_provider.dart';

class PayableDetailsDialog extends ConsumerWidget {
  final String payableUuid;

  const PayableDetailsDialog({
    super.key,
    required this.payableUuid,
  });

  bool _canEditPayable(Payable payable) {
    // Can edit only if PENDING and not linked to any transaction
    return payable.status == 'PENDING' &&
        payable.linkedExpenseUuid == null &&
        payable.linkedIncomeUuid == null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    final itemAsync = ref.watch(payableWithLinkedDataProvider(payableUuid));

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.payableDetails)),
            body: Center(child: Text(l10n.payableNotFound)),
          );
        }

        final payable = item.payable;
        final contact = item.contact;

        if (currency == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final linkedCategory = item.linkedCategory;
        final isPending = payable.status == 'PENDING';

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.payableDetails),
            actions: [
              Builder(
                builder: (context) {
                  ref.watch(dashboardWidgetLayoutProvider);
                  final notifier =
                      ref.read(dashboardWidgetLayoutProvider.notifier);
                  final isPinned = notifier.isPinned(
                      DashboardWidgetKind.payable, payable.uuid);
                  return IconButton(
                    icon: Icon(
                      isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: isPinned
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    tooltip:
                        isPinned ? l10n.unpinFromDashboard : l10n.pinToDashboard,
                    onPressed: () async {
                      if (isPinned) {
                        final layout = ref
                                .read(dashboardWidgetLayoutProvider)
                                .value ??
                            [];
                        final idx = layout.indexWhere((c) =>
                            c.kind == DashboardWidgetKind.payable &&
                            c.payableUuid == payable.uuid);
                        if (idx >= 0) {
                          await ref
                              .read(dashboardWidgetLayoutProvider.notifier)
                              .removeAt(idx);
                          if (context.mounted) {
                            ToastUtils.showSuccessToast(context, ref,
                                l10n.unpinnedFromDashboard);
                          }
                        }
                      } else {
                        await ref
                            .read(dashboardWidgetLayoutProvider.notifier)
                            .addWidget(DashboardWidgetConfig(
                                kind: DashboardWidgetKind.payable,
                                payableUuid: payable.uuid));
                        if (context.mounted) {
                          ToastUtils.showSuccessToast(
                              context, ref, l10n.pinnedToDashboard);
                        }
                      }
                    },
                  );
                },
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
                        '\u200E${AmountFormatter.formatWithCurrency(payable.amount, currency.symbol, currency.decimalPlaces)}',
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.link, color: Colors.white, size: 22),
                            tooltip: l10n.copyLink,
                            onPressed: () {
                              final link = DeepLinkService()
                                  .generateEntityOpenLinkHttps('payable', payable.uuid);
                              Clipboard.setData(ClipboardData(text: link));
                              ToastUtils.showSuccessToast(context, ref, l10n.linkCopied);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.white, size: 22),
                            tooltip: l10n.share,
                            onPressed: () {
                              final capturedCurrency = currency;
                              final capturedUserProfile = ref.read(userProfileProvider);
                              final capturedTransactionService =
                                  ref.read(transactionServiceProvider);
                              final capturedWhatsAppService =
                                  ref.read(whatsAppServiceProvider);
                              final capturedTemplateService =
                                  ref.read(messageTemplateServiceProvider);
                              final capturedLanguage = getCurrentLanguageCode(ref);
                              ShareHelper.sharePayable(
                                context,
                                ref,
                                payable,
                                contact,
                                currencyOverride: capturedCurrency,
                                userProfileOverride: capturedUserProfile,
                                transactionServiceOverride: capturedTransactionService,
                                whatsAppServiceOverride: capturedWhatsAppService,
                                templateServiceOverride: capturedTemplateService,
                                languageOverride: capturedLanguage,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white, size: 22),
                            tooltip: l10n.duplicate,
                            onPressed: () {
                              int dueDateOffset = 0;
                              if (payable.dueDate != null) {
                                dueDateOffset =
                                    payable.dueDate!.difference(payable.date).inDays;
                              }
                              final now = DateTime.now();
                              final initialDueDate = dueDateOffset != 0
                                  ? now.add(Duration(days: dueDateOffset))
                                  : null;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddPayableScreen(
                                    initialAmount: payable.amount,
                                    initialDate: now,
                                    initialDescription: payable.description,
                                    initialContactName: contact?.name,
                                    initialContactPhone: contact?.phone,
                                    initialDueDate: initialDueDate,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (_canEditPayable(payable))
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white, size: 22),
                              tooltip: l10n.editPayable,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditPayableScreen(payableUuid: payable.uuid),
                                  ),
                                );
                              },
                            ),
                          if (payable.status != 'PAID')
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white, size: 22),
                              tooltip: l10n.delete,
                              onPressed: () => _deletePayable(context, ref, payable.uuid),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Contact Header Section
                if (contact != null) ...[
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactDetailsScreen(
                            contactUuid: contact.uuid,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient:
                                  AppColors.getContactGradient(contact.name),
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
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        contact.phone!,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
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
                              icon: const Icon(Icons.chat,
                                  color: Color(0xFF25D366)),
                              onPressed: () {
                                final capturedCurrency = currency;
                                final capturedUserProfile =
                                    ref.read(userProfileProvider);
                                final capturedTransactionService =
                                    ref.read(transactionServiceProvider);
                                final capturedWhatsAppService =
                                    ref.read(whatsAppServiceProvider);
                                final capturedTemplateService =
                                    ref.read(messageTemplateServiceProvider);
                                final capturedLanguage =
                                    getCurrentLanguageCode(ref);

                                ShareHelper.sharePayable(
                                  context,
                                  ref,
                                  payable,
                                  contact,
                                  currencyOverride: capturedCurrency,
                                  userProfileOverride: capturedUserProfile,
                                  transactionServiceOverride:
                                      capturedTransactionService,
                                  whatsAppServiceOverride:
                                      capturedWhatsAppService,
                                  templateServiceOverride:
                                      capturedTemplateService,
                                  languageOverride: capturedLanguage,
                                );
                              },
                            ),
                        ],
                      ),
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

                if (payable.description != null &&
                    payable.description!.isNotEmpty)
                  _buildDetailRow(
                    context,
                    icon: Icons.description,
                    label: l10n.description,
                    value: payable.description!,
                  ),

                // Linked Transaction Section – show up to two cards if both links exist
                if (payable.linkedIncomeUuid != null ||
                    payable.linkedExpenseUuid != null) ...[
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
                  if (payable.linkedExpenseUuid != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildLinkedTransactionCardFromUuid(
                        context,
                        ref,
                        payable.linkedExpenseUuid!,
                      ),
                    ),
                  if (payable.linkedIncomeUuid != null)
                    _buildLinkedTransactionCardFromUuid(
                      context,
                      ref,
                      payable.linkedIncomeUuid!,
                    ),
                ],

                // Actions
                if (isPending) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _markAsPaid(context, ref, item),
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
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Scaffold(
        appBar: AppBar(title: Text(l10n.payableDetails)),
        body: Center(child: Text(l10n.errorOccurred(e.toString()))),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
                  if (transaction.isAutoGenerated == true) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.autoBadge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
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

  Widget _buildLinkedTransactionCardFromUuid(
    BuildContext context,
    WidgetRef ref,
    String transactionUuid,
  ) {
    final repository = ref.read(transactionsRepositoryProvider);
    return FutureBuilder<TransactionWithDetails?>(
      future: repository.getTransactionWithDetailsByUuid(transactionUuid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 72,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final details = snapshot.data;
        if (details == null) {
          return const SizedBox.shrink();
        }
        final transaction = details.transaction;
        final category = details.category;

        return InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => TransactionDetailsDialog(
                transactionUuid: transaction.uuid,
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: _buildLinkedTransactionCard(
            context,
            ref,
            transaction,
            category,
          ),
        );
      },
    );
  }

  Future<void> _deletePayable(
      BuildContext context, WidgetRef ref, String payableUuid) async {
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
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repository = ref.read(payablesRepositoryProvider);
        await repository.deletePayable(payableUuid);

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
    BuildContext context,
    WidgetRef ref,
    PayableWithLinkedData item,
  ) async {
    final payableUuid = item.payable.uuid;
    final l10n = AppLocalizations.of(context)!;
    final choice = await resolveSettlementAccountChoice(
      context,
      ref,
      isPayable: true,
      transactionForAccountDefault: item.linkedTransaction,
    );
    if (choice == null) return;

    try {
      final repository = ref.read(payablesRepositoryProvider);
      await repository.markAsPaid(
        payableUuid,
        accountUuid: choice.accountUuid,
      );

      if (context.mounted) {
        // Refresh item to get updated status and externalLinkId
        final updatedItem =
            await repository.getPayableWithLinkedDataByUuid(payableUuid);

        if (context.mounted) {
          final activeColor = ref.read(activeCashbookProvider).color;
          final currency = ref.read(currentCurrencyProvider).value!;
          final userProfile = ref.read(userProfileProvider);
          final transactionService = ref.read(transactionServiceProvider);
          final whatsAppService = ref.read(whatsAppServiceProvider);

          final capturedCurrency = currency;
          final capturedUserProfile = userProfile;
          final capturedTransactionService = transactionService;
          final capturedWhatsAppService = whatsAppService;

          ToastUtils.showSuccessToast(context, ref, l10n.markedAsPaid,
              color: activeColor);

          if (updatedItem != null) {
            _showSettlementShareOption(
              context,
              ref,
              updatedItem.payable,
              updatedItem.contact,
              activeColor: activeColor,
              currency: capturedCurrency,
              userProfile: capturedUserProfile,
              transactionService: capturedTransactionService,
              whatsAppService: capturedWhatsAppService,
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
    final capturedCurrency = currency;
    final capturedUserProfile = userProfile;
    final capturedTransactionService = transactionService;
    final capturedWhatsAppService = whatsAppService;
    final capturedTemplateService = ref.read(messageTemplateServiceProvider);
    final capturedLanguage = getCurrentLanguageCode(ref);

    ToastUtils.showSuccessToast(
      context,
      ref,
      l10n.informContactSettlementPayable,
      actionLabel: l10n.share,
      onActionPressed: (snackContext) {
        ShareHelper.sharePayable(
          snackContext,
          ref,
          payable,
          contact,
          currencyOverride: capturedCurrency,
          userProfileOverride: capturedUserProfile,
          transactionServiceOverride: capturedTransactionService,
          whatsAppServiceOverride: capturedWhatsAppService,
          templateServiceOverride: capturedTemplateService,
          languageOverride: capturedLanguage,
        );
      },
      color: activeColor,
    );
  }
}
