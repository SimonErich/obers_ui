import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiColorScheme;
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart'
    show OiColorScheme;
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/animation/oi_pulse.dart';

/// Wraps a [child] widget with a pulsing ring to indicate "live" status.
///
/// When [active] is `true` a colored ring pulses around the child using
/// [OiPulse]. The ring color defaults to
/// [OiColorScheme.success] but can be overridden via [color].
///
/// When [active] is `false` the child is rendered without any decoration.
///
/// {@category Composites}
class OiLiveRing extends StatelessWidget {
  /// Creates an [OiLiveRing].
  const OiLiveRing({
    required this.child,
    super.key,
    this.color,
    this.active = true,
  });

  /// The widget to wrap with a live ring.
  final Widget child;

  /// An optional override for the ring color. Defaults to the theme's
  /// success color.
  final Color? color;

  /// Whether the live ring is active. When `false`, [child] is rendered
  /// without any ring decoration.
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (!active) return child;

    final ringColor = color ?? context.colors.success.base;

    return Stack(
      alignment: Alignment.center,
      children: [
        OiPulse(
          minOpacity: 0.3,
          minScale: 0.95,
          maxScale: 1.1,
          duration: const Duration(milliseconds: 1500),
          child: Container(
            key: const Key('oi_live_ring_indicator'),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ringColor, width: 3),
            ),
            child: Opacity(opacity: 0, child: child),
          ),
        ),
        child,
      ],
    );
  }
}
