import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PremiumBadge extends StatelessWidget {
  final bool isSmall;
  final bool isLarge;
  final bool showLock;
  final String? text;

  const PremiumBadge({
    super.key,
    this.isSmall = false,
    this.isLarge = false,
    this.showLock = false,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double paddingHorizontal = 8;
    double paddingVertical = 4;
    double fontSize = 12;
    double iconSize = 12;

    if (isSmall) {
      paddingHorizontal = 6;
      paddingVertical = 2;
      fontSize = 10;
      iconSize = 12;
    } else if (isLarge) {
      paddingHorizontal = 12;
      paddingVertical = 6;
      fontSize = 14;
      iconSize = 16;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: paddingVertical,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showLock) ...[
            Icon(
              Icons.lock_outline,
              size: iconSize,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text ?? l10n.proLabel,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: isSmall ? FontWeight.normal : FontWeight.bold,
              letterSpacing: 0.5,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
