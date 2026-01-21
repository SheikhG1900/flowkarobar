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

    String message;
    if (isPaid) {
      message = '''
Hi ${contact.name},

Greetings! 

The payment of ${AmountFormatter.formatWithCurrency(payable.amount, currency.symbol, currency.decimalPlaces)} dated ${AppDateFormatter.formatDate(payable.date, pattern: userProfile.dateFormat)} has been completed and recorded. 

If you haven't updated this payment in FlowPaisa, please follow the link below to sync your records:
$link

Thank you!
''';
    } else {
      message = '''
Hi ${contact.name},

This is a reminder regarding the payable amount of ${AmountFormatter.formatWithCurrency(payable.amount, currency.symbol, currency.decimalPlaces)} dated ${AppDateFormatter.formatDate(payable.date, pattern: userProfile.dateFormat)}.

${payable.dueDate != null ? 'Due Date: ${AppDateFormatter.formatDate(payable.dueDate, pattern: userProfile.dateFormat)}\n' : ''}${payable.description != null && payable.description.isNotEmpty ? 'Details: ${payable.description}\n' : ''}
View and import this in FlowPaisa:
$link

Thank you!
''';
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

    String message;
    if (isReceived) {
      message = '''
Hi ${contact.name},

Greetings! 

The payment of ${AmountFormatter.formatWithCurrency(receivable.amount, currency.symbol, currency.decimalPlaces)} dated ${AppDateFormatter.formatDate(receivable.date, pattern: userProfile.dateFormat)} has been received and recorded. 

If you haven't updated this in your FlowPaisa records, please follow the link below to sync:
$link

Thank you!
''';
    } else {
      message = '''
Hi ${contact.name},

This is regarding the receivable amount of ${AmountFormatter.formatWithCurrency(receivable.amount, currency.symbol, currency.decimalPlaces)} dated ${AppDateFormatter.formatDate(receivable.date, pattern: userProfile.dateFormat)}.

${receivable.dueDate != null ? 'Due Date: ${AppDateFormatter.formatDate(receivable.dueDate, pattern: userProfile.dateFormat)}\n' : ''}${receivable.description != null && receivable.description.isNotEmpty ? 'Details: ${receivable.description}\n' : ''}
View and import this in FlowPaisa:
$link

Thank you!
''';
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

    String message;
    if (isMarked && (transaction.paidRelationship == 'PAID_FOR' || transaction.paidRelationship == 'WILL_RECEIVE')) {
      message = '''
Hi ${contact.name},

The payment of ${AmountFormatter.formatWithCurrency(transaction.amount, currency.symbol, currency.decimalPlaces)} dated ${AppDateFormatter.formatDate(transaction.date, pattern: userProfile.dateFormat)} has been received and recorded.

Sync your records in FlowPaisa:
$link
''';
    } else if (isMarked && (transaction.paidRelationship == 'PAID_BY' || transaction.paidRelationship == 'RECEIVED_FROM')) {
      message = '''
Hi ${contact.name},

The payment of ${AmountFormatter.formatWithCurrency(transaction.amount, currency.symbol, currency.decimalPlaces)} dated ${AppDateFormatter.formatDate(transaction.date, pattern: userProfile.dateFormat)} has been completed.

Sync your records in FlowPaisa:
$link
''';
    } else {
      message = '''
Hi ${contact.name},

Transaction Details:
Amount: ${AmountFormatter.formatWithCurrency(transaction.amount, currency.symbol, currency.decimalPlaces)}
Date: ${AppDateFormatter.formatDate(transaction.date, pattern: userProfile.dateFormat)}
Relationship: ${transaction.paidRelationship}

View in FlowPaisa:
$link
''';
    }

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
      message = 'Greetings!\n\nThe payment of ${AmountFormatter.formatWithCurrency(payable.amount, currency.symbol, currency.decimalPlaces)} has been completed.\n\nSync in FlowPaisa:\n$link';
    } else {
      message = 'Payable Details\nAmount: ${AmountFormatter.formatWithCurrency(payable.amount, currency.symbol, currency.decimalPlaces)}\nDate: ${AppDateFormatter.formatDate(payable.date, pattern: userProfile.dateFormat)}\n\nView in FlowPaisa:\n$link';
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
      message = 'Greetings!\n\nThe payment of ${AmountFormatter.formatWithCurrency(receivable.amount, currency.symbol, currency.decimalPlaces)} has been received.\n\nSync in FlowPaisa:\n$link';
    } else {
      message = 'Receivable Details\nAmount: ${AmountFormatter.formatWithCurrency(receivable.amount, currency.symbol, currency.decimalPlaces)}\nDate: ${AppDateFormatter.formatDate(receivable.date, pattern: userProfile.dateFormat)}\n\nView in FlowPaisa:\n$link';
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

    final message = 'Transaction Details\nAmount: ${AmountFormatter.formatWithCurrency(transaction.amount, currency.symbol, currency.decimalPlaces)}\nDate: ${AppDateFormatter.formatDate(transaction.date, pattern: userProfile.dateFormat)}\n\nView in FlowPaisa:\n$link';

    await Share.share(message);
  }
}
