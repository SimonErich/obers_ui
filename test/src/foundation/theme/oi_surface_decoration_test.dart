import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/paint_pixels.dart';

void main() {
  testWidgets(
    'large offsets and empty or expanded holes respect every clip pixel',
    (
      tester,
    ) async {
      final shadows = [
        OiInsetShadow(
          color: const Color(0xFFFFFFFF),
          offset: const Offset(200, 0),
        ),
        OiInsetShadow(
          color: const Color(0xFFFFFFFF),
          offset: const Offset(-200, 0),
        ),
        OiInsetShadow(
          color: const Color(0xFFFFFFFF),
          offset: const Offset(0, 200),
        ),
        OiInsetShadow(
          color: const Color(0xFFFFFFFF),
          offset: const Offset(0, -200),
        ),
        OiInsetShadow(color: const Color(0xFFFFFFFF), spread: 100),
        OiInsetShadow(
          color: const Color(0xFFFFFFFF),
          spread: 100,
          blurSigma: 1,
        ),
        OiInsetShadow(color: const Color(0xFFFFFFFF), spread: -100),
      ];
      for (final shadow in shadows) {
        final pixels = await tester.capturePaint(
          Center(
            child: SizedBox(
              width: 100,
              height: 64,
              child: DecoratedBox(
                decoration: OiSurfaceDecoration(
                  base: const BoxDecoration(color: Color(0xFF000000)),
                  insetShadows: [shadow],
                ),
              ),
            ),
          ),
          size: const Size(132, 96),
        );
        for (var y = 0; y < 96; y++) {
          for (var x = 0; x < 132; x++) {
            final inside = x >= 16 && x < 116 && y >= 16 && y < 80;
            expect(
              pixels.rgba(x, y),
              !inside
                  ? [0, 0, 0, 0]
                  : shadow.spread < 0
                  ? [0, 0, 0, 255]
                  : [255, 255, 255, 255],
              reason:
                  '${shadow.offset} ${shadow.spread} ${shadow.blurSigma}: $x,$y',
            );
          }
        }
      }
    },
  );

  testWidgets('loaded images retain native raster through collapsed resize', (
    tester,
  ) async {
    final provider = MemoryImage(
      (await tester.runAsync(
        () => File('test/assets/paint/f4a/sharp.png').readAsBytes(),
      ))!,
    );
    await tester.capturePaint(const SizedBox());
    await tester.runAsync(
      () => precacheImage(
        provider,
        tester.element(find.byType(RepaintBoundary).first),
      ),
    );
    for (final shape in BoxShape.values) {
      final base = BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF131417), Color(0xFF336699)],
        ),
        image: DecorationImage(image: provider, fit: BoxFit.fill),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0xFFFF0000), width: 8),
        ),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? const BorderRadius.all(Radius.circular(14))
            : null,
      );
      final native = base.createBoxPainter(() {});
      final adapted = OiSurfaceDecoration(
        base: base,
        insetShadows: [OiInsetShadow(color: const Color(0x00000000))],
      ).createBoxPainter(() {});
      addTearDown(native.dispose);
      addTearDown(adapted.dispose);
      for (final size in const [
        Size(8, 8),
        Size(100, 64),
        Size(8, 8),
        Size(100, 64),
      ]) {
        final nativePixels = await tester.capturePaint(
          CustomPaint(painter: _BoxPainterProbe(native)),
          size: size,
        );
        final adaptedPixels = await tester.capturePaint(
          CustomPaint(painter: _BoxPainterProbe(adapted)),
          size: size,
        );
        expect(adaptedPixels.bytes, nativePixels.bytes, reason: '$shape $size');
      }
    }
    addTearDown(provider.evict);
  });

  testWidgets(
    'collapsed and nonempty resize retains native async image lifecycle',
    (tester) async {
      final nativeReady = Completer<ImageInfo>();
      final adaptedReady = Completer<ImageInfo>();
      final nativeStream = OneFrameImageStreamCompleter(nativeReady.future);
      final adaptedStream = OneFrameImageStreamCompleter(adaptedReady.future);
      final nativeProvider = _ControlledImageProvider(nativeStream);
      final adaptedProvider = _ControlledImageProvider(adaptedStream);
      BoxDecoration base(ImageProvider provider) => BoxDecoration(
        color: const Color(0xFF000000),
        image: DecorationImage(image: provider, fit: BoxFit.fill),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0xFFFF0000), width: 8),
        ),
      );
      var nativeChanges = 0;
      var adaptedChanges = 0;
      final native = base(
        nativeProvider,
      ).createBoxPainter(() => nativeChanges++);
      final adapted = OiSurfaceDecoration(
        base: base(adaptedProvider),
        insetShadows: [OiInsetShadow(color: const Color(0x00000000))],
      ).createBoxPainter(() => adaptedChanges++);
      addTearDown(() async {
        native.dispose();
        adapted.dispose();
        expect(nativeStream.hasListeners, isFalse);
        expect(adaptedStream.hasListeners, isFalse);
        await nativeProvider.evict();
        await adaptedProvider.evict();
      });
      for (final size in const [
        Size(8, 8),
        Size(100, 64),
        Size(8, 8),
        Size(100, 64),
      ]) {
        for (final painter in [native, adapted]) {
          final recorder = ui.PictureRecorder();
          painter.paint(
            Canvas(recorder),
            Offset.zero,
            ImageConfiguration(size: size, textDirection: TextDirection.ltr),
          );
          recorder.endRecording().dispose();
        }
      }
      expect(nativeStream.hasListeners, isTrue);
      expect(adaptedStream.hasListeners, isTrue);
      final image = (await tester.runAsync(() async {
        final codec = await ui.instantiateImageCodec(
          await File('test/assets/paint/f4a/sharp.png').readAsBytes(),
        );
        final image = (await codec.getNextFrame()).image;
        codec.dispose();
        return image;
      }))!;
      nativeReady.complete(ImageInfo(image: image));
      adaptedReady.complete(ImageInfo(image: image.clone()));
      await tester.pump();
      expect(nativeChanges, 1);
      expect(adaptedChanges, nativeChanges);
    },
  );

  testWidgets(
    'native border side opacity, none style, stroke alignment and RTL retain base raster',
    (tester) async {
      for (final direction in TextDirection.values) {
        for (final border in <BoxBorder>[
          for (final alignment in [-1.0, 0.0, 1.0])
            Border.fromBorderSide(
              BorderSide(
                color: const Color(0xFFFF0000),
                width: 2,
                strokeAlign: alignment,
              ),
            ),
          Border.all(color: const Color(0x80FF0000), width: 2),
          const Border.fromBorderSide(
            BorderSide(
              color: Color(0xFFFF0000),
              width: 2,
              style: BorderStyle.none,
            ),
          ),
          const BorderDirectional(
            start: BorderSide(color: Color(0xFFFF0000), width: 2),
            end: BorderSide(color: Color(0xFFFF0000), width: 4),
            top: BorderSide(color: Color(0xFFFF0000)),
            bottom: BorderSide(color: Color(0xFFFF0000), width: 3),
          ),
          for (final side in const [
            BorderSide(color: Color(0x80FF0000), width: 2),
            BorderSide(
              color: Color(0xFFFF0000),
              width: 2,
              style: BorderStyle.none,
            ),
          ])
            BorderDirectional(top: side, start: side, end: side, bottom: side),
        ]) {
          final base = BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF131417), Color(0xFF336699)],
            ),
            borderRadius: const BorderRadiusDirectional.only(
              topStart: Radius.elliptical(14, 10),
              bottomEnd: Radius.circular(8),
            ),
            border: border,
          );
          final legacy = await tester.capturePaint(
            Directionality(
              textDirection: direction,
              child: DecoratedBox(decoration: base),
            ),
            size: const Size(100, 64),
          );
          final adapted = await tester.capturePaint(
            Directionality(
              textDirection: direction,
              child: DecoratedBox(
                decoration: OiSurfaceDecoration(
                  base: base,
                  insetShadows: [
                    OiInsetShadow(color: const Color(0x00000000), spread: 2),
                  ],
                ),
              ),
            ),
            size: const Size(100, 64),
          );
          expect(adapted.bytes, legacy.bytes, reason: '$direction $border');
        }
      }
    },
  );

  testWidgets(
    'custom borders preserve asymmetric padding, base raster, and exactly one paint',
    (tester) async {
      final count = ValueNotifier(0);
      final border = _CountingBoxBorder(
        const Border(
          top: BorderSide(color: Color(0xFFFF0000), width: 3),
          bottom: BorderSide(color: Color(0xFFFF0000), width: 5),
          left: BorderSide(color: Color(0xFFFF0000), width: 2),
          right: BorderSide(color: Color(0xFFFF0000), width: 4),
        ),
        count,
      );
      final base = BoxDecoration(
        color: const Color(0xFF131417),
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        border: border,
      );
      final decoration = OiSurfaceDecoration(
        base: base,
        insetShadows: [
          OiInsetShadow(color: const Color(0x00000000), spread: 2),
        ],
      );
      final legacy = await tester.capturePaint(
        DecoratedBox(decoration: base),
        size: const Size(100, 64),
      );
      count.value = 0;
      const childKey = ValueKey('custom-border-padding');
      final adapted = await tester.capturePaint(
        Container(
          padding: EdgeInsets.zero,
          decoration: decoration,
          child: const SizedBox.expand(key: childKey),
        ),
        size: const Size(100, 64),
      );
      expect(count.value, 1);
      expect(adapted.bytes, legacy.bytes);
      expect(decoration.padding, const EdgeInsets.fromLTRB(2, 3, 4, 5));
      expect(
        tester.getRect(find.byKey(childKey)),
        const Rect.fromLTWH(2, 3, 94, 56),
      );
      count.dispose();
    },
  );

  testWidgets(
    'transparent inset preserves the actual opaque rounded-border background raster',
    (tester) async {
      const base = BoxDecoration(
        color: Color(0xFF131417),
        borderRadius: BorderRadius.all(Radius.circular(14)),
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFFFF0000), width: 2),
        ),
      );
      final legacy = await tester.capturePaint(
        const DecoratedBox(decoration: base),
        size: const Size(100, 64),
      );
      final adapted = await tester.capturePaint(
        DecoratedBox(
          decoration: OiSurfaceDecoration(
            base: base,
            insetShadows: [
              OiInsetShadow(color: const Color(0x00000000), spread: 1),
            ],
          ),
        ),
        size: const Size(100, 64),
      );
      expect(adapted.bytes, legacy.bytes);
    },
  );

  testWidgets(
    'zero and collapsed padding shapes paint without leaking inset color',
    (tester) async {
      final decoration = OiSurfaceDecoration(
        base: const BoxDecoration(
          color: Color(0xFF000000),
          border: Border.fromBorderSide(
            BorderSide(color: Color(0xFFFF0000), width: 8),
          ),
        ),
        insetShadows: [
          OiInsetShadow(
            color: const Color(0xFFFFFFFF),
            spread: 100,
            blurSigma: 1,
          ),
        ],
      );
      final painter = decoration.createBoxPainter();
      final recorder = ui.PictureRecorder();
      painter.paint(
        Canvas(recorder),
        Offset.zero,
        const ImageConfiguration(
          size: Size.zero,
          textDirection: TextDirection.ltr,
        ),
      );
      recorder.endRecording().dispose();
      painter.dispose();
      final pixels = await tester.capturePaint(
        DecoratedBox(decoration: decoration),
        size: const Size(8, 8),
      );
      final legacy = await tester.capturePaint(
        DecoratedBox(decoration: decoration.base),
        size: const Size(8, 8),
      );
      // Preserve the actual base painter's oversized-border behavior rather
      // than assuming a border wider than its box must fill that box red.
      expect(pixels.bytes, legacy.bytes);
    },
  );

  testWidgets(
    'image overlays the gradient but remains beneath inset and border paint',
    (tester) async {
      final provider = MemoryImage(
        (await tester.runAsync(
          () => File('test/assets/paint/f4a/sharp.png').readAsBytes(),
        ))!,
      );
      final decoration = OiSurfaceDecoration(
        base: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF0000), Color(0xFFFF0000)],
          ),
          image: DecorationImage(image: provider, fit: BoxFit.fill),
          border: const Border.fromBorderSide(
            BorderSide(color: Color(0xFF0000FF)),
          ),
        ),
        insetShadows: [
          OiInsetShadow(
            color: const Color(0xFF00FF00),
            offset: const Offset(0, 1),
          ),
        ],
      );
      await tester.capturePaint(
        DecoratedBox(decoration: decoration),
        size: const Size(100, 64),
      );
      await tester.runAsync(
        () => precacheImage(
          provider,
          tester.element(find.byType(DecoratedBox).last),
        ),
      );
      final pixels = await tester.capturePaint(
        DecoratedBox(decoration: decoration),
        size: const Size(100, 64),
      );
      for (var y = 0; y < 64; y++) {
        for (var x = 0; x < 100; x++) {
          final perimeter = x == 0 || x == 99 || y == 0 || y == 63;
          expect(
            pixels.rgba(x, y),
            perimeter
                ? [0, 0, 255, 255]
                : y == 1
                ? [0, 255, 0, 255]
                : [0, 0, 0, 255],
            reason: '$x,$y',
          );
        }
      }
      await provider.evict();
    },
  );

  testWidgets(
    'asynchronous decoration images notify changes and release listeners on dispose',
    (tester) async {
      final imageReady = Completer<ImageInfo>();
      final stream = OneFrameImageStreamCompleter(imageReady.future);
      final provider = _ControlledImageProvider(stream);
      var changes = 0;
      final painter = OiSurfaceDecoration(
        base: BoxDecoration(image: DecorationImage(image: provider)),
        insetShadows: [
          OiInsetShadow(color: const Color(0xFFFFFFFF), spread: 1),
        ],
      ).createBoxPainter(() => changes++);
      final recorder = ui.PictureRecorder();
      painter.paint(
        Canvas(recorder),
        Offset.zero,
        const ImageConfiguration(
          size: Size(100, 64),
          textDirection: TextDirection.ltr,
        ),
      );
      recorder.endRecording().dispose();
      expect(stream.hasListeners, isTrue);
      final image = (await tester.runAsync(() async {
        final codec = await ui.instantiateImageCodec(
          await File('test/assets/paint/f4a/sharp.png').readAsBytes(),
        );
        final image = (await codec.getNextFrame()).image;
        codec.dispose();
        return image;
      }))!;
      imageReady.complete(ImageInfo(image: image));
      await tester.pump();
      expect(changes, 1);
      painter.dispose();
      expect(stream.hasListeners, isFalse);
      await provider.evict();
    },
  );

  testWidgets(
    'directional borders and asymmetric corners retain padding and inset geometry',
    (tester) async {
      for (final direction in TextDirection.values) {
        const key = ValueKey('directional-padding-child');
        final pixels = await tester.capturePaint(
          Directionality(
            textDirection: direction,
            child: Container(
              padding: EdgeInsets.zero,
              decoration: OiSurfaceDecoration(
                base: const BoxDecoration(
                  color: Color(0xFF000000),
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.elliptical(20, 12),
                  ),
                  border: BorderDirectional(
                    start: BorderSide(color: Color(0xFFFF0000), width: 2),
                    end: BorderSide(color: Color(0xFFFF0000), width: 4),
                    top: BorderSide(color: Color(0xFFFF0000)),
                    bottom: BorderSide(color: Color(0xFFFF0000), width: 3),
                  ),
                ),
                insetShadows: [
                  OiInsetShadow(color: const Color(0xFFFFFFFF), spread: 2),
                ],
              ),
              child: const SizedBox.expand(key: key),
            ),
          ),
          size: const Size(100, 64),
        );
        expect(
          tester.getRect(find.byKey(key)),
          Rect.fromLTWH(direction == TextDirection.ltr ? 2 : 4, 1, 94, 60),
        );
        expect(pixels.rgba(50, 1), [255, 255, 255, 255]);
        expect(pixels.rgba(50, 0), [255, 0, 0, 255]);
        expect(pixels.rgba(direction == TextDirection.ltr ? 0 : 99, 0)[3], 0);
        expect(pixels.rgba(direction == TextDirection.ltr ? 99 : 0, 0), [
          255,
          0,
          0,
          255,
        ]);
      }
    },
  );

  testWidgets(
    'inset shadows preserve signed spread, offsets, front-to-back alpha, and child layering',
    (tester) async {
      final first = OiInsetShadow(color: const Color(0x80FF0000), spread: 2);
      final second = OiInsetShadow(color: const Color(0x800000FF), spread: 2);
      final layered = await tester.capturePaint(
        DecoratedBox(
          decoration: OiSurfaceDecoration(
            base: const BoxDecoration(color: Color(0xFF000000)),
            insetShadows: [first, second],
          ),
        ),
        size: const Size(100, 64),
      );
      expect(layered.rgba(50, 0), [128, 0, 64, 255]);
      expect(layered.rgba(50, 32), [0, 0, 0, 255]);
      for (final shadow in [
        OiInsetShadow(color: const Color(0xFFFFFFFF), spread: -2),
        OiInsetShadow(
          color: const Color(0xFFFFFFFF),
          offset: const Offset(0, -1),
        ),
        OiInsetShadow(color: const Color(0xFFFFFFFF), spread: 100),
      ]) {
        final pixels = await tester.capturePaint(
          DecoratedBox(
            decoration: OiSurfaceDecoration(
              base: const BoxDecoration(color: Color(0xFF000000)),
              insetShadows: [shadow],
            ),
          ),
          size: const Size(100, 64),
        );
        expect(
          pixels.rgba(50, 0),
          shadow.spread == 100 ? [255, 255, 255, 255] : [0, 0, 0, 255],
        );
        expect(
          pixels.rgba(50, 63),
          shadow.spread == -2 ? [0, 0, 0, 255] : [255, 255, 255, 255],
        );
      }
      final child = await tester.capturePaint(
        DecoratedBox(
          decoration: OiSurfaceDecoration(
            base: const BoxDecoration(color: Color(0xFF000000)),
            insetShadows: [first, second],
          ),
          child: const ColoredBox(color: Color(0xFF00FF00)),
        ),
        size: const Size(100, 64),
      );
      expect(child.bytes, everyElement(isIn([0, 255])));
      expect(child.rgba(50, 0), [0, 255, 0, 255]);
    },
  );

  test('empty inset decoration uses the unmodified base painter path', () {
    const base = BoxDecoration(
      color: Color(0xFF123456),
      border: Border.fromBorderSide(BorderSide(width: 2)),
    );
    final legacy = base.createBoxPainter();
    final empty = OiSurfaceDecoration(base: base).createBoxPainter();
    addTearDown(legacy.dispose);
    addTearDown(empty.dispose);
    expect(empty.runtimeType, legacy.runtimeType);
  });

  test(
    'Decoration.lerp blends base values and transparently pads unequal inset lists',
    () {
      final first = OiInsetShadow(
        color: const Color(0xFFFFFFFF),
        offset: const Offset(0, 2),
      );
      final extra = OiInsetShadow(color: const Color(0xFFFF0000), spread: 4);
      final a = OiSurfaceDecoration(
        base: const BoxDecoration(color: Color(0xFF000000)),
        insetShadows: [first],
      );
      final b = OiSurfaceDecoration(
        base: const BoxDecoration(color: Color(0xFFFFFFFF)),
        insetShadows: [first, extra],
      );
      final middle = Decoration.lerp(a, b, .5)! as OiSurfaceDecoration;
      expect(
        middle.base.color,
        const Color.from(alpha: 1, red: .5, green: .5, blue: .5),
      );
      expect(middle.insetShadows, [first, OiInsetShadow.lerp(null, extra, .5)]);
      expect(OiSurfaceDecoration.lerp(a, b, 0), same(a));
      expect(OiSurfaceDecoration.lerp(a, b, 1), same(b));
      expect(OiSurfaceDecoration.lerp(null, null, .5), isNull);
      final fromBox = Decoration.lerp(a.base, b, .5)! as OiSurfaceDecoration;
      expect(fromBox.insetShadows[0].color.a, .5);
      final toBox = Decoration.lerp(b, a.base, .5)! as OiSurfaceDecoration;
      expect(toBox, fromBox);
      expect(Decoration.lerp(null, b, .5)!.isComplex, isTrue);
      expect(Decoration.lerp(b, null, .5)!.isComplex, isTrue);
      expect(
        () => OiSurfaceDecoration.lerp(a, b, double.infinity),
        throwsArgumentError,
      );
    },
  );

  test('surface decoration copies and compares authored values', () {
    final inset = OiInsetShadow(color: const Color(0xFFFFFFFF), spread: 1);
    final decoration = OiSurfaceDecoration(
      base: const BoxDecoration(color: Color(0xFF000000)),
      insetShadows: [inset],
    );
    final copy = decoration.copyWith();
    expect(copy, decoration);
    expect(copy.hashCode, decoration.hashCode);
    expect(copy.copyWith(insetShadows: []).insetShadows, isEmpty);
    expect(
      copy.copyWith(base: const BoxDecoration(color: Color(0xFFFF0000))),
      isNot(decoration),
    );
    expect(
      copy.copyWith(insetShadows: [inset.copyWith(spread: 2)]),
      isNot(decoration),
    );
    expect(decoration == Object(), isFalse);
  });

  testWidgets('Gaussian inset blur reaches inside an untranslated hole', (
    tester,
  ) async {
    final pixels = await tester.capturePaint(
      DecoratedBox(
        decoration: OiSurfaceDecoration(
          base: const BoxDecoration(color: Color(0xFF000000)),
          insetShadows: [
            OiInsetShadow(color: const Color(0xFFFFFFFF), blurSigma: 1),
          ],
        ),
      ),
      size: const Size(100, 64),
    );
    // An unshifted sharp hole has no interior shadow; convolution of its
    // exterior must reach the edge without filling the distant center.
    expect(pixels.rgba(50, 0)[0], greaterThan(0));
    expect(pixels.rgba(50, 0)[0], lessThan(255));
    expect(pixels.rgba(50, 32), [0, 0, 0, 255]);
  });

  testWidgets('inset painting respects rounded and circular padding shapes', (
    tester,
  ) async {
    for (final base in [
      const BoxDecoration(
        color: Color(0xFFFF0000),
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      const BoxDecoration(color: Color(0xFFFF0000), shape: BoxShape.circle),
    ]) {
      final pixels = await tester.capturePaint(
        ColoredBox(
          color: const Color(0xFF000000),
          child: DecoratedBox(
            decoration: OiSurfaceDecoration(
              base: base,
              insetShadows: [
                OiInsetShadow(color: const Color(0xFFFFFFFF), spread: 3),
              ],
            ),
          ),
        ),
        size: const Size(100, 64),
      );
      expect(pixels.rgba(0, 0), [0, 0, 0, 255]);
      // y1 is fully inside both shapes; y0 is the circle's antialiased edge.
      // The separate Chrome comparison includes every edge pixel unchanged.
      expect(pixels.rgba(50, 1), [255, 255, 255, 255]);
      expect(pixels.rgba(50, 32), [255, 0, 0, 255]);
      if (base.shape == BoxShape.circle) {
        expect(pixels.rgba(0, 32), [0, 0, 0, 255]);
      }
    }
  });

  test(
    'surface decoration delegates shape hit testing, clipping, and complexity',
    () {
      const base = BoxDecoration(shape: BoxShape.circle);
      final decoration = OiSurfaceDecoration(
        base: base,
        insetShadows: [OiInsetShadow(color: const Color(0xFFFFFFFF))],
      );
      const size = Size(100, 64);
      expect(decoration.hitTest(size, Offset.zero), isFalse);
      expect(decoration.hitTest(size, const Offset(50, 32)), isTrue);
      final clip = decoration.getClipPath(
        Offset.zero & size,
        TextDirection.ltr,
      );
      expect(clip.contains(Offset.zero), isFalse);
      expect(clip.contains(const Offset(50, 32)), isTrue);
      expect(decoration.isComplex, isTrue);
      expect(OiSurfaceDecoration(base: base).isComplex, base.isComplex);
    },
  );

  testWidgets('surface decoration retains base border padding in real layout', (
    tester,
  ) async {
    const childKey = ValueKey('padding-child');
    await tester.capturePaint(
      Container(
        padding: EdgeInsets.zero,
        decoration: OiSurfaceDecoration(
          base: const BoxDecoration(
            border: Border.fromBorderSide(BorderSide(width: 2)),
          ),
          insetShadows: [OiInsetShadow(color: const Color(0xFFFFFFFF))],
        ),
        child: const SizedBox.expand(key: childKey),
      ),
      size: const Size(100, 64),
    );
    expect(
      tester.getRect(find.byKey(childKey)),
      const Rect.fromLTWH(2, 2, 96, 60),
    );
  });

  test('surface decoration snapshots both caller-owned shadow lists', () {
    final inset = OiInsetShadow(color: const Color(0xFFFFFFFF));
    const outer = BoxShadow();
    final insets = [inset];
    final outers = [outer];
    final decoration = OiSurfaceDecoration(
      base: BoxDecoration(boxShadow: outers),
      insetShadows: insets,
    );
    insets.clear();
    outers.clear();
    expect(decoration.insetShadows, [inset]);
    expect(decoration.base.boxShadow, [outer]);
    expect(decoration.insetShadows.clear, throwsUnsupportedError);
    expect(decoration.base.boxShadow!.clear, throwsUnsupportedError);
  });

  testWidgets(
    'sharp inset matches every pixel of the independent Chrome mask',
    (tester) async {
      final decoration = OiSurfaceDecoration(
        base: const BoxDecoration(color: Color(0xFF000000)),
        insetShadows: [
          OiInsetShadow(
            color: const Color(0xFFFFFFFF),
            offset: const Offset(0, 1),
          ),
        ],
      );
      final pixels = await tester.capturePaint(
        DecoratedBox(decoration: decoration),
        size: const Size(100, 64),
      );
      // Parent-owned Chrome154 pass3/pass4 sharp crops: all6400 pixels checked.
      for (var y = 0; y < 64; y++) {
        for (var x = 0; x < 100; x++) {
          expect(
            pixels.rgba(x, y),
            y == 0 ? [255, 255, 255, 255] : [0, 0, 0, 255],
            reason: '$x,$y',
          );
        }
      }
    },
  );

  testWidgets(
    'inset clips to padding edge beneath the independent Chrome border',
    (tester) async {
      final pixels = await tester.capturePaint(
        DecoratedBox(
          decoration: OiSurfaceDecoration(
            base: const BoxDecoration(
              color: Color(0xFF000000),
              border: Border.fromBorderSide(
                BorderSide(color: Color(0xFFFF0000), width: 2),
              ),
            ),
            insetShadows: [
              OiInsetShadow(
                color: const Color(0xFFFFFFFF),
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        size: const Size(100, 64),
      );
      // Literal masks independently verified in both parent Chrome captures.
      for (var y = 0; y < 64; y++) {
        for (var x = 0; x < 100; x++) {
          final perimeter = x < 2 || x >= 98 || y < 2 || y >= 62;
          expect(
            pixels.rgba(x, y),
            perimeter
                ? [255, 0, 0, 255]
                : y == 2
                ? [255, 255, 255, 255]
                : [0, 0, 0, 255],
            reason: '$x,$y',
          );
        }
      }
    },
  );
}

class _BoxPainterProbe extends CustomPainter {
  const _BoxPainterProbe(this.painter);

  final BoxPainter painter;

  @override
  void paint(Canvas canvas, Size size) => painter.paint(
    canvas,
    Offset.zero,
    ImageConfiguration(size: size, textDirection: TextDirection.ltr),
  );

  @override
  bool shouldRepaint(_BoxPainterProbe oldDelegate) => true;
}

class _ControlledImageProvider extends ImageProvider<_ControlledImageProvider> {
  const _ControlledImageProvider(this.stream);

  final ImageStreamCompleter stream;

  @override
  Future<_ControlledImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) => SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _ControlledImageProvider key,
    ImageDecoderCallback decode,
  ) => stream;
}

class _CountingBoxBorder extends BoxBorder {
  const _CountingBoxBorder(this.border, this.count);
  final Border border;
  final ValueNotifier<int> count;

  @override
  BorderSide get top => border.top;
  @override
  BorderSide get bottom => border.bottom;
  @override
  bool get isUniform => border.isUniform;
  @override
  EdgeInsetsGeometry get dimensions => border.dimensions;
  @override
  BoxBorder scale(double t) => _CountingBoxBorder(border.scale(t), count);
  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    count.value++;
    border.paint(
      canvas,
      rect,
      textDirection: textDirection,
      shape: shape,
      borderRadius: borderRadius,
    );
  }
}
