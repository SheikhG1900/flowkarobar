import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

/// Service class to manage dashboard tour flow
class TourService {
  /// Global keys for showcase targets on dashboard
  static final GlobalKey dashboardHeaderKey = GlobalKey();
  static final GlobalKey balanceKey = GlobalKey();
  static final GlobalKey cashFlowStatsKey = GlobalKey();
  static final GlobalKey lendingStatsKey = GlobalKey();
  static final GlobalKey quickActionsKey = GlobalKey();
  static final GlobalKey recentTransactionsKey = GlobalKey();
  static final GlobalKey bottomNavKey = GlobalKey();

  // Transactions Screen Keys
  static final GlobalKey transactionsSearchKey = GlobalKey();
  static final GlobalKey transactionsFilterKey = GlobalKey();
  static final GlobalKey transactionsListKey = GlobalKey();
  static final GlobalKey transactionsFabKey = GlobalKey();

  // Analytics Screen Keys
  static final GlobalKey analyticsDateRangeKey = GlobalKey();
  static final GlobalKey analyticsExportPdfKey = GlobalKey();
  static final GlobalKey analyticsFinancialSummaryKey = GlobalKey();
  static final GlobalKey analyticsChartsKey = GlobalKey();

  // Settings Screen Keys
  static final GlobalKey settingsProfileKey = GlobalKey();
  static final GlobalKey settingsAppPreferencesKey = GlobalKey();
  static final GlobalKey settingsBackupKey = GlobalKey();
  static final GlobalKey settingsPremiumKey = GlobalKey();

  // Add Transaction Screen Keys
  static final GlobalKey addTxAmountKey = GlobalKey();
  static final GlobalKey addTxCategoryKey = GlobalKey();
  static final GlobalKey addTxContactKey = GlobalKey();
  static final GlobalKey addTxDateKey = GlobalKey();
  static final GlobalKey addTxSaveKey = GlobalKey();

  /// List of showcase keys in order for dashboard tour
  static List<GlobalKey> get dashboardTourKeys => [
        dashboardHeaderKey,
        balanceKey,
        cashFlowStatsKey,
        lendingStatsKey,
        quickActionsKey,
        recentTransactionsKey,
        bottomNavKey,
      ];

  static List<GlobalKey> get transactionsTourKeys => [
        transactionsSearchKey,
        transactionsFilterKey,
        transactionsListKey,
        transactionsFabKey,
      ];

  static List<GlobalKey> get analyticsTourKeys => [
        analyticsDateRangeKey,
        analyticsExportPdfKey,
        analyticsFinancialSummaryKey,
        analyticsChartsKey,
      ];

  static List<GlobalKey> get settingsTourKeys => [
        settingsProfileKey,
        settingsAppPreferencesKey,
        settingsBackupKey,
        settingsPremiumKey,
      ];

  static List<GlobalKey> get addTransactionTourKeys => [
        addTxAmountKey,
        addTxCategoryKey,
        addTxContactKey,
        addTxDateKey,
        addTxSaveKey,
      ];

  /// Start the dashboard tour
  /// This will be called when user taps "Start Tour" or on first launch
  static void startDashboardTour(BuildContext context) {
    // The tour will be controlled by ShowCaseWidget's startShowCase method
    try {
      final showcaseState = ShowCaseWidget.of(context);
      showcaseState.startShowCase(dashboardTourKeys);
    } catch (e) {
      debugPrint('Error starting dashboard tour: $e');
    }
  }

  static void startTransactionsTour(BuildContext context) {
    try {
      final showcaseState = ShowCaseWidget.of(context);
      showcaseState.startShowCase(transactionsTourKeys);
    } catch (e) {
      debugPrint('Error starting transactions tour: $e');
    }
  }

  static void startAnalyticsTour(BuildContext context) {
    try {
      final showcaseState = ShowCaseWidget.of(context);
      showcaseState.startShowCase(analyticsTourKeys);
    } catch (e) {
      debugPrint('Error starting analytics tour: $e');
    }
  }

  static void startSettingsTour(BuildContext context) {
    try {
      final showcaseState = ShowCaseWidget.of(context);
      showcaseState.startShowCase(settingsTourKeys);
    } catch (e) {
      debugPrint('Error starting settings tour: $e');
    }
  }

  static void startAddTransactionTour(BuildContext context) {
    try {
      final showcaseState = ShowCaseWidget.of(context);
      showcaseState.startShowCase(addTransactionTourKeys);
    } catch (e) {
      debugPrint('Error starting add transaction tour: $e');
    }
  }

  /// Get the showcase key for a specific dashboard element
  static GlobalKey? getKeyForElement(String elementName) {
    switch (elementName) {
      case 'dashboardHeader':
        return dashboardHeaderKey;
      case 'balance':
        return balanceKey;
      case 'cashFlowStats':
        return cashFlowStatsKey;
      case 'lendingStats':
        return lendingStatsKey;
      case 'quickActions':
        return quickActionsKey;
      case 'recentTransactions':
        return recentTransactionsKey;
      case 'bottomNav':
        return bottomNavKey;
      default:
        return null;
    }
  }
}
