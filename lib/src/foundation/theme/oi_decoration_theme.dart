import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// The line-drawing style for an [OiBorderStyle].
///
/// {@category Foundation}
enum OiBorderLineStyle {
  /// A continuous solid line.
  solid,

  /// A repeating dash pattern.
  dashed,

  /// A repeating dot pattern.
  dotted,

  /// A double-line border.
  double_,

  /// A gradient-stroked border.
  gradient,

  /// No visible border.
  none,
}

/// Describes the visual style of a border used in the design system.
///
/// Supports solid, dashed, dotted, and gradient borders. Use the named
/// factories for the most common cases.
///
/// {@category Foundation}
@immutable
class OiBorderStyle {
  /// Creates an [OiBorderStyle] with all fields specified explicitly.
  const OiBorderStyle({
    required this.lineStyle,
    required this.color,
    required this.width,
    this.gradient,
    this.borderRadius,
    this.dashLength,
    this.dashGap,
  });

  /// Creates a solid border with the given [color] and [width].
  ///
  /// An optional [borderRadius] rounds the corners.
  factory OiBorderStyle.solid(
    Color color,
    double width, {
    BorderRadius? borderRadius,
  }) {
    return OiBorderStyle(
      lineStyle: OiBorderLineStyle.solid,
      color: color,
      width: width,
      borderRadius: borderRadius,
    );
  }

  /// Creates a dashed border with the given [color] and [width].
  ///
  /// An optional [borderRadius] rounds the corners.
  factory OiBorderStyle.dashed(
    Color color,
    double width, {
    BorderRadius? borderRadius,
  }) {
    return OiBorderStyle(
      lineStyle: OiBorderLineStyle.dashed,
      color: color,
      width: width,
      borderRadius: borderRadius,
    );
  }

  /// Creates a dotted border with the given [color] and [width].
  ///
  /// An optional [borderRadius] rounds the corners.
  factory OiBorderStyle.dotted(
    Color color,
    double width, {
    BorderRadius? borderRadius,
  }) {
    return OiBorderStyle(
      lineStyle: OiBorderLineStyle.dotted,
      color: color,
      width: width,
      borderRadius: borderRadius,
    );
  }

  /// Creates a gradient border with the given [gradient] and [width].
  ///
  /// The [color] is set to fully transparent because the visual appearance
  /// is driven by [gradient]. An optional [borderRadius] rounds the corners.
  factory OiBorderStyle.gradient(
    Gradient gradient,
    double width, {
    BorderRadius? borderRadius,
  }) {
    return OiBorderStyle(
      lineStyle: OiBorderLineStyle.solid,
      color: const Color(0x00000000),
      width: width,
      gradient: gradient,
      borderRadius: borderRadius,
    );
  }

  /// Creates a border with no visible stroke (fully transparent, zero width).
  factory OiBorderStyle.none() {
    return const OiBorderStyle(
      lineStyle: OiBorderLineStyle.solid,
      color: Color(0x00000000),
      width: 0,
    );
  }

  /// The line drawing style (solid, dashed, dotted).
  final OiBorderLineStyle lineStyle;

  /// The border stroke color.
  ///
  /// This is fully transparent when a [gradient] is used instead.
  final Color color;

  /// The border stroke width in logical pixels.
  final double width;

  /// An optional gradient that replaces [color] for the border stroke.
  final Gradient? gradient;

  /// Optional corner radius applied to the border.
  final BorderRadius? borderRadius;

  /// The length of each dash in a dashed border, in logical pixels.
  ///
  /// Only applicable when [lineStyle] is [OiBorderLineStyle.dashed].
  final double? dashLength;

  /// The gap between dashes in a dashed border, in logical pixels.
  ///
  /// Only applicable when [lineStyle] is [OiBorderLineStyle.dashed].
  final double? dashGap;

  /// Creates a copy with optionally overridden values.
  OiBorderStyle copyWith({
    OiBorderLineStyle? lineStyle,
    Color? color,
    double? width,
    Gradient? gradient,
    BorderRadius? borderRadius,
    double? dashLength,
    double? dashGap,
  }) {
    return OiBorderStyle(
      lineStyle: lineStyle ?? this.lineStyle,
      color: color ?? this.color,
      width: width ?? this.width,
      gradient: gradient ?? this.gradient,
      borderRadius: borderRadius ?? this.borderRadius,
      dashLength: dashLength ?? this.dashLength,
      dashGap: dashGap ?? this.dashGap,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiBorderStyle &&
        other.lineStyle == lineStyle &&
        other.color == color &&
        other.width == width &&
        other.gradient == gradient &&
        other.borderRadius == borderRadius &&
        other.dashLength == dashLength &&
        other.dashGap == dashGap;
  }

  @override
  int get hashCode => Object.hash(
    lineStyle,
    color,
    width,
    gradient,
    borderRadius,
    dashLength,
    dashGap,
  );
}

/// Describes a gradient used for backgrounds, borders, or overlays.
///
/// Supports both linear and radial gradients. Call [toGradient] to obtain
/// the corresponding Flutter [Gradient] object for rendering.
///
/// {@category Foundation}
@immutable
class OiGradientStyle {
  /// Creates an [OiGradientStyle] with all fields specified explicitly.
  const OiGradientStyle({
    required this.linear,
    required this.colors,
    this.stops,
    this.begin,
    this.end,
    this.center,
    this.radius,
  });

  /// Creates a linear gradient from [colors].
  ///
  /// [stops] optionally specifies the position of each color (0.0–1.0).
  /// [begin] and [end] define the direction; they default to
  /// [AlignmentDirectional.centerStart] and [AlignmentDirectional.centerEnd].
  factory OiGradientStyle.linear(
    List<Color> colors, {
    List<double>? stops,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
  }) {
    return OiGradientStyle(
      linear: true,
      colors: colors,
      stops: stops,
      begin: begin,
      end: end,
    );
  }

  /// Creates a radial gradient from [colors].
  ///
  /// [stops] optionally specifies the position of each color (0.0–1.0).
  /// [center] and [radius] define the focal point and size.
  factory OiGradientStyle.radial(
    List<Color> colors, {
    List<double>? stops,
    AlignmentGeometry? center,
    double? radius,
  }) {
    return OiGradientStyle(
      linear: false,
      colors: colors,
      stops: stops,
      center: center,
      radius: radius,
    );
  }

  /// Whether this gradient is linear (`true`) or radial (`false`).
  final bool linear;

  /// The list of colors in the gradient.
  final List<Color> colors;

  /// Optional color stops. Must have the same length as [colors] when provided.
  final List<double>? stops;

  /// The start alignment for a linear gradient.
  final AlignmentGeometry? begin;

  /// The end alignment for a linear gradient.
  final AlignmentGeometry? end;

  /// The center alignment for a radial gradient.
  final AlignmentGeometry? center;

  /// The radius for a radial gradient.
  final double? radius;

  /// Converts this style to a Flutter [Gradient] for rendering.
  ///
  /// Returns a [LinearGradient] when [linear] is `true`, otherwise a
  /// [RadialGradient].
  Gradient toGradient() {
    if (linear) {
      return LinearGradient(
        colors: colors,
        stops: stops,
        begin: begin ?? Alignment.centerLeft,
        end: end ?? Alignment.centerRight,
      );
    }
    return RadialGradient(
      colors: colors,
      stops: stops,
      center: center ?? Alignment.center,
      radius: radius ?? 0.5,
    );
  }

  /// Creates a copy with optionally overridden values.
  OiGradientStyle copyWith({
    bool? linear,
    List<Color>? colors,
    List<double>? stops,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    AlignmentGeometry? center,
    double? radius,
  }) {
    return OiGradientStyle(
      linear: linear ?? this.linear,
      colors: colors ?? this.colors,
      stops: stops ?? this.stops,
      begin: begin ?? this.begin,
      end: end ?? this.end,
      center: center ?? this.center,
      radius: radius ?? this.radius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiGradientStyle) return false;
    if (colors.length != other.colors.length) return false;
    for (var i = 0; i < colors.length; i++) {
      if (colors[i] != other.colors[i]) return false;
    }
    if (stops != null && other.stops != null) {
      if (stops!.length != other.stops!.length) return false;
      for (var i = 0; i < stops!.length; i++) {
        if (stops![i] != other.stops![i]) return false;
      }
    } else if (stops != other.stops) {
      return false;
    }
    return other.linear == linear &&
        other.begin == begin &&
        other.end == end &&
        other.center == center &&
        other.radius == radius;
  }

  @override
  int get hashCode => Object.hash(
    linear,
    Object.hashAll(colors),
    Object.hashAll(stops ?? const []),
    begin,
    end,
    center,
    radius,
  );
}

/// The complete decoration theme for the design system.
///
/// Holds the standard border styles for default, focused, and error states,
/// as well as a named gradient palette.
///
/// {@category Foundation}
@immutable
class OiDecorationTheme {
  /// Creates an [OiDecorationTheme] with all fields specified explicitly.
  const OiDecorationTheme({
    required this.defaultBorder,
    required this.focusBorder,
    required this.errorBorder,
    required this.gradients,
    this.surfaceGradient,
    this.cardGradient,
    this.pageGradient,
    this.surfaceBorder,
    this.cardBorder,
    this.inputBorder,
    this.componentGradients,
    this.componentBorders,
  });

  /// Creates the standard decoration theme from [primaryColor] and [errorColor].
  factory OiDecorationTheme.standard({
    required Color primaryColor,
    required Color errorColor,
  }) {
    return OiDecorationTheme(
      defaultBorder: OiBorderStyle.solid(
        const Color(0xFFD1D5DB),
        1,
        borderRadius: BorderRadius.circular(8),
      ),
      focusBorder: OiBorderStyle.solid(
        primaryColor,
        2,
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OiBorderStyle.solid(
        errorColor,
        2,
        borderRadius: BorderRadius.circular(8),
      ),
      gradients: {
        'primary': OiGradientStyle.linear([
          primaryColor,
          primaryColor.withValues(alpha: 0.7),
        ]),
        'error': OiGradientStyle.linear([
          errorColor,
          errorColor.withValues(alpha: 0.7),
        ]),
      },
    );
  }

  /// The default border style used on unfocused, non-error inputs and containers.
  final OiBorderStyle defaultBorder;

  /// The border style applied when an element has keyboard focus.
  final OiBorderStyle focusBorder;

  /// The border style applied when an element has a validation error.
  final OiBorderStyle errorBorder;

  /// A named map of gradient styles available to components.
  final Map<String, OiGradientStyle> gradients;

  /// An optional gradient applied to surface widgets.
  final OiGradientStyle? surfaceGradient;

  /// An optional gradient applied to card widgets.
  final OiGradientStyle? cardGradient;

  /// An optional gradient applied to page-level backgrounds.
  final OiGradientStyle? pageGradient;

  /// An optional border style for surface widgets.
  final OiBorderStyle? surfaceBorder;

  /// An optional border style for card widgets.
  final OiBorderStyle? cardBorder;

  /// An optional border style for input widgets.
  final OiBorderStyle? inputBorder;

  /// Per-component gradient overrides keyed by component [Type].
  final Map<Type, OiGradientStyle>? componentGradients;

  /// Per-component border overrides keyed by component [Type].
  final Map<Type, OiBorderStyle>? componentBorders;

  /// Creates a copy with optionally overridden values.
  OiDecorationTheme copyWith({
    OiBorderStyle? defaultBorder,
    OiBorderStyle? focusBorder,
    OiBorderStyle? errorBorder,
    Map<String, OiGradientStyle>? gradients,
    OiGradientStyle? surfaceGradient,
    OiGradientStyle? cardGradient,
    OiGradientStyle? pageGradient,
    OiBorderStyle? surfaceBorder,
    OiBorderStyle? cardBorder,
    OiBorderStyle? inputBorder,
    Map<Type, OiGradientStyle>? componentGradients,
    Map<Type, OiBorderStyle>? componentBorders,
  }) {
    return OiDecorationTheme(
      defaultBorder: defaultBorder ?? this.defaultBorder,
      focusBorder: focusBorder ?? this.focusBorder,
      errorBorder: errorBorder ?? this.errorBorder,
      gradients: gradients ?? this.gradients,
      surfaceGradient: surfaceGradient ?? this.surfaceGradient,
      cardGradient: cardGradient ?? this.cardGradient,
      pageGradient: pageGradient ?? this.pageGradient,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      cardBorder: cardBorder ?? this.cardBorder,
      inputBorder: inputBorder ?? this.inputBorder,
      componentGradients: componentGradients ?? this.componentGradients,
      componentBorders: componentBorders ?? this.componentBorders,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiDecorationTheme) return false;
    if (other.defaultBorder != defaultBorder) return false;
    if (other.focusBorder != focusBorder) return false;
    if (other.errorBorder != errorBorder) return false;
    if (gradients.length != other.gradients.length) return false;
    for (final key in gradients.keys) {
      if (gradients[key] != other.gradients[key]) return false;
    }
    if (other.surfaceGradient != surfaceGradient) return false;
    if (other.cardGradient != cardGradient) return false;
    if (other.pageGradient != pageGradient) return false;
    if (other.surfaceBorder != surfaceBorder) return false;
    if (other.cardBorder != cardBorder) return false;
    if (other.inputBorder != inputBorder) return false;
    if (other.componentGradients != componentGradients) return false;
    if (other.componentBorders != componentBorders) return false;
    return true;
  }

  @override
  int get hashCode => Object.hashAll([
    defaultBorder,
    focusBorder,
    errorBorder,
    Object.hashAll(gradients.entries.map((e) => Object.hash(e.key, e.value))),
    surfaceGradient,
    cardGradient,
    pageGradient,
    surfaceBorder,
    cardBorder,
    inputBorder,
    componentGradients,
    componentBorders,
  ]);
}
