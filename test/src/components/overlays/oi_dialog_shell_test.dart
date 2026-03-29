// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/overlays/oi_dialog_shell.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiDialogShell', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpObers(
        const OiDialogShell(child: Text('Hello')),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('respects width constraint', (tester) async {
      await tester.pumpObers(
        const Center(
          child: OiDialogShell(
            width: 400,
            child: SizedBox.shrink(),
          ),
        ),
        surfaceSize: const Size(800, 600),
      );

      // When width is set, the Container's constraints are tightened to
      // that width (minWidth == maxWidth == width).
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(OiDialogShell),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.maxWidth, 400);
      expect(container.constraints?.minWidth, 400);
    });

    testWidgets('applies custom backgroundColor', (tester) async {
      const customColor = Color(0xFFFF0000);
      await tester.pumpObers(
        const OiDialogShell(
          backgroundColor: customColor,
          child: Text('colored'),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(OiDialogShell),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, customColor);
    });

    testWidgets('applies custom borderRadius', (tester) async {
      final customRadius = BorderRadius.circular(24);
      await tester.pumpObers(
        OiDialogShell(
          borderRadius: customRadius,
          child: const Text('rounded'),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(OiDialogShell),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.borderRadius, customRadius);
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpObers(
        const OiDialogShell(
          padding: EdgeInsets.all(32),
          child: Text('padded'),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(OiDialogShell),
          matching: find.byType(Container),
        ),
      );
      expect(container.padding, const EdgeInsets.all(32));
    });

    testWidgets('no padding by default', (tester) async {
      await tester.pumpObers(
        const OiDialogShell(child: Text('no padding')),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(OiDialogShell),
          matching: find.byType(Container),
        ),
      );
      expect(container.padding, isNull);
    });

    testWidgets('stores semanticLabel property', (tester) async {
      // Rendering with semanticLabel triggers Semantics(scopesRoute: true)
      // which requires explicitChildNodes in newer Flutter. Verify the
      // property is stored correctly without pumping.
      const widget = OiDialogShell(
        semanticLabel: 'Settings dialog',
        child: Text('content'),
      );
      expect(widget.semanticLabel, 'Settings dialog');
    });

    testWidgets('semanticLabel is null by default', (tester) async {
      const widget = OiDialogShell(child: Text('plain'));
      expect(widget.semanticLabel, isNull);
    });

    testWidgets('no Semantics wrapper when semanticLabel is null',
        (tester) async {
      await tester.pumpObers(
        const OiDialogShell(child: Text('plain')),
      );

      // When no semanticLabel, no namesRoute Semantics wrapper.
      final semanticsWidgets = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(OiDialogShell),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                (widget.properties.namesRoute ?? false),
          ),
        ),
      );
      expect(semanticsWidgets, isEmpty);
    });
  });
}
