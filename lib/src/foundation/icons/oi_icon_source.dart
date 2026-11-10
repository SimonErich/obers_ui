import 'package:flutter/widgets.dart';

/// A local source for an icon token. No network request is performed.
@immutable
sealed class OiIconSource {
  /// Creates SVG markup whose strokes and fills may use currentColor.
  const factory OiIconSource.svg(String markup) = OiSvgIconSource;

  /// Creates a bundled SVG asset source.
  const factory OiIconSource.asset(String asset, {String? package}) =
      OiAssetIconSource;

  /// Uses an alternate font glyph.
  const factory OiIconSource.font(IconData icon) = OiFontIconSource;

  const OiIconSource._();
}

/// Inline vector markup rendered by the shared icon renderer.
final class OiSvgIconSource extends OiIconSource {
  /// Creates a vector source.
  const OiSvgIconSource(this.markup) : super._();

  /// SVG document.
  final String markup;
}

/// A bundled SVG document.
final class OiAssetIconSource extends OiIconSource {
  /// Creates a bundled vector source.
  const OiAssetIconSource(this.asset, {this.package}) : super._();

  /// Asset key.
  final String asset;

  /// Owning Flutter package, or null for the application.
  final String? package;
}

/// An alternate icon font glyph.
final class OiFontIconSource extends OiIconSource {
  /// Creates a font source.
  const OiFontIconSource(this.icon) : super._();

  /// Font glyph descriptor.
  final IconData icon;
}
