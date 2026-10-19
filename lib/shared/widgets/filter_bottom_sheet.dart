import 'package:flutter/material.dart' hide Category;
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/shared/models/date_range_state.dart';
import 'package:flowpaisa/shared/widgets/date_range_selector.dart';

enum FilterType { transactions, payables, receivables }

class FilterBottomSheet extends ConsumerStatefulWidget {
  final FilterType type;
  final dynamic initialFilters;
  final Function(dynamic) onApply;
  final ScrollController? scrollController;

  const FilterBottomSheet({
    super.key,
    required this.type,
    required this.initialFilters,
    required this.onApply,
    this.scrollController,
  });

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late String? _transactionType;
  late List<String> _selectedCategoryUuids;
  late List<String> _selectedContactUuids;
  late List<String> _selectedStatusCodes;
  late List<String> _selectedAccountUuids;
  late List<String> _selectedTagUuids;
  late bool _filterByDueDate;
  late TextEditingController _minAmountController;
  late TextEditingController _maxAmountController;
  DateRangeState? _dateRangeState;

  @override
  void initState() {
    super.initState();
    final filters = widget.initialFilters;
    _startDate = filters.startDate;
    _endDate = filters.endDate;
    _dateRangeState = DateRangeState.fromDates(_startDate, _endDate);
    _selectedContactUuids = List.from(filters.contactUuids ?? []);
    _minAmountController = TextEditingController(
      text: filters.minAmount != null ? filters.minAmount!.toString() : '',
    );
    _maxAmountController = TextEditingController(
      text: filters.maxAmount != null ? filters.maxAmount!.toString() : '',
    );
    _filterByDueDate = (widget.type != FilterType.transactions)
        ? (filters.filterByDueDate ?? false)
        : false;

    if (widget.type == FilterType.transactions) {
      _transactionType = filters.type;
      _selectedCategoryUuids = List.from(filters.categoryUuids ?? []);
      _selectedStatusCodes = List.from(filters.statusCodes ?? []);
      _selectedAccountUuids = List.from(filters.accountUuids ?? []);
      _selectedTagUuids = List.from(filters.tagUuids ?? []);
    } else {
      _transactionType = null;
      _selectedCategoryUuids = [];
      _selectedStatusCodes = [];
      _selectedAccountUuids = [];
      _selectedTagUuids = [];
    }
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _dateRangeState = null;
      _transactionType = null;
      _selectedCategoryUuids = [];
      _selectedContactUuids = [];
      _selectedStatusCodes = [];
      _selectedAccountUuids = [];
      _selectedTagUuids = [];
      _minAmountController.text = '';
      _maxAmountController.text = '';
      _filterByDueDate = false;
    });
  }

  void _onDateRangeChanged(DateRangeState? state) {
    setState(() {
      _dateRangeState = state;
      if (state == null) {
        _startDate = null;
        _endDate = null;
      } else {
        _startDate = state.startDate;
        _endDate = state.endDate;
      }
    });
  }

  void _onNextPeriod() {
    setState(() {
      if (_dateRangeState == null) return;
      switch (_dateRangeState!.type) {
        case DateRangeType.month:
          final d = _dateRangeState!.startDate;
          final nextMonth = DateTime(d.year, d.month + 1, 1);
          _dateRangeState = DateRangeState.month(nextMonth);
          break;
        case DateRangeType.quarter:
          final d = _dateRangeState!.startDate;
          final q = ((d.month - 1) ~/ 3) + 1;
          final nextYear = q == 4 ? d.year + 1 : d.year;
          final nextQ = q == 4 ? 1 : q + 1;
          _dateRangeState = DateRangeState.quarter(nextYear, nextQ);
          break;
        case DateRangeType.year:
          _dateRangeState =
              DateRangeState.year(_dateRangeState!.startDate.year + 1);
          break;
        case DateRangeType.custom:
          return;
      }
      _startDate = _dateRangeState!.startDate;
      _endDate = _dateRangeState!.endDate;
    });
  }

  void _onPreviousPeriod() {
    setState(() {
      if (_dateRangeState == null) return;
      switch (_dateRangeState!.type) {
        case DateRangeType.month:
          final d = _dateRangeState!.startDate;
          final prevMonth = DateTime(d.year, d.month - 1, 1);
          _dateRangeState = DateRangeState.month(prevMonth);
          break;
        case DateRangeType.quarter:
          final d = _dateRangeState!.startDate;
          final q = ((d.month - 1) ~/ 3) + 1;
          final prevYear = q == 1 ? d.year - 1 : d.year;
          final prevQ = q == 1 ? 4 : q - 1;
          _dateRangeState = DateRangeState.quarter(prevYear, prevQ);
          break;
        case DateRangeType.year:
          _dateRangeState =
              DateRangeState.year(_dateRangeState!.startDate.year - 1);
          break;
        case DateRangeType.custom:
          return;
      }
      _startDate = _dateRangeState!.startDate;
      _endDate = _dateRangeState!.endDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final Color primaryFilterColor = widget.type == FilterType.transactions
        ? AppColors.brightCyan
        : widget.type == FilterType.payables
            ? AppColors.payableColor
            : AppColors.receivableColor;

    final categoryCount = ref.watch(categoriesListProvider).value?.length ?? 0;
    final contactCount = ref.watch(contactsListProvider).value?.length ?? 0;
    final accountCount = ref.watch(accountsWithBalanceProvider).value?.length ?? 0;
    final categoriesExpanded =
        _selectedCategoryUuids.isNotEmpty || categoryCount <= 20;
    final contactsExpanded =
        _selectedContactUuids.isNotEmpty || contactCount <= 20;
    final accountsExpanded =
        _selectedAccountUuids.isNotEmpty || accountCount <= 12;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.filters,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(l10n.reset),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCollapsibleSection(
                        title: l10n.dateRange,
                        initiallyExpanded: true,
                        icon: Icons.calendar_today,
                        primaryColor: primaryFilterColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DateRangeSelector(
                              selectedDateRange: _dateRangeState,
                              onDateRangeChanged: _onDateRangeChanged,
                              onNextPeriod: _onNextPeriod,
                              onPreviousPeriod: _onPreviousPeriod,
                              accentColor: primaryFilterColor,
                            ),
                            if (widget.type != FilterType.transactions) ...[
                              const SizedBox(height: 16),
                              _buildDueDateSwitch(l10n, primaryFilterColor),
                            ],
                          ],
                        ),
                      ),
                      if (widget.type == FilterType.transactions) ...[
                        _buildCollapsibleSection(
                          title: l10n.transactionType,
                          initiallyExpanded: true,
                          icon: Icons.swap_horiz,
                          primaryColor: primaryFilterColor,
                          child: _buildTransactionTypeSelector(
                              l10n, primaryFilterColor),
                        ),
                        _buildCollapsibleSection(
                          title: l10n.categories,
                          initiallyExpanded: categoriesExpanded,
                          icon: Icons.category,
                          primaryColor: primaryFilterColor,
                          child: _buildCategorySelector(),
                        ),
                        _buildCollapsibleSection(
                          title: l10n.tags,
                          initiallyExpanded: true,
                          icon: Icons.local_offer,
                          primaryColor: primaryFilterColor,
                          child: _buildTagSelector(theme, primaryFilterColor),
                        ),
                        _buildCollapsibleSection(
                          title: l10n.status,
                          initiallyExpanded: true,
                          icon: Icons.label,
                          primaryColor: primaryFilterColor,
                          child: _buildTransactionStatusSelector(
                              l10n, primaryFilterColor),
                        ),
                        _buildCollapsibleSection(
                          title: l10n.accounts,
                          initiallyExpanded: accountsExpanded,
                          icon: Symbols.account_balance_wallet,
                          primaryColor: primaryFilterColor,
                          child: _buildAccountSelector(),
                        ),
                      ],
                      _buildCollapsibleSection(
                        title: l10n.contacts,
                        initiallyExpanded: contactsExpanded,
                        icon: Icons.people,
                        primaryColor: primaryFilterColor,
                        child: _buildContactSelector(),
                      ),
                      _buildCollapsibleSection(
                        title: l10n.amountRange,
                        initiallyExpanded: true,
                        icon: Icons.attach_money,
                        primaryColor: primaryFilterColor,
                        child:
                            _buildAmountRangeInputs(l10n, primaryFilterColor),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_getUpdatedFilters());
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: primaryFilterColor, width: 1),
                  backgroundColor: primaryFilterColor.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(l10n.applyFilters,
                    style: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? _getMinAmountFromControllers() {
    final s = _minAmountController.text.trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  double? _getMaxAmountFromControllers() {
    final s = _maxAmountController.text.trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  dynamic _getUpdatedFilters() {
    final minAmount = _getMinAmountFromControllers();
    final maxAmount = _getMaxAmountFromControllers();
    if (widget.type == FilterType.transactions) {
      return widget.initialFilters.copyWith(
        startDate: _startDate,
        clearStartDate: _startDate == null,
        endDate: _endDate,
        clearEndDate: _endDate == null,
        type: _transactionType,
        clearType: _transactionType == null,
        categoryUuids: _selectedCategoryUuids,
        contactUuids: _selectedContactUuids,
        accountUuids: _selectedAccountUuids,
        tagUuids: _selectedTagUuids,
        minAmount: minAmount,
        clearMinAmount: minAmount == null,
        maxAmount: maxAmount,
        clearMaxAmount: maxAmount == null,
        statusCodes: _selectedStatusCodes,
      );
    } else {
      return widget.initialFilters.copyWith(
        startDate: _startDate,
        clearStartDate: _startDate == null,
        endDate: _endDate,
        clearEndDate: _endDate == null,
        contactUuids: _selectedContactUuids,
        minAmount: minAmount,
        clearMinAmount: minAmount == null,
        maxAmount: maxAmount,
        clearMaxAmount: maxAmount == null,
        filterByDueDate: _filterByDueDate,
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required bool initiallyExpanded,
    required IconData icon,
    required Color primaryColor,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final sectionColor = Color.lerp(
          theme.colorScheme.surfaceContainerLow,
          primaryColor.withValues(alpha: 0.01),
          0.03,
        ) ??
        theme.colorScheme.surfaceContainerLow;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 2,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        color: sectionColor,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            leading: Icon(icon, size: 22, color: primaryColor),
            title: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            expandedAlignment: Alignment.topLeft,
            children: [SizedBox(width: double.infinity, child: child)],
          ),
        ),
      ),
    );
  }

  Widget _buildDueDateSwitch(AppLocalizations l10n, Color primaryColor) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          l10n.filterByDueDate,
          style: theme.textTheme.bodyLarge,
        ),
        const Spacer(),
        Switch(
          value: _filterByDueDate,
          onChanged: (value) => setState(() => _filterByDueDate = value),
          activeThumbColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildTransactionTypeSelector(
      AppLocalizations l10n, Color primaryColor) {
    return Row(
      children: [
        _buildChoiceChip(l10n.all, null, _transactionType == null,
            (val) => setState(() => _transactionType = null), primaryColor),
        const SizedBox(width: 8),
        _buildChoiceChip(l10n.income, 'INCOME', _transactionType == 'INCOME',
            (val) => setState(() => _transactionType = 'INCOME'), primaryColor),
        const SizedBox(width: 8),
        _buildChoiceChip(
            l10n.expense,
            'EXPENSE',
            _transactionType == 'EXPENSE',
            (val) => setState(() => _transactionType = 'EXPENSE'),
            primaryColor),
      ],
    );
  }

  Widget _buildTransactionStatusSelector(
      AppLocalizations l10n, Color primaryColor) {
    final theme = Theme.of(context);
    final chipTextStyle = theme.textTheme.bodySmall;

    Widget buildStatusChip({
      required String code,
      required String label,
      required Color color,
      required IconData icon,
    }) {
      final selected = _selectedStatusCodes.contains(code);
      return FilterChip(
        avatar: Icon(
          icon,
          size: 16,
          color: selected ? Colors.white : color,
        ),
        label: Text(
          label,
          style: chipTextStyle?.copyWith(
            color: selected ? Colors.white : theme.colorScheme.onSurface,
            fontSize: 12,
          ),
        ),
        selected: selected,
        onSelected: (isSelected) {
          setState(() {
            if (isSelected) {
              if (!_selectedStatusCodes.contains(code)) {
                _selectedStatusCodes.add(code);
              }
            } else {
              _selectedStatusCodes.remove(code);
            }
          });
        },
        selectedColor: color,
        checkmarkColor: Colors.white,
        showCheckmark: false,
        backgroundColor: theme.colorScheme.surface,
        side: BorderSide(
          color: selected ? Colors.transparent : theme.dividerColor,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      children: [
        buildStatusChip(
          code: 'PAID',
          label: l10n.paidTag,
          color: AppColors.payableColor,
          icon: Icons.check_circle_outline,
        ),
        buildStatusChip(
          code: 'RECEIVED',
          label: l10n.receivedTag,
          color: AppColors.receivableColor,
          icon: Icons.move_to_inbox_outlined,
        ),
        buildStatusChip(
          code: 'PAYABLE',
          label: l10n.payableTag,
          color: AppColors.payableColor,
          icon: Icons.arrow_circle_up_outlined,
        ),
        buildStatusChip(
          code: 'RECEIVABLE',
          label: l10n.receivableTag,
          color: AppColors.receivableColor,
          icon: Icons.arrow_circle_down_outlined,
        ),
        buildStatusChip(
          code: 'AUTO',
          label: l10n.autoBadge,
          color: theme.colorScheme.secondary,
          icon: Icons.auto_awesome_outlined,
        ),
        buildStatusChip(
          code: 'SCHEDULED',
          label: l10n.schedules,
          color: Colors.blue,
          icon: Icons.event_repeat,
        ),
        buildStatusChip(
          code: 'PROCESSED',
          label: l10n.filterTransactionProcessed,
          color: AppColors.incomeColor,
          icon: Icons.task_alt,
        ),
        buildStatusChip(
          code: 'NOT_PROCESSED',
          label: l10n.filterTransactionNotProcessed,
          color: theme.colorScheme.outline,
          icon: Icons.pending_outlined,
        ),
      ],
    );
  }

  Widget _buildChoiceChip(String label, String? value, bool selected,
      Function(bool) onSelected, Color primaryColor) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: primaryColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
          color: selected ? Colors.white : theme.colorScheme.onSurface),
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(
        color: selected ? Colors.transparent : theme.dividerColor,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildCategorySelector() {
    final categoriesAsync = ref.watch(categoriesListProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return categoriesAsync.when(
      data: (categories) {
        final isUncategorizedSelected = _selectedCategoryUuids.contains('uncategorized');
        final uncategorizedColor = theme.colorScheme.primary;

        final uncategorizedChip = FilterChip(
          avatar: Icon(
            Symbols.help_outline,
            size: 16,
            color: isUncategorizedSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
          ),
          label: Text(
            l10n.uncategorized,
            style: TextStyle(
              color: isUncategorizedSelected ? Colors.white : theme.colorScheme.onSurface,
              fontSize: 12,
            ),
          ),
          selected: isUncategorizedSelected,
          selectedColor: uncategorizedColor,
          checkmarkColor: Colors.white,
          backgroundColor: theme.colorScheme.surface,
          side: BorderSide(
            color: isUncategorizedSelected ? Colors.transparent : theme.dividerColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                if (!_selectedCategoryUuids.contains('uncategorized')) {
                  _selectedCategoryUuids.add('uncategorized');
                }
              } else {
                _selectedCategoryUuids.remove('uncategorized');
              }
            });
          },
        );

        final List<Widget> chips = categories.map((cat) {
          final isSelected = _selectedCategoryUuids.contains(cat.uuid);
          Color categoryColor;
          if (cat.color != null) {
            try {
              categoryColor =
                  Color(int.parse(cat.color!.replaceAll('#', '0xFF')));
            } catch (_) {
              categoryColor = AppColors.brightCyan;
            }
          } else {
            categoryColor = AppColors.brightCyan;
          }

          return FilterChip(
            avatar: Icon(
              IconHelper.getIconData(cat.icon),
              size: 16,
              color: isSelected ? Colors.white : categoryColor,
            ),
            label: Text(
              LocalizationHelper.getLocalizedCategoryName(context, cat.name),
              style: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 12,
              ),
            ),
            selected: isSelected,
            selectedColor: categoryColor,
            checkmarkColor: Colors.white,
            backgroundColor: theme.colorScheme.surface,
            side: BorderSide(
              color: isSelected ? Colors.transparent : theme.dividerColor,
              width: 1.5,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedCategoryUuids.add(cat.uuid);
                } else {
                  _selectedCategoryUuids.remove(cat.uuid);
                }
              });
            },
          );
        }).toList();

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          children: [
            uncategorizedChip,
            ...chips,
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildAccountSelector() {
    final accountsAsync = ref.watch(accountsWithBalanceProvider);
    final theme = Theme.of(context);
    return accountsAsync.when(
      data: (list) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              AppLocalizations.of(context)!.noAccounts,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        final isNoAccountSelected = _selectedAccountUuids.contains('no_account');
        final noAccountColor = theme.colorScheme.primary;

        final noAccountChip = FilterChip(
          avatar: Icon(
            Symbols.help_outline,
            size: 16,
            color: isNoAccountSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
          ),
          label: Text(
            AppLocalizations.of(context)!.noAccount,
            style: TextStyle(
              color: isNoAccountSelected ? Colors.white : theme.colorScheme.onSurface,
              fontSize: 12,
            ),
          ),
          selected: isNoAccountSelected,
          selectedColor: noAccountColor,
          checkmarkColor: Colors.white,
          backgroundColor: theme.colorScheme.surface,
          side: BorderSide(
            color: isNoAccountSelected ? Colors.transparent : theme.dividerColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                if (!_selectedAccountUuids.contains('no_account')) {
                  _selectedAccountUuids.add('no_account');
                }
              } else {
                _selectedAccountUuids.remove('no_account');
              }
            });
          },
        );

        final List<Widget> chips = list.map((awb) {
          final acc = awb.account;
          final isSelected = _selectedAccountUuids.contains(acc.uuid);
          final accountColor = acc.color != null
              ? Color(int.parse(acc.color!.replaceAll('#', '0xFF')))
              : theme.colorScheme.primary;
          final iconData =
              IconHelper.getIconData(acc.icon) ?? _accountTypeIcon(awb.type);

          return FilterChip(
            avatar: Icon(
              iconData,
              size: 16,
              color: isSelected ? Colors.white : accountColor,
            ),
            label: Text(
              acc.name,
              style: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 12,
              ),
            ),
            selected: isSelected,
            selectedColor: accountColor,
            checkmarkColor: Colors.white,
            backgroundColor: theme.colorScheme.surface,
            side: BorderSide(
              color: isSelected ? Colors.transparent : theme.dividerColor,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  if (!_selectedAccountUuids.contains(acc.uuid)) {
                    _selectedAccountUuids.add(acc.uuid);
                  }
                } else {
                  _selectedAccountUuids.remove(acc.uuid);
                }
              });
            },
          );
        }).toList();

        // Put the "No Account" chip at the beginning of the list for easy access
        chips.insert(0, noAccountChip);

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          children: chips,
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  IconData _accountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Symbols.payments;
      case AccountType.bank:
        return Symbols.account_balance;
      case AccountType.savings:
        return Symbols.savings;
      case AccountType.creditCard:
        return Symbols.credit_card;
    }
  }

  Widget _buildContactSelector() {
    final contactsAsync = ref.watch(contactsListProvider);
    final theme = Theme.of(context);
    return contactsAsync.when(
      data: (contacts) => Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: contacts.map((contact) {
          final isSelected = _selectedContactUuids.contains(contact.uuid);
          final contactColor = AppColors.getContactColor(contact.name);

          return FilterChip(
            avatar: CircleAvatar(
              radius: 10,
              backgroundColor: isSelected ? Colors.white : contactColor,
              child: Text(
                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: isSelected ? contactColor : Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            label: Text(
              contact.name,
              style: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 12,
              ),
            ),
            selected: isSelected,
            selectedColor: contactColor,
            checkmarkColor: Colors.white,
            backgroundColor: theme.colorScheme.surface,
            side: BorderSide(
              color: isSelected ? Colors.transparent : theme.dividerColor,
              width: 1.5,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedContactUuids.add(contact.uuid);
                } else {
                  _selectedContactUuids.remove(contact.uuid);
                }
              });
            },
          );
        }).toList(),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildAmountRangeInputs(AppLocalizations l10n, Color primaryColor) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: l10n.minAmount,
              hintStyle: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _maxAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: l10n.maxAmount,
              hintStyle: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildTagSelector(ThemeData theme, Color primaryColor) {
    final tagsAsync = ref.watch(allTagsProvider);
    final tagUsageCountsAsync = ref.watch(tagUsageCountsProvider);

    final l10n = AppLocalizations.of(context)!;
    return tagsAsync.when(
      data: (tags) {
        final usageCounts = tagUsageCountsAsync.value ?? const {};
        final isWithoutTagsSelected = _selectedTagUuids.contains('no_tag');

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Custom "Without Tags" Chip
            FilterChip(
              avatar: Icon(
                Icons.block,
                size: 14,
                color: isWithoutTagsSelected
                    ? primaryColor
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              showCheckmark: false,
              label: Text(l10n.filterWithoutTags),
              selected: isWithoutTagsSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTagUuids.add('no_tag');
                  } else {
                    _selectedTagUuids.remove('no_tag');
                  }
                });
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: primaryColor.withValues(alpha: 0.15),
              side: BorderSide(
                color: isWithoutTagsSelected
                    ? primaryColor
                    : theme.colorScheme.outline.withValues(alpha: 0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isWithoutTagsSelected ? primaryColor : theme.colorScheme.onSurfaceVariant,
                fontWeight: isWithoutTagsSelected ? FontWeight.bold : null,
                fontSize: 12,
              ),
            ),
            
            // Render regular tags
            ...tags.map((tag) {
              final isSelected = _selectedTagUuids.contains(tag.uuid);
              final tagColor = tag.color != null
                  ? Color(int.parse(tag.color!))
                  : AppColors.getTagColor(tag.name);
              final isOrphan = (usageCounts[tag.uuid] ?? 0) == 0;

              return Tooltip(
                message: isOrphan ? l10n.deleteTagTitle : '',
                child: GestureDetector(
                  onLongPress: () => _handleTagLongPress(context, tag),
                  child: isOrphan
                      ? InputChip(
                          label: Text(tag.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTagUuids.add(tag.uuid);
                              } else {
                                _selectedTagUuids.remove(tag.uuid);
                              }
                            });
                          },
                          backgroundColor: theme.colorScheme.surface,
                          selectedColor: tagColor.withValues(alpha: 0.2),
                          side: BorderSide(
                            color: isSelected
                                ? tagColor
                                : tagColor.withValues(alpha: 0.3),
                            width: 1.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          labelStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected ? tagColor : tagColor.withValues(alpha: 0.7),
                            fontWeight: isSelected ? FontWeight.bold : null,
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                          deleteIcon: Icon(Icons.close, size: 14, color: tagColor.withValues(alpha: 0.7)),
                          onDeleted: () => _handleTagLongPress(context, tag),
                        )
                      : FilterChip(
                          label: Text(tag.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTagUuids.add(tag.uuid);
                              } else {
                                _selectedTagUuids.remove(tag.uuid);
                              }
                            });
                          },
                          backgroundColor: theme.colorScheme.surface,
                          selectedColor: tagColor.withValues(alpha: 0.2),
                          side: BorderSide(
                            color: isSelected
                                ? tagColor
                                : tagColor.withValues(alpha: 0.35),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          labelStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected ? tagColor : tagColor.withValues(alpha: 0.7),
                            fontWeight: isSelected ? FontWeight.bold : null,
                            fontSize: 12,
                          ),
                        ),
                ),
              );
            }),
          ],
        );
      },
      loading: () => const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (err, stack) => Text('Error loading tags: $err'),
    );
  }

  Future<void> _handleTagLongPress(BuildContext context, Tag tag) async {
    final repo = ref.read(transactionsRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    final count = await repo.getTagUsageCount(tag.uuid);
    
    if (!mounted) return;
    
    if (count == 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.deleteTagTitle),
          content: Text(l10n.deleteTagConfirm(tag.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await repo.deleteTag(tag.uuid);
                  if (mounted) {
                    ToastUtils.showSuccessToast(context, ref, l10n.tagDeletedSuccessfully);
                  }
                } catch (e) {
                  if (mounted) {
                    ToastUtils.showErrorToast(context, ref, 'Failed to delete tag: $e');
                  }
                }
              },
              child: Text(l10n.delete),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.cannotDeleteTagTitle),
          content: Text(l10n.cannotDeleteTagMessage(count)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
    }
  }
}
