// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/primitives/overlay/oi_visibility.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. visible=true shows child ────────────────────────────────────────────

  testWidgets('visible=true: child is in the tree and visible', (tester) async {
    await tester.pumpObers(
      const OiVisibility(visible: true, child: Text('hello')),
    );
    await tester.pump();
    expect(find.text('hello'), findsOneWidget);
  });

  // ── 2. visible=false hides child ──────────────────────────────────────────

  testWidgets('visible=false with transition=none: child not rendered', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiVisibility(
        visible: false,
        transition: OiTransition.none,
        child: Text('hidden'),
      ),
    );
    await tester.pump();
    // Visibility widget is used; the child is in tree but not painted.
    final vis = tester.widget<Visibility>(find.byType(Visibility));
    expect(vis.visible, isFalse);
  });

  // ── 3. transition=none just shows/hides ───────────────────────────────────

  testWidgets('transition=none visible=true: no FadeTransition', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiVisibility(
        visible: true,
        transition: OiTransition.none,
        child: Text('hello'),
      ),
    );
    await tester.pump();
    expect(find.byType(FadeTransition), findsNothing);
    expect(find.text('hello'), findsOneWidget);
  });

  // ── 4. transition=fade uses FadeTransition ────────────────────────────────

  testWidgets('transition=fade: FadeTransition is present', (tester) async {
    await tester.pumpObers(
      const OiVisibility(visible: true, child: Text('hello')),
    );
    await tester.pump();
    expect(find.byType(FadeTransition), findsOneWidget);
  });

  // ── 5. transition=fadeScale uses FadeTransition + ScaleTransition ─────────

  testWidgets(
    'transition=fadeScale: FadeTransition and ScaleTransition present',
    (tester) async {
      await tester.pumpObers(
        const OiVisibility(
          visible: true,
          transition: OiTransition.fadeScale,
          child: Text('hello'),
        ),
      );
      await tester.pump();
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(ScaleTransition), findsOneWidget);
    },
  );

  // ── 6. transition=slideUp uses SlideTransition ────────────────────────────

  testWidgets('transition=slideUp: SlideTransition is present', (tester) async {
    await tester.pumpObers(
      const OiVisibility(
        visible: true,
        transition: OiTransition.slideUp,
        child: Text('hello'),
      ),
    );
    await tester.pump();
    expect(find.byType(SlideTransition), findsOneWidget);
  });

  // ── 7. transition=slideDown uses SlideTransition ─────────────────────────

  testWidgets('transition=slideDown: SlideTransition is present', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiVisibility(
        visible: true,
        transition: OiTransition.slideDown,
        child: Text('hello'),
      ),
    );
    await tester.pump();
    expect(find.byType(SlideTransition), findsOneWidget);
  });

  // ── 8. transition=slideLeft uses SlideTransition ─────────────────────────

  testWidgets('transition=slideLeft: SlideTransition is present', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiVisibility(
        visible: true,
        transition: OiTransition.slideLeft,
        child: Text('hello'),
      ),
    );
    await tester.pump();
    expect(find.byType(SlideTransition), findsOneWidget);
  });

  // ── 9. transition=slideRight uses SlideTransition ────────────────────────

  testWidgets('transition=slideRight: SlideTransition is present', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiVisibility(
        visible: true,
        transition: OiTransition.slideRight,
        child: Text('hello'),
      ),
    );
    await tester.pump();
    expect(find.byType(SlideTransition), findsOneWidget);
  });

  // ── 10. maintainState=false removes child when hidden ────────────────────

  testWidgets(
    'maintainState=false transition=none: child removed from tree when hidden',
    (tester) async {
      await tester.pumpObers(
        const OiVisibility(
          visible: false,
          transition: OiTransition.none,
          maintainState: false,
          child: Text('gone'),
        ),
      );
      await tester.pump();
      expect(find.text('gone'), findsNothing);
    },
  );

  testWidgets('maintainState=false: child present when visible=true', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiVisibility(
        visible: true,
        transition: OiTransition.none,
        maintainState: false,
        child: Text('present'),
      ),
    );
    await tester.pump();
    expect(find.text('present'), findsOneWidget);
  });

  // ── 11. Toggling visible shows and hides with animation ───────────────────

  testWidgets('toggling visible=true then false animates', (tester) async {
    final notifier = ValueNotifier<bool>(true);
    addTearDown(notifier.dispose);

    await tester.pumpObers(
      ValueListenableBuilder<bool>(
        valueListenable: notifier,
        builder: (context, isVisible, _) =>
            OiVisibility(visible: isVisible, child: const Text('animated')),
      ),
    );
    await tester.pump();
    expect(find.text('animated'), findsOneWidget);

    // Hide via notifier (no hit-test issues).
    notifier.value = false;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Show again.
    notifier.value = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('animated'), findsOneWidget);
  });

  // ── 12. reducedMotion: transition completes instantly ────────────────────

  testWidgets(
    'reducedMotion: toggling visible uses Duration.zero — no mid-flight opacity',
    (tester) async {
      final notifier = ValueNotifier<bool>(false);
      addTearDown(notifier.dispose);

      await tester.pumpObers(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: ValueListenableBuilder<bool>(
            valueListenable: notifier,
            builder: (_, isVisible, _) =>
                OiVisibility(visible: isVisible, child: const Text('instant')),
          ),
        ),
      );
      await tester.pump();

      // Make visible — with Duration.zero the controller jumps to 1.0.
      notifier.value = true;
      await tester.pump();

      final fade = tester.widget<FadeTransition>(find.byType(FadeTransition));
      expect(fade.opacity.value, 1.0);
    },
  );

  // ── 13. Responsive constructor uses different transitions per breakpoint ──

  testWidgets(
    'OiVisibility.responsive on compact: uses compactTransition (slideUp)',
    (tester) async {
      // Zero magic: breakpoint is passed explicitly — no context lookup.
      await tester.pumpObers(
        const OiVisibility.responsive(
          visible: true,
          breakpoint: OiBreakpoint.compact,
          child: Text('responsive'),
        ),
      );
      await tester.pump();
      // On compact we expect a SlideTransition (from slideUp).
      expect(find.byType(SlideTransition), findsOneWidget);
    },
  );

  testWidgets(
    'OiVisibility.responsive on expanded: uses expandedTransition (fade)',
    (tester) async {
      // Zero magic: breakpoint is passed explicitly — no context lookup.
      await tester.pumpObers(
        const OiVisibility.responsive(
          visible: true,
          breakpoint: OiBreakpoint.expanded,
          child: Text('responsive'),
        ),
      );
      await tester.pump();
      // On expanded we expect only a FadeTransition (no SlideTransition).
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(SlideTransition), findsNothing);
    },
  );

  // ── Hidden children are inert, and maintainState is honoured ──────────────

  group('hidden child', () {
    testWidgets('fade + maintainState: does not receive taps', (tester) async {
      var taps = 0;
      await tester.pumpObers(
        Center(
          child: OiVisibility(
            visible: false,
            child: GestureDetector(
              onTap: () => taps++,
              child: const SizedBox(
                key: Key('target'),
                width: 100,
                height: 100,
                child: ColoredBox(color: Color(0xFF000000)),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('target')), warnIfMissed: false);
      await tester.pump();

      expect(taps, 0);
    });

    testWidgets('fade + maintainState: cannot take focus', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpObers(
        OiVisibility(
          visible: false,
          child: Focus(focusNode: node, child: const SizedBox(height: 10)),
        ),
      );
      await tester.pumpAndSettle();

      node.requestFocus();
      await tester.pump();

      expect(node.hasFocus, isFalse);
    });

    testWidgets('fade + maintainState: is not announced while fading out', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      Widget build({required bool visible}) => OiVisibility(
        visible: visible,
        child: const Text('Secret'),
      );
      await tester.pumpObers(build(visible: true));
      await tester.pumpAndSettle();
      expect(find.semantics.byLabel('Secret'), findsOne);

      // Halfway through the fade the child is still painted, but it is
      // already hidden and must not be read out.
      await tester.pumpObers(build(visible: false));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.semantics.byLabel('Secret'), findsNothing);

      await tester.pumpAndSettle();
      expect(find.semantics.byLabel('Secret'), findsNothing);
      semantics.dispose();
    });

    testWidgets('becomes interactive again when shown', (tester) async {
      var taps = 0;
      Widget build({required bool visible}) => Center(
        child: OiVisibility(
          visible: visible,
          child: GestureDetector(
            onTap: () => taps++,
            child: const SizedBox(
              key: Key('target'),
              width: 100,
              height: 100,
              child: ColoredBox(color: Color(0xFF000000)),
            ),
          ),
        ),
      );
      await tester.pumpObers(build(visible: false));
      await tester.pumpAndSettle();
      await tester.pumpObers(build(visible: true));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('target')));

      expect(taps, 1);
    });

    for (final transition in [OiTransition.none, OiTransition.fade]) {
      testWidgets('${transition.name} + maintainState keeps the child State', (
        tester,
      ) async {
        var inits = 0;
        Widget build({required bool visible}) => OiVisibility(
          visible: visible,
          transition: transition,
          child: _InitCounter(onInit: () => inits++),
        );

        await tester.pumpObers(build(visible: true));
        await tester.pumpObers(build(visible: false));
        await tester.pumpAndSettle();
        await tester.pumpObers(build(visible: true));
        await tester.pumpAndSettle();

        expect(inits, 1);
      });
    }

    testWidgets('none + maintainState=false still drops the child State', (
      tester,
    ) async {
      var inits = 0;
      Widget build({required bool visible}) => OiVisibility(
        visible: visible,
        transition: OiTransition.none,
        maintainState: false,
        child: _InitCounter(onInit: () => inits++),
      );

      await tester.pumpObers(build(visible: true));
      await tester.pumpObers(build(visible: false));
      await tester.pumpObers(build(visible: true));

      expect(inits, 2);
    });

    testWidgets('none + maintainState: hidden child takes no space or taps', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpObers(
        Center(
          child: OiVisibility(
            visible: false,
            transition: OiTransition.none,
            child: GestureDetector(
              onTap: () => taps++,
              child: const SizedBox(
                key: Key('target'),
                width: 100,
                height: 100,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('target')), findsNothing);
      expect(
        find.byKey(const Key('target'), skipOffstage: false),
        findsOneWidget,
      );
      expect(tester.getSize(find.byType(OiVisibility)), Size.zero);
      expect(taps, 0);
    });
  });
}

class _InitCounter extends StatefulWidget {
  const _InitCounter({required this.onInit});

  final VoidCallback onInit;

  @override
  State<_InitCounter> createState() => _InitCounterState();
}

class _InitCounterState extends State<_InitCounter> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) => const SizedBox(width: 10, height: 10);
}
