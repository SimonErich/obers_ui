import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// The possible selection states for [OiThumbs].
///
/// {@category Components}
enum OiThumbsValue {
  /// Thumbs up selected.
  up,

  /// Thumbs down selected.
  down,

  /// Neither thumb selected.
  none,
}

/// A thumbs-up / thumbs-down feedback widget.
///
/// Renders two thumb buttons. The selected thumb is drawn filled; the other
/// uses an outline style. Tapping the same thumb twice deselects it (returns
/// [OiThumbsValue.none]). When [enabled] is `false`, taps are ignored.
///
/// {@category Components}
class OiThumbs extends StatelessWidget {
  /// Creates an [OiThumbs] widget.
  const OiThumbs({
    this.value = OiThumbsValue.none,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  /// The current selection state.
  final OiThumbsValue value;

  /// Called when the user taps a thumb button.
  final ValueChanged<OiThumbsValue>? onChanged;

  /// Whether the widget is interactive. Defaults to `true`.
  final bool enabled;

  void _handleTap(OiThumbsValue tapped) {
    if (!enabled) return;
    // Tapping the same thumb toggles it off.
    final next = value == tapped ? OiThumbsValue.none : tapped;
    onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget thumbButton({
      required OiThumbsValue thumb,
      required String label,
      required bool flipped,
    }) {
      final selected = value == thumb;
      final bg = selected ? colors.primary.muted : colors.surface;
      final fg = selected ? colors.primary.base : colors.textMuted;
      final border = selected ? colors.primary.base : colors.border;

      return Semantics(
        button: true,
        label: label,
        selected: selected,
        child: OiTappable(
          enabled: enabled,
          onTap: () => _handleTap(thumb),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border),
            ),
            child: Transform.scale(
              scaleY: flipped ? -1 : 1,
              child: Text('👍', style: TextStyle(fontSize: 20, color: fg)),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        thumbButton(
          thumb: OiThumbsValue.up,
          label: 'Thumbs up',
          flipped: false,
        ),
        const SizedBox(width: 8),
        thumbButton(
          thumb: OiThumbsValue.down,
          label: 'Thumbs down',
          flipped: true,
        ),
      ],
    );
  }
}
