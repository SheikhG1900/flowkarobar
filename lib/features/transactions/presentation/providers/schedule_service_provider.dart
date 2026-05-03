import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
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
    String? accountUuid,
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
          uuid: Value(DeepLinkService.newMinifiedUuid()),
          amount: Value(amount),
          type: Value(type),
          description: Value(description),
          categoryUuid: Value(categoryUuid),
          contactUuid: Value(contactUuid),
          accountUuid: Value(accountUuid),
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
      if (kDebugMode) {
        debugPrint('Error creating schedule in service: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// Generate transactions from a schedule for missed dates
  Future<int> generateTransactionsFromSchedule(String scheduleUuid,
      {DateTime? customDate, bool isPremium = false}) async {
    final schedule = await schedulesRepository.getScheduleByUuid(scheduleUuid);
    if (schedule == null) {
      throw Exception('Schedule not found');
    }

    // Check premium limits for free users
    if (!isPremium) {
      final seq = schedule.addSeq ?? 0;
      if (seq > PremiumGate.scheduleTotalLimit) {
        if (kDebugMode) {
          debugPrint(
              'Schedule $scheduleUuid is locked (seq: $seq > limit: ${PremiumGate.scheduleTotalLimit}), skipping generation.');
        }
        return 0;
      }
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
    // Priority: lastGeneratedDate + 1 day > createdAt > today (fallback)
    DateTime startDate;
    if (schedule.lastGeneratedDate != null) {
      startDate = DateTime(
        schedule.lastGeneratedDate!.year,
        schedule.lastGeneratedDate!.month,
        schedule.lastGeneratedDate!.day,
      ).add(const Duration(days: 1));
    } else {
      final created = schedule.createdAt;
      startDate = DateTime(created.year, created.month, created.day);
    }

    // Adjust with startDate if it exists and is after our base start
    if (schedule.startDate != null) {
      final sDate = DateTime(
        schedule.startDate!.year,
        schedule.startDate!.month,
        schedule.startDate!.day,
      );
      if (sDate.isAfter(startDate)) {
        startDate = sDate;
      }
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
        if (kDebugMode) {
          debugPrint('Error generating transaction for date $date: $e');
        }
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
  /// Transaction id = scheduleId_date; same rules: externalLinkId = tx id, linked pay/rec = tx_rec, tx_pay
  Future<void> _generateForDate(
      TransactionSchedule schedule, DateTime date) async {
    // schedule.uuid is already minified; id = scheduleId_date
    final monthStr = date.month.toString().padLeft(2, '0');
    final dayStr = date.day.toString().padLeft(2, '0');
    final dateStr = "${date.year}$monthStr$dayStr";
    final transactionUuid = "${schedule.uuid}_$dateStr";

    if (kDebugMode) {
      debugPrint('Generating transaction for schedule: ${schedule.uuid}');
      debugPrint('Target date: $date');
      debugPrint('Generated transaction ID: $transactionUuid');
    }

    // Calculate dynamic due date based on offset if available
    DateTime? calculatedDueDate;
    if (schedule.dueDateOffset != null) {
      calculatedDueDate = date.add(Duration(days: schedule.dueDateOffset!));
    } else {
      calculatedDueDate = schedule.dueDate;
    }

    // Translate 'PROCESSED' (schedule-only workaround) to null relationship + not pending
    final scheduleRelationship = schedule.paidRelationship;
    final effectiveRelationship = scheduleRelationship == 'PROCESSED'
        ? null
        : scheduleRelationship;
    final isPendingTx = effectiveRelationship == 'PAID_BY' ||
        effectiveRelationship == 'WILL_RECEIVE';

    await transactionService.createTransaction(
      amount: schedule.amount,
      type: schedule.type,
      date: date,
      description: schedule.description,
      categoryUuid: schedule.categoryUuid,
      contactUuid: schedule.contactUuid,
      accountUuid: schedule.accountUuid,
      paidRelationship: effectiveRelationship,
      isPending: isPendingTx,
      dueDate: calculatedDueDate,
      isScheduled: true,
      transactionUuid: transactionUuid,
    ).catchError((e) {
      final errorStr = e.toString();
      if (errorStr.contains('1555') || errorStr.contains('UNIQUE constraint failed')) {
        // Ignore unique constraint violations (already generated)
        if (kDebugMode) {
          final msg = 'Transaction for $date already exists (ID: $transactionUuid), skipping.';
          debugPrint(msg);
        }
        // Also show in toast if possible via a callback or just log it
        return ''; // Return empty string to satisfy Future<String> return type
      } else {
        if (kDebugMode) {
          debugPrint('DEBUG: Error in createTransaction: $e');
        }
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

    // Optimized calculation to avoid large while loops
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      DateTime? nextDate;

      switch (schedule.scheduleType) {
        case 'DAILY':
          nextDate = current;
          break;

        case 'WEEKLY':
          if (schedule.selectedDaysOfWeek != null) {
            final List<int> days = List<int>.from(jsonDecode(schedule.selectedDaysOfWeek!))..sort();
            if (days.isNotEmpty) {
              final currentWeekday = current.weekday % 7; // 0=Sunday
              int? targetDay = days.firstWhere((d) => d >= currentWeekday, orElse: () => -1);

              if (targetDay != -1) {
                nextDate = current.add(Duration(days: targetDay - currentWeekday));
              } else {
                nextDate = current.add(Duration(days: (7 - currentWeekday) + days.first));
              }
            }
          }
          break;

        case 'MONTHLY':
          if (schedule.selectedDaysOfMonth != null) {
            final List<int> days = List<int>.from(jsonDecode(schedule.selectedDaysOfMonth!))..sort();
            if (days.isNotEmpty) {
              final currentDay = current.day;
              int? targetDay = days.firstWhere((d) => d >= currentDay, orElse: () => -1);

              if (targetDay != -1) {
                final candidate = DateTime(current.year, current.month, targetDay);
                if (candidate.isBefore(current) || candidate.month != current.month) {
                  nextDate = _getFirstValidDayInNextMonth(current.year, current.month, days.first);
                } else {
                  nextDate = candidate;
                }
              } else {
                nextDate = _getFirstValidDayInNextMonth(current.year, current.month, days.first);
              }
            }
          }
          break;
      }

      if (nextDate != null && (nextDate.isBefore(end) || nextDate.isAtSameMomentAs(end))) {
        dates.add(nextDate);
        // Move current to day after nextDate to find subsequent occurrences
        current = nextDate.add(const Duration(days: 1));
      } else {
        break; // No more occurrences within range
      }
    }

    return dates;
  }

  /// Helper to find the first valid day in the next month
  static DateTime _getFirstValidDayInNextMonth(int year, int month, int targetDay) {
    var nextMonth = month + 1;
    var nextYear = year;
    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear++;
    }
    
    var candidate = DateTime(nextYear, nextMonth, targetDay);
    while (candidate.month != nextMonth) {
      nextMonth++;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }
      candidate = DateTime(nextYear, nextMonth, targetDay);
    }
    return candidate;
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
    String? accountUuid,
    String? paidRelationship,
    DateTime? dueDate,
    int? dueDateOffset,
    String? scheduleType,
    List<int>? selectedDaysOfWeek,
    List<int>? selectedDaysOfMonth,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (kDebugMode) {
      debugPrint('Service updating schedule $scheduleUuid');
      debugPrint('Service categoryUuid: $categoryUuid');
      debugPrint('Service contactUuid: $contactUuid');
    }

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
        // Use Value(description) so clearing the field (null) updates DB to null
        description: Value(description),
        categoryUuid: Value(categoryUuid),
        contactUuid: Value(contactUuid),
        accountUuid: Value(accountUuid),
        paidRelationship: Value(paidRelationship),
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
        // Use Value() so clearing date range (null) updates DB to null
        startDate: Value(startDate),
        endDate: Value(endDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
