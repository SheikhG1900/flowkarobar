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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Cashbook'**
  String get appTitle;

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

  /// No description provided for @transactionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated successfully'**
  String get transactionUpdated;

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
  /// **'Mark as Received'**
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
  /// **'Mark as Paid'**
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

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date Format'**
  String get dateFormat;

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

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

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
  /// **'Mark all read'**
  String get markAllRead;

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
  /// **'Flowpaisa Premium'**
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
  /// **'Flowpaisa is a comprehensive personal finance and cash flow manager. Track your expenses, incomes, receivables, and payables all in one place. Features include receipt scanning, WhatsApp integration, cloud backup, and beautiful analytics.'**
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
  /// **'Tap the \'Share\' icon on any transaction or receivable. This generates a unique link. When the recipient clicks the link on their device, Flowpaisa will open and allow them to import that transaction into their own cashbook.'**
  String get guideDeepLinksStep;

  /// No description provided for @guideImportDeepLink.
  ///
  /// In en, this message translates to:
  /// **'How to import a shared transaction?'**
  String get guideImportDeepLink;

  /// No description provided for @guideImportDeepLinkStep.
  ///
  /// In en, this message translates to:
  /// **'When you receive a Flowpaisa link via WhatsApp or message, simply tap it. The app will open a preview screen showing the details. Tap \'Import\' to add it to your records. If it\'s a settlement, it will update your existing pending record.'**
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
  /// **'Greetings!\n\nThe payment of {amount} on {date} has been completed.\n\nSync in Flowpaisa:\n{link}'**
  String sharePayableCompleted(String amount, String date, String link);

  /// No description provided for @sharePayablePending.
  ///
  /// In en, this message translates to:
  /// **'I owe you {amount}\nDate: {date}\n\nView in Flowpaisa:\n{link}'**
  String sharePayablePending(String amount, String date, String link);

  /// No description provided for @shareReceivableReceived.
  ///
  /// In en, this message translates to:
  /// **'Greetings!\n\nThe payment of {amount} on {date} has been received.\n\nSync in Flowpaisa:\n{link}'**
  String shareReceivableReceived(String amount, String date, String link);

  /// No description provided for @shareReceivablePending.
  ///
  /// In en, this message translates to:
  /// **'Amount to receive: {amount}\nDate: {date}\n\nView in Flowpaisa:\n{link}'**
  String shareReceivablePending(String amount, String date, String link);

  /// No description provided for @shareTransactionMessage.
  ///
  /// In en, this message translates to:
  /// **'Recorded a transaction of {amount} on {date}.\n\nView in Flowpaisa:\n{link}'**
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

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get scanReceipt;

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

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @editSchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit Schedule'**
  String get editSchedule;

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

  /// No description provided for @messageTemplatesDescription.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp message templates'**
  String get messageTemplatesDescription;

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

  /// No description provided for @backupToFile.
  ///
  /// In en, this message translates to:
  /// **'Backup to File'**
  String get backupToFile;

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
  /// **'This will permanently delete ALL your Flowpaisa backups and synchronization data from Google Drive. This action cannot be undone.\n\nAre you sure you want to clear all cloud data?'**
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
