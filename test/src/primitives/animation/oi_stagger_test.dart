// Tests do not require documentation comments.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/animation/oi_stagger.dart';
import 'package:obers_ui/src/primitives/overlay/oi_visibility.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. Renders all children ───────────────────────────────────────────────

  testWidgets('renders all children', (tester) async {
    await tester.pumpObers(
      const OiStagger(children: [Text('first'), Text('second'), Text('third')]),
    );
    await tester.pumpAndSettle();

    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsOneWidget);
    expect(find.text('third'), findsOneWidget);
  });

  // ── 2. autoPlay=true starts animation on mount ────────────────────────────

  testWidgets('autoPlay=true: AnimatedBuilder is present after mount', (
    tester,
  ) async {
    await tester.pumpObers(const OiStagger(children: [Text('a'), Text('b')]));
    await tester.pump();

    expect(find.byType(AnimatedBuilder), findsWidgets);
  });

  // ── 3. autoPlay=false: children still render ─────────────────────────────

  testWidgets('autoPlay=false: children are rendered without auto-play', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiStagger(autoPlay: false, children: [Text('x'), Text('y')]),
    );
    await tester.pump();

    expect(find.text('x'), findsOneWidget);
    expect(find.text('y'), findsOneWidget);
  });

  // ── 4. Empty children list does not crash ─────────────────────────────────

  testWidgets('empty children: renders SizedBox.shrink', (tester) async {
    await tester.pumpObers(const OiStagger(children: []));
    await tester.pump();
    expect(find.byType(SizedBox), findsWidgets);
  });

  // ── 5. staggerDelay creates sequential intervals (FadeTransitions present) ─

  testWidgets('non-zero staggerDelay creates multiple FadeTransitions', (
    tester,
  ) async {
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

  testWidgets('transition=none: wraps children without FadeTransition', (
    tester,
  ) async {
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

  testWidgets('reducedMotion: children visible without animation widgets', (
    tester,
  ) async {
    await tester.pumpObers(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: OiStagger(children: [Text('m'), Text('n')]),
      ),
    );
    await tester.pump();

    expect(find.text('m'), findsOneWidget);
    expect(find.text('n'), findsOneWidget);
    // With reducedMotion the children are returned directly — no FadeTransition.
    expect(find.byType(FadeTransition), findsNothing);
  });

  // ── Leak tracking: one CurvedAnimation per child, all disposed ────────────

  group('interval animations', () {
    late int created;
    late int disposed;

    void track(ObjectEvent event) {
      if (event.object is! CurvedAnimation) return;
      if (event is ObjectCreated) created++;
      if (event is ObjectDisposed) disposed++;
    }

    setUp(() {
      created = 0;
      disposed = 0;
      FlutterMemoryAllocations.instance.addListener(track);
    });

    tearDown(() => FlutterMemoryAllocations.instance.removeListener(track));

    testWidgets('are created once per child, not once per frame', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiStagger(children: [Text('a'), Text('b'), Text('c')]),
      );
      for (var frame = 0; frame < 10; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(created, 3);

      await tester.pumpAndSettle();
      await tester.pumpObers(const SizedBox.shrink());

      expect(created, 3);
      expect(disposed, 3, reason: 'every interval is disposed on unmount');
    });

    testWidgets('are rebuilt and the old ones disposed when children change', (
      tester,
    ) async {
      await tester.pumpObers(const OiStagger(children: [Text('a'), Text('b')]));
      await tester.pumpAndSettle();
      expect(created, 2);

      await tester.pumpObers(
        const OiStagger(children: [Text('a'), Text('b'), Text('c')]),
      );
      await tester.pumpAndSettle();

      expect(created, 5);
      expect(disposed, 2);
      expect(find.text('c'), findsOneWidget);

      await tester.pumpObers(const SizedBox.shrink());
      expect(disposed, 5);
    });
  });
}
