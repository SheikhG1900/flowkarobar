import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:flowpaisa/features/accounts/presentation/screens/add_edit_account_screen.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/account_transfer_sheet.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/transfer_account_box.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/app_floating_action_button.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:material_symbols_icons/symbols.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(accountsWithBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accounts),
        actions: [
          IconButton(
            icon: const Icon(Symbols.swap_horiz),
            tooltip: l10n.transferMoney,
            onPressed: () => _showTransferSheet(context),
          ),
        ],
      ),
      body: accountsAsync.when(
          data: (accounts) {
            if (accounts.isEmpty) {
              return _EmptyAccountsView(
                  onAddTap: () => _goToAddAccount(context));
            }

            final regularAccounts = accounts
                .where((a) => a.type != AccountType.creditCard)
                .toList();
            final creditCardAccounts = accounts
                .where((a) => a.type == AccountType.creditCard)
                .toList();

            return ListView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 80,
              ),
              children: [
                // Net Worth summary card
                _NetWorthCard(accounts: accounts),
                const SizedBox(height: 20),

                if (regularAccounts.isNotEmpty) ...[
                  _SectionHeader(title: l10n.accounts),
                  const SizedBox(height: 8),
                  ...regularAccounts.map((awb) => _AccountCard(
                        awb: awb,
                        onTap: () => _goToDetail(context, awb.account),
                      )),
                ],

                if (creditCardAccounts.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _SectionHeader(title: l10n.creditCards),
                  const SizedBox(height: 8),
                  ...creditCardAccounts.map((awb) => _AccountCard(
                        awb: awb,
                        onTap: () => _goToDetail(context, awb.account),
                      )),
                ],
                const SizedBox(height: 20),
                _RecentTransfersSection(),
              ],
            );
          },
          loading: () => const AppLoadingIndicator(),
          error: (e, _) => Center(
              child: Text(
                  AppLocalizations.of(context)!.errorOccurred(e.toString()))),
        ),
      floatingActionButton: AppFloatingActionButton(
        onPressed: () => _goToAddAccount(context),
        tooltip: l10n.addAccount,
        child: Icon(
          Icons.add,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  void _goToAddAccount(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditAccountScreen()),
    );
  }

  void _goToDetail(BuildContext context, Account account) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AccountDetailScreen(accountUuid: account.uuid)),
    );
  }

  void _showTransferSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AccountTransferSheet(),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Net Worth summary — receivable / income / payable palette
// ────────────────────────────────────────────────────────────
class _NetWorthItem extends StatelessWidget {
  final String label;
  final double amount;
  final String symbol;
  final int decimals;
  final Color accentColor;

  const _NetWorthItem({
    required this.label,
    required this.amount,
    required this.symbol,
    required this.decimals,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseAmountSize = 36.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Symbols.account_balance,
                  color: accentColor,
                  size: 18,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AmountFormatter.formatWithCurrency(amount, symbol, decimals),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
              height: 1.15,
              fontSize: AmountFormatter.getFontSize(
                amount,
                baseSize: baseAmountSize,
                decimalPlaces: decimals,
              ),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _NetWorthCard extends ConsumerWidget {
  final List<AccountWithBalance> accounts;
  const _NetWorthCard({required this.accounts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final symbol = ref.watch(currencySymbolProvider);
    final decimals = ref.watch(currencyDecimalPlacesProvider);

    final totalAssets = accounts
        .where((a) => !a.type.balanceIsLiability)
        .fold<double>(0, (sum, a) => sum + a.balance.clamp(0, double.infinity));
    final totalLiabilities = accounts
        .where((a) => a.type.balanceIsLiability)
        .fold<double>(0, (sum, a) => sum + a.balance.abs());
    final netWorth = totalAssets - totalLiabilities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NetWorthItem(
          label: l10n.netWorth,
          amount: netWorth,
          symbol: symbol,
          decimals: decimals,
          accentColor: AppColors.receivableColor,
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatItem(
                  color: AppColors.incomeColor,
                  icon: Symbols.trending_up,
                  label: l10n.totalAssets,
                  amount: totalAssets,
                  symbol: symbol,
                  decimals: decimals,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatItem(
                  color: AppColors.payableColor,
                  icon: Symbols.trending_down,
                  label: l10n.totalLiabilities,
                  amount: totalLiabilities,
                  symbol: symbol,
                  decimals: decimals,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final double amount;
  final String symbol;
  final int decimals;

  const _StatItem({
    required this.color,
    required this.icon,
    required this.label,
    required this.amount,
    required this.symbol,
    required this.decimals,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AmountFormatter.formatWithCurrency(amount, symbol, decimals),
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Section header row
// ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Individual account card — mirrors contact card style
// ────────────────────────────────────────────────────────────
class _AccountCard extends ConsumerWidget {
  final AccountWithBalance awb;
  final VoidCallback onTap;

  const _AccountCard({required this.awb, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final symbol = ref.watch(currencySymbolProvider);
    final decimals = ref.watch(currencyDecimalPlacesProvider);
    final acc = awb.account;
    final type = awb.type;

    final accountColor = acc.color != null
        ? Color(int.parse(acc.color!.replaceAll('#', '0xFF')))
        : theme.colorScheme.primary;
    final iconData = IconHelper.getIconData(acc.icon) ?? _defaultIcon(type);

    final bool isNegative = awb.balance < 0;
    // Credit card overpaid (balance > 0): show as income color (bank owes you)
    // Credit card normal outstanding (balance <= 0): show as expense color
    // Other accounts: negative = expense color, positive = income color
    final Color balanceColor = type.isCreditCard
        ? (awb.creditBalance > 0 ? AppColors.incomeColor : AppColors.expenseColor)
        : (isNegative ? AppColors.expenseColor : AppColors.incomeColor);

    final String balanceText = type.isCreditCard
        ? (awb.creditBalance > 0
            // Overpaid: show as positive credit balance
            ? AmountFormatter.formatWithCurrency(awb.creditBalance, symbol, decimals)
            // Normal: show outstanding as (amount)
            : '($symbol${AmountFormatter.formatAmount(awb.balance.abs(), decimals)})')
        : AmountFormatter.formatWithCurrency(awb.balance, symbol, decimals);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppColors.transactionListItemDecoration(
            theme,
            accountColor,
          ),
          child: Row(
            children: [
              // Account icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accountColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(iconData, color: accountColor, size: 24),
              ),
              const SizedBox(width: 16),

              // Name & type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      acc.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _typeLabel(l10n, type),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (type.isCreditCard && (awb.dueAmount ?? 0.0) > 0) ...[
                      const SizedBox(height: 4),
                      _DueBadge(
                          dueAmount: awb.dueAmount ?? 0.0,
                          symbol: symbol,
                          decimals: decimals),
                    ],
                  ],
                ),
              ),

              // Balance
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    balanceText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: balanceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (type.isCreditCard &&
                      (acc.creditLimit ?? 0) > 0 &&
                      awb.availableCredit != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${AmountFormatter.formatWithCurrency(awb.availableCredit!, symbol, decimals)} ${l10n.available}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.incomeColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Icon(Icons.chevron_right,
                      size: 18, color: theme.colorScheme.onSurfaceVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _defaultIcon(AccountType type) {
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

  String _typeLabel(AppLocalizations l10n, AccountType type) {
    switch (type) {
      case AccountType.cash:
        return l10n.cash;
      case AccountType.bank:
        return l10n.bank;
      case AccountType.savings:
        return l10n.savings;
      case AccountType.creditCard:
        return l10n.creditCard;
    }
  }
}

class _DueBadge extends StatelessWidget {
  final double dueAmount;
  final String symbol;
  final int decimals;

  const _DueBadge({
    required this.dueAmount,
    required this.symbol,
    required this.decimals,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.expenseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${l10n.due}: ${AmountFormatter.formatWithCurrency(dueAmount, symbol, decimals)}',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.expenseColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Empty state
// ────────────────────────────────────────────────────────────
class _EmptyAccountsView extends StatelessWidget {
  final VoidCallback onAddTap;
  const _EmptyAccountsView({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.account_balance_wallet,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noAccounts,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noAccountsDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAddTap,
              icon: const Icon(Icons.add),
              label: Text(l10n.addAccount),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Recent transfers (accounts screen)
// ────────────────────────────────────────────────────────────
const _recentTransfersLimit = 15;

class _RecentTransfersSection extends ConsumerWidget {
  const _RecentTransfersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final transfersAsync = ref.watch(allTransfersWithDetailsProvider);
    final cashbookAccent = ref.watch(activeCashbookProvider).color;

    return transfersAsync.when(
      data: (list) {
        final recent = list.take(_recentTransfersLimit).toList();
        if (recent.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: l10n.recentTransfers),
            const SizedBox(height: 8),
            for (var i = 0; i < recent.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              Container(
                decoration: AppColors.transactionListItemDecoration(
                  theme,
                  cashbookAccent,
                ),
                child: _TransferRow(details: recent[i]),
              ),
            ],
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _TransferRow extends ConsumerWidget {
  final AccountTransferWithDetails details;

  const _TransferRow({required this.details});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final symbol = ref.watch(currencySymbolProvider);
    final decimals = ref.watch(currencyDecimalPlacesProvider);
    final dateFormat = ref.watch(userProfileProvider).dateFormat;
    final t = details.transfer;
    final desc = t.description?.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    TransferAccountBox(
                      account: details.fromAccount,
                      theme: theme,
                      arrowBesideIcon: true,
                      showBorder: false,
                      onAccountTap: details.fromAccount != null
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AccountDetailScreen(
                                    accountUuid: details.fromAccount!.uuid,
                                  ),
                                ),
                              )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    TransferAccountBox(
                      account: details.toAccount,
                      theme: theme,
                      showBorder: false,
                      onAccountTap: details.toAccount != null
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AccountDetailScreen(
                                    accountUuid: details.toAccount!.uuid,
                                  ),
                                ),
                              )
                          : null,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AmountFormatter.formatWithCurrency(t.amount, symbol, decimals),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppDateFormatter.formatDate(t.date, pattern: dateFormat),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (desc != null && desc.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Symbols.notes,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    desc,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
