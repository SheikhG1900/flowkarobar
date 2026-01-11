import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';

class CurrenciesRepository {
  final AppDatabase _database;

  CurrenciesRepository(this._database);

  /// Watch all active currencies
  Stream<List<AppCurrency>> watchAllCurrencies() {
    return (_database.select(_database.appCurrencies)
          ..where((c) => c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Get currency by ID
  Future<AppCurrency?> getCurrencyById(int id) {
    return (_database.select(_database.appCurrencies)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get currency by ISO code (e.g., "USD", "INR", "PKR")
  Future<AppCurrency?> getCurrencyByCode(String code) {
    return (_database.select(_database.appCurrencies)
          ..where((c) => c.code.equals(code))
          ..where((c) => c.isActive.equals(true)))
        .getSingleOrNull();
  }

  /// Create new currency
  Future<int> createCurrency(AppCurrenciesCompanion currency) {
    return _database.into(_database.appCurrencies).insert(currency);
  }

  /// Update currency
  Future<bool> updateCurrency(AppCurrency currency) async {
    final result = await _database.update(_database.appCurrencies).replace(currency);
    return result;
  }

  /// Soft delete currency (only non-default currencies)
  Future<void> deleteCurrency(int id) async {
    final currency = await getCurrencyById(id);
    if (currency == null) {
      throw Exception('Currency not found');
    }

    if (currency.isDefault) {
      throw Exception('Cannot delete default currency');
    }

    // Soft delete: mark as inactive
    await (_database.update(_database.appCurrencies)
          ..where((c) => c.id.equals(id)))
        .write(AppCurrenciesCompanion(isActive: Value(false)));
  }

  /// Get default currency (fallback to Indian Rupee)
  Future<AppCurrency> getDefaultCurrency() async {
    // Try to get INR first
    final inr = await getCurrencyByCode('INR');
    if (inr != null) return inr;

    // Fallback to first available default currency
    final defaultCurrency = await (_database.select(_database.appCurrencies)
          ..where((c) => c.isDefault.equals(true))
          ..where((c) => c.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();

    if (defaultCurrency != null) return defaultCurrency;

    // Ultimate fallback: first active currency
    final anyCurrency = await (_database.select(_database.appCurrencies)
          ..where((c) => c.isActive.equals(true))
          ..limit(1))
        .getSingle();

    return anyCurrency;
  }
}
