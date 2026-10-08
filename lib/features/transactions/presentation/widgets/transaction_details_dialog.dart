import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/edit_split_transaction_screen.dart';
import 'package:flowpaisa/features/payables/presentation/widgets/payable_details_dialog.dart';
import 'package:flowpaisa/features/receivables/presentation/widgets/receivable_details_dialog.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/contact_details_screen.dart';
import 'package:flowpaisa/features/categories/presentation/screens/category_details_screen.dart';
import 'package:flowpaisa/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/messages/presentation/providers/message_template_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/tabular_editor_sheet.dart';
import 'package:flowpaisa/core/utils/tabular_parser.dart';
import 'package:flowpaisa/core/database/database.dart' show Account, Category, Contact;
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/core/utils/share_helper.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/edit_transaction_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/splitted_transactions_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/utils/split_share_settled_label.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/linked_settlement_account_sheet.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/whatsapp/presentation/providers/whatsapp_provider.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flutter/services.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/features/dashboard/domain/dashboard_widget_models.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_widget_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_attachment_section.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

class TransactionDetailsDialog extends ConsumerWidget {
  final String transactionUuid;

  const TransactionDetailsDialog({
    super.key,
    required this.transactionUuid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    final itemAsync =
        ref.watch(transactionWithDetailsProvider(transactionUuid));
    final groupAsync = ref.watch(transactionGroupProvider(transactionUuid));
    final relatedAsync = ref.watch(relatedTransactionsProvider(transactionUuid));

    // Extract prefix for schedule lookup
    final match = RegExp(r'(.+)_(\d+)').firstMatch(transactionUuid);
    final prefix = match?.group(1);
    final scheduleAsync = prefix != null
        ? ref.watch(scheduleWithDetailsProvider(prefix))
        : const AsyncValue<ScheduleWithDetails?>.data(null);

    // Listen for changes to the group to ensure we refresh if needed
    // (StreamProvider already does this, but we want to be explicit)
    ref.listen(transactionGroupProvider(transactionUuid), (previous, next) {
      if (next is AsyncData && previous is AsyncData) {
        // Data updated
      }
    });

    return itemAsync.when(
      skipLoadingOnRefresh: true,
      data: (item) {
        if (item == null) {
          return Scaffold(
            key: const ValueKey('tx-details-not-found'),
            appBar: AppBar(title: Text(l10n.transactionDetails)),
            body: Center(
                child: Text(l10n.errorOccurred('Transaction not found'))),
          );
        }

        final transaction = item.transaction;
        final category = item.category;
        final contact = item.contact;
        final linkedPayable = item.linkedPayable;
        final linkedReceivable = item.linkedReceivable;
        final isExpense = transaction.type == 'EXPENSE';

        if (currency == null) {
          return const Center(key: ValueKey('tx-details-currency-loading'), child: CircularProgressIndicator());
        }

        return groupAsync.when(
          skipLoadingOnRefresh: true,
          data: (group) {
            final isSplitGroup = group.length > 1;
            return _buildContent(
              context,
              ref,
              item: item,
              transaction: transaction,
              category: category,
              contact: contact,
              linkedPayable: linkedPayable,
              linkedReceivable: linkedReceivable,
              isExpense: isExpense,
              currency: currency,
              group: group,
              isSplitGroup: isSplitGroup,
              relatedAsync: relatedAsync,
              scheduleAsync: scheduleAsync,
            );
          },
          loading: () => Scaffold(
            key: const ValueKey('tx-details-group-loading'),
            appBar: AppBar(title: Text(l10n.transactionDetails)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Scaffold(
            key: const ValueKey('tx-details-group-error'),
            appBar: AppBar(title: Text(l10n.transactionDetails)),
            body: Center(child: Text(l10n.errorOccurred(err.toString()))),
          ),
        );
      },
      loading: () => Scaffold(
        key: const ValueKey('tx-details-item-loading'),
        appBar: AppBar(title: Text(l10n.transactionDetails)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        key: const ValueKey('tx-details-item-error'),
        appBar: AppBar(title: Text(l10n.transactionDetails)),
        body: Center(child: Text(l10n.errorOccurred(err.toString()))),
      ),
    );
  }

  static Widget _buildContent(
    BuildContext context,
    WidgetRef ref, {
    required TransactionWithDetails item,
    required dynamic transaction,
    required dynamic category,
    required dynamic contact,
    required dynamic linkedPayable,
    required dynamic linkedReceivable,
    required bool isExpense,
    required dynamic currency,
    required List<TransactionWithDetails> group,
    required bool isSplitGroup,
    required AsyncValue<List<TransactionWithDetails>> relatedAsync,
    required AsyncValue<ScheduleWithDetails?> scheduleAsync,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final pr = transaction.paidRelationship as String?;
    String displayDesc = '';
    if (transaction.description != null && (transaction.description as String).isNotEmpty) {
      final descStr = transaction.description as String;
      final index = descStr.indexOf('\n[');
      displayDesc = index != -1 ? descStr.substring(0, index).trim() : descStr.trim();
    }

    return Scaffold(
      key: const ValueKey('tx-details-scaffold'),
      appBar: AppBar(
        key: const ValueKey('tx-details-appbar'),
        title: Text(l10n.transactionDetails),
        actions: [
          Builder(
            key: const ValueKey('tx-details-pin-builder'),
            builder: (context) {
              ref.watch(dashboardWidgetLayoutProvider);
              final notifier = ref.read(dashboardWidgetLayoutProvider.notifier);
              final isPinned = notifier.isPinned(
                  DashboardWidgetKind.transaction, transaction.uuid);
              return IconButton(
                key: const ValueKey('tx-details-pin-btn'),
                icon: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: isPinned
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                tooltip: isPinned
                    ? l10n.unpinFromDashboard
                    : l10n.pinToDashboard,
                onPressed: () async {
                  if (isPinned) {
                    final layout = ref.read(dashboardWidgetLayoutProvider).value ?? [];
                    final idx = layout.indexWhere((c) =>
                        c.kind == DashboardWidgetKind.transaction &&
                        c.transactionUuid == transaction.uuid);
                    if (idx >= 0) {
                      await ref
                          .read(dashboardWidgetLayoutProvider.notifier)
                          .removeAt(idx);
                      if (context.mounted) {
                        ToastUtils.showSuccessToast(
                            context, ref, l10n.unpinnedFromDashboard);
                      }
                    }
                  } else {
                    await ref.read(dashboardWidgetLayoutProvider.notifier).addWidget(
                        DashboardWidgetConfig(
                            kind: DashboardWidgetKind.transaction,
                            transactionUuid: transaction.uuid));
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
      body: SafeArea(
        key: const ValueKey('tx-details-safearea'),
        top: false,
        child: SingleChildScrollView(
          key: const ValueKey('tx-details-scrollview'),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            key: const ValueKey('tx-details-column'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Amount Card
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  key: const ValueKey('tx-details-amount-card'),
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
                    key: const ValueKey('tx-details-amount-column'),
                    children: [
                      Text(
                        key: const ValueKey('tx-details-type-label'),
                        isExpense ? l10n.expense : l10n.income,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        key: const ValueKey('tx-details-amount-text'),
                        '${isExpense ? '\u200E-' : '\u200E+'} ${AmountFormatter.formatWithCurrency(transaction.amount, currency)}',
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
                          key: const ValueKey('tx-details-status-badge'),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            key: const ValueKey('tx-details-status-row'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.isLinkedEntryMarked)
                                const Icon(
                                  key: ValueKey('tx-details-status-icon'),
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              if (item.isLinkedEntryMarked)
                                const SizedBox(width: 6),
                              Text(
                                key: const ValueKey('tx-details-status-text'),
                                _getStatusLabel(
                                    context,
                                    transaction.paidRelationship!,
                                    item.isLinkedEntryMarked,
                                    isExpense: isExpense,
                                ),
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
                      if (transaction.isNotSynced == true) ...[
                        const SizedBox(height: 12),
                        Container(
                          key: const ValueKey('tx-details-pending-sync-badge'),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            key: const ValueKey('tx-details-pending-sync-row'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.cloud_upload_outlined,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.changesToPush(1).replaceAll('1 ', ''),
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
                      if (transaction.isAutoGenerated) ...[
                        const SizedBox(height: 8),
                        Container(
                          key: const ValueKey('tx-details-auto-badge'),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            key: const ValueKey('tx-details-auto-row'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                key: ValueKey('tx-details-auto-icon'),
                                Icons.auto_awesome,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                key: const ValueKey('tx-details-auto-text'),
                                l10n.autoGenerated,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (transaction.isScheduled == true) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            key: const ValueKey('tx-details-reviewed-btn'),
                            onPressed: () =>
                                _markAsReviewed(context, ref, transaction.uuid),
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: Text(l10n.markAsReviewed),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                    color: Colors.white30, width: 1),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        key: const ValueKey('tx-details-actions-row'),
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            key: const ValueKey('tx-details-link-btn'),
                            icon: const Icon(Icons.link, color: Colors.white, size: 22),
                            tooltip: l10n.copyLink,
                            onPressed: () {
                              final link = DeepLinkService().generateEntityOpenLinkHttps(
                                  'transaction', transaction.uuid);
                              Clipboard.setData(ClipboardData(text: link));
                              ToastUtils.showSuccessToast(context, ref, l10n.linkCopied);
                            },
                          ),
                          if (transaction.isAutoGenerated != true)
                            IconButton(
                              key: const ValueKey('tx-details-share-btn'),
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
                                ShareHelper.shareTransaction(
                                  context,
                                  ref,
                                  transaction,
                                  contact,
                                  category,
                                  item.isLinkedEntryMarked,
                                  currencyOverride: capturedCurrency,
                                  userProfileOverride: capturedUserProfile,
                                  transactionServiceOverride: capturedTransactionService,
                                  whatsAppServiceOverride: capturedWhatsAppService,
                                  templateServiceOverride: capturedTemplateService,
                                  languageOverride: capturedLanguage,
                                  forceSystemShare: true,
                                );
                              },
                            ),
                          if (transaction.isAutoGenerated != true)
                            IconButton(
                              key: const ValueKey('tx-details-duplicate-btn'),
                              icon: const Icon(Icons.copy, color: Colors.white, size: 22),
                              tooltip: l10n.duplicate,
                              onPressed: () {
                                int dueDateOffset = 0;
                                if (linkedPayable?.dueDate != null) {
                                  dueDateOffset = linkedPayable!.dueDate!
                                      .difference(transaction.date)
                                      .inDays;
                                } else if (linkedReceivable?.dueDate != null) {
                                  dueDateOffset = linkedReceivable!.dueDate!
                                      .difference(transaction.date)
                                      .inDays;
                                }
                                final now = DateTime.now();
                                final initialDueDate = dueDateOffset != 0
                                    ? now.add(Duration(days: dueDateOffset))
                                    : null;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddTransactionScreen(
                                      initialAmount: transaction.amount,
                                      initialDate: now,
                                      initialDescription: transaction.description,
                                      initialType: transaction.type,
                                      initialRelationship: transaction.paidRelationship,
                                      initialCategoryName: category?.name,
                                      initialCategoryColor: category?.color,
                                      initialCategoryIcon: category?.icon,
                                      initialContactName: contact?.name,
                                      initialContactPhone: contact?.phone,
                                      initialAccountUuid: item.account?.uuid,
                                      initialDueDate: initialDueDate,
                                    ),
                                  ),
                                );
                              },
                            ),
                          if (!item.isLinkedEntryMarked && transaction.isAutoGenerated != true)
                            IconButton(
                              key: const ValueKey('tx-details-edit-btn'),
                              icon: const Icon(Icons.edit, color: Colors.white, size: 22),
                              tooltip: l10n.editTransaction,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTransactionScreen(
                                      transaction: transaction,
                                      category: category,
                                      contact: contact,
                                      account: item.account,
                                    ),
                                  ),
                                );
                              },
                            ),
                          if (!item.isLinkedEntryMarked && transaction.isAutoGenerated != true)
                            IconButton(
                              key: const ValueKey('tx-details-delete-btn'),
                              icon: const Icon(Icons.delete, color: Colors.white, size: 22),
                              tooltip: l10n.delete,
                              onPressed: () =>
                                  _deleteTransaction(context, ref, transaction.uuid),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (transaction.isNotSynced == true)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),


            if (linkedPayable != null) ...[
              Material(
                key: const ValueKey('tx-details-payable-material'),
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('tx-details-payable-inkwell'),
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => PayableDetailsDialog(
                        payableUuid: linkedPayable.uuid,
                      ),
                    );
                  },
                  child: _buildLinkedPayableCard(
                    context,
                    ref,
                    linkedPayable,
                    item,
                    transaction,
                    currency,
                    contact: contact as Contact?,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (linkedReceivable != null) ...[
              Material(
                key: const ValueKey('tx-details-receivable-material'),
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('tx-details-receivable-inkwell'),
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => ReceivableDetailsDialog(
                        receivableUuid: linkedReceivable.uuid,
                      ),
                    );
                  },
                  child: _buildLinkedReceivableCard(
                    context,
                    ref,
                    linkedReceivable,
                    item,
                    transaction,
                    currency,
                    contact: contact as Contact?,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (linkedPayable == null &&
                linkedReceivable == null &&
                pr != null &&
                (pr == 'PAID_FOR' ||
                    pr == 'WILL_RECEIVE' ||
                    pr == 'PAID_BY' ||
                    pr == 'RECEIVED_FROM')) ...[
              _buildTxRelationshipCard(
                context,
                theme,
                l10n,
                ref,
                transaction,
                currency,
                item,
                isReceivable: pr == 'PAID_FOR' || pr == 'WILL_RECEIVE',
                contact: contact as Contact?,
              ),
              const SizedBox(height: 16),
            ],
            if (pr == 'PROCESSED') ...[
              Column(
                key: const ValueKey('tx-details-processed-col'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTxProcessedCard(
                    context,
                    theme,
                    l10n,
                    ref,
                    transaction,
                    currency,
                    item,
                    isExpense: isExpense,
                    contact: contact as Contact?,
                  ),
                  if (transaction.processedDate == null &&
                      linkedPayable == null &&
                      linkedReceivable == null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const ValueKey('tx-details-mark-processed-btn'),
                        onPressed: () async {
                          final choice = await resolveSettlementAccountChoice(
                            context,
                            ref,
                            isPayable: isExpense,
                            initialAccount: item.account,
                            transactionForAccountDefault: transaction,
                          );
                          if (choice == null) return;

                          try {
                            if (choice.accountUuid != null) {
                              await ref
                                  .read(transactionServiceProvider)
                                  .updateTransactionAccount(transaction.uuid, choice.accountUuid);
                            }
                            await ref
                                .read(transactionServiceProvider)
                                .markAsProcessed(transaction.uuid);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ToastUtils.showErrorToast(
                                  context, ref, l10n.errorOccurred(e.toString()));
                            }
                          }
                        },
                        icon: const Icon(Icons.check_circle),
                        label: Text(
                          isExpense ? l10n.markAsPaid : l10n.markAsReceived,
                        ),
                        style: isExpense
                            ? AppColors.transactionMarkAsPaidFilledStyle()
                            : AppColors.transactionMarkAsReceivedFilledStyle(),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (category != null) ...[
              _buildTxCategoryCard(
                context,
                theme,
                l10n,
                category: category as Category,
                isExpense: isExpense,
              ),
              const SizedBox(height: 16),
            ],
            if (item.account != null) ...[
              _buildTxAccountCard(
                context,
                theme,
                l10n,
                account: item.account!,
                onEdit: () => _changeAccount(context, ref, item),
              ),
              const SizedBox(height: 16),
            ] else ...[
              _buildNoAccountCard(
                context,
                theme,
                l10n,
                onSet: () => _changeAccount(context, ref, item),
              ),
              const SizedBox(height: 16),
            ],

            _buildSectionCard(
              context,
              key: const ValueKey('tx-details-info-section'),
              title: l10n.information,
              titleIcon: Icons.info_outline,
              body: Column(
                key: const ValueKey('tx-details-info-column'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (contact != null) ...[
                    _buildDetailRow(
                      context,
                      key: const ValueKey('tx-details-contact-row'),
                      icon: Icons.person_outline,
                      label: l10n.contact,
                      value: contact.name,
                      trailing: IconButton(
                        key: const ValueKey('tx-details-contact-btn'),
                        icon: Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContactDetailsScreen(
                                contactUuid: contact.uuid,
                              ),
                            ),
                          );
                        },
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  _buildDetailRow(
                    context,
                    key: const ValueKey('tx-details-date-row'),
                    icon: Icons.calendar_today_outlined,
                    label: l10n.date,
                    value: AppDateFormatter.formatDate(transaction.date,
                        pattern: ref.watch(userProfileProvider).dateFormat),
                  ),
                  _buildDetailRow(
                    context,
                    key: const ValueKey('tx-details-desc-row'),
                    icon: Icons.notes_outlined,
                    label: l10n.description,
                    value: displayDesc.trim().isNotEmpty ? displayDesc : l10n.none,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _editDescriptionDialog(
                        context,
                        ref,
                        transaction.uuid,
                        transaction.description as String? ?? '',
                      ),
                    ),
                  ),
                  if (transaction.processedDate != null)
                    _buildDetailRow(
                      context,
                      key: const ValueKey('tx-details-processed-date-row'),
                      icon: Icons.check_circle_outline,
                      label: isExpense
                          ? l10n.paidOnRowLabel
                          : l10n.receivedOnRowLabel,
                      value: AppDateFormatter.formatDate(
                          transaction.processedDate!,
                          pattern: ref.watch(userProfileProvider).dateFormat),
                    ),
                  if (transaction.processedDate == null &&
                      linkedPayable == null &&
                      linkedReceivable == null &&
                      pr != 'PROCESSED') ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: const ValueKey('tx-details-mark-processed-outlined-btn'),
                      onPressed: () async {
                        final choice = await resolveSettlementAccountChoice(
                          context,
                          ref,
                          isPayable: isExpense,
                          initialAccount: item.account,
                          transactionForAccountDefault: transaction,
                        );
                        if (choice == null) return;

                        try {
                          if (choice.accountUuid != null) {
                            await ref
                                .read(transactionServiceProvider)
                                .updateTransactionAccount(transaction.uuid, choice.accountUuid);
                          }
                          await ref
                              .read(transactionServiceProvider)
                              .markAsProcessed(transaction.uuid);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ToastUtils.showErrorToast(
                                context, ref, l10n.errorOccurred(e.toString()));
                          }
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(
                        isExpense ? l10n.markAsPaid : l10n.markAsReceived,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isExpense
                            ? AppColors.expenseColor
                            : AppColors.incomeColor,
                        side: BorderSide(
                          color: isExpense
                              ? AppColors.expenseColor
                              : AppColors.incomeColor,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ],
            ),
          ),
          const SizedBox(height: 16),

          // Attachments Section
          ref.watch(transactionDocumentsProvider(transaction.uuid)).when(
                data: (docs) {
                  return FutureBuilder<Directory>(
                    future: ref.read(transactionDocumentsRepositoryProvider).getDocumentsDirectory(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final docDir = snapshot.data!;
                      final attachments = docs.map((doc) => AttachmentItem(
                        uuid: doc.uuid,
                        file: File(p.join(docDir.path, doc.fileName)),
                        originalName: doc.originalName,
                        mimeType: doc.mimeType ?? 'application/octet-stream',
                        fileSize: doc.fileSize,
                      )).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: TransactionAttachmentSection(
                              attachments: attachments,
                              onAddMultiple: (items) async {
                                final docRepo = ref.read(transactionDocumentsRepositoryProvider);
                                for (final item in items) {
                                  await docRepo.addDocument(
                                    transactionUuid: transaction.uuid,
                                    file: item.file,
                                    originalName: item.originalName,
                                    mimeType: item.mimeType,
                                  );
                                }
                              },
                              onDelete: (index) async {
                                final item = attachments[index];
                                if (item.uuid != null) {
                                  final docRepo = ref.read(transactionDocumentsRepositoryProvider);
                                  await docRepo.deleteDocument(item.uuid!);
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

          if (ref.watch(premiumProvider).isPremium) ...[
            if (transaction.description != null &&
                TabularParser.isTabular(transaction.description)) ...[
              const SizedBox(height: 16),
              buildTabularDataSection(
                context,
                theme,
                l10n,
                transaction.description!,
                currency,
                onEdit: !item.isLinkedEntryMarked &&
                        transaction.isAutoGenerated != true
                    ? () => _editTabularDetails(context, ref, item, currency)
                    : null,
              ),
            ] else if (!item.isLinkedEntryMarked &&
                transaction.isAutoGenerated != true) ...[
              const SizedBox(height: 16),
              _buildAddItemizedDetailsButton(context, ref, item, currency, theme, l10n),
            ],
          ],

            if (kDebugMode) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: const ValueKey('tx-details-debug-tile'),
                  title: const Text(
                    "DEBUG INFO",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  leading: const Icon(Icons.bug_report, color: Colors.red),
                  childrenPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  expandedAlignment: Alignment.topLeft,
                  children: [
                    _buildDebugInfo(
                        context, "Transaction UUID", transaction.uuid),
                    _buildDebugInfo(context, "External Link ID",
                        transaction.externalLinkId ?? "None"),
                    _buildDebugInfo(context, "Is Scheduled",
                        transaction.isScheduled.toString()),
                    _buildDebugInfo(context, "Is Not Synced",
                        transaction.isNotSynced.toString()),
                    if (linkedPayable != null) ...[
                      const SizedBox(height: 12),
                      const Text("Linked Payable:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                      _buildDebugInfo(context, "UUID", linkedPayable.uuid),
                      _buildDebugInfo(context, "External Link ID",
                          linkedPayable.externalLinkId ?? "None"),
                      _buildDebugInfo(context, "Is Scheduled",
                          linkedPayable.isScheduled.toString()),
                      _buildDebugInfo(context, "Is Not Synced",
                          linkedPayable.isNotSynced.toString()),
                    ],
                    if (linkedReceivable != null) ...[
                      const SizedBox(height: 12),
                      const Text("Linked Receivable:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                      _buildDebugInfo(context, "UUID", linkedReceivable.uuid),
                      _buildDebugInfo(context, "External Link ID",
                          linkedReceivable.externalLinkId ?? "None"),
                      _buildDebugInfo(context, "Is Scheduled",
                          linkedReceivable.isScheduled.toString()),
                      _buildDebugInfo(context, "Is Not Synced",
                          linkedReceivable.isNotSynced.toString()),
                    ],
                  ],
                ),
              ),
            ],

          relatedAsync.when(
            data: (related) {
              if (related.length <= 1) return const SizedBox.shrink();
              
              // Sort chronologically (earlier to later)
              final sortedRelated = [...related]..sort((a, b) => a.transaction.date.compareTo(b.transaction.date));

              // Calculate summary
              double totalAmount = 0;
              double processedAmount = 0;
              double pendingAmount = 0;
              double settledAmount = 0;
              String? relationship;

              for (final item in related) {
                final amt = item.transaction.amount;
                totalAmount += amt;
                if (item.transaction.processedDate != null) {
                  processedAmount += amt;
                } else {
                  pendingAmount += amt;
                }
                if (item.isLinkedEntryMarked) {
                  settledAmount += amt;
                }
                relationship ??= item.transaction.paidRelationship;
              }

              final isReceivableScenario =
                  relationship == 'PAID_FOR' || relationship == 'WILL_RECEIVE';
              final isPayableScenario =
                  relationship == 'PAID_BY' || relationship == 'RECEIVED_FROM';
              final isLinked = isReceivableScenario || isPayableScenario;
              final isMobilePortrait = MediaQuery.of(context).size.width < 600 &&
                  MediaQuery.of(context).orientation == Orientation.portrait;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Summary Row
                  if (isLinked)
                    isMobilePortrait
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSummaryTile(
                                      context,
                                      label: l10n.totalAmount,
                                      amount: totalAmount,
                                      color: isExpense
                                          ? AppColors.expenseColor
                                          : AppColors.incomeColor,
                                      currency: currency,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildSummaryTile(
                                      context,
                                      label: isExpense ? l10n.statusPaid : l10n.statusReceived,
                                      amount: processedAmount,
                                      color: AppColors.success,
                                      currency: currency,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSummaryTile(
                                      context,
                                      label: isExpense ? l10n.statusReceived : l10n.statusPaid,
                                      amount: settledAmount,
                                      color: isExpense
                                          ? AppColors.incomeColor
                                          : AppColors.expenseColor,
                                      currency: currency,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildSummaryTile(
                                      context,
                                      label: isExpense
                                          ? l10n.receivableTag
                                          : l10n.payableTag,
                                      amount: (processedAmount - settledAmount).abs(),
                                      color: AppColors.payableColor,
                                      currency: currency,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _buildSummaryTile(
                                  context,
                                  label: l10n.totalAmount,
                                  amount: totalAmount,
                                  color: isExpense
                                      ? AppColors.expenseColor
                                      : AppColors.incomeColor,
                                  currency: currency,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _buildSummaryTile(
                                  context,
                                  label: isExpense ? l10n.statusPaid : l10n.statusReceived,
                                  amount: processedAmount,
                                  color: AppColors.success,
                                  currency: currency,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _buildSummaryTile(
                                  context,
                                  label: isExpense ? l10n.statusReceived : l10n.statusPaid,
                                  amount: settledAmount,
                                  color: isExpense
                                      ? AppColors.incomeColor
                                      : AppColors.expenseColor,
                                  currency: currency,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _buildSummaryTile(
                                  context,
                                  label: isExpense
                                      ? l10n.receivableTag
                                      : l10n.payableTag,
                                  amount: (processedAmount - settledAmount).abs(),
                                  color: AppColors.payableColor,
                                  currency: currency,
                                ),
                              ),
                            ],
                          )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryTile(
                            context,
                            label: l10n.totalAmount,
                            amount: totalAmount,
                            color: isExpense
                                ? AppColors.expenseColor
                                : AppColors.incomeColor,
                            currency: currency,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSummaryTile(
                            context,
                            label: isExpense ? l10n.statusPaid : l10n.statusReceived,
                            amount: processedAmount,
                            color: AppColors.success,
                            currency: currency,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSummaryTile(
                            context,
                            label: l10n.statusPending,
                            amount: pendingAmount,
                            color: AppColors.payableColor,
                            currency: currency,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  ...sortedRelated.where((relItem) => relItem.transaction.isAutoGenerated != true).map((relItem) {
                      final isCurrent = relItem.transaction.uuid == transaction.uuid;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TransactionListItem(
                          item: relItem,
                          isCompact: true,
                          isHighlighted: isCurrent,
                          titleOverride: AppDateFormatter.formatDate(
                            relItem.transaction.date,
                            pattern: ref.watch(userProfileProvider).dateFormat,
                          ),
                          leadingOverride: scheduleAsync.when(
                            data: (sched) {
                              final isMonthly = sched?.schedule.scheduleType == 'MONTHLY';
                              final text = isMonthly
                                  ? AppDateFormatter.formatMonth(relItem.transaction.date)
                                  : relItem.transaction.date.day.toString();

                              // Resolve category color for avatar background
                              Color avatarColor;
                              final relCat = relItem.category;
                              if (relCat?.color != null) {
                                try {
                                  avatarColor = Color(int.parse(relCat!.color!.replaceAll('#', '0xFF')));
                                } catch (_) {
                                  avatarColor = relItem.transaction.type == 'EXPENSE'
                                      ? AppColors.expenseColor
                                      : AppColors.incomeColor;
                                }
                              } else {
                                avatarColor = relItem.transaction.type == 'EXPENSE'
                                    ? AppColors.expenseColor
                                    : AppColors.incomeColor;
                              }

                              return Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: avatarColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: avatarColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  text,
                                  style: TextStyle(
                                    color: avatarColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMonthly ? 10 : 14,
                                  ),
                                ),
                              );
                            },
                            loading: () => const SizedBox(width: 40, height: 40),
                            error: (_, __) => const SizedBox(width: 40, height: 40),
                          ),
                          onTap: isCurrent ? null : () {
                            showDialog(
                              context: context,
                              builder: (context) => TransactionDetailsDialog(
                                transactionUuid: relItem.transaction.uuid,
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

          if (isSplitGroup) ...[
            Builder(
              builder: (context) {
                // Sort with user's share first (where contactUuid is null), and then alphabetically by contact name
                final sortedGroup = [...group]..sort((a, b) {
                    if (a.transaction.contactUuid == null && b.transaction.contactUuid != null) return -1;
                    if (a.transaction.contactUuid != null && b.transaction.contactUuid == null) return 1;
                    final nameA = a.contact?.name ?? '';
                    final nameB = b.contact?.name ?? '';
                    return nameA.compareTo(nameB);
                  });

                // Calculate split group metrics
                double totalAmount = 0;
                double settledAmount = 0;
                double pendingAmount = 0;

                for (final sibling in group) {
                  final amt = sibling.transaction.amount;
                  totalAmount += amt;
                  final linkedPayable = sibling.linkedPayable;
                  final linkedReceivable = sibling.linkedReceivable;
                  final isSettled = linkedPayable != null
                      ? (linkedPayable.status == 'PAID')
                      : linkedReceivable != null
                          ? (linkedReceivable.status == 'RECEIVED')
                          : (sibling.transaction.processedDate != null);
                  if (isSettled) {
                    settledAmount += amt;
                  } else {
                    pendingAmount += amt;
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Splitted Bill section header with edit button right above the summary row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.people_outline, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              l10n.splittedBill,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          key: const ValueKey('tx-details-split-edit-btn'),
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditSplitTransactionScreen(
                                  transactionUuid: transaction.uuid,
                                ),
                              ),
                            );
                          },
                          tooltip: l10n.editTransaction,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Summary Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryTile(
                            context,
                            label: l10n.totalAmount,
                            amount: totalAmount,
                            color: isExpense
                                ? AppColors.expenseColor
                                : AppColors.incomeColor,
                            currency: currency,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSummaryTile(
                            context,
                            label: l10n.statusCompleted,
                            amount: settledAmount,
                            color: AppColors.success,
                            currency: currency,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSummaryTile(
                            context,
                            label: l10n.statusPending,
                            amount: pendingAmount,
                            color: Colors.orange,
                            currency: currency,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...sortedGroup.map((sibling) {
                      final isCurrent = sibling.transaction.uuid == transaction.uuid;
                      final isUserShare = sibling.transaction.contactUuid == null;
                      final label = isUserShare ? l10n.me : (sibling.contact?.name ?? '');
                      final linkedPayable = sibling.linkedPayable;
                      final linkedReceivable = sibling.linkedReceivable;
                      final isSettled = linkedPayable != null
                          ? (linkedPayable.status == 'PAID')
                          : linkedReceivable != null
                              ? (linkedReceivable.status == 'RECEIVED')
                              : (sibling.transaction.processedDate != null);
                      final settledLineLabel = splitShareSettledStatusLabel(l10n, linkedPayable, linkedReceivable);
                      final canMarkPaid = linkedPayable != null && linkedPayable.status == 'PENDING';
                      final canMarkReceived = linkedReceivable != null && linkedReceivable.status == 'PENDING';

                      // Determine status chip text and color
                      final String? chipText;
                      final Color? chipColor;
                      if (isSettled) {
                        if (linkedPayable != null) {
                          chipText = l10n.paid;
                          chipColor = AppColors.success;
                        } else if (linkedReceivable != null) {
                          chipText = l10n.receivedLabel;
                          chipColor = AppColors.success;
                        } else {
                          chipText = l10n.statusCompleted;
                          chipColor = AppColors.success;
                        }
                      } else if (sibling.transaction.paidRelationship != null) {
                        chipText = LocalizationHelper.localizeRelationshipShort(
                          l10n,
                          sibling.transaction.paidRelationship!,
                          isExpense: sibling.transaction.type == 'EXPENSE',
                        );
                        chipColor = AppColors.getRelationshipColor(sibling.transaction.paidRelationship!);
                      } else {
                        chipText = null;
                        chipColor = null;
                      }

                      // Determine contact/label color for avatar background
                      final avatarColor = AppColors.getContactColor(label);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: isCurrent
                              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.15)
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: isCurrent
                                ? null
                                : () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => TransactionDetailsDialog(
                                        transactionUuid: sibling.transaction.uuid,
                                      ),
                                    );
                                  },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isCurrent
                                      ? theme.colorScheme.primary.withValues(alpha: 0.4)
                                      : isSettled
                                          ? theme.colorScheme.primary.withValues(alpha: 0.15)
                                          : theme.dividerColor.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: avatarColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: avatarColor.withValues(alpha: 0.3),
                                                width: 1,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              label.isNotEmpty ? label[0].toUpperCase() : '?',
                                              style: TextStyle(
                                                color: avatarColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          if (sibling.transaction.isNotSynced == true)
                                            Positioned(
                                              right: -3,
                                              bottom: -3,
                                              child: Container(
                                                padding: const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  color: theme.cardColor,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.15),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 1),
                                                    ),
                                                  ],
                                                  border: Border.all(
                                                    color: Colors.orange.withValues(alpha: 0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.cloud_upload_outlined,
                                                  size: 10,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  label,
                                                  style: theme.textTheme.bodyLarge?.copyWith(
                                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                                  ),
                                                ),
                                                if (chipText != null && chipColor != null) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: chipColor.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(4),
                                                      border: Border.all(
                                                        color: chipColor.withValues(alpha: 0.3),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        if (isSettled) ...[
                                                          Icon(
                                                            Icons.check,
                                                            size: 10,
                                                            color: chipColor,
                                                          ),
                                                          const SizedBox(width: 4),
                                                        ],
                                                        Text(
                                                          chipText,
                                                          style: theme.textTheme.labelSmall?.copyWith(
                                                            color: chipColor,
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 8,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            // Don't show settled text explicitly anymore as requested; the status is updated in the chip
                                            if (settledLineLabel != null && !isSettled) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                settledLineLabel,
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: theme.colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Text(
                                        AmountFormatter.formatWithCurrency(
                                          sibling.transaction.amount,
                                          currency,
                                        ),
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isCurrent ? theme.colorScheme.primary : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (canMarkPaid || canMarkReceived) ...[
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 38,
                                      child: FilledButton.icon(
                                        onPressed: () async {
                                          if (canMarkPaid) {
                                            await markAsPaid(context, ref, linkedPayable.uuid, sibling);
                                          } else if (canMarkReceived) {
                                            await markAsReceived(context, ref, linkedReceivable.uuid, sibling);
                                          }
                                        },
                                        icon: const Icon(Icons.check_circle, size: 16),
                                        label: Text(
                                          canMarkPaid ? l10n.markAsPaid : l10n.markAsReceived,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        style: canMarkPaid
                                            ? AppColors.transactionMarkAsPaidFilledStyle()
                                            : AppColors.transactionMarkAsReceivedFilledStyle(),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ],
          ],
        ),
      ),
    ),
  );
}

  /// Theme-aware pill for itemized amount / quantity summaries.
  static (Color, Color) _tabularBadgeColors(ThemeData theme, bool forAmount) {
    final scheme = theme.colorScheme;
    if (forAmount) {
      return (scheme.primaryContainer, scheme.onPrimaryContainer);
    }
    return (scheme.tertiaryContainer, scheme.onTertiaryContainer);
  }

  static Widget _tabularMetricBadge(
    ThemeData theme, {
    IconData? icon,
    required String text,
    required bool forAmount,
    TextDirection? textDirection,
    /// Header totals keep icons; per-line amount badge is text-only.
    bool showIcon = true,
  }) {
    final (bg, fg) = _tabularBadgeColors(theme, forAmount);
    final outlineAlpha = theme.brightness == Brightness.dark ? 0.32 : 0.16;
    const iconSize = 14.0;
    const hPad = 8.0;
    const vPad = 4.0;
    final textStyle = theme.textTheme.labelMedium?.copyWith(
      color: fg,
      fontWeight: FontWeight.w600,
      height: 1.2,
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: outlineAlpha),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && icon != null) ...[
            Icon(icon, size: iconSize, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: textStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textDirection: textDirection,
          ),
        ],
      ),
    );
  }

  static Widget buildTabularDataSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    String description,
    dynamic currency, {
    VoidCallback? onEdit,
  }) {
    return TabularDataSectionWidget(
      description: description,
      currency: currency,
      onEdit: onEdit,
    );
  }

  /// Section shell (schedule / account-detail style).
  static Widget _buildSummaryTile(
    BuildContext context, {
    required String label,
    required double amount,
    required Color color,
    required dynamic currency,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AmountFormatter.formatWithCurrency(
                  amount, currency),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }


  static Widget _buildSectionCard(
    BuildContext context, {
    Key? key,
    required String title,
    required IconData titleIcon,
    Color? accentColor,
    Widget? titleTrailing,
    required Widget body,
    bool useScheduleDateRangeStyle = false,
  }) {
    final theme = Theme.of(context);
    final accent = accentColor ?? theme.colorScheme.primary;
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: useScheduleDateRangeStyle
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                  theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            )
          : BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
      child: Column(
        key: key != null ? ValueKey('${(key as ValueKey).value}-column') : null,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            key: key != null ? ValueKey('${(key as ValueKey).value}-header') : null,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                key: key != null ? ValueKey('${(key as ValueKey).value}-icon-container') : null,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: useScheduleDateRangeStyle
                      ? theme.colorScheme.primaryContainer
                      : accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  titleIcon,
                  size: 24,
                  color: useScheduleDateRangeStyle
                      ? theme.colorScheme.onPrimaryContainer
                      : accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  key: key != null ? ValueKey('${(key as ValueKey).value}-title') : null,
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (titleTrailing != null) titleTrailing,
            ],
          ),
          const SizedBox(height: 20),
          body,
        ],
      ),
    );
  }

  /// Schedule details–style receivable / payable card.
  static Widget _buildTxRelationshipCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    WidgetRef ref,
    dynamic transaction,
    dynamic currency,
    TransactionWithDetails item, {
    required bool isReceivable,
    Contact? contact,
  }) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final color = isReceivable
        ? AppColors.receivableColor
        : AppColors.payableColor;
    final label = isReceivable ? l10n.receivable : l10n.payable;
    final keyPrefix = isReceivable ? 'receivable' : 'payable';
    final isPending = !(item.isLinkedEntryMarked ?? false);

    return Container(
      key: ValueKey('tx-details-$keyPrefix-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDarkMode ? 0.12 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        key: ValueKey('tx-details-$keyPrefix-column'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            key: ValueKey('tx-details-$keyPrefix-header'),
            children: [
              Container(
                key: ValueKey('tx-details-$keyPrefix-icon-container'),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isReceivable ? Icons.call_received : Icons.call_made,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key: ValueKey('tx-details-$keyPrefix-label'),
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isPending
                      ? Colors.amber.withValues(alpha: 0.12)
                      : AppColors.successGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isPending
                        ? Colors.amber.withValues(alpha: 0.3)
                        : AppColors.successGreen.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      isPending ? Icons.schedule_rounded : Icons.check_circle_rounded,
                      color: isPending ? (Colors.amber[800] ?? Colors.amber) : AppColors.successGreen,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPending ? l10n.pending : (isReceivable ? l10n.received : l10n.paid),
                      style: TextStyle(
                        color: isPending ? (Colors.amber[800] ?? Colors.amber) : AppColors.successGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (contact != null) ...[
            const SizedBox(height: 16),
            Divider(color: theme.dividerColor.withValues(alpha: 0.4), height: 1),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.getContactColor(contact.name).withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
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
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      key: ValueKey('tx-details-$keyPrefix-contact-avatar'),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.getContactGradient(contact.name),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        contact.name.isNotEmpty
                            ? contact.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            key: ValueKey('tx-details-$keyPrefix-contact-name'),
                            contact.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (contact.phone != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              key: ValueKey('tx-details-$keyPrefix-contact-phone-text'),
                              contact.phone!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (contact.phone != null && transaction.isAutoGenerated != true)
                    IconButton(
                      key: ValueKey('tx-details-$keyPrefix-message-btn'),
                      onPressed: () {
                        ShareHelper.shareTransaction(
                          context,
                          ref,
                          transaction,
                          contact,
                          item.category,
                          item.isLinkedEntryMarked,
                          currencyOverride: currency,
                          userProfileOverride: ref.read(userProfileProvider),
                          transactionServiceOverride:
                              ref.read(transactionServiceProvider),
                          whatsAppServiceOverride:
                              ref.read(whatsAppServiceProvider),
                          templateServiceOverride:
                              ref.read(messageTemplateServiceProvider),
                          languageOverride: getCurrentLanguageCode(ref),
                        );
                      },
                      icon: const Icon(Icons.chat, color: Color(0xFF25D366), size: 20),
                      tooltip: l10n.sendMessage,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.12),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildTxProcessedCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    WidgetRef ref,
    dynamic transaction,
    dynamic currency,
    TransactionWithDetails item, {
    required bool isExpense,
    Contact? contact,
  }) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final color = theme.colorScheme.primary;
    return Container(
      key: const ValueKey('tx-details-processed-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: isDarkMode ? 0.15 : 0.08),
            color.withValues(alpha: isDarkMode ? 0.06 : 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDarkMode ? 0.12 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        key: const ValueKey('tx-details-processed-column'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            key: const ValueKey('tx-details-processed-header'),
            children: [
              Container(
                key: const ValueKey('tx-details-processed-icon-container'),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  key: const ValueKey('tx-details-processed-info'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      key: const ValueKey('tx-details-processed-label'),
                      isExpense ? l10n.markAsPaid : l10n.markAsReceived,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      key: const ValueKey('tx-details-processed-desc'),
                      isExpense
                          ? l10n.processedImmediately
                          : l10n.receivedImmediately,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (contact != null) ...[
            const SizedBox(height: 16),
            Material(
              key: const ValueKey('tx-details-processed-contact-material'),
              color: Colors.transparent,
              child: InkWell(
                key: const ValueKey('tx-details-processed-contact-inkwell'),
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
                  key: const ValueKey('tx-details-processed-contact-padding'),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    key: const ValueKey('tx-details-processed-contact-row'),
                    children: [
                      Container(
                        key: const ValueKey('tx-details-processed-contact-avatar'),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.getContactGradient(contact.name),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.getContactColor(contact.name)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          key: const ValueKey('tx-details-processed-contact-info-col'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              key: const ValueKey('tx-details-processed-contact-name'),
                              contact.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (contact.phone != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                key: const ValueKey('tx-details-processed-contact-phone-row'),
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    key: const ValueKey('tx-details-processed-contact-phone-text'),
                                    contact.phone!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (contact.phone != null && transaction.isAutoGenerated != true) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const ValueKey('tx-details-processed-message-btn'),
                  onPressed: () {
                    ShareHelper.shareTransaction(
                      context,
                      ref,
                      transaction,
                      contact,
                      item.category,
                      item.isLinkedEntryMarked,
                      currencyOverride: currency,
                      userProfileOverride: ref.read(userProfileProvider),
                      transactionServiceOverride:
                          ref.read(transactionServiceProvider),
                      whatsAppServiceOverride:
                          ref.read(whatsAppServiceProvider),
                      templateServiceOverride:
                          ref.read(messageTemplateServiceProvider),
                      languageOverride: getCurrentLanguageCode(ref),
                    );
                  },
                  icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                  label: Text(l10n.sendMessage),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF25D366),
                    side: const BorderSide(color: Color(0xFF25D366)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  static Widget _buildTxContactCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    WidgetRef ref,
    Contact contact,
    dynamic transaction,
    dynamic category,
    TransactionWithDetails item,
    dynamic currency,
  ) {
    return const SizedBox.shrink();
  }

  static Widget _buildTxCategoryCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n, {
    required Category category,
    required bool isExpense,
  }) {
    final color = category.color != null
        ? Color(int.parse(category.color!.replaceAll('#', '0xFF')))
        : (isExpense ? AppColors.expenseColor : AppColors.incomeColor);

    return Container(
      key: const ValueKey('tx-details-category-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        key: const ValueKey('tx-details-category-material'),
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('tx-details-category-inkwell'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryDetailsScreen(
                  categoryUuid: category.uuid,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            key: const ValueKey('tx-details-category-padding'),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              key: const ValueKey('tx-details-category-row'),
              children: [
                Container(
                  key: const ValueKey('tx-details-category-icon-container'),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category.icon != null
                        ? IconHelper.getIconData(category.icon!)
                        : (isExpense
                            ? Icons.arrow_circle_down
                            : Icons.arrow_circle_up),
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    key: const ValueKey('tx-details-category-info'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        key: const ValueKey('tx-details-category-label'),
                        l10n.category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        key: const ValueKey('tx-details-category-name'),
                        LocalizationHelper.getLocalizedCategoryName(
                            context, category.name),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildTxAccountCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n, {
    required Account account,
    VoidCallback? onEdit,
  }) {
    final type = AccountType.fromValue(account.type);
    final color = account.color != null
        ? Color(int.parse(account.color!.replaceAll('#', '0xFF')))
        : theme.colorScheme.primary;

    IconData iconData() {
      final fromDb = IconHelper.getIconData(account.icon);
      if (fromDb != null) return fromDb;
      switch (type) {
        case AccountType.cash:
          return Symbols.payments;
        case AccountType.bank:
          return Symbols.account_balance;
        case AccountType.savings:
          return Symbols.savings;
        case AccountType.creditCard:
          return Symbols.credit_card;
      }
    }

    return Container(
      key: const ValueKey('tx-details-account-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        key: const ValueKey('tx-details-account-material'),
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('tx-details-account-inkwell'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccountDetailScreen(
                  accountUuid: account.uuid,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            key: const ValueKey('tx-details-account-padding'),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              key: const ValueKey('tx-details-account-row'),
              children: [
                Container(
                  key: const ValueKey('tx-details-account-icon-container'),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    iconData(),
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    key: const ValueKey('tx-details-account-info'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        key: const ValueKey('tx-details-account-label'),
                        l10n.account,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        key: const ValueKey('tx-details-account-name'),
                        account.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    key: const ValueKey('tx-details-account-edit-btn'),
                    icon: Icon(Icons.edit_outlined,
                        size: 20, color: theme.colorScheme.onSurfaceVariant),
                    onPressed: onEdit,
                    tooltip: l10n.editAccount,
                  ),
                if (onEdit == null)
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildNoAccountCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n, {
    required VoidCallback onSet,
  }) {
    final color = theme.colorScheme.primary;
    return Container(
      key: const ValueKey('tx-details-no-account-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.5), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSet,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Symbols.account_balance_wallet,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.account,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.noAccountSelected,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onSet,
                  icon: Icon(Icons.add_circle_outline,
                      size: 20, color: theme.colorScheme.primary),
                  tooltip: l10n.setAccount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildSplitSummaryCard(BuildContext context,
      List<TransactionWithDetails> group, dynamic currency,
      {bool embedded = false}) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    double totalAmount = 0;
    double paidAmount = 0;
    double receivedAmount = 0;
    double pendingAmount = 0;
    bool hasPayables = false;
    bool hasReceivables = false;

    for (final item in group) {
      totalAmount += item.transaction.amount;
      if (item.linkedPayable != null) {
        hasPayables = true;
        if (item.linkedPayable!.status == 'PAID') {
          paidAmount += item.transaction.amount;
        } else {
          pendingAmount += item.transaction.amount;
        }
      } else if (item.linkedReceivable != null) {
        hasReceivables = true;
        if (item.linkedReceivable!.status == 'RECEIVED') {
          receivedAmount += item.transaction.amount;
        } else {
          pendingAmount += item.transaction.amount;
        }
      }
    }

    final inner = Column(
      key: const ValueKey('tx-details-split-summary-inner'),
      children: [
        Row(
          key: const ValueKey('tx-details-split-summary-top-row'),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSummaryMiniItem(context, l10n.totalAmount, totalAmount,
                currency, theme.colorScheme.primary),
            _buildSummaryMiniItem(
                context,
                l10n.balance,
                totalAmount - paidAmount - receivedAmount,
                currency,
                theme.colorScheme.secondary),
          ],
        ),
        Divider(
          key: const ValueKey('tx-details-split-summary-divider'),
          height: embedded ? 22 : 24,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        Row(
          key: const ValueKey('tx-details-split-summary-bottom-row'),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (hasPayables)
              _buildSummaryMiniItem(context, l10n.paid, paidAmount, currency,
                  AppColors.expenseColor),
            if (hasReceivables)
              _buildSummaryMiniItem(context, l10n.received, receivedAmount,
                  currency, AppColors.incomeColor),
            _buildSummaryMiniItem(context, l10n.pending, pendingAmount,
                currency, Colors.orange),
          ],
        ),
      ],
    );

    if (embedded) {
      return inner;
    }

    return Container(
      key: const ValueKey('tx-details-split-summary-container'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: inner,
    );
  }

  static Widget _buildSummaryMiniItem(BuildContext context, String label,
      double amount, dynamic currency, Color color) {
    final theme = Theme.of(context);
    return Column(
      key: ValueKey('mini-item-$label'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(key: ValueKey('mini-item-label-$label'), label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(
          key: ValueKey('mini-item-amount-$label'),
          AmountFormatter.formatWithCurrency(
              amount, currency),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static Widget _buildDebugInfo(
      BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      key: ValueKey('debug-info-$label'),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        key: ValueKey('debug-info-row-$label'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(key: ValueKey('debug-info-label-$label'), "$label: ",
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              key: ValueKey('debug-info-value-$label'),
              value,
              style:
                  theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailRow(
    BuildContext context, {
    Key? key,
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        key: key != null ? ValueKey('${(key as ValueKey).value}-row') : null,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            key: key != null ? ValueKey('${(key as ValueKey).value}-icon-container') : null,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              key: key != null ? ValueKey('${(key as ValueKey).value}-info-col') : null,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  key: key != null ? ValueKey('${(key as ValueKey).value}-label') : null,
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  key: key != null ? ValueKey('${(key as ValueKey).value}-value') : null,
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
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

  static Widget _buildLinkedPayableCard(
    BuildContext context,
    WidgetRef ref,
    dynamic payable,
    TransactionWithDetails item,
    dynamic transaction,
    dynamic currency, {
    Contact? contact,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isPending = payable.status == 'PENDING';
    final isOverdue = isPending && payable.dueDate != null && payable.dueDate!.isBefore(DateTime.now());
    const color = AppColors.payableColor;

    return Container(
      key: const ValueKey('tx-details-linked-payable-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDarkMode ? 0.12 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        key: const ValueKey('tx-details-linked-payable-column'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            key: const ValueKey('tx-details-linked-payable-header'),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                key: const ValueKey('tx-details-linked-payable-icon-container'),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call_made, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key: const ValueKey('tx-details-linked-payable-label'),
                      l10n.payable,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (payable.dueDate != null || payable.paidDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        payable.paidDate != null
                            ? l10n.paidOn(AppDateFormatter.formatDate(payable.paidDate!,
                                pattern: ref.watch(userProfileProvider).dateFormat))
                            : l10n.dueAt(AppDateFormatter.formatDate(payable.dueDate!,
                                pattern: ref.watch(userProfileProvider).dateFormat)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: payable.paidDate != null
                              ? AppColors.successGreen
                              : (isOverdue
                                  ? Colors.red
                                  : theme.colorScheme.onSurfaceVariant),
                          fontSize: 11,
                          fontWeight: isPending ? FontWeight.w500 : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: !isPending
                      ? AppColors.successGreen.withValues(alpha: 0.12)
                      : (isOverdue
                          ? Colors.red.withValues(alpha: 0.12)
                          : Colors.amber.withValues(alpha: 0.12)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: !isPending
                        ? AppColors.successGreen.withValues(alpha: 0.3)
                        : (isOverdue
                            ? Colors.red.withValues(alpha: 0.3)
                            : Colors.amber.withValues(alpha: 0.3)),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      !isPending
                          ? Icons.check_circle_rounded
                          : (isOverdue ? Icons.error_outline_rounded : Icons.schedule_rounded),
                      color: !isPending
                          ? AppColors.successGreen
                          : (isOverdue ? Colors.red : (Colors.amber[800] ?? Colors.amber)),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      !isPending
                          ? l10n.paid
                          : (isOverdue ? l10n.overdue : l10n.pending),
                      style: TextStyle(
                        color: !isPending
                            ? AppColors.successGreen
                            : (isOverdue ? Colors.red : (Colors.amber[800] ?? Colors.amber)),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (contact != null) ...[
            const SizedBox(height: 16),
            Divider(color: theme.dividerColor.withValues(alpha: 0.4), height: 1),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.getContactColor(contact.name).withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
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
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      key: const ValueKey('tx-details-linked-payable-contact-avatar'),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.getContactGradient(contact.name),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        contact.name.isNotEmpty
                            ? contact.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            key: const ValueKey('tx-details-linked-payable-contact-name'),
                            contact.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (contact.phone != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              contact.phone!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (contact.phone != null && transaction.isAutoGenerated != true)
                    IconButton(
                      key: const ValueKey('tx-details-linked-payable-message-btn'),
                      onPressed: () {
                        ShareHelper.shareTransaction(
                          context,
                          ref,
                          transaction,
                          contact,
                          item.category,
                          item.isLinkedEntryMarked,
                          currencyOverride: currency,
                          userProfileOverride: ref.read(userProfileProvider),
                          transactionServiceOverride:
                              ref.read(transactionServiceProvider),
                          whatsAppServiceOverride:
                              ref.read(whatsAppServiceProvider),
                          templateServiceOverride:
                              ref.read(messageTemplateServiceProvider),
                          languageOverride: getCurrentLanguageCode(ref),
                        );
                      },
                      icon: const Icon(Icons.chat, color: Color(0xFF25D366), size: 20),
                      tooltip: l10n.sendMessage,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.12),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const ValueKey('tx-details-linked-payable-mark-paid-btn'),
                onPressed: () => _markAsPaid(context, ref, payable.uuid, item),
                icon: const Icon(Icons.check_circle),
                label: Text(l10n.markAsPaid),
                style: AppColors.transactionMarkAsPaidFilledStyle(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildLinkedReceivableCard(
    BuildContext context,
    WidgetRef ref,
    dynamic receivable,
    TransactionWithDetails item,
    dynamic transaction,
    dynamic currency, {
    Contact? contact,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isPending = receivable.status == 'PENDING';
    final isOverdue = isPending && receivable.dueDate != null && receivable.dueDate!.isBefore(DateTime.now());
    const color = AppColors.receivableColor;

    return Container(
      key: const ValueKey('tx-details-linked-receivable-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDarkMode ? 0.12 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        key: const ValueKey('tx-details-linked-receivable-column'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            key: const ValueKey('tx-details-linked-receivable-header'),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                key: const ValueKey('tx-details-linked-receivable-icon-container'),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call_received, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key: const ValueKey('tx-details-linked-receivable-label'),
                      l10n.receivable,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (receivable.dueDate != null || receivable.receivedDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        receivable.receivedDate != null
                            ? l10n.receivedOn(AppDateFormatter.formatDate(receivable.receivedDate!,
                                pattern: ref.watch(userProfileProvider).dateFormat))
                            : l10n.dueAt(AppDateFormatter.formatDate(receivable.dueDate!,
                                pattern: ref.watch(userProfileProvider).dateFormat)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: receivable.receivedDate != null
                              ? AppColors.successGreen
                              : (isOverdue
                                  ? Colors.red
                                  : theme.colorScheme.onSurfaceVariant),
                          fontSize: 11,
                          fontWeight: isPending ? FontWeight.w500 : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: !isPending
                      ? AppColors.successGreen.withValues(alpha: 0.12)
                      : (isOverdue
                          ? Colors.red.withValues(alpha: 0.12)
                          : Colors.amber.withValues(alpha: 0.12)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: !isPending
                        ? AppColors.successGreen.withValues(alpha: 0.3)
                        : (isOverdue
                            ? Colors.red.withValues(alpha: 0.3)
                            : Colors.amber.withValues(alpha: 0.3)),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      !isPending
                          ? Icons.check_circle_rounded
                          : (isOverdue ? Icons.error_outline_rounded : Icons.schedule_rounded),
                      color: !isPending
                          ? AppColors.successGreen
                          : (isOverdue ? Colors.red : (Colors.amber[800] ?? Colors.amber)),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      !isPending
                          ? l10n.received
                          : (isOverdue ? l10n.overdue : l10n.pending),
                      style: TextStyle(
                        color: !isPending
                            ? AppColors.successGreen
                            : (isOverdue ? Colors.red : (Colors.amber[800] ?? Colors.amber)),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (contact != null) ...[
            const SizedBox(height: 16),
            Divider(color: theme.dividerColor.withValues(alpha: 0.4), height: 1),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.getContactColor(contact.name).withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
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
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      key: const ValueKey('tx-details-linked-receivable-contact-avatar'),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.getContactGradient(contact.name),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        contact.name.isNotEmpty
                            ? contact.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            key: const ValueKey('tx-details-linked-receivable-contact-name'),
                            contact.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (contact.phone != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              contact.phone!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (contact.phone != null && transaction.isAutoGenerated != true)
                    IconButton(
                      key: const ValueKey('tx-details-linked-receivable-message-btn'),
                      onPressed: () {
                        ShareHelper.shareTransaction(
                          context,
                          ref,
                          transaction,
                          contact,
                          item.category,
                          item.isLinkedEntryMarked,
                          currencyOverride: currency,
                          userProfileOverride: ref.read(userProfileProvider),
                          transactionServiceOverride:
                              ref.read(transactionServiceProvider),
                          whatsAppServiceOverride:
                              ref.read(whatsAppServiceProvider),
                          templateServiceOverride:
                              ref.read(messageTemplateServiceProvider),
                          languageOverride: getCurrentLanguageCode(ref),
                        );
                      },
                      icon: const Icon(Icons.chat, color: Color(0xFF25D366), size: 20),
                      tooltip: l10n.sendMessage,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.12),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const ValueKey('tx-details-linked-receivable-mark-received-btn'),
                onPressed: () =>
                    _markAsReceived(context, ref, receivable.uuid, item),
                icon: const Icon(Icons.check_circle),
                label: Text(l10n.markAsReceived),
                style: AppColors.transactionMarkAsReceivedFilledStyle(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _getStatusLabel(
    BuildContext context,
    String relationship,
    bool isMarked, {
    required bool isExpense,
  }) {
    final l10n = AppLocalizations.of(context)!;
    if (isMarked) {
      switch (relationship.toUpperCase()) {
        case 'PAID_FOR':
        case 'WILL_RECEIVE':
          return l10n.receivedTag;
        case 'PAID_BY':
        case 'RECEIVED_FROM':
          return l10n.paidTag;
      }
    }
    return LocalizationHelper.localizeRelationshipShort(
      l10n,
      relationship,
      isExpense: isExpense,
    );
  }

  static Future<void> _markAsReviewed(
      BuildContext context, WidgetRef ref, String uuid) async {
    try {
      final service = ref.read(transactionServiceProvider);
      await service.markTransactionAsReviewed(uuid);
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ToastUtils.showSuccessToast(
            context, ref, l10n.transactionMarkedAsReviewed);
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  static Future<void> _editTabularDetails(
    BuildContext context,
    WidgetRef ref,
    TransactionWithDetails item,
    dynamic currency,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    var (summary, rows) = TabularParser.parse(item.transaction.description);

    if (rows.isEmpty && item.transaction.amount > 0) {
      rows = [
        TabularRow(
          date: item.transaction.date,
          quantity: 1.0,
          unitAmount: item.transaction.amount,
          description: '',
        )
      ];
    }

    await TabularEditorSheet.show(
      context,
      initialRows: rows,
      currencySymbol: currency.symbol,
      decimalPlaces: currency.decimalPlaces,
      currentTransactionAmount: item.transaction.amount,
      onSave: (updatedRows, updateAmount) async {
        try {
          final newDescription = TabularParser.serialize(summary, updatedRows);
          final newAmount = updateAmount
              ? updatedRows.fold(0.0, (sum, row) => sum + row.totalAmount)
              : item.transaction.amount;

          await ref.read(transactionServiceProvider).updateTransaction(
                transactionUuid: item.transaction.uuid,
                amount: newAmount,
                type: item.transaction.type,
                date: item.transaction.date,
                description: newDescription,
                categoryUuid: item.transaction.categoryUuid,
                contactUuid: item.transaction.contactUuid,
                accountUuid: item.transaction.accountUuid,
                paidRelationship: item.transaction.paidRelationship,
                dueDate: item.linkedPayable?.dueDate ??
                    item.linkedReceivable?.dueDate,
              );

          if (context.mounted) {
            ToastUtils.showSuccessToast(context, ref, l10n.transactionUpdated);
          }
        } catch (e) {
          if (context.mounted) {
            ToastUtils.showErrorToast(
                context, ref, l10n.errorOccurred(e.toString()));
          }
        }
      },
    );
  }

  static Widget _buildAddItemizedDetailsButton(
    BuildContext context,
    WidgetRef ref,
    TransactionWithDetails item,
    dynamic currency,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        key: const ValueKey('tx-details-add-tabular-btn'),
        onPressed: () => _editTabularDetails(context, ref, item, currency),
        icon: const Icon(Icons.table_chart_outlined),
        label: Text(l10n.addItemizedDetails),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static Future<void> _changeAccount(
    BuildContext context,
    WidgetRef ref,
    TransactionWithDetails item,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final isExpense = item.transaction.type == 'EXPENSE';

    final choice = await resolveSettlementAccountChoice(
      context,
      ref,
      isPayable: isExpense, // If expense, we pay from account
      initialAccount: item.account,
      transactionForAccountDefault: item.transaction,
    );

    if (choice != null) {
      try {
        await ref
            .read(transactionServiceProvider)
            .updateTransactionAccount(item.transaction.uuid, choice.accountUuid);
        if (context.mounted) {
          ToastUtils.showSuccessToast(context, ref, l10n.accountUpdated);
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtils.showErrorToast(
              context, ref, l10n.errorOccurred(e.toString()));
        }
      }
    }
  }

  static Future<void> _editDescriptionDialog(
    BuildContext context,
    WidgetRef ref,
    String transactionUuid,
    String fullDescription,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final index = fullDescription.indexOf('\n[');
    final currentDisplayDesc = index != -1 ? fullDescription.substring(0, index).trim() : fullDescription.trim();
    final tabularPart = index != -1 ? fullDescription.substring(index) : '';

    final controller = TextEditingController(text: currentDisplayDesc);

    final newDisplayDesc = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editDescription),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.description,
            hintText: l10n.descriptionHint,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (newDisplayDesc != null && context.mounted) {
      final updatedDescription = tabularPart.isNotEmpty
          ? '$newDisplayDesc\n$tabularPart'.trim()
          : newDisplayDesc.trim();

      try {
        await ref
            .read(transactionServiceProvider)
            .updateTransactionDescription(transactionUuid, updatedDescription);
        if (context.mounted) {
          ToastUtils.showSuccessToast(context, ref, l10n.transactionUpdated);
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtils.showErrorToast(
              context, ref, l10n.errorOccurred(e.toString()));
        }
      }
    }
  }

  static Future<void> _deleteTransaction(
      BuildContext context, WidgetRef ref, String transactionUuid) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTransactionTitle),
        content: Text(l10n.deleteTransactionMessage),
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
        final service = ref.read(transactionServiceProvider);
        await service.deleteTransaction(transactionUuid);

        if (context.mounted) {
          Navigator.pop(context);
          ToastUtils.showSuccessToast(context, ref, l10n.transactionDeleted);
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtils.showErrorToast(
              context, ref, l10n.errorDeletingTransaction(e.toString()));
        }
      }
    }
  }

  static Future<void> markAsPaid(BuildContext context, WidgetRef ref,
      String payableUuid, TransactionWithDetails item) async {
    return _markAsPaid(context, ref, payableUuid, item);
  }

  static Future<void> markAsReceived(BuildContext context, WidgetRef ref,
      String receivableUuid, TransactionWithDetails item) async {
    return _markAsReceived(context, ref, receivableUuid, item);
  }

  static Future<void> _markAsPaid(BuildContext context, WidgetRef ref,
      String payableUuid, TransactionWithDetails item) async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await resolveSettlementAccountChoice(
      context,
      ref,
      isPayable: true,
      initialAccount: item.account,
      transactionForAccountDefault: item.transaction,
    );
    if (choice == null) return;

    try {
      final repository = ref.read(payablesRepositoryProvider);
      await repository.markAsPaid(
        payableUuid,
        accountUuid: choice.accountUuid,
      );

      if (context.mounted) {
        final activeColor = ref.read(activeCashbookProvider).color;
        final currency = ref.read(currentCurrencyProvider).value!;
        final userProfile = ref.read(userProfileProvider);
        final transactionService = ref.read(transactionServiceProvider);
        final whatsAppService = ref.read(whatsAppServiceProvider);

        ToastUtils.showSuccessToast(context, ref, l10n.markedAsPaid,
            color: activeColor);

        // Transaction is the parent of this linked payable
        final transaction = item.transaction;
        final contact = item.contact;
        final category = item.category;

        final capturedCurrency = currency;
        final capturedUserProfile = userProfile;
        final capturedTransactionService = transactionService;
        final capturedWhatsAppService = whatsAppService;
        final capturedTemplateService =
            ref.read(messageTemplateServiceProvider);
        final capturedLanguage = getCurrentLanguageCode(ref);
        final capturedContainer = ProviderScope.containerOf(context);

        ToastUtils.showSuccessToast(
          context,
          ref,
          l10n.informContactSettlementPayable,
          actionLabel: l10n.share,
          onActionPressed: (snackContext) {
            ShareHelper.shareTransaction(
              snackContext,
              null, // Pass null for ref to avoid unmounted check
              transaction,
              contact,
              category,
              true, // isMarked
              currencyOverride: capturedCurrency,
              userProfileOverride: capturedUserProfile,
              transactionServiceOverride: capturedTransactionService,
              whatsAppServiceOverride: capturedWhatsAppService,
              templateServiceOverride: capturedTemplateService,
              languageOverride: capturedLanguage,
              container: capturedContainer,
            );
          },
          color: activeColor,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  static Future<void> _markAsReceived(BuildContext context, WidgetRef ref,
      String receivableUuid, TransactionWithDetails item) async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await resolveSettlementAccountChoice(
      context,
      ref,
      isPayable: false,
      initialAccount: item.account,
      transactionForAccountDefault: item.transaction,
    );
    if (choice == null) return;

    try {
      final repository = ref.read(receivablesRepositoryProvider);
      await repository.markAsReceived(
        receivableUuid,
        accountUuid: choice.accountUuid,
      );

      if (context.mounted) {
        final activeColor = ref.read(activeCashbookProvider).color;
        final currency = ref.read(currentCurrencyProvider).value!;
        final userProfile = ref.read(userProfileProvider);
        final transactionService = ref.read(transactionServiceProvider);
        final whatsAppService = ref.read(whatsAppServiceProvider);

        ToastUtils.showSuccessToast(context, ref, l10n.markedAsReceived,
            color: activeColor);

        // Transaction is the parent of this linked receivable
        final transaction = item.transaction;
        final contact = item.contact;
        final category = item.category;

        final capturedCurrency = currency;
        final capturedUserProfile = userProfile;
        final capturedTransactionService = transactionService;
        final capturedWhatsAppService = whatsAppService;
        final capturedTemplateService =
            ref.read(messageTemplateServiceProvider);
        final capturedLanguage = getCurrentLanguageCode(ref);
        final capturedContainer = ProviderScope.containerOf(context);

        ToastUtils.showSuccessToast(
          context,
          ref,
          l10n.informContactSettlement,
          actionLabel: l10n.share,
          onActionPressed: (snackContext) {
            ShareHelper.shareTransaction(
              snackContext,
              null, // Pass null for ref to avoid unmounted check
              transaction,
              contact,
              category,
              true, // isMarked
              currencyOverride: capturedCurrency,
              userProfileOverride: capturedUserProfile,
              transactionServiceOverride: capturedTransactionService,
              whatsAppServiceOverride: capturedWhatsAppService,
              templateServiceOverride: capturedTemplateService,
              languageOverride: capturedLanguage,
              container: capturedContainer,
            );
          },
          color: activeColor,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }
}

class TabularDataSectionWidget extends StatefulWidget {
  final String description;
  final dynamic currency;
  final VoidCallback? onEdit;

  const TabularDataSectionWidget({
    super.key,
    required this.description,
    required this.currency,
    this.onEdit,
  });

  @override
  State<TabularDataSectionWidget> createState() => _TabularDataSectionWidgetState();
}

class _TabularDataSectionWidgetState extends State<TabularDataSectionWidget> {
  String _sortBy = 'date'; // 'date', 'desc', 'price'
  bool _isAscending = false; // default to latest first (descending)
  bool _isExpanded = true; // tracking expansion state for animated arrow rotation

  Widget _buildSortChip({
    required String label,
    required String field,
    required ThemeData theme,
  }) {
    final isSelected = _sortBy == field;
    final colorScheme = theme.colorScheme;

    Widget? directionIcon;
    if (isSelected) {
      directionIcon = Padding(
        padding: const EdgeInsets.only(left: 4, right: 4),
        child: Icon(
          _isAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          size: 14,
          color: colorScheme.primary,
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            if (_sortBy == field) {
              _isAscending = !_isAscending;
            } else {
              _sortBy = field;
              // default to descending for date, and ascending for others
              _isAscending = field == 'date' ? false : true;
            }
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : theme.dividerColor.withValues(alpha: 0.15),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (directionIcon != null) directionIcon,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (_, rows) = TabularParser.parse(widget.description);
    if (rows.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final total = rows.fold(0.0, (sum, row) => sum + row.totalAmount);
    final totalQuantity = rows.fold(0.0, (sum, row) => sum + row.quantity);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final amountLine = AmountFormatter.formatWithCurrency(
      total,
      widget.currency,
      isRtl,
    );
    final quantityLine = AmountFormatter.formatQuantity(totalQuantity);
    final quantitySubtitle = l10n.itemizedHeaderQuantityLabel(quantityLine);

    final isDarkMode = theme.brightness == Brightness.dark;

    // Sorting
    final sortedRows = List<TabularRow>.from(rows);
    if (_sortBy == 'date') {
      sortedRows.sort((a, b) {
        final cmp = a.date.compareTo(b.date);
        return _isAscending ? cmp : -cmp;
      });
    } else if (_sortBy == 'desc') {
      sortedRows.sort((a, b) {
        final cmp = a.description.toLowerCase().compareTo(b.description.toLowerCase());
        return _isAscending ? cmp : -cmp;
      });
    } else if (_sortBy == 'price') {
      sortedRows.sort((a, b) {
        final cmp = a.totalAmount.compareTo(b.totalAmount);
        return _isAscending ? cmp : -cmp;
      });
    }

    return Container(
      key: const ValueKey('tx-details-tabular-section'),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.colorScheme.surfaceContainerLow
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const ValueKey('tx-details-tabular-tile'),
          initiallyExpanded: true,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Text(
                l10n.itemizedDetails,
                key: const ValueKey('tx-details-tabular-label'),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.1,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Symbols.inventory_2,
                      size: 12,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      quantityLine,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.onEdit != null)
                IconButton(
                  key: const ValueKey('tx-details-tabular-edit-btn'),
                  onPressed: widget.onEdit,
                  icon: Icon(Icons.edit_outlined,
                      size: 20, color: theme.colorScheme.onSurfaceVariant),
                  tooltip: l10n.edit,
                ),
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          children: [
            const Divider(height: 1),
            // Sort Bar (only shown when there are more than 2 records)
            if (rows.length > 2) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: isDarkMode
                    ? theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Sort:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildSortChip(
                              label: l10n.date,
                              field: 'date',
                              theme: theme,
                            ),
                            const SizedBox(width: 8),
                            _buildSortChip(
                              label: l10n.description,
                              field: 'desc',
                              theme: theme,
                            ),
                            const SizedBox(width: 8),
                            _buildSortChip(
                              label: l10n.amount,
                              field: 'price',
                              theme: theme,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],
            ListView.builder(
              key: const ValueKey('tx-details-tabular-list'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: sortedRows.length,
              itemBuilder: (context, index) {
                final row = sortedRows[index];
                final unitPriceStr = AmountFormatter.formatWithCurrency(
                  row.unitAmount,
                  widget.currency,
                );
                final showQtyBreakdown = (row.quantity - 1.0).abs() > 1e-9;
                final qtyDisplay = AmountFormatter.formatQuantity(row.quantity);

                return Container(
                  key: ValueKey('tx-details-tabular-row-$index'),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? theme.colorScheme.surfaceContainerHigh
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.05 : 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isRtl)
                          Container(
                            width: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.7),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 11,
                                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            AppDateFormatter.formatDate(row.date, pattern: 'dd MMM, yyyy'),
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        row.description,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AmountFormatter.formatWithCurrency(
                                        row.totalAmount,
                                        widget.currency,
                                      ),
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.end,
                                      textDirection: TextDirection.ltr,
                                    ),
                                    if (showQtyBreakdown) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isRtl
                                              ? '$unitPriceStr x $qtyDisplay'
                                              : '$qtyDisplay x $unitPriceStr',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.end,
                                          textDirection: TextDirection.ltr,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isRtl)
                          Container(
                            width: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.7),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
