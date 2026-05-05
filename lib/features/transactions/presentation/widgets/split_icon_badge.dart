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
      key: key,
      top: 8,
      right: isRtl ? 8 : null,
      left: isRtl ? null : 8,
      child: Opacity(
        key: key != null ? ValueKey('${(key as ValueKey).value}-opacity') : null,
        opacity: 0.8,
        child: Container(
          key: key != null ? ValueKey('${(key as ValueKey).value}-container') : null,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.55),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.7),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            key: key != null ? ValueKey('${(key as ValueKey).value}-icon') : null,
            icon,
            size: 0,
            color: Colors.white.withValues(alpha: 0.95),
          ),
        ),
      ),
    );
  }
}
