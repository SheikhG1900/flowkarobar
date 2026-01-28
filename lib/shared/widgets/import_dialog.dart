import "package:flowpaisa/l10n/app_localizations.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flowpaisa/core/utils/date_formatter.dart";
import "package:flowpaisa/core/utils/amount_formatter.dart";
import "package:flowpaisa/features/whatsapp/domain/models/shared_data_models.dart";
import "package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart";
import "package:flowpaisa/features/receivables/domain/models.dart";
import "package:flowpaisa/features/payables/domain/models.dart";
import "package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart";
import "package:flowpaisa/features/payables/presentation/providers/payables_provider.dart";
import "package:flowpaisa/shared/providers/currency_provider.dart";
import "package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart";
import "package:flowpaisa/features/payables/presentation/screens/add_payable_screen.dart";
import "package:flowpaisa/features/receivables/presentation/screens/add_receivable_screen.dart";
import "package:flowpaisa/features/payables/presentation/widgets/payable_details_dialog.dart";
import "package:flowpaisa/features/receivables/presentation/widgets/receivable_details_dialog.dart";

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
        "ImportDialog: Checking externalId: $externalId, type: $sharedType, status: $sharedStatus");

    try {
      final payablesRepo = ref.read(payablesRepositoryProvider);
      final payable = await payablesRepo.getPayableByExternalLinkId(externalId);
      if (payable != null) {
        exists = true;
        _existingItemWithLinkedData =
            await payablesRepo.getPayableWithLinkedDataByUuid(payable.uuid);
        debugPrint("ImportDialog: Found matching Payable.");
      } else {
        final receivablesRepo = ref.read(receivablesRepositoryProvider);
        final receivable =
            await receivablesRepo.getReceivableByExternalLinkId(externalId);
        if (receivable != null) {
          exists = true;
          _existingItemWithLinkedData = await receivablesRepo
              .getReceivableWithLinkedDataByUuid(receivable.uuid);
          debugPrint("ImportDialog: Found matching Receivable.");
        } else {
          exists = await ref
              .read(transactionsRepositoryProvider)
              .checkIfExternalLinkExists(externalId);
          debugPrint(
              "ImportDialog: Checked Transactions table. Exists: $exists");
        }
      }

      if (mounted) {
        setState(() {
          _alreadyImported = exists;
          _isSettledUpdate =
              exists && (sharedStatus == "PAID" || sharedStatus == "RECEIVED");
        });
      }
    } catch (e) {
      debugPrint("Error checking if already imported: $e");
    }
  }

  void _navigateToDetails() {
    Navigator.of(context).pop();
    if (_existingItemWithLinkedData is ReceivableWithLinkedData) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ReceivableDetailsDialog(item: _existingItemWithLinkedData),
        ),
      );
    } else if (_existingItemWithLinkedData is PayableWithLinkedData) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PayableDetailsDialog(item: _existingItemWithLinkedData),
        ),
      );
    }
  }

  void _navigateToCreate() {
    Navigator.of(context).pop();
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
            initialDueDate: data.dueDate,
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
            initialDueDate: data.dueDate,
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
            initialDueDate: data.dueDate,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getIcon(),
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_getTitle(context)),
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
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
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
                            ? l10n.markedAsStatus(
                                widget.sharedData.senderName ?? l10n.someone,
                                widget.sharedData.status!)
                            : l10n.itemAlreadyImported,
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
              _buildDataPreview(context),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        if (!_alreadyImported)
          ElevatedButton(
            onPressed: _isImporting ? null : _navigateToCreate,
            child: Text(l10n.importDetails),
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
            child: Text(l10n.viewDetails),
          ),
      ],
    );
  }

  IconData _getIcon() {
    if (widget.sharedData is TransactionShareData) {
      final tx = widget.sharedData as TransactionShareData;
      return tx.transactionType == "EXPENSE"
          ? Icons.arrow_downward
          : Icons.arrow_upward;
    } else if (widget.sharedData is ReceivableShareData) {
      return Icons.account_balance_wallet;
    } else {
      return Icons.payment;
    }
  }

  String _getTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.sharedData is TransactionShareData) {
      return l10n.importTransaction;
    } else if (widget.sharedData is ReceivableShareData) {
      return l10n.importReceivable;
    } else {
      return l10n.importPayable;
    }
  }

  Widget _buildDataPreview(BuildContext context) {
    final currencySymbol = ref.watch(currencySymbolProvider);
    if (widget.sharedData is TransactionShareData) {
      return _buildTransactionPreview(
          context, widget.sharedData as TransactionShareData, currencySymbol);
    } else if (widget.sharedData is ReceivableShareData) {
      return _buildReceivablePreview(
          context, widget.sharedData as ReceivableShareData, currencySymbol);
    } else {
      return _buildPayablePreview(
          context, widget.sharedData as PayableShareData, currencySymbol);
    }
  }

  Widget _buildTransactionPreview(
      BuildContext context, TransactionShareData data, String currencySymbol) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.senderName != null) ...[
          Text(
            l10n.sharedBy(data.senderName!),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
        ],
        _buildDetailRow(l10n.type, data.transactionType),
        _buildDetailRow(
            l10n.amount,
            AmountFormatter.formatWithCurrency(data.amount, currencySymbol,
                ref.watch(currentCurrencyProvider).value?.decimalPlaces ?? 2)),
        if (data.description != null && data.description!.isNotEmpty)
          _buildDetailRow(l10n.description, data.description!),
        if (data.categoryName != null)
          _buildDetailRow(l10n.category, data.categoryName!),
        if (data.contactName != null)
          _buildDetailRow(l10n.contact, data.contactName!),
        _buildDetailRow(
            l10n.date,
            AppDateFormatter.formatDate(data.date)),
        if (data.dueDate != null)
          _buildDetailRow(
              l10n.dueDate,
              AppDateFormatter.formatDate(data.dueDate!)),
      ],
    );
  }

  Widget _buildReceivablePreview(
      BuildContext context, ReceivableShareData data, String currencySymbol) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.senderName != null) ...[
          Text(
            l10n.sharedBy(data.senderName!),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
        ],
        _buildDetailRow(
            l10n.amount,
            AmountFormatter.formatWithCurrency(data.amount, currencySymbol,
                ref.watch(currentCurrencyProvider).value?.decimalPlaces ?? 2)),
        if (data.description != null && data.description!.isNotEmpty)
          _buildDetailRow(l10n.description, data.description!),
        if (data.contactName != null)
          _buildDetailRow(l10n.contact, data.contactName!),
        _buildDetailRow(
            l10n.date,
            AppDateFormatter.formatDate(data.date)),
        if (data.dueDate != null)
          _buildDetailRow(
              l10n.dueDate,
              AppDateFormatter.formatDate(data.dueDate!)),
      ],
    );
  }

  Widget _buildPayablePreview(
      BuildContext context, PayableShareData data, String currencySymbol) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.senderName != null) ...[
          Text(
            l10n.sharedBy(data.senderName!),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
        ],
        _buildDetailRow(
            l10n.amount,
            AmountFormatter.formatWithCurrency(data.amount, currencySymbol,
                ref.watch(currentCurrencyProvider).value?.decimalPlaces ?? 2)),
        if (data.description != null && data.description!.isNotEmpty)
          _buildDetailRow(l10n.description, data.description!),
        if (data.contactName != null)
          _buildDetailRow(l10n.contact, data.contactName!),
        _buildDetailRow(
            l10n.date,
            AppDateFormatter.formatDate(data.date)),
        if (data.dueDate != null)
          _buildDetailRow(
              l10n.dueDate,
              AppDateFormatter.formatDate(data.dueDate!)),
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
              "$label:",
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

