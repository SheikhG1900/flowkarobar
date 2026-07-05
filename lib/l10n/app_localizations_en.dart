// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cashbook';

  @override
  String get backgroundActivityStarted => 'Activity started in background';

  @override
  String get backgroundBackupStarted => 'Backup started in background';

  @override
  String get backgroundCloudClearStarted => 'Cloud clear started in background';

  @override
  String get sourceLabel => 'Source';

  @override
  String get targetLabel => 'Target';

  @override
  String cloudBackupsFor(String name) {
    return 'Backups for $name';
  }

  @override
  String get bulkImport => 'Bulk Import';

  @override
  String get pasteFromClipboard => 'Paste from Clipboard';

  @override
  String get pickCsvFile => 'Pick CSV File';

  @override
  String get importSettings => 'Import Settings';

  @override
  String get separator => 'Separator';

  @override
  String get tab => 'Tab';

  @override
  String get comma => 'Comma';

  @override
  String get semicolon => 'Semicolon';

  @override
  String get pipe => 'Pipe';

  @override
  String get dateFormat => 'Date Format';

  @override
  String get hasHeader => 'Has Header';

  @override
  String get columnMapping => 'Column Mapping';

  @override
  String get defaultValues => 'Default Values';

  @override
  String get preview => 'Preview';

  @override
  String get selected => 'Selected';

  @override
  String importedSuccessfully(int count) {
    return 'Imported $count transactions successfully';
  }

  @override
  String get paste => 'Paste';

  @override
  String get import => 'Import';

  @override
  String get cashbooks => 'Cashbooks';

  @override
  String get transactions => 'Transactions';

  @override
  String get settings => 'Settings';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get scheduleCreated => 'Schedule created successfully';

  @override
  String get scheduleDetails => 'Schedule Details';

  @override
  String get frequency => 'Frequency';

  @override
  String get relationship => 'Relationship';

  @override
  String get days => 'Days';

  @override
  String get lastGenerated => 'Last Generated';

  @override
  String get editSchedule => 'Edit Schedule';

  @override
  String get deleteSchedule => 'Delete Schedule';

  @override
  String get deleteScheduleConfirmation =>
      'Are you sure you want to delete this schedule? This will stop all future automatic transactions for this schedule.';

  @override
  String get transactionUpdated => 'Transaction updated successfully';

  @override
  String get markAsReviewed => 'Mark as Reviewed';

  @override
  String get transactionMarkedAsReviewed => 'Transaction marked as reviewed';

  @override
  String get updateTransaction => 'Update Transaction';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get date => 'Date';

  @override
  String get description => 'Description';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get payable => 'Payable';

  @override
  String get syncSchedule => 'Idle sync';

  @override
  String get noIdleSync => 'No Idle Sync';

  @override
  String autoSyncBadge(String interval) {
    return 'Auto: ${interval}h';
  }

  @override
  String createdLabel(String date) {
    return 'Created: $date';
  }

  @override
  String get defaultPremiumPrice => '\$9.99';

  @override
  String errorOccurred(String error) {
    return 'Error: $error';
  }

  @override
  String get noDataForTrends => 'No data for trends';

  @override
  String get cancelled => 'Cancelled';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String daysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String sample(String sample) {
    return 'Sample: $sample';
  }

  @override
  String positiveAmount(String amount) {
    return 'Positive: $amount';
  }

  @override
  String negativeAmount(String amount) {
    return 'Negative: $amount';
  }

  @override
  String themeSet(String name) {
    return 'Theme set to $name';
  }

  @override
  String languageChanged(String name) {
    return 'Language changed to $name';
  }

  @override
  String lastBackupAt(String time) {
    return 'Last Backup: $time';
  }

  @override
  String restoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String errorSaving(String error) {
    return 'Error saving: $error';
  }

  @override
  String errorSharing(String error) {
    return 'Error sharing: $error';
  }

  @override
  String errorExporting(String error) {
    return 'Error exporting: $error';
  }

  @override
  String exportSavedTo(String path) {
    return 'Export saved to $path';
  }

  @override
  String notificationTitlePrefix(String title) {
    return 'Notification: $title';
  }

  @override
  String errorDeletingTransaction(String error) {
    return 'Error deleting transaction: $error';
  }

  @override
  String noTypeCategories(String type) {
    return 'No $type categories';
  }

  @override
  String deleteCashbookMessage(String name) {
    return 'Are you sure you want to delete $name? This will permanently delete all data associated with this cashbook.';
  }

  @override
  String currencySetTo(String name) {
    return 'Currency set to $name';
  }

  @override
  String confirmDelete(String item) {
    return 'Are you sure you want to delete this $item?';
  }

  @override
  String get search => 'Search';

  @override
  String get searchTransactions => 'Search transactions...';

  @override
  String get noTransactions => 'No transactions found';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get all => 'All';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get customRange => 'Custom Range';

  @override
  String get currency => 'Currency';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get hindi => 'Hindi';

  @override
  String get english => 'English';

  @override
  String get urdu => 'Urdu';

  @override
  String get cashbookName => 'Cashbook Name';

  @override
  String get createCashbook => 'Create Cashbook';

  @override
  String get editCashbook => 'Edit Cashbook';

  @override
  String get deleteCashbook => 'Delete Cashbook';

  @override
  String get cashbookDeleted => 'Cashbook deleted successfully';

  @override
  String get cashbookAdded => 'Cashbook added successfully';

  @override
  String get cashbookUpdated => 'Cashbook updated successfully';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get copyPreferences => 'Copy Preferences';

  @override
  String get copyPreferencesFrom => 'Copy Preferences From';

  @override
  String get copyPreferencesSubtitle =>
      'Categories and settings will be copied from the selected cashbook.';

  @override
  String get none => 'None';

  @override
  String get howMuch => 'How much?';

  @override
  String get amountHint => '0.00';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get amountGreaterThanZero => 'Amount must be greater than 0';

  @override
  String get contact => 'Contact';

  @override
  String get selectContact => 'Select Contact';

  @override
  String get addNew => 'Add New';

  @override
  String get descriptionHint => 'e.g., Lunch money';

  @override
  String get premiumFeature => 'Premium Feature';

  @override
  String get premiumRequired => 'This feature requires a premium subscription.';

  @override
  String get getPremium => 'Get Premium';

  @override
  String switchedToCashbook(String name) {
    return 'Switched to $name';
  }

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryBills => 'Bills';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categorySalary => 'Salary';

  @override
  String get categoryBusiness => 'Business';

  @override
  String get categoryInvestment => 'Investment';

  @override
  String get categoryRent => 'Rent';

  @override
  String get categoryOther => 'Other';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get receivables => 'Receivables';

  @override
  String get pending => 'Pending';

  @override
  String get overdue => 'Overdue';

  @override
  String get receivedLabel => 'Received';

  @override
  String get generateDummyReceivables => 'Generate 100 Dummy Receivables';

  @override
  String dummyGenerated(int count) {
    return 'Generated $count dummy items';
  }

  @override
  String get errorLoadingReceivables => 'Error loading receivables';

  @override
  String get retry => 'Retry';

  @override
  String get noPendingReceivables => 'No pending receivables';

  @override
  String get noOverdueReceivables => 'No overdue receivables';

  @override
  String get noReceivedPayments => 'No received payments';

  @override
  String get addReceivableSubtitle =>
      'Add a receivable to track money owed to you';

  @override
  String get receivablesUpToDate => 'All receivables are up to date';

  @override
  String get markReceivedSubtitle => 'Mark pending receivables as received';

  @override
  String get noMoreItems => 'No more items';

  @override
  String get receivableDeleted => 'Receivable deleted';

  @override
  String get unknown => 'Unknown';

  @override
  String dueAt(String date) {
    return 'Due: $date';
  }

  @override
  String get receivable => 'Receivable';

  @override
  String get addReceivable => 'Add Receivable';

  @override
  String get receivableIntentTitle => 'How would you like to record this?';

  @override
  String receivableIntentBoughtForContact(String contact) {
    return 'You paid for something for $contact. They\'ll pay you back.';
  }

  @override
  String receivableIntentServicesAmount(String amount, String contact) {
    return '$contact will pay you $amount for your services.';
  }

  @override
  String get receivableIntentJustRecord => 'Just create a receivable';

  @override
  String get receivableAlreadyImported =>
      'This receivable has already been imported.';

  @override
  String get pleaseSelectContact => 'Please select a contact';

  @override
  String get receivableAdded => 'Receivable added successfully';

  @override
  String get share => 'SHARE';

  @override
  String get dueDateOptional => 'Due Date (Optional)';

  @override
  String get notSet => 'Not set';

  @override
  String get autoCreateIncome => 'Auto-create income';

  @override
  String get autoCreateIncomeSubtitle =>
      'Record as income when marked as received';

  @override
  String get receivableNotFound => 'Receivable not found';

  @override
  String get receivableUpdated => 'Receivable updated successfully';

  @override
  String get editReceivable => 'Edit Receivable';

  @override
  String get receivableDetails => 'Receivable Details';

  @override
  String get edit => 'Edit';

  @override
  String get receivablePending => 'Receivable (Pending)';

  @override
  String get dueDate => 'Due Date';

  @override
  String get linkedTransaction => 'Linked Transaction';

  @override
  String get markAsReceived => 'Receive';

  @override
  String get deleteReceivableTitle => 'Delete Receivable';

  @override
  String get deleteReceivableMessage =>
      'Are you sure you want to delete this receivable? This action cannot be undone.';

  @override
  String get markedAsReceived => 'Marked as received';

  @override
  String get informContactSettlement =>
      'Receivable marked as received. Inform the contact?';

  @override
  String addContactWithName(String name) {
    return 'Add $name';
  }

  @override
  String get payables => 'Payables';

  @override
  String get generateDummyPayables => 'Generate 100 Dummy Payables';

  @override
  String get dummyPayablesGenerated => 'Generated 100 dummy payables';

  @override
  String get errorLoadingPayables => 'Error loading payables';

  @override
  String get noPendingPayables => 'No pending payables';

  @override
  String get noOverduePayables => 'No overdue payables';

  @override
  String get noPaidBills => 'No paid bills';

  @override
  String get addPayableSubtitle => 'Add a payable to track money you owe';

  @override
  String get allPayablesUpToDate => 'All payables are up to date';

  @override
  String get markPendingAsPaidSubtitle => 'Mark pending payables as paid';

  @override
  String get noMorePayables => 'No more payables';

  @override
  String get payableDeleted => 'Payable deleted';

  @override
  String get payableAlreadyImported =>
      'This payable has already been imported.';

  @override
  String get payableAdded => 'Payable added successfully';

  @override
  String get addPayable => 'Add Payable';

  @override
  String get payableIntentTitle => 'How would you like to record this?';

  @override
  String payableIntentContactBoughtForYou(String contact) {
    return '$contact paid for something on your behalf.';
  }

  @override
  String payableIntentBorrowedFrom(String amount, String contact) {
    return 'You borrowed $amount from $contact.';
  }

  @override
  String get payableIntentJustRecord => 'Just create a payable';

  @override
  String get editPayable => 'Edit Payable';

  @override
  String get payableNotFound => 'Payable not found';

  @override
  String get payableDataNotLoaded => 'Payable data not loaded';

  @override
  String get payableUpdated => 'Payable updated successfully';

  @override
  String get updatePayable => 'Update Payable';

  @override
  String get payableDetails => 'Payable Details';

  @override
  String get payablePending => 'Payable (Pending)';

  @override
  String get paid => 'Paid';

  @override
  String get markAsPaid => 'Pay';

  @override
  String get deletePayableTitle => 'Delete Payable';

  @override
  String get deletePayableMessage =>
      'Are you sure you want to delete this payable? This action cannot be undone.';

  @override
  String get markedAsPaid => 'Marked as paid';

  @override
  String get informContactSettlementPayable =>
      'Payable marked as paid. Inform the contact?';

  @override
  String get autoCreateExpense => 'Auto-create expense';

  @override
  String get autoCreateExpenseSubtitle =>
      'Record as expense when marked as paid';

  @override
  String get appRefreshLanguage =>
      'The app will refresh to apply the new language';

  @override
  String get connectGoogleDrive => 'Connect Google Drive';

  @override
  String get cloudBackupAccount => 'Cloud Backup Account';

  @override
  String get autofillFromGoogle => 'Autofill from Google';

  @override
  String get profile => 'Profile';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get photoUploadComingSoon => 'Photo upload coming soon!';

  @override
  String get name => 'Name';

  @override
  String get enterName => 'Enter your name';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterValidEmail => 'Please enter a valid email';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get address => 'Address';

  @override
  String get enterAddress => 'Enter your address';

  @override
  String get preferences => 'Preferences';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get selectDateFormat => 'Select Date Format';

  @override
  String get customFormat => 'Custom Format';

  @override
  String get enterCustomDateFormat => 'Enter your own date format pattern';

  @override
  String get customDateFormat => 'Custom Date Format';

  @override
  String get formatPattern => 'Format Pattern';

  @override
  String get dateFormatInstructions =>
      'Use standard ICU patterns like:\ndd: Day, MM: Month, yyyy: Year\nMMM: Short Month, EEEE: Full Day';

  @override
  String get lightThemeDescription => 'Always use light theme';

  @override
  String get darkThemeDescription => 'Always use dark theme';

  @override
  String get systemThemeDescription => 'Follow device settings';

  @override
  String get themeChangesApplyImmediately => 'Theme changes apply immediately';

  @override
  String get analytics => 'Analytics';

  @override
  String get exportAnalyticsPDF => 'Export Analytics PDF';

  @override
  String get refreshAnalytics => 'Refresh Analytics';

  @override
  String get financialSummary => 'Financial Summary';

  @override
  String get contactSummaries => 'Contact Summaries';

  @override
  String get expensesByCategory => 'Expenses by Category';

  @override
  String get incomeVsExpenseTrend => 'Income vs Expense Trend';

  @override
  String get payablesVsReceivablesTrend => 'Payables vs Receivables Trend';

  @override
  String get topContactsByBalance => 'Top Contacts by Balance';

  @override
  String get paymentStatusDistribution => 'Payment Status Distribution';

  @override
  String get incomeByCategory => 'Income by Category';

  @override
  String get unlockAdvancedAnalytics =>
      'Unlock advanced analytics, trends, and charts with Premium.';

  @override
  String get unlockPremium => 'Unlock Premium';

  @override
  String get noContactActivity => 'No contact activity for this period';

  @override
  String get settled => 'Settled';

  @override
  String get noExpensesPeriod => 'No expenses for this period';

  @override
  String get noDataTrends => 'No data for trends';

  @override
  String get noPayableReceivableData => 'No payable/receivable data';

  @override
  String get noContactData => 'No contact data';

  @override
  String get noPaymentStatusData => 'No payment status data';

  @override
  String get noIncome => 'No income for this period';

  @override
  String get pdfReady => 'PDF Ready';

  @override
  String get backupReady => 'Backup Ready';

  @override
  String get backupReadyMessage =>
      'Your database backup is ready. Choose an action:';

  @override
  String get analyticsPDFReadyMessage =>
      'Your analytics PDF report is ready. Choose an action:';

  @override
  String get saveCopy => 'Save Copy';

  @override
  String get savedToDownloads => 'Saved to Downloads';

  @override
  String get month => 'Month';

  @override
  String get quarter => 'Quarter';

  @override
  String get year => 'Year';

  @override
  String get custom => 'Custom';

  @override
  String get payableShort => 'P:';

  @override
  String get receivableShort => 'R:';

  @override
  String get netBalance => 'Net Balance';

  @override
  String get balanceReceivableMinusPayable => 'Balance (Receivable − Payable)';

  @override
  String get netReceivable => 'Net Receivable';

  @override
  String get netPayable => 'Net Payable';

  @override
  String get allTime => 'All-time:';

  @override
  String get expenses => 'Expenses';

  @override
  String get noExpenses => 'No expenses for this period';

  @override
  String get expanded => 'expanded';

  @override
  String get collapsed => 'collapsed';

  @override
  String get notifications => 'Notifications';

  @override
  String get allNotificationsMarkedRead => 'All notifications marked as read';

  @override
  String get markAllRead => 'All Read';

  @override
  String get clearAll => 'Clear All';

  @override
  String get clearAllItemsConfirmation =>
      'Are you sure you want to clear all items?';

  @override
  String get clearAllNotifications => 'Clear all notifications?';

  @override
  String get clearAllNotificationsMessage =>
      'Are you sure you want to delete all notifications? This action cannot be undone.';

  @override
  String get notificationsCleared => 'All notifications cleared';

  @override
  String get noNotifications => 'No Notifications';

  @override
  String get noNotificationsDescription =>
      'You\'re all caught up! We\'ll notify you about:\n\n• Due receivables and payables\n• Transaction milestones\n• Backup reminders\n• Important updates';

  @override
  String get notificationsTip =>
      'Tip: Set due dates for receivables and payables to get timely reminders';

  @override
  String get justNow => 'Just now';

  @override
  String get toggledDebugMode => 'Toggled Debug Mode';

  @override
  String get debugToggleMode => 'DEBUG: Toggle Mode';

  @override
  String get premiumTitle => 'Flowpaisa Premium';

  @override
  String get unlockAllFeatures => 'Unlock all features';

  @override
  String get premiumMemberStatus => 'You are a Premium Member';

  @override
  String get premiumFeaturesActive => 'All premium features are active';

  @override
  String get featureCloudBackupTitle => 'Automatic Cloud Backup';

  @override
  String get featureCloudBackupDesc =>
      'Your data is automatically backed up to Google Drive. Never lose your financial records.';

  @override
  String get featureAnalyticsTitle => 'Advanced Analytics';

  @override
  String get featureAnalyticsDesc =>
      'Get detailed insights with advanced charts, trends, and financial forecasting.';

  @override
  String get featurePdfReportsTitle => 'PDF Reports';

  @override
  String get featurePdfReportsDesc =>
      'Generate beautiful PDF reports with charts and summaries for any date range.';

  @override
  String get featureUnlimitedTitle => 'Unlimited Transactions';

  @override
  String get featureUnlimitedDesc =>
      'No limits on the number of transactions, contacts, or categories you can create.';

  @override
  String get featureSupportTitle => 'Priority Support';

  @override
  String get featureSupportDesc =>
      'Get faster responses and dedicated support for any issues or questions.';

  @override
  String get featureEarlyAccessTitle => 'Early Access';

  @override
  String get featureEarlyAccessDesc =>
      'Be the first to try new features before they\'re released to everyone.';

  @override
  String get featureTemplatesTitle => 'Custom Message Templates';

  @override
  String get featureTemplatesDesc =>
      'Customize WhatsApp message templates for reminders, receipts, and sharing in multiple languages.';

  @override
  String get featureMultiDeviceSyncTitle => 'Multi-Device Sync';

  @override
  String get featureMultiDeviceSyncDesc =>
      'Sync your data across all your devices using Google Drive. Your records are always up to date.';

  @override
  String get featureMultipleCashbooksTitle => 'Unlimited Cashbooks';

  @override
  String get featureMultipleCashbooksDesc =>
      'Create and manage as many additional cashbooks as you need for different businesses or personal use.';

  @override
  String get featureUnlimitedSchedulesTitle => 'Unlimited Schedules';

  @override
  String get featureUnlimitedSchedulesDesc =>
      'Set up unlimited recurring transaction schedules for your regular incomes and expenses.';

  @override
  String get featureUnlimitedVoiceExtractionTitle =>
      'Unlimited Voice Smart Extraction';

  @override
  String get featureUnlimitedVoiceExtractionDesc =>
      'Use smart extraction for voice commands without monthly limits. Add transactions by speaking in natural language.';

  @override
  String get featureUnlimitedReceiptExtractionTitle =>
      'Unlimited Receipt Smart Extraction';

  @override
  String get featureUnlimitedReceiptExtractionDesc =>
      'Use smart extraction for receipt scanning without monthly limits. Extract amount, merchant, and category from receipts automatically.';

  @override
  String get featureBulkImportTitle => 'Bulk Import';

  @override
  String get featureBulkImportDesc =>
      'Import hundreds of transactions instantly from CSV files or your clipboard (Google Sheets).';

  @override
  String get featureBulkSettlementTitle =>
      'Bulk Settlement (Receivables & Payables)';

  @override
  String get featureBulkSettlementDesc =>
      'Settle multiple receivables or payables in one go. Mark many entries as paid or received at once.';

  @override
  String get premiumPlan => 'Premium Plan';

  @override
  String get lifetime => 'Lifetime';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get bestValue => 'Best Value';

  @override
  String get chooseYourPlan => 'Choose Your Plan';

  @override
  String get cancelAnytime => 'Cancel anytime';

  @override
  String savePercentage(Object percentage) {
    return 'Save $percentage%';
  }

  @override
  String get oneTimePayment => 'Pay once, own forever';

  @override
  String get recommended => 'Recommended';

  @override
  String get subscribeNow => 'Subscribe Now';

  @override
  String get oneTimePaymentLifetime => 'One-time payment • Lifetime access';

  @override
  String get processing => 'Processing...';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get premiumBenefitsNote =>
      'Unlock all premium features with your chosen plan. Choose Lifetime for permanent access!';

  @override
  String get active => 'Active';

  @override
  String get freeTrial => 'Free Trial';

  @override
  String get noPurchasesFound => 'No purchases found to restore.';

  @override
  String daysFreeTrial(int days) {
    return '$days days free trial';
  }

  @override
  String monthFreeTrial(int months) {
    return '$months month free trial';
  }

  @override
  String get googleDriveBackup => 'Google Drive Backup';

  @override
  String get cloudBackupPremiumDesc =>
      'Cloud backup to Google Drive is available for Premium users.';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signInGoogleToBackup => 'Sign in with Google to backup your data';

  @override
  String get signInGoogle => 'Sign in with Google';

  @override
  String get googleServicesNote =>
      'Note: Backup requires valid Google Services configuration. If sign-in fails, check your setup.';

  @override
  String get backupNow => 'Backup Now';

  @override
  String get noBackupsFound => 'No backups found';

  @override
  String get availableBackups => 'Available Backups';

  @override
  String get restoreBackupTitle => 'Restore Backup?';

  @override
  String get restoreBackupMessage =>
      'This will overwrite your current data with the selected backup. \n\n⚠️ The app will need to be restarted after restoration.';

  @override
  String get restore => 'Restore';

  @override
  String get restoreSuccessful => 'Restore Successful';

  @override
  String get restoreSuccessfulMessage =>
      'Data restored successfully. Please close and restart the app to apply changes.';

  @override
  String get ok => 'OK';

  @override
  String get categories => 'Categories';

  @override
  String get categoryHiddenSuccessfully => 'Category hidden successfully';

  @override
  String get categoryDeletedSuccessfully => 'Category deleted successfully';

  @override
  String get defaultLabel => 'Default';

  @override
  String get addCategory => 'Add Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get suggestedIcons => 'Suggested Icons';

  @override
  String get color => 'Color';

  @override
  String get allIcons => 'All Icons';

  @override
  String get saveCategory => 'Save Category';

  @override
  String get categoryAddedSuccessfully => 'Category added successfully';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get categoryUpdatedSuccessfully => 'Category updated successfully';

  @override
  String get failedToUpdateCategory => 'Failed to update category';

  @override
  String get expenseCategory => 'Expense Category';

  @override
  String get incomeCategory => 'Income Category';

  @override
  String get updateCategory => 'Update Category';

  @override
  String get searchContacts => 'Search contacts...';

  @override
  String get contacts => 'Contacts';

  @override
  String get noContactsYet => 'No contacts yet';

  @override
  String get noContactsFound => 'No contacts found';

  @override
  String get addPeopleToTrack => 'Add people to track expenses with';

  @override
  String get trySearchingDifferentName => 'Try searching for a different name';

  @override
  String get addContact => 'Add Contact';

  @override
  String get contactDeletedSuccessfully => 'Contact deleted successfully';

  @override
  String get contactPermissionDenied =>
      'Contact permission denied. Please enable it in settings.';

  @override
  String errorPickingContact(String error) {
    return 'Error picking contact: $error';
  }

  @override
  String get selectPhoneNumber => 'Select Phone Number';

  @override
  String get contactUpdatedSuccessfully => 'Contact updated successfully';

  @override
  String get contactAddedSuccessfully => 'Contact added successfully';

  @override
  String get editContact => 'Edit Contact';

  @override
  String get importFromContacts => 'Import from Contacts';

  @override
  String get phoneNumberOptional => 'Phone Number (Optional)';

  @override
  String get emailOptional => 'Email (Optional)';

  @override
  String get addressNotesOptional => 'Address / Notes (Optional)';

  @override
  String get updateContact => 'Update Contact';

  @override
  String get saveContact => 'Save Contact';

  @override
  String get myCashbooks => 'My Cashbooks';

  @override
  String get manageCashbooks => 'Manage multiple cashbooks';

  @override
  String get manageContacts => 'Manage your contacts';

  @override
  String get manageCategories => 'Manage expense & income categories';

  @override
  String get manageCurrencies => 'Manage currencies';

  @override
  String get googleDriveBackupRestore => 'Google Drive Backup & Restore';

  @override
  String get messageTemplates => 'Message Templates';

  @override
  String get customizeMessageTemplates =>
      'Customize WhatsApp message templates';

  @override
  String get exportData => 'Export Data';

  @override
  String get downloadDataCsvPdf => 'Download your data as CSV or PDF';

  @override
  String get premiumActive => 'Premium Active';

  @override
  String get about => 'About';

  @override
  String get rateUs => 'Rate Flowpaisa';

  @override
  String get tagline => 'Track every paisa';

  @override
  String versionInfo(String version, String buildNumber) {
    return 'Version $version (Build $buildNumber)';
  }

  @override
  String get appDescription =>
      'Flowpaisa is a comprehensive personal finance and cash flow manager. Track your expenses, incomes, receivables, and payables all in one place. Features include receipt scanning, WhatsApp integration, cloud backup, and beautiful analytics.';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get developedBy => 'Developed by';

  @override
  String get developerName => 'TamataSoft';

  @override
  String get userGuide => 'User Guide';

  @override
  String get guideGettingStarted => 'Getting Started';

  @override
  String get guideGettingStartedDesc =>
      'Learn how to add transactions and manage your cashbooks.';

  @override
  String get guideManagingMoney => 'Managing Money';

  @override
  String get guideManagingMoneyDesc =>
      'Track your income, expenses, receivables, and payables.';

  @override
  String get guideRelationships => 'Relationships & Linked Transactions';

  @override
  String get guideRelationshipsDesc =>
      'Understand how to link transactions with contacts and track loans.';

  @override
  String get guideSharing => 'Sharing & Deep Links';

  @override
  String get guideSharingDesc =>
      'Share transactions and sync data across devices using deep links.';

  @override
  String get guideAdvancedFeatures => 'Advanced Features';

  @override
  String get guideAdvancedFeaturesDesc =>
      'Use receipt scanning, split bills, and cloud backup.';

  @override
  String get guideCustomization => 'Customization';

  @override
  String get guideCustomizationDesc =>
      'Personalize categories, currencies, themes, and languages.';

  @override
  String get guideAddTransaction => 'How to add a transaction?';

  @override
  String get guideAddTransactionStep =>
      'Tap the \'+\' button on the dashboard or transactions screen, enter the amount, select a category, and save.';

  @override
  String get guideSwitchCashbook => 'How to switch cashbooks?';

  @override
  String get guideSwitchCashbookStep =>
      'Tap the cashbook name on the dashboard header to open the cashbook manager and select another one.';

  @override
  String get guideTrackReceivables => 'Tracking Receivables';

  @override
  String get guideTrackReceivablesStep =>
      'Use the \'Receivables\' section to track money people owe you. You can mark them as received to automatically create income.';

  @override
  String get guideTrackPayablesStep =>
      'Use the \'Payables\' section to track money you owe to others. You can mark them as paid to automatically create expense.';

  @override
  String get guideLinkedTransactions => 'What are Linked Transactions?';

  @override
  String get guideLinkedTransactionsStep =>
      'Linked transactions connect an expense to a receivable or an income to a payable.\n\nExample: You paid \$50 for a friend\'s lunch. You record an Expense of \$50 and link it as \'Paid FOR\' that friend. This automatically creates a \$50 Receivable for that contact.';

  @override
  String get guideSplitBill => 'How to use Split Bill?';

  @override
  String get guideSplitBillStep =>
      'When adding an expense, tap \'Split Bill\'. You can divide the total amount among multiple contacts equally or by percentage. The app will create individual receivables for each person\'s share.';

  @override
  String get guideDeepLinks => 'Sharing via Deep Links';

  @override
  String get guideDeepLinksStep =>
      'Tap the \'Share\' icon on any transaction or receivable. This generates a unique link. When the recipient clicks the link on their device, Flowpaisa will open and allow them to import that transaction into their own cashbook.';

  @override
  String get guideImportDeepLink => 'How to import a shared transaction?';

  @override
  String get guideImportDeepLinkStep =>
      'When you receive a Flowpaisa link via WhatsApp or message, simply tap it. The app will open a preview screen showing the details. Tap \'Import\' to add it to your records. If it\'s a settlement, it will update your existing pending record.';

  @override
  String get guideSyncDevices => 'How to share cashbook to another device?';

  @override
  String get guideSyncDevicesStep =>
      '1. Enable \'Google Drive Backup\' in Settings on your first device.\n2. On the second device, sign in with the SAME Google account.\n3. Go to Backup settings and tap \'Restore\' to download your cashbook data. Use \'Sync Now\' for ongoing real-time updates.';

  @override
  String get guideCloudBackup => 'Cloud Backup & Sync';

  @override
  String get guideCloudBackupStep =>
      'Enable Google Drive backup in Settings to keep your data safe and sync across multiple devices.';

  @override
  String get guideScanReceipt => 'Receipt Scanning';

  @override
  String get guideScanReceiptStep =>
      'Use the \'Scan\' action on the dashboard to automatically extract amount and merchant from your paper receipts.';

  @override
  String get copyright => '© 2026 TamataSoft. All rights reserved.';

  @override
  String get receiptScan => 'Receipt Scan';

  @override
  String get cloudBackup => 'Cloud Backup';

  @override
  String get multilingual => 'Multilingual';

  @override
  String get privacyHighlight => 'Private & Secure';

  @override
  String get privacyHighlightDesc =>
      'Your financial data stays on your device or in your private cloud. No one else can access it.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyDesc =>
      'We value your privacy. Your data is stored locally on your device and can be optionally synced with your private Google Drive. We do not have access to your financial records.';

  @override
  String get availableCash => 'Available Cash';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get add => 'Add';

  @override
  String get bulkImportLoadingContent => 'Loading data…';

  @override
  String bulkImportProgress(int percent, int current, int total) {
    return '$percent% ($current / $total)';
  }

  @override
  String bulkImportPreviewLimited(int shown, int total) {
    return 'Preview shows first $shown of $total rows';
  }

  @override
  String bulkImportPreviewShowingFirst(int shown, int total) {
    return 'Previewing first $shown of $total rows';
  }

  @override
  String get bulkImportPreviewShowAll => 'Show all';

  @override
  String get bulkImportPreviewShowLess => 'Show less';

  @override
  String bulkImportPreviewShowingAllRows(int total) {
    return 'Showing all $total rows';
  }

  @override
  String get bulkImportLinkColumn => 'Receivable / Payable';

  @override
  String get bulkImportDefaultLink => 'Default receivable / payable';

  @override
  String get bulkImportUpdatingPreview => 'Updating preview…';

  @override
  String get scanReceipt => 'Scan Receipt';

  @override
  String get voiceAdd => 'Voice Add';

  @override
  String get scan => 'Scan';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get viewAll => 'View All';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get tapToAddFirst => 'Tap + to add your first transaction';

  @override
  String get cashFlow => 'Cash Flow';

  @override
  String get netCash => 'Net Cash';

  @override
  String get lendingCredit => 'Lending & Credit';

  @override
  String get netCredit => 'Net Credit';

  @override
  String get receive => 'Receive';

  @override
  String get appTour => 'App Tour';

  @override
  String get resetOnboardingSubtitle => 'Reset the app tour to see it again';

  @override
  String get resetOnboardingConfirmation =>
      'Are you sure you want to reset the app tour? You will see the onboarding screens again on next restart.';

  @override
  String get onboardingResetSuccess => 'App tour reset successfully';

  @override
  String get tourWelcome => 'Welcome to Cashbook!';

  @override
  String get tourWelcomeDesc =>
      'Let\'s take a quick tour to help you get started';

  @override
  String get tourDashboardHeaderTitle => 'Cashbook Selector';

  @override
  String get tourDashboardHeaderDesc =>
      'Tap here to switch between your cashbooks or create a new one';

  @override
  String get tourBalanceTitle => 'Available Cash';

  @override
  String get tourBalanceDesc =>
      'Your total available cash balance is displayed here. This updates automatically as you add transactions';

  @override
  String get tourCashFlowTitle => 'Cash Flow';

  @override
  String get tourCashFlowDesc =>
      'View your income, expenses, and net cash flow. Tap any card to filter transactions';

  @override
  String get tourLendingTitle => 'Lending & Credit';

  @override
  String get tourLendingDesc =>
      'Track money people owe you (Receivables) and money you owe (Payables). Tap to view details';

  @override
  String get tourQuickActionsTitle => 'Quick Actions';

  @override
  String get tourQuickActionsDesc =>
      'Quick access to add transactions, scan receipts, manage receivables/payables, view analytics, and more';

  @override
  String get tourRecentTransactionsTitle => 'Recent Transactions';

  @override
  String get tourRecentTransactionsDesc =>
      'View your most recent transactions here. Tap any transaction to see full details';

  @override
  String get tourBottomNavTitle => 'Navigation';

  @override
  String get tourBottomNavDesc =>
      'Switch between Dashboard, Transactions, Analytics, and Settings using the bottom navigation';

  @override
  String get tourNext => 'Next';

  @override
  String get tourSkip => 'Skip';

  @override
  String get tourStartTour => 'Start Tour';

  @override
  String get tourCompleted => 'Tour completed';

  @override
  String get tourGotIt => 'Got it!';

  @override
  String get tourTransactionsSearchTitle => 'Search Transactions';

  @override
  String get tourTransactionsSearchDesc =>
      'Quickly find any transaction by description or amount.';

  @override
  String get tourTransactionsFilterTitle => 'Advanced Filters';

  @override
  String get tourTransactionsFilterDesc =>
      'Filter by date range, category, or contact to get specific insights.';

  @override
  String get tourTransactionsListTitle => 'Transaction History';

  @override
  String get tourTransactionsListDesc =>
      'Your transactions are grouped by date. Swipe left or right on any item to edit or delete it.';

  @override
  String get tourTransactionsFabTitle => 'Add New';

  @override
  String get tourTransactionsFabDesc =>
      'Tap here to record a new income or expense transaction.';

  @override
  String get tourAnalyticsDateRangeTitle => 'Date Range Selector';

  @override
  String get tourAnalyticsDateRangeDesc =>
      'Switch between monthly, quarterly, yearly, or custom date ranges to analyze your data.';

  @override
  String get tourAnalyticsExportPdfTitle => 'Export PDF Report';

  @override
  String get tourAnalyticsExportPdfDesc =>
      'Generate and share professional PDF reports of your financial analytics.';

  @override
  String get tourAnalyticsFinancialSummaryTitle => 'Financial Summary';

  @override
  String get tourAnalyticsFinancialSummaryDesc =>
      'Get a quick overview of your total payables, receivables, income, and expenses for the selected period.';

  @override
  String get tourAnalyticsChartsTitle => 'Visual Insights';

  @override
  String get tourAnalyticsChartsDesc =>
      'Understand your spending habits and trends through interactive charts and category breakdowns.';

  @override
  String get tourSettingsProfileTitle => 'User Profile';

  @override
  String get tourSettingsProfileDesc =>
      'Manage your personal information, profile picture, and account details.';

  @override
  String get tourSettingsAppPreferencesTitle => 'App Preferences';

  @override
  String get tourSettingsAppPreferencesDesc =>
      'Customize the app experience by changing language, font, and theme (dark/light mode).';

  @override
  String get tourSettingsBackupTitle => 'Data Security';

  @override
  String get tourSettingsBackupDesc =>
      'Keep your data safe by setting up Google Drive backup and restore.';

  @override
  String get tourSettingsPremiumTitle => 'Premium Features';

  @override
  String get tourSettingsPremiumDesc =>
      'Unlock advanced analytics, custom message templates, and more with Flowpaisa Premium.';

  @override
  String get tourAddTxAmountTitle => 'Enter Amount';

  @override
  String get tourAddTxAmountDesc =>
      'Type the transaction amount here. Use the calculator if needed.';

  @override
  String get tourAddTxCategoryTitle => 'Select Category';

  @override
  String get tourAddTxCategoryDesc =>
      'Categorize your transaction to get better insights in Analytics.';

  @override
  String get tourAddTxContactTitle => 'Link Contact';

  @override
  String get tourAddTxContactDesc =>
      'Optional: Link this transaction to a contact for tracking receivables or payables.';

  @override
  String get tourAddTxDateTitle => 'Transaction Date';

  @override
  String get tourAddTxDateDesc =>
      'You can record transactions for today or any past/future date.';

  @override
  String get tourAddTxSaveTitle => 'Save Transaction';

  @override
  String get tourAddTxSaveDesc =>
      'Tap here to save your transaction. You can also share it via WhatsApp immediately.';

  @override
  String get tourBackupAuthTitle => 'Google Sign-in';

  @override
  String get tourBackupAuthDesc =>
      'Sign in with your Google account to enable cloud backup and sync across devices.';

  @override
  String get tourBackupSyncTitle => 'Synchronization';

  @override
  String get tourBackupSyncDesc =>
      'Keep your data in sync automatically. You can see your local and cloud versions here.';

  @override
  String get tourBackupNowTitle => 'Manual Backup';

  @override
  String get tourBackupNowDesc =>
      'Create a full backup of your data to Google Drive anytime.';

  @override
  String get tourReceivablesListTitle => 'Receivables List';

  @override
  String get tourReceivablesListDesc =>
      'View all money people owe you. Tap to manage.';

  @override
  String get tourPayablesListTitle => 'Payables List';

  @override
  String get tourPayablesListDesc => 'View all money you owe. Tap to manage.';

  @override
  String get tourShowMeHow => 'Let\'s try';

  @override
  String get messageTemplatesDesc =>
      'Customize message templates is available for Premium users.';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get receivableReminders => 'Receivable Reminders';

  @override
  String get pendingReceivable => 'Pending Receivable';

  @override
  String get receivedPayment => 'Received Payment';

  @override
  String get payableReminders => 'Payable Reminders';

  @override
  String get pendingPayable => 'Pending Payable';

  @override
  String get paidPayable => 'Paid Payable';

  @override
  String get transactionMessages => 'Transaction Messages';

  @override
  String get transactionReceipt => 'Transaction Receipt';

  @override
  String get transactionSharePaidFor => 'Transaction Share - Paid For';

  @override
  String get transactionSharePaidBy => 'Transaction Share - Paid By';

  @override
  String get transactionShareWillReceive => 'Transaction Share - Will Receive';

  @override
  String get transactionShareReceivedFrom =>
      'Transaction Share - Received From';

  @override
  String get transactionShareGeneric => 'Transaction Share - Generic';

  @override
  String get shareMessages => 'Share Messages';

  @override
  String get receivableSharePending => 'Receivable Share - Pending';

  @override
  String get receivableShareReceived => 'Receivable Share - Received';

  @override
  String get payableSharePending => 'Payable Share - Pending';

  @override
  String get payableSharePaid => 'Payable Share - Paid';

  @override
  String get resetToDefault => 'Reset to default';

  @override
  String get resetTemplateTitle => 'Reset Template';

  @override
  String get resetTemplateMessage =>
      'Are you sure you want to reset this template to the default? This cannot be undone.';

  @override
  String get templateSaved => 'Template saved successfully';

  @override
  String get templateReset => 'Template reset to default';

  @override
  String get enterTemplateText => 'Enter template text...';

  @override
  String useVariableHint(Object variableName) {
    return 'Use $variableName for dynamic content';
  }

  @override
  String get saveTemplate => 'Save Template';

  @override
  String get availableVariables => 'Available Variables';

  @override
  String get variablesInstructions =>
      'You can use these variables in your templates:';

  @override
  String variableContactName(Object contactName) {
    return '• $contactName - Contact\'s name';
  }

  @override
  String variableAmount(Object amount) {
    return '• $amount - Formatted amount with currency';
  }

  @override
  String variableDescription(Object description) {
    return '• $description - Transaction/receivable/payable description';
  }

  @override
  String variableDate(Object date) {
    return '• $date - Formatted date';
  }

  @override
  String variableDueDate(Object dueDate) {
    return '• $dueDate - Formatted due date';
  }

  @override
  String variableCategoryName(Object categoryName) {
    return '• $categoryName - Category name';
  }

  @override
  String variableLink(Object link) {
    return '• $link - Deep link URL';
  }

  @override
  String variableType(Object type) {
    return '• $type - Transaction type (Income/Expense)';
  }

  @override
  String variableStatus(Object status) {
    return '• $status - Status text';
  }

  @override
  String variableRelationship(Object relationship) {
    return '• $relationship - Relationship text';
  }

  @override
  String get noCurrencies => 'No currencies';

  @override
  String get currencyDeleted => 'Currency deleted successfully';

  @override
  String get addCurrency => 'Add Currency';

  @override
  String get currencyNameLabel => 'Currency Name';

  @override
  String get currencyNameHint => 'e.g., Euro, British Pound';

  @override
  String get pleaseEnterCurrencyName => 'Please enter currency name';

  @override
  String get currencySymbolLabel => 'Currency Symbol';

  @override
  String get currencySymbolHint => 'e.g., €, £, ¥';

  @override
  String get currencySymbolHelper => 'You can use emoji, letters, or symbols';

  @override
  String get pleaseEnterCurrencySymbol => 'Please enter currency symbol';

  @override
  String get symbolLengthError => 'Symbol must be 10 characters or less';

  @override
  String get currencyCodeLabel => 'Currency Code';

  @override
  String get currencyCodeHint => 'e.g., EUR, GBP, JPY';

  @override
  String get currencyCodeHelper => 'ISO 4217 code (3 letters)';

  @override
  String get pleaseEnterCurrencyCode => 'Please enter currency code';

  @override
  String get codeLengthError => 'Code must be exactly 3 characters';

  @override
  String get decimalPlacesLabel => 'Decimal Places';

  @override
  String get decimalPlacesHelper => 'Number of digits after decimal point';

  @override
  String get noDecimals => '0 (No decimals)';

  @override
  String get oneDecimal => '1 decimal place';

  @override
  String get twoDecimals => '2 decimal places';

  @override
  String get saveCurrency => 'Save Currency';

  @override
  String get currencyAdded => 'Currency added successfully';

  @override
  String get editCurrency => 'Edit Currency';

  @override
  String get updateCurrency => 'Update Currency';

  @override
  String get currencyUpdated => 'Currency updated successfully';

  @override
  String get selectDateRange => 'Select date range';

  @override
  String get exportSuccessful => 'Export Successful';

  @override
  String get transactionHistoryReady =>
      'Your transaction history is ready to share.';

  @override
  String get done => 'Done';

  @override
  String get pdfReportReady => 'Your PDF report is ready. Choose an action:';

  @override
  String get testPdfReady => 'Test PDF Ready';

  @override
  String get testPdfCategoriesReady =>
      'Test PDF with all categories is ready. Choose an action:';

  @override
  String get exportYourData => 'Export Your Data';

  @override
  String get downloadHistoryCsvPdf =>
      'Download your transaction history as CSV or PDF';

  @override
  String get simpleExtractionResults => 'Simple Extraction Results';

  @override
  String smartExtractionQuotaLeft(Object remaining, Object total) {
    return '$remaining of $total left this month';
  }

  @override
  String get smartExtractionUnlimited => 'Unlimited';

  @override
  String get useSmartExtractionForBetterResults =>
      'For better results use Smart extraction.';

  @override
  String get getIt => 'Get it';

  @override
  String get amountCalculatorTitle => 'Calculate amount';

  @override
  String get amountCalculatorUndo => 'Undo';

  @override
  String get amountCalculatorMultiply => 'Multiply';

  @override
  String get amountCalculatorDivide => 'Divide';

  @override
  String get amountCalculatorPercent => 'Percent (%)';

  @override
  String get amountCalculatorButtonTooltip => 'Open calculator';

  @override
  String get amountCalculatorOriginal => 'Original';

  @override
  String get amountCalculatorResult => 'Result';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get selectDate => 'Select date';

  @override
  String get exportSummary => 'Export Summary';

  @override
  String get totalTransactions => 'Total Transactions';

  @override
  String get csvInfoNote =>
      'CSV files can be opened in Excel or Google Sheets. PDF reports are great for sharing.';

  @override
  String get testCategoriesPdf => 'Test Categories PDF (Icons)';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get transactionDetails => 'Transaction Details';

  @override
  String get autoGenerated => 'Auto-Generated';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get linkedEntry => 'Linked Entry';

  @override
  String paidOn(String date) {
    return 'Paid on: $date';
  }

  @override
  String receivedOn(String date) {
    return 'Received on: $date';
  }

  @override
  String get deleteTransactionTitle => 'Delete Transaction';

  @override
  String get deleteTransactionMessage =>
      'Are you sure you want to delete this transaction? This action cannot be undone.';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get errorLoadingCurrency => 'Error loading currency';

  @override
  String get balanceLabel => 'Balance';

  @override
  String get errorLabel => 'Error';

  @override
  String get importTransaction => 'Import Transaction';

  @override
  String get importReceivable => 'Import Receivable';

  @override
  String get importPayable => 'Import Payable';

  @override
  String sharedBy(String name) {
    return 'Shared by: $name';
  }

  @override
  String get sender => 'Sender';

  @override
  String get someone => 'Someone';

  @override
  String markedAsStatus(String name, String status) {
    return '$name has marked this as $status. Update your local record?';
  }

  @override
  String get itemAlreadyImported => 'This item has already been imported.';

  @override
  String get importDetails => 'Import Details';

  @override
  String get viewDetails => 'View Details';

  @override
  String get importClassificationReceivableQuestion =>
      'How would you like to record this receivable?';

  @override
  String importClassificationReceivableOptionPaidFor(String contact) {
    return 'I covered this expense — $contact will reimburse me.';
  }

  @override
  String get importClassificationReceivableOptionWillReceive =>
      'This is for my services, a gift I am owed, or another income.';

  @override
  String get importClassificationPayableQuestion =>
      'How would you like to record this payable?';

  @override
  String importClassificationPayableOptionPaidBy(String contact) {
    return '$contact covered this expense on my behalf.';
  }

  @override
  String get importClassificationPayableOptionReceivedFrom =>
      'I received this as a loan, advance, or borrowed amount.';

  @override
  String get type => 'Type';

  @override
  String get remaining => 'remaining';

  @override
  String get daily => 'Daily';

  @override
  String get limitReached => 'Limit Reached';

  @override
  String get proLabel => 'PRO';

  @override
  String get deleteItem => 'Delete Item';

  @override
  String get confirmDeleteItem => 'Are you sure you want to delete this item?';

  @override
  String sharePayableCompleted(String amount, String date, String link) {
    return 'Greetings!\n\nThe payment of $amount on $date has been completed.\n\nSync in Flowpaisa:\n$link';
  }

  @override
  String sharePayablePending(String amount, String date, String link) {
    return 'I owe you $amount\nDate: $date\n\nView in Flowpaisa:\n$link';
  }

  @override
  String shareReceivableReceived(String amount, String date, String link) {
    return 'Greetings!\n\nThe payment of $amount on $date has been received.\n\nSync in Flowpaisa:\n$link';
  }

  @override
  String shareReceivablePending(String amount, String date, String link) {
    return 'Amount to receive: $amount\nDate: $date\n\nView in Flowpaisa:\n$link';
  }

  @override
  String shareTransactionMessage(String amount, String date, String link) {
    return 'Recorded a transaction of $amount on $date.\n\nView in Flowpaisa:\n$link';
  }

  @override
  String get shareViaWhatsApp => 'Share via WhatsApp';

  @override
  String toContact(String name) {
    return 'To $name';
  }

  @override
  String get chooseContact => 'Choose contact';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get copyDeepLinkSubtitle => 'Copy deep link to clipboard';

  @override
  String get tapToSpeak => 'Tap to speak';

  @override
  String get listening => 'Listening...';

  @override
  String get whatWeHeard => 'What we heard:';

  @override
  String get reParse => 'Re-parse';

  @override
  String get smartExtraction => 'Smart extraction';

  @override
  String get basicExtraction => 'Basic extraction';

  @override
  String get addNow => 'Add now';

  @override
  String get editAndAdd => 'Edit and add';

  @override
  String get downloadNow => 'Download Now';

  @override
  String get smartAiDownloadMessage =>
      'Smart features require a one-time download (~100MB). Would you like to download now for better accuracy?';

  @override
  String get smartParsingLimitReached =>
      'Monthly smart parsing limit reached. Using basic extraction.';

  @override
  String get voiceTips =>
      'Try saying: \'Spent 500 on dinner\' or \'I gave 100 to Usman for lunch\'';

  @override
  String get proceed => 'Proceed';

  @override
  String get hints => 'Hints';

  @override
  String get voiceGuideTitle => 'Voice Phrasing Guide';

  @override
  String get voiceInstructionBasic =>
      'You\'re using simple extraction mode. Tap here to see hint messages.';

  @override
  String get voiceInstructionSmart =>
      'You\'re using Smart extraction. Tap here for more tips.';

  @override
  String get windowsDictationTip =>
      'Tip: On Windows, you can click the text box below and press Win + H to use Windows\' highly accurate built-in Dictation tool!';

  @override
  String get includeTextAsDescription => 'Include text as description';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get scanningReceipt => 'Scanning receipt...';

  @override
  String get noReceiptSelected => 'No receipt selected';

  @override
  String get reviewAndEdit => 'Review & Edit';

  @override
  String get merchantName => 'Merchant Name';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get proceedToAddTransaction => 'Proceed to Add Transaction';

  @override
  String errorPickingImage(String error) {
    return 'Error picking image: $error';
  }

  @override
  String errorScanningReceipt(String error) {
    return 'Error scanning receipt: $error';
  }

  @override
  String get noCategoriesFound => 'No categories found';

  @override
  String get allContactsAddedToSplit => 'All contacts are already in the split';

  @override
  String get paidRelationship => 'Paid Relationship';

  @override
  String get paidFor => 'Paid FOR';

  @override
  String get paidBy => 'Paid BY';

  @override
  String get iWillReceiveBack => 'I will receive back';

  @override
  String get someonePaidForMe => 'Someone paid for me';

  @override
  String get receivedRelationship => 'Received Relationship';

  @override
  String get iOwe => 'I Owe';

  @override
  String get receivedLoan => 'Received loan';

  @override
  String get receiveLater => 'Receive later';

  @override
  String get schedulePattern => 'Schedule Pattern';

  @override
  String get startDateOptional => 'Start Date (Optional)';

  @override
  String get endDateOptional => 'End Date (Optional)';

  @override
  String get scheduleUpdated => 'Schedule updated successfully';

  @override
  String get updateSchedule => 'Update Schedule';

  @override
  String get updating => 'Updating...';

  @override
  String get contactOptional => 'Contact (Optional)';

  @override
  String get pleaseSelectContactRelationship =>
      'Please select a contact for this relationship';

  @override
  String get weekly => 'Weekly';

  @override
  String weeklyWithDays(String days) {
    return 'Weekly: $days';
  }

  @override
  String monthlyWithDay(String day) {
    return 'Monthly: $day';
  }

  @override
  String get schedules => 'Schedules';

  @override
  String get generate100DummyTransactions => 'Generate 100 Dummy Transactions';

  @override
  String get generated100DummyTransactions =>
      'Generated 100 dummy transactions';

  @override
  String get errorLoadingTransactions => 'Error loading transactions';

  @override
  String get noSchedulesFound => 'No schedules found';

  @override
  String get noMoreTransactions => 'No more transactions';

  @override
  String get scheduleDeleted => 'Schedule deleted successfully';

  @override
  String get autoBadge => 'Auto';

  @override
  String get remainingNetBalance => 'Remaining net balance';

  @override
  String get settleAll => 'Settle all';

  @override
  String get bulkReceiveInBulk => 'Receive in bulk';

  @override
  String get bulkPayInBulk => 'Pay in bulk';

  @override
  String get bulkProcessInBulk => 'Process in bulk';

  @override
  String get cannotRestoreActiveCashbook =>
      'You cannot restore data into the active cashbook. Please switch to another cashbook first to release the file lock.';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get categoriesSummaryIncludeInTotal => 'Include in total';

  @override
  String get schedule => 'Schedule';

  @override
  String get confirm => 'Confirm';

  @override
  String get emailLabel => 'Email';

  @override
  String get notesLabel => 'Notes';

  @override
  String get deleteContactTitle => 'Delete Contact';

  @override
  String get deleteContactConfirmation =>
      'Are you sure you want to delete this contact? This will delete all associated transaction history.';

  @override
  String get information => 'Information';

  @override
  String get loading => 'Loading...';

  @override
  String get limitReachedTitle => 'Limit Reached';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get summary => 'Summary';

  @override
  String get splittedTransactions => 'Splitted Transactions';

  @override
  String get balance => 'Balance';

  @override
  String get received => 'Received';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get noTransactionsInRange => 'No transactions in this date range.';

  @override
  String get noPayablesInRange => 'No payables in this date range.';

  @override
  String get noReceivablesInRange => 'No receivables in this date range.';

  @override
  String get topCategoriesVisual => 'Top Categories (Visual)';

  @override
  String get incomeVsExpenseTrendVisual => 'Income vs Expense Trend (Visual)';

  @override
  String get payableVsReceivableTrendVisual =>
      'Payable vs Receivable Trend (Visual)';

  @override
  String get incomeShort => 'I:';

  @override
  String get shareTransaction => 'Share Transaction';

  @override
  String get sharePaymentRequest => 'Share Payment Request';

  @override
  String get sharePaymentAcknowledgment => 'Share Payment Acknowledgment';

  @override
  String get openingWhatsApp => 'Opening WhatsApp...';

  @override
  String get linkCopied => 'Link copied to clipboard!';

  @override
  String get addToDashboard => 'Add to dashboard';

  @override
  String get addedToDashboard => 'Added to dashboard';

  @override
  String get removeFromDashboard => 'Remove from dashboard';

  @override
  String get pinToDashboard => 'Pin to dashboard';

  @override
  String get unpinFromDashboard => 'Unpin from dashboard';

  @override
  String get pinnedToDashboard => 'Pinned to dashboard';

  @override
  String get unpinnedFromDashboard => 'Unpinned from dashboard';

  @override
  String get reorderWidgetsOn => 'Reorder widgets';

  @override
  String get reorderWidgetsOff => 'Done reordering';

  @override
  String failedToShare(String error) {
    return 'Failed to share: $error';
  }

  @override
  String failedToCopyLink(String error) {
    return 'Failed to copy link: $error';
  }

  @override
  String get expenseShort => 'E:';

  @override
  String suggestedLabel(String name) {
    return 'Suggested: $name';
  }

  @override
  String get deleteCashbookTitle => 'Delete Cashbook';

  @override
  String get deletePermanently => 'Delete Permanently';

  @override
  String get pleaseEnterValidAmount => 'Please enter a valid amount';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryGift => 'Gift';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusReceived => 'Received';

  @override
  String get statusSettled => 'Settled';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusSent => 'Sent';

  @override
  String get statusFailed => 'Failed';

  @override
  String get payableTag => 'Payable';

  @override
  String get receivableTag => 'Receivable';

  @override
  String get receivedTag => 'Received';

  @override
  String get paidTag => 'Paid';

  @override
  String get filterTransactionProcessed => 'Processed';

  @override
  String get filterTransactionNotProcessed => 'Not processed';

  @override
  String get currencyUSD => 'US Dollar (\$)';

  @override
  String get currencyINR => 'Indian Rupee (₹)';

  @override
  String get currencyPKR => 'Pakistani Rupee (Rs)';

  @override
  String get inactive => 'Inactive';

  @override
  String get sundayShort => 'Sun';

  @override
  String get mondayShort => 'Mon';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get fridayShort => 'Fri';

  @override
  String get saturdayShort => 'Sat';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get willReceive => 'Will Receive';

  @override
  String get selectSchedulePattern => 'Select Schedule Pattern';

  @override
  String get daysOfWeek => 'Days of Week';

  @override
  String get daysOfMonth => 'Days of Month';

  @override
  String get sunday => 'Sunday';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get updateReceivable => 'Update Receivable';

  @override
  String get newCashbook => 'New Cashbook';

  @override
  String get freeLimitReached => 'Free Limit Reached';

  @override
  String get cashbookNameHint => 'e.g., Personal, Business';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get selectColor => 'Select Color';

  @override
  String get updateCashbook => 'Update Cashbook';

  @override
  String get noOtherCashbooks => 'No other cashbooks available to copy from.';

  @override
  String get selectSourceCashbook => 'Select Source Cashbook';

  @override
  String toTarget(String name) {
    return 'To: $name';
  }

  @override
  String get whatToCopy => 'What to Copy?';

  @override
  String get userProfile => 'User Profile';

  @override
  String get userProfileDescription => 'Name, Email, and basic info';

  @override
  String get preferencesDescription => 'Currency and Date Format settings';

  @override
  String get copyDateFormatAndFonts => 'Date format & fonts';

  @override
  String get copyDateFormatAndFontsSubtitle =>
      'App language, fonts per language, date format, and selected currency for amounts';

  @override
  String get copyCurrenciesOption => 'Currencies';

  @override
  String get copyCurrenciesOptionSubtitle =>
      'Currency definitions from the source cashbook (names, symbols, codes)';

  @override
  String get messageTemplatesDescription => 'WhatsApp message templates';

  @override
  String get copyContacts => 'Contacts';

  @override
  String get copyContactsDescription =>
      'Contact names, phone numbers, and emails';

  @override
  String get copyCategories => 'Categories';

  @override
  String get copyCategoriesDescription =>
      'Expense and income categories with icons and colors';

  @override
  String get copyDashboardWidgets => 'Dashboard widgets';

  @override
  String get copyDashboardWidgetsDescription =>
      'Widget layout, privacy and financial summary toggles, bottom quick action, and dashboard visibility';

  @override
  String get copy => 'Copy';

  @override
  String get pleaseSelectSource => 'Please select a source cashbook';

  @override
  String get pleaseSelectAtLeastOne =>
      'Please select at least one item to copy';

  @override
  String get preferencesCopied => 'Preferences copied successfully';

  @override
  String errorCopyingPreferences(String error) {
    return 'Error copying preferences: $error';
  }

  @override
  String get reset => 'Reset';

  @override
  String get template => 'Template';

  @override
  String get variables => 'Variables';

  @override
  String get close => 'Close';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get error => 'Error';

  @override
  String get currencies => 'Currencies';

  @override
  String get backup => 'Backup';

  @override
  String get takeBackup => 'Take Backup';

  @override
  String get restoreOptionsTitle => 'Restore Options';

  @override
  String get restoreFromCloud => 'Restore from Cloud';

  @override
  String get restoreFromCloudSubtitle => 'Restore from Google Drive';

  @override
  String get restoreFromFileSubtitle => 'Restore from a local file';

  @override
  String get backgroundRestoreStarted => 'Restore started in background';

  @override
  String restoreSuccessfulFor(String name) {
    return 'Restore successful for $name';
  }

  @override
  String get selectCloudFolder => 'Select Cloud Folder';

  @override
  String get selectCloudFolderSubtitle =>
      'Choose a cashbook folder to see its backups';

  @override
  String get noCloudFoldersFound => 'No cloud folders found';

  @override
  String get premium => 'Premium';

  @override
  String get free => 'Free';

  @override
  String get transactionAlreadyImported => 'Transaction already imported';

  @override
  String get pleaseSelectContactLinked =>
      'Please select a contact for linked transaction';

  @override
  String get transactionLinkedAdded =>
      'Transaction linked and added successfully';

  @override
  String get transactionAdded => 'Transaction added successfully';

  @override
  String createCategoryNamed(String name) {
    return 'Create category $name';
  }

  @override
  String get tapToAddCategory => 'Tap to add this category';

  @override
  String get frequent => 'Frequent';

  @override
  String get saving => 'Saving...';

  @override
  String get transactionDeletedSuccessfully =>
      'Transaction deleted successfully';

  @override
  String get googleDrive => 'Google Drive';

  @override
  String get activeCashbook => 'Active Cashbook';

  @override
  String get syncAndBackupApplyTo =>
      'All sync and backup actions below apply to this cashbook only.';

  @override
  String get synchronization => 'Synchronization';

  @override
  String get syncActive => 'Sync active';

  @override
  String get syncDescription =>
      'Synchronization keeps your data updated across all your devices by merging small changes. It is fast and runs automatically.';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get syncTriggered => 'Sync triggered in background';

  @override
  String get autoSync => 'Auto Sync';

  @override
  String get syncInterval => 'Sync Interval (Hours)';

  @override
  String get hour => 'hour';

  @override
  String get hours => 'hours';

  @override
  String localVersion(int version) {
    return 'Local Version: $version';
  }

  @override
  String cloudVersion(int version) {
    return 'Cloud Version: $version';
  }

  @override
  String lastSync(String time) {
    return 'Last Sync: $time';
  }

  @override
  String get autoBackup => 'Auto Backup';

  @override
  String get manual => 'Manual';

  @override
  String get backupDescription =>
      'A full backup creates a complete snapshot of your database. Use this for historical records or to recover from major issues.';

  @override
  String get syncRecovery => 'Sync Recovery';

  @override
  String get syncRecoveryDescription =>
      'If you restored this backup to fix a sync error, you should reset the cloud sync to this version. This makes this restored data the \"source of truth\".';

  @override
  String get resetCloudSync => 'Reset Cloud Sync';

  @override
  String get syncManifestReset => 'Sync manifest reset successfully';

  @override
  String failedToResetSync(String error) {
    return 'Failed to reset sync: $error';
  }

  @override
  String get backupOptions => 'Backup Options';

  @override
  String get backupToCloud => 'Backup to Cloud';

  @override
  String get backupToCloudSubtitle =>
      'Securely store your database on Google Drive';

  @override
  String get backupToFile => 'Backup to File';

  @override
  String get backupToFileSubtitle =>
      'Save database file to your device or share it';

  @override
  String get backupOptionsTitle => 'Choose Backup Method';

  @override
  String get restoreFromFile => 'Restore from File';

  @override
  String get clearData => 'Clear Data';

  @override
  String get addCashbook => 'Add Cashbook';

  @override
  String get cashbookCreated => 'Cashbook created successfully';

  @override
  String get fontSelection => 'Font Selection';

  @override
  String get restoreToNewCashbookTitle => 'Restore to New Cashbook?';

  @override
  String restoreToNewCashbookMessage(String cloudCashbookName) {
    return 'This backup belongs to \"$cloudCashbookName\". Restoring it will create a new cashbook entry on this device with its data.';
  }

  @override
  String get overrideExistingCashbookTitle => 'Override Existing Cashbook?';

  @override
  String overrideExistingCashbookMessage(
      String cloudCashbookName, String activeCashbookName) {
    return 'This backup belongs to \"$cloudCashbookName\". Restoring it will overwrite the data of your currently active cashbook, \"$activeCashbookName\".';
  }

  @override
  String restoreSuccessNew(String name) {
    return 'Cashbook $name created successfully. You can switch to it from the home screen.';
  }

  @override
  String get restoreOptionOverride => 'Override';

  @override
  String get restoreOptionNewEntry => 'New Entry';

  @override
  String get filters => 'Filters';

  @override
  String get dateRange => 'Date Range';

  @override
  String get transactionType => 'Transaction Type';

  @override
  String get amountRange => 'Amount Range';

  @override
  String get minAmount => 'Min Amount';

  @override
  String get maxAmount => 'Max Amount';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get filterByDueDate => 'Filter by Due Date';

  @override
  String get notificationBackupSuccessTitle => 'Backup Successful';

  @override
  String notificationBackupSuccessMessage(String name) {
    return 'Successfully backed up \"$name\" to Google Drive.';
  }

  @override
  String get notificationSyncCompleteTitle => 'Background Sync Complete';

  @override
  String notificationSyncCompleteMessage(int count) {
    return 'Successfully synced $count cashbook(s) in the background.';
  }

  @override
  String get cloudCashbooks => 'Cloud Cashbooks';

  @override
  String get main => 'Main';

  @override
  String get cloudDb => 'Cloud DB';

  @override
  String get versions => 'Versions';

  @override
  String get local => 'Local';

  @override
  String get cloud => 'Cloud';

  @override
  String rows(int count) {
    return '$count rows';
  }

  @override
  String get primeCloudWithLocal => 'Prime Cloud with Local';

  @override
  String get resetCloudVersion => 'Reset Cloud Version';

  @override
  String resetCloudVersionMessage(Object version) {
    return 'This will force the cloud version to match your local version ($version).\n\nUse this ONLY if your cloud manifest is corrupted or out of sync with your local data.';
  }

  @override
  String get resetNow => 'Reset Now';

  @override
  String get cloudVersionResetSuccess => 'Cloud version reset successfully';

  @override
  String cloudVersionResetFailed(Object error) {
    return 'Failed to reset cloud version: $error';
  }

  @override
  String get syncIntervalLabel => 'Sync Interval';

  @override
  String get resetLocalSyncState => 'Reset Local Sync State';

  @override
  String get resetLocalSyncMessage =>
      'This will mark all your local records as \"unsynced\" and reset your local version to 0. Tapping \"Sync Now\" after this will re-upload all your data to the cloud.\n\nUse this if you want to force a full re-sync of your local data.';

  @override
  String get localSyncResetSuccess => 'Local sync state reset successfully';

  @override
  String get clearAllCloudData => 'Clear All Cloud Data';

  @override
  String get clearAllCloudDataMessage =>
      'This will permanently delete ALL your Flowpaisa backups and synchronization data from Google Drive. This action cannot be undone.\n\nAre you sure you want to clear all cloud data?';

  @override
  String get cloudDataClearedSuccess => 'All cloud data cleared successfully';

  @override
  String get clearNow => 'Clear Now';

  @override
  String get upcomingSyncDeltas => 'Upcoming Sync Deltas';

  @override
  String get recentSyncDeltas => 'Recent Sync Deltas';

  @override
  String get manifestContentLocked => 'Manifest Content (Locked)';

  @override
  String get deltaContent => 'Delta Content';

  @override
  String get refreshStatus => 'Refresh Status';

  @override
  String get refreshBackups => 'Refresh Backups';

  @override
  String get locked => 'Locked';

  @override
  String lockedWithTime(int minutes) {
    return 'Locked (${minutes}m)';
  }

  @override
  String get payableOverdue => 'Payable Overdue';

  @override
  String payableOverdueMessage(String description, String date) {
    return 'Payment for $description was due on $date';
  }

  @override
  String get receivableOverdue => 'Receivable Overdue';

  @override
  String receivableOverdueMessage(String description, String date) {
    return 'Payment for $description was due on $date';
  }

  @override
  String get upcomingPayable => 'Upcoming Payable';

  @override
  String upcomingPayableMessage(String description, String date) {
    return 'Payment for $description is due tomorrow ($date)';
  }

  @override
  String get upcomingReceivable => 'Upcoming Receivable';

  @override
  String upcomingReceivableMessage(String description, String date) {
    return 'Payment for $description is due tomorrow ($date)';
  }

  @override
  String get urgent => 'URGENT';

  @override
  String get deleteCloudCashbook => 'Delete Cloud Cashbook?';

  @override
  String deleteCloudCashbookMessage(String name) {
    return 'Are you sure you want to delete \"$name\" from Google Drive? This will delete all its backups and sync data. This action cannot be undone.';
  }

  @override
  String get cloudCashbookDeletedSuccess =>
      'Cloud cashbook deleted successfully';

  @override
  String get myShare => 'My Share';

  @override
  String get split => 'Split';

  @override
  String get contactShare => 'Contact\'s Share';

  @override
  String get othersShare => 'Others Share';

  @override
  String get myShareSuffix => ' (My Share)';

  @override
  String get othersShareSuffix => ' (Others Share)';

  @override
  String get splitBill => 'Split Bill';

  @override
  String get includeMe => 'Include Me';

  @override
  String get splittedBill => 'Splitted Bill';

  @override
  String get me => 'Me';

  @override
  String get distributeEqually => 'Distribute Equally';

  @override
  String get totalPercentage => 'Total Percentage';

  @override
  String get lockShare => 'Lock Share';

  @override
  String get unlockShare => 'Unlock Share';

  @override
  String get customAmount => 'Custom Amount';

  @override
  String get percentage => 'Percentage';

  @override
  String get remainingAmount => 'Remaining Amount';

  @override
  String get totalMustBe100 => 'Total must be 100%';

  @override
  String get totalMustMatch => 'Total must match transaction amount';

  @override
  String get sameDay => 'Same day';

  @override
  String inDays(int days) {
    return 'In $days days';
  }

  @override
  String daysAgoRelative(int days) {
    return '$days days ago';
  }

  @override
  String get pickActualDate => 'Pick actual date';

  @override
  String relativeDateAfterXDays(String days) {
    return 'Relative date (After $days days)';
  }

  @override
  String get enterDaysFromTransaction =>
      'Enter number of days from transaction date:';

  @override
  String get enterDaysFromStart => 'Enter number of days from start date:';

  @override
  String get daysHint => 'e.g. 15';

  @override
  String get daysSuffix => 'days';

  @override
  String get status => 'Status';

  @override
  String get payableVsReceivableTrend => 'Payable vs Receivable Trend';

  @override
  String get categoryDetails => 'Category Details';

  @override
  String get netIncome => 'Net Income';

  @override
  String get netExpenses => 'Net Expenses';

  @override
  String get categoriesAggregateTitle => 'All categories';

  @override
  String get syncStatusTitle => 'Sync Status';

  @override
  String changesToPush(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes to push',
      one: '1 change to push',
    );
    return '$_temp0';
  }

  @override
  String get updatesAvailable => 'Updates available on cloud';

  @override
  String get oneUpdateAvailable => '1 update available on cloud';

  @override
  String multipleUpdatesAvailable(int count) {
    return '$count updates available on cloud';
  }

  @override
  String get dataSynced => 'Data is synced';

  @override
  String get syncAlreadyInProgress => 'Sync already in progress';

  @override
  String get syncDelayedRetryShortly => 'Sync delayed – will retry shortly';

  @override
  String get premiumRequiredForSync => 'Premium required for cloud sync';

  @override
  String get signInRequiredForSync => 'Sign in with Google to sync';

  @override
  String get clearCloud => 'Clear Cloud';

  @override
  String get clearCloudTitle => 'Clear Cloud Data';

  @override
  String clearCloudMessage(Object name) {
    return 'Choose which cloud data you want to clear for \"$name\".';
  }

  @override
  String get clearBackups => 'Clear all backups';

  @override
  String get clearBackupsSubtitle =>
      'Deletes full database snapshots from Google Drive';

  @override
  String get clearSyncHistory => 'Clear sync history';

  @override
  String get clearSyncHistorySubtitle =>
      'Resets sync manifest and deletes delta files';

  @override
  String get clearSelectedCloudData => 'Clear Selected Data';

  @override
  String get cloudDataCleared => 'Selected cloud data cleared successfully';

  @override
  String get deleteLocalOnlyNote =>
      'Note: Your cloud backups and sync data will remain safe on Google Drive.';

  @override
  String get alsoClearCloud => 'Also clear cloud backup';

  @override
  String get clearCloudSubtitle =>
      'Wipes history from Google Drive for this cashbook only';

  @override
  String get addCloudCashbook => 'Add Cloud Cashbook';

  @override
  String get addFromCloud => 'Add from Cloud';

  @override
  String get bulkProcessConfirmation =>
      'Are you sure you want to process all outstanding items for this contact?';

  @override
  String get accountChangedTitle => 'Google Drive Account Changed';

  @override
  String accountChangedMessage(String oldEmail, String newEmail) {
    return 'You previously synced with $oldEmail, but are now logged into $newEmail.\n\nTo prevent data conflicts, your data will not sync correctly with this new drive until you clear the existing cloud data.\n\nPlease go to the Cashbooks screen, tap the menu (⋮) on your cashbook, and select \'Clear Cloud\'.';
  }

  @override
  String get understood => 'Understood';

  @override
  String get premiumExpiredSyncPaused =>
      'Your Premium subscription has expired. Cloud sync has been paused and you have been logged out of Google Drive.';

  @override
  String get loggedOutSyncPaused =>
      'Logged out. Background sync has been paused.';

  @override
  String get signOutSyncConfirmMessage =>
      'Signing out will pause background sync. Continue?';

  @override
  String get scenarioHelpTitle => 'What type of transaction?';

  @override
  String get autoSuggest => 'Auto suggest';

  @override
  String get scenarioPaidForMeal => 'Paid for friend\'s lunch / meal';

  @override
  String get scenarioBoughtForSomeone =>
      'Bought something for someone (they\'ll pay back)';

  @override
  String get scenarioLentMoney => 'Lent money to colleague/family';

  @override
  String get scenarioPaidBillForSomeone => 'Paid a bill on behalf of someone';

  @override
  String get scenarioSplitYouPaid =>
      'Split expense – you paid full, others will reimburse';

  @override
  String get scenarioFriendPaidMeal => 'Friend paid for your lunch';

  @override
  String get scenarioSomeonePaidBill =>
      'Someone else paid the bill (you\'ll pay them back)';

  @override
  String get scenarioColleaguePaidForYou =>
      'Colleague/family paid for you (you\'ll reimburse)';

  @override
  String get scenarioSplitTheyPaid => 'Shared expense – others paid your share';

  @override
  String get scenarioPaySomeoneForServices =>
      'You have to pay someone for services';

  @override
  String get scenarioBorrowedCash => 'Borrowed cash from someone';

  @override
  String get scenarioLoanReceived => 'Received a loan (to be repaid)';

  @override
  String get scenarioBorrowedFromContact => 'Borrowed money from friend/family';

  @override
  String get scenarioSalaryAdvance =>
      'Got advance from employer (to be deducted)';

  @override
  String get scenarioReceivedToRepay => 'Received money you\'ll return';

  @override
  String get scenarioSalaryPending => 'Salary to be received';

  @override
  String get scenarioClientPaymentPending => 'Payment from client (pending)';

  @override
  String get scenarioPaymentPending => 'Friend/family will pay you back';

  @override
  String get scenarioRentPending => 'Rent to be received';

  @override
  String get scenarioSalePending => 'Sold something – payment pending';

  @override
  String get scenarioInvoicePending => 'Invoice not yet paid';

  @override
  String get scenarioPersonalExpense => 'Personal expense / shopping';

  @override
  String get scenarioBillPaid => 'Bill / utility payment';

  @override
  String get scenarioSubscription => 'Subscription / membership';

  @override
  String get scenarioSalaryReceived => 'Salary received';

  @override
  String get scenarioFreelanceIncome => 'Freelance / side income';

  @override
  String get scenarioGiftReceived => 'Gift / bonus received';

  @override
  String get scenarioRefundReceived => 'Refund received';

  @override
  String get accounts => 'Accounts';

  @override
  String get account => 'Account';

  @override
  String get addAccount => 'Add Account';

  @override
  String get editAccount => 'Edit Account';

  @override
  String get accountName => 'Account Name';

  @override
  String get accountType => 'Account Type';

  @override
  String get cash => 'Cash';

  @override
  String get bank => 'Bank';

  @override
  String get savings => 'Savings';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get openingBalance => 'Opening Balance';

  @override
  String get openingBalanceDues => 'Opening Balance (Dues)';

  @override
  String get openingDate => 'Opening Date';

  @override
  String get creditLimit => 'Credit Limit';

  @override
  String get billingCycleDay => 'Billing Cycle Day';

  @override
  String get paymentDueDays => 'Payment Due (days after cycle)';

  @override
  String get linkedPaymentAccount => 'Linked Payment Account';

  @override
  String get linkedPaymentAccountHint =>
      'Account used for auto-payment reminder';

  @override
  String get accountCreated => 'Account created successfully';

  @override
  String get accountUpdated => 'Account updated successfully';

  @override
  String get accountDeleted => 'Account deleted successfully';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to delete this account? This will not delete transactions linked to it.';

  @override
  String get noAccounts => 'No accounts yet';

  @override
  String get noAccountsDescription =>
      'Add your cash, bank or card accounts to track balances';

  @override
  String get creditCardNotAllowedForReceive =>
      'Credit cards can\'t be used here. Add or pick a cash, bank, or savings account instead.';

  @override
  String get outstanding => 'Outstanding';

  @override
  String get availableCredit => 'Available Credit';

  @override
  String get creditBalance => 'Credit Balance';

  @override
  String get billed => 'Billed';

  @override
  String get unbilled => 'Unbilled';

  @override
  String get transferMoney => 'Transfer Money';

  @override
  String get fromAccount => 'From Account';

  @override
  String get toAccount => 'To Account';

  @override
  String get transferCreated => 'Transfer recorded successfully';

  @override
  String get selectAccount => 'Select Account';

  @override
  String get noAccount => 'No Account';

  @override
  String get pendingTransactions => 'Pending Transactions';

  @override
  String get payFrom => 'Pay from';

  @override
  String get receiveInto => 'Receive Into';

  @override
  String get settlementAccount => 'Settlement Account';

  @override
  String get setAccount => 'Set Account';

  @override
  String get combineBalances => 'Combine Balances';

  @override
  String get selectedTotal => 'Selected Total';

  @override
  String get selectAccountsToCombine =>
      'Select accounts to see their combined balance';

  @override
  String get accountPickerInfoMessage =>
      'Applies only to transactions without an assigned account';

  @override
  String get settlementContinueWithoutAccount => 'Continue without account';

  @override
  String get negativeBalanceWarning =>
      'This will put your Cash balance below zero';

  @override
  String paymentDueNotification(String amount, int days) {
    return 'Credit card payment of $amount is due in $days days';
  }

  @override
  String paymentDueTodayNotification(String amount) {
    return 'Credit card payment of $amount is due today';
  }

  @override
  String paymentOverdueNotification(String amount, int days) {
    return 'Credit card payment of $amount is overdue by $days days';
  }

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get accountBalance => 'Account Balance';

  @override
  String get noAccountSelected => 'No account selected';

  @override
  String get selectPaymentAccount => 'Select payment account';

  @override
  String get dayOfMonth => 'Day of Month';

  @override
  String get howMuchDoYouOwe => 'How much do you currently owe on this card?';

  @override
  String get transferBetweenAccounts => 'Transfer between accounts';

  @override
  String get sameAccountError => 'From and To accounts cannot be the same';

  @override
  String get transfers => 'Transfers';

  @override
  String get recentTransfers => 'Recent Transfers';

  @override
  String get noTransfers => 'No transfers yet';

  @override
  String transferFromTo(String from, String to) {
    return '$from → $to';
  }

  @override
  String get accountNotFound => 'Account not found';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete this account? This will not delete transactions linked to it.';

  @override
  String get outstandingBalance => 'Outstanding Balance';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get amountDue => 'Amount Due';

  @override
  String get unbilledAmount => 'Unbilled Amount';

  @override
  String get creditUsed => 'Credit Used';

  @override
  String get creditCards => 'Credit Cards';

  @override
  String get netWorth => 'Net Worth';

  @override
  String get totalAssets => 'Total Assets';

  @override
  String get totalLiabilities => 'Total Liabilities';

  @override
  String get available => 'Available';

  @override
  String get due => 'Due';

  @override
  String get pleaseEnterAccountName => 'Please enter account name';

  @override
  String get appearance => 'Appearance';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get icon => 'Icon';

  @override
  String get creditCardDetails => 'Credit Card Details';

  @override
  String get pleaseSelectBothAccounts =>
      'Please select both From and To accounts';

  @override
  String get recordTransfer => 'Record Transfer';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String dayLabel(int day) {
    return 'Day $day';
  }

  @override
  String get openTransactionsForAccount =>
      'Tap to view transactions for this account';

  @override
  String get payBill => 'Pay Bill';

  @override
  String get customPayment => 'Custom Payment';

  @override
  String get customPaymentHint => 'Enter a custom amount';

  @override
  String payingAmount(String amount) {
    return 'Paying $amount';
  }

  @override
  String get noBankAccountsToPayFrom =>
      'No bank or savings accounts available to pay from';

  @override
  String get accountsOverview => 'Accounts Overview';

  @override
  String get balanceDistribution => 'Balance Distribution';

  @override
  String get spendingByAccount => 'Spending by Account';

  @override
  String get transferFlow => 'Transfer Flow';

  @override
  String get creditUtilisation => 'Credit Utilisation';

  @override
  String get noAccountActivity => 'No account activity in this period';

  @override
  String get noTransferActivity => 'No transfers in this period';

  @override
  String creditUsedOf(String used, String limit) {
    return '$used used of $limit';
  }

  @override
  String get inflow => 'Inflow';

  @override
  String get outflow => 'Outflow';

  @override
  String get netFlow => 'Net Flow';

  @override
  String get showDetails => 'Show Details';

  @override
  String get customiseSections => 'Customise Sections';

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get moreOptions => 'More Options';

  @override
  String get processed => 'Processed';

  @override
  String get processedImmediately => 'Paid immediately';

  @override
  String get receivedImmediately => 'Received immediately';

  @override
  String get processedOn => 'Processed On';

  @override
  String get paidOnRowLabel => 'Paid on';

  @override
  String get receivedOnRowLabel => 'Received on';

  @override
  String get paidForSubtitle => 'I paid, will receive back';

  @override
  String get paidBySubtitle => 'Someone paid for me';

  @override
  String get willReceiveSubtitle => 'Expected, not received yet';

  @override
  String get receivedFromSubtitle => 'Received, will pay back';

  @override
  String get spendingBudget => 'Spending budget';

  @override
  String get savingsTarget => 'Savings target';

  @override
  String get setBudget => 'Set budget';

  @override
  String get editBudget => 'Edit budget';

  @override
  String get monthlyBudget => 'Monthly budget';

  @override
  String get quarterlyBudget => 'Quarterly budget';

  @override
  String get yearlyBudget => 'Yearly budget';

  @override
  String get overallBudget => 'Overall budget';

  @override
  String get overallBudgetProgress => 'Overall budget progress';

  @override
  String get overallNetAmount => 'Overall Net Amount';

  @override
  String get providedPeriod => 'Provided Period';

  @override
  String get overall => 'Overall';

  @override
  String get spendingBudgetDescription =>
      'Optional spending limits for the calendar month, quarter, year, or overall.';

  @override
  String get savingsTargetDescription =>
      'Optional savings targets for the calendar month, quarter, year, or overall.';

  @override
  String get budgetSaved => 'Budget saved';

  @override
  String budgetRemainingOf(String remaining, String total) {
    return '$remaining left of $total';
  }

  @override
  String budgetOverBy(String amount) {
    return '$amount over budget';
  }

  @override
  String towardSavingsTarget(String amount) {
    return '$amount toward target';
  }

  @override
  String get customCategoryBadge => 'Custom category';

  @override
  String get budgetBarUsed => 'Used';

  @override
  String get budgetBarProgress => 'Progress';

  @override
  String get categoryRefund => 'Refund';

  @override
  String get showQuickActionButton => 'Show Quick Action Button';

  @override
  String get showQuickActionButtonDesc =>
      'Display the center button in the bottom bar';

  @override
  String get showDashboardWidgetArea => 'Show Dashboard Widgets';

  @override
  String get showDashboardWidgetAreaDesc =>
      'Display the customizable widget section on the dashboard';

  @override
  String get noWidgetsOnDashboard => 'No widgets on dashboard';

  @override
  String get switchCashbook => 'Switch Cashbook';

  @override
  String get switchText => 'Switch';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get featureUnlimitedAccountsTitle => 'Unlimited Accounts';

  @override
  String get featureUnlimitedAccountsDesc =>
      'Add multiple bank accounts, cash wallets, and credit cards to track all your balances in one place.';

  @override
  String get featureCategoryBudgetsTitle => 'Category Budgets';

  @override
  String get featureCategoryBudgetsDesc =>
      'Set monthly, quarterly, or yearly spending limits and savings targets for any category.';

  @override
  String get onDashboard => 'On Dashboard';

  @override
  String get widgets => 'Widgets';

  @override
  String get others => 'Others';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Flowpaisa';

  @override
  String get onboardingWelcomeBody =>
      'Your complete personal finance and cash flow manager. Take control of your money with ease, precision, and the peace of mind that your data is fully secured and private.';

  @override
  String get onboardingScanTitle => 'Scan or Speak';

  @override
  String get onboardingScanBody =>
      'Save time with Smart Scanning and Voice commands. Just snap a photo of your receipt or tell the app what you spent—it handles the details for you.';

  @override
  String get onboardingTransactionsTitle => 'Smart Linked Transactions';

  @override
  String get onboardingTransactionsBody =>
      'Experience a truly connected system. When you mark a debt as Received, the app automatically records it as Income. When you Pay a bill, it’s instantly logged as an Expense.';

  @override
  String get onboardingCollaborationTitle => 'Real-time Collaboration';

  @override
  String get onboardingCollaborationBody =>
      'Track Receivables and Payables by contact. Send professional WhatsApp reminders using customized message templates to ensure you always get paid on time.';

  @override
  String get onboardingSyncTitle => 'Organized & Personalized';

  @override
  String get onboardingSyncBody =>
      'Create separate Cashbooks for Home or Business. Personalize your Dashboard with custom widgets, and keep everything synced across all your devices.';

  @override
  String get guideAccountsTitle => 'Manage All Your Accounts';

  @override
  String get guideAccountsBody =>
      'Track Cash, Bank, and Savings accounts in one place. See your total Net Worth automatically calculated from your assets and liabilities.';

  @override
  String get guideCreditCardsTitle => 'Credit Card Management';

  @override
  String get guideCreditCardsBody =>
      'Set credit limits and billing cycles. Flowpaisa will notify you before your due date so you never miss a payment.';

  @override
  String get guideBulkImportTitle => 'Bulk Import Transactions';

  @override
  String get guideBulkImportBody =>
      'Save time by importing hundreds of transactions instantly from CSV files or your clipboard (Google Sheets).';

  @override
  String get guideBudgetsTitle => 'Smart Category Budgets';

  @override
  String get guideBudgetsBody =>
      'Set monthly spending limits for any category. Use the consumption indicators to stay on track and save more.';

  @override
  String get guideAutoSettleTitle => 'Auto-Generated Transactions';

  @override
  String get guideAutoSettleBody =>
      'Marking a Receivable as \'Received\' automatically creates an Income entry. Paying a bill instantly logs an Expense—keeping your records perfectly linked.';

  @override
  String get guideSplitSettleTitle => 'Split Bills & Bulk Settle';

  @override
  String get guideSplitSettleBody =>
      'Easily split expenses with multiple contacts. Use Bulk Settlement to clear all outstanding dues with a single contact in one tap.';

  @override
  String get deleteTransfer => 'Delete Transfer';

  @override
  String get deleteTransferConfirm =>
      'Are you sure you want to delete this transfer? This will update the balances of both involved accounts.';

  @override
  String get deleteReceivable => 'Delete Receivable';

  @override
  String get deleteReceivableConfirm =>
      'Are you sure you want to delete this receivable? This action cannot be undone.';

  @override
  String get deletePayable => 'Delete Payable';

  @override
  String get deletePayableConfirm =>
      'Are you sure you want to delete this payable? This action cannot be undone.';

  @override
  String get transferDeleted => 'Transfer deleted successfully';

  @override
  String get transferUpdated => 'Transfer updated successfully';

  @override
  String get editTransfer => 'Edit Transfer';

  @override
  String get updateTransfer => 'Update Transfer';

  @override
  String get dashboardHeroCombineTitle => 'View combined balance';

  @override
  String get dashboardHeroCombineSubtitle =>
      'Choose which other cashbooks to add to the dashboard totals for this cashbook.';

  @override
  String get dashboardHeroCombineNoSummary => 'Open once to load amounts.';

  @override
  String get dashboardHeroCombineNoOthers =>
      'There are no other cashbooks to include.';

  @override
  String get itemizedDetails => 'Itemized Details';

  @override
  String itemizedHeaderQuantityLabel(String quantity) {
    return '$quantity units';
  }

  @override
  String get unitPrice => 'Unit Price';

  @override
  String get unitsQuantity => 'Units/Qty';

  @override
  String get price => 'Price';

  @override
  String get itemized => 'Itemized';

  @override
  String get nextGenerated => 'Next Generated';

  @override
  String get never => 'Never';

  @override
  String get showChart => 'Show Chart';

  @override
  String get showList => 'Show List';

  @override
  String get budget => 'Budget';

  @override
  String get relatedTransactions => 'Related Transactions';

  @override
  String get advanced => 'Advanced';

  @override
  String get autoSyncOnStartup => 'Auto-sync on startup';

  @override
  String get autoSyncDescription =>
      'Automatically sync data when the app opens';

  @override
  String get premiumVerificationToken => 'Premium Verification Token';

  @override
  String get tokenExpiry => 'Token Expiry';

  @override
  String get refreshToken => 'Refresh Token';

  @override
  String get tokenValid => 'Premium Token Valid';

  @override
  String get tokenExpiringSoon => 'Expiring Soon';

  @override
  String get tokenExpired => 'Token Expired';

  @override
  String get premiumTokenMissing => 'Premium Token Missing';

  @override
  String get noTokenGenerated => 'No token generated yet';

  @override
  String get tokenRegeneratedSuccess =>
      'Premium token regenerated successfully';

  @override
  String get fetchPremiumToken => 'Fetch Premium Token';

  @override
  String get premiumTokenSyncedSuccess => 'Premium status synced successfully!';

  @override
  String get premiumTokenNotFound =>
      'No premium verification found on Google Drive.';

  @override
  String get premiumTokenDescription =>
      'This token allows you to use your Premium purchase on Windows and other platforms. Log in with the same Google account to sync your Premium status automatically.';

  @override
  String get googleDriveNotConnected =>
      'Google Drive not connected. Cloud verification will not be available.';
}
