import 'package:flowpaisa/features/messages/presentation/providers/message_template_provider.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/whatsapp/presentation/providers/whatsapp_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/core/utils/share_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/shared/widgets/amount_snap_bar.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/categories/domain/category_monthly_hint_key.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/payables/data/payables_repository.dart';
import 'package:flowpaisa/features/receivables/data/receivables_repository.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/features/categories/presentation/screens/add_category_screen.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/add_contact_screen.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/core/services/in_app_review_service.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/shared/widgets/dual_amount_progress_bar.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/schedule_selection_drawer.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/schedule_service_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/edit_split_transaction_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_scenario_picker.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_attachment_section.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:flowpaisa/features/transactions/presentation/widgets/split_bill_multi_contact_picker_sheet.dart';
import 'package:flowpaisa/shared/widgets/amount_calculator_sheet.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/tabular_parser.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/tabular_editor_sheet.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/account_picker.dart';
import 'package:flowpaisa/shared/widgets/voice_input_button.dart';
import 'add_transaction_screen.dart' show TxMoreOptionsSection;

class EditTransactionScreen extends ConsumerStatefulWidget {
  final Transaction transaction;
  final Category? category;
  final Contact? contact;
  final Account? account;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
    this.category,
    this.contact,
    this.account,
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
  final _descriptionFocusNode = FocusNode();

  String _selectedType = 'EXPENSE';
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;
  bool _isLoading = false;

  Category? _selectedCategory;
  Contact? _selectedContact;
  String? _selectedContactUuid;

  /// UI: `'PROCESSED'` = Processed; `null` = none (clears processedDate on save).
  String? _paidRelationship;
  bool _isMoreOptionsExpanded = false;
  Account? _selectedAccount;

  String? get _paidRelationshipForDb =>
      _paidRelationship == 'PROCESSED' ? null : _paidRelationship;

  /// `true` → processedDate cleared on save.
  bool get _saveIsPending {
    final r = _paidRelationship;
    if (r == null) return true;
    if (r == 'PROCESSED') return false;
    return r == 'PAID_BY' || r == 'WILL_RECEIVE';
  }

  List<SplitShare> _groupShares = [];
  bool _isGroupSplit = false;
  List<AttachmentItem> _attachments = [];
  final List<String> _pendingDeletions = [];

  // Tabular Description fields
  bool _isTabularMode = false;
  List<TabularRow> _tabularRows = [];
  String _tabularSummary = '';

  void _onAmountChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    // Initialize with existing transaction data
    _amountController.text = widget.transaction.amount.toStringAsFixed(2);
    if (TabularParser.isTabular(widget.transaction.description)) {
      final (summary, rows) =
          TabularParser.parse(widget.transaction.description);
      _isTabularMode = true;
      _tabularSummary = summary;
      _tabularRows = rows;
      _descriptionController.text = summary;
    } else {
      _descriptionController.text = widget.transaction.description ?? '';
    }
    _selectedType = widget.transaction.type;
    _selectedDate = widget.transaction.date;
    _selectedCategory = widget.category;
    _selectedContact = widget.contact;
    _selectedContactUuid = widget.transaction.contactUuid;
    _selectedAccount = widget.account;
    final t = widget.transaction;
    if (t.paidRelationship != null) {
      _paidRelationship = t.paidRelationship;
    } else if (t.processedDate != null) {
      _paidRelationship = 'PROCESSED';
    } else {
      _paidRelationship = null;
    }

    // Fetch due date from linked payable/receivable if exists
    _loadLinkedEntryDueDate();
    _loadAttachments();
  }

  Future<void> _loadAttachments() async {
    final docRepo = ref.read(transactionDocumentsRepositoryProvider);
    final docs = await docRepo.getDocumentsForTransaction(widget.transaction.uuid);
    final docDir = await docRepo.getDocumentsDirectory();
    if (mounted) {
      setState(() {
        _attachments = docs.map<AttachmentItem>((doc) => AttachmentItem(
          uuid: doc.uuid,
          file: File(p.join(docDir.path, doc.fileName)),
          originalName: doc.originalName,
          mimeType: doc.mimeType ?? 'application/octet-stream',
          fileSize: doc.fileSize,
        )).toList();
      });
    }
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
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
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
        accountUuid: _selectedAccount?.uuid,
        paidRelationship: _paidRelationship,
        dueDate: _dueDate,
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
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
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

  Future<void> _updateTransaction() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate contact for linked transactions
    if (_paidRelationship != null &&
        _paidRelationship != 'PROCESSED' &&
        _selectedContact == null) {
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
      String? description = _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text;

      if (_isTabularMode && _tabularRows.isNotEmpty) {
        description = TabularParser.serialize(
            _descriptionController.text, _tabularRows);
      }

      if (_isGroupSplit && _groupShares.isNotEmpty) {
        // Handle group split update
        await service.createGroupSplit(
          totalAmount: amount,
          type: _selectedType,
          date: _selectedDate,
          description: description,
          categoryUuid: _selectedCategory?.uuid,
          paidRelationship: _paidRelationshipForDb,
          dueDate: _dueDate,
          shares: _groupShares,
        );
        // Delete the original single transaction since it's now replaced by a group
        await service.deleteTransaction(widget.transaction.uuid);
      } else {
        // Standard update
        await service.updateTransaction(
          transactionUuid: widget.transaction.uuid,
          amount: amount,
          type: _selectedType,
          date: _selectedDate,
          description: description,
          contactUuid: _selectedContactUuid,
          categoryUuid: _selectedCategory?.uuid,
          accountUuid: _selectedAccount?.uuid,
          paidRelationship: _paidRelationshipForDb,
          dueDate: _dueDate,
          isPending: _saveIsPending,
        );

        // Process document deletions and additions
        final docRepo = ref.read(transactionDocumentsRepositoryProvider);
        for (final docUuid in _pendingDeletions) {
          await docRepo.deleteDocument(docUuid);
        }
        for (final att in _attachments) {
          if (att.uuid == null) {
            await docRepo.addDocument(
              transactionUuid: widget.transaction.uuid,
              file: att.file,
              originalName: att.originalName,
              mimeType: att.mimeType,
            );
          }
        }
      }

      if (mounted) {
        final capturedTemplateService =
            ref.read(messageTemplateServiceProvider);
        final capturedLanguage = getCurrentLanguageCode(ref);
        final capturedContainer = ProviderScope.containerOf(context);
        final capturedCurrency = ref.read(currentCurrencyProvider).value!;
        final capturedUserProfile = ref.read(userProfileProvider);
        final capturedWhatsAppService = ref.read(whatsAppServiceProvider);
        final capturedTransactionService = ref.read(transactionServiceProvider);
        final capturedActiveColor = ref.read(activeCashbookProvider).color;

        Navigator.pop(context, true); // Return true to indicate success

        // Fetch updated transaction details for the toast action
        final repository = ref.read(transactionsRepositoryProvider);
        final transactionWithDetails = await repository
            .getTransactionWithDetailsByUuid(widget.transaction.uuid);

        if (transactionWithDetails != null) {
          ToastUtils.showSuccessToast(
            context,
            ref,
            l10n.transactionUpdated,
            actionLabel: l10n.share,
            onActionPressed: (snackContext) {
              ShareHelper.shareTransaction(
                snackContext,
                null,
                transactionWithDetails.transaction,
                transactionWithDetails.contact,
                transactionWithDetails.category,
                false,
                currencyOverride: capturedCurrency,
                userProfileOverride: capturedUserProfile,
                transactionServiceOverride: capturedTransactionService,
                whatsAppServiceOverride: capturedWhatsAppService,
                templateServiceOverride: capturedTemplateService,
                languageOverride: capturedLanguage,
                container: capturedContainer,
              );
            },
            color: capturedActiveColor,
          );
        } else {
          ToastUtils.showSuccessToast(context, ref, l10n.transactionUpdated);
        }
        ref.read(inAppReviewServiceProvider).maybeRequestReview();
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Calculate relative days if _dueDate is set
    String? relativeText;
    if (_dueDate != null) {
      final txDate =
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
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
        _showContactPicker();
      }
      setState(() => _paidRelationship = value);
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
                            title: Text(
                                CategoryHelper.getCategoryName(category, l10n)),
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
                          // Add Contact Action (multi-select, same as splitted bill screen)
                          IconButton(
                            onPressed: () async {
                              final excludeUuids = _groupShares
                                  .where((s) => s.contact != null)
                                  .map((s) => s.contact!.uuid)
                                  .toSet();
                              final contacts =
                                  await showSplitBillMultiContactPicker(
                                context,
                                excludeContactUuids: excludeUuids,
                              );
                              if (contacts == null || contacts.isEmpty) return;
                              setModalState(() {
                                for (final contact in contacts) {
                                  _groupShares
                                      .add(SplitShare(contact: contact));
                                }
                                recalculateShares(_groupShares.length - 1);
                              });
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
                                          min: 0,
                                          max: 100,
                                          divisions: 1000,
                                          onChanged: (val) {
                                            setDialogState(() {
                                              share.percentage = val;
                                              share.amount =
                                                  (val / 100) * totalAmount;
                                            });
                                            setModalState(() {
                                              recalculateOthers(index);
                                            });
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
                                      child: Text(l10n.confirm),
                                    ),
                                  ),
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
                      SizedBox(
                        width: double.infinity,
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
                          gradient: theme.brightness == Brightness.dark
                              ? AppColors.primaryGradient
                              : AppColors.getSecondaryGradient(
                                  theme.colorScheme.primary),
                          foreColor: Colors.white,
                        ),
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
    final scheduleLimitsAsync = ref.watch(scheduleLimitsProvider);
    final isSplitted = widget.transaction.linkedGroupId != null &&
        widget.transaction.linkedGroupId!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editTransaction),
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
          if (isSplitted)
            TextButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditSplitTransactionScreen(
                      transactionUuid: widget.transaction.uuid,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.splitscreen),
              label: Text(l10n.splittedBill),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!_isGroupSplit) ...[
              FloatingActionButton.small(
                heroTag: 'edit_schedule_fab',
                tooltip: l10n.schedule,
                backgroundColor:
                    isExpense ? AppColors.expenseColor : AppColors.incomeColor,
                foregroundColor: Colors.white,
                onPressed: _isLoading
                    ? null
                    : (scheduleLimitsAsync.asData?.value != null &&
                            !scheduleLimitsAsync.asData!.value.canAdd)
                        ? () => PremiumGate.showPremiumDialog(context)
                        : _scheduleTransaction,
                child: const Icon(Icons.schedule),
              ),
              const SizedBox(height: 8),
            ],
            _EditFabChip(
              label: _isLoading ? l10n.updating : l10n.updateTransaction,
              icon: _isLoading ? null : Icons.check,
              isLoading: _isLoading,
              color: isExpense ? AppColors.expenseColor : AppColors.incomeColor,
              onPressed: _isLoading ? null : _updateTransaction,
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
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
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
                child: Stack(
                  children: [
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
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isExpense
                                ? AppColors.expenseColor
                                : AppColors.incomeColor,
                          ),
                          decoration: InputDecoration(
                            prefixText:
                                Directionality.of(context) == TextDirection.rtl
                                    ? null
                                    : '$currencySymbol ',
                            suffixText:
                                Directionality.of(context) == TextDirection.rtl
                                    ? ' $currencySymbol'
                                    : null,
                            prefixStyle:
                                theme.textTheme.displayMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            suffixStyle:
                                theme.textTheme.displayMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            border: InputBorder.none,
                            hintText: '0.00',
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
                        AmountSnapBar(
                          controller: _amountController,
                          currencySymbol: currencySymbol,
                        ),
                      ],
                    ),
                    if ((double.tryParse(_amountController.text) ?? 0) > 0)
                      Positioned(
                        top: -8,
                        right: 0,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(minWidth: 28, minHeight: 28),
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
                      onTap: isSplitted
                          ? () {}
                          : () {
                              setState(() {
                                _selectedType = 'EXPENSE';
                                // Reset relationship when type changes
                                _paidRelationship = 'PROCESSED';
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
                      onTap: isSplitted
                          ? () {}
                          : () {
                              setState(() {
                                _selectedType = 'INCOME';
                                // Reset relationship when type changes
                                _paidRelationship = 'PROCESSED';
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
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
                                  ? IconHelper.getIconData(
                                      _selectedCategory!.icon)
                                  : Symbols.category,
                              color: _selectedCategory?.color != null
                                  ? Color(int.parse(_selectedCategory!.color!
                                      .replaceAll('#', '0xFF')))
                                  : null,
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
                          ),
                          if (_selectedCategory != null)
                            IconButton(
                              icon: Icon(Icons.close,
                                  size: 20,
                                  color: _selectedCategory?.color != null
                                      ? Color(int.parse(_selectedCategory!
                                          .color!
                                          .replaceAll('#', '0xFF')))
                                      : theme.colorScheme.primary),
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = null;
                                });
                              },
                            )
                          else
                            const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          final hintAsync = ref.watch(
                            categoryMonthlyBudgetHintProvider(
                              CategoryMonthlyHintKey(
                                _selectedCategory?.uuid,
                                _selectedDate,
                              ),
                            ),
                          );
                          final sym = ref.watch(currencySymbolProvider);
                          final dec = ref.watch(currencyDecimalPlacesProvider);

                          return hintAsync.when(
                            data: (snap) {
                              if (snap == null) {
                                return const SizedBox.shrink();
                              }

                              final isPremium =
                                  ref.watch(premiumProvider).isPremium;
                              final isBudgetLocked = !isPremium &&
                                  (_selectedCategory?.budgetSeq ?? 0) >
                                      PremiumGate.categoryBudgetTotalLimit;

                              if (isBudgetLocked) {
                                return const SizedBox.shrink();
                              }

                              // If no budget is set, only show for premium users
                              if (!snap.hasBudget && !isPremium) {
                                return const SizedBox.shrink();
                              }

                              // If no budget and no consumption, hide even for premium
                              if (!snap.hasBudget && snap.netAmount <= 0) {
                                return const SizedBox.shrink();
                              }

                              final catColor = _selectedCategory?.color != null
                                  ? Color(int.parse(_selectedCategory!.color!
                                      .replaceAll('#', '0xFF')))
                                  : (isExpense
                                      ? AppColors.expenseColor
                                      : AppColors.incomeColor);

                              final monthStr = AppDateFormatter.formatMonth(
                                  snap.period.startDate,
                                  context: context);

                              final currencyAsync = ref.watch(currentCurrencyProvider);
                              final currency = currencyAsync.value;

                              if (currency == null) {
                                return const SizedBox.shrink();
                              }

                              if (!snap.hasBudget) {
                                // Premium feature: show consumption even without budget
                                final consumedStr =
                                    AmountFormatter.formatWithCurrency(
                                  snap.netAmount,
                                  currency,
                                );
                                return Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            isExpense
                                                ? Icons.shopping_cart_outlined
                                                : Icons.account_balance_wallet_outlined,
                                            size: 14,
                                            color: catColor,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              isExpense
                                                  ? '$consumedStr ${l10n.budgetBarUsed.toLowerCase()} ($monthStr)'
                                                  : '$consumedStr ${l10n.budgetBarProgress.toLowerCase()} ($monthStr)',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final rem = snap.remainingOrGap;
                              final remStr = AmountFormatter.formatWithCurrency(
                                rem.abs(),
                                currency,
                              );
                              final budStr = AmountFormatter.formatWithCurrency(
                                snap.budgetAmount!,
                                currency,
                              );
                              final sub = rem >= 0
                                  ? l10n.budgetRemainingOf(remStr, budStr)
                                  : l10n.budgetOverBy(remStr);

                              return Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    DualAmountProgressBar(
                                      leftLabel: isExpense
                                          ? '${l10n.budgetBarUsed} ($monthStr)'
                                          : '${l10n.budgetBarProgress} ($monthStr)',
                                      leftAmount: snap.netAmount > 0
                                          ? snap.netAmount
                                          : 0.0,
                                      rightLabel: '${l10n.remaining} ($monthStr)',
                                      rightAmount: snap.remainingOrGap > 0
                                          ? snap.remainingOrGap
                                          : 0.0,
                                      currency: currency,
                                      filledColor: snap.progressRatio > 1
                                          ? AppColors.expenseColor
                                          : catColor,
                                      compact: true,
                                    ),
                                  ],
                                ),
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Contact Selector
              InkWell(
                onTap: () => _showContactPicker(),
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
                          if (_selectedContact != null &&
                              ref.watch(premiumProvider).isPremium)
                            Consumer(
                              builder: (context, ref, _) {
                                final statsAsync = ref.watch(
                                    contactStatisticsProvider(
                                        _selectedContact!.uuid));
                                return statsAsync.when(
                                  data: (stats) {
                                    final balance = stats.netBalance;
                                    if (balance == 0)
                                      return const SizedBox.shrink();
                                    final isReceivable = balance > 0;
                                    final color = isReceivable
                                        ? AppColors.receivableColor
                                        : AppColors.payableColor;
                                    final currencyAsync = ref.watch(currentCurrencyProvider);
                                    final currency = currencyAsync.value;

                                    if (currency == null) {
                                      return const SizedBox.shrink();
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isReceivable
                                                ? Icons.call_received
                                                : Icons.call_made,
                                            size: 12,
                                            color: color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${isReceivable ? l10n.receivable : l10n.payable}: ${AmountFormatter.formatWithCurrency(balance.abs(), currency, Directionality.of(context) == TextDirection.rtl)}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: color,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, __) => const SizedBox.shrink(),
                                );
                              },
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
              const SizedBox(height: 16),

              // Account picker (create account from sheet when none exist)
              AccountPickerField(
                selectedAccount: _selectedAccount,
                excludeCreditCard: _selectedType == 'INCOME' &&
                    _selectedCategory?.uuid != 'default_cat_refund',
                onChanged: (acc) => setState(() => _selectedAccount = acc),
              ),
              const SizedBox(height: 16),

              // Description
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
                            final currentAmount = double.tryParse(_amountController.text) ?? 0.0;
                            TabularEditorSheet.show(
                              context,
                              initialRows: _tabularRows.isEmpty && currentAmount > 0
                                  ? [
                                      TabularRow(
                                        date: _selectedDate,
                                        quantity: 1.0,
                                        unitAmount: currentAmount,
                                        description: '',
                                      )
                                    ]
                                  : _tabularRows,
                              currencySymbol: currencySymbol,
                              decimalPlaces: decimalPlaces,
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
                                        total.toStringAsFixed(decimalPlaces);
                                  }
                                });
                              },
                            );
                          },
                          tooltip: _isTabularMode
                              ? 'Edit Itemized Details'
                              : 'Add Itemized Details',
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
              if (_isTabularMode)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${_tabularRows.length} item(s) added',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

              // More Options
              TxMoreOptionsSection(
                isExpanded: _isMoreOptionsExpanded,
                onToggle: () => setState(
                    () => _isMoreOptionsExpanded = !_isMoreOptionsExpanded),
                selectedType: _selectedType,
                paidRelationship: _paidRelationship,
                onRelationshipChange:
                    isSplitted ? (_) async {} : _handleRelationshipChange,
                dueDate: _dueDate,
                selectedDate: _selectedDate,
                onDueDateTap: _selectDueDate,
                onClearDueDate: () => setState(() => _dueDate = null),
                isGroupSplit: _isGroupSplit,
                groupSharesCount: _groupShares.length,
                myShareAmount: null,
                isSplitMode: true,
                onSplitTap: _showGroupSplitDialog,
                onClearSplit: () => setState(() {
                  _isGroupSplit = false;
                  _groupShares = [];
                }),
                showSplitButton: !isSplitted,
              ),

              const SizedBox(height: 16),
              TransactionAttachmentSection(
                attachments: _attachments,
                showEditWarning: true,
                onAddMultiple: (items) {
                  setState(() {
                    _attachments.addAll(items);
                  });
                },
                onDelete: (index) {
                  setState(() {
                    final item = _attachments[index];
                    if (item.uuid != null) {
                      _pendingDeletions.add(item.uuid!);
                    }
                    _attachments.removeAt(index);
                  });
                },
              ),

              const SizedBox(height: 100),
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.share.isUser
                          ? widget.l10n.me
                          : (widget.share.contact?.name ?? ''),
                      style: TextStyle(
                        fontWeight: widget.share.isUser
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: widget.share.isUser
                            ? theme.colorScheme.primary
                            : null,
                      ),
                    ),
                    if (!widget.share.isUser &&
                        widget.share.contact != null)
                      Consumer(
                        builder: (context, ref, _) {
                          final isPremium = ref.watch(premiumProvider).isPremium;
                          if (!isPremium) return const SizedBox.shrink();

                          final statsAsync = ref.watch(
                              contactStatisticsProvider(
                                  widget.share.contact!.uuid));
                          return statsAsync.when(
                            data: (stats) {
                              final balance = stats.netBalance;
                              if (balance == 0) return const SizedBox.shrink();
                              final isReceivable = balance > 0;
                              final color = isReceivable
                                  ? AppColors.receivableColor
                                  : AppColors.payableColor;
                              final currencyAsync = ref.watch(currentCurrencyProvider);
                              final currency = currencyAsync.value;

                              if (currency == null) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isReceivable
                                          ? Icons.call_received
                                          : Icons.call_made,
                                      size: 10,
                                      color: color,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${isReceivable ? widget.l10n.receivable : widget.l10n.payable}: ${AmountFormatter.formatWithCurrency(balance.abs(), currency, Directionality.of(context) == TextDirection.rtl)}',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                      ),
                  ],
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
                width: 100,
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

class _EditFabChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _EditFabChip({
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
