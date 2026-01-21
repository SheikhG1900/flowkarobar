import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/amount_formatter.dart';
import '../utils/date_formatter.dart';
import '../../features/whatsapp/domain/deep_link_service.dart';
import '../../features/whatsapp/domain/models/shared_data_models.dart';
import '../../features/whatsapp/presentation/providers/whatsapp_provider.dart';
import '../../features/transactions/presentation/providers/transaction_service_provider.dart';
import '../../shared/providers/currency_provider.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../../features/messages/presentation/providers/message_template_provider.dart';
import '../../features/messages/data/default_templates.dart';

class ShareHelper {
  static Future<void> sharePayable(
    BuildContext context,
    WidgetRef ref,
    dynamic payable,
    dynamic contact, {
    dynamic currencyOverride,
    dynamic userProfileOverride,
    dynamic transactionServiceOverride,
    dynamic whatsAppServiceOverride,
  }) async {
    final currency = currencyOverride ?? ref.read(currentCurrencyProvider).value!;
    final userProfile = userProfileOverride ?? ref.read(userProfileProvider);
    final whatsAppService = whatsAppServiceOverride ?? ref.read(whatsAppServiceProvider);
    final transactionService = transactionServiceOverride ?? ref.read(transactionServiceProvider);

    if (contact != null && contact.phone != null && contact.phone.isNotEmpty) {
      await _sendWhatsAppPayable(
        context,
        ref,
        contact,
        payable,
        currency: currency,
        userProfile: userProfile,
        whatsAppService: whatsAppService,
        transactionService: transactionService,
      );
    } else {
      await _systemSharePayable(
        context,
        ref,
        payable,
        contact,
        currency: currency,
        userProfile: userProfile,
        transactionService: transactionService,
      );
    }
  }

  static Future<void> shareReceivable(
    BuildContext context,
    WidgetRef ref,
    dynamic receivable,
    dynamic contact, {
    dynamic currencyOverride,
    dynamic userProfileOverride,
    dynamic transactionServiceOverride,
    dynamic whatsAppServiceOverride,
  }) async {
    final currency = currencyOverride ?? ref.read(currentCurrencyProvider).value!;
    final userProfile = userProfileOverride ?? ref.read(userProfileProvider);
    final whatsAppService = whatsAppServiceOverride ?? ref.read(whatsAppServiceProvider);
    final transactionService = transactionServiceOverride ?? ref.read(transactionServiceProvider);

    if (contact != null && contact.phone != null && contact.phone.isNotEmpty) {
      await _sendWhatsAppReceivable(
        context,
        ref,
        contact,
        receivable,
        currency: currency,
        userProfile: userProfile,
        whatsAppService: whatsAppService,
        transactionService: transactionService,
      );
    } else {
      await _systemShareReceivable(
        context,
        ref,
        receivable,
        contact,
        currency: currency,
        userProfile: userProfile,
        transactionService: transactionService,
      );
    }
  }

  static Future<void> shareTransaction(
    BuildContext context,
    WidgetRef ref,
    dynamic transaction,
    dynamic contact,
    dynamic category,
    bool isMarked, {
    dynamic currencyOverride,
    dynamic userProfileOverride,
    dynamic transactionServiceOverride,
    dynamic whatsAppServiceOverride,
  }) async {
    final currency = currencyOverride ?? ref.read(currentCurrencyProvider).value!;
    final userProfile = userProfileOverride ?? ref.read(userProfileProvider);
    final whatsAppService = whatsAppServiceOverride ?? ref.read(whatsAppServiceProvider);
    final transactionService = transactionServiceOverride ?? ref.read(transactionServiceProvider);

    if (contact != null && contact.phone != null && contact.phone.isNotEmpty) {
      await _sendWhatsAppTransaction(
        context,
        ref,
        contact,
        transaction,
        category,
        isMarked,
        currency: currency,
        userProfile: userProfile,
        whatsAppService: whatsAppService,
        transactionService: transactionService,
      );
    } else {
      await _systemShareTransaction(
        context,
        ref,
        transaction,
        contact,
        category,
        isMarked,
        currency: currency,
        userProfile: userProfile,
        transactionService: transactionService,
      );
    }
  }

  // --- Internal WhatsApp Helpers ---

  static Future<void> _sendWhatsAppPayable(
    BuildContext context,
    WidgetRef ref,
    dynamic contact,
    dynamic payable, {
    required dynamic currency,
    required dynamic userProfile,
    required dynamic whatsAppService,
    required dynamic transactionService,
  }) async {
    final deepLinkService = DeepLinkService();
    final isPaid = payable.status == 'PAID';
    final effectiveExternalId = await transactionService.ensureExternalLinkId(payableId: payable.id);

    final link = deepLinkService.generateReceivableLink(ReceivableShareData(
      amount: payable.amount,
      date: payable.date,
      description: payable.description,
      dueDate: payable.dueDate,
      senderName: userProfile.name ?? 'Someone',
      senderPhone: userProfile.phone ?? '',
      externalLinkId: effectiveExternalId,
      status: payable.status,
    ));

    // Get template service and language
    final templateService = ref.read(messageTemplateServiceProvider);
    final language = getCurrentLanguageCode(ref);

    String message;
    if (isPaid) {
      // Use template for paid status
      final template = await templateService.getTemplate(
        DefaultTemplates.payableReminder,
        DefaultTemplates.paid,
        language,
      );
      final variables = templateService.buildPayableReminderVariables(
        contactName: contact.name,
        amount: AmountFormatter.formatWithCurrency(payable.amount, currency.symbol, currency.decimalPlaces),
        description: payable.description,
        dueDate: payable.dueDate != null
            ? AppDateFormatter.formatDate(payable.dueDate, pattern: userProfile.dateFormat)
            : null,
        date: AppDateFormatter.formatDate(payable.date, pattern: userProfile.dateFormat),
      );
      variables['link'] = link;
      message = templateService.renderTemplate(template, variables);
    } else {
      // Use template for pending status
      final template = await templateService.getTemplate(
        DefaultTemplates.payableReminder,
        DefaultTemplates.pending,
        language,
      );
      final variables = templateService.buildPayableReminderVariables(
        contactName: contact.name,
        amount: AmountFormatter.formatWithCurrency(payable.amount, currency.symbol, currency.decimalPlaces),
        description: payable.description,
        dueDate: payable.dueDate != null
            ? AppDateFormatter.formatDate(payable.dueDate, pattern: userProfile.dateFormat)
            : null,
        date: AppDateFormatter.formatDate(payable.date, pattern: userProfile.dateFormat),
      );
      variables['link'] = link;
      message = templateService.renderTemplate(template, variables);
    }

    final cleanPhone = contact.phone.replaceAll(' ', '').replaceAll(RegExp(r'[^\d+]'), '');
    await whatsAppService.sendMessage(cleanPhone, message);
  }

  static Future<void> _sendWhatsAppReceivable(
    BuildContext context,
    WidgetRef ref,
    dynamic contact,
    dynamic receivable, {
    required dynamic currency,
    required dynamic userProfile,
    required dynamic whatsAppService,
    required dynamic transactionService,
  }) async {
    final deepLinkService = DeepLinkService();
    final isReceived = receivable.status == 'RECEIVED';
    final effectiveExternalId = await transactionService.ensureExternalLinkId(receivableId: receivable.id);

    final link = deepLinkService.generatePayableLink(PayableShareData(
      amount: receivable.amount,
      date: receivable.date,
      description: receivable.description,
      dueDate: receivable.dueDate,
      senderName: userProfile.name ?? 'Someone',
      senderPhone: userProfile.phone ?? '',
      externalLinkId: effectiveExternalId,
      status: receivable.status,
    ));

    // Get template service and language
    final templateService = ref.read(messageTemplateServiceProvider);
    final language = getCurrentLanguageCode(ref);

    String message;
    if (isReceived) {
      // Use template for received status
      final template = await templateService.getTemplate(
        DefaultTemplates.receivableReminder,
        DefaultTemplates.received,
        language,
      );
      final variables = templateService.buildReceivableReminderVariables(
        contactName: contact.name,
        amount: AmountFormatter.formatWithCurrency(receivable.amount, currency.symbol, currency.decimalPlaces),
        description: receivable.description,
        dueDate: receivable.dueDate != null
            ? AppDateFormatter.formatDate(receivable.dueDate, pattern: userProfile.dateFormat)
            : null,
      );
      variables['date'] = AppDateFormatter.formatDate(receivable.date, pattern: userProfile.dateFormat);
      variables['link'] = link;
      message = templateService.renderTemplate(template, variables);
    } else {
      // Use template for pending status
      final template = await templateService.getTemplate(
        DefaultTemplates.receivableReminder,
        DefaultTemplates.pending,
        language,
      );
      final variables = templateService.buildReceivableReminderVariables(
        contactName: contact.name,
        amount: AmountFormatter.formatWithCurrency(receivable.amount, currency.symbol, currency.decimalPlaces),
        description: receivable.description,
        dueDate: receivable.dueDate != null
            ? AppDateFormatter.formatDate(receivable.dueDate, pattern: userProfile.dateFormat)
            : null,
      );
      variables['date'] = AppDateFormatter.formatDate(receivable.date, pattern: userProfile.dateFormat);
      variables['link'] = link;
      message = templateService.renderTemplate(template, variables);
    }

    final cleanPhone = contact.phone.replaceAll(' ', '').replaceAll(RegExp(r'[^\d+]'), '');
    await whatsAppService.sendMessage(cleanPhone, message);
  }

  static Future<void> _sendWhatsAppTransaction(
    BuildContext context,
    WidgetRef ref,
    dynamic contact,
    dynamic transaction,
    dynamic category,
    bool isMarked, {
    required dynamic currency,
    required dynamic userProfile,
    required dynamic whatsAppService,
    required dynamic transactionService,
  }) async {
    final deepLinkService = DeepLinkService();
    final effectiveExternalId = await transactionService.ensureExternalLinkId(transactionId: transaction.id);

    String? status;
    if (isMarked) {
      if (transaction.paidRelationship == 'PAID_FOR' || transaction.paidRelationship == 'WILL_RECEIVE') {
        status = 'RECEIVED';
      } else if (transaction.paidRelationship == 'PAID_BY' || transaction.paidRelationship == 'RECEIVED_FROM') {
        status = 'PAID';
      }
    }

    final link = deepLinkService.generateReciprocalLink(
      senderName: userProfile.name ?? 'Someone',
      senderPhone: userProfile.phone ?? '',
      relationship: transaction.paidRelationship,
      amount: transaction.amount,
      date: transaction.date,
      description: transaction.description,
      categoryName: category?.name,
      categoryColor: category?.color,
      categoryIcon: category?.icon,
      externalLinkId: effectiveExternalId,
      status: status,
    );

    // Get template service and language
    final templateService = ref.read(messageTemplateServiceProvider);
    final language = getCurrentLanguageCode(ref);

    String message;
    final formattedAmount = AmountFormatter.formatWithCurrency(transaction.amount, currency.symbol, currency.decimalPlaces);
    final formattedDate = AppDateFormatter.formatDate(transaction.date, pattern: userProfile.dateFormat);
    final isIncome = transaction.type.toUpperCase() == 'INCOME';

    // Determine template relationship key
    String relationshipKey = 'generic';
    if (transaction.paidRelationship == 'PAID_FOR') {
      relationshipKey = 'paid_for';
    } else if (transaction.paidRelationship == 'PAID_BY') {
      relationshipKey = 'paid_by';
    } else if (transaction.paidRelationship == 'WILL_RECEIVE') {
      relationshipKey = 'will_receive';
    } else if (transaction.paidRelationship == 'RECEIVED_FROM') {
      relationshipKey = 'received_from';
    }

    // Use template
    final template = await templateService.getTemplate(
      DefaultTemplates.transactionShare,
      relationshipKey,
      language,
    );
    final variables = templateService.buildTransactionShareVariables(
      type: isIncome ? 'Income' : 'Expense',
      amount: formattedAmount,
      date: formattedDate,
      description: transaction.description,
      categoryName: category?.name,
      link: link,
      relationship: transaction.paidRelationship,
    );
    message = templateService.renderTemplate(template, variables);

    final cleanPhone = contact.phone.replaceAll(' ', '').replaceAll(RegExp(r'[^\d+]'), '');
    await whatsAppService.sendMessage(cleanPhone, message);
  }

  // --- Internal System Share Helpers ---

  static Future<void> _systemSharePayable(
    BuildContext context,
    WidgetRef ref,
    dynamic payable,
    dynamic contact, {
    required dynamic currency,
    required dynamic userProfile,
    required dynamic transactionService,
  }) async {
    final deepLinkService = DeepLinkService();
    final isPaid = payable.status == 'PAID';
    final effectiveExternalId = await transactionService.ensureExternalLinkId(payableId: payable.id);

    final link = deepLinkService.generateReceivableLink(ReceivableShareData(
      amount: payable.amount,
      date: payable.date,
      description: payable.description,
      dueDate: payable.dueDate,
      senderName: userProfile.name ?? 'Someone',
      senderPhone: userProfile.phone ?? '',
      externalLinkId: effectiveExternalId,
      status: payable.status,
    ));

    String message;
    if (isPaid) {
      message = 'Greetings!\n\nThe payment of ${AmountFormatter.formatWithCurrency(payable.amount, currency.symbol, currency.decimalPlaces)} on ${AppDateFormatter.formatDate(payable.date, pattern: userProfile.dateFormat)} has been completed.\n\nSync in FlowPaisa:\n$link';
    } else {
      message = 'I owe you ${AmountFormatter.formatWithCurrency(payable.amount, currency.symbol, currency.decimalPlaces)}\nDate: ${AppDateFormatter.formatDate(payable.date, pattern: userProfile.dateFormat)}\n\nView in FlowPaisa:\n$link';
    }

    await Share.share(message);
  }

  static Future<void> _systemShareReceivable(
    BuildContext context,
    WidgetRef ref,
    dynamic receivable,
    dynamic contact, {
    required dynamic currency,
    required dynamic userProfile,
    required dynamic transactionService,
  }) async {
    final deepLinkService = DeepLinkService();
    final isReceived = receivable.status == 'RECEIVED';
    final effectiveExternalId = await transactionService.ensureExternalLinkId(receivableId: receivable.id);

    final link = deepLinkService.generatePayableLink(PayableShareData(
      amount: receivable.amount,
      date: receivable.date,
      description: receivable.description,
      dueDate: receivable.dueDate,
      senderName: userProfile.name ?? 'Someone',
      senderPhone: userProfile.phone ?? '',
      externalLinkId: effectiveExternalId,
      status: receivable.status,
    ));

    String message;
    if (isReceived) {
      message = 'Greetings!\n\nThe payment of ${AmountFormatter.formatWithCurrency(receivable.amount, currency.symbol, currency.decimalPlaces)} on ${AppDateFormatter.formatDate(receivable.date, pattern: userProfile.dateFormat)} has been received.\n\nSync in FlowPaisa:\n$link';
    } else {
      message = 'Amount to receive: ${AmountFormatter.formatWithCurrency(receivable.amount, currency.symbol, currency.decimalPlaces)}\nDate: ${AppDateFormatter.formatDate(receivable.date, pattern: userProfile.dateFormat)}\n\nView in FlowPaisa:\n$link';
    }

    await Share.share(message);
  }

  static Future<void> _systemShareTransaction(
    BuildContext context,
    WidgetRef ref,
    dynamic transaction,
    dynamic contact,
    dynamic category,
    bool isMarked, {
    required dynamic currency,
    required dynamic userProfile,
    required dynamic transactionService,
  }) async {
    final deepLinkService = DeepLinkService();
    final effectiveExternalId = await transactionService.ensureExternalLinkId(transactionId: transaction.id);

    String? status;
    if (isMarked) {
      if (transaction.paidRelationship == 'PAID_FOR' || transaction.paidRelationship == 'WILL_RECEIVE') {
        status = 'RECEIVED';
      } else if (transaction.paidRelationship == 'PAID_BY' || transaction.paidRelationship == 'RECEIVED_FROM') {
        status = 'PAID';
      }
    }

    final link = deepLinkService.generateReciprocalLink(
      senderName: userProfile.name ?? 'Someone',
      senderPhone: userProfile.phone ?? '',
      relationship: transaction.paidRelationship,
      amount: transaction.amount,
      date: transaction.date,
      description: transaction.description,
      categoryName: category?.name,
      categoryColor: category?.color,
      categoryIcon: category?.icon,
      externalLinkId: effectiveExternalId,
      status: status,
    );

    final message = 'Recorded a transaction of ${AmountFormatter.formatWithCurrency(transaction.amount, currency.symbol, currency.decimalPlaces)} on ${AppDateFormatter.formatDate(transaction.date, pattern: userProfile.dateFormat)}.\n\nView in FlowPaisa:\n$link';

    await Share.share(message);
  }
}
