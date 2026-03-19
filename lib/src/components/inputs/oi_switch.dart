import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// The size variants for [OiSwitch].
///
/// {@category Components}
enum OiSwitchSize {
  /// A small 28×16 dp switch track.
  small,

  /// A medium 40×22 dp switch track (default).
  medium,

  /// A large 52×28 dp switch track.
  large,
}

/// An animated toggle switch with on/off states.
///
/// The thumb slides between the off (left) and on (right) positions with an
/// [AnimatedContainer] transition. The track is rounded and colored using the
/// primary color when [value] is `true` and a muted grey when `false`.
///
/// Track dimensions are controlled by [size]:
/// - [OiSwitchSize.small]: 28×16 dp
/// - [OiSwitchSize.medium]: 40×22 dp
/// - [OiSwitchSize.large]: 52×28 dp
///
/// {@category Components}
class OiSwitch extends StatefulWidget {
  /// Creates an [OiSwitch].
  const OiSwitch({
    required this.value,
    this.onChanged,
    this.size = OiSwitchSize.medium,
    this.enabled = true,
    this.label,
    super.key,
  });

  /// Whether the switch is currently on.
  final bool value;

  /// Called when the user toggles the switch.
  final ValueChanged<bool>? onChanged;

  /// The size variant of the switch.
  final OiSwitchSize size;

  /// Whether the switch responds to taps.
  final bool enabled;

  /// Optional label rendered to the right of the switch.
  final String? label;

  @override
  State<OiSwitch> createState() => _OiSwitchState();
}

class _OiSwitchState extends State<OiSwitch> {
  ({double width, double height}) _dimensions() {
    switch (widget.size) {
      case OiSwitchSize.small:
        return (width: 28, height: 16);
      case OiSwitchSize.medium:
        return (width: 40, height: 22);
      case OiSwitchSize.large:
        return (width: 52, height: 28);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dim = _dimensions();
    final trackW = dim.width;
    final trackH = dim.height;
    const padding = 2.0;
    final thumbSize = trackH - padding * 2;
    final travelDistance = trackW - thumbSize - padding * 2;

    final trackColor = widget.value ? colors.primary.base : colors.border;

    final animDuration = context.animations.reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 200);

    final track = AnimatedContainer(
      duration: animDuration,
      curve: Curves.easeInOut,
      width: trackW,
      height: trackH,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(trackH / 2),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: animDuration,
            curve: Curves.easeInOut,
            top: padding,
            left: widget.value ? padding + travelDistance : padding,
            child: Container(
              width: thumbSize,
              height: thumbSize,
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.overlay.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Widget content = OiTappable(
      onTap: widget.enabled
          ? () => widget.onChanged?.call(!widget.value)
          : null,
      enabled: widget.enabled,
      child: track,
    );

    if (widget.label != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          const SizedBox(width: 8),
          Text(
            widget.label!,
            style: TextStyle(fontSize: 14, color: colors.text),
          ),
        ],
      );
    }

    return content;
  }
}
