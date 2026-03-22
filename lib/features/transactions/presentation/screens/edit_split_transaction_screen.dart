import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/contacts/data/contacts_repository.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/utils/split_share_settled_label.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/categories/presentation/screens/add_category_screen.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/add_contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// One row in the split-edit form (existing or new share).
class _ShareRow {
  final String? transactionUuid;
  String? contactUuid;
  Contact? contact;
  double amount;
  double percentage;
  bool isUser;
  bool isLocked;
  bool isProcessed;
  Payable? linkedPayable;
  Receivable? linkedReceivable;
  final TextEditingController amountController;
  final TextEditingController percentController;

  _ShareRow({
    this.transactionUuid,
    this.contactUuid,
    this.contact,
    required this.amount,
    this.percentage = 0.0,
    required this.isUser,
    this.isLocked = false,
    this.isProcessed = false,
    this.linkedPayable,
    this.linkedReceivable,
  })  : amountController = TextEditingController(text: amount.toStringAsFixed(2)),
        percentController = TextEditingController(text: percentage.toStringAsFixed(1));

  void dispose() {
    amountController.dispose();
    percentController.dispose();
  }

  void updateControllers() {
    final newAmountText = amount.toStringAsFixed(2);
    if (amountController.text != newAmountText) {
      amountController.text = newAmountText;
    }
    final newPercentText = percentage.toStringAsFixed(1);
    if (percentController.text != newPercentText) {
      percentController.text = newPercentText;
    }
  }
}

class EditSplitTransactionScreen extends ConsumerStatefulWidget {
  final String transactionUuid;

  const EditSplitTransactionScreen({
    super.key,
    required this.transactionUuid,
  });

  @override
  ConsumerState<EditSplitTransactionScreen> createState() =>
      _EditSplitTransactionScreenState();
}

class _EditSplitTransactionScreenState
    extends ConsumerState<EditSplitTransactionScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _totalAmountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;
  bool _isLoading = false;
  bool _isTotalLocked = true;
  Category? _selectedCategory;
  String? _paidRelationship;
  String? _selectedType;

  List<_ShareRow> _rows = [];
  String? _linkedGroupId;

  @override
  void dispose() {
    _descriptionController.dispose();
    _totalAmountController.dispose();
    for (var row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _initFromGroup(List<TransactionWithDetails> group) {
    if (group.isEmpty) return;
    final first = group.first;
    final t = first.transaction;
    _linkedGroupId ??= t.linkedGroupId;
    _selectedType ??= t.type;
    _selectedDate = t.date;
    _descriptionController.text = t.description ?? '';
    _paidRelationship = t.paidRelationship;
    _selectedCategory = first.category;
    if (t.linkedPayableUuid != null || t.linkedReceivableUuid != null) {
      if (first.linkedPayable != null && first.linkedPayable!.dueDate != null) {
        _dueDate = first.linkedPayable!.dueDate;
      } else if (first.linkedReceivable != null &&
          first.linkedReceivable!.dueDate != null) {
        _dueDate = first.linkedReceivable!.dueDate;
      }
    }

    final totalAmount = group.fold<double>(0, (sum, e) => sum + e.transaction.amount);
    _totalAmountController.text = totalAmount.toStringAsFixed(2);

    _rows = group.map((e) {
      final isUser = e.transaction.contactUuid == null;
      final isSettled = e.linkedPayable?.status == 'PAID' ||
          e.linkedReceivable?.status == 'RECEIVED';
      final amount = e.transaction.amount;
      final percent = totalAmount > 0 ? (amount / totalAmount) * 100 : 0.0;
      
      return _ShareRow(
        transactionUuid: e.transaction.uuid,
        contactUuid: e.transaction.contactUuid,
        contact: e.contact,
        amount: amount,
        percentage: percent,
        isUser: isUser,
        isLocked: false,
        isProcessed: isSettled,
        linkedPayable: e.linkedPayable,
        linkedReceivable: e.linkedReceivable,
      );
    }).toList();
  }

  void _recalculateOthers(int changedIndex, double totalAmount) {
    final lockedRows = _rows
        .asMap()
        .entries
        .where((e) => e.value.isLocked || e.value.isProcessed || e.key == changedIndex)
        .toList();
    final unlockedRows = _rows
        .asMap()
        .entries
        .where((e) => !e.value.isLocked && !e.value.isProcessed && e.key != changedIndex)
        .toList();

    if (unlockedRows.isNotEmpty) {
      double usedPercent =
          lockedRows.fold(0.0, (sum, e) => sum + e.value.percentage);
      double remainingPercent = 100.0 - usedPercent;
      if (remainingPercent < 0) remainingPercent = 0;

      double perSharePercent = remainingPercent / unlockedRows.length;
      for (final entry in unlockedRows) {
        entry.value.percentage = perSharePercent;
        entry.value.amount = (perSharePercent / 100) * totalAmount;
        entry.value.updateControllers();
      }
    }
  }

  void _recalculateShares(int changedIndex, {bool isPercent = true}) {
    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0.0;
    if (totalAmount <= 0) return;

    final changedRow = _rows[changedIndex];
    if (isPercent) {
      changedRow.amount = (changedRow.percentage / 100) * totalAmount;
    } else {
      changedRow.percentage = (changedRow.amount / totalAmount) * 100;
    }
    changedRow.updateControllers();
    
    if (_isTotalLocked) {
      _recalculateOthers(changedIndex, totalAmount);
    } else {
      final newTotal = _rows.fold<double>(0, (sum, r) => sum + r.amount);
      _totalAmountController.text = newTotal.toStringAsFixed(2);
      for (var row in _rows) {
        row.percentage = newTotal > 0 ? (row.amount / newTotal) * 100 : 0.0;
        row.updateControllers();
      }
    }
    setState(() {});
  }

  void _onTotalAmountChanged(String val) {
    final newTotal = double.tryParse(val) ?? 0.0;
    if (newTotal <= 0) return;

    setState(() {
      for (var row in _rows) {
        row.amount = (row.percentage / 100) * newTotal;
        row.updateControllers();
      }
      
      final currentSum = _rows.fold<double>(0, (sum, r) => sum + r.amount);
      final diff = newTotal - currentSum;
      if (diff.abs() > 0.001) {
        final lastRow = _rows.lastWhere((r) => !r.isProcessed, orElse: () => _rows.last);
        lastRow.amount = double.parse((lastRow.amount + diff).toStringAsFixed(2));
        lastRow.updateControllers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(transactionGroupProvider(widget.transactionUuid));
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    return groupAsync.when(
      data: (group) {
        if (group.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.splittedBill)),
            body: Center(child: Text(l10n.errorOccurred('Group not found'))),
          );
        }
        if (_rows.isEmpty) _initFromGroup(group);
        if (_linkedGroupId == null || _linkedGroupId!.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.splittedBill)),
            body: Center(child: Text(l10n.errorOccurred('Not a split group'))),
          );
        }
        if (currency == null) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final isExpense = _selectedType == 'EXPENSE';
        final theme = Theme.of(context);
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        final totalAmount = double.tryParse(_totalAmountController.text) ?? 0.0;
        final currentTotalAmount = _rows.fold<double>(0, (sum, r) => sum + r.amount);
        final currentTotalPercent = _rows.fold<double>(0, (sum, r) => sum + r.percentage);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.splittedBill),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Date
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.calendar_today,
                              color: theme.colorScheme.primary),
                        ),
                        title: Text(l10n.date),
                        subtitle: Text(AppDateFormatter.formatDate(_selectedDate)),
                        onTap: _selectDate,
                      ),
                      const SizedBox(height: 8),
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: l10n.description,
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      // Category
                      if (_selectedCategory != null)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(int.parse(_selectedCategory!.color!
                                      .replaceAll('#', '0xFF')))
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              IconHelper.getIconData(
                                  _selectedCategory!.icon ?? 'category'),
                              color: Color(int.parse(_selectedCategory!.color!
                                  .replaceAll('#', '0xFF'))),
                            ),
                          ),
                          title: Text(LocalizationHelper.getLocalizedCategoryName(
                              context, _selectedCategory!.name)),
                          subtitle: Text(l10n.category),
                          onTap: _showCategoryPicker,
                        ),
                      const SizedBox(height: 16),
                      // Total Amount Input with Lock
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (isExpense
                                      ? AppColors.expenseColor
                                      : AppColors.incomeColor)
                                  .withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.totalAmount,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    _isTotalLocked ? Icons.lock : Icons.lock_open,
                                    size: 18,
                                    color: _isTotalLocked ? theme.colorScheme.primary : theme.hintColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isTotalLocked = !_isTotalLocked;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _totalAmountController,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isExpense
                                    ? AppColors.expenseColor
                                    : AppColors.incomeColor,
                              ),
                              decoration: InputDecoration(
                                prefixText: isRtl ? null : '${currency.symbol} ',
                                suffixText: isRtl ? ' ${currency.symbol}' : null,
                                prefixStyle: theme.textTheme.displayMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                border: InputBorder.none,
                                hintText: '0.00',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              onChanged: _onTotalAmountChanged,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Due Date
                      if (_paidRelationship != null)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: (_paidRelationship == 'PAID_FOR' ||
                                      _paidRelationship == 'WILL_RECEIVE'
                                  ? AppColors.receivableColor
                                  : AppColors.payableColor)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.event_available,
                              color: _paidRelationship == 'PAID_FOR' ||
                                      _paidRelationship == 'WILL_RECEIVE'
                                  ? AppColors.receivableColor
                                  : AppColors.payableColor,
                            ),
                          ),
                          title: Text(l10n.dueDate),
                          subtitle: Text(_dueDate != null
                              ? AppDateFormatter.formatDate(_dueDate!)
                              : l10n.notSet),
                          onTap: _selectDueDate,
                        ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.splittedBill,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: _distributeEqually,
                                icon: const Icon(Icons.balance),
                                tooltip: l10n.distributeEqually,
                              ),
                              IconButton(
                                onPressed: _includeMe,
                                icon: Icon(_rows.any((r) => r.isUser)
                                    ? Icons.person
                                    : Icons.person_outline),
                                tooltip: l10n.me,
                              ),
                              IconButton(
                                onPressed: _addShare,
                                icon: const Icon(Icons.person_add_outlined),
                                tooltip: l10n.addContact,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._rows.asMap().entries.map((entry) {
                        return _buildShareCard(
                          context,
                          theme,
                          currency,
                          entry.key,
                          entry.value,
                        );
                      }),
                    ],
                  ),
                ),
                // Bottom Summary & Action
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.totalAmount,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            isRtl
                                ? '${currentTotalAmount.toStringAsFixed(2)} / ${totalAmount.toStringAsFixed(2)} ${currency.symbol}'
                                : '${currency.symbol} ${currentTotalAmount.toStringAsFixed(2)} / ${totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: (currentTotalAmount - totalAmount).abs() <
                                      0.01
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.totalPercentage),
                          Text(
                            '${currentTotalPercent.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: (currentTotalPercent - 100).abs() < 0.1
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: (_isLoading || (currentTotalPercent - 100).abs() >= 0.1) ? null : _save,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check),
                          label: Text(_isLoading
                              ? l10n.updating
                              : l10n.updateTransaction),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: isExpense
                                ? AppColors.expenseColor
                                : AppColors.incomeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.splittedBill)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.splittedBill)),
        body: Center(child: Text(l10n.errorOccurred(err.toString()))),
      ),
    );
  }

  Widget _buildShareCard(
    BuildContext context,
    ThemeData theme,
    dynamic currency,
    int index,
    _ShareRow row,
  ) {
    final label = row.isUser ? l10n.me : (row.contact?.name ?? l10n.selectContact);
    final settledBadgeLabel = row.isProcessed
        ? splitShareSettledStatusLabel(
            l10n,
            row.linkedPayable,
            row.linkedReceivable,
          )
        : null;
    final contactColor = row.isUser
        ? theme.colorScheme.secondary
        : (row.contact?.name != null
            ? AppColors.getContactColor(row.contact!.name)
            : theme.colorScheme.primary);

    final isNew = row.transactionUuid == null;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    Widget card = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNew 
          ? theme.colorScheme.primary.withValues(alpha: 0.05)
          : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: row.isProcessed ? theme.dividerColor : (row.isLocked ? theme.colorScheme.primary : theme.dividerColor),
          width: row.isLocked ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Top Row: Avatar, Contact Name, and Icons
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: contactColor.withValues(alpha: 0.1),
                child: row.isUser
                    ? Icon(Icons.person, size: 18, color: contactColor)
                    : Text(
                        label.isNotEmpty ? label[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: contactColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  label,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: row.isUser ? theme.colorScheme.primary : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isNew) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    l10n.addNew,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (settledBadgeLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          settledBadgeLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!row.isProcessed) ...[
                IconButton(
                  icon: Icon(
                    row.isLocked ? Icons.lock : Icons.lock_open,
                    color: row.isLocked ? theme.colorScheme.primary : theme.hintColor,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      row.isLocked = !row.isLocked;
                    });
                  },
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
                IconButton(
                  icon: const Icon(Icons.linear_scale, size: 20),
                  onPressed: () => _showPercentageSlider(index),
                  tooltip: l10n.percentage,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Bottom Row: Input Fields
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: row.percentController,
                  key: ValueKey('pct_${index}'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  enabled: !row.isProcessed && !row.isLocked,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    prefixText: isRtl ? '%' : null,
                    suffixText: isRtl ? null : '%',
                    labelText: l10n.percentage,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (val) {
                    final pct = double.tryParse(val) ?? 0.0;
                    row.percentage = pct;
                    _recalculateShares(index, isPercent: true);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: row.amountController,
                  key: ValueKey('amt_${index}'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.end,
                  enabled: !row.isProcessed && !row.isLocked,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: row.isProcessed ? theme.hintColor : null,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    prefixText: isRtl ? null : '${currency.symbol} ',
                    suffixText: isRtl ? ' ${currency.symbol}' : null,
                    labelText: l10n.amount,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (val) {
                    final amt = double.tryParse(val) ?? 0.0;
                    row.amount = amt;
                    _recalculateShares(index, isPercent: false);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (row.isUser || row.isProcessed) return card;

    return Dismissible(
      key: ValueKey('dismiss_${row.transactionUuid ?? index}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
        padding: isRtl
            ? const EdgeInsets.only(left: 20)
            : const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => _removeRow(index),
      child: card,
    );
  }

  void _showPercentageSlider(int index) {
    final row = _rows[index];
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            24, 24, 24,
            MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.percentage} - ${row.isUser ? l10n.me : (row.contact?.name ?? '')}',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${row.percentage.toStringAsFixed(1)}%',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: row.percentage.clamp(0, 100),
                min: 0, max: 100, divisions: 1000,
                onChanged: (val) {
                  setModalState(() => row.percentage = val);
                  _recalculateShares(index, isPercent: true);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectDueDate() async {
    final theme = Theme.of(context);

    String? relativeText;
    if (_dueDate != null) {
      final txDate = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day);
      final dDate = DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day);
      final diff = dDate.difference(txDate).inDays;

      if (diff == 0) {
        relativeText = l10n.sameDay;
      } else if (diff > 0) {
        relativeText = l10n.inDays(diff);
      } else {
        relativeText = l10n.daysAgoRelative(diff.abs());
      }
    }

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.dueDate,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(l10n.pickActualDate),
              subtitle: _dueDate != null
                  ? Text(AppDateFormatter.formatDate(_dueDate!))
                  : null,
              onTap: () async {
                Navigator.pop(context);
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      _dueDate ?? DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) {
                  setState(() {
                    _dueDate = picked;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.more_time),
              title: Text(l10n.relativeDateAfterXDays('')),
              subtitle: relativeText != null ? Text(relativeText) : null,
              onTap: () {
                Navigator.pop(context);
                _showRelativeDateDialog();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showRelativeDateDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.customRange),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.enterDaysFromTransaction),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.daysHint,
                suffixText: l10n.daysSuffix,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final days = int.tryParse(controller.text);
              if (days != null) {
                setState(() {
                  _dueDate = _selectedDate.add(Duration(days: days));
                });
                Navigator.pop(context);
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<Contact?> _showContactPicker() async {
    return await showModalBottomSheet<Contact>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Consumer(
          builder: (context, ref, _) {
            final contactsAsync = ref.watch(smartContactsProvider);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        l10n.selectContact,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final newContact = await Navigator.push<Contact>(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AddContactScreen()),
                          );
                          if (newContact != null && context.mounted) {
                            Navigator.pop(context, newContact);
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addNew),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: contactsAsync.when(
                    data: (contactsWithUsage) {
                      final excludedUuids = _rows
                          .where((r) => r.contactUuid != null)
                          .map((r) => r.contactUuid!)
                          .toSet();
                      final filtered = contactsWithUsage
                          .where((item) =>
                              !excludedUuids.contains(item.contact.uuid))
                          .toList();
                      if (filtered.isEmpty) {
                        return Center(
                            child: Text(contactsWithUsage.isEmpty
                                ? l10n.noContactsFound
                                : l10n.allContactsAddedToSplit));
                      }
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final contact = item.contact;

                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient:
                                    AppColors.getContactGradient(contact.name),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                contact.name.isNotEmpty
                                    ? contact.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(contact.name),
                            subtitle: contact.phone != null
                                ? Text(contact.phone!)
                                : null,
                            onTap: () {
                              Navigator.pop(context, contact);
                            },
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text(l10n.errorOccurred(e.toString()))),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Consumer(
          builder: (context, ref, _) {
            final categoriesAsync =
                ref.watch(smartCategoriesProvider(_selectedType!));

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        l10n.selectCategory,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final newCategory = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddCategoryScreen(
                                initialType: _selectedType!,
                              ),
                            ),
                          );

                          if (newCategory != null && newCategory is Category) {
                            setState(() {
                              _selectedCategory = newCategory;
                            });
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addNew),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: categoriesAsync.when(
                    data: (categoriesWithUsage) {
                      if (categoriesWithUsage.isEmpty) {
                        return Center(child: Text(l10n.noCategoriesFound));
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: categoriesWithUsage.length,
                        itemBuilder: (context, index) {
                          final item = categoriesWithUsage[index];
                          final category = item.category;
                          final color = category.color != null
                              ? Color(int.parse(
                                  category.color!.replaceAll('#', '0xFF')))
                              : (_selectedType == 'EXPENSE'
                                  ? AppColors.expenseColor
                                  : AppColors.incomeColor);

                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: color.withValues(alpha: 0.3)),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                category.icon != null
                                    ? IconHelper.getIconData(category.icon)
                                    : Symbols.category,
                                color: color,
                                size: 24,
                              ),
                            ),
                            title: Text(LocalizationHelper.getLocalizedCategoryName(context, category.name)),
                            trailing: _selectedCategory?.uuid == category.uuid
                                ? Icon(Icons.check_circle, color: color)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text(l10n.errorOccurred(e.toString()))),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Multi-select contact picker for split; returns list of selected contacts.
  Future<List<Contact>?> _showMultiContactPicker() async {
    final excludedUuids = _rows
        .where((r) => r.contactUuid != null)
        .map((r) => r.contactUuid!)
        .toSet();
    return await showModalBottomSheet<List<Contact>>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Consumer(
          builder: (context, ref, _) {
            final contactsAsync = ref.watch(smartContactsProvider);
            return _EditSplitMultiContactPickerSheet(
              scrollController: scrollController,
              contactsAsync: contactsAsync,
              excludeContactUuids: excludedUuids,
              theme: Theme.of(context),
              l10n: l10n,
            );
          },
        ),
      ),
    );
  }

  void _addShare() async {
    final contacts = await _showMultiContactPicker();
    if (contacts == null || contacts.isEmpty) return;

    setState(() {
      for (final contact in contacts) {
        _rows.add(_ShareRow(
          transactionUuid: null,
          contactUuid: contact.uuid,
          contact: contact,
          amount: 0,
          percentage: 0,
          isUser: false,
          isLocked: false,
        ));
      }
      _recalculateShares(_rows.length - 1, isPercent: true);
    });
  }

  void _includeMe() {
    if (_rows.any((r) => r.isUser)) {
      setState(() {
        _rows.removeWhere((r) => r.isUser);
        if (_rows.isNotEmpty) _recalculateShares(0, isPercent: true);
      });
    } else {
      setState(() {
        _rows.insert(
            0,
            _ShareRow(
              transactionUuid: null,
              contactUuid: null,
              contact: null,
              amount: 0,
              percentage: 0,
              isUser: true,
              isLocked: false,
            ));
        _recalculateShares(0, isPercent: true);
      });
    }
  }

  void _distributeEqually() {
    if (_rows.isEmpty) return;
    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0.0;
    if (totalAmount <= 0) return;

    final unlockedRows = _rows.where((r) => !r.isLocked && !r.isProcessed).toList();
    if (unlockedRows.isEmpty) return;

    final lockedAmount = _rows.where((r) => r.isLocked || r.isProcessed).fold<double>(0, (sum, r) => sum + r.amount);
    final remainingAmount = totalAmount - lockedAmount;
    if (remainingAmount <= 0) return;

    final perShareAmount = remainingAmount / unlockedRows.length;
    final perSharePercent = (remainingAmount / totalAmount * 100) / unlockedRows.length;

    setState(() {
      for (var row in _rows) {
        if (!row.isLocked && !row.isProcessed) {
          row.amount = double.parse(perShareAmount.toStringAsFixed(2));
          row.percentage = perSharePercent;
          row.updateControllers();
        }
      }
      
      final newTotal = _rows.fold<double>(0, (sum, r) => sum + r.amount);
      final diff = totalAmount - newTotal;
      if (diff.abs() > 0.001) {
        final lastUnlocked = _rows.lastWhere((r) => !r.isLocked && !r.isProcessed);
        lastUnlocked.amount = double.parse((lastUnlocked.amount + diff).toStringAsFixed(2));
        lastUnlocked.percentage = (lastUnlocked.amount / totalAmount) * 100;
        lastUnlocked.updateControllers();
      }
    });
  }

  void _removeRow(int index) {
    setState(() {
      _rows.removeAt(index);
      if (_rows.isNotEmpty) _recalculateShares(0, isPercent: true);
    });
  }

  Future<void> _save() async {
    if (_linkedGroupId == null) return;
    
    final invalid = _rows.where((r) => r.amount <= 0).toList();
    if (invalid.isNotEmpty) {
      ToastUtils.showErrorToast(context, ref, l10n.pleaseEnterValidAmount);
      return;
    }

    final withoutContact =
        _rows.where((r) => !r.isUser && r.contactUuid == null).toList();
    if (withoutContact.isNotEmpty) {
      ToastUtils.showErrorToast(context, ref, l10n.pleaseSelectContactRelationship);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final shares = _rows
          .map(
            (r) => GroupShareEdit(
              transactionUuid: r.transactionUuid,
              contactUuid: r.contactUuid,
              amount: r.amount,
              isUser: r.isUser,
            ),
          )
          .toList();

      final isPending = _paidRelationship == 'PAID_BY' ||
          _paidRelationship == 'WILL_RECEIVE';

      await ref.read(transactionServiceProvider).updateGroupSplit(
            linkedGroupId: _linkedGroupId!,
            type: _selectedType!,
            date: _selectedDate,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            categoryUuid: _selectedCategory?.uuid,
            paidRelationship: _paidRelationship,
            dueDate: _dueDate,
            shares: shares,
            isPending: isPending,
          );

      if (mounted) {
        ToastUtils.showSuccessToast(context, ref, l10n.transactionUpdated);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _EditSplitMultiContactPickerSheet extends StatefulWidget {
  final ScrollController scrollController;
  final AsyncValue<List<ContactWithUsage>> contactsAsync;
  final Set<String> excludeContactUuids;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _EditSplitMultiContactPickerSheet({
    required this.scrollController,
    required this.contactsAsync,
    required this.excludeContactUuids,
    required this.theme,
    required this.l10n,
  });

  @override
  State<_EditSplitMultiContactPickerSheet> createState() =>
      _EditSplitMultiContactPickerSheetState();
}

class _EditSplitMultiContactPickerSheetState
    extends State<_EditSplitMultiContactPickerSheet> {
  final Set<String> _selectedUuids = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                widget.l10n.selectContact,
                style: widget.theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final newContact = await Navigator.push<Contact>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddContactScreen()),
                  );
                  if (newContact != null &&
                      context.mounted &&
                      !widget.excludeContactUuids.contains(newContact.uuid)) {
                    Navigator.pop(context, [newContact]);
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(widget.l10n.addNew),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.contactsAsync.when(
            data: (contactsWithUsage) {
              final filtered = contactsWithUsage
                  .where((item) =>
                      !widget.excludeContactUuids.contains(item.contact.uuid))
                  .toList();
              if (filtered.isEmpty) {
                return Center(
                    child: Text(contactsWithUsage.isEmpty
                        ? widget.l10n.noContactsFound
                        : widget.l10n.allContactsAddedToSplit));
              }
              return ListView.builder(
                controller: widget.scrollController,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final contact = item.contact;
                  final selected = _selectedUuids.contains(contact.uuid);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Material(
                      color: selected
                          ? widget.theme.colorScheme.primary.withValues(alpha: 0.12)
                          : widget.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _selectedUuids.remove(contact.uuid);
                            } else {
                              _selectedUuids.add(contact.uuid);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient:
                                      AppColors.getContactGradient(contact.name),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  contact.name.isNotEmpty
                                      ? contact.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      contact.name,
                                      style: widget.theme.textTheme.titleMedium,
                                    ),
                                    if (contact.phone != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        contact.phone!,
                                        style: widget.theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: widget.theme.colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (selected)
                                Icon(Icons.check_circle,
                                    color: widget.theme.colorScheme.primary,
                                    size: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(
                child: Text(widget.l10n.errorOccurred(e.toString()))),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                final contactsWithUsage = widget.contactsAsync.value;
                if (contactsWithUsage == null) return;
                final filtered = contactsWithUsage
                    .where((item) => !widget.excludeContactUuids
                        .contains(item.contact.uuid))
                    .toList();
                final selected = filtered
                    .where((item) =>
                        _selectedUuids.contains(item.contact.uuid))
                    .map((item) => item.contact)
                    .toList();
                Navigator.pop(context, selected);
              },
              icon: const Icon(Icons.add),
              label: Text(widget.l10n.add),
            ),
          ),
        ),
      ],
    );
  }
}
