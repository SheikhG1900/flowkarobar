import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/features/messages/presentation/providers/message_template_provider.dart';
import 'package:flowpaisa/features/whatsapp/presentation/providers/whatsapp_provider.dart';
import 'package:flowpaisa/core/utils/share_helper.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/payables/presentation/widgets/payable_details_dialog.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/add_contact_screen.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/shared/widgets/limit_countdown_badge.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';

class AddPayableScreen extends ConsumerStatefulWidget {
  final double? initialAmount;
  final DateTime? initialDate;
  final String? initialDescription;
  final String? initialContactName;
  final String? initialContactPhone;
  final String? initialExternalLinkId;
  final DateTime? initialDueDate;

  const AddPayableScreen({
    super.key,
    this.initialAmount,
    this.initialDate,
    this.initialDescription,
    this.initialContactName,
    this.initialContactPhone,
    this.initialExternalLinkId,
    this.initialDueDate,
  });

  @override
  ConsumerState<AddPayableScreen> createState() => _AddPayableScreenState();
}

class _AddPayableScreenState extends ConsumerState<AddPayableScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;
  bool _autoCreateExpense = true; // Default to true for convenience
  bool _isLoading = false;
  bool _isDuplicate = false;

  Contact? _selectedContact;
  String? _selectedContactUuid;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!.toStringAsFixed(2);
    }
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
    if (widget.initialDescription != null) {
      _descriptionController.text = widget.initialDescription!;
    }
    if (widget.initialDueDate != null) {
      _dueDate = widget.initialDueDate;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeEntities();
    });
  }

  Future<void> _initializeEntities() async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.initialExternalLinkId != null) {
      final repository = ref.read(payablesRepositoryProvider);
      final exists = await repository
          .checkIfExternalLinkExists(widget.initialExternalLinkId!);
      if (exists) {
        if (mounted) {
          setState(() {
            _isDuplicate = true;
          });
          ToastUtils.showWarningToast(
            context,
            ref,
            l10n.payableAlreadyImported,
          );
        }
      }
    }

    if (widget.initialContactPhone != null ||
        widget.initialContactName != null) {
      final contactsRepo = ref.read(contactsRepositoryProvider);

      Contact? contact;
      if (widget.initialContactPhone != null &&
          widget.initialContactPhone!.isNotEmpty) {
        contact =
            await contactsRepo.getContactByPhone(widget.initialContactPhone!);
      }

      if (contact == null && widget.initialContactName != null) {
        final allContacts = await contactsRepo.watchAllContacts().first;
        try {
          contact = allContacts.firstWhere((c) =>
              c.name.toLowerCase() == widget.initialContactName!.toLowerCase());
        } catch (_) {}
      }

      if (contact != null) {
        if (mounted) {
          setState(() {
            _selectedContact = contact;
            _selectedContactUuid = contact!.uuid;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _savePayable() async {
    // Check limits first - prevent saving if limit reached, regardless of form validity
    final isPremium = PremiumGate.isPremium(ref);
    if (!isPremium) {
      final limits = await PremiumGate.getPayableLimits(ref);
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

    final l10n = AppLocalizations.of(context)!;
    if (_selectedContactUuid == null) {
      ToastUtils.showErrorToast(context, ref, l10n.pleaseSelectContact);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(payablesRepositoryProvider);
      final payable = PayablesCompanion(
        contactUuid: drift.Value(_selectedContactUuid!),
        amount: drift.Value(double.parse(_amountController.text)),
        description: drift.Value(_descriptionController.text.isEmpty
            ? null
            : _descriptionController.text),
        date: drift.Value(_selectedDate),
        dueDate: drift.Value(_dueDate),
        status: const drift.Value('PENDING'),
        autoCreateExpense: drift.Value(_autoCreateExpense),
        externalLinkId: drift.Value(widget.initialExternalLinkId),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      );

      // Create payable and get the ID
      final payableUuid = await repository.createPayable(payable);

      // Increment usage count for free users
      if (!PremiumGate.isPremium(ref)) {
        await ref.read(usageTrackerRepositoryProvider).incrementPayableCount();
      }

      // Invalidate provider to refresh limits
      ref.invalidate(payableLimitsProvider);

      if (mounted) {
        // Fetch full payable with linked data
        final payableWithLinkedData =
            await repository.getPayableWithLinkedDataByUuid(payableUuid);

        if (payableWithLinkedData != null) {
          final activeColor = ref.read(activeCashbookProvider).color;
          final currency = ref.read(currentCurrencyProvider).value!;
          final userProfile = ref.read(userProfileProvider);
          final transactionService = ref.read(transactionServiceProvider);
          final whatsAppService = ref.read(whatsAppServiceProvider);

          final capturedCurrency = currency;
          final capturedUserProfile = userProfile;
          final capturedTransactionService = transactionService;
          final capturedWhatsAppService = whatsAppService;
          final capturedTemplateService = ref.read(messageTemplateServiceProvider);
          final capturedLanguage = getCurrentLanguageCode(ref);

          ToastUtils.showSuccessToast(
            context,
            ref,
            l10n.payableAdded,
            actionLabel: l10n.share,
            onActionPressed: (snackContext) => ShareHelper.sharePayable(
              snackContext,
              ref,
              payableWithLinkedData.payable,
              payableWithLinkedData.contact,
              currencyOverride: capturedCurrency,
              userProfileOverride: capturedUserProfile,
              transactionServiceOverride: capturedTransactionService,
              whatsAppServiceOverride: capturedWhatsAppService,
              templateServiceOverride: capturedTemplateService,
              languageOverride: capturedLanguage,
            ),
            color: activeColor,
          );

          final navigator = Navigator.of(context);
          // Pop create page and navigate to details
          navigator.pop();
          navigator.push(
            MaterialPageRoute(
              builder: (context) =>
                  PayableDetailsDialog(item: payableWithLinkedData),
            ),
          );
        } else {
          ToastUtils.showSuccessToast(context, ref, l10n.payableAdded);
          Navigator.pop(context);
        }
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

  void _showContactPicker() {
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

            final l10n = AppLocalizations.of(context)!;
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
                                    color: AppColors.payableColor)
                                : null,
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(
                        child: Text(l10n.errorOccurred(e.toString()))),
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
    final limitsAsync = ref.watch(payableLimitsProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addPayable),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.payableColor.withValues(alpha: 0.05),
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
                      color: AppColors.payableColor.withValues(alpha: 0.1),
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
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.payableColor,
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
                          ? AppColors.payableColor
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
                      ] else if (widget.initialContactName != null) ...[
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ] else ...[
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ],
                  ),
                ),
              ),
              if (widget.initialContactName != null && _selectedContact == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final contactsRepo =
                            ref.read(contactsRepositoryProvider);
                        final uuid = await contactsRepo.createContact(
                          ContactsCompanion(
                            name: drift.Value(widget.initialContactName!),
                            phone: drift.Value(widget.initialContactPhone),
                            createdAt: drift.Value(DateTime.now()),
                            updatedAt: drift.Value(DateTime.now()),
                          ),
                        );
                        final newContact =
                            (await contactsRepo.watchAllContacts().first)
                                .firstWhere((c) => c.uuid == uuid);
                        setState(() {
                          _selectedContact = newContact;
                          _selectedContactUuid = uuid;
                        });
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        l10n.addContactWithName(widget.initialContactName!),
                        textAlign: TextAlign.center,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
                  prefixIcon: const Icon(Icons.description_outlined),
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
                          gradient: AppColors.payableGradient,
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

              // Auto-create expense option
              SwitchListTile(
                value: _autoCreateExpense,
                activeColor: AppColors.payableColor,
                onChanged: (value) {
                  setState(() {
                    _autoCreateExpense = value;
                  });
                },
                title: Text(l10n.autoCreateExpense),
                subtitle: Text(
                  l10n.autoCreateExpenseSubtitle,
                  style: const TextStyle(fontSize: 12),
                ),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.expenseColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.payment, color: AppColors.expenseColor),
                ),
              ),

              const SizedBox(height: 32),

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

              // Submit Button with Lock Icon (only when limit reached)
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      alignment: Alignment.topRight,
                      children: [
                        GradientButton(
                          label: l10n.addPayable,
                          onPressed: _isDuplicate ? null : _savePayable,
                          gradient: AppColors.payableGradient,
                          width: double.infinity,
                        ),
                        if ((limitsAsync.asData?.value != null &&
                                !limitsAsync.asData!.value.canAdd) ||
                            _isDuplicate)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, right: 8),
                            child: Icon(
                              _isDuplicate ? Icons.info_outline : Icons.lock,
                              size: 16,
                              color: Colors.white,
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
