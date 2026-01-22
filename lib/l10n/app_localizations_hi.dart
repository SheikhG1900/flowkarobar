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
  String get transactions => 'लेनदेन';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get totalBalance => 'कुल शेष';

  @override
  String get income => 'आय';

  @override
  String get expense => 'खर्च';

  @override
  String get addTransaction => 'लेनदेन जोड़ें';

  @override
  String get editTransaction => 'लेनदेन संपादित करें';

  @override
  String get scheduleCreated => 'शेड्यूल सफलतापूर्वक बनाया गया';

  @override
  String get transactionUpdated => 'लेनदेन सफलतापूर्वक अपडेट किया गया';

  @override
  String get updateTransaction => 'लेनदेन अपडेट करें';

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
  String get defaultPremiumPrice => '₹999';

  @override
  String errorOccurred(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get noDataForTrends => 'रुझानों के लिए कोई डेटा नहीं';

  @override
  String get cancelled => 'रद्द कर दिया गया';

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
    return 'धनात्मक: $amount';
  }

  @override
  String negativeAmount(String amount) {
    return 'ऋणात्मक: $amount';
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
    return 'पुनर्स्थापना विफल: $error';
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
    return 'निर्यात करने में त्रुटि: $error';
  }

  @override
  String exportSavedTo(String path) {
    return 'निर्यात $path में सहेजा गया';
  }

  @override
  String notificationTitlePrefix(String title) {
    return 'सूचना: $title';
  }

  @override
  String errorDeletingTransaction(String error) {
    return 'लेनदेन हटाने में त्रुटि: $error';
  }

  @override
  String noTypeCategories(String type) {
    return 'कोई $type श्रेणियां नहीं';
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
  String get noTransactions => 'कोई लेनदेन नहीं मिला';

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
  String get english => 'अंग्रेज़ी';

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
  String get cashbookAdded => 'कैशबुक सफलतापूर्वक जोड़ी गई';

  @override
  String get cashbookUpdated => 'कैशबुक सफलतापूर्वक अपडेट की गई';

  @override
  String get pleaseEnterName => 'कृपया नाम दर्ज करें';

  @override
  String get copyPreferences => 'पसंद कॉपी करें';

  @override
  String get copyPreferencesFrom => 'यहाँ से पसंद कॉपी करें';

  @override
  String get copyPreferencesSubtitle =>
      'श्रेणियां और सेटिंग्स चयनित कैशबुक से कॉपी की जाएंगी।';

  @override
  String get none => 'कोई नहीं';

  @override
  String get howMuch => 'कितना?';

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
  String get descriptionHint => 'जैसे, दोपहर के भोजन के पैसे';

  @override
  String get premiumFeature => 'प्रीमियम सुविधा';

  @override
  String get premiumRequired =>
      'इस सुविधा के लिए प्रीमियम सदस्यता की आवश्यकता है।';

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
  String get categoryShopping => 'खरीददारी';

  @override
  String get categoryBills => 'बिल';

  @override
  String get categoryEntertainment => 'मनोरंजन';

  @override
  String get categoryHealth => 'स्वास्थ्य';

  @override
  String get categorySalary => 'वेतन';

  @override
  String get categoryBusiness => 'व्यापार';

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
  String get statusCancelled => 'रद्द';

  @override
  String get receivables => 'प्राप्य';

  @override
  String get pending => 'लंबित';

  @override
  String get overdue => 'देय तिथि बीत गई';

  @override
  String get receivedLabel => 'प्राप्त';

  @override
  String get generateDummyReceivables => '100 डमी प्राप्य उत्पन्न करें';

  @override
  String dummyGenerated(int count) {
    return '$count डमी आइटम उत्पन्न किए गए';
  }

  @override
  String get errorLoadingReceivables => 'प्राप्य लोड करने में त्रुटि';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get noPendingReceivables => 'कोई लंबित प्राप्य नहीं';

  @override
  String get noOverdueReceivables => 'कोई देय प्राप्य नहीं';

  @override
  String get noReceivedPayments => 'कोई प्राप्त भुगतान नहीं';

  @override
  String get addReceivableSubtitle =>
      'आपको देय धन को ट्रैक करने के लिए एक प्राप्य जोड़ें';

  @override
  String get receivablesUpToDate => 'सभी प्राप्य अद्यतित हैं';

  @override
  String get markReceivedSubtitle =>
      'लंबित प्राप्य को प्राप्त के रूप में चिह्नित करें';

  @override
  String get noMoreItems => 'और आइटम नहीं हैं';

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
  String get linkedTransaction => 'लिंक्ड लेनदेन';

  @override
  String get markAsReceived => 'प्राप्त के रूप में चिह्नित करें';

  @override
  String get deleteReceivableTitle => 'प्राप्य हटाएं';

  @override
  String get deleteReceivableMessage =>
      'क्या आप वाकई इस प्राप्य को हटाना चाहते हैं? यह कार्रवाई पूर्ववत नहीं की जा सकती।';

  @override
  String get markedAsReceived => 'प्राप्त के रूप में चिह्नित किया गया';

  @override
  String get informContactSettlement =>
      'प्राप्य प्राप्त के रूप में चिह्नित किया गया। संपर्क को सूचित करें?';

  @override
  String addContactWithName(String name) {
    return '\"$name\" जोड़ें';
  }

  @override
  String get payables => 'देय';

  @override
  String get generateDummyPayables => '100 डमी देय उत्पन्न करें';

  @override
  String get dummyPayablesGenerated => '100 डमी देय उत्पन्न किए गए';

  @override
  String get errorLoadingPayables => 'देय राशि लोड करने में त्रुटि';

  @override
  String get noPendingPayables => 'कोई लंबित देय नहीं';

  @override
  String get noOverduePayables => 'कोई अतिदेय देय नहीं';

  @override
  String get noPaidBills => 'कोई भुगतान किया गया बिल नहीं';

  @override
  String get addPayableSubtitle =>
      'आपके द्वारा बकाया धन को ट्रैक करने के लिए एक देय जोड़ें';

  @override
  String get allPayablesUpToDate => 'सभी देय राशियाँ अद्यतित हैं';

  @override
  String get markPendingAsPaidSubtitle =>
      'लंबित देय राशियों को भुगतान के रूप में चिह्नित करें';

  @override
  String get noMorePayables => 'कोई और देय राशि नहीं';

  @override
  String get payableDeleted => 'देय राशि हटा दी गई';

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
      'क्या आप वाकई इस देय को हटाना चाहते हैं? यह कार्रवाई पूर्ववत नहीं की जा सकती।';

  @override
  String get markedAsPaid => 'भुगतान के रूप में चिह्नित किया गया';

  @override
  String get informContactSettlementPayable =>
      'देय राशि का भुगतान चिह्नित किया गया। संपर्क को सूचित करें?';

  @override
  String get autoCreateExpense => 'स्वचालित रूप से खर्च बनाएं';

  @override
  String get autoCreateExpenseSubtitle =>
      'भुगतान के रूप में चिह्नित होने पर खर्च के रूप में रिकॉर्ड करें';

  @override
  String get appRefreshLanguage => 'नई भाषा लागू करने के लिए ऐप रीफ्रेश होगा';

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
  String get preferences => 'पसंद';

  @override
  String get dateFormat => 'तारीख का प्रारूप';

  @override
  String get saveProfile => 'प्रोफ़ाइल सहेजें';

  @override
  String get profileUpdated => 'प्रोफ़ाइल सफलतापूर्वक अपडेट की गई';

  @override
  String get selectDateFormat => 'तारीख का प्रारूप चुनें';

  @override
  String get customFormat => 'कस्टम प्रारूप';

  @override
  String get enterCustomDateFormat =>
      'अपना खुद का तारीख प्रारूप पैटर्न दर्ज करें';

  @override
  String get customDateFormat => 'कस्टम तारीख प्रारूप';

  @override
  String get formatPattern => 'प्रारूप पैटर्न';

  @override
  String get dateFormatInstructions =>
      'मानक ICU पैटर्न का उपयोग करें जैसे:\ndd: दिन, MM: महीना, yyyy: वर्ष\nMMM: छोटा महीना, EEEE: पूरा दिन';

  @override
  String get lightThemeDescription => 'हमेशा लाइट थीम का उपयोग करें';

  @override
  String get darkThemeDescription => 'हमेशा डार्क थीम का उपयोग करें';

  @override
  String get systemThemeDescription => 'डिवाइस सेटिंग्स का पालन करें';

  @override
  String get themeChangesApplyImmediately => 'थीम परिवर्तन तुरंत लागू होते हैं';

  @override
  String get analytics => 'एनालिटिक्स';

  @override
  String get exportAnalyticsPDF => 'एनालिटिक्स पीडीएफ निर्यात करें';

  @override
  String get refreshAnalytics => 'एनालिटिक्स रीफ्रेश करें';

  @override
  String get financialSummary => 'वित्तीय सारांश';

  @override
  String get contactSummaries => 'संपर्क सारांश';

  @override
  String get expensesByCategory => 'श्रेणी के अनुसार खर्च';

  @override
  String get incomeVsExpenseTrend => 'आय बनाम खर्च का रुझान';

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
  String get unlockPremium => 'प्रीमियम अनलॉक करें';

  @override
  String get noContactActivity => 'इस अवधि के लिए कोई संपर्क गतिविधि नहीं';

  @override
  String get settled => 'निपटारा';

  @override
  String get noExpensesPeriod => 'इस अवधि के लिए कोई खर्च नहीं';

  @override
  String get noDataTrends => 'रुझान के लिए कोई डेटा नहीं';

  @override
  String get noPayableReceivableData => 'कोई देय/प्राप्य डेटा नहीं';

  @override
  String get noContactData => 'कोई संपर्क डेटा नहीं';

  @override
  String get noPaymentStatusData => 'कोई भुगतान स्थिति डेटा नहीं';

  @override
  String get noIncome => 'इस अवधि के लिए कोई आय नहीं';

  @override
  String get pdfReady => 'पीडीएफ तैयार है';

  @override
  String get analyticsPDFReadyMessage =>
      'आपकी एनालिटिक्स पीडीएफ रिपोर्ट तैयार है। एक कार्रवाई चुनें:';

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
  String get noExpenses => 'इस अवधि के लिए कोई खर्च नहीं';

  @override
  String get expanded => 'विस्तारित';

  @override
  String get collapsed => 'संकुचित';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get allNotificationsMarkedRead =>
      'सभी सूचनाएं पढ़ी गई के रूप में चिह्नित की गईं';

  @override
  String get markAllRead => 'सभी को पढ़ा हुआ चिह्नित करें';

  @override
  String get noNotifications => 'कोई सूचना नहीं';

  @override
  String get noNotificationsDescription =>
      'आप पूरी तरह से अपडेट हैं! हम आपको सूचित करेंगे:\n\n• देय प्राप्य और देय राशियाँ\n• लेनदेन के महत्वपूर्ण पड़ाव\n• बैकअप अनुस्मारक\n• महत्वपूर्ण अपडेट';

  @override
  String get notificationsTip =>
      'सुझाव: समय पर अनुस्मारक प्राप्त करने के लिए प्राप्य और देय राशियों के लिए देय तिथियां निर्धारित करें';

  @override
  String get justNow => 'अभी';

  @override
  String get toggledDebugMode => 'डीबग मोड टॉगल किया गया';

  @override
  String get debugToggleMode => 'डीबग: मोड टॉगल करें';

  @override
  String get premiumTitle => 'फ़्लोपैसा प्रीमियम';

  @override
  String get unlockAllFeatures => 'सभी सुविधाओं को अनलॉक करें';

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
      'किसी भी तिथि सीमा के लिए चार्ट और सारांश के साथ सुंदर पीडीएफ रिपोर्ट तैयार करें।';

  @override
  String get featureUnlimitedTitle => 'असीमित लेनदेन';

  @override
  String get featureUnlimitedDesc =>
      'लेनदेन, संपर्क या श्रेणियों की संख्या पर कोई सीमा नहीं।';

  @override
  String get featureSupportTitle => 'प्राथमिकता सहायता';

  @override
  String get featureSupportDesc =>
      'किसी भी मुद्दे या प्रश्न के लिए तेज़ प्रतिक्रिया और समर्पित सहायता प्राप्त करें।';

  @override
  String get featureEarlyAccessTitle => 'जल्द पहुंच';

  @override
  String get featureEarlyAccessDesc =>
      'सभी के लिए जारी होने से पहले नई सुविधाओं को आज़माने वाले पहले व्यक्ति बनें।';

  @override
  String get featureTemplatesTitle => 'कस्टम संदेश टेम्प्लेट';

  @override
  String get featureTemplatesDesc =>
      'अनुस्मारक, रसीदें और कई भाषाओं में साझा करने के लिए व्हाट्सएप संदेश टेम्प्लेट को कस्टमाइज़ करें।';

  @override
  String get premiumPlan => 'प्रीमियम योजना';

  @override
  String get lifetime => 'आजीवन';

  @override
  String get oneTimePaymentLifetime => 'एकमुश्त भुगतान • आजीवन पहुंच';

  @override
  String get processing => 'प्रसंस्करण...';

  @override
  String get restorePurchases => 'खरीद पुनर्स्थापित करें';

  @override
  String get premiumBenefitsNote =>
      'सभी प्रीमियम सुविधाएं एकमुश्त खरीदारी के साथ हमेशा के लिए आपकी हैं। कोई सदस्यता नहीं!';

  @override
  String get active => 'सक्रिय';

  @override
  String get googleDriveBackup => 'Google ड्राइव बैकअप';

  @override
  String get cloudBackupPremiumDesc =>
      'Google ड्राइव पर क्लाउड बैकअप प्रीमियम उपयोगकर्ताओं के लिए उपलब्ध है।';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get signInGoogleToBackup =>
      'अपना डेटा बैकअप करने के लिए Google के साथ साइन इन करें';

  @override
  String get signInGoogle => 'Google के साथ साइन इन करें';

  @override
  String get googleServicesNote =>
      'नोट: बैकअप के लिए वैध Google सेवा कॉन्फ़िगरेशन की आवश्यकता होती है। यदि साइन-इन विफल रहता है, तो अपना सेटअप जांचें।';

  @override
  String get backupNow => 'अभी बैकअप लें';

  @override
  String get noBackupsFound => 'कोई बैकअप नहीं मिला';

  @override
  String get availableBackups => 'उपलब्ध बैकअप';

  @override
  String get restoreBackupTitle => 'बैकअप पुनर्स्थापित करें?';

  @override
  String get restoreBackupMessage =>
      'यह आपके वर्तमान डेटा को चयनित बैकअप के साथ अधिलेखित कर देगा। \n\n⚠️ बहाली के बाद ऐप को पुनरारंभ करने की आवश्यकता होगी।';

  @override
  String get restore => 'पुनर्स्थापित करें';

  @override
  String get restoreSuccessful => 'पुनर्स्थापना सफल';

  @override
  String get restoreSuccessfulMessage =>
      'डेटा सफलतापूर्वक पुनर्स्थापित किया गया। परिवर्तनों को लागू करने के लिए कृपया ऐप को बंद करें और पुनरारंभ करें।';

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
  String get expenseCategory => 'व्यय श्रेणी';

  @override
  String get incomeCategory => 'आय श्रेणी';

  @override
  String get updateCategory => 'श्रेणी अपडेट करें';

  @override
  String get searchContacts => 'संपर्क खोजें...';

  @override
  String get contacts => 'संपर्क';

  @override
  String get noContactsYet => 'अभी तक कोई संपर्क नहीं';

  @override
  String get noContactsFound => 'कोई संपर्क नहीं मिला';

  @override
  String get addPeopleToTrack => 'खर्चों को ट्रैक करने के लिए लोगों को जोड़ें';

  @override
  String get trySearchingDifferentName =>
      'किसी दूसरे नाम से खोजने का प्रयास करें';

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
  String get importFromContacts => 'संपर्क आयात करें';

  @override
  String get phoneNumberOptional => 'फ़ोन नंबर (वैकल्पिक)';

  @override
  String get emailOptional => 'ईमेल (वैकشلपिक)';

  @override
  String get addressNotesOptional => 'पता / नोट्स (वैकल्पिक)';

  @override
  String get updateContact => 'संपर्क अपडेट करें';

  @override
  String get saveContact => 'संपर्क सहेजें';

  @override
  String get myCashbooks => 'मेरी कैशबुक्स';

  @override
  String get manageCashbooks => 'एकाधिक कैशबुक्स प्रबंधित करें';

  @override
  String get manageContacts => 'अपने संपर्कों को प्रबंधित करें';

  @override
  String get manageCategories => 'व्यय और आय श्रेणियों को प्रबंधित करें';

  @override
  String get manageCurrencies => 'मुद्राएं प्रबंधित करें';

  @override
  String get googleDriveBackupRestore => 'गूगल ड्राइव बैकअप और पुनर्स्थापना';

  @override
  String get messageTemplates => 'संदेश टेम्पलेट';

  @override
  String get customizeMessageTemplates =>
      'व्हाट्सएप संदेश टेम्पलेट्स को अनुकूलित करें';

  @override
  String get exportData => 'डेटा निर्यात करें';

  @override
  String get downloadDataCsvPdf =>
      'अपना डेटा CSV या PDF के रूप में डाउनलोड करें';

  @override
  String get premiumActive => 'प्रीमियम सक्रिय';

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
      'FlowPaisa एक व्यापक व्यक्तिगत वित्त और नकद प्रवाह प्रबंधक है। अपने खर्चों, आय, प्राप्य और देय राशियों को एक ही स्थान पर ट्रैक करें। सुविधाओं में रसीद स्कैनिंग, WhatsApp एकीकरण, क्लाउड बैकअप और सुंदर विश्लेषण शामिल हैं।';

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
  String get quickActions => 'त्वरित कार्रवाई';

  @override
  String get add => 'जोड़ें';

  @override
  String get scan => 'स्कैन करें';

  @override
  String get recentTransactions => 'हाल के लेनदेन';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get noTransactionsYet => 'अभी तक कोई लेनदेन नहीं';

  @override
  String get tapToAddFirst => 'अपना पहला लेनदेन जोड़ने के लिए + पर टैप करें';

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
      'संदेश टेम्पलेट्स को अनुकूलित करना प्रीमियम उपयोगकर्ताओं के लिए उपलब्ध है।';

  @override
  String get upgradeToPremium => 'प्रीमियम में अपग्रेड करें';

  @override
  String get receivableReminders => 'प्राप्य अनुस्मारक';

  @override
  String get pendingReceivable => 'लंबित प्राप्य';

  @override
  String get receivedPayment => 'प्राप्त भुगतान';

  @override
  String get payableReminders => 'देय अनुस्मारक';

  @override
  String get pendingPayable => 'लंबित देय';

  @override
  String get paidPayable => 'भुगतान किया गया देय';

  @override
  String get transactionMessages => 'लेनदेन संदेश';

  @override
  String get transactionReceipt => 'लेनदेन की रसीद';

  @override
  String get transactionSharePaidFor => 'लेनदेन साझा - के लिए भुगतान किया गया';

  @override
  String get transactionSharePaidBy => 'लेनदेन साझा - द्वारा भुगतान किया गया';

  @override
  String get transactionShareWillReceive => 'लेनदेन साझा - प्राप्त होगा';

  @override
  String get transactionShareReceivedFrom => 'लेनदेन साझा - से प्राप्त हुआ';

  @override
  String get transactionShareGeneric => 'लेनदेन साझा - सामान्य';

  @override
  String get shareMessages => 'संदेश साझा करें';

  @override
  String get receivableSharePending => 'प्राप्य साझा - लंबित';

  @override
  String get receivableShareReceived => 'प्राप्य साझा - प्राप्त हुआ';

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
      'क्या आप वाकई इस टेम्पलेट को डिफ़ॉल्ट पर रीसेट करना चाहते हैं? इसे पूर्ववत नहीं किया जा सकता।';

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
  String get availableVariables => 'उपलब्ध वेरिएबल्स';

  @override
  String get variablesInstructions =>
      'आप अपने टेम्पलेट में इन वेरिएबल्स का उपयोग कर सकते हैं:';

  @override
  String variableContactName(Object contactName) {
    return '• $contactName - संपर्क का नाम';
  }

  @override
  String variableAmount(Object amount) {
    return '• $amount - मुद्रा के साथ स्वरूपित राशि';
  }

  @override
  String variableDescription(Object description) {
    return '• $description - लेनदेन/प्राप्य/देय विवरण';
  }

  @override
  String variableDate(Object date) {
    return '• $date - स्वरूपित तिथि';
  }

  @override
  String variableDueDate(Object dueDate) {
    return '• $dueDate - स्वरूपित नियत तिथि';
  }

  @override
  String variableCategoryName(Object categoryName) {
    return '• $categoryName - श्रेणी का नाम';
  }

  @override
  String variableLink(Object link) {
    return '• $link - डीप लिंक URL';
  }

  @override
  String variableType(Object type) {
    return '• $type - लेनदेन का प्रकार (आय/व्यय)';
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
  String get noCurrencies => 'कोई मुद्रा नहीं';

  @override
  String get currencyDeleted => 'मुद्रा सफलतापूर्वक हटाई गई';

  @override
  String get addCurrency => 'मुद्रा जोड़ें';

  @override
  String get currencyNameLabel => 'मुद्रा का नाम';

  @override
  String get currencyNameHint => 'जैसे, यूरो, ब्रिटिश पाउंड';

  @override
  String get pleaseEnterCurrencyName => 'कृपया मुद्रा का नाम दर्ज करें';

  @override
  String get currencySymbolLabel => 'मुद्रा प्रतीक';

  @override
  String get currencySymbolHint => 'जैसे, €, £, ¥';

  @override
  String get currencySymbolHelper =>
      'आप इमोजी, अक्षरों या प्रतीकों का उपयोग कर सकते हैं';

  @override
  String get pleaseEnterCurrencySymbol => 'कृपया मुद्रा प्रतीक दर्ज करें';

  @override
  String get symbolLengthError => 'प्रतीक 10 अक्षर या उससे कम होना चाहिए';

  @override
  String get currencyCodeLabel => 'मुद्रा कोड';

  @override
  String get currencyCodeHint => 'जैसे, EUR, GBP, JPY';

  @override
  String get currencyCodeHelper => 'ISO 4217 कोड (3 अक्षर)';

  @override
  String get pleaseEnterCurrencyCode => 'कृपया मुद्रा कोड दर्ज करें';

  @override
  String get codeLengthError => 'कोड ठीक 3 अक्षर का होना चाहिए';

  @override
  String get decimalPlacesLabel => 'दशमलव स्थान';

  @override
  String get decimalPlacesHelper => 'दशमलव बिंदु के बाद अंकों की संख्या';

  @override
  String get noDecimals => '0 (कोई दशमलव नहीं)';

  @override
  String get oneDecimal => '1 दशमलव स्थान';

  @override
  String get twoDecimals => '2 दशमलव स्थान';

  @override
  String get saveCurrency => 'मुद्रा सहेजें';

  @override
  String get currencyAdded => 'मुद्रा सफलतापूर्वक जोड़ी गई';

  @override
  String get editCurrency => 'मुद्रा संपादित करें';

  @override
  String get updateCurrency => 'मुद्रा अपडेट करें';

  @override
  String get currencyUpdated => 'मुद्रा सफलतापूर्वक अपडेट की गई';

  @override
  String get selectDateRange => 'तिथि सीमा चुनें';

  @override
  String get exportSuccessful => 'निर्यात सफल';

  @override
  String get transactionHistoryReady =>
      'आपका लेनदेन इतिहास साझा करने के लिए तैयार है।';

  @override
  String get done => 'हो गया';

  @override
  String get pdfReportReady =>
      'आपकी पीडीएफ रिपोर्ट तैयार है। एक कार्रवाई चुनें:';

  @override
  String get testPdfReady => 'परीक्षण पीडीएफ तैयार है';

  @override
  String get testPdfCategoriesReady =>
      'सभी श्रेणियों के साथ परीक्षण पीडीएफ तैयार है। एक कार्रवाई चुनें:';

  @override
  String get exportYourData => 'अपना डेटा निर्यात करें';

  @override
  String get downloadHistoryCsvPdf =>
      'अपना लेनदेन इतिहास CSV या PDF के रूप में डाउनलोड करें';

  @override
  String get startDate => 'आरंभ तिथि';

  @override
  String get endDate => 'अंतिम तिथि';

  @override
  String get selectDate => 'तिथि चुनें';

  @override
  String get exportSummary => 'निर्यात सारांश';

  @override
  String get totalTransactions => 'कुल लेनदेन';

  @override
  String get csvInfoNote =>
      'CSV फाइलों को Excel या Google Sheets में खोला जा सकता है। पीडीएफ रिपोर्ट साझा करने के लिए बेहतरीन हैं।';

  @override
  String get testCategoriesPdf => 'श्रेणी परीक्षण पीडीएफ (आइकन)';

  @override
  String get transactionDetails => 'लेनदेन का विवरण';

  @override
  String get autoGenerated => 'स्वचालित रूप से जनरेट किया गया';

  @override
  String get scheduled => 'अनुसूचित';

  @override
  String get sendMessage => 'संदेश भेजें';

  @override
  String get linkedEntry => 'लिंक्ड एंट्री';

  @override
  String paidOn(String date) {
    return 'भुगतान किया गया: $date';
  }

  @override
  String receivedOn(String date) {
    return 'प्राप्त हुआ: $date';
  }

  @override
  String get deleteTransactionTitle => 'लेनदेन हटाएं';

  @override
  String get deleteTransactionMessage =>
      'क्या आप वाकई इस लेनदेन को हटाना चाहते हैं? इसे पूर्ववत नहीं किया जा सकता।';

  @override
  String get transactionDeleted => 'लेनदेन हटा दिया गया';

  @override
  String get errorLoadingCurrency => 'मुद्रा लोड करने में त्रुटि';

  @override
  String get balanceLabel => 'शेष';

  @override
  String get errorLabel => 'त्रुटि';

  @override
  String get importTransaction => 'लेनदेन आयात करें';

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
    return 'मुझे आपको $amount देने हैं\nतारीख: $date\n\nFlowPaisa में देखें:\n$link';
  }

  @override
  String shareReceivableReceived(String amount, String date, String link) {
    return 'नमस्ते!\n\n$date को $amount کا भुगतान प्राप्त हो गया है।\n\nFlowPaisa में सिंक करें:\n$link';
  }

  @override
  String shareReceivablePending(String amount, String date, String link) {
    return 'प्राप्त करने योग्य राशि: $amount\nतारीख: $date\n\nFlowPaisa में देखें:\n$link';
  }

  @override
  String shareTransactionMessage(String amount, String date, String link) {
    return '$date को $amount का लेनदेन रिकॉर्ड किया गया।\n\nFlowPaisa में देखें:\n$link';
  }

  @override
  String get shareViaWhatsApp => 'WhatsApp के माध्यम से साझा करें';

  @override
  String toContact(String name) {
    return '$name को';
  }

  @override
  String get chooseContact => 'संपर्क चुनें';

  @override
  String get copyLink => 'लिंक कॉपी करें';

  @override
  String get copyDeepLinkSubtitle => 'डीप लिंक को क्लिपबोर्ड पर कॉपी करें';

  @override
  String get scanReceipt => 'रसीद स्कैन करें';

  @override
  String get camera => 'कैमरा';

  @override
  String get gallery => 'गैलरी';

  @override
  String get scanningReceipt => 'रसीद स्कैन की जा रही है...';

  @override
  String get noReceiptSelected => 'कोई रसीद नहीं चुनी गई';

  @override
  String get reviewAndEdit => 'समीक्षा करें और संपादित करें';

  @override
  String get merchantName => 'व्यापारी का नाम';

  @override
  String get totalAmount => 'कुल राशि';

  @override
  String get proceedToAddTransaction => 'लेनदेन जोड़ने के लिए आगे बढ़ें';

  @override
  String errorPickingImage(String error) {
    return 'छवि चुनने में त्रुटि: $error';
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
  String get receivedRelationship => 'प्राप्त संबंध';

  @override
  String get iOwe => 'मुझ पर उधार है';

  @override
  String get receivedLoan => 'ऋण प्राप्त हुआ';

  @override
  String get receiveLater => 'बाद में प्राप्त करें';

  @override
  String get schedulePattern => 'शेड्यूल पैटर्न';

  @override
  String get startDateOptional => 'आरंभ तिथि (वैकल्पिक)';

  @override
  String get endDateOptional => 'अंतिम तिथि (वैकल्पिक)';

  @override
  String get scheduleUpdated => 'शेड्यूल सफलतापूर्वक अपडेट किया गया';

  @override
  String get updateSchedule => 'शेड्यूल अपडेट करें';

  @override
  String get updating => 'अपडेट किया जा रहा है...';

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
  String get generate100DummyTransactions => '100 डमी लेनदेन जनरेट करें';

  @override
  String get generated100DummyTransactions => '100 डमी लेनदेन जनरेट किए गए';

  @override
  String get errorLoadingTransactions => 'लेनदेन लोड करने में त्रुटि';

  @override
  String get noSchedulesFound => 'कोई शेड्यूल नहीं मिला';

  @override
  String get noMoreTransactions => 'कोई और लेनदेन नहीं';

  @override
  String get scheduleDeleted => 'शेड्यूल सफलतापूर्वक हटा दिया गया';

  @override
  String get autoBadge => 'ऑटो';

  @override
  String get uncategorized => 'बिना श्रेणी का';

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
  String get limitReachedTitle => 'सीमा पहुँच गई';

  @override
  String get upgrade => 'अपग्रेड करें';

  @override
  String get summary => 'सारांश';

  @override
  String get noTransactionsInRange => 'इस तिथि सीमा में कोई लेनदेन नहीं है।';

  @override
  String get noPayablesInRange => 'इस तिथि सीमा में कोई देय राशि नहीं है।';

  @override
  String get noReceivablesInRange =>
      'इस तिथि सीमा में कोई प्राप्य राशि नहीं है।';

  @override
  String get topCategoriesVisual => 'शीर्ष श्रेणियाँ (विजुअल)';

  @override
  String get incomeVsExpenseTrendVisual => 'आय बनाम व्यय रुझान (विजुअल)';

  @override
  String get payableVsReceivableTrendVisual =>
      'देय बनाम प्राप्य रुझान (विजुअल)';

  @override
  String get incomeShort => 'आय:';

  @override
  String get shareTransaction => 'लेनदेन साझा करें';

  @override
  String get sharePaymentRequest => 'भुगतान अनुरोध साझा करें';

  @override
  String get sharePaymentAcknowledgment => 'भुगतान पावती साझा करें';

  @override
  String get openingWhatsApp => 'WhatsApp खोला जा रहा है...';

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
  String get statusSettled => 'निपटारा';

  @override
  String get statusOverdue => 'अतिदेय';

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
  String get cashbookNameHint => 'जैसे, व्यक्तिगत, व्यवसाय';

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
  String get preferencesDescription => 'मुद्रा और तिथि प्रारूप सेटिंग्स';

  @override
  String get messageTemplatesDescription => 'व्हाट्सएप संदेश टेम्प्लेट';

  @override
  String get copy => 'कॉपी करें';

  @override
  String get pleaseSelectSource => 'कृपया एक स्रोत कैशबुक चुनें';

  @override
  String get pleaseSelectAtLeastOne =>
      'कृपया कॉपी करने के लिए कम से कम एक आइटम चुनें';

  @override
  String get preferencesCopied => 'पसंद सफलतापूर्वक कॉपी की गईं';

  @override
  String errorCopyingPreferences(String error) {
    return 'पसंद कॉपी करने में त्रुटि: $error';
  }

  @override
  String get reset => 'रीसेट करें';

  @override
  String get template => 'टेम्प्लेट';

  @override
  String get variables => 'वेरिएबल्स';

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
      'लेनदेन पहले ही आयात किया जा चुका है';

  @override
  String get pleaseSelectContactLinked =>
      'कृपया लिंक किए गए लेनदेन के लिए एक संपर्क चुनें';

  @override
  String get transactionLinkedAdded =>
      'लेनदेन लिंक किया गया और सफलतापूर्वक जोड़ा गया';

  @override
  String get transactionAdded => 'लेनदेन सफलतापूर्वक जोड़ा गया';

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
      'लेनदेन सफलतापूर्वक हटा दिया गया';

  @override
  String get googleDrive => 'गूगल ड्राइव';

  @override
  String get backupToFile => 'फ़ाइल में बैकअप लें';

  @override
  String get restoreFromFile => 'फ़ाइल से पुनर्स्थापित करें';

  @override
  String get clearData => 'डेटा साफ़ करें';

  @override
  String get addCashbook => 'कैशबुक जोड़ें';

  @override
  String get cashbookCreated => 'कैशबुक सफलतापूर्वक बनाई गई';

  @override
  String get fontSelection => 'फ़ॉन्ट चयन';
}
