import 'package:flutter_test/flutter_test.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_pricing.dart';

void main() {
  group('CatalogPricing.computeSellPrice', () {
    test('markup: percent then fixed', () {
      expect(
        CatalogPricing.computeSellPrice(
          approach: CatalogPricingApproach.markup,
          unitCost: 100,
          percent: 20,
          fixedAmount: 50,
        ),
        170,
      );
    });

    test('markupOnBase: fixed then percent', () {
      expect(
        CatalogPricing.computeSellPrice(
          approach: CatalogPricingApproach.markupOnBase,
          unitCost: 100,
          percent: 20,
          fixedAmount: 50,
        ),
        180,
      );
    });

    test('margin: (cost + fixed) / (1 - p/100)', () {
      expect(
        CatalogPricing.computeSellPrice(
          approach: CatalogPricingApproach.margin,
          unitCost: 100,
          percent: 20,
          fixedAmount: 50,
        ),
        187.5,
      );
    });

    test('marginThenFixed: cost/(1-p/100) + fixed', () {
      expect(
        CatalogPricing.computeSellPrice(
          approach: CatalogPricingApproach.marginThenFixed,
          unitCost: 100,
          percent: 20,
          fixedAmount: 50,
        ),
        175,
      );
    });

    test('margin rejects percent >= 100', () {
      expect(
        () => CatalogPricing.computeSellPrice(
          approach: CatalogPricingApproach.margin,
          unitCost: 100,
          percent: 100,
          fixedAmount: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('CatalogPricing.isValidLink', () {
    test('exactly one of product or selling', () {
      expect(
        CatalogPricing.isValidLink(productUuid: 'p1'),
        isTrue,
      );
      expect(
        CatalogPricing.isValidLink(sellingProductUuid: 's1'),
        isTrue,
      );
      expect(CatalogPricing.isValidLink(), isFalse);
      expect(
        CatalogPricing.isValidLink(
          productUuid: 'p1',
          sellingProductUuid: 's1',
        ),
        isFalse,
      );
    });
  });
}
