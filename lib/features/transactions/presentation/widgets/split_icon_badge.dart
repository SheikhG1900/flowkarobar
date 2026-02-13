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
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }
}
