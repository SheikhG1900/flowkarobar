import 'package:workmanager/workmanager.dart';
import 'package:flowpaisa/features/transactions/data/schedule_scheduler.dart';
import 'package:flowpaisa/features/backup/data/sync/sync_scheduler.dart';

/// Unified background task callback for workmanager
/// This is the single entry point for all background tasks in the app.
@pragma('vm:entry-point')
void universalCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // 1. Handle Sync Tasks
    if (task == syncTaskName || task.startsWith('on-demand-sync-')) {
      return await handleSyncTask(task, inputData);
    }

    // 2. Handle Schedule Tasks
    if (task == 'schedule-transactions') {
      await processSchedules();
      return Future.value(true);
    }

    return Future.value(true);
  });
}
