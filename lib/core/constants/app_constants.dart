class AppConstants {
  // App Info
  static const String appName = 'FlowPaisa';
  static const String packageName = 'com.flowpaisa.app';
  static const String deepLinkScheme = 'flowpaisa';
  
  // URLs
  static const String appWebsite = 'https://flowpaisa.app';
  static const String privacyPolicy = 'https://flowpaisa.app/privacy';
  static const String termsOfService = 'https://flowpaisa.app/terms';
  
  // Firebase Collections
  static const String languageRequestsCollection = 'language_requests';
  
  // Shared Preferences Keys
  static const String keyLanguage = 'app_language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyLastBackup = 'last_backup';
  static const String keyIsPremium = 'is_premium';
  
  // Transaction Types
  static const String transactionTypeExpense = 'EXPENSE';
  static const String transactionTypeIncome = 'INCOME';
  
  // Status
  static const String statusPending = 'PENDING';
  static const String statusSettled = 'SETTLED';
  static const String statusCancelled = 'CANCELLED';
  static const String statusReceived = 'RECEIVED';
  static const String statusPaid = 'PAID';
  
  // Paid Relationship
  static const String paidFor = 'PAID_FOR';
  static const String paidBy = 'PAID_BY';
  
  // Category Types
  static const String categoryTypeExpense = 'EXPENSE';
  static const String categoryTypeIncome = 'INCOME';
  
  // WhatsApp
  static const String whatsappBaseUrl = 'https://wa.me/';
  static const String whatsappMessageTemplate = '''
{message}

📱 Track with FlowPaisa
👉 {deepLink}''';
  
  // Premium Features
  static const String premiumProductId = 'flowpaisa_premium_monthly';
  
  // Google Drive
  static const String driveBackupFolder = 'appDataFolder';
  static const String driveBackupFilename = 'flowpaisa_backup';
  
  // Limits
  static const int maxCategoryNameLength = 100;
  static const int maxContactNameLength = 200;
  static const int maxDescriptionLength = 500;
  
  // Pagination
  static const int transactionsPerPage = 50;
  
  // Analytics
  static const int dashboardTopContactsLimit = 5;
  static const int recentSuggestionsLimit = 10;
}


