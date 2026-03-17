// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/primitives/drag_drop/oi_reorderable.dart';

import '../../../helpers/pump_app.dart';

Widget _withDensity(OiDensity density, Widget child) {
  return OiDensityScope(density: density, child: child);
}

void main() {
  // ── 1. Renders all children ────────────────────────────────────────────────

  testWidgets('renders all children', (tester) async {
    await tester.pumpObers(
      OiReorderable(
        onReorder: (_, __) {},
        children: const [
          Text('alpha', key: ValueKey('a')),
          Text('beta', key: ValueKey('b')),
          Text('gamma', key: ValueKey('c')),
        ],
      ),
    );
    expect(find.text('alpha'), findsOneWidget);
    expect(find.text('beta'), findsOneWidget);
    expect(find.text('gamma'), findsOneWidget);
  });

  // ── 2. Wraps in CustomScrollView + SliverReorderableList ──────────────────

  testWidgets('uses CustomScrollView and SliverReorderableList', (
    tester,
  ) async {
    await tester.pumpObers(
      OiReorderable(
        onReorder: (_, __) {},
        children: const [Text('item', key: ValueKey('i'))],
      ),
    );
    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.byType(SliverReorderableList), findsOneWidget);
  });

  // ── 3. Pointer density wraps items in ReorderableDragStartListener ─────────

  testWidgets('pointer density uses ReorderableDragStartListener', (
    tester,
  ) async {
    await tester.pumpObers(
      _withDensity(
        OiDensity.compact,
        OiReorderable(
          onReorder: (_, __) {},
          children: const [
            Text('a', key: ValueKey('a')),
            Text('b', key: ValueKey('b')),
          ],
        ),
      ),
    );
    expect(find.byType(ReorderableDragStartListener), findsWidgets);
    expect(find.byType(ReorderableDelayedDragStartListener), findsNothing);
  });

  // ── 4. Touch density wraps items in ReorderableDelayedDragStartListener ────

  testWidgets('touch density uses ReorderableDelayedDragStartListener', (
    tester,
  ) async {
    await tester.pumpObers(
      _withDensity(
        OiDensity.comfortable,
        OiReorderable(
          onReorder: (_, __) {},
          children: const [
            Text('a', key: ValueKey('a')),
            Text('b', key: ValueKey('b')),
          ],
        ),
      ),
    );
    expect(find.byType(ReorderableDelayedDragStartListener), findsWidgets);
    expect(find.byType(ReorderableDragStartListener), findsNothing);
  });

  // ── 5. Padding is applied via SliverPadding ────────────────────────────────

  testWidgets('padding inserts SliverPadding', (tester) async {
    await tester.pumpObers(
      OiReorderable(
        onReorder: (_, __) {},
        padding: const EdgeInsets.all(16),
        children: const [Text('item', key: ValueKey('i'))],
      ),
    );
    expect(find.byType(SliverPadding), findsOneWidget);
  });

  // ── 6. No SliverPadding when padding is null ───────────────────────────────

  testWidgets('no SliverPadding when padding is omitted', (tester) async {
    await tester.pumpObers(
      OiReorderable(
        onReorder: (_, __) {},
        children: const [Text('item', key: ValueKey('i'))],
      ),
    );
    expect(find.byType(SliverPadding), findsNothing);
  });

  // ── 7. onReorder callback fires ───────────────────────────────────────────

  testWidgets('onReorder callback fires when item is dragged', (tester) async {
    int? capturedOld;
    int? capturedNew;

    await tester.pumpObers(
      _withDensity(
        OiDensity.compact,
        SizedBox(
          height: 400,
          child: OiReorderable(
            onReorder: (oldIndex, newIndex) {
              capturedOld = oldIndex;
              capturedNew = newIndex;
            },
            children: const [
              SizedBox(key: ValueKey('a'), height: 60, child: Text('alpha')),
              SizedBox(key: ValueKey('b'), height: 60, child: Text('beta')),
              SizedBox(key: ValueKey('c'), height: 60, child: Text('gamma')),
            ],
          ),
        ),
      ),
    );

    // Drag the first item down past the second.
    final firstItemCenter = tester.getCenter(find.text('alpha'));
    final gesture = await tester.startGesture(firstItemCenter);
    // Simulate the long-press-style hold needed by drag start listeners.
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(capturedOld, isNotNull);
    expect(capturedNew, isNotNull);
  });
}
