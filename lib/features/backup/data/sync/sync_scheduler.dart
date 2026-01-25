import 'package:workmanager/workmanager.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/backup/data/google_drive_service.dart';
import 'package:flowpaisa/features/backup/data/sync/sync_engine.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/features/notifications/presentation/providers/notification_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String syncTaskName = 'com.flowpaisa.app.sync_task';

@pragma('vm:entry-point')
Future<bool> handleSyncTask(String task, Map<String, dynamic>? inputData) async {
  print('SyncScheduler: handleSyncTask started for task: $task');
  try {
    final prefs = await SharedPreferences.getInstance();
    final cashbooksJson = prefs.getStringList('cashbooks_list');
    if (cashbooksJson == null || cashbooksJson.isEmpty) {
      print('SyncScheduler: No cashbooks found in SharedPreferences');
      return true;
    }

    final driveService = GoogleDriveService();
    print('SyncScheduler: Initializing Drive service...');
    await driveService.init();
    
    // In background, init() might not be enough if silent sign-in fails
    if (!driveService.isSignedIn) {
      print('SyncScheduler: Drive service not signed in, attempting silent sign-in again...');
      // Note: In background, we cannot show UI for sign-in.
      // If this fails, sync cannot proceed.
      if (!driveService.isSignedIn) {
        print('SyncScheduler: Error - Drive service still not signed in. Aborting.');
        return true;
      }
    }

    final cashbooks = cashbooksJson.map((j) {
      try {
        // The error suggests j is already a Map<String, dynamic>
        // but the list is defined as List<String>.
        final dynamic item = j;
        if (item is String) {
          return Cashbook.fromJson(item);
        } else if (item is Map<String, dynamic>) {
          return Cashbook.fromMap(item);
        }
        throw 'Unknown type: ${item.runtimeType}';
      } catch (e) {
        print('SyncScheduler: Error decoding cashbook: $e');
        rethrow;
      }
    }).toList();

    int syncedCount = 0;
    
    for (final cashbook in cashbooks) {
      print('SyncScheduler: Background sync starting for: ${cashbook.name} (DB: ${cashbook.dbPath})');
      
      // Update progress in SharedPreferences
      await prefs.setString('sync_status_${cashbook.id}', 'Syncing...');
      
      final db = AppDatabase(fileName: cashbook.dbPath);
      final syncEngine = SyncEngine(
        db: db,
        driveService: driveService,
        cashbook: cashbook,
      );
      try {
        await syncEngine.sync();
        syncedCount++;
        // The SyncEngine now handles setting 'Success' status internally
        // to ensure it happens even if push is blocked but pull succeeded.
        print('SyncScheduler: Background sync finished for: ${cashbook.name}');
      } catch (e) {
        await prefs.setString('sync_status_${cashbook.id}', 'Error: $e');
        print('SyncScheduler: Sync failed for ${cashbook.name}: $e');
      } finally {
        await db.close();
      }
    }

    // Add local notification for background completion
    if (syncedCount > 0) {
      print('SyncScheduler: Adding notification for $syncedCount synced cashbooks');
      await NotificationNotifier.addNotificationStatic(
        title: 'Background Sync Complete',
        message: 'Successfully synced $syncedCount cashbook(s) in the background.',
        type: NotificationType.sync,
      );
    }

    return true;
  } catch (e, stack) {
    print('SyncScheduler: Background sync fatal error: $e');
    print('SyncScheduler: Stack trace: $stack');
    return false;
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == syncTaskName || task.startsWith('on-demand-sync-')) {
      return await handleSyncTask(task, inputData);
    }
    return true;
  });
}

class SyncScheduler {
  static Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static Future<void> scheduleDailySync() async {
    final prefs = await SharedPreferences.getInstance();
    final syncInterval = prefs.getString('sync_interval') ?? 'manual';
    
    if (syncInterval == 'manual') {
      await Workmanager().cancelByUniqueName('daily-sync');
      return;
    }

    final intervalHours = int.tryParse(syncInterval) ?? 24;

    await Workmanager().registerPeriodicTask(
      'daily-sync',
      syncTaskName,
      frequency: Duration(hours: intervalHours),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  static Future<void> triggerOnDemandSync() async {
    print('Triggering on-demand sync task...');
    await Workmanager().registerOneOffTask(
      'on-demand-sync-${DateTime.now().millisecondsSinceEpoch}',
      syncTaskName,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
