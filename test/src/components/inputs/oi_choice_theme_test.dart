import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

const _blue = Color(0xff0000ff);
const _white = Color(0xffffffff);
const _theme = OiComponentThemes(
  radio: OiRadioThemeData(
    size: 16,
    dotSize: 6,
    borderWidth: 1,
    selectedBorderColor: _blue,
    selectedDotColor: _blue,
    selectedFillColor: _white,
  ),
  radioTile: OiRadioTileThemeData(
    minHeight: 48,
    padding: EdgeInsets.all(12),
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderWidth: 1,
    selectedBorderWidth: 2,
  ),
);

void main() {
  testWidgets('radio theme paints a small dot inside an unfilled 16px ring', (
    tester,
  ) async {
    const key = ValueKey('indicator-paint');
    await tester.pumpObers(
      const Center(
        child: RepaintBoundary(
          key: key,
          child: OiRadioIndicator(selected: true),
        ),
      ),
      theme: OiThemeData.light().copyWith(components: _theme),
    );
    expect(tester.getSize(find.byType(OiRadioIndicator)), const Size(16, 16));
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(key),
    );
    final image = await tester.runAsync(boundary.toImage);
    final bytes = await tester.runAsync(
      () => image!.toByteData(),
    );
    Color pixel(int x, int y) {
      final index = (y * image!.width + x) * 4;
      return Color.fromARGB(
        bytes!.getUint8(index + 3),
        bytes.getUint8(index),
        bytes.getUint8(index + 1),
        bytes.getUint8(index + 2),
      );
    }

    expect(pixel(8, 8), _blue);
    expect(
      pixel(2, 8),
      _white,
      reason: 'The unfilled ring must not become a heavy solid disc.',
    );
    image!.dispose();
  });

  testWidgets('selection border changes never move card content or size', (
    tester,
  ) async {
    String? selected;
    await tester.pumpObers(
      Center(
        child: SizedBox(
          width: 300,
          child: StatefulBuilder(
            builder: (context, setState) => OiRadioTile<String>.card(
              title: 'Company invoice',
              value: 'company',
              groupValue: selected,
              controlLeading: true,
              onChanged: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
      theme: OiThemeData.light().copyWith(components: _theme),
    );
    final card = find.byType(OiRadioTile<String>);
    final before = tester.getRect(card);
    final titleBefore = tester.getTopLeft(find.text('Company invoice'));
    expect(before.height, 48);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(selected, 'company');
    expect(tester.getRect(card), before);
    expect(tester.getTopLeft(find.text('Company invoice')), titleBefore);
    final container = tester
        .widgetList<Container>(
          find.descendant(of: card, matching: find.byType(Container)),
        )
        .firstWhere((widget) => widget.foregroundDecoration is BoxDecoration);
    final stroke = container.foregroundDecoration! as BoxDecoration;
    expect(stroke.borderRadius, BorderRadius.circular(10));
    expect((stroke.border! as Border).top.width, 2);
    expect(tester.getSize(find.byType(OiRadioIndicator)), const Size(16, 16));
  });

  testWidgets(
    'compact choice cards grow with doubled text and reduced motion',
    (tester) async {
      var selected = false;
      await tester.pumpObers(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2),
              disableAnimations: true,
            ),
            child: Center(
              child: SizedBox(
                width: 320,
                child: OiRadioTile<bool>.card(
                  title: 'Company invoice with monthly consolidated billing',
                  value: true,
                  groupValue: selected,
                  controlLeading: true,
                  onChanged: (value) => selected = value,
                ),
              ),
            ),
          ),
        ),
        theme: OiThemeData.light().copyWith(components: _theme),
        surfaceSize: const Size(375, 667),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(OiRadioTile<bool>)).height,
        greaterThan(48),
      );
      await tester.tap(
        find.text('Company invoice with monthly consolidated billing'),
      );
      await tester.pump();
      expect(selected, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  test('selection themes survive copy and equality', () {
    expect(_theme.copyWith(), _theme);
    expect(_theme.radio!.copyWith(size: 20), isNot(_theme.radio));
    expect(_theme.radioTile!.copyWith(minHeight: 60), isNot(_theme.radioTile));
    expect(const OiComponentThemes.empty().radio, isNull);
    expect(const OiComponentThemes.empty().radioTile, isNull);
  });
}
