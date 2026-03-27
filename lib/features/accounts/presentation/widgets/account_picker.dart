import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/screens/add_edit_account_screen.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/dual_amount_progress_bar.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Non-null when the user confirmed a choice (including explicit "No account").
/// `null` when the sheet was dismissed (close / drag) without confirming.
class _AccountPickResult {
  final Account? account;
  const _AccountPickResult(this.account);
}

/// Opens [AddEditAccountScreen]; refreshes providers and calls [onCreated] with
/// the new row. When [excludeCreditCard] is true, new credit card accounts are
/// rejected (e.g. income / receive-into pickers).
Future<void> navigateToAddAccountAndSelect({
  required BuildContext context,
  required WidgetRef ref,
  required bool excludeCreditCard,
  required void Function(Account account) onCreated,
}) async {
  // Check limits before allowing navigation to add account
  final limits = await PremiumGate.getAccountLimits(ref);
  if (!limits.canAdd) {
    if (context.mounted) {
      PremiumGate.showPremiumDialog(context);
    }
    return;
  }

  if (!context.mounted) return;

  final newAccount = await Navigator.of(context).push<Account?>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const AddEditAccountScreen(),
    ),
  );
  if (newAccount == null || !context.mounted) return;
  if (excludeCreditCard &&
      AccountType.fromValue(newAccount.type).isCreditCard) {
    ToastUtils.showErrorToast(
      context,
      ref,
      AppLocalizations.of(context)!.creditCardNotAllowedForReceive,
    );
    return;
  }
  ref.invalidate(accountsStreamProvider);
  ref.invalidate(accountsWithBalanceProvider);
  onCreated(newAccount);
}

Color _accountPickerAccent(Account account, ThemeData theme) {
  final hex = account.color;
  if (hex != null && hex.isNotEmpty) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (_) {}
  }
  return theme.colorScheme.primary;
}

/// Reusable inline account selection field — matches app's selector tile style.
class AccountPickerField extends ConsumerWidget {
  final Account? selectedAccount;
  final ValueChanged<Account?> onChanged;
  final bool excludeCreditCard;
  final String? label;
  /// If set, this account uuid is excluded from the picker list (e.g. the other side in a transfer).
  final String? excludeAccountUuid;

  /// Overrides default surface fill (e.g. white tiles on transfer sheet).
  final Color? surfaceColor;

  const AccountPickerField({
    super.key,
    required this.selectedAccount,
    required this.onChanged,
    this.excludeCreditCard = false,
    this.label,
    this.excludeAccountUuid,
    this.surfaceColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasAccounts = ref.watch(hasAccountsProvider);

    final sectionColor = theme.colorScheme.primary;
    final isSelected = selectedAccount != null;
    final accent =
        isSelected ? _accountPickerAccent(selectedAccount!, theme) : null;
    final fill = surfaceColor ?? theme.colorScheme.surface;
    final iconCircleBg = isSelected
        ? accent!.withValues(alpha: 0.12)
        : (surfaceColor != null
            ? sectionColor.withValues(alpha: 0.07)
            : theme.colorScheme.surfaceContainerHighest);

    return InkWell(
      onTap: () => _showPicker(context, ref),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accent! : theme.dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: isSelected
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconCircleBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: isSelected
                      ? Icon(
                          _accountIcon(selectedAccount!),
                          color: accent,
                          size: 20,
                        )
                      : Icon(
                          Symbols.account_balance_wallet,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: isSelected
                      ? _SelectedAccountInfo(
                          account: selectedAccount!,
                          nameColor: accent!,
                          label: label,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label ?? l10n.account,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hasAccounts
                                  ? l10n.noAccountSelected
                                  : l10n.noAccounts,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                ),
                if (isSelected)
                  IconButton(
                    icon: Icon(Icons.close, size: 20, color: accent),
                    onPressed: () => onChanged(null),
                  )
                else
                  const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            if (isSelected)
              _SelectedAccountProgressBar(
                account: selectedAccount!,
                accentColor: accent!,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPicker(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<_AccountPickResult?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AccountPickerSheet(
        selectedAccount: selectedAccount,
        excludeCreditCard: excludeCreditCard,
        excludeAccountUuid: excludeAccountUuid,
      ),
    );
    if (result != null) {
      onChanged(result.account);
    }
  }

  IconData _accountIcon(Account account) {
    final icon = IconHelper.getIconData(account.icon);
    if (icon != null) return icon;
    return _defaultIcon(AccountType.fromValue(account.type));
  }

  IconData _defaultIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:        return Symbols.payments;
      case AccountType.bank:        return Symbols.account_balance;
      case AccountType.savings:     return Symbols.savings;
      case AccountType.creditCard:  return Symbols.credit_card;
    }
  }
}

class _SelectedAccountInfo extends ConsumerWidget {
  final Account account;
  final Color nameColor;
  final String? label;

  const _SelectedAccountInfo({
    required this.account,
    required this.nameColor,
    this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final symbol = ref.watch(currencySymbolProvider);
    final decimals = ref.watch(currencyDecimalPlacesProvider);
    final repo = ref.watch(accountsRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<double>(
      future: repo.getAccountBalance(account),
      builder: (context, snapshot) {
        final balance = snapshot.data ?? 0.0;
        final isNegative = balance < 0;
        final type = AccountType.fromValue(account.type);
        final balanceColor = type.isCreditCard || isNegative
            ? AppColors.expenseColor
            : AppColors.incomeColor;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label ?? l10n.account,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    account.name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: nameColor,
                    ),
                  ),
                ),
                if (snapshot.hasData)
                  Text(
                    AmountFormatter.formatWithCurrency(
                      balance.abs() * (isNegative || type.isCreditCard ? -1 : 1),
                      symbol,
                      decimals,
                    ),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: balanceColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SelectedAccountProgressBar extends ConsumerWidget {
  final Account account;
  final Color accentColor;

  const _SelectedAccountProgressBar({
    required this.account,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);
    final decimals = ref.watch(currencyDecimalPlacesProvider);
    final repo = ref.watch(accountsRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final type = AccountType.fromValue(account.type);

    if (!type.isCreditCard) return const SizedBox.shrink();

    return FutureBuilder<AccountWithBalance?>(
      future: repo.getAllAccountsWithBalance().then((list) =>
          list.where((a) => a.account.uuid == account.uuid).firstOrNull),
      builder: (context, snapshot) {
        final awb = snapshot.data;
        if (awb == null || (awb.account.creditLimit ?? 0) <= 0) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: DualAmountProgressBar(
            leftLabel: l10n.outstanding,
            leftAmount: awb.balance < 0 ? awb.balance.abs() : 0.0,
            rightLabel: l10n.availableCredit,
            rightAmount: awb.availableCredit ?? 0.0,
            symbol: symbol,
            decimals: decimals,
            filledColor: awb.balance < 0 &&
                    awb.balance.abs() / (awb.account.creditLimit ?? 1) > 0.8
                ? AppColors.expenseColor
                : accentColor,
            compact: true,
          ),
        );
      },
    );
  }
}

/// Bottom sheet for picking an account — styled to match app sheets.
///
/// Pops [_AccountPickResult] when the user picks an option; pops `null` if dismissed.
class AccountPickerSheet extends ConsumerWidget {
  final Account? selectedAccount;
  final bool excludeCreditCard;
  final String? infoMessage;
  /// If set, account with this uuid is excluded from the list.
  final String? excludeAccountUuid;

  const AccountPickerSheet({
    super.key,
    this.selectedAccount,
    this.excludeCreditCard = false,
    this.infoMessage,
    this.excludeAccountUuid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(accountsWithBalanceProvider);

    void pick(Account? account) {
      Navigator.of(context).pop(_AccountPickResult(account));
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      l10n.selectAccount,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: accountsAsync.when(
                data: (accounts) {
                  var filtered = excludeCreditCard
                      ? accounts
                          .where((a) =>
                              AccountType.fromValue(a.account.type) !=
                              AccountType.creditCard)
                          .toList()
                      : accounts;
                  if (excludeAccountUuid != null) {
                    filtered = filtered
                        .where((a) => a.account.uuid != excludeAccountUuid)
                        .toList();
                  }

                  return ListView(
                    controller: scrollController,
                    children: [
                      _AccountSheetTile(
                        icon: Symbols.block,
                        iconColor: theme.colorScheme.onSurfaceVariant,
                        title: l10n.noAccount,
                        subtitle: '',
                        balanceText: '',
                        balanceColor: Colors.transparent,
                        isSelected: selectedAccount == null,
                        onTap: () => pick(null),
                      ),
                      const Divider(height: 1, indent: 20),
                      _AccountSheetTile(
                        icon: Icons.add_circle_outline,
                        iconColor: theme.colorScheme.primary,
                        title: l10n.addAccount,
                        subtitle: '',
                        balanceText: '',
                        balanceColor: Colors.transparent,
                        isSelected: false,
                        onTap: () {
                          navigateToAddAccountAndSelect(
                            context: context,
                            ref: ref,
                            excludeCreditCard: excludeCreditCard,
                            onCreated: (acc) => pick(acc),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 20),
                      if (filtered.isEmpty && accounts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                          child: Center(
                            child: Text(
                              l10n.noAccountsDescription,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      else
                        ...filtered.map((awb) => _AccountWithBalanceTile(
                              awb: awb,
                              isSelected:
                                  selectedAccount?.uuid == awb.account.uuid,
                              onTap: () => pick(awb.account),
                            )),
                      if (infoMessage != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  infoMessage!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 16),
                    ],
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AccountSheetTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String balanceText;
  final Color balanceColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountSheetTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.balanceText,
    required this.balanceColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          )),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _AccountWithBalanceTile extends ConsumerWidget {
  final AccountWithBalance awb;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountWithBalanceTile({
    required this.awb,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final symbol = ref.watch(currencySymbolProvider);
    final decimals = ref.watch(currencyDecimalPlacesProvider);
    final acc = awb.account;
    final balance = awb.balance;
    final type = awb.type;
    final isNegative = balance < 0;

    final Color balanceColor;
    final String balanceText;
    if (type.isCreditCard) {
      balanceColor = AppColors.expenseColor;
      balanceText =
          '($symbol${AmountFormatter.formatAmount(balance.abs(), decimals)})';
    } else {
      balanceColor =
          isNegative ? AppColors.expenseColor : AppColors.incomeColor;
      balanceText = AmountFormatter.formatWithCurrency(balance, symbol, decimals);
    }

    final accountColor = acc.color != null
        ? Color(int.parse(acc.color!.replaceAll('#', '0xFF')))
        : theme.colorScheme.primary;
    final iconData =
        IconHelper.getIconData(acc.icon) ?? _defaultIcon(type);

    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accountColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(iconData, color: accountColor, size: 20),
          ),
          title: Text(
            acc.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            _typeLabel(context, type),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                balanceText,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: balanceColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_circle,
                    color: theme.colorScheme.primary, size: 22),
              ],
            ],
          ),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 20),
      ],
    );
  }

  IconData _defaultIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:        return Symbols.payments;
      case AccountType.bank:        return Symbols.account_balance;
      case AccountType.savings:     return Symbols.savings;
      case AccountType.creditCard:  return Symbols.credit_card;
    }
  }

  String _typeLabel(BuildContext context, AccountType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case AccountType.cash:        return l10n.cash;
      case AccountType.bank:        return l10n.bank;
      case AccountType.savings:     return l10n.savings;
      case AccountType.creditCard:  return l10n.creditCard;
    }
  }
}
