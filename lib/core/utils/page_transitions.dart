import 'package:flutter/material.dart';

/// Slide Up Page Route
/// Animated route that slides from bottom to top
class SlideUpRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  SlideUpRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration: duration,
        );
}

/// Fade Route
/// Simple fade in/out transition
class FadeRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  FadeRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: duration,
        );
}

/// Scale Fade Route
/// Combines scale and fade for modern feel
class ScaleFadeRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  ScaleFadeRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeOutCubic;
            var scaleTween = Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: curve));
            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: ScaleTransition(
                scale: animation.drive(scaleTween),
                child: child,
              ),
            );
          },
          transitionDuration: duration,
        );
}

/// Slide Right Route
/// Slides from right to left (like iOS)
class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  SlideRightRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration: duration,
        );
}

/// Modal Bottom Sheet Route
/// Full-screen modal that slides up with rounded top corners
class ModalBottomSheetRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;
  final double borderRadius;

  ModalBottomSheetRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
    this.borderRadius = 24,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(slideTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(borderRadius),
                  ),
                  child: child,
                ),
              ),
            );
          },
          transitionDuration: duration,
          opaque: false,
          barrierColor: Colors.black.withValues(alpha: 0.5 / 1.0),
        );
}

