// Tests are internal; doc comments on local helpers are not required.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/utils/fuzzy_search.dart';

void main() {
  group('OiFuzzySearch', () {
    group('score', () {
      test('returns 1.0 for exact match', () {
        expect(OiFuzzySearch.score('hello', 'hello'), 1.0);
      });

      test('returns 0 for empty query', () {
        expect(OiFuzzySearch.score('', 'hello'), 0.0);
      });

      test('returns 0 for empty target', () {
        expect(OiFuzzySearch.score('hello', ''), 0.0);
      });

      test('returns high score for prefix match', () {
        final s = OiFuzzySearch.score('hel', 'hello');
        expect(s, greaterThan(0.8));
      });

      test('returns moderate score for substring match', () {
        final s = OiFuzzySearch.score('llo', 'hello');
        expect(s, greaterThan(0.5));
      });

      test('returns positive score for fuzzy match', () {
        final s = OiFuzzySearch.score('hlo', 'hello');
        expect(s, greaterThan(0));
      });

      test('returns 0 for no match', () {
        expect(OiFuzzySearch.score('xyz', 'hello'), 0.0);
      });

      test('is case insensitive', () {
        expect(OiFuzzySearch.score('HELLO', 'hello'), 1.0);
      });

      test('prefers prefix matches over substring matches', () {
        final prefixScore = OiFuzzySearch.score('app', 'application');
        final substringScore = OiFuzzySearch.score('cat', 'application');
        expect(prefixScore, greaterThan(substringScore));
      });

      test('scores are between 0 and 1', () {
        final score = OiFuzzySearch.score('test', 'testing');
        expect(score, greaterThanOrEqualTo(0.0));
        expect(score, lessThanOrEqualTo(1.0));
      });
    });

    group('search', () {
      final items = ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'];

      test('returns empty list for empty query', () {
        final results = OiFuzzySearch.search(
          query: '',
          items: items,
          getText: (s) => s,
        );
        expect(results, isEmpty);
      });

      test('finds exact matches', () {
        final results = OiFuzzySearch.search(
          query: 'Apple',
          items: items,
          getText: (s) => s,
        );
        expect(results, isNotEmpty);
        expect(results.first.item, 'Apple');
        expect(results.first.score, 1.0);
      });

      test('finds fuzzy matches', () {
        final results = OiFuzzySearch.search(
          query: 'Chry',
          items: items,
          getText: (s) => s,
        );
        expect(results, isNotEmpty);
        expect(results.first.item, 'Cherry');
      });

      test('respects threshold', () {
        final results = OiFuzzySearch.search(
          query: 'z',
          items: items,
          getText: (s) => s,
          threshold: 0.9,
        );
        expect(results, isEmpty);
      });

      test('respects maxResults', () {
        final manyItems = List.generate(100, (i) => 'item$i');
        final results = OiFuzzySearch.search(
          query: 'item',
          items: manyItems,
          getText: (s) => s,
          maxResults: 5,
        );
        expect(results.length, lessThanOrEqualTo(5));
      });

      test('sorts by score descending', () {
        final results = OiFuzzySearch.search(
          query: 'an',
          items: items,
          getText: (s) => s,
        );
        for (var i = 1; i < results.length; i++) {
          expect(results[i].score, lessThanOrEqualTo(results[i - 1].score));
        }
      });

      test('works with custom getText', () {
        final people = [
          {'name': 'Alice', 'age': 30},
          {'name': 'Bob', 'age': 25},
          {'name': 'Charlie', 'age': 35},
        ];
        final results = OiFuzzySearch.search(
          query: 'Alice',
          items: people,
          getText: (p) => p['name']! as String,
        );
        expect(results, isNotEmpty);
        expect(results.first.item['name'], 'Alice');
      });

      test('match contains matchedIndices', () {
        final results = OiFuzzySearch.search(
          query: 'App',
          items: items,
          getText: (s) => s,
        );
        expect(results.first.matchedIndices, isNotEmpty);
      });
    });

    group('matchedIndices', () {
      test('returns empty for empty query', () {
        expect(OiFuzzySearch.matchedIndices('', 'hello'), isEmpty);
      });

      test('returns empty for empty target', () {
        expect(OiFuzzySearch.matchedIndices('hello', ''), isEmpty);
      });

      test('returns sequential indices for exact match', () {
        final indices = OiFuzzySearch.matchedIndices('hello', 'hello');
        expect(indices, [0, 1, 2, 3, 4]);
      });

      test('returns correct indices for prefix match', () {
        final indices = OiFuzzySearch.matchedIndices('hel', 'hello');
        expect(indices, [0, 1, 2]);
      });

      test('returns correct indices for fuzzy match', () {
        final indices = OiFuzzySearch.matchedIndices('hlo', 'hello');
        // h=0, l=2 (first l found after index 0), o=4 (first o found after 2)
        expect(indices, [0, 2, 4]);
      });

      test('returns empty for no match', () {
        expect(OiFuzzySearch.matchedIndices('xyz', 'hello'), isEmpty);
      });

      test('is case insensitive', () {
        final indices = OiFuzzySearch.matchedIndices('HEL', 'hello');
        expect(indices, [0, 1, 2]);
      });

      test('indices are ascending', () {
        final indices = OiFuzzySearch.matchedIndices('ace', 'abcde');
        for (var i = 1; i < indices.length; i++) {
          expect(indices[i], greaterThan(indices[i - 1]));
        }
      });
    });

    group('OiFuzzyMatch', () {
      test('stores item, score, and matchedIndices', () {
        const match = OiFuzzyMatch<String>(
          item: 'test',
          score: 0.5,
          matchedIndices: [0, 1],
        );
        expect(match.item, 'test');
        expect(match.score, 0.5);
        expect(match.matchedIndices, [0, 1]);
      });

      test('toString includes score and item', () {
        const match = OiFuzzyMatch<String>(
          item: 'test',
          score: 0.5,
          matchedIndices: [0, 1],
        );
        final str = match.toString();
        expect(str, contains('0.500'));
        expect(str, contains('test'));
      });
    });
  });
}
