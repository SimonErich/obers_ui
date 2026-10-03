import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'search trigger keeps one button identity through hover and keyboard activation',
    (tester) async {
      var opened = 0;
      await tester.pumpObers(
        Center(
          child: SizedBox(
            width: 360,
            child: OiSearchTrigger(
              label: 'Search orders',
              shortcut: const ['⌘', 'K'],
              onPressed: () => opened++,
            ),
          ),
        ),
      );
      final button = find.byType(OiSearchTrigger);
      final bounds = tester.getRect(button);
      expect(find.byType(EditableText), findsNothing);
      expect(find.text('⌘K'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Search orders')),
        matchesSemantics(
          label: 'Search orders',
          isButton: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(bounds.center);
      await tester.pumpAndSettle();
      expect(tester.getRect(button), bounds);
      expect(find.text('Search orders'), findsOneWidget);
      await tester.tap(button);
      await tester.pump();
      expect(opened, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(opened, 2);
      await mouse.removePointer();
    },
  );

  testWidgets('theme controls search geometry and disabled activation', (
    tester,
  ) async {
    const opened = 0;
    final theme = OiThemeData.light();
    await tester.pumpObers(
      const Center(
        child: SizedBox(
          width: 300,
          child: OiSearchTrigger(
            label: 'Search',
            shortcut: [],
            onPressed: null,
          ),
        ),
      ),
      theme: theme.copyWith(
        components: theme.components.copyWith(
          searchTrigger: const OiSearchTriggerThemeData(height: 36),
        ),
      ),
    );
    expect(tester.getSize(find.byType(OiSearchTrigger)), const Size(300, 36));
    expect(find.byType(OiKbd), findsNothing);
    await tester.tap(find.byType(OiSearchTrigger));
    expect(opened, 0);
  });
}
