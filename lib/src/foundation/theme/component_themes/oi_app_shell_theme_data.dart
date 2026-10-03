import 'package:flutter/widgets.dart';

/// Theme geometry and surfaces for the application shell.
///
/// Explicit widget properties override these values. Null uses semantic defaults.
@immutable
class OiAppShellThemeData {
  /// Creates theme overrides for appshell.
  const OiAppShellThemeData({
    this.topBarHeight,
    this.topBarPadding,
    this.primaryNavigationWidth,
    this.searchMaxWidth,
    this.actionSpacing,
    this.titleStyle,
    this.breadcrumbLinkStyle,
    this.breadcrumbSeparatorIcon,
    this.breadcrumbSpacing,
    this.backgroundColor,
    this.borderColor,
  });

  /// Height of the top bar; defaults to 56.
  final double? topBarHeight;

  /// Top bar insets; defaults to 16 horizontal.
  final EdgeInsetsGeometry? topBarPadding;

  /// Width of the primary rail; defaults to 64.
  final double? primaryNavigationWidth;

  /// Maximum search slot width; defaults to 420.
  final double? searchMaxWidth;

  /// Space before each top-bar action and account menu; defaults to 8.
  final double? actionSpacing;

  /// Contextual title typography, merged over the heading role.
  final TextStyle? titleStyle;

  /// Breadcrumb link role; null uses the theme text link role.
  final TextStyle? breadcrumbLinkStyle;

  /// Optional breadcrumb separator icon; null retains the slash string.
  final IconData? breadcrumbSeparatorIcon;

  /// Space on each side of the breadcrumb separator; null retains6.
  final double? breadcrumbSpacing;

  /// Top bar surface color.
  final Color? backgroundColor;

  /// Divider color.
  final Color? borderColor;

  /// Returns a copy with the supplied overrides.
  OiAppShellThemeData copyWith({
    double? topBarHeight,
    EdgeInsetsGeometry? topBarPadding,
    double? primaryNavigationWidth,
    double? searchMaxWidth,
    double? actionSpacing,
    TextStyle? titleStyle,
    TextStyle? breadcrumbLinkStyle,
    IconData? breadcrumbSeparatorIcon,
    double? breadcrumbSpacing,
    Color? backgroundColor,
    Color? borderColor,
  }) => OiAppShellThemeData(
    topBarHeight: topBarHeight ?? this.topBarHeight,
    topBarPadding: topBarPadding ?? this.topBarPadding,
    primaryNavigationWidth:
        primaryNavigationWidth ?? this.primaryNavigationWidth,
    searchMaxWidth: searchMaxWidth ?? this.searchMaxWidth,
    actionSpacing: actionSpacing ?? this.actionSpacing,
    titleStyle: titleStyle ?? this.titleStyle,
    breadcrumbLinkStyle: breadcrumbLinkStyle ?? this.breadcrumbLinkStyle,
    breadcrumbSeparatorIcon:
        breadcrumbSeparatorIcon ?? this.breadcrumbSeparatorIcon,
    breadcrumbSpacing: breadcrumbSpacing ?? this.breadcrumbSpacing,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiAppShellThemeData &&
          other.topBarHeight == topBarHeight &&
          other.topBarPadding == topBarPadding &&
          other.primaryNavigationWidth == primaryNavigationWidth &&
          other.searchMaxWidth == searchMaxWidth &&
          other.actionSpacing == actionSpacing &&
          other.titleStyle == titleStyle &&
          other.breadcrumbLinkStyle == breadcrumbLinkStyle &&
          other.breadcrumbSeparatorIcon == breadcrumbSeparatorIcon &&
          other.breadcrumbSpacing == breadcrumbSpacing &&
          other.backgroundColor == backgroundColor &&
          other.borderColor == borderColor;

  @override
  int get hashCode => Object.hashAll([
    topBarHeight,
    topBarPadding,
    primaryNavigationWidth,
    searchMaxWidth,
    actionSpacing,
    titleStyle,
    breadcrumbLinkStyle,
    breadcrumbSeparatorIcon,
    breadcrumbSpacing,
    backgroundColor,
    borderColor,
  ]);
}
