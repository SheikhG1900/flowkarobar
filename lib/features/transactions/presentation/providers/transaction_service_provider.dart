import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
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
    double? myShareAmount,
    bool isSplitMode = true,
    AppLocalizations? l10n,
  }) async {
    return await database.transaction(() async {
      // 0. Generate base UUID first if not provided
      final baseUuid = externalLinkId ?? const Uuid().v4();
      
      // Derive the externalLinkId directly from the baseUuid using the common method
      final effectiveExternalId = DeepLinkService.shortenUuid(baseUuid);

      // Use the effectiveExternalId as the base UUID for the transaction to ensure consistency across devices
      final baseTransactionUuid = '${effectiveExternalId}_0';

      // Determine actual amounts for contact and user
      double contactAmount = amount;

      if (myShareAmount != null && myShareAmount > 0) {
        if (isSplitMode) {
          // Split: amount is total, contact gets (total - myShare)
          contactAmount = amount - myShareAmount;
        } else {
          // Add: amount is contact's share, user gets myShareAmount
          contactAmount = amount;
        }
      }

    final transactionUuid = await transactionsRepository.createTransaction(
      TransactionsCompanion(
        uuid: drift.Value(baseTransactionUuid),
        amount: drift.Value(contactAmount),
        type: drift.Value(type),
        contactUuid: drift.Value(contactUuid),
        categoryUuid: drift.Value(categoryUuid),
        description: drift.Value(description),
        date: drift.Value(date),
        paidRelationship: drift.Value(paidRelationship),
        isScheduled: drift.Value(isScheduled),
        externalLinkId: drift.Value(baseTransactionUuid),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );

    // Ensure linked entry creation is triggered if relationship is provided
    final shouldCreateLinks = createLinkedEntry || paidRelationship != null;

    // 1.1 Create "My Share" transaction if applicable
      if (myShareAmount != null && myShareAmount > 0) {
        await transactionsRepository.createTransaction(
          TransactionsCompanion(
            uuid: drift.Value(const Uuid().v4()), // Explicitly generate a new UUID
            amount: drift.Value(myShareAmount),
            type: drift.Value(type),
            contactUuid: drift.Value(contactUuid), // Keep contact attached
            categoryUuid: drift.Value(categoryUuid),
            description: drift.Value(description), // Don't append suffix
            date: drift.Value(date),
            isScheduled: drift.Value(isScheduled),
            externalLinkId: drift.Value('${effectiveExternalId}_1'),
            createdAt: drift.Value(DateTime.now()),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
        // Increment contact usage count for the second transaction as well
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

      // 3. Create linked entries based on logic (using contactAmount)
      if (shouldCreateLinks && contactUuid != null) {
        // --- EXPENSE LOGIC ---
        if (type == 'EXPENSE') {
          if (paidRelationship == 'PAID_FOR') {
            final String receivableUuid =
                await receivablesRepository.createReceivable(
              ReceivablesCompanion(
                uuid: drift.Value('${transactionUuid}_rec'), // Derived from transaction
                contactUuid: drift.Value(contactUuid),
                amount: drift.Value(contactAmount),
                description: drift.Value(description),
                date: drift.Value(date),
                dueDate: drift.Value(dueDate),
                status: const drift.Value('PENDING'),
                linkedExpenseUuid: drift.Value(transactionUuid),
                isScheduled: drift.Value(isScheduled),
                autoCreateIncome: const drift.Value(true),
                externalLinkId: drift.Value(baseTransactionUuid),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
            await transactionsRepository.updateTransactionWithCompanion(
              transactionUuid,
              TransactionsCompanion(
                linkedReceivableUuid: drift.Value(receivableUuid),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          } else if (paidRelationship == 'PAID_BY') {
            final String payableUuid = await payablesRepository.createPayable(
              PayablesCompanion(
                uuid: drift.Value('${transactionUuid}_pay'), // Derived from transaction
                contactUuid: drift.Value(contactUuid),
                amount: drift.Value(contactAmount),
                description: drift.Value(description),
                date: drift.Value(date),
                dueDate: drift.Value(dueDate),
                status: const drift.Value('PENDING'),
                linkedExpenseUuid: drift.Value(transactionUuid),
                isScheduled: drift.Value(isScheduled),
                autoCreateExpense: const drift.Value(false),
                externalLinkId: drift.Value(baseTransactionUuid),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
            await transactionsRepository.updateTransactionWithCompanion(
              transactionUuid,
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
                uuid: drift.Value('${transactionUuid}_pay'), // Derived from transaction
                contactUuid: drift.Value(contactUuid),
                amount: drift.Value(contactAmount),
                description: drift.Value(description),
                date: drift.Value(date),
                dueDate: drift.Value(dueDate),
                status: const drift.Value('PENDING'),
                linkedIncomeUuid: drift.Value(transactionUuid),
                isScheduled: drift.Value(isScheduled),
                autoCreateExpense: const drift.Value(true),
                externalLinkId: drift.Value(baseTransactionUuid),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
            await transactionsRepository.updateTransactionWithCompanion(
              transactionUuid,
              TransactionsCompanion(
                linkedPayableUuid: drift.Value(payableUuid),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          } else if (paidRelationship == 'WILL_RECEIVE') {
            final String receivableUuid =
                await receivablesRepository.createReceivable(
              ReceivablesCompanion(
                uuid: drift.Value('${transactionUuid}_rec'), // Derived from transaction
                contactUuid: drift.Value(contactUuid),
                amount: drift.Value(contactAmount),
                description: drift.Value(description),
                date: drift.Value(date),
                dueDate: drift.Value(dueDate),
                status: const drift.Value('PENDING'),
                linkedIncomeUuid: drift.Value(transactionUuid),
                isScheduled: drift.Value(isScheduled),
                autoCreateIncome: const drift.Value(false),
                externalLinkId: drift.Value(baseTransactionUuid),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
            await transactionsRepository.updateTransactionWithCompanion(
              transactionUuid,
              TransactionsCompanion(
                linkedReceivableUuid: drift.Value(receivableUuid),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          }
        }
      }
      return transactionUuid;
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
    String? paidRelationship,
    DateTime? dueDate,
  }) async {
    try {
      await database.transaction(() async {
        // Generate a unique group ID for this split using standard UUID, shortened
        final groupBaseUuid = const Uuid().v4();
        final groupPrefix = DeepLinkService.shortenUuid(groupBaseUuid);

        for (int i = 0; i < shares.length; i++) {
          final share = shares[i];
          if (share.amount <= 0) continue;

          if (share.isUser) {
            // User's share: Just a regular transaction without contact or linked entry
            final userTxUuid = '${groupPrefix}_$i';
            await transactionsRepository.createTransaction(
              TransactionsCompanion(
                uuid: drift.Value(userTxUuid),
                amount: drift.Value(share.amount),
                type: drift.Value(type),
                categoryUuid: drift.Value(categoryUuid),
                description: drift.Value(description),
                date: drift.Value(date),
                externalLinkId: drift.Value(userTxUuid),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          } else if (share.contact != null) {
            // Contact's share: Transaction + Linked Entry
            final transactionUuid = '${groupPrefix}_$i';
            await transactionsRepository.createTransaction(
              TransactionsCompanion(
                uuid: drift.Value(transactionUuid),
                amount: drift.Value(share.amount),
                type: drift.Value(type),
                contactUuid: drift.Value(share.contact!.uuid),
                categoryUuid: drift.Value(categoryUuid),
                description: drift.Value(description),
                date: drift.Value(date),
                paidRelationship: drift.Value(paidRelationship),
                externalLinkId: drift.Value(transactionUuid),
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
      debugPrint('Group Split Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      rethrow;
    }
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

      // 2. If still no ID, generate a new one
      // Derive the ID from the transaction ID if available, otherwise from payable/receivable
      String sourceId;
      if (transactionUuid != null) {
        sourceId = transactionUuid;
      } else if (payableUuid != null) {
        sourceId = payableUuid;
      } else if (receivableUuid != null) {
        sourceId = receivableUuid;
      } else {
        sourceId = const Uuid().v4();
      }
      
      final String finalId = existingId ?? DeepLinkService.shortenUuid(sourceId);

      // 3. Update all related records with this ID
      // Update transaction
      if (transactionUuid != null) {
        await transactionsRepository.updateTransactionWithCompanion(
          transactionUuid,
          TransactionsCompanion(externalLinkId: drift.Value(finalId)),
        );
      } else if (transaction != null) {
        await transactionsRepository.updateTransactionWithCompanion(
          transaction.uuid,
          TransactionsCompanion(externalLinkId: drift.Value(finalId)),
        );
      }

      // Update payable
      if (payableUuid != null) {
        await payablesRepository.updatePayableWithCompanion(
          payableUuid,
          PayablesCompanion(externalLinkId: drift.Value(finalId)),
        );
      } else if (payable != null) {
        await payablesRepository.updatePayableWithCompanion(
          payable.uuid,
          PayablesCompanion(externalLinkId: drift.Value(finalId)),
        );
      }

      // Update receivable
      if (receivableUuid != null) {
        await receivablesRepository.updateReceivableWithCompanion(
          receivableUuid,
          ReceivablesCompanion(externalLinkId: drift.Value(finalId)),
        );
      } else if (receivable != null) {
        await receivablesRepository.updateReceivableWithCompanion(
          receivable.uuid,
          ReceivablesCompanion(externalLinkId: drift.Value(finalId)),
        );
      }

      return finalId;
    });
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
    String? paidRelationship,
    DateTime? dueDate,
  }) async {
    await database.transaction(() async {
      // 1. Get the existing transaction to check for linked entries
      final existingTransaction =
          await transactionsRepository.getTransactionByUuid(transactionUuid);

      if (existingTransaction == null) {
        throw Exception('Transaction not found');
      }

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
      String? oldLinkedReceivableUuid = existingTransaction.linkedReceivableUuid;

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
          paidRelationship: drift.Value(paidRelationship),
          linkedPayableUuid: drift.Value(oldLinkedPayableUuid),
          linkedReceivableUuid: drift.Value(oldLinkedReceivableUuid),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );

      // 5. Recreate linked entries if needed
      if (shouldCreateNewLinks) {
        String? newLinkedPayableUuid;
        String? newLinkedReceivableUuid;

        if (type == 'EXPENSE') {
          if (paidRelationship == 'PAID_FOR') {
            // Create receivable
            newLinkedReceivableUuid =
                await receivablesRepository.createReceivable(
              ReceivablesCompanion(
                contactUuid: drift.Value(contactUuid),
                amount: drift.Value(amount),
                description: drift.Value(description),
                date: drift.Value(date),
                dueDate: drift.Value(dueDate),
                status: const drift.Value('PENDING'),
                linkedExpenseUuid: drift.Value(transactionUuid),
                autoCreateIncome: const drift.Value(true),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          } else if (paidRelationship == 'PAID_BY') {
            // Create payable
            newLinkedPayableUuid = await payablesRepository.createPayable(
              PayablesCompanion(
                contactUuid: drift.Value(contactUuid),
                amount: drift.Value(amount),
                description: drift.Value(description),
                date: drift.Value(date),
                dueDate: drift.Value(dueDate),
                status: const drift.Value('PENDING'),
                linkedExpenseUuid: drift.Value(transactionUuid),
                autoCreateExpense: const drift.Value(false),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          }
        } else if (type == 'INCOME') {
          if (paidRelationship == 'RECEIVED_FROM') {
            // Create payable
            newLinkedPayableUuid = await payablesRepository.createPayable(
              PayablesCompanion(
                contactUuid: drift.Value(contactUuid),
                amount: drift.Value(amount),
                description: drift.Value(description),
                date: drift.Value(date),
                dueDate: drift.Value(dueDate),
                status: const drift.Value('PENDING'),
                linkedIncomeUuid: drift.Value(transactionUuid),
                autoCreateExpense: const drift.Value(true),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          } else if (paidRelationship == 'WILL_RECEIVE') {
            // Create receivable
            newLinkedReceivableUuid =
                await receivablesRepository.createReceivable(
              ReceivablesCompanion(
                contactUuid: drift.Value(contactUuid),
                amount: drift.Value(amount),
                description: drift.Value(description),
                date: drift.Value(date),
                dueDate: drift.Value(dueDate),
                status: const drift.Value('PENDING'),
                linkedIncomeUuid: drift.Value(transactionUuid),
                autoCreateIncome: const drift.Value(false),
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
              receivableCompanion.copyWith(contactUuid: drift.Value(contactUuid)),
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
