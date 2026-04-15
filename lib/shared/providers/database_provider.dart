import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:drift/drift.dart';

// Database instance cache to prevent multiple instances during Phoenix restart
AppDatabase? _cachedDatabase;
String? _cachedDbPath;

/// Clears the cached database instance.
/// Call this before deleting the database file or performing a hard reset.
void clearDatabaseCache() {
  _cachedDatabase = null;
  _cachedDbPath = null;
}

// Database provider - reactive to active cashbook
final databaseProvider = Provider<AppDatabase>((ref) {
  // Watch active cashbook to recreate database on switch
  final activeCashbook = ref.watch(activeCashbookProvider);

  if (_cachedDatabase != null && _cachedDbPath == activeCashbook.dbPath) {
    return _cachedDatabase!;
  }

  // We set dontWarnAboutMultipleDatabases to true because we often open 
  // temporary connections for summary calculations during switches/syncs.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  
  _cachedDatabase = AppDatabase(fileName: activeCashbook.dbPath);
  _cachedDbPath = activeCashbook.dbPath;

  // Dispose when provider is destroyed or active cashbook changes
  ref.onDispose(() {
    // We DON'T close the database here because Phoenix.rebirth() will immediately
    // re-request this provider. If we close it, the next request might fail
    // or cause race conditions with the underlying SQLite connection.
    // The cache is cleared only if the dbPath actually changes.
  });

  return _cachedDatabase!;
});
