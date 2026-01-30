// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'کیش بک';

  @override
  String get cashbooks => 'کیش بکس';

  @override
  String get transactions => 'لین دین';

  @override
  String get settings => 'سیٹنگز';

  @override
  String get totalBalance => 'کل بیلنس';

  @override
  String get income => 'آمدنی';

  @override
  String get expense => 'خرچہ';

  @override
  String get addTransaction => 'لین دین شامل کریں';

  @override
  String get editTransaction => 'لین دین میں ترمیم کریں';

  @override
  String get scheduleCreated => 'شیڈول کامیابی سے تیار ہو گیا';

  @override
  String get transactionUpdated => 'لین دین کامیابی سے اپ ڈیٹ ہو گیا';

  @override
  String get updateTransaction => 'لین دین اپ ڈیٹ کریں';

  @override
  String get amount => 'رقم';

  @override
  String get category => 'زمرہ';

  @override
  String get date => 'تاریخ';

  @override
  String get description => 'تفصیل';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get cancel => 'منسوخ کریں';

  @override
  String get delete => 'حذف کریں';

  @override
  String get payable => 'قابل ادائیگی';

  @override
  String createdLabel(String date) {
    return 'تخلیق شدہ: $date';
  }

  @override
  String get defaultPremiumPrice => 'Rs. 2500';

  @override
  String errorOccurred(String error) {
    return 'غلطی: $error';
  }

  @override
  String get noDataForTrends => 'رجحانات کے لیے کوئی ڈیٹا نہیں ہے';

  @override
  String get cancelled => 'منسوخ کر دیا گیا';

  @override
  String minutesAgo(int minutes) {
    return '$minutes منٹ پہلے';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours گھنٹے پہلے';
  }

  @override
  String daysAgo(int days) {
    return '$days دن پہلے';
  }

  @override
  String sample(String sample) {
    return 'نمونہ: $sample';
  }

  @override
  String positiveAmount(String amount) {
    return 'مثبت: $amount';
  }

  @override
  String negativeAmount(String amount) {
    return 'منفی: $amount';
  }

  @override
  String themeSet(String name) {
    return 'تھیم $name پر سیٹ کر دی گئی';
  }

  @override
  String languageChanged(String name) {
    return 'زبان تبدیل کر کے $name کر دی گئی';
  }

  @override
  String lastBackupAt(String time) {
    return 'آخری بیک اپ: $time';
  }

  @override
  String restoreFailed(String error) {
    return 'بحالی ناکام ہو گئی: $error';
  }

  @override
  String errorSaving(String error) {
    return 'محفوظ کرنے میں غلطی: $error';
  }

  @override
  String errorSharing(String error) {
    return 'شیئر کرنے میں غلطی: $error';
  }

  @override
  String errorExporting(String error) {
    return 'ایکسپورٹ کرنے میں غلطی: $error';
  }

  @override
  String exportSavedTo(String path) {
    return 'ایکسپورٹ $path میں محفوظ ہو گیا';
  }

  @override
  String notificationTitlePrefix(String title) {
    return 'اطلاع: $title';
  }

  @override
  String errorDeletingTransaction(String error) {
    return 'لین دین حذف کرنے میں غلطی: $error';
  }

  @override
  String noTypeCategories(String type) {
    return 'کوئی $type زمرہ جات نہیں ہیں';
  }

  @override
  String deleteCashbookMessage(String name) {
    return 'کیا آپ واقعی \"$name\" کو حذف کرنا چاہتے ہیں؟ یہ اس کیش بک سے وابستہ تمام ڈیٹا کو مستقل طور پر حذف کر دے گا۔';
  }

  @override
  String currencySetTo(String name) {
    return 'کرنسی $name پر سیٹ کر دی گئی';
  }

  @override
  String confirmDelete(String item) {
    return 'کیا آپ واقعی اس $item کو حذف کرنا چاہتے ہیں؟';
  }

  @override
  String get search => 'تلاش کریں';

  @override
  String get searchTransactions => 'Search transactions...';

  @override
  String get noTransactions => 'کوئی لین دین نہیں ملا';

  @override
  String get selectCategory => 'زمرہ منتخب کریں';

  @override
  String get all => 'تمام';

  @override
  String get today => 'آج';

  @override
  String get yesterday => 'کل';

  @override
  String get thisMonth => 'اس ماہ';

  @override
  String get lastMonth => 'گزشتہ ماہ';

  @override
  String get customRange => 'حسب ضرورت حد';

  @override
  String get currency => 'کرنسی';

  @override
  String get language => 'زبان';

  @override
  String get theme => 'تھیم';

  @override
  String get light => 'لائٹ';

  @override
  String get dark => 'ڈارک';

  @override
  String get system => 'سسٹم';

  @override
  String get hindi => 'ہندی';

  @override
  String get english => 'انگریزی';

  @override
  String get urdu => 'اردو';

  @override
  String get cashbookName => 'کیش بک کا نام';

  @override
  String get createCashbook => 'کیش بک بنائیں';

  @override
  String get editCashbook => 'کیش بک میں ترمیم کریں';

  @override
  String get deleteCashbook => 'کیش بک حذف کریں';

  @override
  String get cashbookDeleted => 'کیش بک کامیابی سے حذف کر دی گئی';

  @override
  String get cashbookAdded => 'کیش بک کامیابی سے شامل کر دی گئی';

  @override
  String get cashbookUpdated => 'کیش بک کامیابی سے اپ ڈیٹ کر دی گئی';

  @override
  String get pleaseEnterName => 'براہ کرم نام درج کریں';

  @override
  String get copyPreferences => 'ترجیحات کاپی کریں';

  @override
  String get copyPreferencesFrom => 'ترجیحات یہاں سے کاپی کریں';

  @override
  String get copyPreferencesSubtitle =>
      'زمرہ جات اور ترجیحات منتخب کردہ کیش بک سے کاپی کی جائیں گی۔';

  @override
  String get none => 'کوئی نہیں';

  @override
  String get howMuch => 'کتنی رقم؟';

  @override
  String get amountHint => '0.00';

  @override
  String get pleaseEnterAmount => 'براہ کرم رقم درج کریں';

  @override
  String get pleaseEnterValidNumber => 'براہ کرم درست نمبر درج کریں';

  @override
  String get amountGreaterThanZero => 'رقم 0 سے زیادہ ہونی چاہیے';

  @override
  String get contact => 'رابطہ';

  @override
  String get selectContact => 'رابطہ منتخب کریں';

  @override
  String get addNew => 'نیا شامل کریں';

  @override
  String get descriptionHint => 'مثلاً دوپہر کے کھانے کے پیسے';

  @override
  String get premiumFeature => 'پریمیم فیچر';

  @override
  String get premiumRequired => 'اس فیچر کے لیے پریمیم سبسکرپشن درکار ہے۔';

  @override
  String get getPremium => 'پریمیم حاصل کریں';

  @override
  String switchedToCashbook(String name) {
    return '$name پر منتقل ہو گئے';
  }

  @override
  String get categoryFood => 'خوراک';

  @override
  String get categoryTransport => 'نقل و حمل';

  @override
  String get categoryShopping => 'شاپنگ';

  @override
  String get categoryBills => 'بل';

  @override
  String get categoryEntertainment => 'تفریح';

  @override
  String get categoryHealth => 'صحت';

  @override
  String get categorySalary => 'تنخواہ';

  @override
  String get categoryBusiness => 'کاروبار';

  @override
  String get categoryInvestment => 'سرمایہ کاری';

  @override
  String get categoryRent => 'کرایہ';

  @override
  String get categoryOther => 'دیگر';

  @override
  String get statusPending => 'زیر التواء';

  @override
  String get statusCompleted => 'مکمل ہو گیا';

  @override
  String get statusCancelled => 'منسوخ کر دیا گیا';

  @override
  String get receivables => 'وصولی';

  @override
  String get pending => 'زیر التواء';

  @override
  String get overdue => 'واجب الادا تاریخ گزر گئی';

  @override
  String get receivedLabel => 'وصول شدہ';

  @override
  String get generateDummyReceivables => '100 فرضی وصولیاں بنائیں';

  @override
  String dummyGenerated(int count) {
    return '$count فرضی اشیاء بنائی گئیں';
  }

  @override
  String get errorLoadingReceivables => 'وصولیاں لوڈ کرنے میں غلطی';

  @override
  String get retry => 'دوبارہ کوشش کریں';

  @override
  String get noPendingReceivables => 'کوئی زیر التواء وصولی نہیں ہے';

  @override
  String get noOverdueReceivables => 'کوئی واجب الادا وصولی نہیں ہے';

  @override
  String get noReceivedPayments => 'کوئی وصول شدہ ادائیگی نہیں ہے';

  @override
  String get addReceivableSubtitle =>
      'اپنی واجب الادا رقم کو ٹریک کرنے کے لیے وصولی شامل کریں';

  @override
  String get receivablesUpToDate => 'تمام وصولیاں اپ ٹو ڈیٹ ہیں';

  @override
  String get markReceivedSubtitle =>
      'زیر التواء وصولیوں کو وصول شدہ کے طور پر نشان زد کریں';

  @override
  String get noMoreItems => 'مزید اشیاء نہیں ہیں';

  @override
  String get receivableDeleted => 'وصولی حذف کر دی گئی';

  @override
  String get unknown => 'نامعلوم';

  @override
  String dueAt(String date) {
    return 'واجب الادا: $date';
  }

  @override
  String get receivable => 'وصولی';

  @override
  String get addReceivable => 'وصولی شامل کریں';

  @override
  String get receivableAlreadyImported =>
      'یہ وصولی پہلے ہی درآمد کی جا چکی ہے۔';

  @override
  String get pleaseSelectContact => 'براہ کرم ایک رابطہ منتخب کریں';

  @override
  String get receivableAdded => 'وصولی کامیابی سے شامل ہو گئی';

  @override
  String get share => 'شیئر کریں';

  @override
  String get dueDateOptional => 'واجب الادا تاریخ (اختیاری)';

  @override
  String get notSet => 'سیٹ نہیں ہے';

  @override
  String get autoCreateIncome => 'خودکار طور پر آمدنی بنائیں';

  @override
  String get autoCreateIncomeSubtitle =>
      'وصول شدہ کے طور پر نشان زد ہونے پر آمدنی کے طور پر ریکارڈ کریں';

  @override
  String get receivableNotFound => 'وصولی نہیں ملی';

  @override
  String get receivableUpdated => 'وصولی کامیابی سے اپ ڈیٹ ہو گئی';

  @override
  String get editReceivable => 'وصولی میں ترمیم کریں';

  @override
  String get receivableDetails => 'وصولی کی تفصیلات';

  @override
  String get edit => 'ترمیم کریں';

  @override
  String get receivablePending => 'وصولی (زیر التواء)';

  @override
  String get dueDate => 'واجب الادا تاریخ';

  @override
  String get linkedTransaction => 'منسلک لین دین';

  @override
  String get markAsReceived => 'وصول شدہ کے طور پر نشان زد کریں';

  @override
  String get deleteReceivableTitle => 'وصولی حذف کریں';

  @override
  String get deleteReceivableMessage =>
      'کیا آپ واقعی اس وصولی کو حذف کرنا چاہتے ہیں؟ اس عمل کو واپس نہیں لیا جا سکتا۔';

  @override
  String get markedAsReceived => 'وصول شدہ کے طور پر نشان زد کر دیا گیا';

  @override
  String get informContactSettlement =>
      'وصولی وصول شدہ کے طور پر نشان زد کر دی گئی۔ رابطہ کو مطلع کریں؟';

  @override
  String addContactWithName(String name) {
    return '$name شامل کریں';
  }

  @override
  String get payables => 'واجب الادا';

  @override
  String get generateDummyPayables => '100 فرضی واجبات بنائیں';

  @override
  String get dummyPayablesGenerated => '100 فرضی واجبات بنائی گئیں';

  @override
  String get errorLoadingPayables => 'واجبات لوڈ کرنے میں غلطی';

  @override
  String get noPendingPayables => 'کوئی زیر التواء واجبات نہیں ہے';

  @override
  String get noOverduePayables => 'کوئی واجب الادا ادائیگی نہیں ہے';

  @override
  String get noPaidBills => 'کوئی ادا شدہ بل نہیں ہے';

  @override
  String get addPayableSubtitle =>
      'اپنی واجب الادا رقم کو ٹریک کرنے کے لیے ادائیگی شامل کریں';

  @override
  String get allPayablesUpToDate => 'تمام واجبات اپ ٹو ڈیٹ ہیں';

  @override
  String get markPendingAsPaidSubtitle =>
      'زیر التواء واجبات کو ادا شدہ کے طور پر نشان زد کریں';

  @override
  String get noMorePayables => 'مزید واجبات نہیں ہیں';

  @override
  String get payableDeleted => 'واجب الادا حذف کر دیا گیا';

  @override
  String get payableAlreadyImported =>
      'یہ واجب الادا پہلے ہی درآمد کیا جا چکا ہے۔';

  @override
  String get payableAdded => 'واجب الادا کامیابی سے شامل ہو گیا';

  @override
  String get addPayable => 'واجب الادا شامل کریں';

  @override
  String get editPayable => 'واجب الادا میں ترمیم کریں';

  @override
  String get payableNotFound => 'واجب الادا نہیں ملا';

  @override
  String get payableDataNotLoaded => 'واجب الادا ڈیٹا لوڈ نہیں ہوا';

  @override
  String get payableUpdated => 'واجب الادا کامیابی سے اپ ڈیٹ ہو گیا';

  @override
  String get updatePayable => 'واجب الادا اپ ڈیٹ کریں';

  @override
  String get payableDetails => 'واجب الادا تفصیلات';

  @override
  String get payablePending => 'واجب الادا (زیر التواء)';

  @override
  String get paid => 'ادا شدہ';

  @override
  String get markAsPaid => 'ادا شدہ کے طور پر نشان زد کریں';

  @override
  String get deletePayableTitle => 'واجب الادا حذف کریں';

  @override
  String get deletePayableMessage =>
      'کیا آپ واقعی اس واجب الادا کو حذف کرنا چاہتے ہیں؟ اس عمل کو واپس نہیں لیا جا سکتا۔';

  @override
  String get markedAsPaid => 'ادا شدہ کے طور پر نشان زد کر دیا گیا';

  @override
  String get informContactSettlementPayable =>
      'واجب الادا رقم کی ادائیگی نشان زد کر دی گئی۔ رابطہ کو مطلع کریں؟';

  @override
  String get autoCreateExpense => 'خودکار طور پر خرچہ بنائیں';

  @override
  String get autoCreateExpenseSubtitle =>
      'ادا شدہ کے طور پر نشان زد ہونے پر خرچے کے طور پر ریکارڈ کریں';

  @override
  String get appRefreshLanguage =>
      'نئی زبان لاگو کرنے کے لیے ایپ ری فریش ہو جائے گی';

  @override
  String get profile => 'پروفائل';

  @override
  String get changePhoto => 'فوٹو تبدیل کریں';

  @override
  String get photoUploadComingSoon => 'فوٹو اپ لوڈ کی سہولت جلد آ رہی ہے!';

  @override
  String get name => 'نام';

  @override
  String get enterName => 'اپنا نام درج کریں';

  @override
  String get email => 'ای میل';

  @override
  String get enterEmail => 'اپنا ای میل درج کریں';

  @override
  String get enterValidEmail => 'براہ کرم درست ای میل درج کریں';

  @override
  String get phoneNumber => 'فون نمبر';

  @override
  String get enterPhoneNumber => 'اپنا فون نمبر درج کریں';

  @override
  String get address => 'پتہ';

  @override
  String get enterAddress => 'اپنا پتہ درج کریں';

  @override
  String get preferences => 'ترجیحات';

  @override
  String get dateFormat => 'تاریخ کا فارمیٹ';

  @override
  String get saveProfile => 'پروفائل محفوظ کریں';

  @override
  String get profileUpdated => 'پروفائل کامیابی سے اپ ڈیٹ ہو گیا';

  @override
  String get selectDateFormat => 'تاریخ کا فارمیٹ منتخب کریں';

  @override
  String get customFormat => 'حسب ضرورت فارمیٹ';

  @override
  String get enterCustomDateFormat => 'اپنا تاریخ کا فارمیٹ پیٹرن درج کریں';

  @override
  String get customDateFormat => 'حسب ضرورت تاریخ کا فارمیٹ';

  @override
  String get formatPattern => 'فارمیٹ پیٹرن';

  @override
  String get dateFormatInstructions =>
      'معیاری ICU پیٹرن استعمال کریں جیسے:\ndd: دن, MM: مہینہ, yyyy: سال\nMMM: مختصر مہینہ, EEEE: مکمل دن';

  @override
  String get lightThemeDescription => 'ہمیشہ لائٹ تھیم استعمال کریں';

  @override
  String get darkThemeDescription => 'ہمیشہ ڈارک تھیم استعمال کریں';

  @override
  String get systemThemeDescription => 'ڈیوائس کی سیٹنگز کے مطابق';

  @override
  String get themeChangesApplyImmediately =>
      'تھیم کی تبدیلیاں فوری لاگو ہوتی ہیں';

  @override
  String get analytics => 'تجزیات';

  @override
  String get exportAnalyticsPDF => 'تجزیات پی ڈی ایف ایکسپورٹ کریں';

  @override
  String get refreshAnalytics => 'تجزیات ری فریش کریں';

  @override
  String get financialSummary => 'مالی خلاصہ';

  @override
  String get contactSummaries => 'رابطہ خلاصہ';

  @override
  String get expensesByCategory => 'زمرہ کے لحاظ سے اخراجات';

  @override
  String get incomeVsExpenseTrend => 'آمدنی بنام خرچہ رجحان';

  @override
  String get payablesVsReceivablesTrend => 'واجبات بنام وصولی رجحان';

  @override
  String get topContactsByBalance => 'بیلنس کے لحاظ سے ٹاپ رابطے';

  @override
  String get paymentStatusDistribution => 'ادائیگی کی صورتحال کی تقسیم';

  @override
  String get incomeByCategory => 'زمرہ کے لحاظ سے آمدنی';

  @override
  String get unlockAdvancedAnalytics =>
      'پریمیم کے ساتھ ایڈوانس تجزیات، رجحانات اور چارٹس ان لاک کریں۔';

  @override
  String get unlockPremium => 'پریمیم حاصل کریں';

  @override
  String get noContactActivity => 'اس مدت کے لیے کوئی رابطہ سرگرمی نہیں ہے';

  @override
  String get settled => 'تصفیہ ہو گیا';

  @override
  String get noExpensesPeriod => 'اس مدت کے لیے کوئی اخراجات نہیں ہیں';

  @override
  String get noDataTrends => 'رجحانات کے لیے کوئی ڈیٹا نہیں ہے';

  @override
  String get noPayableReceivableData => 'کوئی واجبات/وصولی کا ڈیٹا نہیں ہے';

  @override
  String get noContactData => 'رابطے کا کوئی ڈیٹا نہیں ہے';

  @override
  String get noPaymentStatusData => 'ادائیگی کی حیثیت کا کوئی ڈیٹا نہیں ہے';

  @override
  String get noIncome => 'اس مدت کے لیے کوئی آمدنی نہیں ہے';

  @override
  String get pdfReady => 'پی ڈی ایف تیار ہے';

  @override
  String get analyticsPDFReadyMessage =>
      'آپ کی تجزیاتی پی ڈی ایف رپورٹ تیار ہے۔ کوئی عمل منتخب کریں:';

  @override
  String get saveCopy => 'کاپی محفوظ کریں';

  @override
  String get preview => 'پیش نظارہ';

  @override
  String get savedToDownloads => 'ڈاؤن لوڈز میں محفوظ ہو گیا';

  @override
  String get month => 'مہینہ';

  @override
  String get quarter => 'سه ماہی';

  @override
  String get year => 'سال';

  @override
  String get custom => 'حسب ضرورت';

  @override
  String get payableShort => 'قابل ادائیگی:';

  @override
  String get receivableShort => 'وصولی:';

  @override
  String get netBalance => 'خالص بیلنس';

  @override
  String get allTime => 'کل وقت:';

  @override
  String get expenses => 'اخراجات';

  @override
  String get noExpenses => 'اس مدت کے لیے کوئی اخراجات نہیں ہیں';

  @override
  String get expanded => 'پھیلا ہوا';

  @override
  String get collapsed => 'سُکڑا ہوا';

  @override
  String get notifications => 'اطلاعات';

  @override
  String get allNotificationsMarkedRead =>
      'تمام اطلاعات کو پڑھا ہوا نشان زد کر دیا گیا';

  @override
  String get markAllRead => 'سب کو پڑھا ہوا نشان زد کریں';

  @override
  String get noNotifications => 'کوئی اطلاع نہیں';

  @override
  String get noNotificationsDescription =>
      'آپ سب اپ ٹو ڈیٹ ہیں! ہم آپ کو مطلع کریں گے:\n\n• واجب الادا وصولیاں اور ادائیگیاں\n• لین دین کے اہم سنگ میل\n• بیک اپ ریمائنڈرز\n• اہم اپ ڈیٹس';

  @override
  String get notificationsTip =>
      'ٹپ: بروقت ریمائنڈرز حاصل کرنے کے لیے وصولیوں اور ادائیگیوں کے لیے واجب الادا تاریخیں مقرر کریں';

  @override
  String get justNow => 'ابھی';

  @override
  String get toggledDebugMode => 'ڈیبگ موڈ ٹوگل کر دیا گیا';

  @override
  String get debugToggleMode => 'ڈیبگ: موڈ ٹوگل کریں';

  @override
  String get premiumTitle => 'فلوپیسہ پریمیم';

  @override
  String get unlockAllFeatures => 'تمام فیچرز ان لاک کریں';

  @override
  String get premiumMemberStatus => 'آپ پریمیم ممبر ہیں';

  @override
  String get premiumFeaturesActive => 'تمام پریمیم فیچرز فعال ہیں';

  @override
  String get featureCloudBackupTitle => 'خودکار کلاؤڈ بیک اپ';

  @override
  String get featureCloudBackupDesc =>
      'آپ کا ڈیٹا خودکار طور پر گوگل ڈرائیو پر بیک اپ ہو جاتا ہے۔ اپنے مالی ریکارڈز کبھی ضائع نہ کریں۔';

  @override
  String get featureAnalyticsTitle => 'ایڈوانس تجزیات';

  @override
  String get featureAnalyticsDesc =>
      'ایڈوانس چارٹس، رجحانات اور مالیاتی پیشن گوئی کے ساتھ تفصیلی بصیرت حاصل کریں۔';

  @override
  String get featurePdfReportsTitle => 'پی ڈی ایف رپورٹس';

  @override
  String get featurePdfReportsDesc =>
      'کسی بھی تاریخ کی حد کے لیے چارٹس اور خلاصوں کے ساتھ خوبصورت پی ڈی ایف رپورٹس بنائیں۔';

  @override
  String get featureUnlimitedTitle => 'لامحدود لین دین';

  @override
  String get featureUnlimitedDesc =>
      'لین دین، رابطوں یا زمرہ جات کی تعداد پر کوئی پابندی نہیں ہے۔';

  @override
  String get featureSupportTitle => 'ترجیحی سپورٹ';

  @override
  String get featureSupportDesc =>
      'کسی بھی مسئلے یا سوال کے لیے تیز تر جوابات اور سرشار سپورٹ حاصل کریں۔';

  @override
  String get featureEarlyAccessTitle => 'قبل از وقت رسائی';

  @override
  String get featureEarlyAccessDesc =>
      'سب کے لیے جاری ہونے سے پہلے نئے فیچرز آزمانے والے پہلے فرد بنیں۔';

  @override
  String get featureTemplatesTitle => 'حسب ضرورت میسج ٹیمپلیٹس';

  @override
  String get featureTemplatesDesc =>
      'کئی زبانوں میں یاد دہانیوں، رسیدوں اور شیئرنگ کے لیے واٹس ایپ میسج ٹیمپلیٹس کو حسب ضرورت بنائیں۔';

  @override
  String get featureMultiDeviceSyncTitle => 'ملٹی ڈیوائس سنک';

  @override
  String get featureMultiDeviceSyncDesc =>
      'گوگل ڈرائیو کا استعمال کرتے ہوئے اپنے تمام آلات پر اپنا ڈیٹا سنک کریں۔ آپ کے ریکارڈ ہمیشہ اپ ٹو ڈیٹ رہتے ہیں۔';

  @override
  String get featureMultipleCashbooksTitle => 'لامحدود کیش بکس';

  @override
  String get featureMultipleCashbooksDesc =>
      'مختلف کاروباروں یا ذاتی استعمال کے لیے جتنی ضرورت ہو اضافی کیش بکس بنائیں اور ان کا انتظام کریں۔';

  @override
  String get featureUnlimitedSchedulesTitle => 'لامحدود شیڈولز';

  @override
  String get featureUnlimitedSchedulesDesc =>
      'اپنی باقاعدہ آمدنی اور اخراجات کے لیے لامحدود بار بار ہونے والے لین دین کے شیڈولز ترتیب دیں۔';

  @override
  String get premiumPlan => 'پریمیم پلان';

  @override
  String get lifetime => 'تاحیات';

  @override
  String get monthly => 'ماہانہ';

  @override
  String get yearly => 'سالانہ';

  @override
  String get bestValue => 'بہترین قیمت';

  @override
  String get chooseYourPlan => 'اپنا پلان منتخب کریں';

  @override
  String get cancelAnytime => 'کسی بھی وقت منسوخ کریں';

  @override
  String savePercentage(Object percentage) {
    return '$percentage% بچائیں';
  }

  @override
  String get oneTimePayment => 'ایک بار ادائیگی کریں، ہمیشہ کے لیے اپنائیں';

  @override
  String get recommended => 'تجویز کردہ';

  @override
  String get subscribeNow => 'ابھی سبسکرائب کریں';

  @override
  String get oneTimePaymentLifetime => 'ایک بار ادائیگی • تاحیات رسائی';

  @override
  String get processing => 'پروسیسنگ...';

  @override
  String get restorePurchases => 'خریداری بحال کریں';

  @override
  String get premiumBenefitsNote =>
      'اپنے منتخب کردہ پلان کے ساتھ تمام پریمیم فیچرز ان لاک کریں۔ مستقل رسائی کے لیے لائف ٹائم منتخب کریں!';

  @override
  String get active => 'فعال';

  @override
  String get googleDriveBackup => 'گوگل ڈرائیو بیک اپ';

  @override
  String get cloudBackupPremiumDesc =>
      'گوگل ڈرائیو پر کلاؤڈ بیک اپ پریمیم صارفین کے لیے دستیاب ہے۔';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signInGoogleToBackup =>
      'اپنے ڈیٹا کا بیک اپ لینے کے لیے گوگل کے ساتھ سائن ان کریں';

  @override
  String get signInGoogle => 'گوگل کے ساتھ سائن ان کریں';

  @override
  String get googleServicesNote =>
      'نوٹ: بیک اپ کے لیے درست گوگل سروسز کنفیگریشن درکار ہے۔ اگر سائن ان ناکام ہو جائے تو اپنا سیٹ اپ چیک کریں۔';

  @override
  String get backupNow => 'ابھی بیک اپ لیں';

  @override
  String get noBackupsFound => 'کوئی بیک اپ نہیں ملا';

  @override
  String get availableBackups => 'دستیاب بیک اپ';

  @override
  String get restoreBackupTitle => 'بیک اپ بحال کریں؟';

  @override
  String get restoreBackupMessage =>
      'یہ آپ کے موجودہ ڈیٹا کو منتخب کردہ بیک اپ سے بدل دے گا۔ \n\n⚠️ بحالی کے بعد ایپ کو ری اسٹارٹ کرنے کی ضرورت ہوگی۔';

  @override
  String get restore => 'بحال کریں';

  @override
  String get restoreSuccessful => 'بحالی کامیاب';

  @override
  String get restoreSuccessfulMessage =>
      'ڈیٹا کامیابی سے بحال ہو گیا۔ تبدیلیاں لاگو کرنے کے لیے براہ کرم ایپ کو بند کر کے دوبارہ چلائیں۔';

  @override
  String get ok => 'ٹھیک ہے';

  @override
  String get categories => 'زمرہ جات';

  @override
  String get categoryHiddenSuccessfully => 'زمرہ کامیابی سے چھپا دیا گیا';

  @override
  String get categoryDeletedSuccessfully => 'زمرہ کامیابی سے حذف کر دیا گیا';

  @override
  String get defaultLabel => 'ڈیفالٹ';

  @override
  String get addCategory => 'زمرہ شامل کریں';

  @override
  String get categoryName => 'زمرہ کا نام';

  @override
  String get suggestedIcons => 'تجویز کردہ آئیکنز';

  @override
  String get color => 'رنگ';

  @override
  String get allIcons => 'تمام آئیکنز';

  @override
  String get saveCategory => 'زمرہ محفوظ کریں';

  @override
  String get categoryAddedSuccessfully => 'زمرہ کامیابی سے شامل ہو گیا';

  @override
  String get editCategory => 'زمرہ میں ترمیم کریں';

  @override
  String get categoryUpdatedSuccessfully => 'زمرہ کامیابی سے اپ ڈیٹ ہو گیا';

  @override
  String get failedToUpdateCategory => 'زمرہ اپ ڈیٹ کرنے میں ناکامی';

  @override
  String get expenseCategory => 'اخراجات کا زمرہ';

  @override
  String get incomeCategory => 'آمدنی کا زمرہ';

  @override
  String get updateCategory => 'زمرہ اپ ڈیٹ کریں';

  @override
  String get searchContacts => 'رابطے تلاش کریں...';

  @override
  String get contacts => 'رابطے';

  @override
  String get noContactsYet => 'ابھی تک کوئی رابطہ نہیں ہے';

  @override
  String get noContactsFound => 'کوئی رابطہ نہیں ملا';

  @override
  String get addPeopleToTrack =>
      'اخراجات کو ٹریک کرنے کے لیے لوگوں کو شامل کریں';

  @override
  String get trySearchingDifferentName =>
      'کسی مختلف نام سے تلاش کرنے کی کوشش کریں';

  @override
  String get addContact => 'رابطہ شامل کریں';

  @override
  String get contactDeletedSuccessfully => 'رابطہ کامیابی سے حذف کر دیا گیا';

  @override
  String get contactPermissionDenied =>
      'رابطہ کی اجازت مسترد کر دی گئی۔ براہ کرم اسے ترتیبات میں فعال کریں۔';

  @override
  String errorPickingContact(String error) {
    return 'رابطہ منتخب کرنے میں خرابی: $error';
  }

  @override
  String get selectPhoneNumber => 'فون نمبر منتخب کریں';

  @override
  String get contactUpdatedSuccessfully => 'رابطہ کامیابی سے اپ ڈیٹ ہو گیا';

  @override
  String get contactAddedSuccessfully => 'رابطہ کامیابی سے شامل ہو گیا';

  @override
  String get editContact => 'رابطہ میں ترمیم کریں';

  @override
  String get importFromContacts => 'رابطوں سے درآمد کریں';

  @override
  String get phoneNumberOptional => 'فون نمبر (اختیاری)';

  @override
  String get emailOptional => 'ای میل (اختیاری)';

  @override
  String get addressNotesOptional => 'پتہ / نوٹس (اختیاری)';

  @override
  String get updateContact => 'رابطہ اپ ڈیٹ کریں';

  @override
  String get saveContact => 'رابطہ محفوظ کریں';

  @override
  String get myCashbooks => 'میری کیش بکس';

  @override
  String get manageCashbooks => 'متعدد کیش بکس کا انتظام کریں';

  @override
  String get manageContacts => 'اپنے رابطوں کا انتظام کریں';

  @override
  String get manageCategories => 'اخراجات اور آمدنی کے زمروں کا انتظام کریں';

  @override
  String get manageCurrencies => 'کرنسیوں کا انتظام کریں';

  @override
  String get googleDriveBackupRestore => 'گوگل ڈرائیو بیک اپ اور بحالی';

  @override
  String get messageTemplates => 'میسج ٹیمپلیٹس';

  @override
  String get customizeMessageTemplates =>
      'واٹس ایپ میسج ٹیمپلیٹس کو حسب ضرورت بنائیں';

  @override
  String get exportData => 'ڈیٹا ایکسپورٹ کریں';

  @override
  String get downloadDataCsvPdf =>
      'اپنا ڈیٹا CSV یا PDF کے طور پر ڈاؤن لوڈ کریں';

  @override
  String get premiumActive => 'پریمیم فعال ہے';

  @override
  String get about => 'ایپ کے بارے میں';

  @override
  String get tagline => 'ہر پیسے کا حساب رکھیں';

  @override
  String versionInfo(String version, String buildNumber) {
    return 'ورژن $version (بلڈ $buildNumber)';
  }

  @override
  String get appDescription =>
      'FlowPaisa ایک جامع ذاتی مالیات اور کیش فلو مینیجر ہے۔ اپنے اخراجات، آمدنی، وصولی اور واجب الادا رقوم کو ایک ہی جگہ پر ٹریک کریں۔ خصوصیات میں رسید اسکیننگ، واٹس ایپ انٹیگریشن، کلاؤڈ بیک اپ، اور خوبصورت تجزیات شامل ہیں۔';

  @override
  String get openSourceLicenses => 'اوپن سورس لائسنس';

  @override
  String get developedBy => 'تیار کردہ از';

  @override
  String get developerName => 'TamataSoft';

  @override
  String get copyright => '© 2026 TamataSoft. جملہ حقوق محفوظ ہیں۔';

  @override
  String get receiptScan => 'رسید اسکین';

  @override
  String get cloudBackup => 'کلاؤڈ بیک اپ';

  @override
  String get multilingual => 'کثیر لسانی';

  @override
  String get availableCash => 'دستیاب رقم';

  @override
  String get quickActions => 'فوری کارروائیاں';

  @override
  String get add => 'شامل کریں';

  @override
  String get scan => 'اسکین';

  @override
  String get recentTransactions => 'حالیہ لین دین';

  @override
  String get viewAll => 'تمام دیکھیں';

  @override
  String get noTransactionsYet => 'ابھی تک کوئی لین دین نہیں ہے';

  @override
  String get tapToAddFirst =>
      'اپنا پہلا لین دین شامل کرنے کے لیے + پر ٹیپ کریں';

  @override
  String get cashFlow => 'کیش فلو';

  @override
  String get netCash => 'خالص رقم';

  @override
  String get lendingCredit => 'ادھار اور کریڈٹ';

  @override
  String get netCredit => 'خالص کریڈٹ';

  @override
  String get receive => 'وصول کریں';

  @override
  String get messageTemplatesDesc =>
      'میسج ٹیمپلیٹس کو حسب ضرورت بنانا پریمیم صارفین کے لیے دستیاب ہے۔';

  @override
  String get upgradeToPremium => 'پریمیم میں اپ گریڈ کریں';

  @override
  String get receivableReminders => 'وصولی کی یاد دہانیاں';

  @override
  String get pendingReceivable => 'زیر التواء وصولی';

  @override
  String get receivedPayment => 'وصول شدہ ادائیگی';

  @override
  String get payableReminders => 'واجب الادا یاد دہانیاں';

  @override
  String get pendingPayable => 'زیر التواء واجبات';

  @override
  String get paidPayable => 'ادا شدہ واجبات';

  @override
  String get transactionMessages => 'لین دین کے پیغامات';

  @override
  String get transactionReceipt => 'لین دین کی رسید';

  @override
  String get transactionSharePaidFor => 'لین دین شیئر - ادا کیا گیا';

  @override
  String get transactionSharePaidBy => 'لین دین شیئر - ادا کیا گیا بذریعہ';

  @override
  String get transactionShareWillReceive => 'لین دین شیئر - موصول ہوگا';

  @override
  String get transactionShareReceivedFrom => 'لین دین شیئر - موصول ہوا از';

  @override
  String get transactionShareGeneric => 'لین دین شیئر - عمومی';

  @override
  String get shareMessages => 'شیئر پیغامات';

  @override
  String get receivableSharePending => 'وصولی شیئر - زیر التواء';

  @override
  String get receivableShareReceived => 'وصولی شیئر - وصول شدہ';

  @override
  String get payableSharePending => 'واجبات شیئر - زیر التواء';

  @override
  String get payableSharePaid => 'واجبات شیئر - ادا شدہ';

  @override
  String get resetToDefault => 'ڈیفالٹ پر ری سیٹ کریں';

  @override
  String get resetTemplateTitle => 'ٹیمپلیٹ ری سیٹ کریں';

  @override
  String get resetTemplateMessage =>
      'کیا آپ واقعی اس ٹیمپلیٹ کو ڈیفالٹ پر ری سیٹ کرنا چاہتے ہیں؟ اس عمل کو واپس نہیں لیا جا سکتا۔';

  @override
  String get templateSaved => 'ٹیمپلیٹ کامیابی سے محفوظ ہو گیا';

  @override
  String get templateReset => 'ٹیمپلیٹ ڈیفالٹ پر ری سیٹ ہو گیا';

  @override
  String get enterTemplateText => 'ٹیمپلیٹ ٹیکسٹ درج کریں...';

  @override
  String useVariableHint(Object variableName) {
    return 'حرکی مواد کے لیے $variableName استعمال کریں';
  }

  @override
  String get saveTemplate => 'ٹیمپلیٹ محفوظ کریں';

  @override
  String get availableVariables => 'دستیاب متغیرات';

  @override
  String get variablesInstructions =>
      'آپ اپنے ٹیمپلیٹس میں یہ متغیرات استعمال کر سکتے ہیں:';

  @override
  String variableContactName(Object contactName) {
    return '• $contactName - رابطے کا نام';
  }

  @override
  String variableAmount(Object amount) {
    return '• $amount - کرنسی کے ساتھ فارمیٹ شدہ رقم';
  }

  @override
  String variableDescription(Object description) {
    return '• $description - لین دین/وصولی/واجبات کی تفصیل';
  }

  @override
  String variableDate(Object date) {
    return '• $date - فارمیٹ شدہ تاریخ';
  }

  @override
  String variableDueDate(Object dueDate) {
    return '• $dueDate - فارمیٹ شدہ واجب الادا تاریخ';
  }

  @override
  String variableCategoryName(Object categoryName) {
    return '• $categoryName - زمرہ کا نام';
  }

  @override
  String variableLink(Object link) {
    return '• $link - ڈیپ لنک یو آر ایل';
  }

  @override
  String variableType(Object type) {
    return '• $type - لین دین کی قسم (آمدنی/خرچہ)';
  }

  @override
  String variableStatus(Object status) {
    return '• $status - اسٹیٹس ٹیکسٹ';
  }

  @override
  String variableRelationship(Object relationship) {
    return '• $relationship - تعلق کا ٹیکسٹ';
  }

  @override
  String get noCurrencies => 'کوئی کرنسی نہیں ہے';

  @override
  String get currencyDeleted => 'کرنسی کامیابی سے حذف کر دی گئی';

  @override
  String get addCurrency => 'کرنسی شامل کریں';

  @override
  String get currencyNameLabel => 'کرنسی کا نام';

  @override
  String get currencyNameHint => 'مثلاً یورو، برطانوی پاؤنڈ';

  @override
  String get pleaseEnterCurrencyName => 'براہ کرم کرنسی کا نام درج کریں';

  @override
  String get currencySymbolLabel => 'کرنسی کی علامت';

  @override
  String get currencySymbolHint => 'مثلاً €، £، ¥';

  @override
  String get currencySymbolHelper =>
      'آپ ایموجی، حروف یا علامات استعمال کر سکتے ہیں';

  @override
  String get pleaseEnterCurrencySymbol => 'براہ کرم کرنسی کی علامت درج کریں';

  @override
  String get symbolLengthError => 'علامت 10 حروف یا اس سے کم ہونی چاہیے';

  @override
  String get currencyCodeLabel => 'کرنسی کوڈ';

  @override
  String get currencyCodeHint => 'مثلاً EUR, GBP, JPY';

  @override
  String get currencyCodeHelper => 'ISO 4217 کوڈ (3 حروف)';

  @override
  String get pleaseEnterCurrencyCode => 'براہ کرم کرنسی کوڈ درج کریں';

  @override
  String get codeLengthError => 'کوڈ بالکل 3 حروف کا ہونا چاہیے';

  @override
  String get decimalPlacesLabel => 'اعشاریہ کے مقامات';

  @override
  String get decimalPlacesHelper => 'اعشاریہ کے بعد ہندسوں کی تعداد';

  @override
  String get noDecimals => '0 (کوئی اعشاریہ نہیں)';

  @override
  String get oneDecimal => '1 اعشاریہ کا مقام';

  @override
  String get twoDecimals => '2 اعشاریہ کے مقامات';

  @override
  String get saveCurrency => 'کرنسی محفوظ کریں';

  @override
  String get currencyAdded => 'کرنسی کامیابی سے شامل کر دی گئی';

  @override
  String get editCurrency => 'کرنسی में ترمیم کریں';

  @override
  String get updateCurrency => 'کرنسی اپ ڈیٹ کریں';

  @override
  String get currencyUpdated => 'کرنسی کامیابی سے اپ ڈیٹ کر دی گئی';

  @override
  String get selectDateRange => 'تاریخ کی حد منتخب کریں';

  @override
  String get exportSuccessful => 'ایکسپورٹ کامیاب';

  @override
  String get transactionHistoryReady =>
      'آپ کی لین دین کی ہسٹری شیئر کرنے کے لیے تیار ہے۔';

  @override
  String get done => 'ہو گیا';

  @override
  String get pdfReportReady =>
      'آپ کی پی ڈی ایف رپورٹ تیار ہے۔ کوئی عمل منتخب کریں:';

  @override
  String get testPdfReady => 'ٹیسٹ پی ڈی ایف تیار ہے';

  @override
  String get testPdfCategoriesReady =>
      'تمام زمروں کے ساتھ ٹیسٹ پی ڈی ایف تیار ہے۔ کوئی عمل منتخب کریں:';

  @override
  String get exportYourData => 'اپنا ڈیٹا ایکسپورٹ کریں';

  @override
  String get downloadHistoryCsvPdf =>
      'اپنی لین دین کی ہسٹری CSV یا PDF کے طور پر ڈاؤن لوڈ کریں';

  @override
  String get startDate => 'شروع کی تاریخ';

  @override
  String get endDate => 'ختم ہونے کی تاریخ';

  @override
  String get selectDate => 'تاریخ منتخب کریں';

  @override
  String get exportSummary => 'ایکسپورٹ خلاصہ';

  @override
  String get totalTransactions => 'کل لین دین';

  @override
  String get csvInfoNote =>
      'سی ایس وی فائلیں ایکسل یا گوگل شیٹس میں کھولی جا سکتی ہیں۔ پی ڈی ایف رپورٹ شیئرنگ کے لیے بہترین ہیں۔';

  @override
  String get testCategoriesPdf => 'ٹیسٹ زمرہ جات پی ڈی ایف (آئیکنز)';

  @override
  String get transactionDetails => 'لین دین کی تفصیلات';

  @override
  String get autoGenerated => 'خودکار طریقے سے تیار کردہ';

  @override
  String get scheduled => 'شیڈول شدہ';

  @override
  String get sendMessage => 'پیغام بھیجیں';

  @override
  String get linkedEntry => 'منسلک اندراج';

  @override
  String paidOn(String date) {
    return 'ادائیگی کی تاریخ: $date';
  }

  @override
  String receivedOn(String date) {
    return 'وصولی کی تاریخ: $date';
  }

  @override
  String get deleteTransactionTitle => 'لین دین حذف کریں';

  @override
  String get deleteTransactionMessage =>
      'کیا آپ واقعی اس لین دین کو حذف کرنا چاہتے ہیں؟ یہ عمل واپس نہیں لیا جا سکتا۔';

  @override
  String get transactionDeleted => 'لین دین حذف کر دیا گیا';

  @override
  String get errorLoadingCurrency => 'کرنسی لوڈ کرنے میں غلطی';

  @override
  String get balanceLabel => 'بیلنس';

  @override
  String get errorLabel => 'غلطی';

  @override
  String get importTransaction => 'لین دین درآمد کریں';

  @override
  String get importReceivable => 'وصولی درآمد کریں';

  @override
  String get importPayable => 'واجبات درآمد کریں';

  @override
  String sharedBy(String name) {
    return '$name کی طرف سے شیئر کیا گیا';
  }

  @override
  String get sender => 'بھیجنے والا';

  @override
  String get someone => 'کوئی';

  @override
  String markedAsStatus(String name, String status) {
    return '$name نے اسے $status کے طور پر نشان زد کیا ہے۔ اپنا مقامی ریکارڈ اپ ڈیٹ کریں؟';
  }

  @override
  String get itemAlreadyImported => 'یہ چیز پہلے ہی درآمد کی جا چکی ہے۔';

  @override
  String get importDetails => 'تفصیلات درآمد کریں';

  @override
  String get viewDetails => 'تفصیلات دیکھیں';

  @override
  String get type => 'قسم';

  @override
  String get remaining => 'باقی';

  @override
  String get daily => 'روزانہ';

  @override
  String get limitReached => 'حد ختم ہو گئی';

  @override
  String get proLabel => 'PRO';

  @override
  String get deleteItem => 'آئٹم حذف کریں';

  @override
  String get confirmDeleteItem => 'کیا آپ واقعی اس آئٹم کو حذف کرنا چاہتے ہیں؟';

  @override
  String sharePayableCompleted(String amount, String date, String link) {
    return 'اسلام علیکم!\n\n$date کو $amount کی ادائیگی مکمل ہو گئی ہے۔\n\nFlowPaisa میں سنک کریں:\n$link';
  }

  @override
  String sharePayablePending(String amount, String date, String link) {
    return 'میں نے آپ کے $amount دینے ہیں\nتاریخ: $date\n\nFlowPaisa میں دیکھیں:\n$link';
  }

  @override
  String shareReceivableReceived(String amount, String date, String link) {
    return 'اسلام علیکم!\n\n$date کو $amount کی ادائیگی موصول ہو گئی ہے۔\n\nFlowPaisa میں سنک کریں:\n$link';
  }

  @override
  String shareReceivablePending(String amount, String date, String link) {
    return 'وصول کرنے والی رقم: $amount\nتاریخ: $date\n\nFlowPaisa میں دیکھیں:\n$link';
  }

  @override
  String shareTransactionMessage(String amount, String date, String link) {
    return '$date کو $amount کا لین دین ریکارڈ کیا گیا۔\n\nFlowPaisa میں دیکھیں:\n$link';
  }

  @override
  String get shareViaWhatsApp => 'واٹس ایپ کے ذریعے شیئر کریں';

  @override
  String toContact(String name) {
    return 'کو $name';
  }

  @override
  String get chooseContact => 'رابطہ منتخب کریں';

  @override
  String get copyLink => 'لنک کاپی کریں';

  @override
  String get copyDeepLinkSubtitle => 'ڈیپ لنک کلپ بورڈ پر کاپی کریں';

  @override
  String get scanReceipt => 'رسید اسکین کریں';

  @override
  String get camera => 'کیمرہ';

  @override
  String get gallery => 'گیلری';

  @override
  String get scanningReceipt => 'رسید اسکین ہو رہی ہے...';

  @override
  String get noReceiptSelected => 'کوئی رسید منتخب نہیں کی گئی';

  @override
  String get reviewAndEdit => 'جائزہ لیں اور ترمیم کریں';

  @override
  String get merchantName => 'تاجر کا نام';

  @override
  String get totalAmount => 'کل رقم';

  @override
  String get proceedToAddTransaction => 'لین دین شامل کرنے کے لیے آگے بڑھیں';

  @override
  String errorPickingImage(String error) {
    return 'تصویر لینے میں غلطی: $error';
  }

  @override
  String errorScanningReceipt(String error) {
    return 'رسید اسکین کرنے میں غلطی: $error';
  }

  @override
  String get noCategoriesFound => 'کوئی زمرہ نہیں ملا';

  @override
  String get paidRelationship => 'ادائیگی کا تعلق';

  @override
  String get paidFor => 'کے لیے ادا کیا';

  @override
  String get paidBy => 'کی طرف سے ادا کیا گیا';

  @override
  String get iWillReceiveBack => 'مجھے واپس ملے گا';

  @override
  String get someonePaidForMe => 'کسی نے میرے لیے ادائیگی کی';

  @override
  String get receivedRelationship => 'موصولی کا تعلق';

  @override
  String get iOwe => 'میرا قرض';

  @override
  String get receivedLoan => 'قرض موصول ہوا';

  @override
  String get receiveLater => 'بعد میں وصول کریں';

  @override
  String get schedulePattern => 'شیڈول پیٹرن';

  @override
  String get startDateOptional => 'شروع کی تاریخ (اختیاری)';

  @override
  String get endDateOptional => 'ختم ہونے کی تاریخ (اختیاری)';

  @override
  String get scheduleUpdated => 'شیڈول کامیابی سے اپ ڈیٹ ہو گیا';

  @override
  String get updateSchedule => 'شیڈول اپ ڈیٹ کریں';

  @override
  String get updating => 'اپ ڈیٹ ہو رہا ہے...';

  @override
  String get contactOptional => 'رابطہ (اختیاری)';

  @override
  String get pleaseSelectContactRelationship =>
      'براہ کرم اس تعلق کے لیے ایک رابطہ منتخب کریں';

  @override
  String get weekly => 'ہفتہ وار';

  @override
  String weeklyWithDays(String days) {
    return 'ہفتہ وار: $days';
  }

  @override
  String monthlyWithDay(String day) {
    return 'ماہانہ: $day';
  }

  @override
  String get schedules => 'شیڈولز';

  @override
  String get generate100DummyTransactions => '100 فرضی لین دین تیار کریں';

  @override
  String get generated100DummyTransactions => '100 فرضی لین دین تیار ہو گئے';

  @override
  String get errorLoadingTransactions => 'لین دین لوڈ کرنے میں غلطی';

  @override
  String get noSchedulesFound => 'کوئی شیڈول نہیں ملا';

  @override
  String get noMoreTransactions => 'مزید لین دین نہیں ہیں';

  @override
  String get scheduleDeleted => 'شیڈول کامیابی سے حذف ہو گیا';

  @override
  String get autoBadge => 'خودکار';

  @override
  String get uncategorized => 'بغیر زمرہ';

  @override
  String get editSchedule => 'شیڈول میں ترمیم کریں';

  @override
  String get schedule => 'شیڈول';

  @override
  String get confirm => 'تصدیق کریں';

  @override
  String get emailLabel => 'ای میل';

  @override
  String get notesLabel => 'نوٹس';

  @override
  String get deleteContactTitle => 'رابطہ حذف کریں';

  @override
  String get loading => 'لوڈنگ...';

  @override
  String get limitReachedTitle => 'حد تک پہنچ گئے';

  @override
  String get upgrade => 'اپ گریڈ کریں';

  @override
  String get summary => 'خلاصہ';

  @override
  String get noTransactionsInRange =>
      'اس تاریخ کی حد میں کوئی لین دین نہیں ہے۔';

  @override
  String get noPayablesInRange =>
      'اس تاریخ کی حد میں کوئی واجب الادا رقم نہیں ہے۔';

  @override
  String get noReceivablesInRange => 'اس تاریخ کی حد میں کوئی وصولی نہیں ہے۔';

  @override
  String get topCategoriesVisual => 'ٹاپ زمرہ جات (بصری)';

  @override
  String get incomeVsExpenseTrendVisual =>
      'آمدنی بمقابلہ اخراجات کا رجحان (بصری)';

  @override
  String get payableVsReceivableTrendVisual =>
      'واجب الادا بمقابلہ وصولی کا رجحان (بصری)';

  @override
  String get incomeShort => 'آمدنی:';

  @override
  String get shareTransaction => 'لین دین شیئر کریں';

  @override
  String get sharePaymentRequest => 'ادائیگی کی درخواست شیئر کریں';

  @override
  String get sharePaymentAcknowledgment => 'ادائیگی کا اعتراف شیئر کریں';

  @override
  String get openingWhatsApp => 'واٹس ایپ کھولا جا رہا ہے...';

  @override
  String get linkCopied => 'لنک کلپ بورڈ پر کاپی ہو گیا!';

  @override
  String failedToShare(String error) {
    return 'شیئر کرنے میں ناکامی: $error';
  }

  @override
  String failedToCopyLink(String error) {
    return 'لنک کاپی کرنے میں ناکامی: $error';
  }

  @override
  String get expenseShort => 'اخراجات:';

  @override
  String suggestedLabel(String name) {
    return 'تجویز کردہ: $name';
  }

  @override
  String get deleteCashbookTitle => 'کیش بک حذف کریں';

  @override
  String get deletePermanently => 'مستقل طور پر حذف کریں';

  @override
  String get pleaseEnterValidAmount => 'براہ کرم درست رقم درج کریں';

  @override
  String get categoryEducation => 'تعلیم';

  @override
  String get categoryGift => 'تحفہ';

  @override
  String get statusPaid => 'ادا شدہ';

  @override
  String get statusReceived => 'وصول شدہ';

  @override
  String get statusSettled => 'تصفیہ شدہ';

  @override
  String get statusOverdue => 'واجب الادا';

  @override
  String get statusSent => 'بھیجا گیا';

  @override
  String get statusFailed => 'ناکام';

  @override
  String get payableTag => 'قابل ادائیگی';

  @override
  String get receivableTag => 'وصولی';

  @override
  String get receivedTag => 'وصول شدہ';

  @override
  String get paidTag => 'ادا شدہ';

  @override
  String get currencyUSD => 'امریکی ڈالر (\$)';

  @override
  String get currencyINR => 'भारतीय रुपया (₹)';

  @override
  String get currencyPKR => 'پاکستانی روپیہ (Rs)';

  @override
  String get inactive => 'غیر فعال';

  @override
  String get sundayShort => 'اتوار';

  @override
  String get mondayShort => 'پیر';

  @override
  String get tuesdayShort => 'منگل';

  @override
  String get wednesdayShort => 'بدھ';

  @override
  String get thursdayShort => 'جمعرات';

  @override
  String get fridayShort => 'جمعہ';

  @override
  String get saturdayShort => 'ہفتہ';

  @override
  String get from => 'سے';

  @override
  String get to => 'تک';

  @override
  String get willReceive => 'وصول ہوگا';

  @override
  String get selectSchedulePattern => 'شیڈول پیٹرن منتخب کریں';

  @override
  String get daysOfWeek => 'ہفتے کے دن';

  @override
  String get daysOfMonth => 'مہینے کے دن';

  @override
  String get sunday => 'اتوار';

  @override
  String get monday => 'پیر';

  @override
  String get tuesday => 'منگل';

  @override
  String get wednesday => 'بدھ';

  @override
  String get thursday => 'جمعرات';

  @override
  String get friday => 'جمعہ';

  @override
  String get saturday => 'ہفتہ';

  @override
  String get updateReceivable => 'وصولی اپ ڈیٹ کریں';

  @override
  String get newCashbook => 'نئی کیش بک';

  @override
  String get freeLimitReached => 'مفت حد ختم ہو گئی';

  @override
  String get cashbookNameHint => 'مثلاً ذاتی، کاروبار';

  @override
  String get selectIcon => 'آئیکن منتخب کریں';

  @override
  String get selectColor => 'رنگ منتخب کریں';

  @override
  String get updateCashbook => 'کیش بک اپ ڈیٹ کریں';

  @override
  String get noOtherCashbooks =>
      'کاپی کرنے کے لیے کوئی دوسری کیش بک دستیاب نہیں ہے۔';

  @override
  String get selectSourceCashbook => 'ماخذ کیش بک منتخب کریں';

  @override
  String toTarget(String name) {
    return 'ہدف: $name';
  }

  @override
  String get whatToCopy => 'کیا کاپی کرنا ہے؟';

  @override
  String get userProfile => 'صارف کا پروفائل';

  @override
  String get userProfileDescription => 'نام, ای میل اور بنیادی معلومات';

  @override
  String get preferencesDescription => 'کرنسی اور تاریخ کے فارمیٹ کی ترتیبات';

  @override
  String get messageTemplatesDescription => 'واٹس ایپ میسج ٹیمپلیٹس';

  @override
  String get copy => 'کاپی کریں';

  @override
  String get pleaseSelectSource => 'براہ کرم ماخذ کیش بک منتخب کریں';

  @override
  String get pleaseSelectAtLeastOne =>
      'براہ کرم کاپی کرنے کے لیے کم از کم ایک چیز منتخب کریں';

  @override
  String get preferencesCopied => 'ترجیحات کامیابی سے کاپی ہو گئیں';

  @override
  String errorCopyingPreferences(String error) {
    return 'ترجیحات کاپی کرنے میں غلطی: $error';
  }

  @override
  String get reset => 'ری سیٹ کریں';

  @override
  String get template => 'ٹیمپلیٹ';

  @override
  String get variables => 'متغیرات';

  @override
  String get close => 'بند کریں';

  @override
  String get dashboard => 'ڈیش بورڈ';

  @override
  String get error => 'غلطی';

  @override
  String get currencies => 'کرنسیاں';

  @override
  String get backup => 'بیک اپ';

  @override
  String get premium => 'پریمیم';

  @override
  String get free => 'مفت';

  @override
  String get transactionAlreadyImported =>
      'لین دین پہلے ہی درآمد کیا جا چکا ہے';

  @override
  String get pleaseSelectContactLinked =>
      'براہ کرم منسلک لین دین کے لیے ایک رابطہ منتخب کریں';

  @override
  String get transactionLinkedAdded =>
      'لین دین منسلک کر دیا گیا اور کامیابی سے شامل ہو گیا';

  @override
  String get transactionAdded => 'لین دین کامیابی سے شامل ہو گیا';

  @override
  String createCategoryNamed(String name) {
    return '\"$name\" زمرہ بنائیں';
  }

  @override
  String get tapToAddCategory => 'اس زمرے کو شامل کرنے کے لیے ٹیپ کریں';

  @override
  String get frequent => 'اکثر';

  @override
  String get saving => 'محفوظ ہو رہا ہے...';

  @override
  String get transactionDeletedSuccessfully =>
      'لین دین کامیابی سے حذف کر دیا گیا';

  @override
  String get googleDrive => 'گوگل ڈرائیو';

  @override
  String get activeCashbook => 'فعال کیش بک';

  @override
  String get syncAndBackupApplyTo =>
      'نیچے دی گئی تمام سنک اور بیک اپ کارروائیاں صرف اسی کیش بک پر لاگو ہوتی ہیں۔';

  @override
  String get synchronization => 'سنکرونائزیشن';

  @override
  String get syncActive => 'سنک فعال ہے';

  @override
  String get syncDescription =>
      'سنکرونائزیشن چھوٹی تبدیلیوں کو ضم کر کے آپ کے ڈیٹا کو آپ کے تمام آلات پر اپ ڈیٹ رکھتا ہے۔ یہ تیز ہے اور خودکار طور پر چلتا ہے۔';

  @override
  String get syncNow => 'ابھی سنک کریں';

  @override
  String get syncTriggered => 'بیک گراؤنڈ میں سنک شروع ہو گیا ہے';

  @override
  String get autoSync => 'آٹو سنک';

  @override
  String get syncInterval => 'سنک کا وقفہ (گھنٹے)';

  @override
  String get hour => 'گھنٹہ';

  @override
  String get hours => 'گھنٹے';

  @override
  String localVersion(int version) {
    return 'مقامی ورژن: $version';
  }

  @override
  String cloudVersion(int version) {
    return 'کلاؤڈ ورژن: $version';
  }

  @override
  String lastSync(String time) {
    return 'آخری سنک: $time';
  }

  @override
  String get autoBackup => 'آٹو بیک اپ';

  @override
  String get manual => 'مینول';

  @override
  String get backupDescription =>
      'ایک مکمل بیک اپ آپ کے ڈیٹا بیس کا ایک مکمل اسنیپ شاٹ بناتا ہے۔ اسے تاریخی ریکارڈ یا بڑے مسائل سے نمٹنے کے لیے استعمال کریں۔';

  @override
  String get syncRecovery => 'سنک ریکوری';

  @override
  String get syncRecoveryDescription =>
      'اگر آپ نے سنک کی غلطی کو ٹھیک کرنے کے لیے اس بیک اپ کو بحال کیا ہے، تو آپ کو کلاؤڈ سنک کو اس ورژن پر ری سیٹ کرنا چاہیے۔ یہ اس بحال شدہ ڈیٹا کو \"سچائی کا ذریعہ\" بناتا ہے۔';

  @override
  String get resetCloudSync => 'کلاؤڈ سنک ری سیٹ کریں';

  @override
  String get syncManifestReset => 'سنک مینی فیسٹ کامیابی سے ری سیٹ ہو گیا';

  @override
  String failedToResetSync(String error) {
    return 'سنک ری سیٹ کرنے میں ناکامی: $error';
  }

  @override
  String get backupToFile => 'فائل میں بیک اپ لیں';

  @override
  String get restoreFromFile => 'فائل سے بحال کریں';

  @override
  String get clearData => 'ڈیٹا صاف کریں';

  @override
  String get addCashbook => 'کیش بک شامل کریں';

  @override
  String get cashbookCreated => 'کیش بک کامیابی سے بن گئی';

  @override
  String get fontSelection => 'فونٹ کا انتخاب';

  @override
  String get restoreToNewCashbookTitle => 'نئی کیش بک میں بحال کریں؟';

  @override
  String restoreToNewCashbookMessage(String cloudCashbookName) {
    return 'یہ بیک اپ $cloudCashbookName کا ہے۔ اسے بحال کرنے سے اس ڈیوائس پر اس کے ڈیٹا کے ساتھ ایک نئی کیش بک انٹری بن جائے گی۔';
  }

  @override
  String get overrideExistingCashbookTitle =>
      'موجودہ کیش بک کو اوور رائٹ کریں؟';

  @override
  String overrideExistingCashbookMessage(
      String cloudCashbookName, String activeCashbookName) {
    return 'یہ بیک اپ $cloudCashbookName کا ہے۔ اسے بحال کرنے سے آپ کی موجودہ فعال کیش بک $activeCashbookName کا ڈیٹا اوور رائٹ ہو جائے گا۔';
  }

  @override
  String restoreSuccessNew(String name) {
    return 'کیش بک $name کامیابی سے بن گئی۔ آپ اسے ہوم اسکرین سے تبدیل کر سکتے ہیں۔';
  }

  @override
  String get restoreOptionOverride => 'اوور رائٹ کریں';

  @override
  String get restoreOptionNewEntry => 'نئی انٹری';

  @override
  String get filters => 'فلٹرز';

  @override
  String get dateRange => 'تاریخ کی حد';

  @override
  String get transactionType => 'لین دین کی قسم';

  @override
  String get amountRange => 'رقم کی حد';

  @override
  String get minAmount => 'کم از کم رقم';

  @override
  String get maxAmount => 'زیادہ سے زیادہ رقم';

  @override
  String get applyFilters => 'فلٹرز لاگو کریں';

  @override
  String get filterByDueDate => 'واجب الادا تاریخ کے مطابق فلٹر کریں';

  @override
  String get notificationBackupSuccessTitle => 'بیک اپ کامیاب';

  @override
  String notificationBackupSuccessMessage(String name) {
    return 'گوگل ڈرائیو پر \"$name\" کا بیک اپ کامیابی سے لے لیا گیا ہے۔';
  }

  @override
  String get notificationSyncCompleteTitle => 'بیک گراؤنڈ سنک مکمل';

  @override
  String notificationSyncCompleteMessage(int count) {
    return 'بیک گراؤنڈ میں $count کیش بکس کامیابی سے سنک ہو گئی ہیں۔';
  }

  @override
  String get cloudCashbooks => 'کلاؤڈ کیش بکس';

  @override
  String get main => 'مین';

  @override
  String get cloudDb => 'کلاؤڈ ڈیٹا بیس';

  @override
  String get versions => 'ورژنز';

  @override
  String get local => 'مقامی';

  @override
  String get cloud => 'کلاؤڈ';

  @override
  String rows(int count) {
    return '$count قطاریں';
  }

  @override
  String get primeCloudWithLocal => 'مقامی کے ساتھ کلاؤڈ کو پرائم کریں';

  @override
  String get resetCloudVersion => 'کلاؤڈ ورژن ری سیٹ کریں';

  @override
  String resetCloudVersionMessage(Object version) {
    return 'یہ کلاؤڈ ورژن کو آپ کے مقامی ورژن ($version) کے مطابق کرنے پر مجبور کر دے گا۔\n\nاسے صرف اس صورت میں استعمال کریں جب آپ کا کلاؤڈ مینی فیسٹ خراب ہو یا آپ کے مقامی ڈیٹا کے ساتھ سنک نہ ہو۔';
  }

  @override
  String get resetNow => 'ابھی ری سیٹ کریں';

  @override
  String get cloudVersionResetSuccess => 'کلاؤڈ ورژن کامیابی سے ری سیٹ ہو گیا';

  @override
  String cloudVersionResetFailed(Object error) {
    return 'کلاؤڈ ورژن ری سیٹ کرنے میں ناکامی: $error';
  }

  @override
  String get syncIntervalLabel => 'سنک کا وقفہ';

  @override
  String get resetLocalSyncState => 'مقامی سنک کی حالت ری سیٹ کریں';

  @override
  String get resetLocalSyncMessage =>
      'یہ آپ کے تمام مقامی ریکارڈز کو \"غیر سنک\" کے طور پر نشان زد کرے گا اور آپ کے مقامی ورژن کو 0 پر ری سیٹ کر دے گا۔ اس کے بعد \"ابھی سنک کریں\" پر ٹیپ کرنے سے آپ کا تمام ڈیٹا کلاؤڈ پر دوبارہ اپ لوڈ ہو جائے گا۔\n\nاسے تب استعمال کریں جب آپ اپنے مقامی ڈیٹا کا مکمل دوبارہ سنک کرنا چاہتے ہیں۔';

  @override
  String get localSyncResetSuccess =>
      'مقامی سنک کی حالت کامیابی سے ری سیٹ ہو گئی';

  @override
  String get clearAllCloudData => 'تمام کلاؤڈ ڈیٹا صاف کریں';

  @override
  String get clearAllCloudDataMessage =>
      'یہ گوگل ڈرائیو سے آپ کے تمام فلو پیسہ بیک اپ اور سنکرونائزیشن ڈیٹا کو مستقل طور پر حذف کر دے گا۔ اس عمل کو واپس نہیں لیا جا سکتا۔\n\nکیا آپ واقعی تمام کلاؤڈ ڈیٹا صاف کرنا چاہتے ہیں؟';

  @override
  String get cloudDataClearedSuccess => 'تمام کلاؤڈ ڈیٹا کامیابی سے صاف ہو گیا';

  @override
  String get clearNow => 'ابھی صاف کریں';

  @override
  String get upcomingSyncDeltas => 'آنے والے سنک ڈیلٹا';

  @override
  String get recentSyncDeltas => 'حالیہ سنک ڈیلٹا';

  @override
  String get manifestContentLocked => 'مینی فیسٹ مواد (مقفل)';

  @override
  String get deltaContent => 'ڈیلٹا مواد';

  @override
  String get refreshStatus => 'اسٹیٹس ری فریش کریں';

  @override
  String get refreshBackups => 'بیک اپ ری فریش کریں';

  @override
  String get locked => 'مقفل';

  @override
  String lockedWithTime(int minutes) {
    return 'مقفل ($minutes منٹ)';
  }

  @override
  String get payableOverdue => 'واجب الادا رقم کی میعاد ختم';

  @override
  String payableOverdueMessage(String description, String date) {
    return '$description کی ادائیگی $date کو واجب الادا تھی';
  }

  @override
  String get receivableOverdue => 'وصولی کی میعاد ختم';

  @override
  String receivableOverdueMessage(String description, String date) {
    return '$description کی ادائیگی $date को واجب الادا تھی';
  }

  @override
  String get upcomingPayable => 'آنے والی ادائیگی';

  @override
  String upcomingPayableMessage(String description, String date) {
    return '$description کی ادائیگی کل ($date) واجب الادا ہے';
  }

  @override
  String get upcomingReceivable => 'آنے والی وصولی';

  @override
  String upcomingReceivableMessage(String description, String date) {
    return '$description کی ادائیگی کل ($date) واجب الادا ہے';
  }

  @override
  String get urgent => 'فوری';

  @override
  String get deleteCloudCashbook => 'کلاؤڈ کیش بک حذف کریں؟';

  @override
  String deleteCloudCashbookMessage(String name) {
    return 'کیا آپ واقعی گوگل ڈرائیو سے \"$name\" کو حذف کرنا چاہتے ہیں؟ یہ اس کے تمام بیک اپ اور سنک ڈیٹا کو حذف کر دے گا۔ اس عمل کو واپس نہیں لیا جا سکتا۔';
  }

  @override
  String get cloudCashbookDeletedSuccess =>
      'کلاؤڈ کیش بک کامیابی سے حذف کر دی گئی';

  @override
  String get myShare => 'میرا حصہ';

  @override
  String get split => 'تقسیم کریں';

  @override
  String get contactShare => 'رابطے کا حصہ';

  @override
  String get othersShare => 'دوسروں کا حصہ';

  @override
  String get myShareSuffix => ' (میرا حصہ)';

  @override
  String get othersShareSuffix => ' (دوسروں کا حصہ)';

  @override
  String get splitBill => 'بل تقسیم کریں';

  @override
  String get includeMe => 'مجھے شامل کریں';

  @override
  String get distributeEqually => 'برابر تقسیم کریں';

  @override
  String get totalPercentage => 'کل فیصد';

  @override
  String get lockShare => 'حصہ لاک کریں';

  @override
  String get unlockShare => 'حصہ ان لاک کریں';

  @override
  String get customAmount => 'کسٹم رقم';

  @override
  String get percentage => 'فیصد';

  @override
  String get remainingAmount => 'باقی رقم';

  @override
  String get totalMustBe100 => 'کل 100% ہونا چاہیے';

  @override
  String get totalMustMatch => 'کل رقم ٹرانزیکشن کی رقم کے برابر ہونی چاہیے';

  @override
  String get sameDay => 'اسی دن';

  @override
  String inDays(int days) {
    return '$days دنوں میں';
  }

  @override
  String daysAgoRelative(int days) {
    return '$days دن پہلے';
  }

  @override
  String get pickActualDate => 'اصل تاریخ منتخب کریں';

  @override
  String relativeDateAfterXDays(String days) {
    return 'نسبتی تاریخ ($days دنوں کے بعد)';
  }

  @override
  String get enterDaysFromTransaction =>
      'لین دین کی تاریخ سے دنوں کی تعداد درج کریں:';

  @override
  String get enterDaysFromStart => 'شروع کی تاریخ سے دنوں کی تعداد درج کریں:';

  @override
  String get daysHint => 'مثلاً 15';

  @override
  String get daysSuffix => 'دن';

  @override
  String get status => 'حالت';

  @override
  String get payableVsReceivableTrend => 'قابل ادائیگی بمقابلہ قابل وصول رجحان';
}
