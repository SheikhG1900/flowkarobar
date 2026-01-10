import 'package:flowpaisa/core/database/database.dart';

/// Enhanced payable model with pre-fetched related data
/// Includes linked transaction and its category to avoid N+1 query problems
class PayableWithLinkedData {
  final Payable payable;
  final Contact? contact;
  final Transaction? linkedTransaction;
  final Category? linkedCategory;

  PayableWithLinkedData({
    required this.payable,
    this.contact,
    this.linkedTransaction,
    this.linkedCategory,
  });

  @override
  String toString() {
    return 'PayableWithLinkedData(payable: ${payable.id}, contact: ${contact?.name}, linkedCategory: ${linkedCategory?.name})';
  }
}
