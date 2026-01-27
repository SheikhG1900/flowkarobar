import 'package:flowpaisa/l10n/app_localizations.dart';
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
import '../../shared/providers/database_provider.dart';
import '../../features/receivables/data/receivables_repository.dart';
import '../../features/payables/data/payables_repository.dart';

class ShareHelper {
  static Future<void> sharePayable(
    BuildContext context,
    WidgetRef? ref,
    dynamic payable,
    dynamic contact, {
    dynamic currencyOverride,
    dynamic userProfileOverride,
    dynamic transactionServiceOverride,
    dynamic whatsAppServiceOverride,
    dynamic templateServiceOverride,
    String? languageOverride,
  }) async {
    final currency =
        currencyOverride ?? ref?.read(currentCurrencyProvider).value!;
    final userProfile = userProfileOverride ?? ref?.read(userProfileProvider);
    final whatsAppService =
        whatsAppServiceOverride ?? ref?.read(whatsAppServiceProvider);
    final transactionService =
        transactionServiceOverride ?? ref?.read(transactionServiceProvider);

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
        templateServiceOverride: templateServiceOverride,
        languageOverride: languageOverride,
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
    WidgetRef? ref,
    dynamic receivable,
    dynamic contact, {
    dynamic currencyOverride,
    dynamic userProfileOverride,
    dynamic transactionServiceOverride,
    dynamic whatsAppServiceOverride,
    dynamic templateServiceOverride,
    String? languageOverride,
  }) async {
    final currency =
        currencyOverride ?? ref?.read(currentCurrencyProvider).value!;
    final userProfile = userProfileOverride ?? ref?.read(userProfileProvider);
    final whatsAppService =
        whatsAppServiceOverride ?? ref?.read(whatsAppServiceProvider);
    final transactionService =
        transactionServiceOverride ?? ref?.read(transactionServiceProvider);

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
        templateServiceOverride: templateServiceOverride,
        languageOverride: languageOverride,
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
    WidgetRef? ref,
    dynamic transaction,
    dynamic contact,
    dynamic category,
    bool isMarked, {
    dynamic currencyOverride,
    dynamic userProfileOverride,
    dynamic transactionServiceOverride,
    dynamic whatsAppServiceOverride,
    dynamic templateServiceOverride,
    String? languageOverride,
  }) async {
    final currency =
        currencyOverride ?? ref?.read(currentCurrencyProvider).value!;
    final userProfile = userProfileOverride ?? ref?.read(userProfileProvider);
    final whatsAppService =
        whatsAppServiceOverride ?? ref?.read(whatsAppServiceProvider);
    final transactionService =
        transactionServiceOverride ?? ref?.read(transactionServiceProvider);

    if (contact != null && contact.phone != null && contact.phone.isNotEmpty) {
      if (isMarked) {
        if (transaction.linkedReceivableUuid != null) {
          // It's a receivable that was marked as RECEIVED
          final database = ref!.read(databaseProvider);
          final receivable = await ReceivablesRepository(database)
              .getReceivableByUuid(transaction.linkedReceivableUuid!);
          if (receivable != null) {
            return shareReceivable(
              context,
              ref,
              receivable,
              contact,
              currencyOverride: currency,
              userProfileOverride: userProfile,
              transactionServiceOverride: transactionService,
              whatsAppServiceOverride: whatsAppService,
              templateServiceOverride: templateServiceOverride,
              languageOverride: languageOverride,
            );
          }
        } else if (transaction.linkedPayableUuid != null) {
          // It's a payable that was marked as PAID
          final database = ref!.read(databaseProvider);
          final payable = await PayablesRepository(database)
              .getPayableByUuid(transaction.linkedPayableUuid!);
          if (payable != null) {
            return sharePayable(
              context,
              ref,
              payable,
              contact,
              currencyOverride: currency,
              userProfileOverride: userProfile,
              transactionServiceOverride: transactionService,
              whatsAppServiceOverride: whatsAppService,
              templateServiceOverride: templateServiceOverride,
              languageOverride: languageOverride,
            );
          }
        }
      }

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
        templateServiceOverride: templateServiceOverride,
        languageOverride: languageOverride,
      );
    } else {
      if (isMarked) {
        if (transaction.linkedReceivableUuid != null) {
          final database = ref!.read(databaseProvider);
          final receivable = await ReceivablesRepository(database)
              .getReceivableByUuid(transaction.linkedReceivableUuid!);
          if (receivable != null) {
            return _systemShareReceivable(
              context,
              ref,
              receivable,
              contact,
              currency: currency,
              userProfile: userProfile,
              transactionService: transactionService,
            );
          }
        } else if (transaction.linkedPayableUuid != null) {
          final database = ref!.read(databaseProvider);
          final payable = await PayablesRepository(database)
              .getPayableByUuid(transaction.linkedPayableUuid!);
          if (payable != null) {
            return _systemSharePayable(
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
      }

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
    WidgetRef? ref,
    dynamic contact,
    dynamic payable, {
    required dynamic currency,
    required dynamic userProfile,
    required dynamic whatsAppService,
    required TransactionService transactionService,
    dynamic templateServiceOverride,
    String? languageOverride,
  }) async {
    // Capture all needed values from ref before any async gaps
    final templateService =
        templateServiceOverride ?? ref?.read(messageTemplateServiceProvider);
    final language =
        languageOverride ?? (ref != null ? getCurrentLanguageCode(ref) : 'en');

    final deepLinkService = DeepLinkService();
    final isPaid = payable.status == 'PAID';
    final effectiveExternalId = await transactionService.ensureExternalLinkId(
        payableUuid: payable.uuid);

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
      // Use template for paid status
      final template = await templateService.getTemplate(
        DefaultTemplates.payableReminder,
        DefaultTemplates.paid,
        language,
      );
      final variables = templateService.buildPayableReminderVariables(
        contactName: contact.name,
        amount: AmountFormatter.formatWithCurrency(
            payable.amount, currency.symbol, currency.decimalPlaces),
        description: payable.description,
        dueDate: payable.dueDate != null
            ? AppDateFormatter.formatDate(payable.dueDate,
                pattern: userProfile.dateFormat)
            : null,
        date: AppDateFormatter.formatDate(payable.date,
            pattern: userProfile.dateFormat),
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
        amount: AmountFormatter.formatWithCurrency(
            payable.amount, currency.symbol, currency.decimalPlaces),
        description: payable.description,
        dueDate: payable.dueDate != null
            ? AppDateFormatter.formatDate(payable.dueDate,
                pattern: userProfile.dateFormat)
            : null,
        date: AppDateFormatter.formatDate(payable.date,
            pattern: userProfile.dateFormat),
      );
      variables['link'] = link;
      message = templateService.renderTemplate(template, variables);
    }

    final cleanPhone =
        contact.phone.replaceAll(' ', '').replaceAll(RegExp(r'[^\d+]'), '');
    await whatsAppService.sendMessage(cleanPhone, message);
  }

  static Future<void> _sendWhatsAppReceivable(
    BuildContext context,
    WidgetRef? ref,
    dynamic contact,
    dynamic receivable, {
    required dynamic currency,
    required dynamic userProfile,
    required dynamic whatsAppService,
    required TransactionService transactionService,
    dynamic templateServiceOverride,
    String? languageOverride,
  }) async {
    // Capture all needed values from ref before any async gaps
    final templateService =
        templateServiceOverride ?? ref?.read(messageTemplateServiceProvider);
    final language =
        languageOverride ?? (ref != null ? getCurrentLanguageCode(ref) : 'en');

    final deepLinkService = DeepLinkService();
    final isReceived = receivable.status == 'RECEIVED';
    final effectiveExternalId = await transactionService.ensureExternalLinkId(
        receivableUuid: receivable.uuid);

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
      // Use template for received status
      final template = await templateService.getTemplate(
        DefaultTemplates.receivableReminder,
        DefaultTemplates.received,
        language,
      );
      final variables = templateService.buildReceivableReminderVariables(
        contactName: contact.name,
        amount: AmountFormatter.formatWithCurrency(
            receivable.amount, currency.symbol, currency.decimalPlaces),
        description: receivable.description,
        dueDate: receivable.dueDate != null
            ? AppDateFormatter.formatDate(receivable.dueDate,
                pattern: userProfile.dateFormat)
            : null,
      );
      variables['date'] = AppDateFormatter.formatDate(receivable.date,
          pattern: userProfile.dateFormat);
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
        amount: AmountFormatter.formatWithCurrency(
            receivable.amount, currency.symbol, currency.decimalPlaces),
        description: receivable.description,
        dueDate: receivable.dueDate != null
            ? AppDateFormatter.formatDate(receivable.dueDate,
                pattern: userProfile.dateFormat)
            : null,
      );
      variables['date'] = AppDateFormatter.formatDate(receivable.date,
          pattern: userProfile.dateFormat);
      variables['link'] = link;
      message = templateService.renderTemplate(template, variables);
    }

    final cleanPhone =
        contact.phone.replaceAll(' ', '').replaceAll(RegExp(r'[^\d+]'), '');
    await whatsAppService.sendMessage(cleanPhone, message);
  }

  static Future<void> _sendWhatsAppTransaction(
    BuildContext context,
    WidgetRef? ref,
    dynamic contact,
    dynamic transaction,
    dynamic category,
    bool isMarked, {
    required dynamic currency,
    required dynamic userProfile,
    required dynamic whatsAppService,
    required TransactionService transactionService,
    dynamic templateServiceOverride,
    String? languageOverride,
  }) async {
    // Capture all needed values from ref before any async gaps
    final templateService =
        templateServiceOverride ?? ref?.read(messageTemplateServiceProvider);
    final language =
        languageOverride ?? (ref != null ? getCurrentLanguageCode(ref) : 'en');

    final deepLinkService = DeepLinkService();
    final effectiveExternalId = await transactionService.ensureExternalLinkId(
        transactionUuid: transaction.uuid);

    String? status;
    if (isMarked) {
      if (transaction.paidRelationship == 'PAID_FOR' ||
          transaction.paidRelationship == 'WILL_RECEIVE') {
        status = 'RECEIVED';
      } else if (transaction.paidRelationship == 'PAID_BY' ||
          transaction.paidRelationship == 'RECEIVED_FROM') {
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
    final formattedAmount = AmountFormatter.formatWithCurrency(
        transaction.amount, currency.symbol, currency.decimalPlaces);
    final formattedDate = AppDateFormatter.formatDate(transaction.date,
        pattern: userProfile.dateFormat);
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

    final cleanPhone =
        contact.phone.replaceAll(' ', '').replaceAll(RegExp(r'[^\d+]'), '');
    await whatsAppService.sendMessage(cleanPhone, message);
  }

  // --- Internal System Share Helpers ---

  static Future<void> _systemSharePayable(
    BuildContext context,
    WidgetRef? ref,
    dynamic payable,
    dynamic contact, {
    required dynamic currency,
    required dynamic userProfile,
    required TransactionService transactionService,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final deepLinkService = DeepLinkService();
    final isPaid = payable.status == 'PAID';
    final effectiveExternalId = await transactionService.ensureExternalLinkId(
        payableUuid: payable.uuid);

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
      message = l10n.sharePayableCompleted(
        AmountFormatter.formatWithCurrency(
            payable.amount, currency.symbol, currency.decimalPlaces),
        AppDateFormatter.formatDate(payable.date),
        link,
      );
    } else {
      message = l10n.sharePayablePending(
        AmountFormatter.formatWithCurrency(
            payable.amount, currency.symbol, currency.decimalPlaces),
        AppDateFormatter.formatDate(payable.date),
        link,
      );
    }

    await Share.share(message);
  }

  static Future<void> _systemShareReceivable(
    BuildContext context,
    WidgetRef? ref,
    dynamic receivable,
    dynamic contact, {
    required dynamic currency,
    required dynamic userProfile,
    required TransactionService transactionService,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final deepLinkService = DeepLinkService();
    final isReceived = receivable.status == 'RECEIVED';
    final effectiveExternalId = await transactionService.ensureExternalLinkId(
        receivableUuid: receivable.uuid);

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
      message = l10n.shareReceivableReceived(
        AmountFormatter.formatWithCurrency(
            receivable.amount, currency.symbol, currency.decimalPlaces),
        AppDateFormatter.formatDate(receivable.date),
        link,
      );
    } else {
      message = l10n.shareReceivablePending(
        AmountFormatter.formatWithCurrency(
            receivable.amount, currency.symbol, currency.decimalPlaces),
        AppDateFormatter.formatDate(receivable.date),
        link,
      );
    }

    await Share.share(message);
  }

  static Future<void> _systemShareTransaction(
    BuildContext context,
    WidgetRef? ref,
    dynamic transaction,
    dynamic contact,
    dynamic category,
    bool isMarked, {
    required dynamic currency,
    required dynamic userProfile,
    required TransactionService transactionService,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final deepLinkService = DeepLinkService();
    final effectiveExternalId = await transactionService.ensureExternalLinkId(
        transactionUuid: transaction.uuid);

    String? status;
    if (isMarked) {
      if (transaction.paidRelationship == 'PAID_FOR' ||
          transaction.paidRelationship == 'WILL_RECEIVE') {
        status = 'RECEIVED';
      } else if (transaction.paidRelationship == 'PAID_BY' ||
          transaction.paidRelationship == 'RECEIVED_FROM') {
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

    final message = l10n.shareTransactionMessage(
      AmountFormatter.formatWithCurrency(
          transaction.amount, currency.symbol, currency.decimalPlaces),
      AppDateFormatter.formatDate(transaction.date),
      link,
    );

    await Share.share(message);
  }
}
