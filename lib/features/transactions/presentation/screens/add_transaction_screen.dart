import 'package:flowpaisa/features/messages/presentation/providers/message_template_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/whatsapp/presentation/providers/whatsapp_provider.dart';
import 'package:flowpaisa/core/utils/share_helper.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
// import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_details_dialog.dart';
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
import 'package:flowpaisa/features/transactions/presentation/widgets/schedule_selection_drawer.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/schedule_service_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final double? initialAmount;
  final DateTime? initialDate;
  final String? initialDescription;
  final String? initialType;
  final String? initialRelationship;
  final String? initialCategoryName;
  final String? initialCategoryColor;
  final String? initialCategoryIcon;
  final String? initialContactName;
  final String? initialContactPhone;
  final String? initialExternalLinkId;

  const AddTransactionScreen({
    super.key,
    this.initialAmount,
    this.initialDate,
    this.initialDescription,
    this.initialType,
    this.initialRelationship,
    this.initialCategoryName,
    this.initialCategoryColor,
    this.initialCategoryIcon,
    this.initialContactName,
    this.initialContactPhone,
    this.initialExternalLinkId,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'EXPENSE';
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;
  bool _isLoading = false;
  bool _isDuplicate = false;

  // Selected entities
  Category? _selectedCategory;
  Contact? _selectedContact;

  // Linked transaction fields
  String? _selectedContactUuid;
  String?
      _paidRelationship; // 'PAID_FOR', 'PAID_BY', 'RECEIVED_FROM', 'WILL_RECEIVE' or null
  bool _createLinkedEntry = false;

  // My Share fields
  double? _myShareAmount;
  bool _isSplitMode = true; // true = Split, false = Add

  // Group Split fields
  List<SplitShare> _groupShares = [];
  bool _isGroupSplit = false;

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
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
    if (widget.initialRelationship != null) {
      _paidRelationship = widget.initialRelationship;
      _createLinkedEntry = true;
    }

    // Handle initial contact and category in post-frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeEntities();
    });
  }

  Future<void> _initializeEntities() async {
    // 0. Handle duplicate check
    if (widget.initialExternalLinkId != null) {
      final repository = ref.read(transactionsRepositoryProvider);
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
            l10n.transactionAlreadyImported,
          );
        }
      }
    }

    // 1. Handle Contact
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
        // Option to create contact will be handled by the UI or we can auto-create
        // For now, we'll try to find by name if phone failed
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
      } else if (widget.initialContactName != null) {
        // We have a name but no contact found - the UI already has a "Suggest" or "Add New" flow
        // We'll keep the info available for the user to create
      }
    }

    // 2. Handle Category
    if (widget.initialCategoryName != null) {
      final categoriesRepo = ref.read(categoriesRepositoryProvider);
      final allCategories = await categoriesRepo.watchAllCategories().first;

      Category? category;
      try {
        category = allCategories.firstWhere((c) =>
            c.name.toLowerCase() == widget.initialCategoryName!.toLowerCase());
      } catch (_) {}

      if (category != null) {
        if (mounted) {
          setState(() {
            _selectedCategory = category;
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

    if (!_isGroupSplit && _createLinkedEntry && _selectedContact == null) {
      ToastUtils.showErrorToast(
        context,
        ref,
        l10n.pleaseSelectContactLinked,
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

      if (_isGroupSplit) {
        await transactionService.createGroupSplit(
          totalAmount: amount,
          type: _selectedType,
          date: _selectedDate,
          shares: _groupShares,
          description: description,
          categoryUuid: _selectedCategory?.uuid,
          paidRelationship: _paidRelationship,
          dueDate: _dueDate,
        );
      } else {
        // Create transaction and get the ID
        final transactionUuid = await transactionService.createTransaction(
          amount: amount,
          type: _selectedType,
          date: _selectedDate,
          description: description,
          contactUuid: _selectedContactUuid,
          categoryUuid: _selectedCategory?.uuid,
          paidRelationship: _paidRelationship,
          createLinkedEntry: _createLinkedEntry,
          dueDate: _dueDate,
          externalLinkId: widget.initialExternalLinkId,
          myShareAmount: _myShareAmount,
          isSplitMode: _isSplitMode,
          l10n: l10n,
        );

        // Fetch full transaction with details for toast action
        final repository = ref.read(transactionsRepositoryProvider);
        final transactionWithDetails =
            await repository.getTransactionWithDetailsByUuid(transactionUuid);

        if (mounted && transactionWithDetails != null) {
          final activeColor = ref.read(activeCashbookProvider).color;
          final currency = ref.read(currentCurrencyProvider).value!;
          final userProfile = ref.read(userProfileProvider);
          final whatsAppService = ref.read(whatsAppServiceProvider);

          ToastUtils.showSuccessToast(
            context,
            ref,
            _createLinkedEntry
                ? l10n.transactionLinkedAdded
                : l10n.transactionAdded,
            actionLabel: l10n.share,
            onActionPressed: (snackContext) {
              ShareHelper.shareTransaction(
                snackContext,
                ref,
                transactionWithDetails.transaction,
                transactionWithDetails.contact,
                transactionWithDetails.category,
                false, // isMarked
                currencyOverride: currency,
                userProfileOverride: userProfile,
                transactionServiceOverride: transactionService,
                whatsAppServiceOverride: whatsAppService,
                templateServiceOverride:
                    ref.read(messageTemplateServiceProvider),
                languageOverride: getCurrentLanguageCode(ref),
              );
            },
            color: activeColor,
          );
        }
      }

      // Increment usage count for free users
      if (!PremiumGate.isPremium(ref)) {
        await ref
            .read(usageTrackerRepositoryProvider)
            .incrementTransactionCount();
      }

      // Invalidate limits to refresh usage count
      ref.invalidate(transactionLimitsProvider);

      if (mounted) {
        if (!_isGroupSplit) {
          // Navigator.pop(context); // Already handled in detail dialog logic if needed
        }
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      debugPrint('Error saving transaction: $e');
      debugPrint('Stack trace: $stackTrace');
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
            final theme = Theme.of(context);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        label: Text(l10n.addNew),
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
                              Text(l10n.noCategoriesFound),
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
                                  label: Text(l10n.createCategoryNamed(
                                      widget.initialCategoryName!)),
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
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: theme.colorScheme.primary),
                                ),
                                alignment: Alignment.center,
                                child: Icon(Icons.add,
                                    color: theme.colorScheme.primary),
                              ),
                              title: Text(l10n.createCategoryNamed(
                                  widget.initialCategoryName!)),
                              subtitle: Text(l10n.tapToAddCategory),
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
                                      l10n.frequent,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (_selectedCategory?.uuid == category.uuid)
                                  Icon(Icons.check_circle, color: color),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                              Navigator.pop(context);
                            },
                            selected: _selectedCategory?.uuid == category.uuid,
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
            final theme = Theme.of(context);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      l10n.frequent,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (_selectedContactUuid == contact.uuid)
                                  Icon(Icons.check_circle,
                                      color: theme.colorScheme.primary),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context, contact);
                            },
                            selected: _selectedContactUuid == contact.uuid,
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

  Future<void> _handleRelationshipChange(String? value) async {
    if (_paidRelationship == value) {
      setState(() {
        _paidRelationship = null;
        _createLinkedEntry = false;
        _dueDate = null;
        _myShareAmount = null; // Reset My Share
      });
    } else {
      if (_selectedContact == null) {
        final contact = await _showContactPicker();
        if (contact != null) {
          setState(() {
            _paidRelationship = value;
            _createLinkedEntry = true;
            _selectedContact = contact;
            _selectedContactUuid = contact.uuid;
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

  void _showGroupSplitDialog() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final totalAmount = double.tryParse(_amountController.text) ?? 0.0;

    // Initialize shares if empty
    if (_groupShares.isEmpty) {
      _groupShares = [
        SplitShare(isUser: true, percentage: 100.0, amount: totalAmount),
      ];
      if (_selectedContact != null) {
        _groupShares[0].percentage = 50.0;
        _groupShares[0].amount = totalAmount / 2;
        _groupShares.add(SplitShare(
          contact: _selectedContact,
          percentage: 50.0,
          amount: totalAmount / 2,
        ));
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          double currentTotalPercent =
              _groupShares.fold(0, (sum, item) => sum + item.percentage);
          double currentTotalAmount =
              _groupShares.fold(0, (sum, item) => sum + item.amount);

          // Trigger recalculation of others
          void recalculateOthers(int changedIndex) {
            final lockedShares = _groupShares
                .asMap()
                .entries
                .where((e) => e.value.isLocked || e.key == changedIndex)
                .toList();
            final unlockedShares = _groupShares
                .asMap()
                .entries
                .where((e) => !e.value.isLocked && e.key != changedIndex)
                .toList();

            if (unlockedShares.isNotEmpty) {
              double usedPercent =
                  lockedShares.fold(0.0, (sum, e) => sum + e.value.percentage);
              double remainingPercent = 100.0 - usedPercent;
              if (remainingPercent < 0) remainingPercent = 0;

              double perSharePercent = remainingPercent / unlockedShares.length;
              for (final entry in unlockedShares) {
                entry.value.percentage = perSharePercent;
                entry.value.amount = (perSharePercent / 100) * totalAmount;
              }
            }
          }

          void recalculateShares(int changedIndex, {bool isPercent = true}) {
            final changedShare = _groupShares[changedIndex];
            if (isPercent) {
              changedShare.amount =
                  (changedShare.percentage / 100) * totalAmount;
            } else {
              changedShare.percentage =
                  (changedShare.amount / totalAmount) * 100;
            }
            recalculateOthers(changedIndex);
            setModalState(() {});
          }

          return Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.splitBill,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Distribute Equally Action
                          IconButton(
                            onPressed: () {
                              setModalState(() {
                                final unlockedShares = _groupShares
                                    .where((s) => !s.isLocked)
                                    .toList();
                                final lockedShares = _groupShares
                                    .where((s) => s.isLocked)
                                    .toList();

                                if (unlockedShares.isNotEmpty) {
                                  double lockedPercent = lockedShares.fold(
                                      0.0, (sum, s) => sum + s.percentage);
                                  double remainingPercent =
                                      100.0 - lockedPercent;
                                  if (remainingPercent < 0)
                                    remainingPercent = 0;

                                  double perSharePercent =
                                      remainingPercent / unlockedShares.length;
                                  for (var s in unlockedShares) {
                                    s.percentage = perSharePercent;
                                    s.amount =
                                        (perSharePercent / 100) * totalAmount;
                                  }
                                }
                              });
                            },
                            icon: const Icon(Icons.balance),
                            tooltip: l10n.distributeEqually,
                          ),
                          // Include Me Action
                          IconButton(
                            onPressed: () {
                              setModalState(() {
                                if (!_groupShares.any((s) => s.isUser)) {
                                  _groupShares.insert(
                                      0, SplitShare(isUser: true));
                                  recalculateShares(0);
                                } else {
                                  _groupShares.removeWhere((s) => s.isUser);
                                  if (_groupShares.isNotEmpty) {
                                    recalculateShares(0);
                                  }
                                }
                              });
                            },
                            icon: Icon(
                              _groupShares.any((s) => s.isUser)
                                  ? Icons.person
                                  : Icons.person_outline,
                              color: _groupShares.any((s) => s.isUser)
                                  ? theme.colorScheme.primary
                                  : theme.hintColor,
                            ),
                            tooltip: l10n.includeMe,
                          ),
                          // Add Contact Action
                          IconButton(
                            onPressed: () async {
                              final contact = await _showContactPicker();
                              if (contact != null) {
                                setModalState(() {
                                  if (!_groupShares.any(
                                      (s) => s.contact?.uuid == contact.uuid)) {
                                    _groupShares
                                        .add(SplitShare(contact: contact));
                                    recalculateShares(_groupShares.length - 1);
                                  }
                                });
                              }
                            },
                            icon: const Icon(Icons.person_add_outlined),
                            tooltip: l10n.addContact,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _groupShares.length,
                    itemBuilder: (context, index) {
                      final share = _groupShares[index];
                      final contactColor = share.isUser
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.primary;

                      return _SplitShareCard(
                        share: share,
                        index: index,
                        totalAmount: totalAmount,
                        contactColor: contactColor,
                        l10n: l10n,
                        currencySymbol: ref.read(currencySymbolProvider),
                        onChanged: () {
                          // Recalculate other shares
                          final lockedShares = _groupShares
                              .asMap()
                              .entries
                              .where((e) => e.value.isLocked || e.key == index)
                              .toList();
                          final unlockedShares = _groupShares
                              .asMap()
                              .entries
                              .where((e) => !e.value.isLocked && e.key != index)
                              .toList();

                          if (unlockedShares.isNotEmpty) {
                            double usedPercent = lockedShares.fold(
                                0.0, (sum, e) => sum + e.value.percentage);
                            double remainingPercent = 100.0 - usedPercent;
                            if (remainingPercent < 0) remainingPercent = 0;

                            double perSharePercent =
                                remainingPercent / unlockedShares.length;
                            for (final entry in unlockedShares) {
                              entry.value.percentage = perSharePercent;
                              entry.value.amount =
                                  (perSharePercent / 100) * totalAmount;
                            }
                          }
                          setModalState(() {});
                        },
                        onDelete: share.isUser
                            ? null
                            : () {
                                setModalState(() {
                                  _groupShares.removeAt(index);
                                  if (_groupShares.isNotEmpty) {
                                    // Recalculate first share to balance
                                    final lockedShares = _groupShares
                                        .where((s) => s.isLocked)
                                        .toList();
                                    final unlockedShares = _groupShares
                                        .where((s) => !s.isLocked)
                                        .toList();

                                    if (unlockedShares.isNotEmpty) {
                                      double usedPercent = lockedShares.fold(
                                          0.0, (sum, s) => sum + s.percentage);
                                      double remainingPercent =
                                          100.0 - usedPercent;
                                      if (remainingPercent < 0)
                                        remainingPercent = 0;

                                      double perSharePercent =
                                          remainingPercent /
                                              unlockedShares.length;
                                      for (final s in unlockedShares) {
                                        s.percentage = perSharePercent;
                                        s.amount = (perSharePercent / 100) *
                                            totalAmount;
                                      }
                                    }
                                  }
                                });
                              },
                        onLockToggle: () {
                          setModalState(() {
                            share.isLocked = !share.isLocked;
                          });
                        },
                        onSliderTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (ctx) => Container(
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(24)),
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${l10n.percentage} - ${share.isUser ? l10n.includeMe : (share.contact?.name ?? '')}',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => Navigator.pop(ctx),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  StatefulBuilder(
                                    builder: (context, setDialogState) =>
                                        Column(
                                      children: [
                                        Text(
                                          '${share.percentage.toStringAsFixed(1)}%',
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Slider(
                                          value: share.percentage,
                                          divisions: 1000,
                                          min: 0,
                                          max: 100,
                                          onChanged: (val) {
                                            setDialogState(() {
                                              share.percentage = val;
                                            });
                                            share.amount =
                                                (val / 100) * totalAmount;

                                            // Trigger recalculation of others
                                            final lockedShares = _groupShares
                                                .asMap()
                                                .entries
                                                .where((e) =>
                                                    e.value.isLocked ||
                                                    e.key == index)
                                                .toList();
                                            final unlockedShares = _groupShares
                                                .asMap()
                                                .entries
                                                .where((e) =>
                                                    !e.value.isLocked &&
                                                    e.key != index)
                                                .toList();

                                            if (unlockedShares.isNotEmpty) {
                                              double usedPercent =
                                                  lockedShares.fold(
                                                      0.0,
                                                      (sum, e) =>
                                                          sum +
                                                          e.value.percentage);
                                              double remainingPercent =
                                                  100.0 - usedPercent;
                                              if (remainingPercent < 0)
                                                remainingPercent = 0;

                                              double perSharePercent =
                                                  remainingPercent /
                                                      unlockedShares.length;
                                              for (final entry
                                                  in unlockedShares) {
                                                entry.value.percentage =
                                                    perSharePercent;
                                                entry.value.amount =
                                                    (perSharePercent / 100) *
                                                        totalAmount;
                                              }
                                            }
                                            setModalState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(l10n.confirm),
                                    ),
                                  ),
                                  SizedBox(
                                      height: MediaQuery.of(context)
                                          .padding
                                          .bottom),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.totalAmount,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${ref.read(currencySymbolProvider)} ${currentTotalAmount.toStringAsFixed(2)} / ${totalAmount.toStringAsFixed(2)}',
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
                      Row(
                        children: [
                          Expanded(
                            child: GradientButton(
                              label: l10n.confirm,
                              onPressed: (currentTotalPercent - 100).abs() < 0.1
                                  ? () {
                                      setState(() {
                                        _isGroupSplit = true;
                                      });
                                      Navigator.pop(context);
                                    }
                                  : null,
                              gradient: AppColors.primaryGradient,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isExpense = _selectedType == 'EXPENSE';
    final currencySymbol = ref.watch(currencySymbolProvider);

    // Watch limits
    final limitsAsync = ref.watch(transactionLimitsProvider);
    final scheduleLimitsAsync = ref.watch(scheduleLimitsProvider);

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
                      l10n.howMuch,
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
                          return l10n.pleaseEnterValidNumber;
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
                            l10n.category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedCategory?.name ?? l10n.selectCategory,
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
                    l10n.suggestedLabel(widget.initialCategoryName!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
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
                      _selectedContactUuid = contact.uuid;
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
                              _paidRelationship = null;
                              _createLinkedEntry = false;
                              _dueDate = null;
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
                        final String uuid = await contactsRepo.createContact(
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
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // Paid Relationship Section (Linked Transactions)
              if (_selectedType == 'EXPENSE') ...[
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

              // Split Bill Button
              if (_paidRelationship != null) ...[
                InkWell(
                  onTap: _showGroupSplitDialog,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isGroupSplit
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isGroupSplit
                            ? theme.colorScheme.primary
                            : theme.dividerColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isGroupSplit ? Icons.groups : Icons.call_split,
                          color: _isGroupSplit
                              ? theme.colorScheme.primary
                              : theme.hintColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.splitBill,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_isGroupSplit)
                                Text(
                                  '${_groupShares.length} ${l10n.contacts}',
                                  style: theme.textTheme.bodySmall,
                                )
                              else if (_myShareAmount != null)
                                Text(
                                  '${_isSplitMode ? l10n.split : l10n.add}: ${AmountFormatter.formatAmount(_myShareAmount!, 2)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: theme.hintColor,
                        ),
                      ],
                    ),
                  ),
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
                            Text(
                              _dueDate != null
                                  ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
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
                    label: _isLoading ? l10n.saving : l10n.save,
                    onPressed:
                        (_isLoading || _isDuplicate) ? null : _saveTransaction,
                    gradient: isExpense
                        ? AppColors.expenseGradient
                        : AppColors.incomeGradient,
                    isLoading: _isLoading,
                    icon: _isLoading ? null : Icons.check,
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
class _SplitShareCard extends StatefulWidget {
  final SplitShare share;
  final int index;
  final double totalAmount;
  final Color contactColor;
  final AppLocalizations l10n;
  final String currencySymbol;
  final VoidCallback onChanged;
  final VoidCallback? onDelete;
  final VoidCallback onLockToggle;
  final VoidCallback onSliderTap;

  const _SplitShareCard({
    required this.share,
    required this.index,
    required this.totalAmount,
    required this.contactColor,
    required this.l10n,
    required this.currencySymbol,
    required this.onChanged,
    this.onDelete,
    required this.onLockToggle,
    required this.onSliderTap,
  });

  @override
  State<_SplitShareCard> createState() => _SplitShareCardState();
}

class _SplitShareCardState extends State<_SplitShareCard> {
  late TextEditingController _pctController;
  late TextEditingController _amtController;
  late FocusNode _pctFocus;
  late FocusNode _amtFocus;

  @override
  void initState() {
    super.initState();
    _pctController =
        TextEditingController(text: widget.share.percentage.toStringAsFixed(1));
    _amtController =
        TextEditingController(text: widget.share.amount.toStringAsFixed(2));
    _pctFocus = FocusNode();
    _amtFocus = FocusNode();
  }

  @override
  void didUpdateWidget(_SplitShareCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers only if the value changed externally (e.g. slider or other share adjusted)
    // and we are not currently focused on this field.
    if (!_pctFocus.hasFocus) {
      final newText = widget.share.percentage.toStringAsFixed(1);
      if (_pctController.text != newText) {
        _pctController.text = newText;
      }
    }
    if (!_amtFocus.hasFocus) {
      final newText = widget.share.amount.toStringAsFixed(2);
      if (_amtController.text != newText) {
        _amtController.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _pctController.dispose();
    _amtController.dispose();
    _pctFocus.dispose();
    _amtFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget card = Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.share.isUser
            ? theme.colorScheme.primary.withValues(alpha: 0.05)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.share.isLocked
              ? theme.colorScheme.primary
              : (widget.share.isUser
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : theme.dividerColor),
          width: widget.share.isUser ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: widget.contactColor,
                child: Text(
                  widget.share.isUser
                      ? 'M'
                      : (widget.share.contact?.name[0] ?? '?'),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.share.isUser
                      ? widget.l10n.includeMe
                      : (widget.share.contact?.name ?? ''),
                  style: TextStyle(
                    fontWeight: widget.share.isUser
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color:
                        widget.share.isUser ? theme.colorScheme.primary : null,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  widget.share.isLocked ? Icons.lock : Icons.lock_open,
                  size: 20,
                  color: widget.share.isLocked
                      ? theme.colorScheme.primary
                      : theme.disabledColor,
                ),
                onPressed: widget.onLockToggle,
              ),
              IconButton(
                icon: const Icon(Icons.linear_scale, size: 20),
                onPressed: widget.onSliderTap,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: TextFormField(
                  controller: _pctController,
                  focusNode: _pctFocus,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '%',
                    suffixText: '%',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (val) {
                    final pct = double.tryParse(val) ?? 0.0;
                    widget.share.percentage = pct;
                    widget.share.amount = (pct / 100) * widget.totalAmount;
                    _amtController.text =
                        widget.share.amount.toStringAsFixed(2);
                    widget.onChanged();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _amtController,
                  focusNode: _amtFocus,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: widget.l10n.amount,
                    prefixText: '${widget.currencySymbol} ',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (val) {
                    final amt = double.tryParse(val) ?? 0.0;
                    widget.share.amount = amt;
                    widget.share.percentage = (amt / widget.totalAmount) * 100;
                    _pctController.text =
                        widget.share.percentage.toStringAsFixed(1);
                    widget.onChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (widget.share.isUser) return card;

    return Dismissible(
      key: ValueKey('dismiss_${widget.share.contact?.uuid ?? widget.index}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => widget.onDelete?.call(),
      child: card,
    );
  }
}

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
