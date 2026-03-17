// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/layout/oi_masonry.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Basic rendering ────────────────────────────────────────────────────────

  testWidgets('renders all children', (tester) async {
    await tester.pumpObers(
      const OiMasonry(children: [Text('A'), Text('B'), Text('C'), Text('D')]),
    );
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('renders outer Row with CrossAxisAlignment.start', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiMasonry(columns: 3, children: [Text('X'), Text('Y'), Text('Z')]),
    );
    final row = tester.widget<Row>(find.byType(Row).first);
    expect(row.crossAxisAlignment, CrossAxisAlignment.start);
  });

  // ── Column count ───────────────────────────────────────────────────────────

  testWidgets('uses correct number of Expanded column widgets', (tester) async {
    await tester.pumpObers(
      const OiMasonry(
        columns: 3,
        children: [Text('1'), Text('2'), Text('3'), Text('4'), Text('5')],
      ),
    );
    // One Expanded per column.
    expect(find.byType(Expanded), findsNWidgets(3));
  });

  // ── Gap spacing ────────────────────────────────────────────────────────────

  testWidgets('gap inserts SizedBox with given width between columns', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiMasonry(gap: 12, children: [Text('A'), Text('B')]),
    );
    // One horizontal SizedBox between the two Expanded columns.
    final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    final widthBoxes = boxes.where((b) => b.width == 12).toList();
    expect(widthBoxes, hasLength(1));
  });

  testWidgets('gap inserts vertical SizedBox between items in same column', (
    tester,
  ) async {
    // 2 columns, 4 items → each column gets 2 items → 1 vertical spacer each.
    await tester.pumpObers(
      const OiMasonry(
        gap: 8,
        children: [Text('A'), Text('B'), Text('C'), Text('D')],
      ),
    );
    final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    final heightBoxes = boxes.where((b) => b.height == 8).toList();
    // 2 columns × 1 spacer each = 2 vertical spacers.
    expect(heightBoxes, hasLength(2));
  });
}
