import 'package:flutter/material.dart';

/// Represents a help scenario for transaction/schedule type + relationship selection.
/// Used by the scenario picker to pre-fill Income/Expense and Payable/Receivable.
class TransactionScenario {
  final String id;
  final String type;
  final String? relationship;
  final IconData icon;
  final int sortOrder;

  const TransactionScenario({
    required this.id,
    required this.type,
    this.relationship,
    required this.icon,
    this.sortOrder = 0,
  });

  bool get isExpense => type == 'EXPENSE';
  bool get isIncome => type == 'INCOME';
  bool get hasRelationship => relationship != null && relationship!.isNotEmpty;
}
