import 'package:flutter/material.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:material_symbols_icons/symbols.dart';

class CategoryHelper {
  /// Builds a category icon widget with appropriate styling
  /// [iconString] - codePoint string from category
  /// [color] - icon color
  /// [isExpense] - true for expense categories, false for income (used for fallback)
  /// [size] - icon size (default: 24)
  static Widget buildCategoryIcon(
    String? iconString,
    Color color,
    bool isExpense, {
    double size = 24,
  }) {
    final iconData = IconHelper.getIconData(iconString);

    if (iconData != null) {
      return Icon(
        iconData,
        color: color,
        size: size,
      );
    }

    // Fallback to default icons
    return Icon(
      isExpense ? Symbols.money_off : Symbols.attach_money,
      color: color,
      size: size,
    );
  }

  // Other category-related utilities can be added here as needed
}
