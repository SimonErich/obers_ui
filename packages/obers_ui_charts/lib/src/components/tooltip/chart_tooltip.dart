import 'package:flutter/foundation.dart';
import 'package:obers_ui_charts/src/primitives/hit_testing/chart_hit_result.dart';

/// Controls tooltip visibility and content for chart interactions.
class OiChartTooltipController {
  OiChartTooltipController();

  /// The currently active hit result, or `null` if no tooltip is shown.
  final ValueNotifier<OiChartHitResult?> activeResult =
      ValueNotifier<OiChartHitResult?>(null);

  /// The current hit result, or `null` if no tooltip is shown.
  OiChartHitResult? get active => activeResult.value;

  /// Shows a tooltip for the given [result].
  set active(OiChartHitResult result) {
    activeResult.value = result;
  }

  /// Hides the currently visible tooltip.
  void hide() {
    activeResult.value = null;
  }

  /// Disposes of the internal notifier.
  void dispose() {
    activeResult.dispose();
  }
}
