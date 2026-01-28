import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/data/schedules_repository.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
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
  Future<String> createSchedule({
    required double amount,
    required String type,
    String? description,
    String? categoryUuid,
    String? contactUuid,
    String? paidRelationship,
    DateTime? dueDate,
    int? dueDateOffset,
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

    try {
      final String scheduleUuid = await schedulesRepository.createSchedule(
        TransactionSchedulesCompanion(
          uuid: Value(const Uuid().v4()),
          amount: Value(amount),
          type: Value(type),
          description: Value(description),
          categoryUuid: Value(categoryUuid),
          contactUuid: Value(contactUuid),
          paidRelationship: Value(paidRelationship),
          dueDate: Value(dueDate),
          dueDateOffset: Value(dueDateOffset),
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

      return scheduleUuid;
    } catch (e, stackTrace) {
      debugPrint('Error creating schedule in service: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Generate transactions from a schedule for missed dates
  Future<int> generateTransactionsFromSchedule(String scheduleUuid,
      {DateTime? customDate}) async {
    final schedule = await schedulesRepository.getScheduleByUuid(scheduleUuid);
    if (schedule == null) {
      throw Exception('Schedule not found');
    }

    if (schedule.isPaused && customDate == null) {
      return 0; // Don't generate if paused (unless manual debug execute)
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // If customDate is provided, we only generate for that specific date
    if (customDate != null) {
      final date = DateTime(customDate.year, customDate.month, customDate.day);
      await _generateForDate(schedule, date);
      return 1;
    }

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
        await _generateForDate(schedule, date);
        generatedCount++;
        latestGeneratedDate = date;
      } catch (e) {
        // Log error but continue with other dates
        debugPrint('Error generating transaction for date $date: $e');
      }
    }

    // Update lastGeneratedDate to the latest generated date
    if (latestGeneratedDate != null) {
      await schedulesRepository.updateLastGeneratedDate(
        scheduleUuid,
        latestGeneratedDate,
      );
    }

    return generatedCount;
  }

  /// Internal helper to generate a single transaction for a date
  Future<void> _generateForDate(
      TransactionSchedule schedule, DateTime date) async {
    // Use a deterministic UUID based on schedule and date to prevent duplicates during sync
    // Shorten the schedule UUID for external link consistency
    final shortScheduleUuid = DeepLinkService.shortenUuid(schedule.uuid);
    // Use 0-padding for month and day to avoid ambiguity (e.g., 20250111 vs 20251101)
    final monthStr = date.month.toString().padLeft(2, '0');
    final dayStr = date.day.toString().padLeft(2, '0');
    final dateStr = "${date.year}$monthStr$dayStr";
    final deterministicUuid = "${shortScheduleUuid}_$dateStr";

    debugPrint('DEBUG: Generating transaction for schedule: ${schedule.uuid}');
    debugPrint('DEBUG: Target date: $date');
    debugPrint('DEBUG: Generated deterministic ID: $deterministicUuid');

    // Calculate dynamic due date based on offset if available
    DateTime? calculatedDueDate;
    if (schedule.dueDateOffset != null) {
      calculatedDueDate = date.add(Duration(days: schedule.dueDateOffset!));
    } else {
      calculatedDueDate = schedule.dueDate;
    }

    await transactionService.createTransaction(
      amount: schedule.amount,
      type: schedule.type,
      date: date,
      description: schedule.description,
      categoryUuid: schedule.categoryUuid,
      contactUuid: schedule.contactUuid,
      paidRelationship: schedule.paidRelationship,
      dueDate: calculatedDueDate,
      isScheduled: true,
      externalLinkId: deterministicUuid, // Use as external link ID as well
    ).catchError((e) {
      final errorStr = e.toString();
      if (errorStr.contains('1555') || errorStr.contains('UNIQUE constraint failed')) {
        // Ignore unique constraint violations (already generated)
        final msg = 'Transaction for $date already exists (deterministic ID: $deterministicUuid), skipping.';
        debugPrint('DEBUG: $msg');
        // Also show in toast if possible via a callback or just log it
        return ''; // Return empty string to satisfy Future<String> return type
      } else {
        debugPrint('DEBUG: Error in createTransaction: $e');
        throw e;
      }
    });
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
  Future<bool> pauseSchedule(String scheduleUuid) async {
    return await schedulesRepository.pauseSchedule(scheduleUuid);
  }

  /// Resume a schedule (set lastGeneratedDate to day before resume date)
  Future<bool> resumeSchedule(String scheduleUuid, DateTime resumeDate) async {
    return await schedulesRepository.resumeSchedule(scheduleUuid, resumeDate);
  }

  /// Delete a schedule
  Future<bool> deleteSchedule(String scheduleUuid) async {
    return await schedulesRepository.deleteSchedule(scheduleUuid);
  }

  /// Update a schedule
  Future<bool> updateSchedule(
    String scheduleUuid, {
    double? amount,
    String? type,
    String? description,
    String? categoryUuid,
    String? contactUuid,
    String? paidRelationship,
    DateTime? dueDate,
    int? dueDateOffset,
    String? scheduleType,
    List<int>? selectedDaysOfWeek,
    List<int>? selectedDaysOfMonth,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    debugPrint('DEBUG: Service updating schedule $scheduleUuid');
    debugPrint('DEBUG: Service categoryUuid: $categoryUuid');
    debugPrint('DEBUG: Service contactUuid: $contactUuid');

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
      scheduleUuid,
      TransactionSchedulesCompanion(
        amount: amount != null ? Value(amount) : const Value.absent(),
        type: type != null ? Value(type) : const Value.absent(),
        description:
            description != null ? Value(description) : const Value.absent(),
        categoryUuid:
            categoryUuid != null ? Value(categoryUuid) : const Value.absent(),
        contactUuid: contactUuid != null ? Value(contactUuid) : const Value.absent(),
        paidRelationship: paidRelationship != null
            ? Value(paidRelationship)
            : const Value.absent(),
        dueDate: dueDate != null ? Value(dueDate) : const Value.absent(),
        dueDateOffset: dueDateOffset != null
            ? Value(dueDateOffset)
            : const Value.absent(),
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
