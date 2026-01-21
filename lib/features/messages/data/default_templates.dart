/// Default message templates for all supported languages
/// These are used as fallbacks when custom templates are not found
class DefaultTemplates {
  // Template types
  static const String receivableReminder = 'receivable_reminder';
  static const String payableReminder = 'payable_reminder';
  static const String transactionReceipt = 'transaction_receipt';
  static const String transactionShare = 'transaction_share';
  static const String receivableShare = 'receivable_share';
  static const String payableShare = 'payable_share';

  // Status variants
  static const String pending = 'pending';
  static const String received = 'received';
  static const String paid = 'paid';

  // Languages
  static const String en = 'en';
  static const String hi = 'hi';
  static const String ur = 'ur';

  /// Get default template for a given type, status, and language
  static String getDefaultTemplate(String type, String status, String language) {
    final key = '${type}_${status}_$language';
    return _templates[key] ?? _templates['${type}_${status}_en'] ?? '';
  }

  /// Get all templates for a given type and status across all languages
  static Map<String, String> getTemplatesForType(String type, String status) {
    final result = <String, String>{};
    for (final lang in [en, hi, ur]) {
      final key = '${type}_${status}_$lang';
      if (_templates.containsKey(key)) {
        result[lang] = _templates[key]!;
      }
    }
    return result;
  }

  static final Map<String, String> _templates = {
    // Receivable Reminder - Pending - English
    'receivable_reminder_pending_en': '''Hi {contactName},

Greetings! I hope you are doing well.

This is a friendly reminder that I am expecting a payment of *{amount}*{description}.

{dueDate}

Thank you!''',

    // Receivable Reminder - Pending - Hindi
    'receivable_reminder_pending_hi': '''नमस्ते {contactName},

नमस्कार! मुझे आशा है कि आप ठीक हैं।

यह एक मैत्रीपूर्ण अनुस्मारक है कि मैं *{amount}*{description} की भुगतान की अपेक्षा कर रहा हूं।

{dueDate}

धन्यवाद!''',

    // Receivable Reminder - Pending - Urdu
    'receivable_reminder_pending_ur': '''ہیلو {contactName},

سلام! مجھے امید ہے کہ آپ ٹھیک ہیں۔

یہ ایک دوستانہ یاد دہانی ہے کہ میں *{amount}*{description} کی ادائیگی کی توقع کر رہا ہوں۔

{dueDate}

شکریہ!''',

    // Receivable Reminder - Received - English
    'receivable_reminder_received_en': '''Hi {contactName},

Greetings!

The payment of *{amount}* on *{date}* has been received and recorded.

If you haven't updated this in your FlowPaisa records, please follow the link below to sync:
{link}

Thank you!''',

    // Receivable Reminder - Received - Hindi
    'receivable_reminder_received_hi': '''नमस्ते {contactName},

नमस्कार!

*{date}* को *{amount}* का भुगतान प्राप्त और दर्ज किया गया है।

यदि आपने इसे अपने FlowPaisa रिकॉर्ड में अपडेट नहीं किया है, तो कृपया सिंक करने के लिए नीचे दिए गए लिंक का अनुसरण करें:
{link}

धन्यवाद!''',

    // Receivable Reminder - Received - Urdu
    'receivable_reminder_received_ur': '''ہیلو {contactName},

سلام!

*{date}* کو *{amount}* کی ادائیگی موصول اور ریکارڈ کی گئی ہے۔

اگر آپ نے اسے اپنے FlowPaisa ریکارڈز میں اپڈیٹ نہیں کیا ہے، تو براہ کرم مطابقت پذیری کے لیے نیچے دیے گئے لنک پر عمل کریں:
{link}

شکریہ!''',

    // Payable Reminder - Pending - English
    'payable_reminder_pending_en': '''Hi {contactName},

I have recorded that I owe you *{amount}*{description}.

{dueDate}

I will settle this soon. Thanks for your patience!''',

    // Payable Reminder - Pending - Hindi
    'payable_reminder_pending_hi': '''नमस्ते {contactName},

मैंने दर्ज किया है कि मैं आपको *{amount}*{description} का बकाया है।

{dueDate}

मैं इसे जल्द ही निपटा दूंगा। आपके धैर्य के लिए धन्यवाद!''',

    // Payable Reminder - Pending - Urdu
    'payable_reminder_pending_ur': '''ہیلو {contactName},

میں نے ریکارڈ کیا ہے کہ میں آپ کا *{amount}*{description} کا مقروض ہوں۔

{dueDate}

میں اسے جلد حل کر دوں گا۔ آپ کے صبر کا شکریہ!''',

    // Payable Reminder - Paid - English
    'payable_reminder_paid_en': '''Hi {contactName},

Greetings!

The payment of *{amount}* on *{date}* has been completed and recorded.

If you haven't updated this payment in FlowPaisa, please follow the link below to sync your records:
{link}

Thank you!''',

    // Payable Reminder - Paid - Hindi
    'payable_reminder_paid_hi': '''नमस्ते {contactName},

नमस्कार!

*{date}* को *{amount}* का भुगतान पूरा और दर्ज किया गया है।

यदि आपने FlowPaisa में इस भुगतान को अपडेट नहीं किया है, तो कृपया अपने रिकॉर्ड को सिंक करने के लिए नीचे दिए गए लिंक का अनुसरण करें:
{link}

धन्यवाद!''',

    // Payable Reminder - Paid - Urdu
    'payable_reminder_paid_ur': '''ہیلو {contactName},

سلام!

*{date}* کو *{amount}* کی ادائیگی مکمل اور ریکارڈ کی گئی ہے۔

اگر آپ نے FlowPaisa میں اس ادائیگی کو اپڈیٹ نہیں کیا ہے، تو براہ کرم اپنے ریکارڈز کو مطابقت پذیری کے لیے نیچے دیے گئے لنک پر عمل کریں:
{link}

شکریہ!''',

    // Transaction Receipt - English
    'transaction_receipt_en': '''_Transaction Receipt_

I have recorded {type} of *{amount}* on *{date}*{description}.

{categoryName}

{contactName}

Generated with FlowPaisa 💰''',

    // Transaction Receipt - Hindi
    'transaction_receipt_hi': '''_लेन-देन रसीद_

मैंने *{date}* को *{amount}* का {type} दर्ज किया है{description}।

{categoryName}

{contactName}

FlowPaisa 💰 के साथ जेनरेट किया गया''',

    // Transaction Receipt - Urdu
    'transaction_receipt_ur': '''_لین دین رسید_

میں نے *{date}* کو *{amount}* کا {type} ریکارڈ کیا ہے{description}۔

{categoryName}

{contactName}

FlowPaisa 💰 کے ساتھ تیار کیا گیا''',

    // Transaction Share - PAID_FOR - English
    'transaction_share_paid_for_en': '''💰 {type} Recorded

I have recorded that I paid on your behalf *{amount}* on *{date}*{description}.

{categoryName}

View this transaction in FlowPaisa:
{link}

Manage your finances better with FlowPaisa! 💰''',

    // Transaction Share - PAID_FOR - Hindi
    'transaction_share_paid_for_hi': '''💰 {type} दर्ज किया गया

मैंने दर्ज किया है कि मैंने आपकी ओर से *{date}* को *{amount}* का भुगतान किया{description}।

{categoryName}

FlowPaisa में इस लेन-देन को देखें:
{link}

FlowPaisa के साथ अपने वित्त को बेहतर तरीके से प्रबंधित करें! 💰''',

    // Transaction Share - PAID_FOR - Urdu
    'transaction_share_paid_for_ur': '''💰 {type} ریکارڈ کیا گیا

میں نے ریکارڈ کیا ہے کہ میں نے آپ کی طرف سے *{date}* کو *{amount}* ادا کیا{description}۔

{categoryName}

FlowPaisa میں اس لین دین کو دیکھیں:
{link}

FlowPaisa کے ساتھ اپنے مالیات کو بہتر طریقے سے منظم کریں! 💰''',

    // Transaction Share - PAID_BY - English
    'transaction_share_paid_by_en': '''💰 {type} Recorded

I have recorded that you paid for me *{amount}* on *{date}*{description}.

{categoryName}

View this transaction in FlowPaisa:
{link}

Manage your finances better with FlowPaisa! 💰''',

    // Transaction Share - PAID_BY - Hindi
    'transaction_share_paid_by_hi': '''💰 {type} दर्ज किया गया

मैंने दर्ज किया है कि आपने मेरे लिए *{date}* को *{amount}* का भुगतान किया{description}।

{categoryName}

FlowPaisa में इस लेन-देन को देखें:
{link}

FlowPaisa के साथ अपने वित्त को बेहतर तरीके से प्रबंधित करें! 💰''',

    // Transaction Share - PAID_BY - Urdu
    'transaction_share_paid_by_ur': '''💰 {type} ریکارڈ کیا گیا

میں نے ریکارڈ کیا ہے کہ آپ نے میرے لیے *{date}* کو *{amount}* ادا کیا{description}۔

{categoryName}

FlowPaisa میں اس لین دین کو دیکھیں:
{link}

FlowPaisa کے ساتھ اپنے مالیات کو بہتر طریقے سے منظم کریں! 💰''',

    // Transaction Share - WILL_RECEIVE - English
    'transaction_share_will_receive_en': '''💰 {type} Recorded

I have recorded that I am expecting a payment of *{amount}* on *{date}*{description}.

{categoryName}

View this transaction in FlowPaisa:
{link}

Manage your finances better with FlowPaisa! 💰''',

    // Transaction Share - WILL_RECEIVE - Hindi
    'transaction_share_will_receive_hi': '''💰 {type} दर्ज किया गया

मैंने दर्ज किया है कि मैं *{date}* को *{amount}* के भुगतान की अपेक्षा कर रहा हूं{description}।

{categoryName}

FlowPaisa में इस लेन-देन को देखें:
{link}

FlowPaisa के साथ अपने वित्त को बेहतर तरीके से प्रबंधित करें! 💰''',

    // Transaction Share - WILL_RECEIVE - Urdu
    'transaction_share_will_receive_ur': '''💰 {type} ریکارڈ کیا گیا

میں نے ریکارڈ کیا ہے کہ میں *{date}* کو *{amount}* کی ادائیگی کی توقع کر رہا ہوں{description}۔

{categoryName}

FlowPaisa میں اس لین دین کو دیکھیں:
{link}

FlowPaisa کے ساتھ اپنے مالیات کو بہتر طریقے سے منظم کریں! 💰''',

    // Transaction Share - RECEIVED_FROM - English
    'transaction_share_received_from_en': '''💰 {type} Recorded

I have recorded that I received *{amount}* from you on *{date}*{description}.

{categoryName}

View this transaction in FlowPaisa:
{link}

Manage your finances better with FlowPaisa! 💰''',

    // Transaction Share - RECEIVED_FROM - Hindi
    'transaction_share_received_from_hi': '''💰 {type} दर्ज किया गया

मैंने दर्ज किया है कि मैंने आपसे *{date}* को *{amount}* प्राप्त किया{description}।

{categoryName}

FlowPaisa में इस लेन-देन को देखें:
{link}

FlowPaisa के साथ अपने वित्त को बेहतर तरीके से प्रबंधित करें! 💰''',

    // Transaction Share - RECEIVED_FROM - Urdu
    'transaction_share_received_from_ur': '''💰 {type} ریکارڈ کیا گیا

میں نے ریکارڈ کیا ہے کہ میں نے آپ سے *{date}* کو *{amount}* وصول کیا{description}۔

{categoryName}

FlowPaisa میں اس لین دین کو دیکھیں:
{link}

FlowPaisa کے ساتھ اپنے مالیات کو بہتر طریقے سے منظم کریں! 💰''',

    // Transaction Share - Generic - English
    'transaction_share_generic_en': '''💰 {type} Recorded

I have recorded a transaction of *{amount}* on *{date}*{description}.

{categoryName}

View this transaction in FlowPaisa:
{link}

Manage your finances better with FlowPaisa! 💰''',

    // Transaction Share - Generic - Hindi
    'transaction_share_generic_hi': '''💰 {type} दर्ज किया गया

मैंने *{date}* को *{amount}* का लेन-देन दर्ज किया है{description}।

{categoryName}

FlowPaisa में इस लेन-देन को देखें:
{link}

FlowPaisa के साथ अपने वित्त को बेहतर तरीके से प्रबंधित करें! 💰''',

    // Transaction Share - Generic - Urdu
    'transaction_share_generic_ur': '''💰 {type} ریکارڈ کیا گیا

میں نے *{date}* کو *{amount}* کا لین دین ریکارڈ کیا ہے{description}۔

{categoryName}

FlowPaisa میں اس لین دین کو دیکھیں:
{link}

FlowPaisa کے ساتھ اپنے مالیات کو بہتر طریقے سے منظم کریں! 💰''',

    // Receivable Share - Pending - English
    'receivable_share_pending_en': '''📝 Payment Request

Hi, I have sent a request for *{amount}*{description}.

{dueDate}

You can view the details and record this in FlowPaisa:
{link}

Track your finances with FlowPaisa! 💰''',

    // Receivable Share - Pending - Hindi
    'receivable_share_pending_hi': '''📝 भुगतान अनुरोध

नमस्ते, मैंने *{amount}*{description} के लिए एक अनुरोध भेजा है।

{dueDate}

आप FlowPaisa में विवरण देख सकते हैं और इसे रिकॉर्ड कर सकते हैं:
{link}

FlowPaisa के साथ अपने वित्त को ट्रैक करें! 💰''',

    // Receivable Share - Pending - Urdu
    'receivable_share_pending_ur': '''📝 ادائیگی کی درخواست

ہیلو، میں نے *{amount}*{description} کے لیے ایک درخواست بھیجی ہے۔

{dueDate}

آپ FlowPaisa میں تفصیلات دیکھ سکتے ہیں اور اسے ریکارڈ کر سکتے ہیں:
{link}

FlowPaisa کے ساتھ اپنے مالیات کو ٹریک کریں! 💰''',

    // Receivable Share - Received - English
    'receivable_share_received_en': '''Hi {contactName},

Greetings!

The payment of *{amount}* on *{date}* has been received and recorded.

If you haven't updated this in your FlowPaisa records, please follow the link below to sync:
{link}

Thank you!''',

    // Receivable Share - Received - Hindi
    'receivable_share_received_hi': '''नमस्ते {contactName},

नमस्कार!

*{date}* को *{amount}* का भुगतान प्राप्त और दर्ज किया गया है।

यदि आपने इसे अपने FlowPaisa रिकॉर्ड में अपडेट नहीं किया है, तो कृपया सिंक करने के लिए नीचे दिए गए लिंक का अनुसरण करें:
{link}

धन्यवाद!''',

    // Receivable Share - Received - Urdu
    'receivable_share_received_ur': '''ہیلو {contactName},

سلام!

*{date}* کو *{amount}* کی ادائیگی موصول اور ریکارڈ کی گئی ہے۔

اگر آپ نے اسے اپنے FlowPaisa ریکارڈز میں اپڈیٹ نہیں کیا ہے، تو براہ کرم مطابقت پذیری کے لیے نیچے دیے گئے لنک پر عمل کریں:
{link}

شکریہ!''',

    // Payable Share - Pending - English
    'payable_share_pending_en': '''Hi {contactName},

This is a friendly reminder that I have recorded that I owe you *{amount}* from *{date}*{description}.

{dueDate}

You can view and import this in FlowPaisa:
{link}

Thank you!''',

    // Payable Share - Pending - Hindi
    'payable_share_pending_hi': '''नमस्ते {contactName},

यह एक मैत्रीपूर्ण अनुस्मारक है कि मैंने दर्ज किया है कि मैं *{date}* से आपको *{amount}* का बकाया हूं{description}।

{dueDate}

आप FlowPaisa में इसे देख और आयात कर सकते हैं:
{link}

धन्यवाद!''',

    // Payable Share - Pending - Urdu
    'payable_share_pending_ur': '''ہیلو {contactName},

یہ ایک دوستانہ یاد دہانی ہے کہ میں نے ریکارڈ کیا ہے کہ میں *{date}* سے آپ کا *{amount}* کا مقروض ہوں{description}۔

{dueDate}

آپ FlowPaisa میں اسے دیکھ اور درآمد کر سکتے ہیں:
{link}

شکریہ!''',

    // Payable Share - Paid - English
    'payable_share_paid_en': '''📋 Payment Acknowledgment

I wanted to let you know that I owe you *{amount}*{description}.

{dueDate}

View details in FlowPaisa:
{link}

I will settle this soon. Thanks for your patience!
Manage your finances with FlowPaisa! 💰''',

    // Payable Share - Paid - Hindi
    'payable_share_paid_hi': '''📋 भुगतान स्वीकृति

मैं आपको बताना चाहता था कि मैं आपका *{amount}*{description} का बकाया हूं।

{dueDate}

FlowPaisa में विवरण देखें:
{link}

मैं इसे जल्द ही निपटा दूंगा। आपके धैर्य के लिए धन्यवाद!
FlowPaisa के साथ अपने वित्त को प्रबंधित करें! 💰''',

    // Payable Share - Paid - Urdu
    'payable_share_paid_ur': '''📋 ادائیگی کی تصدیق

میں آپ کو بتانا چاہتا تھا کہ میں آپ کا *{amount}*{description} کا مقروض ہوں۔

{dueDate}

FlowPaisa میں تفصیلات دیکھیں:
{link}

میں اسے جلد حل کر دوں گا۔ آپ کے صبر کا شکریہ!
FlowPaisa کے ساتھ اپنے مالیات کو منظم کریں! 💰''',
  };
}
