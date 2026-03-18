// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/theme/oi_effects_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Wraps [child] with [OiApp] in touch (comfortable) density.
Widget touchApp(Widget child) =>
    OiApp(density: OiDensity.comfortable, home: child);

/// Wraps [child] with [OiApp] in pointer (compact) density.
Widget pointerApp(Widget child) =>
    OiApp(density: OiDensity.compact, home: child);

void main() {
  // ── 1. Renders child ───────────────────────────────────────────────────────

  testWidgets('renders child widget', (tester) async {
    await tester.pumpObers(const OiTappable(child: Text('tap me')));
    expect(find.text('tap me'), findsOneWidget);
  });

  // ── 2. onTap fires ─────────────────────────────────────────────────────────

  testWidgets('onTap callback fires on tap', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiTappable(
        onTap: () => tapped = true,
        child: const SizedBox(width: 60, height: 60, child: Text('x')),
      ),
    );
    await tester.tap(find.byType(OiTappable));
    expect(tapped, isTrue);
  });

  // ── 3. onDoubleTap fires ───────────────────────────────────────────────────

  testWidgets('onDoubleTap callback fires on double tap', (tester) async {
    var count = 0;
    await tester.pumpObers(
      OiTappable(
        onDoubleTap: () => count++,
        child: const SizedBox(width: 60, height: 60, child: Text('x')),
      ),
    );
    await tester.tap(find.byType(OiTappable));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byType(OiTappable));
    await tester.pump(const Duration(milliseconds: 300));
    expect(count, greaterThanOrEqualTo(1));
  });

  // ── 4. onLongPress fires ───────────────────────────────────────────────────

  testWidgets('onLongPress callback fires on long press', (tester) async {
    var pressed = false;
    await tester.pumpObers(
      OiTappable(
        onLongPress: () => pressed = true,
        child: const SizedBox(width: 60, height: 60, child: Text('x')),
      ),
    );
    await tester.longPress(find.byType(OiTappable));
    expect(pressed, isTrue);
  });

  // ── 5. disabled=true: taps ignored and opacity applied ─────────────────────

  testWidgets('disabled=true: onTap not called', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiTappable(
        enabled: false,
        onTap: () => tapped = true,
        child: const SizedBox(width: 60, height: 60, child: Text('x')),
      ),
    );
    await tester.tap(find.byType(OiTappable));
    expect(tapped, isFalse);
  });

  testWidgets('disabled=true: Opacity widget present with 0.4', (tester) async {
    await tester.pumpObers(
      const OiTappable(enabled: false, child: SizedBox(width: 60, height: 60)),
    );
    final opacityWidgets = tester.widgetList<Opacity>(find.byType(Opacity));
    expect(opacityWidgets.any((o) => o.opacity == 0.4), isTrue);
  });

  // ── 6. focusable=false: Focus cannot request focus ─────────────────────────

  testWidgets('focusable=false: canRequestFocus is false on Focus node', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiTappable(
        focusable: false,
        child: SizedBox(width: 60, height: 60),
      ),
    );
    final focusWidget = tester.widget<Focus>(find.byType(Focus).first);
    expect(focusWidget.canRequestFocus, isFalse);
  });

  // ── 7. semanticLabel renders Semantics node ────────────────────────────────

  testWidgets('semanticLabel creates a Semantics node with label', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiTappable(
        semanticLabel: 'close dialog',
        child: SizedBox(width: 60, height: 60),
      ),
    );
    // The Semantics widget is added directly by OiTappable when semanticLabel
    // is non-null. Verify its properties directly.
    final semanticsWidget = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'close dialog',
      ),
    );
    expect(semanticsWidget.properties.label, 'close dialog');
    expect(semanticsWidget.properties.button, isTrue);
  });

  // ── 8. Touch device: 48 dp minimum touch target ────────────────────────────

  testWidgets('touch device: small child gets minimum 48dp touch target', (
    tester,
  ) async {
    await tester.pumpWidget(
      touchApp(
        const Center(child: OiTappable(child: SizedBox(width: 24, height: 24))),
      ),
    );
    await tester.pump();

    final size = tester.getSize(find.byType(OiTappable));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  // ── 9. Pointer device: no extra padding ────────────────────────────────────

  testWidgets('pointer device: child size is not padded to 48dp', (
    tester,
  ) async {
    await tester.pumpWidget(
      pointerApp(
        const Center(child: OiTappable(child: SizedBox(width: 24, height: 24))),
      ),
    );
    await tester.pump();

    final size = tester.getSize(find.byType(OiTappable));
    // On pointer devices the tappable does not inflate the size to 48dp.
    expect(size.width, lessThan(48));
    expect(size.height, lessThan(48));
  });

  // ── 10. Hover state on pointer device ─────────────────────────────────────

  testWidgets('pointer device: onHover called on MouseRegion enter/exit', (
    tester,
  ) async {
    final hoverStates = <bool>[];
    await tester.pumpWidget(
      pointerApp(
        Center(
          child: OiTappable(
            onHover: hoverStates.add,
            child: const SizedBox(width: 60, height: 60),
          ),
        ),
      ),
    );
    await tester.pump();

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();

    await gesture.moveTo(tester.getCenter(find.byType(OiTappable)));
    await tester.pump();
    expect(hoverStates, contains(true));

    await gesture.moveTo(const Offset(500, 500));
    await tester.pump();
    expect(hoverStates.last, isFalse);
  });

  // ── 11. cursor ─────────────────────────────────────────────────────────────

  testWidgets('pointer device: cursor is click when enabled', (tester) async {
    await tester.pumpWidget(
      pointerApp(
        const Center(
          child: OiTappable(
            key: ValueKey('t'),
            child: SizedBox(width: 60, height: 60),
          ),
        ),
      ),
    );
    await tester.pump();

    final mouseRegion = tester.widget<MouseRegion>(
      find.descendant(
        of: find.byKey(const ValueKey('t')),
        matching: find.byType(MouseRegion),
      ),
    );
    expect(mouseRegion.cursor, SystemMouseCursors.click);
  });

  testWidgets('pointer device: cursor is basic when disabled', (tester) async {
    await tester.pumpWidget(
      pointerApp(
        const Center(
          child: OiTappable(
            key: ValueKey('t'),
            enabled: false,
            child: SizedBox(width: 60, height: 60),
          ),
        ),
      ),
    );
    await tester.pump();

    final mouseRegion = tester.widget<MouseRegion>(
      find.descendant(
        of: find.byKey(const ValueKey('t')),
        matching: find.byType(MouseRegion),
      ),
    );
    expect(mouseRegion.cursor, SystemMouseCursors.basic);
  });

  // ── 12. disableAnimations: AnimatedOpacity uses Duration.zero ─────────────

  testWidgets(
    'disableAnimations=true: AnimatedOpacity.duration is Duration.zero',
    (tester) async {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: OiTappable(child: SizedBox(width: 60, height: 60)),
        ),
      );
      await tester.pump();

      final animOpacity =
          tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(animOpacity.duration, Duration.zero);
    },
  );

  // ── 13. Focus ring: DecoratedBox with foreground border when focused ────────

  testWidgets(
    'focus ring: DecoratedBox with foreground border rendered when widget is focused',
    (tester) async {
      await tester.pumpObers(
        const OiTappable(child: SizedBox(width: 60, height: 60)),
      );
      await tester.pump();

      // The GestureDetector is a descendant of the OiTappable-owned Focus
      // widget, so Focus.of() from that element returns the correct node.
      final gestureElement = tester.element(find.byType(GestureDetector));
      Focus.of(gestureElement).requestFocus();
      // Two pumps: first processes the focus-change notification;
      // second applies the setState rebuild.
      await tester.pump();
      await tester.pump();

      final foregroundBoxes = tester.widgetList<DecoratedBox>(
        find.byType(DecoratedBox),
      ).where((b) => b.position == DecorationPosition.foreground);
      expect(foregroundBoxes, isNotEmpty);
    },
  );

  // ── 14. Focus ring enforced: zero-alpha color is clamped to 0.5 ────────────

  test('focus ring enforced: zero-alpha color is clamped to minimum alpha 0.5',
      () {
    const ring = OiFocusRingStyle(
      color: Color(0x00FF0000), // alpha = 0
      width: 2.0,
    );
    final enforced = ring.enforced;
    expect(enforced.color.a, greaterThanOrEqualTo(0.5));
  });

  // ── 15. Focus ring enforced: sub-minimum width is clamped to 2.0 ───────────

  test('focus ring enforced: sub-minimum width is clamped to 2.0', () {
    const ring = OiFocusRingStyle(
      color: Color(0xFFFF0000),
      width: 0.5, // below minimum
    );
    final enforced = ring.enforced;
    expect(enforced.width, 2.0);
  });

  // ── 16. Keyboard activation: Enter triggers onTap ──────────────────────────

  testWidgets('TC-1: Enter key triggers onTap when focused and enabled', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpObers(
      OiTappable(
        onTap: () => tapped = true,
        child: const SizedBox(width: 60, height: 60, child: Text('x')),
      ),
    );
    await tester.pump();

    final gestureElement = tester.element(find.byType(GestureDetector));
    Focus.of(gestureElement).requestFocus();
    await tester.pump();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(tapped, isTrue);
  });

  // ── 17. Keyboard activation: Space triggers onTap ──────────────────────────

  testWidgets('TC-2: Space key triggers onTap when focused and enabled', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpObers(
      OiTappable(
        onTap: () => tapped = true,
        child: const SizedBox(width: 60, height: 60, child: Text('x')),
      ),
    );
    await tester.pump();

    final gestureElement = tester.element(find.byType(GestureDetector));
    Focus.of(gestureElement).requestFocus();
    await tester.pump();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(tapped, isTrue);
  });

  // ── 18. Keyboard activation: Enter suppressed when disabled ────────────────

  testWidgets('TC-3: Enter key does NOT trigger onTap when disabled', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpObers(
      OiTappable(
        enabled: false,
        onTap: () => tapped = true,
        child: const SizedBox(width: 60, height: 60, child: Text('x')),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(tapped, isFalse);
  });

  // ── 19. Keyboard activation: Space suppressed when disabled ────────────────

  testWidgets('TC-4: Space key does NOT trigger onTap when disabled', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpObers(
      OiTappable(
        enabled: false,
        onTap: () => tapped = true,
        child: const SizedBox(width: 60, height: 60, child: Text('x')),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(tapped, isFalse);
  });

  // ── 20. Keyboard activation: other keys do NOT trigger onTap ───────────────

  testWidgets('TC-5: ArrowDown key does NOT trigger onTap', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiTappable(
        onTap: () => tapped = true,
        child: const SizedBox(width: 60, height: 60, child: Text('x')),
      ),
    );
    await tester.pump();

    final gestureElement = tester.element(find.byType(GestureDetector));
    Focus.of(gestureElement).requestFocus();
    await tester.pump();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    expect(tapped, isFalse);
  });
}
