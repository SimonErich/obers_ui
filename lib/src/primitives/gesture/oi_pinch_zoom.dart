import 'package:flutter/widgets.dart';

/// A widget that wraps its [child] with pinch-to-zoom and optional pan support.
///
/// Uses [GestureDetector] scale callbacks to track the current scale and
/// offset. The transform is applied via [Transform] so the child renders at
/// the correct scale and position. When [clipBehavior] is `true` overflow is
/// hidden with a [ClipRect].
///
/// ```dart
/// OiPinchZoom(
///   minScale: 0.5,
///   maxScale: 4.0,
///   child: Image.asset('photo.png'),
/// )
/// ```
///
/// {@category Primitives}
class OiPinchZoom extends StatefulWidget {
  /// Creates an [OiPinchZoom].
  const OiPinchZoom({
    required this.child,
    this.minScale = 0.5,
    this.maxScale = 4.0,
    this.initialScale = 1.0,
    this.panEnabled = true,
    this.onScaleChanged,
    this.clipBehavior = true,
    super.key,
  });

  /// The content to zoom.
  final Widget child;

  /// Minimum scale.
  ///
  /// Defaults to `0.5`.
  final double minScale;

  /// Maximum scale.
  ///
  /// Defaults to `4.0`.
  final double maxScale;

  /// Initial scale.
  ///
  /// Defaults to `1.0`.
  final double initialScale;

  /// Whether panning (translation) is enabled alongside zooming.
  ///
  /// Defaults to `true`.
  final bool panEnabled;

  /// Callback invoked with the new scale value whenever the scale changes.
  final ValueChanged<double>? onScaleChanged;

  /// Whether to clip content that overflows the original bounds.
  ///
  /// Defaults to `true`.
  final bool clipBehavior;

  @override
  State<OiPinchZoom> createState() => _OiPinchZoomState();
}

class _OiPinchZoomState extends State<OiPinchZoom> {
  late double _scale;
  Offset _offset = Offset.zero;
  late double _baseScale;

  @override
  void initState() {
    super.initState();
    _scale = widget.initialScale.clamp(widget.minScale, widget.maxScale);
    _baseScale = _scale;
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseScale = _scale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      final newScale = (_baseScale * details.scale).clamp(
        widget.minScale,
        widget.maxScale,
      );
      _scale = newScale;
      if (widget.panEnabled) {
        _offset += details.focalPointDelta;
      }
    });
    widget.onScaleChanged?.call(_scale);
  }

  void _onScaleEnd(ScaleEndDetails details) {
    // No post-gesture processing needed.
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Transform(
      transform: Matrix4.identity()
        ..translateByDouble(_offset.dx, _offset.dy, 0, 1)
        ..scaleByDouble(_scale, _scale, 1, 1),
      alignment: Alignment.center,
      child: widget.child,
    );

    if (widget.clipBehavior) {
      content = ClipRect(child: content);
    }

    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: content,
    );
  }
}
