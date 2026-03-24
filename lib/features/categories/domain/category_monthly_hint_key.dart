/// Key for [categoryMonthlyBudgetHintProvider]: category + calendar day (month bucket).
class CategoryMonthlyHintKey {
  final String? categoryUuid;
  final DateTime referenceDate;

  const CategoryMonthlyHintKey(this.categoryUuid, this.referenceDate);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryMonthlyHintKey &&
          other.categoryUuid == categoryUuid &&
          other.referenceDate.year == referenceDate.year &&
          other.referenceDate.month == referenceDate.month &&
          other.referenceDate.day == referenceDate.day;

  @override
  int get hashCode => Object.hash(
        categoryUuid,
        referenceDate.year,
        referenceDate.month,
        referenceDate.day,
      );
}
