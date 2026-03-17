// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_switch.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders off state', (tester) async {
    await tester.pumpObers(const OiSwitch(value: false));
    expect(find.byType(OiSwitch), findsOneWidget);
  });

  testWidgets('renders on state', (tester) async {
    await tester.pumpObers(const OiSwitch(value: true));
    expect(find.byType(OiSwitch), findsOneWidget);
  });

  testWidgets('tapping off switch calls onChanged with true', (tester) async {
    bool? result;
    await tester.pumpObers(
      OiSwitch(value: false, onChanged: (v) => result = v),
    );
    await tester.tap(find.byType(OiTappable).first);
    await tester.pump();
    expect(result, isTrue);
  });

  testWidgets('tapping on switch calls onChanged with false', (tester) async {
    bool? result;
    await tester.pumpObers(
      OiSwitch(value: true, onChanged: (v) => result = v),
    );
    await tester.tap(find.byType(OiTappable).first);
    await tester.pump();
    expect(result, isFalse);
  });

  testWidgets('label is shown', (tester) async {
    await tester.pumpObers(
      const OiSwitch(value: false, label: 'Dark mode'),
    );
    expect(find.text('Dark mode'), findsOneWidget);
  });

  testWidgets('all size variants render', (tester) async {
    for (final size in OiSwitchSize.values) {
      await tester.pumpObers(OiSwitch(value: false, size: size));
      expect(find.byType(OiSwitch), findsOneWidget);
    }
  });

  testWidgets('enabled=false suppresses onChanged', (tester) async {
    bool? result;
    await tester.pumpObers(
      OiSwitch(value: false, enabled: false, onChanged: (v) => result = v),
    );
    await tester.tap(find.byType(OiSwitch), warnIfMissed: false);
    await tester.pump();
    expect(result, isNull);
  });
}
