// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
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

    expect(find.text('All'), findsOneWidget);
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
}
