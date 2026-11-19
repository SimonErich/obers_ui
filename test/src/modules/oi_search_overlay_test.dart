// Tests do not require documentation comments.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/modules/oi_search_overlay.dart';

import '../../helpers/pump_app.dart';

void main() {
  Widget buildOverlay({
    Future<List<OiSearchSuggestion>> Function(String, String?)? onSearch,
    void Function(OiSearchSuggestion)? onSuggestionTap,
    void Function(String)? onRecentTap,
    VoidCallback? onClearRecents,
    List<OiSearchCategory> categories = const [],
    List<String> recentSearches = const [],
  }) {
    return SizedBox(
      width: 800,
      height: 600,
      child: OiSearchOverlay(
        label: 'Test Search',
        onSearch: onSearch,
        onSuggestionTap: onSuggestionTap,
        onRecentTap: onRecentTap,
        onClearRecents: onClearRecents,
        categories: categories,
        recentSearches: recentSearches,
      ),
    );
  }

  testWidgets('a result announces its details and keeps its trailing action', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpObers(
      buildOverlay(
        onSearch: (query, category) async => [
          OiSearchSuggestion(
            key: '1',
            title: 'Result One',
            subtitle: 'In projects',
            category: 'Docs',
            trailing: OiButton.primary(label: 'Open', onTap: () {}),
          ),
        ],
      ),
      surfaceSize: const Size(800, 600),
    );
    await tester.enterText(find.byType(EditableText), 'test');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    final row = tester.getSemantics(find.text('Result One'));
    expect(row.label, contains('In projects'));
    expect(row.label, contains('Docs'));
    expect('Result One'.allMatches(row.label), hasLength(1));
    expect(row, isSemantics(isButton: true, hasTapAction: true));
    expect(
      tester.getSemantics(find.text('Open')),
      isSemantics(label: 'Open', isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });

  testWidgets('renders search input with placeholder', (tester) async {
    await tester.pumpObers(buildOverlay(), surfaceSize: const Size(800, 600));

    expect(find.byType(OiTextInput), findsOneWidget);
  });

  testWidgets('recent searches shown when query is empty', (tester) async {
    await tester.pumpObers(
      buildOverlay(recentSearches: ['Flutter', 'Dart', 'Widget']),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('Recent Searches'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    expect(find.text('Widget'), findsOneWidget);
  });

  testWidgets('clear recents button calls onClearRecents', (tester) async {
    var cleared = false;

    await tester.pumpObers(
      buildOverlay(
        recentSearches: ['Flutter'],
        onClearRecents: () => cleared = true,
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('Clear'), findsOneWidget);
    await tester.tap(find.text('Clear'));
    await tester.pump();

    expect(cleared, isTrue);
  });

  testWidgets('tapping recent search calls onRecentTap', (tester) async {
    String? tappedQuery;

    await tester.pumpObers(
      buildOverlay(
        recentSearches: ['Flutter'],
        onRecentTap: (q) => tappedQuery = q,
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.text('Flutter'));
    await tester.pump();

    expect(tappedQuery, 'Flutter');
  });

  testWidgets('search results render after onSearch resolves', (tester) async {
    final completer = Completer<List<OiSearchSuggestion>>();

    await tester.pumpObers(
      buildOverlay(onSearch: (query, category) => completer.future),
      surfaceSize: const Size(800, 600),
    );

    // Type a query.
    await tester.enterText(find.byType(EditableText), 'test');
    // Wait for debounce (300ms default + some buffer).
    await tester.pump(const Duration(milliseconds: 350));

    // Complete the future with results.
    completer.complete([
      const OiSearchSuggestion(key: '1', title: 'Result One'),
      const OiSearchSuggestion(key: '2', title: 'Result Two'),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('Result One'), findsOneWidget);
    expect(find.text('Result Two'), findsOneWidget);
  });

  testWidgets('empty state shown when no results', (tester) async {
    await tester.pumpObers(
      buildOverlay(onSearch: (query, category) async => []),
      surfaceSize: const Size(800, 600),
    );

    await tester.enterText(find.byType(EditableText), 'nothing');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.byType(OiEmptyState), findsOneWidget);
  });

  testWidgets('loading indicator shown during search', (tester) async {
    final completer = Completer<List<OiSearchSuggestion>>();

    await tester.pumpObers(
      buildOverlay(onSearch: (query, category) => completer.future),
      surfaceSize: const Size(800, 600),
    );

    await tester.enterText(find.byType(EditableText), 'loading');
    // Pump once after entering text — loading starts before debounce fires.
    await tester.pump();

    expect(find.byType(OiProgress), findsOneWidget);

    // Clean up: resolve so no pending timers.
    completer.complete([]);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
  });

  testWidgets('category filter chips render', (tester) async {
    await tester.pumpObers(
      buildOverlay(
        categories: [
          const OiSearchCategory(key: 'docs', label: 'Docs'),
          const OiSearchCategory(
            key: 'code',
            label: 'Code',
            icon: OiIcons.search,
          ),
        ],
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('Docs'), findsOneWidget);
    expect(find.text('Code'), findsOneWidget);
  });

  testWidgets('tapping suggestion calls onSuggestionTap', (tester) async {
    OiSearchSuggestion? tapped;
    const suggestion = OiSearchSuggestion(key: '1', title: 'Result One');

    await tester.pumpObers(
      buildOverlay(
        onSearch: (query, category) async => [suggestion],
        onSuggestionTap: (s) => tapped = s,
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.enterText(find.byType(EditableText), 'test');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Result One'));
    await tester.pump();

    expect(tapped, isNotNull);
    expect(tapped!.title, 'Result One');
  });

  testWidgets('semantics label is applied', (tester) async {
    await tester.pumpObers(buildOverlay(), surfaceSize: const Size(800, 600));

    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Test Search',
      ),
      findsOneWidget,
    );
  });

  // ── Regression: async races, debounce, failures ────────────────────────────

  group('async search', () {
    const apple = OiSearchSuggestion(key: 'a', title: 'Apple');
    const abacus = OiSearchSuggestion(key: 'ab', title: 'Abacus');

    late Map<String, Completer<List<OiSearchSuggestion>>> requests;
    late List<String> calls;

    Future<List<OiSearchSuggestion>> search(String query, String? category) {
      calls.add('$query/$category');
      return (requests[query] = Completer<List<OiSearchSuggestion>>()).future;
    }

    setUp(() {
      requests = {};
      calls = [];
    });

    testWidgets('a slow earlier search does not replace newer results', (
      tester,
    ) async {
      await tester.pumpObers(
        buildOverlay(onSearch: search),
        surfaceSize: const Size(800, 600),
      );

      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.enterText(find.byType(EditableText), 'ab');
      await tester.pump(const Duration(milliseconds: 350));
      expect(requests.keys, ['a', 'ab']);

      // The newer search answers first, the older one afterwards.
      requests['ab']!.complete([abacus]);
      await tester.pumpAndSettle();
      expect(find.text('Abacus'), findsOneWidget);

      requests['a']!.complete([apple]);
      await tester.pumpAndSettle();

      expect(find.text('Abacus'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
    });

    testWidgets('a stale search does not end the loading state', (
      tester,
    ) async {
      await tester.pumpObers(
        buildOverlay(onSearch: search),
        surfaceSize: const Size(800, 600),
      );

      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.enterText(find.byType(EditableText), 'ab');
      await tester.pump(const Duration(milliseconds: 350));

      requests['a']!.complete([apple]);
      await tester.pump();
      await tester.pump();

      expect(find.byType(OiProgress), findsOneWidget);

      requests['ab']!.complete([abacus]);
      await tester.pumpAndSettle();
      expect(find.byType(OiProgress), findsNothing);
      expect(find.text('Abacus'), findsOneWidget);
    });

    testWidgets('a search answering after the query was cleared is dropped', (
      tester,
    ) async {
      OiSearchSuggestion? tapped;
      await tester.pumpObers(
        buildOverlay(onSearch: search, onSuggestionTap: (s) => tapped = s),
        surfaceSize: const Size(800, 600),
      );

      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.enterText(find.byType(EditableText), '');
      await tester.pump();

      requests['a']!.complete([apple]);
      await tester.pumpAndSettle();
      expect(find.text('Apple'), findsNothing);

      // The dropped result cannot be reached from the keyboard either.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(tapped, isNull);
    });

    testWidgets('choosing a category cancels the pending debounce', (
      tester,
    ) async {
      await tester.pumpObers(
        buildOverlay(
          onSearch: search,
          categories: const [OiSearchCategory(key: 'docs', label: 'Docs')],
        ),
        surfaceSize: const Size(800, 600),
      );

      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pump(const Duration(milliseconds: 100));
      expect(calls, isEmpty);

      await tester.tap(find.text('Docs'));
      await tester.pump();
      expect(calls, ['a/docs']);

      // The debounce started by typing must not search a second time.
      await tester.pump(const Duration(milliseconds: 350));
      expect(calls, ['a/docs']);

      requests['a']!.complete([apple]);
      await tester.pumpAndSettle();
    });

    testWidgets('a failed search shows the error state, not "no results"', (
      tester,
    ) async {
      await tester.pumpObers(
        buildOverlay(onSearch: search),
        surfaceSize: const Size(800, 600),
      );

      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pump(const Duration(milliseconds: 350));
      requests['a']!.completeError(Exception('offline'));
      await tester.pumpAndSettle();

      expect(find.byType(OiProgress), findsNothing);
      expect(find.text('Search failed'), findsOneWidget);
      expect(find.text('No results found'), findsNothing);
    });

    testWidgets('a search that throws an Error ends the loading state', (
      tester,
    ) async {
      await tester.pumpObers(
        buildOverlay(onSearch: search),
        surfaceSize: const Size(800, 600),
      );

      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pump(const Duration(milliseconds: 350));
      requests['a']!.completeError(StateError('backend down'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(OiProgress), findsNothing);
      expect(find.text('Search failed'), findsOneWidget);
    });

    testWidgets('the error state clears when the next search succeeds', (
      tester,
    ) async {
      await tester.pumpObers(
        buildOverlay(onSearch: search),
        surfaceSize: const Size(800, 600),
      );

      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pump(const Duration(milliseconds: 350));
      requests['a']!.completeError(Exception('offline'));
      await tester.pumpAndSettle();
      expect(find.text('Search failed'), findsOneWidget);

      await tester.enterText(find.byType(EditableText), 'ab');
      await tester.pump(const Duration(milliseconds: 350));
      requests['ab']!.complete([abacus]);
      await tester.pumpAndSettle();

      expect(find.text('Search failed'), findsNothing);
      expect(find.text('Abacus'), findsOneWidget);
    });

    testWidgets('error texts can be replaced', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 800,
          height: 600,
          child: OiSearchOverlay(
            label: 'Test Search',
            onSearch: search,
            errorStateTitle: 'Suche fehlgeschlagen',
            errorStateDescription: 'Bitte erneut versuchen.',
          ),
        ),
        surfaceSize: const Size(800, 600),
      );

      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pump(const Duration(milliseconds: 350));
      requests['a']!.completeError(Exception('offline'));
      await tester.pumpAndSettle();

      expect(find.text('Suche fehlgeschlagen'), findsOneWidget);
      expect(find.text('Bitte erneut versuchen.'), findsOneWidget);
    });
  });
}
