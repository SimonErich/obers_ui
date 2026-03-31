import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// Displays a sequence of keyboard keys as styled chips.
///
/// Accepts logical key names such as `'meta'`, `'shift'`, `'K'` and
/// translates them to platform-specific glyphs (e.g. `⌘`, `⇧` on
/// Apple, `Ctrl`, `Shift` elsewhere).
///
/// ```dart
/// OiKbd(keys: const ['meta', 'shift', 'K'])
/// ```
///
/// {@category Components}
class OiKbd extends StatelessWidget {
  /// Creates an [OiKbd].
  const OiKbd({required this.keys, super.key});

  /// The logical key names to display.
  ///
  /// Recognized values (case-insensitive): `meta`, `ctrl`, `shift`,
  /// `alt`, `enter`, `tab`, `esc`, `backspace`, `delete`, `up`, `down`,
  /// `left`, `right`, `space`. Any unrecognized string is passed
  /// through capitalized.
  final List<String> keys;

  static bool get _isApple =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  static String _mapKey(String key) {
    final k = key.toLowerCase();
    final apple = _isApple;
    return switch (k) {
      'meta' || 'cmd' || 'command' => apple ? '\u2318' : 'Ctrl',
      'ctrl' || 'control' => apple ? '\u2303' : 'Ctrl',
      'shift' => apple ? '\u21E7' : 'Shift',
      'alt' || 'option' => apple ? '\u2325' : 'Alt',
      'enter' || 'return' => '\u21B5',
      'tab' => '\u21E5',
      'esc' || 'escape' => 'Esc',
      'backspace' => '\u232B',
      'delete' || 'del' => '\u2326',
      'up' => '\u2191',
      'down' => '\u2193',
      'left' => '\u2190',
      'right' => '\u2192',
      'space' => '\u2423',
      _ => key.length == 1 ? key.toUpperCase() : key,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return Semantics(
      label: keys.join(' + '),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < keys.length; i++) ...[
            if (i > 0) SizedBox(width: spacing.xs),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.xs + 2,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceHover,
                border: Border.all(color: colors.borderSubtle),
                borderRadius: radius.xs,
              ),
              child: OiLabel.caption(
                _mapKey(keys[i]),
                color: colors.textSubtle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
