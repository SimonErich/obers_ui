// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/primitives/drag_drop/oi_drag_ghost.dart';

import '../../../helpers/pump_app.dart';

Widget _withDensity(OiDensity density, Widget child) {
  return OiDensityScope(density: density, child: child);
}

void main() {
  // ── 1. Renders child ───────────────────────────────────────────────────────

  testWidgets('renders child widget', (tester) async {
    await tester.pumpObers(
      const OiDragGhost(child: Text('ghost')),
    );
    expect(find.text('ghost'), findsOneWidget);
  });

  // ── 2. Always wraps in Opacity ────────────────────────────────────────────

  testWidgets('wraps child in Opacity', (tester) async {
    await tester.pumpObers(
      const OiDragGhost(child: Text('g')),
    );
    expect(find.byType(Opacity), findsWidgets);
  });

  // ── 3. Custom opacity is applied ─────────────────────────────────────────

  testWidgets('custom opacity is applied', (tester) async {
    await tester.pumpObers(
      const OiDragGhost(opacity: 0.5, child: Text('g')),
    );
    final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
    expect(opacity.opacity, 0.5);
  });

  // ── 4. Touch density: applies rotation ───────────────────────────────────

  testWidgets('touch density applies default rotation', (tester) async {
    await tester.pumpObers(
      _withDensity(
        OiDensity.comfortable,
        const OiDragGhost(child: Text('g')),
      ),
    );
    // Default touch rotation is 0.05 rad — Transform.rotate is present.
    expect(find.byType(Transform), findsWidgets);
  });

  // ── 5. Pointer density: no rotation, applies scale ───────────────────────

  testWidgets('pointer density applies default scale, no rotation',
      (tester) async {
    await tester.pumpObers(
      _withDensity(
        OiDensity.compact,
        const OiDragGhost(child: Text('g')),
      ),
    );
    // Default pointer rotation is 0.0 — no rotate Transform, but scale=1.05
    // produces a Transform.scale widget.
    expect(find.byType(Transform), findsWidgets);
  });

  // ── 6. Explicit scale=1.0 and rotation=0.0 renders no Transform ──────────

  testWidgets('explicit scale=1 rotation=0 skips Transform widgets',
      (tester) async {
    await tester.pumpObers(
      const OiDragGhost(
        scale: 1,
        rotation: 0,
        child: Text('g'),
      ),
    );
    // No Transform should be inserted when scale == 1.0 and rotation == 0.0.
    expect(find.byType(Transform), findsNothing);
  });

  // ── 7. Explicit rotation is respected ────────────────────────────────────

  testWidgets('explicit non-zero rotation inserts rotate Transform',
      (tester) async {
    await tester.pumpObers(
      const OiDragGhost(
        scale: 1,
        rotation: 0.1,
        child: Text('g'),
      ),
    );
    expect(find.byType(Transform), findsOneWidget);
  });

  // ── 8. Explicit scale > 1 is respected ───────────────────────────────────

  testWidgets('explicit scale > 1 inserts scale Transform', (tester) async {
    await tester.pumpObers(
      const OiDragGhost(
        scale: 1.2,
        rotation: 0,
        child: Text('g'),
      ),
    );
    expect(find.byType(Transform), findsOneWidget);
  });
}
