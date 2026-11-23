import 'package:flutter/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:drift/drift.dart';
import 'connection/connection.dart'
    if (dart.library.io) 'connection/native.dart'
    if (dart.library.html) 'connection/web.dart'
    if (dart.library.js_interop) 'connection/web.dart';

export 'package:flowpaisa/features/transactions/domain/models.dart' show Category, Payable, Receivable, Tag, TransactionSchedule, TransactionSchedulesCompanion, TransactionDocument, WhatsAppQueueData, CategoryExpense, MonthlyFinancials, ContactSummary, PayableReceivableTrend, SplitShare, PayablesCompanion, ReceivablesCompanion;

part 'database.g.dart';

class ProductCategories extends Table {
  TextColumn get uuid => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

class Contacts extends Table {
  TextColumn get uuid => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get address => text().nullable()();

  // Dual Role Flags
  BoolColumn get isCustomer => boolean().withDefault(const Constant(true))();
  BoolColumn get isSupplier => boolean().withDefault(const Constant(false))();

  // Credit/Limit
  RealColumn get creditLimit => real().nullable()(); 

  // Supplier Tax & Bank details
  TextColumn get taxNumber => text().nullable()();
  TextColumn get bankName => text().nullable()();
  TextColumn get bankAccount => text().nullable()();
  TextColumn get bankIfsc => text().nullable()();

  // Sync columns
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();
  IntColumn get addSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {uuid};
}

class Products extends Table {
  TextColumn get uuid => text()();
  TextColumn get categoryUuid => text().nullable().references(ProductCategories, #uuid)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get sku => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get unit => text().withDefault(const Constant('Pcs'))();

  RealColumn get purchasePrice => real().withDefault(const Constant(0.0))();
  RealColumn get retailPrice => real().withDefault(const Constant(0.0))();
  RealColumn get wholesalePrice => real().withDefault(const Constant(0.0))();

  RealColumn get stockQuantity => real().withDefault(const Constant(0.0))();
  RealColumn get minStockAlert => real().nullable()();
  BoolColumn get isService => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// Inventory lots. Remaining qty = [totalQuantity] - [consumedQuantity].
/// Purchase: 1 lot ↔ 1 [GoodsReceiptLines] row. Manual: [isManual]=true + [manualType].
/// [batchNumber] is a label; multiple lots may share it (UI groups them).
class ProductBatches extends Table {
  TextColumn get uuid => text()();
  TextColumn get productUuid => text().references(Products, #uuid)();
  TextColumn get batchNumber => text().withLength(min: 1, max: 100)();

  /// Qty received into this lot (purchase / opening / production / adjustment).
  RealColumn get totalQuantity => real().withDefault(const Constant(0.0))();

  /// Qty consumed from this lot (sales, purchase returns, write-offs).
  RealColumn get consumedQuantity => real().withDefault(const Constant(0.0))();

  /// Per-unit cost stamped at receive (or manual create); immutable for purchase lots.
  RealColumn get effectiveCost => real().withDefault(const Constant(0.0))();

  BoolColumn get isManual => boolean().withDefault(const Constant(false))();

  /// When [isManual]: OPENING | PRODUCTION | ADJUSTMENT. Null for purchase lots.
  TextColumn get manualType => text().nullable()();

  /// Purchase lot → [GoodsReceiptLines.uuid]. Null when [isManual].
  /// Plain text to avoid circular FK with receipt lines / order items.
  TextColumn get shipmentLineUuid => text().nullable()();

  /// PO line this lot fulfilled (purchase). Null for manual.
  TextColumn get orderItemUuid => text().nullable()();

  /// Set when a manual cost-split creates this lot from another.
  TextColumn get sourceLotUuid => text().nullable()();

  RealColumn get retailPriceOverride => real().nullable()();
  RealColumn get wholesalePriceOverride => real().nullable()();

  DateTimeColumn get manufactureDate => dateTime().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();

  /// Optional free-text note shown on lot cards when set.
  TextColumn get description => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

class Orders extends Table {
  TextColumn get uuid => text()();
  TextColumn get contactUuid => text().nullable().references(Contacts, #uuid)();
  TextColumn get orderNumber => text()();
  TextColumn get orderType => text()(); // 'SALE' or 'PURCHASE'
  DateTimeColumn get orderDate => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();

  RealColumn get subtotal => real()();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  /// Percent applied to (subtotal − discount); amount stored in [taxAmount].
  RealColumn get taxRate => real().withDefault(const Constant(0.0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();
  RealColumn get totalAmount => real()();

  TextColumn get paymentStatus => text().withDefault(const Constant('UNPAID'))(); // 'UNPAID', 'PARTIALLY_PAID', 'PAID'
  /// PENDING | PARTIALLY_DELIVERED | SHIPPED | DELIVERED | CANCELLED
  TextColumn get deliveryStatus => text().withDefault(const Constant('PENDING'))();
  
  TextColumn get shippingProvider => text().nullable()();
  TextColumn get trackingNumber => text().nullable()();
  DateTimeColumn get deliveredDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

class OrderItems extends Table {
  TextColumn get uuid => text()();
  TextColumn get orderUuid => text().references(Orders, #uuid)();

  /// Direct product line. Null when the line is a selling-product offer.
  TextColumn get productUuid => text().nullable().references(Products, #uuid)();

  /// Catalog line this sale was picked from (optional snapshot ref).
  TextColumn get catalogItemUuid =>
      text().nullable().references(CatalogItems, #uuid)();

  /// Selling-product / bundle line. Null for direct product lines.
  TextColumn get sellingProductUuid =>
      text().nullable().references(SellingProducts, #uuid)();

  TextColumn get productNameSnapshot => text()();

  /// Ordered qty (PO/SO commitment).
  RealColumn get quantity => real()();

  /// List / catalog unit price (before line discount).
  RealColumn get unitPrice => real()();

  /// Unit price after discount (what the customer pays per unit).
  /// Null on legacy rows — treat as [unitPrice] − discount/qty.
  RealColumn get discountedUnitPrice => real().nullable()();

  /// Absolute line discount = ([unitPrice] − [discountedUnitPrice]) × qty.
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get taxRate => real().withDefault(const Constant(0.0))();

  /// Catalog name when the line was picked (sale snapshot).
  TextColumn get catalogNameSnapshot => text().nullable()();

  /// Cumulative qty received against this PO line (purchases).
  RealColumn get receivedQuantity => real().withDefault(const Constant(0.0))();

  /// Cumulative qty delivered against this SO line (sales).
  RealColumn get deliveredQuantity => real().withDefault(const Constant(0.0))();

  TextColumn get batchUuid => text().nullable().references(ProductBatches, #uuid)();
  /// Planned / stamped unit cost (net of discounts; sales COGS or PO planned cost).
  RealColumn get purchasePriceSnapshot => real().withDefault(const Constant(0.0))();
  TextColumn get unit => text().withDefault(const Constant('Pcs'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// Order-level extras (delivery, packing, etc.). Tax uses [Orders.taxAmount].
class OrderCharges extends Table {
  TextColumn get uuid => text()();
  TextColumn get orderUuid => text().references(Orders, #uuid)();
  TextColumn get description => text()();
  RealColumn get amount => real().withDefault(const Constant(0.0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// One outbound delivery / dispatch against a sale order.
class GoodsDeliveries extends Table {
  TextColumn get uuid => text()();
  TextColumn get orderUuid => text().references(Orders, #uuid)();
  DateTimeColumn get deliveredAt => dateTime()();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// One delivery line against an order item (partial or full).
class GoodsDeliveryLines extends Table {
  TextColumn get uuid => text()();
  TextColumn get deliveryUuid => text().references(GoodsDeliveries, #uuid)();
  TextColumn get orderItemUuid => text().references(OrderItems, #uuid)();
  TextColumn get productUuid => text().nullable().references(Products, #uuid)();
  RealColumn get quantity => real()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// One inbound shipment / goods receipt against a purchase order.
class GoodsReceipts extends Table {
  TextColumn get uuid => text()();
  TextColumn get orderUuid => text().references(Orders, #uuid)();
  DateTimeColumn get receivedAt => dateTime()();

  /// Inbound freight landed into line costs (not recoverable tax).
  RealColumn get freightAmount => real().withDefault(const Constant(0.0))();

  /// Import duty / non-recoverable landed charges.
  RealColumn get dutyAmount => real().withDefault(const Constant(0.0))();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// One receive line = one inventory lot (1:1).
class GoodsReceiptLines extends Table {
  TextColumn get uuid => text()();
  TextColumn get receiptUuid => text().references(GoodsReceipts, #uuid)();
  TextColumn get orderItemUuid => text().references(OrderItems, #uuid)();
  TextColumn get productUuid => text().references(Products, #uuid)();

  RealColumn get quantity => real()();

  /// Unit cost stamped onto the lot (discounts + landed share).
  RealColumn get effectiveUnitCost => real().withDefault(const Constant(0.0))();

  TextColumn get batchNumber => text().withDefault(const Constant(''))();
  DateTimeColumn get manufactureDate => dateTime().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();

  /// Lot created for this line (set after insert). Plain text avoids circular FK.
  TextColumn get lotUuid => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// Reusable BOM template. Quantities are a base batch; production orders scale them.
class Recipes extends Table {
  TextColumn get uuid => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

class RecipeInputs extends Table {
  TextColumn get uuid => text()();
  TextColumn get recipeUuid => text().references(Recipes, #uuid)();
  TextColumn get productUuid => text().references(Products, #uuid)();
  TextColumn get productNameSnapshot => text()();
  RealColumn get quantity => real()();

  /// Default consume mode copied onto production inputs (AUTO | BATCH).
  TextColumn get consumeMode => text().withDefault(const Constant('AUTO'))();

  /// Preferred batch label when [consumeMode] is BATCH; copied onto draft POs.
  TextColumn get batchNumber => text().nullable()();

  TextColumn get unit => text().withDefault(const Constant('Pcs'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

class RecipeOutputs extends Table {
  TextColumn get uuid => text()();
  TextColumn get recipeUuid => text().references(Recipes, #uuid)();
  TextColumn get productUuid => text().references(Products, #uuid)();
  TextColumn get productNameSnapshot => text()();
  RealColumn get quantity => real()();
  RealColumn get costWeight => real().withDefault(const Constant(1.0))();
  TextColumn get unit => text().withDefault(const Constant('Pcs'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// Template other charges; scaled by production [ProductionOrders.scaleFactor].
class RecipeCharges extends Table {
  TextColumn get uuid => text()();
  TextColumn get recipeUuid => text().references(Recipes, #uuid)();
  TextColumn get description => text()();
  RealColumn get amount => real().withDefault(const Constant(0.0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// Formal production run: consume inputs (+ charges) → one or more output lots.
/// Stock moves only when [status] becomes COMPLETED.
class ProductionOrders extends Table {
  TextColumn get uuid => text()();
  TextColumn get productionNumber => text()();
  DateTimeColumn get productionDate => dateTime()();

  /// DRAFT | COMPLETED | CANCELLED
  TextColumn get status => text().withDefault(const Constant('DRAFT'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Optional recipe this run was created from (audit only; lines are copied).
  TextColumn get recipeUuid => text().nullable().references(Recipes, #uuid)();
  TextColumn get recipeNameSnapshot => text().nullable()();
  /// Multiplier applied to recipe base quantities when creating this order.
  RealColumn get scaleFactor => real().withDefault(const Constant(1.0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// Raw / component lines consumed when the production order is completed.
class ProductionOrderInputs extends Table {
  TextColumn get uuid => text()();
  TextColumn get productionOrderUuid =>
      text().references(ProductionOrders, #uuid)();
  TextColumn get productUuid => text().references(Products, #uuid)();
  TextColumn get productNameSnapshot => text()();

  RealColumn get plannedQuantity => real()();
  /// Qty actually consumed on complete (defaults to planned).
  RealColumn get actualQuantity => real().withDefault(const Constant(0.0))();

  /// AUTO = FEFO across all lots; BATCH = FEFO within [batchNumber] only.
  TextColumn get consumeMode => text().withDefault(const Constant('AUTO'))();
  TextColumn get batchNumber => text().nullable()();
  TextColumn get unit => text().withDefault(const Constant('Pcs'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// Finished goods produced by this run (supports co-products).
class ProductionOrderOutputs extends Table {
  TextColumn get uuid => text()();
  TextColumn get productionOrderUuid =>
      text().references(ProductionOrders, #uuid)();
  TextColumn get productUuid => text().references(Products, #uuid)();
  TextColumn get productNameSnapshot => text()();

  RealColumn get plannedQuantity => real()();
  RealColumn get actualQuantity => real().withDefault(const Constant(0.0))();

  /// Cost allocation weight (relative). Normalized on complete.
  RealColumn get costWeight => real().withDefault(const Constant(1.0))();
  /// Frozen unit cost after complete.
  RealColumn get unitCostSnapshot => real().withDefault(const Constant(0.0))();
  TextColumn get outputLotUuid => text().nullable()();
  TextColumn get batchNumber => text().withDefault(const Constant(''))();
  TextColumn get unit => text().withDefault(const Constant('Pcs'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// Non-material charges landed into output lot costs (labor, power, etc.).
class ProductionOrderCharges extends Table {
  TextColumn get uuid => text()();
  TextColumn get productionOrderUuid =>
      text().references(ProductionOrders, #uuid)();
  TextColumn get description => text()();
  RealColumn get amount => real().withDefault(const Constant(0.0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// Audit: which lots were consumed for an input line on complete.
class ProductionConsumptions extends Table {
  TextColumn get uuid => text()();
  TextColumn get productionOrderUuid =>
      text().references(ProductionOrders, #uuid)();
  TextColumn get inputLineUuid =>
      text().references(ProductionOrderInputs, #uuid)();
  TextColumn get lotUuid => text().references(ProductBatches, #uuid)();
  RealColumn get quantity => real()();
  RealColumn get effectiveCost => real()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

class OrderReturns extends Table {
  TextColumn get uuid => text()();
  TextColumn get orderUuid => text().references(Orders, #uuid)();
  TextColumn get returnNumber => text()();
  TextColumn get orderType => text()(); // 'SALE' or 'PURCHASE'
  TextColumn get contactUuid => text().nullable().references(Contacts, #uuid)();
  DateTimeColumn get date => dateTime()();
  RealColumn get totalRefundAmount => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

class OrderReturnItems extends Table {
  TextColumn get uuid => text()();
  TextColumn get returnUuid => text().references(OrderReturns, #uuid)();
  TextColumn get productUuid => text().references(Products, #uuid)();
  RealColumn get quantity => real()();
  RealColumn get refundUnitPrice => real()();
  TextColumn get batchUuid => text().nullable().references(ProductBatches, #uuid)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// Virtual sell offer (simple pin or bundle). No stock of its own.
class SellingProducts extends Table {
  TextColumn get uuid => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get sku => text().nullable()();
  TextColumn get description => text().nullable()();

  /// Optional category; if unset at save, defaults from first component product.
  TextColumn get categoryUuid =>
      text().nullable().references(ProductCategories, #uuid)();

  /// Optional sell unit; if unset at save, defaults from first component product.
  TextColumn get unit => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// BOM lines for a selling product. Consume mode: AUTO | BATCH.
class SellingProductComponents extends Table {
  TextColumn get uuid => text()();
  TextColumn get sellingProductUuid => text().references(SellingProducts, #uuid)();
  TextColumn get productUuid => text().references(Products, #uuid)();
  RealColumn get quantity => real()();

  /// AUTO | BATCH — same idea as recipe / production inputs.
  TextColumn get consumeMode => text().withDefault(const Constant('AUTO'))();

  /// Required when [consumeMode] is BATCH.
  TextColumn get batchNumber => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

class Catalogs extends Table {
  TextColumn get uuid => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get validUntil => dateTime().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// Prefill for new catalog lines (copied onto items at add time).
  TextColumn get defaultPricingApproach =>
      text().withDefault(const Constant('MARKUP'))();
  RealColumn get defaultMarkupOrMarginPercent =>
      real().withDefault(const Constant(0.0))();
  RealColumn get defaultFixedAmount =>
      real().withDefault(const Constant(0.0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// Catalog line: exactly one of [productUuid] or [sellingProductUuid].
/// Price = stored [sellPrice]; formula fields support refresh (not order-time calc).
class CatalogItems extends Table {
  TextColumn get uuid => text()();
  TextColumn get catalogUuid => text().references(Catalogs, #uuid)();

  /// Direct stock/service product. XOR with [sellingProductUuid].
  TextColumn get productUuid => text().nullable().references(Products, #uuid)();

  /// Virtual offer / bundle. XOR with [productUuid].
  TextColumn get sellingProductUuid =>
      text().nullable().references(SellingProducts, #uuid)();

  /// Legacy; prefer [sellPrice]. Migrated into sellPrice when present.
  RealColumn get customPrice => real().nullable()();

  /// Deprecated — batch strategy lives on selling-product components.
  TextColumn get batchUuid => text().nullable().references(ProductBatches, #uuid)();
  DateTimeColumn get validUntil => dateTime().nullable()();

  /// Deprecated — unused for new catalog pricing.
  TextColumn get batchSelectionStrategy =>
      text().withDefault(const Constant('FEFO_AUTO'))();

  /// MARKUP | MARGIN
  TextColumn get pricingApproach =>
      text().withDefault(const Constant('MARKUP'))();
  RealColumn get markupOrMarginPercent =>
      real().withDefault(const Constant(0.0))();
  RealColumn get fixedAmount => real().withDefault(const Constant(0.0))();

  /// Final sell price used on orders (snapshot source).
  RealColumn get sellPrice => real().withDefault(const Constant(0.0))();
  RealColumn get unitCostSnapshot => real().nullable()();
  DateTimeColumn get priceComputedAt => dateTime().nullable()();

  /// True when sell price was set manually; skipped by catalog recalculate.
  BoolColumn get priceOverride =>
      boolean().withDefault(const Constant(false))();

  /// Optional always-on discount: PERCENT | FIXED. Null/empty = none.
  TextColumn get defaultDiscountType => text().nullable()();
  RealColumn get defaultDiscountValue =>
      real().withDefault(const Constant(0.0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

class CatalogAssignments extends Table {
  TextColumn get uuid => text()();
  TextColumn get catalogUuid => text().references(Catalogs, #uuid)();
  TextColumn get contactUuid => text().references(Contacts, #uuid)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

class CatalogTieredDiscounts extends Table {
  TextColumn get uuid => text()();
  TextColumn get catalogItemUuid => text().references(CatalogItems, #uuid)();
  RealColumn get minQuantity => real()();

  /// Legacy / PERCENT value. Prefer [discountType] + [discountAmount] for FIXED.
  RealColumn get discountPercentage => real()();

  /// PERCENT | FIXED — qty tier replaces item default when matched.
  TextColumn get discountType =>
      text().withDefault(const Constant('PERCENT'))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

class Accounts extends Table {
  TextColumn get uuid => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text()(); // 'CASH' | 'BANK' | 'SAVINGS' | 'CREDIT_CARD'
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  RealColumn get openingBalance => real().withDefault(const Constant(0.0))();
  DateTimeColumn get openingDate => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  RealColumn get creditLimit => real().nullable()();
  IntColumn get billingCycleDay => integer().nullable()(); // Day of month 1-31
  IntColumn get paymentDueDays => integer().nullable()(); // Days after billing cycle
  TextColumn get linkedAccountUuid => text().nullable()(); // For auto-payment reminder

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  IntColumn get addSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {uuid};
}

class AccountTransfers extends Table {
  TextColumn get uuid => text()();
  @ReferenceName('outgoingTransfersRefs')
  TextColumn get fromAccountUuid => text().references(Accounts, #uuid)();
  @ReferenceName('incomingTransfersRefs')
  TextColumn get toAccountUuid => text().references(Accounts, #uuid)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

class Transactions extends Table {
  TextColumn get uuid => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // 'CASH_IN' or 'CASH_OUT'
  TextColumn get contactUuid => text().nullable().references(Contacts, #uuid)();
  TextColumn get orderUuid => text().nullable().references(Orders, #uuid)();
  TextColumn get categoryUuid => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get date => dateTime()();

  TextColumn get accountUuid => text().nullable().references(Accounts, #uuid)();
  DateTimeColumn get processedDate => dateTime().nullable()();
  TextColumn get paymentMethod => text().withDefault(const Constant('CASH'))(); // 'CASH', 'BANK_TRANSFER', 'UPI', 'CARD'

  // Linked transaction fields
  TextColumn get linkedReceivableUuid => text().nullable()();
  TextColumn get linkedPayableUuid => text().nullable()();
  TextColumn get paidRelationship => text().nullable()(); // 'PAID_FOR', 'PAID_BY', 'RECEIVED_FROM', 'WILL_RECEIVE' or null
  BoolColumn get isAutoGenerated => boolean().withDefault(const Constant(false))();
  BoolColumn get isScheduled => boolean().withDefault(const Constant(false))();

  /// True when this is an order-linked operating cost (not a customer/supplier payment).
  BoolColumn get isOrderCost => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

class UserPreferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(false))();
}

class SyncLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get lastBackup => dateTime().nullable()();
  DateTimeColumn get lastRestore => dateTime().nullable()();
  TextColumn get driveFileId => text().nullable()();
  TextColumn get status => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class AppCurrencies extends Table {
  TextColumn get uuid => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get symbol => text().withLength(min: 0, max: 10)();
  TextColumn get code => text().withLength(min: 3, max: 3)();
  IntColumn get decimalPlaces => integer().withDefault(const Constant(2))();
  RealColumn get scaleFactor => real().withDefault(const Constant(1.0))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

class SyncMetadata extends Table {
  TextColumn get deviceId => text()();
  IntColumn get version => integer().withDefault(const Constant(0))();
  IntColumn get cloudVersion => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('Idle'))();
  DateTimeColumn get syncStartedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {deviceId};
}

/// Compatibility alias: older UI still uses CategoriesCompanion naming.
typedef CategoriesCompanion = ProductCategoriesCompanion;

@DriftDatabase(tables: [
  ProductCategories,
  Contacts,
  Accounts,
  Transactions,
  AccountTransfers,
  UserPreferences,
  SyncLog,
  AppCurrencies,
  SyncMetadata,
  Products,
  ProductBatches,
  SellingProducts,
  SellingProductComponents,
  Catalogs,
  CatalogItems,
  CatalogAssignments,
  CatalogTieredDiscounts,
  Orders,
  OrderItems,
  OrderCharges,
  GoodsDeliveries,
  GoodsDeliveryLines,
  GoodsReceipts,
  GoodsReceiptLines,
  Recipes,
  RecipeInputs,
  RecipeOutputs,
  RecipeCharges,
  ProductionOrders,
  ProductionOrderInputs,
  ProductionOrderOutputs,
  ProductionOrderCharges,
  ProductionConsumptions,
  OrderReturns,
  OrderReturnItems,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase({String fileName = 'flowkarobar.db', QueryExecutor? executor})
      : super(executor ?? openConnection(fileName));

  @override
  int get schemaVersion => 20;

  // Compatibility getters and helpers for deprecated tables
  $ProductCategoriesTable get categories => productCategories;
  Expression<bool>? buildTagExpression(List<String> tagUuids) => null;
  dynamic joinScheduleWithDetails(dynamic select) => select;

  JoinedSelectStatement<HasResultSet, dynamic> joinTransactionWithDetails(
      SimpleSelectStatement<$TransactionsTable, Transaction> select) {
    return select.join([
      leftOuterJoin(
        productCategories,
        productCategories.uuid.equalsExp(transactions.categoryUuid),
      ),
      leftOuterJoin(
        contacts,
        contacts.uuid.equalsExp(transactions.contactUuid),
      ),
      leftOuterJoin(
        accounts,
        accounts.uuid.equalsExp(transactions.accountUuid),
      ),
    ]);
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          try {
            await customStatement('PRAGMA journal_mode=WAL;');
            await customStatement('PRAGMA synchronous=NORMAL;');
            await customStatement('PRAGMA busy_timeout=5000;');
          } catch (e) {
            if (kDebugMode) {
              print('Database: Warning - Failed to set WAL mode: $e');
            }
          }
          await insertDefaultData();
        },
        onCreate: (Migrator m) async {
          await m.createAll();
          await _insertDefaultProductCategories();
          await _insertDefaultCurrencies();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await _migrateProductBatchesToV2();
          }
          if (from < 3) {
            await _migrateGoodsReceiptsToV3(m);
          }
          // Recipes before production when both are new (FK on production_orders).
          if (from < 5) {
            await _ensureRecipeTables(m);
          }
          if (from < 4) {
            await _migrateProductionOrdersToV4(m);
          } else if (from < 5) {
            await _addProductionRecipeColumns();
          }
          if (from < 6) {
            await _migrateLotDescriptionToV6();
          }
          if (from < 7) {
            await _migrateRecipeInputBatchToV7();
          }
          if (from < 8) {
            await _migrateCatalogsSellingProductsToV8(m);
          }
          if (from < 9) {
            await _migrateSellingProductCategoryToV9();
          }
          if (from < 10) {
            await _migrateSellingProductUnitToV10();
          }
          if (from < 11) {
            await _migrateCatalogItemPriceOverrideToV11();
          }
          if (from < 12) {
            await _migrateCatalogDiscountsToV12();
          }
          if (from < 13) {
            await _migrateOrderItemsCatalogRefsToV13();
          }
          if (from < 14) {
            await _migrateCatalogPricingDefaultsToV14();
          }
          if (from < 15) {
            await _migrateOrderItemsDiscountedPriceToV15();
          }
          if (from < 16) {
            // v13 rebuild dropped SQL DEFAULTs on created_at/updated_at; inserts fail.
            await _migrateOrderItemsRestoreTimestampDefaultsToV16();
          }
          if (from < 17 || from < 18) {
            // v17 only backfilled; some DBs never had the columns. v18 adds them.
            await _migrateTransactionsEnsureColumnsToV18();
          }
          if (from < 19) {
            await _migrateOrderChargesToV19(m);
          }
          if (from < 20) {
            await _migrateOrderTaxDeliveryToV20(m);
          }
        },
      );

  Future<void> _migrateOrderChargesToV19(Migrator m) async {
    try {
      await m.createTable(orderCharges);
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v19 order_charges skipped: $e');
      }
    }
  }

  Future<void> _migrateOrderTaxDeliveryToV20(Migrator m) async {
    Future<void> addColumn(String sql, String label) async {
      try {
        await customStatement(sql);
      } catch (e) {
        if (kDebugMode) {
          print('Database migrate v20 $label skipped: $e');
        }
      }
    }

    await addColumn(
      'ALTER TABLE orders ADD COLUMN tax_rate REAL NOT NULL DEFAULT 0.0',
      'orders.tax_rate',
    );
    await addColumn(
      'ALTER TABLE order_items ADD COLUMN delivered_quantity REAL NOT NULL DEFAULT 0.0',
      'order_items.delivered_quantity',
    );
    await addColumn(
      'ALTER TABLE transactions ADD COLUMN is_order_cost INTEGER NOT NULL DEFAULT 0 CHECK (is_order_cost IN (0, 1))',
      'transactions.is_order_cost',
    );

    try {
      await m.createTable(goodsDeliveries);
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v20 goods_deliveries skipped: $e');
      }
    }
    try {
      await m.createTable(goodsDeliveryLines);
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v20 goods_delivery_lines skipped: $e');
      }
    }

    // Legacy fully-delivered sales: treat ordered qty as already delivered.
    try {
      await customStatement('''
UPDATE order_items
SET delivered_quantity = quantity
WHERE uuid IN (
  SELECT oi.uuid FROM order_items oi
  INNER JOIN orders o ON o.uuid = oi.order_uuid
  WHERE o.order_type = 'SALE'
    AND o.delivery_status = 'DELIVERED'
    AND COALESCE(oi.delivered_quantity, 0) = 0
)
''');
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v20 backfill delivered_quantity skipped: $e');
      }
    }
  }

  /// Ensure Drift-required transaction columns exist, then coalesce NULLs.
  /// Older local DBs may predate payment_method / is_auto_generated / is_scheduled.
  Future<void> _migrateTransactionsEnsureColumnsToV18() async {
    Future<void> addColumn(String sql, String label) async {
      try {
        await customStatement(sql);
      } catch (e) {
        if (kDebugMode) {
          print('Database migrate v18 transactions $label skipped: $e');
        }
      }
    }

    await addColumn(
      "ALTER TABLE transactions ADD COLUMN payment_method TEXT NOT NULL DEFAULT 'CASH'",
      'payment_method',
    );
    await addColumn(
      'ALTER TABLE transactions ADD COLUMN is_auto_generated INTEGER NOT NULL DEFAULT 0 CHECK (is_auto_generated IN (0, 1))',
      'is_auto_generated',
    );
    await addColumn(
      'ALTER TABLE transactions ADD COLUMN is_scheduled INTEGER NOT NULL DEFAULT 0 CHECK (is_scheduled IN (0, 1))',
      'is_scheduled',
    );
    await addColumn(
      'ALTER TABLE transactions ADD COLUMN linked_receivable_uuid TEXT',
      'linked_receivable_uuid',
    );
    await addColumn(
      'ALTER TABLE transactions ADD COLUMN linked_payable_uuid TEXT',
      'linked_payable_uuid',
    );
    await addColumn(
      'ALTER TABLE transactions ADD COLUMN paid_relationship TEXT',
      'paid_relationship',
    );
    await addColumn(
      'ALTER TABLE transactions ADD COLUMN order_uuid TEXT REFERENCES orders (uuid)',
      'order_uuid',
    );

    try {
      await customStatement('''
UPDATE transactions SET
  payment_method = COALESCE(payment_method, 'CASH'),
  is_auto_generated = COALESCE(is_auto_generated, 0),
  is_scheduled = COALESCE(is_scheduled, 0),
  is_deleted = COALESCE(is_deleted, 0),
  is_not_synced = COALESCE(is_not_synced, 1),
  created_at = COALESCE(created_at, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
  updated_at = COALESCE(updated_at, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
WHERE payment_method IS NULL
   OR is_auto_generated IS NULL
   OR is_scheduled IS NULL
   OR is_deleted IS NULL
   OR is_not_synced IS NULL
   OR created_at IS NULL
   OR updated_at IS NULL
''');
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v18 transactions null backfill skipped: $e');
      }
    }
  }

  Future<void> _migrateOrderItemsDiscountedPriceToV15() async {
    try {
      await customStatement(
        'ALTER TABLE order_items ADD COLUMN discounted_unit_price REAL',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v15 discounted_unit_price skipped: $e');
      }
    }
    try {
      await customStatement(
        'ALTER TABLE order_items ADD COLUMN catalog_name_snapshot TEXT',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v15 catalog_name_snapshot skipped: $e');
      }
    }
    try {
      // Backfill from list unit price and existing line discount.
      await customStatement('''
UPDATE order_items
SET discounted_unit_price = CASE
  WHEN quantity IS NULL OR quantity = 0 THEN unit_price
  ELSE MAX(0.0, unit_price - (COALESCE(discount_amount, 0.0) / quantity))
END
WHERE discounted_unit_price IS NULL
''');
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v15 discounted_unit_price backfill skipped: $e');
      }
    }
  }

  /// Rebuild [order_items] so [created_at]/[updated_at] have SQL DEFAULTs again
  /// (lost in the v13 table rebuild) and include v15 pricing snapshot columns.
  Future<void> _migrateOrderItemsRestoreTimestampDefaultsToV16() async {
    try {
      await customStatement('PRAGMA foreign_keys = OFF');
      await customStatement('''
CREATE TABLE IF NOT EXISTS order_items_new (
  uuid TEXT NOT NULL PRIMARY KEY,
  order_uuid TEXT NOT NULL REFERENCES orders (uuid),
  product_uuid TEXT REFERENCES products (uuid),
  catalog_item_uuid TEXT REFERENCES catalog_items (uuid),
  selling_product_uuid TEXT REFERENCES selling_products (uuid),
  product_name_snapshot TEXT NOT NULL,
  quantity REAL NOT NULL,
  unit_price REAL NOT NULL,
  discounted_unit_price REAL,
  discount_amount REAL NOT NULL DEFAULT 0.0,
  tax_rate REAL NOT NULL DEFAULT 0.0,
  catalog_name_snapshot TEXT,
  received_quantity REAL NOT NULL DEFAULT 0.0,
  batch_uuid TEXT REFERENCES product_batches (uuid),
  purchase_price_snapshot REAL NOT NULL DEFAULT 0.0,
  unit TEXT NOT NULL DEFAULT 'Pcs',
  created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
  updated_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
  is_deleted INTEGER NOT NULL DEFAULT 0 CHECK (is_deleted IN (0, 1)),
  is_not_synced INTEGER NOT NULL DEFAULT 1 CHECK (is_not_synced IN (0, 1))
)
''');
      // Prefer existing columns; COALESCE for DBs that never got v15 ALTERs.
      await customStatement('''
INSERT INTO order_items_new (
  uuid, order_uuid, product_uuid, catalog_item_uuid, selling_product_uuid,
  product_name_snapshot, quantity, unit_price, discounted_unit_price,
  discount_amount, tax_rate, catalog_name_snapshot, received_quantity,
  batch_uuid, purchase_price_snapshot, unit,
  created_at, updated_at, is_deleted, is_not_synced
)
SELECT
  uuid, order_uuid, product_uuid, catalog_item_uuid, selling_product_uuid,
  product_name_snapshot, quantity, unit_price,
  CASE
    WHEN quantity IS NULL OR quantity = 0 THEN unit_price
    ELSE MAX(0.0, unit_price - (COALESCE(discount_amount, 0.0) / quantity))
  END,
  discount_amount, tax_rate, NULL, received_quantity,
  batch_uuid, purchase_price_snapshot, unit,
  COALESCE(created_at, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
  COALESCE(updated_at, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
  is_deleted, is_not_synced
FROM order_items
''');
      // If v15 columns already exist, copy them over (replace the computed insert).
      try {
        await customStatement('''
UPDATE order_items_new
SET
  discounted_unit_price = (
    SELECT oi.discounted_unit_price FROM order_items oi
    WHERE oi.uuid = order_items_new.uuid
  ),
  catalog_name_snapshot = (
    SELECT oi.catalog_name_snapshot FROM order_items oi
    WHERE oi.uuid = order_items_new.uuid
  )
''');
      } catch (_) {
        // Source table may not have v15 columns yet; computed values kept.
      }
      await customStatement('DROP TABLE order_items');
      await customStatement(
        'ALTER TABLE order_items_new RENAME TO order_items',
      );
      await customStatement('PRAGMA foreign_keys = ON');
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v16 order_items timestamp defaults skipped: $e');
      }
      try {
        await customStatement('PRAGMA foreign_keys = ON');
      } catch (_) {}
    }
  }

  Future<void> _migrateCatalogPricingDefaultsToV14() async {
    try {
      await customStatement(
        "ALTER TABLE catalogs ADD COLUMN default_pricing_approach TEXT "
        "NOT NULL DEFAULT 'MARKUP'",
      );
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v14 default_pricing_approach skipped: $e');
      }
    }
    try {
      await customStatement(
        'ALTER TABLE catalogs ADD COLUMN default_markup_or_margin_percent '
        'REAL NOT NULL DEFAULT 0.0',
      );
    } catch (e) {
      if (kDebugMode) {
        print(
          'Database migrate v14 default_markup_or_margin_percent skipped: $e',
        );
      }
    }
    try {
      await customStatement(
        'ALTER TABLE catalogs ADD COLUMN default_fixed_amount REAL '
        'NOT NULL DEFAULT 0.0',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v14 default_fixed_amount skipped: $e');
      }
    }
  }

  /// Nullable [productUuid] + catalog/selling-product refs on order lines.
  Future<void> _migrateOrderItemsCatalogRefsToV13() async {
    try {
      await customStatement('PRAGMA foreign_keys = OFF');
      await customStatement('''
CREATE TABLE IF NOT EXISTS order_items_new (
  uuid TEXT NOT NULL PRIMARY KEY,
  order_uuid TEXT NOT NULL REFERENCES orders (uuid),
  product_uuid TEXT REFERENCES products (uuid),
  catalog_item_uuid TEXT REFERENCES catalog_items (uuid),
  selling_product_uuid TEXT REFERENCES selling_products (uuid),
  product_name_snapshot TEXT NOT NULL,
  quantity REAL NOT NULL,
  unit_price REAL NOT NULL,
  discount_amount REAL NOT NULL DEFAULT 0.0,
  tax_rate REAL NOT NULL DEFAULT 0.0,
  received_quantity REAL NOT NULL DEFAULT 0.0,
  batch_uuid TEXT REFERENCES product_batches (uuid),
  purchase_price_snapshot REAL NOT NULL DEFAULT 0.0,
  unit TEXT NOT NULL DEFAULT 'Pcs',
  created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
  updated_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
  is_deleted INTEGER NOT NULL DEFAULT 0 CHECK (is_deleted IN (0, 1)),
  is_not_synced INTEGER NOT NULL DEFAULT 1 CHECK (is_not_synced IN (0, 1))
)
''');
      await customStatement('''
INSERT INTO order_items_new (
  uuid, order_uuid, product_uuid, catalog_item_uuid, selling_product_uuid,
  product_name_snapshot, quantity, unit_price, discount_amount, tax_rate,
  received_quantity, batch_uuid, purchase_price_snapshot, unit,
  created_at, updated_at, is_deleted, is_not_synced
)
SELECT
  uuid, order_uuid, product_uuid, NULL, NULL,
  product_name_snapshot, quantity, unit_price, discount_amount, tax_rate,
  received_quantity, batch_uuid, purchase_price_snapshot, unit,
  created_at, updated_at, is_deleted, is_not_synced
FROM order_items
''');
      await customStatement('DROP TABLE order_items');
      await customStatement(
        'ALTER TABLE order_items_new RENAME TO order_items',
      );
      await customStatement('PRAGMA foreign_keys = ON');
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v13 order_items catalog refs skipped: $e');
      }
      try {
        await customStatement('PRAGMA foreign_keys = ON');
      } catch (_) {}
    }
  }

  Future<void> _migrateCatalogDiscountsToV12() async {
    try {
      await customStatement(
        'ALTER TABLE catalog_items ADD COLUMN default_discount_type TEXT',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v12 default_discount_type skipped: $e');
      }
    }
    try {
      await customStatement(
        'ALTER TABLE catalog_items ADD COLUMN default_discount_value REAL '
        'NOT NULL DEFAULT 0.0',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v12 default_discount_value skipped: $e');
      }
    }
    try {
      await customStatement(
        "ALTER TABLE catalog_tiered_discounts ADD COLUMN discount_type TEXT "
        "NOT NULL DEFAULT 'PERCENT'",
      );
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v12 discount_type skipped: $e');
      }
    }
    try {
      await customStatement(
        'ALTER TABLE catalog_tiered_discounts ADD COLUMN discount_amount REAL '
        'NOT NULL DEFAULT 0.0',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v12 discount_amount skipped: $e');
      }
    }
  }

  Future<void> _migrateCatalogItemPriceOverrideToV11() async {
    try {
      await customStatement(
        'ALTER TABLE catalog_items ADD COLUMN price_override INTEGER NOT NULL '
        "DEFAULT 0 CHECK (price_override IN (0, 1))",
      );
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v11 alter skipped: $e');
      }
    }
  }

  Future<void> _migrateSellingProductCategoryToV9() async {
    try {
      await customStatement(
        'ALTER TABLE selling_products ADD COLUMN category_uuid TEXT '
        'REFERENCES product_categories (uuid)',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v9 alter skipped: $e');
      }
    }
  }

  Future<void> _migrateSellingProductUnitToV10() async {
    try {
      await customStatement(
        'ALTER TABLE selling_products ADD COLUMN unit TEXT',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v10 alter skipped: $e');
      }
    }
    // Backfill from first non-deleted component product when unit is empty.
    try {
      await customStatement('''
        UPDATE selling_products
        SET unit = (
          SELECT p.unit
          FROM selling_product_components c
          INNER JOIN products p ON p.uuid = c.product_uuid
          WHERE c.selling_product_uuid = selling_products.uuid
            AND c.is_deleted = 0
            AND p.is_deleted = 0
          ORDER BY c.created_at ASC
          LIMIT 1
        )
        WHERE unit IS NULL OR TRIM(unit) = ''
      ''');
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v10 unit backfill skipped: $e');
      }
    }
  }

  /// Selling products + catalog item pricing / XOR product|sellingProduct link.
  Future<void> _migrateCatalogsSellingProductsToV8(Migrator m) async {
    await m.createTable(sellingProducts);
    await m.createTable(sellingProductComponents);

    try {
      await customStatement('PRAGMA foreign_keys=OFF');
      await customStatement('''
        CREATE TABLE catalog_items_new (
          uuid TEXT NOT NULL PRIMARY KEY,
          catalog_uuid TEXT NOT NULL REFERENCES catalogs (uuid),
          product_uuid TEXT NULL REFERENCES products (uuid),
          selling_product_uuid TEXT NULL REFERENCES selling_products (uuid),
          custom_price REAL NULL,
          batch_uuid TEXT NULL REFERENCES product_batches (uuid),
          valid_until INTEGER NULL,
          batch_selection_strategy TEXT NOT NULL DEFAULT 'FEFO_AUTO',
          pricing_approach TEXT NOT NULL DEFAULT 'MARKUP',
          markup_or_margin_percent REAL NOT NULL DEFAULT 0.0,
          fixed_amount REAL NOT NULL DEFAULT 0.0,
          sell_price REAL NOT NULL DEFAULT 0.0,
          unit_cost_snapshot REAL NULL,
          price_computed_at INTEGER NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          is_deleted INTEGER NOT NULL DEFAULT 0 CHECK ("is_deleted" IN (0, 1)),
          is_not_synced INTEGER NOT NULL DEFAULT 1 CHECK ("is_not_synced" IN (0, 1))
        )
      ''');
      await customStatement('''
        INSERT INTO catalog_items_new (
          uuid, catalog_uuid, product_uuid, selling_product_uuid,
          custom_price, batch_uuid, valid_until, batch_selection_strategy,
          pricing_approach, markup_or_margin_percent, fixed_amount, sell_price,
          unit_cost_snapshot, price_computed_at,
          created_at, updated_at, is_deleted, is_not_synced
        )
        SELECT
          uuid, catalog_uuid, product_uuid, NULL,
          custom_price, batch_uuid, valid_until, batch_selection_strategy,
          'MARKUP', 0.0, 0.0, COALESCE(custom_price, 0.0),
          NULL, NULL,
          created_at, updated_at, is_deleted, is_not_synced
        FROM catalog_items
      ''');
      await customStatement('DROP TABLE catalog_items');
      await customStatement(
        'ALTER TABLE catalog_items_new RENAME TO catalog_items',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v8 catalog_items rebuild: $e');
      }
      // Fresh DBs that already match new schema, or partial migrate: add cols.
      Future<void> tryAlter(String sql) async {
        try {
          await customStatement(sql);
        } catch (err) {
          if (kDebugMode) {
            print('Database migrate v8 alter skipped: $err');
          }
        }
      }

      await tryAlter(
        'ALTER TABLE catalog_items ADD COLUMN selling_product_uuid TEXT '
        'REFERENCES selling_products (uuid)',
      );
      await tryAlter(
        "ALTER TABLE catalog_items ADD COLUMN pricing_approach TEXT "
        "NOT NULL DEFAULT 'MARKUP'",
      );
      await tryAlter(
        'ALTER TABLE catalog_items ADD COLUMN markup_or_margin_percent '
        'REAL NOT NULL DEFAULT 0.0',
      );
      await tryAlter(
        'ALTER TABLE catalog_items ADD COLUMN fixed_amount '
        'REAL NOT NULL DEFAULT 0.0',
      );
      await tryAlter(
        'ALTER TABLE catalog_items ADD COLUMN sell_price '
        'REAL NOT NULL DEFAULT 0.0',
      );
      await tryAlter(
        'ALTER TABLE catalog_items ADD COLUMN unit_cost_snapshot REAL',
      );
      await tryAlter(
        'ALTER TABLE catalog_items ADD COLUMN price_computed_at INTEGER',
      );
      try {
        await customStatement('''
          UPDATE catalog_items
          SET sell_price = COALESCE(custom_price, sell_price, 0.0)
          WHERE sell_price = 0 OR sell_price IS NULL
        ''');
      } catch (_) {}
    } finally {
      try {
        await customStatement('PRAGMA foreign_keys=ON');
      } catch (_) {}
    }
  }

  Future<void> _migrateLotDescriptionToV6() async {
    try {
      await customStatement(
        'ALTER TABLE product_batches ADD COLUMN description TEXT',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v6 alter skipped: $e');
      }
    }
  }

  Future<void> _migrateRecipeInputBatchToV7() async {
    try {
      await customStatement(
        'ALTER TABLE recipe_inputs ADD COLUMN batch_number TEXT',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v7 alter skipped: $e');
      }
    }
  }

  Future<void> _ensureRecipeTables(Migrator m) async {
    await m.createTable(recipes);
    await m.createTable(recipeInputs);
    await m.createTable(recipeOutputs);
    await m.createTable(recipeCharges);
  }

  Future<void> _migrateProductionOrdersToV4(Migrator m) async {
    await m.createTable(productionOrders);
    await m.createTable(productionOrderInputs);
    await m.createTable(productionOrderOutputs);
    await m.createTable(productionOrderCharges);
    await m.createTable(productionConsumptions);
  }

  Future<void> _addProductionRecipeColumns() async {
    Future<void> tryAlter(String sql) async {
      try {
        await customStatement(sql);
      } catch (e) {
        if (kDebugMode) {
          print('Database migrate v5 alter skipped: $e');
        }
      }
    }

    await tryAlter(
        'ALTER TABLE production_orders ADD COLUMN recipe_uuid TEXT REFERENCES recipes (uuid)');
    await tryAlter(
        'ALTER TABLE production_orders ADD COLUMN recipe_name_snapshot TEXT');
    await tryAlter(
        'ALTER TABLE production_orders ADD COLUMN scale_factor REAL NOT NULL DEFAULT 1.0');
  }

  /// Receipts + lot shipment refs + order_items.received_quantity.
  Future<void> _migrateGoodsReceiptsToV3(Migrator m) async {
    await m.createTable(goodsReceipts);
    await m.createTable(goodsReceiptLines);

    Future<void> tryAlter(String sql) async {
      try {
        await customStatement(sql);
      } catch (e) {
        if (kDebugMode) {
          print('Database migrate v3 alter skipped: $e');
        }
      }
    }

    await tryAlter(
        'ALTER TABLE order_items ADD COLUMN received_quantity REAL NOT NULL DEFAULT 0.0');
    await tryAlter(
        'ALTER TABLE product_batches ADD COLUMN shipment_line_uuid TEXT REFERENCES goods_receipt_lines (uuid)');
    await tryAlter(
        'ALTER TABLE product_batches ADD COLUMN order_item_uuid TEXT REFERENCES order_items (uuid)');
    await tryAlter(
        'ALTER TABLE product_batches ADD COLUMN source_lot_uuid TEXT REFERENCES product_batches (uuid)');
  }

  /// Adds lot inventory columns and migrates legacy [stock_quantity] → total/consumed.
  Future<void> _migrateProductBatchesToV2() async {
    Future<void> tryAlter(String sql) async {
      try {
        await customStatement(sql);
      } catch (e) {
        if (kDebugMode) {
          print('Database migrate v2 alter skipped: $e');
        }
      }
    }

    await tryAlter(
        'ALTER TABLE product_batches ADD COLUMN total_quantity REAL NOT NULL DEFAULT 0.0');
    await tryAlter(
        'ALTER TABLE product_batches ADD COLUMN consumed_quantity REAL NOT NULL DEFAULT 0.0');
    await tryAlter(
        'ALTER TABLE product_batches ADD COLUMN effective_cost REAL NOT NULL DEFAULT 0.0');
    await tryAlter(
        'ALTER TABLE product_batches ADD COLUMN is_manual INTEGER NOT NULL DEFAULT 0');
    await tryAlter('ALTER TABLE product_batches ADD COLUMN manual_type TEXT');

    // Legacy stock_quantity → opening remaining as total, consumed 0
    try {
      await customStatement('''
        UPDATE product_batches
        SET total_quantity = COALESCE(stock_quantity, 0),
            consumed_quantity = 0
        WHERE (total_quantity IS NULL OR total_quantity = 0)
          AND COALESCE(stock_quantity, 0) > 0
      ''');
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v2 stock copy skipped: $e');
      }
    }

    // Stamp effective_cost from product purchase_price where still 0
    try {
      await customStatement('''
        UPDATE product_batches
        SET effective_cost = COALESCE((
          SELECT purchase_price FROM products WHERE products.uuid = product_batches.product_uuid
        ), 0)
        WHERE effective_cost = 0 OR effective_cost IS NULL
      ''');
    } catch (e) {
      if (kDebugMode) {
        print('Database migrate v2 cost stamp skipped: $e');
      }
    }
  }

  Future<void> _insertDefaultProductCategories() async {
    await batch((batch) {
      batch.insert(
        productCategories,
        ProductCategoriesCompanion.insert(
          uuid: 'default_cat_general',
          name: 'General',
          icon: Value(Symbols.category.codePoint.toString()),
          color: const Value('#757575'),
          isNotSynced: const Value(false),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Future<void> _insertDefaultCurrencies() async {
    final defaultCurrencies = [
      ('US Dollar', '\$', 'USD', 2, 'default_curr_usd'),
      ('Indian Rupee', '₹', 'INR', 0, 'default_curr_inr'),
      ('Pakistani Rupee', 'R', 'PKR', 0, 'default_curr_pkr'),
    ];

    await batch((batch) {
      for (final curr in defaultCurrencies) {
        batch.insert(
          appCurrencies,
          AppCurrenciesCompanion.insert(
            uuid: curr.$5,
            name: curr.$1,
            symbol: curr.$2,
            code: curr.$3,
            decimalPlaces: Value(curr.$4),
            isDefault: Value(curr.$3 == 'INR'),
            isNotSynced: const Value(false),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Future<void> insertDefaultData() async {
    try {
      await _insertDefaultProductCategories();
      await _insertDefaultCurrencies();
    } catch (e) {
      if (kDebugMode) {
        print('Database: Warning - Failed to insert default data: $e');
      }
    }
  }

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(catalogTieredDiscounts).go();
      await delete(catalogAssignments).go();
      await delete(catalogItems).go();
      await delete(catalogs).go();
      await delete(sellingProductComponents).go();
      await delete(sellingProducts).go();
      await delete(orderReturnItems).go();
      await delete(orderReturns).go();
      await delete(orderItems).go();
      await delete(orders).go();
      await delete(productBatches).go();
      await delete(products).go();
      await delete(transactions).go();
      await delete(accountTransfers).go();
      await delete(contacts).go();
      await delete(accounts).go();
      await delete(syncLog).go();
      await delete(syncMetadata).go();
      await delete(productCategories).go();
      await delete(appCurrencies).go();
      await insertDefaultData();
    });
  }
}