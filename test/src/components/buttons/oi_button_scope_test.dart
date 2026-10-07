import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('buttons retain distinct action names in indexed headers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpObers(
      OiDockedPage.slivers(
        dock: OiButton.primary(label: 'Invite', onTap: () {}),
        slivers: [
          OiSliverList(
            itemCount: 1,
            itemBuilder: (context, _) => OiColumn(
              breakpoint: context.breakpoint,
              children: [
                const OiLabel.h1('Overview'),
                OiButton.ghost(label: 'Review duplicates', onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
    expect(find.bySemanticsLabel('Invite'), findsOneWidget);
    expect(find.bySemanticsLabel('Review duplicates'), findsOneWidget);
    semantics.dispose();
  });

  test('partial typography retains global font and leading', () {
    const base = OiButtonThemeData(
      textStyle: TextStyle(
        fontFamily: 'Custom',
        fontSize: 19,
        height: 1.4,
      ),
    );
    const override = OiButtonThemeData(
      textStyle: TextStyle(fontWeight: FontWeight.w700),
    );
    final resolved = base.merge(override).textStyle!;
    expect(resolved.fontFamily, 'Custom');
    expect(resolved.height, 1.4);
    expect(resolved.fontWeight, FontWeight.w700);
  });
  testWidgets(
    'a button scope overrides height and retains global variant styling',
    (tester) async {
      final base = OiThemeData.light().copyWith(
        components: const OiComponentThemes(
          button: OiButtonThemeData(
            height: 52,
            primaryStyle: OiButtonVariantStyle(background: Color(0xFF123456)),
          ),
        ),
      );
      await tester.pumpObers(
        Center(
          child: OiButtonThemeScope(
            theme: const OiButtonThemeData(height: 64),
            child: OiButton.primary(label: 'A scoped action', onTap: () {}),
          ),
        ),
        theme: base,
      );
      expect(tester.getSize(find.byType(OiButton)).height, 64);
      final surfaces = tester.widgetList<DecoratedBox>(
        find.byType(DecoratedBox),
      );
      expect(
        surfaces.any(
          (w) =>
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).color == const Color(0xFF123456),
        ),
        isTrue,
      );
    },
  );
}
