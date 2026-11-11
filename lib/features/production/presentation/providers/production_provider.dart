import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/production/data/production_repository.dart';
import 'package:flowpaisa/features/production/data/recipe_repository.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

final productionRepositoryProvider = Provider<ProductionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ProductionRepository(db);
});

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return RecipeRepository(db);
});

final productionOrdersStreamProvider =
    StreamProvider<List<ProductionOrder>>((ref) {
  return ref.watch(productionRepositoryProvider).watchAll();
});

final recipesStreamProvider = StreamProvider<List<Recipe>>((ref) {
  return ref.watch(recipeRepositoryProvider).watchAll();
});

final recipeStreamProvider =
    StreamProvider.family<Recipe?, String>((ref, uuid) {
  return ref.watch(recipeRepositoryProvider).watchRecipe(uuid);
});

final recipeInputsStreamProvider =
    StreamProvider.family<List<RecipeInput>, String>((ref, uuid) {
  return ref.watch(recipeRepositoryProvider).watchInputs(uuid);
});

final recipeOutputsStreamProvider =
    StreamProvider.family<List<RecipeOutput>, String>((ref, uuid) {
  return ref.watch(recipeRepositoryProvider).watchOutputs(uuid);
});

final recipeChargesStreamProvider =
    StreamProvider.family<List<RecipeCharge>, String>((ref, uuid) {
  return ref.watch(recipeRepositoryProvider).watchCharges(uuid);
});

final productionOrderStreamProvider =
    StreamProvider.family<ProductionOrder?, String>((ref, uuid) {
  return ref.watch(productionRepositoryProvider).watchOrder(uuid);
});

final productionInputsStreamProvider =
    StreamProvider.family<List<ProductionOrderInput>, String>((ref, uuid) {
  return ref.watch(productionRepositoryProvider).watchInputs(uuid);
});

final productionOutputsStreamProvider =
    StreamProvider.family<List<ProductionOrderOutput>, String>((ref, uuid) {
  return ref.watch(productionRepositoryProvider).watchOutputs(uuid);
});

final productionChargesStreamProvider =
    StreamProvider.family<List<ProductionOrderCharge>, String>((ref, uuid) {
  return ref.watch(productionRepositoryProvider).watchCharges(uuid);
});
