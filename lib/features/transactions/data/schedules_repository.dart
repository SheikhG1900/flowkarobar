import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:uuid/uuid.dart';

class SchedulesRepository {
  final AppDatabase _database;

  SchedulesRepository(this._database);

  Future<int> getNextAvailableSeq<T extends HasResultSet>(
      ResultSetImplementation<T, dynamic> table, GeneratedColumn<int> seqColumn) async {
    // Get isDeleted column from the table
    final isDeletedColumn = table.columnsByName['is_deleted'] as GeneratedColumn<bool>?;

    final query = _database.selectOnly(table)
      ..addColumns([seqColumn])
      ..where(seqColumn.isNotNull());

    // Filter out deleted records if the column exists
    if (isDeletedColumn != null) {
      query.where(isDeletedColumn.equals(false));
    }

    query.orderBy([OrderingTerm.asc(seqColumn)]);

    final rows = await query.get();
    final usedSeqs = rows.map((r) => r.read(seqColumn)!).toSet();

    // Start from 1 for new records (0 is reserved for defaults)
    int nextSeq = 1;
    while (usedSeqs.contains(nextSeq)) {
      nextSeq++;
    }
    return nextSeq;
  }

  // Get all schedules
  Stream<List<TransactionSchedule>> watchAllSchedules() {
    return (_database.select(_database.transactionSchedules)
          ..where((s) => s.isDeleted.equals(false)))
        .watch();
  }

  // Watch all schedules with category, contact, and account details
  Stream<List<ScheduleWithDetails>> watchAllSchedulesWithDetails() {
    final query = _database.select(_database.transactionSchedules).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactionSchedules.categoryUuid),
      ),
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid
            .equalsExp(_database.transactionSchedules.contactUuid),
      ),
      leftOuterJoin(
        _database.accounts,
        _database.accounts.uuid
            .equalsExp(_database.transactionSchedules.accountUuid),
      ),
    ]);

    query.where(_database.transactionSchedules.isDeleted.equals(false));
    query
        .orderBy([OrderingTerm.desc(_database.transactionSchedules.createdAt)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ScheduleWithDetails(
          schedule: row.readTable(_database.transactionSchedules),
          category: row.readTableOrNull(_database.categories),
          contact: row.readTableOrNull(_database.contacts),
          account: row.readTableOrNull(_database.accounts),
        );
      }).toList();
    });
  }

  // Watch schedule with details by UUID
  Stream<ScheduleWithDetails?> watchScheduleWithDetailsByUuid(String uuid) {
    final query = _database.select(_database.transactionSchedules).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactionSchedules.categoryUuid),
      ),
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid
            .equalsExp(_database.transactionSchedules.contactUuid),
      ),
      leftOuterJoin(
        _database.accounts,
        _database.accounts.uuid
            .equalsExp(_database.transactionSchedules.accountUuid),
      ),
    ]);

    query.where(_database.transactionSchedules.uuid.equals(uuid) &
        _database.transactionSchedules.isDeleted.equals(false));

    return query.watchSingleOrNull().map((row) {
      if (row == null) return null;
      return ScheduleWithDetails(
        schedule: row.readTable(_database.transactionSchedules),
        category: row.readTableOrNull(_database.categories),
        contact: row.readTableOrNull(_database.contacts),
        account: row.readTableOrNull(_database.accounts),
      );
    });
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
    final nextSeq = await getNextAvailableSeq(
        _database.transactionSchedules, _database.transactionSchedules.addSeq);
    await _database.into(_database.transactionSchedules).insert(
          schedule.copyWith(
            uuid: Value(uuid),
            isNotSynced: const Value(true),
            addSeq: Value(nextSeq),
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
