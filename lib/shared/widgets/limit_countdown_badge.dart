import 'package:flutter/material.dart';

class LimitCountdownBadge extends StatelessWidget {
  final int? dailyUsed;
  final int? dailyTotal;
  final int? monthlyUsed;
  final int? monthlyTotal;
  final int? totalUsed;
  final int? totalLimit;
  final VoidCallback? onLimitReached;

  const LimitCountdownBadge({
    super.key,
    this.dailyUsed,
    this.dailyTotal,
    this.monthlyUsed,
    this.monthlyTotal,
    this.totalUsed,
    this.totalLimit,
    this.onLimitReached,
  });

  @override
  Widget build(BuildContext context) {
    // Determine which mode to use
    if (totalUsed != null && totalLimit != null) {
      return _buildSingleChip(context, totalUsed!, totalLimit!);
    } else if (dailyUsed != null &&
        dailyTotal != null &&
        monthlyUsed != null &&
        monthlyTotal != null) {
      return _buildDualChips(
          context, dailyUsed!, dailyTotal!, monthlyUsed!, monthlyTotal!);
    }
    return const SizedBox.shrink();
  }

  Widget _buildSingleChip(BuildContext context, int used, int total) {
    if (used >= total) {
      return _buildLimitReachedChip(context);
    }

    final color = _getProgressColor(used, total);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '$used/$total remaining',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDualChips(BuildContext context, int dailyUsed, int dailyTotal,
      int monthlyUsed, int monthlyTotal) {
    if (dailyUsed >= dailyTotal || monthlyUsed >= monthlyTotal) {
      return _buildLimitReachedChip(context);
    }

    final dailyColor = _getProgressColor(dailyUsed, dailyTotal);
    final monthlyColor = _getProgressColor(monthlyUsed, monthlyTotal);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMiniChip(
          context,
          Icons.calendar_today,
          '$dailyUsed/$dailyTotal daily',
          dailyColor,
        ),
        const SizedBox(width: 8),
        _buildMiniChip(
          context,
          Icons.date_range,
          '$monthlyUsed/$monthlyTotal monthly',
          monthlyColor,
        ),
      ],
    );
  }

  Widget _buildMiniChip(
      BuildContext context, IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitReachedChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.red.withValues(alpha: 0.5), width: 1.5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red),
          SizedBox(width: 6),
          Text(
            'Limit Reached',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Color based on usage percentage (not remaining)
  /// < 50% used = green
  /// 50-80% used = orange
  /// > 80% used = red
  Color _getProgressColor(int used, int total) {
    final percentage = used / total;
    if (percentage < 0.5) return Colors.green;
    if (percentage < 0.8) return Colors.orange;
    return Colors.red;
  }
}
