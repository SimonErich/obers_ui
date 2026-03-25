import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// Touch-friendly zoom and reset controls for chart viewports.
///
/// {@category Components}
class OiChartZoomControls extends StatelessWidget {
  /// Creates chart zoom controls.
  const OiChartZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    this.onReset,
  });

  /// Called when the zoom-in button is pressed.
  final VoidCallback onZoomIn;

  /// Called when the zoom-out button is pressed.
  final VoidCallback onZoomOut;

  /// Called when the reset button is pressed. When null, no reset
  /// button is shown.
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiButton.secondary(
          label: '+',
          semanticLabel: 'Zoom in',
          onTap: onZoomIn,
        ),
        const SizedBox(height: 4),
        OiButton.secondary(
          label: '\u2212',
          semanticLabel: 'Zoom out',
          onTap: onZoomOut,
        ),
        if (onReset != null) ...[
          const SizedBox(height: 4),
          OiButton.secondary(
            label: 'Reset',
            semanticLabel: 'Reset zoom',
            onTap: onReset,
          ),
        ],
      ],
    );
  }
}
