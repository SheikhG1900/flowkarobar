import 'package:flowpaisa/core/database/database.dart';

/// Enhanced receivable model with pre-fetched related data
/// Includes linked transaction and its category to avoid N+1 query problems
class ReceivableWithLinkedData {
  final Receivable receivable;
  final Contact? contact;
  final Transaction? linkedTransaction;
  final Category? linkedCategory;

  ReceivableWithLinkedData({
    required this.receivable,
    this.contact,
    this.linkedTransaction,
    this.linkedCategory,
  });

  @override
  String toString() {
    return 'ReceivableWithLinkedData(receivable: ${receivable.id}, contact: ${contact?.name}, linkedCategory: ${linkedCategory?.name})';
  }
}
