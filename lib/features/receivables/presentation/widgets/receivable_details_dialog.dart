import 'package:flowpaisa/core/utils/tabular_parser.dart';
import 'package:flowpaisa/features/receivables/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/linked_settlement_account_sheet.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_details_dialog.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/contact_details_screen.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:flowpaisa/features/categories/presentation/screens/category_details_screen.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/core/utils/share_helper.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/screens/add_receivable_screen.dart';
import 'package:flowpaisa/features/receivables/presentation/screens/edit_receivable_screen.dart';
import 'package:flowpaisa/features/messages/presentation/providers/message_template_provider.dart';
import 'package:flowpaisa/features/whatsapp/presentation/providers/whatsapp_provider.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flutter/services.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/features/dashboard/domain/dashboard_widget_models.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_widget_provider.dart';

class ReceivableDetailsDialog extends ConsumerWidget {
  final String receivableUuid;

  const ReceivableDetailsDialog({
    super.key,
    required this.receivableUuid,
  });

  bool _canEditReceivable(Receivable receivable) {
    // Can edit only if PENDING and not linked to any transaction
    return receivable.status == 'PENDING' &&
        receivable.linkedExpenseUuid == null &&
        receivable.linkedIncomeUuid == null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    final itemAsync =
        ref.watch(receivableWithLinkedDataProvider(receivableUuid));

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.receivableDetails)),
            body: Center(child: Text(l10n.receivableNotFound)),
          );
        }

        final receivable = item.receivable;
        final contact = item.contact;

        if (currency == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final linkedCategory = item.linkedCategory;
        final isPending = receivable.status == 'PENDING';

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.receivableDetails),
            actions: [
              Builder(
                builder: (context) {
                  ref.watch(dashboardWidgetLayoutProvider);
                  final notifier =
                      ref.read(dashboardWidgetLayoutProvider.notifier);
                  final isPinned = notifier.isPinned(
                      DashboardWidgetKind.receivable, receivable.uuid);
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
                            c.kind == DashboardWidgetKind.receivable &&
                            c.receivableUuid == receivable.uuid);
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
                                kind: DashboardWidgetKind.receivable,
                                receivableUuid: receivable.uuid));
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
                        isPending
                            ? '${l10n.receivableTag} (${l10n.statusPending})'
                            : l10n.receivedTag,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\u200E${AmountFormatter.formatWithCurrency(receivable.amount, currency)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AmountFormatter.getFontSize(
                                  receivable.amount,
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
                                l10n.receivedTag,
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
                      if (receivable.isScheduled) ...[
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
                                Icons.event_repeat,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.scheduled,
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.link, color: Colors.white, size: 22),
                            tooltip: l10n.copyLink,
                            onPressed: () {
                              final link = DeepLinkService().generateEntityOpenLinkHttps(
                                  'receivable', receivable.uuid);
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
                              ShareHelper.shareReceivable(
                                context,
                                ref,
                                receivable,
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
                              if (receivable.dueDate != null) {
                                dueDateOffset =
                                    receivable.dueDate!.difference(receivable.date).inDays;
                              }
                              final now = DateTime.now();
                              final initialDueDate = dueDateOffset != 0
                                  ? now.add(Duration(days: dueDateOffset))
                                  : null;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddReceivableScreen(
                                    initialAmount: receivable.amount,
                                    initialDate: now,
                                    initialDescription: receivable.description,
                                    initialContactName: contact?.name,
                                    initialContactPhone: contact?.phone,
                                    initialDueDate: initialDueDate,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (_canEditReceivable(receivable))
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white, size: 22),
                              tooltip: l10n.editReceivable,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditReceivableScreen(
                                        receivableUuid: receivable.uuid),
                                  ),
                                );
                              },
                            ),
                          if (receivable.status != 'RECEIVED')
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white, size: 22),
                              tooltip: l10n.delete,
                              onPressed: () =>
                                  _deleteReceivable(context, ref, receivable.uuid),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (contact != null) ...[
                  _buildContactSection(
                    context,
                    ref,
                    theme,
                    l10n,
                    contact,
                    receivable,
                    currency,
                  ),
                  const SizedBox(height: 16),
                ],

                if (linkedCategory != null) ...[
                  _buildLinkedCategoryCard(
                    context,
                    theme,
                    l10n,
                    linkedCategory,
                  ),
                  const SizedBox(height: 16),
                ],

                if (receivable.linkedIncomeUuid != null ||
                    receivable.linkedExpenseUuid != null) ...[
                  _buildSectionCard(
                    context,
                    title: l10n.linkedTransaction,
                    titleIcon: Icons.receipt_long_outlined,
                    useScheduleDateRangeStyle: false,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (receivable.linkedExpenseUuid != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildLinkedTransactionCardFromUuid(
                              context,
                              ref,
                              receivable.linkedExpenseUuid!,
                            ),
                          ),
                        if (receivable.linkedIncomeUuid != null)
                          _buildLinkedTransactionCardFromUuid(
                            context,
                            ref,
                            receivable.linkedIncomeUuid!,
                          ),
                      ],
                    ),
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
                      _buildDetailRow(
                        context,
                        icon: Icons.calendar_today_outlined,
                        label: l10n.date,
                        value: AppDateFormatter.formatDate(
                          receivable.date,
                          pattern:
                              ref.watch(userProfileProvider).dateFormat,
                        ),
                      ),
                      if (receivable.dueDate != null)
                        _buildDetailRow(
                          context,
                          icon: Icons.event_outlined,
                          label: l10n.dueDate,
                          value: AppDateFormatter.formatDate(
                            receivable.dueDate!,
                            pattern:
                                ref.watch(userProfileProvider).dateFormat,
                          ),
                          valueColor: isPending
                              ? (receivable.dueDate!.isBefore(DateTime.now())
                                  ? Colors.red
                                  : Colors.orange)
                              : null,
                        ),
                      if (receivable.receivedDate != null)
                        _buildDetailRow(
                          context,
                          icon: Icons.check_circle_outline,
                          label: l10n.receivedOnRowLabel,
                          value: AppDateFormatter.formatDate(
                            receivable.receivedDate!,
                            pattern:
                                ref.watch(userProfileProvider).dateFormat,
                          ),
                          valueColor: AppColors.receivableColor,
                        ),
                      if (receivable.description != null &&
                          receivable.description!.isNotEmpty)
                        _buildDetailRow(
                          context,
                          icon: Icons.notes_outlined,
                          label: l10n.description,
                          value: TabularParser.isTabular(receivable.description)
                              ? TabularParser.parse(receivable.description).$1
                              : receivable.description!,
                        ),
                    ],
                  ),
                ),

                if (receivable.description != null &&
                    TabularParser.isTabular(receivable.description)) ...[
                  const SizedBox(height: 16),
                  TransactionDetailsDialog.buildTabularDataSection(
                    context,
                    theme,
                    l10n,
                    receivable.description!,
                    currency,
                  ),
                ],

                if (isPending) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _markAsReceived(context, ref, item),
                      icon: const Icon(Icons.check_circle),
                      label: Text(l10n.markAsReceived),
                      style: AppColors.transactionMarkAsReceivedFilledStyle(),
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
        appBar: AppBar(title: Text(l10n.receivableDetails)),
        body: Center(child: Text(l10n.errorOccurred(e.toString()))),
      ),
    );
  }

  /// Section shell (aligned with [TransactionDetailsDialog]).
  Widget _buildSectionCard(
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

  Widget _buildContactSection(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
    Contact contact,
    Receivable receivable,
    dynamic currency,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person,
                  size: 24,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.contact,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
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
                    if (contact.phone != null)
                      IconButton(
                        icon:
                            const Icon(Icons.chat, color: Color(0xFF25D366)),
                        onPressed: () {
                          ShareHelper.shareReceivable(
                            context,
                            ref,
                            receivable,
                            contact,
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
                        tooltip: l10n.sendMessage,
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
        ],
      ),
    );
  }

  Widget _buildLinkedCategoryCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    Category category,
  ) {
    final isExpense = category.type == 'EXPENSE';
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
                  alignment: Alignment.center,
                  child: CategoryHelper.buildCategoryIcon(
                    category.icon,
                    color,
                    isExpense,
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

  Widget _buildLinkedTransactionCard(BuildContext context, WidgetRef ref,
      dynamic transaction, Category? category) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currency = ref.read(currentCurrencyProvider).value!;
    final isExpense = transaction.type == 'EXPENSE';
    final categoryColor = category != null && category.color != null
        ? Color(int.parse(category.color!.replaceAll('#', '0xFF')))
        : (isExpense ? AppColors.expenseColor : AppColors.incomeColor);
    final datePattern = ref.read(userProfileProvider).dateFormat;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isExpense ? AppColors.expenseColor : AppColors.incomeColor)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isExpense ? AppColors.expenseColor : AppColors.incomeColor)
              .withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: category != null
                    ? CategoryHelper.buildCategoryIcon(
                        category.icon,
                        categoryColor,
                        category.type == 'EXPENSE',
                        size: 24,
                      )
                    : Icon(
                        isExpense ? Icons.payment : Icons.monetization_on,
                        color: categoryColor,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category != null
                          ? LocalizationHelper.getLocalizedCategoryName(
                              context, category.name)
                          : (isExpense ? l10n.expense : l10n.income),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                    Text(
                      isExpense ? l10n.expense : l10n.income,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isExpense ? '\u200E-' : '\u200E+'} ${AmountFormatter.formatWithCurrency(transaction.amount, currency)}',
                    style: theme.textTheme.titleSmall?.copyWith(
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
              TabularParser.isTabular(transaction.description)
                  ? TabularParser.parse(transaction.description).$1
                  : transaction.description,
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  AppDateFormatter.formatDate(
                    transaction.date,
                    pattern: datePattern,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
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
          borderRadius: BorderRadius.circular(20),
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

  Future<void> _deleteReceivable(
      BuildContext context, WidgetRef ref, String receivableUuid) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteReceivableTitle),
        content: Text(l10n.deleteReceivableMessage),
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
        final repository = ref.read(receivablesRepositoryProvider);
        await repository.deleteReceivable(receivableUuid);

        if (context.mounted) {
          Navigator.pop(context);
          ToastUtils.showSuccessToast(context, ref, l10n.receivableDeleted);
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtils.showErrorToast(
              context, ref, l10n.errorOccurred(e.toString()));
        }
      }
    }
  }

  Future<void> _markAsReceived(
    BuildContext context,
    WidgetRef ref,
    ReceivableWithLinkedData item,
  ) async {
    final receivableUuid = item.receivable.uuid;
    final l10n = AppLocalizations.of(context)!;
    final choice = await resolveSettlementAccountChoice(
      context,
      ref,
      isPayable: false,
      transactionForAccountDefault: item.linkedTransaction,
    );
    if (choice == null) return;

    try {
      final repository = ref.read(receivablesRepositoryProvider);
      await repository.markAsReceived(
        receivableUuid,
        accountUuid: choice.accountUuid,
      );

      if (context.mounted) {
        // Refresh item to get updated status and externalLinkId
        final updatedItem =
            await repository.getReceivableWithLinkedDataByUuid(receivableUuid);

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

          ToastUtils.showSuccessToast(context, ref, l10n.markedAsReceived,
              color: activeColor);

          if (updatedItem != null) {
            _showSettlementShareOption(
              context,
              ref,
              updatedItem.receivable,
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
    Receivable receivable,
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
      l10n.informContactSettlement,
      actionLabel: l10n.share,
      onActionPressed: (snackContext) {
        ShareHelper.shareReceivable(
          snackContext,
          ref,
          receivable,
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
