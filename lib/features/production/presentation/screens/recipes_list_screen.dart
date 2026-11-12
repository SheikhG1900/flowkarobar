import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flowpaisa/features/production/presentation/providers/production_provider.dart';
import 'package:flowpaisa/features/production/presentation/screens/add_recipe_screen.dart';
import 'package:flowpaisa/features/production/presentation/screens/production_order_detail_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/app_floating_action_button.dart';
import 'package:flowpaisa/shared/widgets/hover_border_card.dart';

class RecipesListScreen extends ConsumerWidget {
  /// When false, used as a tab body under [ProductionOrdersListScreen].
  final bool showAppBar;

  const RecipesListScreen({super.key, this.showAppBar = true});

  Future<void> _produce(
    BuildContext context,
    WidgetRef ref,
    Recipe recipe,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final scale = await showDialog<double>(
      context: context,
      builder: (context) => _ProduceFromRecipeDialog(recipe: recipe),
    );
    if (scale == null || !context.mounted) return;

    try {
      final orderUuid =
          await ref.read(recipeRepositoryProvider).createProductionFromRecipe(
                recipeUuid: recipe.uuid,
                scaleFactor: scale,
              );
      if (!context.mounted) return;
      ToastUtils.showSuccessToast(context, ref, l10n.productionSaved);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductionOrderDetailScreen(orderUuid: orderUuid),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recipesAsync = ref.watch(recipesStreamProvider);

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(l10n.recipes),
            )
          : null,
      floatingActionButton: AppFloatingActionButton(
        heroTag: 'recipes_fab',
        backgroundColor: AppColors.info,
        foregroundColor: Colors.white,
        tooltip: l10n.newRecipe,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRecipeScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: recipesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorOccurred(e.toString()))),
        data: (recipes) {
          if (recipes.isEmpty) {
            return OrderEmptyState(
              icon: Icons.menu_book_outlined,
              message: l10n.noRecipesYet,
              color: AppColors.info,
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 720 ? 2 : 1;
              final rowCount = (recipes.length / columns).ceil();
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: rowCount,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, rowIndex) {
                  final start = rowIndex * columns;
                  Widget cardAt(int index) {
                    final recipe = recipes[index];
                    return _RecipeCard(
                      recipe: recipe,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddRecipeScreen(
                              existingUuid: recipe.uuid,
                            ),
                          ),
                        );
                      },
                      onProduce: () => _produce(context, ref, recipe),
                    );
                  }

                  if (columns == 1) {
                    return cardAt(start);
                  }

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < columns; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          Expanded(
                            child: start + i < recipes.length
                                ? cardAt(start + i)
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _RecipeCard extends ConsumerWidget {
  final Recipe recipe;
  final VoidCallback onEdit;
  final VoidCallback onProduce;

  const _RecipeCard({
    required this.recipe,
    required this.onEdit,
    required this.onProduce,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accent = AppColors.info;
    final muted = theme.colorScheme.onSurfaceVariant;
    final outputsAsync = ref.watch(recipeOutputsStreamProvider(recipe.uuid));
    final inputsAsync = ref.watch(recipeInputsStreamProvider(recipe.uuid));

    final outputs = outputsAsync.value ?? const <RecipeOutput>[];
    final inputs = inputsAsync.value ?? const <RecipeInput>[];
    final notes = recipe.notes?.trim();

    return HoverBorderCard(
      accent: accent,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (notes != null && notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notes,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _CountBadge(
                count: outputs.length,
                accent: accent,
                tooltip: l10n.sectionOutputs,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.sectionOutputs,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: muted,
            ),
          ),
          const SizedBox(height: 8),
          if (outputsAsync.isLoading && outputs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (outputs.isEmpty)
            Text(
              l10n.noResultsFound,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            )
          else
            ...[
              for (var i = 0; i < outputs.length; i++) ...[
                if (i > 0) const SizedBox(height: 6),
                _LineQtyRow(
                  name: outputs[i].productNameSnapshot,
                  quantity: outputs[i].quantity,
                  unit: outputs[i].unit,
                  accent: AppColors.incomeColor,
                ),
              ],
            ],
          if (inputs.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '${l10n.sectionInputs}: ${inputs.length}',
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEdit,
                  child: Text(l10n.editRecipe),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onProduce,
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(l10n.produceFromRecipe),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.incomeColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProduceFromRecipeDialog extends ConsumerStatefulWidget {
  final Recipe recipe;

  const _ProduceFromRecipeDialog({required this.recipe});

  @override
  ConsumerState<_ProduceFromRecipeDialog> createState() =>
      _ProduceFromRecipeDialogState();
}

class _ProduceFromRecipeDialogState
    extends ConsumerState<_ProduceFromRecipeDialog> {
  late final TextEditingController _scale;
  double _scaleValue = 1;

  @override
  void initState() {
    super.initState();
    _scale = TextEditingController(text: '1');
    _scale.addListener(_onScaleChanged);
  }

  @override
  void dispose() {
    _scale.removeListener(_onScaleChanged);
    _scale.dispose();
    super.dispose();
  }

  void _onScaleChanged() {
    final n = double.tryParse(_scale.text.trim());
    final next = (n != null && n > 0) ? n : 0.0;
    if ((next - _scaleValue).abs() < 1e-12) return;
    setState(() => _scaleValue = next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final muted = theme.colorScheme.onSurfaceVariant;
    final outputsAsync =
        ref.watch(recipeOutputsStreamProvider(widget.recipe.uuid));
    final inputsAsync =
        ref.watch(recipeInputsStreamProvider(widget.recipe.uuid));
    final outputs = outputsAsync.value ?? const <RecipeOutput>[];
    final inputs = inputsAsync.value ?? const <RecipeInput>[];
    final scaleValid = _scaleValue > 0;

    return AlertDialog(
      title: Text(l10n.produceFromRecipe),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.recipe.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _scale,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.scaleFactor,
                  helperText: l10n.scaleFactorHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.sectionOutputs,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (outputsAsync.isLoading && outputs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (outputs.isEmpty)
                Text(
                  l10n.noResultsFound,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.incomeColor.withValues(alpha: 0.2),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    children: [
                      for (var i = 0; i < outputs.length; i++) ...[
                        if (i > 0) const Divider(height: 12),
                        _ScaledLineRow(
                          name: outputs[i].productNameSnapshot,
                          baseQty: outputs[i].quantity,
                          scale: _scaleValue,
                          unit: outputs[i].unit,
                          accent: AppColors.incomeColor,
                          scaleValid: scaleValid,
                        ),
                      ],
                    ],
                  ),
                ),
              if (inputs.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  l10n.sectionInputs,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.expenseColor.withValues(alpha: 0.18),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    children: [
                      for (var i = 0; i < inputs.length; i++) ...[
                        if (i > 0) const Divider(height: 12),
                        _ScaledLineRow(
                          name: inputs[i].productNameSnapshot,
                          baseQty: inputs[i].quantity,
                          scale: _scaleValue,
                          unit: inputs[i].unit,
                          accent: AppColors.expenseColor,
                          scaleValid: scaleValid,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: !scaleValid
              ? null
              : () => Navigator.pop(context, _scaleValue),
          child: Text(l10n.produceFromRecipe),
        ),
      ],
    );
  }
}

class _LineQtyRow extends StatelessWidget {
  final String name;
  final double quantity;
  final String unit;
  final Color accent;

  const _LineQtyRow({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Keep qty + unit in LTR so RTL does not reverse them.
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AmountFormatter.formatQuantity(quantity),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaledLineRow extends StatelessWidget {
  final String name;
  final double baseQty;
  final double scale;
  final String unit;
  final Color accent;
  final bool scaleValid;

  const _ScaledLineRow({
    required this.name,
    required this.baseQty,
    required this.scale,
    required this.unit,
    required this.accent,
    required this.scaleValid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final scaled = scaleValid ? baseQty * scale : null;
    final showBase = scaleValid && (scale - 1).abs() > 1e-9;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                name,
                textAlign: TextAlign.start,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      scaled == null
                          ? '—'
                          : AmountFormatter.formatQuantity(scaled),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: accent,
                        height: 1,
                      ),
                    ),
                    if (scaled != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: muted,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ],
                  ],
                ),
                if (showBase)
                  Text(
                    '${AmountFormatter.formatQuantity(baseQty)} × ${AmountFormatter.formatQuantity(scale)}',
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color accent;
  final String tooltip;

  const _CountBadge({
    required this.count,
    required this.accent,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
                child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          '$count',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: accent,
          ),
        ),
      ),
    );
  }
}
