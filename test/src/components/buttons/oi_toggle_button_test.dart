// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_toggle_button.dart';

import '../../../helpers/pump_app.dart';

const _kIcon = IconData(0xe318, fontFamily: 'MaterialIcons');

void main() {
  testWidgets('renders label', (tester) async {
    await tester.pumpObers(
      const OiToggleButton(selected: false, label: 'Bold'),
    );
    expect(find.text('Bold'), findsOneWidget);
  });

  testWidgets('renders icon', (tester) async {
    await tester.pumpObers(
      const OiToggleButton(selected: false, icon: _kIcon),
    );
    expect(find.byIcon(_kIcon), findsOneWidget);
  });

  testWidgets('onChanged fires with toggled value on tap', (tester) async {
    bool? received;
    await tester.pumpObers(
      OiToggleButton(
        selected: false,
        label: 'Bold',
        onChanged: (v) => received = v,
      ),
    );
    await tester.tap(find.text('Bold'));
    await tester.pump();
    expect(received, isTrue);
  });

  testWidgets('onChanged fires false when selected=true', (tester) async {
    bool? received;
    await tester.pumpObers(
      OiToggleButton(
        selected: true,
        label: 'Bold',
        onChanged: (v) => received = v,
      ),
    );
    await tester.tap(find.text('Bold'));
    await tester.pump();
    expect(received, isFalse);
  });

  testWidgets('onChanged not called when enabled=false', (tester) async {
    bool? received;
    await tester.pumpObers(
      OiToggleButton(
        selected: false,
        label: 'Bold',
        enabled: false,
        onChanged: (v) => received = v,
      ),
    );
    await tester.tap(find.text('Bold'), warnIfMissed: false);
    await tester.pump();
    expect(received, isNull);
  });

  testWidgets('selected=true uses primary background colour', (tester) async {
    // Check that the decorated container has a non-transparent colour when
    // selected.  We do this by looking at the Container decoration.
    await tester.pumpObers(
      const OiToggleButton(selected: true, label: 'Bold'),
    );
    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration! as BoxDecoration;
    // Primary base colour should be fully opaque (alpha > 0).
    expect(decoration.color!.a, greaterThan(0));
  });

  testWidgets('selected=false uses transparent background', (tester) async {
    await tester.pumpObers(
      const OiToggleButton(selected: false, label: 'Bold'),
    );
    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color!.a, equals(0));
  });
}
