import 'package:flowpaisa/features/tour/domain/tour_service.dart';
import 'package:flowpaisa/features/tour/presentation/providers/tour_provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:flowpaisa/core/services/in_app_review_service.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
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
import 'package:flowpaisa/features/contacts/data/contacts_repository.dart';
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
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_scenario_picker.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/schedule_service_provider.dart';
import 'package:flowpaisa/shared/widgets/amount_calculator_sheet.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/relationship_button.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/account_picker.dart';

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
  final DateTime? initialDueDate;
  final bool startTour;

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
    this.initialDueDate,
    this.startTour = false,
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
  final _amountFocusNode = FocusNode();
  bool _tourStarted = false;

  String _selectedType = 'EXPENSE';
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;
  bool _isLoading = false;
  bool _isDuplicate = false;

  // Selected entities
  Category? _selectedCategory;
  Contact? _selectedContact;
  String? _selectedCategoryUuid;

  // Linked transaction fields
  String? _selectedContactUuid;
  /// UI: `'PROCESSED'` = Processed selected; `null` = none (pending / no processedDate);
  /// otherwise `'PAID_FOR'|'PAID_BY'|'RECEIVED_FROM'|'WILL_RECEIVE'`.
  String? _paidRelationship = 'PROCESSED';
  bool _createLinkedEntry = false;

  // Account & processing state
  Account? _selectedAccount;

  /// Value persisted on the transaction (`'PROCESSED'` is never stored).
  String? get _paidRelationshipForDb =>
      _paidRelationship == 'PROCESSED' ? null : _paidRelationship;

  /// `true` → `processedDate` stays null on save.
  bool get _saveIsPending {
    final r = _paidRelationship;
    if (r == null) return true;
    if (r == 'PROCESSED') return false;
    return r == 'PAID_BY' || r == 'WILL_RECEIVE';
  }

  // More Options section
  bool _isMoreOptionsExpanded = false;

  // My Share fields
  double? _myShareAmount;
  bool _isSplitMode = true; // true = Split, false = Add

  // Group Split fields
  List<SplitShare> _groupShares = [];
  bool _isGroupSplit = false;

  void _onAmountChanged() => setState(() {});

  /// True when user opened Add Transaction without any initial data (no import, voice, receipt, etc.).
  bool get _isManualEntry =>
      widget.initialAmount == null &&
      widget.initialDate == null &&
      widget.initialDescription == null &&
      widget.initialType == null &&
      widget.initialRelationship == null &&
      widget.initialCategoryName == null &&
      widget.initialCategoryColor == null &&
      widget.initialCategoryIcon == null &&
      widget.initialContactName == null &&
      widget.initialContactPhone == null &&
      widget.initialExternalLinkId == null &&
      widget.initialDueDate == null;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
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
      // For Paid For and Paid By, we should only populate dueDate if it's explicitly provided
      // and NOT fallback to transaction date or current date, as those relationships
      // don't always imply a future due date like "Will Receive" does.
      _dueDate = widget.initialDueDate;
    } else if (widget.initialDueDate != null) {
      _dueDate = widget.initialDueDate;
    }

    // Handle initial contact and category in post-frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeEntities();
    });

    // Auto-show scenario picker when user opens Add Transaction manually and preference is on
    if (_isManualEntry) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final repo = ref.read(userPreferencesRepositoryProvider);
        final autoSuggest = await repo.getAutoSuggestTransactionScenario();
        if (!mounted) return;
        if (!autoSuggest) {
          // Wait for the route push animation to complete before requesting
          // focus, mirroring Flutter's own autofocus behaviour which also
          // defers until the route has settled.
          final animation = ModalRoute.of(context)?.animation;
          if (animation == null ||
              animation.status == AnimationStatus.completed) {
            _amountFocusNode.requestFocus();
          } else {
            late AnimationStatusListener onStatus;
            onStatus = (status) {
              if (status == AnimationStatus.completed) {
                animation.removeStatusListener(onStatus);
                if (mounted) _amountFocusNode.requestFocus();
              }
            };
            animation.addStatusListener(onStatus);
          }
          return;
        }
        await showTransactionScenarioPicker(context,
            onScenarioSelected: (type, relationship) {
          setState(() {
            _selectedType = type;
            _paidRelationship = relationship;
            _createLinkedEntry = relationship != null;
          });
        });
        if (!mounted) return;
        _amountFocusNode.requestFocus();
      });
    }
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
            _selectedCategoryUuid = category!.uuid;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
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

      // Calculate dueDateOffset if both dates are available
      int? dueDateOffset;
      if (_dueDate != null) {
        // Normalize dates to midnight for accurate day difference
        final txDate = DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day);
        final dDate = DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day);
        dueDateOffset = dDate.difference(txDate).inDays;
      }

      await scheduleService.createSchedule(
        amount: amount,
        type: _selectedType,
        description: description,
        categoryUuid: _selectedCategory?.uuid ?? _selectedCategoryUuid,
        contactUuid: _selectedContact?.uuid ?? _selectedContactUuid,
        accountUuid: _selectedAccount?.uuid,
        paidRelationship: _paidRelationship ?? 'PROCESSED',
        dueDate: _dueDate,
        dueDateOffset: dueDateOffset,
        scheduleType: result.scheduleType,
        selectedDaysOfWeek: result.selectedDaysOfWeek,
        selectedDaysOfMonth: result.selectedDaysOfMonth,
      );

      // Invalidate schedule limits
      ref.invalidate(scheduleLimitsProvider);

      if (mounted) {
        final capturedActiveColor = ref.read(activeCashbookProvider).color;

        Navigator.pop(context);

        ToastUtils.showSuccessToast(
          context,
          ref,
          l10n.scheduleCreated,
          color: capturedActiveColor,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error creating schedule: $e');
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

    // Show negative balance warning for CASH accounts (non-blocking)
    if (_selectedAccount != null && _selectedType == 'EXPENSE' && !_saveIsPending) {
      final accountsRepo = ref.read(accountsRepositoryProvider);
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final wouldBeNegative =
          await accountsRepo.wouldCauseNegativeBalance(_selectedAccount!, amount);
      if (wouldBeNegative && mounted) {
        ToastUtils.showWarningToast(context, ref, l10n.negativeBalanceWarning);
      }
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
          accountUuid: _selectedAccount?.uuid,
          paidRelationship: _paidRelationshipForDb,
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
          paidRelationship: _paidRelationshipForDb,
          createLinkedEntry: _createLinkedEntry,
          dueDate: _dueDate,
          externalLinkId: widget.initialExternalLinkId,
          myShareAmount: _myShareAmount,
          isSplitMode: _isSplitMode,
          isImport: widget.initialExternalLinkId != null,
          l10n: l10n,
          accountUuid: _selectedAccount?.uuid,
          isPending: _saveIsPending,
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

          final capturedTemplateService =
              ref.read(messageTemplateServiceProvider);
          final capturedLanguage = getCurrentLanguageCode(ref);
          final capturedContainer = ProviderScope.containerOf(context);

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
                null, // Pass null for ref to avoid unmounted check
                transactionWithDetails.transaction,
                transactionWithDetails.contact,
                transactionWithDetails.category,
                false, // isMarked
                currencyOverride: currency,
                userProfileOverride: userProfile,
                transactionServiceOverride: transactionService,
                whatsAppServiceOverride: whatsAppService,
                templateServiceOverride: capturedTemplateService,
                languageOverride: capturedLanguage,
                container: capturedContainer,
              );
            },
            color: activeColor,
          );
          ref.read(inAppReviewServiceProvider).maybeRequestReview();
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
                                  style: FilledButton.styleFrom(
                                      foregroundColor: Colors.white),
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
                                      LocalizationHelper.localizeCategory(
                                          context,
                                          widget.initialCategoryName!))),
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
                                  LocalizationHelper.localizeCategory(
                                      context, widget.initialCategoryName!))),
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
                            title: Text(
                                CategoryHelper.getCategoryName(category, l10n)),
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

  Future<Contact?> _showContactPicker({Set<String>? excludeContactUuids}) async {
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
                      final filtered = excludeContactUuids != null
                          ? contactsWithUsage
                              .where((item) =>
                                  !excludeContactUuids.contains(item.contact.uuid))
                              .toList()
                          : contactsWithUsage;
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
                                  fontSize: 16,
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

  /// Multi-select contact picker for split bill; returns list of selected contacts.
  Future<List<Contact>?> _showMultiContactPickerForSplit({
    required Set<String> excludeContactUuids,
  }) async {
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
            final theme = Theme.of(context);
            return _MultiContactPickerSheet(
              scrollController: scrollController,
              contactsAsync: contactsAsync,
              excludeContactUuids: excludeContactUuids,
              theme: theme,
              l10n: l10n,
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleRelationshipChange(String? value) async {
    // Processed card — UI sentinel `'PROCESSED'` (toggle off → `null`, processedDate null)
    if (value == 'PROCESSED') {
      setState(() {
        _paidRelationship =
            _paidRelationship == 'PROCESSED' ? null : 'PROCESSED';
        _createLinkedEntry = false;
        _dueDate = null;
        _myShareAmount = null;
      });
      return;
    }
    if (_paidRelationship == value) {
      // Tapping the active Receivable/Payable card deselects — no relationship
      setState(() {
        _paidRelationship = null;
        _createLinkedEntry = false;
        _dueDate = null;
        _myShareAmount = null;
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
          });
        }
      } else {
        setState(() {
          _paidRelationship = value;
          _createLinkedEntry = true;
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
          final isRtl = Directionality.of(context) == TextDirection.rtl;
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
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  MediaQuery.of(context).padding.bottom,
            ),
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
                            tooltip: l10n.me,
                          ),
                          // Add Contact Action (multi-select)
                          IconButton(
                            onPressed: () async {
                              final excludeUuids = _groupShares
                                  .where((s) => s.contact != null)
                                  .map((s) => s.contact!.uuid)
                                  .toSet();
                              final contacts = await _showMultiContactPickerForSplit(
                                  excludeContactUuids: excludeUuids);
                              if (contacts != null && contacts.isNotEmpty) {
                                setModalState(() {
                                  for (final contact in contacts) {
                                    _groupShares.add(SplitShare(contact: contact));
                                  }
                                  recalculateShares(_groupShares.length - 1);
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
                          : (share.contact?.name != null
                              ? AppColors.getContactColor(share.contact!.name)
                              : theme.colorScheme.primary);

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
                              padding: EdgeInsets.fromLTRB(
                                24,
                                24,
                                24,
                                MediaQuery.of(context).viewInsets.bottom +
                                    MediaQuery.of(context).padding.bottom +
                                    24,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${l10n.percentage} - ${share.isUser ? l10n.me : (share.contact?.name ?? '')}',
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
                            isRtl
                                ? '${currentTotalAmount.toStringAsFixed(2)} / ${totalAmount.toStringAsFixed(2)} ${ref.read(currencySymbolProvider)}'
                                : '${ref.read(currencySymbolProvider)} ${currentTotalAmount.toStringAsFixed(2)} / ${totalAmount.toStringAsFixed(2)}',
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
    final decimalPlaces = ref.watch(currencyDecimalPlacesProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // Watch limits
    final limitsAsync = ref.watch(transactionLimitsProvider);
    final scheduleLimitsAsync = ref.watch(scheduleLimitsProvider);

    return ShowCaseWidget(
      enableAutoScroll: true,
      onFinish: () {
        // Mark add transaction tour as completed
        final tourNotifier = ref.read(tourNotifierProvider);
        tourNotifier.markTourCompleted(tourNotifier.addTransactionKey);
      },
      builder: (context) {
        // Start tour if requested and we haven't started it yet
        if (widget.startTour && !_tourStarted) {
          _tourStarted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              try {
                final showcaseState = ShowCaseWidget.of(context);
                showcaseState.startShowCase(TourService.addTransactionTourKeys);
              } catch (e) {
                debugPrint('Error starting add transaction tour: $e');
              }
            }
          });
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.addTransaction),
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
                      _createLinkedEntry = relationship != null;
                    });
                  });
                },
              ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Schedule button — icon only
                if (!_isGroupSplit) ...[
                  FloatingActionButton.small(
                    heroTag: 'schedule_fab',
                    tooltip: l10n.schedule,
                    backgroundColor:
                        isExpense ? AppColors.expenseColor : AppColors.incomeColor,
                    foregroundColor: Colors.white,
                    onPressed: (_isLoading ||
                            (scheduleLimitsAsync.asData?.value != null &&
                                !scheduleLimitsAsync.asData!.value.canAdd))
                        ? null
                        : _scheduleTransaction,
                    child: (scheduleLimitsAsync.asData?.value != null &&
                            !scheduleLimitsAsync.asData!.value.canAdd)
                        ? const Icon(Icons.lock)
                        : const Icon(Icons.schedule),
                  ),
                  const SizedBox(height: 8),
                ],
                // Save chip
                Showcase(
                  key: TourService.addTxSaveKey,
                  title: l10n.tourAddTxSaveTitle,
                  description: l10n.tourAddTxSaveDesc,
                  targetShapeBorder: const StadiumBorder(),
                  tooltipBackgroundColor:
                      isExpense ? AppColors.expenseColor : AppColors.incomeColor,
                  textColor: Colors.white,
                  tooltipPosition: TooltipPosition.top,
                  child: _FabChip(
                    label: _isLoading ? l10n.saving : l10n.save,
                    icon: _isLoading
                        ? null
                        : (_isDuplicate ||
                                (limitsAsync.asData?.value != null &&
                                    !limitsAsync.asData!.value.canAdd))
                            ? Icons.lock
                            : Icons.check,
                    isLoading: _isLoading,
                    color: isExpense ? AppColors.expenseColor : AppColors.incomeColor,
                    onPressed: (_isLoading || _isDuplicate) ? null : _saveTransaction,
                  ),
                ),
              ],
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
                key: const Key('add_transaction_list_view'),
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                ),
                children: [
                  // Amount Input (Large & Prominent)
                  Showcase(
                    key: TourService.addTxAmountKey,
                    title: l10n.tourAddTxAmountTitle,
                    description: l10n.tourAddTxAmountDesc,
                    targetShapeBorder: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    tooltipBackgroundColor: isExpense
                        ? AppColors.expenseColor
                        : AppColors.incomeColor,
                    textColor: Colors.white,
                    child: Container(
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
                      child: Stack(
                        children: [
                          // Amount field + label
                          Column(
                            children: [
                              Text(
                                l10n.howMuch,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _amountController,
                                focusNode: _amountFocusNode,
                                autofocus: false,
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
                                  prefixStyle:
                                      theme.textTheme.displayMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  suffixStyle:
                                      theme.textTheme.displayMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  border: InputBorder.none,
                                  hintText: l10n.amountHint,
                                  hintStyle: theme.textTheme.displayLarge?.copyWith(
                                    color: Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
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
                          // Calculator icon stacked at top-right corner
                          if ((double.tryParse(_amountController.text) ?? 0) > 0)
                            Positioned(
                              top: -8,
                              right: 0,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 28, minHeight: 28),
                                onPressed: () async {
                                  final amount = double.tryParse(
                                          _amountController.text) ??
                                      0.0;
                                  await AmountCalculatorSheet.show(
                                    context,
                                    initialAmount: amount,
                                    currencySymbol: currencySymbol,
                                    decimalPlaces: decimalPlaces,
                                    onDone: (result) {
                                      setState(() {
                                        _amountController.text =
                                            result.toStringAsFixed(
                                                decimalPlaces);
                                      });
                                    },
                                  );
                                },
                                icon: Icon(
                                  Symbols.calculate,
                                  size: 20,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                tooltip: l10n.amountCalculatorButtonTooltip,
                              ),
                            ),
                        ],
                      ),
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
                              _paidRelationship = 'PROCESSED';
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
                              _paidRelationship = 'PROCESSED';
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
                  Showcase(
                    key: TourService.addTxCategoryKey,
                    title: l10n.tourAddTxCategoryTitle,
                    description: l10n.tourAddTxCategoryDesc,
                    targetShapeBorder: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    tooltipBackgroundColor: isExpense
                        ? AppColors.expenseColor
                        : AppColors.incomeColor,
                    textColor: Colors.white,
                    child: InkWell(
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
                                        color: Color(int.parse(
                                                _selectedCategory!.color!
                                                    .replaceAll('#', '0xFF')))
                                            .withValues(alpha: 0.3),
                                      )
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                IconHelper.getIconData(
                                        _selectedCategory?.icon) ??
                                    Symbols.category,
                                color: _selectedCategory?.color != null
                                    ? Color(int.parse(_selectedCategory!.color!
                                        .replaceAll('#', '0xFF')))
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
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
                  ),
                  if (widget.initialCategoryName != null &&
                      _selectedCategory == null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text(
                        l10n.suggestedLabel(LocalizationHelper.localizeCategory(
                            context, widget.initialCategoryName!)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Contact Selector (Optional)
                  Showcase(
                    key: TourService.addTxContactKey,
                    title: l10n.tourAddTxContactTitle,
                    description: l10n.tourAddTxContactDesc,
                    targetShapeBorder: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    tooltipBackgroundColor: isExpense
                        ? AppColors.expenseColor
                        : AppColors.incomeColor,
                    textColor: Colors.white,
                    child: InkWell(
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
                                    _paidRelationship = 'PROCESSED';
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
                  ),
                  if (widget.initialContactName != null &&
                      _selectedContact == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final contactsRepo =
                                ref.read(contactsRepositoryProvider);
                            final String uuid =
                                await contactsRepo.createContact(
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
                  const SizedBox(height: 16),

                  // Account picker (shown when user has accounts)
                  if (ref.watch(hasAccountsProvider)) ...[
                    AccountPickerField(
                      selectedAccount: _selectedAccount,
                      excludeCreditCard: _selectedType == 'INCOME' &&
                          _selectedCategory?.uuid != 'default_cat_refund',
                      onChanged: (acc) =>
                          setState(() => _selectedAccount = acc),
                    ),
                    const SizedBox(height: 16),
                  ],

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
                  const SizedBox(height: 16),

                  // Date Selector
                  Showcase(
                    key: TourService.addTxDateKey,
                    title: l10n.tourAddTxDateTitle,
                    description: l10n.tourAddTxDateDesc,
                    targetShapeBorder: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    tooltipBackgroundColor: isExpense
                        ? AppColors.expenseColor
                        : AppColors.incomeColor,
                    textColor: Colors.white,
                    child: InkWell(
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
                  ),
                  const SizedBox(height: 16),

                  // More Options (collapsible — relationship cards, due date, split)
                  TxMoreOptionsSection(
                    isExpanded: _isMoreOptionsExpanded,
                    onToggle: () => setState(
                        () => _isMoreOptionsExpanded = !_isMoreOptionsExpanded),
                    selectedType: _selectedType,
                    paidRelationship: _paidRelationship,
                    onRelationshipChange: _handleRelationshipChange,
                    dueDate: _dueDate,
                    selectedDate: _selectedDate,
                    onDueDateTap: () async {
                      await showModalBottomSheet(
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
                                      style: const TextStyle(
                                          color: Colors.red)),
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
                    isGroupSplit: _isGroupSplit,
                    groupSharesCount: _groupShares.length,
                    myShareAmount: _myShareAmount,
                    isSplitMode: _isSplitMode,
                    onSplitTap: _showGroupSplitDialog,
                    onClearSplit: () => setState(() {
                      _isGroupSplit = false;
                      _groupShares = [];
                    }),
                    showSplitButton: widget.initialExternalLinkId == null,
                  ),

                  // Countdown badge
                  if (limitsAsync.asData?.value != null &&
                      !limitsAsync.asData!.value.isUnlimited &&
                      limitsAsync.asData!.value.canAdd)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
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

                  // Bottom padding for FABs
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
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
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    Widget card = Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.share.isUser
            ? theme.colorScheme.primary.withValues(alpha: 0.05)
            : widget.contactColor.withValues(alpha: 0.1),
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
                backgroundColor: widget.contactColor.withValues(alpha: 0.3),
                child: widget.share.isUser
                    ? Icon(Icons.person, size: 18, color: widget.contactColor)
                    : Text(
                        (widget.share.contact?.name[0] ?? '?').toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.share.isUser
                      ? widget.l10n.me
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
                    prefixText: isRtl ? '%' : null,
                    suffixText: isRtl ? null : '%',
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
                    prefixText: isRtl ? null : '${widget.currencySymbol} ',
                    suffixText: isRtl ? ' ${widget.currencySymbol}' : null,
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
        alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
        padding: isRtl
            ? const EdgeInsets.only(left: 20)
            : const EdgeInsets.only(right: 20),
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

/// Compact chip-style floating action button showing icon + label.
class _FabChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _FabChip({
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

/// Collapsible "More Options" section with relationship cards, due date, and split.
class TxMoreOptionsSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final String selectedType;
  final String? paidRelationship;
  final Future<void> Function(String?) onRelationshipChange;
  final DateTime? dueDate;
  final DateTime selectedDate;
  final Future<void> Function() onDueDateTap;
  final VoidCallback onClearDueDate;
  final bool isGroupSplit;
  final int groupSharesCount;
  final double? myShareAmount;
  final bool isSplitMode;
  final VoidCallback onSplitTap;
  final VoidCallback onClearSplit;
  final bool showSplitButton;

  const TxMoreOptionsSection({
    required this.isExpanded,
    required this.onToggle,
    required this.selectedType,
    required this.paidRelationship,
    required this.onRelationshipChange,
    required this.dueDate,
    required this.selectedDate,
    required this.onDueDateTap,
    required this.onClearDueDate,
    required this.isGroupSplit,
    required this.groupSharesCount,
    required this.myShareAmount,
    required this.isSplitMode,
    required this.onSplitTap,
    required this.onClearSplit,
    required this.showSplitButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isExpense = selectedType == 'EXPENSE';

    return Column(
      children: [
        // Header toggle row
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isExpanded
                  ? (isExpense
                      ? AppColors.expenseColor.withValues(alpha: 0.08)
                      : AppColors.incomeColor.withValues(alpha: 0.08))
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isExpanded
                    ? (isExpense ? AppColors.expenseColor : AppColors.incomeColor)
                        .withValues(alpha: 0.4)
                    : theme.dividerColor,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tune,
                  size: 20,
                  color: isExpanded
                      ? (isExpense ? AppColors.expenseColor : AppColors.incomeColor)
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.moreOptions,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isExpanded
                          ? (isExpense ? AppColors.expenseColor : AppColors.incomeColor)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (paidRelationship != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isExpense ? AppColors.expenseColor : AppColors.incomeColor)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _relationshipLabel(
                        paidRelationship!,
                        l10n,
                        isExpense,
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isExpense ? AppColors.expenseColor : AppColors.incomeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: isExpanded ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expanded content
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Three relationship cards — combined group
                if (isExpense) ...[
                  RelationshipButtonGroup(
                    top: RelationshipButtonData(
                      label: l10n.markAsPaid,
                      subtitle: l10n.processedImmediately,
                      icon: Icons.check_circle_outline,
                      isSelected: paidRelationship == 'PROCESSED',
                      gradient: LinearGradient(colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.8),
                        theme.colorScheme.primary,
                      ]),
                      color: theme.colorScheme.primary,
                      foreColor: theme.colorScheme.onPrimary,
                      onTap: () => onRelationshipChange('PROCESSED'),
                    ),
                    middle: RelationshipButtonData(
                      label: l10n.receivable,
                      subtitle: l10n.paidForSubtitle,
                      icon: Icons.account_balance_wallet,
                      isSelected: paidRelationship == 'PAID_FOR',
                      gradient: AppColors.receivableGradient,
                      color: AppColors.receivableColor,
                      onTap: () => onRelationshipChange('PAID_FOR'),
                    ),
                    bottom: RelationshipButtonData(
                      label: l10n.payable,
                      subtitle: l10n.paidBySubtitle,
                      icon: Icons.person_outline,
                      isSelected: paidRelationship == 'PAID_BY',
                      gradient: AppColors.payableGradient,
                      color: AppColors.payableColor,
                      onTap: () => onRelationshipChange('PAID_BY'),
                    ),
                  ),
                ] else ...[
                  RelationshipButtonGroup(
                    top: RelationshipButtonData(
                      label: l10n.markAsReceived,
                      subtitle: l10n.receivedImmediately,
                      icon: Icons.check_circle_outline,
                      isSelected: paidRelationship == 'PROCESSED',
                      gradient: LinearGradient(colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.8),
                        theme.colorScheme.primary,
                      ]),
                      color: theme.colorScheme.primary,
                      foreColor: theme.colorScheme.onPrimary,
                      onTap: () => onRelationshipChange('PROCESSED'),
                    ),
                    middle: RelationshipButtonData(
                      label: l10n.receivable,
                      subtitle: l10n.willReceiveSubtitle,
                      icon: Icons.schedule,
                      isSelected: paidRelationship == 'WILL_RECEIVE',
                      gradient: AppColors.receivableGradient,
                      color: AppColors.receivableColor,
                      onTap: () => onRelationshipChange('WILL_RECEIVE'),
                    ),
                    bottom: RelationshipButtonData(
                      label: l10n.payable,
                      subtitle: l10n.receivedFromSubtitle,
                      icon: Icons.download,
                      isSelected: paidRelationship == 'RECEIVED_FROM',
                      gradient: AppColors.payableGradient,
                      color: AppColors.payableColor,
                      onTap: () => onRelationshipChange('RECEIVED_FROM'),
                    ),
                  ),
                ],

                // Due Date (Receivable / Payable only — not Processed)
                if (paidRelationship != null &&
                    paidRelationship != 'PROCESSED') ...[
                  const SizedBox(height: 12),
                  TxDueDateRow(
                    paidRelationship: paidRelationship,
                    dueDate: dueDate,
                    selectedDate: selectedDate,
                    onTap: onDueDateTap,
                    onClear: onClearDueDate,
                  ),
                ],

                // Split Bill (only if contact relationship and button enabled)
                if (paidRelationship != null &&
                    paidRelationship != 'PROCESSED' &&
                    showSplitButton) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: onSplitTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isGroupSplit
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isGroupSplit
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isGroupSplit ? Icons.groups : Icons.splitscreen,
                            color: isGroupSplit
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
                                if (isGroupSplit)
                                  Text(
                                    '$groupSharesCount ${l10n.contacts}',
                                    style: theme.textTheme.bodySmall,
                                  )
                                else if (myShareAmount != null)
                                  Text(
                                    '${isSplitMode ? l10n.split : l10n.add}: ${AmountFormatter.formatAmount(myShareAmount!, 2)}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          if (isGroupSplit)
                            GestureDetector(
                              onTap: onClearSplit,
                              child: Icon(Icons.close, color: theme.hintColor, size: 20),
                            )
                          else
                            Icon(Icons.chevron_right, color: theme.hintColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _relationshipLabel(
    String rel,
    AppLocalizations l10n,
    bool isExpense,
  ) {
    switch (rel) {
      case 'PROCESSED':
        return isExpense ? l10n.markAsPaid : l10n.markAsReceived;
      case 'PAID_FOR':
      case 'WILL_RECEIVE':
        return l10n.receivable;
      case 'PAID_BY':
      case 'RECEIVED_FROM':
        return l10n.payable;
      default:
        return rel;
    }
  }
}

class TxDueDateRow extends StatelessWidget {
  final String? paidRelationship;
  final DateTime? dueDate;
  final DateTime selectedDate;
  final Future<void> Function() onTap;
  final VoidCallback onClear;

  const TxDueDateRow({
    required this.paidRelationship,
    required this.dueDate,
    required this.selectedDate,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    String dateStr = l10n.notSet;
    String? relativeStr;

    if (dueDate != null) {
      dateStr = '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
      final txDate =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final dDate = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
      final offset = dDate.difference(txDate).inDays;
      if (offset == 0) {
        relativeStr = l10n.sameDay;
      } else if (offset > 0) {
        relativeStr = l10n.inDays(offset);
      } else {
        relativeStr = l10n.daysAgoRelative(offset.abs());
      }
    }

    return InkWell(
      onTap: onTap,
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
                gradient: paidRelationship == 'PAID_FOR' ||
                        paidRelationship == 'WILL_RECEIVE'
                    ? AppColors.receivableGradient
                    : AppColors.payableGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.event_available,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
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
                    dateStr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (relativeStr != null)
                    Text(
                      relativeStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (dueDate != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.clear, size: 20),
              ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

class _MultiContactPickerSheet extends StatefulWidget {
  final ScrollController scrollController;
  final AsyncValue<List<ContactWithUsage>> contactsAsync;
  final Set<String> excludeContactUuids;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _MultiContactPickerSheet({
    required this.scrollController,
    required this.contactsAsync,
    required this.excludeContactUuids,
    required this.theme,
    required this.l10n,
  });

  @override
  State<_MultiContactPickerSheet> createState() =>
      _MultiContactPickerSheetState();
}

class _MultiContactPickerSheetState extends State<_MultiContactPickerSheet> {
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
                                    fontSize: 16,
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

