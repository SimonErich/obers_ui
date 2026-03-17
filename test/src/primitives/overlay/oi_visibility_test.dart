// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/overlay/oi_visibility.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. visible=true shows child ────────────────────────────────────────────

  testWidgets('visible=true: child is in the tree and visible', (tester) async {
    await tester.pumpObers(
      const OiVisibility(
        visible: true,
        child: Text('hello'),
      ),
    );
    await tester.pump();
    expect(find.text('hello'), findsOneWidget);
  });

  // ── 2. visible=false hides child ──────────────────────────────────────────

  testWidgets('visible=false with transition=none: child not rendered',
      (tester) async {
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

  testWidgets('transition=none visible=true: no FadeTransition', (tester) async {
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
      const OiVisibility(
        visible: true,
        child: Text('hello'),
      ),
    );
    await tester.pump();
    expect(find.byType(FadeTransition), findsOneWidget);
  });

  // ── 5. transition=fadeScale uses FadeTransition + ScaleTransition ─────────

  testWidgets('transition=fadeScale: FadeTransition and ScaleTransition present',
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
  });

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

  testWidgets('transition=slideDown: SlideTransition is present',
      (tester) async {
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

  testWidgets('transition=slideLeft: SlideTransition is present',
      (tester) async {
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

  testWidgets('transition=slideRight: SlideTransition is present',
      (tester) async {
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
  });

  testWidgets('maintainState=false: child present when visible=true',
      (tester) async {
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
        builder: (context, isVisible, _) => OiVisibility(
          visible: isVisible,
          child: const Text('animated'),
        ),
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

  // ── 12. Responsive constructor uses different transitions per breakpoint ──

  testWidgets(
      'OiVisibility.responsive on compact: uses compactTransition (slideUp)',
      (tester) async {
    // Inject a compact-width MediaQuery directly so context.isCompact = true.
    await tester.pumpObers(
      const MediaQuery(
        data: MediaQueryData(size: Size(400, 800)),
        child: OiVisibility.responsive(
          visible: true,
          child: Text('responsive'),
        ),
      ),
    );
    await tester.pump();
    // On compact we expect a SlideTransition (from slideUp).
    expect(find.byType(SlideTransition), findsOneWidget);
  });

  testWidgets(
      'OiVisibility.responsive on expanded: uses expandedTransition (fade)',
      (tester) async {
    // Inject an expanded-width MediaQuery directly so context.isCompact = false.
    await tester.pumpObers(
      const MediaQuery(
        data: MediaQueryData(size: Size(900, 800)),
        child: OiVisibility.responsive(
          visible: true,
          child: Text('responsive'),
        ),
      ),
    );
    await tester.pump();
    // On expanded we expect only a FadeTransition (no SlideTransition).
    expect(find.byType(FadeTransition), findsOneWidget);
    expect(find.byType(SlideTransition), findsNothing);
  });
}
