import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A numeric scale rating widget (e.g. NPS 1–10, satisfaction 1–7).
///
/// Renders a connected row of numbered buttons from [min] to [max]. The
/// currently selected button (matching [value]) is highlighted with a bold
/// label and tinted background. Hovering or focusing a button shows a subtle
/// primary-tinted background without changing the font weight.
///
/// Optional [minLabel] and [maxLabel] strings are shown at the left and right
/// ends below the scale. Arrow-key navigation moves the selection when focused.
///
/// When [enabled] is `false` all buttons are non-interactive.
///
/// {@category Components}
class OiScaleRating extends StatefulWidget {
  /// Creates an [OiScaleRating].
  const OiScaleRating({
    this.label,
    this.value,
    this.min = 1,
    this.max = 10,
    this.onChanged,
    this.minLabel,
    this.maxLabel,
    this.enabled = true,
    super.key,
  }) : assert(min <= max, 'min must be <= max');

  /// Accessible label announced by screen readers.
  final String? label;

  /// The currently selected value ([min] to [max]), or null for no selection.
  final int? value;

  /// The minimum scale value. Defaults to 1.
  final int min;

  /// The maximum scale value. Defaults to 10.
  final int max;

  /// Called when the user selects a number.
  final ValueChanged<int>? onChanged;

  /// Label shown to the left of the scale buttons (e.g. "Not likely").
  final String? minLabel;

  /// Label shown to the right of the scale buttons (e.g. "Very likely").
  final String? maxLabel;

  /// Whether the widget is interactive. Defaults to `true`.
  final bool enabled;

  @override
  State<OiScaleRating> createState() => _OiScaleRatingState();
}

class _OiScaleRatingState extends State<OiScaleRating> {
  int? _hoveredIndex;

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.enabled || widget.onChanged == null) {
      return KeyEventResult.ignored;
    }
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final current = widget.value ?? widget.min;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      final next = (current + 1).clamp(widget.min, widget.max);
      widget.onChanged?.call(next);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      final next = (current - 1).clamp(widget.min, widget.max);
      widget.onChanged?.call(next);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colors = context.colors;
    final radius = context.radius;
    final count = widget.max - widget.min + 1;

    final buttons = <Widget>[];
    for (var i = 0; i < count; i++) {
      final n = widget.min + i;
      final isSelected = widget.value == n;
      final isHovered = _hoveredIndex == i;

      Color bg;
      if (isSelected) {
        bg = colors.primary.muted;
      } else if (isHovered) {
        bg = colors.primary.base.withValues(alpha: 0.2 * 255 / 255);
      } else {
        bg = const Color(0x00000000);
      }

      final fontWeight = isSelected ? FontWeight.w700 : FontWeight.w500;

      Widget cell = GestureDetector(
        onTap: widget.enabled ? () => widget.onChanged?.call(n) : null,
        behavior: HitTestBehavior.opaque,
        child: MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onEnter: widget.enabled
              ? (_) => setState(() => _hoveredIndex = i)
              : null,
          onExit: widget.enabled
              ? (_) => setState(() => _hoveredIndex = null)
              : null,
          child: Container(
            height: 28,
            constraints: const BoxConstraints(minWidth: 32),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: bg,
            alignment: Alignment.center,
            child: Text(
              '$n',
              style: TextStyle(
                fontSize: 12,
                fontWeight: fontWeight,
                color: isSelected ? colors.primary.base : colors.text,
                height: 1,
              ),
            ),
          ),
        ),
      );

      if (!widget.enabled) {
        cell = Opacity(opacity: 0.4, child: cell);
      }

      buttons.add(cell);

      if (i < count - 1) {
        buttons.add(Container(width: 1, color: colors.border));
      }
    }

    Widget group = Focus(
      onKeyEvent: _onKeyEvent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius.sm,
          border: Border.all(color: colors.border),
        ),
        child: ClipRRect(
          borderRadius: radius.sm,
          child: Row(mainAxisSize: MainAxisSize.min, children: buttons),
        ),
      ),
    );

    if (widget.minLabel != null || widget.maxLabel != null) {
      group = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              group,
              const SizedBox(height: 4),
              Row(
                children: [
                  if (widget.minLabel != null)
                    Text(
                      widget.minLabel!,
                      style: textTheme.tiny.copyWith(color: colors.textMuted),
                    ),
                  const Spacer(),
                  if (widget.maxLabel != null)
                    Text(
                      widget.maxLabel!,
                      style: textTheme.tiny.copyWith(color: colors.textMuted),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      group = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: group,
      );
    }

    final semanticLabel = widget.label ??
        'Scale rating, selected: ${widget.value ?? 'none'} of ${widget.max}';

    return Semantics(label: semanticLabel, child: group);
  }
}
