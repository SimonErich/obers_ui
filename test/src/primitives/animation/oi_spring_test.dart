// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/animation/oi_spring.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. Renders via builder ────────────────────────────────────────────────

  testWidgets('calls builder and renders its output', (tester) async {
    await tester.pumpObers(
      OiSpring(
        value: 1,
        builder: (_, v, __) => Text('val:${v.toStringAsFixed(1)}'),
      ),
    );
    await tester.pump();

    // Initial controller value is set to widget.value (1.0) in initState.
    expect(find.text('val:1.0'), findsOneWidget);
  });

  // ── 2. AnimatedBuilder is present ────────────────────────────────────────

  testWidgets('wraps output in AnimatedBuilder', (tester) async {
    await tester.pumpObers(
      OiSpring(
        value: 0,
        builder: (_, __, ___) => const SizedBox(),
      ),
    );
    await tester.pump();

    // At least one AnimatedBuilder driven by an AnimationController is present.
    final builders = tester.widgetList<AnimatedBuilder>(
      find.byType(AnimatedBuilder),
    );
    expect(builders.any((b) => b.listenable is AnimationController), isTrue);
  });

  // ── 3. child passthrough reaches builder ─────────────────────────────────

  testWidgets('child widget is passed through to builder', (tester) async {
    await tester.pumpObers(
      OiSpring(
        value: 0.5,
        builder: (_, __, child) => child!,
        child: const Text('passed'),
      ),
    );
    await tester.pump();

    expect(find.text('passed'), findsOneWidget);
  });

  // ── 4. value change triggers spring animation ─────────────────────────────

  testWidgets('value change: controller animates toward new target',
      (tester) async {
    final notifier = ValueNotifier<double>(0);

    await tester.pumpObers(
      ValueListenableBuilder<double>(
        valueListenable: notifier,
        builder: (_, v, __) => OiSpring(
          value: v,
          builder: (_, animVal, ___) =>
              Text(animVal.toStringAsFixed(2), key: const ValueKey('out')),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('0.00'), findsOneWidget);

    // Trigger a value change and advance time so the spring moves.
    notifier.value = 1;
    await tester.pump(); // rebuild with new value, kicks off animateWith
    await tester.pump(const Duration(milliseconds: 50)); // advance ticker

    // After 50 ms the spring is mid-flight: value must be above 0.
    expect(find.text('0.00'), findsNothing);

    // After settling the spring must reach approximately 1.0.
    await tester.pumpAndSettle();
    expect(find.text('1.00'), findsOneWidget);
  });

  // ── 5. custom spring parameters accepted without error ────────────────────

  testWidgets('custom stiffness/damping/mass renders without error',
      (tester) async {
    await tester.pumpObers(
      OiSpring(
        value: 1,
        stiffness: 500,
        damping: 20,
        mass: 2,
        builder: (_, v, __) => Text(v.toStringAsFixed(1)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1.0'), findsOneWidget);
  });
}
