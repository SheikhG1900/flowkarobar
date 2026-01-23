import 'package:flowpaisa/core/database/database.dart';

/// Enhanced transaction model with pre-fetched related data
/// Used to avoid N+1 query problems when displaying transaction lists
class TransactionWithDetails {
  final Transaction transaction;
  final Category? category;
  final Contact? contact;
  final Payable? linkedPayable;
  final Receivable? linkedReceivable;

  TransactionWithDetails({
    required this.transaction,
    this.category,
    this.contact,
    this.linkedPayable,
    this.linkedReceivable,
  });
  
  /// Returns true if the linked payable/receivable is marked/settled
  bool get isLinkedEntryMarked {
    if (linkedPayable != null) {
      return linkedPayable!.status == 'PAID';
    }
    if (linkedReceivable != null) {
      return linkedReceivable!.status == 'RECEIVED';
    }
    return false;
  }

  @override
  String toString() {
    return 'TransactionWithDetails(transaction: ${transaction.uuid}, category: ${category?.name}, contact: ${contact?.name})';
  }
}
