// Test file — public_member_api_docs not required for test helpers.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/primitives/layout/oi_grid_zoom_controls.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders grid children', (tester) async {
    await tester.pumpObers(
      const OiGridZoomControls(
        breakpoint: OiBreakpoint.compact,
        initialColumns: 2,
        children: [Text('A'), Text('B')],
      ),
    );
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('renders plus and minus buttons', (tester) async {
    await tester.pumpObers(
      const OiGridZoomControls(
        breakpoint: OiBreakpoint.compact,
        initialColumns: 2,
        children: [Text('A')],
      ),
    );
    expect(find.byType(OiIconButton), findsNWidgets(2));
  });

  testWidgets('displays current column count', (tester) async {
    await tester.pumpObers(
      const OiGridZoomControls(
        breakpoint: OiBreakpoint.compact,
        initialColumns: 4,
        children: [Text('A')],
      ),
    );
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('tapping plus increases column count', (tester) async {
    int? reported;
    await tester.pumpObers(
      OiGridZoomControls(
        breakpoint: OiBreakpoint.compact,
        initialColumns: 2,
        maxColumns: 5,
        onColumnsChanged: (v) => reported = v,
        children: const [Text('A')],
      ),
    );
    // Tap the "Increase columns" button (second OiIconButton).
    final buttons = find.byType(OiIconButton);
    await tester.tap(buttons.last);
    await tester.pump();
    expect(reported, 3);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('tapping minus decreases column count', (tester) async {
    int? reported;
    await tester.pumpObers(
      OiGridZoomControls(
        breakpoint: OiBreakpoint.compact,
        onColumnsChanged: (v) => reported = v,
        children: const [Text('A')],
      ),
    );
    // Tap the "Decrease columns" button (first OiIconButton).
    final buttons = find.byType(OiIconButton);
    await tester.tap(buttons.first);
    await tester.pump();
    expect(reported, 2);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('column count respects minColumns', (tester) async {
    int? reported;
    await tester.pumpObers(
      OiGridZoomControls(
        breakpoint: OiBreakpoint.compact,
        initialColumns: 1,
        onColumnsChanged: (v) => reported = v,
        children: const [Text('A')],
      ),
    );
    // Minus button should be disabled (onTap is null).
    final buttons = find.byType(OiIconButton);
    await tester.tap(buttons.first);
    await tester.pump();
    expect(reported, isNull);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('column count respects maxColumns', (tester) async {
    int? reported;
    await tester.pumpObers(
      OiGridZoomControls(
        breakpoint: OiBreakpoint.compact,
        initialColumns: 5,
        maxColumns: 5,
        onColumnsChanged: (v) => reported = v,
        children: const [Text('A')],
      ),
    );
    // Plus button should be disabled.
    final buttons = find.byType(OiIconButton);
    await tester.tap(buttons.last);
    await tester.pump();
    expect(reported, isNull);
    expect(find.text('5'), findsOneWidget);
  });
}
