import 'package:flutter/material.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/transfer_account_box.dart';
import 'corner_badge_container.dart';

/// Small account icon on the card corner (bottom, same horizontal side as split badge in LTR).
class TransactionAccountIconBadge extends StatelessWidget {
  final Account account;
  final ThemeData theme;
  final bool isInactive;
  final double bottomOffset;
  final double horizontalOffset;

  const TransactionAccountIconBadge({
    super.key,
    required this.account,
    required this.theme,
    this.isInactive = false,
    this.bottomOffset = 0.0,
    this.horizontalOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final accent = TransferAccountBox.accentColorFor(account, theme);

    return Positioned(
      key: key,
      bottom: bottomOffset - 6,
      right: isRtl ? horizontalOffset - 8 : null,
      left: isRtl ? null : horizontalOffset - 8,
      child: Opacity(
        key: key != null ? ValueKey('${(key as ValueKey).value}-opacity') : null,
        opacity: isInactive ? 0.6 : 1.0,
        child: Tooltip(
          key: key != null ? ValueKey('${(key as ValueKey).value}-tooltip') : null,
          message: account.name,
          child: CornerBadgeContainer(
            containerKey: key != null ? ValueKey('${(key as ValueKey).value}-container') : null,
            accentColor: accent,
            padding: const EdgeInsets.all(6),
            child: Icon(
              key: key != null ? ValueKey('${(key as ValueKey).value}-icon') : null,
              TransferAccountBox.iconForAccount(account),
              size: 14,
              color: accent,
            ),
          ),
        ),
      ),
    );
  }
}
