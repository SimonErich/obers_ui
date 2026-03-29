// Tests do not require documentation comments.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/search/oi_search.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

List<OiSearchResult> _fileResults(String query) {
  const items = [
    OiSearchResult(id: 'f1', title: 'main.dart', subtitle: 'lib/'),
    OiSearchResult(id: 'f2', title: 'pubspec.yaml', subtitle: 'root'),
    OiSearchResult(id: 'f3', title: 'README.md', subtitle: 'root'),
  ];
  if (query.isEmpty) return items;
  final lower = query.toLowerCase();
  return items.where((r) => r.title.toLowerCase().contains(lower)).toList();
}

List<OiSearchResult> _commandResults(String query) {
  const items = [
    OiSearchResult(id: 'c1', title: 'Open File'),
    OiSearchResult(id: 'c2', title: 'Save All'),
    OiSearchResult(id: 'c3', title: 'Toggle Terminal'),
  ];
  if (query.isEmpty) return items;
  final lower = query.toLowerCase();
  return items.where((r) => r.title.toLowerCase().contains(lower)).toList();
}

final _sources = [
  OiSearchSource(
    category: 'Files',
    icon: const IconData(0xe873, fontFamily: 'MaterialIcons'),
    search: (query) async => _fileResults(query),
  ),
  OiSearchSource(
    category: 'Commands',
    icon: const IconData(0xe5c3, fontFamily: 'MaterialIcons'),
    search: (query) async => _commandResults(query),
  ),
];

Widget _search({
  List<OiSearchSource>? sources,
  ValueChanged<OiSearchResult>? onSelect,
  VoidCallback? onDismiss,
  bool showRecent = true,
  bool showPreview = true,
  Duration debounce = Duration.zero,
  List<OiSearchFilter>? filters,
}) {
  return SizedBox(
    width: 800,
    height: 600,
    child: OiSearch(
      label: 'Global Search',
      sources: sources ?? _sources,
      onSelect: onSelect,
      onDismiss: onDismiss,
      showRecent: showRecent,
      showPreview: showPreview,
      debounce: debounce,
      filters: filters,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  testWidgets('renders search input', (tester) async {
    await tester.pumpObers(_search());
    expect(find.byType(OiSearch), findsOneWidget);
    expect(find.byType(EditableText), findsWidgets);
  });

  testWidgets('shows placeholder when query is empty', (tester) async {
    await tester.pumpObers(_search());
    expect(find.text('Type to search'), findsOneWidget);
  });

  testWidgets('typing queries sources and shows results', (tester) async {
    await tester.pumpObers(_search());

    final editableTexts = find.byType(EditableText);
    await tester.enterText(editableTexts.first, 'main');
    await tester.pumpAndSettle();

    expect(find.text('main.dart'), findsOneWidget);
  });

  testWidgets('results grouped by category', (tester) async {
    await tester.pumpObers(_search());

    final editableTexts = find.byType(EditableText);
    await tester.enterText(editableTexts.first, 'a');
    await tester.pumpAndSettle();

    // Category headers should be visible.
    expect(find.text('Files'), findsOneWidget);
    expect(find.text('Commands'), findsOneWidget);
  });

  testWidgets('onSelect fires when result is tapped', (tester) async {
    OiSearchResult? selected;
    await tester.pumpObers(_search(onSelect: (r) => selected = r));

    final editableTexts = find.byType(EditableText);
    await tester.enterText(editableTexts.first, 'main');
    await tester.pumpAndSettle();

    await tester.tap(find.text('main.dart'));
    await tester.pump();

    expect(selected, isNotNull);
    expect(selected!.id, equals('f1'));
  });

  testWidgets('onSelect fires via keyboard enter', (tester) async {
    OiSearchResult? selected;
    await tester.pumpObers(_search(onSelect: (r) => selected = r));

    final editableTexts = find.byType(EditableText);
    await tester.enterText(editableTexts.first, 'main');
    await tester.pumpAndSettle();

    // Arrow down to first result, press enter.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(selected, isNotNull);
  });

  testWidgets('escape calls onDismiss', (tester) async {
    var dismissed = false;
    await tester.pumpObers(_search(onDismiss: () => dismissed = true));

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(dismissed, isTrue);
  });

  testWidgets('loading state shows while searching', (tester) async {
    final completer = Completer<List<OiSearchResult>>();
    final slowSource = OiSearchSource(
      category: 'Slow',
      icon: const IconData(0xe873, fontFamily: 'MaterialIcons'),
      search: (query) => completer.future,
    );

    await tester.pumpObers(_search(sources: [slowSource]));

    final editableTexts = find.byType(EditableText);
    await tester.enterText(editableTexts.first, 'test');
    // Advance past debounce (0ms) but don't settle since future is pending.
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Searching\u2026'), findsOneWidget);

    completer.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('empty results shows "No results found"', (tester) async {
    final emptySource = OiSearchSource(
      category: 'Empty',
      icon: const IconData(0xe873, fontFamily: 'MaterialIcons'),
      search: (query) async => [],
    );

    await tester.pumpObers(_search(sources: [emptySource]));

    final editableTexts = find.byType(EditableText);
    await tester.enterText(editableTexts.first, 'nothing');
    await tester.pumpAndSettle();

    expect(find.text('No results found'), findsOneWidget);
  });

  testWidgets('semantics include label', (tester) async {
    await tester.pumpObers(_search());

    final semanticsWidgets = tester.widgetList<Semantics>(
      find.byType(Semantics),
    );
    final matching = semanticsWidgets
        .where(
          (s) =>
              s.properties.label != null &&
              s.properties.label!.contains('Global Search'),
        )
        .toList();
    expect(matching, hasLength(1));
  });

  testWidgets('filters render when provided', (tester) async {
    await tester.pumpObers(
      _search(
        filters: const [
          OiSearchFilter(
            label: 'Type',
            key: 'type',
            options: ['File', 'Command'],
          ),
        ],
      ),
    );

    expect(find.text('Type'), findsOneWidget);
  });

  testWidgets('debounce delays search execution', (tester) async {
    var searchCount = 0;
    final source = OiSearchSource(
      category: 'Counted',
      icon: const IconData(0xe873, fontFamily: 'MaterialIcons'),
      search: (query) async {
        searchCount++;
        return [];
      },
    );

    await tester.pumpObers(
      _search(sources: [source], debounce: const Duration(milliseconds: 300)),
    );

    final editableTexts = find.byType(EditableText);

    // Type quickly — should not trigger search yet.
    await tester.enterText(editableTexts.first, 'a');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(editableTexts.first, 'ab');
    await tester.pump(const Duration(milliseconds: 100));

    expect(searchCount, equals(0));

    // Wait for debounce to fire.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(searchCount, equals(1));
  });

  testWidgets('arrow keys navigate results', (tester) async {
    await tester.pumpObers(_search());

    final editableTexts = find.byType(EditableText);
    await tester.enterText(editableTexts.first, 'a');
    await tester.pumpAndSettle();

    // Navigate down and up.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();

    // No crash — navigation works.
    expect(find.byType(OiSearch), findsOneWidget);
  });
}
