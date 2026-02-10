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
  String get transactionUpdated => 'Transaction updated successfully';

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
  String get markAsReceived => 'Mark as Received';

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
  String get markAsPaid => 'Mark as Paid';

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
  String get dateFormat => 'Date Format';

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
  String get preview => 'Preview';

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
  String get markAllRead => 'Mark all read';

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
  String get tourShowMeHow => 'Show me how';

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
  String get scanReceipt => 'Scan Receipt';

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
  String get uncategorized => 'Uncategorized';

  @override
  String get editSchedule => 'Edit Schedule';

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
  String get loading => 'Loading...';

  @override
  String get limitReachedTitle => 'Limit Reached';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get summary => 'Summary';

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
  String get messageTemplatesDescription => 'WhatsApp message templates';

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
  String get backupToFile => 'Backup to File';

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
  String get premiumRequiredForSync => 'Premium required for cloud sync';

  @override
  String get signInRequiredForSync => 'Sign in with Google to sync';

  @override
  String get alsoClearCloud => 'Also clear cloud backup';

  @override
  String get clearCloudSubtitle =>
      'Wipes history from Google Drive for this cashbook only';

  @override
  String get addCloudCashbook => 'Add Cloud Cashbook';

  @override
  String get addFromCloud => 'Add from Cloud';
}
