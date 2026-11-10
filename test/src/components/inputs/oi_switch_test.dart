// Tests do not require documentation comments.

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
    await tester.pumpObers(OiSwitch(value: true, onChanged: (v) => result = v));
    await tester.tap(find.byType(OiTappable).first);
    await tester.pump();
    expect(result, isFalse);
  });

  testWidgets('label is shown', (tester) async {
    await tester.pumpObers(const OiSwitch(value: false, label: 'Dark mode'));
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

  group('semantics', () {
    testWidgets('names the switch with its on/off state and a tap action', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      bool? result;
      await tester.pumpObers(
        OiSwitch(
          value: true,
          semanticLabel: 'Dark mode',
          onChanged: (v) => result = v,
        ),
      );

      expect(find.text('Dark mode'), findsNothing, reason: 'nothing drawn');
      expect(
        tester.getSemantics(find.bySemanticsLabel('Dark mode')),
        matchesSemantics(
          label: 'Dark mode',
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      tester.semantics.tap(find.semantics.byLabel('Dark mode'));
      expect(result, isFalse);
      handle.dispose();
    });

    testWidgets('the visible label names it when no semanticLabel is given', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        OiSwitch(value: false, label: 'Dark mode', onChanged: (_) {}),
      );

      expect(find.bySemanticsLabel('Dark mode'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a disabled switch has no tap action', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        const OiSwitch(value: false, enabled: false, semanticLabel: 'Sound'),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Sound')),
        matchesSemantics(
          label: 'Sound',
          hasToggledState: true,
          hasEnabledState: true,
        ),
      );
      handle.dispose();
    });
  });
}
