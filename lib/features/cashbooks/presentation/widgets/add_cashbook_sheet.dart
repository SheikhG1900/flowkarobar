import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';

import 'package:material_symbols_icons/symbols.dart';

import 'package:flowpaisa/l10n/app_localizations.dart';

class AddCashbookSheet extends ConsumerStatefulWidget {
  final Cashbook? cashbook;

  const AddCashbookSheet({super.key, this.cashbook});

  @override
  ConsumerState<AddCashbookSheet> createState() => _AddCashbookSheetState();
}

class _AddCashbookSheetState extends ConsumerState<AddCashbookSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedColor;
  late String _selectedIcon;
  bool _isLoading = false;

  final List<List<String>> _colorVariants = [
    ['#E3F2FD', '#90CAF9', '#2196F3', '#1976D2', '#0D47A1'], // Blue variants
    ['#E0F7FA', '#80DEEA', '#00BCD4', '#0097A7', '#006064'], // Cyan variants
    ['#E0F2F1', '#80CBC4', '#009688', '#00796B', '#004D40'], // Teal variants
    ['#E8F5E9', '#A5D6A7', '#4CAF50', '#388E3C', '#1B5E20'], // Green variants
    [
      '#F1F8E9',
      '#C5E1A5',
      '#8BC34A',
      '#689F38',
      '#33691E'
    ], // Light Green variants
    ['#F9FBE7', '#E6EE9C', '#CDDC39', '#AFB42B', '#827717'], // Lime variants
    ['#FFFDE7', '#FFF59D', '#FFEB3B', '#FBC02D', '#F57F17'], // Yellow variants
    ['#FFF8E1', '#FFE082', '#FFC107', '#FFA000', '#FF6F00'], // Amber variants
    ['#FFF3E0', '#FFCC80', '#FF9800', '#F57C00', '#E65100'], // Orange variants
    [
      '#FBE9E7',
      '#FFAB91',
      '#FF5722',
      '#E64A19',
      '#BF360C'
    ], // Deep Orange variants
    ['#FFEBEE', '#EF9A9A', '#F44336', '#D32F2F', '#B71C1C'], // Red variants
    ['#FCE4EC', '#F48FB1', '#E91E63', '#C2185B', '#880E4F'], // Pink variants
    ['#F3E5F5', '#CE93D8', '#9C27B0', '#7B1FA2', '#4A148C'], // Purple variants
    [
      '#EDE7F6',
      '#B39DDB',
      '#673AB7',
      '#512DA8',
      '#311B92'
    ], // Deep Purple variants
    ['#E8EAF6', '#9FA8DA', '#3F51B5', '#303F9F', '#1A237E'], // Indigo variants
    ['#EFEBE9', '#BCAAA4', '#795548', '#5D4037', '#3E2723'], // Brown variants
    [
      '#ECEFF1',
      '#B0BEC5',
      '#607D8B',
      '#455A64',
      '#263238'
    ], // Blue Grey variants
    ['#FAFAFA', '#EEEEEE', '#9E9E9E', '#616161', '#212121'], // Grey variants
  ];

  final List<IconData> _cashbookIcons = [
    Symbols.water_drop,
    Symbols.account_balance_wallet,
    Symbols.flight,
    Symbols.home,
    Symbols.shopping_cart,
    Symbols.restaurant,
    Symbols.directions_car,
    Symbols.work,
    Symbols.school,
    Symbols.medical_services,
    Symbols.sports_esports,
    Symbols.payments,
    Symbols.savings,
    Symbols.business_center,
    Symbols.construction,
    Symbols.celebration,
    Symbols.apartment,
    Symbols.card_giftcard,
    Symbols.pets,
    Symbols.fitness_center,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.cashbook?.name ?? '');
    _selectedColor = widget.cashbook?.colorCode ?? _colorVariants[0][0];

    String initialIcon = widget.cashbook?.iconCodePoint ??
        Symbols.water_drop.codePoint.toString();
    if (initialIcon == 'water_drop') {
      initialIcon = Symbols.water_drop.codePoint.toString();
    }
    _selectedIcon = initialIcon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final isEdit = widget.cashbook != null;
    final limits = ref.watch(cashbookLimitsProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? l10n.editCashbook : l10n.newCashbook,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (!isEdit && !limits.canAdd)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, size: 20, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.freeLimitReached,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.cashbookName,
                  hintText: l10n.cashbookNameHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.book_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterName;
                  }
                  return null;
                },
                autofocus: !isEdit,
                textCapitalization: TextCapitalization.words,
                enabled: isEdit || limits.canAdd,
              ),
              const SizedBox(height: 24),
              Text(l10n.selectIcon, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _cashbookIcons.length,
                  itemBuilder: (context, index) {
                    final iconData = _cashbookIcons[index];
                    final iconCode = iconData.codePoint.toString();
                    final isSelected = _selectedIcon == iconCode;
                    final color =
                        Color(int.parse(_selectedColor.replaceAll('#', '0xFF')));
                    return InkWell(
                      onTap: (isEdit || limits.canAdd)
                          ? () => setState(() => _selectedIcon = iconCode)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.15)
                              : theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                          border: Border.all(
                            color: isSelected ? color : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          iconData,
                          color: isSelected
                              ? color
                              : theme.iconTheme.color?.withValues(alpha: 0.5),
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(l10n.selectColor, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 260,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colorVariants.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final variants = _colorVariants[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: variants.map((colorHex) {
                        final color =
                            Color(int.parse(colorHex.replaceAll('#', '0xFF')));
                        final isSelected = _selectedColor == colorHex;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: (isEdit || limits.canAdd)
                                ? () => setState(() => _selectedColor = colorHex)
                                : null,
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color:
                                            isDark ? Colors.white : Colors.black,
                                        width: 3,
                                      )
                                    : null,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? Icon(Icons.check,
                                      size: 24,
                                      color: color.computeLuminance() > 0.5
                                          ? Colors.black
                                          : Colors.white)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              if (!isEdit && !limits.canAdd)
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    PremiumGate.showPremiumDialog(context);
                  },
                  icon: const Icon(Icons.star),
                  label: Text(l10n.upgradeToPremium),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              else
                FilledButton(
                  onPressed: _isLoading ? null : _save,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          isEdit ? l10n.updateCashbook : l10n.createCashbook,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        if (widget.cashbook != null) {
          await ref.read(cashbooksProvider.notifier).updateCashbook(
                widget.cashbook!.copyWith(
                  name: _nameController.text.trim(),
                  colorCode: _selectedColor,
                  iconCodePoint: _selectedIcon,
                ),
              );
          if (mounted) {
            ToastUtils.showSuccessToast(context, ref, l10n.cashbookUpdated);
            Navigator.pop(context);
          }
        } else {
          await ref.read(cashbooksProvider.notifier).addCashbook(
                name: _nameController.text.trim(),
                colorCode: _selectedColor,
                iconCodePoint: _selectedIcon,
              );
          if (mounted) {
            ToastUtils.showSuccessToast(context, ref, l10n.cashbookCreated);
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
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
