// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/animation/oi_morph.dart';
import 'package:obers_ui/src/primitives/overlay/oi_visibility.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. Renders initial child ──────────────────────────────────────────────

  testWidgets('renders the initial child', (tester) async {
    await tester.pumpObers(
      const OiMorph(child: Text('initial', key: ValueKey('initial'))),
    );
    await tester.pump();

    expect(find.text('initial'), findsOneWidget);
  });

  // ── 2. AnimatedSwitcher is present ────────────────────────────────────────

  testWidgets('wraps child in AnimatedSwitcher', (tester) async {
    await tester.pumpObers(
      const OiMorph(child: Text('hello', key: ValueKey('hello'))),
    );
    await tester.pump();

    expect(find.byType(AnimatedSwitcher), findsOneWidget);
  });

  // ── 3. Child change triggers FadeTransition (default transition=fade) ─────

  testWidgets('child key change: FadeTransition present during switch', (
    tester,
  ) async {
    final notifier = ValueNotifier<bool>(false);

    await tester.pumpObers(
      ValueListenableBuilder<bool>(
        valueListenable: notifier,
        builder: (_, flag, __) => OiMorph(
          child: flag
              ? const Text('B', key: ValueKey('b'))
              : const Text('A', key: ValueKey('a')),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('A'), findsOneWidget);

    notifier.value = true;
    await tester.pump(); // begin transition

    // During the transition both old and new children are in tree.
    expect(find.byType(FadeTransition), findsWidgets);

    await tester.pumpAndSettle();
    expect(find.text('B'), findsOneWidget);
    expect(find.text('A'), findsNothing);
  });

  // ── 4. transition=none: no FadeTransition ─────────────────────────────────

  testWidgets('transition=none: no FadeTransition on child switch', (
    tester,
  ) async {
    final notifier = ValueNotifier<bool>(false);

    await tester.pumpObers(
      ValueListenableBuilder<bool>(
        valueListenable: notifier,
        builder: (_, flag, __) => OiMorph(
          transition: OiTransition.none,
          child: flag
              ? const Text('Y', key: ValueKey('y'))
              : const Text('X', key: ValueKey('x')),
        ),
      ),
    );
    await tester.pump();

    notifier.value = true;
    await tester.pump();

    expect(find.byType(FadeTransition), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('Y'), findsOneWidget);
  });

  // ── 5. transition=fadeScale: ScaleTransition present ─────────────────────

  testWidgets('transition=fadeScale: ScaleTransition present during switch', (
    tester,
  ) async {
    final notifier = ValueNotifier<bool>(false);

    await tester.pumpObers(
      ValueListenableBuilder<bool>(
        valueListenable: notifier,
        builder: (_, flag, __) => OiMorph(
          transition: OiTransition.fadeScale,
          child: flag
              ? const Text('2', key: ValueKey('2'))
              : const Text('1', key: ValueKey('1')),
        ),
      ),
    );
    await tester.pump();

    notifier.value = true;
    await tester.pump();

    expect(find.byType(ScaleTransition), findsWidgets);

    await tester.pumpAndSettle();
  });

  // ── 6. explicit duration is forwarded ─────────────────────────────────────

  testWidgets('explicit duration renders without error', (tester) async {
    await tester.pumpObers(
      const OiMorph(
        duration: Duration(milliseconds: 100),
        child: Text('dur', key: ValueKey('dur')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('dur'), findsOneWidget);
  });
}
