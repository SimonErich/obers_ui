import 'dart:convert';
import 'dart:typed_data';
// Tests do not require documentation comments.
// REQ-0014: OiImage required-prop enforcement tests.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_image.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('provider images retain image identity, fit and alternative text', (tester) async {
    final bytes = Uint8List.fromList(base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jg/0AAAAASUVORK5CYII='));
    final provider = MemoryImage(bytes);
    final semantics = tester.ensureSemantics();
    await tester.pumpObers(OiImage.provider(provider: provider, alt: 'An imported photo', width: 80, height: 80, fit: BoxFit.cover));
    await tester.pumpAndSettle();
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, provider); expect(image.fit, BoxFit.cover);
    expect(find.bySemanticsLabel('An imported photo'), findsOneWidget); semantics.dispose();
  });

  // Asset paths below do not need to exist — errorWidget suppresses the load
  // error so tests focus on semantics, not image rendering.

  // ── REQ-0014: Required props enforce correctness ──────────────────────────

  testWidgets('REQ-0014: alt is exposed in the accessibility tree', (
    tester,
  ) async {
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
