// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/animation/oi_shimmer.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. Renders child shape ────────────────────────────────────────────────

  testWidgets('renders child regardless of active state', (tester) async {
    await tester.pumpObers(
      const OiShimmer(child: SizedBox(width: 100, height: 20)),
    );
    await tester.pump();
    expect(find.byType(SizedBox), findsWidgets);
  });

  // ── 2. active=false: no ShaderMask ────────────────────────────────────────

  testWidgets('active=false: child rendered directly without ShaderMask', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiShimmer(active: false, child: Text('content')),
    );
    await tester.pump();

    expect(find.text('content'), findsOneWidget);
    expect(find.byType(ShaderMask), findsNothing);
  });

  // ── 3. active=true: ShaderMask applied ───────────────────────────────────

  testWidgets('active=true: ShaderMask wraps the child', (tester) async {
    await tester.pumpObers(
      const OiShimmer(child: SizedBox(width: 100, height: 20)),
    );
    await tester.pump();

    expect(find.byType(ShaderMask), findsOneWidget);
  });

  // ── 4. reducedMotion: no ShaderMask, uses ColorFiltered instead ───────────

  testWidgets(
    'reducedMotion + active=true: ColorFiltered instead of ShaderMask',
    (tester) async {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: OiShimmer(child: SizedBox(width: 100, height: 20)),
        ),
      );
      await tester.pump();

      expect(find.byType(ShaderMask), findsNothing);
      expect(find.byType(ColorFiltered), findsOneWidget);
    },
  );

  // ── 5. Custom colors are accepted without error ───────────────────────────

  testWidgets('custom baseColor and highlightColor accepted', (tester) async {
    await tester.pumpObers(
      const OiShimmer(
        baseColor: Color(0xFFBBBBBB),
        highlightColor: Color(0xFFEEEEEE),
        child: SizedBox(width: 80, height: 16),
      ),
    );
    await tester.pump();
    expect(find.byType(ShaderMask), findsOneWidget);
  });

  // ── 6. active toggles ShaderMask on/off ──────────────────────────────────

  testWidgets('toggling active removes and restores ShaderMask', (
    tester,
  ) async {
    final notifier = ValueNotifier<bool>(true);

    await tester.pumpObers(
      ValueListenableBuilder<bool>(
        valueListenable: notifier,
        builder: (_, active, _) => OiShimmer(
          active: active,
          child: const SizedBox(width: 60, height: 12),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(ShaderMask), findsOneWidget);

    notifier.value = false;
    await tester.pump();
    expect(find.byType(ShaderMask), findsNothing);

    notifier.value = true;
    await tester.pump();
    expect(find.byType(ShaderMask), findsOneWidget);
  });
}
