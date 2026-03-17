// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/layout/oi_wrap_layout.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders children inside a Wrap', (tester) async {
    await tester.pumpObers(
      const OiWrapLayout(
        children: [Text('A'), Text('B'), Text('C')],
      ),
    );
    expect(find.byType(Wrap), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('passes spacing and runSpacing to Wrap', (tester) async {
    await tester.pumpObers(
      const OiWrapLayout(
        spacing: 8,
        runSpacing: 16,
        children: [Text('X')],
      ),
    );
    final wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.spacing, 8);
    expect(wrap.runSpacing, 16);
  });

  testWidgets('passes alignment to Wrap', (tester) async {
    await tester.pumpObers(
      const OiWrapLayout(
        alignment: WrapAlignment.center,
        children: [Text('X')],
      ),
    );
    final wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.alignment, WrapAlignment.center);
  });

  testWidgets('passes direction to Wrap', (tester) async {
    await tester.pumpObers(
      const OiWrapLayout(
        direction: Axis.vertical,
        children: [Text('X')],
      ),
    );
    final wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.direction, Axis.vertical);
  });
}
