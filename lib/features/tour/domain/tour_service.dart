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
