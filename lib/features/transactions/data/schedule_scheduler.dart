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
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';

/// Background task callback for workmanager
/// This function will be called by workmanager to generate transactions from schedules
@pragma('vm:entry-point')
void scheduleTransactionTask() {
  // This will be called from the background isolate
  // We need to initialize the database and services here
  // Note: This is a simplified version - in production, you'd need to handle
  // the isolate context properly
}

/// Main function to process all active schedules and generate transactions
/// This should be called from the background task
Future<void> processSchedules() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('cashbooks_list');

    List<Cashbook> cashbooks = [];
    if (jsonList == null || jsonList.isEmpty) {
      cashbooks = [
        Cashbook(
          id: 'default',
          name: 'Main Cashbook',
          colorCode: '#2196F3',
          iconCodePoint: Symbols.water_drop.codePoint.toString(),
          dbPath: 'flowpaisa.db',
          createdAt: DateTime.now(),
        )
      ];
    } else {
      cashbooks = jsonList.map((json) => Cashbook.fromJson(json)).toList();
    }

    for (final cashbook in cashbooks) {
      try {
        final database = AppDatabase(fileName: cashbook.dbPath);
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

        // Get all active schedules
        final activeSchedules = await schedulesRepository.getActiveSchedules();

        // Process each schedule
        for (final schedule in activeSchedules) {
          try {
            await scheduleService.generateTransactionsFromSchedule(schedule.id);
          } catch (e) {
            print(
                'Error processing schedule ${schedule.id} in ${cashbook.name}: $e');
          }
        }

        await database.close();
      } catch (e) {
        print('Error processing cashbook ${cashbook.name}: $e');
      }
    }
  } catch (e) {
    print('Error in processSchedules: $e');
  }
}

/// Helper function to process schedules from a Riverpod context
/// This is used when the app is in foreground
Future<void> processSchedulesFromContext(WidgetRef ref) async {
  try {
    final cashbooks = ref.read(cashbooksProvider);

    for (final cashbook in cashbooks) {
      // For each cashbook, we need a separate database instance and services
      // except if it's the active one, we might want to use the providers
      final isActive = cashbook.id == ref.read(activeCashbookIdProvider);

      final database = isActive
          ? ref.read(databaseProvider)
          : AppDatabase(fileName: cashbook.dbPath);
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

      final activeSchedules = await schedulesRepository.getActiveSchedules();

      for (final schedule in activeSchedules) {
        try {
          await scheduleService.generateTransactionsFromSchedule(schedule.id);
        } catch (e) {
          print(
              'Error processing schedule ${schedule.id} in ${cashbook.name}: $e');
        }
      }

      if (!isActive) {
        await database.close();
      }
    }
  } catch (e) {
    print('Error in processSchedulesFromContext: $e');
  }
}
