// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/animation/oi_pulse.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. Renders child ─────────────────────────────────────────────────────

  testWidgets('renders child widget', (tester) async {
    await tester.pumpObers(const OiPulse(child: Text('pulse me')));
    await tester.pump();
    expect(find.text('pulse me'), findsOneWidget);
  });

  // ── 2. active=false: no AnimatedBuilder ──────────────────────────────────

  testWidgets('active=false: child rendered directly, no AnimatedBuilder', (
    tester,
  ) async {
    await tester.pumpObers(const OiPulse(active: false, child: Text('still')));
    await tester.pump();

    expect(find.text('still'), findsOneWidget);
    // The OiApp wrapper may itself use AnimatedBuilder; verify OiPulse does
    // not add one by checking that no AnimationController-driven builder is
    // present for the pulse widget specifically.
    final pulseBuilders = tester.widgetList<AnimatedBuilder>(
      find.byType(AnimatedBuilder),
    );
    // None of the builders should be for an AnimationController (pulse uses one).
    final hasPulseBuilder = pulseBuilders.any(
      (b) => b.listenable is AnimationController,
    );
    expect(hasPulseBuilder, isFalse);
  });

  // ── 3. active=true: AnimatedBuilder present ───────────────────────────────

  testWidgets('active=true: AnimatedBuilder wraps child', (tester) async {
    await tester.pumpObers(const OiPulse(child: Text('pulsing')));
    await tester.pump();

    // At least one AnimatedBuilder driven by an AnimationController is present.
    final pulseBuilders = tester.widgetList<AnimatedBuilder>(
      find.byType(AnimatedBuilder),
    );
    final hasPulseBuilder = pulseBuilders.any(
      (b) => b.listenable is AnimationController,
    );
    expect(hasPulseBuilder, isTrue);
  });

  // ── 4. active=true with scale: Opacity and Transform present ─────────────

  testWidgets('active=true with maxScale>1: Opacity and Transform present', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiPulse(maxScale: 1.2, child: Text('big pulse')),
    );
    await tester.pump();

    expect(find.byType(Opacity), findsOneWidget);
    expect(find.byType(Transform), findsOneWidget);
  });

  // ── 5. reducedMotion: no AnimatedBuilder, child shown directly ────────────

  testWidgets('reducedMotion: no AnimatedBuilder', (tester) async {
    await tester.pumpObers(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: OiPulse(child: Text('no motion')),
      ),
    );
    await tester.pump();

    expect(find.text('no motion'), findsOneWidget);
    // With reducedMotion, OiPulse returns the child directly — no
    // AnimationController-driven AnimatedBuilder should be present.
    final builders = tester.widgetList<AnimatedBuilder>(
      find.byType(AnimatedBuilder),
    );
    expect(builders.any((b) => b.listenable is AnimationController), isFalse);
  });

  // ── 6. toggling active starts and stops animation widget ─────────────────

  testWidgets('toggling active adds and removes AnimatedBuilder', (
    tester,
  ) async {
    final notifier = ValueNotifier<bool>(true);

    await tester.pumpObers(
      ValueListenableBuilder<bool>(
        valueListenable: notifier,
        builder: (_, active, __) =>
            OiPulse(active: active, child: const Text('toggle')),
      ),
    );
    await tester.pump();
    // active=true: pulse adds an AnimationController-driven AnimatedBuilder.
    final buildersOn = tester.widgetList<AnimatedBuilder>(
      find.byType(AnimatedBuilder),
    );
    expect(buildersOn.any((b) => b.listenable is AnimationController), isTrue);

    notifier.value = false;
    await tester.pump();
    // active=false: OiPulse returns child directly; no AnimationController
    // driven builder from the pulse widget remains.
    final buildersOff = tester.widgetList<AnimatedBuilder>(
      find.byType(AnimatedBuilder),
    );
    expect(
      buildersOff.any((b) => b.listenable is AnimationController),
      isFalse,
    );
  });
}
