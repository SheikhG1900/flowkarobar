import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/contacts/data/contact_bulk_settlement_service.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/add_contact_screen.dart';
import 'package:flowpaisa/features/payables/domain/models.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/payables/presentation/screens/payables_list_screen.dart';
import 'package:flowpaisa/features/receivables/domain/models.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/screens/receivables_list_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:flutter/services.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/features/dashboard/domain/dashboard_widget_models.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_widget_provider.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/core/database/database.dart' show Account;
import 'package:flowpaisa/features/accounts/presentation/widgets/account_picker.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/transactions_list_screen.dart';

// Provider to get transactions for a contact
// Note: We'll fetch this from the database directly in a future iteration
// For now, we'll just show the stats

class ContactDetailsScreen extends ConsumerWidget {
  final String contactUuid;

  const ContactDetailsScreen({super.key, required this.contactUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(contactStatisticsProvider(contactUuid));
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    void showContactNavigationSheet({
      required String title,
      required Color color,
      required IconData icon,
      required String specificLabel,
      required IconData specificIcon,
      required VoidCallback onSpecific,
      required String transactionStatusCode,
    }) {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).padding.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Transactions option
              _ContactNavTile(
                icon: Icons.receipt_long,
                color: theme.colorScheme.primary,
                label: l10n.transactions,
                onTap: () {
                  Navigator.pop(sheetContext);
                  ref
                      .read(transactionsPaginatedProvider.notifier)
                      .applyFilters(
                        TransactionFilters(
                          contactUuids: [contactUuid],
                          statusCodes: [transactionStatusCode],
                        ),
                      );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TransactionsListScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              // Receivable / Payable specific option
              _ContactNavTile(
                icon: specificIcon,
                color: color,
                label: specificLabel,
                onTap: () {
                  Navigator.pop(sheetContext);
                  onSpecific();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: statsAsync.when(
        data: (stats) {
          final contact = stats.contact;
          final netBalance = stats.netBalance;
          final isPositive = netBalance >= 0;

          return CustomScrollView(
            slivers: [
              // Sliver App Bar with Avatar
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                stretch: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gradient Background
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.getContactColor(contact.name)
                                  .withValues(alpha: 0.2),
                              theme.scaffoldBackgroundColor,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Content
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Hero(
                              tag: 'contact_avatar_${contact.uuid}',
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: AppColors.getContactGradient(
                                      contact.name),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.getContactColor(
                                              contact.name)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                  border:
                                      Border.all(color: Colors.white, width: 4),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  contact.name.isNotEmpty
                                      ? contact.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              contact.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (contact.phone != null &&
                                contact.phone!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                contact.phone!,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.link),
                    tooltip: l10n.copyLink,
                    onPressed: () {
                      final link = DeepLinkService()
                          .generateEntityOpenLinkHttps('contact', contact.uuid);
                      Clipboard.setData(ClipboardData(text: link));
                      ToastUtils.showSuccessToast(context, ref, l10n.linkCopied);
                    },
                  ),
                  Builder(
                    builder: (context) {
                      ref.watch(dashboardWidgetLayoutProvider);
                      final notifier =
                          ref.read(dashboardWidgetLayoutProvider.notifier);
                      final isPinned = notifier.isPinned(
                          DashboardWidgetKind.contact, contact.uuid);
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
                            final layout = ref
                                    .read(dashboardWidgetLayoutProvider)
                                    .value ??
                                [];
                            final idx = layout.indexWhere((c) =>
                                c.kind == DashboardWidgetKind.contact &&
                                c.contactUuid == contact.uuid);
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
                                    kind: DashboardWidgetKind.contact,
                                    contactUuid: contact.uuid));
                            if (context.mounted) {
                              ToastUtils.showSuccessToast(
                                  context, ref, l10n.pinnedToDashboard);
                            }
                          }
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddContactScreen(contactToEdit: contact),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.error,
                    onPressed: () => _showDeleteDialog(context, ref),
                  ),
                ],
              ),

              // Content Body
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    // Net Balance Card: full width, amount and badge centered
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: InkWell(
                        onTap: () {
                          ref
                              .read(transactionsPaginatedProvider.notifier)
                              .applyFilters(
                                TransactionFilters(
                                  contactUuids: [contactUuid],
                                ),
                              );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TransactionsListScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: isPositive
                              ? AppColors.receivableGradient
                              : AppColors.payableGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: (isPositive
                                      ? AppColors.receivableColor
                                      : AppColors.payableColor)
                                  .withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            l10n.netBalance,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AmountFormatter.formatWithCurrency(
                              netBalance.abs(),
                              currency,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              netBalance == 0
                                  ? l10n.settled
                                  : (isPositive
                                      ? l10n.receivable
                                      : l10n.payable),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      ),
                    ),
                    ),
                    const SizedBox(height: 16),

                    // Rest of content with padding
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats Row
                          Row(
                            children: [
                              // Receivable Stats
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  title: l10n.receivable,
                                  amount: stats.totalReceivable,
                                  count: stats.receivablesCount,
                                  color: AppColors.receivableColor,
                                  icon: Icons.arrow_downward,
                                  currency: currency,
                                  onTap: () => showContactNavigationSheet(
                                    title: l10n.receivable,
                                    color: AppColors.receivableColor,
                                    icon: Icons.arrow_downward,
                                    specificLabel: l10n.receivables,
                                    specificIcon: Icons.arrow_downward,
                                    transactionStatusCode: 'RECEIVABLE',
                                    onSpecific: () {
                                      ref
                                          .read(receivablesPaginatedProvider(
                                                  'PENDING')
                                              .notifier)
                                          .applyFilters(ReceivableFilters(
                                              contactUuids: [contactUuid]));
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ReceivablesListScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Payable Stats
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  title: l10n.payable,
                                  amount: stats.totalPayable,
                                  count: stats.payablesCount,
                                  color: AppColors.payableColor,
                                  icon: Icons.arrow_upward,
                                  currency: currency,
                                  onTap: () => showContactNavigationSheet(
                                    title: l10n.payable,
                                    color: AppColors.payableColor,
                                    icon: Icons.arrow_upward,
                                    specificLabel: l10n.payables,
                                    specificIcon: Icons.arrow_upward,
                                    transactionStatusCode: 'PAYABLE',
                                    onSpecific: () {
                                      ref
                                          .read(payablesPaginatedProvider(
                                                  'PENDING')
                                              .notifier)
                                          .applyFilters(PayableFilters(
                                              contactUuids: [contactUuid]));
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const PayablesListScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Progress Bars
                          if (stats.totalReceivable + stats.totalReceived >
                              0) ...[
                            _buildProgressBar(
                              context,
                              title: l10n.receivedTag,
                              completedAmount: stats.totalReceived,
                              totalAmount:
                                  stats.totalReceivable + stats.totalReceived,
                              color: AppColors.receivableColor,
                              currency: currency,
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (stats.totalPayable + stats.totalPaid > 0) ...[
                            _buildProgressBar(
                              context,
                              title: l10n.paidTag,
                              completedAmount: stats.totalPaid,
                              totalAmount: stats.totalPayable + stats.totalPaid,
                              color: AppColors.payableColor,
                              currency: currency,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Bulk process / pay / receive button
                          ...() {
                            final totalPendingCount =
                                stats.receivablesCount + stats.payablesCount;
                            if (totalPendingCount <= 0) {
                              return const <Widget>[];
                            }

                            final bool isPremium = PremiumGate.isPremium(ref);
                            final bool isNetReceivable = netBalance >= 0;
                            final Color buttonColor = netBalance > 0
                                ? AppColors.receivableColor
                                : netBalance < 0
                                    ? AppColors.payableColor
                                    : theme.colorScheme.primary;

                            String label;
                            if (netBalance > 0) {
                              // Net receivable
                              label =
                                  '${l10n.bulkReceiveInBulk} ($totalPendingCount)';
                            } else if (netBalance < 0) {
                              // Net payable
                              label =
                                  '${l10n.bulkPayInBulk} ($totalPendingCount)';
                            } else {
                              // Zero balance -> just process outstanding items
                              label =
                                  '${l10n.bulkProcessInBulk} ($totalPendingCount)';
                            }

                            final IconData icon = netBalance > 0
                                ? Icons.download_done
                                : netBalance < 0
                                    ? Icons.upload
                                    : Icons.swap_horizontal_circle;

                            return <Widget>[
                              SizedBox(
                                width: double.infinity,
                                child: GradientButton(
                                  foreColor: Colors.white,
                                  label: label,
                                  icon: icon,
                                  gradient: netBalance > 0
                                      ? AppColors.receivableGradient
                                      : netBalance < 0
                                          ? AppColors.payableGradient
                                          : AppColors.primaryGradient,
                                  onPressed: () async {
                                    if (!isPremium) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const PremiumScreen(),
                                        ),
                                      );
                                      return;
                                    }

                                    // If balance is zero, we still show the sheet for account selection
                                    _showBulkSettleSheet(
                                      context,
                                      ref,
                                      netBalance,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                            ];
                          }(),

                          // Info Section
                          if (contact.email != null ||
                              contact.notes != null) ...[
                            Text(
                              l10n.information,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: theme.dividerColor
                                        .withValues(alpha: 0.5)),
                              ),
                              child: Column(
                                children: [
                                  if (contact.email != null &&
                                      contact.email!.isNotEmpty)
                                    ListTile(
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.email_outlined,
                                            size: 20),
                                      ),
                                      title: Text(contact.email!),
                                      subtitle: Text(l10n.emailLabel),
                                    ),
                                  if (contact.notes != null &&
                                      contact.notes!.isNotEmpty)
                                    ListTile(
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                            Icons.note_alt_outlined,
                                            size: 20),
                                      ),
                                      title: Text(contact.notes!),
                                      subtitle: Text(l10n.notesLabel),
                                    ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 80), // Bottom padding
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
            child: Text(AppLocalizations.of(context)!.errorOccurred('$error'))),
      ),
    );
  }

  Future<void> _showBulkSettleSheet(
      BuildContext context, WidgetRef ref, double netBalance) async {
    final l10n = AppLocalizations.of(context)!;
    final isNetReceivable = netBalance >= 0;
    final absNet = netBalance.abs();
    final service = ref.read(contactBulkSettlementServiceProvider);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final keyboardInset = MediaQuery.viewInsetsOf(ctx).bottom;
        return AnimatedPadding(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: keyboardInset),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: _BulkSettleSheetContent(
              contactUuid: contactUuid,
              absNet: absNet,
              isNetReceivable: isNetReceivable,
              service: service,
              l10n: l10n,
              ref: ref,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required double amount,
    required int count,
    required Color color,
    required IconData icon,
    required AppCurrency currency,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
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
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AmountFormatter.formatWithCurrency(
                amount,
                currency,
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${count} ${l10n.pending}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context, {
    required String title,
    required double completedAmount,
    required double totalAmount,
    required Color color,
    required AppCurrency currency,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final percent = totalAmount > 0 ? (completedAmount / totalAmount) : 0.0;
    final safePercent = percent.clamp(0.0, 1.0);

    final formattedCompleted = AmountFormatter.formatWithCurrency(
      completedAmount,
      currency,
    );
    final formattedTotal = AmountFormatter.formatWithCurrency(
      totalAmount,
      currency,
    );

    // Create the text row that will be used for both the background and foreground
    Widget buildTextRow(
        Color completedColor, Color percentageColor, Color totalColor) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title and Completed amount (left)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: completedColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    formattedCompleted,
                    style: TextStyle(
                      color: completedColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 48), // Space for the center badge
            // Total amount (right)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.totalAmount,
                    style: TextStyle(
                      color: totalColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    formattedTotal,
                    style: TextStyle(
                      color: totalColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 64, // Expanded vertically to accommodate title and amounts
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Base text (visible on the un-filled portion)
          Align(
            alignment: Alignment.center,
            child: buildTextRow(
              color, // Completed amount color
              theme.colorScheme.onSurfaceVariant, // Percentage color
              theme.colorScheme.onSurfaceVariant, // Total amount color
            ),
          ),
          // The progress fill with clipping for the text inside it
          ClipRect(
            child: Align(
              alignment: Directionality.of(context) == TextDirection.rtl
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              widthFactor: safePercent,
              child: Container(
                width: double
                    .infinity, // Ensure the container takes full width before clipping
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Align(
                  alignment: Alignment.center,
                  // The text inside the filled portion (always white)
                  child: buildTextRow(
                    Colors.white,
                    Colors.white,
                    Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // Percentage badge floating in the middle
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.cardColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '${(safePercent * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteContactTitle),
        content: Text(l10n.deleteContactConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                final repository = ref.read(contactsRepositoryProvider);
                await repository.deleteContact(contactUuid);
                if (context.mounted) {
                  Navigator.pop(dialogContext); // Close dialog
                  Navigator.pop(context); // Close details screen
                  ToastUtils.showSuccessToast(
                      context, ref, l10n.contactDeletedSuccessfully);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  ToastUtils.showErrorToast(
                      context, ref, l10n.errorOccurred(e.toString()));
                }
              }
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _BulkSettleSheetContent extends StatefulWidget {
  const _BulkSettleSheetContent({
    required this.contactUuid,
    required this.absNet,
    required this.isNetReceivable,
    required this.service,
    required this.l10n,
    required this.ref,
  });

  final String contactUuid;
  final double absNet;
  final bool isNetReceivable;
  final ContactBulkSettlementService service;
  final AppLocalizations l10n;
  final WidgetRef ref;

  @override
  State<_BulkSettleSheetContent> createState() =>
      _BulkSettleSheetContentState();
}

class _BulkSettleSheetContentState extends State<_BulkSettleSheetContent> {
  late final TextEditingController _amountController;
  double _currentAmount = 0.0;
  Account? _selectedAccount;

  double get _remainingAmount {
    final remaining = widget.absNet - _currentAmount;
    return remaining < 0 ? 0 : remaining;
  }

  @override
  void initState() {
    super.initState();
    // Start with empty amount; user can enter or use "Settle All"
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyAsync = widget.ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.absNet == 0
                    ? widget.l10n.bulkProcessInBulk
                    : widget.isNetReceivable
                        ? widget.l10n.receivable
                        : widget.l10n.payable,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Remaining net balance summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: widget.isNetReceivable
                  ? AppColors.receivableGradient
                  : AppColors.payableGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.l10n.remainingNetBalance,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  AmountFormatter.formatWithCurrency(
                    _remainingAmount,
                    currency,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (widget.absNet > 0) ...[
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: widget.l10n.amount,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                final parsed = double.tryParse(value.trim()) ?? 0;
                setState(() {
                  _currentAmount = parsed;
                });
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _currentAmount = widget.absNet;
                    _amountController.text =
                        widget.absNet.toStringAsFixed(currency.decimalPlaces);
                  });
                },
                child: Text(widget.l10n.settleAll),
              ),
            ),
          ],

          // Account picker
          const SizedBox(height: 12),
          Text(
            widget.l10n.settlementAccount,
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 6),
          AccountPickerField(
            selectedAccount: _selectedAccount,
            excludeCreditCard: widget.isNetReceivable,
            onChanged: (acc) => setState(() => _selectedAccount = acc),
            label: widget.l10n.settlementAccount,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.l10n.accountPickerInfoMessage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                try {
                  if (widget.absNet == 0) {
                    await widget.service.settleAll(
                      widget.contactUuid,
                      outgoingAccountUuid: _selectedAccount?.uuid,
                      incomingAccountUuid: _selectedAccount?.uuid,
                    );
                  } else {
                    final raw = _amountController.text.trim();
                    final parsed = double.tryParse(raw) ?? 0;
                    if (parsed <= 0) {
                      ToastUtils.showErrorToast(
                        context,
                        widget.ref,
                        widget.l10n.errorOccurred('Invalid amount'),
                      );
                      return;
                    }
                    await widget.service.settleAmount(
                      widget.contactUuid,
                      parsed,
                      isNetReceivable: widget.isNetReceivable,
                      outgoingAccountUuid: _selectedAccount?.uuid,
                      incomingAccountUuid: _selectedAccount?.uuid,
                    );
                  }
                  if (mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                  if (context.mounted) {
                    ToastUtils.showErrorToast(
                      context,
                      widget.ref,
                      widget.l10n.errorOccurred(e.toString()),
                    );
                  }
                }
              },
              child: Text(widget.l10n.confirm),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _ContactNavTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ContactNavTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
