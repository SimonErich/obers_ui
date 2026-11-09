import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump_app.dart';

/// Exact straight-alpha pixels captured through a public widget paint seam.
class PaintPixels {
  /// Creates a raster of [width] by [height] pixels.
  const PaintPixels(this.width, this.height, this.bytes);

  /// Raster width in pixels.
  final int width;

  /// Raster height in pixels.
  final int height;

  /// Straight RGBA bytes, in row-major order.
  final Uint8List bytes;

  /// Decodes an independently captured PNG without resizing or filtering.
  static Future<PaintPixels> readPng(String path) async {
    final codec = await ui.instantiateImageCodec(
      await File(path).readAsBytes(),
    );
    final image = (await codec.getNextFrame()).image;
    final data = await image.toByteData(
      format: ui.ImageByteFormat.rawStraightRgba,
    );
    final pixels = PaintPixels(
      image.width,
      image.height,
      data!.buffer.asUint8List(),
    );
    image.dispose();
    codec.dispose();
    return pixels;
  }

  /// Returns the four channels of a single pixel.
  List<int> rgba(int x, int y) =>
      bytes.sublist((y * width + x) * 4, (y * width + x + 1) * 4);

  /// Noncryptographic fingerprint for pre-change legacy raster regression.
  int get fingerprint {
    var hash = 0x811c9dc5;
    for (final byte in bytes) {
      hash = ((hash ^ byte) * 0x01000193) & 0xffffffff;
    }
    return hash;
  }
}

/// Deterministic DPR1 paint capture, with real widget layering and clipping.
extension PaintCapture on WidgetTester {
  /// Captures [child] in a fixed-size, text-free repaint boundary.
  Future<PaintPixels> capturePaint(
    Widget child, {
    Size size = const Size(160, 100),
    String? evidencePath,
  }) async {
    const key = ValueKey('paint-capture');
    await pumpObers(
      Center(
        child: RepaintBoundary(
          key: key,
          child: SizedBox.fromSize(size: size, child: child),
        ),
      ),
      surfaceSize: size,
    );
    await pump();
    final boundary = renderObject<RenderRepaintBoundary>(find.byKey(key));
    return (await runAsync(() async {
      final image = await boundary.toImage();
      final data = await image.toByteData(
        format: ui.ImageByteFormat.rawStraightRgba,
      );
      final pixels = PaintPixels(
        image.width,
        image.height,
        data!.buffer.asUint8List(),
      );
      if (evidencePath != null) {
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        final output = File(evidencePath);
        await output.parent.create(recursive: true);
        await output.writeAsBytes(png!.buffer.asUint8List());
      }
      image.dispose();
      return pixels;
    }))!;
  }
}
