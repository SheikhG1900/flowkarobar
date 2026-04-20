import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

QueryExecutor openConnection(String fileName) {
  return driftDatabase(
    name: fileName.replaceAll('.db', ''),
  );
}

/// Performs a WAL checkpoint on the specified database file.
/// This ensures all data from the -wal file is flushed into the main .sqlite file.
Future<void> checkpointDatabase(String logicalName) async {
  try {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, '$logicalName.sqlite'));

    if (await dbFile.exists()) {
      final db = sqlite3.open(dbFile.path);
      try {
        db.execute('PRAGMA wal_checkpoint(FULL);');
      } finally {
        db.dispose();
      }
    }
  } catch (e) {
    // ignore: avoid_print
    print('[Database] Checkpoint failed for $logicalName: $e');
  }
}
