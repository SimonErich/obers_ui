// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/scroll/oi_virtual_grid.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. Renders items ───────────────────────────────────────────────────────

  testWidgets('renders all items for small item count', (tester) async {
    await tester.pumpObers(
      OiVirtualGrid(
        itemCount: 6,
        crossAxisCount: 3,
        itemBuilder: (_, i) => Text('g$i', key: ValueKey('g$i')),
        shrinkWrap: true,
      ),
    );
    for (var i = 0; i < 6; i++) {
      expect(find.text('g$i'), findsOneWidget);
    }
  });

  // ── 2. crossAxisCount propagates to SliverGridDelegate ────────────────────

  testWidgets('crossAxisCount is forwarded to SliverGridDelegateWithFixedCrossAxisCount',
      (tester) async {
    await tester.pumpObers(
      OiVirtualGrid(
        itemCount: 4,
        crossAxisCount: 4,
        itemBuilder: (_, i) => Text('c$i'),
        shrinkWrap: true,
      ),
    );
    final gv = tester.widget<GridView>(find.byType(GridView));
    final delegate = gv.gridDelegate
        as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 4);
  });

  // ── 3. mainAxisSpacing / crossAxisSpacing propagate ───────────────────────

  testWidgets('spacing values propagate to grid delegate', (tester) async {
    await tester.pumpObers(
      OiVirtualGrid(
        itemCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 12,
        itemBuilder: (_, i) => Text('s$i'),
        shrinkWrap: true,
      ),
    );
    final gv = tester.widget<GridView>(find.byType(GridView));
    final delegate = gv.gridDelegate
        as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.mainAxisSpacing, 8);
    expect(delegate.crossAxisSpacing, 12);
  });

  // ── 4. childAspectRatio propagates ────────────────────────────────────────

  testWidgets('childAspectRatio propagates to grid delegate', (tester) async {
    await tester.pumpObers(
      OiVirtualGrid(
        itemCount: 4,
        childAspectRatio: 0.5,
        itemBuilder: (_, i) => Text('a$i'),
        shrinkWrap: true,
      ),
    );
    final gv = tester.widget<GridView>(find.byType(GridView));
    final delegate = gv.gridDelegate
        as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.childAspectRatio, 0.5);
  });

  // ── 5. cacheExtent propagates ─────────────────────────────────────────────

  testWidgets('cacheExtent is forwarded to GridView', (tester) async {
    await tester.pumpObers(
      OiVirtualGrid(
        itemCount: 4,
        cacheExtent: 300,
        itemBuilder: (_, i) => Text('ce$i'),
        shrinkWrap: true,
      ),
    );
    final gv = tester.widget<GridView>(find.byType(GridView));
    expect(gv.cacheExtent, 300);
  });

  // ── 6. shrinkWrap embeds in Column without error ───────────────────────────

  testWidgets('shrinkWrap=true embeds in Column without error', (tester) async {
    await tester.pumpObers(
      SingleChildScrollView(
        child: Column(
          children: [
            OiVirtualGrid(
              itemCount: 4,
              childAspectRatio: 2,
              itemBuilder: (_, i) => Text('sw$i'),
              shrinkWrap: true,
            ),
          ],
        ),
      ),
    );
    expect(find.text('sw0'), findsOneWidget);
  });

  // ── 7. itemBuilder called for each item ───────────────────────────────────

  testWidgets('itemBuilder invoked for each visible index', (tester) async {
    final built = <int>[];
    await tester.pumpObers(
      OiVirtualGrid(
        itemCount: 3,
        crossAxisCount: 3,
        itemBuilder: (_, i) {
          built.add(i);
          return Text('$i');
        },
        shrinkWrap: true,
      ),
    );
    expect(built, containsAll([0, 1, 2]));
  });
}
