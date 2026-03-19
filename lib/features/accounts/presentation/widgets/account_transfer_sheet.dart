import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/account_picker.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

class AccountTransferSheet extends ConsumerStatefulWidget {
  final String? preselectedFromUuid;
  final String? preselectedToUuid;
  final double? initialAmount;

  const AccountTransferSheet({
    super.key,
    this.preselectedFromUuid,
    this.preselectedToUuid,
    this.initialAmount,
  });

  @override
  ConsumerState<AccountTransferSheet> createState() =>
      _AccountTransferSheetState();
}

class _AccountTransferSheetState extends ConsumerState<AccountTransferSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Account? _fromAccount;
  Account? _toAccount;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  void _onAmountChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!.toStringAsFixed(2);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = ref.read(accountsRepositoryProvider);
      if (widget.preselectedFromUuid != null) {
        final acc = await repo.getAccountByUuid(widget.preselectedFromUuid!);
        if (acc != null && mounted) setState(() => _fromAccount = acc);
      }
      if (widget.preselectedToUuid != null) {
        final acc = await repo.getAccountByUuid(widget.preselectedToUuid!);
        if (acc != null && mounted) setState(() => _toAccount = acc);
      }
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (_fromAccount == null || _toAccount == null) {
      ToastUtils.showErrorToast(
          context, ref, l10n.pleaseSelectBothAccounts);
      return;
    }
    if (_fromAccount!.uuid == _toAccount!.uuid) {
      ToastUtils.showErrorToast(
          context, ref, l10n.sameAccountError);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final repo = ref.read(accountsRepositoryProvider);
      final now = DateTime.now();

      await repo.createTransfer(
        AccountTransfersCompanion.insert(
          uuid: const Uuid().v4(),
          fromAccountUuid: _fromAccount!.uuid,
          toAccountUuid: _toAccount!.uuid,
          amount: amount,
          date: _selectedDate,
          description: drift.Value(_descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim()),
          createdAt: drift.Value(now),
          updatedAt: drift.Value(now),
        ),
      );

      if (mounted) {
        ToastUtils.showSuccessToast(context, ref, l10n.transferCreated);
        Navigator.pop(context);
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
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final decimalPlaces = ref.watch(currencyDecimalPlacesProvider);
    final dateFormat = ref.watch(userProfileProvider).dateFormat;
    final isLight = theme.brightness == Brightness.light;
    final sheetBg = isLight ? Colors.white : theme.scaffoldBackgroundColor;
    final tileFill = isLight ? Colors.white : null;
    final softBorder = theme.colorScheme.primary.withValues(alpha: 0.12);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sheet handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.transferMoney,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                ),
                children: [
                  // Amount card — clean white in light mode
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isLight ? Colors.white : theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: isLight
                          ? Border.all(color: softBorder, width: 1)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary
                              .withValues(alpha: isLight ? 0.05 : 0.08),
                          blurRadius: isLight ? 14 : 20,
                          offset: Offset(0, isLight ? 5 : 8),
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
                            color: theme.colorScheme.primary,
                          ),
                          decoration: InputDecoration(
                            prefixText: '$currencySymbol ',
                            prefixStyle:
                                theme.textTheme.displayMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            border: InputBorder.none,
                            hintText:
                                AmountFormatter.formatAmount(0, decimalPlaces),
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

                  const SizedBox(height: 20),

                  // From account (exclude To account from list)
                  AccountPickerField(
                    selectedAccount: _fromAccount,
                    label: l10n.fromAccount,
                    excludeAccountUuid: _toAccount?.uuid,
                    surfaceColor: tileFill,
                    onChanged: (acc) => setState(() => _fromAccount = acc),
                  ),

                  const SizedBox(height: 12),

                  // Transfer direction indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_downward_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // To account (exclude From account from list)
                  AccountPickerField(
                    selectedAccount: _toAccount,
                    label: l10n.toAccount,
                    excludeAccountUuid: _fromAccount?.uuid,
                    surfaceColor: tileFill,
                    onChanged: (acc) => setState(() => _toAccount = acc),
                  ),

                  const SizedBox(height: 16),

                  // Date selector
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tileFill ?? theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isLight ? softBorder : theme.dividerColor,
                        ),
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
                                l10n.date,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppDateFormatter.formatDate(
                                  _selectedDate,
                                  pattern: dateFormat,
                                ),
                                style:
                                    theme.textTheme.titleMedium?.copyWith(
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

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: l10n.descriptionOptional,
                      prefixIcon: const Icon(Icons.notes_outlined),
                      filled: isLight,
                      fillColor: isLight ? Colors.white : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isLight ? softBorder : theme.dividerColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isLight ? softBorder : theme.dividerColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      label: l10n.recordTransfer,
                      gradient: AppColors.getPrimaryGradient(
                        theme.colorScheme.primary,
                      ),
                      icon: Symbols.swap_horiz,
                      isLoading: _isLoading,
                      onPressed: _save,
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
