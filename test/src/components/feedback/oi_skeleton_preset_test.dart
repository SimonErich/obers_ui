// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_skeleton_group.dart';
import 'package:obers_ui/src/components/feedback/oi_skeleton_preset.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('text preset renders correct number of lines', (tester) async {
    await tester.pumpObers(const OiSkeletonPreset.text(lines: 4));
    expect(find.byType(OiSkeletonLine), findsNWidgets(4));
  });

  testWidgets('text preset last line is shorter via FractionallySizedBox', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiSkeletonPreset.text(lines: 3, lastLineWidth: 0.5),
    );
    final fractions = tester.widgetList<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    // Last one should have widthFactor 0.5.
    expect(fractions.last.widthFactor, 0.5);
  });

  testWidgets('avatar preset renders circular shape', (tester) async {
    await tester.pumpObers(const OiSkeletonPreset.avatar());
    expect(find.byType(ClipOval), findsOneWidget);
    expect(find.byType(OiSkeletonBox), findsOneWidget);
  });

  testWidgets('card preset renders OiSkeletonBox', (tester) async {
    await tester.pumpObers(const OiSkeletonPreset.card(height: 200));
    expect(find.byType(OiSkeletonBox), findsOneWidget);
  });

  testWidgets('listTile preset shows avatar + text lines', (tester) async {
    await tester.pumpObers(const OiSkeletonPreset.listTile(showAvatar: true));
    // Avatar (ClipOval + OiSkeletonBox) + 2 OiSkeletonLine.
    expect(find.byType(ClipOval), findsOneWidget);
    expect(find.byType(OiSkeletonLine), findsNWidgets(2));
  });

  testWidgets('listTile without avatar omits circle', (tester) async {
    await tester.pumpObers(const OiSkeletonPreset.listTile(showAvatar: false));
    expect(find.byType(ClipOval), findsNothing);
    expect(find.byType(OiSkeletonLine), findsAtLeast(2));
  });

  testWidgets('tableRow preset renders N column placeholders', (tester) async {
    await tester.pumpObers(const OiSkeletonPreset.tableRow(columns: 5));
    expect(find.byType(OiSkeletonLine), findsNWidgets(5));
  });

  testWidgets('list factory repeats item skeleton', (tester) async {
    await tester.pumpObers(
      OiSkeletonPreset.list(
        itemSkeleton: const OiSkeletonPreset.text(lines: 1),
        count: 3,
      ),
    );
    // 3 presets, each with 1 OiSkeletonLine.
    expect(find.byType(OiSkeletonLine), findsNWidgets(3));
  });

  testWidgets('image preset respects aspectRatio', (tester) async {
    await tester.pumpObers(const OiSkeletonPreset.image(aspectRatio: 16 / 9));
    expect(find.byType(AspectRatio), findsOneWidget);
  });

  testWidgets('badge preset renders small placeholder', (tester) async {
    await tester.pumpObers(const OiSkeletonPreset.badge(width: 80));
    expect(find.byType(OiSkeletonLine), findsOneWidget);
  });

  testWidgets('metric preset renders value + label placeholders', (
    tester,
  ) async {
    await tester.pumpObers(const OiSkeletonPreset.metric());
    expect(find.byType(OiSkeletonLine), findsNWidgets(2));
  });
}
