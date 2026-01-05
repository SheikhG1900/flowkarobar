import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'EXPENSE';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Linked transaction fields
  int? _selectedContactId;
  String? _paidRelationship; // 'PAID_FOR' or 'PAID_BY' or null
  bool _createLinkedEntry = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final transactionRepository = ref.read(transactionsRepositoryProvider);
      final database = ref.read(databaseProvider);

      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text;

      await database.transaction(() async {
        // Create the main transaction
        final transactionId = await transactionRepository.createTransaction(
          TransactionsCompanion(
            amount: drift.Value(amount),
            type: drift.Value(_selectedType),
            contactId: drift.Value(_selectedContactId),
            description: drift.Value(description),
            date: drift.Value(_selectedDate),
            paidRelationship: drift.Value(_paidRelationship),
            createdAt: drift.Value(DateTime.now()),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );

        // Create linked entries based on paid relationship
        if (_createLinkedEntry && _selectedContactId != null) {
          if (_paidRelationship == 'PAID_FOR' && _selectedType == 'EXPENSE') {
            // Create a receivable (money you're owed)
            final receivablesRepository =
                ref.read(receivablesRepositoryProvider);
            await receivablesRepository.createReceivable(
              ReceivablesCompanion(
                contactId: drift.Value(_selectedContactId!),
                amount: drift.Value(amount),
                description: drift.Value(description),
                date: drift.Value(_selectedDate),
                status: const drift.Value('PENDING'),
                linkedExpenseId: drift.Value(transactionId),
                autoCreateIncome: const drift.Value(true),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          } else if (_paidRelationship == 'PAID_BY' &&
              _selectedType == 'EXPENSE') {
            // This shouldn't happen - if someone else paid, it's not an expense
            // It should be recorded as a payable from the beginning
          } else if (_paidRelationship == 'PAID_FOR' &&
              _selectedType == 'INCOME') {
            // If you received money that you'll pay back, create a payable
            final payablesRepository = ref.read(payablesRepositoryProvider);
            await payablesRepository.createPayable(
              PayablesCompanion(
                contactId: drift.Value(_selectedContactId!),
                amount: drift.Value(amount),
                description: drift.Value(description),
                date: drift.Value(_selectedDate),
                status: const drift.Value('PENDING'),
                linkedExpenseId: drift.Value(null),
                autoCreateExpense: const drift.Value(true),
                createdAt: drift.Value(DateTime.now()),
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
          }
        }
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _createLinkedEntry
                  ? 'Transaction and linked entry added successfully'
                  : 'Transaction added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isExpense = _selectedType == 'EXPENSE';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.addTransaction),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isExpense
                ? [AppColors.expenseColor.withOpacity(0.05), Colors.transparent]
                : [AppColors.incomeColor.withOpacity(0.05), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Amount Input (Large & Prominent)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ), // Diagonal beveled
                  boxShadow: [
                    BoxShadow(
                      color: (isExpense
                              ? AppColors.expenseColor
                              : AppColors.incomeColor)
                          .withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'How much?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isExpense
                            ? AppColors.expenseColor
                            : AppColors.incomeColor,
                      ),
                      decoration: InputDecoration(
                        prefixText: '₹ ',
                        prefixStyle: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: theme.textTheme.displayLarge?.copyWith(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Amount must be greater than 0';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Type Selection (Gradient Buttons)
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: l10n.expense,
                      icon: Icons.arrow_upward_rounded,
                      isSelected: isExpense,
                      gradient: AppColors.expenseGradient,
                      onTap: () {
                        setState(() {
                          _selectedType = 'EXPENSE';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeButton(
                      label: l10n.income,
                      icon: Icons.arrow_downward_rounded,
                      isSelected: !isExpense,
                      gradient: AppColors.incomeGradient,
                      onTap: () {
                        setState(() {
                          _selectedType = 'INCOME';
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  hintText: 'E.g., Groceries, Salary, etc.',
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // Paid Relationship Section (Linked Transactions)
              if (_selectedType == 'EXPENSE') ...[
                Text(
                  'Paid Relationship',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RelationshipButton(
                        label: 'Paid FOR',
                        subtitle: 'I will receive back',
                        icon: Icons.account_balance_wallet,
                        isSelected: _paidRelationship == 'PAID_FOR',
                        onTap: () {
                          setState(() {
                            if (_paidRelationship == 'PAID_FOR') {
                              _paidRelationship = null;
                              _createLinkedEntry = false;
                            } else {
                              _paidRelationship = 'PAID_FOR';
                              _createLinkedEntry = true;
                              _selectedContactId = 1; // TODO: Contact selection
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RelationshipButton(
                        label: 'Paid BY',
                        subtitle: 'Someone paid for me',
                        icon: Icons.person_outline,
                        isSelected: _paidRelationship == 'PAID_BY',
                        onTap: () {
                          setState(() {
                            if (_paidRelationship == 'PAID_BY') {
                              _paidRelationship = null;
                              _createLinkedEntry = false;
                            } else {
                              _paidRelationship = 'PAID_BY';
                              _createLinkedEntry =
                                  false; // Don't create linked entry for PAID_BY
                              _selectedContactId = 1; // TODO: Contact selection
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Date Selector
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ), // Diagonal beveled
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppColors.secondaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              GradientButton(
                label: _isLoading ? 'Saving...' : l10n.save,
                onPressed: _isLoading ? null : _saveTransaction,
                gradient: isExpense
                    ? AppColors.expenseGradient
                    : AppColors.incomeGradient,
                isLoading: _isLoading,
                icon: _isLoading ? null : Icons.check,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Type Selection Button
class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Gradient gradient;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ), // Diagonal beveled
          border: Border.all(
            color: isSelected ? Colors.transparent : theme.dividerColor,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Relationship Button Widget for Paid FOR/BY selection
class _RelationshipButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RelationshipButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.receivableGradient : null,
          color: isSelected ? null : theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: isSelected ? AppColors.receivableColor : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.receivableColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.9 / 1.0)
                    : theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
