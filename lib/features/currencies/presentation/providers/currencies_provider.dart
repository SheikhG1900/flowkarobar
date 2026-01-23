import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/features/currencies/data/currencies_repository.dart';

// Currencies Repository Provider
final currenciesRepositoryProvider = Provider<CurrenciesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CurrenciesRepository(db);
});

// Stream of all active currencies
final currenciesListProvider = StreamProvider<List<AppCurrency>>((ref) {
  final repository = ref.watch(currenciesRepositoryProvider);
  return repository.watchAllCurrencies();
});

// Get currency by UUID
final currencyByUuidProvider = FutureProvider.family<AppCurrency?, String>((ref, uuid) async {
  final repository = ref.read(currenciesRepositoryProvider);
  return repository.getCurrencyByUuid(uuid);
});
