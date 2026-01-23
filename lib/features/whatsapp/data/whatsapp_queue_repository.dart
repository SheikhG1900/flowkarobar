import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';

class WhatsAppQueueRepository {
  final AppDatabase _database;

  WhatsAppQueueRepository(this._database);

  /// Add a message to the queue
  Future<int> queueMessage({
    required String contactUuid,
    required String message,
    String? deepLink,
  }) {
    return _database.into(_database.whatsAppQueue).insert(
          WhatsAppQueueCompanion(
            contactUuid: Value(contactUuid),
            message: Value(message),
            deepLink: Value(deepLink),
            status: const Value('PENDING'),
          ),
        );
  }

  /// Get all pending messages
  Future<List<WhatsAppQueueData>> getPendingMessages() {
    return (_database.select(_database.whatsAppQueue)
          ..where((q) => q.status.equals('PENDING'))
          ..orderBy([(q) => OrderingTerm.asc(q.createdAt)]))
        .get();
  }

  /// Mark a message as sent
  Future<bool> markAsSent(int id) async {
    final result = await (_database.update(_database.whatsAppQueue)
          ..where((q) => q.id.equals(id)))
        .write(const WhatsAppQueueCompanion(status: Value('SENT')));
    return result > 0;
  }

  /// Mark a message as failed
  Future<bool> markAsFailed(int id) async {
    final result = await (_database.update(_database.whatsAppQueue)
          ..where((q) => q.id.equals(id)))
        .write(const WhatsAppQueueCompanion(status: Value('FAILED')));
    return result > 0;
  }

  /// Delete a message from the queue
  Future<int> deleteMessage(int id) {
    return (_database.delete(_database.whatsAppQueue)
          ..where((q) => q.id.equals(id)))
        .go();
  }

  /// Get all messages (for history/debugging)
  Future<List<WhatsAppQueueData>> getAllMessages() {
    return (_database.select(_database.whatsAppQueue)
          ..orderBy([(q) => OrderingTerm.desc(q.createdAt)]))
        .get();
  }

  /// Clear sent messages older than specified days
  Future<int> clearOldMessages({int daysOld = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    return (_database.delete(_database.whatsAppQueue)
          ..where((q) =>
              q.status.equals('SENT') & q.createdAt.isSmallerThanValue(cutoffDate)))
        .go();
  }
}

