import 'package:flutter/rendering.dart';

/// Read-only painted text geometry for visual regression tooling.
///
/// Unlike semantics, this includes decorative/excluded labels. Bounds are in
/// logical pixels relative to [OiVisualSnapshot.capture]'s root. Offstage, transparent and fully
/// clipped children are excluded; partially clipped text is marked explicitly.
/// Capture after a completed frame, never during build/layout. This is a
/// diagnostic tool: it does not add render objects or affect application state.
class OiVisualSnapshot {
  OiVisualSnapshot._(this.texts);

  /// Captures currently laid out text beneath [root], clipped to [viewport].
  factory OiVisualSnapshot.capture(
    RenderObject root, {
    required Rect viewport,
  }) {
    final texts = <Map<String, Object?>>[];
    // RenderView adds its device-pixel transform to getTransformTo(view).
    // Its child is the logical-pixel origin used by viewport/capture tools.
    final coordinateRoot = root is RenderView ? root.child ?? root : root;
    Map<String, double> bounds(Rect r) => {
      'x': r.left,
      'y': r.top,
      'width': r.width,
      'height': r.height,
    };
    void visit(RenderObject object, Rect clip) {
      if (!object.attached ||
          (object is RenderOffstage && object.offstage) ||
          (object is RenderOpacity && object.opacity == 0)) {
        return;
      }
      if (object is RenderParagraph && object.hasSize) {
        final transform = object.getTransformTo(coordinateRoot);
        final layout = MatrixUtils.transformRect(
          transform,
          Offset.zero & object.size,
        );
        final visible = layout.intersect(clip);
        final label = object.text.toPlainText();
        if (!visible.isEmpty && label.trim().isNotEmpty) {
          final span = object.text;
          final style = span is TextSpan ? span.style : null;
          final lines = object
              .getBoxesForSelection(
                TextSelection(baseOffset: 0, extentOffset: label.length),
              )
              .map((box) => MatrixUtils.transformRect(transform, box.toRect()))
              .toList();
          texts.add({
            'label': label,
            ...bounds(layout),
            'visibleBounds': bounds(visible),
            'fullyVisible': visible == layout,
            'lines': lines.map(bounds).toList(),
            'style': {
              'fontFamily': style?.fontFamily,
              'fontSize': style?.fontSize,
              'fontWeight': style?.fontWeight?.value,
              'fontStyle': style?.fontStyle?.name,
              'height': style?.height,
              'letterSpacing': style?.letterSpacing,
              'color': style?.color?.toARGB32(),
              'variations': {
                for (final axis in style?.fontVariations ?? <FontVariation>[])
                  axis.axis: axis.value,
              },
            },
          });
        }
      }
      object.visitChildren((child) {
        final localClip = object.describeApproximatePaintClip(child);
        final childClip = localClip == null
            ? clip
            : clip.intersect(
                MatrixUtils.transformRect(
                  object.getTransformTo(coordinateRoot),
                  localClip,
                ),
              );
        if (!childClip.isEmpty) visit(child, childClip);
      });
    }

    visit(coordinateRoot, viewport);
    return OiVisualSnapshot._(List.unmodifiable(texts));
  }

  /// Visible paragraphs with layout bounds, tight line boxes and font tokens.
  ///
  /// Tight boxes describe font metrics, not per-pixel glyph ink. Different text
  /// engines may rasterize identical font metrics differently.
  final List<Map<String, Object?>> texts;
}
