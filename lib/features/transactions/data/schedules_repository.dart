import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:uuid/uuid.dart';

class SchedulesRepository {
  final AppDatabase _database;

  SchedulesRepository(this._database);

  // Get all schedules
  Stream<List<TransactionSchedule>> watchAllSchedules() {
    return (_database.select(_database.transactionSchedules)
          ..where((s) => s.isDeleted.equals(false)))
        .watch();
  }

  // Get all schedules (Future)
  Future<List<TransactionSchedule>> getAllSchedules() {
    return (_database.select(_database.transactionSchedules)
          ..where((s) => s.isDeleted.equals(false)))
        .get();
  }

  // Get active schedules (not paused, within date range)
  Future<List<TransactionSchedule>> getActiveSchedules() {
    final now = DateTime.now();
    return (_database.select(_database.transactionSchedules)
          ..where((s) => s.isPaused.equals(false) & s.isDeleted.equals(false))
          ..where((s) {
            // Check if startDate is null or before/equal to now
            final startCheck =
                s.startDate.isNull() | s.startDate.isSmallerOrEqualValue(now);
            // Check if endDate is null or after/equal to now
            final endCheck =
                s.endDate.isNull() | s.endDate.isBiggerOrEqualValue(now);
            return startCheck & endCheck;
          }))
        .get();
  }

  // Get schedule by UUID
  Future<TransactionSchedule?> getScheduleByUuid(String uuid) {
    return (_database.select(_database.transactionSchedules)
          ..where((s) => s.uuid.equals(uuid) & s.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  // Create schedule
  Future<String> createSchedule(TransactionSchedulesCompanion schedule) async {
    final uuid =
        schedule.uuid.present ? schedule.uuid.value : const Uuid().v4();
    await _database.into(_database.transactionSchedules).insert(
          schedule.copyWith(
            uuid: Value(uuid),
            isNotSynced: const Value(true),
          ),
        );
    return uuid;
  }

  // Update schedule
  Future<bool> updateSchedule(
      String uuid, TransactionSchedulesCompanion schedule) async {
    final result = await (_database.update(_database.transactionSchedules)
          ..where((s) => s.uuid.equals(uuid)))
        .write(schedule.copyWith(isNotSynced: const Value(true)));
    return result > 0;
  }

  // Update lastGeneratedDate
  Future<bool> updateLastGeneratedDate(String uuid, DateTime date) async {
    final result = await (_database.update(_database.transactionSchedules)
          ..where((s) => s.uuid.equals(uuid)))
        .write(TransactionSchedulesCompanion(
      lastGeneratedDate: Value(date),
      updatedAt: Value(DateTime.now()),
      isNotSynced: const Value(true),
    ));
    return result > 0;
  }

  // Pause schedule
  Future<bool> pauseSchedule(String uuid) async {
    final result = await (_database.update(_database.transactionSchedules)
          ..where((s) => s.uuid.equals(uuid)))
        .write(TransactionSchedulesCompanion(
      isPaused: const Value(true),
      updatedAt: Value(DateTime.now()),
      isNotSynced: const Value(true),
    ));
    return result > 0;
  }

  // Resume schedule (set lastGeneratedDate to day before resume date)
  Future<bool> resumeSchedule(String uuid, DateTime resumeDate) async {
    final dayBefore = resumeDate.subtract(const Duration(days: 1));
    final result = await (_database.update(_database.transactionSchedules)
          ..where((s) => s.uuid.equals(uuid)))
        .write(TransactionSchedulesCompanion(
      isPaused: const Value(false),
      lastGeneratedDate: Value(dayBefore),
      updatedAt: Value(DateTime.now()),
      isNotSynced: const Value(true),
    ));
    return result > 0;
  }

  // Delete schedule
  Future<bool> deleteSchedule(String uuid) async {
    final result = await (_database.update(_database.transactionSchedules)
          ..where((s) => s.uuid.equals(uuid)))
        .write(const TransactionSchedulesCompanion(
      isDeleted: Value(true),
      isNotSynced: Value(true),
    ));
    return result > 0;
  }

  // Get count of schedules
  Future<int> getScheduleCount() async {
    final schedules = await getAllSchedules();
    return schedules.length;
  }
}
