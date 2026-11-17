import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:flowpaisa/features/catalog/presentation/screens/add_edit_catalog_screen.dart';
import 'package:flowpaisa/features/catalog/presentation/screens/catalog_detail_screen.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/app_floating_action_button.dart';
import 'package:flowpaisa/shared/widgets/hover_border_card.dart';
import 'package:flowpaisa/shared/widgets/pending_sync_badge.dart';

class CatalogsListScreen extends ConsumerStatefulWidget {
  const CatalogsListScreen({super.key});

  @override
  ConsumerState<CatalogsListScreen> createState() => _CatalogsListScreenState();
}

class _CatalogsListScreenState extends ConsumerState<CatalogsListScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Catalog> _filtered(List<Catalog> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((c) {
      final name = c.name.toLowerCase();
      final desc = (c.description ?? '').toLowerCase();
      return name.contains(q) || desc.contains(q);
    }).toList();
  }

  Future<void> _openEditor({Catalog? existing}) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCatalogScreen(existing: existing),
      ),
    );
  }

  Future<void> _openDetail(Catalog catalog) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => CatalogDetailScreen(catalogUuid: catalog.uuid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final accent = AppColors.receivableColor;
    final async = ref.watch(catalogsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.catalogs),
      ),
      floatingActionButton: AppFloatingActionButton(
        heroTag: 'catalogs_fab',
        backgroundColor: accent,
        foregroundColor: Colors.white,
        tooltip: l10n.newCatalog,
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorOccurred(e.toString()))),
        data: (all) {
          if (all.isEmpty) {
            return OrderEmptyState(
              icon: Icons.price_change_outlined,
              message: l10n.noCatalogsYet,
              color: accent,
            );
          }
          final items = _filtered(all);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: l10n.search,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noResultsFound,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 720 ? 2 : 1;
                          final rowCount = (items.length / columns).ceil();
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: rowCount,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, rowIndex) {
                              final start = rowIndex * columns;
                              Widget cardAt(int index) {
                                final catalog = items[index];
                                return _CatalogCard(
                                  catalog: catalog,
                                  onTap: () => _openDetail(catalog),
                                  onEdit: () =>
                                      _openEditor(existing: catalog),
                                );
                              }

                              if (columns == 1) {
                                return cardAt(start);
                              }

                              return IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    for (var i = 0; i < columns; i++) ...[
                                      if (i > 0) const SizedBox(width: 12),
                                      Expanded(
                                        child: start + i < items.length
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
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CatalogCard extends ConsumerWidget {
  final Catalog catalog;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _CatalogCard({
    required this.catalog,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accent = AppColors.receivableColor;
    final muted = theme.colorScheme.onSurfaceVariant;
    final itemsAsync = ref.watch(catalogItemsStreamProvider(catalog.uuid));
    final itemCount = itemsAsync.value?.length ?? 0;
    final desc = catalog.description?.trim();
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final validUntil = catalog.validUntil;
    final isExpired = validUntil != null &&
        validUntil.isBefore(
          DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
        );

    return HoverBorderCard(
      accent: accent,
      onTap: onTap,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.price_change_outlined,
                          color: accent,
                        ),
                      ),
                    ),
                    if (catalog.isNotSynced == true)
                      Positioned(
                        right: -3,
                        top: -3,
                        child: Tooltip(
                          message: l10n.pendingSync,
                          child: const PendingSyncCornerBadge(iconSize: 11),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: catalog.name, style: titleStyle),
                          if (catalog.isDefault)
                            WidgetSpan(
                              alignment: PlaceholderAlignment.top,
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  start: 3,
                                  top: 1,
                                ),
                                child: Tooltip(
                                  message: l10n.defaultCatalog,
                                  child: Icon(
                                    Icons.star_rounded,
                                    size: 13,
                                    color: accent,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (desc != null && desc.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        desc,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isExpired) ...[
                    Tooltip(
                      message:
                          '${l10n.catalogValidUntil}: ${AppDateFormatter.formatDate(validUntil)}',
                      child: OrderStatusChip(
                        label: l10n.expired,
                        color: AppColors.warning,
                        icon: Icons.event_busy_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$itemCount',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onEdit,
            child: Text(l10n.editCatalog),
          ),
        ],
      ),
    );
  }
}
