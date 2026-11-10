// Tests do not require documentation comments.

import 'dart:ui' show Tristate;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'a standalone switch keeps its accessible name and themed thumb inset',
    (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      bool? result;
      final theme = OiThemeData.light();
      await tester.pumpObers(
        Center(
          child: OiThemeScope(
            data: theme.copyWith(
              components: theme.components.copyWith(
                switchTheme: const OiSwitchThemeData(
                  width: 52,
                  height: 32,
                  thumbInset: 4,
                ),
              ),
            ),
            child: OiSwitch(
              value: false,
              semanticLabel: 'Render remotely',
              onChanged: (v) => result = v,
            ),
          ),
        ),
      );
      final action = find.bySemanticsLabel('Render remotely');
      expect(tester.getSize(action), const Size(52, 32));
      final thumb = tester.widget<AnimatedPositioned>(
        find.byType(AnimatedPositioned),
      );
      expect(thumb.top, 4);
      await tester.tap(action);
      expect(result, isTrue);
      expect(find.text('Render remotely'), findsNothing);
      semantics.dispose();
    },
  );
  testWidgets('exposes the name and current switch state', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpObers(
      OiSwitch(value: true, label: 'Cloud rendering', onChanged: (_) {}),
    );
    final node = tester.getSemantics(find.bySemanticsLabel('Cloud rendering'));
    expect(node.flagsCollection.isToggled, Tristate.isTrue);
    semantics.dispose();
  });
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
}
