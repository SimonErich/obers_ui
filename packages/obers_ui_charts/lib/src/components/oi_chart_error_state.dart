import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// A widget shown when a chart encounters an error, such as a streaming
/// data source failure.
///
/// {@category Components}
class OiChartErrorState extends StatelessWidget {
  /// Creates a chart error state widget.
  const OiChartErrorState({
    super.key,
    this.message = 'Failed to load chart data',
    this.error,
    this.onRetry,
    this.semanticLabel,
  });

  /// The error message to display.
  final String message;

  /// The underlying error object, if available.
  final Object? error;

  /// Called when the user taps the retry action. When null, no retry
  /// action is shown.
  final VoidCallback? onRetry;

  /// Accessibility label. Defaults to [message].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? message,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OiLabel.small(message),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              OiButton.secondary(label: 'Retry', onTap: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
