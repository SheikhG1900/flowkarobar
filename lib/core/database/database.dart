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
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();
  RealColumn get totalAmount => real()();

  TextColumn get paymentStatus => text().withDefault(const Constant('UNPAID'))(); // 'UNPAID', 'PARTIALLY_PAID', 'PAID'
  TextColumn get deliveryStatus => text().withDefault(const Constant('PENDING'))(); // 'PENDING', 'SHIPPED', 'DELIVERED', 'CANCELLED'
  
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
  TextColumn get productUuid => text().references(Products, #uuid)();
  TextColumn get productNameSnapshot => text()();

  /// Ordered qty (PO/SO commitment).
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get taxRate => real().withDefault(const Constant(0.0))();

  /// Cumulative qty received against this PO line (purchases).
  RealColumn get receivedQuantity => real().withDefault(const Constant(0.0))();

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

class Catalogs extends Table {
  TextColumn get uuid => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get validUntil => dateTime().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isNotSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {uuid};
}

class CatalogItems extends Table {
  TextColumn get uuid => text()();
  TextColumn get catalogUuid => text().references(Catalogs, #uuid)();
  TextColumn get productUuid => text().references(Products, #uuid)();
  RealColumn get customPrice => real().nullable()();
  TextColumn get batchUuid => text().nullable().references(ProductBatches, #uuid)();
  DateTimeColumn get validUntil => dateTime().nullable()();
  TextColumn get batchSelectionStrategy => text().withDefault(const Constant('FEFO_AUTO'))(); // 'FEFO_AUTO' | 'FIFO_AUTO' | 'MANUAL_BATCH'

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
  RealColumn get discountPercentage => real()();

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
  Orders,
  OrderItems,
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
  Catalogs,
  CatalogItems,
  CatalogAssignments,
  CatalogTieredDiscounts,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase({String fileName = 'flowkarobar.db', QueryExecutor? executor})
      : super(executor ?? openConnection(fileName));

  @override
  int get schemaVersion => 7;

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
        },
      );

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