import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';

class EditCategoryScreen extends ConsumerStatefulWidget {
  final Category category;

  const EditCategoryScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends ConsumerState<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedIcon;
  late Color _selectedColor;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Use didChangeDependencies to access context for localization
    _nameController = TextEditingController(
        text: widget.category.name.localizeCategory(context));
    _selectedIcon = widget.category.icon ?? '58668';

    // Parse color from category
    if (widget.category.color != null) {
      try {
        _selectedColor =
            Color(int.parse(widget.category.color!.replaceAll('#', '0xFF')));
      } catch (e) {
        _selectedColor = widget.category.type == 'EXPENSE'
            ? AppColors.expenseColor
            : AppColors.incomeColor;
      }
    } else {
      _selectedColor = widget.category.type == 'EXPENSE'
          ? AppColors.expenseColor
          : AppColors.incomeColor;
    }

    // Initial suggestions check
    if (widget.category.name.isNotEmpty) {
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

  @override
  void dispose() {
    _nameController.removeListener(_updateSuggestions);
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateCategory() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(categoriesRepositoryProvider);

      // Create updated category
      final updatedCategory = widget.category.copyWith(
        name: _nameController.text.trim(),
        icon: drift.Value(_selectedIcon),
        color: drift.Value(
            '#${(_selectedColor.r * 255).toInt().toRadixString(16).padLeft(2, '0')}${(_selectedColor.g * 255).toInt().toRadixString(16).padLeft(2, '0')}${(_selectedColor.b * 255).toInt().toRadixString(16).padLeft(2, '0')}'),
      );

      final success = await repository.updateCategory(updatedCategory);

      if (mounted) {
        if (success) {
          Navigator.pop(context, true); // Return true to indicate success
          ToastUtils.showSuccessToast(
              context, ref, l10n.categoryUpdatedSuccessfully);
        } else {
          ToastUtils.showErrorToast(context, ref, l10n.failedToUpdateCategory);
        }
      }
    } catch (e, stackTrace) {
      if (mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
        // Print error for debugging
        debugPrint('Error updating category: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isExpense = widget.category.type == 'EXPENSE';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editCategory),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Display (read-only)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isExpense
                          ? AppColors.expenseColor
                          : AppColors.incomeColor)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isExpense
                            ? AppColors.expenseColor
                            : AppColors.incomeColor)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isExpense ? Symbols.money_off : Symbols.attach_money,
                      color: isExpense
                          ? AppColors.expenseColor
                          : AppColors.incomeColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isExpense ? l10n.expenseCategory : l10n.incomeCategory,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isExpense
                            ? AppColors.expenseColor
                            : AppColors.incomeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
                        size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.suggestedIcons,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
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
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: theme.colorScheme.primary)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            icon,
                            size: 24,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
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
                style: theme.textTheme.titleMedium,
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
                                color: theme.colorScheme.onSurface, width: 3)
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
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
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
                              ? theme.colorScheme.primaryContainer
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: theme.colorScheme.primary)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          icon,
                          size: 24,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Update Button
              GradientButton(
                label: l10n.updateCategory,
                gradient: isExpense
                    ? AppColors.expenseGradient
                    : AppColors.incomeGradient,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _updateCategory,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
