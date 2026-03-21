import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// An annotation on the image.
///
/// Represents a single drawn shape, freehand stroke, or text label
/// placed on an [OiImageAnnotator].
@immutable
class OiAnnotation {
  /// Creates an [OiAnnotation].
  const OiAnnotation({
    required this.key,
    required this.type,
    required this.points,
    this.color,
    this.strokeWidth = 2.0,
    this.text,
  });

  /// A unique identifier for this annotation.
  final Object key;

  /// The kind of annotation (shape, freehand, text, etc.).
  final OiAnnotationType type;

  /// The points that define the annotation geometry.
  ///
  /// For freehand strokes this is the full path, for rectangles/circles
  /// it is two points (top-left + bottom-right), for arrows two endpoints,
  /// and for text a single position.
  final List<Offset> points;

  /// An optional color override for the stroke/fill.
  final Color? color;

  /// The stroke width used to render this annotation.
  final double strokeWidth;

  /// The text content (only used when [type] is [OiAnnotationType.text]).
  final String? text;
}

/// The type of annotation tool.
enum OiAnnotationType {
  /// Free-form drawing.
  freehand,

  /// A rectangle shape.
  rectangle,

  /// A circle/ellipse shape.
  circle,

  /// An arrow pointing between two points.
  arrow,

  /// A text label at a position.
  text,
}

/// An image annotation tool for drawing markers, shapes, and text on images.
///
/// Renders an image with an overlay where users can draw freehand strokes,
/// rectangles, circles, arrows, and text annotations.
///
/// {@category Composites}
class OiImageAnnotator extends StatefulWidget {
  /// Creates an [OiImageAnnotator].
  const OiImageAnnotator({
    required this.image,
    required this.label,
    super.key,
    this.annotations = const [],
    this.onAnnotationsChange,
    this.selectedTool = OiAnnotationType.freehand,
    this.onToolChange,
    this.strokeColor,
    this.strokeWidth = 2.0,
    this.readOnly = false,
  });

  /// The image to annotate.
  final ImageProvider image;

  /// An accessibility label describing this annotator.
  final String label;

  /// The current list of annotations.
  final List<OiAnnotation> annotations;

  /// Called when the annotations list changes (add, remove, modify).
  final ValueChanged<List<OiAnnotation>>? onAnnotationsChange;

  /// The currently selected annotation tool.
  final OiAnnotationType selectedTool;

  /// Called when the user selects a different tool.
  final ValueChanged<OiAnnotationType>? onToolChange;

  /// The stroke color for new annotations. Defaults to the primary color.
  final Color? strokeColor;

  /// The stroke width for new annotations.
  final double strokeWidth;

  /// Whether annotations are read-only (no drawing allowed).
  final bool readOnly;

  @override
  State<OiImageAnnotator> createState() => _OiImageAnnotatorState();
}

class _OiImageAnnotatorState extends State<OiImageAnnotator> {
  List<Offset> _currentPoints = [];
  bool _isDrawing = false;

  // ── Tool labels ─────────────────────────────────────────────────────────

  static const _toolLabels = {
    OiAnnotationType.freehand: 'Draw',
    OiAnnotationType.rectangle: 'Rect',
    OiAnnotationType.circle: 'Circle',
    OiAnnotationType.arrow: 'Arrow',
    OiAnnotationType.text: 'Text',
  };

  // ── Drawing handlers ────────────────────────────────────────────────────

  void _onPanStart(DragStartDetails details) {
    if (widget.readOnly) return;
    setState(() {
      _isDrawing = true;
      _currentPoints = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDrawing || widget.readOnly) return;
    setState(() {
      _currentPoints = [..._currentPoints, details.localPosition];
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDrawing || widget.readOnly) return;
    if (_currentPoints.length < 2) {
      setState(() {
        _isDrawing = false;
        _currentPoints = [];
      });
      return;
    }

    final annotation = OiAnnotation(
      key: UniqueKey(),
      type: widget.selectedTool,
      points: List.unmodifiable(_currentPoints),
      color: widget.strokeColor,
      strokeWidth: widget.strokeWidth,
    );

    final updated = [...widget.annotations, annotation];
    widget.onAnnotationsChange?.call(updated);

    setState(() {
      _isDrawing = false;
      _currentPoints = [];
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveStrokeColor = widget.strokeColor ?? colors.primary.base;

    return Semantics(
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar
          if (!widget.readOnly) _buildToolbar(context),
          // Canvas
          Expanded(
            child: GestureDetector(
              key: const ValueKey('annotator_canvas'),
              onPanStart: widget.readOnly ? null : _onPanStart,
              onPanUpdate: widget.readOnly ? null : _onPanUpdate,
              onPanEnd: widget.readOnly ? null : _onPanEnd,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  Image(image: widget.image, fit: BoxFit.contain),
                  // Existing annotations
                  CustomPaint(
                    painter: _AnnotationPainter(
                      annotations: widget.annotations,
                      defaultColor: effectiveStrokeColor,
                    ),
                  ),
                  // Current drawing in progress
                  if (_isDrawing)
                    CustomPaint(
                      painter: _ActiveStrokePainter(
                        points: _currentPoints,
                        color: effectiveStrokeColor,
                        strokeWidth: widget.strokeWidth,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final tool in OiAnnotationType.values)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                key: ValueKey('annotator_tool_${tool.name}'),
                onTap: () => widget.onToolChange?.call(tool),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.selectedTool == tool
                        ? colors.primary.base
                        : colors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _toolLabels[tool]!,
                    style: TextStyle(
                      color: widget.selectedTool == tool
                          ? colors.textOnPrimary
                          : colors.text,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────

class _AnnotationPainter extends CustomPainter {
  _AnnotationPainter({required this.annotations, required this.defaultColor});

  final List<OiAnnotation> annotations;
  final Color defaultColor;

  @override
  void paint(Canvas canvas, Size size) {
    for (final annotation in annotations) {
      final color = annotation.color ?? defaultColor;
      final paint = Paint()
        ..color = color
        ..strokeWidth = annotation.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      switch (annotation.type) {
        case OiAnnotationType.freehand:
          if (annotation.points.length < 2) continue;
          final path = Path()
            ..moveTo(annotation.points.first.dx, annotation.points.first.dy);
          for (var i = 1; i < annotation.points.length; i++) {
            path.lineTo(annotation.points[i].dx, annotation.points[i].dy);
          }
          canvas.drawPath(path, paint);

        case OiAnnotationType.rectangle:
          if (annotation.points.length < 2) continue;
          final rect = Rect.fromPoints(
            annotation.points.first,
            annotation.points.last,
          );
          canvas.drawRect(rect, paint);

        case OiAnnotationType.circle:
          if (annotation.points.length < 2) continue;
          final rect = Rect.fromPoints(
            annotation.points.first,
            annotation.points.last,
          );
          canvas.drawOval(rect, paint);

        case OiAnnotationType.arrow:
          if (annotation.points.length < 2) continue;
          final start = annotation.points.first;
          final end = annotation.points.last;
          canvas.drawLine(start, end, paint);
          // Draw arrowhead
          final direction = end - start;
          final length = direction.distance;
          if (length > 0) {
            final unit = direction / length;
            final headLength = annotation.strokeWidth * 4;
            final p1 =
                end -
                Offset(
                  unit.dx * headLength - unit.dy * headLength * 0.5,
                  unit.dy * headLength + unit.dx * headLength * 0.5,
                );
            final p2 =
                end -
                Offset(
                  unit.dx * headLength + unit.dy * headLength * 0.5,
                  unit.dy * headLength - unit.dx * headLength * 0.5,
                );
            canvas
              ..drawLine(end, p1, paint)
              ..drawLine(end, p2, paint);
          }

        case OiAnnotationType.text:
          if (annotation.points.isEmpty || annotation.text == null) continue;
          (TextPainter(
            text: TextSpan(
              text: annotation.text,
              style: TextStyle(
                color: color,
                fontSize: annotation.strokeWidth * 6,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout()).paint(canvas, annotation.points.first);
      }
    }
  }

  @override
  bool shouldRepaint(_AnnotationPainter oldDelegate) =>
      annotations != oldDelegate.annotations;
}

class _ActiveStrokePainter extends CustomPainter {
  _ActiveStrokePainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ActiveStrokePainter oldDelegate) =>
      points != oldDelegate.points;
}
