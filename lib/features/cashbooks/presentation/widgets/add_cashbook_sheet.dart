import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';

import 'package:material_symbols_icons/symbols.dart';

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? 'Edit Cashbook' : 'New Cashbook',
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
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, size: 20, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Free limit reached (Max 2). Upgrade to Premium for unlimited cashbooks.',
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
                labelText: 'Cashbook Name',
                hintText: 'e.g. Travel, Home Construction',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.book_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              autofocus: !isEdit,
              textCapitalization: TextCapitalization.words,
              enabled: isEdit || limits.canAdd,
            ),
            const SizedBox(height: 24),
            Text('Select Icon', style: theme.textTheme.titleMedium),
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
                  final color = Color(
                      int.parse(_selectedColor.replaceAll('#', '0xFF')));
                  return InkWell(
                    onTap: (isEdit || limits.canAdd)
                        ? () => setState(() => _selectedIcon = iconCode)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.15)
                            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        border: Border.all(
                          color: isSelected ? color : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        iconData,
                        color: isSelected ? color : theme.iconTheme.color?.withValues(alpha: 0.5),
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text('Select Color', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableColors.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final colorHex = _availableColors[index];
                  final color = Color(int.parse(colorHex.replaceAll('#', '0xFF')));
                  final isSelected = _selectedColor == colorHex;
                  return InkWell(
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
                                color: isDark ? Colors.white : Colors.black,
                                width: 3,
                              )
                            : null,
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ] : null,
                      ),
                      child: isSelected
                          ? Icon(Icons.check,
                              size: 24,
                              color: color.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white)
                          : null,
                    ),
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
                label: const Text('Upgrade to Premium'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                        isEdit ? 'Update Cashbook' : 'Create Cashbook',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
          ],
        ),
      ),
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
