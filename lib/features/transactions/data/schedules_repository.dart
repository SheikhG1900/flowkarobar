import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';

class SchedulesRepository {
  final AppDatabase _database;

  SchedulesRepository(this._database);

  // Get all schedules
  Stream<List<TransactionSchedule>> watchAllSchedules() {
    return _database.select(_database.transactionSchedules).watch();
  }

  // Get all schedules (Future)
  Future<List<TransactionSchedule>> getAllSchedules() {
    return _database.select(_database.transactionSchedules).get();
  }

  // Get active schedules (not paused, within date range)
  Future<List<TransactionSchedule>> getActiveSchedules() {
    final now = DateTime.now();
    return (_database.select(_database.transactionSchedules)
          ..where((s) => s.isPaused.equals(false))
          ..where((s) {
            // Check if startDate is null or before/equal to now
            final startCheck = s.startDate.isNull() |
                s.startDate.isSmallerOrEqualValue(now);
            // Check if endDate is null or after/equal to now
            final endCheck = s.endDate.isNull() | s.endDate.isBiggerOrEqualValue(now);
            return startCheck & endCheck;
          }))
        .get();
  }

  // Get schedule by ID
  Future<TransactionSchedule?> getScheduleById(int id) {
    return (_database.select(_database.transactionSchedules)
          ..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  // Create schedule
  Future<int> createSchedule(TransactionSchedulesCompanion schedule) {
    return _database.into(_database.transactionSchedules).insert(schedule);
  }

  // Update schedule
  Future<bool> updateSchedule(
      int id, TransactionSchedulesCompanion schedule) async {
    final result = await (_database.update(_database.transactionSchedules)
          ..where((s) => s.id.equals(id)))
        .write(schedule);
    return result > 0;
  }

  // Update lastGeneratedDate
  Future<bool> updateLastGeneratedDate(int id, DateTime date) async {
    final result = await (_database.update(_database.transactionSchedules)
          ..where((s) => s.id.equals(id)))
        .write(TransactionSchedulesCompanion(
          lastGeneratedDate: Value(date),
          updatedAt: Value(DateTime.now()),
        ));
    return result > 0;
  }

  // Pause schedule
  Future<bool> pauseSchedule(int id) async {
    final result = await (_database.update(_database.transactionSchedules)
          ..where((s) => s.id.equals(id)))
        .write(TransactionSchedulesCompanion(
          isPaused: const Value(true),
          updatedAt: Value(DateTime.now()),
        ));
    return result > 0;
  }

  // Resume schedule (set lastGeneratedDate to day before resume date)
  Future<bool> resumeSchedule(int id, DateTime resumeDate) async {
    final dayBefore = resumeDate.subtract(const Duration(days: 1));
    final result = await (_database.update(_database.transactionSchedules)
          ..where((s) => s.id.equals(id)))
        .write(TransactionSchedulesCompanion(
          isPaused: const Value(false),
          lastGeneratedDate: Value(dayBefore),
          updatedAt: Value(DateTime.now()),
        ));
    return result > 0;
  }

  // Delete schedule
  Future<bool> deleteSchedule(int id) async {
    final result = await (_database.delete(_database.transactionSchedules)
          ..where((s) => s.id.equals(id)))
        .go();
    return result > 0;
  }

  // Get count of schedules
  Future<int> getScheduleCount() async {
    final schedules = await getAllSchedules();
    return schedules.length;
  }
}
