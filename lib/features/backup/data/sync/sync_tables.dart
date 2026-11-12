import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';

/// Canonical sync table names and dependency order for push/pull.
///
/// Legacy cloud payloads may use `categories`; the live SQLite table is
/// `product_categories`. Use [sqlTableName] for SQL and [tableInfo] for Drift.
class SyncTables {
  SyncTables._();

  /// All syncable business tables in FK-safe apply/push order.
  static const List<String> ordered = [
    // Core
    'product_categories',
    'contacts',
    'app_currencies',
    'accounts',
    'tags',
    // Inventory
    'products',
    'product_batches',
    // Pricing catalogs
    'catalogs',
    'catalog_items',
    'catalog_assignments',
    'catalog_tiered_discounts',
    // Recipes (before production)
    'recipes',
    'recipe_inputs',
    'recipe_outputs',
    'recipe_charges',
    // Orders / receipts / returns
    'orders',
    'order_items',
    'goods_receipts',
    'goods_receipt_lines',
    'order_returns',
    'order_return_items',
    // Production
    'production_orders',
    'production_order_inputs',
    'production_order_outputs',
    'production_order_charges',
    'production_consumptions',
    // Ledger / money
    'transactions',
    'transaction_tags',
    'account_transfers',
    'receivables',
    'payables',
    'reminders',
    'transaction_schedules',
    'transaction_documents',
    'user_preferences',
  ];

  /// Date/time column names that may need DateTime → ISO8601 conversion.
  static const List<String> dateFields = [
    'date',
    'due_date',
    'received_date',
    'paid_date',
    'processed_date',
    'opening_date',
    'created_at',
    'updated_at',
    'last_sync_at',
    'reminder_date',
    'last_used',
    'last_generated_date',
    'start_date',
    'end_date',
    'order_date',
    'delivered_date',
    'received_at',
    'manufacture_date',
    'expiry_date',
    'production_date',
    'completed_at',
  ];

  /// Maps payload/legacy names to the real SQLite table name.
  static String sqlTableName(String tableName) {
    if (tableName == 'categories') return 'product_categories';
    return tableName;
  }

  static TableInfo? tableInfo(AppDatabase db, String tableName) {
    switch (sqlTableName(tableName)) {
      case 'product_categories':
        return db.productCategories;
      case 'contacts':
        return db.contacts;
      case 'accounts':
        return db.accounts;
      case 'transactions':
        return db.transactions;
      case 'account_transfers':
        return db.accountTransfers;
      case 'products':
        return db.products;
      case 'product_batches':
        return db.productBatches;
      case 'catalogs':
        return db.catalogs;
      case 'catalog_items':
        return db.catalogItems;
      case 'catalog_assignments':
        return db.catalogAssignments;
      case 'catalog_tiered_discounts':
        return db.catalogTieredDiscounts;
      case 'recipes':
        return db.recipes;
      case 'recipe_inputs':
        return db.recipeInputs;
      case 'recipe_outputs':
        return db.recipeOutputs;
      case 'recipe_charges':
        return db.recipeCharges;
      case 'orders':
        return db.orders;
      case 'order_items':
        return db.orderItems;
      case 'goods_receipts':
        return db.goodsReceipts;
      case 'goods_receipt_lines':
        return db.goodsReceiptLines;
      case 'order_returns':
        return db.orderReturns;
      case 'order_return_items':
        return db.orderReturnItems;
      case 'production_orders':
        return db.productionOrders;
      case 'production_order_inputs':
        return db.productionOrderInputs;
      case 'production_order_outputs':
        return db.productionOrderOutputs;
      case 'production_order_charges':
        return db.productionOrderCharges;
      case 'production_consumptions':
        return db.productionConsumptions;
      case 'app_currencies':
        return db.appCurrencies;
      case 'user_preferences':
        return db.userPreferences;
      default:
        return null;
    }
  }

  /// Drift tables to refresh after sync (existing tables only).
  static Set<TableInfo> allKnownTableInfos(AppDatabase db) {
    return {
      db.productCategories,
      db.contacts,
      db.accounts,
      db.transactions,
      db.accountTransfers,
      db.products,
      db.productBatches,
      db.catalogs,
      db.catalogItems,
      db.catalogAssignments,
      db.catalogTieredDiscounts,
      db.recipes,
      db.recipeInputs,
      db.recipeOutputs,
      db.recipeCharges,
      db.orders,
      db.orderItems,
      db.goodsReceipts,
      db.goodsReceiptLines,
      db.orderReturns,
      db.orderReturnItems,
      db.productionOrders,
      db.productionOrderInputs,
      db.productionOrderOutputs,
      db.productionOrderCharges,
      db.productionConsumptions,
      db.appCurrencies,
      db.userPreferences,
    };
  }
}
