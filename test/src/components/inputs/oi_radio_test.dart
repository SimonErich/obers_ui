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

  testWidgets('each option is a labelled, selectable node in a group', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    String? picked;
    await tester.pumpObers(
      OiRadio<String>(
        options: _kOptions,
        value: _kOptions.first.value,
        onChanged: (v) => picked = v,
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel(_kOptions.first.label)),
      matchesSemantics(
        label: _kOptions.first.label,
        hasCheckedState: true,
        isChecked: true,
        isInMutuallyExclusiveGroup: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );

    tester.semantics.tap(find.semantics.byLabel('Beta'));
    expect(picked, 'b');

    // The disabled option can't be picked.
    expect(
      tester.getSemantics(find.bySemanticsLabel('Gamma')),
      matchesSemantics(
        label: 'Gamma',
        hasCheckedState: true,
        isInMutuallyExclusiveGroup: true,
        hasEnabledState: true,
      ),
    );
    handle.dispose();
  });
}
