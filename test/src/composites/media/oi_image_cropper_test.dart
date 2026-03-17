// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/media/oi_image_cropper.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// A 1x1 red pixel [ImageProvider] for tests.
class _TestImageProvider extends ImageProvider<_TestImageProvider> {
  const _TestImageProvider();

  @override
  Future<_TestImageProvider> obtainKey(ImageConfiguration configuration) async {
    return this;
  }

  @override
  ImageStreamCompleter loadImage(
    _TestImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(_createImage());
  }

  Future<ImageInfo> _createImage() async {
    final recorder = ui.PictureRecorder();
    Canvas(recorder)..drawRect(
      const Rect.fromLTWH(0, 0, 100, 100),
      Paint()..color = const Color(0xFFFF0000),
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(100, 100);
    return ImageInfo(image: image);
  }
}

Widget _cropper({
  ValueChanged<OiCropResult>? onCrop,
  double? aspectRatio,
  List<double>? aspectRatioOptions,
  bool enableRotate = true,
  bool enableFlip = true,
}) {
  return SizedBox(
    width: 400,
    height: 500,
    child: OiImageCropper(
      image: const _TestImageProvider(),
      onCrop: onCrop,
      aspectRatio: aspectRatio,
      aspectRatioOptions: aspectRatioOptions,
      enableRotate: enableRotate,
      enableFlip: enableFlip,
      label: 'Test cropper',
    ),
  );
}

void main() {
  group('OiImageCropper', () {
    testWidgets('renders the cropper widget', (tester) async {
      await tester.pumpObers(_cropper(), surfaceSize: const Size(400, 500));
      await tester.pump();

      expect(find.byKey(const Key('oi_image_cropper')), findsOneWidget);
    });

    testWidgets('image is displayed', (tester) async {
      await tester.pumpObers(_cropper(), surfaceSize: const Size(400, 500));
      await tester.pump();

      expect(find.byKey(const Key('oi_image_cropper_image')), findsOneWidget);
    });

    testWidgets('crop overlay is visible', (tester) async {
      await tester.pumpObers(_cropper(), surfaceSize: const Size(400, 500));
      await tester.pump();

      expect(find.byKey(const Key('oi_image_cropper_overlay')), findsOneWidget);
    });

    testWidgets('crop handle is visible', (tester) async {
      await tester.pumpObers(_cropper(), surfaceSize: const Size(400, 500));
      await tester.pump();

      expect(find.byKey(const Key('oi_image_cropper_handle')), findsOneWidget);
    });

    testWidgets('onCrop fires with result when confirm tapped', (tester) async {
      OiCropResult? result;
      await tester.pumpObers(
        _cropper(onCrop: (r) => result = r),
        surfaceSize: const Size(400, 500),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('oi_image_cropper_confirm')));
      await tester.pump();

      expect(result, isNotNull);
      expect(result!.rect, isA<Rect>());
      expect(result!.rotation, 0);
      expect(result!.flippedHorizontal, isFalse);
      expect(result!.flippedVertical, isFalse);
    });

    testWidgets('rotate button increments rotation', (tester) async {
      OiCropResult? result;
      await tester.pumpObers(
        _cropper(onCrop: (r) => result = r),
        surfaceSize: const Size(400, 500),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('oi_image_cropper_rotate')));
      await tester.pump();

      await tester.tap(find.byKey(const Key('oi_image_cropper_confirm')));
      await tester.pump();

      expect(result, isNotNull);
      expect(result!.rotation, closeTo(math.pi / 2, 0.001));
    });

    testWidgets('flip horizontal toggles flippedHorizontal', (tester) async {
      OiCropResult? result;
      await tester.pumpObers(
        _cropper(onCrop: (r) => result = r),
        surfaceSize: const Size(400, 500),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('oi_image_cropper_flip_h')));
      await tester.pump();

      await tester.tap(find.byKey(const Key('oi_image_cropper_confirm')));
      await tester.pump();

      expect(result!.flippedHorizontal, isTrue);
    });

    testWidgets('flip vertical toggles flippedVertical', (tester) async {
      OiCropResult? result;
      await tester.pumpObers(
        _cropper(onCrop: (r) => result = r),
        surfaceSize: const Size(400, 500),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('oi_image_cropper_flip_v')));
      await tester.pump();

      await tester.tap(find.byKey(const Key('oi_image_cropper_confirm')));
      await tester.pump();

      expect(result!.flippedVertical, isTrue);
    });

    testWidgets('rotate button hidden when enableRotate is false', (
      tester,
    ) async {
      await tester.pumpObers(
        _cropper(enableRotate: false),
        surfaceSize: const Size(400, 500),
      );
      await tester.pump();

      expect(find.byKey(const Key('oi_image_cropper_rotate')), findsNothing);
    });

    testWidgets('flip buttons hidden when enableFlip is false', (tester) async {
      await tester.pumpObers(
        _cropper(enableFlip: false),
        surfaceSize: const Size(400, 500),
      );
      await tester.pump();

      expect(find.byKey(const Key('oi_image_cropper_flip_h')), findsNothing);
      expect(find.byKey(const Key('oi_image_cropper_flip_v')), findsNothing);
    });

    testWidgets('semantics label is applied', (tester) async {
      await tester.pumpObers(_cropper(), surfaceSize: const Size(400, 500));
      await tester.pump();

      expect(find.bySemanticsLabel('Test cropper'), findsOneWidget);
    });

    testWidgets('aspect ratio constrains crop rect', (tester) async {
      OiCropResult? result;
      await tester.pumpObers(
        _cropper(aspectRatio: 1, onCrop: (r) => result = r),
        surfaceSize: const Size(400, 500),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('oi_image_cropper_confirm')));
      await tester.pump();

      expect(result, isNotNull);
      // With 1:1 aspect ratio, width and height of the crop rect should match.
      expect(result!.rect.width, closeTo(result!.rect.height, 0.01));
    });
  });

  group('OiCropResult', () {
    test('equality works', () {
      const a = OiCropResult(rect: Rect.fromLTWH(0, 0, 1, 1));
      const b = OiCropResult(rect: Rect.fromLTWH(0, 0, 1, 1));
      const c = OiCropResult(rect: Rect.fromLTWH(0, 0, 0.5, 1));

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString contains rect', () {
      const r = OiCropResult(rect: Rect.fromLTWH(0.1, 0.2, 0.3, 0.4));
      expect(r.toString(), contains('OiCropResult'));
      expect(r.toString(), contains('rect'));
    });
  });
}
