import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/backup/data/google_drive_service.dart';
import 'package:flowpaisa/features/backup/data/sync/sync_engine.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/features/notifications/presentation/providers/notification_provider.dart';
import 'package:flowpaisa/features/transactions/data/schedules_repository.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/schedule_service_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/features/receivables/data/receivables_repository.dart';
import 'package:flowpaisa/features/payables/data/payables_repository.dart';
import 'package:flowpaisa/features/categories/data/categories_repository.dart';
import 'package:flowpaisa/features/contacts/data/contacts_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart' as import_device_info;
import 'package:drift/drift.dart';
import 'dart:io';

const String syncTaskName = 'com.flowpaisa.app.sync_task';

@pragma('vm:entry-point')
Future<bool> handleSyncTask(String task, Map<String, dynamic>? inputData) async {
  if (kDebugMode) {
    print('SyncScheduler: handleSyncTask started for task: $task');
  }
  try {
    final prefs = await SharedPreferences.getInstance();

    // Try to get localization for background task
    AppLocalizations? l10n;
    try {
      final localeCode = prefs.getString('language_code') ?? 'en';
      l10n = await AppLocalizations.delegate.load(Locale(localeCode));
    } catch (e) {
      if (kDebugMode) {
        print('SyncScheduler: Could not load l10n for background task: $e');
      }
    }

    final cashbooksJson = prefs.getStringList('cashbooks_list');
    if (cashbooksJson == null || cashbooksJson.isEmpty) {
      if (kDebugMode) {
        print('SyncScheduler: No cashbooks found in SharedPreferences');
      }
      return true;
    }

    final driveService = GoogleDriveService();
    if (kDebugMode) {
      print('SyncScheduler: Initializing Drive service...');
    }
    await driveService.init();

    // In background, init() might not be enough if silent sign-in fails
    if (!driveService.isSignedIn) {
      if (kDebugMode) {
        print(
            'SyncScheduler: Drive service not signed in, attempting silent sign-in again...');
      }
      // Note: In background, we cannot show UI for sign-in.
      // If this fails, sync cannot proceed.
      if (!driveService.isSignedIn) {
        if (kDebugMode) {
          print(
              'SyncScheduler: Error - Drive service still not signed in. Aborting.');
        }
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
        if (kDebugMode) {
          print('SyncScheduler: Error decoding cashbook: $e');
        }
        rethrow;
      }
    }).toList();

    int syncedCount = 0;

    for (final cashbook in cashbooks) {
      if (kDebugMode) {
        print(
            'SyncScheduler: Background sync starting for: ${cashbook.name} (DB: ${cashbook.dbPath})');
      }

      await prefs.setString('sync_status_${cashbook.id}', 'Syncing...');
      // Force reload to ensure other isolates see the change
      await prefs.reload();

      final db = AppDatabase(fileName: '${cashbook.dbPath}.db');

      // Update progress in database and SharedPreferences
      final deviceId = await _getDeviceId();
      await _updateSyncStatus(db, deviceId, 'Syncing...', isStarting: true);
      try {
        final schedulesRepository = SchedulesRepository(db);
        final scheduleService = ScheduleService(
          database: db,
          schedulesRepository: schedulesRepository,
          transactionsRepository: TransactionsRepository(db),
          transactionService: TransactionService(
            database: db,
            transactionsRepository: TransactionsRepository(db),
            receivablesRepository: ReceivablesRepository(db),
            payablesRepository: PayablesRepository(db),
            categoriesRepository: CategoriesRepository(db),
            contactsRepository: ContactsRepository(db),
          ),
        );
        final activeSchedules = await schedulesRepository.getActiveSchedules();
        for (final schedule in activeSchedules) {
          await scheduleService.generateTransactionsFromSchedule(schedule.uuid);
        }
      } catch (e) {
        if (kDebugMode) {
          print(
              'SyncScheduler: Error processing schedules for ${cashbook.name}: $e');
        }
      }

      // 2. Check for overdue payables and receivables
      try {
        final payablesRepo = PayablesRepository(db);
        final receivablesRepo = ReceivablesRepository(db);

        final overduePayables = await payablesRepo.getOverduePayables();
        for (final p in overduePayables) {
          await NotificationNotifier.addNotificationStatic(
            title: l10n?.payableOverdue ?? 'Payable Overdue',
            message: l10n != null
                ? l10n.payableOverdueMessage(
                    p.description ?? (l10n.payable), p.dueDate?.toString() ?? '')
                : 'Payment for ${p.description ?? 'Payable'} was due on ${p.dueDate}',
            type: NotificationType.payable,
            isUrgent: true,
          );
        }

        final overdueReceivables =
            await receivablesRepo.getOverdueReceivables();
        for (final r in overdueReceivables) {
          await NotificationNotifier.addNotificationStatic(
            title: l10n?.receivableOverdue ?? 'Receivable Overdue',
            message: l10n != null
                ? l10n.receivableOverdueMessage(
                    r.description ?? (l10n.receivable),
                    r.dueDate?.toString() ?? '')
                : 'Payment for ${r.description ?? 'Receivable'} was due on ${r.dueDate}',
            type: NotificationType.receivable,
            isUrgent: true,
          );
        }

        // 2.1 Check for upcoming payables (due within 24 hours)
        final upcomingPayables = await payablesRepo.getUpcomingPayables(days: 1);
        for (final p in upcomingPayables) {
          await NotificationNotifier.addNotificationStatic(
            title: l10n?.upcomingPayable ?? 'Upcoming Payable',
            message: l10n != null
                ? l10n.upcomingPayableMessage(
                    p.description ?? (l10n.payable), p.dueDate?.toString() ?? '')
                : 'Payment for ${p.description ?? 'Payable'} is due tomorrow (${p.dueDate})',
            type: NotificationType.payable,
          );
        }

        // 2.2 Check for upcoming receivables (due within 24 hours)
        final upcomingReceivables =
            await receivablesRepo.getUpcomingReceivables(days: 1);
        for (final r in upcomingReceivables) {
          await NotificationNotifier.addNotificationStatic(
            title: l10n?.upcomingReceivable ?? 'Upcoming Receivable',
            message: l10n != null
                ? l10n.upcomingReceivableMessage(
                    r.description ?? (l10n.receivable),
                    r.dueDate?.toString() ?? '')
                : 'Payment for ${r.description ?? 'Receivable'} is due tomorrow (${r.dueDate})',
            type: NotificationType.receivable,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print(
              'SyncScheduler: Error checking overdue items for ${cashbook.name}: $e');
        }
      }

      // 3. Run sync engine
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
        if (kDebugMode) {
          print('SyncScheduler: Background sync finished for: ${cashbook.name}');
        }
      } catch (e) {
        await prefs.setString('sync_status_${cashbook.id}', 'Error: $e');
        await prefs.reload();
        if (kDebugMode) {
          print('SyncScheduler: Sync failed for ${cashbook.name}: $e');
        }
      } finally {
        await db.close();
      }
    }

    // Add local notification for background completion
    if (syncedCount > 0) {
      if (kDebugMode) {
        print(
            'SyncScheduler: Adding notification for $syncedCount synced cashbooks');
      }
      await NotificationNotifier.addNotificationStatic(
        title:
            l10n?.notificationSyncCompleteTitle ?? 'Background Sync Complete',
        message: l10n?.notificationSyncCompleteMessage(syncedCount) ??
            'Successfully synced $syncedCount cashbook(s) in the background.',
        type: NotificationType.sync,
      );
    }

    return true;
  } catch (e, stack) {
    if (kDebugMode) {
      print('SyncScheduler: Background sync fatal error: $e');
      print('SyncScheduler: Stack trace: $stack');
    }
    return false;
  }
}

Future<String> _getDeviceId() async {
  final deviceInfo = import_device_info.DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor ?? 'unknown_ios';
  }
  return 'unknown_device';
}

Future<void> _updateSyncStatus(AppDatabase db, String deviceId, String status,
    {bool isStarting = false}) async {
  try {
    if (kDebugMode) {
      print('SyncScheduler: Updating sync status to $status for device $deviceId');
    }
    await (db.update(db.syncMetadata)..where((t) => t.deviceId.equals(deviceId)))
        .write(SyncMetadataCompanion(
      syncStatus: Value(status),
      syncStartedAt:
          isStarting ? Value(DateTime.now().toUtc()) : const Value.absent(),
      // Ensure we don't touch other fields
      version: const Value.absent(),
      cloudVersion: const Value.absent(),
    ));
  } catch (e) {
    if (kDebugMode) {
      print('SyncScheduler: Failed to update sync status in DB: $e');
    }
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

    // ALWAYS register the permanent schedule processing task on init
    // This runs every 24 hours regardless of sync settings
    await Workmanager().registerPeriodicTask(
      'permanent-schedule-processing',
      'schedule-transactions',
      frequency: const Duration(hours: 24),
      constraints: Constraints(
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
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
    if (kDebugMode) {
      print('Triggering on-demand sync task...');
    }
    await Workmanager().registerOneOffTask(
      'on-demand-sync-${DateTime.now().millisecondsSinceEpoch}',
      syncTaskName,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.append,
    );
  }
}
