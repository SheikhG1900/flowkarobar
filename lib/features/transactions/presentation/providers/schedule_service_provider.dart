import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/data/schedules_repository.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService(
    database: ref.watch(databaseProvider),
    schedulesRepository: ref.watch(schedulesRepositoryProvider),
    transactionsRepository: ref.watch(transactionsRepositoryProvider),
    transactionService: ref.watch(transactionServiceProvider),
  );
});

class ScheduleService {
  final AppDatabase database;
  final SchedulesRepository schedulesRepository;
  final TransactionsRepository transactionsRepository;
  final TransactionService transactionService;

  ScheduleService({
    required this.database,
    required this.schedulesRepository,
    required this.transactionsRepository,
    required this.transactionService,
  });

  /// Create a schedule from transaction template
  Future<int> createSchedule({
    required double amount,
    required String type,
    String? description,
    int? categoryId,
    int? contactId,
    String? paidRelationship,
    DateTime? dueDate,
    required String scheduleType, // 'DAILY', 'WEEKLY', 'MONTHLY'
    List<int>? selectedDaysOfWeek, // 0=Sunday, 6=Saturday
    List<int>? selectedDaysOfMonth, // 1-31
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Serialize arrays to JSON
    String? daysOfWeekJson;
    if (selectedDaysOfWeek != null && selectedDaysOfWeek.isNotEmpty) {
      daysOfWeekJson = jsonEncode(selectedDaysOfWeek);
    }

    String? daysOfMonthJson;
    if (selectedDaysOfMonth != null && selectedDaysOfMonth.isNotEmpty) {
      daysOfMonthJson = jsonEncode(selectedDaysOfMonth);
    }

    final scheduleId = await schedulesRepository.createSchedule(
      TransactionSchedulesCompanion(
        amount: Value(amount),
        type: Value(type),
        description: Value(description),
        categoryId: Value(categoryId),
        contactId: Value(contactId),
        paidRelationship: Value(paidRelationship),
        dueDate: Value(dueDate),
        scheduleType: Value(scheduleType),
        selectedDaysOfWeek: Value(daysOfWeekJson),
        selectedDaysOfMonth: Value(daysOfMonthJson),
        isPaused: const Value(false),
        startDate: Value(startDate),
        endDate: Value(endDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return scheduleId;
  }

  /// Generate transactions from a schedule for missed dates
  Future<int> generateTransactionsFromSchedule(int scheduleId) async {
    final schedule = await schedulesRepository.getScheduleById(scheduleId);
    if (schedule == null) {
      throw Exception('Schedule not found');
    }

    if (schedule.isPaused) {
      return 0; // Don't generate if paused
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if schedule is within date range
    if (schedule.startDate != null && schedule.startDate!.isAfter(today)) {
      return 0; // Not started yet
    }
    if (schedule.endDate != null && schedule.endDate!.isBefore(today)) {
      return 0; // Already ended
    }

    // Determine start date for generation
    DateTime startDate;
    if (schedule.lastGeneratedDate != null) {
      // Start from day after last generated date
      final lastDate = schedule.lastGeneratedDate!;
      startDate = DateTime(lastDate.year, lastDate.month, lastDate.day)
          .add(const Duration(days: 1));
    } else if (schedule.startDate != null) {
      startDate = DateTime(
        schedule.startDate!.year,
        schedule.startDate!.month,
        schedule.startDate!.day,
      );
    } else {
      startDate = today; // Start from today if no start date
    }

    // Generate list of dates to create transactions for
    final datesToGenerate = _calculateDatesToGenerate(
      schedule: schedule,
      startDate: startDate,
      endDate: today,
    );

    if (datesToGenerate.isEmpty) {
      return 0;
    }

    // Generate transactions for each date
    int generatedCount = 0;
    DateTime? latestGeneratedDate;

    for (final date in datesToGenerate) {
      try {
        final transactionId = await transactionService.createTransaction(
          amount: schedule.amount,
          type: schedule.type,
          date: date,
          description: schedule.description,
          categoryId: schedule.categoryId,
          contactId: schedule.contactId,
          paidRelationship: schedule.paidRelationship,
          dueDate: schedule.dueDate,
        );

        // Mark transaction as scheduled
        await transactionsRepository.updateTransactionWithCompanion(
          transactionId,
          TransactionsCompanion(
            isScheduled: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );

        generatedCount++;
        latestGeneratedDate = date;
      } catch (e) {
        // Log error but continue with other dates
        print('Error generating transaction for date $date: $e');
      }
    }

    // Update lastGeneratedDate to the latest generated date
    if (latestGeneratedDate != null) {
      await schedulesRepository.updateLastGeneratedDate(
        scheduleId,
        latestGeneratedDate,
      );
    }

    return generatedCount;
  }

  /// Calculate which dates should have transactions generated based on schedule pattern
  List<DateTime> _calculateDatesToGenerate({
    required TransactionSchedule schedule,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final dates = <DateTime>[];
    var current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      bool shouldGenerate = false;

      switch (schedule.scheduleType) {
        case 'DAILY':
          shouldGenerate = true;
          break;

        case 'WEEKLY':
          if (schedule.selectedDaysOfWeek != null) {
            final daysOfWeek = _parseDaysOfWeek(schedule.selectedDaysOfWeek!);
            final weekday =
                current.weekday % 7; // Convert to 0=Sunday, 6=Saturday
            shouldGenerate = daysOfWeek.contains(weekday);
          }
          break;

        case 'MONTHLY':
          if (schedule.selectedDaysOfMonth != null) {
            final daysOfMonth =
                _parseDaysOfMonth(schedule.selectedDaysOfMonth!);
            final dayOfMonth = current.day;
            shouldGenerate = daysOfMonth.contains(dayOfMonth);
          }
          break;
      }

      if (shouldGenerate) {
        dates.add(DateTime(current.year, current.month, current.day));
      }

      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  /// Parse days of week from JSON string
  List<int> _parseDaysOfWeek(String jsonString) {
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => e as int).toList();
    } catch (e) {
      return [];
    }
  }

  /// Parse days of month from JSON string
  List<int> _parseDaysOfMonth(String jsonString) {
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => e as int).toList();
    } catch (e) {
      return [];
    }
  }

  /// Pause a schedule
  Future<bool> pauseSchedule(int scheduleId) async {
    return await schedulesRepository.pauseSchedule(scheduleId);
  }

  /// Resume a schedule (set lastGeneratedDate to day before resume date)
  Future<bool> resumeSchedule(int scheduleId, DateTime resumeDate) async {
    return await schedulesRepository.resumeSchedule(scheduleId, resumeDate);
  }

  /// Delete a schedule
  Future<bool> deleteSchedule(int scheduleId) async {
    return await schedulesRepository.deleteSchedule(scheduleId);
  }

  /// Update a schedule
  Future<bool> updateSchedule(
    int scheduleId, {
    double? amount,
    String? type,
    String? description,
    int? categoryId,
    int? contactId,
    String? paidRelationship,
    DateTime? dueDate,
    String? scheduleType,
    List<int>? selectedDaysOfWeek,
    List<int>? selectedDaysOfMonth,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String? daysOfWeekJson;
    if (selectedDaysOfWeek != null) {
      if (selectedDaysOfWeek.isEmpty) {
        daysOfWeekJson = null;
      } else {
        daysOfWeekJson = jsonEncode(selectedDaysOfWeek);
      }
    }

    String? daysOfMonthJson;
    if (selectedDaysOfMonth != null) {
      if (selectedDaysOfMonth.isEmpty) {
        daysOfMonthJson = null;
      } else {
        daysOfMonthJson = jsonEncode(selectedDaysOfMonth);
      }
    }

    return await schedulesRepository.updateSchedule(
      scheduleId,
      TransactionSchedulesCompanion(
        amount: amount != null ? Value(amount) : const Value.absent(),
        type: type != null ? Value(type) : const Value.absent(),
        description:
            description != null ? Value(description) : const Value.absent(),
        categoryId:
            categoryId != null ? Value(categoryId) : const Value.absent(),
        contactId: contactId != null ? Value(contactId) : const Value.absent(),
        paidRelationship: paidRelationship != null
            ? Value(paidRelationship)
            : const Value.absent(),
        dueDate: dueDate != null ? Value(dueDate) : const Value.absent(),
        scheduleType:
            scheduleType != null ? Value(scheduleType) : const Value.absent(),
        selectedDaysOfWeek: daysOfWeekJson != null
            ? Value(daysOfWeekJson)
            : const Value.absent(),
        selectedDaysOfMonth: daysOfMonthJson != null
            ? Value(daysOfMonthJson)
            : const Value.absent(),
        startDate: startDate != null ? Value(startDate) : const Value.absent(),
        endDate: endDate != null ? Value(endDate) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
