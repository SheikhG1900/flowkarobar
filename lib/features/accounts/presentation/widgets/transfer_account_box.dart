import 'package:flutter/material.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Box showing account icon (above) and name (below) in the account's color.
/// Used in transfer list rows.
class TransferAccountBox extends StatelessWidget {
  final Account? account;
  final ThemeData theme;

  /// When true, shows [icon] [→] in one row, then name below (for "from" account).
  final bool arrowBesideIcon;

  /// When true, only icon (and arrow if [arrowBesideIcon]) — no name line.
  final bool hideName;

  /// Opens account detail when set (only for boxes that show the account name).
  final VoidCallback? onAccountTap;

  const TransferAccountBox({
    super.key,
    required this.account,
    required this.theme,
    this.arrowBesideIcon = false,
    this.hideName = false,
    this.onAccountTap,
  });

  /// Icon for list rows, pickers, etc. (custom icon or default by account type).
  static IconData iconForAccount(Account? account) {
    if (account == null) return Symbols.account_balance_wallet;
    final icon = IconHelper.getIconData(account.icon);
    if (icon != null) return icon;
    return _defaultIcon(AccountType.fromValue(account.type));
  }

  static IconData _defaultIcon(AccountType type) {
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

  /// Parsed account color, or theme primary when missing / invalid.
  static Color accentColorFor(Account account, ThemeData theme) {
    if (account.color != null) {
      try {
        return Color(int.parse(account.color!.replaceAll('#', '0xFF')));
      } catch (_) {}
    }
    return theme.colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final name = account?.name ?? '?';
    final color = account != null
        ? accentColorFor(account!, theme)
        : theme.colorScheme.primary;
    final iconData = iconForAccount(account);

    final box = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (arrowBesideIcon)
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconData, size: 20, color: color),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: color,
                  ),
                ),
              ],
            )
          else
            Icon(iconData, size: 20, color: color),
          if (!hideName) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: arrowBesideIcon ? 88 : 72,
              child: Text(
                name,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );

    if (onAccountTap != null && !hideName && account != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onAccountTap,
          borderRadius: BorderRadius.circular(10),
          child: box,
        ),
      );
    }
    return box;
  }
}
