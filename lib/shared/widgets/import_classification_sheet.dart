import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/whatsapp/domain/models/shared_data_models.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';

/// Bottom sheet shown when importing a shared transaction with an ambiguous
/// relationship (PAID_FOR, WILL_RECEIVE, PAID_BY, RECEIVED_FROM). Lets the user
/// choose the correct classification before opening the add-transaction screen.
class ImportClassificationSheet extends ConsumerWidget {
  final TransactionShareData data;

  const ImportClassificationSheet({
    super.key,
    required this.data,
  });

  static const List<String> _receivableRelationships = ['PAID_FOR', 'WILL_RECEIVE'];
  static const List<String> _payableRelationships = ['PAID_BY', 'RECEIVED_FROM'];

  /// Whether this shared data should show the classification sheet (ambiguous relationship).
  static bool needsClassification(TransactionShareData data) {
    final r = data.relationship;
    return r != null &&
        (_receivableRelationships.contains(r) || _payableRelationships.contains(r));
  }

  bool get _isReceivableGroup =>
      data.relationship != null && _receivableRelationships.contains(data.relationship);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = ref.watch(currencySymbolProvider);
    final decimalPlaces = ref.watch(currentCurrencyProvider).value?.decimalPlaces ?? 2;
    final contactName = data.contactName ?? data.senderName ?? l10n.someone;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDragHandle(theme),
                const SizedBox(height: 8),
                Text(
                  l10n.importTransaction,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailsCard(
                  context,
                  ref,
                  theme,
                  l10n,
                  currencySymbol,
                  decimalPlaces,
                ),
                const SizedBox(height: 24),
                Text(
                  _isReceivableGroup
                      ? l10n.importClassificationReceivableQuestion
                      : l10n.importClassificationPayableQuestion,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (_isReceivableGroup) ...[
                  _buildIntentOption(
                    context: context,
                    theme: theme,
                    icon: Icons.shopping_bag_outlined,
                    title: l10n.importClassificationReceivableOptionPaidFor(contactName),
                    chipLabel: l10n.receivable,
                    color: AppColors.expenseColor,
                    onTap: () => _navigateWith(context, 'EXPENSE', 'PAID_FOR'),
                  ),
                  const SizedBox(height: 12),
                  _buildIntentOption(
                    context: context,
                    theme: theme,
                    icon: Icons.handshake_outlined,
                    title: l10n.importClassificationReceivableOptionWillReceive,
                    chipLabel: l10n.receivable,
                    color: AppColors.incomeColor,
                    onTap: () => _navigateWith(context, 'INCOME', 'WILL_RECEIVE'),
                  ),
                ] else ...[
                  _buildIntentOption(
                    context: context,
                    theme: theme,
                    icon: Icons.payments_outlined,
                    title: l10n.importClassificationPayableOptionPaidBy(contactName),
                    chipLabel: l10n.payable,
                    color: AppColors.expenseColor,
                    onTap: () => _navigateWith(context, 'EXPENSE', 'PAID_BY'),
                  ),
                  const SizedBox(height: 12),
                  _buildIntentOption(
                    context: context,
                    theme: theme,
                    icon: Icons.account_balance_wallet_outlined,
                    title: l10n.importClassificationPayableOptionReceivedFrom,
                    chipLabel: l10n.payable,
                    color: AppColors.incomeColor,
                    onTap: () => _navigateWith(context, 'INCOME', 'RECEIVED_FROM'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDragHandle(ThemeData theme) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
    String currencySymbol,
    int decimalPlaces,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.senderName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.sharedBy(data.senderName!),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          _detailRow(l10n.amount, AmountFormatter.formatWithCurrency(
              data.amount, currencySymbol, decimalPlaces)),
          _detailRow(l10n.date, AppDateFormatter.formatDate(data.date)),
          if (data.description != null && data.description!.isNotEmpty)
            _detailRow(l10n.description, data.description!),
          if (data.categoryName != null)
            _detailRow(l10n.category, data.categoryName!),
          if (data.contactName != null)
            _detailRow(l10n.contact, data.contactName!),
          if (data.dueDate != null)
            _detailRow(l10n.dueDate, AppDateFormatter.formatDate(data.dueDate!)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildIntentOption({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String chipLabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      chipLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  void _navigateWith(BuildContext context, String transactionType, String relationship) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          initialAmount: data.amount,
          initialDate: data.date,
          initialDescription: data.description,
          initialType: transactionType,
          initialRelationship: relationship,
          initialCategoryName: data.categoryName,
          initialCategoryColor: data.categoryColor,
          initialCategoryIcon: data.categoryIcon,
          initialContactName: data.contactName ?? data.senderName,
          initialContactPhone: data.contactPhone ?? data.senderPhone,
          initialExternalLinkId: data.externalLinkId,
          initialDueDate: data.dueDate,
        ),
      ),
    );
  }
}
