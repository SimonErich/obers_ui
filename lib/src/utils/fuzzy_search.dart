/// Fuzzy search utility for matching user input against a list of items.
///
/// Uses a scoring algorithm that rewards consecutive character matches,
/// matches at word boundaries, and prefix matches.
///
/// {@category Utils}
class OiFuzzySearch {
  const OiFuzzySearch._();

  /// Scores how well [query] matches [target].
  ///
  /// Returns 0.0 (no match) to 1.0 (perfect match).
  /// An empty query always returns 0.0.
  static double score(String query, String target) {
    if (query.isEmpty || target.isEmpty) return 0;

    final q = query.toLowerCase();
    final t = target.toLowerCase();

    // Exact match
    if (q == t) return 1;

    // Contains as substring
    if (t.contains(q)) {
      final lengthRatio = q.length / t.length;
      // Bonus for prefix match
      if (t.startsWith(q)) return 0.8 + 0.2 * lengthRatio;
      return 0.5 + 0.3 * lengthRatio;
    }

    // Character-by-character fuzzy matching
    final indices = matchedIndices(query, target);
    if (indices.isEmpty) return 0;

    // Score based on several heuristics
    var rawScore = 0.0;
    final matchCount = indices.length;

    // Base score: ratio of matched characters to query length
    rawScore += matchCount / q.length * 0.4;

    // Consecutive character bonus
    var consecutiveBonus = 0.0;
    for (var i = 1; i < indices.length; i++) {
      if (indices[i] == indices[i - 1] + 1) {
        consecutiveBonus += 1;
      }
    }
    if (indices.length > 1) {
      rawScore += (consecutiveBonus / (indices.length - 1)) * 0.3;
    }

    // Position penalty: prefer matches closer to the start
    final avgPosition =
        indices.fold<int>(0, (sum, i) => sum + i) / indices.length;
    final positionScore = 1.0 - (avgPosition / t.length);
    rawScore += positionScore * 0.2;

    // Length similarity bonus
    rawScore += (q.length / t.length).clamp(0.0, 1.0) * 0.1;

    return rawScore.clamp(0.0, 0.99);
  }

  /// Searches a list of [items] and returns matches sorted by relevance.
  ///
  /// [query] is the search string. [getText] extracts the searchable text
  /// from each item. [threshold] sets the minimum score to include (default
  /// 0.3). [maxResults] limits the number of returned matches (default 50).
  static List<OiFuzzyMatch<T>> search<T>({
    required String query,
    required List<T> items,
    required String Function(T) getText,
    double threshold = 0.3,
    int maxResults = 50,
  }) {
    if (query.isEmpty) return [];

    final matches = <OiFuzzyMatch<T>>[];

    for (final item in items) {
      final text = getText(item);
      final matchScore = score(query, text);

      if (matchScore >= threshold) {
        matches.add(
          OiFuzzyMatch<T>(
            item: item,
            score: matchScore,
            matchedIndices: matchedIndices(query, text),
          ),
        );
      }
    }

    matches.sort((a, b) => b.score.compareTo(a.score));

    return matches.take(maxResults).toList();
  }

  /// Returns the matched character indices for highlighting.
  ///
  /// Finds the best matching positions of [query] characters in [target].
  /// Returns an empty list if not all characters can be matched.
  static List<int> matchedIndices(String query, String target) {
    if (query.isEmpty || target.isEmpty) return [];

    final q = query.toLowerCase();
    final t = target.toLowerCase();

    final indices = <int>[];
    var searchStart = 0;

    for (var i = 0; i < q.length; i++) {
      final charIndex = t.indexOf(q[i], searchStart);
      if (charIndex < 0) return []; // Character not found
      indices.add(charIndex);
      searchStart = charIndex + 1;
    }

    return indices;
  }
}

/// A fuzzy search result with score and matched item.
///
/// {@category Utils}
class OiFuzzyMatch<T> {
  /// Creates an [OiFuzzyMatch].
  const OiFuzzyMatch({
    required this.item,
    required this.score,
    required this.matchedIndices,
  });

  /// The matched item.
  final T item;

  /// The match score (0.0 to 1.0).
  final double score;

  /// Indices of matched characters in the text for highlighting.
  final List<int> matchedIndices;

  @override
  String toString() =>
      'OiFuzzyMatch(score: ${score.toStringAsFixed(3)}, indices: $matchedIndices, item: $item)';
}
