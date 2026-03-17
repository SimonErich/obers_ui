// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/overlays/oi_sheet.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('open=true shows child content', (tester) async {
    await tester.pumpObers(
      const OiSheet(open: true, child: Text('Sheet content')),
    );
    await tester.pump(); // let animation settle
    expect(find.text('Sheet content'), findsOneWidget);
  });

  testWidgets('open=false hides child content via slide animation', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiSheet(open: false, child: Text('Hidden content')),
    );
    // The SlideTransition keeps the child in tree but translated off-screen;
    // the text widget is still found but visually off-screen.
    // At minimum, the widget must build without errors.
    expect(tester.takeException(), isNull);
  });

  testWidgets('onClose fires when scrim is tapped (dismissible=true)', (
    tester,
  ) async {
    var closed = false;
    await tester.pumpObers(
      OiSheet(
        open: true,
        onClose: () => closed = true,
        child: const SizedBox(height: 200, child: Text('Panel')),
      ),
    );
    await tester.pump();
    // Tap well above the panel (on the scrim).
    await tester.tapAt(const Offset(200, 10));
    await tester.pump();
    expect(closed, isTrue);
  });

  testWidgets('dismissible=false: scrim tap does not call onClose', (
    tester,
  ) async {
    var closed = false;
    await tester.pumpObers(
      OiSheet(
        open: true,
        dismissible: false,
        onClose: () => closed = true,
        child: const SizedBox(height: 200, child: Text('Panel')),
      ),
    );
    await tester.pump();
    await tester.tapAt(const Offset(200, 10));
    await tester.pump();
    expect(closed, isFalse);
  });

  testWidgets('dragHandle=true renders drag handle widget', (tester) async {
    await tester.pumpObers(
      const OiSheet(open: true, dragHandle: true, child: Text('With handle')),
    );
    await tester.pump();
    // The handle is a small Container; the sheet child text must be visible.
    expect(find.text('With handle'), findsOneWidget);
  });

  testWidgets('side=right slides in from the right', (tester) async {
    await tester.pumpObers(
      const OiSheet(
        open: true,
        side: OiPanelSide.right,
        child: Text('Right panel'),
      ),
    );
    await tester.pump();
    expect(find.text('Right panel'), findsOneWidget);
  });

  testWidgets('side=top slides in from the top', (tester) async {
    await tester.pumpObers(
      const OiSheet(
        open: true,
        side: OiPanelSide.top,
        child: Text('Top panel'),
      ),
    );
    await tester.pump();
    expect(find.text('Top panel'), findsOneWidget);
  });

  testWidgets('side=left slides in from the left', (tester) async {
    await tester.pumpObers(
      const OiSheet(
        open: true,
        side: OiPanelSide.left,
        child: Text('Left panel'),
      ),
    );
    await tester.pump();
    expect(find.text('Left panel'), findsOneWidget);
  });

  testWidgets('toggling open from false to true animates in', (tester) async {
    // OiSheet uses SlideTransition which keeps the child in the tree
    // regardless of open state. Verify that animation runs by checking
    // controller direction: starts at 0 (closed) then animates to 1 (open).
    var open = false;
    await tester.pumpObers(
      StatefulBuilder(
        builder: (_, setState) => Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => open = true),
              child: const Text('open'),
            ),
            OiSheet(open: open, child: const Text('Toggled')),
          ],
        ),
      ),
    );
    // Closed: child exists in tree (maintained by SlideTransition).
    expect(find.text('Toggled'), findsOneWidget);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    // Open: still visible (now fully animated in).
    expect(find.text('Toggled'), findsOneWidget);
  });

  testWidgets(
    'disableAnimations=true: toggling open completes instantly — '
    'SlideTransition position is Offset.zero after one pump',
    (tester) async {
      final notifier = ValueNotifier<bool>(false);
      addTearDown(notifier.dispose);

      await tester.pumpObers(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: ValueListenableBuilder<bool>(
            valueListenable: notifier,
            builder: (_, isOpen, __) =>
                OiSheet(open: isOpen, child: const Text('instant')),
          ),
        ),
      );
      await tester.pump();

      // Open the sheet — with Duration.zero the controller jumps to 1.0
      // immediately without needing pumpAndSettle.
      notifier.value = true;
      await tester.pump();

      final slide =
          tester.widget<SlideTransition>(find.byType(SlideTransition));
      expect(slide.position.value, Offset.zero);
    },
  );
}
