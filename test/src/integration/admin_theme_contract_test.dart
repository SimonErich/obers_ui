import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  testWidgets('compact capacity keeps semantics and wraps its explanation', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const OiApp(
        home: Center(
          child: SizedBox(
            width: 180,
            child: OiCapacityIndicator(
              value: 85,
              max: 120,
              label: 'Monthly budget',
              showLabel: false,
              showValue: false,
              caption: 'Includes the reservation for this order.',
            ),
          ),
        ),
      ),
    );
    expect(find.text('Monthly budget'), findsNothing);
    expect(find.text('85 / 120'), findsNothing);
    final node = tester.getSemantics(find.byType(OiCapacityIndicator));
    expect(node.label, contains('Monthly budget'));
    expect(node.value, '85 / 120');
    expect(
      find.text('Includes the reservation for this order.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets(
    'card input and button resolve component theme geometry and text',
    (tester) async {
      final theme = OiThemeData.light().copyWith(
        components: const OiComponentThemes(
          card: OiCardThemeData(padding: EdgeInsets.all(29)),
          textInput: OiTextInputThemeData(
            height: 46,
            textStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          button: OiButtonThemeData(
            mediumHeight: 43,
            textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      );
      await tester.pumpWidget(
        OiApp(
          theme: theme,
          home: Center(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const OiCard(
                    key: ValueKey('card'),
                    child: SizedBox(key: ValueKey('inside'), height: 30),
                  ),
                  const OiTextInput(key: ValueKey('input')),
                  OiButton.primary(
                    key: const ValueKey('button'),
                    label: 'Save',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('inside'))).dx -
            tester.getTopLeft(find.byKey(const ValueKey('card'))).dx,
        29,
      );
      expect(tester.getSize(find.byKey(const ValueKey('input'))).height, 46);
      final input = tester.widget<EditableText>(find.byType(EditableText));
      expect(input.style.fontSize, 17);
      expect(input.style.fontWeight, FontWeight.w600);
      expect(tester.getSize(find.byKey(const ValueKey('button'))).height, 43);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('capacity indicator exposes values and only warns at threshold', (
    tester,
  ) async {
    Future<void> pump(num value, {num max = 100}) => tester.pumpWidget(
      OiApp(
        theme: OiThemeData.light(),
        home: Center(
          child: SizedBox(
            width: 240,
            child: OiCapacityIndicator(
              value: value,
              max: max,
              label: 'Capacity',
              subtitle: 'Morning service',
              warningText: 'Nearly full',
            ),
          ),
        ),
      ),
    );
    await pump(80);
    expect(find.text('80 / 100'), findsOneWidget);
    expect(find.text('Nearly full'), findsNothing);
    await pump(95);
    expect(find.text('Nearly full'), findsOneWidget);
    await pump(120);
    expect(find.text('120 / 100'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await pump(0, max: 0);
    expect(find.text('0 / 0'), findsOneWidget);
    expect(find.text('Nearly full'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
