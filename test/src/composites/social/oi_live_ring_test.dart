// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/social/oi_live_ring.dart';
import 'package:obers_ui/src/primitives/animation/oi_pulse.dart';

import '../../../helpers/pump_app.dart';

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  testWidgets('ring renders when active is true', (tester) async {
    await tester.pumpObers(
      const Center(
        child: OiLiveRing(
          child: SizedBox(width: 40, height: 40),
        ),
      ),
    );

    // The live ring indicator container is present.
    expect(find.byKey(const Key('oi_live_ring_indicator')), findsOneWidget);
    // OiPulse wrapper is present.
    expect(find.byType(OiPulse), findsOneWidget);
  });

  testWidgets('no ring when active is false', (tester) async {
    await tester.pumpObers(
      const Center(
        child: OiLiveRing(
          active: false,
          child: SizedBox(width: 40, height: 40),
        ),
      ),
    );

    expect(find.byKey(const Key('oi_live_ring_indicator')), findsNothing);
    expect(find.byType(OiPulse), findsNothing);
  });

  testWidgets('child renders when active', (tester) async {
    await tester.pumpObers(
      const Center(
        child: OiLiveRing(
          child: Text('Live'),
        ),
      ),
    );

    // The child appears twice when active (once as the real child, once as the
    // invisible sizing copy inside OiPulse), so at least one must be present.
    expect(find.text('Live'), findsAtLeast(1));
  });

  testWidgets('child renders when inactive', (tester) async {
    await tester.pumpObers(
      const Center(
        child: OiLiveRing(
          active: false,
          child: Text('Live'),
        ),
      ),
    );

    expect(find.text('Live'), findsOneWidget);
  });

  testWidgets('custom color is applied to the ring', (tester) async {
    const customColor = Color(0xFFFF00FF);

    await tester.pumpObers(
      const Center(
        child: OiLiveRing(
          color: customColor,
          child: SizedBox(width: 40, height: 40),
        ),
      ),
    );

    // The ring indicator container has a border with the custom color.
    final container = tester.widget<Container>(
      find.byKey(const Key('oi_live_ring_indicator')),
    );
    final decoration = container.decoration! as BoxDecoration;
    final border = decoration.border! as Border;
    expect(border.top.color, customColor);
  });

  testWidgets('pulse animation runs when active', (tester) async {
    await tester.pumpObers(
      const Center(
        child: OiLiveRing(
          child: SizedBox(width: 40, height: 40),
        ),
      ),
    );

    // Advance the animation — should not throw.
    await tester.pump(const Duration(milliseconds: 750));
    expect(find.byType(OiPulse), findsOneWidget);
  });
}
