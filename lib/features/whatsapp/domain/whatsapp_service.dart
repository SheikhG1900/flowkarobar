import 'package:url_launcher/url_launcher.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/features/whatsapp/domain/models/shared_data_models.dart';

class WhatsAppService {
  final DeepLinkService _deepLinkService = DeepLinkService();

  /// Send a message via WhatsApp to a phone number
  ///
  /// [phoneNumber] should be in international format without + (e.g., "919876543210")
  /// [message] is the text to send
  Future<bool> sendMessage(String phoneNumber, String message) async {
    try {
      // Clean phone number (remove spaces, dashes, etc.)
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // WhatsApp URL scheme
      final whatsappUrl = Uri.parse(
          'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        return true;
      } else {
        throw Exception('WhatsApp is not installed or phone number is invalid');
      }
    } catch (e) {
      throw Exception('Failed to open WhatsApp: $e');
    }
  }

  /// Format a receivable reminder message
  String formatReceivableReminder({
    required String contactName,
    required double amount,
    required String description,
    DateTime? dueDate,
    String currencySymbol = '₹',
    int decimalPlaces = 2,
    String? dateFormat,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Hi $contactName,');
    buffer.writeln();
    buffer.writeln('Greetings! I hope you are doing well.');
    buffer.writeln();
    buffer.write(
        'This is a friendly reminder that I am expecting a payment of *${AmountFormatter.formatWithCurrency(amount, currencySymbol, decimalPlaces)}*');

    if (description.isNotEmpty) {
      buffer.write(' for _${description}_');
    }
    buffer.writeln('.');

    if (dueDate != null) {
      buffer.writeln(
          'Expected by: *${AppDateFormatter.formatDate(dueDate, pattern: dateFormat)}*.');
    }

    buffer.writeln();
    buffer.writeln('Thank you!');
    return buffer.toString();
  }

  /// Format a payable reminder message
  String formatPayableReminder({
    required String contactName,
    required double amount,
    required String description,
    DateTime? dueDate,
    String currencySymbol = '₹',
    int decimalPlaces = 2,
    String? dateFormat,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Hi $contactName,');
    buffer.writeln();
    buffer.write(
        'I have recorded that I owe you *${AmountFormatter.formatWithCurrency(amount, currencySymbol, decimalPlaces)}*');

    if (description.isNotEmpty) {
      buffer.write(' for _${description}_');
    }
    buffer.writeln('.');

    if (dueDate != null) {
      buffer.writeln(
          'I will settle this by *${AppDateFormatter.formatDate(dueDate, pattern: dateFormat)}*.');
    } else {
      buffer.writeln('I will settle this soon. Thanks for your patience!');
    }

    buffer.writeln();
    return buffer.toString();
  }

  /// Format a transaction receipt message
  String formatTransactionReceipt({
    required String type,
    required double amount,
    required String description,
    required DateTime date,
    String? categoryName,
    String? contactName,
    String currencySymbol = '₹',
    int decimalPlaces = 2,
    String? dateFormat,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('_Transaction Receipt_');
    buffer.writeln();

    final formattedAmount = AmountFormatter.formatWithCurrency(
        amount, currencySymbol, decimalPlaces);
    final formattedDate =
        AppDateFormatter.formatDate(date, pattern: dateFormat);

    if (type.toUpperCase() == 'INCOME') {
      buffer.write('I have recorded an Income of *$formattedAmount*');
    } else {
      buffer.write('I have recorded an Expense of *$formattedAmount*');
    }

    buffer.write(' on *$formattedDate*');

    if (description.isNotEmpty) {
      buffer.write(' for _${description}_');
    }
    buffer.writeln('.');

    if (categoryName != null) {
      buffer.writeln('This was categorized under *$categoryName*.');
    }

    if (contactName != null) {
      buffer.writeln('This transaction is associated with *$contactName*.');
    }

    buffer.writeln();
    buffer.writeln('Generated with FlowPaisa 💰');
    return buffer.toString();
  }

  /// Share a transaction with encoded deep link
  Future<bool> shareTransactionWithLink({
    required TransactionShareData transaction,
    String? contactPhone,
    required String currencySymbol,
    int decimalPlaces = 2,
    String? dateFormat,
  }) async {
    try {
      // Generate deep link
      final deepLink = _deepLinkService.generateTransactionLink(transaction);

      // Format message
      final buffer = StringBuffer();
      final isIncome = transaction.transactionType.toUpperCase() == "INCOME";
      final formattedAmount = AmountFormatter.formatWithCurrency(
          transaction.amount, currencySymbol, decimalPlaces);
      final formattedDate =
          AppDateFormatter.formatDate(transaction.date, pattern: dateFormat);

      buffer.writeln(isIncome ? '💰 Income Recorded' : '💸 Expense Recorded');
      buffer.writeln();

      if (transaction.relationship == 'PAID_FOR') {
        buffer.write(
            'I have recorded that I paid on your behalf *$formattedAmount*');
      } else if (transaction.relationship == 'PAID_BY') {
        buffer.write('I have recorded that you paid for me *$formattedAmount*');
      } else if (transaction.relationship == 'WILL_RECEIVE') {
        buffer.write(
            'I have recorded that I am expecting a payment of *$formattedAmount*');
      } else if (transaction.relationship == 'RECEIVED_FROM') {
        buffer.write(
            'I have recorded that I received *$formattedAmount* from you');
      } else {
        buffer.write(
            'I have recorded a ${isIncome ? 'receipt' : 'payment'} of *$formattedAmount*');
      }

      buffer.write(' on *$formattedDate*');

      if (transaction.description != null &&
          transaction.description!.isNotEmpty) {
        buffer.write(' for _${transaction.description}_');
      }
      buffer.writeln('.');

      if (transaction.categoryName != null) {
        buffer.writeln(
            'This was recorded under the *${transaction.categoryName}* category.');
      }

      buffer.writeln();
      buffer.writeln('View this transaction in FlowPaisa:');
      buffer.writeln(deepLink);
      buffer.writeln();
      buffer.writeln('Manage your finances better with FlowPaisa! 💰');

      final message = buffer.toString();

      if (contactPhone != null && contactPhone.isNotEmpty) {
        return await sendMessage(contactPhone, message);
      } else {
        // Share to WhatsApp without specific contact
        final whatsappUrl =
            Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
        if (await canLaunchUrl(whatsappUrl)) {
          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          return true;
        }
        return false;
      }
    } catch (e) {
      throw Exception('Failed to share transaction: $e');
    }
  }

  /// Share a receivable (payment request) with encoded deep link
  Future<bool> shareReceivableWithLink({
    required ReceivableShareData receivable,
    String? contactPhone,
    required String currencySymbol,
    int decimalPlaces = 2,
    String? dateFormat,
  }) async {
    try {
      // Generate deep link
      final deepLink = _deepLinkService.generateReceivableLink(receivable);

      // Format message
      final buffer = StringBuffer();
      final formattedAmount = AmountFormatter.formatWithCurrency(
          receivable.amount, currencySymbol, decimalPlaces);

      buffer.writeln('📝 Payment Request');
      buffer.writeln();
      buffer.write('Hi, I have sent a request for *$formattedAmount*');

      if (receivable.description != null &&
          receivable.description!.isNotEmpty) {
        buffer.write(' for _${receivable.description}_');
      }
      buffer.writeln('.');

      if (receivable.dueDate != null) {
        buffer.writeln(
            'Due Date: *${AppDateFormatter.formatDate(receivable.dueDate!, pattern: dateFormat)}*');
      }

      buffer.writeln();
      buffer.writeln('You can view the details and record this in FlowPaisa:');
      buffer.writeln(deepLink);
      buffer.writeln();
      buffer.writeln('Track your finances with FlowPaisa! 💰');

      final message = buffer.toString();

      if (contactPhone != null && contactPhone.isNotEmpty) {
        return await sendMessage(contactPhone, message);
      } else {
        final whatsappUrl =
            Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
        if (await canLaunchUrl(whatsappUrl)) {
          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          return true;
        }
        return false;
      }
    } catch (e) {
      throw Exception('Failed to share receivable: $e');
    }
  }

  /// Share a payable (payment acknowledgment) with encoded deep link
  Future<bool> sharePayableWithLink({
    required PayableShareData payable,
    String? contactPhone,
    required String currencySymbol,
    int decimalPlaces = 2,
    String? dateFormat,
  }) async {
    try {
      // Generate deep link
      final deepLink = _deepLinkService.generatePayableLink(payable);

      // Format message
      final buffer = StringBuffer();
      final formattedAmount = AmountFormatter.formatWithCurrency(
          payable.amount, currencySymbol, decimalPlaces);

      buffer.writeln('📋 Payment Acknowledgment');
      buffer.writeln();
      buffer
          .write('I wanted to let you know that I owe you *$formattedAmount*');

      if (payable.description != null && payable.description!.isNotEmpty) {
        buffer.write(' for _${payable.description}_');
      }
      buffer.writeln('.');

      if (payable.dueDate != null) {
        buffer.writeln(
            'Planned payment date: *${AppDateFormatter.formatDate(payable.dueDate!, pattern: dateFormat)}*');
      }

      buffer.writeln();
      buffer.writeln('View details in FlowPaisa:');
      buffer.writeln(deepLink);
      buffer.writeln();
      buffer.writeln('I will settle this soon. Thanks for your patience!');
      buffer.writeln('Manage your finances with FlowPaisa! 💰');

      final message = buffer.toString();

      if (contactPhone != null && contactPhone.isNotEmpty) {
        return await sendMessage(contactPhone, message);
      } else {
        final whatsappUrl =
            Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
        if (await canLaunchUrl(whatsappUrl)) {
          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          return true;
        }
        return false;
      }
    } catch (e) {
      throw Exception('Failed to share payable: $e');
    }
  }
}
