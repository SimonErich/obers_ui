import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/paint_pixels.dart';

void main() {
  testWidgets('null and empty Surface insets retain the native path and tree', (
    tester,
  ) async {
    List<Type>? originalTree;
    for (final insets in <List<OiInsetShadow>?>[null, const []]) {
      final pixels = await tester.capturePaint(
        ColoredBox(
          color: const Color(0xFFCCCCCC),
          child: Center(
            child: OiSurface(
              color: const Color(0xFF131417),
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              shadow: const [
                BoxShadow(color: Color(0x80FF0000), spreadRadius: 1),
                BoxShadow(color: Color(0x800000FF), spreadRadius: 2),
              ],
              insetShadows: insets,
              child: const SizedBox(width: 100, height: 64),
            ),
          ),
        ),
      );
      expect(pixels.fingerprint, 0x03fb4261);
      final containers = find.descendant(
        of: find.byType(OiSurface),
        matching: find.byType(Container),
      );
      expect(
        tester.widget<Container>(containers.first).decoration,
        isA<BoxDecoration>(),
      );
      final tree = find
          .descendant(
            of: find.byType(OiSurface),
            matching: find.byWidgetPredicate((_) => true),
          )
          .evaluate()
          .map((element) => element.widget.runtimeType)
          .toList();
      originalTree ??= tree;
      expect(tree, originalTree);
    }
    expect(const OiSurface.transparent().insetShadows, isNull);
    expect(const OiSurface.elevated(elevation: []).insetShadows, isNull);
  });

  testWidgets('legacy surface paint fingerprints are preserved', (
    tester,
  ) async {
    const fingerprints = {
      'solid': 0xc19ffadb,
      'dashed': 0x14f78fee,
      'dotted': 0xd9a73568,
      'none': 0x03fb4261,
    };
    final borders = <String, OiBorderStyle?>{
      'solid': OiBorderStyle.solid(const Color(0xFFEE4411), 2),
      'dashed': OiBorderStyle.dashed(const Color(0xFFEE4411), 2),
      'dotted': OiBorderStyle.dotted(const Color(0xFFEE4411), 2),
      'none': null,
    };
    for (final entry in borders.entries) {
      final pixels = await tester.capturePaint(
        ColoredBox(
          color: const Color(0xFFCCCCCC),
          child: Center(
            child: OiSurface(
              color: const Color(0xFF131417),
              border: entry.value,
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              shadow: const [
                BoxShadow(color: Color(0x80FF0000), spreadRadius: 1),
                BoxShadow(color: Color(0x800000FF), spreadRadius: 2),
              ],
              child: const SizedBox(width: 100, height: 64),
            ),
          ),
        ),
      );
      // Frozen from unchanged Surface097dd008; not a browser/inset oracle.
      expect(pixels.fingerprint, fingerprints[entry.key], reason: entry.key);
      expect(pixels.rgba(80, 50), [19, 20, 23, 255]);
    }
  });

  testWidgets('Surface opts into sharp insets without changing its bounds', (
    tester,
  ) async {
    final pixels = await tester.capturePaint(
      OiSurface(
        color: const Color(0xFF000000),
        insetShadows: [
          OiInsetShadow(
            color: const Color(0xFFFFFFFF),
            offset: const Offset(0, 1),
          ),
        ],
      ),
      size: const Size(100, 64),
    );
    expect(pixels.width, 100);
    expect(pixels.height, 64);
    for (var y = 0; y < 64; y++) {
      for (var x = 0; x < 100; x++) {
        expect(
          pixels.rgba(x, y),
          y == 0 ? [255, 255, 255, 255] : [0, 0, 0, 255],
        );
      }
    }
  });
}
