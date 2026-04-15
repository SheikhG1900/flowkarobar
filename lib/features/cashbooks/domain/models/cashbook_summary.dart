import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/accounts/data/accounts_repository.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:drift/drift.dart';

class CashbookSummary {
  final String uuid;
  final double availableCash;
  final double netWorth;
  final DateTime lastUpdated;

  CashbookSummary({
    required this.uuid,
    required this.availableCash,
    required this.netWorth,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'availableCash': availableCash,
      'netWorth': netWorth,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory CashbookSummary.fromMap(Map<String, dynamic> map) {
    return CashbookSummary(
      uuid: map['uuid'] as String,
      availableCash: (map['availableCash'] as num?)?.toDouble() ?? 0.0,
      netWorth: (map['netWorth'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory CashbookSummary.fromJson(String source) =>
      CashbookSummary.fromMap(json.decode(source) as Map<String, dynamic>);
}

class CashbookSummaryService {
  static const String _kStorageKey = 'cashbook_summaries_v1';

  static Future<void> updateSummary(SharedPreferences prefs, CashbookSummary summary) async {
    final summaries = await _loadAll(prefs);
    summaries[summary.uuid] = summary;
    await _saveAll(prefs, summaries);
  }

  static Future<void> calculateAndUpdate(SharedPreferences prefs, AppDatabase db, Cashbook cashbook) async {
    try {
      final accountsRepo = AccountsRepository(db);
      final accounts = await accountsRepo.getAllAccountsWithBalance();
      
      final txRepo = TransactionsRepository(db);
      // We need to get the stats stream first to get the cashIncome and cashExpense
      // Since we are in a Future context, we take the first value from the stream
      final txStats = await txRepo.watchTransactionStats().first;
      
      // 1. Available Cash (same as dashboard header: cashIncome - cashExpense)
      final availableCash = txStats.cashIncome - txStats.cashExpense;

      // 2. Net Worth (same as dashboard header: assets − liabilities from accounts)
      final netWorth = dashboardNetWorthFromAccounts(accounts);

      final summary = CashbookSummary(
        uuid: cashbook.id,
        availableCash: availableCash,
        netWorth: netWorth,
        lastUpdated: DateTime.now(),
      );

      await updateSummary(prefs, summary);
      
      if (kDebugMode) {
        print('CashbookSummaryService: Summary updated for ${cashbook.name}');
        print('  - availableCash: $availableCash (from transactions)');
        print('  - netWorth: $netWorth (from accounts)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('CashbookSummaryService: Error calculating summary for ${cashbook.name}: $e');
      }
      rethrow;
    }
  }

  static Future<List<CashbookSummary>> getOtherSummaries(SharedPreferences prefs, String currentUuid) async {
    final summaries = await _loadAll(prefs);
    return summaries.values.where((s) => s.uuid != currentUuid).toList()
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
  }

  /// Sync read for dashboard combine totals (same JSON as [_loadAll]).
  static Map<String, CashbookSummary> readAllSummariesSync(
      SharedPreferences prefs) {
    final jsonString = prefs.getString(_kStorageKey);
    if (jsonString == null) return {};

    try {
      final List<dynamic> list = json.decode(jsonString);
      final Map<String, CashbookSummary> map = {};
      for (final item in list) {
        final summary = CashbookSummary.fromMap(item as Map<String, dynamic>);
        map[summary.uuid] = summary;
      }
      return map;
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, CashbookSummary>> _loadAll(
      SharedPreferences prefs) async {
    return readAllSummariesSync(prefs);
  }

  static Future<void> _saveAll(SharedPreferences prefs, Map<String, CashbookSummary> summaries) async {
    final list = summaries.values.map((s) => s.toMap()).toList();
    await prefs.setString(_kStorageKey, json.encode(list));
  }
}
