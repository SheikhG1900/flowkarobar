import 'package:flutter/material.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/transfer_account_box.dart';

/// Small account icon on the card corner (bottom, same horizontal side as split badge in LTR).
class TransactionAccountIconBadge extends StatelessWidget {
  final Account account;
  final ThemeData theme;
  final bool isInactive;

  const TransactionAccountIconBadge({
    super.key,
    required this.account,
    required this.theme,
    this.isInactive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final accent = TransferAccountBox.accentColorFor(account, theme);

    return Positioned(
      bottom: 8,
      right: isRtl ? 8 : null,
      left: isRtl ? null : 8,
      child: Opacity(
        opacity: isInactive ? 0.25 : 0.55,
        child: Tooltip(
          message: account.name,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              TransferAccountBox.iconForAccount(account),
              size: 18,
              color: accent,
            ),
          ),
        ),
      ),
    );
  }
}
