import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/shared/widgets/limit_countdown_badge.dart';
import 'package:uuid/uuid.dart';

class AddEditAccountScreen extends ConsumerStatefulWidget {
  final Account? account;

  const AddEditAccountScreen({super.key, this.account});

  @override
  ConsumerState<AddEditAccountScreen> createState() => _AddEditAccountScreenState();
}

class _AddEditAccountScreenState extends ConsumerState<AddEditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _creditLimitController = TextEditingController();

  AccountType _selectedType = AccountType.cash;
  DateTime _openingDate = DateTime.now();
  String? _selectedIcon;
  String? _selectedColor;
  int _billingCycleDay = 1;
  int _paymentDueDays = 20;
  String? _linkedAccountUuid;

  bool _isLoading = false;
  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final acc = widget.account;
    if (acc != null) {
      _nameController.text = acc.name;
      _selectedType = AccountType.fromValue(acc.type);
      _openingDate = acc.openingDate;
      // Credit card balance is stored negative; show as positive in the field.
      final displayBalance = _selectedType.isCreditCard
          ? acc.openingBalance.abs()
          : acc.openingBalance;
      _openingBalanceController.text = displayBalance.toStringAsFixed(2);
      _selectedIcon = acc.icon;
      _selectedColor = acc.color;
      if (acc.creditLimit != null) {
        _creditLimitController.text = acc.creditLimit!.toStringAsFixed(2);
      }
      _billingCycleDay = acc.billingCycleDay ?? 1;
      _paymentDueDays = acc.paymentDueDays ?? 20;
      _linkedAccountUuid = acc.linkedAccountUuid;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _openingBalanceController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      if (!_isEditing) {
        final isPremium = PremiumGate.isPremium(ref);
        if (!isPremium) {
          final limits = await PremiumGate.getAccountLimits(ref);
          if (!limits.canAdd) {
            if (mounted) {
              PremiumGate.showPremiumDialog(context);
            }
            return;
          }
        }
      }

      final repo = ref.read(accountsRepositoryProvider);
      final now = DateTime.now();
      final name = _nameController.text.trim();
      final rawOpeningBalance =
          double.tryParse(_openingBalanceController.text) ?? 0.0;
      // Credit card opening balance is a liability (dues), stored as negative.
      final openingBalance = _selectedType.isCreditCard
          ? -rawOpeningBalance.abs()
          : rawOpeningBalance;
      final creditLimit = _selectedType.isCreditCard
          ? (double.tryParse(_creditLimitController.text) ?? 0.0)
          : null;

      if (_isEditing) {
        final existing = widget.account!;
        await repo.updateAccount(
          existing.copyWith(
            name: name,
            type: _selectedType.value,
            openingBalance: openingBalance,
            openingDate: _openingDate,
            icon: drift.Value(_selectedIcon),
            color: drift.Value(_selectedColor),
            creditLimit: drift.Value(creditLimit),
            billingCycleDay: _selectedType.isCreditCard
                ? drift.Value(_billingCycleDay)
                : const drift.Value(null),
            paymentDueDays: _selectedType.isCreditCard
                ? drift.Value(_paymentDueDays)
                : const drift.Value(null),
            linkedAccountUuid: drift.Value(_linkedAccountUuid),
            updatedAt: now,
            isNotSynced: true,
          ),
        );
        if (mounted) {
          ref.invalidate(accountDetailWithBalanceProvider(existing.uuid));
          ToastUtils.showSuccessToast(context, ref, l10n.accountUpdated);
          Navigator.pop(context);
        }
      } else {
        final newUuid = const Uuid().v4();
        await repo.createAccount(
          AccountsCompanion.insert(
            uuid: newUuid,
            name: name,
            type: _selectedType.value,
            openingBalance: drift.Value(openingBalance),
            openingDate: drift.Value(_openingDate),
            icon: drift.Value(_selectedIcon),
            color: drift.Value(_selectedColor),
            creditLimit: drift.Value(creditLimit),
            billingCycleDay: _selectedType.isCreditCard
                ? drift.Value(_billingCycleDay)
                : const drift.Value(null),
            paymentDueDays: _selectedType.isCreditCard
                ? drift.Value(_paymentDueDays)
                : const drift.Value(null),
            linkedAccountUuid: drift.Value(_linkedAccountUuid),
            createdAt: drift.Value(now),
            updatedAt: drift.Value(now),
          ),
        );
        if (mounted) {
          final created = await repo.getAccountByUuid(newUuid);
          ToastUtils.showSuccessToast(context, ref, l10n.accountCreated);
          Navigator.pop(context, created);
        }
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
            context, ref, AppLocalizations.of(context)!.errorOccurred(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _openingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _openingDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final decimalPlaces = ref.watch(currencyDecimalPlacesProvider);
    final dateFormat = ref.watch(userProfileProvider).dateFormat;
    final sectionColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editAccount : l10n.addAccount),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              sectionColor.withValues(alpha: 0.05),
              Colors.transparent,
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
              // Account type selector
              _AccountTypeSelector(
                selected: _selectedType,
                onChanged: (type) => setState(() => _selectedType = type),
              ),
              const SizedBox(height: 20),

              // Name & opening balance card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: sectionColor.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Account Name
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.accountName,
                        prefixIcon: const Icon(Icons.label_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.pleaseEnterAccountName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Opening Balance
                    TextFormField(
                      controller: _openingBalanceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        labelText: _selectedType.isCreditCard
                            ? l10n.openingBalanceDues
                            : l10n.openingBalance,
                        prefixText: '$currencySymbol ',
                        prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: AmountFormatter.formatAmount(0, decimalPlaces),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Opening Date
                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 20),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.openingDate,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppDateFormatter.formatDate(
                                    _openingDate,
                                    pattern: dateFormat,
                                  ),
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
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Icon & color pickers
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appearance,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _IconPicker(
                      selectedIcon: _selectedIcon,
                      onChanged: (icon) => setState(() => _selectedIcon = icon),
                    ),
                    const SizedBox(height: 12),
                    _ColorPicker(
                      selectedColor: _selectedColor,
                      onChanged: (color) =>
                          setState(() => _selectedColor = color),
                    ),
                  ],
                ),
              ),

              // Credit card specific fields
              if (_selectedType.isCreditCard) ...[
                const SizedBox(height: 20),
                _CreditCardFields(
                  creditLimitController: _creditLimitController,
                  billingCycleDay: _billingCycleDay,
                  paymentDueDays: _paymentDueDays,
                  currencySymbol: currencySymbol,
                  onBillingCycleDayChanged: (v) =>
                      setState(() => _billingCycleDay = v),
                  onPaymentDueDaysChanged: (v) =>
                      setState(() => _paymentDueDays = v),
                ),
              ],

              const SizedBox(height: 28),

              // Countdown Badge (show until limit reached)
              if (!_isEditing)
                FutureBuilder<TotalLimits>(
                  future: PremiumGate.getAccountLimits(ref),
                  builder: (context, snapshot) {
                    final limits = snapshot.data;
                    if (limits != null && !limits.isUnlimited && limits.canAdd) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Center(
                          child: LimitCountdownBadge(
                            totalUsed: limits.used,
                            totalLimit: limits.total,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

              // Save button
              Stack(
                alignment: Alignment.topRight,
                children: [
                  GradientButton(
                    label: _isEditing ? l10n.saveChanges : l10n.addAccount,
                    isLoading: _isLoading,
                    onPressed: _save,
                    width: double.infinity,
                  ),
                  if (!_isEditing)
                    FutureBuilder<TotalLimits>(
                      future: PremiumGate.getAccountLimits(ref),
                      builder: (context, snapshot) {
                        final limits = snapshot.data;
                        if (limits != null &&
                            !limits.isUnlimited &&
                            !limits.canAdd) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 8, right: 8),
                            child:
                                Icon(Icons.lock, size: 16, color: Colors.white),
                          );
                        }
                        return const SizedBox.shrink();
                      },
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

// ────────────────────────────────────────────────────────────
// Account Type Selector — horizontal pill chips
// ────────────────────────────────────────────────────────────
class _AccountTypeSelector extends StatelessWidget {
  final AccountType selected;
  final ValueChanged<AccountType> onChanged;

  const _AccountTypeSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.accountType.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: AccountType.values.map((type) {
            final isSelected = type == selected;
            final color = _typeColor(type);
            final icon = _typeIcon(type);
            final label = _typeLabel(l10n, type);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onChanged(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.12)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? color : theme.dividerColor,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(icon,
                            color: isSelected
                                ? color
                                : theme.colorScheme.onSurfaceVariant,
                            size: 22),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? color
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _typeColor(AccountType type) {
    switch (type) {
      case AccountType.cash:       return Colors.green;
      case AccountType.bank:       return Colors.blue;
      case AccountType.savings:    return Colors.teal;
      case AccountType.creditCard: return AppColors.expenseColor;
    }
  }

  IconData _typeIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:       return Symbols.payments;
      case AccountType.bank:       return Symbols.account_balance;
      case AccountType.savings:    return Symbols.savings;
      case AccountType.creditCard: return Symbols.credit_card;
    }
  }

  String _typeLabel(AppLocalizations l10n, AccountType type) {
    switch (type) {
      case AccountType.cash:       return l10n.cash;
      case AccountType.bank:       return l10n.bank;
      case AccountType.savings:    return l10n.savings;
      case AccountType.creditCard: return l10n.creditCard;
    }
  }
}

// ────────────────────────────────────────────────────────────
// Icon Picker
// ────────────────────────────────────────────────────────────
const _kAccountIcons = [
  'account_balance_wallet',
  'account_balance',
  'savings',
  'payments',
  'credit_card',
  'wallet',
  'money',
  'currency_exchange',
  'attach_money',
  'local_atm',
  'shopping_bag',
  'store',
  'home',
  'directions_car',
];

class _IconPicker extends StatelessWidget {
  final String? selectedIcon;
  final ValueChanged<String?> onChanged;

  const _IconPicker({required this.selectedIcon, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.icon,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _kAccountIcons.map((iconName) {
            final iconData = IconHelper.getIconData(iconName);
            if (iconData == null) return const SizedBox.shrink();
            final isSelected = iconName == selectedIcon;
            return InkWell(
              onTap: () => onChanged(isSelected ? null : iconName),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.12)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(
                          color: theme.colorScheme.primary, width: 1.5)
                      : null,
                ),
                alignment: Alignment.center,
                child: Icon(
                  iconData,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────
// Color Picker
// ────────────────────────────────────────────────────────────
const _kAccountColors = [
  '#2196F3', '#4CAF50', '#F44336', '#FF9800', '#9C27B0',
  '#00BCD4', '#009688', '#FF5722', '#607D8B', '#E91E63',
];

class _ColorPicker extends StatelessWidget {
  final String? selectedColor;
  final ValueChanged<String?> onChanged;

  const _ColorPicker({required this.selectedColor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.color,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _kAccountColors.map((hex) {
            final color = Color(int.parse(hex.replaceAll('#', '0xFF')));
            final isSelected = hex == selectedColor;
            return InkWell(
              onTap: () => onChanged(isSelected ? null : hex),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: theme.colorScheme.onSurface, width: 2.5)
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────
// Credit Card Specific Fields
// ────────────────────────────────────────────────────────────
class _CreditCardFields extends StatelessWidget {
  final TextEditingController creditLimitController;
  final int billingCycleDay;
  final int paymentDueDays;
  final String currencySymbol;
  final ValueChanged<int> onBillingCycleDayChanged;
  final ValueChanged<int> onPaymentDueDaysChanged;

  const _CreditCardFields({
    required this.creditLimitController,
    required this.billingCycleDay,
    required this.paymentDueDays,
    required this.currencySymbol,
    required this.onBillingCycleDayChanged,
    required this.onPaymentDueDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.expenseColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.credit_card,
                  color: AppColors.expenseColor, size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.creditCardDetails.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.expenseColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Credit Limit
          TextFormField(
            controller: creditLimitController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: l10n.creditLimit,
              prefixText: '$currencySymbol ',
              prefixIcon: const Icon(Icons.credit_score_outlined),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          // Billing Cycle Day
          _SpinnerField(
            label: l10n.billingCycleDay,
            value: billingCycleDay,
            min: 1,
            max: 28,
            suffix: '',
            onChanged: onBillingCycleDayChanged,
            icon: Icons.calendar_month_outlined,
          ),
          const SizedBox(height: 12),

          // Payment Due Days
          _SpinnerField(
            label: l10n.paymentDueDays,
            value: paymentDueDays,
            min: 1,
            max: 60,
            suffix: l10n.days,
            onChanged: onPaymentDueDaysChanged,
            icon: Icons.alarm_outlined,
          ),
        ],
      ),
    );
  }
}

class _SpinnerField extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final String suffix;
  final ValueChanged<int> onChanged;
  final IconData icon;

  const _SpinnerField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  suffix.isNotEmpty ? '$value $suffix' : '$value',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton.outlined(
                icon: const Icon(Icons.remove),
                onPressed:
                    value > min ? () => onChanged(value - 1) : null,
                iconSize: 18,
              ),
              const SizedBox(width: 4),
              IconButton.outlined(
                icon: const Icon(Icons.add),
                onPressed:
                    value < max ? () => onChanged(value + 1) : null,
                iconSize: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
