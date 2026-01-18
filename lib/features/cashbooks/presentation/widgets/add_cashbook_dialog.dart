import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';

import 'package:material_symbols_icons/symbols.dart';

class AddCashbookDialog extends ConsumerStatefulWidget {
  final Cashbook? cashbook;

  const AddCashbookDialog({super.key, this.cashbook});

  @override
  ConsumerState<AddCashbookDialog> createState() => _AddCashbookDialogState();
}

class _AddCashbookDialogState extends ConsumerState<AddCashbookDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedColor;
  late String _selectedIcon;
  bool _isLoading = false;

  final List<String> _availableColors = [
    '#2196F3', // Blue
    '#00BCD4', // Cyan
    '#009688', // Teal
    '#4CAF50', // Green
    '#8BC34A', // Light Green
    '#CDDC39', // Lime
    '#FFEB3B', // Yellow
    '#FFC107', // Amber
    '#FF9800', // Orange
    '#FF5722', // Deep Orange
    '#F44336', // Red
    '#E91E63', // Pink
    '#9C27B0', // Purple
    '#673AB7', // Deep Purple
    '#3F51B5', // Indigo
    '#795548', // Brown
    '#607D8B', // Blue Grey
    '#9E9E9E', // Grey
  ];

  // Curated list of icons for cashbooks
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
    _selectedColor = widget.cashbook?.colorCode ?? _availableColors.first;

    // Normalize legacy icon names
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
    final isDark = theme.brightness == Brightness.dark;
    final isEdit = widget.cashbook != null;
    final limits = ref.watch(cashbookLimitsProvider);

    return AlertDialog(
      title: Text(isEdit ? 'Edit Cashbook' : 'New Cashbook'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isEdit && !limits.canAdd)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock,
                          size: 16, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Free limit reached (Max 2). Upgrade to Premium for unlimited cashbooks.',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Cashbook Name',
                  hintText: 'e.g. Travel, Home Construction',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                enabled: isEdit || limits.canAdd,
              ),
              const SizedBox(height: 24),
              Text('Icon', style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                width: double.maxFinite,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _cashbookIcons.length,
                  itemBuilder: (context, index) {
                    final iconData = _cashbookIcons[index];
                    final iconCode = iconData.codePoint.toString();
                    final isSelected = _selectedIcon == iconCode;
                    final color = Color(
                        int.parse(_selectedColor.replaceAll('#', '0xFF')));
                    return InkWell(
                      onTap: (isEdit || limits.canAdd)
                          ? () => setState(() => _selectedIcon = iconCode)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.2)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? color : theme.dividerColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          iconData,
                          color: isSelected
                              ? color
                              : theme.iconTheme.color?.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text('Color', style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                width: double.maxFinite,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _availableColors.length,
                  itemBuilder: (context, index) {
                    final colorHex = _availableColors[index];
                    final color =
                        Color(int.parse(colorHex.replaceAll('#', '0xFF')));
                    final isSelected = _selectedColor == colorHex;
                    return InkWell(
                      onTap: (isEdit || limits.canAdd)
                          ? () => setState(() => _selectedColor = colorHex)
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: isDark ? Colors.white : Colors.black,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: isSelected
                            ? Icon(Icons.check,
                                size: 16,
                                color: color.computeLuminance() > 0.5
                                    ? Colors.black
                                    : Colors.white)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (!isEdit && !limits.canAdd)
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              PremiumGate.showPremiumDialog(context);
            },
            child: const Text('Upgrade'),
          )
        else
          FilledButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(isEdit ? 'Update' : 'Create'),
          ),
      ],
    );
  }

  Future<void> _save() async {
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
            ToastUtils.showSuccessToast(context, ref, 'Cashbook updated');
            Navigator.pop(context);
          }
        } else {
          await ref.read(cashbooksProvider.notifier).addCashbook(
                name: _nameController.text.trim(),
                colorCode: _selectedColor,
                iconCodePoint: _selectedIcon,
              );
          if (mounted) {
            ToastUtils.showSuccessToast(context, ref, 'Cashbook created');
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showErrorToast(context, ref, 'Error: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
