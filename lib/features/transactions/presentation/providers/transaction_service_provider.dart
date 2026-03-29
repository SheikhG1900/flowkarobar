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
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

import 'package:flutter/foundation.dart';

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

  Future<String> createTransaction({
    required double amount,
    required String type,
    required DateTime date,
    String? description,
    String? categoryUuid,
    String? contactUuid,
    String?
        paidRelationship, // 'PAID_FOR', 'PAID_BY', 'RECEIVED_FROM', 'WILL_RECEIVE'
    bool createLinkedEntry = false,
    DateTime? dueDate,
    bool isScheduled = false,
    String? externalLinkId,
    String? transactionUuid,
    double? myShareAmount,
    bool isSplitMode = true,
    bool isImport = false,
    AppLocalizations? l10n,
    String? accountUuid,
    // processedDate: null = pending; defaults to date (processed immediately) for regular transactions
    DateTime? processedDate,
    bool isPending = false,
  }) async {
    return await database.transaction(() async {
      // 0. Determine UUIDs and optional linkedGroupId for split bills
      // Rule: transaction id = minified UUID (or scheduleId_date for scheduled); externalLinkId = same as transaction id
      String contactTxUuid;
      String? sharedLinkedGroupId;
      String effectiveExternalId;

      if (isImport && externalLinkId != null) {
        contactTxUuid = externalLinkId;
        effectiveExternalId = externalLinkId;
        // Imports do not use linkedGroupId; keep null
      } else if (transactionUuid != null && transactionUuid.isNotEmpty) {
        // Scheduled: id = scheduleId_date; externalLinkId = same
        contactTxUuid = transactionUuid;
        effectiveExternalId = contactTxUuid;
      } else {
        // Standard creation: use minified UUID; externalLinkId = same as transaction id
        contactTxUuid = DeepLinkService.newMinifiedUuid();
        effectiveExternalId = contactTxUuid;
        if (myShareAmount != null && myShareAmount > 0) {
          sharedLinkedGroupId = DeepLinkService.newMinifiedUuid();
        }
      }

      if (kDebugMode) {
        debugPrint('Transaction Service creating transaction');
        debugPrint('Is Import: $isImport');
        debugPrint('linkedGroupId: $sharedLinkedGroupId');
      }

      // Determine actual amounts for contact and user
      double contactAmount = amount;

      if (myShareAmount != null && myShareAmount > 0) {
        if (isSplitMode) {
          contactAmount = amount - myShareAmount;
        } else {
          contactAmount = amount;
        }
      }

      // Determine processedDate:
      // - PAID_BY / WILL_RECEIVE → null (money hasn't moved yet)
      // - isPending flag also forces null
      // - Otherwise: default to transaction date (processed immediately)
      final effectiveIsPending = isPending ||
          paidRelationship == 'PAID_BY' ||
          paidRelationship == 'WILL_RECEIVE';
      final effectiveProcessedDate = effectiveIsPending
          ? null
          : (processedDate ?? date);

      final createdTxUuid = await transactionsRepository.createTransaction(
        TransactionsCompanion(
          uuid: drift.Value(contactTxUuid),
          amount: drift.Value(contactAmount),
          type: drift.Value(type),
          contactUuid: drift.Value(contactUuid),
          categoryUuid: drift.Value(categoryUuid),
          description: drift.Value(description),
          date: drift.Value(date),
          paidRelationship: drift.Value(paidRelationship),
          isScheduled: drift.Value(isScheduled),
          linkedGroupId: drift.Value(sharedLinkedGroupId),
          externalLinkId: drift.Value(effectiveExternalId),
          accountUuid: drift.Value(accountUuid),
          processedDate: drift.Value(effectiveProcessedDate),
          createdAt: drift.Value(DateTime.now()),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );

      final shouldCreateLinks = createLinkedEntry || paidRelationship != null;

      // 1.1 Create "My Share" transaction if applicable (same linkedGroupId, minified UUID; externalLinkId = same)
      if (myShareAmount != null && myShareAmount > 0) {
        final userTxUuid = DeepLinkService.newMinifiedUuid();
        await transactionsRepository.createTransaction(
          TransactionsCompanion(
            uuid: drift.Value(userTxUuid),
            amount: drift.Value(myShareAmount),
            type: drift.Value(type),
            contactUuid: drift.Value(contactUuid),
            categoryUuid: drift.Value(categoryUuid),
            description: drift.Value(description),
            date: drift.Value(date),
            isScheduled: drift.Value(isScheduled),
            linkedGroupId: drift.Value(sharedLinkedGroupId),
            externalLinkId: drift.Value(userTxUuid),
            accountUuid: drift.Value(accountUuid),
            processedDate: drift.Value(effectiveProcessedDate),
            createdAt: drift.Value(DateTime.now()),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
        if (contactUuid != null) {
          await contactsRepository.incrementUsageCount(contactUuid);
        }
      }

      // 2. Increment usage counts
      if (categoryUuid != null) {
        await categoriesRepository.incrementUsageCount(categoryUuid);
      }
      if (contactUuid != null) {
        await contactsRepository.incrementUsageCount(contactUuid);
      }

      // 3. Create linked entries based on logic (using contactAmount); id = tx_rec / tx_pay, externalLinkId = tx id
      if (shouldCreateLinks && contactUuid != null) {
        // --- EXPENSE LOGIC ---
        if (type == 'EXPENSE') {
          if (paidRelationship == 'PAID_FOR') {
            final String receivableUuid =
                await receivablesRepository.createReceivable(
              ReceivablesCompanion(
                uuid: drift.Value('${createdTxUuid}_rec'),
                contactUuid: drift.Value(contactUuid),
                amount: drift.Value(contactAmount),
                description: drift.Value(description),
                date: drift.Value(date),
                dueDate: drift.Value(dueDate),
                status: const drift.Value('PENDING'),
                linkedExpenseUuid: drift.Value(createdTxUuid),
                isScheduled: drift.Value(isScheduled),
                autoCreateIncome: const drift.Value(true),
                externalLinkId: drift.Value(createdTxUuid),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
            await transactionsRepository.updateTransactionWithCompanion(
              createdTxUuid,
              TransactionsCompanion(
                linkedReceivableUuid: drift.Value(receivableUuid),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          } else if (paidRelationship == 'PAID_BY') {
            final String payableUuid = await payablesRepository.createPayable(
              PayablesCompanion(
                uuid: drift.Value('${createdTxUuid}_pay'),
                contactUuid: drift.Value(contactUuid),
                amount: drift.Value(contactAmount),
                description: drift.Value(description),
                date: drift.Value(date),
                dueDate: drift.Value(dueDate),
                status: const drift.Value('PENDING'),
                linkedExpenseUuid: drift.Value(createdTxUuid),
                isScheduled: drift.Value(isScheduled),
                autoCreateExpense: const drift.Value(false),
                externalLinkId: drift.Value(createdTxUuid),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
            await transactionsRepository.updateTransactionWithCompanion(
              createdTxUuid,
              TransactionsCompanion(
                linkedPayableUuid: drift.Value(payableUuid),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          }
        }
        // --- INCOME LOGIC ---
        else if (type == 'INCOME') {
          if (paidRelationship == 'RECEIVED_FROM') {
            final String payableUuid = await payablesRepository.createPayable(
              PayablesCompanion(
                uuid: drift.Value('${createdTxUuid}_pay'),
                contactUuid: drift.Value(contactUuid),
                amount: drift.Value(contactAmount),
                description: drift.Value(description),
                date: drift.Value(date),
                dueDate: drift.Value(dueDate),
                status: const drift.Value('PENDING'),
                linkedIncomeUuid: drift.Value(createdTxUuid),
                isScheduled: drift.Value(isScheduled),
                autoCreateExpense: const drift.Value(true),
                externalLinkId: drift.Value(createdTxUuid),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
            await transactionsRepository.updateTransactionWithCompanion(
              createdTxUuid,
              TransactionsCompanion(
                linkedPayableUuid: drift.Value(payableUuid),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          } else if (paidRelationship == 'WILL_RECEIVE') {
            final String receivableUuid =
                await receivablesRepository.createReceivable(
              ReceivablesCompanion(
                uuid: drift.Value('${createdTxUuid}_rec'),
                contactUuid: drift.Value(contactUuid),
                amount: drift.Value(contactAmount),
                description: drift.Value(description),
                date: drift.Value(date),
                dueDate: drift.Value(dueDate),
                status: const drift.Value('PENDING'),
                linkedIncomeUuid: drift.Value(createdTxUuid),
                isScheduled: drift.Value(isScheduled),
                autoCreateIncome: const drift.Value(false),
                externalLinkId: drift.Value(createdTxUuid),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
            await transactionsRepository.updateTransactionWithCompanion(
              createdTxUuid,
              TransactionsCompanion(
                linkedReceivableUuid: drift.Value(receivableUuid),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          }
        }
      }
      return createdTxUuid;
    });
  }

  /// Create a group split transaction with multiple participants
  Future<void> createGroupSplit({
    required double totalAmount,
    required String type,
    required DateTime date,
    required List<SplitShare> shares,
    String? description,
    String? categoryUuid,
    String? accountUuid,
    String? paidRelationship,
    DateTime? dueDate,
  }) async {
    try {
      await database.transaction(() async {
        final linkedGroupId = DeepLinkService.newMinifiedUuid();

        // Same as createTransaction: PAID_BY / WILL_RECEIVE → pending (null); else processed on date
        final effectiveIsPending = paidRelationship == 'PAID_BY' ||
            paidRelationship == 'WILL_RECEIVE';
        final effectiveProcessedDate =
            effectiveIsPending ? null : date;

        for (int i = 0; i < shares.length; i++) {
          final share = shares[i];
          if (share.amount <= 0) continue;

          if (share.isUser) {
            final userTxUuid = DeepLinkService.newMinifiedUuid();
            await transactionsRepository.createTransaction(
              TransactionsCompanion(
                uuid: drift.Value(userTxUuid),
                amount: drift.Value(share.amount),
                type: drift.Value(type),
                categoryUuid: drift.Value(categoryUuid),
                description: drift.Value(description),
                date: drift.Value(date),
                accountUuid: drift.Value(accountUuid),
                linkedGroupId: drift.Value(linkedGroupId),
                externalLinkId: drift.Value(userTxUuid),
                processedDate: drift.Value(effectiveProcessedDate),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          } else if (share.contact != null) {
            final transactionUuid = DeepLinkService.newMinifiedUuid();
            await transactionsRepository.createTransaction(
              TransactionsCompanion(
                uuid: drift.Value(transactionUuid),
                amount: drift.Value(share.amount),
                type: drift.Value(type),
                contactUuid: drift.Value(share.contact!.uuid),
                categoryUuid: drift.Value(categoryUuid),
                description: drift.Value(description),
                date: drift.Value(date),
                accountUuid: drift.Value(accountUuid),
                paidRelationship: drift.Value(paidRelationship),
                linkedGroupId: drift.Value(linkedGroupId),
                externalLinkId: drift.Value(transactionUuid),
                processedDate: drift.Value(effectiveProcessedDate),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );

            // Create linked entry
            if (paidRelationship != null) {
              if (type == 'EXPENSE') {
                if (paidRelationship == 'PAID_FOR') {
                  final String receivableUuid = '${transactionUuid}_rec';
                  await receivablesRepository.createReceivable(
                    ReceivablesCompanion(
                      uuid: drift.Value(receivableUuid),
                      contactUuid: drift.Value(share.contact!.uuid),
                      amount: drift.Value(share.amount),
                      description: drift.Value(description),
                      date: drift.Value(date),
                      dueDate: drift.Value(dueDate),
                      status: const drift.Value('PENDING'),
                      linkedExpenseUuid: drift.Value(transactionUuid),
                      autoCreateIncome: const drift.Value(true),
                      externalLinkId: drift.Value(transactionUuid),
                      createdAt: drift.Value(DateTime.now()),
                      updatedAt: drift.Value(DateTime.now()),
                    ),
                  );
                  await transactionsRepository.updateTransactionWithCompanion(
                    transactionUuid,
                    TransactionsCompanion(
                      linkedReceivableUuid: drift.Value(receivableUuid),
                    ),
                  );
                } else if (paidRelationship == 'PAID_BY') {
                  final String payableUuid = '${transactionUuid}_pay';
                  await payablesRepository.createPayable(
                    PayablesCompanion(
                      uuid: drift.Value(payableUuid),
                      contactUuid: drift.Value(share.contact!.uuid),
                      amount: drift.Value(share.amount),
                      description: drift.Value(description),
                      date: drift.Value(date),
                      dueDate: drift.Value(dueDate),
                      status: const drift.Value('PENDING'),
                      linkedExpenseUuid: drift.Value(transactionUuid),
                      autoCreateExpense: const drift.Value(false),
                      externalLinkId: drift.Value(transactionUuid),
                      createdAt: drift.Value(DateTime.now()),
                      updatedAt: drift.Value(DateTime.now()),
                    ),
                  );
                  await transactionsRepository.updateTransactionWithCompanion(
                    transactionUuid,
                    TransactionsCompanion(
                      linkedPayableUuid: drift.Value(payableUuid),
                    ),
                  );
                }
              } else if (type == 'INCOME') {
                if (paidRelationship == 'RECEIVED_FROM') {
                  final String payableUuid = '${transactionUuid}_pay';
                  await payablesRepository.createPayable(
                    PayablesCompanion(
                      uuid: drift.Value(payableUuid),
                      contactUuid: drift.Value(share.contact!.uuid),
                      amount: drift.Value(share.amount),
                      description: drift.Value(description),
                      date: drift.Value(date),
                      dueDate: drift.Value(dueDate),
                      status: const drift.Value('PENDING'),
                      linkedIncomeUuid: drift.Value(transactionUuid),
                      autoCreateExpense: const drift.Value(true),
                      externalLinkId: drift.Value(transactionUuid),
                      createdAt: drift.Value(DateTime.now()),
                      updatedAt: drift.Value(DateTime.now()),
                    ),
                  );
                  await transactionsRepository.updateTransactionWithCompanion(
                    transactionUuid,
                    TransactionsCompanion(
                      linkedPayableUuid: drift.Value(payableUuid),
                    ),
                  );
                } else if (paidRelationship == 'WILL_RECEIVE') {
                  final String receivableUuid = '${transactionUuid}_rec';
                  await receivablesRepository.createReceivable(
                    ReceivablesCompanion(
                      uuid: drift.Value(receivableUuid),
                      contactUuid: drift.Value(share.contact!.uuid),
                      amount: drift.Value(share.amount),
                      description: drift.Value(description),
                      date: drift.Value(date),
                      dueDate: drift.Value(dueDate),
                      status: const drift.Value('PENDING'),
                      linkedIncomeUuid: drift.Value(transactionUuid),
                      autoCreateIncome: const drift.Value(false),
                      externalLinkId: drift.Value(transactionUuid),
                      createdAt: drift.Value(DateTime.now()),
                      updatedAt: drift.Value(DateTime.now()),
                    ),
                  );
                  await transactionsRepository.updateTransactionWithCompanion(
                    transactionUuid,
                    TransactionsCompanion(
                      linkedReceivableUuid: drift.Value(receivableUuid),
                    ),
                  );
                }
              }
            }

            // Increment usage counts
            await contactsRepository.incrementUsageCount(share.contact!.uuid);
          }
        }

        if (categoryUuid != null) {
          await categoriesRepository.incrementUsageCount(categoryUuid);
        }
      });
    } catch (e, stackTrace) {
      // Log the error for debugging
      if (kDebugMode) {
        debugPrint('Group Split Error: $e');
        debugPrint('Stack Trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// Returns all transactions in the same split group as the given transaction.
  /// If the transaction has no linkedGroupId, returns a list containing only that transaction with details.
  Future<List<TransactionWithDetails>> getGroupByTransactionUuid(
    String transactionUuid,
  ) async {
    final item = await transactionsRepository
        .getTransactionWithDetailsByUuid(transactionUuid);
    if (item == null) return [];
    final linkedGroupId = item.transaction.linkedGroupId;
    if (linkedGroupId == null || linkedGroupId.isEmpty) {
      return [item];
    }
    return transactionsRepository
        .getTransactionsWithDetailsByLinkedGroupId(linkedGroupId);
  }

  /// Updates a split group atomically: updates non-locked shares, removes non-locked shares not in [shares], adds new shares.
  /// [shares] is the full desired list. Each item with [transactionUuid] non-null is an existing row (update or keep);
  /// items with [transactionUuid] null are new. Existing DB rows in the group that are not in [shares] and not locked are deleted.
  Future<void> updateGroupSplit({
    required String linkedGroupId,
    required String type,
    required DateTime date,
    String? description,
    String? categoryUuid,
    String? paidRelationship,
    DateTime? dueDate,
    required List<GroupShareEdit> shares,
    /// When true (or PAID_BY / WILL_RECEIVE), [processedDate] is cleared for all rows in the group.
    bool isPending = false,
  }) async {
    await database.transaction(() async {
      final existing = await transactionsRepository
          .getTransactionsWithDetailsByLinkedGroupId(linkedGroupId);

      // Helper to find the effective relationship for new entries
      // We look for the first existing transaction that has a relationship defined.
      String? effectiveRelationship = paidRelationship;
      if (effectiveRelationship == null) {
        for (final e in existing) {
          if (e.transaction.paidRelationship != null) {
            effectiveRelationship = e.transaction.paidRelationship;
            break;
          }
        }
      }

      // Same as createTransaction: pending → null processedDate; else date
      final effectiveIsPending = isPending ||
          effectiveRelationship == 'PAID_BY' ||
          effectiveRelationship == 'WILL_RECEIVE';
      final effectiveProcessedDate =
          effectiveIsPending ? null : date;

      // 1. First, handle updates and additions to ensure we have relationship context
      // and to avoid issues if all existing records were to be deleted.

      // Handle Updates
      final desiredTxUuids = <String>{};
      for (final s in shares) {
        if (s.transactionUuid != null) desiredTxUuids.add(s.transactionUuid!);
      }

      for (final e in existing) {
        final txUuid = e.transaction.uuid;
        final locked = e.linkedPayable?.status == 'PAID' ||
            e.linkedReceivable?.status == 'RECEIVED';

        if (desiredTxUuids.contains(txUuid)) {
          if (!locked) {
            final edit = shares.firstWhere((s) => s.transactionUuid == txUuid);
            await transactionsRepository.updateTransactionWithCompanion(
              txUuid,
              TransactionsCompanion(
                amount: drift.Value(edit.amount),
                description: drift.Value(description),
                date: drift.Value(date),
                categoryUuid: drift.Value(categoryUuid),
                contactUuid: drift.Value(edit.contactUuid),
                paidRelationship:
                    drift.Value(edit.isUser ? null : effectiveRelationship),
                processedDate: drift.Value(effectiveProcessedDate),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
            if (e.transaction.linkedPayableUuid != null) {
              await payablesRepository.updatePayableWithCompanion(
                e.transaction.linkedPayableUuid!,
                PayablesCompanion(
                  amount: drift.Value(edit.amount),
                  description: drift.Value(description),
                  date: drift.Value(date),
                  dueDate: drift.Value(dueDate),
                  updatedAt: drift.Value(DateTime.now()),
                ),
              );
            }
            if (e.transaction.linkedReceivableUuid != null) {
              await receivablesRepository.updateReceivableWithCompanion(
                e.transaction.linkedReceivableUuid!,
                ReceivablesCompanion(
                  amount: drift.Value(edit.amount),
                  description: drift.Value(description),
                  date: drift.Value(date),
                  dueDate: drift.Value(dueDate),
                  updatedAt: drift.Value(DateTime.now()),
                ),
              );
            }
          }
        }
      }

      // Handle Additions (minified tx id; externalLinkId = tx id; pay/rec = tx_rec, tx_pay; same externalLinkId)
      for (final edit in shares.where((s) => s.transactionUuid == null)) {
        if (edit.amount <= 0) continue;
        if (edit.isUser) {
          final userTxUuid = DeepLinkService.newMinifiedUuid();
          await transactionsRepository.createTransaction(
            TransactionsCompanion(
              uuid: drift.Value(userTxUuid),
              amount: drift.Value(edit.amount),
              type: drift.Value(type),
              categoryUuid: drift.Value(categoryUuid),
              description: drift.Value(description),
              date: drift.Value(date),
              linkedGroupId: drift.Value(linkedGroupId),
              externalLinkId: drift.Value(userTxUuid),
              processedDate: drift.Value(effectiveProcessedDate),
              createdAt: drift.Value(DateTime.now()),
              updatedAt: drift.Value(DateTime.now()),
            ),
          );
        } else if (edit.contactUuid != null) {
          final txUuid = DeepLinkService.newMinifiedUuid();
          await transactionsRepository.createTransaction(
            TransactionsCompanion(
              uuid: drift.Value(txUuid),
              amount: drift.Value(edit.amount),
              type: drift.Value(type),
              contactUuid: drift.Value(edit.contactUuid),
              categoryUuid: drift.Value(categoryUuid),
              description: drift.Value(description),
              date: drift.Value(date),
              paidRelationship: drift.Value(effectiveRelationship),
              linkedGroupId: drift.Value(linkedGroupId),
              externalLinkId: drift.Value(txUuid),
              processedDate: drift.Value(effectiveProcessedDate),
              createdAt: drift.Value(DateTime.now()),
              updatedAt: drift.Value(DateTime.now()),
            ),
          );
          if (effectiveRelationship != null && type == 'EXPENSE') {
            if (effectiveRelationship == 'PAID_FOR') {
              final recUuid = '${txUuid}_rec';
              await receivablesRepository.createReceivable(
                ReceivablesCompanion(
                  uuid: drift.Value(recUuid),
                  contactUuid: drift.Value(edit.contactUuid!),
                  amount: drift.Value(edit.amount),
                  description: drift.Value(description),
                  date: drift.Value(date),
                  dueDate: drift.Value(dueDate),
                  status: const drift.Value('PENDING'),
                  linkedExpenseUuid: drift.Value(txUuid),
                  autoCreateIncome: const drift.Value(true),
                  externalLinkId: drift.Value(txUuid),
                  createdAt: drift.Value(DateTime.now()),
                  updatedAt: drift.Value(DateTime.now()),
                ),
              );
              await transactionsRepository.updateTransactionWithCompanion(
                txUuid,
                TransactionsCompanion(
                  linkedReceivableUuid: drift.Value(recUuid),
                  updatedAt: drift.Value(DateTime.now()),
                ),
              );
            } else if (effectiveRelationship == 'PAID_BY') {
              final payUuid = '${txUuid}_pay';
              await payablesRepository.createPayable(
                PayablesCompanion(
                  uuid: drift.Value(payUuid),
                  contactUuid: drift.Value(edit.contactUuid!),
                  amount: drift.Value(edit.amount),
                  description: drift.Value(description),
                  date: drift.Value(date),
                  dueDate: drift.Value(dueDate),
                  status: const drift.Value('PENDING'),
                  linkedExpenseUuid: drift.Value(txUuid),
                  autoCreateExpense: const drift.Value(false),
                  externalLinkId: drift.Value(txUuid),
                  createdAt: drift.Value(DateTime.now()),
                  updatedAt: drift.Value(DateTime.now()),
                ),
              );
              await transactionsRepository.updateTransactionWithCompanion(
                txUuid,
                TransactionsCompanion(
                  linkedPayableUuid: drift.Value(payUuid),
                  updatedAt: drift.Value(DateTime.now()),
                ),
              );
            }
          } else if (effectiveRelationship != null && type == 'INCOME') {
            if (effectiveRelationship == 'RECEIVED_FROM') {
              final payUuid = '${txUuid}_pay';
              await payablesRepository.createPayable(
                PayablesCompanion(
                  uuid: drift.Value(payUuid),
                  contactUuid: drift.Value(edit.contactUuid!),
                  amount: drift.Value(edit.amount),
                  description: drift.Value(description),
                  date: drift.Value(date),
                  dueDate: drift.Value(dueDate),
                  status: const drift.Value('PENDING'),
                  linkedIncomeUuid: drift.Value(txUuid),
                  autoCreateExpense: const drift.Value(true),
                  externalLinkId: drift.Value(txUuid),
                  createdAt: drift.Value(DateTime.now()),
                  updatedAt: drift.Value(DateTime.now()),
                ),
              );
              await transactionsRepository.updateTransactionWithCompanion(
                txUuid,
                TransactionsCompanion(
                  linkedPayableUuid: drift.Value(payUuid),
                  updatedAt: drift.Value(DateTime.now()),
                ),
              );
            } else if (effectiveRelationship == 'WILL_RECEIVE') {
              final recUuid = '${txUuid}_rec';
              await receivablesRepository.createReceivable(
                ReceivablesCompanion(
                  uuid: drift.Value(recUuid),
                  contactUuid: drift.Value(edit.contactUuid!),
                  amount: drift.Value(edit.amount),
                  description: drift.Value(description),
                  date: drift.Value(date),
                  dueDate: drift.Value(dueDate),
                  status: const drift.Value('PENDING'),
                  linkedIncomeUuid: drift.Value(txUuid),
                  autoCreateIncome: const drift.Value(false),
                  externalLinkId: drift.Value(txUuid),
                  createdAt: drift.Value(DateTime.now()),
                  updatedAt: drift.Value(DateTime.now()),
                ),
              );
              await transactionsRepository.updateTransactionWithCompanion(
                txUuid,
                TransactionsCompanion(
                  linkedReceivableUuid: drift.Value(recUuid),
                  updatedAt: drift.Value(DateTime.now()),
                ),
              );
            }
          }
          if (edit.contactUuid != null) {
            await contactsRepository.incrementUsageCount(edit.contactUuid!);
          }
        }
      }

      // 2. Finally, handle Deletions
      for (final e in existing) {
        final txUuid = e.transaction.uuid;
        final locked = e.linkedPayable?.status == 'PAID' ||
            e.linkedReceivable?.status == 'RECEIVED';
        if (!desiredTxUuids.contains(txUuid) && !locked) {
          await deleteTransaction(txUuid);
        }
      }

      if (categoryUuid != null) {
        await categoriesRepository.incrementUsageCount(categoryUuid);
      }
    });
  }

  /// Ensure a transaction and its linked entries have a consistent externalLinkId
  Future<String> ensureExternalLinkId({
    String? transactionUuid,
    String? payableUuid,
    String? receivableUuid,
  }) async {
    return await database.transaction(() async {
      String? existingId;
      Transaction? transaction;
      Payable? payable;
      Receivable? receivable;

      // 1. Fetch existing objects and find if any already has an ID
      if (transactionUuid != null) {
        transaction =
            await transactionsRepository.getTransactionByUuid(transactionUuid);
        existingId ??= transaction?.externalLinkId;
      }
      if (payableUuid != null) {
        payable = await payablesRepository.getPayableByUuid(payableUuid);
        existingId ??= payable?.externalLinkId;
      }
      if (receivableUuid != null) {
        receivable =
            await receivablesRepository.getReceivableByUuid(receivableUuid);
        existingId ??= receivable?.externalLinkId;
      }

      // Also check linked objects if we only have one ID
      if (existingId == null) {
        if (transaction != null) {
          if (transaction.linkedPayableUuid != null) {
            payable = await payablesRepository
                .getPayableByUuid(transaction.linkedPayableUuid!);
            existingId ??= payable?.externalLinkId;
          }
          if (transaction.linkedReceivableUuid != null) {
            receivable = await receivablesRepository
                .getReceivableByUuid(transaction.linkedReceivableUuid!);
            existingId ??= receivable?.externalLinkId;
          }
        } else if (payable != null) {
          if (payable.linkedExpenseUuid != null) {
            transaction = await transactionsRepository
                .getTransactionByUuid(payable.linkedExpenseUuid!);
            existingId ??= transaction?.externalLinkId;
          }
          if (payable.linkedIncomeUuid != null) {
            transaction = await transactionsRepository
                .getTransactionByUuid(payable.linkedIncomeUuid!);
            existingId ??= transaction?.externalLinkId;
          }
        } else if (receivable != null) {
          if (receivable.linkedExpenseUuid != null) {
            transaction = await transactionsRepository
                .getTransactionByUuid(receivable.linkedExpenseUuid!);
            existingId ??= transaction?.externalLinkId;
          }
          if (receivable.linkedIncomeUuid != null) {
            transaction = await transactionsRepository
                .getTransactionByUuid(receivable.linkedIncomeUuid!);
            existingId ??= transaction?.externalLinkId;
          }
        }
      }

      // 2. If still no ID, use transaction/payable/receivable id (same as tx id for linked); else new minified
      String sourceId;
      if (transactionUuid != null) {
        sourceId = transactionUuid;
      } else if (payableUuid != null) {
        sourceId = payableUuid;
      } else if (receivableUuid != null) {
        sourceId = receivableUuid;
      } else {
        sourceId = DeepLinkService.newMinifiedUuid();
      }

      final String finalId = existingId ??
          (sourceId.length <= 12
              ? sourceId
              : DeepLinkService.shortenUuid(sourceId));

      // 3. Update all related records with this ID
      // Update transaction
      if (transactionUuid != null) {
        try {
          await transactionsRepository.updateTransactionWithCompanion(
            transactionUuid,
            TransactionsCompanion(externalLinkId: drift.Value(finalId)),
          );
        } catch (e) {
          if (!e.toString().contains('1555') &&
              !e.toString().contains('UNIQUE constraint failed')) {
            rethrow;
          }
        }
      } else if (transaction != null) {
        try {
          await transactionsRepository.updateTransactionWithCompanion(
            transaction.uuid,
            TransactionsCompanion(externalLinkId: drift.Value(finalId)),
          );
        } catch (e) {
          if (!e.toString().contains('1555') &&
              !e.toString().contains('UNIQUE constraint failed')) {
            rethrow;
          }
        }
      }

      // Update payable
      if (payableUuid != null) {
        try {
          await payablesRepository.updatePayableWithCompanion(
            payableUuid,
            PayablesCompanion(externalLinkId: drift.Value(finalId)),
          );
        } catch (e) {
          if (!e.toString().contains('1555') &&
              !e.toString().contains('UNIQUE constraint failed')) {
            rethrow;
          }
        }
      } else if (payable != null) {
        try {
          await payablesRepository.updatePayableWithCompanion(
            payable.uuid,
            PayablesCompanion(externalLinkId: drift.Value(finalId)),
          );
        } catch (e) {
          if (!e.toString().contains('1555') &&
              !e.toString().contains('UNIQUE constraint failed')) {
            rethrow;
          }
        }
      }

      // Update receivable
      if (receivableUuid != null) {
        try {
          await receivablesRepository.updateReceivableWithCompanion(
            receivableUuid,
            ReceivablesCompanion(externalLinkId: drift.Value(finalId)),
          );
        } catch (e) {
          if (!e.toString().contains('1555') &&
              !e.toString().contains('UNIQUE constraint failed')) {
            rethrow;
          }
        }
      } else if (receivable != null) {
        try {
          await receivablesRepository.updateReceivableWithCompanion(
            receivable.uuid,
            ReceivablesCompanion(externalLinkId: drift.Value(finalId)),
          );
        } catch (e) {
          if (!e.toString().contains('1555') &&
              !e.toString().contains('UNIQUE constraint failed')) {
            rethrow;
          }
        }
      }

      return finalId;
    });
  }

  Future<void> markTransactionAsReviewed(String uuid) async {
    await transactionsRepository.markAsReviewed(uuid);
  }

  /// Marks the transaction (and all others in the same split group) as processed.
  Future<void> markAsProcessed(String transactionUuid) async {
    final group = await getGroupByTransactionUuid(transactionUuid);
    final processedDate = DateTime.now();
    final companion = TransactionsCompanion(
      processedDate: drift.Value(processedDate),
      updatedAt: drift.Value(processedDate),
      isNotSynced: const drift.Value(true),
    );
    for (final item in group) {
      await transactionsRepository.updateTransactionWithCompanion(
        item.transaction.uuid,
        companion,
      );
    }
  }

  /// Update a transaction and sync the amount/description with linked entries
  /// If type or relationship changes significantly, linked entries are recreated
  Future<void> updateTransaction({
    required String transactionUuid,
    required double amount,
    required String type,
    required DateTime date,
    String? description,
    String? categoryUuid,
    String? contactUuid,
    String? accountUuid,
    String? paidRelationship,
    DateTime? dueDate,
    /// When true (or PAID_BY / WILL_RECEIVE), [processedDate] is cleared.
    bool isPending = false,
  }) async {
    await database.transaction(() async {
      // 1. Get the existing transaction to check for linked entries
      final existingTransaction =
          await transactionsRepository.getTransactionByUuid(transactionUuid);

      if (existingTransaction == null) {
        throw Exception('Transaction not found');
      }

      // Same rules as [createTransaction]: pending → no processedDate.
      final effectiveIsPending = isPending ||
          paidRelationship == 'PAID_BY' ||
          paidRelationship == 'WILL_RECEIVE';
      final effectiveProcessedDate =
          effectiveIsPending ? null : date;

      // 2. Check if type or relationship changed (requires linked entry recreation)
      final typeChanged = existingTransaction.type != type;
      final relationshipChanged =
          existingTransaction.paidRelationship != paidRelationship;

      // Determine if we need to DELETE old links
      final hasOldLinks = existingTransaction.linkedPayableUuid != null ||
          existingTransaction.linkedReceivableUuid != null;
      final shouldDeleteOldLinks =
          hasOldLinks && (typeChanged || relationshipChanged);

      // Determine if we need to CREATE new links
      final hasValidNewRelationship =
          contactUuid != null && paidRelationship != null;
      final shouldCreateNewLinks = hasValidNewRelationship &&
          (shouldDeleteOldLinks ||
              !hasOldLinks ||
              relationshipChanged ||
              typeChanged);

      // 3. If significant change, delete old linked entries
      String? oldLinkedPayableUuid = existingTransaction.linkedPayableUuid;
      String? oldLinkedReceivableUuid =
          existingTransaction.linkedReceivableUuid;

      if (shouldDeleteOldLinks) {
        if (existingTransaction.linkedPayableUuid != null) {
          await payablesRepository
              .deletePayable(existingTransaction.linkedPayableUuid!);
        }
        if (existingTransaction.linkedReceivableUuid != null) {
          await receivablesRepository
              .deleteReceivable(existingTransaction.linkedReceivableUuid!);
        }
        oldLinkedPayableUuid = null;
        oldLinkedReceivableUuid = null;
      }

      // 4. Update the transaction
      await transactionsRepository.updateTransactionWithCompanion(
        transactionUuid,
        TransactionsCompanion(
          amount: drift.Value(amount),
          type: drift.Value(type),
          contactUuid: drift.Value(contactUuid),
          categoryUuid: drift.Value(categoryUuid),
          description: drift.Value(description),
          date: drift.Value(date),
          accountUuid: drift.Value(accountUuid),
          paidRelationship: drift.Value(paidRelationship),
          processedDate: drift.Value(effectiveProcessedDate),
          linkedPayableUuid: drift.Value(oldLinkedPayableUuid),
          linkedReceivableUuid: drift.Value(oldLinkedReceivableUuid),
          isScheduled: const drift.Value(false),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );

      // 5. Recreate linked entries if needed (id = transactionId_rec / _pay; externalLinkId = transaction id)
      if (shouldCreateNewLinks) {
        String? newLinkedPayableUuid;
        String? newLinkedReceivableUuid;

        if (type == 'EXPENSE') {
          if (paidRelationship == 'PAID_FOR') {
            newLinkedReceivableUuid = '${transactionUuid}_rec';
            await receivablesRepository.createReceivable(
              ReceivablesCompanion(
                uuid: drift.Value(newLinkedReceivableUuid),
                contactUuid: drift.Value(contactUuid),
                amount: drift.Value(amount),
                description: drift.Value(description),
                date: drift.Value(date),
                dueDate: drift.Value(dueDate),
                status: const drift.Value('PENDING'),
                linkedExpenseUuid: drift.Value(transactionUuid),
                autoCreateIncome: const drift.Value(true),
                externalLinkId: drift.Value(transactionUuid),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          } else if (paidRelationship == 'PAID_BY') {
            newLinkedPayableUuid = '${transactionUuid}_pay';
            await payablesRepository.createPayable(
              PayablesCompanion(
                uuid: drift.Value(newLinkedPayableUuid),
                contactUuid: drift.Value(contactUuid),
                amount: drift.Value(amount),
                description: drift.Value(description),
                date: drift.Value(date),
                dueDate: drift.Value(dueDate),
                status: const drift.Value('PENDING'),
                linkedExpenseUuid: drift.Value(transactionUuid),
                autoCreateExpense: const drift.Value(false),
                externalLinkId: drift.Value(transactionUuid),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          }
        } else if (type == 'INCOME') {
          if (paidRelationship == 'RECEIVED_FROM') {
            newLinkedPayableUuid = '${transactionUuid}_pay';
            await payablesRepository.createPayable(
              PayablesCompanion(
                uuid: drift.Value(newLinkedPayableUuid),
                contactUuid: drift.Value(contactUuid),
                amount: drift.Value(amount),
                description: drift.Value(description),
                date: drift.Value(date),
                dueDate: drift.Value(dueDate),
                status: const drift.Value('PENDING'),
                linkedIncomeUuid: drift.Value(transactionUuid),
                autoCreateExpense: const drift.Value(true),
                externalLinkId: drift.Value(transactionUuid),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          } else if (paidRelationship == 'WILL_RECEIVE') {
            newLinkedReceivableUuid = '${transactionUuid}_rec';
            await receivablesRepository.createReceivable(
              ReceivablesCompanion(
                uuid: drift.Value(newLinkedReceivableUuid),
                contactUuid: drift.Value(contactUuid),
                amount: drift.Value(amount),
                description: drift.Value(description),
                date: drift.Value(date),
                dueDate: drift.Value(dueDate),
                status: const drift.Value('PENDING'),
                linkedIncomeUuid: drift.Value(transactionUuid),
                autoCreateIncome: const drift.Value(false),
                externalLinkId: drift.Value(transactionUuid),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          }
        }

        // Update transaction with new linked IDs
        if (newLinkedPayableUuid != null || newLinkedReceivableUuid != null) {
          await transactionsRepository.updateTransactionWithCompanion(
            transactionUuid,
            TransactionsCompanion(
              linkedPayableUuid: drift.Value(newLinkedPayableUuid),
              linkedReceivableUuid: drift.Value(newLinkedReceivableUuid),
              updatedAt: drift.Value(DateTime.now()),
            ),
          );
        }
      }
      // 6. If no recreation needed but linked entries exist, just sync them
      else if (!shouldCreateNewLinks && !shouldDeleteOldLinks) {
        if (existingTransaction.linkedPayableUuid != null) {
          final payableCompanion = PayablesCompanion(
            amount: drift.Value(amount),
            description: drift.Value(description),
            date: drift.Value(date),
            dueDate: drift.Value(dueDate),
            updatedAt: drift.Value(DateTime.now()),
          );
          if (contactUuid != null) {
            await payablesRepository.updatePayableWithCompanion(
              existingTransaction.linkedPayableUuid!,
              payableCompanion.copyWith(contactUuid: drift.Value(contactUuid)),
            );
          } else {
            await payablesRepository.updatePayableWithCompanion(
              existingTransaction.linkedPayableUuid!,
              payableCompanion,
            );
          }
        }

        if (existingTransaction.linkedReceivableUuid != null) {
          final receivableCompanion = ReceivablesCompanion(
            amount: drift.Value(amount),
            description: drift.Value(description),
            date: drift.Value(date),
            dueDate: drift.Value(dueDate),
            updatedAt: drift.Value(DateTime.now()),
          );
          if (contactUuid != null) {
            await receivablesRepository.updateReceivableWithCompanion(
              existingTransaction.linkedReceivableUuid!,
              receivableCompanion.copyWith(
                  contactUuid: drift.Value(contactUuid)),
            );
          } else {
            await receivablesRepository.updateReceivableWithCompanion(
              existingTransaction.linkedReceivableUuid!,
              receivableCompanion,
            );
          }
        }
      }

      // 7. Update usage counts if categories/contacts changed
      if (categoryUuid != existingTransaction.categoryUuid) {
        if (existingTransaction.categoryUuid != null) {
          await categoriesRepository
              .decrementUsageCount(existingTransaction.categoryUuid!);
        }
        if (categoryUuid != null) {
          await categoriesRepository.incrementUsageCount(categoryUuid);
        }
      }

      if (contactUuid != existingTransaction.contactUuid) {
        if (existingTransaction.contactUuid != null) {
          await contactsRepository
              .decrementUsageCount(existingTransaction.contactUuid!);
        }
        if (contactUuid != null) {
          await contactsRepository.incrementUsageCount(contactUuid);
        }
      }
    });
  }

  /// Delete a transaction and its linked entries
  Future<void> deleteTransaction(String transactionUuid) async {
    await database.transaction(() async {
      // 1. Get the existing transaction to check for linked entries
      final existingTransaction =
          await transactionsRepository.getTransactionByUuid(transactionUuid);

      if (existingTransaction == null) {
        throw Exception('Transaction not found');
      }

      // 2. Delete linked entries first
      if (existingTransaction.linkedPayableUuid != null) {
        await payablesRepository
            .deletePayable(existingTransaction.linkedPayableUuid!);
      }

      if (existingTransaction.linkedReceivableUuid != null) {
        await receivablesRepository
            .deleteReceivable(existingTransaction.linkedReceivableUuid!);
      }

      // 3. Decrement usage counts
      if (existingTransaction.categoryUuid != null) {
        await categoriesRepository
            .decrementUsageCount(existingTransaction.categoryUuid!);
      }
      if (existingTransaction.contactUuid != null) {
        await contactsRepository
            .decrementUsageCount(existingTransaction.contactUuid!);
      }

      // 4. Delete the transaction
      await transactionsRepository.deleteTransaction(transactionUuid);
    });
  }

  /// Generate dummy transactions for testing
  Future<void> generateDummyTransactions({int count = 100}) async {
    final expenseCategories =
        await categoriesRepository.watchCategoriesByType('EXPENSE').first;
    final incomeCategories =
        await categoriesRepository.watchCategoriesByType('INCOME').first;
    final contacts = await contactsRepository.watchAllContacts().first;

    final descriptions = [
      'Grocery Shopping',
      'Restaurant Bill',
      'Gas Station',
      'Coffee Shop',
      'Movie Tickets',
      'Online Purchase',
      'Utility Bill',
      'Phone Bill',
      'Internet Bill',
      'Rent Payment',
      'Salary',
      'Freelance Work',
      'Investment Return',
      'Gift Received',
      'Bonus Payment',
      'Splitted Bill',
    ];

    for (int i = 0; i < count; i++) {
      final daysAgo = i ~/ 2;
      final date = DateTime.now().subtract(Duration(days: daysAgo));
      final isExpense = i % 3 != 0;
      final type = isExpense ? 'EXPENSE' : 'INCOME';
      final amount = (10.0 + (i * 23.5) % 4990).roundToDouble();
      final categories = isExpense ? expenseCategories : incomeCategories;
      String? categoryUuid;
      if (categories.isNotEmpty) {
        categoryUuid = categories[i % categories.length].uuid;
      }
      String? contactUuid;
      if (contacts.isNotEmpty && i % 4 == 0) {
        contactUuid = contacts[i % contacts.length].uuid;
      }
      final description = descriptions[i % descriptions.length] + ' #${i + 1}';

      await createTransaction(
        amount: amount,
        type: type,
        date: date,
        description: description,
        categoryUuid: categoryUuid,
        contactUuid: contactUuid,
      );
    }
  }
}

/// Model for a share in a group split
class SplitShare {
  final Contact? contact;
  final bool isUser;
  double amount;
  double percentage;
  bool isLocked;

  SplitShare({
    this.contact,
    this.isUser = false,
    this.amount = 0.0,
    this.percentage = 0.0,
    this.isLocked = false,
  });
}

/// One share in a group split edit (existing or new). Used by [TransactionService.updateGroupSplit].
class GroupShareEdit {
  final String? transactionUuid;
  final String? contactUuid;
  final double amount;
  final bool isUser;

  GroupShareEdit({
    this.transactionUuid,
    this.contactUuid,
    required this.amount,
    this.isUser = false,
  });
}
