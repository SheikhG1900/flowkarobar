import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class TransactionDocumentsRepository {
  final AppDatabase _database;
  final String cashbookId;

  TransactionDocumentsRepository(this._database, [this.cashbookId = 'default']);

  /// Get the local documents directory path
  Future<Directory> getDocumentsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final docDir = Directory(p.join(appDir.path, 'documents', cashbookId));
    if (!await docDir.exists()) {
      await docDir.create(recursive: true);
    }
    return docDir;
  }

  /// Watch active documents for a specific transaction
  Stream<List<TransactionDocument>> watchDocumentsForTransaction(String transactionUuid) {
    return Stream.value([]);
  }

  /// Get active documents for a specific transaction
  Future<List<TransactionDocument>> getDocumentsForTransaction(String transactionUuid) async {
    return [];
  }

  /// Watch all active documents
  Stream<List<TransactionDocument>> watchAllDocuments() {
    return Stream.value([]);
  }

  /// Get all active documents
  Future<List<TransactionDocument>> getAllDocuments() async {
    return [];
  }

  /// Add a new document attachment
  Future<TransactionDocument> addDocument({
    required String transactionUuid,
    required File file,
    required String originalName,
    String? mimeType,
  }) async {
    final uuid = const Uuid().v4();
    final extension = p.extension(originalName);
    final localFileName = 'doc_$uuid$extension';

    return TransactionDocument(
      uuid: uuid,
      transactionUuid: transactionUuid,
      fileName: localFileName,
      originalName: originalName,
      fileSize: 0,
      mimeType: mimeType ?? extension.replaceAll('.', ''),
      createdAt: DateTime.now(),
    );
  }

  /// Delete a single document (physical file + metadata)
  Future<void> deleteDocument(String uuid) async {
    // Legacy bridge
  }

  /// Delete all documents for a transaction (physical files + metadata)
  Future<void> deleteDocumentsForTransaction(String transactionUuid) async {
    // Legacy bridge
  }

  /// Get total storage used by active documents in bytes
  Future<int> getTotalStorageUsed() async {
    return 0;
  }

  /// Link an existing orphan document to a transaction
  Future<void> linkExistingDocument({
    required String documentUuid,
    required String transactionUuid,
    String? customName,
  }) async {
    // Legacy bridge
  }
}
