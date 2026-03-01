import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class LocalizationHelper {
  static String localizeCategory(BuildContext context, String categoryName) {
    final l10n = AppLocalizations.of(context)!;
    switch (categoryName.toLowerCase()) {
      case 'food':
        return l10n.categoryFood;
      case 'transport':
        return l10n.categoryTransport;
      case 'shopping':
        return l10n.categoryShopping;
      case 'bills':
        return l10n.categoryBills;
      case 'entertainment':
        return l10n.categoryEntertainment;
      case 'health':
        return l10n.categoryHealth;
      case 'education':
        return l10n.categoryEducation;
      case 'salary':
        return l10n.categorySalary;
      case 'business':
        return l10n.categoryBusiness;
      case 'investment':
        return l10n.categoryInvestment;
      case 'gift':
        return l10n.categoryGift;
      case 'rent':
        return l10n.categoryRent;
      case 'other':
        return l10n.categoryOther;
      case 'income':
        return l10n.income;
      case 'expense':
        return l10n.expense;
      case 'payable':
        return l10n.payableTag;
      case 'receivable':
        return l10n.receivableTag;
      case 'paid':
        return l10n.paidTag;
      case 'received':
        return l10n.receivedTag;
      default:
        return categoryName;
    }
  }

  static String getLocalizedCategoryName(
      BuildContext context, String categoryName) {
    return localizeCategory(context, categoryName);
  }

  static String localizeCategoryName(
      BuildContext context, String categoryName) {
    return localizeCategory(context, categoryName);
  }

  static String localizeStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toUpperCase()) {
      case 'PENDING':
        return l10n.statusPending;
      case 'PAID':
        return l10n.statusPaid;
      case 'RECEIVED':
        return l10n.statusReceived;
      case 'CANCELLED':
        return l10n.statusCancelled;
      case 'SETTLED':
        return l10n.statusSettled;
      case 'OVERDUE':
        return l10n.statusOverdue;
      case 'SENT':
        return l10n.statusSent;
      case 'FAILED':
        return l10n.statusFailed;
      default:
        return status;
    }
  }

  static String localizeCurrency(BuildContext context, String currencyName) {
    final l10n = AppLocalizations.of(context)!;
    switch (currencyName) {
      case 'US Dollar':
        return l10n.currencyUSD;
      case 'Indian Rupee':
        return l10n.currencyINR;
      case 'Pakistani Rupee':
        return l10n.currencyPKR;
      default:
        return currencyName;
    }
  }

  static String localizeRelationship(
      AppLocalizations l10n, String? relationship) {
    if (relationship == null) return '';
    switch (relationship.toUpperCase()) {
      case 'PAID_FOR':
        return l10n.paidFor;
      case 'PAID_BY':
        return l10n.paidBy;
      case 'RECEIVED_FROM':
        return l10n.iOwe;
      case 'WILL_RECEIVE':
        return l10n.willReceive;
      default:
        return relationship;
    }
  }
}

extension LocalizationExtension on String {
  String localizeCategory(BuildContext context) =>
      LocalizationHelper.localizeCategory(context, this);
  String localizeStatus(BuildContext context) =>
      LocalizationHelper.localizeStatus(context, this);
  String localizeCurrency(BuildContext context) =>
      LocalizationHelper.localizeCurrency(context, this);
}
