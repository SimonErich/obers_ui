// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. Anchor renders ──────────────────────────────────────────────────────

  testWidgets('renders the anchor widget', (tester) async {
    await tester.pumpObers(
      const OiFloating(
        anchor: Text('anchor'),
        child: Text('floating'),
      ),
    );
    expect(find.text('anchor'), findsOneWidget);
  });

  // ── 2. visible=false hides child ──────────────────────────────────────────

  testWidgets('visible=false: floating child is not visible', (tester) async {
    await tester.pumpObers(
      const OiFloating(
        anchor: SizedBox(width: 80, height: 40),
        child: Text('floating'),
      ),
    );
    await tester.pump();
    // Visibility widget keeps it in tree but not visible.
    final visibility = tester.widget<Visibility>(find.byType(Visibility));
    expect(visibility.visible, isFalse);
  });

  // ── 3. visible=true shows child ────────────────────────────────────────────

  testWidgets('visible=true: floating child is visible', (tester) async {
    await tester.pumpObers(
      const OiFloating(
        anchor: SizedBox(width: 80, height: 40),
        visible: true,
        child: Text('floating'),
      ),
    );
    await tester.pump();
    final visibility = tester.widget<Visibility>(find.byType(Visibility));
    expect(visibility.visible, isTrue);
  });

  // ── 4. Different alignments render without error ───────────────────────────

  for (final alignment in [
    OiFloatingAlignment.topStart,
    OiFloatingAlignment.bottomEnd,
    OiFloatingAlignment.leftCenter,
    OiFloatingAlignment.rightStart,
  ]) {
    testWidgets('alignment=$alignment renders without error', (tester) async {
      await tester.pumpObers(
        OiFloating(
          anchor: const SizedBox(width: 80, height: 40),
          visible: true,
          alignment: alignment,
          child: const Text('floating'),
        ),
      );
      await tester.pump();
      expect(find.byType(OiFloating), findsOneWidget);
    });
  }

  // ── 5. autoFlip=false does not change alignment ────────────────────────────

  testWidgets('autoFlip=false: uses provided alignment without flipping',
      (tester) async {
    await tester.pumpObers(
      const OiFloating(
        anchor: SizedBox(width: 80, height: 40),
        visible: true,
        alignment: OiFloatingAlignment.topCenter,
        autoFlip: false,
        child: Text('floating'),
      ),
    );
    await tester.pump();
    expect(find.byType(OiFloating), findsOneWidget);
  });

  // ── 6. gap parameter is accepted ──────────────────────────────────────────

  testWidgets('gap parameter does not cause errors', (tester) async {
    await tester.pumpObers(
      const OiFloating(
        anchor: SizedBox(width: 80, height: 40),
        visible: true,
        gap: 12,
        child: Text('floating'),
      ),
    );
    await tester.pump();
    expect(find.byType(OiFloating), findsOneWidget);
  });

  // ── 7. offset parameter is accepted ───────────────────────────────────────

  testWidgets('offset parameter does not cause errors', (tester) async {
    await tester.pumpObers(
      const OiFloating(
        anchor: SizedBox(width: 80, height: 40),
        visible: true,
        offset: Offset(8, 8),
        child: Text('floating'),
      ),
    );
    await tester.pump();
    expect(find.byType(OiFloating), findsOneWidget);
  });

  // ── 8. toggling visible updates Visibility ────────────────────────────────

  testWidgets('toggling visible updates the Visibility widget', (tester) async {
    final notifier = ValueNotifier<bool>(false);
    addTearDown(notifier.dispose);

    await tester.pumpObers(
      ValueListenableBuilder<bool>(
        valueListenable: notifier,
        builder: (context, showFloating, _) => OiFloating(
          anchor: const SizedBox(width: 80, height: 40),
          visible: showFloating,
          child: const Text('floating'),
        ),
      ),
    );
    await tester.pump();

    // Initially hidden.
    expect(
      tester.widget<Visibility>(find.byType(Visibility)).visible,
      isFalse,
    );

    // Toggle visible=true via notifier (no hit-test issues).
    notifier.value = true;
    await tester.pump();

    expect(
      tester.widget<Visibility>(find.byType(Visibility)).visible,
      isTrue,
    );
  });
}
