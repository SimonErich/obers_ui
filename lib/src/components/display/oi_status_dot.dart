import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/animation/oi_pulse.dart';

/// Semantic status variants for [OiStatusDot].
///
/// {@category Components}
enum OiStatusVariant {
  /// Green — healthy / online / passed.
  success,

  /// Amber — degraded / at risk.
  warning,

  /// Red — down / failed.
  error,

  /// Blue — informational.
  info,

  /// Default text colour — no semantic meaning.
  neutral,

  /// Dimmed text colour — inactive / disabled.
  muted,
}

/// A semantic live-status indicator dot.
///
/// Renders a small coloured circle that can optionally pulse via
/// [OiPulse]. Use [OiStatusDot.active] for a boolean on/off shorthand.
///
/// {@category Components}
class OiStatusDot extends StatelessWidget {
  /// Creates an [OiStatusDot].
  const OiStatusDot({
    required this.label,
    this.variant = OiStatusVariant.neutral,
    this.color,
    this.size = 8.0,
    this.pulsing = false,
    super.key,
  });

  /// Boolean shorthand: `active: true` → success + pulse,
  /// `active: false` → muted.
  factory OiStatusDot.active({
    required bool active,
    required String label,
    double size = 8.0,
  }) => OiStatusDot(
    label: label,
    variant: active ? OiStatusVariant.success : OiStatusVariant.muted,
    pulsing: active,
    size: size,
  );

  /// Accessibility label (required).
  final String label;

  /// The semantic colour variant. Overridden by [color] when set.
  final OiStatusVariant variant;

  /// Explicit colour override. Takes precedence over [variant].
  final Color? color;

  /// Diameter in logical pixels. Defaults to 8.
  final double size;

  /// Whether the dot animates with a pulsing glow.
  final bool pulsing;

  Color _resolveColor(BuildContext context) {
    if (color != null) return color!;
    final colors = context.colors;
    return switch (variant) {
      OiStatusVariant.success => colors.success.base,
      OiStatusVariant.warning => colors.warning.base,
      OiStatusVariant.error => colors.error.base,
      OiStatusVariant.info => colors.info.base,
      OiStatusVariant.neutral => colors.text,
      OiStatusVariant.muted => colors.textMuted,
    };
  }

  @override
  Widget build(BuildContext context) {
    final resolvedColor = _resolveColor(context);

    Widget dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: resolvedColor,
        shape: BoxShape.circle,
      ),
    );

    if (pulsing) {
      dot = OiPulse(
        minScale: 0.8,
        maxScale: 1.2,
        duration: const Duration(milliseconds: 1200),
        child: dot,
      );
    }

    return Semantics(label: label, child: dot);
  }
}
