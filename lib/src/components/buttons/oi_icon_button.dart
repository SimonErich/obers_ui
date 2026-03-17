import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';

/// A button that displays only an icon.
///
/// This is a thin wrapper around [OiButton.icon] that exposes the same
/// parameters as a regular [StatelessWidget] for convenience.
///
/// ```dart
/// OiIconButton(
///   icon: Icons.add,
///   onTap: () => doSomething(),
/// )
/// ```
///
/// {@category Components}
class OiIconButton extends StatelessWidget {
  /// Creates an [OiIconButton].
  const OiIconButton({
    required this.icon,
    required this.semanticLabel,
    this.onTap,
    this.size = OiButtonSize.medium,
    this.variant = OiButtonVariant.ghost,
    this.enabled = true,
    super.key,
  });

  /// The icon to display inside the button.
  final IconData icon;

  /// Called when the button is tapped.
  final VoidCallback? onTap;

  /// The size tier.
  final OiButtonSize size;

  /// The visual style variant.
  final OiButtonVariant variant;

  /// Whether the button responds to interactions.
  final bool enabled;

  /// Accessibility label announced by screen readers.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return OiButton.icon(
      icon: icon,
      onTap: onTap,
      size: size,
      variant: variant,
      enabled: enabled,
      label: semanticLabel,
    );
  }
}
