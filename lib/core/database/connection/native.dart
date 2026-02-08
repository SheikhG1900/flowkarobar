import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

QueryExecutor openConnection(String fileName) {
  return driftDatabase(
    name: fileName.replaceAll('.db', ''),
  );
}
