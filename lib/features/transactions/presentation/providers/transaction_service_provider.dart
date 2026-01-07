import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/features/receivables/data/receivables_repository.dart';
import 'package:flowpaisa/features/payables/data/payables_repository.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService(
    database: ref.watch(databaseProvider),
    transactionsRepository: ref.watch(transactionsRepositoryProvider),
    receivablesRepository: ref.watch(receivablesRepositoryProvider),
    payablesRepository: ref.watch(payablesRepositoryProvider),
  );
});

class TransactionService {
  final AppDatabase database;
  final TransactionsRepository transactionsRepository;
  final ReceivablesRepository receivablesRepository;
  final PayablesRepository payablesRepository;

  TransactionService({
    required this.database,
    required this.transactionsRepository,
    required this.receivablesRepository,
    required this.payablesRepository,
  });

  Future<void> createTransaction({
    required double amount,
    required String type,
    required DateTime date,
    String? description,
    int? categoryId,
    int? contactId,
    String? paidRelationship, // 'PAID_FOR' or 'PAID_BY'
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

      // 2. Create linked entries based on logic
      if (createLinkedEntry && contactId != null) {
        if (paidRelationship == 'PAID_FOR' && type == 'EXPENSE') {
          // Logic: You paid FOR someone -> It's an expense for you (cash out), 
          // but you expect to be paid back (Receivable).
          // Actually, strictly speaking, if you pay for someone, it might not be YOUR expense category,
          // but in cashbook terms, money left your wallet.
          
          await receivablesRepository.createReceivable(
            ReceivablesCompanion(
              contactId: Value(contactId),
              amount: Value(amount),
              description: Value(description),
              date: Value(date),
              status: const Value('PENDING'),
              linkedExpenseId: Value(transactionId),
              autoCreateIncome: const Value(true), // When they pay back, it becomes income
              createdAt: Value(DateTime.now()),
              updatedAt: Value(DateTime.now()),
            ),
          );
        } else if (paidRelationship == 'PAID_FOR' && type == 'INCOME') {
           // Logic: You received money FOR someone else -> You owe them (Payable).
           await payablesRepository.createPayable(
            PayablesCompanion(
              contactId: Value(contactId),
              amount: Value(amount),
              description: Value(description),
              date: Value(date),
              status: const Value('PENDING'),
              linkedExpenseId: Value(null),
              autoCreateExpense: const Value(true), // When you pay them, it creates expense
              createdAt: Value(DateTime.now()),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
        // 'PAID_BY' logic usually implies you didn't pay (no expense transaction for you yet), 
        // OR it's a split. 
        // For MVP, if type is EXPENSE and Paid BY someone else, 
        // it means you spent money but someone else paid -> You owe them (Payable).
        // But the current UI flow for 'Add Transaction' assumes a transaction record is created.
        // If I record an Expense of 500, paid by John:
        // 1. Transaction (Expense 500) created? 
        //    - If I create an expense, my balance goes down. 
        //    - But if John paid, my cash didn't go down. 
        //    - So this is complex. Usually 'Paid By' means "I consumed this, but didn't pay".
        //    - This fits better as just creating a Payable directly, OR 
        //    - Creating an Expense + a generic "Debt" income? No.
        //    - Let's stick to the current implementation where we only handle 'PAID_FOR' links for now
        //      as implemented in the original UI logic.
      }
    });
  }
}

