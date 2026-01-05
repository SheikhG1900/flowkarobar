import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';

// Database provider - single instance
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  
  // Dispose when provider is destroyed
  ref.onDispose(() {
    database.close();
  });
  
  return database;
});



