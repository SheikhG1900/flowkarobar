import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';

enum FilterType { transactions, payables, receivables }

class FilterBottomSheet extends ConsumerStatefulWidget {
  final FilterType type;
  final dynamic initialFilters;
  final Function(dynamic) onApply;

  const FilterBottomSheet({
    super.key,
    required this.type,
    required this.initialFilters,
    required this.onApply,
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
  late double? _minAmount;
  late double? _maxAmount;
  late bool _filterByDueDate;

  @override
  void initState() {
    super.initState();
    final filters = widget.initialFilters;
    _startDate = filters.startDate;
    _endDate = filters.endDate;
    _selectedContactUuids = List.from(filters.contactUuids ?? []);
    _minAmount = filters.minAmount;
    _maxAmount = filters.maxAmount;
    _filterByDueDate = (widget.type != FilterType.transactions)
        ? (filters.filterByDueDate ?? false)
        : false;

    if (widget.type == FilterType.transactions) {
      _transactionType = filters.type;
      _selectedCategoryUuids = List.from(filters.categoryUuids ?? []);
    } else {
      _transactionType = null;
      _selectedCategoryUuids = [];
    }
  }

  void _resetFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _transactionType = null;
      _selectedCategoryUuids = [];
      _selectedContactUuids = [];
      _minAmount = null;
      _maxAmount = null;
      _filterByDueDate = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final userProfile = ref.watch(userProfileProvider);

    final Color primaryFilterColor = widget.type == FilterType.transactions
        ? AppColors.brightCyan
        : widget.type == FilterType.payables
            ? AppColors.payableColor
            : AppColors.receivableColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
          const SizedBox(height: 20),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(l10n.dateRange),
                  _buildDateRangePicker(
                      context, userProfile.dateFormat, primaryFilterColor),
                  if (widget.type != FilterType.transactions) ...[
                    const SizedBox(height: 16),
                    _buildDueDateSwitch(l10n, primaryFilterColor),
                  ],
                  if (widget.type == FilterType.transactions) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle(l10n.transactionType),
                    _buildTransactionTypeSelector(l10n, primaryFilterColor),
                    const SizedBox(height: 24),
                    _buildSectionTitle(l10n.categories),
                    _buildCategorySelector(),
                  ],
                  const SizedBox(height: 24),
                  _buildSectionTitle(l10n.contacts),
                  _buildContactSelector(),
                  const SizedBox(height: 24),
                  _buildSectionTitle(l10n.amountRange),
                  _buildAmountRangeInputs(l10n, primaryFilterColor),
                  const SizedBox(height: 32),
                ],
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
    );
  }

  dynamic _getUpdatedFilters() {
    if (widget.type == FilterType.transactions) {
      // We'll need to import the filter models here or use dynamic
      // Since we can't easily import from different features here without circular deps
      // if they were in domain, it's fine.
      return widget.initialFilters.copyWith(
        startDate: _startDate,
        endDate: _endDate,
        type: _transactionType,
        categoryUuids: _selectedCategoryUuids,
        contactUuids: _selectedContactUuids,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
      );
    } else {
      return widget.initialFilters.copyWith(
        startDate: _startDate,
        endDate: _endDate,
        contactUuids: _selectedContactUuids,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
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
          activeColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildDateRangePicker(
      BuildContext context, String dateFormat, Color primaryColor) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _startDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _startDate = picked);
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: _startDate != null
                  ? primaryColor.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
              side: BorderSide(
                color: _startDate != null ? primaryColor : theme.dividerColor,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: Icon(
              Icons.calendar_today,
              size: 18,
              color: _startDate != null
                  ? primaryColor
                  : theme.colorScheme.onSurfaceVariant,
            ),
            label: Text(
              _startDate == null
                  ? l10n.from
                  : AppDateFormatter.formatDate(_startDate!,
                      pattern: dateFormat),
              style: TextStyle(
                color: _startDate != null
                    ? primaryColor
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _endDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _endDate = picked);
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: _endDate != null
                  ? primaryColor.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
              side: BorderSide(
                color: _endDate != null ? primaryColor : theme.dividerColor,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: Icon(
              Icons.calendar_today,
              size: 18,
              color: _endDate != null
                  ? primaryColor
                  : theme.colorScheme.onSurfaceVariant,
            ),
            label: Text(
              _endDate == null
                  ? l10n.to
                  : AppDateFormatter.formatDate(_endDate!, pattern: dateFormat),
              style: TextStyle(
                color: _endDate != null
                    ? primaryColor
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
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
    return categoriesAsync.when(
      data: (categories) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: categories.map((cat) {
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
        }).toList(),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildContactSelector() {
    final contactsAsync = ref.watch(contactsListProvider);
    final theme = Theme.of(context);
    return contactsAsync.when(
      data: (contacts) => Wrap(
        spacing: 8,
        runSpacing: 8,
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
            keyboardType: TextInputType.number,
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
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (val) =>
                setState(() => _minAmount = double.tryParse(val)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            keyboardType: TextInputType.number,
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
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (val) =>
                setState(() => _maxAmount = double.tryParse(val)),
          ),
        ),
      ],
    );
  }
}
