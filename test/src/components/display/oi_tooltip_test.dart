// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('tooltip hidden by default', (tester) async {
    await tester.pumpObers(
      const OiTooltip(label: 'Tip', message: 'Tip text', child: Text('hover me')),
    );
    expect(find.text('Tip text'), findsNothing);
  });

  testWidgets('long-press shows tooltip', (tester) async {
    await tester.pumpObers(
      const OiTooltip(
        label: 'Tip',
        message: 'Tip text',
        showDelay: Duration.zero,
        child: Text('hold me'),
      ),
    );
    await tester.longPress(find.text('hold me'));
    await tester.pump();
    expect(find.text('Tip text'), findsOneWidget);
  });

  testWidgets('tooltip auto-dismisses after 2s on long-press', (tester) async {
    await tester.pumpObers(
      const OiTooltip(
        label: 'Tip',
        message: 'Gone soon',
        showDelay: Duration.zero,
        child: Text('hold me'),
      ),
    );
    await tester.longPress(find.text('hold me'));
    await tester.pump();
    expect(find.text('Gone soon'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Gone soon'), findsNothing);
  });

  testWidgets('hover shows tooltip after delay', (tester) async {
    await tester.pumpObers(
      const OiTooltip(
        label: 'Tip',
        message: 'Hover tip',
        showDelay: Duration(milliseconds: 100),
        child: Text('hover me'),
      ),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: tester.getCenter(find.text('hover me')));
    addTearDown(gesture.removePointer);
    await tester.pump();

    // Before delay — not visible.
    expect(find.text('Hover tip'), findsNothing);

    // After delay — visible.
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Hover tip'), findsOneWidget);
  });

  testWidgets('hover shows tooltip immediately when reducedMotion', (
    tester,
  ) async {
    await tester.pumpObers(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: OiTooltip(
          label: 'Tip',
          message: 'Instant tip',
          showDelay: Duration(milliseconds: 600),
          child: Text('hover me'),
        ),
      ),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: tester.getCenter(find.text('hover me')));
    addTearDown(gesture.removePointer);
    await tester.pump();

    // With reducedMotion, the tooltip should appear immediately — no delay.
    expect(find.text('Instant tip'), findsOneWidget);
  });

  testWidgets('rich content overrides message', (tester) async {
    await tester.pumpObers(
      const OiTooltip(
        label: 'Tip',
        message: 'plain',
        showDelay: Duration.zero,
        content: Text('rich content'),
        child: Text('hold me'),
      ),
    );
    await tester.longPress(find.text('hold me'));
    await tester.pump();
    expect(find.text('rich content'), findsOneWidget);
    expect(find.text('plain'), findsNothing);
  });
}
