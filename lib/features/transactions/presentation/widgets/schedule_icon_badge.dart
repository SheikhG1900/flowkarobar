import 'package:flutter/material.dart';

/// Small schedule icon on the card corner (top-right corner in LTR, same appearance as account and tag badges).
class ScheduleIconBadge extends StatelessWidget {
  const ScheduleIconBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);
    final accent = Colors.blue;

    return Positioned(
      key: key,
      top: -6,
      right: isRtl ? null : -8,
      left: isRtl ? -8 : null,
      child: Opacity(
        key: key != null ? ValueKey('${(key as ValueKey).value}-opacity') : null,
        opacity: 1.0,
        child: Container(
          key: key != null ? ValueKey('${(key as ValueKey).value}-container') : null,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: theme.cardColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: accent.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            key: key != null ? ValueKey('${(key as ValueKey).value}-icon') : null,
            Icons.schedule,
            size: 22,
            color: accent,
          ),
        ),
      ),
    );
  }
}
