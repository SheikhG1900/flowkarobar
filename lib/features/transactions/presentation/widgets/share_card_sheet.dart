import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';

import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/native_share.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/whatsapp/presentation/providers/whatsapp_provider.dart';
import 'package:flutter/services.dart';
import 'package:flowpaisa/core/utils/windows_clipboard_helper.dart';

class ShareCardSheet extends ConsumerStatefulWidget {
  final String transactionType; // 'INCOME', 'EXPENSE', 'RECEIVABLE', 'PAYABLE'
  final double amount;
  final DateTime date;
  final String? description;
  final String deepLink;
  final String initialTextMessage;
  final String senderName;
  final String? senderPhone;
  final String? partnerName;
  final String? partnerPhone;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;

  final bool isLinked;

  const ShareCardSheet({
    super.key,
    required this.transactionType,
    required this.amount,
    required this.date,
    this.description,
    required this.deepLink,
    required this.initialTextMessage,
    required this.senderName,
    this.senderPhone,
    this.partnerName,
    this.partnerPhone,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.isLinked = false,
  });

  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required String transactionType,
    required double amount,
    required DateTime date,
    String? description,
    required String deepLink,
    required String initialTextMessage,
    required String senderName,
    String? senderPhone,
    String? partnerName,
    String? partnerPhone,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    bool isLinked = false,
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.90,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: ShareCardSheet(
              transactionType: transactionType,
              amount: amount,
              date: date,
              description: description,
              deepLink: deepLink,
              initialTextMessage: initialTextMessage,
              senderName: senderName,
              senderPhone: senderPhone,
              partnerName: partnerName,
              partnerPhone: partnerPhone,
              categoryName: categoryName,
              categoryIcon: categoryIcon,
              categoryColor: categoryColor,
              isLinked: isLinked,
            ),
          ),
        ),
      ),
    );
  }

  @override
  ConsumerState<ShareCardSheet> createState() => _ShareCardSheetState();
}

class _ShareCardSheetState extends ConsumerState<ShareCardSheet> {
  final GlobalKey _repaintKey = GlobalKey();
  late bool _isRecipientPerspective;
  bool _includeBranding = true;
  bool _showQrCode = true;
  bool _showDescription = false; // By default description will not be displayed
  String _shareFormat = 'both'; // 'text', 'card', 'both'
  bool _isExporting = false;

  // Custom Pro Profile fields toggles (Persisted locally in widget state)
  bool _showPhone = true;
  bool _showEmail = false;
  bool _showAddress = false;

  @override
  void initState() {
    super.initState();
    // Default recipient perspective enabled for relationship transactions, disabled for others
    _isRecipientPerspective = widget.isLinked || 
                              widget.transactionType == 'PAYABLE' || 
                              widget.transactionType == 'RECEIVABLE';
  }

  // Localized Strings Map for Urdu, Hindi & English
  String _getTranslatedText(String key, String lang) {
    final Map<String, Map<String, String>> localizedValues = {
      'ur': {
        'shareOptions': 'شیئر کے اختیارات',
        'recipientPerspective': 'وصول کنندہ کا نقطہ نظر',
        'perspectiveSub': 'کارڈ کو ان کے مطابق قابل ادائیگی/وصول کے طور پر دکھائیں',
        'includeBranding': 'برانڈنگ واٹر مارک شامل کریں',
        'removeWatermarkSub': 'واٹر مارک ہٹانے کے لیے پریمیم حاصل کریں',
        'formatTextOnly': 'ٹیکسٹ',
        'formatCardOnly': 'کارڈ',
        'formatBoth': 'دونوں',
        'shareFormatLabel': 'فارمیٹ منتخب کریں',
        'shareBtnLabel': 'شیئر کریں',
        'scanToSync': 'فوری طور پر سنک کرنے کے لیے کیمرے سے کیو آر کوڈ اسکین کریں',
        'verifiedVia': 'فلوپیسہ سے تصدیق شدہ',
        'brandingLine': 'فلوپیسہ | کیش بک اور بل تقسیم',
        'paymentRequest': 'ادائیگی کی درخواست',
        'paymentNotification': 'ادائیگی کی اطلاع',
        'paymentAck': 'ادائیگی کی تصدیق',
        'paymentReceipt': 'ادائیگی کی رسید',
        'payableTo': 'کو ادائیگی',
        'receivableFrom': 'سے وصولی',
        'sentTo': 'کو بھیجا گیا',
        'receivedFrom': 'سے موصول ہوا',
        'description': 'تفصیل',
        'issuedBy': 'جاری کنندہ',
        'businessAccount': 'تصدیق شدہ کاروباری پروفائل',
        'personalAccount': 'تصدیق شدہ ذاتی پروفائل',
        'categoryLabel': 'زمرہ',
        'proCardCustom': 'پروفائل کارڈ حسب ضرورت بنائیں',
        'proCardCustomSub': 'پروفائل میں سے منتخب تفصیلات کارڈ پر دکھائیں',
        'togglePhone': 'فون نمبر دکھائیں',
        'toggleEmail': 'ای میل دکھائیں',
        'toggleAddress': 'پتہ دکھائیں',
        'needProField': 'یہ تفصیل شامل کرنے کے لیے اپنی پروفائل میں درج کریں',
        'showQrCode': 'کیو آر کوڈ دکھائیں',
        'showQrCodeSub': 'کارڈ پر فوری سنک کے لیے کیو آر کوڈ شامل کریں',
        'removeQrCodeSub': 'کیو آر کوڈ چھپانے کے لیے پریمیم حاصل کریں',
        'showDescription': 'تفصیل دکھائیں',
        'showDescriptionSub': 'کارڈ پر ٹرانزیکشن کی تفصیل شامل کریں',
        'removeDescriptionSub': 'تفصیل چھپانے کے لیے پریمیم حاصل کریں',
        'partnerLabel': 'شریک کار',
        'issuedTo': 'بنام',
        'payer': 'ادا کنندہ',
        'receiver': 'وصول کنندہ',
        'paymentConfirmation': 'ادائیگی کی تصدیق',
        'payableAdvice': 'قابل ادائیگی تفصیل',
        'receivableAdvice': 'قابل وصولی تفصیل',
        'shareWhatsApp': 'واٹس ایپ کے ذریعے بھیجیں',
        'sentWhatsAppMsg': 'پیغام واٹس ایپ پر بھیج دیا گیا ہے',
        'textCopied': 'متن کلپ بورڈ پر کاپی ہو گیا ہے!',
        'cardCopied': 'کارڈ کلپ بورڈ پر کاپی ہو گیا ہے! شیئر کرنے کے لیے کہیں بھی پیسٹ (Ctrl+V) کریں۔',
        'bothCopied': 'کارڈ اور متن کلپ بورڈ پر کاپی ہو گیا ہے! شیئر کرنے کے لیے کہیں بھی پیسٹ (Ctrl+V) کریں۔',
        'failedCopy': 'کلپ بورڈ پر کاپی کرنے میں ناکامی۔',
      },
      'hi': {
        'shareOptions': 'साझा करने के विकल्प',
        'recipientPerspective': 'प्राप्तकर्ता का दृष्टिकोण',
        'perspectiveSub': 'कार्ड को उनके अनुसार देय/प्राप्य के रूप में दिखाएं',
        'includeBranding': 'ब्रांडिंग वॉटरमार्क शामिल करें',
        'removeWatermarkSub': 'वॉटरमार्क हटाने के लिए प्रीमियम लें',
        'formatTextOnly': 'टेक्स्ट',
        'formatCardOnly': 'कार्ड',
        'formatBoth': 'दोनों',
        'shareFormatLabel': 'प्रारूप चुनें',
        'shareBtnLabel': 'साझा करें',
        'scanToSync': 'तुरंत सिंक करने के लिए कैमरे से क्यूआर कोड स्कैन करें',
        'verifiedVia': 'फ्लोपैसा द्वारा सत्यापित',
        'brandingLine': 'फ्लोपैसा | कैशबुक और बिल विभाजन',
        'paymentRequest': 'भुगतान अनुरोध',
        'paymentNotification': 'भुगतान सूचना',
        'paymentAck': 'भुगतान पावती',
        'paymentReceipt': 'भुगतान रसीद',
        'payableTo': 'को देय',
        'receivableFrom': 'से प्राप्य',
        'sentTo': 'को भेजा गया',
        'receivedFrom': 'से प्राप्त हुआ',
        'description': 'विवरण',
        'issuedBy': 'जारीकर्ता',
        'businessAccount': 'सत्यापित व्यावसायिक प्रोफ़ाइल',
        'personalAccount': 'सत्यापित व्यक्तिगत प्रोफ़ाइल',
        'categoryLabel': 'श्रेणी',
        'proCardCustom': 'प्रोफ़ाइल कार्ड अनुकूलित करें',
        'proCardCustomSub': 'प्रोफ़ाइल से चुनिंदा जानकारी कार्ड पर प्रदर्शित करें',
        'togglePhone': 'फ़ोन नंबर दिखाएं',
        'toggleEmail': 'ईमेल दिखाएं',
        'toggleAddress': 'पता दिखाएं',
        'needProField': 'यह जानकारी जोड़ने के लिए अपनी प्रोफ़ाइल सेट करें',
        'showQrCode': 'क्यूआर कोड दिखाएं',
        'showQrCodeSub': 'त्वरित सिंक के लिए कार्ड पर क्यूआर कोड शामिल करें',
        'removeQrCodeSub': 'क्यूआर कोड छिपाने के लिए प्रीमियम लें',
        'showDescription': 'विवरण दिखाएं',
        'showDescriptionSub': 'कार्ड पर लेनदेन का विवरण शामिल करें',
        'removeDescriptionSub': 'विवरण छिपाने के लिए प्रीमियम लें',
        'partnerLabel': 'साझेदार',
        'issuedTo': 'के नाम',
        'payer': 'भुगतानकर्ता',
        'receiver': 'प्राप्तकर्ता',
        'paymentConfirmation': 'भुगतान पुष्टि',
        'payableAdvice': 'देय विवरण',
        'receivableAdvice': 'प्राप्य विवरण',
        'shareWhatsApp': 'व्हाट्सएप के माध्यम से भेजें',
        'sentWhatsAppMsg': 'संदेश व्हाट्सएप पर भेज दिया गया है',
        'textCopied': 'पाठ क्लिपबोर्ड पर कॉपी हो गया है!',
        'cardCopied': 'कार्ड क्लिपबोर्ड पर कॉपी हो गया है! साझा करने के लिए कहीं भी पेस्ट (Ctrl+V) करें।',
        'bothCopied': 'कार्ड और पाठ क्लिपबोर्ड पर कॉपी हो गया है! साझा करने के लिए कहीं भी पेस्ट (Ctrl+V) करें।',
        'failedCopy': 'क्लिपबोर्ड पर कॉपी करने में असमर्थ।',
      },
      'en': {
        'shareOptions': 'Share Options',
        'recipientPerspective': "Recipient's Perspective",
        'perspectiveSub': 'Show card as payable/receivable for them',
        'includeBranding': 'Include Branding Watermark',
        'removeWatermarkSub': 'Get Premium to remove watermark',
        'formatTextOnly': 'Text',
        'formatCardOnly': 'Card',
        'formatBoth': 'Both',
        'shareFormatLabel': 'Select Format',
        'shareBtnLabel': 'Share',
        'scanToSync': 'Scan QR with camera to sync transaction instantly',
        'verifiedVia': 'Verified via Flowpaisa',
        'brandingLine': 'Flowpaisa | Smart Cashbook & Splits',
        'paymentRequest': 'Payment Request',
        'paymentNotification': 'Payment Notification',
        'paymentAck': 'Payment Acknowledgment',
        'paymentReceipt': 'Payment Receipt',
        'payableTo': 'Payable to',
        'receivableFrom': 'Receivable from',
        'sentTo': 'Sent to',
        'receivedFrom': 'Received from',
        'description': 'Note',
        'issuedBy': 'Issued by',
        'businessAccount': 'Verified Business Profile',
        'personalAccount': 'Verified Personal Profile',
        'categoryLabel': 'Category',
        'proCardCustom': 'Customize Business Profile Card',
        'proCardCustomSub': 'Display custom profile information on the card',
        'togglePhone': 'Show Phone Number',
        'toggleEmail': 'Show Email Address',
        'toggleAddress': 'Show Address',
        'needProField': 'Fill this field in your profile settings to enable',
        'showQrCode': 'Show QR Code',
        'showQrCodeSub': 'Include QR code on the card for instant sync',
        'removeQrCodeSub': 'Get Premium to hide QR code',
        'showDescription': 'Show Description',
        'showDescriptionSub': 'Include transaction description on the card',
        'removeDescriptionSub': 'Get Premium to hide description',
        'partnerLabel': 'Partner',
        'issuedTo': 'Issued to',
        'payer': 'Payer',
        'receiver': 'Receiver',
        'paymentConfirmation': 'Payment Confirmation',
        'payableAdvice': 'Payable Advice',
        'receivableAdvice': 'Receivable Advice',
        'shareWhatsApp': 'Send via WhatsApp',
        'sentWhatsAppMsg': 'Message sent on WhatsApp',
        'textCopied': 'Text copied to clipboard!',
        'cardCopied': 'Card copied to clipboard! Paste (Ctrl+V) anywhere to share.',
        'bothCopied': 'Card and text copied to clipboard! Paste (Ctrl+V) anywhere to share.',
        'failedCopy': 'Failed to copy to clipboard.',
      }
    };

    final effectiveLang = ['ur', 'hi', 'en'].contains(lang) ? lang : 'en';
    return localizedValues[effectiveLang]?[key] ?? localizedValues['en']![key]!;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final isPremium = ref.watch(premiumProvider).isPremiumActive;
    final theme = Theme.of(context);
    final currency = ref.watch(currentCurrencyProvider).value;
    final profile = ref.watch(userProfileProvider);

    // Enforce that only Premium users can actually hide the QR code/description under any circumstances
    final actualShowQr = isPremium ? _showQrCode : true;
    final actualShowDescription = isPremium ? _showDescription : false; // For free users, hide description by default unless premium allows choice

    // Filter available custom toggles based on user profile settings
    final hasPhone = profile.phone != null && profile.phone!.trim().isNotEmpty;
    final hasEmail = profile.email != null && profile.email!.trim().isNotEmpty;
    final hasAddress = profile.address != null && profile.address!.trim().isNotEmpty;

    // Determine the deep link's payload status if possible
    String? deepLinkStatus;
    String? finalCategoryName = widget.categoryName;
    String? finalCategoryIcon = widget.categoryIcon;
    String? finalCategoryColor = widget.categoryColor;

    try {
      final uri = Uri.parse(widget.deepLink);
      final dataParam = uri.queryParameters['data'];
      if (dataParam != null) {
        final decodedBytes = base64Url.decode(dataParam);
        final decodedStr = utf8.decode(decodedBytes);
        final jsonMap = json.decode(decodedStr) as Map<String, dynamic>;
        deepLinkStatus = (jsonMap['s'] ?? jsonMap['status']) as String?;
        finalCategoryName ??= (jsonMap['cn'] ?? jsonMap['categoryName']) as String?;
        finalCategoryIcon ??= (jsonMap['ci'] ?? jsonMap['categoryIcon']) as String?;
        finalCategoryColor ??= (jsonMap['cc'] ?? jsonMap['categoryColor']) as String?;
      }
    } catch (_) {
      // Ignore parsing errors and use default behavior
    }

    // Filter and sanitize the description to strip any appended itemized JSON / splits metadata block (e.g. \n[ or json arrays/objects)
    String cleanDescription = '';
    if (widget.description != null && widget.description!.isNotEmpty) {
      final descStr = widget.description!;
      final bracketIdx = descStr.indexOf('\n[');
      if (bracketIdx != -1) {
        cleanDescription = descStr.substring(0, bracketIdx).trim();
      } else {
        // Also clean generic json structure if it somehow starts with [ or {
        final trimmed = descStr.trim();
        if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
          cleanDescription = '';
        } else {
          cleanDescription = trimmed;
        }
      }
    }

    // Determine current perspective colors and text
    String cardTitle = '';
    String cardSubtitle = '';
    LinearGradient cardGradient = AppColors.primaryGradient;
    IconData cardIcon = Icons.account_balance_wallet;

    bool isPaidStatus = false;
    bool isReceivedStatus = false;
    bool isPayableStatus = false;
    bool isReceivableStatus = false;

    final actualType = widget.transactionType.toUpperCase();

    // Calculate Payer / Receiver role tags
    // For INCOME and RECEIVABLE: Sender is the Receiver, Partner/Recipient is the Payer.
    // For EXPENSE and PAYABLE: Sender is the Payer, Partner/Recipient is the Receiver.
    final bool isSenderPayer = actualType == 'EXPENSE' || actualType == 'PAYABLE';
    final String senderRoleTag = isSenderPayer 
        ? _getTranslatedText('payer', locale) 
        : _getTranslatedText('receiver', locale);
    final String partnerRoleTag = isSenderPayer 
        ? _getTranslatedText('receiver', locale) 
        : _getTranslatedText('payer', locale);

    if (_isRecipientPerspective) {
      if (actualType == 'RECEIVABLE') {
        if (deepLinkStatus == 'RECEIVED') {
          cardTitle = _getTranslatedText('paymentConfirmation', locale);
          cardSubtitle = 'paid'.localizeCategory(context);
          isPaidStatus = true;
          cardGradient = AppColors.expenseGradient;
          cardIcon = Icons.check_circle_outline_rounded;
        } else {
          cardTitle = _getTranslatedText('paymentRequest', locale);
          cardSubtitle = 'payable'.localizeCategory(context);
          isPayableStatus = true;
          cardGradient = AppColors.payableGradient;
          cardIcon = Icons.pending_actions_rounded;
        }
      } else if (actualType == 'PAYABLE') {
        if (deepLinkStatus == 'PAID') {
          cardTitle = _getTranslatedText('paymentConfirmation', locale);
          cardSubtitle = 'received'.localizeCategory(context);
          isReceivedStatus = true;
          cardGradient = AppColors.incomeGradient;
          cardIcon = Icons.check_circle_outline_rounded;
        } else {
          cardTitle = _getTranslatedText('paymentNotification', locale);
          cardSubtitle = 'receivable'.localizeCategory(context);
          isReceivableStatus = true;
          cardGradient = AppColors.receivableGradient;
          cardIcon = Icons.hourglass_empty_rounded;
        }
      } else if (actualType == 'INCOME') {
        cardTitle = _getTranslatedText('paymentReceipt', locale);
        cardSubtitle = 'paid'.localizeCategory(context);
        isPaidStatus = true;
        cardGradient = AppColors.expenseGradient;
        cardIcon = Icons.check_circle_outline_rounded;
      } else {
        // EXPENSE
        cardTitle = _getTranslatedText('paymentConfirmation', locale);
        cardSubtitle = 'received'.localizeCategory(context);
        isReceivedStatus = true;
        cardGradient = AppColors.incomeGradient;
        cardIcon = Icons.check_circle_outline_rounded;
      }
    } else {
      // Self perspective
      if (actualType == 'RECEIVABLE') {
        if (deepLinkStatus == 'RECEIVED') {
          cardTitle = _getTranslatedText('paymentReceipt', locale);
          cardSubtitle = 'received'.localizeCategory(context);
          isReceivedStatus = true;
          cardGradient = AppColors.incomeGradient;
          cardIcon = Icons.check_circle_outline_rounded;
        } else {
          cardTitle = _getTranslatedText('receivableAdvice', locale);
          cardSubtitle = 'receivable'.localizeCategory(context);
          isReceivableStatus = true;
          cardGradient = AppColors.receivableGradient;
          cardIcon = Icons.arrow_downward_rounded;
        }
      } else if (actualType == 'PAYABLE') {
        if (deepLinkStatus == 'PAID') {
          cardTitle = _getTranslatedText('paymentConfirmation', locale);
          cardSubtitle = 'paid'.localizeCategory(context);
          isPaidStatus = true;
          cardGradient = AppColors.expenseGradient;
          cardIcon = Icons.check_circle_outline_rounded;
        } else {
          cardTitle = _getTranslatedText('payableAdvice', locale);
          cardSubtitle = 'payable'.localizeCategory(context);
          isPayableStatus = true;
          cardGradient = AppColors.payableGradient;
          cardIcon = Icons.arrow_upward_rounded;
        }
      } else if (actualType == 'INCOME') {
        cardTitle = _getTranslatedText('paymentReceipt', locale);
        cardSubtitle = 'received'.localizeCategory(context);
        isReceivedStatus = true;
        cardGradient = AppColors.incomeGradient;
        cardIcon = Icons.check_circle_outline_rounded;
      } else {
        // EXPENSE
        cardTitle = _getTranslatedText('paymentConfirmation', locale);
        cardSubtitle = 'paid'.localizeCategory(context);
        isPaidStatus = true;
        cardGradient = AppColors.expenseGradient;
        cardIcon = Icons.check_circle_outline_rounded;
      }
    }

    Color statusBgColor = Colors.transparent;
    Color statusTextColor = Colors.white;
    Color statusBorderColor = Colors.white.withValues(alpha: 0.4);
    IconData? statusIconData;

    if (isPaidStatus) {
      statusTextColor = const Color(0xFFFFCDD2);
      statusBorderColor = statusTextColor;
      statusIconData = Icons.check_circle_outline_rounded;
    } else if (isReceivedStatus) {
      statusTextColor = const Color(0xFFC8E6C9);
      statusBorderColor = statusTextColor;
      statusIconData = Icons.check_circle_outline_rounded;
    } else if (isPayableStatus) {
      statusTextColor = const Color(0xFFFFE082);
      statusBorderColor = statusTextColor;
    } else if (isReceivableStatus) {
      statusTextColor = const Color(0xFFB3E5FC);
      statusBorderColor = statusTextColor;
    }

    final isUrdu = locale == 'ur';
    final textDirection = isUrdu ? TextDirection.rtl : TextDirection.ltr;

    IconData? catIconData;
    if (finalCategoryIcon != null) {
      catIconData = IconHelper.getIconData(finalCategoryIcon);
    }

    final mainColor = cardGradient.colors.last;
    final hsl = HSLColor.fromColor(mainColor);
    // Lower the saturation (dullness) and increase lightness slightly to make the card's drop shadow pop beautifully
    final dullHsl = hsl
        .withSaturation((hsl.saturation * 0.40).clamp(0.12, 0.35))
        .withLightness((hsl.lightness * 0.58).clamp(0.15, 0.28));
    final frameBgColorColor = dullHsl.toColor();
    
    // Create an elegant gradient with a subtle lightness variance (a soft top-to-bottom glow)
    final topHsl = dullHsl.withLightness((dullHsl.lightness + 0.05).clamp(0.0, 1.0));
    final bottomHsl = dullHsl.withLightness((dullHsl.lightness - 0.05).clamp(0.0, 1.0));
    
    final frameGradient = LinearGradient(
      colors: [
        topHsl.toColor(),
        bottomHsl.toColor(),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Drag Handle & Title
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getTranslatedText('shareOptions', locale),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // 1. Interactive Image Card Preview
          if (_shareFormat != 'text') ...[
            Center(
              child: RepaintBoundary(
                key: _repaintKey,
                child: Container(
                  width: 360,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
                  decoration: BoxDecoration(
                    gradient: frameGradient,
                  ),
                  child: Directionality(
                    textDirection: textDirection,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Card Header & App Brand (moved to outer canvas)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/logo_square.png',
                                    width: 24,
                                    height: 24,
                                    errorBuilder: (_, __, ___) => Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white24,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.account_balance_wallet, size: 14, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.appTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(cardIcon, size: 12, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      cardTitle,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Ticket Card Content
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: cardGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // PREMIUM ONLY: USER-SPECIFIC BRANDING (Verified Professional Header)
                              if (isPremium) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.senderName.isNotEmpty ? widget.senderName[0].toUpperCase() : 'S',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              widget.senderName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.verified_rounded,
                                            size: 14,
                                            color: Color(0xFFFFD700), // Gold badge checkmark
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              senderRoleTag,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Customizable Profile Details based on active toggles
                                      if (_showPhone && hasPhone) ...[
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.phone, size: 8, color: Colors.white70),
                                            const SizedBox(width: 4),
                                            Text(
                                              profile.phone!,
                                              style: const TextStyle(color: Colors.white70, fontSize: 9),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (_showEmail && hasEmail) ...[
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.email, size: 8, color: Colors.white70),
                                            const SizedBox(width: 4),
                                            Text(
                                              profile.email!,
                                              style: const TextStyle(color: Colors.white70, fontSize: 9),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (_showAddress && hasAddress) ...[
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 8, color: Colors.white70),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                profile.address!,
                                                style: const TextStyle(color: Colors.white70, fontSize: 9),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                        
                        // SMART TWO-COLUMN DETAILS ROW (Category & Date on Left, Amount & Subtitle on Right)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Left Column: Category (above) & Date (below)
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Category Capsule with a subtle high-end glass border
                                  if (finalCategoryName != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            catIconData ?? Icons.category_rounded,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              LocalizationHelper.getLocalizedCategoryName(context, finalCategoryName),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                shadows: [
                                                  Shadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 1),
                                                ],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                  // Date Block
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white.withValues(alpha: 0.75)),
                                      const SizedBox(width: 5),
                                      Text(
                                        AppDateFormatter.formatDate(widget.date),
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.85),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(color: Colors.black12, offset: const Offset(0, 1), blurRadius: 1),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: 12),

                            // Right Column: Amount & Subtitle (Right-aligned with elegant typography shadows)
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusBgColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: statusBorderColor, width: 1.2),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (statusIconData != null) ...[
                                          Icon(
                                            statusIconData,
                                            size: 11,
                                            color: statusTextColor,
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        Text(
                                          cardSubtitle,
                                          style: TextStyle(
                                            color: statusTextColor,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 10,
                                            letterSpacing: 0.4,
                                          ),
                                          textAlign: TextAlign.end,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    currency != null
                                        ? AmountFormatter.formatWithCurrency(widget.amount, currency)
                                        : widget.amount.toStringAsFixed(2),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 28, // Compacted to look crisp on a row
                                      letterSpacing: -0.5,
                                      shadows: [
                                        Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
                                      ],
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        // Premium Dashed Ticket Divider Line (Always visible, even when QR is hidden)
                        Padding(
                          padding: const EdgeInsets.only(top: 14.0, bottom: 4.0),
                          child: Row(
                            children: List.generate(
                              24,
                              (index) => Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  height: 1.5,
                                  color: Colors.white.withValues(alpha: 0.22),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Notes Description Bubble (Enhanced design - premium toggle controlled and sanitized)
                        if (actualShowDescription && cleanDescription.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.notes_rounded, size: 14, color: Colors.white.withValues(alpha: 0.9)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    cleanDescription,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Partner / Other-Side Contact Bubble (Enhanced design - same as description)
                        if (widget.partnerName != null && widget.partnerName!.trim().isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.person_outline_rounded, size: 14, color: Colors.white.withValues(alpha: 0.9)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          widget.partnerName!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            height: 1.3,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          partnerRoleTag,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                            ],
                          ),
                        ),

                        // Centered High-Contrast Standalone QR Code directly on the outer canvas background (With Modern Circular Eyes and Sleek Minimalist Outline)
                        if (actualShowQr) ...[
                          const SizedBox(height: 20),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8), // Minimal curve
                                color: Colors.black.withValues(alpha: 0.08),
                              ),
                              child: QrImageView(
                                data: widget.deepLink,
                                version: QrVersions.auto,
                                errorCorrectionLevel: QrErrorCorrectLevel.L, // Lowest density = much larger dots & instant scanning
                                size: 160.0, // Sleek, clean, highly visible standalone size
                                padding: EdgeInsets.zero, // Zero internal padding for maximum space efficiency
                                gapless: true, // Prevents tiny gaps or scanning glitches
                                eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.circle, // Circular eye blocks look EXTREMELY premium and modern!
                                    color: Colors.white,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.circle, // Sleek circular dots
                                    color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Watermark App Branding on the outer canvas background
                        if (_includeBranding) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                size: 10,
                                color: Colors.white.withValues(alpha: 0.4), // Reduced opacity
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPremium
                                    ? _getTranslatedText('verifiedVia', locale)
                                    : _getTranslatedText('brandingLine', locale),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4), // Reduced opacity
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 2. Control Options Panel
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Option A: Perspective Switch
                  SwitchListTile(
                    activeColor: theme.colorScheme.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    title: Text(
                      _getTranslatedText('recipientPerspective', locale),
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _getTranslatedText('perspectiveSub', locale),
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                    value: _isRecipientPerspective,
                    onChanged: (val) {
                      setState(() {
                        _isRecipientPerspective = val;
                      });
                    },
                  ),
                  const Divider(height: 1),

                  // Option B: Watermark Switch (Locked for Free Users)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    title: Row(
                      children: [
                        Text(
                          _getTranslatedText('includeBranding', locale),
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (!isPremium) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.payableColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.star_rounded, size: 10, color: AppColors.payableColor),
                                SizedBox(width: 2),
                                Text('PRO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.payableColor)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      isPremium
                          ? l10n.premiumActive
                          : _getTranslatedText('removeWatermarkSub', locale),
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                    trailing: Switch(
                      activeColor: theme.colorScheme.primary,
                      value: _includeBranding,
                      onChanged: (val) {
                        if (!isPremium && !val) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PremiumScreen()),
                          );
                        } else {
                          setState(() {
                            _includeBranding = val;
                          });
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),

                  // Option C: QR Code Toggle Switch (Locked for Free Users)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    title: Row(
                      children: [
                        Text(
                          _getTranslatedText('showQrCode', locale),
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (!isPremium) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.payableColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.star_rounded, size: 10, color: AppColors.payableColor),
                                SizedBox(width: 2),
                                Text('PRO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.payableColor)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      isPremium
                          ? _getTranslatedText('showQrCodeSub', locale)
                          : _getTranslatedText('removeQrCodeSub', locale),
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                    trailing: Switch(
                      activeColor: theme.colorScheme.primary,
                      value: actualShowQr,
                      onChanged: (val) {
                        if (!isPremium && !val) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PremiumScreen()),
                          );
                        } else {
                          setState(() {
                            _showQrCode = val;
                          });
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),

                  // Option D: Description Toggle Switch (Locked for Free Users)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    title: Row(
                      children: [
                        Text(
                          _getTranslatedText('showDescription', locale),
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (!isPremium) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.payableColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.star_rounded, size: 10, color: AppColors.payableColor),
                                SizedBox(width: 2),
                                Text('PRO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.payableColor)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      isPremium
                          ? _getTranslatedText('showDescriptionSub', locale)
                          : _getTranslatedText('removeDescriptionSub', locale),
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                    trailing: Switch(
                      activeColor: theme.colorScheme.primary,
                      value: actualShowDescription,
                      onChanged: (val) {
                        if (!isPremium) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PremiumScreen()),
                          );
                        } else {
                          setState(() {
                            _showDescription = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3. PREMIUM CUSTOMIZABLE PROFILE CARD OPTIONS
          if (isPremium) ...[
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.badge_rounded, size: 16, color: Color(0xFFFFD700)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getTranslatedText('proCardCustom', locale),
                                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _getTranslatedText('proCardCustomSub', locale),
                                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 12),
                    // Phone Toggle (Only shown if filled in profile)
                    if (hasPhone)
                      SwitchListTile(
                        activeColor: theme.colorScheme.primary,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                        title: Text(
                          _getTranslatedText('togglePhone', locale),
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        value: _showPhone,
                        onChanged: (val) {
                          setState(() {
                            _showPhone = val;
                          });
                        },
                      )
                    else
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                        title: Text(
                          _getTranslatedText('togglePhone', locale),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.disabledColor),
                        ),
                        subtitle: Text(
                          _getTranslatedText('needProField', locale),
                          style: TextStyle(fontSize: 9, color: theme.disabledColor),
                        ),
                        trailing: const Icon(Icons.lock_outline, size: 16),
                      ),
                    
                    // Email Toggle (Only shown if filled in profile)
                    if (hasEmail)
                      SwitchListTile(
                        activeColor: theme.colorScheme.primary,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                        title: Text(
                          _getTranslatedText('toggleEmail', locale),
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        value: _showEmail,
                        onChanged: (val) {
                          setState(() {
                            _showEmail = val;
                          });
                        },
                      )
                    else
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                        title: Text(
                          _getTranslatedText('toggleEmail', locale),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.disabledColor),
                        ),
                        subtitle: Text(
                          _getTranslatedText('needProField', locale),
                          style: TextStyle(fontSize: 9, color: theme.disabledColor),
                        ),
                        trailing: const Icon(Icons.lock_outline, size: 16),
                      ),

                    // Address Toggle (Only shown if filled in profile)
                    if (hasAddress)
                      SwitchListTile(
                        activeColor: theme.colorScheme.primary,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                        title: Text(
                          _getTranslatedText('toggleAddress', locale),
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        value: _showAddress,
                        onChanged: (val) {
                          setState(() {
                            _showAddress = val;
                          });
                        },
                      )
                    else
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                        title: Text(
                          _getTranslatedText('toggleAddress', locale),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.disabledColor),
                        ),
                        subtitle: Text(
                          _getTranslatedText('needProField', locale),
                          style: TextStyle(fontSize: 9, color: theme.disabledColor),
                        ),
                        trailing: const Icon(Icons.lock_outline, size: 16),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 4. Share Format Segment Choice
          Text(
            _getTranslatedText('shareFormatLabel', locale),
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment<String>(
                value: 'text',
                label: Text(_getTranslatedText('formatTextOnly', locale), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.notes_rounded, size: 14),
              ),
              ButtonSegment<String>(
                value: 'card',
                label: Text(_getTranslatedText('formatCardOnly', locale), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.photo_outlined, size: 14),
              ),
              ButtonSegment<String>(
                value: 'both',
                label: Text(_getTranslatedText('formatBoth', locale), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.all_inclusive_rounded, size: 14),
              ),
            ],
            selected: {_shareFormat},
            onSelectionChanged: (newSelection) {
              setState(() {
                _shareFormat = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 24),

          // 5. Action Share Button
          FilledButton.icon(
            onPressed: _isExporting ? null : _shareContent,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: _isExporting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.share_rounded),
            label: Text(
              _getTranslatedText('shareBtnLabel', locale),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          
          // WhatsApp Brand Direct Message Button (Shown if partnerPhone is available)
          if (!Platform.isWindows && widget.partnerPhone != null && widget.partnerPhone!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isExporting ? null : _sendWhatsAppDirect,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: const Color(0xFF25D366),
                side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
              label: Text(
                _getTranslatedText('shareWhatsApp', locale),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _sendWhatsAppDirect() async {
    final locale = Localizations.localeOf(context).languageCode;
    final cleanPhone = widget.partnerPhone!.replaceAll(' ', '').replaceAll(RegExp(r'[^\d+]'), '');
    final whatsAppService = ref.read(whatsAppServiceProvider);
    
    setState(() => _isExporting = true);
    try {
      if (Platform.isWindows && _shareFormat != 'text') {
        final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) {
          throw Exception('Preview render boundary is not ready');
        }

        await Future.delayed(const Duration(milliseconds: 100));

        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) {
          throw Exception('Failed to generate image byte data');
        }

        final pngBytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        
        final file = await File('${tempDir.path}/flowpaisa_tx_${DateTime.now().millisecondsSinceEpoch}.png').create();
        await file.writeAsBytes(pngBytes);

        // Copy both text and image file to clipboard
        final copied = WindowsClipboardHelper.copyTextAndFileToClipboard(widget.initialTextMessage, file.path);
        
        // Open WhatsApp chat
        await whatsAppService.sendMessage(cleanPhone, widget.initialTextMessage);

        if (copied && mounted) {
          ToastUtils.showSuccessToast(
            context,
            ref,
            'Card and text copied to clipboard! Paste (Ctrl+V) in WhatsApp to send.',
          );
          Navigator.pop(context);
        } else if (mounted) {
          ToastUtils.showSuccessToast(
            context,
            ref,
            _getTranslatedText('sentWhatsAppMsg', locale),
          );
          Navigator.pop(context);
        }
      } else {
        await whatsAppService.sendMessage(cleanPhone, widget.initialTextMessage);
        if (mounted) {
          ToastUtils.showSuccessToast(
            context,
            ref,
            _getTranslatedText('sentWhatsAppMsg', locale),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(context, ref, 'Failed to send WhatsApp message: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _shareContent() async {
    final locale = Localizations.localeOf(context).languageCode;
    setState(() => _isExporting = true);

    try {
      if (_shareFormat == 'text') {
        if (Platform.isWindows) {
          await Clipboard.setData(ClipboardData(text: widget.initialTextMessage));
          if (mounted) {
            ToastUtils.showSuccessToast(context, ref, _getTranslatedText('textCopied', locale));
            Navigator.pop(context);
          }
        } else {
          await SharePlus.instance.share(ShareParams(
            text: widget.initialTextMessage,
            subject: 'Flowpaisa',
          ));
        }
      } else {
        final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) {
          throw Exception('Preview render boundary is not ready');
        }

        await Future.delayed(const Duration(milliseconds: 100));

        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) {
          throw Exception('Failed to generate image byte data');
        }

        final pngBytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        
        final file = await File('${tempDir.path}/flowpaisa_tx_${DateTime.now().millisecondsSinceEpoch}.png').create();
        await file.writeAsBytes(pngBytes);

        if (Platform.isWindows) {
          bool copied = false;
          if (_shareFormat == 'card') {
            copied = WindowsClipboardHelper.copyPngToClipboard(pngBytes);
          } else {
            copied = WindowsClipboardHelper.copyPngAndTextToClipboard(widget.initialTextMessage, pngBytes, file.path);
          }
          if (mounted) {
            if (copied) {
              ToastUtils.showSuccessToast(
                context,
                ref,
                _shareFormat == 'card' 
                    ? _getTranslatedText('cardCopied', locale)
                    : _getTranslatedText('bothCopied', locale),
              );
            } else {
              ToastUtils.showErrorToast(context, ref, _getTranslatedText('failedCopy', locale));
            }
            Navigator.pop(context);
          }
        } else {
          final xFile = XFile(
            file.path,
            mimeType: 'image/png',
            name: file.path.split(Platform.pathSeparator).last,
          );

          if (_shareFormat == 'card') {
            if (Platform.isAndroid) {
              final success = await NativeShare.shareFile(file.path);
              if (!success) {
                await SharePlus.instance.share(ShareParams(
                  files: [xFile],
                  subject: 'Flowpaisa Card',
                ));
              }
            } else {
              await SharePlus.instance.share(ShareParams(
                files: [xFile],
                subject: 'Flowpaisa Card',
              ));
            }
          } else {
            await SharePlus.instance.share(ShareParams(
              files: [xFile],
              text: widget.initialTextMessage,
              subject: 'Flowpaisa Sync Receipt',
            ));
          }
        }
      }

      if (mounted && !Platform.isWindows) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(context, ref, 'Failed to share: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
}
