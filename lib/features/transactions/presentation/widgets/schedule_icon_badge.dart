import 'package:flutter/material.dart';

class ScheduleIconBadge extends StatelessWidget {
  const ScheduleIconBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Positioned(
      top: 8,
      left: isRtl ? 8 : null,
      right: isRtl ? null : 8,
      child: Opacity(
        opacity: 0.8,
        child: Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.55),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.7),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.schedule_outlined,
            size: 28,
            color: Colors.white.withValues(alpha: 0.95),
          ),
        ),
      ),
    );
  }
}
