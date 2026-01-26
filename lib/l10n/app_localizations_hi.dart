// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'कैशबुक';

  @override
  String get cashbooks => 'कैशबुक';

  @override
  String get transactions => 'लेन-देन';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get totalBalance => 'कुल शेष';

  @override
  String get income => 'आय';

  @override
  String get expense => 'खर्च';

  @override
  String get addTransaction => 'लेन-देन जोड़ें';

  @override
  String get editTransaction => 'लेन-देन संपादित करें';

  @override
  String get scheduleCreated => 'शेड्यूल सफलतापूर्वक बनाया गया';

  @override
  String get transactionUpdated => 'लेन-देन सफलतापूर्वक अपडेट किया गया';

  @override
  String get updateTransaction => 'लेन-देन अपडेट करें';

  @override
  String get amount => 'राशि';

  @override
  String get category => 'श्रेणी';

  @override
  String get date => 'तारीख';

  @override
  String get description => 'विवरण';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get payable => 'देय';

  @override
  String createdLabel(String date) {
    return 'बनाया गया: $date';
  }

  @override
  String get defaultPremiumPrice => 'Rs. 2500';

  @override
  String errorOccurred(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get noDataForTrends => 'रुझानों के लिए कोई डेटा नहीं है';

  @override
  String get cancelled => 'रद्द किया गया';

  @override
  String minutesAgo(int minutes) {
    return '$minutes मिनट पहले';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours घंटे पहले';
  }

  @override
  String daysAgo(int days) {
    return '$days दिन पहले';
  }

  @override
  String sample(String sample) {
    return 'नमूना: $sample';
  }

  @override
  String positiveAmount(String amount) {
    return 'सकारात्मक: $amount';
  }

  @override
  String negativeAmount(String amount) {
    return 'नकारात्मक: $amount';
  }

  @override
  String themeSet(String name) {
    return 'थीम $name पर सेट की गई';
  }

  @override
  String languageChanged(String name) {
    return 'भाषा बदलकर $name कर दी गई';
  }

  @override
  String lastBackupAt(String time) {
    return 'अंतिम बैकअप: $time';
  }

  @override
  String restoreFailed(String error) {
    return 'बहाली विफल: $error';
  }

  @override
  String errorSaving(String error) {
    return 'सहेजने में त्रुटि: $error';
  }

  @override
  String errorSharing(String error) {
    return 'साझा करने में त्रुटि: $error';
  }

  @override
  String errorExporting(String error) {
    return 'एक्सपोर्ट करने में त्रुटि: $error';
  }

  @override
  String exportSavedTo(String path) {
    return 'एक्सपोर्ट $path में सहेजा गया';
  }

  @override
  String notificationTitlePrefix(String title) {
    return 'सूचना: $title';
  }

  @override
  String errorDeletingTransaction(String error) {
    return 'लेन-देन हटाने में त्रुटि: $error';
  }

  @override
  String noTypeCategories(String type) {
    return 'कोई $type श्रेणियां नहीं हैं';
  }

  @override
  String deleteCashbookMessage(String name) {
    return 'क्या आप वाकई \"$name\" को हटाना चाहते हैं? यह इस कैशबुक से जुड़े सभी डेटा को स्थायी रूप से हटा देगा।';
  }

  @override
  String currencySetTo(String name) {
    return 'मुद्रा $name पर सेट की गई';
  }

  @override
  String confirmDelete(String item) {
    return 'क्या आप वाकई इस $item को हटाना चाहते हैं?';
  }

  @override
  String get search => 'खोजें';

  @override
  String get searchTransactions => 'Search transactions...';

  @override
  String get noTransactions => 'कोई लेन-देन नहीं मिला';

  @override
  String get selectCategory => 'श्रेणी चुनें';

  @override
  String get all => 'सभी';

  @override
  String get today => 'आज';

  @override
  String get yesterday => 'कल';

  @override
  String get thisMonth => 'इस महीने';

  @override
  String get lastMonth => 'पिछले महीने';

  @override
  String get customRange => 'कस्टम रेंज';

  @override
  String get currency => 'मुद्रा';

  @override
  String get language => 'भाषा';

  @override
  String get theme => 'थीम';

  @override
  String get light => 'लाइट';

  @override
  String get dark => 'डार्क';

  @override
  String get system => 'सिस्टम';

  @override
  String get hindi => 'हिंदी';

  @override
  String get english => 'अंग्रेजी';

  @override
  String get urdu => 'उर्दू';

  @override
  String get cashbookName => 'कैशबुक का नाम';

  @override
  String get createCashbook => 'कैशबुक बनाएं';

  @override
  String get editCashbook => 'कैशबुक संपादित करें';

  @override
  String get deleteCashbook => 'कैशबुक हटाएं';

  @override
  String get cashbookDeleted => 'कैशबुक सफलतापूर्वक हटा दी गई';

  @override
  String get cashbookAdded => 'कैशबुक सफलतापूर्वक जोड़ दी गई';

  @override
  String get cashbookUpdated => 'कैशबुक सफलतापूर्वक अपडेट कर दी गई';

  @override
  String get pleaseEnterName => 'कृपया नाम दर्ज करें';

  @override
  String get copyPreferences => 'प्राथमिकताएं कॉपी करें';

  @override
  String get copyPreferencesFrom => 'यहां से प्राथमिकताएं कॉपी करें';

  @override
  String get copyPreferencesSubtitle =>
      'श्रेणियां और प्राथमिकताएं चुनी गई कैशबुक से कॉपी की जाएंगी।';

  @override
  String get none => 'कोई नहीं';

  @override
  String get howMuch => 'कितनी राशि?';

  @override
  String get amountHint => '0.00';

  @override
  String get pleaseEnterAmount => 'कृपया राशि दर्ज करें';

  @override
  String get pleaseEnterValidNumber => 'कृपया एक वैध संख्या दर्ज करें';

  @override
  String get amountGreaterThanZero => 'राशि 0 से अधिक होनी चाहिए';

  @override
  String get contact => 'संपर्क';

  @override
  String get selectContact => 'संपर्क चुनें';

  @override
  String get addNew => 'नया जोड़ें';

  @override
  String get descriptionHint => 'जैसे: दोपहर का भोजन';

  @override
  String get premiumFeature => 'प्रीमियम सुविधा';

  @override
  String get premiumRequired => 'इस सुविधा के लिए प्रीमियम सदस्यता आवश्यक है।';

  @override
  String get getPremium => 'प्रीमियम प्राप्त करें';

  @override
  String switchedToCashbook(String name) {
    return '$name पर स्विच किया गया';
  }

  @override
  String get categoryFood => 'भोजन';

  @override
  String get categoryTransport => 'परिवहन';

  @override
  String get categoryShopping => 'खरीदारी';

  @override
  String get categoryBills => 'बिल';

  @override
  String get categoryEntertainment => 'मनोरंजन';

  @override
  String get categoryHealth => 'स्वास्थ्य';

  @override
  String get categorySalary => 'वेतन';

  @override
  String get categoryBusiness => 'व्यवसाय';

  @override
  String get categoryInvestment => 'निवेश';

  @override
  String get categoryRent => 'किराया';

  @override
  String get categoryOther => 'अन्य';

  @override
  String get statusPending => 'लंबित';

  @override
  String get statusCompleted => 'पूरा हुआ';

  @override
  String get statusCancelled => 'रद्द किया गया';

  @override
  String get receivables => 'प्राप्य';

  @override
  String get pending => 'लंबित';

  @override
  String get overdue => 'देय तिथि निकल गई';

  @override
  String get receivedLabel => 'प्राप्त';

  @override
  String get generateDummyReceivables => '100 डमी प्राप्य बनाएं';

  @override
  String dummyGenerated(int count) {
    return '$count डमी आइटम बनाए गए';
  }

  @override
  String get errorLoadingReceivables => 'प्राप्य लोड करने में त्रुटि';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get noPendingReceivables => 'कोई लंबित प्राप्य नहीं है';

  @override
  String get noOverdueReceivables => 'कोई देय तिथि निकल चुकी प्राप्य नहीं है';

  @override
  String get noReceivedPayments => 'कोई प्राप्त भुगतान नहीं है';

  @override
  String get addReceivableSubtitle =>
      'अपनी बकाया राशि को ट्रैक करने के लिए प्राप्य जोड़ें';

  @override
  String get receivablesUpToDate => 'सभी प्राप्य अप-टू-डेट हैं';

  @override
  String get markReceivedSubtitle =>
      'लंबित प्राप्य को प्राप्त के रूप में चिह्नित करें';

  @override
  String get noMoreItems => 'कोई और आइटम नहीं हैं';

  @override
  String get receivableDeleted => 'प्राप्य हटा दिया गया';

  @override
  String get unknown => 'अज्ञात';

  @override
  String dueAt(String date) {
    return 'देय: $date';
  }

  @override
  String get receivable => 'प्राप्य';

  @override
  String get addReceivable => 'प्राप्य जोड़ें';

  @override
  String get receivableAlreadyImported =>
      'यह प्राप्य पहले ही आयात किया जा चुका है।';

  @override
  String get pleaseSelectContact => 'कृपया एक संपर्क चुनें';

  @override
  String get receivableAdded => 'प्राप्य सफलतापूर्वक जोड़ा गया';

  @override
  String get share => 'साझा करें';

  @override
  String get dueDateOptional => 'देय तिथि (वैकल्पिक)';

  @override
  String get notSet => 'सेट नहीं है';

  @override
  String get autoCreateIncome => 'स्वचालित रूप से आय बनाएं';

  @override
  String get autoCreateIncomeSubtitle =>
      'प्राप्त के रूप में चिह्नित होने पर आय के रूप में रिकॉर्ड करें';

  @override
  String get receivableNotFound => 'प्राप्य नहीं मिला';

  @override
  String get receivableUpdated => 'प्राप्य सफलतापूर्वक अपडेट किया गया';

  @override
  String get editReceivable => 'प्राप्य संपादित करें';

  @override
  String get receivableDetails => 'प्राप्य विवरण';

  @override
  String get edit => 'संपादित करें';

  @override
  String get receivablePending => 'प्राप्य (लंबित)';

  @override
  String get dueDate => 'देय तिथि';

  @override
  String get linkedTransaction => 'लिंक्ड लेन-देन';

  @override
  String get markAsReceived => 'प्राप्त के रूप में चिह्नित करें';

  @override
  String get deleteReceivableTitle => 'प्राप्य हटाएं';

  @override
  String get deleteReceivableMessage =>
      'क्या आप वाकई इस प्राप्य को हटाना चाहते हैं? इस क्रिया को पूर्ववत नहीं किया जा सकता।';

  @override
  String get markedAsReceived => 'प्राप्त के रूप में चिह्नित किया गया';

  @override
  String get informContactSettlement =>
      'प्राप्य को प्राप्त के रूप में चिह्नित किया गया। संपर्क को सूचित करें?';

  @override
  String addContactWithName(String name) {
    return '$name जोड़ें';
  }

  @override
  String get payables => 'देय';

  @override
  String get generateDummyPayables => '100 डमी देय बनाएं';

  @override
  String get dummyPayablesGenerated => '100 डमी देय बनाए गए';

  @override
  String get errorLoadingPayables => 'देय लोड करने में त्रुटि';

  @override
  String get noPendingPayables => 'कोई लंबित देय नहीं है';

  @override
  String get noOverduePayables => 'कोई देय तिथि निकल चुकी भुगतान नहीं है';

  @override
  String get noPaidBills => 'कोई भुगतान किया गया बिल नहीं है';

  @override
  String get addPayableSubtitle =>
      'अपनी बकाया राशि को ट्रैक करने के लिए भुगतान जोड़ें';

  @override
  String get allPayablesUpToDate => 'सभी देय अप-टू-डेट हैं';

  @override
  String get markPendingAsPaidSubtitle =>
      'लंबित देय को भुगतान के रूप में चिह्नित करें';

  @override
  String get noMorePayables => 'कोई और देय नहीं हैं';

  @override
  String get payableDeleted => 'देय हटा दिया गया';

  @override
  String get payableAlreadyImported => 'यह देय पहले ही आयात किया जा चुका है।';

  @override
  String get payableAdded => 'देय सफलतापूर्वक जोड़ा गया';

  @override
  String get addPayable => 'देय जोड़ें';

  @override
  String get editPayable => 'देय संपादित करें';

  @override
  String get payableNotFound => 'देय नहीं मिला';

  @override
  String get payableDataNotLoaded => 'देय डेटा लोड नहीं हुआ';

  @override
  String get payableUpdated => 'देय सफलतापूर्वक अपडेट किया गया';

  @override
  String get updatePayable => 'देय अपडेट करें';

  @override
  String get payableDetails => 'देय विवरण';

  @override
  String get payablePending => 'देय (लंबित)';

  @override
  String get paid => 'भुगतान किया गया';

  @override
  String get markAsPaid => 'भुगतान के रूप में चिह्नित करें';

  @override
  String get deletePayableTitle => 'देय हटाएं';

  @override
  String get deletePayableMessage =>
      'क्या आप वाकई इस देय को हटाना चाहते हैं? इस क्रिया को पूर्ववत नहीं किया जा सकता।';

  @override
  String get markedAsPaid => 'भुगतान के रूप में चिह्नित किया गया';

  @override
  String get informContactSettlementPayable =>
      'देय भुगतान चिह्नित किया गया। संपर्क को सूचित करें?';

  @override
  String get autoCreateExpense => 'स्वचालित रूप से खर्च बनाएं';

  @override
  String get autoCreateExpenseSubtitle =>
      'भुगतान के रूप में चिह्नित होने पर खर्च के रूप में रिकॉर्ड करें';

  @override
  String get appRefreshLanguage => 'नई भाषा लागू करने के लिए ऐप रिफ्रेश होगा';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get changePhoto => 'फोटो बदलें';

  @override
  String get photoUploadComingSoon => 'फोटो अपलोड जल्द ही आ रहा है!';

  @override
  String get name => 'नाम';

  @override
  String get enterName => 'अपना नाम दर्ज करें';

  @override
  String get email => 'ईमेल';

  @override
  String get enterEmail => 'अपना ईमेल दर्ज करें';

  @override
  String get enterValidEmail => 'कृपया एक वैध ईमेल दर्ज करें';

  @override
  String get phoneNumber => 'फ़ोन नंबर';

  @override
  String get enterPhoneNumber => 'अपना फ़ोन नंबर दर्ज करें';

  @override
  String get address => 'पता';

  @override
  String get enterAddress => 'अपना पता दर्ज करें';

  @override
  String get preferences => 'प्राथमिकताएं';

  @override
  String get dateFormat => 'तारीख का प्रारूप';

  @override
  String get saveProfile => 'प्रोफ़ाइल सहेजें';

  @override
  String get profileUpdated => 'प्रोफ़ाइल सफलतापूर्वक अपडेट किया गया';

  @override
  String get selectDateFormat => 'तारीख का प्रारूप चुनें';

  @override
  String get customFormat => 'कस्टम प्रारूप';

  @override
  String get enterCustomDateFormat =>
      'अपना कस्टम तारीख प्रारूप पैटर्न दर्ज करें';

  @override
  String get customDateFormat => 'कस्टम तारीख प्रारूप';

  @override
  String get formatPattern => 'प्रारूप पैटर्न';

  @override
  String get dateFormatInstructions =>
      'मानक ICU पैटर्न का उपयोग करें जैसे:\ndd: दिन, MM: महीना, yyyy: वर्ष\nMMM: संक्षिप्त महीना, EEEE: पूरा दिन';

  @override
  String get lightThemeDescription => 'हमेशा लाइट थीम का उपयोग करें';

  @override
  String get darkThemeDescription => 'हमेशा डार्क थीम का उपयोग करें';

  @override
  String get systemThemeDescription => 'डिवाइस की सेटिंग्स के अनुसार';

  @override
  String get themeChangesApplyImmediately => 'थीम परिवर्तन तुरंत लागू होते हैं';

  @override
  String get analytics => 'एनालिटिक्स';

  @override
  String get exportAnalyticsPDF => 'एनालिटिक्स पीडीएफ एक्सपोर्ट करें';

  @override
  String get refreshAnalytics => 'एनालिटिक्स रिफ्रेश करें';

  @override
  String get financialSummary => 'वित्तीय सारांश';

  @override
  String get contactSummaries => 'संपर्क सारांश';

  @override
  String get expensesByCategory => 'श्रेणी के अनुसार खर्च';

  @override
  String get incomeVsExpenseTrend => 'आय बनाम खर्च रुझान';

  @override
  String get payablesVsReceivablesTrend => 'देय बनाम प्राप्य रुझान';

  @override
  String get topContactsByBalance => 'शेष राशि के अनुसार शीर्ष संपर्क';

  @override
  String get paymentStatusDistribution => 'भुगतान स्थिति वितरण';

  @override
  String get incomeByCategory => 'श्रेणी के अनुसार आय';

  @override
  String get unlockAdvancedAnalytics =>
      'प्रीमियम के साथ उन्नत एनालिटिक्स, रुझान और चार्ट अनलॉक करें।';

  @override
  String get unlockPremium => 'प्रीमियम प्राप्त करें';

  @override
  String get noContactActivity => 'इस अवधि के लिए कोई संपर्क गतिविधि नहीं है';

  @override
  String get settled => 'निपटाया गया';

  @override
  String get noExpensesPeriod => 'इस अवधि के लिए कोई खर्च नहीं है';

  @override
  String get noDataTrends => 'रुझानों के लिए कोई डेटा नहीं है';

  @override
  String get noPayableReceivableData => 'कोई देय/प्राप्य डेटा नहीं है';

  @override
  String get noContactData => 'कोई संपर्क डेटा नहीं है';

  @override
  String get noPaymentStatusData => 'कोई भुगतान स्थिति डेटा नहीं है';

  @override
  String get noIncome => 'इस अवधि के लिए कोई आय नहीं है';

  @override
  String get pdfReady => 'पीडीएफ तैयार है';

  @override
  String get analyticsPDFReadyMessage =>
      'आपकी एनालिटिक्स पीडीएफ रिपोर्ट तैयार है। एक क्रिया चुनें:';

  @override
  String get saveCopy => 'कॉपी सहेजें';

  @override
  String get preview => 'पूर्वावलोकन';

  @override
  String get savedToDownloads => 'डाउनलोड में सहेजा गया';

  @override
  String get month => 'महीना';

  @override
  String get quarter => 'तिमाही';

  @override
  String get year => 'वर्ष';

  @override
  String get custom => 'कस्टम';

  @override
  String get payableShort => 'देय:';

  @override
  String get receivableShort => 'प्राप्य:';

  @override
  String get netBalance => 'शुद्ध शेष';

  @override
  String get allTime => 'कुल समय:';

  @override
  String get expenses => 'खर्च';

  @override
  String get noExpenses => 'इस अवधि के लिए कोई खर्च नहीं है';

  @override
  String get expanded => 'विस्तारित';

  @override
  String get collapsed => 'संकुचित';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get allNotificationsMarkedRead =>
      'सभी सूचनाओं को पढ़ा गया चिह्नित किया गया';

  @override
  String get markAllRead => 'सभी को पढ़ा गया चिह्नित करें';

  @override
  String get noNotifications => 'कोई सूचना नहीं';

  @override
  String get noNotificationsDescription =>
      'आप पूरी तरह से अप-टू-डेट हैं! हम आपको सूचित करेंगे:\n\n• देय प्राप्य और भुगतान\n• महत्वपूर्ण लेन-देन मील के पत्थर\n• बैकअप रिमाइंडर\n• महत्वपूर्ण अपडेट';

  @override
  String get notificationsTip =>
      'टिप: समय पर रिमाइंडर प्राप्त करने के लिए प्राप्य और देय के लिए देय तिथियां निर्धारित करें';

  @override
  String get justNow => 'अभी';

  @override
  String get toggledDebugMode => 'डिबग मोड टॉगल किया गया';

  @override
  String get debugToggleMode => 'डिबग: मोड टॉगल करें';

  @override
  String get premiumTitle => 'फ्लोपैसा प्रीमियम';

  @override
  String get unlockAllFeatures => 'सभी सुविधाएं अनलॉक करें';

  @override
  String get premiumMemberStatus => 'आप एक प्रीमियम सदस्य हैं';

  @override
  String get premiumFeaturesActive => 'सभी प्रीमियम सुविधाएं सक्रिय हैं';

  @override
  String get featureCloudBackupTitle => 'स्वचालित क्लाउड बैकअप';

  @override
  String get featureCloudBackupDesc =>
      'आपका डेटा स्वचालित रूप से Google ड्राइव पर बैकअप हो जाता है। अपने वित्तीय रिकॉर्ड कभी न खोएं।';

  @override
  String get featureAnalyticsTitle => 'उन्नत एनालिटिक्स';

  @override
  String get featureAnalyticsDesc =>
      'उन्नत चार्ट, रुझान और वित्तीय पूर्वानुमान के साथ विस्तृत जानकारी प्राप्त करें।';

  @override
  String get featurePdfReportsTitle => 'पीडीएफ रिपोर्ट';

  @override
  String get featurePdfReportsDesc =>
      'किसी भी तारीख सीमा के लिए चार्ट और सारांश के साथ सुंदर पीडीएफ रिपोर्ट बनाएं।';

  @override
  String get featureUnlimitedTitle => 'असीमित लेन-देन';

  @override
  String get featureUnlimitedDesc =>
      'लेन-देन, संपर्कों या श्रेणियों की संख्या पर कोई प्रतिबंध नहीं है।';

  @override
  String get featureSupportTitle => 'प्राथमिकता सहायता';

  @override
  String get featureSupportDesc =>
      'किसी भी समस्या या प्रश्न के लिए तेज़ प्रतिक्रिया और समर्पित सहायता प्राप्त करें।';

  @override
  String get featureEarlyAccessTitle => 'अर्ली एक्सेस';

  @override
  String get featureEarlyAccessDesc =>
      'सभी के लिए जारी होने से पहले नई सुविधाओं को आज़माने वाले पहले व्यक्ति बनें।';

  @override
  String get featureTemplatesTitle => 'कस्टम संदेश टेम्पलेट';

  @override
  String get featureTemplatesDesc =>
      'कई भाषाओं में रिमाइंडर, रसीद और साझा करने के लिए व्हाट्सएप संदेश टेम्पलेट्स को कस्टमाइज़ करें।';

  @override
  String get premiumPlan => 'प्रीमियम प्लान';

  @override
  String get lifetime => 'लाइफटाइम';

  @override
  String get oneTimePaymentLifetime => 'एक बार भुगतान • लाइफटाइम एक्सेस';

  @override
  String get processing => 'प्रसंस्करण...';

  @override
  String get restorePurchases => 'खरीद बहाल करें';

  @override
  String get premiumBenefitsNote =>
      'एक बार की खरीदारी के साथ सभी प्रीमियम सुविधाएं हमेशा के लिए आपकी हैं। कोई सदस्यता नहीं!';

  @override
  String get active => 'सक्रिय';

  @override
  String get googleDriveBackup => 'Google ड्राइव बैकअप';

  @override
  String get cloudBackupPremiumDesc =>
      'Google ड्राइव पर क्लाउड बैकअप प्रीमियम उपयोगकर्ताओं के लिए उपलब्ध है।';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signInGoogleToBackup =>
      'अपने डेटा का बैकअप लेने के लिए Google के साथ साइन इन करें';

  @override
  String get signInGoogle => 'Google के साथ साइन इन करें';

  @override
  String get googleServicesNote =>
      'नोट: बैकअप के लिए वैध Google सेवा कॉन्फ़िगरेशन आवश्यक है। यदि साइन इन विफल हो जाता है, तो अपना सेटअप जांचें।';

  @override
  String get backupNow => 'अभी बैकअप लें';

  @override
  String get noBackupsFound => 'कोई बैकअप नहीं मिला';

  @override
  String get availableBackups => 'उपलब्ध बैकअप';

  @override
  String get restoreBackupTitle => 'बैकअप बहाल करें?';

  @override
  String get restoreBackupMessage =>
      'यह आपके वर्तमान डेटा को चुने गए बैकअप से बदल देगा। \n\n⚠️ बहाली के बाद ऐप को पुनरारंभ करने की आवश्यकता होगी।';

  @override
  String get restore => 'बहाल करें';

  @override
  String get restoreSuccessful => 'बहाली सफल';

  @override
  String get restoreSuccessfulMessage =>
      'डेटा सफलतापूर्वक बहाल हो गया। परिवर्तन लागू करने के लिए कृपया ऐप को बंद करके फिर से चलाएं।';

  @override
  String get ok => 'ठीक है';

  @override
  String get categories => 'श्रेणियां';

  @override
  String get categoryHiddenSuccessfully => 'श्रेणी सफलतापूर्वक छिपाई गई';

  @override
  String get categoryDeletedSuccessfully => 'श्रेणी सफलतापूर्वक हटा दी गई';

  @override
  String get defaultLabel => 'डिफ़ॉल्ट';

  @override
  String get addCategory => 'श्रेणी जोड़ें';

  @override
  String get categoryName => 'श्रेणी का नाम';

  @override
  String get suggestedIcons => 'सुझाए गए आइकन';

  @override
  String get color => 'रंग';

  @override
  String get allIcons => 'सभी आइकन';

  @override
  String get saveCategory => 'श्रेणी सहेजें';

  @override
  String get categoryAddedSuccessfully => 'श्रेणी सफलतापूर्वक जोड़ी गई';

  @override
  String get editCategory => 'श्रेणी संपादित करें';

  @override
  String get categoryUpdatedSuccessfully => 'श्रेणी सफलतापूर्वक अपडेट की गई';

  @override
  String get failedToUpdateCategory => 'श्रेणी अपडेट करने में विफल';

  @override
  String get expenseCategory => 'खर्च श्रेणी';

  @override
  String get incomeCategory => 'आय श्रेणी';

  @override
  String get updateCategory => 'श्रेणी अपडेट करें';

  @override
  String get searchContacts => 'संपर्क खोजें...';

  @override
  String get contacts => 'संपर्क';

  @override
  String get noContactsYet => 'अभी तक कोई संपर्क नहीं है';

  @override
  String get noContactsFound => 'कोई संपर्क नहीं मिला';

  @override
  String get addPeopleToTrack => 'खर्चों को ट्रैक करने के लिए लोगों को जोड़ें';

  @override
  String get trySearchingDifferentName =>
      'किसी अलग नाम से खोजने का प्रयास करें';

  @override
  String get addContact => 'संपर्क जोड़ें';

  @override
  String get contactDeletedSuccessfully => 'संपर्क सफलतापूर्वक हटा दिया गया';

  @override
  String get contactPermissionDenied =>
      'संपर्क अनुमति अस्वीकार कर दी गई। कृपया इसे सेटिंग्स में सक्षम करें।';

  @override
  String errorPickingContact(String error) {
    return 'संपर्क चुनने में त्रुटि: $error';
  }

  @override
  String get selectPhoneNumber => 'फ़ोन नंबर चुनें';

  @override
  String get contactUpdatedSuccessfully => 'संपर्क सफलतापूर्वक अपडेट किया गया';

  @override
  String get contactAddedSuccessfully => 'संपर्क सफलतापूर्वक जोड़ा गया';

  @override
  String get editContact => 'संपर्क संपादित करें';

  @override
  String get importFromContacts => 'संपर्कों से आयात करें';

  @override
  String get phoneNumberOptional => 'फ़ोन नंबर (वैकल्पिक)';

  @override
  String get emailOptional => 'ईमेल (वैकल्पिक)';

  @override
  String get addressNotesOptional => 'पता / नोट्स (वैकल्पिक)';

  @override
  String get updateContact => 'संपर्क अपडेट करें';

  @override
  String get saveContact => 'संपर्क सहेजें';

  @override
  String get myCashbooks => 'मेरी कैशबुक';

  @override
  String get manageCashbooks => 'कई कैशबुक प्रबंधित करें';

  @override
  String get manageContacts => 'अपने संपर्कों को प्रबंधित करें';

  @override
  String get manageCategories => 'खर्च और आय श्रेणियों को प्रबंधित करें';

  @override
  String get manageCurrencies => 'मुद्राओं को प्रबंधित करें';

  @override
  String get googleDriveBackupRestore => 'Google ड्राइव बैकअप और बहाली';

  @override
  String get messageTemplates => 'संदेश टेम्पलेट';

  @override
  String get customizeMessageTemplates =>
      'व्हाट्सएप संदेश टेम्पलेट्स को कस्टमाइज़ करें';

  @override
  String get exportData => 'डेटा एक्सपोर्ट करें';

  @override
  String get downloadDataCsvPdf =>
      'अपना डेटा CSV या PDF के रूप में डाउनलोड करें';

  @override
  String get premiumActive => 'प्रीमियम सक्रिय है';

  @override
  String get about => 'ऐप के बारे में';

  @override
  String get tagline => 'हर पैसे का हिसाब रखें';

  @override
  String versionInfo(String version, String buildNumber) {
    return 'संस्करण $version (बिल्ड $buildNumber)';
  }

  @override
  String get appDescription =>
      'FlowPaisa एक व्यापक व्यक्तिगत वित्त और कैशफ्लो मैनेजर है। अपने खर्चों, आय, प्राप्य और देय राशि को एक ही स्थान पर ट्रैक करें। सुविधाओं में रसीद स्कैनिंग, व्हाट्सएप एकीकरण, क्लाउड बैकअप और सुंदर एनालिटिक्स शामिल हैं।';

  @override
  String get openSourceLicenses => 'ओपन सोर्स लाइसेंस';

  @override
  String get developedBy => 'द्वारा विकसित';

  @override
  String get developerName => 'TamataSoft';

  @override
  String get copyright => '© 2026 TamataSoft. सर्वाधिकार सुरक्षित।';

  @override
  String get receiptScan => 'रसीद स्कैन';

  @override
  String get cloudBackup => 'क्लाउड बैकअप';

  @override
  String get multilingual => 'बहुभाषी';

  @override
  String get availableCash => 'उपलब्ध नकद';

  @override
  String get quickActions => 'त्वरित कार्य';

  @override
  String get add => 'जोड़ें';

  @override
  String get scan => 'स्कैन';

  @override
  String get recentTransactions => 'हाल के लेन-देन';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get noTransactionsYet => 'अभी तक कोई लेन-देन नहीं है';

  @override
  String get tapToAddFirst => 'अपना पहला लेन-देन जोड़ने के लिए + पर टैप करें';

  @override
  String get cashFlow => 'कैश फ्लो';

  @override
  String get netCash => 'शुद्ध नकद';

  @override
  String get lendingCredit => 'उधार और क्रेडिट';

  @override
  String get netCredit => 'शुद्ध क्रेडिट';

  @override
  String get receive => 'प्राप्त करें';

  @override
  String get messageTemplatesDesc =>
      'संदेश टेम्पलेट्स को कस्टमाइज़ करना प्रीमियम उपयोगकर्ताओं के लिए उपलब्ध है।';

  @override
  String get upgradeToPremium => 'प्रीमियम में अपग्रेड करें';

  @override
  String get receivableReminders => 'प्राप्य रिमाइंडर';

  @override
  String get pendingReceivable => 'लंबित प्राप्य';

  @override
  String get receivedPayment => 'प्राप्त भुगतान';

  @override
  String get payableReminders => 'देय रिमाइंडर';

  @override
  String get pendingPayable => 'लंबित देय';

  @override
  String get paidPayable => 'भुगतान किया गया देय';

  @override
  String get transactionMessages => 'लेन-देन संदेश';

  @override
  String get transactionReceipt => 'लेन-देन रसीद';

  @override
  String get transactionSharePaidFor => 'लेन-देन साझा - भुगतान किया गया';

  @override
  String get transactionSharePaidBy => 'लेन-देन साझा - भुगतान किया गया द्वारा';

  @override
  String get transactionShareWillReceive => 'लेन-देन साझा - प्राप्त होगा';

  @override
  String get transactionShareReceivedFrom => 'लेन-देन साझा - प्राप्त हुआ से';

  @override
  String get transactionShareGeneric => 'लेन-देन साझा - सामान्य';

  @override
  String get shareMessages => 'साझा संदेश';

  @override
  String get receivableSharePending => 'प्राप्य साझा - लंबित';

  @override
  String get receivableShareReceived => 'प्राप्य साझा - प्राप्त';

  @override
  String get payableSharePending => 'देय साझा - लंबित';

  @override
  String get payableSharePaid => 'देय साझा - भुगतान किया गया';

  @override
  String get resetToDefault => 'डिफ़ॉल्ट पर रीसेट करें';

  @override
  String get resetTemplateTitle => 'टेम्पलेट रीसेट करें';

  @override
  String get resetTemplateMessage =>
      'क्या आप वाकई इस टेम्पलेट को डिफ़ॉल्ट पर रीसेट करना चाहते हैं? इस क्रिया को पूर्ववत नहीं किया जा सकता।';

  @override
  String get templateSaved => 'टेम्पलेट सफलतापूर्वक सहेजा गया';

  @override
  String get templateReset => 'टेम्पलेट डिफ़ॉल्ट पर रीसेट हो गया';

  @override
  String get enterTemplateText => 'टेम्पलेट टेक्स्ट दर्ज करें...';

  @override
  String useVariableHint(Object variableName) {
    return 'गतिशील सामग्री के लिए $variableName का उपयोग करें';
  }

  @override
  String get saveTemplate => 'टेम्पलेट सहेजें';

  @override
  String get availableVariables => 'उपलब्ध चर';

  @override
  String get variablesInstructions =>
      'आप अपने टेम्पलेट्स में इन चरों का उपयोग कर सकते हैं:';

  @override
  String variableContactName(Object contactName) {
    return '• $contactName - संपर्क का नाम';
  }

  @override
  String variableAmount(Object amount) {
    return '• $amount - मुद्रा के साथ प्रारूपित राशि';
  }

  @override
  String variableDescription(Object description) {
    return '• $description - लेन-देन/प्राप्य/देय का विवरण';
  }

  @override
  String variableDate(Object date) {
    return '• $date - प्रारूपित तारीख';
  }

  @override
  String variableDueDate(Object dueDate) {
    return '• $dueDate - प्रारूपित देय तिथि';
  }

  @override
  String variableCategoryName(Object categoryName) {
    return '• $categoryName - श्रेणी का नाम';
  }

  @override
  String variableLink(Object link) {
    return '• $link - डीप लिंक यूआरएल';
  }

  @override
  String variableType(Object type) {
    return '• $type - लेन-देन का प्रकार (आय/खर्च)';
  }

  @override
  String variableStatus(Object status) {
    return '• $status - स्थिति टेक्स्ट';
  }

  @override
  String variableRelationship(Object relationship) {
    return '• $relationship - संबंध टेक्स्ट';
  }

  @override
  String get noCurrencies => 'कोई मुद्रा नहीं है';

  @override
  String get currencyDeleted => 'मुद्रा सफलतापूर्वक हटा दी गई';

  @override
  String get addCurrency => 'मुद्रा जोड़ें';

  @override
  String get currencyNameLabel => 'मुद्रा का नाम';

  @override
  String get currencyNameHint => 'जैसे: यूरो, ब्रिटिश पाउंड';

  @override
  String get pleaseEnterCurrencyName => 'कृपया मुद्रा का नाम दर्ज करें';

  @override
  String get currencySymbolLabel => 'मुद्रा प्रतीक';

  @override
  String get currencySymbolHint => 'जैसे: €, £, ¥';

  @override
  String get currencySymbolHelper =>
      'आप इमोजी, अक्षर या प्रतीकों का उपयोग कर सकते हैं';

  @override
  String get pleaseEnterCurrencySymbol => 'कृपया मुद्रा प्रतीक दर्ज करें';

  @override
  String get symbolLengthError => 'प्रतीक 10 वर्णों या उससे कम का होना चाहिए';

  @override
  String get currencyCodeLabel => 'मुद्रा कोड';

  @override
  String get currencyCodeHint => 'जैसे: EUR, GBP, JPY';

  @override
  String get currencyCodeHelper => 'ISO 4217 कोड (3 वर्ण)';

  @override
  String get pleaseEnterCurrencyCode => 'कृपया मुद्रा कोड दर्ज करें';

  @override
  String get codeLengthError => 'कोड ठीक 3 वर्णों का होना चाहिए';

  @override
  String get decimalPlacesLabel => 'दशमलव स्थान';

  @override
  String get decimalPlacesHelper => 'दशमलव के बाद अंकों की संख्या';

  @override
  String get noDecimals => '0 (कोई दशमलव नहीं)';

  @override
  String get oneDecimal => '1 दशमलव स्थान';

  @override
  String get twoDecimals => '2 दशमलव स्थान';

  @override
  String get saveCurrency => 'मुद्रा सहेजें';

  @override
  String get currencyAdded => 'मुद्रा सफलतापूर्वक जोड़ दी गई';

  @override
  String get editCurrency => 'मुद्रा संपादित करें';

  @override
  String get updateCurrency => 'मुद्रा अपडेट करें';

  @override
  String get currencyUpdated => 'मुद्रा सफलतापूर्वक अपडेट कर दी गई';

  @override
  String get selectDateRange => 'तारीख सीमा चुनें';

  @override
  String get exportSuccessful => 'एक्सपोर्ट सफल';

  @override
  String get transactionHistoryReady =>
      'आपका लेन-देन इतिहास साझा करने के लिए तैयार है।';

  @override
  String get done => 'हो गया';

  @override
  String get pdfReportReady => 'आपकी पीडीएफ रिपोर्ट तैयार है। एक क्रिया चुनें:';

  @override
  String get testPdfReady => 'टेस्ट पीडीएफ तैयार है';

  @override
  String get testPdfCategoriesReady =>
      'सभी श्रेणियों के साथ टेस्ट पीडीएफ तैयार है। एक क्रिया चुनें:';

  @override
  String get exportYourData => 'अपना डेटा एक्सपोर्ट करें';

  @override
  String get downloadHistoryCsvPdf =>
      'अपना लेन-देन इतिहास CSV या PDF के रूप में डाउनलोड करें';

  @override
  String get startDate => 'शुरू होने की तारीख';

  @override
  String get endDate => 'समाप्त होने की तारीख';

  @override
  String get selectDate => 'तारीख चुनें';

  @override
  String get exportSummary => 'एक्सपोर्ट सारांश';

  @override
  String get totalTransactions => 'कुल लेन-देन';

  @override
  String get csvInfoNote =>
      'सीएसवी फाइलें एक्सेल या Google शीट्स में खोली जा सकती हैं। पीडीएफ रिपोर्ट साझा करने के लिए सर्वोत्तम हैं।';

  @override
  String get testCategoriesPdf => 'टेस्ट श्रेणियां पीडीएफ (आइकन)';

  @override
  String get transactionDetails => 'लेन-देन विवरण';

  @override
  String get autoGenerated => 'स्वचालित रूप से उत्पन्न';

  @override
  String get scheduled => 'शेड्यूल किया गया';

  @override
  String get sendMessage => 'संदेश भेजें';

  @override
  String get linkedEntry => 'लिंक्ड प्रविष्टि';

  @override
  String paidOn(String date) {
    return 'भुगतान की तारीख: $date';
  }

  @override
  String receivedOn(String date) {
    return 'प्राप्ति की तारीख: $date';
  }

  @override
  String get deleteTransactionTitle => 'लेन-देन हटाएं';

  @override
  String get deleteTransactionMessage =>
      'क्या आप वाकई इस लेन-देन को हटाना चाहते हैं? यह क्रिया वापस नहीं ली जा सकती।';

  @override
  String get transactionDeleted => 'लेन-देन हटा दिया गया';

  @override
  String get errorLoadingCurrency => 'मुद्रा लोड करने में त्रुटि';

  @override
  String get balanceLabel => 'शेष';

  @override
  String get errorLabel => 'त्रुटि';

  @override
  String get importTransaction => 'लेन-देन आयात करें';

  @override
  String get importReceivable => 'प्राप्य आयात करें';

  @override
  String get importPayable => 'देय आयात करें';

  @override
  String sharedBy(String name) {
    return '$name द्वारा साझा किया गया';
  }

  @override
  String get sender => 'प्रेषक';

  @override
  String get someone => 'कोई';

  @override
  String markedAsStatus(String name, String status) {
    return '$name ने इसे $status के रूप में चिह्नित किया है। अपना स्थानीय रिकॉर्ड अपडेट करें?';
  }

  @override
  String get itemAlreadyImported => 'यह आइटम पहले ही आयात किया जा चुका है।';

  @override
  String get importDetails => 'विवरण आयात करें';

  @override
  String get viewDetails => 'विवरण देखें';

  @override
  String get type => 'प्रकार';

  @override
  String get remaining => 'शेष';

  @override
  String get daily => 'दैनिक';

  @override
  String get monthly => 'मासिक';

  @override
  String get limitReached => 'सीमा समाप्त';

  @override
  String get proLabel => 'PRO';

  @override
  String get deleteItem => 'आइटम हटाएं';

  @override
  String get confirmDeleteItem => 'क्या आप वाकई इस आइटम को हटाना चाहते हैं?';

  @override
  String sharePayableCompleted(String amount, String date, String link) {
    return 'नमस्ते!\n\n$date को $amount का भुगतान पूरा हो गया है।\n\nFlowPaisa में सिंक करें:\n$link';
  }

  @override
  String sharePayablePending(String amount, String date, String link) {
    return 'मैंने आपके $amount देने हैं\nतारीख: $date\n\nFlowPaisa में देखें:\n$link';
  }

  @override
  String shareReceivableReceived(String amount, String date, String link) {
    return 'नमस्ते!\n\n$date को $amount का भुगतान प्राप्त हो गया है।\n\nFlowPaisa में सिंक करें:\n$link';
  }

  @override
  String shareReceivablePending(String amount, String date, String link) {
    return 'प्राप्त होने वाली राशि: $amount\nतारीख: $date\n\nFlowPaisa में देखें:\n$link';
  }

  @override
  String shareTransactionMessage(String amount, String date, String link) {
    return '$date को $amount का लेन-देन रिकॉर्ड किया गया।\n\nFlowPaisa में देखें:\n$link';
  }

  @override
  String get shareViaWhatsApp => 'व्हाट्सएप के माध्यम से साझा करें';

  @override
  String toContact(String name) {
    return '$name को';
  }

  @override
  String get chooseContact => 'संपर्क चुनें';

  @override
  String get copyLink => 'लिंक कॉपी करें';

  @override
  String get copyDeepLinkSubtitle => 'डीप लिंक क्लिपबोर्ड पर कॉपी करें';

  @override
  String get scanReceipt => 'रसीद स्कैन करें';

  @override
  String get camera => 'कैमरा';

  @override
  String get gallery => 'गैलरी';

  @override
  String get scanningReceipt => 'रसीद स्कैन हो रही है...';

  @override
  String get noReceiptSelected => 'कोई रसीद नहीं चुनी गई';

  @override
  String get reviewAndEdit => 'समीक्षा करें और संपादित करें';

  @override
  String get merchantName => 'व्यापारी का नाम';

  @override
  String get totalAmount => 'कुल राशि';

  @override
  String get proceedToAddTransaction => 'लेन-देन जोड़ने के लिए आगे बढ़ें';

  @override
  String errorPickingImage(String error) {
    return 'छवि लेने में त्रुटि: $error';
  }

  @override
  String errorScanningReceipt(String error) {
    return 'रसीद स्कैन करने में त्रुटि: $error';
  }

  @override
  String get noCategoriesFound => 'कोई श्रेणी नहीं मिली';

  @override
  String get paidRelationship => 'भुगतान संबंध';

  @override
  String get paidFor => 'के लिए भुगतान किया';

  @override
  String get paidBy => 'द्वारा भुगतान किया गया';

  @override
  String get iWillReceiveBack => 'मुझे वापस मिलेगा';

  @override
  String get someonePaidForMe => 'किसी ने मेरे लिए भुगतान किया';

  @override
  String get receivedRelationship => 'प्राप्ति संबंध';

  @override
  String get iOwe => 'मेरा कर्ज';

  @override
  String get receivedLoan => 'ऋण प्राप्त हुआ';

  @override
  String get receiveLater => 'बाद में प्राप्त करें';

  @override
  String get schedulePattern => 'शेड्यूल पैटर्न';

  @override
  String get startDateOptional => 'शुरू होने की तारीख (वैकल्पिक)';

  @override
  String get endDateOptional => 'समाप्त होने की तारीख (वैकल्पिक)';

  @override
  String get scheduleUpdated => 'शेड्यूल सफलतापूर्वक अपडेट किया गया';

  @override
  String get updateSchedule => 'शेड्यूल अपडेट करें';

  @override
  String get updating => 'अपडेट हो रहा है...';

  @override
  String get contactOptional => 'संपर्क (वैकल्पिक)';

  @override
  String get pleaseSelectContactRelationship =>
      'कृपया इस संबंध के लिए एक संपर्क चुनें';

  @override
  String get weekly => 'साप्ताहिक';

  @override
  String weeklyWithDays(String days) {
    return 'साप्ताहिक: $days';
  }

  @override
  String monthlyWithDay(String day) {
    return 'मासिक: $day';
  }

  @override
  String get schedules => 'शेड्यूल';

  @override
  String get generate100DummyTransactions => '100 डमी लेन-देन उत्पन्न करें';

  @override
  String get generated100DummyTransactions => '100 डमी लेन-देन उत्पन्न हुए';

  @override
  String get errorLoadingTransactions => 'लेन-देन लोड करने में त्रुटि';

  @override
  String get noSchedulesFound => 'कोई शेड्यूल नहीं मिला';

  @override
  String get noMoreTransactions => 'कोई और लेन-देन नहीं हैं';

  @override
  String get scheduleDeleted => 'शेड्यूल सफलतापूर्वक हटा दिया गया';

  @override
  String get autoBadge => 'स्वचालित';

  @override
  String get uncategorized => 'बिना श्रेणी';

  @override
  String get editSchedule => 'शेड्यूल संपादित करें';

  @override
  String get schedule => 'शेड्यूल';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get notesLabel => 'नोट्स';

  @override
  String get deleteContactTitle => 'संपर्क हटाएं';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get limitReachedTitle => 'सीमा तक पहुँच गए';

  @override
  String get upgrade => 'अपग्रेड करें';

  @override
  String get summary => 'सारांश';

  @override
  String get noTransactionsInRange => 'इस तारीख सीमा में कोई लेन-देन नहीं है।';

  @override
  String get noPayablesInRange => 'इस तारीख सीमा में कोई देय राशि नहीं है।';

  @override
  String get noReceivablesInRange => 'इस तारीख सीमा में कोई प्राप्य नहीं है।';

  @override
  String get topCategoriesVisual => 'शीर्ष श्रेणियां (दृश्य)';

  @override
  String get incomeVsExpenseTrendVisual => 'आय बनाम व्यय रुझान (दृश्य)';

  @override
  String get payableVsReceivableTrendVisual => 'देय बनाम प्राप्य रुझान (दृश्य)';

  @override
  String get incomeShort => 'आय:';

  @override
  String get shareTransaction => 'लेन-देन साझा करें';

  @override
  String get sharePaymentRequest => 'भुगतान अनुरोध साझा करें';

  @override
  String get sharePaymentAcknowledgment => 'भुगतान पावती साझा करें';

  @override
  String get openingWhatsApp => 'व्हाट्सएप खोला जा रहा है...';

  @override
  String get linkCopied => 'लिंक क्लिपबोर्ड पर कॉपी किया गया!';

  @override
  String failedToShare(String error) {
    return 'साझा करने में विफल: $error';
  }

  @override
  String failedToCopyLink(String error) {
    return 'लिंक कॉपी करने में विफल: $error';
  }

  @override
  String get expenseShort => 'व्यय:';

  @override
  String suggestedLabel(String name) {
    return 'सुझाया गया: $name';
  }

  @override
  String get deleteCashbookTitle => 'कैशबुक हटाएं';

  @override
  String get deletePermanently => 'स्थायी रूप से हटाएं';

  @override
  String get pleaseEnterValidAmount => 'कृपया एक वैध राशि दर्ज करें';

  @override
  String get categoryEducation => 'शिक्षा';

  @override
  String get categoryGift => 'उपहार';

  @override
  String get statusPaid => 'भुगतान किया गया';

  @override
  String get statusReceived => 'प्राप्त हुआ';

  @override
  String get statusSettled => 'निपटाया गया';

  @override
  String get statusOverdue => 'देय तिथि निकल गई';

  @override
  String get statusSent => 'भेजा गया';

  @override
  String get statusFailed => 'विफल';

  @override
  String get payableTag => 'देय';

  @override
  String get receivableTag => 'प्राप्य';

  @override
  String get receivedTag => 'प्राप्त';

  @override
  String get paidTag => 'भुगतान किया गया';

  @override
  String get currencyUSD => 'अमेरिकी डॉलर (\$)';

  @override
  String get currencyINR => 'भारतीय रुपया (₹)';

  @override
  String get currencyPKR => 'पाकिस्तानी रुपया (Rs)';

  @override
  String get inactive => 'निष्क्रिय';

  @override
  String get sundayShort => 'रवि';

  @override
  String get mondayShort => 'सोम';

  @override
  String get tuesdayShort => 'मंगल';

  @override
  String get wednesdayShort => 'बुध';

  @override
  String get thursdayShort => 'गुरु';

  @override
  String get fridayShort => 'शुक्र';

  @override
  String get saturdayShort => 'शनि';

  @override
  String get from => 'से';

  @override
  String get to => 'तक';

  @override
  String get willReceive => 'प्राप्त होगा';

  @override
  String get selectSchedulePattern => 'शेड्यूल पैटर्न चुनें';

  @override
  String get daysOfWeek => 'सप्ताह के दिन';

  @override
  String get daysOfMonth => 'महीने के दिन';

  @override
  String get sunday => 'रविवार';

  @override
  String get monday => 'सोमवार';

  @override
  String get tuesday => 'मंगलवार';

  @override
  String get wednesday => 'बुधवार';

  @override
  String get thursday => 'गुरुवार';

  @override
  String get friday => 'शुक्रवार';

  @override
  String get saturday => 'शनिवार';

  @override
  String get updateReceivable => 'प्राप्य अपडेट करें';

  @override
  String get newCashbook => 'नई कैशबुक';

  @override
  String get freeLimitReached => 'मुफ्त सीमा समाप्त';

  @override
  String get cashbookNameHint => 'जैसे: व्यक्तिगत, व्यवसाय';

  @override
  String get selectIcon => 'आइकन चुनें';

  @override
  String get selectColor => 'रंग चुनें';

  @override
  String get updateCashbook => 'कैशबुक अपडेट करें';

  @override
  String get noOtherCashbooks =>
      'कॉपी करने के लिए कोई अन्य कैशबुक उपलब्ध नहीं है।';

  @override
  String get selectSourceCashbook => 'स्रोत कैशबुक चुनें';

  @override
  String toTarget(String name) {
    return 'लक्ष्य: $name';
  }

  @override
  String get whatToCopy => 'क्या कॉपी करना है?';

  @override
  String get userProfile => 'उपयोगकर्ता प्रोफ़ाइल';

  @override
  String get userProfileDescription => 'नाम, ईमेल और बुनियादी जानकारी';

  @override
  String get preferencesDescription => 'मुद्रा और तारीख प्रारूप सेटिंग्स';

  @override
  String get messageTemplatesDescription => 'व्हाट्सएप संदेश टेम्पलेट्स';

  @override
  String get copy => 'कॉपी करें';

  @override
  String get pleaseSelectSource => 'कृपया स्रोत कैशबुक चुनें';

  @override
  String get pleaseSelectAtLeastOne =>
      'कृपया कॉपी करने के लिए कम से कम एक आइटम चुनें';

  @override
  String get preferencesCopied => 'प्राथमिकताएं सफलतापूर्वक कॉपी की गईं';

  @override
  String errorCopyingPreferences(String error) {
    return 'प्राथमिकताएं कॉपी करने में त्रुटि: $error';
  }

  @override
  String get reset => 'रीसेट करें';

  @override
  String get template => 'टेम्पलेट';

  @override
  String get variables => 'चर';

  @override
  String get close => 'बंद करें';

  @override
  String get dashboard => 'डैशबोर्ड';

  @override
  String get error => 'त्रुटि';

  @override
  String get currencies => 'मुद्राएं';

  @override
  String get backup => 'बैकअप';

  @override
  String get premium => 'प्रीमियम';

  @override
  String get free => 'मुफ्त';

  @override
  String get transactionAlreadyImported =>
      'लेन-देन पहले ही आयात किया जा चुका है';

  @override
  String get pleaseSelectContactLinked =>
      'कृपया लिंक्ड लेन-देन के लिए एक संपर्क चुनें';

  @override
  String get transactionLinkedAdded =>
      'लेन-देन लिंक किया गया और सफलतापूर्वक जोड़ा गया';

  @override
  String get transactionAdded => 'लेन-देन सफलतापूर्वक जोड़ा गया';

  @override
  String createCategoryNamed(String name) {
    return '\"$name\" श्रेणी बनाएं';
  }

  @override
  String get tapToAddCategory => 'इस श्रेणी को जोड़ने के लिए टैप करें';

  @override
  String get frequent => 'अक्सर';

  @override
  String get saving => 'सहेजा जा रहा है...';

  @override
  String get transactionDeletedSuccessfully =>
      'लेन-देन सफलतापूर्वक हटा दिया गया';

  @override
  String get googleDrive => 'Google ड्राइव';

  @override
  String get activeCashbook => 'सक्रिय कैशबुक';

  @override
  String get syncAndBackupApplyTo =>
      'नीचे दी गई सभी सिंक और बैकअप क्रियाएं केवल इसी कैशबुक पर लागू होती हैं।';

  @override
  String get synchronization => 'सिंक्रनाइज़ेशन';

  @override
  String get syncActive => 'सिंक सक्रिय है';

  @override
  String get syncDescription =>
      'सिंक्रनाइज़ेशन छोटे परिवर्तनों को मर्ज करके आपके डेटा को आपके सभी उपकरणों पर अपडेट रखता है। यह तेज़ है और स्वचालित रूप से चलता है।';

  @override
  String get syncNow => 'अभी सिंक करें';

  @override
  String get syncTriggered => 'बैकग्राउंड में सिंक शुरू हो गया है';

  @override
  String get autoSync => 'आटो सिंक';

  @override
  String get syncInterval => 'सिंक अंतराल (घंटे)';

  @override
  String get hour => 'घंटा';

  @override
  String get hours => 'घंटे';

  @override
  String localVersion(int version) {
    return 'स्थानीय संस्करण: $version';
  }

  @override
  String cloudVersion(int version) {
    return 'क्लाउड संस्करण: $version';
  }

  @override
  String lastSync(String time) {
    return 'अंतिम सिंक: $time';
  }

  @override
  String get autoBackup => 'आटो बैकअप';

  @override
  String get manual => 'मैनुअल';

  @override
  String get backupDescription =>
      'एक पूर्ण बैकअप आपके डेटाबेस का एक पूर्ण स्नैपशॉट बनाता है। इसे ऐतिहासिक रिकॉर्ड या बड़ी समस्याओं से निपटने के लिए उपयोग करें।';

  @override
  String get syncRecovery => 'सिंक रिकवरी';

  @override
  String get syncRecoveryDescription =>
      'यदि आपने सिंक त्रुटि को ठीक करने के लिए इस बैकअप को बहाल किया है, तो आपको क्लाउड सिंक को इस संस्करण पर रीसेट करना चाहिए। यह इस बहाल डेटा को \"सत्य का स्रोत\" बनाता है।';

  @override
  String get resetCloudSync => 'क्लाउड सिंक रीसेट करें';

  @override
  String get syncManifestReset => 'सिंक मेनिफेस्ट सफलतापूर्वक रीसेट हो गया';

  @override
  String failedToResetSync(String error) {
    return 'सिंक रीसेट करने में विफल: $error';
  }

  @override
  String get backupToFile => 'फ़ाइल में बैकअप लें';

  @override
  String get restoreFromFile => 'फ़ाइल से बहाल करें';

  @override
  String get clearData => 'डेटा साफ़ करें';

  @override
  String get addCashbook => 'कैशबुक जोड़ें';

  @override
  String get cashbookCreated => 'कैशबुक सफलतापूर्वक बनाई गई';

  @override
  String get fontSelection => 'फ़ॉन्ट चयन';

  @override
  String get restoreToNewCashbookTitle => 'नई कैशबुक में बहाल करें?';

  @override
  String restoreToNewCashbookMessage(String cloudCashbookName) {
    return 'यह बैकअप $cloudCashbookName का है। इसे बहाल करने से इस डिवाइस पर इसके डेटा के साथ एक नई कैशबुक प्रविष्टि बन जाएगी।';
  }

  @override
  String get overrideExistingCashbookTitle => 'मौजूदा कैशबुक को ओवरराइट करें?';

  @override
  String overrideExistingCashbookMessage(
      String cloudCashbookName, String activeCashbookName) {
    return 'यह बैकअप $cloudCashbookName का है। इसे बहाल करने से आपकी वर्तमान सक्रिय कैशबुक $activeCashbookName का डेटा ओवरराइट हो जाएगा।';
  }

  @override
  String restoreSuccessNew(String name) {
    return 'कैशबुक $name सफलतापूर्वक बनाई गई। आप इसे होम स्क्रीन से स्विच कर सकते हैं।';
  }

  @override
  String get restoreOptionOverride => 'ओवरराइट करें';

  @override
  String get restoreOptionNewEntry => 'नई प्रविष्टि';

  @override
  String get filters => 'फ़िल्टर';

  @override
  String get dateRange => 'तारीख सीमा';

  @override
  String get transactionType => 'लेन-देन का प्रकार';

  @override
  String get amountRange => 'राशि सीमा';

  @override
  String get minAmount => 'न्यूनतम राशि';

  @override
  String get maxAmount => 'अधिकतम राशि';

  @override
  String get applyFilters => 'फ़िल्टर लागू करें';

  @override
  String get filterByDueDate => 'देय तिथि के अनुसार फ़िल्टर करें';

  @override
  String get notificationBackupSuccessTitle => 'बैकअप सफल';

  @override
  String notificationBackupSuccessMessage(String name) {
    return 'गूगल ड्राइव पर \"$name\" का सफलतापूर्वक बैकअप लिया गया।';
  }

  @override
  String get notificationSyncCompleteTitle => 'बैकग्राउंड सिंक पूर्ण';

  @override
  String notificationSyncCompleteMessage(int count) {
    return 'बैकग्राउंड में $count कैशबुक सफलतापूर्वक सिंक की गईं।';
  }

  @override
  String get cloudCashbooks => 'क्लाउड कैशबुक';

  @override
  String get main => 'मुख्य';

  @override
  String get cloudDb => 'क्लाउड डेटाबेस';

  @override
  String get versions => 'संस्करण';

  @override
  String get local => 'स्थानीय';

  @override
  String get cloud => 'क्लाउड';

  @override
  String rows(int count) {
    return '$count पंक्तियाँ';
  }

  @override
  String get primeCloudWithLocal => 'स्थानीय के साथ क्लाउड को प्राइम करें';

  @override
  String get resetCloudVersion => 'क्लाउड संस्करण रीसेट करें';

  @override
  String resetCloudVersionMessage(Object version) {
    return 'यह क्लाउड संस्करण को आपके स्थानीय संस्करण ($version) से मेल खाने के लिए मजबूर करेगा।\n\nइसका उपयोग केवल तभी करें जब आपका क्लाउड मेनिफेस्ट दूषित हो या आपके स्थानीय डेटा के साथ सिंक न हो।';
  }

  @override
  String get resetNow => 'अभी रीसेट करें';

  @override
  String get cloudVersionResetSuccess =>
      'क्लाउड संस्करण सफलतापूर्वक रीसेट हो गया';

  @override
  String cloudVersionResetFailed(Object error) {
    return 'क्लाउड संस्करण रीसेट करने में विफल: $error';
  }

  @override
  String get syncIntervalLabel => 'सिंक अंतराल';

  @override
  String get resetLocalSyncState => 'स्थानीय सिंक स्थिति रीसेट करें';

  @override
  String get resetLocalSyncMessage =>
      'यह आपके सभी स्थानीय रिकॉर्ड को \"अनसिंक\" के रूप में चिह्नित करेगा और आपके स्थानीय संस्करण को 0 पर रीसेट कर देगा। इसके बाद \"अभी सिंक करें\" पर टैप करने से आपका सारा डेटा क्लाउड पर फिर से अपलोड हो जाएगा।\n\nइसका उपयोग तब करें जब आप अपने स्थानीय डेटा का पूर्ण पुनः सिंक करना चाहते हैं।';

  @override
  String get localSyncResetSuccess =>
      'स्थानीय सिंक स्थिति सफलतापूर्वक रीसेट हो गई';

  @override
  String get clearAllCloudData => 'सभी क्लाउड डेटा साफ़ करें';

  @override
  String get clearAllCloudDataMessage =>
      'यह Google Drive से आपके सभी FlowPaisa बैकअप और सिंक्रनाइज़ेशन डेटा को स्थायी रूप से हटा देगा। इस क्रिया को पूर्ववत नहीं किया जा सकता है।\n\nक्या आप वाकई सभी क्लाउड डेटा साफ़ करना चाहते हैं?';

  @override
  String get cloudDataClearedSuccess =>
      'सभी क्लाउड डेटा सफलतापूर्वक साफ़ कर दिया गया';

  @override
  String get clearNow => 'अभी साफ़ करें';

  @override
  String get upcomingSyncDeltas => 'आगामी सिंक डेल्टा';

  @override
  String get recentSyncDeltas => 'हाल के सिंक डेल्टा';

  @override
  String get manifestContentLocked => 'मेनिफेस्ट सामग्री (लॉक)';

  @override
  String get deltaContent => 'डेल्टा सामग्री';

  @override
  String get refreshStatus => 'स्थिति रिफ्रेश करें';

  @override
  String get refreshBackups => 'बैकअप रिफ्रेश करें';

  @override
  String get locked => 'लॉक';

  @override
  String lockedWithTime(int minutes) {
    return 'लॉक ($minutes मिनट)';
  }

  @override
  String get payableOverdue => 'देय अतिदेय';

  @override
  String payableOverdueMessage(String description, String date) {
    return '$description के लिए भुगतान $date को देय था';
  }

  @override
  String get receivableOverdue => 'प्राप्य अतिदेय';

  @override
  String receivableOverdueMessage(String description, String date) {
    return '$description के लिए भुगतान $date को देय था';
  }

  @override
  String get upcomingPayable => 'आगामी देय';

  @override
  String upcomingPayableMessage(String description, String date) {
    return '$description के लिए भुगतान कल ($date) देय है';
  }

  @override
  String get upcomingReceivable => 'आगामी प्राप्य';

  @override
  String upcomingReceivableMessage(String description, String date) {
    return '$description के लिए भुगतान कल ($date) देय है';
  }

  @override
  String get urgent => 'अत्यावश्यक';

  @override
  String get deleteCloudCashbook => 'क्लाउड कैशबुक हटाएं?';

  @override
  String deleteCloudCashbookMessage(String name) {
    return 'क्या आप वाकई गूगल ड्राइव سے \"$name\" को हटाना चाहते हैं? यह इसके सभी बैकअप और सिंक डेटा को हटा देगा। यह क्रिया वापस नहीं ली जा सकती।';
  }

  @override
  String get cloudCashbookDeletedSuccess =>
      'क्लाउड कैशबुक सफलतापूर्वक हटा दी गई';

  @override
  String get myShare => 'मेरा हिस्सा';

  @override
  String get split => 'विभाजित करें';

  @override
  String get contactShare => 'संपर्क का हिस्सा';

  @override
  String get othersShare => 'दूसरों का हिस्सा';

  @override
  String get myShareSuffix => ' (मेरा हिस्सा)';

  @override
  String get othersShareSuffix => ' (दूसरों का हिस्सा)';
}
