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
            await receivablesRepository.createReceivable(
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
          } else if (paidRelationship == 'PAID_BY') {
            // Logic: Someone paid FOR you -> You consumed (Expense recorded),
            // but you didn't pay cash yet. You owe them (Payable).
            await payablesRepository.createPayable(
              PayablesCompanion(
                contactId: Value(contactId),
                amount: Value(amount),
                description: Value(description),
                date: Value(date),
                status: const Value('PENDING'),
                linkedExpenseId: Value(transactionId),
                autoCreateExpense:
                    const Value(true), // Settle debt = Cash Expense
                createdAt: Value(DateTime.now()),
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
            await payablesRepository.createPayable(
              PayablesCompanion(
                contactId: Value(contactId),
                amount: Value(amount),
                description: Value(description),
                date: Value(date),
                status: const Value('PENDING'),
                // linkedIncomeId is not available in Payables table currently
                autoCreateExpense:
                    const Value(true), // When you pay back, it becomes expense
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
          } else if (paidRelationship == 'WILL_RECEIVE') {
            // Logic: You earned money but haven't received it yet (Accrued Income).
            // Cash Balance UNCHANGED (handled by DashboardProvider).
            // Create Receivable.
            await receivablesRepository.createReceivable(
              ReceivablesCompanion(
                contactId: Value(contactId),
                amount: Value(amount),
                description: Value(description),
                date: Value(date),
                status: const Value('PENDING'),
                linkedIncomeId: Value(transactionId), // Store as linked income
                autoCreateIncome: const Value(
                    true), // When you receive it, it becomes realized income (cash)
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
          }
        }
      }
    });
  }
}
