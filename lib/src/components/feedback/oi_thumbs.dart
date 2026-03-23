import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

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
/// Renders two [OiIconButton]s. The selected thumb uses the *soft* variant;
/// the other uses *ghost*. Tapping the same thumb twice deselects it (returns
/// [OiThumbsValue.none]). When [showCount] is `true`, [upCount] and [downCount]
/// are displayed alongside their respective buttons.
///
/// When [enabled] is `false`, taps are ignored.
///
/// {@category Components}
class OiThumbs extends StatelessWidget {
  /// Creates an [OiThumbs] widget.
  const OiThumbs({
    this.label,
    this.value = OiThumbsValue.none,
    this.onChanged,
    this.enabled = true,
    this.showCount = false,
    this.upCount = 0,
    this.downCount = 0,
    super.key,
  });

  /// Accessible label announced by screen readers for the group.
  final String? label;

  /// The current selection state.
  final OiThumbsValue value;

  /// Called when the user taps a thumb button.
  final ValueChanged<OiThumbsValue>? onChanged;

  /// Whether the widget is interactive. Defaults to `true`.
  final bool enabled;

  /// Whether to display the up/down counts. Defaults to `false`.
  final bool showCount;

  /// Number of thumbs-up votes shown when [showCount] is `true`.
  final int upCount;

  /// Number of thumbs-down votes shown when [showCount] is `true`.
  final int downCount;

  void _handleTap(OiThumbsValue tapped) {
    if (!enabled) return;
    // Tapping the same thumb toggles it off.
    final next = value == tapped ? OiThumbsValue.none : tapped;
    onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colors = context.colors;

    Widget buildThumb({
      required OiThumbsValue thumb,
      required String semanticLabel,
      required bool up,
      required int count,
    }) {
      final selected = value == thumb;
      final variant = selected ? OiButtonVariant.soft : OiButtonVariant.ghost;

      Widget button = Semantics(
        button: true,
        selected: selected,
        child: OiIconButton(
          icon: up ? OiIcons.thumbsUp : OiIcons.thumbsDown,
          semanticLabel: semanticLabel,
          onTap: enabled ? () => _handleTap(thumb) : null,
          variant: variant,
          enabled: enabled,
        ),
      );

      if (showCount) {
        button = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            button,
            const SizedBox(width: 4),
            Text(
              '$count',
              style: textTheme.small.copyWith(color: colors.textMuted),
            ),
          ],
        );
      }

      return button;
    }

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildThumb(
          thumb: OiThumbsValue.up,
          semanticLabel: 'Thumbs up',
          up: true,
          count: upCount,
        ),
        const SizedBox(width: 8),
        buildThumb(
          thumb: OiThumbsValue.down,
          semanticLabel: 'Thumbs down',
          up: false,
          count: downCount,
        ),
      ],
    );

    if (label != null) {
      return Semantics(label: label, child: content);
    }
    return content;
  }
}
