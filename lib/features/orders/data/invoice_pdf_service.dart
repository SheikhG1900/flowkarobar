import 'dart:typed_data';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/utils/export_service.dart';
import 'package:flowpaisa/features/currencies/data/currencies_repository.dart';
import 'package:flowpaisa/features/settings/data/user_preferences_repository.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:printing/printing.dart';

class InvoicePdfService {
  final AppDatabase _db;

  InvoicePdfService(this._db);

  /// Loads business customization settings from UserPreferencesRepository
  Future<Map<String, String>> loadBusinessInvoicePreferences() async {
    final prefsRepo = UserPreferencesRepository(_db);
    final allPrefs = await prefsRepo.getAllPreferences();

    final userName = allPrefs[UserPreferencesRepository.keyUserName] ?? 'FLOWKAROBAR ENTERPRISES';
    final userAddress = allPrefs[UserPreferencesRepository.keyUserAddress] ?? 'Main Commercial Sector';
    final userPhone = allPrefs[UserPreferencesRepository.keyUserPhone];
    final userEmail = allPrefs[UserPreferencesRepository.keyUserEmail];
    final taxId = allPrefs[UserPreferencesRepository.keyBusinessTaxId];
    final notes = allPrefs[UserPreferencesRepository.keyDefaultInvoiceNotes] ??
        'Thank you for your business!';

    final result = <String, String>{
      'user_name': userName,
      'user_address': userAddress,
      'default_invoice_notes': notes,
    };

    if (userPhone != null && userPhone.isNotEmpty) {
      result['user_phone'] = userPhone;
    }
    if (userEmail != null && userEmail.isNotEmpty) {
      result['user_email'] = userEmail;
    }
    if (taxId != null && taxId.isNotEmpty) {
      result['business_tax_id'] = taxId;
    }

    return result;
  }

  /// Generates the raw PDF bytes for an order invoice
  Future<Uint8List> generateInvoicePdfBytes({
    required Order order,
    required List<OrderItem> items,
    Contact? contact,
    AppLocalizations? l10n,
  }) async {
    final businessPrefs = await loadBusinessInvoicePreferences();
    final prefsRepo = UserPreferencesRepository(_db);

    // Load active currency symbol & decimal places
    String symbol = '\$';
    int decimals = 2;

    try {
      final selectedCurrencyId =
          await prefsRepo.getPreference(UserPreferencesRepository.keySelectedCurrencyId);
      final currenciesRepo = CurrenciesRepository(_db);
      if (selectedCurrencyId != null && selectedCurrencyId.isNotEmpty) {
        final currency = await currenciesRepo.getCurrencyByUuid(selectedCurrencyId);
        if (currency != null) {
          symbol = currency.symbol;
          decimals = currency.decimalPlaces;
        }
      } else {
        final code = await prefsRepo.getCurrency();
        final currency = await currenciesRepo.getCurrencyByCode(code);
        if (currency != null) {
          symbol = currency.symbol;
          decimals = currency.decimalPlaces;
        }
      }
    } catch (_) {
      // Fallback to default
    }

    String dateFormat = 'dd/MM/yyyy';
    try {
      dateFormat = await prefsRepo.getDateFormat();
    } catch (_) {}

    final txRepo = TransactionsRepository(_db);
    final exportService = ExportService(txRepo, _db, dateFormat: dateFormat);
    return exportService.generateInvoicePDF(
      order: order,
      items: items,
      contact: contact,
      businessPrefs: businessPrefs,
      currencySymbol: symbol,
      decimalPlaces: decimals,
      l10n: l10n,
    );
  }

  /// Share the PDF directly
  Future<void> shareInvoicePdf({
    required Order order,
    required List<OrderItem> items,
    Contact? contact,
    AppLocalizations? l10n,
  }) async {
    final bytes = await generateInvoicePdfBytes(
      order: order,
      items: items,
      contact: contact,
      l10n: l10n,
    );

    final filename = 'Invoice_${order.orderNumber}.pdf';
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  /// Print or open standard print preview for the PDF
  Future<void> printInvoicePdf({
    required Order order,
    required List<OrderItem> items,
    Contact? contact,
    AppLocalizations? l10n,
  }) async {
    final bytes = await generateInvoicePdfBytes(
      order: order,
      items: items,
      contact: contact,
      l10n: l10n,
    );

    final filename = 'Invoice_${order.orderNumber}.pdf';
    await Printing.layoutPdf(
      name: filename,
      onLayout: (_) async => bytes,
    );
  }
}
