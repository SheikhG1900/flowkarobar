import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/currencies/presentation/providers/currencies_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/core/utils/currency_detector.dart';

/// Initialize currency on first launch by detecting from system locale
final currencyInitializerProvider = FutureProvider<void>((ref) async {
  final prefsRepository = ref.watch(userPreferencesRepositoryProvider);
  final hasInitialized =
      await prefsRepository.getPreference('currency_initialized');

  print('💵 Currency Initializer: hasInitialized = $hasInitialized');

  if (hasInitialized == null) {
    print(
        '💵 Currency Initializer: First launch detected, initializing currency...');

    // First launch - detect currency from system locale
    final currencyCode = CurrencyDetector.detectCurrencyCodeFromLocale();
    final repository = ref.read(currenciesRepositoryProvider);

    print(
        '💵 Currency Initializer: Looking for currency with code: $currencyCode');
    final currency = await repository.getCurrencyByCode(currencyCode);

    if (currency != null) {
      print(
          '💵 Currency Initializer: Found currency: ${currency.name} (${currency.symbol})');
      await prefsRepository.setPreference(
          'selected_currency_id', currency.uuid,
          markUnsynced: false);
    } else {
      print(
          '💵 Currency Initializer: Currency code $currencyCode not found, using default');
      // Fallback to default currency
      final defaultCurrency = await repository.getDefaultCurrency();
      print(
          '💵 Currency Initializer: Using default: ${defaultCurrency.name} (${defaultCurrency.symbol})');
      await prefsRepository.setPreference(
          'selected_currency_id', defaultCurrency.uuid,
          markUnsynced: false);
    }
    await prefsRepository.setPreference('currency_initialized', 'true',
        markUnsynced: false);
    print('💵 Currency Initializer: Initialization complete');
  } else {
    print('💵 Currency Initializer: Already initialized');
  }
});

/// Provider for the currently selected currency ID
final selectedCurrencyIdProvider = FutureProvider<String?>((ref) async {
  // Ensure currency initialization is complete
  await ref.watch(currencyInitializerProvider.future);

  final prefsRepository = ref.watch(userPreferencesRepositoryProvider);
  final idString = await prefsRepository.getPreference('selected_currency_id');

  return idString;
});

/// Provider for the current currency object
final currentCurrencyProvider = FutureProvider<AppCurrency>((ref) async {
  final currencyId = await ref.watch(selectedCurrencyIdProvider.future);

  if (currencyId != null) {
    final repository = ref.read(currenciesRepositoryProvider);
    final currency = await repository.getCurrencyByUuid(currencyId);
    if (currency != null) {
      return currency;
    }
  }

  // Fallback to default currency
  final repository = ref.read(currenciesRepositoryProvider);
  return repository.getDefaultCurrency();
});

/// Provider for the current currency symbol (most commonly used)
final currencySymbolProvider = Provider<String>((ref) {
  final currencyAsync = ref.watch(currentCurrencyProvider);
  return currencyAsync.when(
    data: (currency) => currency.symbol,
    loading: () => '₹', // Fallback while loading
    error: (_, __) => '₹', // Fallback on error
  );
});

/// Provider for the current currency decimal places
final currencyDecimalPlacesProvider = Provider<int>((ref) {
  final currencyAsync = ref.watch(currentCurrencyProvider);
  return currencyAsync.when(
    data: (currency) => currency.decimalPlaces,
    loading: () => 2, // Fallback while loading
    error: (_, __) => 2, // Fallback on error
  );
});

/// Notifier for updating the selected currency
class CurrencyNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> setSelectedCurrency(String currencyUuid) async {
    final prefsRepository = ref.read(userPreferencesRepositoryProvider);
    await prefsRepository.setPreference(
        'selected_currency_id', currencyUuid);

    // Invalidate providers to refresh the UI
    ref.invalidate(selectedCurrencyIdProvider);
    ref.invalidate(currentCurrencyProvider);
  }
}

final currencyNotifierProvider = NotifierProvider<CurrencyNotifier, void>(() {
  return CurrencyNotifier();
});
