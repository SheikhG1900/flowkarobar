import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/shared/widgets/limit_countdown_badge.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  final String? initialName;
  final String? initialType;
  final String? initialColor;
  final String? initialIcon;

  const AddCategoryScreen({
    super.key,
    this.initialName,
    this.initialType,
    this.initialColor,
    this.initialIcon,
  });

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String _selectedType = 'EXPENSE';
  String _selectedIcon = '58668'; // Default to Icons.restaurant
  Color _selectedColor = AppColors.expenseColor;
  bool _isLoading = false;

  // Smart Suggestions
  List<IconData> _suggestedIcons = [];

  final List<Color> _colors = [
    const Color(0xFFFF5252), // Red
    const Color(0xFFFF6F00), // Amber
    const Color(0xFFE91E63), // Pink
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFF2196F3), // Blue
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFF009688), // Teal
    const Color(0xFF4CAF50), // Green
    const Color(0xFF8BC34A), // Light Green
    const Color(0xFFCDDC39), // Lime
    const Color(0xFFFFC107), // Yellow
    const Color(0xFF795548), // Brown
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFF212121), // Black/Grey
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
      _updateColorForType();
    }

    if (widget.initialColor != null) {
      try {
        _selectedColor =
            Color(int.parse(widget.initialColor!.replaceAll('#', '0xFF')));
      } catch (_) {}
    }

    if (widget.initialIcon != null) {
      _selectedIcon = widget.initialIcon!;
    }

    // Initial suggestions check
    if (widget.initialName != null && widget.initialName!.isNotEmpty) {
      _updateSuggestions();
    }

    _nameController.addListener(_updateSuggestions);
  }

  void _updateSuggestions() {
    final suggestions = IconHelper.getSuggestedIcons(_nameController.text);
    if (suggestions.isNotEmpty && _suggestedIcons != suggestions) {
      setState(() {
        _suggestedIcons = suggestions;
      });
    } else if (suggestions.isEmpty && _suggestedIcons.isNotEmpty) {
      setState(() {
        _suggestedIcons = [];
      });
    }
  }

  void _updateColorForType() {
    if (_selectedType == 'INCOME' && _selectedColor == AppColors.expenseColor) {
      _selectedColor = AppColors.incomeColor;
    } else if (_selectedType == 'EXPENSE' &&
        _selectedColor == AppColors.incomeColor) {
      _selectedColor = AppColors.expenseColor;
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateSuggestions);
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    final l10n = AppLocalizations.of(context)!;
    // Check limits - call the method directly to get accurate current limits
    final isPremium = PremiumGate.isPremium(ref);
    if (!isPremium) {
      final limits = await PremiumGate.getCategoryLimits(ref);
      if (!limits.canAdd) {
        if (mounted) {
          PremiumGate.showPremiumDialog(context);
        }
        return;
      }
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(categoriesRepositoryProvider);
      final newUuid = const Uuid().v4();

      await repository.createCategory(
        CategoriesCompanion(
          uuid: drift.Value(newUuid),
          name: drift.Value(_nameController.text.trim()),
          icon: drift.Value(_selectedIcon),
          color: drift.Value(
              '#${(_selectedColor.r * 255).toInt().toRadixString(16).padLeft(2, '0')}${(_selectedColor.g * 255).toInt().toRadixString(16).padLeft(2, '0')}${(_selectedColor.b * 255).toInt().toRadixString(16).padLeft(2, '0')}'),
          type: drift.Value(_selectedType),
          isDefault: const drift.Value(false),
        ),
      );

      final newCategory = await repository.getCategoryByUuid(newUuid);

      if (mounted) {
        Navigator.pop(context, newCategory); // Return the created category
        ToastUtils.showSuccessToast(
            context, ref, l10n.categoryAddedSuccessfully);
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

  @override
  Widget build(BuildContext context) {
    final limitsAsync = ref.watch(categoryLimitsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addCategory),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Toggle
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'EXPENSE',
                    label: Text(l10n.expense),
                    icon: const Icon(Symbols.money_off),
                  ),
                  ButtonSegment(
                    value: 'INCOME',
                    label: Text(l10n.income),
                    icon: const Icon(Symbols.attach_money),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                    _updateColorForType();
                  });
                },
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _selectedType == 'EXPENSE'
                          ? AppColors.expenseColor.withValues(alpha: 0.2)
                          : AppColors.incomeColor.withValues(alpha: 0.2);
                    }
                    return Colors.transparent;
                  }),
                  foregroundColor:
                      WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _selectedType == 'EXPENSE'
                          ? AppColors.expenseColor
                          : AppColors.incomeColor;
                    }
                    return Theme.of(context).colorScheme.onSurface;
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Preview
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _selectedColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedColor,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    IconHelper.getIconData(_selectedIcon),
                    color: _selectedColor,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.categoryName,
                  prefixIcon: const Icon(Icons.label_outline),
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Smart Suggestions
              if (_suggestedIcons.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 16, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.suggestedIcons,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _suggestedIcons.length,
                    itemBuilder: (context, index) {
                      final icon = _suggestedIcons[index];
                      final isSelected =
                          _selectedIcon == icon.codePoint.toString();

                      return GestureDetector(
                        onTap: () => setState(
                            () => _selectedIcon = icon.codePoint.toString()),
                        child: Container(
                          width: 50,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            icon,
                            size: 24,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Color Picker
              Text(
                l10n.color,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == color
                            ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 3)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _selectedColor == color
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Icon Picker
              Text(
                l10n.allIcons,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Container(
                height: 300, // Increased height for more icons
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: IconHelper.allIcons.length,
                  itemBuilder: (context, index) {
                    final icon = IconHelper.allIcons[index];
                    final isSelected =
                        _selectedIcon == icon.codePoint.toString();

                    return GestureDetector(
                      onTap: () => setState(
                          () => _selectedIcon = icon.codePoint.toString()),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          icon,
                          size: 24,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Countdown Badge (show until limit reached)
              if (limitsAsync.asData?.value != null &&
                  !limitsAsync.asData!.value.isUnlimited &&
                  limitsAsync.asData!.value.canAdd)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: LimitCountdownBadge(
                      totalUsed: limitsAsync.asData!.value.used,
                      totalLimit: limitsAsync.asData!.value.total,
                    ),
                  ),
                ),

              // Submit Button with Lock Icon (only when limit reached)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  GradientButton(
                    label: l10n.saveCategory,
                    gradient: _selectedType == 'EXPENSE'
                        ? AppColors.expenseGradient
                        : AppColors.incomeGradient,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _saveCategory,
                    width: double.infinity,
                  ),
                  if (limitsAsync.asData?.value != null &&
                      !limitsAsync.asData!.value.canAdd)
                    const Padding(
                      padding: EdgeInsets.only(top: 8, right: 8),
                      child: Icon(Icons.lock, size: 16, color: Colors.white),
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
