// Tests do not require documentation comments.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_skeleton_group.dart';
import 'package:obers_ui/src/primitives/animation/oi_shimmer.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('OiSkeletonLine renders OiShimmer', (tester) async {
    await tester.pumpObers(const OiSkeletonLine());
    expect(find.byType(OiShimmer), findsOneWidget);
  });

  testWidgets('OiSkeletonBox renders OiShimmer', (tester) async {
    await tester.pumpObers(const OiSkeletonBox(height: 80));
    expect(find.byType(OiShimmer), findsOneWidget);
  });

  testWidgets('OiSkeletonGroup renders children', (tester) async {
    await tester.pumpObers(
      const OiSkeletonGroup(
        children: [
          OiSkeletonLine(),
          OiSkeletonLine(width: 120),
          OiSkeletonBox(height: 48),
        ],
      ),
    );
    expect(find.byType(OiShimmer), findsNWidgets(3));
  });

  testWidgets('OiSkeletonGroup active=true shows shimmer', (tester) async {
    await tester.pumpObers(const OiSkeletonGroup(children: [OiSkeletonLine()]));
    final shimmer = tester.widget<OiShimmer>(find.byType(OiShimmer));
    expect(shimmer.active, isTrue);
  });

  testWidgets('OiSkeletonLine respects width and height', (tester) async {
    await tester.pumpObers(const OiSkeletonLine(width: 200, height: 20));
    expect(find.byType(OiShimmer), findsOneWidget);
  });

  testWidgets('OiSkeletonBox respects width and height', (tester) async {
    await tester.pumpObers(const OiSkeletonBox(width: 100, height: 60));
    expect(find.byType(OiShimmer), findsOneWidget);
  });
}
