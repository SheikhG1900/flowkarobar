import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_sale_pick.dart';
import 'package:flowpaisa/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/add_contact_screen.dart';
import 'package:flowpaisa/features/categories/presentation/screens/add_category_screen.dart';
import 'package:flowpaisa/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:flowpaisa/features/inventory/presentation/screens/add_product_screen.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart' show Category;
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/entity_picker_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';

Color parseCategoryColor(String? hex, [Color fallback = AppColors.expenseColor]) {
  if (hex == null || hex.isEmpty) return fallback;
  try {
    return Color(int.parse(hex.replaceAll('#', '0xFF')));
  } catch (_) {
    return fallback;
  }
}

IconData categoryIconData(ProductCategory? category) {
  return IconHelper.getIconData(category?.icon) ?? Symbols.category;
}

Widget productLeadingAvatar({
  required Product product,
  ProductCategory? category,
}) {
  final color = parseCategoryColor(category?.color, AppColors.incomeColor);
  return categoryLeadingAvatar(color: color, icon: categoryIconData(category));
}

/// Returns confirmed pick. `null` future = dismissed. Result.value null = cleared.
Future<EntityPickResult<Contact>?> showOrderContactPicker({
  required BuildContext context,
  required WidgetRef ref,
  required bool isSale,
  Contact? selected,
  bool showAll = false,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final contacts = ref.read(contactsListProvider).value ?? const <Contact>[];
  final visible = contacts
      .where((c) => showAll || (isSale ? c.isCustomer : c.isSupplier))
      .toList();

  return showEntityPickerSheet<Contact>(
    context: context,
    title: l10n.selectContact,
    selected: selected,
    allowClear: true,
    clearLabel: l10n.walkInCustomer,
    searchHint: l10n.searchContacts,
    addNewLabel: l10n.addContact,
    onAddNew: () async {
      final created = await Navigator.push<Contact>(
        context,
        MaterialPageRoute(builder: (_) => const AddContactScreen()),
      );
      if (created == null) return null;
      Contact result = created;
      if (!isSale && !created.isSupplier) {
        result = created.copyWith(isSupplier: true);
        await ref.read(contactsRepositoryProvider).updateContact(result);
      } else if (isSale && !created.isCustomer) {
        result = created.copyWith(isCustomer: true);
        await ref.read(contactsRepositoryProvider).updateContact(result);
      }
      ref.invalidate(contactsListProvider);
      return result;
    },
    items: [
      for (final c in visible)
        EntityPickerItem(
          value: c,
          title: c.name,
          subtitle: c.phone,
          leading: contactLeadingAvatar(c.name),
        ),
    ],
  );
}

Future<EntityPickResult<Product>?> showOrderProductPicker({
  required BuildContext context,
  required WidgetRef ref,
  Product? selected,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final products = ref.read(productsStreamProvider).value ?? const <Product>[];
  final categories = ref.read(productCategoriesStreamProvider).value ??
      const <ProductCategory>[];
  final byId = {for (final c in categories) c.uuid: c};

  return showEntityPickerSheet<Product>(
    context: context,
    title: l10n.selectProduct,
    selected: selected,
    searchHint: l10n.search,
    addNewLabel: l10n.addProduct,
    onAddNew: () async {
      final created = await Navigator.push<Product>(
        context,
        MaterialPageRoute(builder: (_) => const AddProductScreen()),
      );
      ref.invalidate(productsStreamProvider);
      return created;
    },
    items: [
      for (final p in products)
        EntityPickerItem(
          value: p,
          title: p.name,
          subtitle: p.isService
              ? l10n.isServiceProduct
              : l10n.stockLabel(
                  AmountFormatter.formatQuantity(p.stockQuantity),
                ),
          leading: productLeadingAvatar(
            product: p,
            category: p.categoryUuid == null ? null : byId[p.categoryUuid],
          ),
        ),
    ],
  );
}

/// Bottom drawer to pick which active catalog drives this sale.
Future<EntityPickResult<Catalog>?> showOrderCatalogPicker({
  required BuildContext context,
  required WidgetRef ref,
  required List<Catalog> catalogs,
  Catalog? selected,
  Set<String> openCatalogUuids = const {},
}) async {
  final l10n = AppLocalizations.of(context)!;
  return showEntityPickerSheet<Catalog>(
    context: context,
    title: l10n.selectCatalog,
    selected: selected,
    searchHint: l10n.search,
    items: [
      for (final c in catalogs)
        EntityPickerItem(
          value: c,
          title: c.name,
          subtitle: () {
            final parts = <String>[
              if (c.isDefault) l10n.defaultCatalog,
              if (openCatalogUuids.contains(c.uuid))
                l10n.catalogAvailableToAll,
            ];
            return parts.isEmpty ? null : parts.join(' · ');
          }(),
          leading: categoryLeadingAvatar(
            color: AppColors.receivableColor,
            icon: Icons.price_change_outlined,
          ),
        ),
    ],
  );
}

/// Sale picker from a resolved catalog (name + stored sell price).
Future<EntityPickResult<CatalogSalePick>?> showOrderCatalogItemPicker({
  required BuildContext context,
  required WidgetRef ref,
  required String catalogUuid,
  String? catalogName,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final catalogRepo = ref.read(catalogRepositoryProvider);

  final items = await catalogRepo.getItems(catalogUuid);
  final categories = ref.read(productCategoriesStreamProvider).value ??
      const <ProductCategory>[];
  final byCategory = {for (final c in categories) c.uuid: c};

  final picks = <CatalogSalePick>[];
  for (final item in items) {
    final pick = await catalogRepo.buildSalePick(item);
    if (pick != null) picks.add(pick);
  }

  if (!context.mounted) return null;

  return showEntityPickerSheet<CatalogSalePick>(
    context: context,
    title: catalogName == null || catalogName.trim().isEmpty
        ? l10n.selectCatalogItem
        : l10n.selectFromCatalog(catalogName),
    searchHint: l10n.search,
    items: [
      for (final pick in picks)
        EntityPickerItem(
          value: pick,
          title: pick.displayName,
          subtitle: [
            formatOrderAmount(ref, pick.sellPrice),
            if (pick.unit.isNotEmpty) '/ ${pick.unit}',
            if (pick.sellingProduct != null) ' · ${l10n.sellingProductOffer}',
          ].join(),
          leading: pick.product != null
              ? productLeadingAvatar(
                  product: pick.product!,
                  category: pick.categoryUuid == null
                      ? null
                      : byCategory[pick.categoryUuid],
                )
              : categoryLeadingAvatar(
                  color: parseCategoryColor(
                    pick.categoryUuid == null
                        ? null
                        : byCategory[pick.categoryUuid]?.color,
                    AppColors.receivableColor,
                  ),
                  icon: pick.categoryUuid == null
                      ? Icons.sell_outlined
                      : categoryIconData(byCategory[pick.categoryUuid]),
                ),
        ),
    ],
  );
}

Future<EntityPickResult<ProductCategory>?> showProductCategoryPicker({
  required BuildContext context,
  required WidgetRef ref,
  ProductCategory? selected,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final categories = ref.read(productCategoriesStreamProvider).value ??
      const <ProductCategory>[];

  return showEntityPickerSheet<ProductCategory>(
    context: context,
    title: l10n.selectCategory,
    selected: selected,
    allowClear: true,
    clearLabel: l10n.none,
    searchHint: l10n.search,
    addNewLabel: l10n.addCategory,
    onAddNew: () async {
      final created = await Navigator.push<Category>(
        context,
        MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
      );
      ref.invalidate(productCategoriesStreamProvider);
      if (created == null) return null;
      return ref.read(inventoryRepositoryProvider).getCategory(created.uuid);
    },
    items: [
      for (final c in categories)
        EntityPickerItem(
          value: c,
          title: c.name,
          leading: categoryLeadingAvatar(
            color: parseCategoryColor(c.color),
            icon: categoryIconData(c),
          ),
        ),
    ],
  );
}
