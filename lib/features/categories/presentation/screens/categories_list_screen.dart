import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/categories/presentation/screens/add_category_screen.dart';
import 'package:flowpaisa/shared/widgets/glass_card.dart';

class CategoriesListScreen extends ConsumerStatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  ConsumerState<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends ConsumerState<CategoriesListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _tabController.index == 0 ? AppColors.expenseColor : AppColors.incomeColor,
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
          ],
          onTap: (index) {
            setState(() {}); // Rebuild to update indicator color
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CategoryList(type: 'EXPENSE'),
          _CategoryList(type: 'INCOME'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCategoryScreen(),
            ),
          );
        },
        backgroundColor: _tabController.index == 0 ? AppColors.expenseColor : AppColors.incomeColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  final String type;

  const _CategoryList({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesByTypeProvider(type));

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No $type categories',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryCard(category: category);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final dynamic category; // Using dynamic to avoid import issues

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = category.type == 'EXPENSE';
    final color = category.color != null 
        ? Color(int.parse(category.color!.replaceAll('#', '0xFF'))) 
        : (isExpense ? AppColors.expenseColor : AppColors.incomeColor);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: theme.brightness == Brightness.dark ? 0.1 : 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: _buildCategoryIcon(category.icon, color, isExpense),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                category.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (category.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Default',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String? iconString, Color color, bool isExpense) {
    if (iconString == null) {
      return Icon(
        isExpense ? Icons.money_off : Icons.attach_money,
        color: color,
        size: 24,
      );
    }
    
    // Try to parse as integer (code point for IconData)
    final int? codePoint = int.tryParse(iconString);
    if (codePoint != null) {
      return Icon(
        IconData(codePoint, fontFamily: 'MaterialIcons'),
        color: color,
        size: 24,
      );
    }
    
    // Fallback to text (emoji) for legacy data
    return Text(
      iconString,
      style: const TextStyle(fontSize: 24),
    );
  }
}

