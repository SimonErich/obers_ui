/// Interaction mode for chart widgets.
///
/// Determines whether the chart responds to touch gestures (tap to select
/// nearest) or pointer events (hover to highlight nearest).
///
/// {@category Composites}
enum OiChartInteractionMode {
  /// Automatically detect the interaction mode based on the platform's
  /// input modality.
  auto,

  /// Touch interaction: tap to select the nearest bubble.
  touch,

  /// Pointer interaction: hover to highlight the nearest bubble.
  pointer,
}
