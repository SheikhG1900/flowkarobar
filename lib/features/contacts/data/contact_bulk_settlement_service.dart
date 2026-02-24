import 'package:drift/drift.dart' show Value;
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/payables/data/payables_repository.dart';
import 'package:flowpaisa/features/receivables/data/receivables_repository.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:uuid/uuid.dart';

/// Service to perform bulk pay/receive operations for a single contact.
class ContactBulkSettlementService {
  final PayablesRepository payablesRepository;
  final ReceivablesRepository receivablesRepository;
  final TransactionsRepository transactionsRepository;

  ContactBulkSettlementService({
    required this.payablesRepository,
    required this.receivablesRepository,
    required this.transactionsRepository,
  });

  /// Settle all pending payables and receivables for a contact.
  ///
  /// This blindly marks:
  /// - all PENDING payables as PAID
  /// - all PENDING receivables as RECEIVED
  Future<void> settleAll(String contactUuid) async {
    // Get current pending entries
    final pendingPayables =
        await payablesRepository.getPendingPayablesForContactOrderedForSettlement(
      contactUuid,
    );
    final pendingReceivables = await receivablesRepository
        .getPendingReceivablesForContactOrderedForSettlement(contactUuid);

    // Mark payables as paid
    for (final payable in pendingPayables) {
      await payablesRepository.markAsPaid(payable.uuid);
    }

    // Mark receivables as received
    for (final receivable in pendingReceivables) {
      await receivablesRepository.markAsReceived(receivable.uuid);
    }
  }

  /// Settle a specific [amount] (net) for a contact.
  ///
  /// [amount] is the net amount to settle. When [isNetReceivable] is true,
  /// net = receivables received − payables paid; when false, net = payables
  /// paid − receivables received.
  ///
  /// Receivable case: Mark all payables as PAID, then mark receivables as
  /// RECEIVED until (sum of receivables marked) = [amount] + (total payables
  /// marked). Any remainder gets a linked INCOME transaction (RECEIVED_FROM) +
  /// Payable — not marked.
  ///
  /// Payable case: Mark all receivables as RECEIVED, then mark payables as
  /// PAID until (sum of payables marked) = [amount] + (total receivables
  /// marked). Remainder gets a linked EXPENSE transaction (PAID_FOR) +
  /// Receivable — not marked.
  Future<void> settleAmount(
    String contactUuid,
    double amount, {
    required bool isNetReceivable,
  }) async {
    if (amount <= 0) return;

    // Snapshot current pending items
    final pendingPayables =
        await payablesRepository.getPendingPayablesForContactOrderedForSettlement(
      contactUuid,
    );
    final pendingReceivables = await receivablesRepository
        .getPendingReceivablesForContactOrderedForSettlement(contactUuid);

    final totalPayable =
        pendingPayables.fold<double>(0, (sum, p) => sum + p.amount);
    final totalReceivable =
        pendingReceivables.fold<double>(0, (sum, r) => sum + r.amount);
    final netBalance = totalReceivable - totalPayable;

    if (netBalance.abs() < 0.01) {
      // Nothing meaningful to settle
      return;
    }

    // If user-settle amount is effectively "all", just settle everything.
    if (amount >= netBalance.abs() - 0.01) {
      await settleAll(contactUuid);
      return;
    }

    if (isNetReceivable && netBalance <= 0) {
      // Defensive: if net is not actually receivable, do nothing.
      return;
    }
    if (!isNetReceivable && netBalance >= 0) {
      // Defensive: if net is not actually payable, do nothing.
      return;
    }

    if (isNetReceivable) {
      await _settleReceivableAmount(
        contactUuid: contactUuid,
        amount: amount,
        pendingPayables: pendingPayables,
        pendingReceivables: pendingReceivables,
      );
    } else {
      await _settlePayableAmount(
        contactUuid: contactUuid,
        amount: amount,
        pendingPayables: pendingPayables,
        pendingReceivables: pendingReceivables,
      );
    }
  }

  Future<void> _settleReceivableAmount({
    required String contactUuid,
    required double amount,
    required List<Payable> pendingPayables,
    required List<Receivable> pendingReceivables,
  }) async {
    final totalPayable =
        pendingPayables.fold<double>(0, (sum, p) => sum + p.amount);
    // Net settled = receivables marked - payables marked. We mark all payables,
    // so we must mark receivables until sum = amount + totalPayable.
    double targetReceivableSum = amount + totalPayable;

    // 1. Mark all payables as paid.
    for (final payable in pendingPayables) {
      await payablesRepository.markAsPaid(payable.uuid);
    }

    // 2. Mark receivables in order until we've reached target sum (overdue first, then by date).
    final ordered = _orderReceivablesForSettlement(pendingReceivables);
    final used = <String>{};
    double receivableMarkedSum = 0;

    for (final r in ordered) {
      if (receivableMarkedSum >= targetReceivableSum - 1e-6) break;
      if (used.contains(r.uuid)) continue;
      if (receivableMarkedSum + r.amount <= targetReceivableSum + 1e-6) {
        await receivablesRepository.markAsReceived(r.uuid);
        receivableMarkedSum += r.amount;
        used.add(r.uuid);
      }
    }

    // Second pass: greedy pick any receivable that fits into remaining target.
    bool progress;
    do {
      progress = false;
      if (receivableMarkedSum >= targetReceivableSum - 1e-6) break;
      final remaining = targetReceivableSum - receivableMarkedSum;
      for (final r in ordered) {
        if (used.contains(r.uuid)) continue;
        if (r.amount <= remaining + 1e-6) {
          await receivablesRepository.markAsReceived(r.uuid);
          receivableMarkedSum += r.amount;
          used.add(r.uuid);
          progress = true;
          break;
        }
      }
    } while (progress &&
        receivableMarkedSum < targetReceivableSum - 1e-6);

    // 3. Remainder: create linked INCOME transaction (RECEIVED_FROM) + Payable — do NOT mark.
    final remainder = targetReceivableSum - receivableMarkedSum;
    if (remainder > 0.01) {
      final now = DateTime.now();
      final txUuid = const Uuid().v4();
      await transactionsRepository.createTransaction(
        TransactionsCompanion(
          uuid: Value(txUuid),
          amount: Value(remainder),
          type: const Value('INCOME'),
          contactUuid: Value(contactUuid),
          description: const Value('bulk adjustment'),
          date: Value(now),
          paidRelationship: const Value('RECEIVED_FROM'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      final payableUuid = await payablesRepository.createPayable(
        PayablesCompanion(
          contactUuid: Value(contactUuid),
          amount: Value(remainder),
          description: const Value('bulk adjustment'),
          date: Value(now),
          status: const Value('PENDING'),
          linkedIncomeUuid: Value(txUuid),
          autoCreateExpense: const Value(false),
        ),
      );
      await transactionsRepository.updateTransactionWithCompanion(
        txUuid,
        TransactionsCompanion(
          linkedPayableUuid: Value(payableUuid),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> _settlePayableAmount({
    required String contactUuid,
    required double amount,
    required List<Payable> pendingPayables,
    required List<Receivable> pendingReceivables,
  }) async {
    final totalReceivable =
        pendingReceivables.fold<double>(0, (sum, r) => sum + r.amount);
    // Net settled = payables marked - receivables marked. We mark all receivables,
    // so we must mark payables until sum = amount + totalReceivable.
    double targetPayableSum = amount + totalReceivable;

    // 1. Mark all receivables as received.
    for (final receivable in pendingReceivables) {
      await receivablesRepository.markAsReceived(receivable.uuid);
    }

    // 2. Mark payables in order until we've reached target sum (overdue first, then by date).
    final ordered = _orderPayablesForSettlement(pendingPayables);
    final used = <String>{};
    double payableMarkedSum = 0;

    for (final p in ordered) {
      if (payableMarkedSum >= targetPayableSum - 1e-6) break;
      if (used.contains(p.uuid)) continue;
      if (payableMarkedSum + p.amount <= targetPayableSum + 1e-6) {
        await payablesRepository.markAsPaid(p.uuid);
        payableMarkedSum += p.amount;
        used.add(p.uuid);
      }
    }

    // Second pass: greedy pick any payable that fits into remaining target.
    bool progress;
    do {
      progress = false;
      if (payableMarkedSum >= targetPayableSum - 1e-6) break;
      final remaining = targetPayableSum - payableMarkedSum;
      for (final p in ordered) {
        if (used.contains(p.uuid)) continue;
        if (p.amount <= remaining + 1e-6) {
          await payablesRepository.markAsPaid(p.uuid);
          payableMarkedSum += p.amount;
          used.add(p.uuid);
          progress = true;
          break;
        }
      }
    } while (progress && payableMarkedSum < targetPayableSum - 1e-6);

    // 3. Remainder: create linked EXPENSE transaction (PAID_FOR) + Receivable — do NOT mark.
    final remainder = targetPayableSum - payableMarkedSum;
    if (remainder > 0.01) {
      final now = DateTime.now();
      final txUuid = const Uuid().v4();
      await transactionsRepository.createTransaction(
        TransactionsCompanion(
          uuid: Value(txUuid),
          amount: Value(remainder),
          type: const Value('EXPENSE'),
          contactUuid: Value(contactUuid),
          description: const Value('bulk adjustment'),
          date: Value(now),
          paidRelationship: const Value('PAID_FOR'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      final receivableUuid = await receivablesRepository.createReceivable(
        ReceivablesCompanion(
          contactUuid: Value(contactUuid),
          amount: Value(remainder),
          description: const Value('bulk adjustment'),
          date: Value(now),
          status: const Value('PENDING'),
          linkedExpenseUuid: Value(txUuid),
          autoCreateIncome: const Value(false),
        ),
      );
      await transactionsRepository.updateTransactionWithCompanion(
        txUuid,
        TransactionsCompanion(
          linkedReceivableUuid: Value(receivableUuid),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  List<Receivable> _orderReceivablesForSettlement(
      List<Receivable> receivables) {
    final now = DateTime.now();
    final overdue = <Receivable>[];
    final normal = <Receivable>[];

    for (final r in receivables) {
      final due = r.dueDate;
      if (due != null && due.isBefore(now)) {
        overdue.add(r);
      } else {
        normal.add(r);
      }
    }

    return [...overdue, ...normal];
  }

  List<Payable> _orderPayablesForSettlement(List<Payable> payables) {
    final now = DateTime.now();
    final overdue = <Payable>[];
    final normal = <Payable>[];

    for (final p in payables) {
      final due = p.dueDate;
      if (due != null && due.isBefore(now)) {
        overdue.add(p);
      } else {
        normal.add(p);
      }
    }

    return [...overdue, ...normal];
  }
}

