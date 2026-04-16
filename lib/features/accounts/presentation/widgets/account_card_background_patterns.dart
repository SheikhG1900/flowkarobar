import 'package:flutter/material.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';

/// Large corner watermark at the top trailing side (mirrors in RTL via [end]).
/// Alpha matches cashbook slider cards.
PositionedDirectional accountCardDecorativeBackgroundIcon(IconData iconData) {
  return PositionedDirectional(
    end: -20,
    top: -20,
    child: Icon(
      iconData,
      size: 180,
      color: Colors.white.withValues(alpha: 0.08),
    ),
  );
}

/// Subtle background textures for account tiles (dashboard slider + accounts screen).
/// Credit: diagonal stripes (card plastic). Bank / savings: horizontal pinstripes.
/// Cash: light dot grid — all low-contrast on top of the gradient.
CustomPainter accountCardBackgroundPainter(AccountType type) {
  switch (type) {
    case AccountType.creditCard:
      return CreditCardDiagonalPatternPainter(
        color: Colors.white.withValues(alpha: 0.05),
      );
    case AccountType.bank:
      return HorizontalPinstripePatternPainter(
        color: Colors.white.withValues(alpha: 0.05),
        lineSpacing: 14,
      );
    case AccountType.savings:
      return HorizontalPinstripePatternPainter(
        color: Colors.white.withValues(alpha: 0.05),
        lineSpacing: 17,
      );
    case AccountType.cash:
      return DotGridPatternPainter(
        color: Colors.white.withValues(alpha: 0.055),
        cellSize: 18,
        dotRadius: 2.0,
      );
  }
}

/// Diagonal lines — reads as physical credit card.
class CreditCardDiagonalPatternPainter extends CustomPainter {
  CreditCardDiagonalPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (var i = -size.height; i < size.width; i += 15) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CreditCardDiagonalPatternPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Ledger / statement feel for bank & savings.
class HorizontalPinstripePatternPainter extends CustomPainter {
  HorizontalPinstripePatternPainter({
    required this.color,
    required this.lineSpacing,
  });

  final Color color;
  final double lineSpacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (var y = 0.0; y <= size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant HorizontalPinstripePatternPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.lineSpacing != lineSpacing;
}

/// Soft dot grid for cash — distinct from stripes, still subtle.
class DotGridPatternPainter extends CustomPainter {
  DotGridPatternPainter({
    required this.color,
    required this.cellSize,
    required this.dotRadius,
  });

  final Color color;
  final double cellSize;
  final double dotRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final startX = cellSize * 0.5;
    final startY = cellSize * 0.5;
    for (var y = startY; y < size.height + cellSize; y += cellSize) {
      for (var x = startX; x < size.width + cellSize; x += cellSize) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotGridPatternPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.cellSize != cellSize ||
      oldDelegate.dotRadius != dotRadius;
}
