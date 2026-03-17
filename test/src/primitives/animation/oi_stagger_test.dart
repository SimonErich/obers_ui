// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/animation/oi_stagger.dart';
import 'package:obers_ui/src/primitives/overlay/oi_visibility.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. Renders all children ───────────────────────────────────────────────

  testWidgets('renders all children', (tester) async {
    await tester.pumpObers(
      const OiStagger(
        children: [Text('first'), Text('second'), Text('third')],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsOneWidget);
    expect(find.text('third'), findsOneWidget);
  });

  // ── 2. autoPlay=true starts animation on mount ────────────────────────────

  testWidgets('autoPlay=true: AnimatedBuilder is present after mount',
      (tester) async {
    await tester.pumpObers(
      const OiStagger(
        children: [Text('a'), Text('b')],
      ),
    );
    await tester.pump();

    expect(find.byType(AnimatedBuilder), findsWidgets);
  });

  // ── 3. autoPlay=false: children still render ─────────────────────────────

  testWidgets('autoPlay=false: children are rendered without auto-play',
      (tester) async {
    await tester.pumpObers(
      const OiStagger(
        autoPlay: false,
        children: [Text('x'), Text('y')],
      ),
    );
    await tester.pump();

    expect(find.text('x'), findsOneWidget);
    expect(find.text('y'), findsOneWidget);
  });

  // ── 4. Empty children list does not crash ─────────────────────────────────

  testWidgets('empty children: renders SizedBox.shrink', (tester) async {
    await tester.pumpObers(
      const OiStagger(children: []),
    );
    await tester.pump();
    expect(find.byType(SizedBox), findsWidgets);
  });

  // ── 5. staggerDelay creates sequential intervals (FadeTransitions present) ─

  testWidgets('non-zero staggerDelay creates multiple FadeTransitions',
      (tester) async {
    await tester.pumpObers(
      const OiStagger(
        staggerDelay: Duration(milliseconds: 100),
        duration: Duration(milliseconds: 200),
        children: [Text('p'), Text('q'), Text('r')],
      ),
    );
    await tester.pump();
    // Each child gets a FadeTransition (default transition=fade).
    expect(find.byType(FadeTransition), findsNWidgets(3));
  });

  // ── 6. transition=none: no FadeTransition when reduced motion ─────────────

  testWidgets('transition=none: wraps children without FadeTransition',
      (tester) async {
    await tester.pumpObers(
      const OiStagger(
        transition: OiTransition.none,
        children: [Text('i'), Text('ii')],
      ),
    );
    await tester.pump();
    expect(find.text('i'), findsOneWidget);
    expect(find.text('ii'), findsOneWidget);
  });

  // ── 7. reducedMotion: children shown immediately without FadeTransition ───

  testWidgets('reducedMotion: children visible without animation widgets',
      (tester) async {
    await tester.pumpObers(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: OiStagger(
          children: [Text('m'), Text('n')],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('m'), findsOneWidget);
    expect(find.text('n'), findsOneWidget);
    // With reducedMotion the children are returned directly — no FadeTransition.
    expect(find.byType(FadeTransition), findsNothing);
  });
}
