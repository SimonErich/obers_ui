import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// A placeholder widget shown when a chart has no data to display.
///
/// Uses obers_ui's [OiLabel] for text rendering and theme-driven colors.
///
/// {@category Components}
class OiChartEmptyState extends StatelessWidget {
  /// Creates a chart empty state widget.
  const OiChartEmptyState({
    super.key,
    this.message = 'No data available',
    this.icon,
    this.semanticLabel,
  });

  /// The message to display.
  final String message;

  /// An optional icon widget displayed above the message.
  final Widget? icon;

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
            if (icon != null) ...[icon!, const SizedBox(height: 8)],
            OiLabel.small(message),
          ],
        ),
      ),
    );
  }
}
