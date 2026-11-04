import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/businesses/presentation/providers/business_provider.dart';
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

// Database provider - reactive to active business
final databaseProvider = Provider<AppDatabase>((ref) {
  // Watch active business to recreate database on switch
  final activeBusiness = ref.watch(activeBusinessProvider);

  if (_cachedDatabase != null && _cachedDbPath == activeBusiness.dbPath) {
    return _cachedDatabase!;
  }

  // We set dontWarnAboutMultipleDatabases to true because we often open 
  // temporary connections for summary calculations during switches/syncs.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  
  _cachedDatabase = AppDatabase(fileName: '${activeBusiness.dbPath}.db');
  _cachedDbPath = activeBusiness.dbPath;

  // Dispose when provider is destroyed or active business changes
  ref.onDispose(() {
    // We DON'T close the database here because Phoenix.rebirth() will immediately
    // re-request this provider. If we close it, the next request might fail
    // or cause race conditions with the underlying SQLite connection.
    // The cache is cleared only if the dbPath actually changes.
  });

  return _cachedDatabase!;
});
