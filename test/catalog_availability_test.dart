import 'package:flutter_test/flutter_test.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_availability.dart';

Catalog _catalog({
  DateTime? validUntil,
  bool isDeleted = false,
}) {
  return Catalog(
    uuid: 'c1',
    name: 'Test',
    description: null,
    validUntil: validUntil,
    isDefault: false,
    defaultPricingApproach: 'MARKUP',
    defaultMarkupOrMarginPercent: 0,
    defaultFixedAmount: 0,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    isDeleted: isDeleted,
    isNotSynced: true,
  );
}

void main() {
  final today = DateTime(2026, 11, 18);

  group('CatalogAvailability.isActive', () {
    test('null validUntil is active', () {
      expect(CatalogAvailability.isActive(_catalog(), now: today), isTrue);
    });

    test('validUntil today is active', () {
      expect(
        CatalogAvailability.isActive(
          _catalog(validUntil: DateTime(2026, 11, 18)),
          now: today,
        ),
        isTrue,
      );
    });

    test('validUntil yesterday is expired', () {
      expect(
        CatalogAvailability.isActive(
          _catalog(validUntil: DateTime(2026, 11, 17)),
          now: today,
        ),
        isFalse,
      );
      expect(
        CatalogAvailability.isExpired(
          _catalog(validUntil: DateTime(2026, 11, 17)),
          now: today,
        ),
        isTrue,
      );
    });

    test('deleted is not active', () {
      expect(
        CatalogAvailability.isActive(_catalog(isDeleted: true), now: today),
        isFalse,
      );
    });
  });
}
