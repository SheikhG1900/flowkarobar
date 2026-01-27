import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/payables/data/payables_repository.dart';
import 'package:flowpaisa/features/receivables/data/receivables_repository.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/features/categories/presentation/screens/add_category_screen.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/add_contact_screen.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/schedule_selection_drawer.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/schedule_service_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  final Transaction transaction;
  final Category? category;
  final Contact? contact;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
    this.category,
    this.contact,
  });

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'EXPENSE';
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;
  bool _isLoading = false;

  Category? _selectedCategory;
  Contact? _selectedContact;
  String? _selectedContactUuid;

  String? _paidRelationship;

  @override
  void initState() {
    super.initState();
    // Initialize with existing transaction data
    _amountController.text = widget.transaction.amount.toStringAsFixed(2);
    _descriptionController.text = widget.transaction.description ?? '';
    _selectedType = widget.transaction.type;
    _selectedDate = widget.transaction.date;
    _selectedCategory = widget.category;
    _selectedContact = widget.contact;
    _selectedContactUuid = widget.transaction.contactUuid;
    _paidRelationship = widget.transaction.paidRelationship;

    // Fetch due date from linked payable/receivable if exists
    _loadLinkedEntryDueDate();
  }

  Future<void> _loadLinkedEntryDueDate() async {
    final database = ref.read(databaseProvider);
    final payablesRepository = PayablesRepository(database);
    final receivablesRepository = ReceivablesRepository(database);

    if (widget.transaction.linkedPayableUuid != null) {
      final payable = await payablesRepository
          .getPayableByUuid(widget.transaction.linkedPayableUuid!);
      if (mounted && payable != null) {
        setState(() {
          _dueDate = payable.dueDate;
        });
      }
    } else if (widget.transaction.linkedReceivableUuid != null) {
      final receivable = await receivablesRepository
          .getReceivableByUuid(widget.transaction.linkedReceivableUuid!);
      if (mounted && receivable != null) {
        setState(() {
          _dueDate = receivable.dueDate;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _scheduleTransaction() async {
    // Check schedule limits first
    final isPremium = PremiumGate.isPremium(ref);
    if (!isPremium) {
      final limits = await PremiumGate.getScheduleLimits(ref);
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

    // Show schedule selection drawer
    final result = await showModalBottomSheet<ScheduleSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ScheduleSelectionDrawer(),
    );

    if (result == null) {
      return; // User cancelled
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final scheduleService = ref.read(scheduleServiceProvider);
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text;

      await scheduleService.createSchedule(
        amount: amount,
        type: _selectedType,
        description: description,
        categoryUuid: _selectedCategory?.uuid,
        contactUuid: _selectedContactUuid,
        paidRelationship: _paidRelationship,
        dueDate: _dueDate,
        scheduleType: result.scheduleType,
        selectedDaysOfWeek: result.selectedDaysOfWeek,
        selectedDaysOfMonth: result.selectedDaysOfMonth,
      );

      // Invalidate schedule limits
      ref.invalidate(scheduleLimitsProvider);

      if (mounted) {
        Navigator.pop(context);
        ToastUtils.showSuccessToast(
          context,
          ref,
          l10n.scheduleCreated,
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateTransaction() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate contact for linked transactions
    if (_paidRelationship != null && _selectedContact == null) {
      ToastUtils.showErrorToast(
        context,
        ref,
        l10n.pleaseSelectContactRelationship,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final service = ref.read(transactionServiceProvider);
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text;

      // Update the transaction
      await service.updateTransaction(
        transactionUuid: widget.transaction.uuid,
        amount: amount,
        type: _selectedType,
        date: _selectedDate,
        description: description,
        contactUuid: _selectedContactUuid,
        categoryUuid: _selectedCategory?.uuid,
        paidRelationship: _paidRelationship,
        dueDate: _dueDate,
      );

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ToastUtils.showSuccessToast(
            context, ref, l10n.transactionUpdated);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Calculate relative days if _dueDate is set
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
    final l10n = AppLocalizations.of(context)!;
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

  Future<void> _handleRelationshipChange(String? value) async {
    final l10n = AppLocalizations.of(context)!;
    if (_paidRelationship == value) {
      setState(() {
        _paidRelationship = null;
      });
    } else {
      // Logic from AddTransactionScreen to prompt for contact if missing
      if (_selectedContact == null) {
        // Attempt to show picker
        _showContactPicker();
      }

      setState(() {
        _paidRelationship = value;
      });

      if (_selectedContact == null && mounted) {
        ToastUtils.showErrorToast(
          context,
          ref,
          l10n.pleaseSelectContactRelationship,
        );
      }
    }
  }

  void _showCategoryPicker() {
    final l10n = AppLocalizations.of(context)!;
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
                ref.watch(smartCategoriesProvider(_selectedType));

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
                          // Navigate to Add Category Screen
                          final newCategory = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddCategoryScreen(
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
                        label: Text(l10n.addNew),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: categoriesAsync.when(
                    data: (categoriesWithUsage) {
                      if (categoriesWithUsage.isEmpty) {
                        return Center(
                          child: Text(l10n.noCategoriesFound),
                        );
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
                            title: Text(CategoryHelper.getCategoryName(category, l10n)),
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

  void _showContactPicker() {
    final l10n = AppLocalizations.of(context)!;
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
            final contactsAsync = ref.watch(smartContactsProvider);
            final theme = Theme.of(context);

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
                            setState(() {
                              _selectedContact = newContact;
                              _selectedContactUuid = newContact.uuid;
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
                  child: contactsAsync.when(
                    data: (contactsWithUsage) {
                      if (contactsWithUsage.isEmpty) {
                        return Center(
                          child: Text(l10n.noContactsFound),
                        );
                      }
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: contactsWithUsage.length,
                        itemBuilder: (context, index) {
                          final item = contactsWithUsage[index];
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
                            trailing: _selectedContactUuid == contact.uuid
                                ? Icon(Icons.check_circle,
                                    color: theme.colorScheme.primary)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedContact = contact;
                                _selectedContactUuid = contact.uuid;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isExpense = _selectedType == 'EXPENSE';
    final currencySymbol = ref.watch(currencySymbolProvider);
    final scheduleLimitsAsync = ref.watch(scheduleLimitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editTransaction),
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
              // Amount Input
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
                      l10n.howMuch,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
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
                          return l10n.pleaseEnterValidAmount;
                        }
                        if (double.tryParse(value) == null) {
                          return l10n.pleaseEnterValidAmount;
                        }
                        if (double.parse(value) <= 0) {
                          return l10n.amountGreaterThanZero;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Type Selection
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
                          ? (isExpense
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
                          _selectedCategory?.icon != null
                              ? IconHelper.getIconData(_selectedCategory!.icon)
                              : Symbols.category,
                          color: _selectedCategory?.color != null
                              ? Color(int.parse(_selectedCategory!.color!
                                  .replaceAll('#', '0xFF')))
                              : null,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedCategory != null
                                ? CategoryHelper.getCategoryName(
                                    _selectedCategory!, l10n)
                                : l10n.selectCategory,
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
              const SizedBox(height: 16),

              // Contact Selector
              InkWell(
                onTap: _showContactPicker,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedContact != null
                          ? theme.colorScheme.primary
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
                            l10n.contactOptional,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedContact?.name ?? l10n.selectContact,
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
                              _selectedContactUuid = null;
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
                  hintText: l10n.descriptionHint,
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // Paid Relationship Section (Linked Transactions)
              if (isExpense) ...[
                Text(
                  l10n.paidRelationship,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RelationshipButton(
                        label: l10n.paidFor,
                        subtitle: l10n.iWillReceiveBack,
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
                        label: l10n.paidBy,
                        subtitle: l10n.someonePaidForMe,
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
                  l10n.receivedRelationship,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RelationshipButton(
                        label: l10n.iOwe,
                        subtitle: l10n.receivedLoan,
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
                        label: l10n.willReceive,
                        subtitle: l10n.receiveLater,
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
                              l10n.dueDateOptional,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_dueDate != null) ...[
                              Text(
                                AppDateFormatter.formatDate(_dueDate!),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  final txDate = DateTime(_selectedDate.year,
                                      _selectedDate.month, _selectedDate.day);
                                  final dDate = DateTime(_dueDate!.year,
                                      _dueDate!.month, _dueDate!.day);
                                  final diff = dDate.difference(txDate).inDays;
                                  String relativeText;
                                  if (diff == 0) {
                                    relativeText = l10n.sameDay;
                                  } else if (diff > 0) {
                                    relativeText = l10n.inDays(diff);
                                  } else {
                                    relativeText = l10n.daysAgoRelative(diff.abs());
                                  }
                                  return Text(
                                    relativeText,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ] else
                              Text(
                                l10n.notSet,
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
                          gradient: AppColors.getSecondaryGradient(theme.colorScheme.primary),
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
                            l10n.date,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppDateFormatter.formatDate(_selectedDate),
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

              // Update Button
              GradientButton(
                label: _isLoading ? l10n.updating : l10n.updateTransaction,
                onPressed: _isLoading ? null : _updateTransaction,
                gradient: isExpense
                    ? AppColors.expenseGradient
                    : AppColors.incomeGradient,
                isLoading: _isLoading,
                icon: _isLoading ? null : Icons.check,
                width: double.infinity,
              ),
              const SizedBox(height: 12),
              // Schedule Button with Lock Icon (only when limit reached)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: (_isLoading ||
                              (scheduleLimitsAsync.asData?.value != null &&
                                  !scheduleLimitsAsync.asData!.value.canAdd))
                          ? null
                          : _scheduleTransaction,
                      icon: const Icon(Icons.schedule),
                      label: Text(l10n.schedule),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: isExpense
                              ? AppColors.expenseColor
                              : AppColors.incomeColor,
                        ),
                      ),
                    ),
                  ),
                  if (scheduleLimitsAsync.asData?.value != null &&
                      !scheduleLimitsAsync.asData!.value.canAdd)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, right: 8),
                      child: Icon(
                        Icons.lock,
                        size: 16,
                        color: isExpense
                            ? AppColors.expenseColor
                            : AppColors.incomeColor,
                      ),
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
