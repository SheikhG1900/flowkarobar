import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/schedule_service_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/schedule_selection_drawer.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'dart:convert';

class EditScheduleScreen extends ConsumerStatefulWidget {
  final TransactionSchedule schedule;

  const EditScheduleScreen({
    super.key,
    required this.schedule,
  });

  @override
  ConsumerState<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends ConsumerState<EditScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'EXPENSE';
  bool _isLoading = false;

  Category? _selectedCategory;
  Contact? _selectedContact;
  int? _selectedContactId;
  String? _paidRelationship;
  DateTime? _dueDate;
  DateTime? _startDate;
  DateTime? _endDate;

  String _scheduleType = 'DAILY';
  List<int>? _selectedDaysOfWeek;
  List<int>? _selectedDaysOfMonth;

  @override
  void initState() {
    super.initState();
    // Initialize with existing schedule data
    _amountController.text = widget.schedule.amount.toStringAsFixed(2);
    _descriptionController.text = widget.schedule.description ?? '';
    _selectedType = widget.schedule.type;
    _selectedCategory = null; // Will be loaded
    _selectedContact = null; // Will be loaded
    _selectedContactId = widget.schedule.contactId;
    _paidRelationship = widget.schedule.paidRelationship;
    _dueDate = widget.schedule.dueDate;
    _startDate = widget.schedule.startDate;
    _endDate = widget.schedule.endDate;
    _scheduleType = widget.schedule.scheduleType;

    // Parse selected days
    if (widget.schedule.selectedDaysOfWeek != null) {
      try {
        final List<dynamic> decoded =
            jsonDecode(widget.schedule.selectedDaysOfWeek!);
        _selectedDaysOfWeek = decoded.map((e) => e as int).toList();
      } catch (e) {
        _selectedDaysOfWeek = null;
      }
    }

    if (widget.schedule.selectedDaysOfMonth != null) {
      try {
        final List<dynamic> decoded =
            jsonDecode(widget.schedule.selectedDaysOfMonth!);
        _selectedDaysOfMonth = decoded.map((e) => e as int).toList();
      } catch (e) {
        _selectedDaysOfMonth = null;
      }
    }

    // Load category and contact
    _loadCategoryAndContact();
  }

  Future<void> _loadCategoryAndContact() async {
    if (widget.schedule.categoryId != null) {
      // Load category
      final categories =
          await ref.read(categoriesByTypeProvider(widget.schedule.type).future);
      try {
        final category =
            categories.firstWhere((c) => c.id == widget.schedule.categoryId);
        if (mounted) {
          setState(() {
            _selectedCategory = category;
          });
        }
      } catch (e) {
        // Category not found
      }
    }

    if (widget.schedule.contactId != null) {
      // Load contact
      final contacts = await ref.read(contactsListProvider.future);
      try {
        final contact =
            contacts.firstWhere((c) => c.id == widget.schedule.contactId);
        if (mounted) {
          setState(() {
            _selectedContact = contact;
          });
        }
      } catch (e) {
        // Contact not found
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateSchedule() async {
    if (!_formKey.currentState!.validate()) {
      return;
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

      await scheduleService.updateSchedule(
        widget.schedule.id,
        amount: amount,
        type: _selectedType,
        description: description,
        categoryId: _selectedCategory?.id,
        contactId: _selectedContactId,
        paidRelationship: _paidRelationship,
        dueDate: _dueDate,
        scheduleType: _scheduleType,
        selectedDaysOfWeek: _selectedDaysOfWeek,
        selectedDaysOfMonth: _selectedDaysOfMonth,
        startDate: _startDate,
        endDate: _endDate,
      );

      // Invalidate schedules provider
      ref.invalidate(allSchedulesProvider);

      if (mounted) {
        Navigator.pop(context, true);
        ToastUtils.showSuccessToast(context, 'Schedule updated successfully');
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

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
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

  Future<void> _handleRelationshipChange(String? value) async {
    if (_paidRelationship == value) {
      setState(() {
        _paidRelationship = null;
        _dueDate = null;
      });
    } else {
      // Check if contact is selected when setting relationship
      if (_selectedContact == null) {
        // Show contact picker
        final contact = await _showContactPicker();
        if (contact == null) {
          if (mounted) {
            ToastUtils.showErrorToast(
              context,
              'Please select a contact for this relationship',
            );
          }
          return;
        }
        setState(() {
          _selectedContact = contact;
          _selectedContactId = contact.id;
        });
      }

      setState(() {
        _paidRelationship = value;
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
            final categoriesAsync =
                ref.watch(smartCategoriesProvider(_selectedType));

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Select Category',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Expanded(
                  child: categoriesAsync.when(
                    data: (categoriesWithUsage) {
                      if (categoriesWithUsage.isEmpty) {
                        return const Center(
                          child: Text('No categories found'),
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
                                IconHelper.getIconData(category.icon) ??
                                    Symbols.category,
                                color: color,
                                size: 24,
                              ),
                            ),
                            title: Text(category.name),
                            trailing: _selectedCategory?.id == category.id
                                ? Icon(Icons.check_circle, color: color)
                                : null,
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
            final contactsAsync = ref.watch(smartContactsProvider);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Select Contact',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                            trailing: _selectedContactId == contact.id
                                ? const Icon(Icons.check_circle,
                                    color: AppColors.brightCyan)
                                : null,
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

  Future<void> _showSchedulePatternPicker() async {
    // Pre-select current pattern
    final result = await showModalBottomSheet<ScheduleSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleSelectionDrawer(
        initialScheduleType: _scheduleType,
        initialSelectedDaysOfWeek: _selectedDaysOfWeek,
        initialSelectedDaysOfMonth: _selectedDaysOfMonth,
      ),
    );

    if (result != null) {
      setState(() {
        _scheduleType = result.scheduleType;
        _selectedDaysOfWeek = result.selectedDaysOfWeek;
        _selectedDaysOfMonth = result.selectedDaysOfMonth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isExpense = _selectedType == 'EXPENSE';
    final currencySymbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Schedule'),
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
                      'Amount',
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
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
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
                          _paidRelationship = null;
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
                          _paidRelationship = null;
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
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          IconHelper.getIconData(_selectedCategory?.icon) ??
                              Symbols.category,
                          color: _selectedCategory?.color != null
                              ? Color(int.parse(_selectedCategory!.color!
                                  .replaceAll('#', '0xFF')))
                              : theme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
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
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Contact Selector
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
                      Expanded(
                        child: Column(
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
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedContact != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedContact = null;
                              _selectedContactId = null;
                              // Clear relationship when contact is removed
                              _paidRelationship = null;
                              _dueDate = null;
                            });
                          },
                        )
                      else
                        const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
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
                        Expanded(
                          child: Column(
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
                        ),
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
                const SizedBox(height: 24),
              ],

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

              // Schedule Pattern Selector
              InkWell(
                onTap: _showSchedulePatternPicker,
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
                          Icons.schedule,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Schedule Pattern',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getSchedulePatternText(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Start Date (Optional)
              InkWell(
                onTap: _selectStartDate,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date (Optional)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _startDate != null
                                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                  : 'Not set',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_startDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              _startDate = null;
                            });
                          },
                        ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // End Date (Optional)
              InkWell(
                onTap: _selectEndDate,
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
                          Icons.event_available,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Date (Optional)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _endDate != null
                                  ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                  : 'Not set',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_endDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              _endDate = null;
                            });
                          },
                        ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Update Button
              GradientButton(
                label: _isLoading ? 'Updating...' : 'Update Schedule',
                onPressed: _isLoading ? null : _updateSchedule,
                gradient: isExpense
                    ? AppColors.expenseGradient
                    : AppColors.incomeGradient,
                isLoading: _isLoading,
                icon: _isLoading ? null : Icons.check,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSchedulePatternText() {
    switch (_scheduleType) {
      case 'DAILY':
        return 'Daily';
      case 'WEEKLY':
        if (_selectedDaysOfWeek != null && _selectedDaysOfWeek!.isNotEmpty) {
          final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
          final selectedDayNames =
              _selectedDaysOfWeek!.map((d) => dayNames[d]).join(', ');
          return 'Weekly: $selectedDayNames';
        }
        return 'Weekly';
      case 'MONTHLY':
        if (_selectedDaysOfMonth != null && _selectedDaysOfMonth!.isNotEmpty) {
          if (_selectedDaysOfMonth!.length == 1) {
            return 'Monthly: ${_selectedDaysOfMonth!.first}';
          }
          return 'Monthly: ${_selectedDaysOfMonth!.join(', ')}';
        }
        return 'Monthly';
      default:
        return 'Unknown';
    }
  }
}

/// Relationship Button Widget for Paid FOR/BY selection
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
