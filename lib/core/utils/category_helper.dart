import 'package:flutter/material.dart' hide Category;
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/core/database/database.dart' hide Category;
import 'package:flowpaisa/features/transactions/domain/models.dart' show Category;
import 'package:flowpaisa/l10n/app_localizations.dart';

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
      isExpense ? Symbols.money_off : Symbols.payments,
      color: color,
      size: size,
    );
  }

  /// Returns the localized name of a category if it's a default category.
  /// Otherwise, returns the category's name as stored in the database.
  static String getCategoryName(Category category, AppLocalizations l10n) {
    if (!category.isDefault) {
      return category.name;
    }

    // Default Categories Localization using standard keys
    final name = category.name.toLowerCase();
    if (name.contains('food') || name.contains('dining')) return l10n.categoryFood;
    if (name.contains('transport') || name.contains('travel')) return l10n.categoryTransport;
    if (name.contains('shopping')) return l10n.categoryShopping;
    if (name.contains('entertainment') || name.contains('movie')) return l10n.categoryEntertainment;
    if (name.contains('medical') || name.contains('health')) return l10n.categoryHealth;
    if (name.contains('education')) return l10n.categoryEducation;
    if (name.contains('business')) return l10n.categoryBusiness;
    if (name.contains('rent') || name.contains('home')) return l10n.categoryRent;
    if (name.contains('bills') || name.contains('utility')) return l10n.categoryBills;
    if (name.contains('salary') || name.contains('income')) return l10n.categorySalary;
    if (name.contains('gift')) return l10n.categoryGift;
    if (name.contains('investment')) return l10n.categoryInvestment;
    if (name.contains('refund')) return l10n.categoryRefund;
    if (name.contains('other')) return l10n.categoryOther;

    return category.name;
  }
}
