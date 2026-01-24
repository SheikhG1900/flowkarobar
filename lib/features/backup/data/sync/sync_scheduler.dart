import 'package:workmanager/workmanager.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/backup/data/google_drive_service.dart';
import 'package:flowpaisa/features/backup/data/sync/sync_engine.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const String syncTaskName = 'com.flowpaisa.app.sync_task';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == syncTaskName) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cashbooksJson = prefs.getStringList('cashbooks_list');
        if (cashbooksJson == null || cashbooksJson.isEmpty) return true;

        final driveService = GoogleDriveService();
        await driveService.init();
        if (!driveService.isSignedIn) return true;

        final cashbooks = cashbooksJson.map((j) => Cashbook.fromJson(json.decode(j))).toList();

        for (final cashbook in cashbooks) {
          final db = AppDatabase(fileName: cashbook.dbPath);
          final syncEngine = SyncEngine(
            db: db,
            driveService: driveService,
            cashbook: cashbook,
          );
          await syncEngine.sync();
          await db.close();
        }
        return true;
      } catch (e) {
        print('Background sync failed: $e');
        return false;
      }
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
    await Workmanager().registerOneOffTask(
      'on-demand-sync-${DateTime.now().millisecondsSinceEpoch}',
      syncTaskName,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
