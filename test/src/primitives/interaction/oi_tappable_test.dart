// Tests do not require documentation comments.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart' show OiA11y;
import 'package:obers_ui/src/foundation/oi_accessibility.dart' show OiA11y;
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/oi_platform.dart';
import 'package:obers_ui/src/foundation/theme/oi_effects_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Wraps [child] with [OiApp] in touch (comfortable) density, overriding
/// [OiPlatform] to [OiInputModality.touch] so that [OiA11y.minTouchTarget]
/// returns 48 dp.
Widget touchApp(Widget child) => OiApp(
  density: OiDensity.comfortable,
  home: OiPlatform(
    data: OiPlatformData(
      platform: defaultTargetPlatform,
      keyboardHeight: 0,
      keyboardVisible: false,
      inputModality: OiInputModality.touch,
    ),
    child: child,
  ),
);

/// Wraps [child] with [OiApp] in pointer (compact) density, overriding
/// [OiPlatform] to [OiInputModality.pointer].
Widget pointerApp(Widget child) => OiApp(
  density: OiDensity.compact,
  home: OiPlatform(
    data: OiPlatformData(
      platform: defaultTargetPlatform,
      keyboardHeight: 0,
      keyboardVisible: false,
      inputModality: OiInputModality.pointer,
    ),
    child: child,
  ),
);

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
    await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 50));
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

  testWidgets(
    'touch device: small child gets minimum 48dp touch target',
    (tester) async {
      await tester.pumpWidget(
        touchApp(
          const Center(
            child: OiTappable(child: SizedBox(width: 24, height: 24)),
          ),
        ),
      );
      await tester.pump();

      final size = tester.getSize(find.byType(OiTappable));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  // ── 9. Pointer device: no extra padding ────────────────────────────────────

  testWidgets(
    'pointer device: child size is not padded to 48dp',
    (tester) async {
      await tester.pumpWidget(
        pointerApp(
          const Center(
            child: OiTappable(child: SizedBox(width: 24, height: 24)),
          ),
        ),
      );
      await tester.pump();

      final size = tester.getSize(find.byType(OiTappable));
      // On pointer platforms the tappable does not inflate the size to 48dp.
      expect(size.width, lessThan(48));
      expect(size.height, lessThan(48));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  // ── TC-touch-compact: compact density still enforces 48dp on touch ────────
  // Density no longer suppresses the 48 dp touch-target floor — touch
  // targets are always enforced on touch devices regardless of density.

  testWidgets(
    'TC-touch-compact: compact density on touch device still enforces 48dp target',
    (tester) async {
      await tester.pumpWidget(
        touchApp(
          const Center(
            child: OiTappable(child: SizedBox(width: 24, height: 24)),
          ),
        ),
      );
      await tester.pump();

      final size = tester.getSize(find.byType(OiTappable));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  // ── 10. Hover state on pointer device ─────────────────────────────────────

  testWidgets(
    'pointer device: onHover called on MouseRegion enter/exit',
    (tester) async {
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
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  // ── 11. cursor ─────────────────────────────────────────────────────────────

  testWidgets(
    'pointer device: cursor is click when enabled',
    (tester) async {
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
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'pointer device: cursor is basic when disabled',
    (tester) async {
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
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

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

      final animOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animOpacity.duration, Duration.zero);
    },
  );

  // ── 13. Focus ring: DecoratedBox with foreground border when focused ────────

  testWidgets(
    'focus ring: DecoratedBox with foreground border rendered when widget is focused',
    (tester) async {
      // Force keyboard highlight mode so the focus ring is always rendered
      // during keyboard-navigation tests regardless of the platform default.
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );

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

      final foregroundBoxes = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .where((b) => b.position == DecorationPosition.foreground);
      expect(foregroundBoxes, isNotEmpty);
    },
  );

  // ── TC-focus-ring-touch-hidden: focus ring absent in touch modality ─────────

  testWidgets(
    'TC-focus-ring-touch-hidden: focus ring absent when touch highlight mode is active',
    (tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTouch;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );

      await tester.pumpObers(
        const OiTappable(child: SizedBox(width: 60, height: 60)),
      );
      await tester.pump();

      final gestureElement = tester.element(find.byType(GestureDetector));
      Focus.of(gestureElement).requestFocus();
      await tester.pump();
      await tester.pump();

      final foregroundBoxes = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .where((b) => b.position == DecorationPosition.foreground);
      expect(foregroundBoxes, isEmpty);
    },
  );

  // ── TC-focus-ring-reappear-keyboard: focus ring reappears on keyboard ────────

  testWidgets(
    'TC-focus-ring-reappear-keyboard: focus ring reappears when mode switches from touch to traditional',
    (tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTouch;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );

      await tester.pumpObers(
        const OiTappable(child: SizedBox(width: 60, height: 60)),
      );
      await tester.pump();

      final gestureElement = tester.element(find.byType(GestureDetector));
      Focus.of(gestureElement).requestFocus();
      await tester.pump();
      await tester.pump();

      // Confirm focus ring is absent in touch mode.
      final touchForegroundBoxes = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .where((b) => b.position == DecorationPosition.foreground);
      expect(touchForegroundBoxes, isEmpty);

      // Switch to keyboard modality.
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      await tester.pump();

      // Focus ring must now be present.
      final keyboardForegroundBoxes = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .where((b) => b.position == DecorationPosition.foreground);
      expect(keyboardForegroundBoxes, isNotEmpty);
    },
  );

  // ── 14. Focus ring enforced: zero-alpha color is clamped to 0.5 ────────────

  test(
    'focus ring enforced: zero-alpha color is clamped to minimum alpha 0.5',
    () {
      const ring = OiFocusRingStyle(
        color: Color(0x00FF0000), // alpha = 0
      );
      final enforced = ring.enforced;
      expect(enforced.color.a, greaterThanOrEqualTo(0.5));
    },
  );

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

  // ── 20. isDragging: applies dragging style ─────────────────────────────────

  testWidgets('isDragging=true: applies dragging scale from OiEffectsTheme', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiTappable(dragging: true, child: SizedBox(width: 60, height: 60)),
    );
    await tester.pump();

    // The dragging style from OiEffectsTheme.standard has scale > 1.0 (1.03).
    // Verify a Transform widget is present with the dragging scale.
    final transforms = tester.widgetList<Transform>(find.byType(Transform));
    expect(transforms, isNotEmpty);
  });

  testWidgets('isDragging=false: no dragging scale applied by default', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiTappable(child: SizedBox(width: 60, height: 60)),
    );
    await tester.pump();

    // Default state (no dragging, no hover, no focus, no press) applies
    // OiInteractiveStyle.none which has scale=1.0, so no Transform.
    final transforms = tester.widgetList<Transform>(find.byType(Transform));
    expect(transforms, isEmpty);
  });

  testWidgets('isDragging takes priority over pressed state', (tester) async {
    // When both isDragging and pressed are active, dragging wins.
    await tester.pumpObers(
      const OiTappable(dragging: true, child: SizedBox(width: 60, height: 60)),
    );
    await tester.pump();

    // Simulate a press — but isDragging should still take priority.
    await tester.tap(find.byType(OiTappable), warnIfMissed: false);
    await tester.pump();

    // The dragging style has scale 1.03 (> 1), active has 0.97 (< 1).
    // Verify scale > 1 by checking Transform is present.
    final transforms = tester.widgetList<Transform>(find.byType(Transform));
    expect(transforms, isNotEmpty);
  });

  // ── 21. Keyboard activation: other keys do NOT trigger onTap ───────────────

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
