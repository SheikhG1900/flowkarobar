import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsageTrackerRepository {
  final SharedPreferences _prefs;

  UsageTrackerRepository(this._prefs);

  static const String _transactionsPrefix = 'usage_transactions_';
  static const String _receivablesPrefix = 'usage_receivables_';
  static const String _payablesPrefix = 'usage_payables_';
  static const String _smartParsingPrefix = 'usage_smart_parsing_';
  
  // Date formatters
  String _getDayKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  String _getMonthKey(DateTime date) => DateFormat('yyyy-MM').format(date);

  // --- Transactions ---

  int getTransactionCountToday() {
    final key = '${_transactionsPrefix}daily_${_getDayKey(DateTime.now())}';
    return _prefs.getInt(key) ?? 0;
  }

  int getTransactionCountThisMonth() {
    final key = '${_transactionsPrefix}monthly_${_getMonthKey(DateTime.now())}';
    return _prefs.getInt(key) ?? 0;
  }

  Future<void> incrementTransactionCount() async {
    final now = DateTime.now();
    final dayKey = '${_transactionsPrefix}daily_${_getDayKey(now)}';
    final monthKey = '${_transactionsPrefix}monthly_${_getMonthKey(now)}';

    final currentDay = _prefs.getInt(dayKey) ?? 0;
    final currentMonth = _prefs.getInt(monthKey) ?? 0;

    await _prefs.setInt(dayKey, currentDay + 1);
    await _prefs.setInt(monthKey, currentMonth + 1);
  }

  // --- Receivables ---

  int getReceivableCountToday() {
    final key = '${_receivablesPrefix}daily_${_getDayKey(DateTime.now())}';
    return _prefs.getInt(key) ?? 0;
  }

  int getReceivableCountThisMonth() {
    final key = '${_receivablesPrefix}monthly_${_getMonthKey(DateTime.now())}';
    return _prefs.getInt(key) ?? 0;
  }

  Future<void> incrementReceivableCount() async {
    final now = DateTime.now();
    final dayKey = '${_receivablesPrefix}daily_${_getDayKey(now)}';
    final monthKey = '${_receivablesPrefix}monthly_${_getMonthKey(now)}';

    final currentDay = _prefs.getInt(dayKey) ?? 0;
    final currentMonth = _prefs.getInt(monthKey) ?? 0;

    await _prefs.setInt(dayKey, currentDay + 1);
    await _prefs.setInt(monthKey, currentMonth + 1);
  }

  // --- Payables ---

  int getPayableCountToday() {
    final key = '${_payablesPrefix}daily_${_getDayKey(DateTime.now())}';
    return _prefs.getInt(key) ?? 0;
  }

  int getPayableCountThisMonth() {
    final key = '${_payablesPrefix}monthly_${_getMonthKey(DateTime.now())}';
    return _prefs.getInt(key) ?? 0;
  }

  Future<void> incrementPayableCount() async {
    final now = DateTime.now();
    final dayKey = '${_payablesPrefix}daily_${_getDayKey(now)}';
    final monthKey = '${_payablesPrefix}monthly_${_getMonthKey(now)}';

    final currentDay = _prefs.getInt(dayKey) ?? 0;
    final currentMonth = _prefs.getInt(monthKey) ?? 0;

    await _prefs.setInt(dayKey, currentDay + 1);
    await _prefs.setInt(monthKey, currentMonth + 1);
  }

  // --- Smart Parsing ---

  int getSmartParsingCountThisMonth() {
    final key = '${_smartParsingPrefix}monthly_${_getMonthKey(DateTime.now())}';
    return _prefs.getInt(key) ?? 0;
  }

  Future<void> incrementSmartParsingCount() async {
    final now = DateTime.now();
    final monthKey = '${_smartParsingPrefix}monthly_${_getMonthKey(now)}';
    final currentMonth = _prefs.getInt(monthKey) ?? 0;
    await _prefs.setInt(monthKey, currentMonth + 1);
  }

  /// Reset counts (useful for testing)
  Future<void> debugResetCounts() async {
    final keys = _prefs.getKeys();
    for (var key in keys) {
      if (key.startsWith('usage_')) {
        await _prefs.remove(key);
      }
    }
  }
}
