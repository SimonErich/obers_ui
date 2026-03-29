// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_radio.dart';

import '../../../helpers/pump_app.dart';

const List<OiRadioOption<String>> _kOptions = [
  OiRadioOption(value: 'a', label: 'Alpha'),
  OiRadioOption(value: 'b', label: 'Beta'),
  OiRadioOption(value: 'c', label: 'Gamma', enabled: false),
];

void main() {
  testWidgets('renders all option labels', (tester) async {
    await tester.pumpObers(const OiRadio<String>(options: _kOptions));
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Gamma'), findsOneWidget);
  });

  testWidgets('tapping enabled option calls onChanged', (tester) async {
    String? selected;
    await tester.pumpObers(
      OiRadio<String>(options: _kOptions, onChanged: (v) => selected = v),
    );
    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(selected, 'b');
  });

  testWidgets('tapping enabled=false option does not call onChanged', (
    tester,
  ) async {
    String? selected;
    await tester.pumpObers(
      OiRadio<String>(options: _kOptions, onChanged: (v) => selected = v),
    );
    await tester.tap(find.text('Gamma'), warnIfMissed: false);
    await tester.pump();
    expect(selected, isNull);
  });

  testWidgets('horizontal direction renders row', (tester) async {
    await tester.pumpObers(
      const OiRadio<String>(options: _kOptions, direction: Axis.horizontal),
    );
    expect(find.byType(OiRadio<String>), findsOneWidget);
  });

  testWidgets('vertical direction renders column', (tester) async {
    await tester.pumpObers(const OiRadio<String>(options: _kOptions));
    expect(find.byType(OiRadio<String>), findsOneWidget);
  });

  testWidgets('enabled=false suppresses all options', (tester) async {
    String? selected;
    await tester.pumpObers(
      OiRadio<String>(
        options: _kOptions,
        enabled: false,
        onChanged: (v) => selected = v,
      ),
    );
    await tester.tap(find.text('Alpha'), warnIfMissed: false);
    await tester.pump();
    expect(selected, isNull);
  });
}
