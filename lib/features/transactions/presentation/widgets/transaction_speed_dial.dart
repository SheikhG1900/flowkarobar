import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';

class TransactionSpeedDial extends ConsumerStatefulWidget {
  final VoidCallback onAddTransaction;
  final VoidCallback onVoiceAdd;
  final VoidCallback onScanReceipt;
  final VoidCallback onBulkImport;
  final Color activeColor;

  const TransactionSpeedDial({
    super.key,
    required this.onAddTransaction,
    required this.onVoiceAdd,
    required this.onScanReceipt,
    required this.onBulkImport,
    required this.activeColor,
  });

  @override
  ConsumerState<TransactionSpeedDial> createState() => _TransactionSpeedDialState();
}

class _TransactionSpeedDialState extends ConsumerState<TransactionSpeedDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeCashbook = ref.watch(activeCashbookProvider);
    final activeColor = activeCashbook.color;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isExpanded)
          GestureDetector(
            onTap: _toggle,
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStep(
                index: 2,
                label: 'Bulk Import',
                icon: Icons.backup_table,
                color: isDark
                    ? theme.colorScheme.secondaryContainer
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                iconColor: isDark
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.primary,
                size: 40,
                onTap: () {
                  _toggle();
                  widget.onBulkImport();
                },
              ),
              const SizedBox(height: 16),
              _buildStep(
                index: 1,
                label: 'Scan Receipt',
                icon: Icons.document_scanner_outlined,
                color: isDark
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                iconColor: isDark
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.primary,
                size: 48,
                onTap: () {
                  _toggle();
                  widget.onScanReceipt();
                },
              ),
              const SizedBox(height: 16),
              _buildStep(
                index: 0,
                label: 'Voice Add',
                icon: Icons.mic_none_rounded,
                color: widget.activeColor,
                iconColor: Colors.white,
                size: 56,
                onTap: () {
                  _toggle();
                  widget.onVoiceAdd();
                },
              ),
              const SizedBox(height: 16),
              // Split Main Button
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(32),
                color: widget.activeColor,
                shadowColor: widget.activeColor.withValues(alpha: 0.4),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Primary Action: Add Transaction
                      InkWell(
                        onTap: widget.onAddTransaction,
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(32)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add,
                                  color: Colors.white, size: 24),
                              const SizedBox(width: 8),
                              const Text(
                                'Add',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Vertical Divider
                      Container(
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.2),
                        margin: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      // Toggle Expansion Arrow
                      InkWell(
                        onTap: _toggle,
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(32)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _controller.value * math.pi, // 180 degrees
                                child: const Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep({
    required int index,
    required String label,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required double size,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final labelBgColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.9)
        : theme.colorScheme.onSurface.withValues(alpha: 0.85);
    final labelTextColor = isDark ? theme.colorScheme.onSurface : Colors.white;

    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        index * 0.1,
        1.0,
        curve: Curves.easeOutBack,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double value = animation.value;
        if (value == 0 && !_isExpanded) return const SizedBox.shrink();

        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: Transform.scale(
              scale: value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: labelBgColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: labelTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: size,
                    height: size,
                    child: FloatingActionButton(
                      heroTag: 'speed_dial_$index',
                      onPressed: onTap,
                      backgroundColor: isDark ? color : theme.cardColor,
                      elevation: 3,
                      highlightElevation: 4,
                      disabledElevation: 0,
                      focusElevation: 4,
                      hoverElevation: 4,
                      splashColor: iconColor.withValues(alpha: 0.1),
                      shape: CircleBorder(
                        side: isDark
                            ? BorderSide.none
                            : BorderSide(
                                color: iconColor.withValues(alpha: 0.15),
                                width: 1,
                              ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (!isDark)
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                              ),
                            ),
                          Icon(icon, color: iconColor, size: size * 0.45),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
