/// Fuzzy string matching for voice/receipt suggestions (e.g. "Afsar" → "Absar Ahmed").
/// Uses Levenshtein distance and optional word-by-word matching for names.

/// Levenshtein edit distance between [a] and [b].
int levenshteinDistance(String a, String b) {
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  final aLen = a.length;
  final bLen = b.length;
  // Two rows only
  List<int> prev = List.generate(bLen + 1, (i) => i);
  List<int> curr = List.filled(bLen + 1, 0);
  for (int i = 1; i <= aLen; i++) {
    curr[0] = i;
    for (int j = 1; j <= bLen; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      curr[j] = [
        curr[j - 1] + 1,
        prev[j] + 1,
        prev[j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y);
    }
    final t = prev;
    prev = curr;
    curr = t;
  }
  return prev[bLen];
}

/// Similarity in [0, 1]; 1 = identical.
double stringSimilarity(String a, String b) {
  if (a.isEmpty && b.isEmpty) return 1.0;
  if (a.isEmpty || b.isEmpty) return 0.0;
  final maxLen = a.length > b.length ? a.length : b.length;
  final distance = levenshteinDistance(a, b);
  return 1.0 - (distance / maxLen);
}

/// Default threshold for fuzzy match (e.g. "Afsar" vs "Absar").
const double kFuzzyMatchThreshold = 0.6;

/// Returns true if [extracted] matches [candidate] either by substring or by fuzzy similarity.
/// [candidate] is typically a full name/category (e.g. "Absar Ahmed"); [extracted] is what
/// voice/OCR produced (e.g. "Afsar"). Also checks word-by-word so one misheard word still matches.
bool stringsMatchFuzzy(
  String extracted,
  String candidate, {
  double threshold = kFuzzyMatchThreshold,
}) {
  final e = extracted.trim().toLowerCase();
  final c = candidate.trim().toLowerCase();
  if (e.isEmpty) return false;
  if (c.isEmpty) return false;
  // Exact substring (existing behavior)
  if (c.contains(e) || e.contains(c)) return true;
  // Full string similarity
  if (stringSimilarity(e, c) >= threshold) return true;
  // Word-by-word: e.g. "Afsar" vs "Absar Ahmed" → compare "afsar" with "absar"
  final candidateWords = c.split(RegExp(r'\s+'));
  for (final word in candidateWords) {
    if (word.isEmpty) continue;
    if (stringSimilarity(e, word) >= threshold) return true;
    if (e.length >= 2 && word.length >= 2 && stringSimilarity(e, word) >= 0.5) return true;
  }
  return false;
}

/// Returns a similarity score in [0, 1] for ranking: best match first.
/// Uses full-string similarity and max word similarity so "Afsar" scores high vs "Absar Ahmed".
double fuzzyScore(String extracted, String candidate) {
  final e = extracted.trim().toLowerCase();
  final c = candidate.trim().toLowerCase();
  if (e.isEmpty || c.isEmpty) return 0.0;
  double score = stringSimilarity(e, c);
  final candidateWords = c.split(RegExp(r'\s+'));
  for (final word in candidateWords) {
    if (word.isEmpty) continue;
    final wordScore = stringSimilarity(e, word);
    if (wordScore > score) score = wordScore;
  }
  // Boost if substring match (exact contains)
  if (c.contains(e) || e.contains(c)) score = score < 0.9 ? 0.95 : score;
  return score;
}
