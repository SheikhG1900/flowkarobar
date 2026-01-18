import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/whatsapp/domain/models/shared_data_models.dart';
import 'package:flowpaisa/features/receivables/data/receivables_repository.dart';
import 'package:flowpaisa/features/payables/data/payables_repository.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/features/contacts/data/contacts_repository.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flowpaisa/shared/providers/currency_provider.dart';

class ImportDialog extends ConsumerStatefulWidget {
  final SharedData sharedData;
  final WidgetRef ref;

  const ImportDialog({
    Key? key,
    required this.sharedData,
    required this.ref,
  }) : super(key: key);

  @override
  ConsumerState<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<ImportDialog> {
  bool _isImporting = false;
  bool _alreadyImported = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyImported();
  }

  Future<void> _checkIfAlreadyImported() async {
    final database = ref.read(databaseProvider);

    try {
      if (widget.sharedData is ReceivableShareData) {
        final repo = ReceivablesRepository(database);
        _alreadyImported = await repo.checkIfExternalLinkExists(
          widget.sharedData.externalLinkId,
        );
      } else if (widget.sharedData is PayableShareData) {
        final repo = PayablesRepository(database);
        _alreadyImported = await repo.checkIfExternalLinkExists(
          widget.sharedData.externalLinkId,
        );
      }
      // For transactions, we don't check (allow duplicates)

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error checking if already imported: $e');
    }
  }

  Future<void> _importData() async {
    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    try {
      final database = ref.read(databaseProvider);

      if (widget.sharedData is TransactionShareData) {
        await _importTransaction(
            database, widget.sharedData as TransactionShareData);
      } else if (widget.sharedData is ReceivableShareData) {
        await _importReceivable(
            database, widget.sharedData as ReceivableShareData);
      } else if (widget.sharedData is PayableShareData) {
        await _importPayable(database, widget.sharedData as PayableShareData);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ToastUtils.showSuccessToast(context, ref, 'Successfully imported!');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to import: $e';
        _isImporting = false;
      });
    }
  }

  Future<void> _importTransaction(database, TransactionShareData data) async {
    final repo = TransactionsRepository(database);
    final contactsRepo = ContactsRepository(database);

    // Find or create contact if phone is provided
    int? contactId;
    if (data.contactPhone != null && data.contactPhone!.isNotEmpty) {
      contactId = await contactsRepo.findOrCreateContactByPhone(
        phone: data.contactPhone!,
        name: data.contactName ?? 'Unknown',
      );
    }

    await repo.createTransactionSimple(
      amount: data.amount,
      type: data.transactionType,
      description: data.description,
      date: data.date,
      categoryId: null, // User can edit later
      contactId: contactId,
    );
  }

  Future<void> _importReceivable(database, ReceivableShareData data) async {
    final repo = ReceivablesRepository(database);
    await repo.importFromSharedLink(data);
  }

  Future<void> _importPayable(database, PayableShareData data) async {
    final repo = PayablesRepository(database);
    await repo.importFromSharedLink(data);
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = ref.watch(currencySymbolProvider);
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getIcon(),
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_getTitle()),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_alreadyImported)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This item has already been imported.',
                        style: TextStyle(color: Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              _buildDataPreview(),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (!_alreadyImported)
          ElevatedButton(
            onPressed: _isImporting ? null : _importData,
            child: _isImporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Import'),
          ),
      ],
    );
  }

  IconData _getIcon() {
    if (widget.sharedData is TransactionShareData) {
      final tx = widget.sharedData as TransactionShareData;
      return tx.transactionType == 'EXPENSE'
          ? Icons.arrow_downward
          : Icons.arrow_upward;
    } else if (widget.sharedData is ReceivableShareData) {
      return Icons.account_balance_wallet;
    } else {
      return Icons.payment;
    }
  }

  String _getTitle() {
    if (widget.sharedData is TransactionShareData) {
      return 'Import Transaction';
    } else if (widget.sharedData is ReceivableShareData) {
      return 'Import Receivable';
    } else {
      return 'Import Payable';
    }
  }

  Widget _buildDataPreview() {
    final currencySymbol = ref.watch(currencySymbolProvider);

    if (widget.sharedData is TransactionShareData) {
      return _buildTransactionPreview(
          widget.sharedData as TransactionShareData, currencySymbol);
    } else if (widget.sharedData is ReceivableShareData) {
      return _buildReceivablePreview(
          widget.sharedData as ReceivableShareData, currencySymbol);
    } else {
      return _buildPayablePreview(
          widget.sharedData as PayableShareData, currencySymbol);
    }
  }

  Widget _buildTransactionPreview(
      TransactionShareData data, String currencySymbol) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.sharedBy != null) ...[
          Text(
            'Shared by: ${data.sharedBy}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
        ],
        _buildDetailRow('Type', data.transactionType),
        _buildDetailRow(
            'Amount', '$currencySymbol${data.amount.toStringAsFixed(2)}'),
        if (data.description != null && data.description!.isNotEmpty)
          _buildDetailRow('Description', data.description!),
        if (data.categoryName != null)
          _buildDetailRow('Category', data.categoryName!),
        if (data.contactName != null)
          _buildDetailRow('Contact', data.contactName!),
        _buildDetailRow('Date', AppDateFormatter.formatDate(data.date, pattern: ref.watch(userProfileProvider).dateFormat)),
      ],
    );
  }

  Widget _buildReceivablePreview(
      ReceivableShareData data, String currencySymbol) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.sharedBy != null) ...[
          Text(
            'Shared by: ${data.sharedBy}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
        ],
        _buildDetailRow(
            'Amount', '$currencySymbol${data.amount.toStringAsFixed(2)}'),
        if (data.description != null && data.description!.isNotEmpty)
          _buildDetailRow('Description', data.description!),
        if (data.contactName != null)
          _buildDetailRow('Contact', data.contactName!),
        _buildDetailRow('Date', AppDateFormatter.formatDate(data.date, pattern: ref.watch(userProfileProvider).dateFormat)),
        if (data.dueDate != null)
          _buildDetailRow('Due Date', AppDateFormatter.formatDate(data.dueDate!, pattern: ref.watch(userProfileProvider).dateFormat)),
      ],
    );
  }

  Widget _buildPayablePreview(PayableShareData data, String currencySymbol) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.sharedBy != null) ...[
          Text(
            'Shared by: ${data.sharedBy}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
        ],
        _buildDetailRow(
            'Amount', '$currencySymbol${data.amount.toStringAsFixed(2)}'),
        if (data.description != null && data.description!.isNotEmpty)
          _buildDetailRow('Description', data.description!),
        if (data.contactName != null)
          _buildDetailRow('Contact', data.contactName!),
        _buildDetailRow('Date', AppDateFormatter.formatDate(data.date, pattern: ref.watch(userProfileProvider).dateFormat)),
        if (data.dueDate != null)
          _buildDetailRow('Due Date', AppDateFormatter.formatDate(data.dueDate!, pattern: ref.watch(userProfileProvider).dateFormat)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
