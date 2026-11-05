import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ur')
  ];

  /// No description provided for @businesses.
  ///
  /// In en, this message translates to:
  /// **'Businesses'**
  String get businesses;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @batches.
  ///
  /// In en, this message translates to:
  /// **'Batches'**
  String get batches;

  /// No description provided for @batch.
  ///
  /// In en, this message translates to:
  /// **'Batch'**
  String get batch;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get sale;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @taxInvoice.
  ///
  /// In en, this message translates to:
  /// **'Tax Invoice'**
  String get taxInvoice;

  /// No description provided for @purchaseReceipt.
  ///
  /// In en, this message translates to:
  /// **'Purchase Receipt'**
  String get purchaseReceipt;

  /// No description provided for @reconcileInventory.
  ///
  /// In en, this message translates to:
  /// **'Reconcile Inventory'**
  String get reconcileInventory;

  /// No description provided for @reconciliation.
  ///
  /// In en, this message translates to:
  /// **'Reconciliation'**
  String get reconciliation;

  /// No description provided for @catalogs.
  ///
  /// In en, this message translates to:
  /// **'Catalogs'**
  String get catalogs;

  /// No description provided for @catalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get catalog;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @purchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get purchases;

  /// No description provided for @returns.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get returns;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @toCollect.
  ///
  /// In en, this message translates to:
  /// **'To Collect'**
  String get toCollect;

  /// No description provided for @toPay.
  ///
  /// In en, this message translates to:
  /// **'To Pay'**
  String get toPay;

  /// No description provided for @sectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get sectionDetails;

  /// No description provided for @sectionPricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get sectionPricing;

  /// No description provided for @sectionPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get sectionPayment;

  /// No description provided for @sectionDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get sectionDelivery;

  /// No description provided for @sectionStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get sectionStock;

  /// No description provided for @sectionSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get sectionSummary;

  /// No description provided for @sectionActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get sectionActions;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @noSalesYet.
  ///
  /// In en, this message translates to:
  /// **'No sales yet'**
  String get noSalesYet;

  /// No description provided for @noPurchasesYet.
  ///
  /// In en, this message translates to:
  /// **'No purchases yet'**
  String get noPurchasesYet;

  /// No description provided for @noReturnsYet.
  ///
  /// In en, this message translates to:
  /// **'No returns yet'**
  String get noReturnsYet;

  /// No description provided for @newSale.
  ///
  /// In en, this message translates to:
  /// **'New Sale'**
  String get newSale;

  /// No description provided for @newPurchase.
  ///
  /// In en, this message translates to:
  /// **'New Purchase'**
  String get newPurchase;

  /// No description provided for @newReturn.
  ///
  /// In en, this message translates to:
  /// **'New Return'**
  String get newReturn;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @walkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in'**
  String get walkInCustomer;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @partiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get partiallyPaid;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @shipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get shipped;

  /// No description provided for @deliveryPending.
  ///
  /// In en, this message translates to:
  /// **'Delivery Pending'**
  String get deliveryPending;

  /// No description provided for @deliveryStatus.
  ///
  /// In en, this message translates to:
  /// **'Delivery Status'**
  String get deliveryStatus;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orderNotFound;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select Product'**
  String get selectProduct;

  /// No description provided for @noProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No products available. Add a product first.'**
  String get noProductsAvailable;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @paymentNow.
  ///
  /// In en, this message translates to:
  /// **'Payment Now'**
  String get paymentNow;

  /// No description provided for @balanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance Due'**
  String get balanceDue;

  /// No description provided for @showAllContacts.
  ///
  /// In en, this message translates to:
  /// **'Show all contacts'**
  String get showAllContacts;

  /// No description provided for @addAtLeastOneItem.
  ///
  /// In en, this message translates to:
  /// **'Add at least one item'**
  String get addAtLeastOneItem;

  /// No description provided for @selectAccountForPayment.
  ///
  /// In en, this message translates to:
  /// **'Select an account to record the payment'**
  String get selectAccountForPayment;

  /// No description provided for @orderCreated.
  ///
  /// In en, this message translates to:
  /// **'Order created successfully'**
  String get orderCreated;

  /// No description provided for @markDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark as Delivered'**
  String get markDelivered;

  /// No description provided for @orderMarkedDelivered.
  ///
  /// In en, this message translates to:
  /// **'Order marked as delivered'**
  String get orderMarkedDelivered;

  /// No description provided for @inboundFreight.
  ///
  /// In en, this message translates to:
  /// **'Inbound freight'**
  String get inboundFreight;

  /// No description provided for @importDuty.
  ///
  /// In en, this message translates to:
  /// **'Import duty'**
  String get importDuty;

  /// No description provided for @landedCostHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. Added into inventory unit cost for this receipt.'**
  String get landedCostHint;

  /// No description provided for @receiveShipment.
  ///
  /// In en, this message translates to:
  /// **'Receive shipment'**
  String get receiveShipment;

  /// No description provided for @shareInvoice.
  ///
  /// In en, this message translates to:
  /// **'Share Invoice'**
  String get shareInvoice;

  /// No description provided for @paymentRecorded.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded successfully'**
  String get paymentRecorded;

  /// No description provided for @collectPayment.
  ///
  /// In en, this message translates to:
  /// **'Collect Payment'**
  String get collectPayment;

  /// No description provided for @payToSupplier.
  ///
  /// In en, this message translates to:
  /// **'Pay Supplier'**
  String get payToSupplier;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get invalidNumber;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @noProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProductsYet;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get lowStock;

  /// No description provided for @stockLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock: {quantity}'**
  String stockLabel(String quantity);

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @deleteProductConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String deleteProductConfirm(String name);

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeleted;

  /// No description provided for @productSaved.
  ///
  /// In en, this message translates to:
  /// **'Product saved successfully'**
  String get productSaved;

  /// No description provided for @sku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get sku;

  /// No description provided for @scanSkuTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan SKU'**
  String get scanSkuTitle;

  /// No description provided for @scanSkuHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at a barcode or QR code'**
  String get scanSkuHint;

  /// No description provided for @scanSkuTorch.
  ///
  /// In en, this message translates to:
  /// **'Torch'**
  String get scanSkuTorch;

  /// No description provided for @scanSkuUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Barcode scanning is available on phones. Enter the SKU manually here.'**
  String get scanSkuUnavailable;

  /// No description provided for @scanSkuReplaceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Replace current SKU with the scanned code?'**
  String get scanSkuReplaceConfirm;

  /// No description provided for @scanSkuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode or QR'**
  String get scanSkuTooltip;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @purchasePrice.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price'**
  String get purchasePrice;

  /// No description provided for @retailPrice.
  ///
  /// In en, this message translates to:
  /// **'Retail Price'**
  String get retailPrice;

  /// No description provided for @wholesalePrice.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Price'**
  String get wholesalePrice;

  /// No description provided for @stockQuantity.
  ///
  /// In en, this message translates to:
  /// **'Stock Quantity'**
  String get stockQuantity;

  /// No description provided for @openingStock.
  ///
  /// In en, this message translates to:
  /// **'Opening Stock'**
  String get openingStock;

  /// No description provided for @currentStock.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get currentStock;

  /// No description provided for @currentStockHint.
  ///
  /// In en, this message translates to:
  /// **'Managed by purchases, sales, and stock adjustments'**
  String get currentStockHint;

  /// No description provided for @productMasterHint.
  ///
  /// In en, this message translates to:
  /// **'Identity only — stock via lots or purchases; prices via catalogs later'**
  String get productMasterHint;

  /// No description provided for @productStockManagedElsewhere.
  ///
  /// In en, this message translates to:
  /// **'On-hand stock comes from lots and purchase receipts'**
  String get productStockManagedElsewhere;

  /// No description provided for @minStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Min Stock Alert'**
  String get minStockAlert;

  /// No description provided for @isServiceProduct.
  ///
  /// In en, this message translates to:
  /// **'This is a service (no stock tracking)'**
  String get isServiceProduct;

  /// No description provided for @serviceProduct.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get serviceProduct;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FlowKarobar'**
  String get appTitle;

  /// No description provided for @backgroundActivityStarted.
  ///
  /// In en, this message translates to:
  /// **'Activity started in background'**
  String get backgroundActivityStarted;

  /// No description provided for @backgroundBackupStarted.
  ///
  /// In en, this message translates to:
  /// **'Backup started in background'**
  String get backgroundBackupStarted;

  /// No description provided for @backgroundCloudClearStarted.
  ///
  /// In en, this message translates to:
  /// **'Cloud clear started in background'**
  String get backgroundCloudClearStarted;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceLabel;

  /// No description provided for @targetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get targetLabel;

  /// No description provided for @limitLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limitLabel;

  /// No description provided for @leftLabel.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get leftLabel;

  /// No description provided for @needed.
  ///
  /// In en, this message translates to:
  /// **'Needed'**
  String get needed;

  /// No description provided for @surplus.
  ///
  /// In en, this message translates to:
  /// **'Surplus'**
  String get surplus;

  /// No description provided for @cloudBackupsFor.
  ///
  /// In en, this message translates to:
  /// **'Backups for {name}'**
  String cloudBackupsFor(String name);

  /// No description provided for @bulkImport.
  ///
  /// In en, this message translates to:
  /// **'Bulk Import'**
  String get bulkImport;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste from Clipboard'**
  String get pasteFromClipboard;

  /// No description provided for @pickCsvFile.
  ///
  /// In en, this message translates to:
  /// **'Pick CSV File'**
  String get pickCsvFile;

  /// No description provided for @importSettings.
  ///
  /// In en, this message translates to:
  /// **'Import Settings'**
  String get importSettings;

  /// No description provided for @separator.
  ///
  /// In en, this message translates to:
  /// **'Separator'**
  String get separator;

  /// No description provided for @tab.
  ///
  /// In en, this message translates to:
  /// **'Tab'**
  String get tab;

  /// No description provided for @comma.
  ///
  /// In en, this message translates to:
  /// **'Comma'**
  String get comma;

  /// No description provided for @semicolon.
  ///
  /// In en, this message translates to:
  /// **'Semicolon'**
  String get semicolon;

  /// No description provided for @pipe.
  ///
  /// In en, this message translates to:
  /// **'Pipe'**
  String get pipe;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date Format'**
  String get dateFormat;

  /// No description provided for @hasHeader.
  ///
  /// In en, this message translates to:
  /// **'Has Header'**
  String get hasHeader;

  /// No description provided for @columnMapping.
  ///
  /// In en, this message translates to:
  /// **'Column Mapping'**
  String get columnMapping;

  /// No description provided for @defaultValues.
  ///
  /// In en, this message translates to:
  /// **'Default Values'**
  String get defaultValues;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @importedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} transactions successfully'**
  String importedSuccessfully(int count);

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @cashbooks.
  ///
  /// In en, this message translates to:
  /// **'Cashbooks'**
  String get cashbooks;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @scheduleCreated.
  ///
  /// In en, this message translates to:
  /// **'Schedule created successfully'**
  String get scheduleCreated;

  /// No description provided for @scheduleDetails.
  ///
  /// In en, this message translates to:
  /// **'Schedule Details'**
  String get scheduleDetails;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @lastGenerated.
  ///
  /// In en, this message translates to:
  /// **'Last Generated'**
  String get lastGenerated;

  /// No description provided for @editSchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit Schedule'**
  String get editSchedule;

  /// No description provided for @deleteSchedule.
  ///
  /// In en, this message translates to:
  /// **'Delete Schedule'**
  String get deleteSchedule;

  /// No description provided for @deleteScheduleConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this schedule? This will stop all future automatic transactions for this schedule.'**
  String get deleteScheduleConfirmation;

  /// No description provided for @transactionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated successfully'**
  String get transactionUpdated;

  /// Label for indicating when a record was last updated
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @markAsReviewed.
  ///
  /// In en, this message translates to:
  /// **'Mark as Reviewed'**
  String get markAsReviewed;

  /// No description provided for @transactionMarkedAsReviewed.
  ///
  /// In en, this message translates to:
  /// **'Transaction marked as reviewed'**
  String get transactionMarkedAsReviewed;

  /// No description provided for @updateTransaction.
  ///
  /// In en, this message translates to:
  /// **'Update Transaction'**
  String get updateTransaction;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @payable.
  ///
  /// In en, this message translates to:
  /// **'Payable'**
  String get payable;

  /// No description provided for @syncSchedule.
  ///
  /// In en, this message translates to:
  /// **'Idle sync'**
  String get syncSchedule;

  /// No description provided for @noIdleSync.
  ///
  /// In en, this message translates to:
  /// **'No Idle Sync'**
  String get noIdleSync;

  /// No description provided for @autoSyncBadge.
  ///
  /// In en, this message translates to:
  /// **'Auto: {interval}h'**
  String autoSyncBadge(String interval);

  /// No description provided for @createdLabel.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String createdLabel(String date);

  /// No description provided for @defaultPremiumPrice.
  ///
  /// In en, this message translates to:
  /// **'\$9.99'**
  String get defaultPremiumPrice;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorOccurred(String error);

  /// No description provided for @noDataForTrends.
  ///
  /// In en, this message translates to:
  /// **'No data for trends'**
  String get noDataForTrends;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(int days);

  /// No description provided for @sample.
  ///
  /// In en, this message translates to:
  /// **'Sample: {sample}'**
  String sample(String sample);

  /// No description provided for @positiveAmount.
  ///
  /// In en, this message translates to:
  /// **'Positive: {amount}'**
  String positiveAmount(String amount);

  /// No description provided for @negativeAmount.
  ///
  /// In en, this message translates to:
  /// **'Negative: {amount}'**
  String negativeAmount(String amount);

  /// No description provided for @themeSet.
  ///
  /// In en, this message translates to:
  /// **'Theme set to {name}'**
  String themeSet(String name);

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {name}'**
  String languageChanged(String name);

  /// No description provided for @lastBackupAt.
  ///
  /// In en, this message translates to:
  /// **'Last Backup: {time}'**
  String lastBackupAt(String time);

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String restoreFailed(String error);

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String errorSaving(String error);

  /// No description provided for @errorSharing.
  ///
  /// In en, this message translates to:
  /// **'Error sharing: {error}'**
  String errorSharing(String error);

  /// No description provided for @errorExporting.
  ///
  /// In en, this message translates to:
  /// **'Error exporting: {error}'**
  String errorExporting(String error);

  /// No description provided for @exportSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Export saved to {path}'**
  String exportSavedTo(String path);

  /// No description provided for @notificationTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Notification: {title}'**
  String notificationTitlePrefix(String title);

  /// No description provided for @errorDeletingTransaction.
  ///
  /// In en, this message translates to:
  /// **'Error deleting transaction: {error}'**
  String errorDeletingTransaction(String error);

  /// No description provided for @noTypeCategories.
  ///
  /// In en, this message translates to:
  /// **'No {type} categories'**
  String noTypeCategories(String type);

  /// No description provided for @deleteCashbookMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}? This will permanently delete all data associated with this cashbook.'**
  String deleteCashbookMessage(String name);

  /// No description provided for @currencySetTo.
  ///
  /// In en, this message translates to:
  /// **'Currency set to {name}'**
  String currencySetTo(String name);

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this {item}?'**
  String confirmDelete(String item);

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get searchTransactions;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @renameSearch.
  ///
  /// In en, this message translates to:
  /// **'Rename Search'**
  String get renameSearch;

  /// No description provided for @enterNewName.
  ///
  /// In en, this message translates to:
  /// **'Enter new name'**
  String get enterNewName;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactions;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;

  /// No description provided for @cashbookName.
  ///
  /// In en, this message translates to:
  /// **'Cashbook Name'**
  String get cashbookName;

  /// No description provided for @createCashbook.
  ///
  /// In en, this message translates to:
  /// **'Create Cashbook'**
  String get createCashbook;

  /// No description provided for @editCashbook.
  ///
  /// In en, this message translates to:
  /// **'Edit Cashbook'**
  String get editCashbook;

  /// No description provided for @deleteCashbook.
  ///
  /// In en, this message translates to:
  /// **'Delete Cashbook'**
  String get deleteCashbook;

  /// No description provided for @cashbookDeleted.
  ///
  /// In en, this message translates to:
  /// **'Cashbook deleted successfully'**
  String get cashbookDeleted;

  /// No description provided for @cashbookAdded.
  ///
  /// In en, this message translates to:
  /// **'Cashbook added successfully'**
  String get cashbookAdded;

  /// No description provided for @cashbookUpdated.
  ///
  /// In en, this message translates to:
  /// **'Cashbook updated successfully'**
  String get cashbookUpdated;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @copyPreferences.
  ///
  /// In en, this message translates to:
  /// **'Copy Preferences'**
  String get copyPreferences;

  /// No description provided for @copyPreferencesFrom.
  ///
  /// In en, this message translates to:
  /// **'Copy Preferences From'**
  String get copyPreferencesFrom;

  /// No description provided for @copyPreferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Categories and settings will be copied from the selected cashbook.'**
  String get copyPreferencesSubtitle;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @howMuch.
  ///
  /// In en, this message translates to:
  /// **'How much?'**
  String get howMuch;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get amountHint;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// No description provided for @amountGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get amountGreaterThanZero;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @selectContact.
  ///
  /// In en, this message translates to:
  /// **'Select Contact'**
  String get selectContact;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Lunch money'**
  String get descriptionHint;

  /// No description provided for @premiumFeature.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeature;

  /// No description provided for @premiumRequired.
  ///
  /// In en, this message translates to:
  /// **'This feature requires a premium subscription.'**
  String get premiumRequired;

  /// No description provided for @getPremium.
  ///
  /// In en, this message translates to:
  /// **'Get Premium'**
  String get getPremium;

  /// No description provided for @switchedToCashbook.
  ///
  /// In en, this message translates to:
  /// **'Switched to {name}'**
  String switchedToCashbook(String name);

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get categoryBills;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categorySalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get categorySalary;

  /// No description provided for @categoryBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get categoryBusiness;

  /// No description provided for @categoryInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get categoryInvestment;

  /// No description provided for @categoryRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get categoryRent;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @receivables.
  ///
  /// In en, this message translates to:
  /// **'Receivables'**
  String get receivables;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @receivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get receivedLabel;

  /// No description provided for @generateDummyReceivables.
  ///
  /// In en, this message translates to:
  /// **'Generate 100 Dummy Receivables'**
  String get generateDummyReceivables;

  /// No description provided for @dummyGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated {count} dummy items'**
  String dummyGenerated(int count);

  /// No description provided for @errorLoadingReceivables.
  ///
  /// In en, this message translates to:
  /// **'Error loading receivables'**
  String get errorLoadingReceivables;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noPendingReceivables.
  ///
  /// In en, this message translates to:
  /// **'No pending receivables'**
  String get noPendingReceivables;

  /// No description provided for @noOverdueReceivables.
  ///
  /// In en, this message translates to:
  /// **'No overdue receivables'**
  String get noOverdueReceivables;

  /// No description provided for @noReceivedPayments.
  ///
  /// In en, this message translates to:
  /// **'No received payments'**
  String get noReceivedPayments;

  /// No description provided for @addReceivableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a receivable to track money owed to you'**
  String get addReceivableSubtitle;

  /// No description provided for @receivablesUpToDate.
  ///
  /// In en, this message translates to:
  /// **'All receivables are up to date'**
  String get receivablesUpToDate;

  /// No description provided for @markReceivedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mark pending receivables as received'**
  String get markReceivedSubtitle;

  /// No description provided for @noMoreItems.
  ///
  /// In en, this message translates to:
  /// **'No more items'**
  String get noMoreItems;

  /// No description provided for @receivableDeleted.
  ///
  /// In en, this message translates to:
  /// **'Receivable deleted'**
  String get receivableDeleted;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @dueAt.
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String dueAt(String date);

  /// No description provided for @receivable.
  ///
  /// In en, this message translates to:
  /// **'Receivable'**
  String get receivable;

  /// No description provided for @addReceivable.
  ///
  /// In en, this message translates to:
  /// **'Add Receivable'**
  String get addReceivable;

  /// No description provided for @receivableIntentTitle.
  ///
  /// In en, this message translates to:
  /// **'How would you like to record this?'**
  String get receivableIntentTitle;

  /// No description provided for @receivableIntentBoughtForContact.
  ///
  /// In en, this message translates to:
  /// **'You paid for something for {contact}. They\'ll pay you back.'**
  String receivableIntentBoughtForContact(String contact);

  /// No description provided for @receivableIntentServicesAmount.
  ///
  /// In en, this message translates to:
  /// **'{contact} will pay you {amount} for your services.'**
  String receivableIntentServicesAmount(String amount, String contact);

  /// No description provided for @receivableIntentJustRecord.
  ///
  /// In en, this message translates to:
  /// **'Just create a receivable'**
  String get receivableIntentJustRecord;

  /// No description provided for @receivableAlreadyImported.
  ///
  /// In en, this message translates to:
  /// **'This receivable has already been imported.'**
  String get receivableAlreadyImported;

  /// No description provided for @pleaseSelectContact.
  ///
  /// In en, this message translates to:
  /// **'Please select a contact'**
  String get pleaseSelectContact;

  /// No description provided for @receivableAdded.
  ///
  /// In en, this message translates to:
  /// **'Receivable added successfully'**
  String get receivableAdded;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'SHARE'**
  String get share;

  /// No description provided for @dueDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Due Date (Optional)'**
  String get dueDateOptional;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @autoCreateIncome.
  ///
  /// In en, this message translates to:
  /// **'Auto-create income'**
  String get autoCreateIncome;

  /// No description provided for @autoCreateIncomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record as income when marked as received'**
  String get autoCreateIncomeSubtitle;

  /// No description provided for @receivableNotFound.
  ///
  /// In en, this message translates to:
  /// **'Receivable not found'**
  String get receivableNotFound;

  /// No description provided for @receivableUpdated.
  ///
  /// In en, this message translates to:
  /// **'Receivable updated successfully'**
  String get receivableUpdated;

  /// No description provided for @editReceivable.
  ///
  /// In en, this message translates to:
  /// **'Edit Receivable'**
  String get editReceivable;

  /// No description provided for @receivableDetails.
  ///
  /// In en, this message translates to:
  /// **'Receivable Details'**
  String get receivableDetails;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editDescription.
  ///
  /// In en, this message translates to:
  /// **'Edit Description'**
  String get editDescription;

  /// No description provided for @receivablePending.
  ///
  /// In en, this message translates to:
  /// **'Receivable (Pending)'**
  String get receivablePending;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @linkedTransaction.
  ///
  /// In en, this message translates to:
  /// **'Linked Transaction'**
  String get linkedTransaction;

  /// No description provided for @markAsReceived.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get markAsReceived;

  /// No description provided for @deleteReceivableTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Receivable'**
  String get deleteReceivableTitle;

  /// No description provided for @deleteReceivableMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this receivable? This action cannot be undone.'**
  String get deleteReceivableMessage;

  /// No description provided for @markedAsReceived.
  ///
  /// In en, this message translates to:
  /// **'Marked as received'**
  String get markedAsReceived;

  /// No description provided for @informContactSettlement.
  ///
  /// In en, this message translates to:
  /// **'Receivable marked as received. Inform the contact?'**
  String get informContactSettlement;

  /// No description provided for @addContactWithName.
  ///
  /// In en, this message translates to:
  /// **'Add {name}'**
  String addContactWithName(String name);

  /// No description provided for @payables.
  ///
  /// In en, this message translates to:
  /// **'Payables'**
  String get payables;

  /// No description provided for @generateDummyPayables.
  ///
  /// In en, this message translates to:
  /// **'Generate 100 Dummy Payables'**
  String get generateDummyPayables;

  /// No description provided for @dummyPayablesGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated 100 dummy payables'**
  String get dummyPayablesGenerated;

  /// No description provided for @errorLoadingPayables.
  ///
  /// In en, this message translates to:
  /// **'Error loading payables'**
  String get errorLoadingPayables;

  /// No description provided for @noPendingPayables.
  ///
  /// In en, this message translates to:
  /// **'No pending payables'**
  String get noPendingPayables;

  /// No description provided for @noOverduePayables.
  ///
  /// In en, this message translates to:
  /// **'No overdue payables'**
  String get noOverduePayables;

  /// No description provided for @noPaidBills.
  ///
  /// In en, this message translates to:
  /// **'No paid bills'**
  String get noPaidBills;

  /// No description provided for @addPayableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a payable to track money you owe'**
  String get addPayableSubtitle;

  /// No description provided for @allPayablesUpToDate.
  ///
  /// In en, this message translates to:
  /// **'All payables are up to date'**
  String get allPayablesUpToDate;

  /// No description provided for @markPendingAsPaidSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mark pending payables as paid'**
  String get markPendingAsPaidSubtitle;

  /// No description provided for @noMorePayables.
  ///
  /// In en, this message translates to:
  /// **'No more payables'**
  String get noMorePayables;

  /// No description provided for @payableDeleted.
  ///
  /// In en, this message translates to:
  /// **'Payable deleted'**
  String get payableDeleted;

  /// No description provided for @payableAlreadyImported.
  ///
  /// In en, this message translates to:
  /// **'This payable has already been imported.'**
  String get payableAlreadyImported;

  /// No description provided for @payableAdded.
  ///
  /// In en, this message translates to:
  /// **'Payable added successfully'**
  String get payableAdded;

  /// No description provided for @addPayable.
  ///
  /// In en, this message translates to:
  /// **'Add Payable'**
  String get addPayable;

  /// No description provided for @payableIntentTitle.
  ///
  /// In en, this message translates to:
  /// **'How would you like to record this?'**
  String get payableIntentTitle;

  /// No description provided for @payableIntentContactBoughtForYou.
  ///
  /// In en, this message translates to:
  /// **'{contact} paid for something on your behalf.'**
  String payableIntentContactBoughtForYou(String contact);

  /// No description provided for @payableIntentBorrowedFrom.
  ///
  /// In en, this message translates to:
  /// **'You borrowed {amount} from {contact}.'**
  String payableIntentBorrowedFrom(String amount, String contact);

  /// No description provided for @payableIntentJustRecord.
  ///
  /// In en, this message translates to:
  /// **'Just create a payable'**
  String get payableIntentJustRecord;

  /// No description provided for @editPayable.
  ///
  /// In en, this message translates to:
  /// **'Edit Payable'**
  String get editPayable;

  /// No description provided for @payableNotFound.
  ///
  /// In en, this message translates to:
  /// **'Payable not found'**
  String get payableNotFound;

  /// No description provided for @payableDataNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Payable data not loaded'**
  String get payableDataNotLoaded;

  /// No description provided for @payableUpdated.
  ///
  /// In en, this message translates to:
  /// **'Payable updated successfully'**
  String get payableUpdated;

  /// No description provided for @updatePayable.
  ///
  /// In en, this message translates to:
  /// **'Update Payable'**
  String get updatePayable;

  /// No description provided for @payableDetails.
  ///
  /// In en, this message translates to:
  /// **'Payable Details'**
  String get payableDetails;

  /// No description provided for @payablePending.
  ///
  /// In en, this message translates to:
  /// **'Payable (Pending)'**
  String get payablePending;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @markAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get markAsPaid;

  /// No description provided for @deletePayableTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Payable'**
  String get deletePayableTitle;

  /// No description provided for @deletePayableMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this payable? This action cannot be undone.'**
  String get deletePayableMessage;

  /// No description provided for @markedAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Marked as paid'**
  String get markedAsPaid;

  /// No description provided for @informContactSettlementPayable.
  ///
  /// In en, this message translates to:
  /// **'Payable marked as paid. Inform the contact?'**
  String get informContactSettlementPayable;

  /// No description provided for @autoCreateExpense.
  ///
  /// In en, this message translates to:
  /// **'Auto-create expense'**
  String get autoCreateExpense;

  /// No description provided for @autoCreateExpenseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record as expense when marked as paid'**
  String get autoCreateExpenseSubtitle;

  /// No description provided for @appRefreshLanguage.
  ///
  /// In en, this message translates to:
  /// **'The app will refresh to apply the new language'**
  String get appRefreshLanguage;

  /// No description provided for @connectGoogleDrive.
  ///
  /// In en, this message translates to:
  /// **'Connect Google Drive'**
  String get connectGoogleDrive;

  /// No description provided for @cloudBackupAccount.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup Account'**
  String get cloudBackupAccount;

  /// No description provided for @autofillFromGoogle.
  ///
  /// In en, this message translates to:
  /// **'Autofill from Google'**
  String get autofillFromGoogle;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @photoUploadComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Photo upload coming soon!'**
  String get photoUploadComingSoon;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @enterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your address'**
  String get enterAddress;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @selectDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Select Date Format'**
  String get selectDateFormat;

  /// No description provided for @customFormat.
  ///
  /// In en, this message translates to:
  /// **'Custom Format'**
  String get customFormat;

  /// No description provided for @enterCustomDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter your own date format pattern'**
  String get enterCustomDateFormat;

  /// No description provided for @customDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Custom Date Format'**
  String get customDateFormat;

  /// No description provided for @formatPattern.
  ///
  /// In en, this message translates to:
  /// **'Format Pattern'**
  String get formatPattern;

  /// No description provided for @dateFormatInstructions.
  ///
  /// In en, this message translates to:
  /// **'Use standard ICU patterns like:\ndd: Day, MM: Month, yyyy: Year\nMMM: Short Month, EEEE: Full Day'**
  String get dateFormatInstructions;

  /// No description provided for @lightThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Always use light theme'**
  String get lightThemeDescription;

  /// No description provided for @darkThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Always use dark theme'**
  String get darkThemeDescription;

  /// No description provided for @systemThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow device settings'**
  String get systemThemeDescription;

  /// No description provided for @themeChangesApplyImmediately.
  ///
  /// In en, this message translates to:
  /// **'Theme changes apply immediately'**
  String get themeChangesApplyImmediately;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @exportAnalyticsPDF.
  ///
  /// In en, this message translates to:
  /// **'Export Analytics PDF'**
  String get exportAnalyticsPDF;

  /// No description provided for @refreshAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Refresh Analytics'**
  String get refreshAnalytics;

  /// No description provided for @financialSummary.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get financialSummary;

  /// No description provided for @contactSummaries.
  ///
  /// In en, this message translates to:
  /// **'Contact Summaries'**
  String get contactSummaries;

  /// No description provided for @expensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get expensesByCategory;

  /// No description provided for @incomeVsExpenseTrend.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expense Trend'**
  String get incomeVsExpenseTrend;

  /// No description provided for @payablesVsReceivablesTrend.
  ///
  /// In en, this message translates to:
  /// **'Payables vs Receivables Trend'**
  String get payablesVsReceivablesTrend;

  /// No description provided for @topContactsByBalance.
  ///
  /// In en, this message translates to:
  /// **'Top Contacts by Balance'**
  String get topContactsByBalance;

  /// No description provided for @paymentStatusDistribution.
  ///
  /// In en, this message translates to:
  /// **'Payment Status Distribution'**
  String get paymentStatusDistribution;

  /// No description provided for @incomeByCategory.
  ///
  /// In en, this message translates to:
  /// **'Income by Category'**
  String get incomeByCategory;

  /// No description provided for @unlockAdvancedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Unlock advanced analytics, trends, and charts with Premium.'**
  String get unlockAdvancedAnalytics;

  /// No description provided for @unlockPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium'**
  String get unlockPremium;

  /// No description provided for @noContactActivity.
  ///
  /// In en, this message translates to:
  /// **'No contact activity for this period'**
  String get noContactActivity;

  /// No description provided for @settled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get settled;

  /// No description provided for @noExpensesPeriod.
  ///
  /// In en, this message translates to:
  /// **'No expenses for this period'**
  String get noExpensesPeriod;

  /// No description provided for @noDataTrends.
  ///
  /// In en, this message translates to:
  /// **'No data for trends'**
  String get noDataTrends;

  /// No description provided for @noPayableReceivableData.
  ///
  /// In en, this message translates to:
  /// **'No payable/receivable data'**
  String get noPayableReceivableData;

  /// No description provided for @noContactData.
  ///
  /// In en, this message translates to:
  /// **'No contact data'**
  String get noContactData;

  /// No description provided for @noPaymentStatusData.
  ///
  /// In en, this message translates to:
  /// **'No payment status data'**
  String get noPaymentStatusData;

  /// No description provided for @noIncome.
  ///
  /// In en, this message translates to:
  /// **'No income for this period'**
  String get noIncome;

  /// No description provided for @pdfReady.
  ///
  /// In en, this message translates to:
  /// **'PDF Ready'**
  String get pdfReady;

  /// No description provided for @backupReady.
  ///
  /// In en, this message translates to:
  /// **'Backup Ready'**
  String get backupReady;

  /// No description provided for @backupReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your database backup is ready. Choose an action:'**
  String get backupReadyMessage;

  /// No description provided for @analyticsPDFReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your analytics PDF report is ready. Choose an action:'**
  String get analyticsPDFReadyMessage;

  /// No description provided for @saveCopy.
  ///
  /// In en, this message translates to:
  /// **'Save Copy'**
  String get saveCopy;

  /// No description provided for @savedToDownloads.
  ///
  /// In en, this message translates to:
  /// **'Saved to Downloads'**
  String get savedToDownloads;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @quarter.
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get quarter;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @payableShort.
  ///
  /// In en, this message translates to:
  /// **'P:'**
  String get payableShort;

  /// No description provided for @receivableShort.
  ///
  /// In en, this message translates to:
  /// **'R:'**
  String get receivableShort;

  /// No description provided for @netBalance.
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get netBalance;

  /// No description provided for @balanceReceivableMinusPayable.
  ///
  /// In en, this message translates to:
  /// **'Balance (Receivable − Payable)'**
  String get balanceReceivableMinusPayable;

  /// No description provided for @netReceivable.
  ///
  /// In en, this message translates to:
  /// **'Net Receivable'**
  String get netReceivable;

  /// No description provided for @netPayable.
  ///
  /// In en, this message translates to:
  /// **'Net Payable'**
  String get netPayable;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All-time:'**
  String get allTime;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @noExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses for this period'**
  String get noExpenses;

  /// No description provided for @expanded.
  ///
  /// In en, this message translates to:
  /// **'expanded'**
  String get expanded;

  /// No description provided for @collapsed.
  ///
  /// In en, this message translates to:
  /// **'collapsed'**
  String get collapsed;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @allNotificationsMarkedRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsMarkedRead;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'All Read'**
  String get markAllRead;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @clearAllItemsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all items?'**
  String get clearAllItemsConfirmation;

  /// No description provided for @clearAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear all notifications?'**
  String get clearAllNotifications;

  /// No description provided for @clearAllNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all notifications? This action cannot be undone.'**
  String get clearAllNotificationsMessage;

  /// No description provided for @unsyncedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsynced Changes'**
  String get unsyncedChanges;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @notificationsCleared.
  ///
  /// In en, this message translates to:
  /// **'All notifications cleared'**
  String get notificationsCleared;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get noNotifications;

  /// No description provided for @noNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up! We\'ll notify you about:\n\n• Due receivables and payables\n• Transaction milestones\n• Backup reminders\n• Important updates'**
  String get noNotificationsDescription;

  /// No description provided for @notificationsTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Set due dates for receivables and payables to get timely reminders'**
  String get notificationsTip;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @toggledDebugMode.
  ///
  /// In en, this message translates to:
  /// **'Toggled Debug Mode'**
  String get toggledDebugMode;

  /// No description provided for @debugToggleMode.
  ///
  /// In en, this message translates to:
  /// **'DEBUG: Toggle Mode'**
  String get debugToggleMode;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'FlowKarobar Premium'**
  String get premiumTitle;

  /// No description provided for @unlockAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features'**
  String get unlockAllFeatures;

  /// No description provided for @premiumMemberStatus.
  ///
  /// In en, this message translates to:
  /// **'You are a Premium Member'**
  String get premiumMemberStatus;

  /// No description provided for @premiumFeaturesActive.
  ///
  /// In en, this message translates to:
  /// **'All premium features are active'**
  String get premiumFeaturesActive;

  /// No description provided for @featureCloudBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic Cloud Backup'**
  String get featureCloudBackupTitle;

  /// No description provided for @featureCloudBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Your data is automatically backed up to Google Drive. Never lose your financial records.'**
  String get featureCloudBackupDesc;

  /// No description provided for @featureAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get featureAnalyticsTitle;

  /// No description provided for @featureAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get detailed insights with advanced charts, trends, and financial forecasting.'**
  String get featureAnalyticsDesc;

  /// No description provided for @featurePdfReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'PDF Reports'**
  String get featurePdfReportsTitle;

  /// No description provided for @featurePdfReportsDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate beautiful PDF reports with charts and summaries for any date range.'**
  String get featurePdfReportsDesc;

  /// No description provided for @featureUnlimitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Transactions'**
  String get featureUnlimitedTitle;

  /// No description provided for @featureUnlimitedDesc.
  ///
  /// In en, this message translates to:
  /// **'No limits on the number of transactions, contacts, or categories you can create.'**
  String get featureUnlimitedDesc;

  /// No description provided for @featureSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Priority Support'**
  String get featureSupportTitle;

  /// No description provided for @featureSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Get faster responses and dedicated support for any issues or questions.'**
  String get featureSupportDesc;

  /// No description provided for @featureEarlyAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Early Access'**
  String get featureEarlyAccessTitle;

  /// No description provided for @featureEarlyAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Be the first to try new features before they\'re released to everyone.'**
  String get featureEarlyAccessDesc;

  /// No description provided for @featureTemplatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Message Templates'**
  String get featureTemplatesTitle;

  /// No description provided for @featureTemplatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize WhatsApp message templates for reminders, receipts, and sharing in multiple languages.'**
  String get featureTemplatesDesc;

  /// No description provided for @featureMultiDeviceSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Multi-Device Sync'**
  String get featureMultiDeviceSyncTitle;

  /// No description provided for @featureMultiDeviceSyncDesc.
  ///
  /// In en, this message translates to:
  /// **'Sync your data across all your devices using Google Drive. Your records are always up to date.'**
  String get featureMultiDeviceSyncDesc;

  /// No description provided for @featureMultipleCashbooksTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Cashbooks'**
  String get featureMultipleCashbooksTitle;

  /// No description provided for @featureMultipleCashbooksDesc.
  ///
  /// In en, this message translates to:
  /// **'Create and manage as many additional cashbooks as you need for different businesses or personal use.'**
  String get featureMultipleCashbooksDesc;

  /// No description provided for @featureUnlimitedSchedulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Schedules'**
  String get featureUnlimitedSchedulesTitle;

  /// No description provided for @featureUnlimitedSchedulesDesc.
  ///
  /// In en, this message translates to:
  /// **'Set up unlimited recurring transaction schedules for your regular incomes and expenses.'**
  String get featureUnlimitedSchedulesDesc;

  /// No description provided for @featureUnlimitedVoiceExtractionTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Voice Smart Extraction'**
  String get featureUnlimitedVoiceExtractionTitle;

  /// No description provided for @featureUnlimitedVoiceExtractionDesc.
  ///
  /// In en, this message translates to:
  /// **'Use smart extraction for voice commands without monthly limits. Add transactions by speaking in natural language.'**
  String get featureUnlimitedVoiceExtractionDesc;

  /// No description provided for @featureUnlimitedReceiptExtractionTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Receipt Smart Extraction'**
  String get featureUnlimitedReceiptExtractionTitle;

  /// No description provided for @featureUnlimitedReceiptExtractionDesc.
  ///
  /// In en, this message translates to:
  /// **'Use smart extraction for receipt scanning without monthly limits. Extract amount, merchant, and category from receipts automatically.'**
  String get featureUnlimitedReceiptExtractionDesc;

  /// No description provided for @featureBulkImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk Import'**
  String get featureBulkImportTitle;

  /// No description provided for @featureBulkImportDesc.
  ///
  /// In en, this message translates to:
  /// **'Import hundreds of transactions instantly from CSV files or your clipboard (Google Sheets).'**
  String get featureBulkImportDesc;

  /// No description provided for @featureBulkSettlementTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk Settlement (Receivables & Payables)'**
  String get featureBulkSettlementTitle;

  /// No description provided for @featureBulkSettlementDesc.
  ///
  /// In en, this message translates to:
  /// **'Settle multiple receivables or payables in one go. Mark many entries as paid or received at once.'**
  String get featureBulkSettlementDesc;

  /// No description provided for @premiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium Plan'**
  String get premiumPlan;

  /// No description provided for @lifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetime;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// No description provided for @chooseYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get chooseYourPlan;

  /// No description provided for @cancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get cancelAnytime;

  /// No description provided for @savePercentage.
  ///
  /// In en, this message translates to:
  /// **'Save {percentage}%'**
  String savePercentage(Object percentage);

  /// No description provided for @oneTimePayment.
  ///
  /// In en, this message translates to:
  /// **'Pay once, own forever'**
  String get oneTimePayment;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @oneTimePaymentLifetime.
  ///
  /// In en, this message translates to:
  /// **'One-time payment • Lifetime access'**
  String get oneTimePaymentLifetime;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @premiumBenefitsNote.
  ///
  /// In en, this message translates to:
  /// **'Unlock all premium features with your chosen plan. Choose Lifetime for permanent access!'**
  String get premiumBenefitsNote;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @freeTrial.
  ///
  /// In en, this message translates to:
  /// **'Free Trial'**
  String get freeTrial;

  /// No description provided for @noPurchasesFound.
  ///
  /// In en, this message translates to:
  /// **'No purchases found to restore.'**
  String get noPurchasesFound;

  /// No description provided for @daysFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'{days} days free trial'**
  String daysFreeTrial(int days);

  /// No description provided for @monthFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'{months} month free trial'**
  String monthFreeTrial(int months);

  /// No description provided for @googleDriveBackup.
  ///
  /// In en, this message translates to:
  /// **'Google Drive Backup'**
  String get googleDriveBackup;

  /// No description provided for @cloudBackupPremiumDesc.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup to Google Drive is available for Premium users.'**
  String get cloudBackupPremiumDesc;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signInGoogleToBackup.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google to backup your data'**
  String get signInGoogleToBackup;

  /// No description provided for @signInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInGoogle;

  /// No description provided for @googleServicesNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Backup requires valid Google Services configuration. If sign-in fails, check your setup.'**
  String get googleServicesNote;

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Backup Now'**
  String get backupNow;

  /// No description provided for @noBackupsFound.
  ///
  /// In en, this message translates to:
  /// **'No backups found'**
  String get noBackupsFound;

  /// No description provided for @availableBackups.
  ///
  /// In en, this message translates to:
  /// **'Available Backups'**
  String get availableBackups;

  /// No description provided for @restoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup?'**
  String get restoreBackupTitle;

  /// No description provided for @restoreBackupMessage.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite your current data with the selected backup. \n\n⚠️ The app will need to be restarted after restoration.'**
  String get restoreBackupMessage;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Restore Successful'**
  String get restoreSuccessful;

  /// No description provided for @restoreSuccessfulMessage.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully. Please close and restart the app to apply changes.'**
  String get restoreSuccessfulMessage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @categoryHiddenSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category hidden successfully'**
  String get categoryHiddenSuccessfully;

  /// No description provided for @categoryDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category deleted successfully'**
  String get categoryDeletedSuccessfully;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @suggestedIcons.
  ///
  /// In en, this message translates to:
  /// **'Suggested Icons'**
  String get suggestedIcons;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @allIcons.
  ///
  /// In en, this message translates to:
  /// **'All Icons'**
  String get allIcons;

  /// No description provided for @saveCategory.
  ///
  /// In en, this message translates to:
  /// **'Save Category'**
  String get saveCategory;

  /// No description provided for @categoryAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category added successfully'**
  String get categoryAddedSuccessfully;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @categoryUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully'**
  String get categoryUpdatedSuccessfully;

  /// No description provided for @failedToUpdateCategory.
  ///
  /// In en, this message translates to:
  /// **'Failed to update category'**
  String get failedToUpdateCategory;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense Category'**
  String get expenseCategory;

  /// No description provided for @incomeCategory.
  ///
  /// In en, this message translates to:
  /// **'Income Category'**
  String get incomeCategory;

  /// No description provided for @updateCategory.
  ///
  /// In en, this message translates to:
  /// **'Update Category'**
  String get updateCategory;

  /// No description provided for @searchContacts.
  ///
  /// In en, this message translates to:
  /// **'Search contacts...'**
  String get searchContacts;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @noContactsYet.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet'**
  String get noContactsYet;

  /// No description provided for @noContactsFound.
  ///
  /// In en, this message translates to:
  /// **'No contacts found'**
  String get noContactsFound;

  /// No description provided for @addPeopleToTrack.
  ///
  /// In en, this message translates to:
  /// **'Add people to track expenses with'**
  String get addPeopleToTrack;

  /// No description provided for @trySearchingDifferentName.
  ///
  /// In en, this message translates to:
  /// **'Try searching for a different name'**
  String get trySearchingDifferentName;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get addContact;

  /// No description provided for @contactDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Contact deleted successfully'**
  String get contactDeletedSuccessfully;

  /// No description provided for @contactPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Contact permission denied. Please enable it in settings.'**
  String get contactPermissionDenied;

  /// No description provided for @errorPickingContact.
  ///
  /// In en, this message translates to:
  /// **'Error picking contact: {error}'**
  String errorPickingContact(String error);

  /// No description provided for @selectPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Select Phone Number'**
  String get selectPhoneNumber;

  /// No description provided for @contactUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Contact updated successfully'**
  String get contactUpdatedSuccessfully;

  /// No description provided for @contactAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Contact added successfully'**
  String get contactAddedSuccessfully;

  /// No description provided for @editContact.
  ///
  /// In en, this message translates to:
  /// **'Edit Contact'**
  String get editContact;

  /// No description provided for @importFromContacts.
  ///
  /// In en, this message translates to:
  /// **'Import from Contacts'**
  String get importFromContacts;

  /// No description provided for @phoneNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (Optional)'**
  String get phoneNumberOptional;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (Optional)'**
  String get emailOptional;

  /// No description provided for @addressNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Address / Notes (Optional)'**
  String get addressNotesOptional;

  /// No description provided for @updateContact.
  ///
  /// In en, this message translates to:
  /// **'Update Contact'**
  String get updateContact;

  /// No description provided for @saveContact.
  ///
  /// In en, this message translates to:
  /// **'Save Contact'**
  String get saveContact;

  /// No description provided for @myCashbooks.
  ///
  /// In en, this message translates to:
  /// **'My Cashbooks'**
  String get myCashbooks;

  /// No description provided for @manageCashbooks.
  ///
  /// In en, this message translates to:
  /// **'Manage multiple cashbooks'**
  String get manageCashbooks;

  /// No description provided for @manageContacts.
  ///
  /// In en, this message translates to:
  /// **'Manage your contacts'**
  String get manageContacts;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage expense & income categories'**
  String get manageCategories;

  /// No description provided for @manageCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Manage currencies'**
  String get manageCurrencies;

  /// No description provided for @googleDriveBackupRestore.
  ///
  /// In en, this message translates to:
  /// **'Google Drive Backup & Restore'**
  String get googleDriveBackupRestore;

  /// No description provided for @messageTemplates.
  ///
  /// In en, this message translates to:
  /// **'Message Templates'**
  String get messageTemplates;

  /// No description provided for @customizeMessageTemplates.
  ///
  /// In en, this message translates to:
  /// **'Customize WhatsApp message templates'**
  String get customizeMessageTemplates;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @downloadDataCsvPdf.
  ///
  /// In en, this message translates to:
  /// **'Download your data as CSV or PDF'**
  String get downloadDataCsvPdf;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium Active'**
  String get premiumActive;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate FlowKarobar'**
  String get rateUs;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Track every paisa'**
  String get tagline;

  /// No description provided for @versionInfo.
  ///
  /// In en, this message translates to:
  /// **'Version {version} (Build {buildNumber})'**
  String versionInfo(String version, String buildNumber);

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'FlowKarobar is a comprehensive business and cash flow manager. Track your sales, purchases, products, orders, receivables, and payables all in one place. Features include receipt scanning, WhatsApp integration, cloud backup, and beautiful analytics.'**
  String get appDescription;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get developedBy;

  /// No description provided for @developerName.
  ///
  /// In en, this message translates to:
  /// **'TamataSoft'**
  String get developerName;

  /// No description provided for @userGuide.
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get userGuide;

  /// No description provided for @guideGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get guideGettingStarted;

  /// No description provided for @guideGettingStartedDesc.
  ///
  /// In en, this message translates to:
  /// **'Learn how to add transactions and manage your cashbooks.'**
  String get guideGettingStartedDesc;

  /// No description provided for @guideManagingMoney.
  ///
  /// In en, this message translates to:
  /// **'Managing Money'**
  String get guideManagingMoney;

  /// No description provided for @guideManagingMoneyDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your income, expenses, receivables, and payables.'**
  String get guideManagingMoneyDesc;

  /// No description provided for @guideRelationships.
  ///
  /// In en, this message translates to:
  /// **'Relationships & Linked Transactions'**
  String get guideRelationships;

  /// No description provided for @guideRelationshipsDesc.
  ///
  /// In en, this message translates to:
  /// **'Understand how to link transactions with contacts and track loans.'**
  String get guideRelationshipsDesc;

  /// No description provided for @guideSharing.
  ///
  /// In en, this message translates to:
  /// **'Sharing & Deep Links'**
  String get guideSharing;

  /// No description provided for @guideSharingDesc.
  ///
  /// In en, this message translates to:
  /// **'Share transactions and sync data across devices using deep links.'**
  String get guideSharingDesc;

  /// No description provided for @guideAdvancedFeatures.
  ///
  /// In en, this message translates to:
  /// **'Advanced Features'**
  String get guideAdvancedFeatures;

  /// No description provided for @guideAdvancedFeaturesDesc.
  ///
  /// In en, this message translates to:
  /// **'Use receipt scanning, split bills, and cloud backup.'**
  String get guideAdvancedFeaturesDesc;

  /// No description provided for @guideCustomization.
  ///
  /// In en, this message translates to:
  /// **'Customization'**
  String get guideCustomization;

  /// No description provided for @guideCustomizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Personalize categories, currencies, themes, and languages.'**
  String get guideCustomizationDesc;

  /// No description provided for @guideAddTransaction.
  ///
  /// In en, this message translates to:
  /// **'How to add a transaction?'**
  String get guideAddTransaction;

  /// No description provided for @guideAddTransactionStep.
  ///
  /// In en, this message translates to:
  /// **'Tap the \'+\' button on the dashboard or transactions screen, enter the amount, select a category, and save.'**
  String get guideAddTransactionStep;

  /// No description provided for @guideSwitchCashbook.
  ///
  /// In en, this message translates to:
  /// **'How to switch cashbooks?'**
  String get guideSwitchCashbook;

  /// No description provided for @guideSwitchCashbookStep.
  ///
  /// In en, this message translates to:
  /// **'Tap the cashbook name on the dashboard header to open the cashbook manager and select another one.'**
  String get guideSwitchCashbookStep;

  /// No description provided for @guideTrackReceivables.
  ///
  /// In en, this message translates to:
  /// **'Tracking Receivables'**
  String get guideTrackReceivables;

  /// No description provided for @guideTrackReceivablesStep.
  ///
  /// In en, this message translates to:
  /// **'Use the \'Receivables\' section to track money people owe you. You can mark them as received to automatically create income.'**
  String get guideTrackReceivablesStep;

  /// No description provided for @guideTrackPayablesStep.
  ///
  /// In en, this message translates to:
  /// **'Use the \'Payables\' section to track money you owe to others. You can mark them as paid to automatically create expense.'**
  String get guideTrackPayablesStep;

  /// No description provided for @guideLinkedTransactions.
  ///
  /// In en, this message translates to:
  /// **'What are Linked Transactions?'**
  String get guideLinkedTransactions;

  /// No description provided for @guideLinkedTransactionsStep.
  ///
  /// In en, this message translates to:
  /// **'Linked transactions connect an expense to a receivable or an income to a payable.\n\nExample: You paid \$50 for a friend\'s lunch. You record an Expense of \$50 and link it as \'Paid FOR\' that friend. This automatically creates a \$50 Receivable for that contact.'**
  String get guideLinkedTransactionsStep;

  /// No description provided for @guideSplitBill.
  ///
  /// In en, this message translates to:
  /// **'How to use Split Bill?'**
  String get guideSplitBill;

  /// No description provided for @guideSplitBillStep.
  ///
  /// In en, this message translates to:
  /// **'When adding an expense, tap \'Split Bill\'. You can divide the total amount among multiple contacts equally or by percentage. The app will create individual receivables for each person\'s share.'**
  String get guideSplitBillStep;

  /// No description provided for @guideDeepLinks.
  ///
  /// In en, this message translates to:
  /// **'Sharing via Deep Links'**
  String get guideDeepLinks;

  /// No description provided for @guideDeepLinksStep.
  ///
  /// In en, this message translates to:
  /// **'Tap the \'Share\' icon on any transaction or receivable. This generates a unique link. When the recipient clicks the link on their device, FlowKarobar will open and allow them to import that transaction into their own cashbook.'**
  String get guideDeepLinksStep;

  /// No description provided for @guideImportDeepLink.
  ///
  /// In en, this message translates to:
  /// **'How to import a shared transaction?'**
  String get guideImportDeepLink;

  /// No description provided for @guideImportDeepLinkStep.
  ///
  /// In en, this message translates to:
  /// **'When you receive a FlowKarobar link via WhatsApp or message, simply tap it. The app will open a preview screen showing the details. Tap \'Import\' to add it to your records. If it\'s a settlement, it will update your existing pending record.'**
  String get guideImportDeepLinkStep;

  /// No description provided for @guideSyncDevices.
  ///
  /// In en, this message translates to:
  /// **'How to share cashbook to another device?'**
  String get guideSyncDevices;

  /// No description provided for @guideSyncDevicesStep.
  ///
  /// In en, this message translates to:
  /// **'1. Enable \'Google Drive Backup\' in Settings on your first device.\n2. On the second device, sign in with the SAME Google account.\n3. Go to Backup settings and tap \'Restore\' to download your cashbook data. Use \'Sync Now\' for ongoing real-time updates.'**
  String get guideSyncDevicesStep;

  /// No description provided for @guideCloudBackup.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup & Sync'**
  String get guideCloudBackup;

  /// No description provided for @guideCloudBackupStep.
  ///
  /// In en, this message translates to:
  /// **'Enable Google Drive backup in Settings to keep your data safe and sync across multiple devices.'**
  String get guideCloudBackupStep;

  /// No description provided for @guideScanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt Scanning'**
  String get guideScanReceipt;

  /// No description provided for @guideScanReceiptStep.
  ///
  /// In en, this message translates to:
  /// **'Use the \'Scan\' action on the dashboard to automatically extract amount and merchant from your paper receipts.'**
  String get guideScanReceiptStep;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 TamataSoft. All rights reserved.'**
  String get copyright;

  /// No description provided for @receiptScan.
  ///
  /// In en, this message translates to:
  /// **'Receipt Scan'**
  String get receiptScan;

  /// No description provided for @cloudBackup.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup'**
  String get cloudBackup;

  /// No description provided for @multilingual.
  ///
  /// In en, this message translates to:
  /// **'Multilingual'**
  String get multilingual;

  /// No description provided for @privacyHighlight.
  ///
  /// In en, this message translates to:
  /// **'Private & Secure'**
  String get privacyHighlight;

  /// No description provided for @privacyHighlightDesc.
  ///
  /// In en, this message translates to:
  /// **'Your financial data stays on your device or in your private cloud. No one else can access it.'**
  String get privacyHighlightDesc;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyDesc.
  ///
  /// In en, this message translates to:
  /// **'We value your privacy. Your data is stored locally on your device and can be optionally synced with your private Google Drive. We do not have access to your financial records.'**
  String get privacyPolicyDesc;

  /// No description provided for @availableCash.
  ///
  /// In en, this message translates to:
  /// **'Available Cash'**
  String get availableCash;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @bulkImportLoadingContent.
  ///
  /// In en, this message translates to:
  /// **'Loading data…'**
  String get bulkImportLoadingContent;

  /// No description provided for @bulkImportProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% ({current} / {total})'**
  String bulkImportProgress(int percent, int current, int total);

  /// No description provided for @bulkImportPreviewLimited.
  ///
  /// In en, this message translates to:
  /// **'Preview shows first {shown} of {total} rows'**
  String bulkImportPreviewLimited(int shown, int total);

  /// No description provided for @bulkImportPreviewShowingFirst.
  ///
  /// In en, this message translates to:
  /// **'Previewing first {shown} of {total} rows'**
  String bulkImportPreviewShowingFirst(int shown, int total);

  /// No description provided for @bulkImportPreviewShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get bulkImportPreviewShowAll;

  /// No description provided for @bulkImportPreviewShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get bulkImportPreviewShowLess;

  /// No description provided for @bulkImportPreviewShowingAllRows.
  ///
  /// In en, this message translates to:
  /// **'Showing all {total} rows'**
  String bulkImportPreviewShowingAllRows(int total);

  /// No description provided for @bulkImportLinkColumn.
  ///
  /// In en, this message translates to:
  /// **'Receivable / Payable'**
  String get bulkImportLinkColumn;

  /// No description provided for @bulkImportDefaultLink.
  ///
  /// In en, this message translates to:
  /// **'Default receivable / payable'**
  String get bulkImportDefaultLink;

  /// No description provided for @bulkImportUpdatingPreview.
  ///
  /// In en, this message translates to:
  /// **'Updating preview…'**
  String get bulkImportUpdatingPreview;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get scanReceipt;

  /// No description provided for @voiceAdd.
  ///
  /// In en, this message translates to:
  /// **'Voice Add'**
  String get voiceAdd;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @recentUpdates.
  ///
  /// In en, this message translates to:
  /// **'Recent Updates'**
  String get recentUpdates;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @tapToAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first transaction'**
  String get tapToAddFirst;

  /// No description provided for @cashFlow.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow'**
  String get cashFlow;

  /// No description provided for @netCash.
  ///
  /// In en, this message translates to:
  /// **'Net Cash'**
  String get netCash;

  /// No description provided for @lendingCredit.
  ///
  /// In en, this message translates to:
  /// **'Lending & Credit'**
  String get lendingCredit;

  /// No description provided for @netCredit.
  ///
  /// In en, this message translates to:
  /// **'Net Credit'**
  String get netCredit;

  /// No description provided for @receive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receive;

  /// No description provided for @appTour.
  ///
  /// In en, this message translates to:
  /// **'App Tour'**
  String get appTour;

  /// No description provided for @resetOnboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reset the app tour to see it again'**
  String get resetOnboardingSubtitle;

  /// No description provided for @resetOnboardingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the app tour? You will see the onboarding screens again on next restart.'**
  String get resetOnboardingConfirmation;

  /// No description provided for @onboardingResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'App tour reset successfully'**
  String get onboardingResetSuccess;

  /// No description provided for @tourWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FlowKarobar!'**
  String get tourWelcome;

  /// No description provided for @tourWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Let\'s take a quick tour to help you get started'**
  String get tourWelcomeDesc;

  /// No description provided for @tourDashboardHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Cashbook Selector'**
  String get tourDashboardHeaderTitle;

  /// No description provided for @tourDashboardHeaderDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap here to switch between your cashbooks or create a new one'**
  String get tourDashboardHeaderDesc;

  /// No description provided for @tourBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Cash'**
  String get tourBalanceTitle;

  /// No description provided for @tourBalanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Your total available cash balance is displayed here. This updates automatically as you add transactions'**
  String get tourBalanceDesc;

  /// No description provided for @tourCashFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow'**
  String get tourCashFlowTitle;

  /// No description provided for @tourCashFlowDesc.
  ///
  /// In en, this message translates to:
  /// **'View your income, expenses, and net cash flow. Tap any card to filter transactions'**
  String get tourCashFlowDesc;

  /// No description provided for @tourLendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Lending & Credit'**
  String get tourLendingTitle;

  /// No description provided for @tourLendingDesc.
  ///
  /// In en, this message translates to:
  /// **'Track money people owe you (Receivables) and money you owe (Payables). Tap to view details'**
  String get tourLendingDesc;

  /// No description provided for @tourQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get tourQuickActionsTitle;

  /// No description provided for @tourQuickActionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Quick access to add transactions, scan receipts, manage receivables/payables, view analytics, and more'**
  String get tourQuickActionsDesc;

  /// No description provided for @tourRecentTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get tourRecentTransactionsTitle;

  /// No description provided for @tourRecentTransactionsDesc.
  ///
  /// In en, this message translates to:
  /// **'View your most recent transactions here. Tap any transaction to see full details'**
  String get tourRecentTransactionsDesc;

  /// No description provided for @tourBottomNavTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get tourBottomNavTitle;

  /// No description provided for @tourBottomNavDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch between Dashboard, Transactions, Analytics, and Settings using the bottom navigation'**
  String get tourBottomNavDesc;

  /// No description provided for @tourNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tourNext;

  /// No description provided for @tourSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tourSkip;

  /// No description provided for @tourStartTour.
  ///
  /// In en, this message translates to:
  /// **'Start Tour'**
  String get tourStartTour;

  /// No description provided for @tourCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tour completed'**
  String get tourCompleted;

  /// No description provided for @tourGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get tourGotIt;

  /// No description provided for @tourTransactionsSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Transactions'**
  String get tourTransactionsSearchTitle;

  /// No description provided for @tourTransactionsSearchDesc.
  ///
  /// In en, this message translates to:
  /// **'Quickly find any transaction by description or amount.'**
  String get tourTransactionsSearchDesc;

  /// No description provided for @tourTransactionsFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get tourTransactionsFilterTitle;

  /// No description provided for @tourTransactionsFilterDesc.
  ///
  /// In en, this message translates to:
  /// **'Filter by date range, category, or contact to get specific insights.'**
  String get tourTransactionsFilterDesc;

  /// No description provided for @tourTransactionsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get tourTransactionsListTitle;

  /// No description provided for @tourTransactionsListDesc.
  ///
  /// In en, this message translates to:
  /// **'Your transactions are grouped by date. Swipe left or right on any item to edit or delete it.'**
  String get tourTransactionsListDesc;

  /// No description provided for @tourTransactionsFabTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get tourTransactionsFabTitle;

  /// No description provided for @tourTransactionsFabDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap here to record a new income or expense transaction.'**
  String get tourTransactionsFabDesc;

  /// No description provided for @tourAnalyticsDateRangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Date Range Selector'**
  String get tourAnalyticsDateRangeTitle;

  /// No description provided for @tourAnalyticsDateRangeDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch between monthly, quarterly, yearly, or custom date ranges to analyze your data.'**
  String get tourAnalyticsDateRangeDesc;

  /// No description provided for @tourAnalyticsExportPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Export PDF Report'**
  String get tourAnalyticsExportPdfTitle;

  /// No description provided for @tourAnalyticsExportPdfDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate and share professional PDF reports of your financial analytics.'**
  String get tourAnalyticsExportPdfDesc;

  /// No description provided for @tourAnalyticsFinancialSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get tourAnalyticsFinancialSummaryTitle;

  /// No description provided for @tourAnalyticsFinancialSummaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Get a quick overview of your total payables, receivables, income, and expenses for the selected period.'**
  String get tourAnalyticsFinancialSummaryDesc;

  /// No description provided for @tourAnalyticsChartsTitle.
  ///
  /// In en, this message translates to:
  /// **'Visual Insights'**
  String get tourAnalyticsChartsTitle;

  /// No description provided for @tourAnalyticsChartsDesc.
  ///
  /// In en, this message translates to:
  /// **'Understand your spending habits and trends through interactive charts and category breakdowns.'**
  String get tourAnalyticsChartsDesc;

  /// No description provided for @tourSettingsProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get tourSettingsProfileTitle;

  /// No description provided for @tourSettingsProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your personal information, profile picture, and account details.'**
  String get tourSettingsProfileDesc;

  /// No description provided for @tourSettingsAppPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get tourSettingsAppPreferencesTitle;

  /// No description provided for @tourSettingsAppPreferencesDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize the app experience by changing language, font, and theme (dark/light mode).'**
  String get tourSettingsAppPreferencesDesc;

  /// No description provided for @tourSettingsBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Security'**
  String get tourSettingsBackupTitle;

  /// No description provided for @tourSettingsBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep your data safe by setting up Google Drive backup and restore.'**
  String get tourSettingsBackupDesc;

  /// No description provided for @tourSettingsPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get tourSettingsPremiumTitle;

  /// No description provided for @tourSettingsPremiumDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock advanced analytics, custom message templates, and more with FlowKarobar Premium.'**
  String get tourSettingsPremiumDesc;

  /// No description provided for @tourAddTxAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get tourAddTxAmountTitle;

  /// No description provided for @tourAddTxAmountDesc.
  ///
  /// In en, this message translates to:
  /// **'Type the transaction amount here. Use the calculator if needed.'**
  String get tourAddTxAmountDesc;

  /// No description provided for @tourAddTxCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get tourAddTxCategoryTitle;

  /// No description provided for @tourAddTxCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Categorize your transaction to get better insights in Analytics.'**
  String get tourAddTxCategoryDesc;

  /// No description provided for @tourAddTxContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Link Contact'**
  String get tourAddTxContactTitle;

  /// No description provided for @tourAddTxContactDesc.
  ///
  /// In en, this message translates to:
  /// **'Optional: Link this transaction to a contact for tracking receivables or payables.'**
  String get tourAddTxContactDesc;

  /// No description provided for @tourAddTxDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Date'**
  String get tourAddTxDateTitle;

  /// No description provided for @tourAddTxDateDesc.
  ///
  /// In en, this message translates to:
  /// **'You can record transactions for today or any past/future date.'**
  String get tourAddTxDateDesc;

  /// No description provided for @tourAddTxSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get tourAddTxSaveTitle;

  /// No description provided for @tourAddTxSaveDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap here to save your transaction. You can also share it via WhatsApp immediately.'**
  String get tourAddTxSaveDesc;

  /// No description provided for @tourBackupAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-in'**
  String get tourBackupAuthTitle;

  /// No description provided for @tourBackupAuthDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your Google account to enable cloud backup and sync across devices.'**
  String get tourBackupAuthDesc;

  /// No description provided for @tourBackupSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Synchronization'**
  String get tourBackupSyncTitle;

  /// No description provided for @tourBackupSyncDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep your data in sync automatically. You can see your local and cloud versions here.'**
  String get tourBackupSyncDesc;

  /// No description provided for @tourBackupNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Backup'**
  String get tourBackupNowTitle;

  /// No description provided for @tourBackupNowDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a full backup of your data to Google Drive anytime.'**
  String get tourBackupNowDesc;

  /// No description provided for @tourReceivablesListTitle.
  ///
  /// In en, this message translates to:
  /// **'Receivables List'**
  String get tourReceivablesListTitle;

  /// No description provided for @tourReceivablesListDesc.
  ///
  /// In en, this message translates to:
  /// **'View all money people owe you. Tap to manage.'**
  String get tourReceivablesListDesc;

  /// No description provided for @tourPayablesListTitle.
  ///
  /// In en, this message translates to:
  /// **'Payables List'**
  String get tourPayablesListTitle;

  /// No description provided for @tourPayablesListDesc.
  ///
  /// In en, this message translates to:
  /// **'View all money you owe. Tap to manage.'**
  String get tourPayablesListDesc;

  /// No description provided for @tourShowMeHow.
  ///
  /// In en, this message translates to:
  /// **'Let\'s try'**
  String get tourShowMeHow;

  /// No description provided for @messageTemplatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize message templates is available for Premium users.'**
  String get messageTemplatesDesc;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @receivableReminders.
  ///
  /// In en, this message translates to:
  /// **'Receivable Reminders'**
  String get receivableReminders;

  /// No description provided for @pendingReceivable.
  ///
  /// In en, this message translates to:
  /// **'Pending Receivable'**
  String get pendingReceivable;

  /// No description provided for @receivedPayment.
  ///
  /// In en, this message translates to:
  /// **'Received Payment'**
  String get receivedPayment;

  /// No description provided for @payableReminders.
  ///
  /// In en, this message translates to:
  /// **'Payable Reminders'**
  String get payableReminders;

  /// No description provided for @pendingPayable.
  ///
  /// In en, this message translates to:
  /// **'Pending Payable'**
  String get pendingPayable;

  /// No description provided for @paidPayable.
  ///
  /// In en, this message translates to:
  /// **'Paid Payable'**
  String get paidPayable;

  /// No description provided for @transactionMessages.
  ///
  /// In en, this message translates to:
  /// **'Transaction Messages'**
  String get transactionMessages;

  /// No description provided for @transactionReceipt.
  ///
  /// In en, this message translates to:
  /// **'Transaction Receipt'**
  String get transactionReceipt;

  /// No description provided for @transactionSharePaidFor.
  ///
  /// In en, this message translates to:
  /// **'Transaction Share - Paid For'**
  String get transactionSharePaidFor;

  /// No description provided for @transactionSharePaidBy.
  ///
  /// In en, this message translates to:
  /// **'Transaction Share - Paid By'**
  String get transactionSharePaidBy;

  /// No description provided for @transactionShareWillReceive.
  ///
  /// In en, this message translates to:
  /// **'Transaction Share - Will Receive'**
  String get transactionShareWillReceive;

  /// No description provided for @transactionShareReceivedFrom.
  ///
  /// In en, this message translates to:
  /// **'Transaction Share - Received From'**
  String get transactionShareReceivedFrom;

  /// No description provided for @transactionShareGeneric.
  ///
  /// In en, this message translates to:
  /// **'Transaction Share - Generic'**
  String get transactionShareGeneric;

  /// No description provided for @shareMessages.
  ///
  /// In en, this message translates to:
  /// **'Share Messages'**
  String get shareMessages;

  /// No description provided for @receivableSharePending.
  ///
  /// In en, this message translates to:
  /// **'Receivable Share - Pending'**
  String get receivableSharePending;

  /// No description provided for @receivableShareReceived.
  ///
  /// In en, this message translates to:
  /// **'Receivable Share - Received'**
  String get receivableShareReceived;

  /// No description provided for @payableSharePending.
  ///
  /// In en, this message translates to:
  /// **'Payable Share - Pending'**
  String get payableSharePending;

  /// No description provided for @payableSharePaid.
  ///
  /// In en, this message translates to:
  /// **'Payable Share - Paid'**
  String get payableSharePaid;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get resetToDefault;

  /// No description provided for @resetTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Template'**
  String get resetTemplateTitle;

  /// No description provided for @resetTemplateMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset this template to the default? This cannot be undone.'**
  String get resetTemplateMessage;

  /// No description provided for @templateSaved.
  ///
  /// In en, this message translates to:
  /// **'Template saved successfully'**
  String get templateSaved;

  /// No description provided for @templateReset.
  ///
  /// In en, this message translates to:
  /// **'Template reset to default'**
  String get templateReset;

  /// No description provided for @enterTemplateText.
  ///
  /// In en, this message translates to:
  /// **'Enter template text...'**
  String get enterTemplateText;

  /// No description provided for @useVariableHint.
  ///
  /// In en, this message translates to:
  /// **'Use {variableName} for dynamic content'**
  String useVariableHint(Object variableName);

  /// No description provided for @saveTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save Template'**
  String get saveTemplate;

  /// No description provided for @availableVariables.
  ///
  /// In en, this message translates to:
  /// **'Available Variables'**
  String get availableVariables;

  /// No description provided for @variablesInstructions.
  ///
  /// In en, this message translates to:
  /// **'You can use these variables in your templates:'**
  String get variablesInstructions;

  /// No description provided for @variableContactName.
  ///
  /// In en, this message translates to:
  /// **'• {contactName} - Contact\'s name'**
  String variableContactName(Object contactName);

  /// No description provided for @variableAmount.
  ///
  /// In en, this message translates to:
  /// **'• {amount} - Formatted amount with currency'**
  String variableAmount(Object amount);

  /// No description provided for @variableDescription.
  ///
  /// In en, this message translates to:
  /// **'• {description} - Transaction/receivable/payable description'**
  String variableDescription(Object description);

  /// No description provided for @variableDate.
  ///
  /// In en, this message translates to:
  /// **'• {date} - Formatted date'**
  String variableDate(Object date);

  /// No description provided for @variableDueDate.
  ///
  /// In en, this message translates to:
  /// **'• {dueDate} - Formatted due date'**
  String variableDueDate(Object dueDate);

  /// No description provided for @variableCategoryName.
  ///
  /// In en, this message translates to:
  /// **'• {categoryName} - Category name'**
  String variableCategoryName(Object categoryName);

  /// No description provided for @variableLink.
  ///
  /// In en, this message translates to:
  /// **'• {link} - Deep link URL'**
  String variableLink(Object link);

  /// No description provided for @variableType.
  ///
  /// In en, this message translates to:
  /// **'• {type} - Transaction type (Income/Expense)'**
  String variableType(Object type);

  /// No description provided for @variableStatus.
  ///
  /// In en, this message translates to:
  /// **'• {status} - Status text'**
  String variableStatus(Object status);

  /// No description provided for @variableRelationship.
  ///
  /// In en, this message translates to:
  /// **'• {relationship} - Relationship text'**
  String variableRelationship(Object relationship);

  /// No description provided for @noCurrencies.
  ///
  /// In en, this message translates to:
  /// **'No currencies'**
  String get noCurrencies;

  /// No description provided for @currencyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Currency deleted successfully'**
  String get currencyDeleted;

  /// No description provided for @addCurrency.
  ///
  /// In en, this message translates to:
  /// **'Add Currency'**
  String get addCurrency;

  /// No description provided for @currencyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency Name'**
  String get currencyNameLabel;

  /// No description provided for @currencyNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Euro, British Pound'**
  String get currencyNameHint;

  /// No description provided for @pleaseEnterCurrencyName.
  ///
  /// In en, this message translates to:
  /// **'Please enter currency name'**
  String get pleaseEnterCurrencyName;

  /// No description provided for @currencySymbolLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency Symbol'**
  String get currencySymbolLabel;

  /// No description provided for @currencySymbolHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., €, £, ¥'**
  String get currencySymbolHint;

  /// No description provided for @currencySymbolHelper.
  ///
  /// In en, this message translates to:
  /// **'You can use emoji, letters, or symbols'**
  String get currencySymbolHelper;

  /// No description provided for @pleaseEnterCurrencySymbol.
  ///
  /// In en, this message translates to:
  /// **'Please enter currency symbol'**
  String get pleaseEnterCurrencySymbol;

  /// No description provided for @symbolLengthError.
  ///
  /// In en, this message translates to:
  /// **'Symbol must be 10 characters or less'**
  String get symbolLengthError;

  /// No description provided for @currencyCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency Code'**
  String get currencyCodeLabel;

  /// No description provided for @currencyCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., EUR, GBP, JPY'**
  String get currencyCodeHint;

  /// No description provided for @currencyCodeHelper.
  ///
  /// In en, this message translates to:
  /// **'ISO 4217 code (3 letters)'**
  String get currencyCodeHelper;

  /// No description provided for @pleaseEnterCurrencyCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter currency code'**
  String get pleaseEnterCurrencyCode;

  /// No description provided for @codeLengthError.
  ///
  /// In en, this message translates to:
  /// **'Code must be exactly 3 characters'**
  String get codeLengthError;

  /// No description provided for @decimalPlacesLabel.
  ///
  /// In en, this message translates to:
  /// **'Decimal Places'**
  String get decimalPlacesLabel;

  /// No description provided for @decimalPlacesHelper.
  ///
  /// In en, this message translates to:
  /// **'Number of digits after decimal point'**
  String get decimalPlacesHelper;

  /// No description provided for @scaleFactorLabel.
  ///
  /// In en, this message translates to:
  /// **'Display Unit / Scale Factor'**
  String get scaleFactorLabel;

  /// No description provided for @scaleFactorHelper.
  ///
  /// In en, this message translates to:
  /// **'Divide amounts by this value for cleaner display'**
  String get scaleFactorHelper;

  /// No description provided for @scaleWhole.
  ///
  /// In en, this message translates to:
  /// **'Whole Units (1)'**
  String get scaleWhole;

  /// No description provided for @scaleThousands.
  ///
  /// In en, this message translates to:
  /// **'Thousands (1K)'**
  String get scaleThousands;

  /// No description provided for @scaleLakhs.
  ///
  /// In en, this message translates to:
  /// **'Lakhs (1L)'**
  String get scaleLakhs;

  /// No description provided for @scaleMillions.
  ///
  /// In en, this message translates to:
  /// **'Millions (1M)'**
  String get scaleMillions;

  /// No description provided for @scaleCrores.
  ///
  /// In en, this message translates to:
  /// **'Crores (1Cr)'**
  String get scaleCrores;

  /// No description provided for @scaleBillions.
  ///
  /// In en, this message translates to:
  /// **'Billions (1B)'**
  String get scaleBillions;

  /// No description provided for @noDecimals.
  ///
  /// In en, this message translates to:
  /// **'0 (No decimals)'**
  String get noDecimals;

  /// No description provided for @oneDecimal.
  ///
  /// In en, this message translates to:
  /// **'1 decimal place'**
  String get oneDecimal;

  /// No description provided for @twoDecimals.
  ///
  /// In en, this message translates to:
  /// **'2 decimal places'**
  String get twoDecimals;

  /// No description provided for @saveCurrency.
  ///
  /// In en, this message translates to:
  /// **'Save Currency'**
  String get saveCurrency;

  /// No description provided for @currencyAdded.
  ///
  /// In en, this message translates to:
  /// **'Currency added successfully'**
  String get currencyAdded;

  /// No description provided for @editCurrency.
  ///
  /// In en, this message translates to:
  /// **'Edit Currency'**
  String get editCurrency;

  /// No description provided for @updateCurrency.
  ///
  /// In en, this message translates to:
  /// **'Update Currency'**
  String get updateCurrency;

  /// No description provided for @currencyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Currency updated successfully'**
  String get currencyUpdated;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select date range'**
  String get selectDateRange;

  /// No description provided for @exportSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Export Successful'**
  String get exportSuccessful;

  /// No description provided for @openFile.
  ///
  /// In en, this message translates to:
  /// **'Open File'**
  String get openFile;

  /// No description provided for @transactionHistoryReady.
  ///
  /// In en, this message translates to:
  /// **'Your transaction history is ready to share.'**
  String get transactionHistoryReady;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @pdfReportReady.
  ///
  /// In en, this message translates to:
  /// **'Your PDF report is ready. Choose an action:'**
  String get pdfReportReady;

  /// No description provided for @testPdfReady.
  ///
  /// In en, this message translates to:
  /// **'Test PDF Ready'**
  String get testPdfReady;

  /// No description provided for @testPdfCategoriesReady.
  ///
  /// In en, this message translates to:
  /// **'Test PDF with all categories is ready. Choose an action:'**
  String get testPdfCategoriesReady;

  /// No description provided for @exportYourData.
  ///
  /// In en, this message translates to:
  /// **'Export Your Data'**
  String get exportYourData;

  /// No description provided for @downloadHistoryCsvPdf.
  ///
  /// In en, this message translates to:
  /// **'Download your transaction history as CSV or PDF'**
  String get downloadHistoryCsvPdf;

  /// No description provided for @simpleExtractionResults.
  ///
  /// In en, this message translates to:
  /// **'Simple Extraction Results'**
  String get simpleExtractionResults;

  /// No description provided for @smartExtractionQuotaLeft.
  ///
  /// In en, this message translates to:
  /// **'{remaining} of {total} left this month'**
  String smartExtractionQuotaLeft(Object remaining, Object total);

  /// No description provided for @smartExtractionUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get smartExtractionUnlimited;

  /// No description provided for @useSmartExtractionForBetterResults.
  ///
  /// In en, this message translates to:
  /// **'For better results use Smart extraction.'**
  String get useSmartExtractionForBetterResults;

  /// No description provided for @getIt.
  ///
  /// In en, this message translates to:
  /// **'Get it'**
  String get getIt;

  /// No description provided for @amountCalculatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate amount'**
  String get amountCalculatorTitle;

  /// No description provided for @amountCalculatorUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get amountCalculatorUndo;

  /// No description provided for @amountCalculatorMultiply.
  ///
  /// In en, this message translates to:
  /// **'Multiply'**
  String get amountCalculatorMultiply;

  /// No description provided for @amountCalculatorDivide.
  ///
  /// In en, this message translates to:
  /// **'Divide'**
  String get amountCalculatorDivide;

  /// No description provided for @amountCalculatorPercent.
  ///
  /// In en, this message translates to:
  /// **'Percent (%)'**
  String get amountCalculatorPercent;

  /// No description provided for @amountCalculatorButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open calculator'**
  String get amountCalculatorButtonTooltip;

  /// No description provided for @amountCalculatorOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get amountCalculatorOriginal;

  /// No description provided for @amountCalculatorResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get amountCalculatorResult;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @exportSummary.
  ///
  /// In en, this message translates to:
  /// **'Export Summary'**
  String get exportSummary;

  /// No description provided for @totalTransactions.
  ///
  /// In en, this message translates to:
  /// **'Total Transactions'**
  String get totalTransactions;

  /// No description provided for @includePayablesReceivables.
  ///
  /// In en, this message translates to:
  /// **'Include Payables & Receivables'**
  String get includePayablesReceivables;

  /// No description provided for @includePayablesReceivablesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Include outstanding balances and lists in the report'**
  String get includePayablesReceivablesSubtitle;

  /// No description provided for @exportAsCSV.
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get exportAsCSV;

  /// No description provided for @exportAsCSVSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free • Open in Excel or Google Sheets'**
  String get exportAsCSVSubtitle;

  /// No description provided for @exportAsPDF.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get exportAsPDF;

  /// No description provided for @exportAsPDFSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Premium • Beautiful report with summaries'**
  String get exportAsPDFSubtitle;

  /// No description provided for @csvInfoNote.
  ///
  /// In en, this message translates to:
  /// **'CSV files can be opened in Excel or Google Sheets. PDF reports are great for sharing.'**
  String get csvInfoNote;

  /// No description provided for @testCategoriesPdf.
  ///
  /// In en, this message translates to:
  /// **'Test Categories PDF (Icons)'**
  String get testCategoriesPdf;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @autoGenerated.
  ///
  /// In en, this message translates to:
  /// **'Auto-Generated'**
  String get autoGenerated;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @linkedEntry.
  ///
  /// In en, this message translates to:
  /// **'Linked Entry'**
  String get linkedEntry;

  /// No description provided for @paidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid on: {date}'**
  String paidOn(String date);

  /// No description provided for @receivedOn.
  ///
  /// In en, this message translates to:
  /// **'Received on: {date}'**
  String receivedOn(String date);

  /// No description provided for @deleteTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransactionTitle;

  /// No description provided for @deleteTransactionMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction? This action cannot be undone.'**
  String get deleteTransactionMessage;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionDeleted;

  /// No description provided for @errorLoadingCurrency.
  ///
  /// In en, this message translates to:
  /// **'Error loading currency'**
  String get errorLoadingCurrency;

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceLabel;

  /// No description provided for @periodNet.
  ///
  /// In en, this message translates to:
  /// **'Period Net'**
  String get periodNet;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// No description provided for @importTransaction.
  ///
  /// In en, this message translates to:
  /// **'Import Transaction'**
  String get importTransaction;

  /// No description provided for @importReceivable.
  ///
  /// In en, this message translates to:
  /// **'Import Receivable'**
  String get importReceivable;

  /// No description provided for @importPayable.
  ///
  /// In en, this message translates to:
  /// **'Import Payable'**
  String get importPayable;

  /// No description provided for @sharedBy.
  ///
  /// In en, this message translates to:
  /// **'Shared by: {name}'**
  String sharedBy(String name);

  /// No description provided for @sender.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get sender;

  /// No description provided for @someone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get someone;

  /// No description provided for @markedAsStatus.
  ///
  /// In en, this message translates to:
  /// **'{name} has marked this as {status}. Update your local record?'**
  String markedAsStatus(String name, String status);

  /// No description provided for @itemAlreadyImported.
  ///
  /// In en, this message translates to:
  /// **'This item has already been imported.'**
  String get itemAlreadyImported;

  /// No description provided for @importDetails.
  ///
  /// In en, this message translates to:
  /// **'Import Details'**
  String get importDetails;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @importClassificationReceivableQuestion.
  ///
  /// In en, this message translates to:
  /// **'How would you like to record this receivable?'**
  String get importClassificationReceivableQuestion;

  /// No description provided for @importClassificationReceivableOptionPaidFor.
  ///
  /// In en, this message translates to:
  /// **'I covered this expense — {contact} will reimburse me.'**
  String importClassificationReceivableOptionPaidFor(String contact);

  /// No description provided for @importClassificationReceivableOptionWillReceive.
  ///
  /// In en, this message translates to:
  /// **'This is for my services, a gift I am owed, or another income.'**
  String get importClassificationReceivableOptionWillReceive;

  /// No description provided for @importClassificationPayableQuestion.
  ///
  /// In en, this message translates to:
  /// **'How would you like to record this payable?'**
  String get importClassificationPayableQuestion;

  /// No description provided for @importClassificationPayableOptionPaidBy.
  ///
  /// In en, this message translates to:
  /// **'{contact} covered this expense on my behalf.'**
  String importClassificationPayableOptionPaidBy(String contact);

  /// No description provided for @importClassificationPayableOptionReceivedFrom.
  ///
  /// In en, this message translates to:
  /// **'I received this as a loan, advance, or borrowed amount.'**
  String get importClassificationPayableOptionReceivedFrom;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @limitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit Reached'**
  String get limitReached;

  /// No description provided for @proLabel.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get proLabel;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// No description provided for @confirmDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get confirmDeleteItem;

  /// No description provided for @sharePayableCompleted.
  ///
  /// In en, this message translates to:
  /// **'Greetings!\n\nThe payment of {amount} on {date} has been completed.\n\nSync in FlowKarobar:\n{link}'**
  String sharePayableCompleted(String amount, String date, String link);

  /// No description provided for @sharePayablePending.
  ///
  /// In en, this message translates to:
  /// **'I owe you {amount}\nDate: {date}\n\nView in FlowKarobar:\n{link}'**
  String sharePayablePending(String amount, String date, String link);

  /// No description provided for @shareReceivableReceived.
  ///
  /// In en, this message translates to:
  /// **'Greetings!\n\nThe payment of {amount} on {date} has been received.\n\nSync in FlowKarobar:\n{link}'**
  String shareReceivableReceived(String amount, String date, String link);

  /// No description provided for @shareReceivablePending.
  ///
  /// In en, this message translates to:
  /// **'Amount to receive: {amount}\nDate: {date}\n\nView in FlowKarobar:\n{link}'**
  String shareReceivablePending(String amount, String date, String link);

  /// No description provided for @shareTransactionMessage.
  ///
  /// In en, this message translates to:
  /// **'Recorded a transaction of {amount} on {date}.\n\nView in FlowKarobar:\n{link}'**
  String shareTransactionMessage(String amount, String date, String link);

  /// No description provided for @shareViaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Share via WhatsApp'**
  String get shareViaWhatsApp;

  /// No description provided for @toContact.
  ///
  /// In en, this message translates to:
  /// **'To {name}'**
  String toContact(String name);

  /// No description provided for @chooseContact.
  ///
  /// In en, this message translates to:
  /// **'Choose contact'**
  String get chooseContact;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @copyDeepLinkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Copy deep link to clipboard'**
  String get copyDeepLinkSubtitle;

  /// No description provided for @tapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak'**
  String get tapToSpeak;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @whatWeHeard.
  ///
  /// In en, this message translates to:
  /// **'What we heard:'**
  String get whatWeHeard;

  /// No description provided for @reParse.
  ///
  /// In en, this message translates to:
  /// **'Re-parse'**
  String get reParse;

  /// No description provided for @smartExtraction.
  ///
  /// In en, this message translates to:
  /// **'Smart extraction'**
  String get smartExtraction;

  /// No description provided for @basicExtraction.
  ///
  /// In en, this message translates to:
  /// **'Basic extraction'**
  String get basicExtraction;

  /// No description provided for @addNow.
  ///
  /// In en, this message translates to:
  /// **'Add now'**
  String get addNow;

  /// No description provided for @editAndAdd.
  ///
  /// In en, this message translates to:
  /// **'Edit and add'**
  String get editAndAdd;

  /// No description provided for @downloadNow.
  ///
  /// In en, this message translates to:
  /// **'Download Now'**
  String get downloadNow;

  /// No description provided for @smartAiDownloadMessage.
  ///
  /// In en, this message translates to:
  /// **'Smart features require a one-time download (~100MB). Would you like to download now for better accuracy?'**
  String get smartAiDownloadMessage;

  /// No description provided for @smartParsingLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Monthly smart parsing limit reached. Using basic extraction.'**
  String get smartParsingLimitReached;

  /// No description provided for @voiceTips.
  ///
  /// In en, this message translates to:
  /// **'Try saying: \'Spent 500 on dinner\' or \'I gave 100 to Usman for lunch\''**
  String get voiceTips;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @hints.
  ///
  /// In en, this message translates to:
  /// **'Hints'**
  String get hints;

  /// No description provided for @voiceGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Phrasing Guide'**
  String get voiceGuideTitle;

  /// No description provided for @voiceInstructionBasic.
  ///
  /// In en, this message translates to:
  /// **'You\'re using simple extraction mode. Tap here to see hint messages.'**
  String get voiceInstructionBasic;

  /// No description provided for @voiceInstructionSmart.
  ///
  /// In en, this message translates to:
  /// **'You\'re using Smart extraction. Tap here for more tips.'**
  String get voiceInstructionSmart;

  /// No description provided for @windowsDictationTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: On Windows, you can click the text box below and press Win + H to use Windows\' highly accurate built-in Dictation tool!'**
  String get windowsDictationTip;

  /// No description provided for @includeTextAsDescription.
  ///
  /// In en, this message translates to:
  /// **'Include text as description'**
  String get includeTextAsDescription;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @scanningReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scanning receipt...'**
  String get scanningReceipt;

  /// No description provided for @noReceiptSelected.
  ///
  /// In en, this message translates to:
  /// **'No receipt selected'**
  String get noReceiptSelected;

  /// No description provided for @reviewAndEdit.
  ///
  /// In en, this message translates to:
  /// **'Review & Edit'**
  String get reviewAndEdit;

  /// No description provided for @merchantName.
  ///
  /// In en, this message translates to:
  /// **'Merchant Name'**
  String get merchantName;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @proceedToAddTransaction.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Add Transaction'**
  String get proceedToAddTransaction;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String errorPickingImage(String error);

  /// No description provided for @errorScanningReceipt.
  ///
  /// In en, this message translates to:
  /// **'Error scanning receipt: {error}'**
  String errorScanningReceipt(String error);

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// No description provided for @allContactsAddedToSplit.
  ///
  /// In en, this message translates to:
  /// **'All contacts are already in the split'**
  String get allContactsAddedToSplit;

  /// No description provided for @paidRelationship.
  ///
  /// In en, this message translates to:
  /// **'Paid Relationship'**
  String get paidRelationship;

  /// No description provided for @paidFor.
  ///
  /// In en, this message translates to:
  /// **'Paid FOR'**
  String get paidFor;

  /// No description provided for @paidBy.
  ///
  /// In en, this message translates to:
  /// **'Paid BY'**
  String get paidBy;

  /// No description provided for @iWillReceiveBack.
  ///
  /// In en, this message translates to:
  /// **'I will receive back'**
  String get iWillReceiveBack;

  /// No description provided for @someonePaidForMe.
  ///
  /// In en, this message translates to:
  /// **'Someone paid for me'**
  String get someonePaidForMe;

  /// No description provided for @receivedRelationship.
  ///
  /// In en, this message translates to:
  /// **'Received Relationship'**
  String get receivedRelationship;

  /// No description provided for @iOwe.
  ///
  /// In en, this message translates to:
  /// **'I Owe'**
  String get iOwe;

  /// No description provided for @receivedLoan.
  ///
  /// In en, this message translates to:
  /// **'Received loan'**
  String get receivedLoan;

  /// No description provided for @receiveLater.
  ///
  /// In en, this message translates to:
  /// **'Receive later'**
  String get receiveLater;

  /// No description provided for @schedulePattern.
  ///
  /// In en, this message translates to:
  /// **'Schedule Pattern'**
  String get schedulePattern;

  /// No description provided for @startDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Start Date (Optional)'**
  String get startDateOptional;

  /// No description provided for @endDateOptional.
  ///
  /// In en, this message translates to:
  /// **'End Date (Optional)'**
  String get endDateOptional;

  /// No description provided for @scheduleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Schedule updated successfully'**
  String get scheduleUpdated;

  /// No description provided for @updateSchedule.
  ///
  /// In en, this message translates to:
  /// **'Update Schedule'**
  String get updateSchedule;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @contactOptional.
  ///
  /// In en, this message translates to:
  /// **'Contact (Optional)'**
  String get contactOptional;

  /// No description provided for @pleaseSelectContactRelationship.
  ///
  /// In en, this message translates to:
  /// **'Please select a contact for this relationship'**
  String get pleaseSelectContactRelationship;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @weeklyWithDays.
  ///
  /// In en, this message translates to:
  /// **'Weekly: {days}'**
  String weeklyWithDays(String days);

  /// No description provided for @monthlyWithDay.
  ///
  /// In en, this message translates to:
  /// **'Monthly: {day}'**
  String monthlyWithDay(String day);

  /// No description provided for @schedules.
  ///
  /// In en, this message translates to:
  /// **'Schedules'**
  String get schedules;

  /// No description provided for @generate100DummyTransactions.
  ///
  /// In en, this message translates to:
  /// **'Generate 100 Dummy Transactions'**
  String get generate100DummyTransactions;

  /// No description provided for @generated100DummyTransactions.
  ///
  /// In en, this message translates to:
  /// **'Generated 100 dummy transactions'**
  String get generated100DummyTransactions;

  /// No description provided for @errorLoadingTransactions.
  ///
  /// In en, this message translates to:
  /// **'Error loading transactions'**
  String get errorLoadingTransactions;

  /// No description provided for @noSchedulesFound.
  ///
  /// In en, this message translates to:
  /// **'No schedules found'**
  String get noSchedulesFound;

  /// No description provided for @noMoreTransactions.
  ///
  /// In en, this message translates to:
  /// **'No more transactions'**
  String get noMoreTransactions;

  /// No description provided for @scheduleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Schedule deleted successfully'**
  String get scheduleDeleted;

  /// No description provided for @autoBadge.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get autoBadge;

  /// No description provided for @remainingNetBalance.
  ///
  /// In en, this message translates to:
  /// **'Remaining net balance'**
  String get remainingNetBalance;

  /// No description provided for @settleAll.
  ///
  /// In en, this message translates to:
  /// **'Settle all'**
  String get settleAll;

  /// No description provided for @bulkReceiveInBulk.
  ///
  /// In en, this message translates to:
  /// **'Receive in bulk'**
  String get bulkReceiveInBulk;

  /// No description provided for @bulkPayInBulk.
  ///
  /// In en, this message translates to:
  /// **'Pay in bulk'**
  String get bulkPayInBulk;

  /// No description provided for @bulkProcessInBulk.
  ///
  /// In en, this message translates to:
  /// **'Process in bulk'**
  String get bulkProcessInBulk;

  /// No description provided for @cannotRestoreActiveCashbook.
  ///
  /// In en, this message translates to:
  /// **'You cannot restore data into the active cashbook. Please switch to another cashbook first to release the file lock.'**
  String get cannotRestoreActiveCashbook;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @categoriesSummaryIncludeInTotal.
  ///
  /// In en, this message translates to:
  /// **'Include in total'**
  String get categoriesSummaryIncludeInTotal;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @deleteContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Contact'**
  String get deleteContactTitle;

  /// No description provided for @deleteContactConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this contact? This will delete all associated transaction history.'**
  String get deleteContactConfirmation;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @limitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Limit Reached'**
  String get limitReachedTitle;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @splittedTransactions.
  ///
  /// In en, this message translates to:
  /// **'Splitted Transactions'**
  String get splittedTransactions;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @noTransactionsInRange.
  ///
  /// In en, this message translates to:
  /// **'No transactions in this date range.'**
  String get noTransactionsInRange;

  /// No description provided for @noPayablesInRange.
  ///
  /// In en, this message translates to:
  /// **'No payables in this date range.'**
  String get noPayablesInRange;

  /// No description provided for @noReceivablesInRange.
  ///
  /// In en, this message translates to:
  /// **'No receivables in this date range.'**
  String get noReceivablesInRange;

  /// No description provided for @topCategoriesVisual.
  ///
  /// In en, this message translates to:
  /// **'Top Categories (Visual)'**
  String get topCategoriesVisual;

  /// No description provided for @incomeVsExpenseTrendVisual.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expense Trend (Visual)'**
  String get incomeVsExpenseTrendVisual;

  /// No description provided for @payableVsReceivableTrendVisual.
  ///
  /// In en, this message translates to:
  /// **'Payable vs Receivable Trend (Visual)'**
  String get payableVsReceivableTrendVisual;

  /// No description provided for @incomeShort.
  ///
  /// In en, this message translates to:
  /// **'I:'**
  String get incomeShort;

  /// No description provided for @shareTransaction.
  ///
  /// In en, this message translates to:
  /// **'Share Transaction'**
  String get shareTransaction;

  /// No description provided for @sharePaymentRequest.
  ///
  /// In en, this message translates to:
  /// **'Share Payment Request'**
  String get sharePaymentRequest;

  /// No description provided for @sharePaymentAcknowledgment.
  ///
  /// In en, this message translates to:
  /// **'Share Payment Acknowledgment'**
  String get sharePaymentAcknowledgment;

  /// No description provided for @openingWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Opening WhatsApp...'**
  String get openingWhatsApp;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard!'**
  String get linkCopied;

  /// No description provided for @addToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Add to dashboard'**
  String get addToDashboard;

  /// No description provided for @addedToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Added to dashboard'**
  String get addedToDashboard;

  /// No description provided for @removeFromDashboard.
  ///
  /// In en, this message translates to:
  /// **'Remove from dashboard'**
  String get removeFromDashboard;

  /// No description provided for @pinToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Pin to dashboard'**
  String get pinToDashboard;

  /// No description provided for @unpinFromDashboard.
  ///
  /// In en, this message translates to:
  /// **'Unpin from dashboard'**
  String get unpinFromDashboard;

  /// No description provided for @pinnedToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Pinned to dashboard'**
  String get pinnedToDashboard;

  /// No description provided for @unpinnedFromDashboard.
  ///
  /// In en, this message translates to:
  /// **'Unpinned from dashboard'**
  String get unpinnedFromDashboard;

  /// No description provided for @reorderWidgetsOn.
  ///
  /// In en, this message translates to:
  /// **'Reorder widgets'**
  String get reorderWidgetsOn;

  /// No description provided for @reorderWidgetsOff.
  ///
  /// In en, this message translates to:
  /// **'Done reordering'**
  String get reorderWidgetsOff;

  /// No description provided for @failedToShare.
  ///
  /// In en, this message translates to:
  /// **'Failed to share: {error}'**
  String failedToShare(String error);

  /// No description provided for @failedToCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Failed to copy link: {error}'**
  String failedToCopyLink(String error);

  /// No description provided for @expenseShort.
  ///
  /// In en, this message translates to:
  /// **'E:'**
  String get expenseShort;

  /// No description provided for @suggestedLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggested: {name}'**
  String suggestedLabel(String name);

  /// No description provided for @deleteCashbookTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Cashbook'**
  String get deleteCashbookTitle;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanently;

  /// No description provided for @pleaseEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterValidAmount;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get categoryGift;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get statusReceived;

  /// No description provided for @statusSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get statusSettled;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @statusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get statusSent;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @payableTag.
  ///
  /// In en, this message translates to:
  /// **'Payable'**
  String get payableTag;

  /// No description provided for @receivableTag.
  ///
  /// In en, this message translates to:
  /// **'Receivable'**
  String get receivableTag;

  /// No description provided for @receivedTag.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get receivedTag;

  /// No description provided for @paidTag.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidTag;

  /// No description provided for @filterTransactionProcessed.
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get filterTransactionProcessed;

  /// No description provided for @filterTransactionNotProcessed.
  ///
  /// In en, this message translates to:
  /// **'Not processed'**
  String get filterTransactionNotProcessed;

  /// No description provided for @currencyUSD.
  ///
  /// In en, this message translates to:
  /// **'US Dollar (\$)'**
  String get currencyUSD;

  /// No description provided for @currencyINR.
  ///
  /// In en, this message translates to:
  /// **'Indian Rupee (₹)'**
  String get currencyINR;

  /// No description provided for @currencyPKR.
  ///
  /// In en, this message translates to:
  /// **'Pakistani Rupee (Rs)'**
  String get currencyPKR;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @sundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sundayShort;

  /// No description provided for @mondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fridayShort;

  /// No description provided for @saturdayShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturdayShort;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @willReceive.
  ///
  /// In en, this message translates to:
  /// **'Will Receive'**
  String get willReceive;

  /// No description provided for @selectSchedulePattern.
  ///
  /// In en, this message translates to:
  /// **'Select Schedule Pattern'**
  String get selectSchedulePattern;

  /// No description provided for @daysOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Days of Week'**
  String get daysOfWeek;

  /// No description provided for @daysOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Days of Month'**
  String get daysOfMonth;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @updateReceivable.
  ///
  /// In en, this message translates to:
  /// **'Update Receivable'**
  String get updateReceivable;

  /// No description provided for @newCashbook.
  ///
  /// In en, this message translates to:
  /// **'New Cashbook'**
  String get newCashbook;

  /// No description provided for @freeLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Free Limit Reached'**
  String get freeLimitReached;

  /// No description provided for @cashbookNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Personal, Business'**
  String get cashbookNameHint;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @updateCashbook.
  ///
  /// In en, this message translates to:
  /// **'Update Cashbook'**
  String get updateCashbook;

  /// No description provided for @noOtherCashbooks.
  ///
  /// In en, this message translates to:
  /// **'No other cashbooks available to copy from.'**
  String get noOtherCashbooks;

  /// No description provided for @selectSourceCashbook.
  ///
  /// In en, this message translates to:
  /// **'Select Source Cashbook'**
  String get selectSourceCashbook;

  /// No description provided for @toTarget.
  ///
  /// In en, this message translates to:
  /// **'To: {name}'**
  String toTarget(String name);

  /// No description provided for @whatToCopy.
  ///
  /// In en, this message translates to:
  /// **'What to Copy?'**
  String get whatToCopy;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @userProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Name, Email, and basic info'**
  String get userProfileDescription;

  /// No description provided for @preferencesDescription.
  ///
  /// In en, this message translates to:
  /// **'Currency and Date Format settings'**
  String get preferencesDescription;

  /// No description provided for @copyDateFormatAndFonts.
  ///
  /// In en, this message translates to:
  /// **'Date format & fonts'**
  String get copyDateFormatAndFonts;

  /// No description provided for @copyDateFormatAndFontsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App language, fonts per language, date format, and selected currency for amounts'**
  String get copyDateFormatAndFontsSubtitle;

  /// No description provided for @copyCurrenciesOption.
  ///
  /// In en, this message translates to:
  /// **'Currencies'**
  String get copyCurrenciesOption;

  /// No description provided for @copyCurrenciesOptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Currency definitions from the source cashbook (names, symbols, codes)'**
  String get copyCurrenciesOptionSubtitle;

  /// No description provided for @messageTemplatesDescription.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp message templates'**
  String get messageTemplatesDescription;

  /// No description provided for @copyContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get copyContacts;

  /// No description provided for @copyContactsDescription.
  ///
  /// In en, this message translates to:
  /// **'Contact names, phone numbers, and emails'**
  String get copyContactsDescription;

  /// No description provided for @copyCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get copyCategories;

  /// No description provided for @copyCategoriesDescription.
  ///
  /// In en, this message translates to:
  /// **'Expense and income categories with icons and colors'**
  String get copyCategoriesDescription;

  /// No description provided for @copyDashboardWidgets.
  ///
  /// In en, this message translates to:
  /// **'Dashboard widgets'**
  String get copyDashboardWidgets;

  /// No description provided for @copyDashboardWidgetsDescription.
  ///
  /// In en, this message translates to:
  /// **'Widget layout, privacy and financial summary toggles, bottom quick action, and dashboard visibility'**
  String get copyDashboardWidgetsDescription;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @pleaseSelectSource.
  ///
  /// In en, this message translates to:
  /// **'Please select a source cashbook'**
  String get pleaseSelectSource;

  /// No description provided for @pleaseSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one item to copy'**
  String get pleaseSelectAtLeastOne;

  /// No description provided for @preferencesCopied.
  ///
  /// In en, this message translates to:
  /// **'Preferences copied successfully'**
  String get preferencesCopied;

  /// No description provided for @errorCopyingPreferences.
  ///
  /// In en, this message translates to:
  /// **'Error copying preferences: {error}'**
  String errorCopyingPreferences(String error);

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @template.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get template;

  /// No description provided for @variables.
  ///
  /// In en, this message translates to:
  /// **'Variables'**
  String get variables;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @currencies.
  ///
  /// In en, this message translates to:
  /// **'Currencies'**
  String get currencies;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @takeBackup.
  ///
  /// In en, this message translates to:
  /// **'Take Backup'**
  String get takeBackup;

  /// No description provided for @restoreOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Options'**
  String get restoreOptionsTitle;

  /// No description provided for @restoreFromCloud.
  ///
  /// In en, this message translates to:
  /// **'Restore from Cloud'**
  String get restoreFromCloud;

  /// No description provided for @restoreFromCloudSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from Google Drive'**
  String get restoreFromCloudSubtitle;

  /// No description provided for @restoreFromFileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from a local file'**
  String get restoreFromFileSubtitle;

  /// No description provided for @backgroundRestoreStarted.
  ///
  /// In en, this message translates to:
  /// **'Restore started in background'**
  String get backgroundRestoreStarted;

  /// No description provided for @restoreSuccessfulFor.
  ///
  /// In en, this message translates to:
  /// **'Restore successful for {name}'**
  String restoreSuccessfulFor(String name);

  /// No description provided for @selectCloudFolder.
  ///
  /// In en, this message translates to:
  /// **'Select Cloud Folder'**
  String get selectCloudFolder;

  /// No description provided for @selectCloudFolderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a cashbook folder to see its backups'**
  String get selectCloudFolderSubtitle;

  /// No description provided for @noCloudFoldersFound.
  ///
  /// In en, this message translates to:
  /// **'No cloud folders found'**
  String get noCloudFoldersFound;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @transactionAlreadyImported.
  ///
  /// In en, this message translates to:
  /// **'Transaction already imported'**
  String get transactionAlreadyImported;

  /// No description provided for @pleaseSelectContactLinked.
  ///
  /// In en, this message translates to:
  /// **'Please select a contact for linked transaction'**
  String get pleaseSelectContactLinked;

  /// No description provided for @transactionLinkedAdded.
  ///
  /// In en, this message translates to:
  /// **'Transaction linked and added successfully'**
  String get transactionLinkedAdded;

  /// No description provided for @transactionAdded.
  ///
  /// In en, this message translates to:
  /// **'Transaction added successfully'**
  String get transactionAdded;

  /// No description provided for @createCategoryNamed.
  ///
  /// In en, this message translates to:
  /// **'Create category {name}'**
  String createCategoryNamed(String name);

  /// No description provided for @tapToAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Tap to add this category'**
  String get tapToAddCategory;

  /// No description provided for @frequent.
  ///
  /// In en, this message translates to:
  /// **'Frequent'**
  String get frequent;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @transactionDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted successfully'**
  String get transactionDeletedSuccessfully;

  /// No description provided for @googleDrive.
  ///
  /// In en, this message translates to:
  /// **'Google Drive'**
  String get googleDrive;

  /// No description provided for @activeCashbook.
  ///
  /// In en, this message translates to:
  /// **'Active Cashbook'**
  String get activeCashbook;

  /// No description provided for @syncAndBackupApplyTo.
  ///
  /// In en, this message translates to:
  /// **'All sync and backup actions below apply to this cashbook only.'**
  String get syncAndBackupApplyTo;

  /// No description provided for @synchronization.
  ///
  /// In en, this message translates to:
  /// **'Synchronization'**
  String get synchronization;

  /// No description provided for @syncActive.
  ///
  /// In en, this message translates to:
  /// **'Sync active'**
  String get syncActive;

  /// No description provided for @syncDescription.
  ///
  /// In en, this message translates to:
  /// **'Synchronization keeps your data updated across all your devices by merging small changes. It is fast and runs automatically.'**
  String get syncDescription;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @syncTriggered.
  ///
  /// In en, this message translates to:
  /// **'Sync triggered in background'**
  String get syncTriggered;

  /// No description provided for @autoSync.
  ///
  /// In en, this message translates to:
  /// **'Auto Sync'**
  String get autoSync;

  /// No description provided for @syncInterval.
  ///
  /// In en, this message translates to:
  /// **'Sync Interval (Hours)'**
  String get syncInterval;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @localVersion.
  ///
  /// In en, this message translates to:
  /// **'Local Version: {version}'**
  String localVersion(int version);

  /// No description provided for @cloudVersion.
  ///
  /// In en, this message translates to:
  /// **'Cloud Version: {version}'**
  String cloudVersion(int version);

  /// No description provided for @lastSync.
  ///
  /// In en, this message translates to:
  /// **'Last Sync: {time}'**
  String lastSync(String time);

  /// No description provided for @autoBackup.
  ///
  /// In en, this message translates to:
  /// **'Auto Backup'**
  String get autoBackup;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @backupDescription.
  ///
  /// In en, this message translates to:
  /// **'A full backup creates a complete snapshot of your database. Use this for historical records or to recover from major issues.'**
  String get backupDescription;

  /// No description provided for @syncRecovery.
  ///
  /// In en, this message translates to:
  /// **'Sync Recovery'**
  String get syncRecovery;

  /// No description provided for @syncRecoveryDescription.
  ///
  /// In en, this message translates to:
  /// **'If you restored this backup to fix a sync error, you should reset the cloud sync to this version. This makes this restored data the \"source of truth\".'**
  String get syncRecoveryDescription;

  /// No description provided for @resetCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Reset Cloud Sync'**
  String get resetCloudSync;

  /// No description provided for @syncManifestReset.
  ///
  /// In en, this message translates to:
  /// **'Sync manifest reset successfully'**
  String get syncManifestReset;

  /// No description provided for @failedToResetSync.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset sync: {error}'**
  String failedToResetSync(String error);

  /// No description provided for @backupOptions.
  ///
  /// In en, this message translates to:
  /// **'Backup Options'**
  String get backupOptions;

  /// No description provided for @backupToCloud.
  ///
  /// In en, this message translates to:
  /// **'Backup to Cloud'**
  String get backupToCloud;

  /// No description provided for @backupToCloudSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Securely store your database on Google Drive'**
  String get backupToCloudSubtitle;

  /// No description provided for @backupToFile.
  ///
  /// In en, this message translates to:
  /// **'Backup to File'**
  String get backupToFile;

  /// No description provided for @backupToFileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save database file to your device or share it'**
  String get backupToFileSubtitle;

  /// No description provided for @backupOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Backup Method'**
  String get backupOptionsTitle;

  /// No description provided for @restoreFromFile.
  ///
  /// In en, this message translates to:
  /// **'Restore from File'**
  String get restoreFromFile;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clearData;

  /// No description provided for @orphan.
  ///
  /// In en, this message translates to:
  /// **'Orphan'**
  String get orphan;

  /// No description provided for @orphanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlinked or missing transaction'**
  String get orphanSubtitle;

  /// No description provided for @clearOrphans.
  ///
  /// In en, this message translates to:
  /// **'Clear Orphan Files'**
  String get clearOrphans;

  /// No description provided for @clearOrphansConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all physical files that are not linked to any active transactions. This action cannot be undone.'**
  String get clearOrphansConfirm;

  /// No description provided for @orphansCleared.
  ///
  /// In en, this message translates to:
  /// **'Orphan files cleared successfully'**
  String get orphansCleared;

  /// No description provided for @linkOrphan.
  ///
  /// In en, this message translates to:
  /// **'Link Existing Attachment'**
  String get linkOrphan;

  /// No description provided for @linkOrphanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose from unlinked or orphan documents'**
  String get linkOrphanSubtitle;

  /// No description provided for @selectOrphans.
  ///
  /// In en, this message translates to:
  /// **'Select Orphan Documents'**
  String get selectOrphans;

  /// No description provided for @linkSelected.
  ///
  /// In en, this message translates to:
  /// **'Link Selected'**
  String get linkSelected;

  /// No description provided for @renameFile.
  ///
  /// In en, this message translates to:
  /// **'Rename File'**
  String get renameFile;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// No description provided for @enterFileName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a file name'**
  String get enterFileName;

  /// No description provided for @addCashbook.
  ///
  /// In en, this message translates to:
  /// **'Add Cashbook'**
  String get addCashbook;

  /// No description provided for @cashbookCreated.
  ///
  /// In en, this message translates to:
  /// **'Cashbook created successfully'**
  String get cashbookCreated;

  /// No description provided for @fontSelection.
  ///
  /// In en, this message translates to:
  /// **'Font Selection'**
  String get fontSelection;

  /// No description provided for @fontChanged.
  ///
  /// In en, this message translates to:
  /// **'Font changed to {fontName}'**
  String fontChanged(String fontName);

  /// No description provided for @restoreToNewCashbookTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore to New Cashbook?'**
  String get restoreToNewCashbookTitle;

  /// No description provided for @restoreToNewCashbookMessage.
  ///
  /// In en, this message translates to:
  /// **'This backup belongs to \"{cloudCashbookName}\". Restoring it will create a new cashbook entry on this device with its data.'**
  String restoreToNewCashbookMessage(String cloudCashbookName);

  /// No description provided for @overrideExistingCashbookTitle.
  ///
  /// In en, this message translates to:
  /// **'Override Existing Cashbook?'**
  String get overrideExistingCashbookTitle;

  /// No description provided for @overrideExistingCashbookMessage.
  ///
  /// In en, this message translates to:
  /// **'This backup belongs to \"{cloudCashbookName}\". Restoring it will overwrite the data of your currently active cashbook, \"{activeCashbookName}\".'**
  String overrideExistingCashbookMessage(
      String cloudCashbookName, String activeCashbookName);

  /// No description provided for @restoreSuccessNew.
  ///
  /// In en, this message translates to:
  /// **'Cashbook {name} created successfully. You can switch to it from the home screen.'**
  String restoreSuccessNew(String name);

  /// No description provided for @restoreOptionOverride.
  ///
  /// In en, this message translates to:
  /// **'Override'**
  String get restoreOptionOverride;

  /// No description provided for @restoreOptionNewEntry.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get restoreOptionNewEntry;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @transactionType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get transactionType;

  /// No description provided for @amountRange.
  ///
  /// In en, this message translates to:
  /// **'Amount Range'**
  String get amountRange;

  /// No description provided for @minAmount.
  ///
  /// In en, this message translates to:
  /// **'Min Amount'**
  String get minAmount;

  /// No description provided for @maxAmount.
  ///
  /// In en, this message translates to:
  /// **'Max Amount'**
  String get maxAmount;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @filterByDueDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by Due Date'**
  String get filterByDueDate;

  /// No description provided for @notificationBackupSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup Successful'**
  String get notificationBackupSuccessTitle;

  /// No description provided for @notificationBackupSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Successfully backed up \"{name}\" to Google Drive.'**
  String notificationBackupSuccessMessage(String name);

  /// No description provided for @notificationSyncCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Background Sync Complete'**
  String get notificationSyncCompleteTitle;

  /// No description provided for @notificationSyncCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Successfully synced {count} cashbook(s) in the background.'**
  String notificationSyncCompleteMessage(int count);

  /// No description provided for @cloudCashbooks.
  ///
  /// In en, this message translates to:
  /// **'Cloud Cashbooks'**
  String get cloudCashbooks;

  /// No description provided for @main.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get main;

  /// No description provided for @cloudDb.
  ///
  /// In en, this message translates to:
  /// **'Cloud DB'**
  String get cloudDb;

  /// No description provided for @versions.
  ///
  /// In en, this message translates to:
  /// **'Versions'**
  String get versions;

  /// No description provided for @local.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get local;

  /// No description provided for @cloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud'**
  String get cloud;

  /// No description provided for @rows.
  ///
  /// In en, this message translates to:
  /// **'{count} rows'**
  String rows(int count);

  /// No description provided for @primeCloudWithLocal.
  ///
  /// In en, this message translates to:
  /// **'Prime Cloud with Local'**
  String get primeCloudWithLocal;

  /// No description provided for @resetCloudVersion.
  ///
  /// In en, this message translates to:
  /// **'Reset Cloud Version'**
  String get resetCloudVersion;

  /// No description provided for @resetCloudVersionMessage.
  ///
  /// In en, this message translates to:
  /// **'This will force the cloud version to match your local version ({version}).\n\nUse this ONLY if your cloud manifest is corrupted or out of sync with your local data.'**
  String resetCloudVersionMessage(Object version);

  /// No description provided for @resetNow.
  ///
  /// In en, this message translates to:
  /// **'Reset Now'**
  String get resetNow;

  /// No description provided for @cloudVersionResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cloud version reset successfully'**
  String get cloudVersionResetSuccess;

  /// No description provided for @cloudVersionResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset cloud version: {error}'**
  String cloudVersionResetFailed(Object error);

  /// No description provided for @syncIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Sync Interval'**
  String get syncIntervalLabel;

  /// No description provided for @resetLocalSyncState.
  ///
  /// In en, this message translates to:
  /// **'Reset Local Sync State'**
  String get resetLocalSyncState;

  /// No description provided for @resetLocalSyncMessage.
  ///
  /// In en, this message translates to:
  /// **'This will mark all your local records as \"unsynced\" and reset your local version to 0. Tapping \"Sync Now\" after this will re-upload all your data to the cloud.\n\nUse this if you want to force a full re-sync of your local data.'**
  String get resetLocalSyncMessage;

  /// No description provided for @localSyncResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Local sync state reset successfully'**
  String get localSyncResetSuccess;

  /// No description provided for @clearAllCloudData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Cloud Data'**
  String get clearAllCloudData;

  /// No description provided for @clearAllCloudDataMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete ALL your FlowKarobar backups and synchronization data from Google Drive. This action cannot be undone.\n\nAre you sure you want to clear all cloud data?'**
  String get clearAllCloudDataMessage;

  /// No description provided for @cloudDataClearedSuccess.
  ///
  /// In en, this message translates to:
  /// **'All cloud data cleared successfully'**
  String get cloudDataClearedSuccess;

  /// No description provided for @clearNow.
  ///
  /// In en, this message translates to:
  /// **'Clear Now'**
  String get clearNow;

  /// No description provided for @upcomingSyncDeltas.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Sync Deltas'**
  String get upcomingSyncDeltas;

  /// No description provided for @recentSyncDeltas.
  ///
  /// In en, this message translates to:
  /// **'Recent Sync Deltas'**
  String get recentSyncDeltas;

  /// No description provided for @manifestContentLocked.
  ///
  /// In en, this message translates to:
  /// **'Manifest Content (Locked)'**
  String get manifestContentLocked;

  /// No description provided for @deltaContent.
  ///
  /// In en, this message translates to:
  /// **'Delta Content'**
  String get deltaContent;

  /// No description provided for @refreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get refreshStatus;

  /// No description provided for @refreshBackups.
  ///
  /// In en, this message translates to:
  /// **'Refresh Backups'**
  String get refreshBackups;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @lockedWithTime.
  ///
  /// In en, this message translates to:
  /// **'Locked ({minutes}m)'**
  String lockedWithTime(int minutes);

  /// No description provided for @payableOverdue.
  ///
  /// In en, this message translates to:
  /// **'Payable Overdue'**
  String get payableOverdue;

  /// No description provided for @payableOverdueMessage.
  ///
  /// In en, this message translates to:
  /// **'Payment for {description} was due on {date}'**
  String payableOverdueMessage(String description, String date);

  /// No description provided for @receivableOverdue.
  ///
  /// In en, this message translates to:
  /// **'Receivable Overdue'**
  String get receivableOverdue;

  /// No description provided for @receivableOverdueMessage.
  ///
  /// In en, this message translates to:
  /// **'Payment for {description} was due on {date}'**
  String receivableOverdueMessage(String description, String date);

  /// No description provided for @upcomingPayable.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Payable'**
  String get upcomingPayable;

  /// No description provided for @upcomingPayableMessage.
  ///
  /// In en, this message translates to:
  /// **'Payment for {description} is due tomorrow ({date})'**
  String upcomingPayableMessage(String description, String date);

  /// No description provided for @upcomingReceivable.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Receivable'**
  String get upcomingReceivable;

  /// No description provided for @upcomingReceivableMessage.
  ///
  /// In en, this message translates to:
  /// **'Payment for {description} is due tomorrow ({date})'**
  String upcomingReceivableMessage(String description, String date);

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'URGENT'**
  String get urgent;

  /// No description provided for @deleteCloudCashbook.
  ///
  /// In en, this message translates to:
  /// **'Delete Cloud Cashbook?'**
  String get deleteCloudCashbook;

  /// No description provided for @deleteCloudCashbookMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\" from Google Drive? This will delete all its backups and sync data. This action cannot be undone.'**
  String deleteCloudCashbookMessage(String name);

  /// No description provided for @cloudCashbookDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cloud cashbook deleted successfully'**
  String get cloudCashbookDeletedSuccess;

  /// No description provided for @myShare.
  ///
  /// In en, this message translates to:
  /// **'My Share'**
  String get myShare;

  /// No description provided for @split.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get split;

  /// No description provided for @contactShare.
  ///
  /// In en, this message translates to:
  /// **'Contact\'s Share'**
  String get contactShare;

  /// No description provided for @othersShare.
  ///
  /// In en, this message translates to:
  /// **'Others Share'**
  String get othersShare;

  /// No description provided for @myShareSuffix.
  ///
  /// In en, this message translates to:
  /// **' (My Share)'**
  String get myShareSuffix;

  /// No description provided for @othersShareSuffix.
  ///
  /// In en, this message translates to:
  /// **' (Others Share)'**
  String get othersShareSuffix;

  /// No description provided for @splitBill.
  ///
  /// In en, this message translates to:
  /// **'Split Bill'**
  String get splitBill;

  /// No description provided for @includeMe.
  ///
  /// In en, this message translates to:
  /// **'Include Me'**
  String get includeMe;

  /// No description provided for @splittedBill.
  ///
  /// In en, this message translates to:
  /// **'Splitted Bill'**
  String get splittedBill;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @distributeEqually.
  ///
  /// In en, this message translates to:
  /// **'Distribute Equally'**
  String get distributeEqually;

  /// No description provided for @totalPercentage.
  ///
  /// In en, this message translates to:
  /// **'Total Percentage'**
  String get totalPercentage;

  /// No description provided for @lockShare.
  ///
  /// In en, this message translates to:
  /// **'Lock Share'**
  String get lockShare;

  /// No description provided for @unlockShare.
  ///
  /// In en, this message translates to:
  /// **'Unlock Share'**
  String get unlockShare;

  /// No description provided for @customAmount.
  ///
  /// In en, this message translates to:
  /// **'Custom Amount'**
  String get customAmount;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @remainingAmount.
  ///
  /// In en, this message translates to:
  /// **'Remaining Amount'**
  String get remainingAmount;

  /// No description provided for @totalMustBe100.
  ///
  /// In en, this message translates to:
  /// **'Total must be 100%'**
  String get totalMustBe100;

  /// No description provided for @totalMustMatch.
  ///
  /// In en, this message translates to:
  /// **'Total must match transaction amount'**
  String get totalMustMatch;

  /// No description provided for @sameDay.
  ///
  /// In en, this message translates to:
  /// **'Same day'**
  String get sameDay;

  /// No description provided for @inDays.
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String inDays(int days);

  /// No description provided for @daysAgoRelative.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgoRelative(int days);

  /// No description provided for @pickActualDate.
  ///
  /// In en, this message translates to:
  /// **'Pick actual date'**
  String get pickActualDate;

  /// No description provided for @relativeDateAfterXDays.
  ///
  /// In en, this message translates to:
  /// **'Relative date (After {days} days)'**
  String relativeDateAfterXDays(String days);

  /// No description provided for @enterDaysFromTransaction.
  ///
  /// In en, this message translates to:
  /// **'Enter number of days from transaction date:'**
  String get enterDaysFromTransaction;

  /// No description provided for @enterDaysFromStart.
  ///
  /// In en, this message translates to:
  /// **'Enter number of days from start date:'**
  String get enterDaysFromStart;

  /// No description provided for @daysHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 15'**
  String get daysHint;

  /// No description provided for @daysSuffix.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysSuffix;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @payableVsReceivableTrend.
  ///
  /// In en, this message translates to:
  /// **'Payable vs Receivable Trend'**
  String get payableVsReceivableTrend;

  /// No description provided for @categoryDetails.
  ///
  /// In en, this message translates to:
  /// **'Category Details'**
  String get categoryDetails;

  /// No description provided for @netIncome.
  ///
  /// In en, this message translates to:
  /// **'Net Income'**
  String get netIncome;

  /// No description provided for @netExpenses.
  ///
  /// In en, this message translates to:
  /// **'Net Expenses'**
  String get netExpenses;

  /// No description provided for @categoriesAggregateTitle.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get categoriesAggregateTitle;

  /// No description provided for @syncStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get syncStatusTitle;

  /// No description provided for @changesToPush.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change to push} other{{count} changes to push}}'**
  String changesToPush(int count);

  /// Chip label for transactions that are not synced
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get changes;

  /// No description provided for @updatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Updates available on cloud'**
  String get updatesAvailable;

  /// No description provided for @oneUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'1 update available on cloud'**
  String get oneUpdateAvailable;

  /// No description provided for @multipleUpdatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} updates available on cloud'**
  String multipleUpdatesAvailable(int count);

  /// No description provided for @dataSynced.
  ///
  /// In en, this message translates to:
  /// **'Data is synced'**
  String get dataSynced;

  /// No description provided for @syncAlreadyInProgress.
  ///
  /// In en, this message translates to:
  /// **'Sync already in progress'**
  String get syncAlreadyInProgress;

  /// No description provided for @syncDelayedRetryShortly.
  ///
  /// In en, this message translates to:
  /// **'Sync delayed – will retry shortly'**
  String get syncDelayedRetryShortly;

  /// No description provided for @premiumRequiredForSync.
  ///
  /// In en, this message translates to:
  /// **'Premium required for cloud sync'**
  String get premiumRequiredForSync;

  /// No description provided for @signInRequiredForSync.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google to sync'**
  String get signInRequiredForSync;

  /// No description provided for @clearCloud.
  ///
  /// In en, this message translates to:
  /// **'Clear Cloud'**
  String get clearCloud;

  /// No description provided for @clearCloudTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Cloud Data'**
  String get clearCloudTitle;

  /// No description provided for @clearCloudMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose which cloud data you want to clear for \"{name}\".'**
  String clearCloudMessage(Object name);

  /// No description provided for @clearBackups.
  ///
  /// In en, this message translates to:
  /// **'Clear all backups'**
  String get clearBackups;

  /// No description provided for @clearBackupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deletes full database snapshots from Google Drive'**
  String get clearBackupsSubtitle;

  /// No description provided for @clearDocuments.
  ///
  /// In en, this message translates to:
  /// **'Clear documents backup'**
  String get clearDocuments;

  /// No description provided for @clearDocumentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deletes all document ZIP backups from Google Drive'**
  String get clearDocumentsSubtitle;

  /// No description provided for @clearSyncHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear sync history'**
  String get clearSyncHistory;

  /// No description provided for @clearSyncHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Resets sync manifest and deletes delta files'**
  String get clearSyncHistorySubtitle;

  /// No description provided for @clearSelectedCloudData.
  ///
  /// In en, this message translates to:
  /// **'Clear Selected Data'**
  String get clearSelectedCloudData;

  /// No description provided for @cloudDataCleared.
  ///
  /// In en, this message translates to:
  /// **'Selected cloud data cleared successfully'**
  String get cloudDataCleared;

  /// No description provided for @deleteLocalOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Your cloud backups and sync data will remain safe on Google Drive.'**
  String get deleteLocalOnlyNote;

  /// No description provided for @alsoClearCloud.
  ///
  /// In en, this message translates to:
  /// **'Also clear cloud backup'**
  String get alsoClearCloud;

  /// No description provided for @clearCloudSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Wipes history from Google Drive for this cashbook only'**
  String get clearCloudSubtitle;

  /// No description provided for @addCloudCashbook.
  ///
  /// In en, this message translates to:
  /// **'Add Cloud Cashbook'**
  String get addCloudCashbook;

  /// No description provided for @addFromCloud.
  ///
  /// In en, this message translates to:
  /// **'Add from Cloud'**
  String get addFromCloud;

  /// No description provided for @bulkProcessConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to process all outstanding items for this contact?'**
  String get bulkProcessConfirmation;

  /// No description provided for @accountChangedTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Drive Account Changed'**
  String get accountChangedTitle;

  /// No description provided for @accountChangedMessage.
  ///
  /// In en, this message translates to:
  /// **'You previously synced with {oldEmail}, but are now logged into {newEmail}.\n\nTo prevent data conflicts, your data will not sync correctly with this new drive until you clear the existing cloud data.\n\nPlease go to the Cashbooks screen, tap the menu (⋮) on your cashbook, and select \'Clear Cloud\'.'**
  String accountChangedMessage(String oldEmail, String newEmail);

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @premiumExpiredSyncPaused.
  ///
  /// In en, this message translates to:
  /// **'Your Premium subscription has expired. Cloud sync has been paused and you have been logged out of Google Drive.'**
  String get premiumExpiredSyncPaused;

  /// No description provided for @loggedOutSyncPaused.
  ///
  /// In en, this message translates to:
  /// **'Logged out. Background sync has been paused.'**
  String get loggedOutSyncPaused;

  /// No description provided for @signOutSyncConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Signing out will pause background sync. Continue?'**
  String get signOutSyncConfirmMessage;

  /// No description provided for @scenarioHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'What type of transaction?'**
  String get scenarioHelpTitle;

  /// No description provided for @autoSuggest.
  ///
  /// In en, this message translates to:
  /// **'Auto suggest'**
  String get autoSuggest;

  /// No description provided for @scenarioPaidForMeal.
  ///
  /// In en, this message translates to:
  /// **'Paid for friend\'s lunch / meal'**
  String get scenarioPaidForMeal;

  /// No description provided for @scenarioBoughtForSomeone.
  ///
  /// In en, this message translates to:
  /// **'Bought something for someone (they\'ll pay back)'**
  String get scenarioBoughtForSomeone;

  /// No description provided for @scenarioLentMoney.
  ///
  /// In en, this message translates to:
  /// **'Lent money to colleague/family'**
  String get scenarioLentMoney;

  /// No description provided for @scenarioPaidBillForSomeone.
  ///
  /// In en, this message translates to:
  /// **'Paid a bill on behalf of someone'**
  String get scenarioPaidBillForSomeone;

  /// No description provided for @scenarioSplitYouPaid.
  ///
  /// In en, this message translates to:
  /// **'Split expense – you paid full, others will reimburse'**
  String get scenarioSplitYouPaid;

  /// No description provided for @scenarioFriendPaidMeal.
  ///
  /// In en, this message translates to:
  /// **'Friend paid for your lunch'**
  String get scenarioFriendPaidMeal;

  /// No description provided for @scenarioSomeonePaidBill.
  ///
  /// In en, this message translates to:
  /// **'Someone else paid the bill (you\'ll pay them back)'**
  String get scenarioSomeonePaidBill;

  /// No description provided for @scenarioColleaguePaidForYou.
  ///
  /// In en, this message translates to:
  /// **'Colleague/family paid for you (you\'ll reimburse)'**
  String get scenarioColleaguePaidForYou;

  /// No description provided for @scenarioSplitTheyPaid.
  ///
  /// In en, this message translates to:
  /// **'Shared expense – others paid your share'**
  String get scenarioSplitTheyPaid;

  /// No description provided for @scenarioPaySomeoneForServices.
  ///
  /// In en, this message translates to:
  /// **'You have to pay someone for services'**
  String get scenarioPaySomeoneForServices;

  /// No description provided for @scenarioBorrowedCash.
  ///
  /// In en, this message translates to:
  /// **'Borrowed cash from someone'**
  String get scenarioBorrowedCash;

  /// No description provided for @scenarioLoanReceived.
  ///
  /// In en, this message translates to:
  /// **'Received a loan (to be repaid)'**
  String get scenarioLoanReceived;

  /// No description provided for @scenarioBorrowedFromContact.
  ///
  /// In en, this message translates to:
  /// **'Borrowed money from friend/family'**
  String get scenarioBorrowedFromContact;

  /// No description provided for @scenarioSalaryAdvance.
  ///
  /// In en, this message translates to:
  /// **'Got advance from employer (to be deducted)'**
  String get scenarioSalaryAdvance;

  /// No description provided for @scenarioReceivedToRepay.
  ///
  /// In en, this message translates to:
  /// **'Received money you\'ll return'**
  String get scenarioReceivedToRepay;

  /// No description provided for @scenarioSalaryPending.
  ///
  /// In en, this message translates to:
  /// **'Salary to be received'**
  String get scenarioSalaryPending;

  /// No description provided for @scenarioClientPaymentPending.
  ///
  /// In en, this message translates to:
  /// **'Payment from client (pending)'**
  String get scenarioClientPaymentPending;

  /// No description provided for @scenarioPaymentPending.
  ///
  /// In en, this message translates to:
  /// **'Friend/family will pay you back'**
  String get scenarioPaymentPending;

  /// No description provided for @scenarioRentPending.
  ///
  /// In en, this message translates to:
  /// **'Rent to be received'**
  String get scenarioRentPending;

  /// No description provided for @scenarioSalePending.
  ///
  /// In en, this message translates to:
  /// **'Sold something – payment pending'**
  String get scenarioSalePending;

  /// No description provided for @scenarioInvoicePending.
  ///
  /// In en, this message translates to:
  /// **'Invoice not yet paid'**
  String get scenarioInvoicePending;

  /// No description provided for @scenarioPersonalExpense.
  ///
  /// In en, this message translates to:
  /// **'Personal expense / shopping'**
  String get scenarioPersonalExpense;

  /// No description provided for @scenarioBillPaid.
  ///
  /// In en, this message translates to:
  /// **'Bill / utility payment'**
  String get scenarioBillPaid;

  /// No description provided for @scenarioSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription / membership'**
  String get scenarioSubscription;

  /// No description provided for @scenarioSalaryReceived.
  ///
  /// In en, this message translates to:
  /// **'Salary received'**
  String get scenarioSalaryReceived;

  /// No description provided for @scenarioFreelanceIncome.
  ///
  /// In en, this message translates to:
  /// **'Freelance / side income'**
  String get scenarioFreelanceIncome;

  /// No description provided for @scenarioGiftReceived.
  ///
  /// In en, this message translates to:
  /// **'Gift / bonus received'**
  String get scenarioGiftReceived;

  /// No description provided for @scenarioRefundReceived.
  ///
  /// In en, this message translates to:
  /// **'Refund received'**
  String get scenarioRefundReceived;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @openingBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening Balance'**
  String get openingBalance;

  /// No description provided for @openingBalanceDues.
  ///
  /// In en, this message translates to:
  /// **'Opening Balance (Dues)'**
  String get openingBalanceDues;

  /// No description provided for @openingDate.
  ///
  /// In en, this message translates to:
  /// **'Opening Date'**
  String get openingDate;

  /// No description provided for @creditLimit.
  ///
  /// In en, this message translates to:
  /// **'Credit Limit'**
  String get creditLimit;

  /// No description provided for @billingCycleDay.
  ///
  /// In en, this message translates to:
  /// **'Billing Cycle Day'**
  String get billingCycleDay;

  /// No description provided for @paymentDueDays.
  ///
  /// In en, this message translates to:
  /// **'Payment Due (days after cycle)'**
  String get paymentDueDays;

  /// No description provided for @linkedPaymentAccount.
  ///
  /// In en, this message translates to:
  /// **'Linked Payment Account'**
  String get linkedPaymentAccount;

  /// No description provided for @linkedPaymentAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Account used for auto-payment reminder'**
  String get linkedPaymentAccountHint;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreated;

  /// No description provided for @accountUpdated.
  ///
  /// In en, this message translates to:
  /// **'Account updated successfully'**
  String get accountUpdated;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeleted;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this account? This will not delete transactions linked to it.'**
  String get deleteAccountConfirmation;

  /// No description provided for @noAccounts.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get noAccounts;

  /// No description provided for @noAccountsDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your cash, bank or card accounts to track balances'**
  String get noAccountsDescription;

  /// No description provided for @creditCardNotAllowedForReceive.
  ///
  /// In en, this message translates to:
  /// **'Credit cards can\'t be used here. Add or pick a cash, bank, or savings account instead.'**
  String get creditCardNotAllowedForReceive;

  /// No description provided for @outstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// No description provided for @availableCredit.
  ///
  /// In en, this message translates to:
  /// **'Available Credit'**
  String get availableCredit;

  /// No description provided for @creditBalance.
  ///
  /// In en, this message translates to:
  /// **'Credit Balance'**
  String get creditBalance;

  /// No description provided for @billed.
  ///
  /// In en, this message translates to:
  /// **'Billed'**
  String get billed;

  /// No description provided for @unbilled.
  ///
  /// In en, this message translates to:
  /// **'Unbilled'**
  String get unbilled;

  /// No description provided for @transferMoney.
  ///
  /// In en, this message translates to:
  /// **'Transfer Money'**
  String get transferMoney;

  /// No description provided for @fromAccount.
  ///
  /// In en, this message translates to:
  /// **'From Account'**
  String get fromAccount;

  /// No description provided for @toAccount.
  ///
  /// In en, this message translates to:
  /// **'To Account'**
  String get toAccount;

  /// No description provided for @transferCreated.
  ///
  /// In en, this message translates to:
  /// **'Transfer recorded successfully'**
  String get transferCreated;

  /// No description provided for @selectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get selectAccount;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No Account'**
  String get noAccount;

  /// No description provided for @pendingTransactions.
  ///
  /// In en, this message translates to:
  /// **'Pending Transactions'**
  String get pendingTransactions;

  /// No description provided for @payFrom.
  ///
  /// In en, this message translates to:
  /// **'Pay from'**
  String get payFrom;

  /// No description provided for @receiveInto.
  ///
  /// In en, this message translates to:
  /// **'Receive Into'**
  String get receiveInto;

  /// No description provided for @settlementAccount.
  ///
  /// In en, this message translates to:
  /// **'Settlement Account'**
  String get settlementAccount;

  /// No description provided for @setAccount.
  ///
  /// In en, this message translates to:
  /// **'Set Account'**
  String get setAccount;

  /// No description provided for @combineBalances.
  ///
  /// In en, this message translates to:
  /// **'Combine Balances'**
  String get combineBalances;

  /// No description provided for @selectedTotal.
  ///
  /// In en, this message translates to:
  /// **'Selected Total'**
  String get selectedTotal;

  /// No description provided for @selectAccountsToCombine.
  ///
  /// In en, this message translates to:
  /// **'Select accounts to see their combined balance'**
  String get selectAccountsToCombine;

  /// No description provided for @accountPickerInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Applies only to transactions without an assigned account'**
  String get accountPickerInfoMessage;

  /// No description provided for @settlementContinueWithoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Keep transaction\'s account'**
  String get settlementContinueWithoutAccount;

  /// No description provided for @negativeBalanceWarning.
  ///
  /// In en, this message translates to:
  /// **'This will put your Cash balance below zero'**
  String get negativeBalanceWarning;

  /// No description provided for @paymentDueNotification.
  ///
  /// In en, this message translates to:
  /// **'Credit card payment of {amount} is due in {days} days'**
  String paymentDueNotification(String amount, int days);

  /// No description provided for @paymentDueTodayNotification.
  ///
  /// In en, this message translates to:
  /// **'Credit card payment of {amount} is due today'**
  String paymentDueTodayNotification(String amount);

  /// No description provided for @paymentOverdueNotification.
  ///
  /// In en, this message translates to:
  /// **'Credit card payment of {amount} is overdue by {days} days'**
  String paymentOverdueNotification(String amount, int days);

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// No description provided for @accountBalance.
  ///
  /// In en, this message translates to:
  /// **'Account Balance'**
  String get accountBalance;

  /// No description provided for @noAccountSelected.
  ///
  /// In en, this message translates to:
  /// **'No account selected'**
  String get noAccountSelected;

  /// No description provided for @selectPaymentAccount.
  ///
  /// In en, this message translates to:
  /// **'Select payment account'**
  String get selectPaymentAccount;

  /// No description provided for @dayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day of Month'**
  String get dayOfMonth;

  /// No description provided for @howMuchDoYouOwe.
  ///
  /// In en, this message translates to:
  /// **'How much do you currently owe on this card?'**
  String get howMuchDoYouOwe;

  /// No description provided for @transferBetweenAccounts.
  ///
  /// In en, this message translates to:
  /// **'Transfer between accounts'**
  String get transferBetweenAccounts;

  /// No description provided for @sameAccountError.
  ///
  /// In en, this message translates to:
  /// **'From and To accounts cannot be the same'**
  String get sameAccountError;

  /// No description provided for @transfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get transfers;

  /// No description provided for @recentTransfers.
  ///
  /// In en, this message translates to:
  /// **'Recent Transfers'**
  String get recentTransfers;

  /// No description provided for @noTransfers.
  ///
  /// In en, this message translates to:
  /// **'No transfers yet'**
  String get noTransfers;

  /// No description provided for @transferFromTo.
  ///
  /// In en, this message translates to:
  /// **'{from} → {to}'**
  String transferFromTo(String from, String to);

  /// No description provided for @accountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found'**
  String get accountNotFound;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this account? This will not delete transactions linked to it.'**
  String get deleteAccountConfirm;

  /// No description provided for @outstandingBalance.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Balance'**
  String get outstandingBalance;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @amountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount Due'**
  String get amountDue;

  /// No description provided for @unbilledAmount.
  ///
  /// In en, this message translates to:
  /// **'Unbilled Amount'**
  String get unbilledAmount;

  /// No description provided for @creditUsed.
  ///
  /// In en, this message translates to:
  /// **'Credit Used'**
  String get creditUsed;

  /// No description provided for @creditCards.
  ///
  /// In en, this message translates to:
  /// **'Credit Cards'**
  String get creditCards;

  /// No description provided for @netWorth.
  ///
  /// In en, this message translates to:
  /// **'Net Worth'**
  String get netWorth;

  /// No description provided for @totalAssets.
  ///
  /// In en, this message translates to:
  /// **'Total Assets'**
  String get totalAssets;

  /// No description provided for @totalLiabilities.
  ///
  /// In en, this message translates to:
  /// **'Total Liabilities'**
  String get totalLiabilities;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @pleaseEnterAccountName.
  ///
  /// In en, this message translates to:
  /// **'Please enter account name'**
  String get pleaseEnterAccountName;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @creditCardDetails.
  ///
  /// In en, this message translates to:
  /// **'Credit Card Details'**
  String get creditCardDetails;

  /// No description provided for @pleaseSelectBothAccounts.
  ///
  /// In en, this message translates to:
  /// **'Please select both From and To accounts'**
  String get pleaseSelectBothAccounts;

  /// No description provided for @recordTransfer.
  ///
  /// In en, this message translates to:
  /// **'Record Transfer'**
  String get recordTransfer;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @dayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String dayLabel(int day);

  /// No description provided for @openTransactionsForAccount.
  ///
  /// In en, this message translates to:
  /// **'Tap to view transactions for this account'**
  String get openTransactionsForAccount;

  /// No description provided for @payBill.
  ///
  /// In en, this message translates to:
  /// **'Pay Bill'**
  String get payBill;

  /// No description provided for @customPayment.
  ///
  /// In en, this message translates to:
  /// **'Custom Payment'**
  String get customPayment;

  /// No description provided for @customPaymentHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a custom amount'**
  String get customPaymentHint;

  /// No description provided for @payingAmount.
  ///
  /// In en, this message translates to:
  /// **'Paying {amount}'**
  String payingAmount(String amount);

  /// No description provided for @noBankAccountsToPayFrom.
  ///
  /// In en, this message translates to:
  /// **'No bank or savings accounts available to pay from'**
  String get noBankAccountsToPayFrom;

  /// No description provided for @accountsOverview.
  ///
  /// In en, this message translates to:
  /// **'Accounts Overview'**
  String get accountsOverview;

  /// No description provided for @balanceDistribution.
  ///
  /// In en, this message translates to:
  /// **'Balance Distribution'**
  String get balanceDistribution;

  /// No description provided for @accountFlowSummary.
  ///
  /// In en, this message translates to:
  /// **'Account Cashflow'**
  String get accountFlowSummary;

  /// No description provided for @creditUtilisation.
  ///
  /// In en, this message translates to:
  /// **'Credit Utilisation'**
  String get creditUtilisation;

  /// No description provided for @openingBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening'**
  String get openingBalanceLabel;

  /// No description provided for @closingBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Closing'**
  String get closingBalanceLabel;

  /// No description provided for @transferFromAnalytics.
  ///
  /// In en, this message translates to:
  /// **'From {account}'**
  String transferFromAnalytics(String account);

  /// No description provided for @transferToAnalytics.
  ///
  /// In en, this message translates to:
  /// **'To {account}'**
  String transferToAnalytics(String account);

  /// No description provided for @unknownAccount.
  ///
  /// In en, this message translates to:
  /// **'Other Account'**
  String get unknownAccount;

  /// No description provided for @noAccountActivity.
  ///
  /// In en, this message translates to:
  /// **'No account activity in this period'**
  String get noAccountActivity;

  /// No description provided for @noTransferActivity.
  ///
  /// In en, this message translates to:
  /// **'No transfers in this period'**
  String get noTransferActivity;

  /// No description provided for @creditUsedOf.
  ///
  /// In en, this message translates to:
  /// **'{used} used of {limit}'**
  String creditUsedOf(String used, String limit);

  /// No description provided for @inflow.
  ///
  /// In en, this message translates to:
  /// **'Inflow'**
  String get inflow;

  /// No description provided for @outflow.
  ///
  /// In en, this message translates to:
  /// **'Outflow'**
  String get outflow;

  /// No description provided for @netFlow.
  ///
  /// In en, this message translates to:
  /// **'Net Flow'**
  String get netFlow;

  /// No description provided for @showDetails.
  ///
  /// In en, this message translates to:
  /// **'Show Details'**
  String get showDetails;

  /// No description provided for @customiseSections.
  ///
  /// In en, this message translates to:
  /// **'Customise Sections'**
  String get customiseSections;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get moreOptions;

  /// No description provided for @processed.
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get processed;

  /// No description provided for @processedImmediately.
  ///
  /// In en, this message translates to:
  /// **'Paid immediately'**
  String get processedImmediately;

  /// No description provided for @doubleTapForDetails.
  ///
  /// In en, this message translates to:
  /// **'Double tap for details'**
  String get doubleTapForDetails;

  /// No description provided for @receivedImmediately.
  ///
  /// In en, this message translates to:
  /// **'Received immediately'**
  String get receivedImmediately;

  /// No description provided for @processedOn.
  ///
  /// In en, this message translates to:
  /// **'Processed On'**
  String get processedOn;

  /// No description provided for @paidOnRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid on'**
  String get paidOnRowLabel;

  /// No description provided for @receivedOnRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Received on'**
  String get receivedOnRowLabel;

  /// No description provided for @paidForSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I paid, will receive back'**
  String get paidForSubtitle;

  /// No description provided for @paidBySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Someone paid for me'**
  String get paidBySubtitle;

  /// No description provided for @willReceiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Expected, not received yet'**
  String get willReceiveSubtitle;

  /// No description provided for @receivedFromSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Received, will pay back'**
  String get receivedFromSubtitle;

  /// No description provided for @spendingBudget.
  ///
  /// In en, this message translates to:
  /// **'Spending budget'**
  String get spendingBudget;

  /// No description provided for @savingsTarget.
  ///
  /// In en, this message translates to:
  /// **'Savings target'**
  String get savingsTarget;

  /// No description provided for @setBudget.
  ///
  /// In en, this message translates to:
  /// **'Set budget'**
  String get setBudget;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit budget'**
  String get editBudget;

  /// No description provided for @setTarget.
  ///
  /// In en, this message translates to:
  /// **'Set target'**
  String get setTarget;

  /// No description provided for @editTarget.
  ///
  /// In en, this message translates to:
  /// **'Edit target'**
  String get editTarget;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get monthlyBudget;

  /// No description provided for @quarterlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Quarterly budget'**
  String get quarterlyBudget;

  /// No description provided for @yearlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Yearly budget'**
  String get yearlyBudget;

  /// No description provided for @overallBudget.
  ///
  /// In en, this message translates to:
  /// **'Overall budget'**
  String get overallBudget;

  /// No description provided for @overallBudgetProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall budget progress'**
  String get overallBudgetProgress;

  /// No description provided for @overallTargetProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall target progress'**
  String get overallTargetProgress;

  /// No description provided for @monthlyTarget.
  ///
  /// In en, this message translates to:
  /// **'Monthly target'**
  String get monthlyTarget;

  /// No description provided for @quarterlyTarget.
  ///
  /// In en, this message translates to:
  /// **'Quarterly target'**
  String get quarterlyTarget;

  /// No description provided for @yearlyTarget.
  ///
  /// In en, this message translates to:
  /// **'Yearly target'**
  String get yearlyTarget;

  /// No description provided for @overallTarget.
  ///
  /// In en, this message translates to:
  /// **'Overall target'**
  String get overallTarget;

  /// No description provided for @overallNetAmount.
  ///
  /// In en, this message translates to:
  /// **'Overall Net Amount'**
  String get overallNetAmount;

  /// No description provided for @providedPeriod.
  ///
  /// In en, this message translates to:
  /// **'Provided Period'**
  String get providedPeriod;

  /// No description provided for @overall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get overall;

  /// No description provided for @spendingBudgetDescription.
  ///
  /// In en, this message translates to:
  /// **'Optional spending limits for the calendar month, quarter, year, or overall.'**
  String get spendingBudgetDescription;

  /// No description provided for @savingsTargetDescription.
  ///
  /// In en, this message translates to:
  /// **'Optional savings targets for the calendar month, quarter, year, or overall.'**
  String get savingsTargetDescription;

  /// No description provided for @budgetSaved.
  ///
  /// In en, this message translates to:
  /// **'Budget saved'**
  String get budgetSaved;

  /// No description provided for @targetSaved.
  ///
  /// In en, this message translates to:
  /// **'Target saved'**
  String get targetSaved;

  /// No description provided for @budgetRemainingOf.
  ///
  /// In en, this message translates to:
  /// **'{remaining} left of {total}'**
  String budgetRemainingOf(String remaining, String total);

  /// No description provided for @budgetOverBy.
  ///
  /// In en, this message translates to:
  /// **'{amount} over budget'**
  String budgetOverBy(String amount);

  /// No description provided for @towardSavingsTarget.
  ///
  /// In en, this message translates to:
  /// **'{amount} toward target'**
  String towardSavingsTarget(String amount);

  /// No description provided for @customCategoryBadge.
  ///
  /// In en, this message translates to:
  /// **'Custom category'**
  String get customCategoryBadge;

  /// No description provided for @budgetBarUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get budgetBarUsed;

  /// No description provided for @budgetBarProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get budgetBarProgress;

  /// No description provided for @categoryRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get categoryRefund;

  /// No description provided for @showQuickActionButton.
  ///
  /// In en, this message translates to:
  /// **'Show Quick Action Button'**
  String get showQuickActionButton;

  /// No description provided for @showQuickActionButtonDesc.
  ///
  /// In en, this message translates to:
  /// **'Display the center button in the bottom bar'**
  String get showQuickActionButtonDesc;

  /// No description provided for @showDashboardWidgetArea.
  ///
  /// In en, this message translates to:
  /// **'Show Dashboard Widgets'**
  String get showDashboardWidgetArea;

  /// No description provided for @showDashboardWidgetAreaDesc.
  ///
  /// In en, this message translates to:
  /// **'Display the customizable widget section on the dashboard'**
  String get showDashboardWidgetAreaDesc;

  /// No description provided for @noWidgetsOnDashboard.
  ///
  /// In en, this message translates to:
  /// **'No widgets on dashboard'**
  String get noWidgetsOnDashboard;

  /// No description provided for @switchCashbook.
  ///
  /// In en, this message translates to:
  /// **'Switch Cashbook'**
  String get switchCashbook;

  /// No description provided for @switchText.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchText;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @featureUnlimitedAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Accounts'**
  String get featureUnlimitedAccountsTitle;

  /// No description provided for @featureUnlimitedAccountsDesc.
  ///
  /// In en, this message translates to:
  /// **'Add multiple bank accounts, cash wallets, and credit cards to track all your balances in one place.'**
  String get featureUnlimitedAccountsDesc;

  /// No description provided for @featureCategoryBudgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Category Budgets'**
  String get featureCategoryBudgetsTitle;

  /// No description provided for @featureCategoryBudgetsDesc.
  ///
  /// In en, this message translates to:
  /// **'Set monthly, quarterly, or yearly spending limits and savings targets for any category.'**
  String get featureCategoryBudgetsDesc;

  /// No description provided for @onDashboard.
  ///
  /// In en, this message translates to:
  /// **'On Dashboard'**
  String get onDashboard;

  /// No description provided for @widgets.
  ///
  /// In en, this message translates to:
  /// **'Widgets'**
  String get widgets;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FlowKarobar'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Your complete business and cash flow manager. Take control of your sales, purchases, and orders with ease, precision, and the peace of mind that your data is fully secured and private.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan or Speak'**
  String get onboardingScanTitle;

  /// No description provided for @onboardingScanBody.
  ///
  /// In en, this message translates to:
  /// **'Save time with Smart Scanning and Voice commands. Just snap a photo of your receipt or tell the app what you spent—it handles the details for you.'**
  String get onboardingScanBody;

  /// No description provided for @onboardingTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Linked Transactions'**
  String get onboardingTransactionsTitle;

  /// No description provided for @onboardingTransactionsBody.
  ///
  /// In en, this message translates to:
  /// **'Experience a truly connected system. When you mark a debt as Received, the app automatically records it as Income. When you Pay a bill, it’s instantly logged as an Expense.'**
  String get onboardingTransactionsBody;

  /// No description provided for @onboardingCollaborationTitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time Collaboration'**
  String get onboardingCollaborationTitle;

  /// No description provided for @onboardingCollaborationBody.
  ///
  /// In en, this message translates to:
  /// **'Track Receivables and Payables by contact. Send professional WhatsApp reminders using customized message templates to ensure you always get paid on time.'**
  String get onboardingCollaborationBody;

  /// No description provided for @onboardingSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Organized & Personalized'**
  String get onboardingSyncTitle;

  /// No description provided for @onboardingSyncBody.
  ///
  /// In en, this message translates to:
  /// **'Create separate Cashbooks for Home or Business. Personalize your Dashboard with custom widgets, and keep everything synced across all your devices.'**
  String get onboardingSyncBody;

  /// No description provided for @guideAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage All Your Accounts'**
  String get guideAccountsTitle;

  /// No description provided for @guideAccountsBody.
  ///
  /// In en, this message translates to:
  /// **'Track Cash, Bank, and Savings accounts in one place. See your total Net Worth automatically calculated from your assets and liabilities.'**
  String get guideAccountsBody;

  /// No description provided for @guideCreditCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credit Card Management'**
  String get guideCreditCardsTitle;

  /// No description provided for @guideCreditCardsBody.
  ///
  /// In en, this message translates to:
  /// **'Set credit limits and billing cycles. FlowKarobar will notify you before your due date so you never miss a payment.'**
  String get guideCreditCardsBody;

  /// No description provided for @guideBulkImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk Import Transactions'**
  String get guideBulkImportTitle;

  /// No description provided for @guideBulkImportBody.
  ///
  /// In en, this message translates to:
  /// **'Save time by importing hundreds of transactions instantly from CSV files or your clipboard (Google Sheets).'**
  String get guideBulkImportBody;

  /// No description provided for @guideBudgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Category Budgets'**
  String get guideBudgetsTitle;

  /// No description provided for @guideBudgetsBody.
  ///
  /// In en, this message translates to:
  /// **'Set monthly spending limits for any category. Use the consumption indicators to stay on track and save more.'**
  String get guideBudgetsBody;

  /// No description provided for @guideAutoSettleTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-Generated Transactions'**
  String get guideAutoSettleTitle;

  /// No description provided for @guideAutoSettleBody.
  ///
  /// In en, this message translates to:
  /// **'Marking a Receivable as \'Received\' automatically creates an Income entry. Paying a bill instantly logs an Expense—keeping your records perfectly linked.'**
  String get guideAutoSettleBody;

  /// No description provided for @guideSplitSettleTitle.
  ///
  /// In en, this message translates to:
  /// **'Split Bills & Bulk Settle'**
  String get guideSplitSettleTitle;

  /// No description provided for @guideSplitSettleBody.
  ///
  /// In en, this message translates to:
  /// **'Easily split expenses with multiple contacts. Use Bulk Settlement to clear all outstanding dues with a single contact in one tap.'**
  String get guideSplitSettleBody;

  /// No description provided for @deleteTransfer.
  ///
  /// In en, this message translates to:
  /// **'Delete Transfer'**
  String get deleteTransfer;

  /// No description provided for @deleteTransferConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transfer? This will update the balances of both involved accounts.'**
  String get deleteTransferConfirm;

  /// No description provided for @deleteReceivable.
  ///
  /// In en, this message translates to:
  /// **'Delete Receivable'**
  String get deleteReceivable;

  /// No description provided for @deleteReceivableConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this receivable? This action cannot be undone.'**
  String get deleteReceivableConfirm;

  /// No description provided for @deletePayable.
  ///
  /// In en, this message translates to:
  /// **'Delete Payable'**
  String get deletePayable;

  /// No description provided for @deletePayableConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this payable? This action cannot be undone.'**
  String get deletePayableConfirm;

  /// No description provided for @transferDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transfer deleted successfully'**
  String get transferDeleted;

  /// No description provided for @transferUpdated.
  ///
  /// In en, this message translates to:
  /// **'Transfer updated successfully'**
  String get transferUpdated;

  /// No description provided for @editTransfer.
  ///
  /// In en, this message translates to:
  /// **'Edit Transfer'**
  String get editTransfer;

  /// No description provided for @updateTransfer.
  ///
  /// In en, this message translates to:
  /// **'Update Transfer'**
  String get updateTransfer;

  /// No description provided for @dashboardHeroCombineTitle.
  ///
  /// In en, this message translates to:
  /// **'View combined balance'**
  String get dashboardHeroCombineTitle;

  /// No description provided for @dashboardHeroCombineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose which other cashbooks to add to the dashboard totals for this cashbook.'**
  String get dashboardHeroCombineSubtitle;

  /// No description provided for @dashboardHeroCombineNoSummary.
  ///
  /// In en, this message translates to:
  /// **'Open once to load amounts.'**
  String get dashboardHeroCombineNoSummary;

  /// No description provided for @dashboardHeroCombineNoOthers.
  ///
  /// In en, this message translates to:
  /// **'There are no other cashbooks to include.'**
  String get dashboardHeroCombineNoOthers;

  /// No description provided for @itemizedDetails.
  ///
  /// In en, this message translates to:
  /// **'Itemized Details'**
  String get itemizedDetails;

  /// No description provided for @addItemizedDetails.
  ///
  /// In en, this message translates to:
  /// **'Add Itemized Details'**
  String get addItemizedDetails;

  /// No description provided for @itemizedHeaderQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'{quantity} units'**
  String itemizedHeaderQuantityLabel(String quantity);

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @unitsQuantity.
  ///
  /// In en, this message translates to:
  /// **'Units/Qty'**
  String get unitsQuantity;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @itemized.
  ///
  /// In en, this message translates to:
  /// **'Itemized'**
  String get itemized;

  /// No description provided for @nextGenerated.
  ///
  /// In en, this message translates to:
  /// **'Next Generated'**
  String get nextGenerated;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @showChart.
  ///
  /// In en, this message translates to:
  /// **'Show Chart'**
  String get showChart;

  /// No description provided for @showList.
  ///
  /// In en, this message translates to:
  /// **'Show List'**
  String get showList;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @relatedTransactions.
  ///
  /// In en, this message translates to:
  /// **'Related Transactions'**
  String get relatedTransactions;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @autoSyncOnStartup.
  ///
  /// In en, this message translates to:
  /// **'Auto-sync on startup'**
  String get autoSyncOnStartup;

  /// No description provided for @autoSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically sync data when the app opens'**
  String get autoSyncDescription;

  /// No description provided for @premiumVerificationToken.
  ///
  /// In en, this message translates to:
  /// **'Premium Verification Token'**
  String get premiumVerificationToken;

  /// No description provided for @tokenExpiry.
  ///
  /// In en, this message translates to:
  /// **'Token Expiry'**
  String get tokenExpiry;

  /// No description provided for @refreshToken.
  ///
  /// In en, this message translates to:
  /// **'Refresh Token'**
  String get refreshToken;

  /// No description provided for @tokenValid.
  ///
  /// In en, this message translates to:
  /// **'Premium Token Valid'**
  String get tokenValid;

  /// No description provided for @tokenExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring Soon'**
  String get tokenExpiringSoon;

  /// No description provided for @tokenExpired.
  ///
  /// In en, this message translates to:
  /// **'Token Expired'**
  String get tokenExpired;

  /// No description provided for @premiumTokenMissing.
  ///
  /// In en, this message translates to:
  /// **'Premium Token Missing'**
  String get premiumTokenMissing;

  /// No description provided for @noTokenGenerated.
  ///
  /// In en, this message translates to:
  /// **'No token generated yet'**
  String get noTokenGenerated;

  /// No description provided for @tokenRegeneratedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Premium token regenerated successfully'**
  String get tokenRegeneratedSuccess;

  /// No description provided for @fetchPremiumToken.
  ///
  /// In en, this message translates to:
  /// **'Fetch Premium Token'**
  String get fetchPremiumToken;

  /// No description provided for @premiumTokenSyncedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Premium status synced successfully!'**
  String get premiumTokenSyncedSuccess;

  /// No description provided for @premiumTokenNotFound.
  ///
  /// In en, this message translates to:
  /// **'No premium verification found on Google Drive.'**
  String get premiumTokenNotFound;

  /// No description provided for @premiumTokenDescription.
  ///
  /// In en, this message translates to:
  /// **'This token allows you to use your Premium purchase on Windows and other platforms. Log in with the same Google account to sync your Premium status automatically.'**
  String get premiumTokenDescription;

  /// No description provided for @googleDriveNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Google Drive not connected. Cloud verification will not be available.'**
  String get googleDriveNotConnected;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// No description provided for @updateAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version ({version}) of FlowKarobar is available. Update now to get the latest features and improvements!'**
  String updateAvailableMessage(String version);

  /// No description provided for @whatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s New:'**
  String get whatsNew;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @downloadingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Downloading Update'**
  String get downloadingUpdate;

  /// No description provided for @downloadingPercentage.
  ///
  /// In en, this message translates to:
  /// **'Downloading: {percentage}%'**
  String downloadingPercentage(String percentage);

  /// No description provided for @downloadingProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloadingProgress;

  /// No description provided for @doNotCloseApp.
  ///
  /// In en, this message translates to:
  /// **'Please do not close the application. Once finished, the installer will launch automatically.'**
  String get doNotCloseApp;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update Failed'**
  String get updateFailed;

  /// No description provided for @updateFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while downloading the update:\n\n{error}\n\nPlease check your internet connection and try again.'**
  String updateFailedMessage(String error);

  /// No description provided for @accountStatement.
  ///
  /// In en, this message translates to:
  /// **'Account Statement'**
  String get accountStatement;

  /// No description provided for @startingBalance.
  ///
  /// In en, this message translates to:
  /// **'Starting Balance'**
  String get startingBalance;

  /// No description provided for @endingBalance.
  ///
  /// In en, this message translates to:
  /// **'Ending Balance'**
  String get endingBalance;

  /// No description provided for @totalCredits.
  ///
  /// In en, this message translates to:
  /// **'Total Credits'**
  String get totalCredits;

  /// No description provided for @totalDebits.
  ///
  /// In en, this message translates to:
  /// **'Total Debits'**
  String get totalDebits;

  /// No description provided for @statementPeriod.
  ///
  /// In en, this message translates to:
  /// **'Statement Period'**
  String get statementPeriod;

  /// No description provided for @noStatementEntries.
  ///
  /// In en, this message translates to:
  /// **'No transactions or transfers found for this period.'**
  String get noStatementEntries;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @debit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get debit;

  /// No description provided for @runningBalance.
  ///
  /// In en, this message translates to:
  /// **'Running Balance'**
  String get runningBalance;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @addAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add Attachments'**
  String get addAttachment;

  /// No description provided for @noAttachments.
  ///
  /// In en, this message translates to:
  /// **'No attachments added yet'**
  String get noAttachments;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @storageUsed.
  ///
  /// In en, this message translates to:
  /// **'Storage Used'**
  String get storageUsed;

  /// No description provided for @documentBackup.
  ///
  /// In en, this message translates to:
  /// **'Document Backup'**
  String get documentBackup;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportBackup;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importBackup;

  /// No description provided for @backupExported.
  ///
  /// In en, this message translates to:
  /// **'Backup exported successfully'**
  String get backupExported;

  /// No description provided for @backupImported.
  ///
  /// In en, this message translates to:
  /// **'Backup imported successfully'**
  String get backupImported;

  /// No description provided for @uploadingToCloud.
  ///
  /// In en, this message translates to:
  /// **'Uploading to Cloud...'**
  String get uploadingToCloud;

  /// No description provided for @downloadingFromCloud.
  ///
  /// In en, this message translates to:
  /// **'Downloading from Cloud...'**
  String get downloadingFromCloud;

  /// No description provided for @importingBackup.
  ///
  /// In en, this message translates to:
  /// **'Importing Backup...'**
  String get importingBackup;

  /// No description provided for @uploadingPercentage.
  ///
  /// In en, this message translates to:
  /// **'Uploading: {percentage}%'**
  String uploadingPercentage(String percentage);

  /// No description provided for @exportOptions.
  ///
  /// In en, this message translates to:
  /// **'Export Options'**
  String get exportOptions;

  /// No description provided for @importOptions.
  ///
  /// In en, this message translates to:
  /// **'Import Options'**
  String get importOptions;

  /// No description provided for @localDevice.
  ///
  /// In en, this message translates to:
  /// **'Local Device'**
  String get localDevice;

  /// No description provided for @googleDriveCloud.
  ///
  /// In en, this message translates to:
  /// **'Google Drive (Cloud)'**
  String get googleDriveCloud;

  /// No description provided for @selectExportDestination.
  ///
  /// In en, this message translates to:
  /// **'Select where to export your documents'**
  String get selectExportDestination;

  /// No description provided for @selectImportSource.
  ///
  /// In en, this message translates to:
  /// **'Select where to import your documents'**
  String get selectImportSource;

  /// No description provided for @noCloudBackupFound.
  ///
  /// In en, this message translates to:
  /// **'No cloud backup found'**
  String get noCloudBackupFound;

  /// No description provided for @checkingCloudBackup.
  ///
  /// In en, this message translates to:
  /// **'Checking cloud backup...'**
  String get checkingCloudBackup;

  /// No description provided for @createCloudBackup.
  ///
  /// In en, this message translates to:
  /// **'Create Cloud Backup'**
  String get createCloudBackup;

  /// No description provided for @updateCloudBackup.
  ///
  /// In en, this message translates to:
  /// **'Update Cloud Backup'**
  String get updateCloudBackup;

  /// No description provided for @lastBackedUp.
  ///
  /// In en, this message translates to:
  /// **'Last backed up {time}'**
  String lastBackedUp(String time);

  /// No description provided for @relativeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get relativeJustNow;

  /// No description provided for @relativeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String relativeMinutesAgo(String minutes);

  /// No description provided for @relativeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String relativeHoursAgo(String hours);

  /// No description provided for @relativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String relativeDaysAgo(String days);

  /// No description provided for @documentsAndStorage.
  ///
  /// In en, this message translates to:
  /// **'Documents & Storage'**
  String get documentsAndStorage;

  /// No description provided for @viewAllDocuments.
  ///
  /// In en, this message translates to:
  /// **'View All Documents'**
  String get viewAllDocuments;

  /// No description provided for @deleteAttachmentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this attachment?'**
  String get deleteAttachmentConfirm;

  /// No description provided for @deleteAttachmentEditWarning.
  ///
  /// In en, this message translates to:
  /// **'This attachment will be permanently deleted only when you save the transaction.'**
  String get deleteAttachmentEditWarning;

  /// No description provided for @chooseDocument.
  ///
  /// In en, this message translates to:
  /// **'Choose Documents'**
  String get chooseDocument;

  /// No description provided for @cameraSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your receipt or document'**
  String get cameraSubtitle;

  /// No description provided for @gallerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose images from your gallery'**
  String get gallerySubtitle;

  /// No description provided for @chooseDocumentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select PDF or other document files'**
  String get chooseDocumentSubtitle;

  /// No description provided for @exportAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get exportAsPdf;

  /// No description provided for @exportAsPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate a PDF with transaction details and attachments'**
  String get exportAsPdfSubtitle;

  /// No description provided for @exportPdfWithAttachments.
  ///
  /// In en, this message translates to:
  /// **'PDF with Attachments'**
  String get exportPdfWithAttachments;

  /// No description provided for @exportPdfWithAttachmentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Premium • Beautiful report with attachment images/PDFs'**
  String get exportPdfWithAttachmentsSubtitle;

  /// No description provided for @generatingPdfReport.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF Report...'**
  String get generatingPdfReport;

  /// No description provided for @generatingPdfReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we compile your transactions and attachments'**
  String get generatingPdfReportSubtitle;

  /// No description provided for @transactionsAttachmentReport.
  ///
  /// In en, this message translates to:
  /// **'Transactions Attachment Report'**
  String get transactionsAttachmentReport;

  /// No description provided for @generatedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated on {date}'**
  String generatedOn(Object date);

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageOf(Object current, Object total);

  /// No description provided for @pdfAppendedMessage.
  ///
  /// In en, this message translates to:
  /// **'PDF Document (Appended natively after this card)'**
  String get pdfAppendedMessage;

  /// No description provided for @imageAppendedMessage.
  ///
  /// In en, this message translates to:
  /// **'Image Attachment (Appended on the next page)'**
  String get imageAppendedMessage;

  /// No description provided for @attachmentFile.
  ///
  /// In en, this message translates to:
  /// **'Attachment File'**
  String get attachmentFile;

  /// No description provided for @noTransactionsWithAttachments.
  ///
  /// In en, this message translates to:
  /// **'No transactions with attachments found.'**
  String get noTransactionsWithAttachments;

  /// No description provided for @documentSyncRequired.
  ///
  /// In en, this message translates to:
  /// **'Document backup required'**
  String get documentSyncRequired;

  /// No description provided for @documentSyncRequiredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved or new attachments. Tap to backup now.'**
  String get documentSyncRequiredSubtitle;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textSize;

  /// No description provided for @textSizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust the display size of text across the application'**
  String get textSizeSubtitle;

  /// No description provided for @horizontalSpacing.
  ///
  /// In en, this message translates to:
  /// **'Horizontal Spacing'**
  String get horizontalSpacing;

  /// No description provided for @horizontalSpacingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust the horizontal character spacing of the text'**
  String get horizontalSpacingSubtitle;

  /// No description provided for @verticalSpacing.
  ///
  /// In en, this message translates to:
  /// **'Vertical Spacing'**
  String get verticalSpacing;

  /// No description provided for @verticalSpacingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust the vertical line spacing of the text'**
  String get verticalSpacingSubtitle;

  /// No description provided for @largeLabel.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get largeLabel;

  /// No description provided for @smallLabel.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get smallLabel;

  /// No description provided for @tightLabel.
  ///
  /// In en, this message translates to:
  /// **'Tight'**
  String get tightLabel;

  /// No description provided for @wideLabel.
  ///
  /// In en, this message translates to:
  /// **'Wide'**
  String get wideLabel;

  /// No description provided for @condensedLabel.
  ///
  /// In en, this message translates to:
  /// **'Condensed'**
  String get condensedLabel;

  /// No description provided for @looseLabel.
  ///
  /// In en, this message translates to:
  /// **'Loose'**
  String get looseLabel;

  /// No description provided for @doubleLabel.
  ///
  /// In en, this message translates to:
  /// **'Double'**
  String get doubleLabel;

  /// No description provided for @tripleLabel.
  ///
  /// In en, this message translates to:
  /// **'Triple'**
  String get tripleLabel;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @transactionTags.
  ///
  /// In en, this message translates to:
  /// **'Transaction Tags'**
  String get transactionTags;

  /// No description provided for @suggestedTags.
  ///
  /// In en, this message translates to:
  /// **'Suggested Tags'**
  String get suggestedTags;

  /// No description provided for @addTagHint.
  ///
  /// In en, this message translates to:
  /// **'Add a tag...'**
  String get addTagHint;

  /// No description provided for @noTagsUsedYet.
  ///
  /// In en, this message translates to:
  /// **'No tags used yet.'**
  String get noTagsUsedYet;

  /// No description provided for @filterWithoutTags.
  ///
  /// In en, this message translates to:
  /// **'Without tags'**
  String get filterWithoutTags;

  /// No description provided for @deleteTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Tag'**
  String get deleteTagTitle;

  /// No description provided for @deleteTagConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete the tag \"{tagName}\"? It is not used in any transactions.'**
  String deleteTagConfirm(String tagName);

  /// No description provided for @cannotDeleteTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Cannot Delete Tag'**
  String get cannotDeleteTagTitle;

  /// No description provided for @cannotDeleteTagMessage.
  ///
  /// In en, this message translates to:
  /// **'This tag is currently used in {count} transactions. You must remove it from those transactions first before you can delete it.'**
  String cannotDeleteTagMessage(int count);

  /// No description provided for @tagDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Tag deleted successfully'**
  String get tagDeletedSuccessfully;

  /// No description provided for @removeTagConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this tag from this transaction?'**
  String get removeTagConfirm;

  /// No description provided for @failedToUpdateTags.
  ///
  /// In en, this message translates to:
  /// **'Failed to update tags: {error}'**
  String failedToUpdateTags(String error);

  /// No description provided for @unusedTagIndicator.
  ///
  /// In en, this message translates to:
  /// **'Unused'**
  String get unusedTagIndicator;

  /// No description provided for @createTagQuery.
  ///
  /// In en, this message translates to:
  /// **'Create Tag \"{tagName}\"'**
  String createTagQuery(String tagName);

  /// No description provided for @renameTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Tag'**
  String get renameTagTitle;

  /// No description provided for @tagNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Tag Name'**
  String get tagNameLabel;

  /// No description provided for @tagOptions.
  ///
  /// In en, this message translates to:
  /// **'Tag Options'**
  String get tagOptions;

  /// No description provided for @longPressTagHint.
  ///
  /// In en, this message translates to:
  /// **'Long press any tag to rename or delete'**
  String get longPressTagHint;

  /// No description provided for @tagRenamedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Tag renamed successfully'**
  String get tagRenamedSuccessfully;

  /// No description provided for @todaySales.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sales'**
  String get todaySales;

  /// No description provided for @lowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert'**
  String get lowStockAlert;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
