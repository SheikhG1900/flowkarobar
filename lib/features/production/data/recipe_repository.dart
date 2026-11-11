import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/production/domain/production_models.dart';
import 'package:uuid/uuid.dart';

class RecipeRepository {
  final AppDatabase _db;

  RecipeRepository(this._db);

  Stream<List<Recipe>> watchAll() {
    return (_db.select(_db.recipes)
          ..where((r) => r.isDeleted.equals(false))
          ..orderBy([(r) => OrderingTerm.asc(r.name)]))
        .watch();
  }

  Stream<Recipe?> watchRecipe(String uuid) {
    return (_db.select(_db.recipes)
          ..where((r) => r.uuid.equals(uuid) & r.isDeleted.equals(false)))
        .watch()
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<Recipe?> getRecipe(String uuid) {
    return (_db.select(_db.recipes)
          ..where((r) => r.uuid.equals(uuid) & r.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<RecipeInput>> getInputs(String recipeUuid) {
    return (_db.select(_db.recipeInputs)
          ..where((i) =>
              i.recipeUuid.equals(recipeUuid) & i.isDeleted.equals(false)))
        .get();
  }

  Future<List<RecipeOutput>> getOutputs(String recipeUuid) {
    return (_db.select(_db.recipeOutputs)
          ..where((o) =>
              o.recipeUuid.equals(recipeUuid) & o.isDeleted.equals(false)))
        .get();
  }

  Future<List<RecipeCharge>> getCharges(String recipeUuid) {
    return (_db.select(_db.recipeCharges)
          ..where((c) =>
              c.recipeUuid.equals(recipeUuid) & c.isDeleted.equals(false)))
        .get();
  }

  Stream<List<RecipeInput>> watchInputs(String recipeUuid) {
    return (_db.select(_db.recipeInputs)
          ..where((i) =>
              i.recipeUuid.equals(recipeUuid) & i.isDeleted.equals(false)))
        .watch();
  }

  Stream<List<RecipeOutput>> watchOutputs(String recipeUuid) {
    return (_db.select(_db.recipeOutputs)
          ..where((o) =>
              o.recipeUuid.equals(recipeUuid) & o.isDeleted.equals(false)))
        .watch();
  }

  Stream<List<RecipeCharge>> watchCharges(String recipeUuid) {
    return (_db.select(_db.recipeCharges)
          ..where((c) =>
              c.recipeUuid.equals(recipeUuid) & c.isDeleted.equals(false)))
        .watch();
  }

  Future<String> createRecipe({
    required String name,
    String? notes,
    required List<RecipeInputsCompanion> inputs,
    required List<RecipeOutputsCompanion> outputs,
    List<RecipeChargesCompanion> charges = const [],
  }) async {
    if (name.trim().isEmpty) throw ArgumentError('Recipe name required');
    if (inputs.isEmpty) throw ArgumentError('At least one input is required');
    if (outputs.isEmpty) throw ArgumentError('At least one output is required');

    return _db.transaction(() async {
      final uuid = const Uuid().v4();
      await _db.into(_db.recipes).insert(
            RecipesCompanion.insert(
              uuid: uuid,
              name: name.trim(),
              notes: Value(notes),
            ),
          );
      await _insertLines(
        recipeUuid: uuid,
        inputs: inputs,
        outputs: outputs,
        charges: charges,
      );
      return uuid;
    });
  }

  Future<void> updateRecipe({
    required String recipeUuid,
    required String name,
    String? notes,
    required List<RecipeInputsCompanion> inputs,
    required List<RecipeOutputsCompanion> outputs,
    List<RecipeChargesCompanion> charges = const [],
  }) async {
    final existing = await getRecipe(recipeUuid);
    if (existing == null) throw StateError('Recipe not found');
    if (name.trim().isEmpty) throw ArgumentError('Recipe name required');
    if (inputs.isEmpty || outputs.isEmpty) {
      throw ArgumentError('Inputs and outputs are required');
    }

    await _db.transaction(() async {
      await (_db.update(_db.recipes)..where((r) => r.uuid.equals(recipeUuid)))
          .write(
        RecipesCompanion(
          name: Value(name.trim()),
          notes: Value(notes),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await (_db.update(_db.recipeInputs)
            ..where((i) => i.recipeUuid.equals(recipeUuid)))
          .write(
        const RecipeInputsCompanion(
          isDeleted: Value(true),
          isNotSynced: Value(true),
        ),
      );
      await (_db.update(_db.recipeOutputs)
            ..where((o) => o.recipeUuid.equals(recipeUuid)))
          .write(
        const RecipeOutputsCompanion(
          isDeleted: Value(true),
          isNotSynced: Value(true),
        ),
      );
      await (_db.update(_db.recipeCharges)
            ..where((c) => c.recipeUuid.equals(recipeUuid)))
          .write(
        const RecipeChargesCompanion(
          isDeleted: Value(true),
          isNotSynced: Value(true),
        ),
      );

      await _insertLines(
        recipeUuid: recipeUuid,
        inputs: inputs,
        outputs: outputs,
        charges: charges,
      );
    });
  }

  Future<void> _insertLines({
    required String recipeUuid,
    required List<RecipeInputsCompanion> inputs,
    required List<RecipeOutputsCompanion> outputs,
    required List<RecipeChargesCompanion> charges,
  }) async {
    for (final input in inputs) {
      final id = input.uuid.present ? input.uuid.value : const Uuid().v4();
      await _db.into(_db.recipeInputs).insert(
            input.copyWith(
              uuid: Value(id),
              recipeUuid: Value(recipeUuid),
              isDeleted: const Value(false),
              isNotSynced: const Value(true),
            ),
          );
    }
    for (final output in outputs) {
      final id = output.uuid.present ? output.uuid.value : const Uuid().v4();
      await _db.into(_db.recipeOutputs).insert(
            output.copyWith(
              uuid: Value(id),
              recipeUuid: Value(recipeUuid),
              isDeleted: const Value(false),
              isNotSynced: const Value(true),
            ),
          );
    }
    for (final charge in charges) {
      final id = charge.uuid.present ? charge.uuid.value : const Uuid().v4();
      await _db.into(_db.recipeCharges).insert(
            charge.copyWith(
              uuid: Value(id),
              recipeUuid: Value(recipeUuid),
              isDeleted: const Value(false),
              isNotSynced: const Value(true),
            ),
          );
    }
  }

  Future<void> deleteRecipe(String recipeUuid) async {
    await (_db.update(_db.recipes)..where((r) => r.uuid.equals(recipeUuid)))
        .write(
      RecipesCompanion(
        isDeleted: const Value(true),
        isNotSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Create a draft production order by copying & scaling a recipe.
  /// [scaleFactor] multiplies all qty and charge amounts (must be > 0).
  Future<String> createProductionFromRecipe({
    required String recipeUuid,
    required double scaleFactor,
    DateTime? productionDate,
    String? notes,
  }) async {
    if (scaleFactor <= 1e-9) {
      throw ArgumentError('scaleFactor must be > 0');
    }
    final recipe = await getRecipe(recipeUuid);
    if (recipe == null) throw StateError('Recipe not found');

    final inputs = await getInputs(recipeUuid);
    final outputs = await getOutputs(recipeUuid);
    final charges = await getCharges(recipeUuid);
    if (inputs.isEmpty || outputs.isEmpty) {
      throw StateError('Recipe must have inputs and outputs');
    }

    final date = productionDate ?? DateTime.now();
    final uuid = const Uuid().v4();
    final now = DateTime.now();
    final prefix =
        'PROD-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-';
    final existing = await (_db.select(_db.productionOrders)
          ..where((o) => o.productionNumber.like('$prefix%')))
        .get();
    final number =
        '$prefix${(existing.length + 1).toString().padLeft(3, '0')}';

    return _db.transaction(() async {
      await _db.into(_db.productionOrders).insert(
            ProductionOrdersCompanion.insert(
              uuid: uuid,
              productionNumber: number,
              productionDate: date,
              status: const Value(ProductionStatus.draft),
              notes: Value(notes),
              recipeUuid: Value(recipe.uuid),
              recipeNameSnapshot: Value(recipe.name),
              scaleFactor: Value(scaleFactor),
            ),
          );

      for (final i in inputs) {
        final mode = ProductionConsumeMode.all.contains(i.consumeMode)
            ? i.consumeMode
            : ProductionConsumeMode.auto;
        final batch = i.batchNumber?.trim();
        await _db.into(_db.productionOrderInputs).insert(
              ProductionOrderInputsCompanion.insert(
                uuid: const Uuid().v4(),
                productionOrderUuid: uuid,
                productUuid: i.productUuid,
                productNameSnapshot: i.productNameSnapshot,
                plannedQuantity: i.quantity * scaleFactor,
                consumeMode: Value(mode),
                batchNumber: Value(
                  mode == ProductionConsumeMode.batch &&
                          batch != null &&
                          batch.isNotEmpty
                      ? batch
                      : null,
                ),
                unit: Value(i.unit),
              ),
            );
      }
      for (final o in outputs) {
        await _db.into(_db.productionOrderOutputs).insert(
              ProductionOrderOutputsCompanion.insert(
                uuid: const Uuid().v4(),
                productionOrderUuid: uuid,
                productUuid: o.productUuid,
                productNameSnapshot: o.productNameSnapshot,
                plannedQuantity: o.quantity * scaleFactor,
                costWeight: Value(o.costWeight <= 0 ? 1.0 : o.costWeight),
                unit: Value(o.unit),
              ),
            );
      }
      for (final c in charges) {
        await _db.into(_db.productionOrderCharges).insert(
              ProductionOrderChargesCompanion.insert(
                uuid: const Uuid().v4(),
                productionOrderUuid: uuid,
                description: c.description,
                amount: Value(c.amount * scaleFactor),
              ),
            );
      }
      return uuid;
    });
  }
}
