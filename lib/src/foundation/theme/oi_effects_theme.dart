import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Defines a halo/glow effect rendered as a [BoxShadow].
///
/// Halo effects are used to highlight interactive elements (e.g. focused
/// inputs, hovered buttons) with a subtle colored glow.
///
/// {@category Foundation}
@immutable
class OiHaloStyle {
  /// Creates an [OiHaloStyle] with explicit values.
  const OiHaloStyle({
    required this.color,
    required this.spread,
    required this.blur,
  });

  /// Creates a halo from [color] with default intensity.
  ///
  /// The [intensity] factor (0.0–1.0) scales the spread and opacity.
  factory OiHaloStyle.from(Color color, {double intensity = 0.3}) {
    return OiHaloStyle(
      color: color.withValues(alpha: intensity),
      spread: 2,
      blur: 8,
    );
  }

  /// No halo effect.
  static const OiHaloStyle none = OiHaloStyle(
    color: Color(0x00000000),
    spread: 0,
    blur: 0,
  );

  /// The glow color (including alpha for intensity).
  final Color color;

  /// The shadow spread radius in logical pixels.
  final double spread;

  /// The shadow blur radius in logical pixels.
  final double blur;

  /// Converts this halo style to a [BoxShadow] for rendering.
  BoxShadow toBoxShadow() {
    return BoxShadow(
      color: color,
      spreadRadius: spread,
      blurRadius: blur,
    );
  }

  /// Creates a copy with optionally overridden values.
  OiHaloStyle copyWith({Color? color, double? spread, double? blur}) {
    return OiHaloStyle(
      color: color ?? this.color,
      spread: spread ?? this.spread,
      blur: blur ?? this.blur,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiHaloStyle &&
        other.color == color &&
        other.spread == spread &&
        other.blur == blur;
  }

  @override
  int get hashCode => Object.hash(color, spread, blur);
}

/// Visual styling for a single interactive state (hover, focus, etc.).
///
/// Contains the background overlay color and halo style applied when the
/// widget enters that state.
///
/// {@category Foundation}
@immutable
class OiInteractiveStyle {
  /// Creates an [OiInteractiveStyle].
  const OiInteractiveStyle({
    required this.backgroundOverlay,
    required this.halo,
    this.scale = 1.0,
  });

  /// No visual change — transparent background, no halo.
  static const OiInteractiveStyle none = OiInteractiveStyle(
    backgroundOverlay: Color(0x00000000),
    halo: OiHaloStyle.none,
  );

  /// Semi-transparent overlay tinted over the widget background.
  final Color backgroundOverlay;

  /// The halo/glow rendered around the widget in this state.
  final OiHaloStyle halo;

  /// Scale transform applied to the widget in this state. Default is 1.0.
  ///
  /// For active/pressed states, this is typically 0.97 or 0.98.
  final double scale;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiInteractiveStyle &&
        other.backgroundOverlay == backgroundOverlay &&
        other.halo == halo &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(backgroundOverlay, halo, scale);
}

/// The complete set of interactive state effects for the design system.
///
/// Each field describes the visual effect applied when a widget enters
/// that state. Used by [OiTappable] and other interactive primitives.
///
/// {@category Foundation}
@immutable
class OiEffectsTheme {
  /// Creates an [OiEffectsTheme] with explicit styles for each state.
  const OiEffectsTheme({
    required this.hover,
    required this.focus,
    required this.active,
    required this.disabled,
    required this.selected,
    required this.dragging,
  });

  /// Creates the standard effects theme using [primaryColor] for focus/hover halos.
  factory OiEffectsTheme.standard({required Color primaryColor}) {
    return OiEffectsTheme(
      hover: const OiInteractiveStyle(
        backgroundOverlay: Color(0x0A000000),
        halo: OiHaloStyle.none,
      ),
      focus: OiInteractiveStyle(
        backgroundOverlay: const Color(0x00000000),
        halo: OiHaloStyle.from(primaryColor, intensity: 0.25),
      ),
      active: const OiInteractiveStyle(
        backgroundOverlay: Color(0x1A000000),
        halo: OiHaloStyle.none,
        scale: 0.97,
      ),
      disabled: OiInteractiveStyle.none,
      selected: OiInteractiveStyle(
        backgroundOverlay: primaryColor.withValues(alpha: 0.08),
        halo: OiHaloStyle.none,
      ),
      dragging: OiInteractiveStyle(
        backgroundOverlay: primaryColor.withValues(alpha: 0.04),
        halo: OiHaloStyle.from(primaryColor, intensity: 0.15),
        scale: 1.03,
      ),
    );
  }

  /// Applied when the pointer hovers over the widget.
  final OiInteractiveStyle hover;

  /// Applied when the widget has keyboard focus.
  final OiInteractiveStyle focus;

  /// Applied when the widget is being pressed/activated.
  final OiInteractiveStyle active;

  /// Applied when the widget is disabled.
  final OiInteractiveStyle disabled;

  /// Applied when the widget is in a selected/checked state.
  final OiInteractiveStyle selected;

  /// Applied when the widget is being dragged.
  final OiInteractiveStyle dragging;

  /// Creates a copy with optionally overridden state styles.
  OiEffectsTheme copyWith({
    OiInteractiveStyle? hover,
    OiInteractiveStyle? focus,
    OiInteractiveStyle? active,
    OiInteractiveStyle? disabled,
    OiInteractiveStyle? selected,
    OiInteractiveStyle? dragging,
  }) {
    return OiEffectsTheme(
      hover: hover ?? this.hover,
      focus: focus ?? this.focus,
      active: active ?? this.active,
      disabled: disabled ?? this.disabled,
      selected: selected ?? this.selected,
      dragging: dragging ?? this.dragging,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiEffectsTheme &&
        other.hover == hover &&
        other.focus == focus &&
        other.active == active &&
        other.disabled == disabled &&
        other.selected == selected &&
        other.dragging == dragging;
  }

  @override
  int get hashCode =>
      Object.hash(hover, focus, active, disabled, selected, dragging);
}
