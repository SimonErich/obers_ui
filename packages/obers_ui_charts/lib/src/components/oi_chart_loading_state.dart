import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// A loading indicator widget shown while chart data is being fetched.
///
/// {@category Components}
class OiChartLoadingState extends StatelessWidget {
  /// Creates a chart loading state widget.
  const OiChartLoadingState({
    super.key,
    this.message = 'Loading chart data…',
    this.semanticLabel,
  });

  /// The loading message to display.
  final String message;

  /// Accessibility label. Defaults to [message].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? message,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [OiLabel.small(message)],
        ),
      ),
    );
  }
}
