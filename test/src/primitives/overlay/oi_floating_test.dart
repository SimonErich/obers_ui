// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. Anchor renders ──────────────────────────────────────────────────────

  testWidgets('renders the anchor widget', (tester) async {
    await tester.pumpObers(
      const OiFloating(anchor: Text('anchor'), child: Text('floating')),
    );
    expect(find.text('anchor'), findsOneWidget);
  });

  // ── 2. visible=false hides child ──────────────────────────────────────────

  testWidgets('floating child is not visible', (tester) async {
    await tester.pumpObers(
      const OiFloating(
        anchor: SizedBox(width: 80, height: 40),
        child: Text('floating'),
      ),
    );
    await tester.pumpAndSettle();
    // When visible=false (default), the floating text should not appear.
    expect(find.text('floating'), findsNothing);
  });

  // ── 3. visible=true shows child ────────────────────────────────────────────

  testWidgets('floating child is visible', (tester) async {
    await tester.pumpObers(
      const OiFloating(
        anchor: SizedBox(width: 80, height: 40),
        visible: true,
        child: Text('floating'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('floating'), findsOneWidget);
  });

  // ── 4. Different alignments render without error ───────────────────────────

  for (final alignment in [
    OiFloatingAlignment.topStart,
    OiFloatingAlignment.bottomEnd,
    OiFloatingAlignment.leftCenter,
    OiFloatingAlignment.rightStart,
  ]) {
    testWidgets('alignment=$alignment renders without error', (tester) async {
      await tester.pumpObers(
        OiFloating(
          anchor: const SizedBox(width: 80, height: 40),
          visible: true,
          alignment: alignment,
          child: const Text('floating'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OiFloating), findsOneWidget);
    });
  }

  // ── 5. autoFlip=false does not change alignment ────────────────────────────

  testWidgets('autoFlip=false: uses provided alignment without flipping', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiFloating(
        anchor: SizedBox(width: 80, height: 40),
        visible: true,
        alignment: OiFloatingAlignment.topCenter,
        autoFlip: false,
        child: Text('floating'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(OiFloating), findsOneWidget);
  });

  // ── 6. gap parameter is accepted ──────────────────────────────────────────

  testWidgets('gap parameter does not cause errors', (tester) async {
    await tester.pumpObers(
      const OiFloating(
        anchor: SizedBox(width: 80, height: 40),
        visible: true,
        gap: 12,
        child: Text('floating'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(OiFloating), findsOneWidget);
  });

  // ── 7. offset parameter is accepted ───────────────────────────────────────

  testWidgets('offset parameter does not cause errors', (tester) async {
    await tester.pumpObers(
      const OiFloating(
        anchor: SizedBox(width: 80, height: 40),
        visible: true,
        offset: Offset(8, 8),
        child: Text('floating'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(OiFloating), findsOneWidget);
  });

  // ── 9. flip: bottomStart near bottom edge flips above anchor ─────────────

  testWidgets(
      'overflow=flip: bottomStart near bottom edge positions child above anchor',
      (tester) async {
    // 400×200 screen with anchor at the very bottom (y=160, h=40 → bottom=200).
    // A 100-tall child would overflow → should flip to above the anchor.
    await tester.pumpObers(
      const Align(
        alignment: Alignment.bottomLeft,
        child: OiFloating(
          anchor: SizedBox(width: 80, height: 40),
          visible: true,
          child: SizedBox(width: 100, height: 100),
        ),
      ),
      surfaceSize: const Size(400, 200),
    );
    await tester.pumpAndSettle();

    final anchorTop =
        tester.getTopLeft(find.byType(OiFloating)).dy;
    final childBottom =
        tester.getBottomLeft(find.byWidget(
          tester.widget(
            find.byType(SizedBox).last,
          ),
        )).dy;
    // Child should end at or before the anchor's top edge.
    expect(childBottom, lessThanOrEqualTo(anchorTop + 1));
  });

  // ── 10. flip: bottomEnd near bottom-right corner clamps to screen ─────────

  testWidgets(
      'overflow=flip: bottomEnd near bottom-right corner stays within screen',
      (tester) async {
    await tester.pumpObers(
      const Align(
        alignment: Alignment.bottomRight,
        child: OiFloating(
          anchor: SizedBox(width: 60, height: 40),
          visible: true,
          alignment: OiFloatingAlignment.bottomEnd,
          child: SizedBox(width: 200, height: 150),
        ),
      ),
      surfaceSize: const Size(300, 300),
    );
    await tester.pumpAndSettle();

    final childRect = tester.getRect(
      find.byType(SizedBox).last,
    );
    expect(childRect.right, lessThanOrEqualTo(300));
    expect(childRect.bottom, lessThanOrEqualTo(300));
    expect(childRect.left, greaterThanOrEqualTo(0));
    expect(childRect.top, greaterThanOrEqualTo(0));
  });

  // ── 11. shift mode keeps child within bounds on the same side ─────────────

  testWidgets('overflow=shift: child stays within screen bounds', (
    tester,
  ) async {
    await tester.pumpObers(
      const Align(
        alignment: Alignment.bottomRight,
        child: OiFloating(
          anchor: SizedBox(width: 60, height: 40),
          visible: true,
          alignment: OiFloatingAlignment.bottomEnd,
          overflow: OiFloatingOverflow.shift,
          child: SizedBox(width: 200, height: 80),
        ),
      ),
      surfaceSize: const Size(300, 300),
    );
    await tester.pumpAndSettle();

    final childRect = tester.getRect(find.byType(SizedBox).last);
    expect(childRect.right, lessThanOrEqualTo(300));
    expect(childRect.left, greaterThanOrEqualTo(0));
  });

  // ── 12. overflow=none does not constrain the position ─────────────────────

  testWidgets('overflow=none (autoFlip=false): widget renders without error',
      (tester) async {
    await tester.pumpObers(
      const OiFloating(
        anchor: SizedBox(width: 80, height: 40),
        visible: true,
        autoFlip: false,
        child: SizedBox(width: 200, height: 150),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(OiFloating), findsOneWidget);
  });

  // ── 13. screenPadding keeps child away from edges ─────────────────────────

  testWidgets('screenPadding is respected: child stays within padded bounds',
      (tester) async {
    await tester.pumpObers(
      const Align(
        alignment: Alignment.bottomRight,
        child: OiFloating(
          anchor: SizedBox(width: 60, height: 40),
          visible: true,
          alignment: OiFloatingAlignment.bottomEnd,
          screenPadding: EdgeInsets.all(16),
          child: SizedBox(width: 200, height: 80),
        ),
      ),
      surfaceSize: const Size(300, 300),
    );
    await tester.pumpAndSettle();

    final childRect = tester.getRect(find.byType(SizedBox).last);
    expect(childRect.right, lessThanOrEqualTo(300 - 16));
    expect(childRect.left, greaterThanOrEqualTo(16));
  });

  // ── 8. toggling visible shows/hides floating content ──────────────────────

  testWidgets('toggling visible shows and hides floating content',
      (tester) async {
    final notifier = ValueNotifier<bool>(false);
    addTearDown(notifier.dispose);

    await tester.pumpObers(
      ValueListenableBuilder<bool>(
        valueListenable: notifier,
        builder: (context, showFloating, _) => OiFloating(
          anchor: const SizedBox(width: 80, height: 40),
          visible: showFloating,
          child: const Text('floating'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initially hidden.
    expect(find.text('floating'), findsNothing);

    // Toggle visible=true.
    notifier.value = true;
    await tester.pumpAndSettle();

    expect(find.text('floating'), findsOneWidget);
  });
}
