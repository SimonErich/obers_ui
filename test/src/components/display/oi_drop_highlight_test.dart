// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_drop_highlight.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders child when inactive', (tester) async {
    await tester.pumpObers(
      const OiDropHighlight(
        active: false,
        child: Text('content'),
      ),
    );
    expect(find.text('content'), findsOneWidget);
    expect(find.byType(AnimatedOpacity), findsNothing);
  });

  testWidgets('renders SizedBox.shrink when inactive and no child',
      (tester) async {
    await tester.pumpObers(
      const OiDropHighlight(active: false),
    );
    expect(find.byType(SizedBox), findsOneWidget);
  });

  testWidgets('area style shows message when active', (tester) async {
    await tester.pumpObers(
      const OiDropHighlight(
        active: true,
        style: OiDropHighlightStyle.area,
        message: 'Drop files here',
        child: SizedBox(width: 200, height: 200),
      ),
    );
    expect(find.text('Drop files here'), findsOneWidget);
  });

  testWidgets('area style shows icon when active', (tester) async {
    const icon = IconData(0xe145, fontFamily: 'MaterialIcons');
    await tester.pumpObers(
      const OiDropHighlight(
        active: true,
        style: OiDropHighlightStyle.area,
        icon: icon,
        child: SizedBox(width: 200, height: 200),
      ),
    );
    expect(find.byIcon(icon), findsOneWidget);
  });

  testWidgets('area style renders Stack and AnimatedOpacity when active',
      (tester) async {
    await tester.pumpObers(
      const OiDropHighlight(
        active: true,
        style: OiDropHighlightStyle.area,
        message: 'Drop here',
        child: SizedBox(width: 200, height: 200),
      ),
    );
    expect(find.byType(Stack), findsOneWidget);
    expect(find.byType(AnimatedOpacity), findsOneWidget);
  });

  testWidgets('area style AnimatedOpacity has full opacity when active',
      (tester) async {
    await tester.pumpObers(
      const OiDropHighlight(
        active: true,
        style: OiDropHighlightStyle.area,
        child: SizedBox(width: 200, height: 200),
      ),
    );
    final opacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );
    expect(opacity.opacity, 1.0);
  });

  testWidgets('border style renders Container with border when active',
      (tester) async {
    await tester.pumpObers(
      const OiDropHighlight(
        active: true,
        style: OiDropHighlightStyle.border,
        child: Text('folder'),
      ),
    );
    expect(find.text('folder'), findsOneWidget);
    // The Container wrapping the child should have a BoxDecoration with a border
    final container = tester.widget<Container>(find.byType(Container).first);
    expect(container.decoration, isA<BoxDecoration>());
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.border, isNotNull);
  });

  testWidgets('border style does not show message text', (tester) async {
    await tester.pumpObers(
      const OiDropHighlight(
        active: true,
        style: OiDropHighlightStyle.border,
        message: 'Should not appear',
        child: Text('child'),
      ),
    );
    expect(find.text('Should not appear'), findsNothing);
  });

  testWidgets('area style without message or icon renders no text/icon',
      (tester) async {
    await tester.pumpObers(
      const OiDropHighlight(
        active: true,
        style: OiDropHighlightStyle.area,
        child: SizedBox(width: 100, height: 100),
      ),
    );
    expect(find.byType(Text), findsNothing);
    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('area style renders CustomPaint for dashed border',
      (tester) async {
    await tester.pumpObers(
      const OiDropHighlight(
        active: true,
        style: OiDropHighlightStyle.area,
        child: SizedBox(width: 100, height: 100),
      ),
    );
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('default style is area', (tester) async {
    const highlight = OiDropHighlight(active: true);
    expect(highlight.style, OiDropHighlightStyle.area);
  });
}
