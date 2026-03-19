import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/account_transfer_sheet.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

class PayBillSheet extends ConsumerWidget {
  final AccountWithBalance creditCard;

  const PayBillSheet({super.key, required this.creditCard});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final symbol = ref.watch(currencySymbolProvider);
    final decimals = ref.watch(currencyDecimalPlacesProvider);
    final isLight = theme.brightness == Brightness.light;
    final sheetBg = isLight ? Colors.white : theme.scaffoldBackgroundColor;

    final accountsAsync = ref.watch(accountsWithBalanceProvider);

    final cardColor = creditCard.account.color != null
        ? Color(int.parse(creditCard.account.color!.replaceAll('#', '0xFF')))
        : theme.colorScheme.primary;

    // Amount to pay: dueAmount if available, else full outstanding
    final payAmount = (creditCard.dueAmount ?? 0) > 0
        ? creditCard.dueAmount!
        : (creditCard.balance < 0 ? creditCard.balance.abs() : 0.0);

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.payBill,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.payingAmount(AmountFormatter.formatWithCurrency(
                          payAmount, symbol, decimals)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cardColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Account list
          Flexible(
            child: accountsAsync.when(
              data: (list) {
                final payableAccounts = list
                    .where((awb) =>
                        !awb.type.isCreditCard &&
                        awb.account.uuid != creditCard.account.uuid)
                    .toList();

                if (payableAccounts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Symbols.account_balance_wallet,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noBankAccountsToPayFrom,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    top: 8,
                    bottom: MediaQuery.of(context).padding.bottom + 8,
                  ),
                  children: [
                    // Pay from label
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                      child: Text(
                        l10n.payFrom,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    // Bank / savings accounts
                    ...payableAccounts
                        .map((awb) => _AccountTile(
                              awb: awb,
                              symbol: symbol,
                              decimals: decimals,
                              onTap: () => _payFromAccount(
                                context,
                                ref,
                                awb,
                                payAmount,
                                l10n,
                              ),
                            ))
                        .toList(),

                    const Divider(height: 24, indent: 20, endIndent: 20),

                    // Custom payment option
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Symbols.tune,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        l10n.customPayment,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        l10n.customPaymentHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onTap: () => _openCustomPayment(context, ref),
                    ),

                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 8),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _payFromAccount(
    BuildContext context,
    WidgetRef ref,
    AccountWithBalance fromAccount,
    double amount,
    AppLocalizations l10n,
  ) async {
    Navigator.pop(context); // close sheet immediately

    if (amount <= 0) {
      ToastUtils.showErrorToast(context, ref, l10n.customPaymentHint);
      return;
    }

    try {
      final repo = ref.read(accountsRepositoryProvider);
      final now = DateTime.now();
      await repo.createTransfer(
        AccountTransfersCompanion.insert(
          uuid: const Uuid().v4(),
          fromAccountUuid: fromAccount.account.uuid,
          toAccountUuid: creditCard.account.uuid,
          amount: amount,
          date: now,
          description: const drift.Value(null),
          createdAt: drift.Value(now),
          updatedAt: drift.Value(now),
        ),
      );
      if (context.mounted) {
        ToastUtils.showSuccessToast(context, ref, l10n.transferCreated);
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(
          context,
          ref,
          AppLocalizations.of(context)!.errorOccurred(e.toString()),
        );
      }
    }
  }

  void _openCustomPayment(BuildContext context, WidgetRef ref) {
    Navigator.pop(context); // close Pay Bill sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AccountTransferSheet(
        preselectedToUuid: creditCard.account.uuid,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Single account tile
// ─────────────────────────────────────────────────────────
class _AccountTile extends StatelessWidget {
  final AccountWithBalance awb;
  final String symbol;
  final int decimals;
  final VoidCallback onTap;

  const _AccountTile({
    required this.awb,
    required this.symbol,
    required this.decimals,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final acc = awb.account;
    final accountColor = acc.color != null
        ? Color(int.parse(acc.color!.replaceAll('#', '0xFF')))
        : theme.colorScheme.primary;

    final iconData = IconHelper.getIconData(acc.icon) ??
        _typeIcon(AccountType.fromValue(acc.type));

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: accountColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(iconData, color: accountColor, size: 22),
      ),
      title: Text(
        acc.name,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        AmountFormatter.formatWithCurrency(awb.balance, symbol, decimals),
        style: theme.textTheme.bodySmall?.copyWith(
          color: awb.balance >= 0
              ? AppColors.incomeColor
              : AppColors.expenseColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  IconData _typeIcon(AccountType type) {
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
}
