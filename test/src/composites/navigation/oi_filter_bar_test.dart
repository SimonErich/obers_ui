// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/navigation/oi_filter_bar.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

const _filters = [
  OiFilterDefinition(key: 'status', label: 'Status', type: OiFilterType.select),
  OiFilterDefinition(key: 'name', label: 'Name', type: OiFilterType.text),
  OiFilterDefinition(key: 'date', label: 'Date', type: OiFilterType.date),
];

Widget _filterBar({
  List<OiFilterDefinition>? filters,
  Map<String, OiColumnFilter>? activeFilters,
  ValueChanged<Map<String, OiColumnFilter>>? onFilterChange,
  Widget? trailing,
}) {
  return SizedBox(
    width: 600,
    height: 100,
    child: OiFilterBar(
      filters: filters ?? _filters,
      activeFilters: activeFilters ?? const {},
      onFilterChange: onFilterChange ?? (_) {},
      trailing: trailing,
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('OiFilterBar', () {
    testWidgets('filter chips render', (tester) async {
      await tester.pumpObers(_filterBar());

      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
    });

    testWidgets('tap opens filter popover', (tester) async {
      await tester.pumpObers(_filterBar());

      // Tap the Status chip.
      await tester.tap(find.text('Status'));
      await tester.pumpAndSettle();

      // The popover should appear.
      expect(find.byKey(const Key('oi_filter_popover')), findsOneWidget);
    });

    testWidgets('active filter shows filled chip with value', (tester) async {
      await tester.pumpObers(
        _filterBar(
          activeFilters: const {'status': OiColumnFilter(value: 'Active')},
        ),
      );

      // The chip should display the label and value.
      expect(find.text('Status: Active'), findsOneWidget);
    });

    testWidgets('removing filter calls onFilterChange without the key', (
      tester,
    ) async {
      Map<String, OiColumnFilter>? result;
      await tester.pumpObers(
        _filterBar(
          activeFilters: const {'status': OiColumnFilter(value: 'Active')},
          onFilterChange: (f) => result = f,
        ),
      );

      // Find and tap the X icon to remove the filter.
      final closeIcon = find.byIcon(OiIcons.x);
      expect(closeIcon, findsOneWidget);

      await tester.tap(closeIcon);
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.containsKey('status'), isFalse);
    });

    testWidgets('trailing widget renders', (tester) async {
      await tester.pumpObers(_filterBar(trailing: const Text('Clear all')));

      expect(find.text('Clear all'), findsOneWidget);
    });

    testWidgets('inactive chip does not show value text', (tester) async {
      await tester.pumpObers(_filterBar());

      // Inactive chips show only the label, not "Label: value".
      expect(find.text('Status'), findsOneWidget);
      expect(find.textContaining(':'), findsNothing);
    });

    testWidgets('applying a filter calls onFilterChange', (tester) async {
      Map<String, OiColumnFilter>? result;
      await tester.pumpObers(_filterBar(onFilterChange: (f) => result = f));

      // Tap the Name chip to open the popover.
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();

      // The popover should be visible.
      expect(find.byKey(const Key('oi_filter_popover')), findsOneWidget);

      // Enter text into the filter input.
      final editableText = find.byType(EditableText);
      expect(editableText, findsOneWidget);

      await tester.enterText(editableText, 'Alice');
      await tester.pumpAndSettle();

      // Tap the Apply button.
      await tester.tap(find.byKey(const Key('oi_filter_apply')));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.containsKey('name'), isTrue);
      expect(result!['name']!.value, 'Alice');
    });

    testWidgets('multiple active filters render correctly', (tester) async {
      await tester.pumpObers(
        _filterBar(
          activeFilters: const {
            'status': OiColumnFilter(value: 'Active'),
            'name': OiColumnFilter(value: 'Alice'),
          },
        ),
      );

      expect(find.text('Status: Active'), findsOneWidget);
      expect(find.text('Name: Alice'), findsOneWidget);
      // Date is not active, so it should show only the label.
      expect(find.text('Date'), findsOneWidget);
    });
  });
}
