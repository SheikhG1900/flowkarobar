import 'package:flutter_test/flutter_test.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_discounts.dart';

void main() {
  group('SaleLinePricing', () {
    test('unit and line discount from list vs discounted', () {
      expect(
        SaleLinePricing.unitDiscountFixed(
          listUnitPrice: 100,
          discountedUnitPrice: 85,
        ),
        15,
      );
      expect(
        SaleLinePricing.unitDiscountPercent(
          listUnitPrice: 100,
          discountedUnitPrice: 85,
        ),
        15,
      );
      expect(
        SaleLinePricing.lineDiscountFixed(
          listUnitPrice: 100,
          discountedUnitPrice: 85,
          quantity: 3,
        ),
        45,
      );
      expect(
        SaleLinePricing.lineTotal(discountedUnitPrice: 85, quantity: 3),
        255,
      );
      expect(
        SaleLinePricing.lineGross(listUnitPrice: 100, quantity: 3),
        300,
      );
    });
  });

  group('CatalogDiscounts.applyDiscount', () {
    test('percent off', () {
      expect(
        CatalogDiscounts.applyDiscount(
          sellPrice: 100,
          type: CatalogDiscountType.percent,
          value: 10,
        ),
        90,
      );
    });

    test('fixed off per unit', () {
      expect(
        CatalogDiscounts.applyDiscount(
          sellPrice: 100,
          type: CatalogDiscountType.fixed,
          value: 15,
        ),
        85,
      );
    });

    test('fixed does not go below zero', () {
      expect(
        CatalogDiscounts.applyDiscount(
          sellPrice: 10,
          type: CatalogDiscountType.fixed,
          value: 50,
        ),
        0,
      );
    });
  });

  group('CatalogDiscounts.unitPriceAfterDiscounts', () {
    test('uses default when no tier matches', () {
      final price = CatalogDiscounts.unitPriceAfterDiscounts(
        sellPrice: 100,
        defaultType: CatalogDiscountType.percent,
        defaultValue: 5,
        quantity: 2,
        tiers: [
          (minQuantity: 10, type: CatalogDiscountType.percent, value: 15),
        ],
      );
      expect(price, 95);
    });

    test('tier replaces default when qty matches', () {
      final price = CatalogDiscounts.unitPriceAfterDiscounts(
        sellPrice: 100,
        defaultType: CatalogDiscountType.percent,
        defaultValue: 5,
        quantity: 12,
        tiers: [
          (minQuantity: 10, type: CatalogDiscountType.percent, value: 15),
          (minQuantity: 50, type: CatalogDiscountType.fixed, value: 20),
        ],
      );
      expect(price, 85);
    });

    test('picks highest matching minQuantity', () {
      final price = CatalogDiscounts.unitPriceAfterDiscounts(
        sellPrice: 100,
        quantity: 60,
        tiers: [
          (minQuantity: 10, type: CatalogDiscountType.percent, value: 10),
          (minQuantity: 50, type: CatalogDiscountType.fixed, value: 25),
        ],
      );
      expect(price, 75);
    });
  });

  group('CatalogDiscounts.lineDiscountAmount', () {
    test('default percent on qty 1', () {
      expect(
        CatalogDiscounts.lineDiscountAmount(
          sellPrice: 100,
          defaultType: CatalogDiscountType.percent,
          defaultValue: 10,
          quantity: 1,
          tiers: const [],
        ),
        10,
      );
    });

    test('tier replaces default across qty', () {
      expect(
        CatalogDiscounts.lineDiscountAmount(
          sellPrice: 100,
          defaultType: CatalogDiscountType.percent,
          defaultValue: 5,
          quantity: 10,
          tiers: [
            (minQuantity: 10, type: CatalogDiscountType.percent, value: 20),
          ],
        ),
        200,
      );
    });
  });
}
