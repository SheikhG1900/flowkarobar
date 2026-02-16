extension ListExtensions<T> on List<T> {
  /// Returns true if the list contains any of the elements in the [other] list.
  bool containsAny(List<T> other) {
    return other.any((element) => contains(element));
  }

  /// Returns true if the list contains all of the elements in the [other] list.
  bool containsAll(List<T> other) {
    return other.every((element) => contains(element));
  }
}

extension ListStringExtensions on List<String> {
  /// Generates combinations of strings from this list and [other] list.
  /// Each string from this list is joined with each string from [other] using each separator in [separators].
  List<String> makeCombinations(List<String> other, [List<String> separators = const [' ']]) {
    final List<String> result = [];
    for (final first in this) {
      for (final second in other) {
        for (final sep in separators) {
          result.add('$first$sep$second');
        }
      }
    }
    return result;
  }
}
