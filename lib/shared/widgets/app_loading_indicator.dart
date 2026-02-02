import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLoadingIndicator extends StatefulWidget {
  final double size;
  final bool isFullPage;
  final Color? color;

  const AppLoadingIndicator({
    super.key,
    this.size = 50.0,
    this.isFullPage = false,
    this.color,
  });

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutBack,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoColor = widget.color ?? theme.colorScheme.primary;

    Widget indicator = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: SvgPicture.asset(
        'assets/images/logo_square.svg',
        width: widget.size,
        height: widget.size,
        colorFilter: ColorFilter.mode(logoColor, BlendMode.srcIn),
      ),
    );

    if (widget.isFullPage) {
      return Scaffold(
        body: Center(
          child: indicator,
        ),
      );
    }

    return Center(
      child: indicator,
    );
  }
}
