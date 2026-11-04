import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/data/schedules_repository.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/schedule_service_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/features/receivables/data/receivables_repository.dart';
import 'package:flowpaisa/features/payables/data/payables_repository.dart';
import 'package:flowpaisa/features/categories/data/categories_repository.dart';
import 'package:flowpaisa/features/contacts/data/contacts_repository.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/businesses/domain/models/business.dart';
import 'package:flowpaisa/features/businesses/presentation/providers/business_provider.dart';

import 'package:flowpaisa/features/notifications/presentation/providers/notification_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

/// Background task callback for workmanager
/// This function will be called by workmanager to generate transactions from schedules
@pragma('vm:entry-point')
void scheduleTransactionTask() {
  // Background tasks removed
}

/// Helper function to process schedules and check for overdue items from a Riverpod context
/// This is used when the app is in foreground
Future<void> processSchedulesFromContext(WidgetRef ref) async {
  try {
    final cashbooks = ref.read(businessesProvider);
    final isPremium = PremiumGate.isPremium(ref);
    
    // Load localizations for notifications
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString('language_code') ?? 'en';
    final l10n = await AppLocalizations.delegate.load(Locale(localeCode));

    for (final cashbook in cashbooks) {
      // Skip locked cashbooks for free users
      if (!isPremium &&
          cashbook.id != 'default' &&
          (cashbook.addSeq ?? 0) >= PremiumGate.cashbookTotalLimit) {
        continue;
      }

      // For each cashbook, we need a separate database instance and services
      final isActive = cashbook.id == ref.read(activeBusinessIdProvider);

      final database = isActive
          ? ref.read(databaseProvider)
          : AppDatabase(fileName: '${cashbook.dbPath}.db');
      
      try {
        final schedulesRepository = SchedulesRepository(database);
        final scheduleService = ScheduleService(
          database: database,
          schedulesRepository: schedulesRepository,
          transactionsRepository: TransactionsRepository(database),
          transactionService: TransactionService(
            database: database,
            transactionsRepository: TransactionsRepository(database),
            receivablesRepository: ReceivablesRepository(database),
            payablesRepository: PayablesRepository(database),
            categoriesRepository: CategoriesRepository(database),
            contactsRepository: ContactsRepository(database),
          ),
        );

        // 1. Process active schedules
        final activeSchedules = await schedulesRepository.getActiveSchedules();
        for (final schedule in activeSchedules) {
          try {
            await scheduleService.generateTransactionsFromSchedule(schedule.uuid,
                isPremium: isPremium);
          } catch (e) {
            debugPrint('Error processing schedule ${schedule.uuid} in ${cashbook.name}: $e');
          }
        }

        // 2. Check for overdue payables and receivables
        final payablesRepo = PayablesRepository(database);
        final receivablesRepo = ReceivablesRepository(database);

        final overduePayables = await payablesRepo.getOverduePayables();
        for (final p in overduePayables) {
          await NotificationNotifier.addNotificationStatic(
            title: l10n.payableOverdue,
            message: l10n.payableOverdueMessage(
                p.description ?? (l10n.payable), p.dueDate?.toString() ?? ''),
            type: NotificationType.payable,
            isUrgent: true,
            cashbookUuid: cashbook.id,
            entityId: p.uuid,
            titleKey: 'payableOverdue',
            messageKey: 'payableOverdueMessage',
            parameters: {
              'description': p.description ?? l10n.payable,
              'date': p.dueDate?.toString() ?? '',
            },
          );
        }

        final overdueReceivables = await receivablesRepo.getOverdueReceivables();
        for (final r in overdueReceivables) {
          await NotificationNotifier.addNotificationStatic(
            title: l10n.receivableOverdue,
            message: l10n.receivableOverdueMessage(
                r.description ?? (l10n.receivable), r.dueDate?.toString() ?? ''),
            type: NotificationType.receivable,
            isUrgent: true,
            cashbookUuid: cashbook.id,
            entityId: r.uuid,
            titleKey: 'receivableOverdue',
            messageKey: 'receivableOverdueMessage',
            parameters: {
              'description': r.description ?? l10n.receivable,
              'date': r.dueDate?.toString() ?? '',
            },
          );
        }

        // 3. Check for upcoming items (due within 24 hours)
        final upcomingPayables = await payablesRepo.getUpcomingPayables(days: 1);
        for (final p in upcomingPayables) {
          await NotificationNotifier.addNotificationStatic(
            title: l10n.upcomingPayable,
            message: l10n.upcomingPayableMessage(
                p.description ?? (l10n.payable), p.dueDate?.toString() ?? ''),
            type: NotificationType.payable,
            cashbookUuid: cashbook.id,
            entityId: p.uuid,
            titleKey: 'upcomingPayable',
            messageKey: 'upcomingPayableMessage',
            parameters: {
              'description': p.description ?? l10n.payable,
              'date': p.dueDate?.toString() ?? '',
            },
          );
        }

        final upcomingReceivables = await receivablesRepo.getUpcomingReceivables(days: 1);
        for (final r in upcomingReceivables) {
          await NotificationNotifier.addNotificationStatic(
            title: l10n.upcomingReceivable,
            message: l10n.upcomingReceivableMessage(
                r.description ?? (l10n.receivable), r.dueDate?.toString() ?? ''),
            type: NotificationType.receivable,
            cashbookUuid: cashbook.id,
            entityId: r.uuid,
            titleKey: 'upcomingReceivable',
            messageKey: 'upcomingReceivableMessage',
            parameters: {
              'description': r.description ?? l10n.receivable,
              'date': r.dueDate?.toString() ?? '',
            },
          );
        }
      } finally {
        if (!isActive) {
          await database.close();
        }
      }
    }
    
    // Refresh the notification provider to show new items in UI
    ref.read(notificationProvider.notifier).refresh();
    
  } catch (e) {
    debugPrint('Error in processSchedulesFromContext: $e');
  }
}
