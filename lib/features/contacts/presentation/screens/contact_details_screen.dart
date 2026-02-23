import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
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
    final currencySymbol = ref.watch(currencySymbolProvider);
    final currencyDecimalPlaces = ref.watch(currencyDecimalPlacesProvider);

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
                    // Net Balance Card: full width, badge top-right, amount centered
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
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
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Receivable/Payable badge at top right
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
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
                              ),
                            ),
                          ),
                          // Amount and label in center
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.netBalance,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AmountFormatter.formatWithCurrency(
                                  netBalance.abs(),
                                  currencySymbol,
                                  currencyDecimalPlaces,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
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
                              currencySymbol: currencySymbol,
                              currencyDecimalPlaces: currencyDecimalPlaces,
                              onTap: () {
                                ref
                                    .read(
                                        receivablesPaginatedProvider('PENDING')
                                            .notifier)
                                    .applyFilters(
                                      ReceivableFilters(
                                        contactUuids: [contactUuid],
                                      ),
                                    );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ReceivablesListScreen(),
                                  ),
                                );
                              },
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
                              currencySymbol: currencySymbol,
                              currencyDecimalPlaces: currencyDecimalPlaces,
                              onTap: () {
                                ref
                                    .read(payablesPaginatedProvider('PENDING')
                                        .notifier)
                                    .applyFilters(
                                      PayableFilters(
                                        contactUuids: [contactUuid],
                                      ),
                                    );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PayablesListScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Info Section
                      if (contact.email != null || contact.notes != null) ...[
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
                                color:
                                    theme.dividerColor.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            children: [
                              if (contact.email != null &&
                                  contact.email!.isNotEmpty)
                                ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme
                                          .colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
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
                                      color: theme
                                          .colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.note_alt_outlined,
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

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required double amount,
    required int count,
    required Color color,
    required IconData icon,
    required String currencySymbol,
    required int currencyDecimalPlaces,
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
                currencySymbol,
                currencyDecimalPlaces,
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
