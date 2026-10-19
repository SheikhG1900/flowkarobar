import "package:flowpaisa/l10n/app_localizations.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flowpaisa/core/theme/app_colors.dart";
import "package:flowpaisa/core/utils/date_formatter.dart";
import "package:flowpaisa/core/utils/amount_formatter.dart";
import "package:flowpaisa/features/whatsapp/domain/models/shared_data_models.dart";
import "package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart";
import "package:flowpaisa/features/transactions/presentation/widgets/transaction_details_dialog.dart";
import "package:flowpaisa/features/receivables/domain/models.dart";
import "package:flowpaisa/features/payables/domain/models.dart";
import "package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart";
import "package:flowpaisa/features/payables/presentation/providers/payables_provider.dart";
import "package:flowpaisa/shared/providers/currency_provider.dart";
import "package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart";
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
  String? _existingTransactionUuid;

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
          final txRepo = ref.read(transactionsRepositoryProvider);
          final transaction =
              await txRepo.getTransactionByExternalLinkId(externalId);
          if (transaction != null) {
            exists = true;
            _existingTransactionUuid = transaction.uuid;
            debugPrint("ImportDialog: Found matching Transaction.");
          }
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
          builder: (context) => ReceivableDetailsDialog(
              receivableUuid: _existingItemWithLinkedData.receivable.uuid),
        ),
      );
    } else if (_existingItemWithLinkedData is PayableWithLinkedData) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PayableDetailsDialog(
              payableUuid: _existingItemWithLinkedData.payable.uuid),
        ),
      );
    } else if (_existingTransactionUuid != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionDetailsDialog(
              transactionUuid: _existingTransactionUuid!),
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
          builder: (context) => AddTransactionScreen(
            initialAmount: data.amount,
            initialDate: data.date,
            initialDescription: data.description,
            initialType: 'INCOME',
            initialRelationship: 'WILL_RECEIVE',
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
          builder: (context) => AddTransactionScreen(
            initialAmount: data.amount,
            initialDate: data.date,
            initialDescription: data.description,
            initialType: 'EXPENSE',
            initialRelationship: 'PAID_BY',
            initialContactName: data.senderName,
            initialContactPhone: data.senderPhone,
            initialExternalLinkId: data.externalLinkId,
            initialDueDate: data.dueDate,
          ),
        ),
      );
    }
  }

  LinearGradient _getThemeGradient() {
    final status = widget.sharedData.status?.toUpperCase();
    if (widget.sharedData is TransactionShareData) {
      final tx = widget.sharedData as TransactionShareData;
      // Recipient perspective of direct transactions:
      // Sender's EXPENSE is Recipient's INCOME (Green Gradient)
      // Sender's INCOME is Recipient's EXPENSE (Orange Gradient)
      return tx.transactionType == "EXPENSE"
          ? AppColors.incomeGradient
          : AppColors.expenseGradient;
    } else if (widget.sharedData is ReceivableShareData) {
      // ReceivableShareData is already in recipient's perspective (it's a Receivable for them):
      // If status is RECEIVED/PAID -> Recipient received (Income - Green)
      // Otherwise -> Recipient has a RECEIVABLE (Teal/Cyan)
      return (status == "RECEIVED" || status == "PAID")
          ? AppColors.incomeGradient
          : AppColors.receivablesSectionGradient; // or AppColors.receivableGradient
    } else {
      // PayableShareData is already in recipient's perspective (it's a Payable for them):
      // If status is PAID/RECEIVED -> Recipient paid (Expense - Orange)
      // Otherwise -> Recipient has a PAYABLE (Amber/Yellow)
      return (status == "PAID" || status == "RECEIVED")
          ? AppColors.expenseGradient
          : AppColors.payablesSectionGradient; // or AppColors.payableGradient
    }
  }

  Color _getThemeColor() {
    final status = widget.sharedData.status?.toUpperCase();
    if (widget.sharedData is TransactionShareData) {
      final tx = widget.sharedData as TransactionShareData;
      return tx.transactionType == "EXPENSE"
          ? AppColors.incomeColor
          : AppColors.expenseColor;
    } else if (widget.sharedData is ReceivableShareData) {
      return (status == "RECEIVED" || status == "PAID")
          ? AppColors.incomeColor
          : AppColors.receivableColor;
    } else {
      return (status == "PAID" || status == "RECEIVED")
          ? AppColors.expenseColor
          : AppColors.payableColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeColor = _getThemeColor();
    final themeGradient = _getThemeGradient();

    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      content: Container(
        decoration: BoxDecoration(
          gradient: themeGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Header with Circle Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIcon(),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getTitle(context),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Content Body
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_alreadyImported)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isSettledUpdate
                                ? Icons.check_circle_outline
                                : Icons.info_outline,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isSettledUpdate
                                  ? l10n.markedAsStatus(
                                      widget.sharedData.senderName ?? l10n.someone,
                                      widget.sharedData.status!)
                                  : l10n.itemAlreadyImported,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.85),
                  ),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                if (!_alreadyImported)
                  ElevatedButton(
                    onPressed: _isImporting ? null : _navigateToCreate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: themeColor,
                      elevation: 4,
                      shadowColor: Colors.black.withValues(alpha: 0.2),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.importDetails,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _isImporting ? null : _navigateToDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: themeColor,
                      elevation: 4,
                      shadowColor: Colors.black.withValues(alpha: 0.2),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.viewDetails,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    final status = widget.sharedData.status?.toUpperCase();
    if (widget.sharedData is TransactionShareData) {
      final tx = widget.sharedData as TransactionShareData;
      // Recipient perspective:
      // Sender's EXPENSE is Recipient's INCOME (arrow_upward)
      // Sender's INCOME is Recipient's EXPENSE (arrow_downward)
      return tx.transactionType == "EXPENSE"
          ? Icons.arrow_upward
          : Icons.arrow_downward;
    } else if (widget.sharedData is ReceivableShareData) {
      // Recipient perspective:
      // If status is RECEIVED -> Recipient paid (check_circle)
      // Otherwise -> Recipient has a PAYABLE (payment)
      return status == "RECEIVED"
          ? Icons.check_circle_outline_rounded
          : Icons.payment;
    } else {
      // Recipient perspective:
      // If status is PAID -> Recipient received (check_circle)
      // Otherwise -> Recipient has a RECEIVABLE (account_balance_wallet)
      return status == "PAID"
          ? Icons.check_circle_outline_rounded
          : Icons.account_balance_wallet;
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

    Widget previewContent;
    if (widget.sharedData is TransactionShareData) {
      previewContent = _buildTransactionPreview(
          context, widget.sharedData as TransactionShareData, currencySymbol);
    } else if (widget.sharedData is ReceivableShareData) {
      previewContent = _buildReceivablePreview(
          context, widget.sharedData as ReceivableShareData, currencySymbol);
    } else {
      previewContent = _buildPayablePreview(
          context, widget.sharedData as PayableShareData, currencySymbol);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: previewContent,
    );
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
              color: Colors.white.withValues(alpha: 0.72),
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
              color: Colors.white.withValues(alpha: 0.72),
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
              color: Colors.white.withValues(alpha: 0.72),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

