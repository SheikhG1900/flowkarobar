import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/categories/presentation/screens/add_category_screen.dart';
import 'package:flowpaisa/features/categories/presentation/screens/edit_category_screen.dart';
import 'package:flowpaisa/features/categories/presentation/screens/category_details_screen.dart';
import 'package:flowpaisa/shared/widgets/glass_card.dart';
import 'package:flowpaisa/shared/widgets/swipeable_list_item.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';

class CategoriesListScreen extends ConsumerStatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  ConsumerState<CategoriesListScreen> createState() =>
      _CategoriesListScreenState();
}

class _CategoriesListScreenState extends ConsumerState<CategoriesListScreen>
    with SingleTickerProviderStateMixin {
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categories),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _tabController.index == 0
              ? AppColors.expenseColor
              : AppColors.incomeColor,
          tabs: [
            Tab(text: l10n.expense),
            Tab(text: l10n.income),
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
        backgroundColor: _tabController.index == 0
            ? AppColors.expenseColor
            : AppColors.incomeColor,
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
    final l10n = AppLocalizations.of(context)!;

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          final typeLabel = type == 'EXPENSE' ? l10n.expense : l10n.income;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Symbols.category,
                  size: 80,
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noTypeCategories(typeLabel),
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
      error: (error, stack) => Center(child: Text(l10n.errorOccurred(error.toString()))),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  final Category category;

  const _CategoryCard({required this.category});

  Future<void> _deleteCategory(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(categoriesRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;

    // Check if category has transactions
    final hasTransactions =
        await repository.categoryHasTransactions(category.uuid);

    if (!context.mounted) return;

    try {
      await repository.softDeleteCategory(category.uuid);
      if (context.mounted) {
        ToastUtils.showSuccessToast(
          context,
          ref,
          hasTransactions
              ? l10n.categoryHiddenSuccessfully
              : l10n.categoryDeletedSuccessfully,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isExpense = category.type == 'EXPENSE';
    final color = category.color != null
        ? Color(int.parse(category.color!.replaceAll('#', '0xFF')))
        : (isExpense ? AppColors.expenseColor : AppColors.incomeColor);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SwipeableListItem(
        enableEdit: true,
        enableDelete: !category.isDefault,
        editBackgroundColor: color,
        deleteBackgroundColor: AppColors.error,
        borderRadius: 16,
        backgroundMargin: const EdgeInsets.only(bottom: 12),
        onEdit: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditCategoryScreen(category: category),
            ),
          );
        },
        onDelete: category.isDefault
            ? null
            : () async {
                await _deleteCategory(context, ref);
              },
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CategoryDetailsScreen(categoryUuid: category.uuid),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: 'category_icon_${category.uuid}',
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(
                          alpha:
                              theme.brightness == Brightness.dark ? 0.1 : 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: CategoryHelper.buildCategoryIcon(
                        category.icon, color, isExpense),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    LocalizationHelper.getLocalizedCategoryName(
                        context, category.name),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (category.isDefault)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.defaultLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
