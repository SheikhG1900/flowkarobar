import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class TransactionDocumentsRepository {
  final AppDatabase _database;

  TransactionDocumentsRepository(this._database);

  /// Get the local documents directory path
  Future<Directory> getDocumentsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final docDir = Directory(p.join(appDir.path, 'documents'));
    if (!await docDir.exists()) {
      await docDir.create(recursive: true);
    }
    return docDir;
  }

  /// Watch active documents for a specific transaction
  Stream<List<TransactionDocument>> watchDocumentsForTransaction(String transactionUuid) {
    return (_database.select(_database.transactionDocuments)
          ..where((d) => d.transactionUuid.equals(transactionUuid) & d.isDeleted.equals(false))
          ..orderBy([(d) => OrderingTerm.desc(d.createdAt)]))
        .watch();
  }

  /// Get active documents for a specific transaction
  Future<List<TransactionDocument>> getDocumentsForTransaction(String transactionUuid) {
    return (_database.select(_database.transactionDocuments)
          ..where((d) => d.transactionUuid.equals(transactionUuid) & d.isDeleted.equals(false))
          ..orderBy([(d) => OrderingTerm.desc(d.createdAt)]))
        .get();
  }

  /// Watch all active documents
  Stream<List<TransactionDocument>> watchAllDocuments() {
    return (_database.select(_database.transactionDocuments)
          ..where((d) => d.isDeleted.equals(false))
          ..orderBy([(d) => OrderingTerm.desc(d.createdAt)]))
        .watch();
  }

  /// Get all active documents
  Future<List<TransactionDocument>> getAllDocuments() {
    return (_database.select(_database.transactionDocuments)
          ..where((d) => d.isDeleted.equals(false))
          ..orderBy([(d) => OrderingTerm.desc(d.createdAt)]))
        .get();
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

    // 1. Copy the physical file to local documents directory
    final docDir = await getDocumentsDirectory();
    final localFile = File(p.join(docDir.path, localFileName));
    await file.copy(localFile.path);

    // 2. Insert metadata into the database
    final fileSize = await file.length();
    final companion = TransactionDocumentsCompanion(
      uuid: Value(uuid),
      transactionUuid: Value(transactionUuid),
      fileName: Value(localFileName),
      originalName: Value(originalName),
      fileSize: Value(fileSize),
      mimeType: Value(mimeType ?? extension.replaceAll('.', '')),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      isDeleted: const Value(false),
      isNotSynced: const Value(true),
    );

    await _database.into(_database.transactionDocuments).insert(companion);

    return TransactionDocument(
      uuid: uuid,
      transactionUuid: transactionUuid,
      fileName: localFileName,
      originalName: originalName,
      fileSize: fileSize,
      mimeType: mimeType ?? extension.replaceAll('.', ''),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: false,
      isNotSynced: true,
    );
  }

  /// Delete a single document (physical file + metadata)
  Future<void> deleteDocument(String uuid) async {
    final doc = await (_database.select(_database.transactionDocuments)
          ..where((d) => d.uuid.equals(uuid)))
        .getSingleOrNull();

    if (doc != null) {
      // 1. Delete physical file
      final docDir = await getDocumentsDirectory();
      final file = File(p.join(docDir.path, doc.fileName));
      if (await file.exists()) {
        await file.delete();
      }

      // 2. Soft-delete row in database
      await (_database.update(_database.transactionDocuments)
            ..where((d) => d.uuid.equals(uuid)))
          .write(const TransactionDocumentsCompanion(
        isDeleted: Value(true),
        isNotSynced: Value(true),
      ));
    }
  }

  /// Delete all documents for a transaction (physical files + metadata)
  Future<void> deleteDocumentsForTransaction(String transactionUuid) async {
    final docs = await getDocumentsForTransaction(transactionUuid);
    final docDir = await getDocumentsDirectory();

    for (final doc in docs) {
      // 1. Delete physical file
      final file = File(p.join(docDir.path, doc.fileName));
      if (await file.exists()) {
        await file.delete();
      }

      // 2. Soft-delete row in database
      await (_database.update(_database.transactionDocuments)
            ..where((d) => d.uuid.equals(doc.uuid)))
          .write(const TransactionDocumentsCompanion(
        isDeleted: Value(true),
        isNotSynced: Value(true),
      ));
    }
  }

  /// Get total storage used by active documents in bytes
  Future<int> getTotalStorageUsed() async {
    final query = _database.selectOnly(_database.transactionDocuments)
      ..addColumns([_database.transactionDocuments.fileSize.sum()])
      ..where(_database.transactionDocuments.isDeleted.equals(false));

    final result = await query.getSingle();
    return result.read(_database.transactionDocuments.fileSize.sum()) ?? 0;
  }

  /// Link an existing orphan document to a transaction
  Future<void> linkExistingDocument({
    required String documentUuid,
    required String transactionUuid,
    String? customName,
  }) async {
    // 1. Check if the document exists in the database
    final existing = await (_database.select(_database.transactionDocuments)
          ..where((d) => d.uuid.equals(documentUuid)))
        .getSingleOrNull();

    if (existing != null) {
      // Update existing row
      await (_database.update(_database.transactionDocuments)
            ..where((d) => d.uuid.equals(documentUuid)))
          .write(TransactionDocumentsCompanion(
        transactionUuid: Value(transactionUuid),
        originalName: customName != null ? Value(customName) : const Value.absent(),
        isDeleted: const Value(false),
        isNotSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));
    } else {
      // If it's a physical-only orphan (not in DB yet), insert it
      final docDir = await getDocumentsDirectory();
      final file = File(p.join(docDir.path, documentUuid)); // documentUuid is the fileName for physical-only orphans
      if (await file.exists()) {
        final extension = p.extension(documentUuid);
        final companion = TransactionDocumentsCompanion(
          uuid: Value(const Uuid().v4()),
          transactionUuid: Value(transactionUuid),
          fileName: Value(documentUuid),
          originalName: Value(customName ?? documentUuid),
          fileSize: Value(await file.length()),
          mimeType: Value(extension.replaceAll('.', '')),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
          isDeleted: const Value(false),
          isNotSynced: const Value(true),
        );
        await _database.into(_database.transactionDocuments).insert(companion);
      }
    }
  }
}
