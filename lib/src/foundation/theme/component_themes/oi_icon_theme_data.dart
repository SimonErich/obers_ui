import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/icons/oi_icon_source.dart';

/// Resolves stable icon tokens to local vector or font sources.
@immutable
class OiIconThemeData {
  /// Creates an icon set. Unmapped tokens retain their original font glyph.
  const OiIconThemeData({this.sources = const {}, this.size, this.color});

  /// Replacement sources, keyed by existing icon tokens.
  final Map<IconData, OiIconSource> sources;

  /// Default icon size. Explicit widget sizes take precedence.
  final double? size;

  /// Default icon color. Explicit widget colors take precedence.
  final Color? color;

  /// Copies this theme with overrides.
  OiIconThemeData copyWith({
    Map<IconData, OiIconSource>? sources,
    double? size,
    Color? color,
  }) => OiIconThemeData(
    sources: sources ?? this.sources,
    size: size ?? this.size,
    color: color ?? this.color,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiIconThemeData &&
          mapEquals(sources, other.sources) &&
          size == other.size &&
          color == other.color;
  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(
      sources.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
    size,
    color,
  );
}
