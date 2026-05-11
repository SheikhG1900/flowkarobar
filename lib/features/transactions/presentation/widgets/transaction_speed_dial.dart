import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';

import 'package:flowpaisa/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Stack(
      key: const ValueKey('speed-dial-stack'),
      alignment: isRtl ? Alignment.bottomLeft : Alignment.bottomRight,
      children: [
        if (_isExpanded)
          GestureDetector(
            key: const ValueKey('speed-dial-overlay'),
            onTap: _toggle,
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        Padding(
          key: const ValueKey('speed-dial-padding'),
          padding: EdgeInsets.only(
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            left: isRtl ? 16 : 0,
            right: isRtl ? 0 : 16,
          ),
          child: Column(
            key: const ValueKey('speed-dial-column'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isRtl ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              _buildStep(
                key: const ValueKey('speed-dial-step-bulk'),
                index: 2,
                label: l10n.bulkImport,
                icon: Icons.backup_table,
                isRtl: isRtl,
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
                key: const ValueKey('speed-dial-step-scan'),
                index: 1,
                label: l10n.scanReceipt,
                icon: Icons.document_scanner_outlined,
                isRtl: isRtl,
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
                key: const ValueKey('speed-dial-step-voice'),
                index: 0,
                label: l10n.voiceAdd,
                icon: Icons.mic_none_rounded,
                isRtl: isRtl,
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
              Align(
                key: const ValueKey('speed-dial-main-align'),
                alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                child: Material(
                  key: const ValueKey('speed-dial-main-material'),
                  elevation: 4,
                  borderRadius: BorderRadius.circular(32),
                  color: widget.activeColor,
                  shadowColor: widget.activeColor.withValues(alpha: 0.4),
                  child: IntrinsicHeight(
                    key: const ValueKey('speed-dial-main-height'),
                    child: Row(
                      key: const ValueKey('speed-dial-main-row'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAddAction(context, l10n),
                        _buildDivider(),
                        _buildToggleArrow(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      key: const ValueKey('speed-dial-divider'),
      width: 1,
      color: Colors.white.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  Widget _buildAddAction(BuildContext context, AppLocalizations l10n) {
    return InkWell(
      key: const ValueKey('speed-dial-add-action'),
      onTap: widget.onAddTransaction,
      borderRadius: BorderRadiusDirectional.horizontal(
        start: const Radius.circular(32),
        end: Radius.zero,
      ).resolve(Directionality.of(context)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              l10n.add,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleArrow(BuildContext context) {
    return InkWell(
      key: const ValueKey('speed-dial-toggle-action'),
      onTap: _toggle,
      borderRadius: BorderRadiusDirectional.horizontal(
        start: Radius.zero,
        end: const Radius.circular(32),
      ).resolve(Directionality.of(context)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
    );
  }

  Widget _buildStep({
    Key? key,
    required int index,
    required String label,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required double size,
    required VoidCallback onTap,
    required bool isRtl,
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
      key: key,
      animation: animation,
      builder: (context, child) {
        final double value = animation.value;
        if (value == 0 && !_isExpanded) return const SizedBox.shrink();

        return Opacity(
          key: key != null ? ValueKey('${(key as ValueKey).value}-opacity') : null,
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            key: key != null ? ValueKey('${(key as ValueKey).value}-translate') : null,
            offset: Offset(0, (1 - value) * 20),
            child: Transform.scale(
              key: key != null ? ValueKey('${(key as ValueKey).value}-scale') : null,
              scale: value,
              child: Align(
                key: key != null ? ValueKey('${(key as ValueKey).value}-align') : null,
                alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                child: Row(
                  key: key != null ? ValueKey('${(key as ValueKey).value}-row') : null,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStepLabel(labelBgColor, label, labelTextColor, key: key != null ? ValueKey('${(key as ValueKey).value}-label') : null),
                    const SizedBox(width: 12),
                    _buildStepFab(index, onTap, isDark, color, theme, iconColor,
                        size, icon, key: key != null ? ValueKey('${(key as ValueKey).value}-fab') : null),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepLabel(Color labelBgColor, String label, Color labelTextColor, {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    );
  }

  Widget _buildStepFab(int index, VoidCallback onTap, bool isDark, Color color,
      ThemeData theme, Color iconColor, double size, IconData icon, {Key? key}) {
    return SizedBox(
      key: key,
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
    );
  }
}
