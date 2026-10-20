import 'package:flutter/material.dart';
import 'corner_badge_container.dart';

/// Small schedule icon on the card corner (top-right corner in LTR, same appearance as account and tag badges).
class ScheduleIconBadge extends StatelessWidget {
  const ScheduleIconBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final accent = Colors.blue;

    return Positioned(
      key: key,
      top: -6,
      right: isRtl ? null : -8,
      left: isRtl ? -8 : null,
      child: Opacity(
        key: key != null ? ValueKey('${(key as ValueKey).value}-opacity') : null,
        opacity: 1.0,
        child: CornerBadgeContainer(
          containerKey: key != null ? ValueKey('${(key as ValueKey).value}-container') : null,
          accentColor: accent,
          padding: const EdgeInsets.all(2),
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
