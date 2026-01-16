import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_details_dialog.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/categories/presentation/screens/add_category_screen.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/add_contact_screen.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/shared/widgets/limit_countdown_badge.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:material_symbols_icons/symbols.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final double? initialAmount;
  final DateTime? initialDate;
  final String? initialDescription;
  final String? initialCategoryName; // Pass name to lookup ID

  const AddTransactionScreen({
    super.key,
    this.initialAmount,
    this.initialDate,
    this.initialDescription,
    this.initialCategoryName,
  });

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
  DateTime? _dueDate;
  bool _isLoading = false;

  // Selected entities
  Category? _selectedCategory;
  Contact? _selectedContact;

  // Linked transaction fields
  int? _selectedContactId;
  String?
      _paidRelationship; // 'PAID_FOR', 'PAID_BY', 'RECEIVED_FROM', 'WILL_RECEIVE' or null
  bool _createLinkedEntry = false;

  @override
  void initState() {
    super.initState();
    // Initialize fields with scanned data if available
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!.toStringAsFixed(2);
    }
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
    if (widget.initialDescription != null) {
      _descriptionController.text = widget.initialDescription!;
    }

    // Auto-select category if name provided (needs async lookup, handled in post-frame or logic below)
    if (widget.initialCategoryName != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _findAndSelectCategory(widget.initialCategoryName!);
      });
    }
  }

  Future<void> _findAndSelectCategory(String name) async {
    // Logic to select category if needed
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    // Check limits first - prevent saving if limit reached, regardless of form validity
    final isPremium = PremiumGate.isPremium(ref);
    if (!isPremium) {
      final limits = await PremiumGate.getTransactionLimits(ref);
      if (!limits.canAdd) {
        if (mounted) {
          PremiumGate.showPremiumDialog(context);
        }
        return;
      }
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_createLinkedEntry && _selectedContact == null) {
      ToastUtils.showErrorToast(
        context,
        'Please select a contact for linked transaction',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final transactionService = ref.read(transactionServiceProvider);

      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text;

      // Create transaction and get the ID
      final transactionId = await transactionService.createTransaction(
        amount: amount,
        type: _selectedType,
        date: _selectedDate,
        description: description,
        contactId: _selectedContactId,
        categoryId: _selectedCategory?.id,
        paidRelationship: _paidRelationship,
        createLinkedEntry: _createLinkedEntry,
        dueDate: _dueDate,
      );

      // Increment usage count for free users
      if (!PremiumGate.isPremium(ref)) {
        await ref
            .read(usageTrackerRepositoryProvider)
            .incrementTransactionCount();
      }

      // Invalidate limits to refresh usage count
      ref.invalidate(transactionLimitsProvider);

      if (mounted) {
        // Fetch full transaction with details
        final repository = ref.read(transactionsRepositoryProvider);
        final transactionWithDetails =
            await repository.getTransactionWithDetailsById(transactionId);

        if (transactionWithDetails != null) {
          // Pop create page and navigate to details
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TransactionDetailsDialog(item: transactionWithDetails),
            ),
          );
          ToastUtils.showSuccessToast(
            context,
            _createLinkedEntry
                ? 'Transaction and linked entry added successfully'
                : 'Transaction added successfully',
          );
        } else {
          // Fallback: just pop if details fetch fails
          Navigator.pop(context);
          ToastUtils.showSuccessToast(
            context,
            _createLinkedEntry
                ? 'Transaction and linked entry added successfully'
                : 'Transaction added successfully',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(context, 'Error: ${e.toString()}');
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

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
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
            // Use Smart Provider (Sorted by Usage)
            final categoriesAsync =
                ref.watch(smartCategoriesProvider(_selectedType));

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Category',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          // Navigate to Add Category Screen
                          // If coming from Scan, pass the initial name
                          final newCategory = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddCategoryScreen(
                                initialName: widget.initialCategoryName,
                                initialType: _selectedType,
                              ),
                            ),
                          );

                          if (newCategory != null && newCategory is Category) {
                            setState(() {
                              _selectedCategory = newCategory;
                            });
                            Navigator.pop(context); // Close picker
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add New'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: categoriesAsync.when(
                    data: (categoriesWithUsage) {
                      // Check if suggested category exists in list
                      bool suggestedExists = false;
                      if (widget.initialCategoryName != null) {
                        try {
                          categoriesWithUsage.firstWhere(
                            (c) =>
                                c.category.name.toUpperCase() ==
                                widget.initialCategoryName!.toUpperCase(),
                          );
                          suggestedExists = true;
                        } catch (_) {}
                      }

                      if (categoriesWithUsage.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  'No ${_selectedType.toLowerCase()} categories found'),
                              const SizedBox(height: 16),
                              if (widget.initialCategoryName != null)
                                FilledButton.icon(
                                  onPressed: () async {
                                    final newCategory = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddCategoryScreen(
                                          initialName:
                                              widget.initialCategoryName,
                                          initialType: _selectedType,
                                        ),
                                      ),
                                    );
                                    if (newCategory != null &&
                                        newCategory is Category) {
                                      setState(() {
                                        _selectedCategory = newCategory;
                                      });
                                      Navigator.pop(context);
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label: Text(
                                      'Create "${widget.initialCategoryName}"'),
                                ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: categoriesWithUsage.length +
                            (widget.initialCategoryName != null &&
                                    !suggestedExists
                                ? 1
                                : 0),
                        itemBuilder: (context, index) {
                          // Show "Create Suggested" button as first item if it doesn't exist
                          if (widget.initialCategoryName != null &&
                              !suggestedExists &&
                              index == 0) {
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.brightCyan
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: AppColors.brightCyan),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.add,
                                    color: AppColors.brightCyan),
                              ),
                              title: Text(
                                  'Create "${widget.initialCategoryName}"'),
                              subtitle: const Text('Tap to add this category'),
                              onTap: () async {
                                final newCategory = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddCategoryScreen(
                                      initialName: widget.initialCategoryName,
                                      initialType: _selectedType,
                                    ),
                                  ),
                                );
                                if (newCategory != null &&
                                    newCategory is Category) {
                                  setState(() {
                                    _selectedCategory = newCategory;
                                  });
                                  Navigator.pop(context);
                                }
                              },
                            );
                          }

                          final actualIndex =
                              (widget.initialCategoryName != null &&
                                      !suggestedExists)
                                  ? index - 1
                                  : index;
                          final item = categoriesWithUsage[actualIndex];
                          final category = item.category;
                          final usage = item.usageCount;

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
                                IconHelper.getIconData(category.icon) ??
                                    Symbols.category,
                                color: color,
                                size: 24,
                              ),
                            ),
                            title: Text(category.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Show "Frequent" tag for top used categories if usage > 0
                                if (actualIndex < 3 && usage > 0)
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Frequent',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (_selectedCategory?.id == category.id)
                                  Icon(Icons.check_circle, color: color),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                              Navigator.pop(context);
                            },
                            selected: _selectedCategory?.id == category.id,
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            );
          },
        ),
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
            // Use Smart Provider (Sorted by Usage)
            final contactsAsync = ref.watch(smartContactsProvider);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Contact',
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
                        label: const Text('Add New'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: contactsAsync.when(
                    data: (contactsWithUsage) {
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: contactsWithUsage.length,
                        itemBuilder: (context, index) {
                          final item = contactsWithUsage[index];
                          final contact = item.contact;
                          final usage = item.usageCount;

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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Show "Frequent" tag for top used contacts if usage > 0
                                if (index < 3 && usage > 0)
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors
                                          .primaryGradient.colors.first
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Frequent',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors
                                            .primaryGradient.colors.first,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (_selectedContactId == contact.id)
                                  const Icon(Icons.check_circle,
                                      color: AppColors.brightCyan),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context, contact);
                            },
                            selected: _selectedContactId == contact.id,
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleRelationshipChange(String? value) async {
    if (_paidRelationship == value) {
      setState(() {
        _paidRelationship = null;
        _createLinkedEntry = false;
        _dueDate = null;
      });
    } else {
      if (_selectedContact == null) {
        final contact = await _showContactPicker();
        if (contact != null) {
          setState(() {
            _paidRelationship = value;
            _createLinkedEntry = true;
            _selectedContact = contact;
            _selectedContactId = contact.id;
            // Keep existing due date if already set
          });
        }
      } else {
        setState(() {
          _paidRelationship = value;
          _createLinkedEntry = true;
          // Keep existing due date if already set
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isExpense = _selectedType == 'EXPENSE';
    final currencySymbol = ref.watch(currencySymbolProvider);

    // Watch limits
    final limitsAsync = ref.watch(transactionLimitsProvider);

    return Scaffold(
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
                ? [
                    AppColors.expenseColor.withValues(alpha: 0.05),
                    Colors.transparent
                  ]
                : [
                    AppColors.incomeColor.withValues(alpha: 0.05),
                    Colors.transparent
                  ],
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
                    Text(
                      'How much?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      autofocus: widget.initialAmount ==
                          null, // Autofocus only if no initial amount
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isExpense
                            ? AppColors.expenseColor
                            : AppColors.incomeColor,
                      ),
                      decoration: InputDecoration(
                        prefixText: '$currencySymbol ',
                        prefixStyle: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: theme.textTheme.displayLarge?.copyWith(
                          color: Colors.grey.withValues(alpha: 0.3),
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
                          // Reset relationship when type changes
                          _paidRelationship = null;
                          _createLinkedEntry = false;
                          _dueDate = null;
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
                          // Reset relationship when type changes
                          _paidRelationship = null;
                          _createLinkedEntry = false;
                          _dueDate = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Category Selector
              InkWell(
                onTap: _showCategoryPicker,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedCategory != null
                          ? (_selectedType == 'EXPENSE'
                              ? AppColors.expenseColor
                              : AppColors.incomeColor)
                          : theme.dividerColor,
                      width: _selectedCategory != null ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedCategory?.color != null
                              ? Color(int.parse(_selectedCategory!.color!
                                      .replaceAll('#', '0xFF')))
                                  .withValues(alpha: 0.1)
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                          border: _selectedCategory?.color != null
                              ? Border.all(
                                  color: Color(int.parse(_selectedCategory!
                                          .color!
                                          .replaceAll('#', '0xFF')))
                                      .withValues(alpha: 0.3),
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          IconHelper.getIconData(_selectedCategory?.icon) ??
                              Symbols.category,
                          color: _selectedCategory?.color != null
                              ? Color(int.parse(_selectedCategory!.color!
                                  .replaceAll('#', '0xFF')))
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedCategory?.name ?? 'Select Category',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: _selectedCategory != null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _selectedCategory != null
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant,
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
              if (widget.initialCategoryName != null &&
                  _selectedCategory == null)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    'Suggested: ${widget.initialCategoryName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.brightCyan,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Contact Selector (Optional)
              InkWell(
                onTap: () async {
                  final contact = await _showContactPicker();
                  if (contact != null) {
                    setState(() {
                      _selectedContact = contact;
                      _selectedContactId = contact.id;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedContact != null
                          ? AppColors.brightCyan
                          : theme.dividerColor,
                      width: _selectedContact != null ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: _selectedContact != null
                              ? AppColors.getContactGradient(
                                  _selectedContact!.name)
                              : null,
                          color: _selectedContact == null
                              ? theme.colorScheme.surfaceContainerHighest
                              : null,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: _selectedContact != null
                            ? Text(
                                _selectedContact!.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Icon(
                                Icons.person_outline,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact (Optional)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedContact?.name ?? 'Select Contact',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: _selectedContact != null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _selectedContact != null
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedContact != null) ...[
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedContact = null;
                              _selectedContactId = null;
                              _paidRelationship = null;
                              _createLinkedEntry = false;
                              _dueDate = null;
                            });
                          },
                        ),
                      ] else ...[
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ],
                  ),
                ),
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
                        gradient: AppColors.receivableGradient,
                        color: AppColors.receivableColor,
                        onTap: () => _handleRelationshipChange('PAID_FOR'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RelationshipButton(
                        label: 'Paid BY',
                        subtitle: 'Someone paid for me',
                        icon: Icons.person_outline,
                        isSelected: _paidRelationship == 'PAID_BY',
                        gradient: AppColors.payableGradient,
                        color: AppColors.payableColor,
                        onTap: () => _handleRelationshipChange('PAID_BY'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ] else if (_selectedType == 'INCOME') ...[
                Text(
                  'Received Relationship',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RelationshipButton(
                        label: 'I Owe',
                        subtitle: 'Received loan',
                        icon: Icons.download,
                        isSelected: _paidRelationship == 'RECEIVED_FROM',
                        gradient: AppColors.payableGradient,
                        color: AppColors.payableColor,
                        onTap: () => _handleRelationshipChange('RECEIVED_FROM'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RelationshipButton(
                        label: 'Will Receive',
                        subtitle: 'Receive later',
                        icon: Icons.schedule,
                        isSelected: _paidRelationship == 'WILL_RECEIVE',
                        gradient: AppColors.receivableGradient,
                        color: AppColors.receivableColor,
                        onTap: () => _handleRelationshipChange('WILL_RECEIVE'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Due Date Selector (only shown when relationship is active)
              if (_paidRelationship != null) ...[
                InkWell(
                  onTap: _selectDueDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: _paidRelationship == 'PAID_FOR' ||
                                    _paidRelationship == 'WILL_RECEIVE'
                                ? AppColors.receivableGradient
                                : AppColors.payableGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.event_available,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Due Date (Optional)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _dueDate != null
                                  ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                  : 'Not set',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (_dueDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() {
                                _dueDate = null;
                              });
                            },
                          ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
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
                    borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 24),

              // Countdown Badge (show until limit reached)
              if (limitsAsync.asData?.value != null &&
                  !limitsAsync.asData!.value.isUnlimited &&
                  limitsAsync.asData!.value.canAdd)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: LimitCountdownBadge(
                      dailyUsed: limitsAsync.asData!.value.dailyTotal -
                          limitsAsync.asData!.value.dailyRemaining,
                      dailyTotal: limitsAsync.asData!.value.dailyTotal,
                      monthlyUsed: limitsAsync.asData!.value.monthlyTotal -
                          limitsAsync.asData!.value.monthlyRemaining,
                      monthlyTotal: limitsAsync.asData!.value.monthlyTotal,
                    ),
                  ),
                ),

              // Save Button with Lock Icon (only when limit reached)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  GradientButton(
                    label: _isLoading ? 'Saving...' : l10n.save,
                    onPressed: _isLoading ? null : _saveTransaction,
                    gradient: isExpense
                        ? AppColors.expenseGradient
                        : AppColors.incomeGradient,
                    isLoading: _isLoading,
                    icon: _isLoading ? null : Icons.check,
                    width: double.infinity,
                  ),
                  if (limitsAsync.asData?.value != null &&
                      !limitsAsync.asData!.value.canAdd)
                    const Padding(
                      padding: EdgeInsets.only(top: 8, right: 8),
                      child: Icon(Icons.lock, size: 16, color: Colors.white),
                    ),
                ],
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : theme.dividerColor,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.3),
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
  final Gradient gradient;
  final Color color;

  const _RelationshipButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.gradient,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
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
