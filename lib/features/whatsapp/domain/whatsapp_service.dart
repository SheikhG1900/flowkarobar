import 'package:url_launcher/url_launcher.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/features/whatsapp/domain/models/shared_data_models.dart';
import 'package:flowpaisa/features/messages/domain/message_template_service.dart';
import 'package:flowpaisa/features/messages/data/default_templates.dart';

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
        // Add a small delay to allow the OS to process the activity launch
        await Future.delayed(const Duration(milliseconds: 800));
        return true;
      } else {
        throw Exception('WhatsApp is not installed or phone number is invalid');
      }
    } catch (e) {
      throw Exception('Failed to open WhatsApp: $e');
    }
  }

  /// Format a receivable reminder message
  Future<String> formatReceivableReminder({
    required String contactName,
    required double amount,
    required String description,
    DateTime? dueDate,
    String currencySymbol = '₹',
    int decimalPlaces = 2,
    String? dateFormat,
    MessageTemplateService? templateService,
    String language = 'en',
  }) async {
    final formattedAmount = AmountFormatter.formatWithCurrency(
        amount, currencySymbol, decimalPlaces);
    final dueDateText = dueDate != null
        ? AppDateFormatter.formatDate(dueDate, pattern: dateFormat)
        : null;

    // Use template service if provided
    if (templateService != null) {
      final status = DefaultTemplates.pending;
      final template = await templateService.getTemplate(
        DefaultTemplates.receivableReminder,
        status,
        language,
      );
      final variables = templateService.buildReceivableReminderVariables(
        contactName: contactName,
        amount: formattedAmount,
        description: description,
        dueDate: dueDateText,
      );
      return templateService.renderTemplate(template, variables);
    }

    // Fallback to old hardcoded logic
    final buffer = StringBuffer();
    buffer.writeln('Hi $contactName,');
    buffer.writeln();
    buffer.writeln('Greetings! I hope you are doing well.');
    buffer.writeln();
    buffer.write(
        'This is a friendly reminder that I am expecting a payment of *$formattedAmount*');

    if (description.isNotEmpty) {
      buffer.write(' for _${description}_');
    }
    buffer.writeln('.');

    if (dueDate != null) {
      buffer.writeln('Expected by: *$dueDateText*.');
    }

    buffer.writeln();
    buffer.writeln('Thank you!');
    return buffer.toString();
  }

  /// Format a payable reminder message
  Future<String> formatPayableReminder({
    required String contactName,
    required double amount,
    required String description,
    DateTime? dueDate,
    String currencySymbol = '₹',
    int decimalPlaces = 2,
    String? dateFormat,
    MessageTemplateService? templateService,
    String language = 'en',
  }) async {
    final formattedAmount = AmountFormatter.formatWithCurrency(
        amount, currencySymbol, decimalPlaces);
    final dueDateText = dueDate != null
        ? AppDateFormatter.formatDate(dueDate, pattern: dateFormat)
        : null;

    // Use template service if provided
    if (templateService != null) {
      final status = DefaultTemplates.pending;
      final template = await templateService.getTemplate(
        DefaultTemplates.payableReminder,
        status,
        language,
      );
      final variables = templateService.buildPayableReminderVariables(
        contactName: contactName,
        amount: formattedAmount,
        description: description,
        dueDate: dueDateText,
      );
      return templateService.renderTemplate(template, variables);
    }

    // Fallback to old hardcoded logic
    final buffer = StringBuffer();
    buffer.writeln('Hi $contactName,');
    buffer.writeln();
    buffer.write('I have recorded that I owe you *$formattedAmount*');

    if (description.isNotEmpty) {
      buffer.write(' for _${description}_');
    }
    buffer.writeln('.');

    if (dueDate != null) {
      buffer.writeln('I will settle this by *$dueDateText*.');
    } else {
      buffer.writeln('I will settle this soon. Thanks for your patience!');
    }

    buffer.writeln();
    return buffer.toString();
  }

  /// Format a transaction receipt message
  Future<String> formatTransactionReceipt({
    required String type,
    required double amount,
    required String description,
    required DateTime date,
    String? categoryName,
    String? contactName,
    String currencySymbol = '₹',
    int decimalPlaces = 2,
    String? dateFormat,
    MessageTemplateService? templateService,
    String language = 'en',
  }) async {
    final formattedAmount = AmountFormatter.formatWithCurrency(
        amount, currencySymbol, decimalPlaces);
    final formattedDate =
        AppDateFormatter.formatDate(date, pattern: dateFormat);

    // Use template service if provided
    if (templateService != null) {
      final template = await templateService.getTemplate(
        DefaultTemplates.transactionReceipt,
        '',
        language,
      );
      final variables = templateService.buildTransactionReceiptVariables(
        type: type,
        amount: formattedAmount,
        date: formattedDate,
        description: description,
        categoryName: categoryName,
        contactName: contactName,
      );
      return templateService.renderTemplate(template, variables);
    }

    // Fallback to old hardcoded logic
    final buffer = StringBuffer();
    buffer.writeln('_Transaction Receipt_');
    buffer.writeln();

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
    buffer.writeln('Generated with Flowpaisa 💰');
    return buffer.toString();
  }

  /// Share a transaction with encoded deep link
  Future<bool> shareTransactionWithLink({
    required TransactionShareData transaction,
    String? contactPhone,
    required String currencySymbol,
    int decimalPlaces = 2,
    String? dateFormat,
    MessageTemplateService? templateService,
    String language = 'en',
  }) async {
    try {
      // Generate deep link
      final deepLink = _deepLinkService.generateTransactionLink(transaction);

      // Format message
      final isIncome = transaction.transactionType.toUpperCase() == "INCOME";
      final formattedAmount = AmountFormatter.formatWithCurrency(
          transaction.amount, currencySymbol, decimalPlaces);
      final formattedDate =
          AppDateFormatter.formatDate(transaction.date, pattern: dateFormat);

      String message;
      if (templateService != null) {
        // Determine template type based on relationship
        String templateType = DefaultTemplates.transactionShare;
        String relationshipKey = 'generic';

        if (transaction.relationship == 'PAID_FOR') {
          relationshipKey = 'paid_for';
        } else if (transaction.relationship == 'PAID_BY') {
          relationshipKey = 'paid_by';
        } else if (transaction.relationship == 'WILL_RECEIVE') {
          relationshipKey = 'will_receive';
        } else if (transaction.relationship == 'RECEIVED_FROM') {
          relationshipKey = 'received_from';
        }

        final template = await templateService.getTemplate(
          templateType,
          relationshipKey,
          language,
        );
        final variables = templateService.buildTransactionShareVariables(
          type: isIncome ? 'Income' : 'Expense',
          amount: formattedAmount,
          date: formattedDate,
          description: transaction.description,
          categoryName: transaction.categoryName,
          link: deepLink,
          relationship: transaction.relationship,
        );
        message = templateService.renderTemplate(template, variables);
      } else {
        // Fallback to old hardcoded logic
        final buffer = StringBuffer();
        buffer.writeln(isIncome ? '💰 Income Recorded' : '💸 Expense Recorded');
        buffer.writeln();

        if (transaction.relationship == 'PAID_FOR') {
          buffer.write(
              'I have recorded that I paid on your behalf *$formattedAmount*');
        } else if (transaction.relationship == 'PAID_BY') {
          buffer
              .write('I have recorded that you paid for me *$formattedAmount*');
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
        buffer.writeln('View this transaction in Flowpaisa:');
        buffer.writeln(deepLink);
        buffer.writeln();
        buffer.writeln('Manage your finances better with Flowpaisa! 💰');
        message = buffer.toString();
      }

      if (contactPhone != null && contactPhone.isNotEmpty) {
        return await sendMessage(contactPhone, message);
      } else {
        // Share to WhatsApp without specific contact
        final whatsappUrl =
            Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
        if (await canLaunchUrl(whatsappUrl)) {
          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          // Add a small delay to allow the OS to process the activity launch
          await Future.delayed(const Duration(milliseconds: 800));
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
    MessageTemplateService? templateService,
    String language = 'en',
  }) async {
    try {
      // Generate deep link
      final deepLink = _deepLinkService.generateReceivableLink(receivable);

      // Format message
      final formattedAmount = AmountFormatter.formatWithCurrency(
          receivable.amount, currencySymbol, decimalPlaces);
      final dueDateText = receivable.dueDate != null
          ? AppDateFormatter.formatDate(receivable.dueDate!,
              pattern: dateFormat)
          : null;

      String message;
      if (templateService != null) {
        final status = receivable.status?.toLowerCase() == 'received'
            ? DefaultTemplates.received
            : DefaultTemplates.pending;
        final template = await templateService.getTemplate(
          DefaultTemplates.receivableShare,
          status,
          language,
        );
        final variables = templateService.buildReceivableShareVariables(
          amount: formattedAmount,
          description: receivable.description,
          dueDate: dueDateText,
          link: deepLink,
        );
        message = templateService.renderTemplate(template, variables);
      } else {
        // Fallback to old hardcoded logic
        final buffer = StringBuffer();
        buffer.writeln('📝 Payment Request');
        buffer.writeln();
        buffer.write('Hi, I have sent a request for *$formattedAmount*');

        if (receivable.description != null &&
            receivable.description!.isNotEmpty) {
          buffer.write(' for _${receivable.description}_');
        }
        buffer.writeln('.');

        if (receivable.dueDate != null) {
          buffer.writeln('Due Date: *$dueDateText*');
        }

        buffer.writeln();
        buffer
            .writeln('You can view the details and record this in Flowpaisa:');
        buffer.writeln(deepLink);
        buffer.writeln();
        buffer.writeln('Track your finances with Flowpaisa! 💰');
        message = buffer.toString();
      }

      if (contactPhone != null && contactPhone.isNotEmpty) {
        return await sendMessage(contactPhone, message);
      } else {
        final whatsappUrl =
            Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
        if (await canLaunchUrl(whatsappUrl)) {
          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          // Add a small delay to allow the OS to process the activity launch
          await Future.delayed(const Duration(milliseconds: 800));
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
    MessageTemplateService? templateService,
    String language = 'en',
  }) async {
    try {
      // Generate deep link
      final deepLink = _deepLinkService.generatePayableLink(payable);

      // Format message
      final formattedAmount = AmountFormatter.formatWithCurrency(
          payable.amount, currencySymbol, decimalPlaces);
      final dueDateText = payable.dueDate != null
          ? AppDateFormatter.formatDate(payable.dueDate!, pattern: dateFormat)
          : null;

      String message;
      if (templateService != null) {
        final status = payable.status?.toLowerCase() == 'paid'
            ? DefaultTemplates.paid
            : DefaultTemplates.pending;
        final template = await templateService.getTemplate(
          DefaultTemplates.payableShare,
          status,
          language,
        );
        final variables = templateService.buildPayableShareVariables(
          amount: formattedAmount,
          description: payable.description,
          dueDate: dueDateText,
          link: deepLink,
        );
        message = templateService.renderTemplate(template, variables);
      } else {
        // Fallback to old hardcoded logic
        final buffer = StringBuffer();
        buffer.writeln('📋 Payment Acknowledgment');
        buffer.writeln();
        buffer.write(
            'I wanted to let you know that I owe you *$formattedAmount*');

        if (payable.description != null && payable.description!.isNotEmpty) {
          buffer.write(' for _${payable.description}_');
        }
        buffer.writeln('.');

        if (payable.dueDate != null) {
          buffer.writeln('Planned payment date: *$dueDateText*');
        }

        buffer.writeln();
        buffer.writeln('View details in Flowpaisa:');
        buffer.writeln(deepLink);
        buffer.writeln();
        buffer.writeln('I will settle this soon. Thanks for your patience!');
        buffer.writeln('Manage your finances with Flowpaisa! 💰');
        message = buffer.toString();
      }

      if (contactPhone != null && contactPhone.isNotEmpty) {
        return await sendMessage(contactPhone, message);
      } else {
        final whatsappUrl =
            Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
        if (await canLaunchUrl(whatsappUrl)) {
          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          // Add a small delay to allow the OS to process the activity launch
          await Future.delayed(const Duration(milliseconds: 800));
          return true;
        }
        return false;
      }
    } catch (e) {
      throw Exception('Failed to share payable: $e');
    }
  }
}
