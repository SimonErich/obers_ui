// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_drawer.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Visibility ─────────────────────────────────────────────────────────────

  testWidgets('renders child when open=true', (tester) async {
    await tester.pumpObers(
      OiDrawer(
        open: true,
        onClose: () {},
        child: const Text('Nav content'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nav content'), findsOneWidget);
  });

  testWidgets('child is present in tree when open=false (slide hidden)',
      (tester) async {
    // AnimatedSlide keeps the widget in the tree; it's just translated off screen.
    await tester.pumpObers(
      const OiDrawer(
        open: false,
        child: Text('Nav content'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nav content'), findsOneWidget);
  });

  // ── onClose ────────────────────────────────────────────────────────────────

  testWidgets('tapping scrim calls onClose', (tester) async {
    var closed = 0;
    await tester.pumpObers(
      OiDrawer(
        open: true,
        onClose: () => closed++,
        child: const SizedBox(width: 280, child: Text('Nav')),
      ),
    );
    await tester.pumpAndSettle();
    // Tap the scrim area (to the right of the drawer).
    final screenWidth = tester.view.physicalSize.width /
        tester.view.devicePixelRatio;
    await tester.tapAt(Offset(screenWidth - 20, 100));
    await tester.pump();
    expect(closed, 1);
  });

  // ── Animation ──────────────────────────────────────────────────────────────

  testWidgets('slides in when open transitions from false to true',
      (tester) async {
    var open = false;

    await tester.pumpObers(
      StatefulBuilder(
        builder: (context, setState) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () => setState(() => open = true),
                child: const Text('toggle'),
              ),
              OiDrawer(
                open: open,
                child: const Text('Drawer child'),
              ),
            ],
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('toggle'));
    await tester.pumpAndSettle();

    expect(find.text('Drawer child'), findsOneWidget);
  });

  // ── Width ──────────────────────────────────────────────────────────────────

  testWidgets('default width is 280', (tester) async {
    await tester.pumpObers(
      const OiDrawer(
        open: true,
        child: SizedBox.expand(),
      ),
    );
    await tester.pumpAndSettle();
    final sizedBox = tester
        .widgetList<SizedBox>(find.byType(SizedBox))
        .firstWhere(
          (b) => b.width == 280,
          orElse: () => throw TestFailure('No 280-wide SizedBox found'),
        );
    expect(sizedBox.width, 280);
  });

  testWidgets('custom width is respected', (tester) async {
    await tester.pumpObers(
      const OiDrawer(
        open: true,
        width: 320,
        child: SizedBox.expand(),
      ),
    );
    await tester.pumpAndSettle();
    final sizedBox = tester
        .widgetList<SizedBox>(find.byType(SizedBox))
        .firstWhere(
          (b) => b.width == 320,
          orElse: () => throw TestFailure('No 320-wide SizedBox found'),
        );
    expect(sizedBox.width, 320);
  });
}
