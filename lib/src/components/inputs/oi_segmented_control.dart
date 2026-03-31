import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A single segment entry in an [OiSegmentedControl].
///
/// Each segment represents one exclusive option within the control. The generic
/// type [T] identifies the value associated with this segment.
///
/// {@category Components}
@immutable
class OiSegment<T> {
  /// Creates an [OiSegment].
  const OiSegment({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
    this.semanticLabel,
  });

  /// The value this segment represents.
  ///
  /// When selected, this value is passed to [OiSegmentedControl.onChanged].
  final T value;

  /// The text label displayed inside the segment.
  final String label;

  /// An optional icon displayed alongside [label].
  final IconData? icon;

  /// Whether this individual segment is interactive.
  ///
  /// When `false`, the segment is rendered in a disabled style and cannot be
  /// selected, even if the parent [OiSegmentedControl] is enabled.
  final bool enabled;

  /// An optional accessibility label for screen readers.
  ///
  /// When provided, this overrides the default semantic content derived from
  /// [label].
  final String? semanticLabel;
}

/// The size of an [OiSegmentedControl].
///
/// Controls the height and internal padding of each segment.
///
/// {@category Components}
enum OiSegmentedControlSize {
  /// Small size — 28dp height.
  small,

  /// Medium size — 36dp height. The default.
  medium,

  /// Large size — 44dp height.
  large,
}

/// An exclusive segment toggle that renders 2–5 options as connected buttons.
///
/// Exactly one segment is selected at a time. Tapping an inactive segment fires
/// [onChanged] with the corresponding [OiSegment.value].
///
/// The control renders as a horizontal row of connected segments sharing a
/// common border. The first segment has a left radius, the last has a right
/// radius, and middle segments have no corner rounding, giving the appearance
/// of a single connected control.
///
/// Keyboard navigation is supported: Tab focuses the group, and the left/right
/// arrow keys move the selection between segments.
///
/// ```dart
/// OiSegmentedControl<String>(
///   segments: [
///     OiSegment(value: 'day', label: 'Day'),
///     OiSegment(value: 'week', label: 'Week'),
///     OiSegment(value: 'month', label: 'Month'),
///   ],
///   selected: _view,
///   onChanged: (value) => setState(() => _view = value),
/// )
/// ```
///
/// {@category Components}
class OiSegmentedControl<T> extends StatelessWidget {
  /// Creates an [OiSegmentedControl].
  const OiSegmentedControl({
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
    this.size = OiSegmentedControlSize.medium,
    this.expand = false,
    this.semanticLabel,
    super.key,
  }) : assert(segments.length >= 2, 'At least 2 segments are required'),
       assert(segments.length <= 5, 'At most 5 segments are allowed');

  /// The list of segments to display.
  ///
  /// Must contain between 2 and 5 entries (inclusive).
  final List<OiSegment<T>> segments;

  /// The currently selected segment value.
  final T selected;

  /// Called with the new value when the user selects a different segment.
  final ValueChanged<T> onChanged;

  /// Whether the entire control is interactive.
  ///
  /// When `false`, all segments are rendered in a disabled style regardless of
  /// their individual [OiSegment.enabled] state.
  final bool enabled;

  /// The size variant of the control.
  ///
  /// Determines the height and internal padding of each segment.
  final OiSegmentedControlSize size;

  /// Whether each segment should expand to fill equal width.
  ///
  /// When `true`, the control stretches to fill available horizontal space and
  /// each segment receives equal width. When `false` (default), segments are
  /// sized to fit their content.
  final bool expand;

  /// An optional accessibility label for the entire group.
  ///
  /// Announced by screen readers to describe the purpose of the control.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final animations = context.animations;

    final reducedMotion =
        animations.reducedMotion || MediaQuery.disableAnimationsOf(context);
    final animDuration = reducedMotion ? Duration.zero : animations.fast;

    final segmentHeight = switch (size) {
      OiSegmentedControlSize.small => 28.0,
      OiSegmentedControlSize.medium => 36.0,
      OiSegmentedControlSize.large => 44.0,
    };

    final fontSize = switch (size) {
      OiSegmentedControlSize.small => 12.0,
      OiSegmentedControlSize.medium => 14.0,
      OiSegmentedControlSize.large => 16.0,
    };

    final iconSize = switch (size) {
      OiSegmentedControlSize.small => 14.0,
      OiSegmentedControlSize.medium => 16.0,
      OiSegmentedControlSize.large => 18.0,
    };

    final horizontalPadding = switch (size) {
      OiSegmentedControlSize.small => 8.0,
      OiSegmentedControlSize.medium => 12.0,
      OiSegmentedControlSize.large => 16.0,
    };

    // Resolve the base radius value from the theme's sm scale.
    final baseRadius = radius.sm.topLeft;

    final children = <Widget>[];

    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final isSelected = segment.value == selected;
      final isFirst = i == 0;
      final isLast = i == segments.length - 1;
      final isEnabled = enabled && segment.enabled;

      // Compute per-segment border radius: left on first, right on last.
      final segmentRadius = BorderRadius.only(
        topLeft: isFirst ? baseRadius : Radius.zero,
        bottomLeft: isFirst ? baseRadius : Radius.zero,
        topRight: isLast ? baseRadius : Radius.zero,
        bottomRight: isLast ? baseRadius : Radius.zero,
      );

      final bgColor =
          isSelected ? colors.primary.muted : colors.surface;
      final textColor =
          isSelected ? colors.primary.foreground : colors.text;

      // Build label content.
      Widget labelWidget = Text(
        segment.label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );

      // Prepend icon if present.
      if (segment.icon != null) {
        labelWidget = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(segment.icon, size: iconSize, color: textColor),
            const SizedBox(width: 4),
            Flexible(child: labelWidget),
          ],
        );
      }

      // Build the segment border. Shared borders: only the left border is
      // drawn on non-first segments to avoid double borders.
      final segmentBorder = Border(
        top: BorderSide(color: colors.border),
        bottom: BorderSide(color: colors.border),
        left: isFirst
            ? BorderSide(color: colors.border)
            : BorderSide(color: colors.border, width: 0.5),
        right: isLast
            ? BorderSide(color: colors.border)
            : BorderSide(color: colors.border, width: 0.5),
      );

      Widget segmentWidget = AnimatedContainer(
        duration: animDuration,
        height: segmentHeight,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: segmentRadius,
          border: segmentBorder,
        ),
        alignment: Alignment.center,
        child: labelWidget,
      );

      segmentWidget = Semantics(
        selected: isSelected,
        enabled: isEnabled,
        label: segment.semanticLabel ?? segment.label,
        child: OiTappable(
          onTap: isEnabled && !isSelected
              ? () => onChanged(segment.value)
              : null,
          enabled: isEnabled,
          child: _SegmentKeyboardHandler<T>(
            index: i,
            segmentCount: segments.length,
            segments: segments,
            selected: selected,
            onChanged: onChanged,
            enabled: isEnabled,
            child: segmentWidget,
          ),
        ),
      );

      if (expand) {
        segmentWidget = Expanded(child: segmentWidget);
      }

      children.add(segmentWidget);
    }

    // Wrap with group-level semantics.
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: children,
      ),
    );
  }
}

/// Internal widget that handles keyboard arrow-key navigation within a segment.
class _SegmentKeyboardHandler<T> extends StatelessWidget {
  const _SegmentKeyboardHandler({
    required this.index,
    required this.segmentCount,
    required this.segments,
    required this.selected,
    required this.onChanged,
    required this.enabled,
    required this.child,
  });

  final int index;
  final int segmentCount;
  final List<OiSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(skipTraversal: true),
      onKeyEvent: (event) {
        if (!enabled) return;
        if (event is! KeyDownEvent) return;

        int? nextIndex;
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          nextIndex = (index + 1) % segmentCount;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          nextIndex = (index - 1 + segmentCount) % segmentCount;
        }

        if (nextIndex != null && segments[nextIndex].enabled) {
          onChanged(segments[nextIndex].value);
        }
      },
      child: child,
    );
  }
}
