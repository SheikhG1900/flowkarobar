import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  final String? initialName;
  final String? initialType;

  const AddCategoryScreen({
    super.key,
    this.initialName,
    this.initialType,
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
    } else if (_selectedType == 'EXPENSE' && _selectedColor == AppColors.incomeColor) {
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(categoriesRepositoryProvider);
      
      final categoryId = await repository.createCategory(
        CategoriesCompanion(
          name: drift.Value(_nameController.text.trim()),
          icon: drift.Value(_selectedIcon),
          color: drift.Value('#${(_selectedColor.r * 255).toInt().toRadixString(16).padLeft(2, '0')}${(_selectedColor.g * 255).toInt().toRadixString(16).padLeft(2, '0')}${(_selectedColor.b * 255).toInt().toRadixString(16).padLeft(2, '0')}'),
          type: drift.Value(_selectedType),
          isDefault: const drift.Value(false),
        ),
      );
      
      // Fetch the created category to return it
      final newCategory = await repository.getCategoryById(categoryId);

      if (mounted) {
        Navigator.pop(context, newCategory); // Return the created category
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Category'),
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
                segments: const [
                  ButtonSegment(
                    value: 'EXPENSE',
                    label: Text('Expense'),
                    icon: Icon(Icons.money_off),
                  ),
                  ButtonSegment(
                    value: 'INCOME',
                    label: Text('Income'),
                    icon: Icon(Icons.attach_money),
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
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _selectedType == 'EXPENSE' 
                          ? AppColors.expenseColor.withValues(alpha: 0.2)
                          : AppColors.incomeColor.withValues(alpha: 0.2);
                    }
                    return Colors.transparent;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
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
                    IconData(int.parse(_selectedIcon), fontFamily: 'MaterialIcons'),
                    color: _selectedColor,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  prefixIcon: Icon(Icons.label_outline),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Smart Suggestions
              if (_suggestedIcons.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Suggested Icons',
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
                      final isSelected = _selectedIcon == icon.codePoint.toString();
                      
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = icon.codePoint.toString()),
                        child: Container(
                          width: 50,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: Theme.of(context).colorScheme.primary)
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
                'Color',
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
                            ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3)
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
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Icon Picker
              Text(
                'All Icons',
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
                    final isSelected = _selectedIcon == icon.codePoint.toString();
                    
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon.codePoint.toString()),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: Theme.of(context).colorScheme.primary)
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

              // Submit Button
              GradientButton(
                label: 'Save Category',
                gradient: _selectedType == 'EXPENSE' 
                    ? AppColors.expenseGradient 
                    : AppColors.incomeGradient,
                isLoading: _isLoading,
                onPressed: _saveCategory,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
