// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/overlays/oi_sheet.dart'
    show OiPanelSide;
import 'package:obers_ui/src/components/panels/oi_panel.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Rendering ──────────────────────────────────────────────────────────────

  testWidgets('open=true shows panel content', (tester) async {
    await tester.pumpObers(
      const OiPanel(label: 'panel', open: true, child: Text('panel content')),
    );
    await tester.pumpAndSettle();
    expect(find.text('panel content'), findsOneWidget);
  });

  testWidgets('open=false panel is still in tree but slid out', (tester) async {
    await tester.pumpObers(
      const OiPanel(label: 'panel', open: false, child: Text('hidden panel')),
    );
    await tester.pumpAndSettle();
    // Widget is in the tree (SlideTransition doesn't remove it).
    expect(find.text('hidden panel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('toggling open from false to true animates without error', (
    tester,
  ) async {
    var open = false;
    await tester.pumpObers(
      StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            OiPanel(label: 'panel', open: open, child: const Text('panel')),
            GestureDetector(
              onTap: () => setState(() => open = true),
              child: const Text('toggle'),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('toggle'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  // ── Sides ──────────────────────────────────────────────────────────────────

  testWidgets('side=right renders without error', (tester) async {
    await tester.pumpObers(
      const OiPanel(
        label: 'panel',
        open: true,
        side: OiPanelSide.right,
        child: Text('right panel'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('right panel'), findsOneWidget);
  });

  testWidgets('side=top renders without error', (tester) async {
    await tester.pumpObers(
      const OiPanel(
        label: 'panel',
        open: true,
        side: OiPanelSide.top,
        child: Text('top panel'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('top panel'), findsOneWidget);
  });

  testWidgets('side=bottom renders without error', (tester) async {
    await tester.pumpObers(
      const OiPanel(
        label: 'panel',
        open: true,
        side: OiPanelSide.bottom,
        child: Text('bottom panel'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('bottom panel'), findsOneWidget);
  });

  // ── Scrim + dismiss ────────────────────────────────────────────────────────

  testWidgets('showScrim=true with dismissible=true fires onClose on scrim tap', (
    tester,
  ) async {
    var closed = false;
    await tester.pumpObers(
      OiPanel(
        label: 'panel',
        open: true,
        showScrim: true,
        onClose: () => closed = true,
        child: const SizedBox(width: 200, height: 400, child: Text('panel')),
      ),
      surfaceSize: const Size(800, 600),
    );
    await tester.pumpAndSettle();

    // Tap in the scrim area (far left of an 800-wide screen with a left panel).
    await tester.tapAt(const Offset(700, 300));
    await tester.pump();
    expect(closed, isTrue);
  });

  testWidgets('dismissible=false does not fire onClose on scrim tap', (
    tester,
  ) async {
    var closed = false;
    await tester.pumpObers(
      OiPanel(
        label: 'panel',
        open: true,
        showScrim: true,
        dismissible: false,
        onClose: () => closed = true,
        child: const SizedBox(width: 200, height: 400, child: Text('panel')),
      ),
      surfaceSize: const Size(800, 600),
    );
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(700, 300));
    await tester.pump();
    expect(closed, isFalse);
  });

  // ── Size ───────────────────────────────────────────────────────────────────

  testWidgets('explicit size renders without error', (tester) async {
    await tester.pumpObers(
      const OiPanel(
        label: 'panel',
        open: true,
        size: 300,
        child: Text('sized panel'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('sized panel'), findsOneWidget);
  });

  // ── Reduced motion ────────────────────────────────────────────────────────

  testWidgets('reducedMotion: toggling open completes instantly', (
    tester,
  ) async {
    final notifier = ValueNotifier<bool>(false);
    addTearDown(notifier.dispose);

    await tester.pumpObers(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: ValueListenableBuilder<bool>(
          valueListenable: notifier,
          builder: (_, isOpen, __) => OiPanel(
            label: 'panel',
            open: isOpen,
            child: const Text('instant panel'),
          ),
        ),
      ),
    );
    await tester.pump();

    // Open — controller jumps to 1.0 with Duration.zero.
    notifier.value = true;
    await tester.pump();

    final slide = tester.widget<SlideTransition>(find.byType(SlideTransition));
    expect(slide.position.value, Offset.zero);
  });
}
