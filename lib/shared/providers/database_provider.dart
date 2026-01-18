import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';

// Database provider - reactive to active cashbook
final databaseProvider = Provider<AppDatabase>((ref) {
  // Watch active cashbook to recreate database on switch
  final activeCashbook = ref.watch(activeCashbookProvider);
  
  final database = AppDatabase(fileName: activeCashbook.dbPath);
  
  // Dispose when provider is destroyed or active cashbook changes
  ref.onDispose(() {
    database.close();
  });
  
  return database;
});
