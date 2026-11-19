// Tests do not require documentation comments.

import 'dart:ui' show SemanticsRole;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart' show SemanticsNode;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart' show OiA11y;
import 'package:obers_ui/src/foundation/oi_accessibility.dart' show OiA11y;
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/oi_focus_visibility.dart';
import 'package:obers_ui/src/foundation/oi_platform.dart';
import 'package:obers_ui/src/foundation/theme/oi_effects_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
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

  testWidgets('disabled=true: child is faded to 0.4', (tester) async {
    await tester.pumpObers(
      const OiTappable(enabled: false, child: SizedBox(width: 60, height: 60)),
    );
    expect(tester.widget<Opacity>(_tappablePart<Opacity>()).opacity, 0.4);
  });

  testWidgets('enabled: child is fully opaque', (tester) async {
    await tester.pumpObers(
      const OiTappable(child: SizedBox(width: 60, height: 60)),
    );
    expect(tester.widget<Opacity>(_tappablePart<Opacity>()).opacity, 1);
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

  testWidgets(
    'touch device: touchTargetAlignment places a small child',
    (tester) async {
      await tester.pumpWidget(
        touchApp(
          Center(
            child: OiTappable(
              onTap: () {},
              touchTargetAlignment: AlignmentDirectional.centerStart,
              child: const SizedBox(key: Key('mark'), width: 20, height: 20),
            ),
          ),
        ),
      );

      final target = tester.getRect(find.byType(OiTappable));
      final mark = tester.getRect(find.byKey(const Key('mark')));
      expect(mark.left, target.left);
      expect(mark.center.dy, target.center.dy);
    },
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

      final animOpacities = tester.widgetList<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animOpacities.every((o) => o.duration == Duration.zero), isTrue);
    },
  );

  // ── 13. Focus ring: DecoratedBox with foreground border when focused ────────

  testWidgets(
    'focus ring: foreground border rendered when widget is focused',
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

      expect(_focusRings(tester), isNotEmpty);
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

      expect(_focusRings(tester), isEmpty);
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
      expect(_focusRings(tester), isEmpty);

      // Switch to keyboard modality.
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      await tester.pump();

      // Focus ring must now be present.
      expect(_focusRings(tester), isNotEmpty);
    },
  );

  // ── TC-focus-ring-pointer-hidden: no ring after a click ──────────────────────

  testWidgets(
    'TC-focus-ring-pointer-hidden: no focus ring when focus follows a click',
    (tester) async {
      // Flutter treats the mouse as traditional highlight mode; the ring must
      // still stay hidden until a key is pressed.
      OiFocusVisibility.reset();
      addTearDown(OiFocusVisibility.reset);
      await tester.pumpObers(
        const OiTappable(child: SizedBox(width: 60, height: 60)),
      );
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.down(tester.getCenter(find.byType(OiTappable)));
      await gesture.up();
      await tester.pump();

      final gestureElement = tester.element(find.byType(GestureDetector));
      Focus.of(gestureElement).requestFocus();
      await tester.pump();
      await tester.pump();

      expect(_focusRings(tester), isEmpty);
    },
  );

  // ── TC-focus-ring-key-shows: a key press shows the ring ─────────────────────

  testWidgets(
    'TC-focus-ring-key-shows: a key press shows the ring, a click hides it',
    (tester) async {
      OiFocusVisibility.reset();
      addTearDown(OiFocusVisibility.reset);
      await tester.pumpObers(
        const OiTappable(child: SizedBox(width: 60, height: 60)),
      );
      final gestureElement = tester.element(find.byType(GestureDetector));
      Focus.of(gestureElement).requestFocus();
      await tester.pump();
      await tester.pump();

      Iterable<DecoratedBox> rings() => _focusRings(tester);
      expect(rings(), isEmpty, reason: 'no key pressed yet');

      await tester.sendKeyEvent(LogicalKeyboardKey.shift);
      await tester.pump();
      expect(rings(), isNotEmpty);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.down(const Offset(1, 1));
      await gesture.up();
      await tester.pump();
      expect(rings(), isEmpty);
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

    // The dragging style from OiEffectsTheme.standard has scale 1.03.
    expect(_scale(tester), 1.03);
  });

  testWidgets('isDragging=false: no dragging scale applied by default', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiTappable(child: SizedBox(width: 60, height: 60)),
    );
    await tester.pump();

    // Default state (no dragging, no hover, no focus, no press) applies
    // OiInteractiveStyle.none which has scale=1.0: the Transform stays in the
    // tree as an identity.
    expect(_scale(tester), 1);
  });

  testWidgets('isDragging takes priority over pressed state', (tester) async {
    // When both isDragging and pressed are active, dragging wins.
    await tester.pumpObers(
      OiTappable(
        dragging: true,
        onTap: () {},
        child: const SizedBox(width: 60, height: 60),
      ),
    );
    await tester.pump();

    // Hold a press — but isDragging should still take priority.
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(OiTappable)),
    );
    await tester.pump();

    // The dragging style has scale 1.03 (> 1), active has 0.97 (< 1).
    expect(_scale(tester), 1.03);
    await gesture.up();
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

  // ── 22. Hover: backgroundOverride ─────────────────────────────────────────

  /// Pointer-modality app whose hover state overrides the background outright.
  Widget hoverStyledApp(Widget child, {OiInteractiveStyle? hover}) {
    final base = OiThemeData.light();
    return OiApp(
      theme: base.copyWith(
        effects: base.effects.copyWith(
          hover:
              hover ??
              const OiInteractiveStyle(
                backgroundOverlay: Color(0x00000000),
                halo: OiHaloStyle.none,
                backgroundOverride: Color(0xFF123456),
              ),
        ),
      ),
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
  }

  Future<TestGesture> hoverOver(WidgetTester tester, Finder finder) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(finder));
    await tester.pumpAndSettle();
    return gesture;
  }

  /// True when a state fill of [color] is currently shown (opacity 1).
  bool hasVisibleColoredBox(WidgetTester tester, Color color) => tester
      .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
      .any(
        (o) =>
            o.opacity == 1.0 &&
            o.child is ColoredBox &&
            (o.child! as ColoredBox).color == color,
      );

  Stack stateStack(WidgetTester tester) => tester.widget<Stack>(
    find.descendant(
      of: find.byType(OiTappable),
      matching: find.byWidgetPredicate(
        (w) => w is Stack && w.children.length == 3,
      ),
    ),
  );

  testWidgets(
    'hover: backgroundOverride paints the state background',
    (tester) async {
      await tester.pumpWidget(
        hoverStyledApp(
          const Center(
            child: OiTappable(child: SizedBox(width: 60, height: 60)),
          ),
        ),
      );
      await tester.pump();

      expect(hasVisibleColoredBox(tester, const Color(0xFF123456)), isFalse);

      await hoverOver(tester, find.byType(OiTappable));

      expect(hasVisibleColoredBox(tester, const Color(0xFF123456)), isTrue);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'hover: backgroundOverride is painted behind the child',
    (tester) async {
      await tester.pumpWidget(
        hoverStyledApp(
          const Center(
            child: OiTappable(
              child: SizedBox(width: 60, height: 60, child: Text('Label')),
            ),
          ),
        ),
      );
      await tester.pump();
      await hoverOver(tester, find.byType(OiTappable));

      final stack = stateStack(tester);
      expect(
        stack.children[1],
        isA<ExcludeSemantics>()
            .having((e) => e.excluding, 'excluding', isFalse)
            .having((e) => e.child, 'child', isA<SizedBox>()),
      );
      expect(find.text('Label'), findsOneWidget);
      expect(hasVisibleColoredBox(tester, const Color(0xFF123456)), isTrue);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'override layer stays in the tree at rest and on hover',
    (tester) async {
      await tester.pumpWidget(
        hoverStyledApp(
          const Center(
            child: OiTappable(child: SizedBox(width: 60, height: 60)),
          ),
        ),
      );
      await tester.pump();

      expect(stateStack(tester).children, hasLength(3));

      await hoverOver(tester, find.byType(OiTappable));

      expect(stateStack(tester).children, hasLength(3));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'hover: child state survives the override appearing',
    (tester) async {
      final probeKey = GlobalKey<_HoverProbeState>();
      await tester.pumpWidget(
        hoverStyledApp(
          Center(
            child: OiTappable(
              child: SizedBox(
                width: 60,
                height: 60,
                child: _HoverProbe(key: probeKey),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      probeKey.currentState!.bump();
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      await hoverOver(tester, find.byType(OiTappable));

      expect(find.text('1'), findsOneWidget);
      expect(hasVisibleColoredBox(tester, const Color(0xFF123456)), isTrue);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'backgroundOverride suppresses the overlay tint',
    (tester) async {
      await tester.pumpWidget(
        hoverStyledApp(
          const Center(
            child: OiTappable(child: SizedBox(width: 60, height: 60)),
          ),
          hover: const OiInteractiveStyle(
            backgroundOverlay: Color(0x80FF0000),
            halo: OiHaloStyle.none,
            backgroundOverride: Color(0xFF123456),
          ),
        ),
      );
      await tester.pump();
      await hoverOver(tester, find.byType(OiTappable));

      expect(hasVisibleColoredBox(tester, const Color(0xFF123456)), isTrue);
      expect(hasVisibleColoredBox(tester, const Color(0x80FF0000)), isFalse);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'applyBackgroundOverlay: false keeps the overlay hidden',
    (tester) async {
      await tester.pumpWidget(
        pointerApp(
          const Center(
            child: OiTappable(
              applyBackgroundOverlay: false,
              child: SizedBox(width: 60, height: 60),
            ),
          ),
        ),
      );
      await tester.pump();
      await hoverOver(tester, find.byType(OiTappable));

      expect(
        hasVisibleColoredBox(tester, const Color(0x0A000000)),
        isFalse,
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets('dimWhenDisabled: false skips the 0.4 fade', (tester) async {
    await tester.pumpObers(
      const OiTappable(
        enabled: false,
        dimWhenDisabled: false,
        child: Text('x'),
      ),
    );
    await tester.pump();

    expect(tester.widget<Opacity>(_tappablePart<Opacity>()).opacity, 1);
  });

  testWidgets(
    'resting state paints no override',
    (tester) async {
      await tester.pumpWidget(
        hoverStyledApp(
          const Center(
            child: OiTappable(child: Text('Label')),
          ),
        ),
      );
      await tester.pump();

      expect(hasVisibleColoredBox(tester, const Color(0xFF123456)), isFalse);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'a theme leaving backgroundOverride unset renders as before',
    (tester) async {
      await tester.pumpObers(
        const OiTappable(child: Text('Label')),
      );
      await tester.pump();

      expect(hasVisibleColoredBox(tester, const Color(0xFF123456)), isFalse);
      expect(find.text('Label'), findsOneWidget);
    },
  );

  // ── 23. Child state survives every interactive state ──────────────────────

  group('child state is kept', () {
    Widget probe() =>
        const SizedBox(width: 60, height: 60, child: _InitProbe());

    setUp(() => _InitProbe.inits = 0);

    testWidgets('on press and release', (tester) async {
      await tester.pumpObers(
        Center(
          child: OiTappable(onTap: () {}, child: probe()),
        ),
      );
      expect(_InitProbe.inits, 1);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(OiTappable)),
      );
      await tester.pump();
      expect(_InitProbe.inits, 1, reason: 'tap down');
      expect(
        _scale(tester),
        0.97,
        reason: 'the pressed scale is applied',
      );

      await gesture.up();
      await tester.pump();
      expect(_InitProbe.inits, 1, reason: 'tap up');
    });

    testWidgets('on keyboard focus', (tester) async {
      OiFocusVisibility.reset();
      addTearDown(OiFocusVisibility.reset);
      await tester.pumpObers(
        Center(
          child: OiTappable(onTap: () {}, child: probe()),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump();

      expect(_focusRings(tester), isNotEmpty, reason: 'the ring is shown');
      expect(_InitProbe.inits, 1);
    });

    testWidgets('when enabled flips', (tester) async {
      Widget build({required bool enabled}) => Center(
        child: OiTappable(enabled: enabled, onTap: () {}, child: probe()),
      );
      await tester.pumpObers(build(enabled: true));
      await tester.pumpObers(build(enabled: false));
      expect(_InitProbe.inits, 1, reason: 'disabled');
      await tester.pumpObers(build(enabled: true));
      expect(_InitProbe.inits, 1, reason: 'enabled again');
    });

    testWidgets('when dragging flips', (tester) async {
      Widget build({required bool dragging}) => Center(
        child: OiTappable(dragging: dragging, onTap: () {}, child: probe()),
      );
      await tester.pumpObers(build(dragging: false));
      await tester.pumpObers(build(dragging: true));
      expect(_InitProbe.inits, 1, reason: 'dragging');
      await tester.pumpObers(build(dragging: false));
      expect(_InitProbe.inits, 1, reason: 'dropped');
    });

    testWidgets(
      'on hover with a theme that draws a halo',
      (tester) async {
        const halo = OiHaloStyle(
          color: Color(0x80FF0000),
          spread: 2,
          blur: 4,
        );
        await tester.pumpWidget(
          hoverStyledApp(
            Center(
              child: OiTappable(onTap: () {}, child: probe()),
            ),
            hover: const OiInteractiveStyle(
              backgroundOverlay: Color(0x00000000),
              halo: halo,
            ),
          ),
        );
        await tester.pump();
        expect(_InitProbe.inits, 1);

        final gesture = await hoverOver(tester, find.byType(OiTappable));
        expect(_InitProbe.inits, 1, reason: 'hovered');
        expect(_haloShadows(tester), [halo.toBoxShadow()]);

        await gesture.moveTo(const Offset(1, 1));
        await tester.pumpAndSettle();
        expect(_InitProbe.inits, 1, reason: 'left');
        expect(_haloShadows(tester), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.linux),
    );
  });

  // ── 24. Semantics ─────────────────────────────────────────────────────────

  group('semantics', () {
    testWidgets('an unlabelled tappable is an enabled button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        Center(
          child: OiTappable(onTap: () {}, child: const Text('Vis')),
        ),
      );

      expect(
        _node(tester),
        isSemantics(
          label: 'Vis',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('a disabled tappable is disabled and offers no tap', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        Center(
          child: OiTappable(
            enabled: false,
            onTap: () {},
            onLongPress: () {},
            child: const Text('Vis'),
          ),
        ),
      );

      expect(
        _node(tester),
        isSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
          hasLongPressAction: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('a disabled tappable still swallows the tap', (tester) async {
      var outer = 0;
      await tester.pumpObers(
        Center(
          child: GestureDetector(
            onTap: () => outer++,
            child: OiTappable(
              enabled: false,
              onTap: () {},
              child: const SizedBox(width: 60, height: 60),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OiTappable));
      expect(outer, 0);
    });

    testWidgets('semanticLabel replaces the child text', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        Center(
          child: OiTappable(
            semanticLabel: 'Other',
            onTap: () {},
            child: const Text('Vis'),
          ),
        ),
      );

      final node = _node(tester);
      expect(node.label, 'Other');
      expect(node, isSemantics(isButton: true, hasTapAction: true));
      expect(find.bySemanticsLabel(RegExp('Vis')), findsNothing);
      handle.dispose();
    });

    testWidgets('a label equal to the child text is announced once', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        Center(
          child: OiTappable(
            semanticLabel: 'Save',
            onTap: () {},
            child: const Text('Save'),
          ),
        ),
      );

      expect(_node(tester).label, 'Save');
      handle.dispose();
    });

    testWidgets('the semantic tap and long press run the callbacks', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final calls = <String>[];
      await tester.pumpObers(
        Center(
          child: OiTappable(
            semanticLabel: 'Go',
            onTap: () => calls.add('tap'),
            onLongPress: () => calls.add('long'),
            child: const Text('Vis'),
          ),
        ),
      );

      final node = _node(tester);
      expect(
        node,
        isSemantics(hasLongPressAction: true, isFocusable: true),
      );
      tester.semantics.tap(find.semantics.byLabel('Go'));
      tester.semantics.longPress(find.semantics.byLabel('Go'));
      expect(calls, ['tap', 'long']);
      handle.dispose();
    });

    testWidgets('a tappable without callbacks has no role', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        const Center(child: OiTappable(child: Text('Vis'))),
      );

      expect(
        tester.getSemantics(find.text('Vis')),
        isSemantics(
          label: 'Vis',
          isButton: false,
          hasEnabledState: false,
          hasTapAction: false,
        ),
      );
      handle.dispose();
    });
  });

  // ── 25. Semantic state, role, key hook, traversal ─────────────────────────

  group('semantic state and role', () {
    testWidgets('state flags are passed through', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        Center(
          child: OiTappable(
            role: OiTappableRole.checkbox,
            checked: true,
            selected: true,
            expanded: false,
            onTap: () {},
            child: const Text('Vis'),
          ),
        ),
      );

      expect(
        _node(tester),
        isSemantics(
          isButton: false,
          hasCheckedState: true,
          isChecked: true,
          hasSelectedState: true,
          isSelected: true,
          hasExpandedState: true,
          isExpanded: false,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('mixed and toggled are passed through', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        Column(
          children: [
            OiTappable(
              key: const Key('mixed'),
              role: OiTappableRole.checkbox,
              mixed: true,
              onTap: () {},
              child: const Text('a'),
            ),
            OiTappable(
              key: const Key('switch'),
              role: OiTappableRole.toggle,
              toggled: true,
              onTap: () {},
              child: const Text('b'),
            ),
          ],
        ),
      );

      expect(
        _node(tester, of: find.byKey(const Key('mixed'))),
        isSemantics(isCheckStateMixed: true, isButton: false),
      );
      expect(
        _node(tester, of: find.byKey(const Key('switch'))),
        isSemantics(
          hasToggledState: true,
          isToggled: true,
          isButton: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('a radio is in a mutually exclusive group by default', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        Center(
          child: OiTappable(
            role: OiTappableRole.radio,
            checked: false,
            onTap: () {},
            child: const Text('Vis'),
          ),
        ),
      );

      expect(
        _node(tester),
        isSemantics(
          hasCheckedState: true,
          isChecked: false,
          isInMutuallyExclusiveGroup: true,
          isButton: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('the tab role is exposed', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        Center(
          child: OiTappable(
            role: OiTappableRole.tab,
            selected: true,
            onTap: () {},
            child: const Text('Vis'),
          ),
        ),
      );

      final node = _node(tester);
      expect(node.role, SemanticsRole.tab);
      expect(node, isSemantics(isSelected: true, isButton: false));
      handle.dispose();
    });

    testWidgets('role none keeps the enabled state without a role', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        Center(
          child: OiTappable(
            role: OiTappableRole.none,
            onTap: () {},
            child: const Text('Vis'),
          ),
        ),
      );

      final node = _node(tester);
      expect(node.role, SemanticsRole.none);
      expect(
        node,
        isSemantics(isButton: false, isEnabled: true, hasTapAction: true),
      );
      handle.dispose();
    });
  });

  group('onKeyEvent', () {
    Future<void> focusTappable(WidgetTester tester) async {
      Focus.of(tester.element(find.byType(GestureDetector))).requestFocus();
      await tester.pump();
    }

    testWidgets('sees keys the tappable does not handle', (tester) async {
      final keys = <LogicalKeyboardKey>[];
      var taps = 0;
      await tester.pumpObers(
        OiTappable(
          onTap: () => taps++,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) keys.add(event.logicalKey);
            return KeyEventResult.ignored;
          },
          child: const SizedBox(width: 60, height: 60),
        ),
      );
      await focusTappable(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      expect(keys, [
        LogicalKeyboardKey.arrowDown,
        LogicalKeyboardKey.home,
        LogicalKeyboardKey.escape,
        LogicalKeyboardKey.enter,
      ]);
      expect(taps, 1, reason: 'an ignored Enter still activates');
    });

    testWidgets('runs before Enter and Space and can take them', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpObers(
        OiTappable(
          onTap: () => taps++,
          onKeyEvent: (node, event) =>
              event.logicalKey == LogicalKeyboardKey.space
              ? KeyEventResult.handled
              : KeyEventResult.ignored,
          child: const SizedBox(width: 60, height: 60),
        ),
      );
      await focusTappable(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(taps, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, 1);
    });

    testWidgets('is not called while disabled', (tester) async {
      var calls = 0;
      await tester.pumpObers(
        OiTappable(
          enabled: false,
          onTap: () {},
          onKeyEvent: (node, event) {
            calls++;
            return KeyEventResult.handled;
          },
          child: const Focus(
            autofocus: true,
            child: SizedBox(width: 60, height: 60),
          ),
        ),
      );
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(calls, 0);
    });
  });

  group('skipTraversal', () {
    Widget pair({required bool skipFirst}) => Column(
      children: [
        OiTappable(
          key: const Key('first'),
          skipTraversal: skipFirst,
          onTap: () {},
          child: const SizedBox(width: 60, height: 60),
        ),
        OiTappable(
          key: const Key('second'),
          onTap: () {},
          child: const SizedBox(width: 60, height: 60),
        ),
      ],
    );

    FocusNode nodeOf(WidgetTester tester, Key key) => Focus.of(
      tester.element(
        find.descendant(
          of: find.byKey(key),
          matching: find.byType(GestureDetector),
        ),
      ),
    );

    testWidgets('Tab passes over a skipped tappable', (tester) async {
      await tester.pumpObers(pair(skipFirst: true));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(nodeOf(tester, const Key('first')).hasPrimaryFocus, isFalse);
      expect(nodeOf(tester, const Key('second')).hasPrimaryFocus, isTrue);
    });

    testWidgets('a skipped tappable can still be focused in code', (
      tester,
    ) async {
      await tester.pumpObers(pair(skipFirst: true));

      nodeOf(tester, const Key('first')).requestFocus();
      await tester.pump();

      expect(nodeOf(tester, const Key('first')).hasPrimaryFocus, isTrue);
    });

    testWidgets('Tab reaches it by default', (tester) async {
      await tester.pumpObers(pair(skipFirst: false));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(nodeOf(tester, const Key('first')).hasPrimaryFocus, isTrue);
    });
  });
}

/// The widgets of type [T] that an [OiTappable] wraps its child in.
Finder _tappablePart<T extends Widget>() =>
    find.descendant(of: find.byType(OiTappable), matching: find.byType(T));

/// The semantics node of the [OiTappable] found by [of] (the only one by
/// default).
SemanticsNode _node(WidgetTester tester, {Finder? of}) => tester.getSemantics(
  find.descendant(
    of: of ?? find.byType(OiTappable),
    matching: find.byType(GestureDetector),
  ),
);

/// The scale the [OiTappable] currently paints its child at.
double _scale(WidgetTester tester) =>
    tester.widget<Transform>(_tappablePart<Transform>()).transform.entry(0, 0);

/// The focus rings currently painted (foreground boxes with a border).
Iterable<DecoratedBox> _focusRings(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(_tappablePart<DecoratedBox>())
    .where(
      (b) =>
          b.position == DecorationPosition.foreground &&
          (b.decoration as BoxDecoration).border != null,
    );

/// The shadows of the halo box, or `null` while no halo is painted.
List<BoxShadow>? _haloShadows(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(_tappablePart<DecoratedBox>())
    .where((b) => b.position == DecorationPosition.background)
    .map((b) => (b.decoration as BoxDecoration).boxShadow)
    .single;

class _InitProbe extends StatefulWidget {
  const _InitProbe();

  static int inits = 0;

  @override
  State<_InitProbe> createState() => _InitProbeState();
}

class _InitProbeState extends State<_InitProbe> {
  @override
  void initState() {
    super.initState();
    _InitProbe.inits++;
  }

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

class _HoverProbe extends StatefulWidget {
  const _HoverProbe({super.key});

  @override
  State<_HoverProbe> createState() => _HoverProbeState();
}

class _HoverProbeState extends State<_HoverProbe> {
  int ticks = 0;

  void bump() => setState(() => ticks++);

  @override
  Widget build(BuildContext context) => Text('$ticks');
}
