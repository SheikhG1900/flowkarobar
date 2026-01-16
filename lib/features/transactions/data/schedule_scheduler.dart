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
    // Initialize database
    final database = AppDatabase();
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
        // Log error but continue with other schedules
        print('Error processing schedule ${schedule.id}: $e');
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
    final scheduleService = ref.read(scheduleServiceProvider);

    // Get all active schedules using the service's repository
    final schedulesRepository = SchedulesRepository(
      ref.read(databaseProvider),
    );
    final activeSchedules = await schedulesRepository.getActiveSchedules();

    // Process each schedule
    for (final schedule in activeSchedules) {
      try {
        await scheduleService.generateTransactionsFromSchedule(schedule.id);
      } catch (e) {
        // Log error but continue with other schedules
        print('Error processing schedule ${schedule.id}: $e');
      }
    }
  } catch (e) {
    print('Error in processSchedulesFromContext: $e');
  }
}
