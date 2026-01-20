import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/whatsapp/domain/models/shared_data_models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/receivables/domain/models.dart';
import 'package:flowpaisa/features/payables/domain/models.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flowpaisa/features/payables/presentation/screens/add_payable_screen.dart';
import 'package:flowpaisa/features/receivables/presentation/screens/add_receivable_screen.dart';
import 'package:flowpaisa/features/payables/presentation/widgets/payable_details_dialog.dart';
import 'package:flowpaisa/features/receivables/presentation/widgets/receivable_details_dialog.dart';

class ImportDialog extends ConsumerStatefulWidget {
  final SharedData sharedData;

  const ImportDialog({
    super.key,
    required this.sharedData,
  });

  @override
  ConsumerState<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<ImportDialog> {
  bool _isImporting = false;
  bool _alreadyImported = false;
  bool _isSettledUpdate = false;
  String? _errorMessage;
  dynamic _existingItemWithLinkedData;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyImported();
  }

  Future<void> _checkIfAlreadyImported() async {
    final externalId = widget.sharedData.externalLinkId;
    final sharedStatus = widget.sharedData.status;
    final sharedType = widget.sharedData.type;
    bool exists = false;

    debugPrint(
        'ImportDialog: Checking externalId: $externalId, type: $sharedType, status: $sharedStatus');

    try {
      // Priority 1: Check Payables (Focus according to user requirement)
      final payablesRepo = ref.read(payablesRepositoryProvider);
      final payable = await payablesRepo.getPayableByExternalLinkId(externalId);
      if (payable != null) {
        exists = true;
        _existingItemWithLinkedData =
            await payablesRepo.getPayableWithLinkedDataById(payable.id);
        debugPrint('ImportDialog: Found matching Payable.');
      } else {
        // Priority 2: Check Receivables
        final receivablesRepo = ref.read(receivablesRepositoryProvider);
        final receivable =
            await receivablesRepo.getReceivableByExternalLinkId(externalId);
        if (receivable != null) {
          exists = true;
          _existingItemWithLinkedData = await receivablesRepo
              .getReceivableWithLinkedDataById(receivable.id);
          debugPrint('ImportDialog: Found matching Receivable.');
        } else {
          // Priority 3: Check Transactions
          exists = await ref
              .read(transactionsRepositoryProvider)
              .checkIfExternalLinkExists(externalId);
          debugPrint(
              'ImportDialog: Checked Transactions table. Exists: $exists');
        }
      }

      if (!exists) {
        debugPrint('ImportDialog: externalId NOT FOUND in any table.');
      } else {
        debugPrint('ImportDialog: externalId FOUND in the database.');
      }

      if (mounted) {
        setState(() {
          _alreadyImported = exists;
          _isSettledUpdate =
              exists && (sharedStatus == 'PAID' || sharedStatus == 'RECEIVED');
          debugPrint(
              'ImportDialog: _alreadyImported: $_alreadyImported, _isSettledUpdate: $_isSettledUpdate');
        });
      }
    } catch (e) {
      debugPrint('Error checking if already imported: $e');
    }
  }

  void _navigateToDetails() {
    debugPrint(
        'ImportDialog: Navigating to details. sharedData type: ${widget.sharedData.runtimeType}');
    Navigator.of(context).pop(); // Close dialog

    if (_existingItemWithLinkedData is ReceivableWithLinkedData) {
      debugPrint('ImportDialog: Pushing ReceivableDetailsDialog');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ReceivableDetailsDialog(item: _existingItemWithLinkedData),
        ),
      );
    } else if (_existingItemWithLinkedData is PayableWithLinkedData) {
      debugPrint('ImportDialog: Pushing PayableDetailsDialog');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PayableDetailsDialog(item: _existingItemWithLinkedData),
        ),
      );
    } else {
      debugPrint(
          'ImportDialog: Warning - no details screen found for this type/data combo');
    }
  }

  void _navigateToCreate() {
    debugPrint(
        'ImportDialog: Navigating to create. sharedData type: ${widget.sharedData.runtimeType}');
    Navigator.of(context).pop(); // Close dialog first

    if (widget.sharedData is TransactionShareData) {
      final data = widget.sharedData as TransactionShareData;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddTransactionScreen(
            initialAmount: data.amount,
            initialDate: data.date,
            initialDescription: data.description,
            initialType: data.transactionType,
            initialRelationship: data.relationship,
            initialCategoryName: data.categoryName,
            initialCategoryColor: data.categoryColor,
            initialCategoryIcon: data.categoryIcon,
            initialContactName: data.senderName,
            initialContactPhone: data.senderPhone,
            initialExternalLinkId: data.externalLinkId,
          ),
        ),
      );
    } else if (widget.sharedData is ReceivableShareData) {
      final data = widget.sharedData as ReceivableShareData;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddReceivableScreen(
            initialAmount: data.amount,
            initialDate: data.date,
            initialDescription: data.description,
            initialContactName: data.senderName,
            initialContactPhone: data.senderPhone,
            initialExternalLinkId: data.externalLinkId,
          ),
        ),
      );
    } else if (widget.sharedData is PayableShareData) {
      final data = widget.sharedData as PayableShareData;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPayableScreen(
            initialAmount: data.amount,
            initialDate: data.date,
            initialDescription: data.description,
            initialContactName: data.senderName,
            initialContactPhone: data.senderPhone,
            initialExternalLinkId: data.externalLinkId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  color: _isSettledUpdate
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: _isSettledUpdate ? Colors.green : Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(
                        _isSettledUpdate
                            ? Icons.check_circle_outline
                            : Icons.info_outline,
                        color: _isSettledUpdate ? Colors.green : Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isSettledUpdate
                            ? '${widget.sharedData.senderName ?? 'Sender'} has marked this as ${widget.sharedData.status}. Update your local record?'
                            : 'This item has already been imported.',
                        style: TextStyle(
                            color: _isSettledUpdate
                                ? Colors.green.shade800
                                : Colors.orange.shade800),
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
            onPressed: _isImporting ? null : _navigateToCreate,
            child: const Text('Import Details'),
          )
        else
          ElevatedButton(
            onPressed: _isImporting
                ? null
                : (_isSettledUpdate ? _navigateToDetails : _navigateToCreate),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isSettledUpdate ? Colors.green : Colors.grey.shade400,
              foregroundColor: Colors.white,
            ),
            child: Text(_isSettledUpdate ? 'View Details' : 'View Details'),
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
        if (data.senderName != null) ...[
          Text(
            'Shared by: ${data.senderName}',
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
            'Amount',
            AmountFormatter.formatWithCurrency(data.amount, currencySymbol,
                ref.watch(currentCurrencyProvider).value?.decimalPlaces ?? 2)),
        if (data.description != null && data.description!.isNotEmpty)
          _buildDetailRow('Description', data.description!),
        if (data.categoryName != null)
          _buildDetailRow('Category', data.categoryName!),
        if (data.contactName != null)
          _buildDetailRow('Contact', data.contactName!),
        _buildDetailRow(
            'Date',
            AppDateFormatter.formatDate(data.date,
                pattern: ref.watch(userProfileProvider).dateFormat)),
      ],
    );
  }

  Widget _buildReceivablePreview(
      ReceivableShareData data, String currencySymbol) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.senderName != null) ...[
          Text(
            'Shared by: ${data.senderName}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
        ],
        _buildDetailRow(
            'Amount',
            AmountFormatter.formatWithCurrency(data.amount, currencySymbol,
                ref.watch(currentCurrencyProvider).value?.decimalPlaces ?? 2)),
        if (data.description != null && data.description!.isNotEmpty)
          _buildDetailRow('Description', data.description!),
        if (data.contactName != null)
          _buildDetailRow('Contact', data.contactName!),
        _buildDetailRow(
            'Date',
            AppDateFormatter.formatDate(data.date,
                pattern: ref.watch(userProfileProvider).dateFormat)),
        if (data.dueDate != null)
          _buildDetailRow(
              'Due Date',
              AppDateFormatter.formatDate(data.dueDate!,
                  pattern: ref.watch(userProfileProvider).dateFormat)),
      ],
    );
  }

  Widget _buildPayablePreview(PayableShareData data, String currencySymbol) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.senderName != null) ...[
          Text(
            'Shared by: ${data.senderName}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
        ],
        _buildDetailRow(
            'Amount',
            AmountFormatter.formatWithCurrency(data.amount, currencySymbol,
                ref.watch(currentCurrencyProvider).value?.decimalPlaces ?? 2)),
        if (data.description != null && data.description!.isNotEmpty)
          _buildDetailRow('Description', data.description!),
        if (data.contactName != null)
          _buildDetailRow('Contact', data.contactName!),
        _buildDetailRow(
            'Date',
            AppDateFormatter.formatDate(data.date,
                pattern: ref.watch(userProfileProvider).dateFormat)),
        if (data.dueDate != null)
          _buildDetailRow(
              'Due Date',
              AppDateFormatter.formatDate(data.dueDate!,
                  pattern: ref.watch(userProfileProvider).dateFormat)),
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
