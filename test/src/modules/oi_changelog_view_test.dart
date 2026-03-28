// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/modules/oi_changelog_view.dart';

import '../../helpers/pump_app.dart';

void main() {
  final sampleVersions = [
    OiVersionEntry(
      version: '2.1.0',
      isLatest: true,
      date: DateTime(2026, 3, 15),
      changes: const [
        OiChangeEntry(
          description: 'Dark mode support',
          type: OiChangeType.added,
        ),
        OiChangeEntry(
          description: 'Fixed login crash',
          type: OiChangeType.fixed,
        ),
      ],
    ),
    OiVersionEntry(
      version: '2.0.0',
      date: DateTime(2026, 2),
      changes: const [
        OiChangeEntry(
          description: 'New dashboard layout',
          type: OiChangeType.changed,
        ),
        OiChangeEntry(
          description: 'Removed legacy API',
          type: OiChangeType.removed,
        ),
      ],
    ),
    OiVersionEntry(
      version: '1.5.0',
      date: DateTime(2026, 1, 10),
      changes: const [
        OiChangeEntry(
          description: 'Password hashing upgrade',
          type: OiChangeType.security,
        ),
      ],
    ),
    OiVersionEntry(
      version: '1.4.0',
      date: DateTime(2025, 12),
      changes: const [
        OiChangeEntry(
          description: 'Old config format',
          type: OiChangeType.deprecated,
        ),
      ],
    ),
    OiVersionEntry(
      version: '1.3.0',
      date: DateTime(2025, 11),
      changes: const [
        OiChangeEntry(
          description: 'Initial release feature',
          type: OiChangeType.added,
        ),
      ],
    ),
  ];

  Widget buildWidget({
    List<OiVersionEntry>? versions,
    int initiallyExpandedCount = 3,
    bool showSearch = true,
    bool showTypeFilters = true,
  }) {
    return SizedBox(
      width: 800,
      height: 900,
      child: OiChangelogView(
        versions: versions ?? sampleVersions,
        label: 'Changelog',
        initiallyExpandedCount: initiallyExpandedCount,
        showSearch: showSearch,
        showTypeFilters: showTypeFilters,
      ),
    );
  }

  testWidgets('renders version numbers', (tester) async {
    await tester.pumpObers(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('2.1.0'), findsOneWidget);
    expect(find.text('2.0.0'), findsOneWidget);
    expect(find.text('1.5.0'), findsOneWidget);
  });

  testWidgets('renders change descriptions', (tester) async {
    await tester.pumpObers(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('Dark mode support'), findsOneWidget);
    expect(find.text('Fixed login crash'), findsOneWidget);
    expect(find.text('New dashboard layout'), findsOneWidget);
  });

  testWidgets('shows NEW badge on latest version', (tester) async {
    await tester.pumpObers(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('NEW'), findsOneWidget);
  });

  testWidgets('only shows initiallyExpandedCount versions by default', (
    tester,
  ) async {
    await tester.pumpObers(buildWidget(initiallyExpandedCount: 2));
    await tester.pumpAndSettle();

    // First 2 versions visible.
    expect(find.text('2.1.0'), findsOneWidget);
    expect(find.text('2.0.0'), findsOneWidget);
    // Third version not visible yet.
    expect(find.text('1.5.0'), findsNothing);
    // Show older button present.
    expect(find.textContaining('Show older versions'), findsOneWidget);
  });

  testWidgets('show older versions button expands all', (tester) async {
    await tester.pumpObers(buildWidget(initiallyExpandedCount: 2));
    await tester.pumpAndSettle();

    // Tap the expand button.
    await tester.tap(find.textContaining('Show older versions'));
    await tester.pumpAndSettle();

    // All versions should now be visible.
    expect(find.text('2.1.0'), findsOneWidget);
    expect(find.text('2.0.0'), findsOneWidget);
    expect(find.text('1.5.0'), findsOneWidget);
    expect(find.text('1.4.0'), findsOneWidget);
    expect(find.text('1.3.0'), findsOneWidget);
    // Button should be gone.
    expect(find.textContaining('Show older versions'), findsNothing);
  });

  testWidgets('search filters changes by description text', (tester) async {
    await tester.pumpObers(buildWidget());
    await tester.pumpAndSettle();

    // Type in the search box.
    await tester.enterText(find.byType(EditableText), 'Dark mode');
    await tester.pumpAndSettle();

    // Only version 2.1.0 should remain (it contains 'Dark mode support').
    expect(find.text('Dark mode support'), findsOneWidget);
    // Other entries should be filtered out.
    expect(find.text('New dashboard layout'), findsNothing);
    expect(find.text('Removed legacy API'), findsNothing);
  });

  testWidgets('type filter chips filter by change type', (tester) async {
    await tester.pumpObers(buildWidget());
    await tester.pumpAndSettle();

    // Tap the 'Fixed' filter chip.
    await tester.tap(find.text('Fixed').first);
    await tester.pumpAndSettle();

    // Should show the fixed entry.
    expect(find.text('Fixed login crash'), findsOneWidget);
    // Other types should be filtered out.
    expect(find.text('Dark mode support'), findsNothing);
    expect(find.text('New dashboard layout'), findsNothing);
  });

  testWidgets('date is rendered when provided', (tester) async {
    await tester.pumpObers(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('Mar 15, 2026'), findsOneWidget);
    expect(find.text('Feb 1, 2026'), findsOneWidget);
  });

  testWidgets('semantics label is applied', (tester) async {
    await tester.pumpObers(buildWidget());
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Changelog',
      ),
      findsOneWidget,
    );
  });

  testWidgets('empty state when no versions provided', (tester) async {
    await tester.pumpObers(buildWidget(versions: []));
    await tester.pumpAndSettle();

    expect(find.text('No matching changes'), findsOneWidget);
  });
}
