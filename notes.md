   dart:633:637:lib/features/analytics/data/analytics_repository.dart

      // Exclude inactive: do not include expense/income linked to PENDING payable/receivable
      final expenseWhere = _database.transactions.type.equals('EXPENSE') &
          _database.transactions.isDeleted.equals(false) &
          (_database.transactions.linkedPayableUuid.isNull() |
              _database.payables.status.equals('PAID'));

  For Income:

   dart:655:658:lib/features/analytics/data/analytics_repository.dart

      final incomeWhere = _database.transactions.type.equals('INCOME') &
          _database.transactions.isDeleted.equals(false) &
          (_database.transactions.linkedReceivableUuid.isNull() |
              _database.receivables.status.equals('RECEIVED'));
