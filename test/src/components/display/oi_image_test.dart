// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_image.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // Asset paths below do not need to exist — errorWidget suppresses the load
  // error so tests focus on semantics, not image rendering.

  testWidgets('alt is exposed in the accessibility tree', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpObers(
        const OiImage(
          src: 'assets/cat.png',
          alt: 'A cat',
          errorWidget: SizedBox(),
        ),
      );
      expect(find.bySemanticsLabel('A cat'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('alt is wrapped in Semantics with image:true flag', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiImage(
        src: 'assets/dog.png',
        alt: 'A dog',
        errorWidget: SizedBox(),
      ),
    );
    final semanticsWidgets = tester.widgetList<Semantics>(
      find.ancestor(of: find.byType(Image), matching: find.byType(Semantics)),
    );
    final ours = semanticsWidgets.first;
    expect(ours.properties.label, 'A dog');
    expect(ours.properties.image, true);
  });

  testWidgets('decorative image is excluded from the semantics tree', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpObers(
        const OiImage.decorative(
          src: 'assets/background.png',
          errorWidget: SizedBox(),
        ),
      );
      expect(find.bySemanticsLabel('background'), findsNothing);
      expect(
        find.ancestor(
          of: find.byType(Image),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    } finally {
      handle.dispose();
    }
  });
}
