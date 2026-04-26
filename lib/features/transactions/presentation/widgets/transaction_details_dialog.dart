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

    // Listen for changes to the group to ensure we refresh if needed
    // (StreamProvider already does this, but we want to be explicit)
    ref.listen(transactionGroupProvider(transactionUuid), (previous, next) {
      if (next is AsyncData && previous is AsyncData) {
        // Data updated
      }
    });

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return Scaffold(
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
          return const Center(child: CircularProgressIndicator());
        }

        return groupAsync.when(
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
            );
          },
          loading: () => Scaffold(
            appBar: AppBar(title: Text(l10n.transactionDetails)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Scaffold(
            appBar: AppBar(title: Text(l10n.transactionDetails)),
            body: Center(child: Text(l10n.errorOccurred(err.toString()))),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.transactionDetails)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
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
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final pr = transaction.paidRelationship as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionDetails),
        actions: [
          Builder(
            builder: (context) {
              ref.watch(dashboardWidgetLayoutProvider);
              final notifier = ref.read(dashboardWidgetLayoutProvider.notifier);
              final isPinned = notifier.isPinned(
                  DashboardWidgetKind.transaction, transaction.uuid);
              return IconButton(
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
                    isExpense ? l10n.expense : l10n.income,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${isExpense ? '\u200E-' : '\u200E+'} ${AmountFormatter.formatWithCurrency(transaction.amount, currency.symbol, currency.decimalPlaces)}',
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
                  if (transaction.isAutoGenerated) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
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
                                  initialDueDate: initialDueDate,
                                ),
                              ),
                            );
                          },
                        ),
                      if (!item.isLinkedEntryMarked && transaction.isAutoGenerated != true)
                        IconButton(
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

            const SizedBox(height: 16),

            if (isSplitGroup) ...[
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SplittedTransactionsScreen(
                          transactionUuid: transaction.uuid,
                        ),
                      ),
                    );
                  },
                  child: _buildSectionCard(
                    context,
                    title: l10n.splittedBill,
                    titleIcon: Icons.people_outline,
                    useScheduleDateRangeStyle: true,
                    titleTrailing: IconButton(
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
                    body: _buildSplitSummaryCard(
                      context,
                      group,
                      currency,
                      embedded: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (linkedPayable != null) ...[
              Material(
                color: Colors.transparent,
                child: InkWell(
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
                color: Colors.transparent,
                child: InkWell(
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
                        onPressed: () async {
                          await ref
                              .read(transactionServiceProvider)
                              .markAsProcessed(transaction.uuid);
                          if (context.mounted) Navigator.pop(context);
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
              ),
              const SizedBox(height: 16),
            ],

            _buildSectionCard(
              context,
              title: l10n.information,
              titleIcon: Icons.info_outline,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (contact != null) ...[
                    _buildDetailRow(
                      context,
                      icon: Icons.person_outline,
                      label: l10n.contact,
                      value: contact.name,
                      trailing: IconButton(
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
                    icon: Icons.calendar_today_outlined,
                    label: l10n.date,
                    value: AppDateFormatter.formatDate(transaction.date,
                        pattern: ref.watch(userProfileProvider).dateFormat),
                  ),
                  if (transaction.description != null &&
                      transaction.description!.isNotEmpty) ...[
                    _buildDetailRow(
                      context,
                      icon: Icons.notes_outlined,
                      label: l10n.description,
                      value: TabularParser.isTabular(transaction.description)
                          ? TabularParser.parse(transaction.description).$1
                          : transaction.description!,
                    ),
                  ],
                  if (transaction.processedDate != null)
                    _buildDetailRow(
                      context,
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
                      onPressed: () async {
                        await ref
                            .read(transactionServiceProvider)
                            .markAsProcessed(transaction.uuid);
                        if (context.mounted) Navigator.pop(context);
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

            if (transaction.description != null &&
                TabularParser.isTabular(transaction.description) &&
                ref.watch(premiumProvider).isPremium) ...[
              const SizedBox(height: 16),
              buildTabularDataSection(
                context,
                theme,
                l10n,
                transaction.description!,
                currency,
              ),
            ],

            if (kDebugMode) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
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
          ],
        ),
      ),
    );
  }

  static Widget buildTabularDataSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    String description,
    dynamic currency,
  ) {
    final (_, rows) = TabularParser.parse(description);
    if (rows.isEmpty) return const SizedBox.shrink();

    final total = rows.fold(0.0, (sum, row) => sum + row.totalAmount);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
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
          initiallyExpanded: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          title: Row(
            children: [
              Icon(Icons.table_chart_outlined,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.itemizedDetails,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Text(
                AmountFormatter.formatWithCurrency(
                  total,
                  currency.symbol,
                  currency.decimalPlaces,
                ),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          children: [
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final row = rows[index];
                final unitPriceStr = AmountFormatter.formatWithCurrency(
                  row.unitAmount,
                  currency.symbol,
                  currency.decimalPlaces,
                );

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppDateFormatter.formatDate(row.date,
                                pattern: 'dd MMM, yyyy'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            AmountFormatter.formatWithCurrency(
                              row.totalAmount,
                              currency.symbol,
                              currency.decimalPlaces,
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        row.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isRtl
                            ? '$unitPriceStr x ${row.quantity}'
                            : '${row.quantity} x $unitPriceStr',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Section shell (schedule / account-detail style).
  static Widget _buildSectionCard(
    BuildContext context, {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
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

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isReceivable ? Icons.call_received : Icons.call_made,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          if (contact != null) ...[
            const SizedBox(height: 16),
            Material(
              color: Colors.transparent,
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
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (contact.phone != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isExpense ? l10n.markAsPaid : l10n.markAsReceived,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
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
              color: Colors.transparent,
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
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (contact.phone != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
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
        color: Colors.transparent,
        child: InkWell(
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
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
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
        color: Colors.transparent,
        child: InkWell(
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
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
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
                        account.name,
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
      children: [
        Row(
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
          height: embedded ? 22 : 24,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        Row(
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(
          AmountFormatter.formatWithCurrency(
              amount, currency.symbol, currency.decimalPlaces),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ",
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
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
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
    const color = AppColors.payableColor;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.call_made, size: 24, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.payable,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                isPending ? Icons.schedule : Icons.check_circle,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isPending ? l10n.payablePending : l10n.paidTag,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (contact != null) ...[
            const SizedBox(height: 14),
            Material(
              color: Colors.transparent,
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
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.getContactGradient(contact.name),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.getContactColor(contact.name)
                                  .withValues(alpha: 0.28),
                              blurRadius: 6,
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          contact.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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
          if (payable.dueDate != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.dueAt(AppDateFormatter.formatDate(payable.dueDate,
                  pattern: ref.watch(userProfileProvider).dateFormat)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isPending
                    ? (payable.dueDate!.isBefore(DateTime.now())
                        ? Colors.red
                        : Colors.orange)
                    : null,
                fontWeight: isPending ? FontWeight.bold : null,
              ),
            ),
          ],
          if (payable.paidDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: AppColors.payableColor,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.paidOn(AppDateFormatter.formatDate(payable.paidDate!,
                      pattern: ref.watch(userProfileProvider).dateFormat)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.payableColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
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
    const color = AppColors.receivableColor;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.call_received, size: 24, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.receivable,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                isPending ? Icons.schedule : Icons.check_circle,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isPending ? l10n.receivablePending : l10n.receivedTag,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (contact != null) ...[
            const SizedBox(height: 14),
            Material(
              color: Colors.transparent,
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
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.getContactGradient(contact.name),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.getContactColor(contact.name)
                                  .withValues(alpha: 0.28),
                              blurRadius: 6,
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          contact.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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
          if (receivable.dueDate != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.dueAt(AppDateFormatter.formatDate(receivable.dueDate,
                  pattern: ref.watch(userProfileProvider).dateFormat)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isPending
                    ? (receivable.dueDate!.isBefore(DateTime.now())
                        ? Colors.red
                        : Colors.orange)
                    : null,
                fontWeight: isPending ? FontWeight.bold : null,
              ),
            ),
          ],
          if (receivable.receivedDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: AppColors.receivableColor,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.receivedOn(AppDateFormatter.formatDate(
                      receivable.receivedDate!,
                      pattern: ref.watch(userProfileProvider).dateFormat)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.receivableColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
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
