import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// The result of a crop operation.
///
/// {@category Composites}
@immutable
class OiCropResult {
  /// Creates an [OiCropResult].
  const OiCropResult({
    required this.rect,
    this.rotation = 0,
    this.flippedHorizontal = false,
    this.flippedVertical = false,
  });

  /// The crop rectangle in logical pixels relative to the image bounds.
  final Rect rect;

  /// The rotation angle in radians.
  final double rotation;

  /// Whether the image is flipped horizontally.
  final bool flippedHorizontal;

  /// Whether the image is flipped vertically.
  final bool flippedVertical;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiCropResult &&
          rect == other.rect &&
          rotation == other.rotation &&
          flippedHorizontal == other.flippedHorizontal &&
          flippedVertical == other.flippedVertical;

  @override
  int get hashCode => Object.hash(rect, rotation, flippedHorizontal, flippedVertical);

  @override
  String toString() =>
      'OiCropResult(rect: $rect, rotation: $rotation, '
      'flippedH: $flippedHorizontal, flippedV: $flippedVertical)';
}

/// Image crop tool with aspect ratio lock, rotate, and flip.
///
/// Renders an image with a draggable crop area overlay. Users can drag the
/// crop handles to adjust the crop region, rotate the image in 90-degree
/// increments, and flip horizontally or vertically.
///
/// {@category Composites}
class OiImageCropper extends StatefulWidget {
  /// Creates an [OiImageCropper].
  const OiImageCropper({
    required this.image,
    required this.label,
    this.onCrop,
    this.aspectRatio,
    this.aspectRatioOptions,
    this.enableRotate = true,
    this.enableFlip = true,
    super.key,
  });

  /// The image to crop.
  final ImageProvider image;

  /// Called with the [OiCropResult] when the user confirms the crop.
  final ValueChanged<OiCropResult>? onCrop;

  /// When non-null, the crop rectangle is constrained to this aspect ratio
  /// (width / height).
  final double? aspectRatio;

  /// An optional list of aspect ratio presets for the user to choose from.
  final List<double>? aspectRatioOptions;

  /// Whether the rotate control is shown.
  final bool enableRotate;

  /// Whether the flip controls are shown.
  final bool enableFlip;

  /// Semantic label for the cropper widget.
  final String label;

  @override
  State<OiImageCropper> createState() => _OiImageCropperState();
}

class _OiImageCropperState extends State<OiImageCropper> {
  /// The crop rectangle in normalized coordinates (0..1).
  Rect _cropRect = const Rect.fromLTWH(0.1, 0.1, 0.8, 0.8);

  /// Current rotation in 90-degree steps (0, 1, 2, or 3).
  int _rotationSteps = 0;

  /// Whether the image is flipped horizontally.
  bool _flippedH = false;

  /// Whether the image is flipped vertically.
  bool _flippedV = false;

  /// The currently enforced aspect ratio, if any.
  double? _activeAspectRatio;

  @override
  void initState() {
    super.initState();
    _activeAspectRatio = widget.aspectRatio;
    if (_activeAspectRatio != null) {
      _applyCropAspectRatio();
    }
  }

  /// Rotation in radians.
  double get _rotationRadians => _rotationSteps * (math.pi / 2);

  void _rotate() {
    setState(() {
      _rotationSteps = (_rotationSteps + 1) % 4;
    });
  }

  void _flipHorizontal() {
    setState(() => _flippedH = !_flippedH);
  }

  void _flipVertical() {
    setState(() => _flippedV = !_flippedV);
  }

  void _applyCropAspectRatio() {
    final ar = _activeAspectRatio;
    if (ar == null) return;
    // Adjust crop rect to match aspect ratio while staying within bounds.
    final cx = _cropRect.center.dx;
    final cy = _cropRect.center.dy;
    var w = _cropRect.width;
    var h = w / ar;
    if (h > 0.8) {
      h = 0.8;
      w = h * ar;
    }
    if (w > 0.8) {
      w = 0.8;
      h = w / ar;
    }
    final left = (cx - w / 2).clamp(0.0, 1.0 - w);
    final top = (cy - h / 2).clamp(0.0, 1.0 - h);
    _cropRect = Rect.fromLTWH(left, top, w, h);
  }

  void _onConfirm() {
    widget.onCrop?.call(
      OiCropResult(
        rect: _cropRect,
        rotation: _rotationRadians,
        flippedHorizontal: _flippedH,
        flippedVertical: _flippedV,
      ),
    );
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (size.width == 0 || size.height == 0) return;
    setState(() {
      final dx = details.delta.dx / size.width;
      final dy = details.delta.dy / size.height;
      _cropRect = Rect.fromLTWH(
        (_cropRect.left + dx).clamp(0.0, 1.0 - _cropRect.width),
        (_cropRect.top + dy).clamp(0.0, 1.0 - _cropRect.height),
        _cropRect.width,
        _cropRect.height,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Semantics(
      label: widget.label,
      child: Column(
        key: const Key('oi_image_cropper'),
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image with crop overlay
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                return Stack(
                  children: [
                    // Background image
                    Positioned.fill(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..rotateZ(_rotationRadians)
                          ..scaleByDouble(_flippedH ? -1.0 : 1.0, _flippedV ? -1.0 : 1.0, 1, 1),
                        child: Image(
                          key: const Key('oi_image_cropper_image'),
                          image: widget.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Dark overlay outside crop area
                    Positioned.fill(
                      child: CustomPaint(
                        key: const Key('oi_image_cropper_overlay'),
                        painter: _CropOverlayPainter(
                          cropRect: _cropRect,
                          overlayColor: const Color(0x88000000),
                        ),
                      ),
                    ),

                    // Draggable crop area
                    Positioned(
                      left: _cropRect.left * size.width,
                      top: _cropRect.top * size.height,
                      width: _cropRect.width * size.width,
                      height: _cropRect.height * size.height,
                      child: GestureDetector(
                        key: const Key('oi_image_cropper_handle'),
                        onPanUpdate: (d) => _onPanUpdate(d, size),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colors.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.enableRotate)
                  GestureDetector(
                    key: const Key('oi_image_cropper_rotate'),
                    onTap: _rotate,
                    child: Semantics(
                      label: 'Rotate image',
                      button: true,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.surfaceHover,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '\u21BB',
                            style: TextStyle(fontSize: 20, color: colors.text),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.enableRotate) const SizedBox(width: 8),
                if (widget.enableFlip) ...[
                  GestureDetector(
                    key: const Key('oi_image_cropper_flip_h'),
                    onTap: _flipHorizontal,
                    child: Semantics(
                      label: 'Flip horizontal',
                      button: true,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.surfaceHover,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '\u2194',
                            style: TextStyle(fontSize: 20, color: colors.text),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    key: const Key('oi_image_cropper_flip_v'),
                    onTap: _flipVertical,
                    child: Semantics(
                      label: 'Flip vertical',
                      button: true,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.surfaceHover,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '\u2195',
                            style: TextStyle(fontSize: 20, color: colors.text),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Aspect ratio selector
                if (widget.aspectRatioOptions != null)
                  ...widget.aspectRatioOptions!.map((ar) {
                    final isActive = _activeAspectRatio == ar;
                    final arLabel = ar == 1.0
                        ? '1:1'
                        : ar == 16 / 9
                            ? '16:9'
                            : ar == 4 / 3
                                ? '4:3'
                                : ar.toStringAsFixed(2);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeAspectRatio = isActive ? null : ar;
                            if (_activeAspectRatio != null) {
                              _applyCropAspectRatio();
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? colors.primary.base
                                : colors.surfaceHover,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            arLabel,
                            style: textTheme.small.copyWith(
                              color: isActive
                                  ? colors.textOnPrimary
                                  : colors.text,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                const Spacer(),
                // Confirm button
                GestureDetector(
                  key: const Key('oi_image_cropper_confirm'),
                  onTap: _onConfirm,
                  child: Semantics(
                    label: 'Confirm crop',
                    button: true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.base,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Crop',
                        style: textTheme.body.copyWith(
                          color: colors.textOnPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a dark overlay outside the crop rectangle.
class _CropOverlayPainter extends CustomPainter {
  /// Creates a [_CropOverlayPainter].
  const _CropOverlayPainter({
    required this.cropRect,
    required this.overlayColor,
  });

  /// The normalised crop rectangle (values 0..1).
  final Rect cropRect;

  /// The colour of the overlay outside the crop area.
  final Color overlayColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;
    final crop = Rect.fromLTWH(
      cropRect.left * size.width,
      cropRect.top * size.height,
      cropRect.width * size.width,
      cropRect.height * size.height,
    );

    // Paint four rectangles around the crop area.
    canvas
      // Top
      ..drawRect(Rect.fromLTRB(0, 0, size.width, crop.top), paint)
      // Bottom
      ..drawRect(Rect.fromLTRB(0, crop.bottom, size.width, size.height), paint)
      // Left
      ..drawRect(Rect.fromLTRB(0, crop.top, crop.left, crop.bottom), paint)
      // Right
      ..drawRect(Rect.fromLTRB(crop.right, crop.top, size.width, crop.bottom), paint);
  }

  @override
  bool shouldRepaint(_CropOverlayPainter oldDelegate) =>
      oldDelegate.cropRect != cropRect ||
      oldDelegate.overlayColor != overlayColor;
}
