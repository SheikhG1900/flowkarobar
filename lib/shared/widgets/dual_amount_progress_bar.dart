import 'package:flutter/material.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';

/// Filled progress bar (same style as credit card balance on account details):
/// left vs right amounts, centre % badge, left-to-right fill.
class DualAmountProgressBar extends StatelessWidget {
  final String leftLabel;
  final double leftAmount;
  final String rightLabel;
  final double rightAmount;
  final String symbol;
  final int decimals;

  /// Color for the left / filled side.
  final Color filledColor;

  /// Optional independent color for the right side.
  /// Falls back to [filledColor] when null.
  final Color? rightFilledColor;

  /// When true, shows individual % badges at left/right corners instead of
  /// a single centred badge.
  final bool cornerPercents;

  /// When true, renders a split comparison bar (both sides solid-filled)
  /// instead of a left-to-right progress fill.
  final bool comparisonMode;

  /// Shorter bar and smaller type (e.g. category list aggregate summary).
  final bool compact;

  const DualAmountProgressBar({
    super.key,
    required this.leftLabel,
    required this.leftAmount,
    required this.rightLabel,
    required this.rightAmount,
    required this.symbol,
    required this.decimals,
    required this.filledColor,
    this.rightFilledColor,
    this.cornerPercents = false,
    this.comparisonMode = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = leftAmount + rightAmount;
    final percent = total > 0 ? (leftAmount / total).clamp(0.0, 1.0) : 0.0;
    final rightPercent = 1.0 - percent;
    final resolvedRightColor = rightFilledColor ?? filledColor;

    final formattedLeft =
        AmountFormatter.formatWithCurrency(leftAmount, symbol, decimals);
    final formattedRight =
        AmountFormatter.formatWithCurrency(rightAmount, symbol, decimals);

    Widget buildCornerRow(Color leftColor, Color rightColor) {
      Widget corner({
        required String label,
        required String percentText,
        required String amount,
        required Color color,
        required Color badgeBorderColor,
        required CrossAxisAlignment align,
      }) =>
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: align,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.cardColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: badgeBorderColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  percentText,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                amount,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            corner(
              label: leftLabel,
              percentText: '${(percent * 100).toStringAsFixed(1)}%',
              amount: formattedLeft,
              color: leftColor,
              badgeBorderColor: filledColor,
              align: CrossAxisAlignment.start,
            ),
            corner(
              label: rightLabel,
              percentText: '${(rightPercent * 100).toStringAsFixed(1)}%',
              amount: formattedRight,
              color: rightColor,
              badgeBorderColor: resolvedRightColor,
              align: CrossAxisAlignment.end,
            ),
          ],
        ),
      );
    }

    Widget buildCentreRow(Color leftColor, Color rightColor) {
      final hPad = compact ? 10.0 : 16.0;
      final fsLabel = compact ? 9.0 : 11.0;
      final fsLeftAmt = compact ? 13.0 : 15.0;
      final fsRightAmt = compact ? 12.0 : 14.0;
      final fsPct = compact ? 10.0 : 12.0;
      final pctPadH = compact ? 6.0 : 8.0;
      final pctPadV = compact ? 2.0 : 4.0;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    leftLabel,
                    style: TextStyle(
                      color: leftColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: fsLabel,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    formattedLeft,
                    style: TextStyle(
                      color: leftColor,
                      fontWeight: FontWeight.bold,
                      fontSize: fsLeftAmt,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: pctPadH,
                vertical: pctPadV,
              ),
              decoration: BoxDecoration(
                color: theme.cardColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(compact ? 10 : 12),
                border: Border.all(
                  color: filledColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '${(percent * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: filledColor,
                  fontWeight: FontWeight.bold,
                  fontSize: fsPct,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    rightLabel,
                    style: TextStyle(
                      color: rightColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                      fontSize: fsLabel,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    formattedRight,
                    style: TextStyle(
                      color: rightColor,
                      fontWeight: FontWeight.w600,
                      fontSize: fsRightAmt,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget buildRow(Color leftColor, Color rightColor) => cornerPercents
        ? buildCornerRow(leftColor, rightColor)
        : buildCentreRow(leftColor, rightColor);

    if (comparisonMode) {
      Widget segment({
        required Color color,
        required Color textColor,
        required String label,
        required String percentText,
        required String amount,
        required CrossAxisAlignment align,
        required BorderRadius borderRadius,
      }) {
        return Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: borderRadius,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: align,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  percentText,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  amount,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              segment(
                color: filledColor,
                textColor: Colors.white,
                label: leftLabel,
                percentText: '${(percent * 100).toStringAsFixed(1)}%',
                amount: formattedLeft,
                align: CrossAxisAlignment.start,
                borderRadius: BorderRadiusDirectional.only(
                  topStart: const Radius.circular(16),
                  bottomStart: const Radius.circular(16),
                ).resolve(Directionality.of(context)),
              ),
              Container(width: 1.5, color: Colors.white.withValues(alpha: 0.4)),
              segment(
                color: resolvedRightColor,
                textColor: theme.colorScheme.onPrimary,
                label: rightLabel,
                percentText: '${((1 - percent) * 100).toStringAsFixed(1)}%',
                amount: formattedRight,
                align: CrossAxisAlignment.end,
                borderRadius: BorderRadiusDirectional.only(
                  topEnd: const Radius.circular(16),
                  bottomEnd: const Radius.circular(16),
                ).resolve(Directionality.of(context)),
              ),
            ],
          ),
        ),
      );
    }

    final double stackHeight =
        cornerPercents ? 80 : (compact ? 52 : 64);
    final double radius = compact ? 14.0 : 20.0;

    return Container(
      height: stackHeight,
      decoration: BoxDecoration(
        color: cornerPercents
            ? Color.lerp(filledColor, resolvedRightColor, 0.5)!
                .withValues(alpha: 0.07)
            : filledColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: cornerPercents
              ? Color.lerp(filledColor, resolvedRightColor, 0.5)!
                  .withValues(alpha: 0.5)
              : filledColor.withValues(alpha: 0.5),
          width: .5,
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: buildRow(
              filledColor,
              cornerPercents
                  ? resolvedRightColor
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          ClipRect(
            child: Align(
              alignment: Directionality.of(context) == TextDirection.rtl
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              widthFactor: percent,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: filledColor.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: buildRow(Colors.white, Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
