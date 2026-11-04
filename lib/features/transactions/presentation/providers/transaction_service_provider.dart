import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/receivables/data/receivables_repository.dart';
import 'package:flowpaisa/features/payables/data/payables_repository.dart';
import 'package:flowpaisa/features/categories/data/categories_repository.dart';
import 'package:flowpaisa/features/contacts/data/contacts_repository.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService(
    database: ref.watch(databaseProvider),
    transactionsRepository: ref.watch(transactionsRepositoryProvider),
    receivablesRepository: ref.watch(receivablesRepositoryProvider),
    payablesRepository: ref.watch(payablesRepositoryProvider),
    categoriesRepository: ref.watch(categoriesRepositoryProvider),
    contactsRepository: ref.watch(contactsRepositoryProvider),
  );
});

class TransactionService {
  final AppDatabase database;
  final TransactionsRepository transactionsRepository;
  final ReceivablesRepository receivablesRepository;
  final PayablesRepository payablesRepository;
  final CategoriesRepository categoriesRepository;
  final ContactsRepository contactsRepository;

  TransactionService({
    required this.database,
    required this.transactionsRepository,
    required this.receivablesRepository,
    required this.payablesRepository,
    required this.categoriesRepository,
    required this.contactsRepository,
  });

  Future<void> updateTransactionAccount(String uuid, String? accountUuid) async {
    await transactionsRepository.updateTransactionWithCompanion(
      uuid,
      TransactionsCompanion(
        accountUuid: drift.Value(accountUuid),
      ),
    );
  }

  Future<void> updateTransactionCategory(String uuid, String? categoryUuid) async {
    await transactionsRepository.updateTransactionWithCompanion(
      uuid,
      TransactionsCompanion(
        categoryUuid: drift.Value(categoryUuid),
      ),
    );
  }

  Future<void> updateTransactionDate(String uuid, DateTime date) async {
    await transactionsRepository.updateTransactionWithCompanion(
      uuid,
      TransactionsCompanion(
        date: drift.Value(date),
      ),
    );
  }

  Future<void> updateTransactionDescription(String uuid, String? description) async {
    await transactionsRepository.updateTransactionWithCompanion(
      uuid,
      TransactionsCompanion(
        description: drift.Value(description),
      ),
    );
  }

  Future<void> updateTransaction({
    required String transactionUuid,
    required double amount,
    required String type,
    required DateTime date,
    String? description,
    String? contactUuid,
    String? categoryUuid,
    String? accountUuid,
    String? paidRelationship,
    DateTime? dueDate,
    bool isPending = false,
  }) async {
    await transactionsRepository.updateTransactionWithCompanion(
      transactionUuid,
      TransactionsCompanion(
        amount: drift.Value(amount),
        type: drift.Value(type),
        date: drift.Value(date),
        description: drift.Value(description),
        contactUuid: drift.Value(contactUuid),
        categoryUuid: drift.Value(categoryUuid),
        accountUuid: drift.Value(accountUuid),
      ),
    );
  }

  Future<void> updateGroupSplit({required List<dynamic> transactions}) async {
    // Legacy stub
  }

  Future<String> addTransaction(TransactionsCompanion transaction, {dynamic payable, dynamic receivable}) async {
    return await transactionsRepository.createTransaction(transaction);
  }

  Future<void> deleteTransaction(String uuid) async {
    await transactionsRepository.deleteTransaction(uuid);
  }

  Future<String?> getDeepLinkForTransaction(String uuid, AppLocalizations l10n) async {
    return null;
  }

  Future<String?> getDeepLinkForPayable(String uuid, AppLocalizations l10n) async {
    return null;
  }

  Future<String?> getDeepLinkForReceivable(String uuid, AppLocalizations l10n) async {
    return null;
  }

  Future<void> generateDummyTransactions({int count = 100}) async {}

  Future<void> createGroupSplit({
    required double totalAmount,
    required String type,
    required DateTime date,
    required List<dynamic> shares,
    String? description,
    String? categoryUuid,
    String? accountUuid,
    String? paidRelationship,
    DateTime? dueDate,
  }) async {}

  Future<String> createTransaction({
    required double amount,
    required String type,
    required DateTime date,
    String? description,
    String? contactUuid,
    String? categoryUuid,
    String? paidRelationship,
    bool createLinkedEntry = false,
    DateTime? dueDate,
    String? externalLinkId,
    double? myShareAmount,
    bool isSplitMode = false,
    bool isImport = false,
    dynamic l10n,
    String? accountUuid,
    bool isPending = false,
  }) async {
    final companion = TransactionsCompanion(
      uuid: drift.Value(const Uuid().v4()),
      amount: drift.Value(amount),
      type: drift.Value(type),
      date: drift.Value(date),
      description: drift.Value(description),
      contactUuid: drift.Value(contactUuid),
      categoryUuid: drift.Value(categoryUuid),
      accountUuid: drift.Value(accountUuid),
      processedDate: drift.Value(isPending ? null : DateTime.now()),
    );
    await transactionsRepository.createTransaction(companion);
    return companion.uuid.value;
  }

  Future<void> markAsProcessed(String uuid) async {
    await transactionsRepository.updateTransactionWithCompanion(
      uuid,
      TransactionsCompanion(
        processedDate: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> markTransactionAsReviewed(String uuid) async {}

  Future<String> ensureExternalLinkId(String uuid) async => '';
}
