import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/inventory/data/inventory_repository.dart';
import 'package:flowpaisa/features/inventory/domain/batch_models.dart';
import 'package:flowpaisa/features/production/domain/production_models.dart';
import 'package:uuid/uuid.dart';

class ProductionStockShortfall {
  final String productUuid;
  final String productName;
  final String? batchNumber;
  final double required;
  final double available;
  final bool missingBatch;

  const ProductionStockShortfall({
    required this.productUuid,
    required this.productName,
    required this.required,
    required this.available,
    this.batchNumber,
    this.missingBatch = false,
  });
}

class ProductionInputImpact {
  final String inputUuid;
  final String productUuid;
  final String productName;
  final String unit;
  final String? batchNumber;
  final bool batchMode;
  final bool missingBatch;
  final double required;
  final double available;
  final double remainingAfter;
  final double estimatedMaterialCost;
  /// Avg unit cost of available open stock (batch-scoped when set).
  final double currentUnitCost;
  /// FEFO unit cost of the qty being consumed.
  final double consumeUnitCost;
  /// Blended avg unit cost of stock left after consume.
  final double unitCostAfter;

  const ProductionInputImpact({
    required this.inputUuid,
    required this.productUuid,
    required this.productName,
    required this.unit,
    required this.required,
    required this.available,
    required this.remainingAfter,
    required this.estimatedMaterialCost,
    required this.batchMode,
    required this.missingBatch,
    required this.currentUnitCost,
    required this.consumeUnitCost,
    required this.unitCostAfter,
    this.batchNumber,
  });

  bool get insufficient => missingBatch || required > available + 1e-9;
}

class ProductionOutputImpact {
  final String outputUuid;
  final String productUuid;
  final String productName;
  final String unit;
  final double quantity;
  final double costWeight;
  /// Calculated production unit cost for this output line.
  final double unitCost;
  final double shareCost;
  final double currentStock;
  final double stockAfter;
  /// Current avg unit cost of open stock (batch-scoped when [batchNumber] set).
  final double currentUnitCost;
  /// Blended avg unit cost after landing this production qty.
  final double unitCostAfter;
  final String? batchNumber;

  const ProductionOutputImpact({
    required this.outputUuid,
    required this.productUuid,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.costWeight,
    required this.unitCost,
    required this.shareCost,
    required this.currentStock,
    required this.stockAfter,
    required this.currentUnitCost,
    required this.unitCostAfter,
    this.batchNumber,
  });
}

class ProductionCompletionPreview {
  final double materialCost;
  final double chargesTotal;
  final double totalCost;
  final List<ProductionInputImpact> inputs;
  final List<ProductionOutputImpact> outputs;

  const ProductionCompletionPreview({
    required this.materialCost,
    required this.chargesTotal,
    required this.totalCost,
    required this.inputs,
    required this.outputs,
  });
}

class ProductionRepository {
  final AppDatabase _db;
  late final InventoryRepository _inventory;

  ProductionRepository(this._db) : _inventory = InventoryRepository(_db);

  Stream<List<ProductionOrder>> watchAll() {
    return (_db.select(_db.productionOrders)
          ..where((o) => o.isDeleted.equals(false))
          ..orderBy([(o) => OrderingTerm.desc(o.productionDate)]))
        .watch();
  }

  Stream<ProductionOrder?> watchOrder(String uuid) {
    return (_db.select(_db.productionOrders)
          ..where((o) => o.uuid.equals(uuid) & o.isDeleted.equals(false)))
        .watch()
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<ProductionOrder?> getOrder(String uuid) {
    return (_db.select(_db.productionOrders)
          ..where((o) => o.uuid.equals(uuid) & o.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Stream<List<ProductionOrderInput>> watchInputs(String orderUuid) {
    return (_db.select(_db.productionOrderInputs)
          ..where((i) =>
              i.productionOrderUuid.equals(orderUuid) &
              i.isDeleted.equals(false)))
        .watch();
  }

  Stream<List<ProductionOrderOutput>> watchOutputs(String orderUuid) {
    return (_db.select(_db.productionOrderOutputs)
          ..where((o) =>
              o.productionOrderUuid.equals(orderUuid) &
              o.isDeleted.equals(false)))
        .watch();
  }

  Stream<List<ProductionOrderCharge>> watchCharges(String orderUuid) {
    return (_db.select(_db.productionOrderCharges)
          ..where((c) =>
              c.productionOrderUuid.equals(orderUuid) &
              c.isDeleted.equals(false)))
        .watch();
  }

  Future<List<ProductionOrderInput>> getInputs(String orderUuid) {
    return (_db.select(_db.productionOrderInputs)
          ..where((i) =>
              i.productionOrderUuid.equals(orderUuid) &
              i.isDeleted.equals(false)))
        .get();
  }

  Future<List<ProductionOrderOutput>> getOutputs(String orderUuid) {
    return (_db.select(_db.productionOrderOutputs)
          ..where((o) =>
              o.productionOrderUuid.equals(orderUuid) &
              o.isDeleted.equals(false)))
        .get();
  }

  Future<List<ProductionOrderCharge>> getCharges(String orderUuid) {
    return (_db.select(_db.productionOrderCharges)
          ..where((c) =>
              c.productionOrderUuid.equals(orderUuid) &
              c.isDeleted.equals(false)))
        .get();
  }

  Future<String> _nextProductionNumber() async {
    final now = DateTime.now();
    final prefix =
        'PROD-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-';
    final existing = await (_db.select(_db.productionOrders)
          ..where((o) => o.productionNumber.like('$prefix%')))
        .get();
    final seq = (existing.length + 1).toString().padLeft(3, '0');
    return '$prefix$seq';
  }

  /// Create a draft production order with inputs, outputs, and charges.
  Future<String> createDraft({
    required DateTime productionDate,
    String? notes,
    String? recipeUuid,
    String? recipeNameSnapshot,
    double scaleFactor = 1.0,
    required List<ProductionOrderInputsCompanion> inputs,
    required List<ProductionOrderOutputsCompanion> outputs,
    List<ProductionOrderChargesCompanion> charges = const [],
  }) async {
    if (inputs.isEmpty) {
      throw ArgumentError('At least one input is required');
    }
    if (outputs.isEmpty) {
      throw ArgumentError('At least one output is required');
    }

    return _db.transaction(() async {
      final uuid = const Uuid().v4();
      final number = await _nextProductionNumber();
      await _db.into(_db.productionOrders).insert(
            ProductionOrdersCompanion.insert(
              uuid: uuid,
              productionNumber: number,
              productionDate: productionDate,
              status: const Value(ProductionStatus.draft),
              notes: Value(notes),
              recipeUuid: Value(recipeUuid),
              recipeNameSnapshot: Value(recipeNameSnapshot),
              scaleFactor: Value(scaleFactor <= 0 ? 1.0 : scaleFactor),
            ),
          );

      for (final input in inputs) {
        final id = input.uuid.present ? input.uuid.value : const Uuid().v4();
        await _db.into(_db.productionOrderInputs).insert(
              input.copyWith(
                uuid: Value(id),
                productionOrderUuid: Value(uuid),
                isNotSynced: const Value(true),
              ),
            );
      }
      for (final output in outputs) {
        final id = output.uuid.present ? output.uuid.value : const Uuid().v4();
        await _db.into(_db.productionOrderOutputs).insert(
              output.copyWith(
                uuid: Value(id),
                productionOrderUuid: Value(uuid),
                isNotSynced: const Value(true),
              ),
            );
      }
      for (final charge in charges) {
        final id = charge.uuid.present ? charge.uuid.value : const Uuid().v4();
        await _db.into(_db.productionOrderCharges).insert(
              charge.copyWith(
                uuid: Value(id),
                productionOrderUuid: Value(uuid),
                isNotSynced: const Value(true),
              ),
            );
      }
      return uuid;
    });
  }

  Future<void> updateDraft({
    required String orderUuid,
    required DateTime productionDate,
    String? notes,
    double? scaleFactor,
    required List<ProductionOrderInputsCompanion> inputs,
    required List<ProductionOrderOutputsCompanion> outputs,
    List<ProductionOrderChargesCompanion> charges = const [],
  }) async {
    final order = await getOrder(orderUuid);
    if (order == null) throw StateError('Production order not found');
    if (order.status != ProductionStatus.draft) {
      throw StateError('Only draft production orders can be edited');
    }
    if (inputs.isEmpty || outputs.isEmpty) {
      throw ArgumentError('Inputs and outputs are required');
    }

    await _db.transaction(() async {
      await (_db.update(_db.productionOrders)
            ..where((o) => o.uuid.equals(orderUuid)))
          .write(
        ProductionOrdersCompanion(
          productionDate: Value(productionDate),
          notes: Value(notes),
          scaleFactor: scaleFactor == null
              ? const Value.absent()
              : Value(scaleFactor <= 0 ? 1.0 : scaleFactor),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await (_db.update(_db.productionOrderInputs)
            ..where((i) => i.productionOrderUuid.equals(orderUuid)))
          .write(
        const ProductionOrderInputsCompanion(
          isDeleted: Value(true),
          isNotSynced: Value(true),
        ),
      );
      await (_db.update(_db.productionOrderOutputs)
            ..where((o) => o.productionOrderUuid.equals(orderUuid)))
          .write(
        const ProductionOrderOutputsCompanion(
          isDeleted: Value(true),
          isNotSynced: Value(true),
        ),
      );
      await (_db.update(_db.productionOrderCharges)
            ..where((c) => c.productionOrderUuid.equals(orderUuid)))
          .write(
        const ProductionOrderChargesCompanion(
          isDeleted: Value(true),
          isNotSynced: Value(true),
        ),
      );

      for (final input in inputs) {
        final id = input.uuid.present ? input.uuid.value : const Uuid().v4();
        await _db.into(_db.productionOrderInputs).insert(
              input.copyWith(
                uuid: Value(id),
                productionOrderUuid: Value(orderUuid),
                isDeleted: const Value(false),
                isNotSynced: const Value(true),
              ),
            );
      }
      for (final output in outputs) {
        final id = output.uuid.present ? output.uuid.value : const Uuid().v4();
        await _db.into(_db.productionOrderOutputs).insert(
              output.copyWith(
                uuid: Value(id),
                productionOrderUuid: Value(orderUuid),
                isDeleted: const Value(false),
                isNotSynced: const Value(true),
              ),
            );
      }
      for (final charge in charges) {
        final id = charge.uuid.present ? charge.uuid.value : const Uuid().v4();
        await _db.into(_db.productionOrderCharges).insert(
              charge.copyWith(
                uuid: Value(id),
                productionOrderUuid: Value(orderUuid),
                isDeleted: const Value(false),
                isNotSynced: const Value(true),
              ),
            );
      }
    });
  }

  Future<void> cancel(String orderUuid) async {
    final order = await getOrder(orderUuid);
    if (order == null) throw StateError('Production order not found');
    if (order.status != ProductionStatus.draft) {
      throw StateError('Only draft orders can be cancelled');
    }
    await (_db.update(_db.productionOrders)
          ..where((o) => o.uuid.equals(orderUuid)))
        .write(
      ProductionOrdersCompanion(
        status: const Value(ProductionStatus.cancelled),
        isNotSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Soft-delete a draft/cancelled order.
  Future<void> deleteOrder(String orderUuid) async {
    final order = await getOrder(orderUuid);
    if (order == null) return;
    if (order.status == ProductionStatus.completed) {
      throw StateError('Completed production orders cannot be deleted');
    }
    await (_db.update(_db.productionOrders)
          ..where((o) => o.uuid.equals(orderUuid)))
        .write(
      ProductionOrdersCompanion(
        isDeleted: const Value(true),
        isNotSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Check stock for each input without consuming.
  Future<List<ProductionStockShortfall>> validateStock(
    String orderUuid, {
    Map<String, double>? actualQtyByInputId,
  }) async {
    final inputs = await getInputs(orderUuid);
    final shortfalls = <ProductionStockShortfall>[];
    for (final input in inputs) {
      final need = actualQtyByInputId?[input.uuid] ??
          (input.actualQuantity > 1e-9
              ? input.actualQuantity
              : input.plannedQuantity);
      if (need <= 1e-9) continue;
      final batchScope = input.consumeMode == ProductionConsumeMode.batch
          ? input.batchNumber
          : null;
      if (input.consumeMode == ProductionConsumeMode.batch &&
          (batchScope == null || batchScope.trim().isEmpty)) {
        shortfalls.add(
          ProductionStockShortfall(
            productUuid: input.productUuid,
            productName: input.productNameSnapshot,
            batchNumber: batchScope,
            required: need,
            available: 0,
            missingBatch: true,
          ),
        );
        continue;
      }
      final available = await _inventory.availableQuantity(
        productUuid: input.productUuid,
        batchNumber: batchScope,
      );
      if (need > available + 1e-9) {
        shortfalls.add(
          ProductionStockShortfall(
            productUuid: input.productUuid,
            productName: input.productNameSnapshot,
            batchNumber: batchScope,
            required: need,
            available: available,
          ),
        );
      }
    }
    return shortfalls;
  }

  /// Draft preview: stock left after consume + estimated output unit costs.
  Future<ProductionCompletionPreview> previewCompletion(
    String orderUuid, {
    Map<String, double>? actualInputQty,
    Map<String, double>? actualOutputQty,
  }) async {
    final inputs = await getInputs(orderUuid);
    final outputs = await getOutputs(orderUuid);
    final charges = await getCharges(orderUuid);
    final chargesTotal = charges.fold<double>(0, (s, c) => s + c.amount);

    var materialCost = 0.0;
    final inputImpacts = <ProductionInputImpact>[];
    for (final input in inputs) {
      final need = actualInputQty?[input.uuid] ??
          (input.actualQuantity > 1e-9
              ? input.actualQuantity
              : input.plannedQuantity);
      final batchMode = input.consumeMode == ProductionConsumeMode.batch;
      final batchScope = batchMode ? input.batchNumber : null;
      final missingBatch =
          batchMode && (batchScope == null || batchScope.trim().isEmpty);

      double available = 0;
      double estimatedCost = 0;
      double currentUnitCost = 0;
      if (!missingBatch) {
        available = await _inventory.availableQuantity(
          productUuid: input.productUuid,
          batchNumber: batchScope,
        );
        currentUnitCost = await _inventory.averageUnitCost(
          productUuid: input.productUuid,
          batchNumber: batchScope,
        );
        if (need > 1e-9) {
          final peek = await _inventory.peekFefo(
            productUuid: input.productUuid,
            quantity: need <= available ? need : available,
            batchNumber: batchScope,
          );
          estimatedCost =
              peek.fold<double>(0, (s, a) => s + a.quantity * a.effectiveCost);
          if (need <= available + 1e-9) {
            materialCost += estimatedCost;
          } else if (available > 1e-9) {
            // Partial cost estimate when short; still show available slice cost.
            materialCost += estimatedCost;
          }
        }
      }

      final remainingAfter = missingBatch ? 0.0 : (available - need);
      final consumedQty = need <= available ? need : available;
      final consumeUnitCost =
          consumedQty > 1e-9 ? estimatedCost / consumedQty : 0.0;
      final remainingValue =
          (available * currentUnitCost) - estimatedCost;
      final unitCostAfter = remainingAfter > 1e-9
          ? (remainingValue / remainingAfter).clamp(0.0, double.infinity)
          : 0.0;

      inputImpacts.add(
        ProductionInputImpact(
          inputUuid: input.uuid,
          productUuid: input.productUuid,
          productName: input.productNameSnapshot,
          unit: input.unit,
          batchNumber: batchScope,
          batchMode: batchMode,
          missingBatch: missingBatch,
          required: need,
          available: available,
          remainingAfter: remainingAfter,
          estimatedMaterialCost: estimatedCost,
          currentUnitCost: currentUnitCost,
          consumeUnitCost: consumeUnitCost,
          unitCostAfter: unitCostAfter,
        ),
      );
    }

    final resolved = <({ProductionOrderOutput line, double qty})>[];
    for (final output in outputs) {
      final qty = actualOutputQty?[output.uuid] ??
          (output.actualQuantity > 1e-9
              ? output.actualQuantity
              : output.plannedQuantity);
      if (qty <= 1e-9) continue;
      resolved.add((line: output, qty: qty));
    }

    final weightSum = resolved.fold<double>(
      0,
      (s, o) => s + (o.line.costWeight <= 0 ? 1.0 : o.line.costWeight),
    );
    final totalCost = materialCost + chargesTotal;

    final outputImpacts = <ProductionOutputImpact>[];
    for (final item in resolved) {
      final weight = item.line.costWeight <= 0 ? 1.0 : item.line.costWeight;
      final share = weightSum <= 1e-9 ? 0.0 : totalCost * (weight / weightSum);
      final unitCost = share / item.qty;
      final batch = item.line.batchNumber.trim();
      final hasBatch = batch.isNotEmpty;
      final batchScope = hasBatch ? batch : null;
      // When an output batch is chosen, mirror inputs: stock math is scoped
      // to that batch label. Otherwise use product-level open stock.
      final currentStock = await _inventory.availableQuantity(
        productUuid: item.line.productUuid,
        batchNumber: batchScope,
      );
      final currentUnitCost = await _inventory.averageUnitCost(
        productUuid: item.line.productUuid,
        batchNumber: batchScope,
      );
      final stockAfter = currentStock + item.qty;
      final unitCostAfter = stockAfter <= 1e-9
          ? unitCost
          : ((currentStock * currentUnitCost) + (item.qty * unitCost)) /
              stockAfter;
      outputImpacts.add(
        ProductionOutputImpact(
          outputUuid: item.line.uuid,
          productUuid: item.line.productUuid,
          productName: item.line.productNameSnapshot,
          unit: item.line.unit,
          quantity: item.qty,
          costWeight: weight,
          unitCost: unitCost,
          shareCost: share,
          currentStock: currentStock,
          stockAfter: stockAfter,
          currentUnitCost: currentUnitCost,
          unitCostAfter: unitCostAfter,
          batchNumber: batchScope,
        ),
      );
    }

    return ProductionCompletionPreview(
      materialCost: materialCost,
      chargesTotal: chargesTotal,
      totalCost: totalCost,
      inputs: inputImpacts,
      outputs: outputImpacts,
    );
  }

  /// Complete: verify stock, consume inputs, land charges, create output lots.
  Future<void> complete(
    String orderUuid, {
    Map<String, double>? actualInputQty,
    Map<String, double>? actualOutputQty,
  }) async {
    final order = await getOrder(orderUuid);
    if (order == null) throw StateError('Production order not found');
    if (order.status != ProductionStatus.draft) {
      throw StateError('Only draft production orders can be completed');
    }

    final shortfalls =
        await validateStock(orderUuid, actualQtyByInputId: actualInputQty);
    if (shortfalls.isNotEmpty) {
      final first = shortfalls.first;
      final scope = first.batchNumber == null || first.batchNumber!.isEmpty
          ? ''
          : ' (batch ${first.batchNumber})';
      throw StateError(
        'Insufficient stock for ${first.productName}$scope: '
        'need ${first.required}, have ${first.available}',
      );
    }

    await _db.transaction(() async {
      final inputs = await getInputs(orderUuid);
      final outputs = await getOutputs(orderUuid);
      final charges = await getCharges(orderUuid);

      if (outputs.isEmpty) {
        throw StateError('No outputs to produce');
      }

      // Re-validate inside transaction.
      final shortfallsTx =
          await validateStock(orderUuid, actualQtyByInputId: actualInputQty);
      if (shortfallsTx.isNotEmpty) {
        throw StateError('Stock changed; insufficient quantity to complete');
      }

      var materialCost = 0.0;
      for (final input in inputs) {
        final qty = actualInputQty?[input.uuid] ??
            (input.actualQuantity > 1e-9
                ? input.actualQuantity
                : input.plannedQuantity);
        if (qty <= 1e-9) {
          await (_db.update(_db.productionOrderInputs)
                ..where((i) => i.uuid.equals(input.uuid)))
              .write(
            ProductionOrderInputsCompanion(
              actualQuantity: const Value(0),
              isNotSynced: const Value(true),
              updatedAt: Value(DateTime.now()),
            ),
          );
          continue;
        }

        final batchScope = input.consumeMode == ProductionConsumeMode.batch
            ? input.batchNumber
            : null;
        final allocations = await _inventory.consumeFefo(
          productUuid: input.productUuid,
          quantity: qty,
          batchNumber: batchScope,
        );

        for (final a in allocations) {
          materialCost += a.quantity * a.effectiveCost;
          await _db.into(_db.productionConsumptions).insert(
                ProductionConsumptionsCompanion.insert(
                  uuid: const Uuid().v4(),
                  productionOrderUuid: orderUuid,
                  inputLineUuid: input.uuid,
                  lotUuid: a.batchUuid,
                  quantity: a.quantity,
                  effectiveCost: a.effectiveCost,
                ),
              );
        }

        await (_db.update(_db.productionOrderInputs)
              ..where((i) => i.uuid.equals(input.uuid)))
            .write(
          ProductionOrderInputsCompanion(
            actualQuantity: Value(qty),
            isNotSynced: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      final chargesTotal =
          charges.fold<double>(0, (s, c) => s + c.amount);
      final totalCost = materialCost + chargesTotal;

      final resolvedOutputs = <({ProductionOrderOutput line, double qty})>[];
      for (final output in outputs) {
        final qty = actualOutputQty?[output.uuid] ??
            (output.actualQuantity > 1e-9
                ? output.actualQuantity
                : output.plannedQuantity);
        if (qty <= 1e-9) {
          throw StateError(
            'Output ${output.productNameSnapshot} quantity must be > 0',
          );
        }
        resolvedOutputs.add((line: output, qty: qty));
      }

      final weightSum = resolvedOutputs.fold<double>(
        0,
        (s, o) => s + (o.line.costWeight <= 0 ? 1.0 : o.line.costWeight),
      );

      for (final item in resolvedOutputs) {
        final weight =
            item.line.costWeight <= 0 ? 1.0 : item.line.costWeight;
        final share = weightSum <= 1e-9 ? 0.0 : totalCost * (weight / weightSum);
        final unitCost = share / item.qty;

        var batchNum = item.line.batchNumber.trim();
        if (batchNum.isEmpty) {
          batchNum = order.productionNumber;
        }

        final lotUuid = await _inventory.receiveIntoBatch(
          productUuid: item.line.productUuid,
          quantity: item.qty,
          effectiveCost: unitCost,
          batchNumber: batchNum,
          isManual: true,
          manualType: ManualBatchType.production,
        );

        await (_db.update(_db.productionOrderOutputs)
              ..where((o) => o.uuid.equals(item.line.uuid)))
            .write(
          ProductionOrderOutputsCompanion(
            actualQuantity: Value(item.qty),
            unitCostSnapshot: Value(unitCost),
            outputLotUuid: Value(lotUuid),
            batchNumber: Value(batchNum),
            isNotSynced: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      await (_db.update(_db.productionOrders)
            ..where((o) => o.uuid.equals(orderUuid)))
          .write(
        ProductionOrdersCompanion(
          status: const Value(ProductionStatus.completed),
          completedAt: Value(DateTime.now()),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }
}
