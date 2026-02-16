extension StringExtensions on String {
  /// Returns true if the string contains any of the elements in the [list].
  bool containsAny(List<String> list) {
    return list.any((element) => contains(element));
  }

  /// Returns true if the string starts with any of the elements in the [list].
  bool startsWithAny(List<String> list) {
    return list.any((element) => startsWith(element));
  }

  /// Returns true if the string contains all of the elements in the [list].
  bool containsAll(List<String> list) {
    return list.every((element) => contains(element));
  }

  /// Generates combinations of this string with each string from [other] list.
  /// This string is joined with each string from [other] using each separator in [separators].
  List<String> makeCombinations(List<String> other, [List<String> separators = const [' ']]) {
    final List<String> result = [];
    for (final second in other) {
      for (final sep in separators) {
        result.add('$this$sep$second');
      }
    }
    return result;
  }
}
