import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/accounts/data/accounts_repository.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/features/businesses/domain/models/business.dart';
import 'package:flowpaisa/features/currencies/data/currencies_repository.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flowpaisa/features/settings/data/user_preferences_repository.dart';
import 'package:drift/drift.dart';

class BusinessSummary {
  final String uuid;
  final double availableCash;
  final double netWorth;
  final DateTime lastUpdated;

  /// [AppCurrency.uuid] for this business when the summary was saved (per-business DB).
  final String? currencyUuid;

  BusinessSummary({
    required this.uuid,
    required this.availableCash,
    required this.netWorth,
    required this.lastUpdated,
    this.currencyUuid,
  });

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'availableCash': availableCash,
      'netWorth': netWorth,
      'lastUpdated': lastUpdated.toIso8601String(),
      if (currencyUuid != null) 'currencyUuid': currencyUuid,
    };
  }

  factory BusinessSummary.fromMap(Map<String, dynamic> map) {
    return BusinessSummary(
      uuid: map['uuid'] as String,
      availableCash: (map['availableCash'] as num?)?.toDouble() ?? 0.0,
      netWorth: (map['netWorth'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
      currencyUuid: map['currencyUuid'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory BusinessSummary.fromJson(String source) =>
      BusinessSummary.fromMap(json.decode(source) as Map<String, dynamic>);
}

class BusinessSummaryService {
  static const String _kStorageKey = 'business_summaries_v1';

  static Future<void> updateSummary(SharedPreferences prefs, BusinessSummary summary) async {
    final summaries = await _loadAll(prefs);
    summaries[summary.uuid] = summary;
    await _saveAll(prefs, summaries);
  }

  static Future<void> calculateAndUpdate(SharedPreferences prefs, AppDatabase db, Business business) async {
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

      final userPrefsRepo = UserPreferencesRepository(db);
      String? currencyUuid =
          await userPrefsRepo.getPreference(UserPreferencesRepository.keySelectedCurrencyId);
      if (currencyUuid == null || currencyUuid.isEmpty) {
        final code = await userPrefsRepo.getCurrency();
        final currenciesRepo = CurrenciesRepository(db);
        final c = await currenciesRepo.getCurrencyByCode(code);
        currencyUuid = c?.uuid;
      }

      final summary = BusinessSummary(
        uuid: business.id,
        availableCash: availableCash,
        netWorth: netWorth,
        lastUpdated: DateTime.now(),
        currencyUuid: currencyUuid,
      );

      await updateSummary(prefs, summary);
      
      if (kDebugMode) {
        print('BusinessSummaryService: Summary updated for ${business.name}');
        print('  - availableCash: $availableCash (from transactions)');
        print('  - netWorth: $netWorth (from accounts)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('BusinessSummaryService: Error calculating summary for ${business.name}: $e');
      }
      rethrow;
    }
  }

  static Future<List<BusinessSummary>> getOtherSummaries(SharedPreferences prefs, String currentUuid) async {
    final summaries = await _loadAll(prefs);
    return summaries.values.where((s) => s.uuid != currentUuid).toList()
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
  }

  /// Sync read for dashboard combine totals (same JSON as [_loadAll]).
  static Map<String, BusinessSummary> readAllSummariesSync(
      SharedPreferences prefs) {
    final jsonString = prefs.getString(_kStorageKey);
    if (jsonString == null) return {};

    try {
      final List<dynamic> list = json.decode(jsonString);
      final Map<String, BusinessSummary> map = {};
      for (final item in list) {
        final summary = BusinessSummary.fromMap(item as Map<String, dynamic>);
        map[summary.uuid] = summary;
      }
      return map;
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, BusinessSummary>> _loadAll(
      SharedPreferences prefs) async {
    return readAllSummariesSync(prefs);
  }

  static Future<void> _saveAll(SharedPreferences prefs, Map<String, BusinessSummary> summaries) async {
    final list = summaries.values.map((s) => s.toMap()).toList();
    await prefs.setString(_kStorageKey, json.encode(list));
  }
}
