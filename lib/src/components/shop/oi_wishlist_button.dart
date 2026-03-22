import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// Material Icons codepoints.
const IconData _kHeartOutline = IconData(
  0xe87e,
  fontFamily: 'MaterialIcons',
); // favorite_border
const IconData _kHeartFilled = IconData(
  0xe87d,
  fontFamily: 'MaterialIcons',
); // favorite

/// A heart toggle button for adding or removing a product from a wishlist.
///
/// Coverage: REQ-0071
///
/// When [active] is `true` the heart is filled with the error color (red).
/// When `false` the heart is outlined. The [loading] state disables the
/// button and shows reduced opacity to indicate a pending server round-trip.
///
/// {@category Components}
class OiWishlistButton extends StatelessWidget {
  /// Creates an [OiWishlistButton].
  const OiWishlistButton({
    required this.label,
    this.active = false,
    this.onToggle,
    this.loading = false,
    super.key,
  });

  /// Accessibility label announced by screen readers.
  final String label;

  /// Whether the product is currently wishlisted.
  final bool active;

  /// Called when the user taps the heart.
  final VoidCallback? onToggle;

  /// When `true` the button is disabled and shows reduced opacity.
  final bool loading;

  bool get _interactive => !loading && onToggle != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final icon = active ? _kHeartFilled : _kHeartOutline;
    final iconColor = active ? colors.error.base : colors.textMuted;

    Widget content = Icon(icon, size: 24, color: iconColor);

    if (loading) {
      content = Opacity(opacity: 0.4, child: content);
    }

    if (_interactive) {
      content = OiTappable(onTap: onToggle!, child: content);
    }

    return Semantics(
      label: label,
      toggled: active,
      button: true,
      child: ExcludeSemantics(child: content),
    );
  }
}
