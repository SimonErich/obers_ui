import 'package:flutter/widgets.dart';

/// Theme data for banner components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiBannerThemeData {
  /// Creates an [OiBannerThemeData].
  const OiBannerThemeData({
    this.borderRadius,
    this.padding,
    this.iconSize,
    this.animationDuration,
    this.animationCurve,
    this.infoBackground,
    this.infoBorder,
    this.successBackground,
    this.successBorder,
    this.warningBackground,
    this.warningBorder,
    this.errorBackground,
    this.errorBorder,
    this.neutralBackground,
    this.neutralBorder,
  });

  /// The corner radius of the banner.
  final BorderRadius? borderRadius;

  /// The internal padding of the banner.
  final EdgeInsetsGeometry? padding;

  /// The size of the leading severity icon.
  final double? iconSize;

  /// The duration of the show/dismiss animation.
  final Duration? animationDuration;

  /// The curve used for the show/dismiss animation.
  final Curve? animationCurve;

  /// Background color override for info-level banners.
  final Color? infoBackground;

  /// Border color override for info-level banners.
  final Color? infoBorder;

  /// Background color override for success-level banners.
  final Color? successBackground;

  /// Border color override for success-level banners.
  final Color? successBorder;

  /// Background color override for warning-level banners.
  final Color? warningBackground;

  /// Border color override for warning-level banners.
  final Color? warningBorder;

  /// Background color override for error-level banners.
  final Color? errorBackground;

  /// Border color override for error-level banners.
  final Color? errorBorder;

  /// Background color override for neutral-level banners.
  final Color? neutralBackground;

  /// Border color override for neutral-level banners.
  final Color? neutralBorder;

  /// Creates a copy with optionally overridden values.
  OiBannerThemeData copyWith({
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    double? iconSize,
    Duration? animationDuration,
    Curve? animationCurve,
    Color? infoBackground,
    Color? infoBorder,
    Color? successBackground,
    Color? successBorder,
    Color? warningBackground,
    Color? warningBorder,
    Color? errorBackground,
    Color? errorBorder,
    Color? neutralBackground,
    Color? neutralBorder,
  }) {
    return OiBannerThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      iconSize: iconSize ?? this.iconSize,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      infoBackground: infoBackground ?? this.infoBackground,
      infoBorder: infoBorder ?? this.infoBorder,
      successBackground: successBackground ?? this.successBackground,
      successBorder: successBorder ?? this.successBorder,
      warningBackground: warningBackground ?? this.warningBackground,
      warningBorder: warningBorder ?? this.warningBorder,
      errorBackground: errorBackground ?? this.errorBackground,
      errorBorder: errorBorder ?? this.errorBorder,
      neutralBackground: neutralBackground ?? this.neutralBackground,
      neutralBorder: neutralBorder ?? this.neutralBorder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiBannerThemeData &&
        other.borderRadius == borderRadius &&
        other.padding == padding &&
        other.iconSize == iconSize &&
        other.animationDuration == animationDuration &&
        other.animationCurve == animationCurve &&
        other.infoBackground == infoBackground &&
        other.infoBorder == infoBorder &&
        other.successBackground == successBackground &&
        other.successBorder == successBorder &&
        other.warningBackground == warningBackground &&
        other.warningBorder == warningBorder &&
        other.errorBackground == errorBackground &&
        other.errorBorder == errorBorder &&
        other.neutralBackground == neutralBackground &&
        other.neutralBorder == neutralBorder;
  }

  @override
  int get hashCode => Object.hash(
    borderRadius,
    padding,
    iconSize,
    animationDuration,
    animationCurve,
    infoBackground,
    infoBorder,
    successBackground,
    successBorder,
    warningBackground,
    warningBorder,
    errorBackground,
    errorBorder,
    neutralBackground,
    neutralBorder,
  );
}
