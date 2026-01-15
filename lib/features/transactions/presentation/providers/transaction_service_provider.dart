import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
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
import 'package:flowpaisa/shared/providers/database_provider.dart';

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

  Future<void> createTransaction({
    required double amount,
    required String type,
    required DateTime date,
    String? description,
    int? categoryId,
    int? contactId,
    String?
        paidRelationship, // 'PAID_FOR', 'PAID_BY', 'RECEIVED_FROM', 'WILL_RECEIVE'
    bool createLinkedEntry = false,
  }) async {
    await database.transaction(() async {
      // 1. Create the main transaction
      final transactionId = await transactionsRepository.createTransaction(
        TransactionsCompanion(
          amount: Value(amount),
          type: Value(type),
          contactId: Value(contactId),
          categoryId: Value(categoryId),
          description: Value(description),
          date: Value(date),
          paidRelationship: Value(paidRelationship),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // 2. Increment usage counts
      if (categoryId != null) {
        await categoriesRepository.incrementUsageCount(categoryId);
      }
      if (contactId != null) {
        await contactsRepository.incrementUsageCount(contactId);
      }

      // 3. Create linked entries based on logic
      if (createLinkedEntry && contactId != null) {
        // --- EXPENSE LOGIC ---
        if (type == 'EXPENSE') {
          if (paidRelationship == 'PAID_FOR') {
            // Logic: You paid FOR someone -> It's an expense for you (cash out),
            // but you expect to be paid back (Receivable).
            final receivableId = await receivablesRepository.createReceivable(
              ReceivablesCompanion(
                contactId: Value(contactId),
                amount: Value(amount),
                description: Value(description),
                date: Value(date),
                status: const Value('PENDING'),
                linkedExpenseId: Value(transactionId),
                autoCreateIncome:
                    const Value(true), // When they pay back, it becomes income
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
            // Update transaction with linked receivable ID
            await transactionsRepository.updateTransactionWithCompanion(
              transactionId,
              TransactionsCompanion(
                linkedReceivableId: Value(receivableId),
                updatedAt: Value(DateTime.now()),
              ),
            );
          } else if (paidRelationship == 'PAID_BY') {
            // Logic: Someone paid FOR you -> You consumed (Expense recorded),
            // but you didn't pay cash yet. You owe them (Payable).
            final payableId = await payablesRepository.createPayable(
              PayablesCompanion(
                contactId: Value(contactId),
                amount: Value(amount),
                description: Value(description),
                date: Value(date),
                status: const Value('PENDING'),
                linkedExpenseId: Value(transactionId),
                autoCreateExpense:
                    const Value(false), // Don't create new transaction, activate existing one when marked
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
            // Update transaction with linked payable ID
            await transactionsRepository.updateTransactionWithCompanion(
              transactionId,
              TransactionsCompanion(
                linkedPayableId: Value(payableId),
                updatedAt: Value(DateTime.now()),
              ),
            );
          }
        }
        // --- INCOME LOGIC ---
        else if (type == 'INCOME') {
          if (paidRelationship == 'RECEIVED_FROM') {
            // Logic: You received money FROM someone (Loan/Advance) -> You owe them (Payable).
            // Cash Balance INCREASES (handled by DashboardProvider).
            final payableId = await payablesRepository.createPayable(
              PayablesCompanion(
                contactId: Value(contactId),
                amount: Value(amount),
                description: Value(description),
                date: Value(date),
                status: const Value('PENDING'),
                linkedIncomeId: Value(transactionId),
                autoCreateExpense:
                    const Value(true), // When you pay back, it becomes expense
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
            // Update transaction with linked payable ID
            await transactionsRepository.updateTransactionWithCompanion(
              transactionId,
              TransactionsCompanion(
                linkedPayableId: Value(payableId),
                updatedAt: Value(DateTime.now()),
              ),
            );
          } else if (paidRelationship == 'WILL_RECEIVE') {
            // Logic: You earned money but haven't received it yet (Accrued Income).
            // Cash Balance UNCHANGED (handled by DashboardProvider).
            // Create Receivable.
            final receivableId = await receivablesRepository.createReceivable(
              ReceivablesCompanion(
                contactId: Value(contactId),
                amount: Value(amount),
                description: Value(description),
                date: Value(date),
                status: const Value('PENDING'),
                linkedIncomeId: Value(transactionId), // Store as linked income
                autoCreateIncome: const Value(
                    false), // Don't create new transaction, activate existing one when marked
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
            // Update transaction with linked receivable ID
            await transactionsRepository.updateTransactionWithCompanion(
              transactionId,
              TransactionsCompanion(
                linkedReceivableId: Value(receivableId),
                updatedAt: Value(DateTime.now()),
              ),
            );
          }
        }
      }
    });
  }

  /// Update a transaction and sync the amount/description with linked entries
  /// If type or relationship changes significantly, linked entries are recreated
  Future<void> updateTransaction({
    required int transactionId,
    required double amount,
    required String type,
    required DateTime date,
    String? description,
    int? categoryId,
    int? contactId,
    String? paidRelationship,
  }) async {
    await database.transaction(() async {
      // 1. Get the existing transaction to check for linked entries
      final existingTransaction = await transactionsRepository.getTransactionById(transactionId);
      
      if (existingTransaction == null) {
        throw Exception('Transaction not found');
      }

      // 2. Check if type or relationship changed (requires linked entry recreation)
      final typeChanged = existingTransaction.type != type;
      final relationshipChanged = existingTransaction.paidRelationship != paidRelationship;
      
      // Determine if we need to DELETE old links
      final hasOldLinks = existingTransaction.linkedPayableId != null || existingTransaction.linkedReceivableId != null;
      final shouldDeleteOldLinks = hasOldLinks && (typeChanged || relationshipChanged);

      // Determine if we need to CREATE new links
      // We create new links if:
      // 1. We have a valid relationship and contact
      // 2. AND (We deleted old links OR we didn't have links before OR the relationship/type changed)
      final hasValidNewRelationship = contactId != null && paidRelationship != null;
      final shouldCreateNewLinks = hasValidNewRelationship && (shouldDeleteOldLinks || !hasOldLinks || relationshipChanged || typeChanged);

      // 3. If significant change, delete old linked entries
      int? oldLinkedPayableId = existingTransaction.linkedPayableId;
      int? oldLinkedReceivableId = existingTransaction.linkedReceivableId;
      
      if (shouldDeleteOldLinks) {
        if (existingTransaction.linkedPayableId != null) {
          await payablesRepository.deletePayable(existingTransaction.linkedPayableId!);
        }
        if (existingTransaction.linkedReceivableId != null) {
          await receivablesRepository.deleteReceivable(existingTransaction.linkedReceivableId!);
        }
        oldLinkedPayableId = null;
        oldLinkedReceivableId = null;
      }

      // 4. Update the transaction
      await transactionsRepository.updateTransactionWithCompanion(
        transactionId,
        TransactionsCompanion(
          amount: Value(amount),
          type: Value(type),
          contactId: Value(contactId),
          categoryId: Value(categoryId),
          description: Value(description),
          date: Value(date),
          paidRelationship: Value(paidRelationship),
          linkedPayableId: Value(oldLinkedPayableId),
          linkedReceivableId: Value(oldLinkedReceivableId),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // 5. Recreate linked entries if needed
      if (shouldCreateNewLinks) {
        int? newLinkedPayableId;
        int? newLinkedReceivableId;

        if (type == 'EXPENSE') {
          if (paidRelationship == 'PAID_FOR') {
            // Create receivable
            newLinkedReceivableId = await receivablesRepository.createReceivable(
              ReceivablesCompanion(
                contactId: Value(contactId),
                amount: Value(amount),
                description: Value(description),
                date: Value(date),
                status: const Value('PENDING'),
                linkedExpenseId: Value(transactionId),
                autoCreateIncome: const Value(true),
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
          } else if (paidRelationship == 'PAID_BY') {
            // Create payable
            newLinkedPayableId = await payablesRepository.createPayable(
              PayablesCompanion(
                contactId: Value(contactId),
                amount: Value(amount),
                description: Value(description),
                date: Value(date),
                status: const Value('PENDING'),
                linkedExpenseId: Value(transactionId),
                autoCreateExpense: const Value(false),
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
          }
        } else if (type == 'INCOME') {
          if (paidRelationship == 'RECEIVED_FROM') {
            // Create payable
            newLinkedPayableId = await payablesRepository.createPayable(
              PayablesCompanion(
                contactId: Value(contactId),
                amount: Value(amount),
                description: Value(description),
                date: Value(date),
                status: const Value('PENDING'),
                linkedIncomeId: Value(transactionId),
                autoCreateExpense: const Value(true),
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
          } else if (paidRelationship == 'WILL_RECEIVE') {
            // Create receivable
            newLinkedReceivableId = await receivablesRepository.createReceivable(
              ReceivablesCompanion(
                contactId: Value(contactId),
                amount: Value(amount),
                description: Value(description),
                date: Value(date),
                status: const Value('PENDING'),
                linkedIncomeId: Value(transactionId),
                autoCreateIncome: const Value(false),
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
          }
        }

        // Update transaction with new linked IDs
        if (newLinkedPayableId != null || newLinkedReceivableId != null) {
          await transactionsRepository.updateTransactionWithCompanion(
            transactionId,
            TransactionsCompanion(
              linkedPayableId: Value(newLinkedPayableId),
              linkedReceivableId: Value(newLinkedReceivableId),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }
      // 6. If no recreation needed but linked entries exist, just sync them
      else if (!shouldCreateNewLinks && !shouldDeleteOldLinks) {
        if (existingTransaction.linkedPayableId != null) {
          final payableCompanion = PayablesCompanion(
            amount: Value(amount),
            description: Value(description),
            date: Value(date),
            updatedAt: Value(DateTime.now()),
          );
          if (contactId != null) {
            await payablesRepository.updatePayableWithCompanion(
              existingTransaction.linkedPayableId!,
              payableCompanion.copyWith(contactId: Value(contactId)),
            );
          } else {
            await payablesRepository.updatePayableWithCompanion(
              existingTransaction.linkedPayableId!,
              payableCompanion,
            );
          }
        }

        if (existingTransaction.linkedReceivableId != null) {
          final receivableCompanion = ReceivablesCompanion(
            amount: Value(amount),
            description: Value(description),
            date: Value(date),
            updatedAt: Value(DateTime.now()),
          );
          if (contactId != null) {
            await receivablesRepository.updateReceivableWithCompanion(
              existingTransaction.linkedReceivableId!,
              receivableCompanion.copyWith(contactId: Value(contactId)),
            );
          } else {
            await receivablesRepository.updateReceivableWithCompanion(
              existingTransaction.linkedReceivableId!,
              receivableCompanion,
            );
          }
        }
      }

      // 7. Update usage counts if categories/contacts changed
      if (categoryId != existingTransaction.categoryId) {
        if (existingTransaction.categoryId != null) {
          await categoriesRepository.decrementUsageCount(existingTransaction.categoryId!);
        }
        if (categoryId != null) {
          await categoriesRepository.incrementUsageCount(categoryId);
        }
      }

      if (contactId != existingTransaction.contactId) {
        if (existingTransaction.contactId != null) {
          await contactsRepository.decrementUsageCount(existingTransaction.contactId!);
        }
        if (contactId != null) {
          await contactsRepository.incrementUsageCount(contactId);
        }
      }
    });
  }

  /// Delete a transaction and its linked entries
  Future<void> deleteTransaction(int transactionId) async {
    await database.transaction(() async {
      // 1. Get the existing transaction to check for linked entries
      final existingTransaction = await transactionsRepository.getTransactionById(transactionId);
      
      if (existingTransaction == null) {
        throw Exception('Transaction not found');
      }

      // 2. Delete linked entries first
      if (existingTransaction.linkedPayableId != null) {
        await payablesRepository.deletePayable(existingTransaction.linkedPayableId!);
      }

      if (existingTransaction.linkedReceivableId != null) {
        await receivablesRepository.deleteReceivable(existingTransaction.linkedReceivableId!);
      }

      // 3. Decrement usage counts
      if (existingTransaction.categoryId != null) {
        await categoriesRepository.decrementUsageCount(existingTransaction.categoryId!);
      }
      if (existingTransaction.contactId != null) {
        await contactsRepository.decrementUsageCount(existingTransaction.contactId!);
      }

      // 4. Delete the transaction
      await transactionsRepository.deleteTransaction(transactionId);
    });
  }

  /// Generate dummy transactions for testing pagination
  /// Creates transactions with various dates, amounts, and types
  Future<void> generateDummyTransactions({int count = 100}) async {
    // Get categories and contacts
    final expenseCategories = await categoriesRepository.watchCategoriesByType('EXPENSE').first;
    final incomeCategories = await categoriesRepository.watchCategoriesByType('INCOME').first;
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
      final daysAgo = i ~/ 2; // Spread transactions over time
      final date = DateTime.now().subtract(Duration(days: daysAgo));
      final isExpense = i % 3 != 0; // Mix of expenses and income
      final type = isExpense ? 'EXPENSE' : 'INCOME';
      
      // Random amount between 10 and 5000
      final amount = (10.0 + (i * 23.5) % 4990).roundToDouble();
      
      // Pick random category
      final categories = isExpense ? expenseCategories : incomeCategories;
      int? categoryId;
      if (categories.isNotEmpty) {
        categoryId = categories[i % categories.length].id;
      }
      
      // Pick random contact (optional)
      int? contactId;
      if (contacts.isNotEmpty && i % 4 == 0) {
        contactId = contacts[i % contacts.length].id;
      }
      
      // Pick random description
      final description = descriptions[i % descriptions.length] + ' #${i + 1}';

      await createTransaction(
        amount: amount,
        type: type,
        date: date,
        description: description,
        categoryId: categoryId,
        contactId: contactId,
      );
    }
  }
}
