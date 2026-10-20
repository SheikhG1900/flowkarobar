import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/schedule_service_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/account_picker.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart'
    show TxMoreOptionsSection;
import 'package:flowpaisa/features/transactions/presentation/widgets/schedule_selection_drawer.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_scenario_picker.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/amount_snap_bar.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/shared/widgets/voice_input_button.dart';
import 'package:flowpaisa/core/utils/tabular_parser.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/tabular_editor_sheet.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
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
  final _descriptionFocusNode = FocusNode();

  List<TabularRow> _tabularRows = [];
  String _tabularSummary = '';
  bool _isTabularMode = false;

  String _selectedType = 'EXPENSE';
  bool _isLoading = false;

  Category? _selectedCategory;
  Contact? _selectedContact;
  Account? _selectedAccount;
  String? _selectedCategoryUuid;
  String? _selectedContactUuid;
  String? _paidRelationship;
  bool _isMoreOptionsExpanded = false;
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
    
    // Initialize tabular data if present
    if (TabularParser.isTabular(widget.schedule.description)) {
      final (summary, rows) = TabularParser.parse(widget.schedule.description);
      _tabularSummary = summary;
      _tabularRows = rows;
      _isTabularMode = true;
      _descriptionController.text = summary;
    }

    _selectedType = widget.schedule.type;
    _selectedCategory = null; 
    _selectedContact = null; 
    _selectedCategoryUuid = widget.schedule.categoryUuid; // Initialize UUID immediately
    _selectedContactUuid = widget.schedule.contactUuid;   // Initialize UUID immediately
    // Show actual stored value; null = no relationship selected
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

    // Load category, contact, and account
    Future.delayed(Duration.zero, () => _loadCategoryContactAndAccount());
  }

  Future<void> _loadCategoryContactAndAccount() async {
    if (widget.schedule.categoryUuid != null) {
      try {
        final categoriesRepo = ref.read(categoriesRepositoryProvider);
        final category = await categoriesRepo.getCategoryByUuid(widget.schedule.categoryUuid!);
        
        if (category != null) {
          if (mounted) {
            setState(() {
              _selectedCategory = category;
              _selectedCategoryUuid = category.uuid;
            });
          }
        }
      } catch (_) {}
    }

    if (widget.schedule.contactUuid != null) {
      try {
        final contactsRepo = ref.read(contactsRepositoryProvider);
        final contact = await contactsRepo.getContactByUuid(widget.schedule.contactUuid!);
        
        if (contact != null) {
          if (mounted) {
            setState(() {
              _selectedContact = contact;
              _selectedContactUuid = contact.uuid;
            });
          }
        }
      } catch (_) {}
    }

    if (widget.schedule.accountUuid != null) {
      try {
        final accountsRepo = ref.read(accountsRepositoryProvider);
        final account = await accountsRepo.getAccountByUuid(widget.schedule.accountUuid!);
        if (account != null && mounted) {
          setState(() => _selectedAccount = account);
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
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
      final l10n = AppLocalizations.of(context)!;
      final scheduleService = ref.read(scheduleServiceProvider);
      final amount = double.parse(_amountController.text);
      
      String? description;
      if (_isTabularMode && _tabularRows.isNotEmpty) {
        description = TabularParser.serialize(
            _descriptionController.text, _tabularRows);
      } else {
        description = _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text;
      }

      final catUuid = _selectedCategory?.uuid ?? _selectedCategoryUuid;
      final conUuid = _selectedContact?.uuid ?? _selectedContactUuid;

      // Calculate dueDateOffset if both dates are available
      int? dueDateOffset;
      if (_dueDate != null) {
        // Use startDate if available as the reference, otherwise use current date as a fallback
        // since schedules are template-based.
        final referenceDate = _startDate ?? DateTime.now();
        final refDate = DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
        final dDate = DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day);
        dueDateOffset = dDate.difference(refDate).inDays;
      }

      await scheduleService.updateSchedule(
        widget.schedule.uuid,
        amount: Value(amount),
        type: Value(_selectedType),
        description: Value(description),
        categoryUuid: Value(catUuid),
        contactUuid: Value(conUuid),
        accountUuid: Value(_selectedAccount?.uuid),
        paidRelationship: Value(_paidRelationship),
        dueDate: Value(_dueDate),
        dueDateOffset: Value(dueDateOffset),
        scheduleType: Value(_scheduleType),
        selectedDaysOfWeek: Value(_selectedDaysOfWeek),
        selectedDaysOfMonth: Value(_selectedDaysOfMonth),
        startDate: Value(_startDate),
        endDate: Value(_endDate),
      );

      // Invalidate schedules provider
      ref.invalidate(allSchedulesProvider);

      if (mounted) {
        Navigator.pop(context, true);
        ToastUtils.showSuccessToast(
            context, ref, l10n.scheduleUpdated);
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
            Text(l10n.enterDaysFromStart),
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
                final referenceDate = _startDate ?? DateTime.now();
                setState(() {
                  _dueDate = referenceDate.add(Duration(days: days));
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
    final l10n = AppLocalizations.of(context)!;
    // Same behavior as add/edit transaction: PROCESSED toggle, deselect Receivable/Payable
    if (value == 'PROCESSED') {
      setState(() {
        _paidRelationship =
            _paidRelationship == 'PROCESSED' ? null : 'PROCESSED';
        _dueDate = null;
      });
      return;
    }
    if (_paidRelationship == value) {
      setState(() {
        _paidRelationship = null;
        _dueDate = null;
      });
    } else {
      if (_selectedContact == null) {
        await _showContactPicker();
        if (_selectedContact == null) {
          if (mounted) {
            ToastUtils.showErrorToast(
              context,
              ref,
              l10n.pleaseSelectContactRelationship,
            );
          }
          return;
        }
      }
      setState(() {
        _paidRelationship = value;
      });
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
      builder: (modalContext) => DraggableScrollableSheet(
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
                    l10n.selectCategory,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                                IconHelper.getIconData(category.icon) ??
                                    Symbols.category,
                                color: color,
                                size: 24,
                              ),
                            ),
                            title: Text(
                                CategoryHelper.getCategoryName(category, l10n)),
                            trailing: _selectedCategory?.uuid == category.uuid
                                ? Icon(Icons.check_circle, color: color)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                                _selectedCategoryUuid = category.uuid;
                              });
                              Navigator.pop(modalContext);
                            },
                            selected: _selectedCategory?.uuid == category.uuid,
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

  Future<Contact?> _showContactPicker() async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return await showModalBottomSheet<Contact>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (modalContext) => DraggableScrollableSheet(
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
                    l10n.selectContact,
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
                            trailing: _selectedContactUuid == contact.uuid
                                ? Icon(Icons.check_circle,
                                    color: theme.colorScheme.primary)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedContact = contact;
                                _selectedContactUuid = contact.uuid;
                              });
                              Navigator.pop(modalContext);
                            },
                            selected: _selectedContactUuid == contact.uuid,
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
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editSchedule),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n.scenarioHelpTitle,
            onPressed: () {
              showTransactionScenarioPicker(context,
                  onScenarioSelected: (type, relationship) {
                setState(() {
                  _selectedType = type;
                  _paidRelationship = relationship;
                });
              });
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _ScheduleFabChip(
        label: _isLoading ? l10n.updating : l10n.updateSchedule,
        icon: _isLoading ? null : Icons.check,
        isLoading: _isLoading,
        color: isExpense ? AppColors.expenseColor : AppColors.incomeColor,
        onPressed: _isLoading ? null : _updateSchedule,
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
                      l10n.amount,
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
                        prefixText: isRtl ? null : '$currencySymbol ',
                        suffixText: isRtl ? ' $currencySymbol' : null,
                        prefixStyle: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        suffixStyle: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        hintText: l10n.amountHint,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseEnterAmount;
                        }
                        if (double.tryParse(value) == null) {
                          return l10n.pleaseEnterValidNumber;
                        }
                        if (double.parse(value) <= 0) {
                          return l10n.amountGreaterThanZero;
                        }
                        return null;
                      },
                    ),
                    AmountSnapBar(
                      controller: _amountController,
                      currencySymbol: currencySymbol,
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
                          if (_paidRelationship == 'WILL_RECEIVE') {
                            _paidRelationship = 'PAID_FOR';
                          } else if (_paidRelationship == 'RECEIVED_FROM') {
                            _paidRelationship = 'PAID_BY';
                          } else {
                            _paidRelationship = 'PROCESSED';
                            _dueDate = null;
                          }
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
                          if (_paidRelationship == 'PAID_FOR') {
                            _paidRelationship = 'WILL_RECEIVE';
                          } else if (_paidRelationship == 'PAID_BY') {
                            _paidRelationship = 'RECEIVED_FROM';
                          } else {
                            _paidRelationship = 'PROCESSED';
                            _dueDate = null;
                          }
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
                                  : (_selectedCategoryUuid != null
                                      ? 'Loading...'
                                      : l10n.selectCategory),
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

              // Account picker (create account from sheet when none exist)
              AccountPickerField(
                selectedAccount: _selectedAccount,
                excludeCreditCard: _selectedType == 'INCOME' &&
                    _selectedCategory?.uuid != 'default_cat_refund',
                onChanged: (acc) => setState(() => _selectedAccount = acc),
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
                      Expanded(
                        child: Column(
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
                              _selectedContact?.name ??
                                  (_selectedContactUuid != null
                                      ? 'Loading...'
                                      : l10n.selectContact),
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
                              _selectedContactUuid = null;
                              // Clear relationship when contact is removed
                              _paidRelationship = 'PROCESSED';
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
              const SizedBox(height: 16),

              // Description
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                focusNode: _descriptionFocusNode,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  hintText: l10n.descriptionHint,
                  prefixIcon: const Icon(Icons.notes_outlined),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (ref.watch(premiumProvider).isPremium)
                        IconButton(
                          icon: Icon(
                            _isTabularMode
                                ? Icons.table_chart
                                : Icons.table_chart_outlined,
                            color: _isTabularMode
                                ? theme.colorScheme.primary
                                : null,
                          ),
                          onPressed: () {
                            TabularEditorSheet.show(
                              context,
                              initialRows: _tabularRows,
                              currencySymbol: currencySymbol,
                              decimalPlaces:
                                  ref.read(currencyDecimalPlacesProvider),
                              currentTransactionAmount:
                                  double.tryParse(_amountController.text) ??
                                      0.0,
                              onSave: (rows, updateAmount) {
                                setState(() {
                                  _tabularRows = rows;
                                  _isTabularMode = rows.isNotEmpty;
                                  if (updateAmount) {
                                    final total = rows.fold(0.0,
                                        (sum, row) => sum + row.totalAmount);
                                    _amountController.text =
                                        total.toStringAsFixed(2);
                                  }
                                });
                              },
                            );
                          },
                          tooltip: _isTabularMode
                              ? l10n.itemizedDetails
                              : l10n.itemizedDetails,
                        ),
                      VoiceInputButton(
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                      ),
                    ],
                  ),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),

              if (_isTabularMode && ref.watch(premiumProvider).isPremium) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    TabularEditorSheet.show(
                      context,
                      initialRows: _tabularRows,
                      currencySymbol: currencySymbol,
                      decimalPlaces: ref.read(currencyDecimalPlacesProvider),
                      currentTransactionAmount:
                          double.tryParse(_amountController.text) ?? 0,
                      onSave: (rows, updateAmount) {
                        setState(() {
                          _tabularRows = rows;
                          _isTabularMode = rows.isNotEmpty;
                          if (updateAmount) {
                            final total = rows.fold(
                                0.0, (sum, row) => sum + row.totalAmount);
                            _amountController.text = total.toStringAsFixed(2);
                          }
                        });
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.list_alt,
                            size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _tabularRows.isEmpty
                                ? 'Add Itemized Details'
                                : '${_tabularRows.length} item(s) added',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            size: 20, color: theme.colorScheme.primary),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

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
                          gradient: AppColors.getSecondaryGradient(
                              theme.colorScheme.primary),
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
                              l10n.schedulePattern,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getSchedulePatternText(l10n),
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
                          gradient: AppColors.getSecondaryGradient(
                              theme.colorScheme.primary),
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
                              l10n.startDateOptional,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _startDate != null
                                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                  : l10n.notSet,
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
                          gradient: AppColors.getSecondaryGradient(
                              theme.colorScheme.primary),
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
                              l10n.endDateOptional,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _endDate != null
                                  ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                  : l10n.notSet,
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
              const SizedBox(height: 16),

              // More Options (same as add/edit transaction)
              TxMoreOptionsSection(
                isExpanded: _isMoreOptionsExpanded,
                onToggle: () => setState(
                    () => _isMoreOptionsExpanded = !_isMoreOptionsExpanded),
                selectedType: _selectedType,
                paidRelationship: _paidRelationship,
                onRelationshipChange: _handleRelationshipChange,
                dueDate: _dueDate,
                selectedDate: _startDate ?? DateTime.now(),
                onDueDateTap: () async {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: Text(l10n.pickActualDate),
                            onTap: () {
                              Navigator.pop(context);
                              _selectDueDate();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.timer),
                            title: Text(l10n.relativeDateAfterXDays("X")),
                            onTap: () {
                              Navigator.pop(context);
                              _showRelativeDateDialog();
                            },
                          ),
                          if (_dueDate != null)
                            ListTile(
                              leading: const Icon(Icons.clear,
                                  color: Colors.red),
                              title: Text(l10n.clearData,
                                  style: const TextStyle(color: Colors.red)),
                              onTap: () {
                                setState(() => _dueDate = null);
                                Navigator.pop(context);
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
                onClearDueDate: () => setState(() => _dueDate = null),
                isGroupSplit: false,
                groupSharesCount: 0,
                myShareAmount: null,
                isSplitMode: false,
                onSplitTap: () {},
                onClearSplit: () {},
                showSplitButton: false,
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  String _getSchedulePatternText(AppLocalizations l10n) {
    switch (_scheduleType) {
      case 'DAILY':
        return l10n.daily;
      case 'WEEKLY':
        if (_selectedDaysOfWeek != null && _selectedDaysOfWeek!.isNotEmpty) {
          final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
          final selectedDayNames =
              _selectedDaysOfWeek!.map((d) => dayNames[d]).join(', ');
          return l10n.weeklyWithDays(selectedDayNames);
        }
        return l10n.weekly;
      case 'MONTHLY':
        if (_selectedDaysOfMonth != null && _selectedDaysOfMonth!.isNotEmpty) {
          if (_selectedDaysOfMonth!.length == 1) {
            return l10n.monthlyWithDay(_selectedDaysOfMonth!.first.toString());
          }
          return l10n.monthlyWithDay(_selectedDaysOfMonth!.join(', '));
        }
        return l10n.monthly;
      default:
        return l10n.unknown;
    }
  }
}

class _ScheduleFabChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _ScheduleFabChip({
    required this.label,
    required this.color,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null && !isLoading;
    final effectiveColor = disabled ? color.withValues(alpha: 0.5) : color;

    return Material(
      elevation: disabled ? 0 : 4,
      borderRadius: BorderRadius.circular(24),
      color: effectiveColor,
      shadowColor: color.withValues(alpha: 0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              else if (icon != null)
                Icon(icon, color: Colors.white, size: 18),
              if (isLoading || icon != null) const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
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


