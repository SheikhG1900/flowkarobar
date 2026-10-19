// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get refresh => 'ताज़ा करें';

  @override
  String get appTitle => 'फ्लोपैसा';

  @override
  String get backgroundActivityStarted => 'गतिविधि बैकग्राउंड में शुरू हुई';

  @override
  String get backgroundBackupStarted => 'बैकअप बैकग्राउंड में शुरू हुआ';

  @override
  String get backgroundCloudClearStarted =>
      'क्लाउड डेटा हटाना बैकग्राउंड में शुरू हुआ';

  @override
  String get sourceLabel => 'स्रोत';

  @override
  String get targetLabel => 'लक्ष्य';

  @override
  String get limitLabel => 'सीमा';

  @override
  String get leftLabel => 'बचे';

  @override
  String get needed => 'आवश्यक';

  @override
  String get surplus => 'अतिरिक्त';

  @override
  String cloudBackupsFor(String name) {
    return '$name के लिए बैकअप';
  }

  @override
  String get bulkImport => 'बल्क इंपोर्ट';

  @override
  String get open => 'खोलें';

  @override
  String get pasteFromClipboard => 'क्लिपबोर्ड से पेस्ट करें';

  @override
  String get pickCsvFile => 'CSV फ़ाइल चुनें';

  @override
  String get importSettings => 'इंपोर्ट सेटिंग्स';

  @override
  String get separator => 'विभाजक';

  @override
  String get tab => 'टैब';

  @override
  String get comma => 'कोमा';

  @override
  String get semicolon => 'सेमीकोलन';

  @override
  String get pipe => 'पाइप';

  @override
  String get dateFormat => 'तारीख का प्रारूप';

  @override
  String get hasHeader => 'हेडर है';

  @override
  String get columnMapping => 'कॉलम मैपिंग';

  @override
  String get defaultValues => 'डिफ़ॉल्ट मान';

  @override
  String get preview => 'पूर्वावलोकन';

  @override
  String get selected => 'चयनित';

  @override
  String importedSuccessfully(int count) {
    return '$count लेनदेन सफलतापूर्वक इंपोर्ट किए गए';
  }

  @override
  String get paste => 'पेस्ट करें';

  @override
  String get import => 'इंपोर्ट';

  @override
  String get export => 'निर्यात';

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
  String get scheduleDetails => 'शेड्यूल विवरण';

  @override
  String get frequency => 'आवृत्ति';

  @override
  String get relationship => 'संबंध';

  @override
  String get days => 'दिन';

  @override
  String get lastGenerated => 'पिछली बार उत्पन्न';

  @override
  String get editSchedule => 'शेड्यूल संपादित करें';

  @override
  String get deleteSchedule => 'शेड्यूल हटाएं';

  @override
  String get deleteScheduleConfirmation =>
      'क्या आप वाकई इस शेड्यूल को हटाना चाहते हैं? यह इस शेड्यूल के लिए भविष्य के सभी स्वचालित लेनदेन बंद कर देगा।';

  @override
  String get transactionUpdated => 'लेनदेन सफलतापूर्वक अपडेट किया गया';

  @override
  String get markAsReviewed => 'समीक्षित के रूप में चिह्नित करें';

  @override
  String get transactionMarkedAsReviewed =>
      'लेन-देन को समीक्षित के रूप में चिह्नित किया गया है';

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
  String get syncSchedule => 'निष्क्रिय सिंक';

  @override
  String get noIdleSync => 'निष्क्रिय सिंक नहीं';

  @override
  String autoSyncBadge(String interval) {
    return 'ऑटो: ${interval}h';
  }

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
  String get recentSearches => 'हाल की खोजें';

  @override
  String get renameSearch => 'खोज का नाम बदलें';

  @override
  String get enterNewName => 'नया नाम दर्ज करें';

  @override
  String get rename => 'नाम बदलें';

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
  String get receivableIntentTitle => 'आप इसे कैसे रिकॉर्ड करना चाहेंगे?';

  @override
  String receivableIntentBoughtForContact(String contact) {
    return 'आपने $contact के लिए कुछ खरीदा। वे आपको वापस देंगे।';
  }

  @override
  String receivableIntentServicesAmount(String amount, String contact) {
    return '$contact आपको आपकी सेवाओं के लिए $amount देंगे।';
  }

  @override
  String get receivableIntentJustRecord => 'बस एक प्राप्य बनाएँ';

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
  String get editDescription => 'विवरण संपादित करें';

  @override
  String get receivablePending => 'प्राप्य (लंबित)';

  @override
  String get dueDate => 'देय तिथि';

  @override
  String get linkedTransaction => 'लिंक्ड लेन-देन';

  @override
  String get markAsReceived => 'वसूल करें';

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
  String get payableIntentTitle => 'आप इसे कैसे रिकॉर्ड करना चाहेंगे?';

  @override
  String payableIntentContactBoughtForYou(String contact) {
    return '$contact ने आपकी तरफ से कुछ खरीदा।';
  }

  @override
  String payableIntentBorrowedFrom(String amount, String contact) {
    return 'आपने $contact से $amount उधार लिया।';
  }

  @override
  String get payableIntentJustRecord => 'बस एक देय बनाएँ';

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
  String get paid => 'भुगतान किया';

  @override
  String get markAsPaid => 'अदा करें';

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
  String get connectGoogleDrive => 'Google Drive कनेक्ट करें';

  @override
  String get cloudBackupAccount => 'क्लाउड बैकअप खाता';

  @override
  String get autofillFromGoogle => 'Google से ऑटोफिल करें';

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
  String get backupReady => 'बैकअप तैयार है';

  @override
  String get backupReadyMessage =>
      'आपका डेटाबेस बैकअप तैयार है। एक क्रिया चुनें:';

  @override
  String get analyticsPDFReadyMessage =>
      'आपकी एनालिटिक्स पीडीएफ रिपोर्ट तैयार है। एक क्रिया चुनें:';

  @override
  String get saveCopy => 'कॉपी सहेजें';

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
  String get balanceReceivableMinusPayable => 'बैलेंस (प्राप्य − देय)';

  @override
  String get netReceivable => 'शुद्ध प्राप्य';

  @override
  String get netPayable => 'शुद्ध देय';

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
  String get markAllRead => 'सब पढ़ा';

  @override
  String get clearAll => 'सभी साफ़ करें';

  @override
  String get clearAllItemsConfirmation =>
      'क्या आप वाकई सभी आइटम साफ़ करना चाहते हैं?';

  @override
  String get clearAllNotifications => 'सभी सूचनाएं साफ़ करें?';

  @override
  String get clearAllNotificationsMessage =>
      'क्या आप वाकई सभी सूचनाएं हटाना चाहते हैं? यह क्रिया पूर्ववत नहीं की जा सकती।';

  @override
  String get unsyncedChanges => 'असिंक किए गए परिवर्तन';

  @override
  String get reminders => 'रिमाइंडर';

  @override
  String get notificationsCleared => 'सभी सूचनाएं साफ़ कर दी गईं';

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
      'कई भाषाओं में रिमाइंडर, रसीद और साझा करने के लिए व्हाट्सएप संदेश टेम्पलेट्स को कستमाइज़ करें।';

  @override
  String get featureMultiDeviceSyncTitle => 'मल्टी-डिवाइस सिंक';

  @override
  String get featureMultiDeviceSyncDesc =>
      'Google ड्राइव का उपयोग करके अपने सभी डिवाइस पर अपना डेटा सिंक करें। आपके रिकॉर्ड हमेशा अप-टू-डेट रहते हैं।';

  @override
  String get featureMultipleCashbooksTitle => 'असीमित कैशबुक';

  @override
  String get featureMultipleCashbooksDesc =>
      'विभिन्न व्यवसायों या व्यक्तिगत उपयोग के लिए जितनी आवश्यकता हो उतनी अतिरिक्त कैशबुक बनाएं और प्रबंधित करें।';

  @override
  String get featureUnlimitedSchedulesTitle => 'असीमित शेड्यूल';

  @override
  String get featureUnlimitedSchedulesDesc =>
      'अपनी नियमित आय और खर्चों के लिए असीमित आवर्ती लेन-देन शेड्यूल सेट करें।';

  @override
  String get featureUnlimitedVoiceExtractionTitle =>
      'असीमित वॉयस स्मार्ट एक्सट्रैक्शन';

  @override
  String get featureUnlimitedVoiceExtractionDesc =>
      'मासिक सीमा के बिना आवाज़ कमांड के लिए स्मार्ट एक्सट्रैक्शन का उपयोग करें। प्राकृतिक भाषा में बोलकर लेन-देन जोड़ें।';

  @override
  String get featureUnlimitedReceiptExtractionTitle =>
      'असीमित रसीद स्मार्ट एक्सट्रैक्शन';

  @override
  String get featureUnlimitedReceiptExtractionDesc =>
      'मासिक सीमा के बिना रसीद स्कैनिंग के लिए स्मार्ट एक्सट्रैक्शन का उपयोग करें। रसीदों से राशि, व्यापारी और श्रेणी स्वचालित रूप से निकालें।';

  @override
  String get featureBulkImportTitle => 'बल्क इंपोर्ट';

  @override
  String get featureBulkImportDesc =>
      'CSV फ़ाइलों या अपने क्लिपबोर्ड (Google शीट्स) से सैकड़ों लेन-देन तुरंत इंपोर्ट करें।';

  @override
  String get featureBulkSettlementTitle => 'बल्क सेटलमेंट (प्राप्य और देय)';

  @override
  String get featureBulkSettlementDesc =>
      'एक साथ कई प्राप्य या देय राशि सेटल करें। कई एंट्री को एक बार में भुगतान या प्राप्त के रूप में चिह्नित करें।';

  @override
  String get premiumPlan => 'प्रीमियम प्लान';

  @override
  String get lifetime => 'लाइफटाइम';

  @override
  String get monthly => 'मासिक';

  @override
  String get yearly => 'वार्षिक';

  @override
  String get bestValue => 'सर्वश्रेष्ठ मूल्य';

  @override
  String get chooseYourPlan => 'अपना प्लान चुनें';

  @override
  String get cancelAnytime => 'कभी भी रद्द करें';

  @override
  String savePercentage(Object percentage) {
    return '$percentage% बचाएं';
  }

  @override
  String get oneTimePayment => 'एक बार भुगतान करें, हमेशा के लिए अपनाएं';

  @override
  String get recommended => 'अनुशंसित';

  @override
  String get subscribeNow => 'अभी सदस्यता लें';

  @override
  String get oneTimePaymentLifetime => 'एक बार भुगतान • लाइफटाइम एक्सेस';

  @override
  String get processing => 'प्रसंस्करण...';

  @override
  String get restorePurchases => 'खरीद बहाल करें';

  @override
  String get premiumBenefitsNote =>
      'अपने चुने हुए प्लान के साथ सभी प्रीमियम सुविधाओं को अनलॉक करें। स्थायी पहुंच के लिए लाइफटाइम चुनें!';

  @override
  String get active => 'सक्रिय';

  @override
  String get freeTrial => 'नि:शुल्क परीक्षण';

  @override
  String get noPurchasesFound => 'बहाल करने के लिए कोई खरीदारी नहीं मिली।';

  @override
  String daysFreeTrial(int days) {
    return '$days दिनों का नि:शुल्क परीक्षण';
  }

  @override
  String monthFreeTrial(int months) {
    return '$months महीने का नि:शुल्क परीक्षण';
  }

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
  String get rateUs => 'Flowpaisa को रेट करें';

  @override
  String get tagline => 'हर पैसे का हिसाब रखें';

  @override
  String versionInfo(String version, String buildNumber) {
    return 'संस्करण $version (बिल्ड $buildNumber)';
  }

  @override
  String get appDescription =>
      'Flowpaisa एक व्यापक व्यक्तिगत वित्त और कैशफ्लो मैनेजर है। अपने खर्चों, आय, प्राप्य और देय राशि को एक ही स्थान पर ट्रैक करें। सुविधाओं में रसीद स्कैनिंग, व्हाट्सएप एकीकरण, क्लाउड बैकअप और सुंदर एनालिटिक्स शामिल हैं।';

  @override
  String get openSourceLicenses => 'ओपन सोर्स लाइसेंस';

  @override
  String get developedBy => 'द्वारा विकसित';

  @override
  String get developerName => 'TamataSoft';

  @override
  String get userGuide => 'यूज़र गाइड';

  @override
  String get guideGettingStarted => 'शुरुआत करना';

  @override
  String get guideGettingStartedDesc =>
      'लेन-देन जोड़ना और अपनी कैशबुक प्रबंधित करना सीखें।';

  @override
  String get guideManagingMoney => 'पैसे का प्रबंधन';

  @override
  String get guideManagingMoneyDesc =>
      'अपनी आय, खर्च, प्राप्य और देय राशि को ट्रैक करें।';

  @override
  String get guideRelationships => 'संबंध और लिंक्ड लेन-देन';

  @override
  String get guideRelationshipsDesc =>
      'संपर्कों के साथ लेन-देन जोड़ने और ऋण को ट्रैक करने का तरीका समझें।';

  @override
  String get guideSharing => 'शेयरिंग और डीप लिंक्स';

  @override
  String get guideSharingDesc =>
      'डीप लिंक का उपयोग करके लेन-देन साझा करें और उपकरणों के बीच डेटा सिंक करें।';

  @override
  String get guideAdvancedFeatures => 'उन्नत सुविधाएँ';

  @override
  String get guideAdvancedFeaturesDesc =>
      'रसीद स्कैनिंग, बिल विभाजन और क्लाउड बैकअप का उपयोग करें।';

  @override
  String get guideCustomization => 'कस्टमाइजेशन';

  @override
  String get guideCustomizationDesc =>
      'श्रेणियों, मुद्राओं, थीम और भाषाओं को वैयक्तिकृत करें।';

  @override
  String get guideAddTransaction => 'लेन-देन कैसे जोड़ें?';

  @override
  String get guideAddTransactionStep =>
      'डैशबोर्ड या लेन-देन स्क्रीन पर \'+\' बटन पर टैप करें, राशि दर्ज करें, श्रेणी चुनें और सहेजें।';

  @override
  String get guideSwitchCashbook => 'कैशबुक कैसे बदलें?';

  @override
  String get guideSwitchCashbookStep =>
      'कैशबुक मैनेजर खोलने के लिए डैशबोर्ड हेडर पर कैशबुक के नाम पर टैप करें और दूसरा चुनें।';

  @override
  String get guideTrackReceivables => 'प्राप्य को ट्रैक करना';

  @override
  String get guideTrackReceivablesStep =>
      'लोगों द्वारा आपको दिए जाने वाले पैसे को ट्रैक करने के लिए \'प्राप्य\' अनुभाग का उपयोग करें। स्वचालित रूप से आय बनाने के लिए आप उन्हें प्राप्त के रूप में चिह्नित कर सकते हैं।';

  @override
  String get guideTrackPayablesStep =>
      'दूसरों को आपके द्वारा दिए जाने वाले पैसे को ट्रैक करने के लिए \'देय\' अनुभाग का उपयोग करें। स्वचालित रूप से व्यय बनाने के लिए आप उन्हें भुगतान किया गया के रूप में चिह्नित कर सकते हैं।';

  @override
  String get guideLinkedTransactions => 'लिंक्ड लेन-देन क्या हैं?';

  @override
  String get guideLinkedTransactionsStep =>
      'लिंक्ड लेन-देन एक खर्च को प्राप्य से या आय को देय से जोड़ते हैं।\n\nउदाहरण: आपने किसी मित्र के दोपहर के भोजन के लिए \$50 का भुगतान किया। आप \$50 का खर्च रिकॉर्ड करते हैं और उसे उस मित्र के लिए \'Paid FOR\' के रूप में लिंक करते हैं। यह स्वचालित रूप से उस संपर्क के लिए \$50 का प्राप्य (Receivable) बना देता है।';

  @override
  String get guideSplitBill => 'बिल विभाजन (Split Bill) का उपयोग कैसे करें?';

  @override
  String get guideSplitBillStep =>
      'खर्च जोड़ते समय, \'Split Bill\' पर टैप करें। आप कुल राशि को कई संपर्कों के बीच समान रूप से या प्रतिशत के आधार पर विभाजित कर सकते हैं। ऐप प्रत्येक व्यक्ति के हिस्से के लिए अलग-अलग प्राप्य (Receivables) बनाएगा।';

  @override
  String get guideDeepLinks => 'डीप लिंक के माध्यम से साझा करना';

  @override
  String get guideDeepLinksStep =>
      'किसी भी लेन-देन या प्राप्य पर \'Share\' आइकन पर टैप करें। यह एक अनूठा लिंक उत्पन्न करता है। जब प्राप्तकर्ता अपने डिवाइस पर लिंक पर क्लिक करता है, तो Flowpaisa खुल जाएगा और उन्हें उस लेन-देन को अपनी कैशबुक में आयात (Import) करने की अनुमति देगा।';

  @override
  String get guideImportDeepLink => 'साझा किए गए लेन-देन को कैसे आयात करें?';

  @override
  String get guideImportDeepLinkStep =>
      'जब आपको व्हाट्सएप या संदेश के माध्यम से Flowpaisa लिंक प्राप्त होता है, तो बस उस पर टैप करें। ऐप विवरण दिखाते हुए एक पूर्वावलोकन स्क्रीन खोलेगा। इसे अपने रिकॉर्ड में जोड़ने के लिए \'Import\' पर टैप करें। यदि यह एक निपटान (Settlement) है, तो यह आपके मौजूदा लंबित रिकॉर्ड को अपडेट कर देगा।';

  @override
  String get guideSyncDevices => 'कैशबुक को दूसरे डिवाइस पर कैसे साझा करें?';

  @override
  String get guideSyncDevicesStep =>
      '1. अपने पहले डिवाइस पर सेटिंग्स में \'Google Drive Backup\' सक्षम करें।\n2. दूसरे डिवाइस पर, उसी Google खाते से साइन इन करें।\n3. बैकअप सेटिंग्स पर जाएं और अपना कैशबुक डेटा डाउनलोड करने के लिए \'Restore\' पर टैप करें। निरंतर रीयल-टाइम अपडेट के लिए \'Sync Now\' का उपयोग करें।';

  @override
  String get guideCloudBackup => 'क्लाउड बैकअप और सिंक';

  @override
  String get guideCloudBackupStep =>
      'अपने डेटा को सुरक्षित रखने और कई उपकरणों पर सिंक करने के लिए सेटिंग्स में Google ड्राइव बैकअप सक्षम करें।';

  @override
  String get guideScanReceipt => 'रसीद स्कैनिंग';

  @override
  String get guideScanReceiptStep =>
      'अपनी कागजी रसीदों से राशि और व्यापारी को स्वचालित रूप से निकालने के लिए डैशबोर्ड पर \'स्कैन\' क्रिया का उपयोग करें।';

  @override
  String get copyright => '© 2026 TamataSoft. सर्वाधिकार सुरक्षित।';

  @override
  String get receiptScan => 'रसीद स्कैन';

  @override
  String get cloudBackup => 'क्लाउड बैकअप';

  @override
  String get multilingual => 'बहुभाषी';

  @override
  String get privacyHighlight => 'निजी और सुरक्षित';

  @override
  String get privacyHighlightDesc =>
      'आपका वित्तीय डेटा आपके डिवाइस या आपके निजी क्लाउड में रहता है। कोई और इसे एक्सेस नहीं कर सकता।';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get privacyPolicyDesc =>
      'हम आपकी गोपनीयता का सम्मान करते हैं। आपका डेटा आपके डिवाइस पर स्थानीय रूप से संग्रहीत होता है और वैकल्पिक रूप से आपके निजी Google ड्राइव के साथ सिंक किया जा सकता है। हमारे पास आपके वित्तीय रिकॉर्ड तक पहुंच नहीं है।';

  @override
  String get availableCash => 'उपलब्ध नकद';

  @override
  String get quickActions => 'त्वरित कार्य';

  @override
  String get add => 'जोड़ें';

  @override
  String get bulkImportLoadingContent => 'डेटा लोड हो रहा है…';

  @override
  String bulkImportProgress(int percent, int current, int total) {
    return '$percent% ($current / $total)';
  }

  @override
  String bulkImportPreviewLimited(int shown, int total) {
    return 'पूर्वावलोकन में पहली $shown पंक्तियाँ, कुल $total';
  }

  @override
  String bulkImportPreviewShowingFirst(int shown, int total) {
    return 'कुल $total में से पहली $shown पंक्तियों का पूर्वावलोकन';
  }

  @override
  String get bulkImportPreviewShowAll => 'सभी दिखाएँ';

  @override
  String get bulkImportPreviewShowLess => 'कम दिखाएँ';

  @override
  String bulkImportPreviewShowingAllRows(int total) {
    return 'सभी $total पंक्तियाँ दिख रही हैं';
  }

  @override
  String get bulkImportLinkColumn => 'प्राप्य / देय';

  @override
  String get bulkImportDefaultLink => 'डिफ़ॉल्ट प्राप्य / देय';

  @override
  String get bulkImportUpdatingPreview => 'पूर्वावलोकन अपडेट हो रहा है…';

  @override
  String get scanReceipt => 'रसीद स्कैन करें';

  @override
  String get voiceAdd => 'आवाज से जोड़ें';

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
  String get appTour => 'ऐप टूर';

  @override
  String get resetOnboardingSubtitle =>
      'इसे फिर से देखने के लिए ऐप टूर को रीसेट करें';

  @override
  String get resetOnboardingConfirmation =>
      'क्या आप वाकई ऐप टूर को रीसेट करना चाहते हैं? अगली बार शुरू करने पर आपको ऑनबोर्डिंग स्क्रीन फिर से दिखाई देंगी।';

  @override
  String get onboardingResetSuccess => 'ऐप टूर सफलतापूर्वक रीसेट हो गया';

  @override
  String get tourWelcome => 'Cashbook में आपका स्वागत है!';

  @override
  String get tourWelcomeDesc =>
      'आइए शुरुआत करने में आपकी मदद के लिए एक त्वरित टूर लें';

  @override
  String get tourDashboardHeaderTitle => 'कैशबुक चयनकर्ता';

  @override
  String get tourDashboardHeaderDesc =>
      'अपनी कैशबुक के बीच स्विच करने या नया बनाने के लिए यहाँ टैप करें';

  @override
  String get tourBalanceTitle => 'उपलब्ध नकद';

  @override
  String get tourBalanceDesc =>
      'आपकी कुल उपलब्ध नकद बैलेंस यहाँ प्रदर्शित होती है। लेन-देन जोड़ने पर यह स्वचालित रूप से अपडेट होती है';

  @override
  String get tourCashFlowTitle => 'नकदी प्रवाह';

  @override
  String get tourCashFlowDesc =>
      'अपनी आय, खर्च और शुद्ध नकदी प्रवाह देखें। लेन-देन फ़िल्टर करने के लिए किसी भी कार्ड पर टैप करें';

  @override
  String get tourLendingTitle => 'उधार और क्रेडिट';

  @override
  String get tourLendingDesc =>
      'लोगों द्वारा आपको दी जाने वाली राशि (प्राप्य) और आपके द्वारा दी जाने वाली राशि (देय) को ट्रैक करें। विवरण देखने के लिए टैप करें';

  @override
  String get tourQuickActionsTitle => 'त्वरित कार्य';

  @override
  String get tourQuickActionsDesc =>
      'लेन-देन जोड़ने, रसीद स्कैन करने, प्राप्य/देय राशि प्रबंधित करने, एनालिटिक्स देखने और अधिक के लिए त्वरित पहुंच';

  @override
  String get tourRecentTransactionsTitle => 'हाल की लेन-देन';

  @override
  String get tourRecentTransactionsDesc =>
      'अपनी सबसे हाल की लेन-देन यहाँ देखें। पूर्ण विवरण देखने के लिए किसी भी लेन-देन पर टैप करें';

  @override
  String get tourBottomNavTitle => 'नेविगेशन';

  @override
  String get tourBottomNavDesc =>
      'नीचे नेविगेशन का उपयोग करके डैशबोर्ड, लेन-देन, एनालिटिक्स और सेटिंग्स के बीच स्विच करें';

  @override
  String get tourNext => 'अगला';

  @override
  String get tourSkip => 'छोड़ें';

  @override
  String get tourStartTour => 'टूर शुरू करें';

  @override
  String get tourCompleted => 'टूर पूर्ण';

  @override
  String get tourGotIt => 'समझ गया!';

  @override
  String get tourTransactionsSearchTitle => 'लेनदेन खोजें';

  @override
  String get tourTransactionsSearchDesc =>
      'विवरण या राशि के आधार पर किसी भी लेनदेन को जल्दी से खोजें।';

  @override
  String get tourTransactionsFilterTitle => 'उन्नत फ़िल्टर';

  @override
  String get tourTransactionsFilterDesc =>
      'विशिष्ट जानकारी प्राप्त करने के लिए तिथि सीमा, श्रेणी या संपर्क के आधार पर फ़िल्टर करें।';

  @override
  String get tourTransactionsListTitle => 'लेनदेन का इतिहास';

  @override
  String get tourTransactionsListDesc =>
      'आपके लेनदेन तिथि के अनुसार समूहित हैं। किसी भी आइटम को संपादित करने या हटाने के लिए बाएं या दाएं स्वाइप करें।';

  @override
  String get tourTransactionsFabTitle => 'नया जोड़ें';

  @override
  String get tourTransactionsFabDesc =>
      'नया आय या व्यय लेनदेन रिकॉर्ड करने के लिए यहां टैप करें।';

  @override
  String get tourAnalyticsDateRangeTitle => 'तारीख सीमा चयनकर्ता';

  @override
  String get tourAnalyticsDateRangeDesc =>
      'अपने डेटा का विश्लेषण करने के लिए मासिक, त्रैमासिक, वार्षिक या कस्टम तारीख सीमा के बीच स्विच करें।';

  @override
  String get tourAnalyticsExportPdfTitle => 'पीडीएफ रिपोर्ट एक्सपोर्ट करें';

  @override
  String get tourAnalyticsExportPdfDesc =>
      'अपने वित्तीय विश्लेषण की पेशेवर पीडीएफ रिपोर्ट बनाएं और साझा करें।';

  @override
  String get tourAnalyticsFinancialSummaryTitle => 'वित्तीय सारांश';

  @override
  String get tourAnalyticsFinancialSummaryDesc =>
      'चयनित अवधि के लिए अपने कुल देय, प्राप्य, आय और खर्चों का त्वरित अवलोकन प्राप्त करें।';

  @override
  String get tourAnalyticsChartsTitle => 'दृश्य अंतर्दृष्टि';

  @override
  String get tourAnalyticsChartsDesc =>
      'इंटरैक्टिव चार्ट और श्रेणी विवरण के माध्यम से अपनी खर्च करने की आदतों और रुझानों को समझें।';

  @override
  String get tourSettingsProfileTitle => 'उपयोगकर्ता प्रोफ़ाइल';

  @override
  String get tourSettingsProfileDesc =>
      'अपनी व्यक्तिगत जानकारी, प्रोफ़ाइल फ़ोटो और खाते के विवरण प्रबंधित करें।';

  @override
  String get tourSettingsAppPreferencesTitle => 'ऐप प्राथमिकताएं';

  @override
  String get tourSettingsAppPreferencesDesc =>
      'भाषा, फ़ॉन्ट और थीम (डार्क/लाइट मोड) बदलकर ऐप अनुभव को कस्टमाइज़ करें।';

  @override
  String get tourSettingsBackupTitle => 'डेटा सुरक्षा';

  @override
  String get tourSettingsBackupDesc =>
      'गूगल ड्राइव बैकअप और रिस्टोर सेटअप करके अपना डेटा सुरक्षित रखें।';

  @override
  String get tourSettingsPremiumTitle => 'प्रीमियम विशेषताएं';

  @override
  String get tourSettingsPremiumDesc =>
      'फ्लोपैसा प्रीमियम के साथ उन्नत विश्लेषण, कस्टम संदेश टेम्पलेट और बहुत कुछ अनलॉक करें।';

  @override
  String get tourAddTxAmountTitle => 'राशि दर्ज करें';

  @override
  String get tourAddTxAmountDesc =>
      'यहां लेनदेन की राशि टाइप करें। यदि आवश्यक हो तो कैलकुलेटर का उपयोग करें।';

  @override
  String get tourAddTxCategoryTitle => 'श्रेणी चुनें';

  @override
  String get tourAddTxCategoryDesc =>
      'एनालिटिक्स में बेहतर जानकारी प्राप्त करने के लिए अपने लेनदेन को वर्गीकृत करें।';

  @override
  String get tourAddTxContactTitle => 'संपर्क लिंक करें';

  @override
  String get tourAddTxContactDesc =>
      'वैकल्पिक: देय या प्राप्य को ट्रैक करने के लिए इस लेनदेन को किसी संपर्क से लिंक करें।';

  @override
  String get tourAddTxDateTitle => 'लेनदेन की तिथि';

  @override
  String get tourAddTxDateDesc =>
      'आप आज या किसी भी पिछली/भविष्य की तिथि के लिए लेनदेन रिकॉर्ड कर सकते हैं।';

  @override
  String get tourAddTxSaveTitle => 'लेनदेन सहेजें';

  @override
  String get tourAddTxSaveDesc =>
      'अपना लेनदेन सहेजने के लिए यहां टैप करें। आप इसे तुरंत व्हाट्सएप के माध्यम से साझा भी कर सकते हैं।';

  @override
  String get tourBackupAuthTitle => 'गूगल साइन-इन';

  @override
  String get tourBackupAuthDesc =>
      'क्लाउड बैकअप सक्षम करने और उपकरणों के बीच सिंक करने के लिए अपने गूगल खाते से साइन इन करें।';

  @override
  String get tourBackupSyncTitle => 'सिंक्रनाइज़ेशन';

  @override
  String get tourBackupSyncDesc =>
      'अपने डेटा को स्वचालित रूप से सिंक में रखें। आप यहां अपने स्थानीय और क्लाउड संस्करण देख सकते हैं।';

  @override
  String get tourBackupNowTitle => 'मैनुअल बैकअप';

  @override
  String get tourBackupNowDesc =>
      'किसी भी समय गूगल ड्राइव पर अपने डेटा का पूर्ण बैकअप बनाएं।';

  @override
  String get tourReceivablesListTitle => 'प्राप्य सूची';

  @override
  String get tourReceivablesListDesc =>
      'लोगों द्वारा आपको दिए जाने वाले सभी पैसे देखें। प्रबंधित करने के लिए टैप करें।';

  @override
  String get tourPayablesListTitle => 'देय सूची';

  @override
  String get tourPayablesListDesc =>
      'आपके द्वारा दूसरों को दिए जाने वाले सभी पैसे देखें। प्रबंधित करने के लिए टैप करें।';

  @override
  String get tourShowMeHow => 'कोशिश करें';

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
  String get scaleFactorLabel => 'प्रदर्शन इकाई / स्केल फैक्टर';

  @override
  String get scaleFactorHelper =>
      'साफ प्रदर्शन के लिए राशि को इस मूल्य से विभाजित करें';

  @override
  String get scaleWhole => 'संपूर्ण इकाइयाँ (1)';

  @override
  String get scaleThousands => 'हज़ार (1K)';

  @override
  String get scaleLakhs => 'लाख (1L)';

  @override
  String get scaleMillions => 'मिलियन (1M)';

  @override
  String get scaleCrores => 'करोड़ (1Cr)';

  @override
  String get scaleBillions => 'बिलियन (1B)';

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
  String get openFile => 'फ़ाइल खोलें';

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
  String get simpleExtractionResults => 'सरल निष्कर्षण परिणाम';

  @override
  String smartExtractionQuotaLeft(Object remaining, Object total) {
    return 'इस महीने $remaining / $total शेष';
  }

  @override
  String get smartExtractionUnlimited => 'असीमित';

  @override
  String get useSmartExtractionForBetterResults =>
      'बेहतर परिणाम के लिए स्मार्ट निष्कर्षण इस्तेमाल करें।';

  @override
  String get getIt => 'लें';

  @override
  String get amountCalculatorTitle => 'राशि की गणना करें';

  @override
  String get amountCalculatorUndo => 'पूर्ववत करें';

  @override
  String get amountCalculatorMultiply => 'गुणा';

  @override
  String get amountCalculatorDivide => 'भाग';

  @override
  String get amountCalculatorPercent => 'प्रतिशत (%)';

  @override
  String get amountCalculatorButtonTooltip => 'कैलकुलेटर खोलें';

  @override
  String get amountCalculatorOriginal => 'मूल';

  @override
  String get amountCalculatorResult => 'Result';

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
  String get includePayablesReceivables => 'देय और प्राप्य शामिल करें';

  @override
  String get includePayablesReceivablesSubtitle =>
      'रिपोर्ट में बकाया शेष और सूचियाँ शामिल करें';

  @override
  String get exportAsCSV => 'CSV के रूप में एक्सपोर्ट करें';

  @override
  String get exportAsCSVSubtitle => 'निःशुल्क • एक्सेल या गूगल शीट्स में खोलें';

  @override
  String get exportAsPDF => 'PDF के रूप में एक्सपोर्ट करें';

  @override
  String get exportAsPDFSubtitle => 'प्रीमियम • सारांश के साथ सुंदर रिपोर्ट';

  @override
  String get csvInfoNote =>
      'सीएसवी फाइलें एक्सेल या Google शीट्स में खोली जा सकती हैं। पीडीएफ रिपोर्ट साझा करने के लिए सर्वोत्तम हैं।';

  @override
  String get testCategoriesPdf => 'टेस्ट श्रेणियां पीडीएफ (आइकन)';

  @override
  String get duplicate => 'डुप्लिकेट';

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
  String get periodNet => 'अवधि का शुद्ध';

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
  String get importClassificationReceivableQuestion =>
      'आप इस प्राप्य को कैसे दर्ज करना चाहेंगे?';

  @override
  String importClassificationReceivableOptionPaidFor(String contact) {
    return 'मैंने यह खर्च उठाया — $contact मुझे चुकाएगा।';
  }

  @override
  String get importClassificationReceivableOptionWillReceive =>
      'यह मेरी सेवाओं, उपहार या अन्य आय के लिए है।';

  @override
  String get importClassificationPayableQuestion =>
      'आप इस देय को कैसे दर्ज करना चाहेंगे?';

  @override
  String importClassificationPayableOptionPaidBy(String contact) {
    return '$contact ने मेरी ओर से यह खर्च उठाया।';
  }

  @override
  String get importClassificationPayableOptionReceivedFrom =>
      'मैंने इसे ऋण, अग्रिम या उधार के रूप में प्राप्त किया।';

  @override
  String get type => 'प्रकार';

  @override
  String get remaining => 'शेष';

  @override
  String get daily => 'दैनिक';

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
    return 'नमस्ते!\n\n$date को $amount का भुगतान पूरा हो गया है।\n\nFlowpaisa में सिंक करें:\n$link';
  }

  @override
  String sharePayablePending(String amount, String date, String link) {
    return 'मैंने आपके $amount देने हैं\nतारीख: $date\n\nFlowpaisa में देखें:\n$link';
  }

  @override
  String shareReceivableReceived(String amount, String date, String link) {
    return 'नमस्ते!\n\n$date को $amount का भुगतान प्राप्त हो गया है।\n\nFlowpaisa में सिंक करें:\n$link';
  }

  @override
  String shareReceivablePending(String amount, String date, String link) {
    return 'प्राप्त होने वाली राशि: $amount\nतारीख: $date\n\nFlowpaisa में देखें:\n$link';
  }

  @override
  String shareTransactionMessage(String amount, String date, String link) {
    return '$date को $amount का लेन-देन रिकॉर्ड किया गया।\n\nFlowpaisa में देखें:\n$link';
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
  String get tapToSpeak => 'बोलने के लिए टैप करें';

  @override
  String get listening => 'सुन रहा हूँ...';

  @override
  String get whatWeHeard => 'हमने क्या सुना:';

  @override
  String get reParse => 'फिर से पार्स करें';

  @override
  String get smartExtraction => 'स्मार्ट निष्कर्षण';

  @override
  String get basicExtraction => 'बुनियादी निष्कर्षण';

  @override
  String get addNow => 'अभी जोड़ें';

  @override
  String get editAndAdd => 'संपादित करें और जोड़یں';

  @override
  String get downloadNow => 'अभी डाउनलोड करें';

  @override
  String get smartAiDownloadMessage =>
      'स्मार्ट सुविधाओं के लिए एक बार डाउनलोड (~100MB) की आवश्यकता होती है। क्या आप बेहतर सटीकता के लिए अभी डाउनलोड करना चाहेंगे?';

  @override
  String get smartParsingLimitReached =>
      'मासिक स्मार्ट पार्सिंग सीमा समाप्त हो गई है। बुनियादी निष्कर्षण का उपयोग कर रहे हैं।';

  @override
  String get voiceTips =>
      'कहने की कोशिश करें: \'रात के खाने पर 500 खर्च किए\' या \'मैंने उस्मान को दोपहर के भोजन के लिए 100 दिए\'';

  @override
  String get proceed => 'आगे बढ़ें';

  @override
  String get hints => 'संकेत';

  @override
  String get voiceGuideTitle => 'वॉयस फ़्रैज़िंग गाइड';

  @override
  String get voiceInstructionBasic =>
      'आप सरल एक्सट्रैक्शन मोड का उपयोग कर रहे हैं। संकेत संदेश देखने के लिए यहां टैप करें।';

  @override
  String get voiceInstructionSmart =>
      'आप स्मार्ट एक्सट्रैक्शन का उपयोग कर रहे हैं। अधिक टिप्स के लिए यहां टैप करें।';

  @override
  String get windowsDictationTip =>
      'सुझाव: विंडोज़ पर, आप नीचे दिए गए टेक्स्ट बॉक्स पर क्लिक कर सकते हैं और विंडोज़ के अत्यधिक सटीक अंतर्निहित डिक्टेशन टूल का उपयोग करने के लिए Win + H दबा सकते हैं!';

  @override
  String get includeTextAsDescription =>
      'टेक्स्ट को विवरण के रूप में शामिल करें';

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
  String get allContactsAddedToSplit => 'सभी संपर्क पहले से विभाजन में हैं';

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
  String get remainingNetBalance => 'शेष शुद्ध बैलेंस';

  @override
  String get settleAll => 'पूरा सेटल करें';

  @override
  String get bulkReceiveInBulk => 'बल्क में प्राप्त करें';

  @override
  String get bulkPayInBulk => 'बल्क में भुगतान करें';

  @override
  String get bulkProcessInBulk => 'बल्क में प्रोसेस करें';

  @override
  String get cannotRestoreActiveCashbook =>
      'आप सक्रिय कैशबुक में डेटा बहाल नहीं कर सकते। फ़ाइल लॉक हटाने के लिए कृपया पहले दूसरी कैशबुक पर स्विच करें।';

  @override
  String get uncategorized => 'बिना श्रेणी';

  @override
  String get categoriesSummaryIncludeInTotal => 'कुल में शामिल करें';

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
  String get deleteContactConfirmation =>
      'क्या आप वाकई इस संपर्क को हटाना चाहते हैं? इससे संबंधित सभी लेनदेन इतिहास हट जाएगा।';

  @override
  String get information => 'जानकारी';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get limitReachedTitle => 'सीमा तक पहुँच गए';

  @override
  String get upgrade => 'अपग्रेड करें';

  @override
  String get summary => 'सारांश';

  @override
  String get splittedTransactions => 'विभाजित लेनदेन';

  @override
  String get balance => 'शेष';

  @override
  String get received => 'प्राप्त किया गया';

  @override
  String get noTransactionsFound => 'कोई लेनदेन नहीं मिला';

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
  String get addToDashboard => 'डैशबोर्ड में जोड़ें';

  @override
  String get addedToDashboard => 'डैशबोर्ड में जोड़ दिया गया';

  @override
  String get removeFromDashboard => 'डैशबोर्ड से हटाएं';

  @override
  String get pinToDashboard => 'डैशबोर्ड पर पिन करें';

  @override
  String get unpinFromDashboard => 'डैशबोर्ड से अनपिन करें';

  @override
  String get pinnedToDashboard => 'डैशबोर्ड पर पिन किया गया';

  @override
  String get unpinnedFromDashboard => 'डैशबोर्ड से अनपिन किया गया';

  @override
  String get reorderWidgetsOn => 'विजेट क्रम बदलें';

  @override
  String get reorderWidgetsOff => 'क्रम बदलना समाप्त';

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
  String get filterTransactionProcessed => 'संसाधित';

  @override
  String get filterTransactionNotProcessed => 'असंसाधित';

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
  String get copyDateFormatAndFonts => 'तारीख प्रारूप और फ़ॉन्ट';

  @override
  String get copyDateFormatAndFontsSubtitle =>
      'ऐप भाषा, प्रति भाषा फ़ॉन्ट, तारीख प्रारूप और राशियों के लिए चयनित मुद्रा';

  @override
  String get copyCurrenciesOption => 'मुद्राएँ';

  @override
  String get copyCurrenciesOptionSubtitle =>
      'स्रोत कैशबुक की मुद्रा परिभाषाएँ (नाम, प्रतीक, कोड)';

  @override
  String get messageTemplatesDescription => 'व्हाट्सएप संदेश टेम्पलेट्स';

  @override
  String get copyContacts => 'संपर्क';

  @override
  String get copyContactsDescription => 'संपर्क नाम, फ़ोन नंबर और ईमेल';

  @override
  String get copyCategories => 'श्रेणियाँ';

  @override
  String get copyCategoriesDescription =>
      'आय और व्यय श्रेणियाँ आइकन और रंगों के साथ';

  @override
  String get copyDashboardWidgets => 'डैशबोर्ड विजेट';

  @override
  String get copyDashboardWidgetsDescription =>
      'विजेट लेआउट, गोपनीयता और वित्तीय सारांश टॉगल, नीचे त्वरित क्रिया और डैशबोर्ड दृश्यता';

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
  String get takeBackup => 'बैकअप लें';

  @override
  String get restoreOptionsTitle => 'रिस्टोर विकल्प';

  @override
  String get restoreFromCloud => 'क्लाउड से रिस्टोर करें';

  @override
  String get restoreFromCloudSubtitle => 'गूगल ड्राइव से रिस्टोर करें';

  @override
  String get restoreFromFileSubtitle => 'स्थानीय फ़ाइल से रिस्टोर करें';

  @override
  String get backgroundRestoreStarted => 'रिस्टोर बैकग्राउंड में शुरू हुआ';

  @override
  String restoreSuccessfulFor(String name) {
    return '$name के लिए रिस्टोर सफल रहा';
  }

  @override
  String get selectCloudFolder => 'क्लाउड फ़ोल्डर चुनें';

  @override
  String get selectCloudFolderSubtitle =>
      'बैकअप देखने के लिए कैशबुक फ़ोल्डर चुनें';

  @override
  String get noCloudFoldersFound => 'कोई क्लाउड फ़ोल्डर नहीं मिला';

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
  String get backupOptions => 'बैकअप विकल्प';

  @override
  String get backupToCloud => 'क्लाउड पर बैकअप लें';

  @override
  String get backupToCloudSubtitle =>
      'Google ड्राइव पर अपना डेटाबेस सुरक्षित रूप से सहेजें';

  @override
  String get backupToFile => 'फ़ाइल में बैकअप लें';

  @override
  String get backupToFileSubtitle =>
      'अपने डिवाइस पर डेटाबेस फ़ाइल सहेजें या साझा करें';

  @override
  String get backupOptionsTitle => 'बैकअप विधि चुनें';

  @override
  String get restoreFromFile => 'फ़ाइल से बहाल करें';

  @override
  String get clearData => 'डेटा साफ़ करें';

  @override
  String get orphan => 'अलिंक (Orphan)';

  @override
  String get orphanSubtitle => 'अलिंक या गायब लेन-देन';

  @override
  String get clearOrphans => 'अलिंक की गई फ़ाइलें साफ़ करें';

  @override
  String get clearOrphansConfirm =>
      'यह स्थायी रूप से उन सभी भौतिक फ़ाइलों को हटा देगा जो किसी भी सक्रिय लेन-देन से लिंक नहीं हैं। इस क्रिया को पूर्ववत नहीं किया जा सकता है।';

  @override
  String get orphansCleared => 'अलिंक की गई फ़ाइलें सफलतापूर्वक साफ़ की गईं';

  @override
  String get linkOrphan => 'मौजूदा अटैचमेंट लिंक करें';

  @override
  String get linkOrphanSubtitle => 'अलिंक या अनाथ दस्तावेजों में से चुनें';

  @override
  String get selectOrphans => 'अनाथ दस्तावेज़ चुनें';

  @override
  String get linkSelected => 'चयनित लिंक करें';

  @override
  String get renameFile => 'फ़ाइल का नाम बदलें';

  @override
  String get fileName => 'फ़ाइल का नाम';

  @override
  String get enterFileName => 'कृपया फ़ाइल का नाम दर्ज करें';

  @override
  String get addCashbook => 'कैशबुक जोड़ें';

  @override
  String get cashbookCreated => 'कैशबुक सफलतापूर्वक बनाई गई';

  @override
  String get fontSelection => 'फ़ॉन्ट चयन';

  @override
  String fontChanged(String fontName) {
    return 'फ़ॉन्ट को बदलकर $fontName कर दिया गया है';
  }

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
      'यह Google Drive से आपके सभी Flowpaisa बैकअप और सिंक्रनाइज़ेशन डेटा को स्थायी रूप से हटा देगा। इस क्रिया को पूर्ववत नहीं किया जा सकता है।\n\nक्या आप वाकई सभी क्लाउड डेटा साफ़ करना चाहते हैं?';

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

  @override
  String get splitBill => 'बिल विभाजित करें';

  @override
  String get includeMe => 'मुझे शामिल करें';

  @override
  String get splittedBill => 'विभाजित बिल';

  @override
  String get me => 'मैं';

  @override
  String get distributeEqually => 'समान रूप से वितरित करें';

  @override
  String get totalPercentage => 'कुल प्रतिशत';

  @override
  String get lockShare => 'हिस्सा लॉक करें';

  @override
  String get unlockShare => 'हिस्सा अनलॉक करें';

  @override
  String get customAmount => 'कस्टम राशि';

  @override
  String get percentage => 'प्रतिशत';

  @override
  String get remainingAmount => 'शेष राशि';

  @override
  String get totalMustBe100 => 'कुल 100% होना चाहिए';

  @override
  String get totalMustMatch => 'कुल लेनदेन राशि से मेल खाना चाहिए';

  @override
  String get sameDay => 'उसी दिन';

  @override
  String inDays(int days) {
    return '$days दिनों में';
  }

  @override
  String daysAgoRelative(int days) {
    return '$days दिन पहले';
  }

  @override
  String get pickActualDate => 'वास्तविक तारीख चुनें';

  @override
  String relativeDateAfterXDays(String days) {
    return 'सापेक्ष तारीख ($days दिनों के बाद)';
  }

  @override
  String get enterDaysFromTransaction =>
      'लेन-देन की तारीख से दिनों की संख्या दर्ज करें:';

  @override
  String get enterDaysFromStart =>
      'शुरू होने की तारीख से दिनों की संख्या दर्ज करें:';

  @override
  String get daysHint => 'जैसे: 15';

  @override
  String get daysSuffix => 'दिन';

  @override
  String get status => 'स्थिति';

  @override
  String get payableVsReceivableTrend => 'देय बनाम प्राप्य रुझान';

  @override
  String get categoryDetails => 'श्रेणी का विवरण';

  @override
  String get netIncome => 'शुद्ध आय';

  @override
  String get netExpenses => 'शुद्ध खर्च';

  @override
  String get categoriesAggregateTitle => 'सभी श्रेणियाँ';

  @override
  String get syncStatusTitle => 'सिंक स्थिति';

  @override
  String changesToPush(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count परिवर्तन पुश करने के लिए',
      one: '1 परिवर्तन पुश करने के लिए',
    );
    return '$_temp0';
  }

  @override
  String get updatesAvailable => 'क्लाउड पर अपडेट उपलब्ध हैं';

  @override
  String get oneUpdateAvailable => 'क्लाउड पर 1 अपडेट उपलब्ध है';

  @override
  String multipleUpdatesAvailable(int count) {
    return 'क्लाउड पर $count अपडेट उपलब्ध हैं';
  }

  @override
  String get dataSynced => 'डेटा सिंक हो गया है';

  @override
  String get syncAlreadyInProgress => 'सिंक पहले से चल रहा है';

  @override
  String get syncDelayedRetryShortly =>
      'सिंक विलंबित – जल्द ही पुनः प्रयास करेगा';

  @override
  String get premiumRequiredForSync => 'क्लाउड सिंक के लिए प्रीमियम आवश्यक है';

  @override
  String get signInRequiredForSync =>
      'सिंक करने के लिए Google के साथ साइन इन करें';

  @override
  String get clearCloud => 'क्लाउड साफ़ करें';

  @override
  String get clearCloudTitle => 'क्लाउड डेटा साफ़ करें';

  @override
  String clearCloudMessage(Object name) {
    return '\"$name\" के लिए कौन सा क्लाउड डेटा आप साफ़ करना चाहते हैं चुनें।';
  }

  @override
  String get clearBackups => 'सभी बैकअप साफ़ करें';

  @override
  String get clearBackupsSubtitle =>
      'Google ड्राइव से पूर्ण डेटाबेस स्नैपशॉट हटाता है';

  @override
  String get clearDocuments => 'दस्तावेज़ बैकअप साफ़ करें';

  @override
  String get clearDocumentsSubtitle =>
      'Google ड्राइव से सभी दस्तावेज़ ज़िप बैकअप हटाता है';

  @override
  String get clearSyncHistory => 'सिंक इतिहास साफ़ करें';

  @override
  String get clearSyncHistorySubtitle =>
      'सिंक मेनिफेस्ट को रीसेट करता है और डेल्टा फ़ाइलें हटाता है';

  @override
  String get clearSelectedCloudData => 'चयनित डेटा साफ़ करें';

  @override
  String get cloudDataCleared => 'चयनित क्लाउड डेटा सफलतापूर्वक साफ़ किया गया';

  @override
  String get deleteLocalOnlyNote =>
      'नोट: आपके क्लाउड बैकअप और सिंक डेटा Google ड्राइव पर सुरक्षित रहेंगे।';

  @override
  String get alsoClearCloud => 'क्लाउड बैकअप भी साफ़ करें';

  @override
  String get clearCloudSubtitle =>
      'केवल इसी कैशबुक के लिए Google ड्राइव से इतिहास साफ़ करता है';

  @override
  String get addCloudCashbook => 'क्लाउड कैशबुक जोड़ें';

  @override
  String get addFromCloud => 'क्लाउड से जोड़ें';

  @override
  String get bulkProcessConfirmation =>
      'क्या आप वाकई इस संपर्क के लिए सभी बकाया आइटम प्रोसेस करना चाहते हैं?';

  @override
  String get accountChangedTitle => 'Google Drive खाता बदल गया';

  @override
  String accountChangedMessage(String oldEmail, String newEmail) {
    return 'आपने पहले $oldEmail के साथ सिंक किया था, लेकिन अब $newEmail में लॉग इन हैं।\n\nडेटा टकराव को रोकने के लिए, आपका डेटा इस नए ड्राइव के साथ तब तक सही ढंग से सिंक नहीं होगा जब तक आप मौजूदा क्लाउड डेटा साफ़ नहीं करते।\n\nकृपया Cashbooks स्क्रीन पर जाएं, अपने cashbook पर मेनू (⋮) टैप करें, और \'क्लाउड साफ़ करें\' चुनें।';
  }

  @override
  String get understood => 'समझ गया';

  @override
  String get premiumExpiredSyncPaused =>
      'आपकी प्रीमियम सदस्यता समाप्त हो गई है। क्लाउड सिंक रोक दिया गया है और आपको Google Drive से लॉग आउट कर दिया गया है।';

  @override
  String get loggedOutSyncPaused =>
      'लॉग आउट हो गया। बैकग्राउंड सिंक रोक दिया गया है।';

  @override
  String get signOutSyncConfirmMessage =>
      'साइन आउट करने पर बैकग्राउंड सिंक रुक जाएगा। जारी रखें?';

  @override
  String get scenarioHelpTitle => 'किस प्रकार का लेन-देन?';

  @override
  String get autoSuggest => 'स्वतः सुझाव';

  @override
  String get scenarioPaidForMeal => 'दोस्त के लंच/भोजन का भुगतान किया';

  @override
  String get scenarioBoughtForSomeone =>
      'किसी के लिए कुछ खरीदा (वे वापस देंगे)';

  @override
  String get scenarioLentMoney => 'साथी/परिवार को पैसे उधार दिए';

  @override
  String get scenarioPaidBillForSomeone => 'किसी की ओर से बिल का भुगतान किया';

  @override
  String get scenarioSplitYouPaid => 'बंटवारा – आपने पूरा दिया, बाकी लौटाएंगे';

  @override
  String get scenarioFriendPaidMeal => 'दोस्त ने आपके लंच का भुगतान किया';

  @override
  String get scenarioSomeonePaidBill => 'किसी और ने बिल दिया (आप लौटाएंगे)';

  @override
  String get scenarioColleaguePaidForYou =>
      'साथी/परिवार ने आपके लिए दिया (आप लौटाएंगे)';

  @override
  String get scenarioSplitTheyPaid => 'बंटवारा – दूसरों ने आपका हिस्सा दिया';

  @override
  String get scenarioPaySomeoneForServices =>
      'किसी को सेवाओं के लिए भुगतान करना है';

  @override
  String get scenarioBorrowedCash => 'किसी से नकद उधार लिया';

  @override
  String get scenarioLoanReceived => 'ऋण प्राप्त (वापस देना है)';

  @override
  String get scenarioBorrowedFromContact => 'दोस्त/परिवार से पैसे उधार लिए';

  @override
  String get scenarioSalaryAdvance => 'नियोक्ता से अग्रिम मिला (काटा जाएगा)';

  @override
  String get scenarioReceivedToRepay => 'पैसे मिले जो वापस देंगे';

  @override
  String get scenarioSalaryPending => 'वेतन प्राप्त होना बाकी';

  @override
  String get scenarioClientPaymentPending => 'ग्राहक से भुगतान (लंबित)';

  @override
  String get scenarioPaymentPending => 'दोस्त/परिवार वापस देंगे';

  @override
  String get scenarioRentPending => 'किराया प्राप्त होना बाकी';

  @override
  String get scenarioSalePending => 'कुछ बेचा – भुगतान लंबित';

  @override
  String get scenarioInvoicePending => 'इनवॉइस अभी भुगतान नहीं हुआ';

  @override
  String get scenarioPersonalExpense => 'निजी खर्च / खरीदारी';

  @override
  String get scenarioBillPaid => 'बिल / उपयोगिता भुगतान';

  @override
  String get scenarioSubscription => 'सदस्यता / मेम्बरशिप';

  @override
  String get scenarioSalaryReceived => 'वेतन प्राप्त';

  @override
  String get scenarioFreelanceIncome => 'फ्रीलांस / अतिरिक्त आय';

  @override
  String get scenarioGiftReceived => 'उपहार / बोनस प्राप्त';

  @override
  String get scenarioRefundReceived => 'रिफंड प्राप्त';

  @override
  String get accounts => 'खाते';

  @override
  String get account => 'खाता';

  @override
  String get addAccount => 'खाता जोड़ें';

  @override
  String get editAccount => 'खाता संपादित करें';

  @override
  String get accountName => 'खाते का नाम';

  @override
  String get accountType => 'खाते का प्रकार';

  @override
  String get cash => 'नकद';

  @override
  String get bank => 'बैंक';

  @override
  String get savings => 'बचत';

  @override
  String get creditCard => 'क्रेडिट कार्ड';

  @override
  String get openingBalance => 'प्रारंभिक शेष';

  @override
  String get openingBalanceDues => 'प्रारंभिक शेष (बकाया)';

  @override
  String get openingDate => 'प्रारंभ तिथि';

  @override
  String get creditLimit => 'क्रेडिट सीमा';

  @override
  String get billingCycleDay => 'बिलिंग चक्र दिन';

  @override
  String get paymentDueDays => 'भुगतान देय (चक्र के बाद दिन)';

  @override
  String get linkedPaymentAccount => 'लिंक्ड भुगतान खाता';

  @override
  String get linkedPaymentAccountHint => 'ऑटो-भुगतान अनुस्मारक के लिए खाता';

  @override
  String get accountCreated => 'खाता सफलतापूर्वक बनाया गया';

  @override
  String get accountUpdated => 'खाता सफलतापूर्वक अपडेट किया गया';

  @override
  String get accountDeleted => 'खाता सफलतापूर्वक हटाया गया';

  @override
  String get deleteAccountConfirmation =>
      'क्या आप इस खाते को हटाना चाहते हैं? इससे जुड़े लेनदेन नहीं हटेंगे।';

  @override
  String get noAccounts => 'कोई खाता नहीं';

  @override
  String get noAccountsDescription =>
      'बैलेंस ट्रैक करने के लिए अपने नकद, बैंक या कार्ड खाते जोड़ें';

  @override
  String get creditCardNotAllowedForReceive =>
      'क्रेडिट कार्ड यहाँ उपयोग नहीं हो सकता। नकद, बैंक या बचत खाता जोड़ें या चुनें।';

  @override
  String get outstanding => 'बकाया';

  @override
  String get availableCredit => 'उपलब्ध क्रेडिट';

  @override
  String get creditBalance => 'क्रेडिट बैलेंस';

  @override
  String get billed => 'बिल किया गया';

  @override
  String get unbilled => 'अनबिल्ड';

  @override
  String get transferMoney => 'पैसे ट्रांसफर करें';

  @override
  String get fromAccount => 'खाते से';

  @override
  String get toAccount => 'खाते में';

  @override
  String get transferCreated => 'ट्रांसफर सफलतापूर्वक दर्ज किया गया';

  @override
  String get selectAccount => 'खाता चुनें';

  @override
  String get noAccount => 'कोई खाता नहीं';

  @override
  String get pendingTransactions => 'लंबित लेनदेन';

  @override
  String get payFrom => 'किससे भुगतान करें';

  @override
  String get receiveInto => 'यहाँ प्राप्त करें';

  @override
  String get settlementAccount => 'सेटलेमेंट अकाउंट';

  @override
  String get setAccount => 'खाता सेट करें';

  @override
  String get combineBalances => 'बैलेंस कंबाइन करें';

  @override
  String get selectedTotal => 'चयनित कुल';

  @override
  String get selectAccountsToCombine =>
      'संयुक्त बैलेंस देखने के लिए खाते चुनें';

  @override
  String get accountPickerInfoMessage =>
      'केवल उन लेनदेन पर लागू होता है जिनका खाता निर्दिष्ट नहीं है';

  @override
  String get settlementContinueWithoutAccount => 'मूल लेन-देन खाता रखें';

  @override
  String get negativeBalanceWarning =>
      'इससे आपका नकद शेष शून्य से नीचे चला जाएगा';

  @override
  String paymentDueNotification(String amount, int days) {
    return 'क्रेडिट कार्ड भुगतान $amount $days दिनों में देय है';
  }

  @override
  String paymentDueTodayNotification(String amount) {
    return 'क्रेडिट कार्ड भुगतान $amount आज देय है';
  }

  @override
  String paymentOverdueNotification(String amount, int days) {
    return 'क्रेडिट कार्ड भुगतान $amount $days दिन से अधिक है';
  }

  @override
  String get recordPayment => 'भुगतान दर्ज करें';

  @override
  String get accountBalance => 'खाता शेष';

  @override
  String get noAccountSelected => 'कोई खाता नहीं चुना';

  @override
  String get selectPaymentAccount => 'भुगतान खाता चुनें';

  @override
  String get dayOfMonth => 'महीने का दिन';

  @override
  String get howMuchDoYouOwe => 'इस कार्ड पर आप अभी कितना बकाया हैं?';

  @override
  String get transferBetweenAccounts => 'खातों के बीच ट्रांसफर';

  @override
  String get sameAccountError => 'स्रोत और गंतव्य खाते एक नहीं हो सकते';

  @override
  String get transfers => 'स्थानांतरण';

  @override
  String get recentTransfers => 'हाल के ट्रांसफर';

  @override
  String get noTransfers => 'अभी तक कोई ट्रांसफर नहीं';

  @override
  String transferFromTo(String from, String to) {
    return '$from → $to';
  }

  @override
  String get accountNotFound => 'खाता नहीं मिला';

  @override
  String get deleteAccount => 'खाता हटाएं';

  @override
  String get deleteAccountConfirm =>
      'क्या आप वाकई इस खाते को हटाना चाहते हैं? इससे जुड़े लेनदेन नहीं हटेंगे।';

  @override
  String get outstandingBalance => 'बकाया शेष';

  @override
  String get currentBalance => 'वर्तमान शेष';

  @override
  String get amountDue => 'देय राशि';

  @override
  String get unbilledAmount => 'अनबिल्ड राशि';

  @override
  String get creditUsed => 'उपयोग किया क्रेडिट';

  @override
  String get creditCards => 'क्रेडिट कार्ड';

  @override
  String get netWorth => 'कुल संपत्ति';

  @override
  String get totalAssets => 'कुल परिसंपत्तियां';

  @override
  String get totalLiabilities => 'कुल देनदारियां';

  @override
  String get available => 'उपलब्ध';

  @override
  String get due => 'देय';

  @override
  String get pleaseEnterAccountName => 'कृपया खाते का नाम दर्ज करें';

  @override
  String get appearance => 'दिखावट';

  @override
  String get saveChanges => 'बदलाव सहेजें';

  @override
  String get icon => 'आइकन';

  @override
  String get creditCardDetails => 'क्रेडिट कार्ड विवरण';

  @override
  String get pleaseSelectBothAccounts =>
      'कृपया स्रोत और गंतव्य दोनों खाते चुनें';

  @override
  String get recordTransfer => 'ट्रांसफर दर्ज करें';

  @override
  String get descriptionOptional => 'विवरण (वैकल्पिक)';

  @override
  String dayLabel(int day) {
    return 'दिन $day';
  }

  @override
  String get openTransactionsForAccount =>
      'इस खाते के लेनदेन देखने के लिए टैप करें';

  @override
  String get payBill => 'बिल भुगतान करें';

  @override
  String get customPayment => 'कस्टम भुगतान';

  @override
  String get customPaymentHint => 'कस्टम राशि दर्ज करें';

  @override
  String payingAmount(String amount) {
    return '$amount का भुगतान';
  }

  @override
  String get noBankAccountsToPayFrom =>
      'भुगतान के लिए कोई बैंक या बचत खाता उपलब्ध नहीं है';

  @override
  String get accountsOverview => 'खाते अवलोकन';

  @override
  String get balanceDistribution => 'शेष वितरण';

  @override
  String get accountFlowSummary => 'खाता नकद प्रवाह';

  @override
  String get creditUtilisation => 'क्रेडिट उपयोग';

  @override
  String get openingBalanceLabel => 'प्रारंभिक';

  @override
  String get closingBalanceLabel => 'अंतिम';

  @override
  String transferFromAnalytics(String account) {
    return '$account से';
  }

  @override
  String transferToAnalytics(String account) {
    return '$account को';
  }

  @override
  String get unknownAccount => 'अन्य खाता';

  @override
  String get noAccountActivity => 'इस अवधि में कोई खाता गतिविधि नहीं';

  @override
  String get noTransferActivity => 'इस अवधि में कोई स्थानांतरण नहीं';

  @override
  String creditUsedOf(String used, String limit) {
    return '$limit में से $used उपयोग';
  }

  @override
  String get inflow => 'आवक';

  @override
  String get outflow => 'जावक';

  @override
  String get netFlow => 'शुद्ध प्रवाह';

  @override
  String get showDetails => 'विवरण दिखाएं';

  @override
  String get customiseSections => 'अनुभाग अनुकूलित करें';

  @override
  String get selectAll => 'सभी चुनें';

  @override
  String get deselectAll => 'सभी हटाएं';

  @override
  String get moreOptions => 'अधिक विकल्प';

  @override
  String get processed => 'संसाधित';

  @override
  String get processedImmediately => 'तुरंत भुगतान किया';

  @override
  String get doubleTapForDetails => 'विवरण के लिए दो बार टैप करें';

  @override
  String get receivedImmediately => 'तुरंत प्राप्त हुआ';

  @override
  String get processedOn => 'संसाधित तिथि';

  @override
  String get paidOnRowLabel => 'भुगतान की तिथि';

  @override
  String get receivedOnRowLabel => 'प्राप्ति की तिथि';

  @override
  String get paidForSubtitle => 'मैंने भुगतान किया, वापस मिलेगा';

  @override
  String get paidBySubtitle => 'किसी ने मेरे लिए भुगतान किया';

  @override
  String get willReceiveSubtitle => 'अपेक्षित, अभी प्राप्त नहीं हुआ';

  @override
  String get receivedFromSubtitle => 'प्राप्त हुआ, वापस करना है';

  @override
  String get spendingBudget => 'खर्च बजट';

  @override
  String get savingsTarget => 'बचत लक्ष्य';

  @override
  String get setBudget => 'बजट सेट करें';

  @override
  String get editBudget => 'बजट संपादित करें';

  @override
  String get setTarget => 'लक्ष्य सेट करें';

  @override
  String get editTarget => 'लक्ष्य संपादित करें';

  @override
  String get monthlyBudget => 'मासिक बजट';

  @override
  String get quarterlyBudget => 'त्रैमासिक बजट';

  @override
  String get yearlyBudget => 'वार्षिक बजट';

  @override
  String get overallBudget => 'कुल बजट';

  @override
  String get overallBudgetProgress => 'कुल बजट प्रगति';

  @override
  String get overallTargetProgress => 'कुल लक्ष्य प्रगति';

  @override
  String get monthlyTarget => 'मासिक लक्ष्य';

  @override
  String get quarterlyTarget => 'त्रैमासिक लक्ष्य';

  @override
  String get yearlyTarget => 'वार्षिक लक्ष्य';

  @override
  String get overallTarget => 'कुल लक्ष्य';

  @override
  String get overallNetAmount => 'कुल शुद्ध राशि';

  @override
  String get providedPeriod => 'निर्धारित अवधि';

  @override
  String get overall => 'कुल';

  @override
  String get spendingBudgetDescription =>
      'कैलेंडर माह, तिमाही, वर्ष या कुल के लिए वैकल्पिक खर्च सीमा।';

  @override
  String get savingsTargetDescription =>
      'कैलेंडर माह, तिमाही, वर्ष या कुल के लिए वैकल्पिक बचत लक्ष्य।';

  @override
  String get budgetSaved => 'बजट सहेजा गया';

  @override
  String get targetSaved => 'लक्ष्य सहेजा गया';

  @override
  String budgetRemainingOf(String remaining, String total) {
    return '$total में से $remaining शेष';
  }

  @override
  String budgetOverBy(String amount) {
    return 'बजट से $amount अधिक';
  }

  @override
  String towardSavingsTarget(String amount) {
    return 'लक्ष्य की ओर $amount';
  }

  @override
  String get customCategoryBadge => 'कस्टम श्रेणी';

  @override
  String get budgetBarUsed => 'उपयोग';

  @override
  String get budgetBarProgress => 'प्रगति';

  @override
  String get categoryRefund => 'रिफंड';

  @override
  String get showQuickActionButton => 'त्वरित कार्य बटन दिखाएं';

  @override
  String get showQuickActionButtonDesc =>
      'नीचे की पट्टी में केंद्र बटन प्रदर्शित करें';

  @override
  String get showDashboardWidgetArea => 'डैशबोर्ड विजेट दिखाएं';

  @override
  String get showDashboardWidgetAreaDesc =>
      'डैशबोर्ड पर अनुकूलन योग्य विजेट अनुभाग प्रदर्शित करें';

  @override
  String get noWidgetsOnDashboard => 'डैशबोर्ड पर कोई विजेट नहीं है';

  @override
  String get switchCashbook => 'कैशबुक बदलें';

  @override
  String get switchText => 'बदलें';

  @override
  String get totalIncome => 'कुल आय';

  @override
  String get totalExpenses => 'कुल खर्च';

  @override
  String get featureUnlimitedAccountsTitle => 'असीमित खाते';

  @override
  String get featureUnlimitedAccountsDesc =>
      'एक ही स्थान पर अपने सभी बैलेंस को ट्रैक करने के लिए कई बैंक खाते, नकद वॉलेट और क्रेडिट कार्ड जोड़ें।';

  @override
  String get featureCategoryBudgetsTitle => 'श्रेणी बजट';

  @override
  String get featureCategoryBudgetsDesc =>
      'किसी भी श्रेणी के लिए मासिक, त्रैमासिक या वार्षिक खर्च सीमा और बचत लक्ष्य निर्धारित करें।';

  @override
  String get onDashboard => 'डैशबोर्ड पर';

  @override
  String get widgets => 'विजेट';

  @override
  String get others => 'अन्य';

  @override
  String get onboardingWelcomeTitle => 'Flowpaisa में आपका स्वागत है';

  @override
  String get onboardingWelcomeBody =>
      'आपका संपूर्ण व्यक्तिगत वित्त और नकदी प्रवाह प्रबंधक। आसानी, सटीकता और इस मानसिक शांति के साथ अपने पैसे पर नियंत्रण रखें कि आपका डेटा पूरी तरह से सुरक्षित और निजी है।';

  @override
  String get onboardingScanTitle => 'स्कैन करें या बोलें';

  @override
  String get onboardingScanBody =>
      'स्मार्ट स्कैनिंग और वॉयस कमांड के साथ समय बचाएं। बस अपनी रसीद की एक फोटो लें या ऐप को बताएं कि आपने क्या खर्च किया—यह आपके लिए विवरण संभाल लेगा।';

  @override
  String get onboardingTransactionsTitle => 'स्मार्ट लिंक्ड लेनदेन';

  @override
  String get onboardingTransactionsBody =>
      'वास्तव में जुड़े हुए सिस्टम का अनुभव करें। जब आप किसी कर्ज को \'प्राप्त\' के रूप में चिह्नित करते हैं, तो ऐप स्वचालित रूप से इसे आय के रूप में रिकॉर्ड करता है। जब आप बिल का भुगतान करते हैं, तो यह तुरंत खर्च के रूप में दर्ज हो जाता है।';

  @override
  String get onboardingCollaborationTitle => 'रीयल-टाइम सहयोग';

  @override
  String get onboardingCollaborationBody =>
      'संपर्क द्वारा प्राप्य और देय राशि को ट्रैक करें। यह सुनिश्चित करने के लिए कि आपको हमेशा समय पर भुगतान मिले, अनुकूलित संदेश टेम्पलेट्स का उपयोग करके पेशेवर व्हाट्सएप रिमाइंडर भेजें।';

  @override
  String get onboardingSyncTitle => 'व्यवस्थित और व्यक्तिगत';

  @override
  String get onboardingSyncBody =>
      'घर या व्यवसाय के लिए अलग कैशबुक बनाएं। कस्टम विजेट्स के साथ अपने डैशबोर्ड को व्यक्तिगत बनाएं, और सब कुछ अपने सभी उपकरणों पर सिंक रखें।';

  @override
  String get guideAccountsTitle => 'अपने सभी खातों का प्रबंधन करें';

  @override
  String get guideAccountsBody =>
      'एक ही स्थान पर नकद, बैंक और बचत खातों को ट्रैक करें। अपनी संपत्ति और देनदारियों से स्वचालित रूप से गणना की गई अपनी कुल संपत्ति देखें।';

  @override
  String get guideCreditCardsTitle => 'क्रेडिट कार्ड प्रबंधन';

  @override
  String get guideCreditCardsBody =>
      'क्रेडिट सीमा और बिलिंग चक्र निर्धारित करें। Flowpaisa आपको देय तिथि से पहले सूचित करेगा ताकि आप कभी भी भुगतान न चूकें।';

  @override
  String get guideBulkImportTitle => 'बल्क इंपोर्ट लेनदेन';

  @override
  String get guideBulkImportBody =>
      'CSV फ़ाइलों या अपने क्लिपबोर्ड (Google शीट्स) से सैकड़ों लेनदेन तुरंत इंपोर्ट करके समय बचाएं।';

  @override
  String get guideBudgetsTitle => 'स्मार्ट श्रेणी बजट';

  @override
  String get guideBudgetsBody =>
      'किसी भी श्रेणी के लिए मासिक खर्च सीमा निर्धारित करें। ट्रैक पर रहने और अधिक बचत करने के लिए खपत संकेतकों का उपयोग करें।';

  @override
  String get guideAutoSettleTitle => 'स्वचालित रूप से उत्पन्न लेनदेन';

  @override
  String get guideAutoSettleBody =>
      'प्राप्य को \'प्राप्त\' के रूप में चिह्नित करने से स्वचालित रूप से एक आय प्रविष्टि बन जाती है। बिल का भुगतान करने से तुरंत एक खर्च दर्ज हो जाता है—आपके रिकॉर्ड को पूरी तरह से लिंक रखता है।';

  @override
  String get guideSplitSettleTitle => 'बिल विभाजित करें और बल्क सेटल करें';

  @override
  String get guideSplitSettleBody =>
      'आसानी से कई संपर्कों के साथ खर्चों को विभाजित करें। एक ही टैप में एक ही संपर्क के साथ सभी बकाया देय राशि को स्पष्ट करने के लिए बल्क सेटलमेंट का उपयोग करें।';

  @override
  String get deleteTransfer => 'ट्रांसफर हटाएं';

  @override
  String get deleteTransferConfirm =>
      'क्या आप वाकई इस ट्रांसफर को हटाना चाहते हैं? इससे दोनों खातों की शेष राशि अपडेट हो जाएगी।';

  @override
  String get deleteReceivable => 'प्राप्य हटाएं';

  @override
  String get deleteReceivableConfirm =>
      'क्या आप वाकई इस प्राप्य को हटाना चाहते हैं? इस क्रिया को पूर्ववत नहीं किया जा सकता।';

  @override
  String get deletePayable => 'देय हटाएं';

  @override
  String get deletePayableConfirm =>
      'क्या आप वाकई इस देय को हटाना चाहते हैं? इस क्रिया को पूर्ववत नहीं किया जा सकता।';

  @override
  String get transferDeleted => 'ट्रांसफर सफलतापूर्वक हटा दिया गया';

  @override
  String get transferUpdated => 'ट्रांसफर सफलतापूर्वक अपडेट किया गया';

  @override
  String get editTransfer => 'ट्रांसफर संपादित करें';

  @override
  String get updateTransfer => 'ट्रांसफर अपडेट करें';

  @override
  String get dashboardHeroCombineTitle => 'संयुक्त शेष देखें';

  @override
  String get dashboardHeroCombineSubtitle =>
      'इस कैशबुक के लिए डैशबोर्ड कुल में कौन से अन्य कैशबुक जोड़ने हैं, चुनें।';

  @override
  String get dashboardHeroCombineNoSummary =>
      'राशि लोड करने के लिए एक बार खोलें।';

  @override
  String get dashboardHeroCombineNoOthers =>
      'शामिल करने के लिए कोई अन्य कैशबुक नहीं है।';

  @override
  String get itemizedDetails => 'मदवार विवरण';

  @override
  String get addItemizedDetails => 'मदवार विवरण जोड़ें';

  @override
  String itemizedHeaderQuantityLabel(String quantity) {
    return '$quantity इकाई';
  }

  @override
  String get unitPrice => 'इकाई मूल्य';

  @override
  String get unitsQuantity => 'इकाई/मात्रा';

  @override
  String get price => 'मूल्य';

  @override
  String get itemized => 'मदवार';

  @override
  String get nextGenerated => 'अगली बार उत्पन्न होगा';

  @override
  String get never => 'कभी नहीं';

  @override
  String get showChart => 'चार्ट दिखाएं';

  @override
  String get showList => 'सूची दिखाएं';

  @override
  String get budget => 'बजट';

  @override
  String get relatedTransactions => 'संबंधित लेनदेन';

  @override
  String get advanced => 'उन्नत';

  @override
  String get autoSyncOnStartup => 'स्टार्टअप पर ऑटो-सिंक';

  @override
  String get autoSyncDescription =>
      'ऐप खुलने पर डेटा को स्वचालित रूप से सिंक करें';

  @override
  String get premiumVerificationToken => 'प्रीमियम सत्यापन टोकन';

  @override
  String get tokenExpiry => 'टोकन समाप्ति';

  @override
  String get refreshToken => 'टोकन रिफ्रेश करें';

  @override
  String get tokenValid => 'प्रीमियम टोकन मान्य है';

  @override
  String get tokenExpiringSoon => 'जल्د समाप्त हो रहा है';

  @override
  String get tokenExpired => 'टोकन समाप्त हो गया';

  @override
  String get premiumTokenMissing => 'प्रीमियम टोकन गायब है';

  @override
  String get noTokenGenerated => 'अभी तक कोई टोकन उत्पन्न नहीं हुआ';

  @override
  String get tokenRegeneratedSuccess =>
      'प्रीमियम टोकन सफलतापूर्वक पुन: उत्पन्न किया गया';

  @override
  String get fetchPremiumToken => 'प्रीमियम टोकन प्राप्त करें';

  @override
  String get premiumTokenSyncedSuccess =>
      'प्रीमियम स्थिति सफलतापूर्वक सिंक की गई!';

  @override
  String get premiumTokenNotFound =>
      'Google Drive पर कोई प्रीमियम सत्यापन नहीं मिला।';

  @override
  String get premiumTokenDescription =>
      'यह टोकन आपको विंडोज और अन्य प्लेटफॉर्म पर अपनी प्रीमियम खरीद का उपयोग करने की अनुमति देता है। अपनी प्रीमियम स्थिति को स्वचालित रूप से सिंक करने के लिए उसी Google खाते से लॉग इन करें।';

  @override
  String get googleDriveNotConnected =>
      'Google Drive कनेक्ट नहीं है। क्लाउड सत्यापन उपलब्ध नहीं होगा।';

  @override
  String get updateAvailable => 'अपडेट उपलब्ध है';

  @override
  String updateAvailableMessage(String version) {
    return 'फ्लोपैसा का एक नया संस्करण ($version) उपलब्ध है। नवीनतम सुविधाओं और सुधारों को प्राप्त करने के लिए अभी अपडेट करें!';
  }

  @override
  String get whatsNew => 'नया क्या है:';

  @override
  String get later => 'बाद में';

  @override
  String get updateNow => 'अभी अपडेट करें';

  @override
  String get downloadingUpdate => 'अपडेट डाउनलोड हो रहा है';

  @override
  String downloadingPercentage(String percentage) {
    return 'डाउनलोड हो रहा है: $percentage%';
  }

  @override
  String get downloadingProgress => 'डाउनलोड हो रहा है...';

  @override
  String get doNotCloseApp =>
      'कृपया एप्लिकेशन बंद न करें। समाप्त होने के बाद, इंस्टॉलर स्वचालित रूप से लॉन्च हो जाएगा।';

  @override
  String get updateFailed => 'अपडेट विफल रहा';

  @override
  String updateFailedMessage(String error) {
    return 'अपडेट डाउनलोड करते समय एक त्रुटि हुई:\n\n$error\n\nकृपया अपना इंटरनेट कनेक्शन जांचें और पुनः प्रयास करें.';
  }

  @override
  String get accountStatement => 'खाता विवरण';

  @override
  String get startingBalance => 'प्रारंभिक शेष';

  @override
  String get endingBalance => 'अंतिम शेष';

  @override
  String get totalCredits => 'कुल क्रेडिट';

  @override
  String get totalDebits => 'कुल डेबिट';

  @override
  String get statementPeriod => 'विवरण अवधि';

  @override
  String get noStatementEntries =>
      'इस अवधि के लिए कोई लेनदेन या ट्रांसफर नहीं मिला।';

  @override
  String get credit => 'क्रेडिट';

  @override
  String get debit => 'डेबिट';

  @override
  String get runningBalance => 'शेष राशि';

  @override
  String get attachments => 'संलग्नक';

  @override
  String get addAttachment => 'संलग्नक जोड़ें';

  @override
  String get noAttachments => 'अभी तक कोई संलग्नक नहीं जोड़ा गया';

  @override
  String get documents => 'दस्तावेज़';

  @override
  String get storage => 'स्टोरेज';

  @override
  String get storageUsed => 'उपयोग की गई स्टोरेज';

  @override
  String get documentBackup => 'दस्तावेज़ बैकअप';

  @override
  String get exportBackup => 'निर्यात';

  @override
  String get importBackup => 'इंपोर्ट';

  @override
  String get backupExported => 'बैकअप सफलतापूर्वक निर्यात किया गया';

  @override
  String get backupImported => 'बैकअप सफलतापूर्वक आयात किया गया';

  @override
  String get uploadingToCloud => 'क्लाउड पर अपलोड हो रहा है...';

  @override
  String get downloadingFromCloud => 'क्लाउड से डाउनलोड हो रहा है...';

  @override
  String get importingBackup => 'बैकअप आयात किया जा रहा है...';

  @override
  String uploadingPercentage(String percentage) {
    return 'अपलोड हो रहा है: $percentage%';
  }

  @override
  String get exportOptions => 'निर्यात विकल्प';

  @override
  String get importOptions => 'इंपोर्ट विकल्प';

  @override
  String get localDevice => 'स्थानीय डिवाइस';

  @override
  String get googleDriveCloud => 'गूगल ड्राइव (क्लाउड)';

  @override
  String get selectExportDestination =>
      'चुनें कि आप अपने दस्तावेज़ कहाँ निर्यात करना चाहते हैं';

  @override
  String get selectImportSource =>
      'चुनें कि आप अपने दस्तावेज़ कहाँ से आयात करना चाहते हैं';

  @override
  String get noCloudBackupFound => 'कोई क्लाउड बैकअप नहीं मिला';

  @override
  String get checkingCloudBackup => 'क्लाउड बैकअप की जाँच की जा रही है...';

  @override
  String get createCloudBackup => 'क्लाउड बैकअप बनाएं';

  @override
  String get updateCloudBackup => 'क्लाउड बैकअप अपडेट करें';

  @override
  String lastBackedUp(String time) {
    return 'पिछला बैकअप $time';
  }

  @override
  String get relativeJustNow => 'अभी-अभी';

  @override
  String relativeMinutesAgo(String minutes) {
    return '$minutes मिनट पहले';
  }

  @override
  String relativeHoursAgo(String hours) {
    return '$hours घंटे पहले';
  }

  @override
  String relativeDaysAgo(String days) {
    return '$days दिन पहले';
  }

  @override
  String get documentsAndStorage => 'दस्तावेज़ और स्टोरेज';

  @override
  String get viewAllDocuments => 'सभी दस्तावेज़ देखें';

  @override
  String get deleteAttachmentConfirm =>
      'क्या आप वाकई इस संलग्नक को हटाना चाहते हैं?';

  @override
  String get deleteAttachmentEditWarning =>
      'यह संलग्नक केवल तभी स्थायी रूप से हटाया जाएगा जब आप लेनदेन को सहेजेंगे।';

  @override
  String get chooseDocument => 'दस्तावेज़ चुनें';

  @override
  String get cameraSubtitle => 'अपने रसीद या दस्तावेज़ की फ़ोटो लें';

  @override
  String get gallerySubtitle => 'अपनी गैलरी से चित्र चुनें';

  @override
  String get chooseDocumentSubtitle => 'पीडीएफ या अन्य दस्तावेज़ फ़ाइलें चुनें';

  @override
  String get exportAsPdf => 'पीडीएफ के रूप में निर्यात करें';

  @override
  String get exportAsPdfSubtitle =>
      'लेन-देन के विवरण और अनुलग्नकों के साथ एक पीडीएफ बनाएं';

  @override
  String get exportPdfWithAttachments => 'अटैचमेंट के साथ पीडीएफ';

  @override
  String get exportPdfWithAttachmentsSubtitle =>
      'प्रीमियम • अटैचमेंट छवियों/पीडीएफ के साथ सुंदर रिपोर्ट';

  @override
  String get generatingPdfReport => 'पीडीएफ रिपोर्ट तैयार की जा रही है...';

  @override
  String get generatingPdfReportSubtitle =>
      'कृपया प्रतीक्षा करें जब तक हम आपके लेनदेन और अनुलग्नकों को संकलित करते हैं';

  @override
  String get transactionsAttachmentReport => 'लेनदेन अटैचमेंट रिपोर्ट';

  @override
  String generatedOn(Object date) {
    return '$date को जनरेट किया गया';
  }

  @override
  String pageOf(Object current, Object total) {
    return 'पृष्ठ $total का $current';
  }

  @override
  String get pdfAppendedMessage =>
      'पीडीएफ दस्तावेज़ (इस कार्ड के बाद मूल रूप से संलग्न)';

  @override
  String get imageAppendedMessage => 'छवि अटैचमेंट (अगले पृष्ठ पर संलग्न)';

  @override
  String get attachmentFile => 'अटैचमेंट फ़ाइल';

  @override
  String get noTransactionsWithAttachments =>
      'अटैचमेंट के ساتھ کوئی लेनदेन नहीं मिला।';

  @override
  String get documentSyncRequired => 'दस्तावेज़ बैकअप आवश्यक है';

  @override
  String get documentSyncRequiredSubtitle =>
      'आपके पास नए अटैचमेंट हैं। बैकअप के लिए टैप करें।';

  @override
  String get textSize => 'टेक्स्ट का आकार';

  @override
  String get textSizeSubtitle =>
      'पूरे ऐप में टेक्स्ट का प्रदर्शन आकार समायोजित करें';

  @override
  String get horizontalSpacing => 'क्षैतिज अंतर';

  @override
  String get horizontalSpacingSubtitle =>
      'टेक्स्ट के क्षैतिज वर्णों के बीच की दूरी समायोजित करें';

  @override
  String get verticalSpacing => 'ऊर्ध्वाधर अंतर';

  @override
  String get verticalSpacingSubtitle =>
      'टेक्स्ट के ऊर्ध्वाधर लाइनों के बीच की दूरी समायोजित करें';

  @override
  String get largeLabel => 'बड़ा';

  @override
  String get smallLabel => 'छोटा';

  @override
  String get tightLabel => 'सघन';

  @override
  String get wideLabel => 'चौड़ा';

  @override
  String get condensedLabel => 'संकुचित';

  @override
  String get looseLabel => 'ढीला';

  @override
  String get doubleLabel => 'दोगुना';

  @override
  String get tripleLabel => 'तिगुना';

  @override
  String get tags => 'टैग';

  @override
  String get transactionTags => 'लेनदेन टैग';

  @override
  String get suggestedTags => 'सुझाए गए टैग';

  @override
  String get addTagHint => 'एक टैग जोड़ें...';

  @override
  String get noTagsUsedYet => 'अभी तक कोई टैग उपयोग नहीं किया गया है।';

  @override
  String get filterWithoutTags => 'बिना टैग';

  @override
  String get deleteTagTitle => 'टैग हटाएं';

  @override
  String deleteTagConfirm(String tagName) {
    return 'क्या आप वाकई टैग \"$tagName\" को स्थायी रूप से हटाना चाहते हैं? इसका उपयोग किसी भी लेनदेन में नहीं किया गया है।';
  }

  @override
  String get cannotDeleteTagTitle => 'टैग हटाया नहीं जा सकता';

  @override
  String cannotDeleteTagMessage(int count) {
    return 'यह टैग वर्तमान में $count लेनदेन में उपयोग किया जा रहा है। इसे हटाने से पहले आपको उन लेनदेन से हटाना होगा।';
  }

  @override
  String get tagDeletedSuccessfully => 'टैग सफलतापूर्वक हटा दिया गया';

  @override
  String get unusedTagIndicator => 'अप्रयुक्त';

  @override
  String createTagQuery(String tagName) {
    return 'टैग \"$tagName\" बनाएं';
  }
}
