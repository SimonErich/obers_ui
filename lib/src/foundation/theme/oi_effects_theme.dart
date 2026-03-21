import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:obers_ui/obers_ui.dart' show OiTappable;

import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart'
    show OiTappable;

/// Defines the focus ring border rendered around a focused widget.
///
/// The ring is always rendered independently of the halo/glow effect so that
/// no theme configuration can remove keyboard focus visibility.
///
/// {@category Foundation}
@immutable
class OiFocusRingStyle {
  /// Creates an [OiFocusRingStyle] with explicit values.
  const OiFocusRingStyle({
    required this.color,
    this.width = 2.0,
    this.borderRadius = BorderRadius.zero,
  });

  /// Creates a standard focus ring from [primaryColor].
  factory OiFocusRingStyle.standard(Color primaryColor) {
    return OiFocusRingStyle(color: primaryColor.withValues(alpha: 0.85));
  }

  /// The border color of the focus ring.
  final Color color;

  /// The border width in logical pixels.
  final double width;

  /// The border radius applied to each corner of the ring.
  final BorderRadius borderRadius;

  /// Returns a copy of this style with minimum alpha and width enforced.
  ///
  /// Guarantees that:
  /// - [color] alpha ≥ 0.5 (ring is always perceptible)
  /// - [width] ≥ 2.0 (ring is always physically visible)
  OiFocusRingStyle get enforced {
    final clampedColor = color.a < 0.5 ? color.withValues(alpha: 0.5) : color;
    final clampedWidth = width < 2.0 ? 2.0 : width;
    return OiFocusRingStyle(
      color: clampedColor,
      width: clampedWidth,
      borderRadius: borderRadius,
    );
  }

  /// Creates a copy with optionally overridden values.
  OiFocusRingStyle copyWith({
    Color? color,
    double? width,
    BorderRadius? borderRadius,
  }) {
    return OiFocusRingStyle(
      color: color ?? this.color,
      width: width ?? this.width,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiFocusRingStyle &&
        other.color == color &&
        other.width == width &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(color, width, borderRadius);
}

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
    this.opacity,
    this.offset = Offset.zero,
  });

  /// Creates a halo from [color] with default intensity.
  ///
  /// The [intensity] factor (0.0–1.0) scales the spread and opacity.
  factory OiHaloStyle.from(Color color, {double intensity = 0.3}) {
    return OiHaloStyle(
      color: color.withValues(alpha: intensity),
      spread: 2,
      blur: 8,
      opacity: intensity,
    );
  }

  /// No halo effect.
  static const OiHaloStyle none = OiHaloStyle(
    color: Color(0x00000000),
    spread: 0,
    blur: 0,
    opacity: 0,
  );

  /// The glow color (including alpha for intensity).
  final Color color;

  /// The shadow spread radius in logical pixels.
  final double spread;

  /// The shadow blur radius in logical pixels.
  final double blur;

  /// The opacity of the halo effect (0.0–1.0).
  ///
  /// When provided, this value overrides the alpha channel of [color].
  final double? opacity;

  /// The offset of the halo from the widget center.
  ///
  /// Defaults to [Offset.zero].
  final Offset offset;

  /// Converts this halo style to a [BoxShadow] for rendering.
  BoxShadow toBoxShadow() {
    final effectiveColor = opacity != null
        ? color.withValues(alpha: opacity)
        : color;
    return BoxShadow(
      color: effectiveColor,
      spreadRadius: spread,
      blurRadius: blur,
      offset: offset,
    );
  }

  /// Creates a copy with optionally overridden values.
  OiHaloStyle copyWith({
    Color? color,
    double? spread,
    double? blur,
    double? opacity,
    Offset? offset,
  }) {
    return OiHaloStyle(
      color: color ?? this.color,
      spread: spread ?? this.spread,
      blur: blur ?? this.blur,
      opacity: opacity ?? this.opacity,
      offset: offset ?? this.offset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiHaloStyle &&
        other.color == color &&
        other.spread == spread &&
        other.blur == blur &&
        other.opacity == opacity &&
        other.offset == offset;
  }

  @override
  int get hashCode => Object.hash(color, spread, blur, opacity, offset);
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
    this.backgroundOverride,
    this.borderColor,
    this.textColor,
    this.opacity,
    this.translate,
    this.elevationDelta,
    this.border,
    this.gradient,
    this.cursor,
  });

  /// No visual change — transparent background, no halo.
  static const OiInteractiveStyle none = OiInteractiveStyle(
    backgroundOverlay: Color(0x00000000),
    halo: OiHaloStyle.none,
  );

  /// An optional background color that replaces the widget's background
  /// entirely when this state is active.
  final Color? backgroundOverride;

  /// Semi-transparent overlay tinted over the widget background.
  final Color backgroundOverlay;

  /// An optional border color applied when this state is active.
  final Color? borderColor;

  /// An optional text color applied when this state is active.
  final Color? textColor;

  /// An optional opacity applied to the widget (0.0–1.0).
  final double? opacity;

  /// Scale transform applied to the widget in this state. Default is 1.0.
  ///
  /// For active/pressed states, this is typically 0.97 or 0.98.
  final double scale;

  /// An optional translation offset applied to the widget.
  final Offset? translate;

  /// An optional elevation change applied in this state.
  final double? elevationDelta;

  /// The halo/glow rendered around the widget in this state.
  final OiHaloStyle halo;

  /// An optional border style applied when this state is active.
  final OiBorderStyle? border;

  /// An optional gradient applied when this state is active.
  final OiGradientStyle? gradient;

  /// An optional mouse cursor applied when this state is active.
  final MouseCursor? cursor;

  /// Merges this style with a [base] style. Non-null values in this style
  /// take precedence over values in [base].
  OiInteractiveStyle merge(OiInteractiveStyle base) {
    return OiInteractiveStyle(
      backgroundOverride: backgroundOverride ?? base.backgroundOverride,
      backgroundOverlay: backgroundOverlay,
      borderColor: borderColor ?? base.borderColor,
      textColor: textColor ?? base.textColor,
      opacity: opacity ?? base.opacity,
      scale: scale != 1.0 ? scale : base.scale,
      translate: translate ?? base.translate,
      elevationDelta: elevationDelta ?? base.elevationDelta,
      halo: halo,
      border: border ?? base.border,
      gradient: gradient ?? base.gradient,
      cursor: cursor ?? base.cursor,
    );
  }

  /// Creates a copy with optionally overridden values.
  OiInteractiveStyle copyWith({
    Color? backgroundOverride,
    Color? backgroundOverlay,
    Color? borderColor,
    Color? textColor,
    double? opacity,
    double? scale,
    Offset? translate,
    double? elevationDelta,
    OiHaloStyle? halo,
    OiBorderStyle? border,
    OiGradientStyle? gradient,
    MouseCursor? cursor,
  }) {
    return OiInteractiveStyle(
      backgroundOverride: backgroundOverride ?? this.backgroundOverride,
      backgroundOverlay: backgroundOverlay ?? this.backgroundOverlay,
      borderColor: borderColor ?? this.borderColor,
      textColor: textColor ?? this.textColor,
      opacity: opacity ?? this.opacity,
      scale: scale ?? this.scale,
      translate: translate ?? this.translate,
      elevationDelta: elevationDelta ?? this.elevationDelta,
      halo: halo ?? this.halo,
      border: border ?? this.border,
      gradient: gradient ?? this.gradient,
      cursor: cursor ?? this.cursor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiInteractiveStyle &&
        other.backgroundOverride == backgroundOverride &&
        other.backgroundOverlay == backgroundOverlay &&
        other.borderColor == borderColor &&
        other.textColor == textColor &&
        other.opacity == opacity &&
        other.scale == scale &&
        other.translate == translate &&
        other.elevationDelta == elevationDelta &&
        other.halo == halo &&
        other.border == border &&
        other.gradient == gradient &&
        other.cursor == cursor;
  }

  @override
  int get hashCode => Object.hashAll([
    backgroundOverride,
    backgroundOverlay,
    borderColor,
    textColor,
    opacity,
    scale,
    translate,
    elevationDelta,
    halo,
    border,
    gradient,
    cursor,
  ]);
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
    required this.focusRing,
    this.halo,
    this.haloFocus,
    this.haloError,
    this.stateTransition = const Duration(milliseconds: 150),
    this.stateTransitionCurve = Curves.easeInOut,
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
      focusRing: OiFocusRingStyle.standard(primaryColor),
      halo: OiHaloStyle.from(primaryColor),
      haloFocus: OiHaloStyle.from(primaryColor, intensity: 0.25),
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

  /// The focus ring border style rendered when the widget has keyboard focus.
  ///
  /// This ring is always rendered independently of [focus] so that it cannot
  /// be suppressed by setting [focus] to [OiInteractiveStyle.none].
  final OiFocusRingStyle focusRing;

  /// The default halo effect applied to interactive elements.
  final OiHaloStyle? halo;

  /// The halo effect applied when an element has keyboard focus.
  final OiHaloStyle? haloFocus;

  /// The halo effect applied when an element has a validation error.
  final OiHaloStyle? haloError;

  /// The duration of state transitions between interactive states.
  final Duration stateTransition;

  /// The curve used for state transition animations.
  final Curve stateTransitionCurve;

  /// Creates a copy with optionally overridden state styles.
  OiEffectsTheme copyWith({
    OiInteractiveStyle? hover,
    OiInteractiveStyle? focus,
    OiInteractiveStyle? active,
    OiInteractiveStyle? disabled,
    OiInteractiveStyle? selected,
    OiInteractiveStyle? dragging,
    OiFocusRingStyle? focusRing,
    OiHaloStyle? halo,
    OiHaloStyle? haloFocus,
    OiHaloStyle? haloError,
    Duration? stateTransition,
    Curve? stateTransitionCurve,
  }) {
    return OiEffectsTheme(
      hover: hover ?? this.hover,
      focus: focus ?? this.focus,
      active: active ?? this.active,
      disabled: disabled ?? this.disabled,
      selected: selected ?? this.selected,
      dragging: dragging ?? this.dragging,
      focusRing: focusRing ?? this.focusRing,
      halo: halo ?? this.halo,
      haloFocus: haloFocus ?? this.haloFocus,
      haloError: haloError ?? this.haloError,
      stateTransition: stateTransition ?? this.stateTransition,
      stateTransitionCurve: stateTransitionCurve ?? this.stateTransitionCurve,
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
        other.dragging == dragging &&
        other.focusRing == focusRing &&
        other.halo == halo &&
        other.haloFocus == haloFocus &&
        other.haloError == haloError &&
        other.stateTransition == stateTransition &&
        other.stateTransitionCurve == stateTransitionCurve;
  }

  @override
  int get hashCode => Object.hashAll([
    hover,
    focus,
    active,
    disabled,
    selected,
    dragging,
    focusRing,
    halo,
    haloFocus,
    haloError,
    stateTransition,
    stateTransitionCurve,
  ]);
}
