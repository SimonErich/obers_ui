import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A horizontal audio level meter.
///
/// Shows an instantaneous level — the RMS of a capture buffer, an output
/// volume — as a filled proportion of a track. Distinct from `OiProgress`: a
/// progress bar reports how far through something you are and only ever moves
/// forward, while a meter reports what is happening right now and moves both
/// ways many times a second.
///
/// [gain] exists because raw RMS is a poor thing to render directly. Speech
/// rarely exceeds about 0.35 RMS, so a meter driven by it unscaled sits in its
/// first third and looks broken while someone is talking normally.
///
/// {@category Components}
class OiLevelMeter extends StatelessWidget {
  /// Creates a level meter.
  const OiLevelMeter({
    required this.level,
    required this.semanticLabel,
    this.gain = 3,
    this.height,
    this.color,
    super.key,
  });

  /// The current level, normally 0..1 before [gain].
  final double level;

  /// What this meter is measuring, for screen readers.
  final String semanticLabel;

  /// Multiplier applied to [level] before clamping to the track.
  final double gain;

  /// Track height. Defaults to `spacing.sm`.
  final double? height;

  /// Fill colour. Defaults to the theme's primary.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = OiTheme.of(context);
    final fraction = (level * gain).clamp(0.0, 1.0);
    return Semantics(
      label: semanticLabel,
      value: '${(fraction * 100).round()}%',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.surfaceSubtle,
            borderRadius: theme.radius.full,
          ),
          child: SizedBox(
            height: height ?? theme.spacing.sm,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fraction,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color ?? theme.colors.primary.base,
                    borderRadius: theme.radius.full,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
