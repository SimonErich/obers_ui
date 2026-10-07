import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_color_mix.dart';

/// Internal raw, premultiplied sRGB interpolation shared by semantic groups.
@internal
abstract final class OiSemanticColorInterpolation {
  /// Mixes without clipping; missing endpoints are carried, not synthesized.
  static Color? optional(Color? first, Color? second, double fraction) =>
      first == null
      ? second
      : second == null
      ? first
      : color(first, second, fraction);

  /// Mixes raw gamma-encoded RGB and premultiplied alpha.
  static Color color(Color first, Color second, double fraction) =>
      OiColorMix.srgb(first, second, secondPercent: fraction * 100);
}
