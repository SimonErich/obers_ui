// Tests do not require documentation comments.

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_popover.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('popover labels its content independently from its trigger', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    for (final open in [false, true]) {
      await tester.pumpObers(
        OiPopover(
          label: 'Account options',
          open: open,
          anchor: const Text('Account trigger'),
          content: const Text('Profile details'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Account trigger'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Account options'),
        open ? findsOneWidget : findsNothing,
      );
      if (open) {
        expect(find.bySemanticsLabel('Profile details'), findsOneWidget);
      }
    }
    semantics.dispose();
  });

  testWidgets('open=true shows content', (tester) async {
    await tester.pumpObers(
      const OiPopover(
        label: 'Test popover',
        open: true,
        anchor: Text('anchor'),
        content: Text('popover body'),
      ),
    );
    expect(find.text('popover body'), findsOneWidget);
  });

  testWidgets('open=false hides content', (tester) async {
    await tester.pumpObers(
      const OiPopover(
        label: 'Test popover',
        anchor: Text('anchor'),
        content: Text('popover body'),
      ),
    );
    expect(find.text('popover body'), findsNothing);
  });

  testWidgets('escape key calls onClose', (tester) async {
    var closed = false;
    await tester.pumpObers(
      OiPopover(
        label: 'Test popover',
        open: true,
        onClose: () => closed = true,
        anchor: const Text('anchor'),
        content: const Text('content'),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(closed, isTrue);
  });

  group('an anchor that toggles it', () {
    Future<void> pumpToggling(WidgetTester tester) =>
        tester.pumpObers(const Center(child: _Toggling()));

    TestGesture? mouse;

    Future<void> click(WidgetTester tester, Offset at) async {
      if (mouse == null) {
        mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse!.addPointer(location: at);
        addTearDown(mouse!.removePointer);
      }
      await mouse!.moveTo(at);
      await mouse!.down(at);
      await tester.pump();
      await mouse!.up();
      await tester.pumpAndSettle();
    }

    setUp(() => mouse = null);

    testWidgets('a click on the anchor closes it, and stays closed', (
      tester,
    ) async {
      await pumpToggling(tester);
      final anchor = find.byKey(const ValueKey('anchor'));

      await click(tester, tester.getCenter(anchor));
      expect(find.text('popover body'), findsOneWidget);

      await click(tester, tester.getCenter(anchor));
      expect(find.text('popover body'), findsNothing);

      await click(tester, tester.getCenter(anchor));
      expect(find.text('popover body'), findsOneWidget);
    });

    testWidgets('a click elsewhere still closes it', (tester) async {
      await pumpToggling(tester);
      await click(
        tester,
        tester.getCenter(find.byKey(const ValueKey('anchor'))),
      );
      expect(find.text('popover body'), findsOneWidget);

      await click(tester, const Offset(4, 4));

      expect(find.text('popover body'), findsNothing);
    });
  });
}

/// A popover whose anchor opens and closes it, as a menu button does.
class _Toggling extends StatefulWidget {
  const _Toggling();

  @override
  State<_Toggling> createState() => _TogglingState();
}

class _TogglingState extends State<_Toggling> {
  bool _open = false;

  @override
  Widget build(BuildContext context) => OiPopover(
    label: 'Test popover',
    open: _open,
    onClose: () => setState(() => _open = false),
    anchor: GestureDetector(
      key: const ValueKey('anchor'),
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _open = !_open),
      child: const SizedBox(width: 60, height: 30),
    ),
    content: const Text('popover body'),
  );
}
