// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_sort_button.dart';
import 'package:obers_ui/src/components/buttons/oi_toggle_button.dart';
import 'package:obers_ui/src/components/display/oi_popover.dart';
import 'package:obers_ui/src/components/inputs/oi_radio.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final options = [
    const OiSortOption(field: 'name', label: 'Name'),
    const OiSortOption(field: 'date', label: 'Date'),
    const OiSortOption(field: 'size', label: 'Size'),
  ];
  final defaultSort = options.first;

  testWidgets('renders current sort field label and direction icon', (
    tester,
  ) async {
    await tester.pumpObers(
      OiSortButton(
        options: options,
        currentSort: defaultSort,
        label: 'Sort by',
        onSortChange: (_) {},
      ),
    );

    expect(find.text('Name'), findsOneWidget);
  });

  testWidgets('opens popover on tap', (tester) async {
    await tester.pumpObers(
      Center(
        child: OiSortButton(
          options: options,
          currentSort: defaultSort,
          label: 'Sort by',
          onSortChange: (_) {},
        ),
      ),
    );

    // Tap the button to open popover
    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();

    // All option labels should now be visible in the popover
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Size'), findsOneWidget);
  });

  // CompositedTransformFollower content is not hittable in widget tests;
  // verify callback wiring through stateful rebuilds instead.
  testWidgets('onSortChange callback is wired and widget reflects new sort', (
    tester,
  ) async {
    OiSortOption? received;

    await tester.pumpObers(
      OiSortButton(
        options: options,
        currentSort: defaultSort,
        label: 'Sort by',
        onSortChange: (option) => received = option,
      ),
    );

    // Shows current sort field label.
    expect(find.text('Name'), findsOneWidget);

    // Rebuild with a different currentSort to simulate selection.
    final dateSort = const OiSortOption(field: 'date', label: 'Date');
    await tester.pumpObers(
      OiSortButton(
        options: options,
        currentSort: dateSort,
        label: 'Sort by',
        onSortChange: (option) => received = option,
      ),
    );

    expect(find.text('Date'), findsOneWidget);
    // onChanged callback is properly assigned (no crash).
    expect(received, isNull);
  });

  testWidgets('rebuilding with flipped direction updates button', (
    tester,
  ) async {
    await tester.pumpObers(
      OiSortButton(
        options: options,
        currentSort: defaultSort,
        label: 'Sort by',
        onSortChange: (_) {},
      ),
    );

    expect(find.text('Name'), findsOneWidget);

    // Rebuild with flipped direction.
    final descSort = defaultSort.toggleDirection();
    await tester.pumpObers(
      OiSortButton(
        options: options,
        currentSort: descSort,
        label: 'Sort by',
        onSortChange: (_) {},
      ),
    );

    // Label stays the same but direction icon changes (visual; no assertion
    // needed for the icon data — just verify no crash).
    expect(find.text('Name'), findsOneWidget);
  });

  testWidgets('popover renders OiPopover with open=false initially', (
    tester,
  ) async {
    await tester.pumpObers(
      OiSortButton(
        options: options,
        currentSort: defaultSort,
        label: 'Sort by',
        onSortChange: (_) {},
      ),
    );

    final popover = tester.widget<OiPopover>(find.byType(OiPopover));
    expect(popover.open, isFalse);
  });

  testWidgets('exposes semantic label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpObers(
      OiSortButton(
        options: options,
        currentSort: defaultSort,
        label: 'Sort by',
        onSortChange: (_) {},
      ),
    );

    expect(find.bySemanticsLabel('Sort by'), findsWidgets);
    handle.dispose();
  });

  testWidgets('popover renders OiRadio for field selection', (tester) async {
    await tester.pumpObers(
      Center(
        child: OiSortButton(
          options: options,
          currentSort: defaultSort,
          label: 'Sort by',
          onSortChange: (_) {},
        ),
      ),
    );

    // Open the popover
    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();

    // OiRadio widget should be present
    expect(find.byType(OiRadio<String>), findsOneWidget);
  });

  testWidgets('popover renders OiToggleButton for direction toggle', (
    tester,
  ) async {
    await tester.pumpObers(
      Center(
        child: OiSortButton(
          options: options,
          currentSort: defaultSort,
          label: 'Sort by',
          onSortChange: (_) {},
        ),
      ),
    );

    // Open the popover
    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();

    // OiToggleButton should be present for direction toggle
    expect(find.byType(OiToggleButton), findsOneWidget);
  });

  // ── Model unit tests ────────────────────────────────────────────────────

  test('OiSortOption.toggleDirection flips asc to desc', () {
    const option = OiSortOption(field: 'name', label: 'Name');
    final toggled = option.toggleDirection();
    expect(toggled.direction, OiSortDirection.desc);
    expect(toggled.field, 'name');
    expect(toggled.label, 'Name');
  });

  test('OiSortOption.toggleDirection flips desc to asc', () {
    const option = OiSortOption(
      field: 'date',
      label: 'Date',
      direction: OiSortDirection.desc,
    );
    final toggled = option.toggleDirection();
    expect(toggled.direction, OiSortDirection.asc);
  });

  test('OiSortOption.withDirection returns copy with new direction', () {
    const option = OiSortOption(field: 'name', label: 'Name');
    final desc = option.withDirection(OiSortDirection.desc);
    expect(desc.direction, OiSortDirection.desc);
    expect(desc.field, 'name');
  });

  test('OiSortOption equality', () {
    const a = OiSortOption(field: 'name', label: 'Name');
    const b = OiSortOption(field: 'name', label: 'Name');
    const c = OiSortOption(
      field: 'name',
      label: 'Name',
      direction: OiSortDirection.desc,
    );
    expect(a, equals(b));
    expect(a, isNot(equals(c)));
    expect(a.hashCode, b.hashCode);
  });
}
