// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/layout/oi_aspect_ratio.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders child', (tester) async {
    await tester.pumpObers(
      const OiAspectRatio(
        ratio: 16 / 9,
        child: ColoredBox(color: Color(0xFF000000)),
      ),
    );
    expect(find.byType(AspectRatio), findsOneWidget);
    expect(find.byType(ColoredBox), findsOneWidget);
  });

  testWidgets('passes ratio to AspectRatio', (tester) async {
    await tester.pumpObers(
      const OiAspectRatio(
        ratio: 4 / 3,
        child: ColoredBox(color: Color(0xFF000000)),
      ),
    );
    final ar = tester.widget<AspectRatio>(find.byType(AspectRatio));
    expect(ar.aspectRatio, closeTo(4 / 3, 0.001));
  });

  testWidgets('1:1 ratio passes through correctly', (tester) async {
    await tester.pumpObers(
      const OiAspectRatio(
        ratio: 1,
        child: ColoredBox(color: Color(0xFF000000)),
      ),
    );
    final ar = tester.widget<AspectRatio>(find.byType(AspectRatio));
    expect(ar.aspectRatio, 1.0);
  });
}
