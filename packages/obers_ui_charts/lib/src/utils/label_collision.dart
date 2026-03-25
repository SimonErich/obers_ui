import 'dart:ui' show Rect;

/// Result of a label collision avoidance check.
enum OiLabelAction {
  /// Show the label at its original position.
  show,

  /// Skip the label entirely.
  skip,

  /// Stagger the label vertically to avoid overlap.
  stagger,

  /// Rotate the label (e.g. 45° or 90°).
  rotate,
}

/// Determines which labels from [rects] should be shown, skipped, or
/// modified to avoid overlap.
///
/// Returns a list of actions, one per input rect.
List<OiLabelAction> resolveCollisions(
  List<Rect> rects, {
  double minSpacing = 2.0,
}) {
  if (rects.isEmpty) return const [];

  final actions = List.filled(rects.length, OiLabelAction.show);

  for (var i = 1; i < rects.length; i++) {
    final prev = rects[i - 1];
    final curr = rects[i];

    // Check horizontal overlap.
    if (actions[i - 1] == OiLabelAction.show &&
        curr.left < prev.right + minSpacing) {
      // Mark current as skip (simple strategy — every-other).
      actions[i] = OiLabelAction.skip;
    }
  }

  return actions;
}

/// Returns `true` if two label rectangles overlap with the given [margin].
bool labelsOverlap(Rect a, Rect b, {double margin = 0}) {
  return a.left - margin < b.right + margin &&
      a.right + margin > b.left - margin &&
      a.top - margin < b.bottom + margin &&
      a.bottom + margin > b.top - margin;
}
