// Tests do not require documentation comments.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_list_tile.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('unlimited title wraps at large text and keeps its action', (
    tester,
  ) async {
    const title = 'Saturday, 20 June with the family';
    var taps = 0;
    await tester.pumpObers(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: Center(
          child: SizedBox(
            width: 240,
            child: OiListTile(
              title: title,
              titleMaxLines: null,
              leading: const SizedBox(width: 32, height: 32),
              trailing: const SizedBox(width: 44, height: 44),
              onTap: () => taps++,
            ),
          ),
        ),
      ),
    );
    final text = find.descendant(
      of: find.text(title),
      matching: find.byType(RichText),
    );
    final paragraph = tester.renderObject<RenderParagraph>(text);
    final boxes = paragraph.getBoxesForSelection(
      const TextSelection(baseOffset: 0, extentOffset: title.length),
    );
    expect(boxes.length, greaterThan(1));
    expect(
      tester.getRect(text).bottom,
      lessThanOrEqualTo(tester.getRect(find.byType(OiListTile)).bottom),
    );
    await tester.tap(find.text(title));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom geometry and type preserve title, subtitle and actions', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpObers(
      OiListTile(
        title: 'A moment',
        subtitle: 'Yesterday',
        semanticLabel: 'Open moment',
        padding: const EdgeInsets.all(24),
        gap: 16,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        subtitleStyle: const TextStyle(fontSize: 14),
        leading: const SizedBox(width: 44, height: 44),
        onTap: () => taps++,
      ),
    );
    expect(tester.widget<Text>(find.text('A moment')).style!.fontSize, 16);
    expect(tester.widget<Text>(find.text('Yesterday')).style!.fontSize, 14);
    await tester.tap(find.text('A moment'));
    expect(taps, 1);
    expect(
      tester.getSize(find.byType(OiListTile)).height,
      greaterThanOrEqualTo(92),
    );
  });
  testWidgets('renders title', (tester) async {
    await tester.pumpObers(const OiListTile(title: 'Item One'));
    expect(find.text('Item One'), findsOneWidget);
  });

  testWidgets('renders subtitle when provided', (tester) async {
    await tester.pumpObers(const OiListTile(title: 'Title', subtitle: 'Sub'));
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Sub'), findsOneWidget);
  });

  testWidgets('renders leading widget', (tester) async {
    await tester.pumpObers(
      const OiListTile(
        title: 'Item',
        leading: Icon(IconData(0xe318, fontFamily: 'MaterialIcons')),
      ),
    );
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('renders trailing widget', (tester) async {
    await tester.pumpObers(
      const OiListTile(
        title: 'Item',
        trailing: Icon(IconData(0xe5c5, fontFamily: 'MaterialIcons')),
      ),
    );
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('onTap fires when tapped', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiListTile(title: 'Tap me', onTap: () => tapped = true),
    );
    await tester.tap(find.text('Tap me'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('selected tile has highlight background', (tester) async {
    await tester.pumpObers(const OiListTile(title: 'Selected', selected: true));
    // At least one ColoredBox (the highlight) must be present.
    expect(find.byType(ColoredBox), findsWidgets);
  });

  testWidgets('dense reduces vertical space', (tester) async {
    await tester.pumpObers(const OiListTile(title: 'Dense', dense: true));
    expect(find.text('Dense'), findsOneWidget);
  });
}
