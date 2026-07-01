import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/add_contact_screen.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/amount_calculator_sheet.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/shared/widgets/voice_input_button.dart';

class EditReceivableScreen extends ConsumerStatefulWidget {
  final String receivableUuid;

  const EditReceivableScreen({
    super.key,
    required this.receivableUuid,
  });

  @override
  ConsumerState<EditReceivableScreen> createState() =>
      _EditReceivableScreenState();
}

class _EditReceivableScreenState extends ConsumerState<EditReceivableScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionFocusNode = FocusNode();

  DateTime? _selectedDate;
  DateTime? _dueDate;
  bool? _autoCreateIncome;
  bool _isLoading = false;
  bool _isLoadingData = true;

  Contact? _selectedContact;
  String? _selectedContactUuid;
  Receivable? _receivable;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoadingData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadReceivableData();
      });
    }
  }

  Future<void> _loadReceivableData() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final repository = ref.read(receivablesRepositoryProvider);
      final receivable =
          await repository.getReceivableByUuid(widget.receivableUuid);

      if (receivable == null) {
        if (mounted) {
          ToastUtils.showErrorToast(context, ref, l10n.receivableNotFound);
          Navigator.pop(context);
        }
        return;
      }

      // Load contact data
      final contactsRepo = ref.read(contactsRepositoryProvider);
      final contact =
          await contactsRepo.getContactByUuid(receivable.contactUuid);

      if (mounted) {
        setState(() {
          _receivable = receivable;
          _amountController.text = receivable.amount.toString();
          _descriptionController.text = receivable.description ?? '';
          _selectedDate = receivable.date;
          _dueDate = receivable.dueDate;
          _autoCreateIncome = receivable.autoCreateIncome;
          _selectedContact = contact;
          _selectedContactUuid = receivable.contactUuid;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  void _onAmountChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _updateReceivable() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedContactUuid == null) {
      ToastUtils.showErrorToast(context, ref, l10n.pleaseSelectContact);
      return;
    }

    if (_receivable == null) {
      ToastUtils.showErrorToast(context, ref, l10n.receivableNotFound);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(receivablesRepositoryProvider);
      final updatedReceivable = _receivable!.copyWith(
        contactUuid: _selectedContactUuid!,
        amount: double.parse(_amountController.text),
        description: drift.Value(_descriptionController.text.isEmpty
            ? null
            : _descriptionController.text),
        date: _selectedDate!,
        dueDate: drift.Value(_dueDate),
        autoCreateIncome: _autoCreateIncome ?? false,
        updatedAt: DateTime.now(),
      );

      await repository.updateReceivable(updatedReceivable);

      if (mounted) {
        Navigator.pop(context);
        ToastUtils.showSuccessToast(context, ref, l10n.receivableUpdated);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
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
      initialDate: _selectedDate ?? DateTime.now(),
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
            final contactsAsync = ref.watch(contactsListProvider);

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
                          Navigator.pop(context); // Close picker
                          final newContact = await Navigator.push<Contact>(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AddContactScreen()),
                          );
                          if (newContact != null && mounted) {
                            setState(() {
                              _selectedContact = newContact;
                              _selectedContactUuid = newContact.uuid;
                            });
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
                    data: (contacts) {
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
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
                              setState(() {
                                _selectedContact = contact;
                                _selectedContactUuid = contact.uuid;
                              });
                              Navigator.pop(context);
                            },
                            selected: _selectedContactUuid == contact.uuid,
                            trailing: _selectedContactUuid == contact.uuid
                                ? const Icon(Icons.check_circle,
                                    color: AppColors.receivableColor)
                                : null,
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) =>
                        Center(child: Text(l10n.errorOccurred(e.toString()))),
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
    final currencySymbol = ref.watch(currencySymbolProvider);
    final decimalPlaces = ref.watch(currencyDecimalPlacesProvider);

    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.editReceivable),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editReceivable),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.receivableColor.withValues(alpha: 0.05),
              Colors.transparent
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            children: [
              // Amount Input (Large & Prominent)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.receivableColor.withValues(alpha: 0.1),
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
                        color: AppColors.receivableColor,
                      ),
                      decoration: InputDecoration(
                        prefixText: '$currencySymbol ',
                        prefixStyle: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        hintText: l10n.amountHint,
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
                          return l10n.pleaseEnterAmount;
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
                    if ((double.tryParse(_amountController.text) ?? 0) > 0) ...[
                      const SizedBox(height: 12),
                      IconButton.filled(
                        onPressed: () async {
                          final amount =
                              double.tryParse(_amountController.text) ?? 0.0;
                          await AmountCalculatorSheet.show(
                            context,
                            initialAmount: amount,
                            currencySymbol: currencySymbol,
                            decimalPlaces: decimalPlaces,
                            onDone: (result) {
                              setState(() {
                                _amountController.text =
                                    result.toStringAsFixed(decimalPlaces);
                              });
                            },
                          );
                        },
                        icon: const Icon(Symbols.calculate, size: 22),
                        tooltip: l10n.amountCalculatorButtonTooltip,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

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
                          ? AppColors.receivableColor
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
                            l10n.contact,
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
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Description
              TextFormField(
                controller: _descriptionController,
                focusNode: _descriptionFocusNode,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  hintText: l10n.descriptionHint,
                  prefixIcon: const Icon(Icons.description_outlined),
                  suffixIcon: VoiceInputButton(
                    controller: _descriptionController,
                    focusNode: _descriptionFocusNode,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 24),

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
                            _selectedDate != null
                                ? AppDateFormatter.formatDate(_selectedDate!)
                                : l10n.notSet,
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

              const SizedBox(height: 16),

              // Due Date Selector (Optional)
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
                          gradient: AppColors.receivableGradient,
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
                          Text(
                            _dueDate != null
                                ? AppDateFormatter.formatDate(_dueDate!)
                                : l10n.notSet,
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

              const SizedBox(height: 24),

              // Auto-create income option
              SwitchListTile(
                value: _autoCreateIncome ?? false,
                activeThumbColor: AppColors.receivableColor,
                onChanged: (value) {
                  setState(() {
                    _autoCreateIncome = value;
                  });
                },
                title: Text(l10n.autoCreateIncome),
                subtitle: Text(
                  l10n.autoCreateIncomeSubtitle,
                  style: const TextStyle(fontSize: 12),
                ),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.incomeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.monetization_on,
                      color: AppColors.incomeColor),
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GradientButton(
                      label: l10n.updateReceivable,
                      onPressed: _updateReceivable,
                      gradient: AppColors.receivableGradient,
                      width: double.infinity,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
