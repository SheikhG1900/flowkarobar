import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A centralized widget to display the faded app logo at the bottom of lists.
/// This matches the design used in Analytics, Transactions, and other listing screens.
class FadedBottomLogo extends StatelessWidget {
  final double height;
  final double opacity;
  final double topPadding;
  final double bottomPadding;

  const FadedBottomLogo({
    super.key,
    this.height = 60,
    this.opacity = 0.1,
    this.topPadding = 40,
    this.bottomPadding = 40,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: topPadding),
        Center(
          child: Opacity(
            opacity: opacity,
            child: SvgPicture.asset(
              'assets/images/logo_square.svg',
              height: height,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        SizedBox(height: bottomPadding),
      ],
    );
  }
}
