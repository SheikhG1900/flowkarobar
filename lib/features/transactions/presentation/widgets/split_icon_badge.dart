import 'package:flutter/material.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';

class SplitIconBadge extends StatelessWidget {
  final String groupId;

  const SplitIconBadge({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    final icon = IconHelper.getGroupIcon(groupId);
    final color = AppColors.getContactColor(groupId);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Positioned(
      top: 8,
      right: isRtl ? 8 : null,
      left: isRtl ? null : 8,
      child: Opacity(
        opacity: 0.8,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.55),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.7),
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
            icon,
            size: 28,
            color: Colors.white.withValues(alpha: 0.95),
          ),
        ),
      ),
    );
  }
}
