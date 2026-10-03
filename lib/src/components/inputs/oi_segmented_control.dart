import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
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

/// An exclusive segment toggle that renders up to 5 options as connected
/// buttons (2–5 in typical use).
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
class OiSegmentedControl<T> extends StatefulWidget {
  /// Creates an [OiSegmentedControl].
  const OiSegmentedControl({
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.onReselected,
    this.enabled = true,
    this.size = OiSegmentedControlSize.medium,
    this.expand = false,
    this.showLabels = true,
    this.semanticLabel,
    super.key,
  }) : assert(segments.length <= 5, 'At most 5 segments are allowed');

  /// The list of segments to display.
  ///
  /// May contain up to 5 entries. Typically 2–5 segments are used. As a
  /// safeguard against dynamic data, the control degrades gracefully: an empty
  /// list renders nothing, and a single segment renders as a standalone pill.
  final List<OiSegment<T>> segments;

  /// Whether labels are visible beside icons. When false, segments with icons
  /// become square icon controls; labels remain their accessible names.
  /// Segments without icons continue to show their labels.
  final bool showLabels;

  /// The currently selected segment value.
  final T selected;

  /// Called with the new value when the user selects a different segment.
  final ValueChanged<T> onChanged;

  /// Optional activation of an already-selected segment, for example reopening
  /// a custom picker without changing the current selection.
  final ValueChanged<T>? onReselected;

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
  State<OiSegmentedControl<T>> createState() => _OiSegmentedControlState<T>();
}

class _OiSegmentedControlState<T> extends State<OiSegmentedControl<T>> {
  late List<FocusNode> _segmentFocusNodes;

  @override
  void initState() {
    super.initState();
    _segmentFocusNodes = List.generate(
      widget.segments.length,
      (_) => FocusNode(skipTraversal: true),
    );
  }

  @override
  void didUpdateWidget(OiSegmentedControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segments.length != widget.segments.length) {
      for (final node in _segmentFocusNodes) {
        node.dispose();
      }
      _segmentFocusNodes = List.generate(
        widget.segments.length,
        (_) => FocusNode(skipTraversal: true),
      );
    }
  }

  @override
  void dispose() {
    for (final node in _segmentFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _selectSegmentAt(int index) {
    if (index < 0 || index >= widget.segments.length) return;
    final segment = widget.segments[index];
    final isEnabled = widget.enabled && segment.enabled;
    if (!isEnabled) return;
    _segmentFocusNodes[index].requestFocus();
    widget.onChanged(segment.value);
  }

  int? _nextEnabledIndex(int start, int delta) {
    if (widget.segments.isEmpty) return null;
    for (var step = 1; step <= widget.segments.length; step++) {
      final idx =
          (start + (delta * step) + widget.segments.length) %
          widget.segments.length;
      if (widget.enabled && widget.segments[idx].enabled) {
        return idx;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Degrade gracefully when segment data is empty (e.g. from a dynamic list)
    // rather than throwing. A single segment falls through and renders as a
    // standalone pill via the loop below.
    if (widget.segments.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    final radius = context.radius;
    final animations = context.animations;
    final themeData = context.components.segmentedControl;

    final selectedColor = themeData?.selectedColor ?? colors.primary.muted;
    final backgroundColor = themeData?.backgroundColor ?? colors.surface;
    final selectedTextColor =
        themeData?.selectedTextColor ?? colors.primary.foreground;
    final unselectedTextColor = themeData?.unselectedTextColor ?? colors.text;
    final borderColor = themeData?.borderColor ?? colors.border;

    final reducedMotion =
        animations.reducedMotion || MediaQuery.disableAnimationsOf(context);
    final animDuration = reducedMotion ? Duration.zero : animations.fast;

    final segmentHeight =
        themeData?.height ??
        switch (widget.size) {
          OiSegmentedControlSize.small => 28.0,
          OiSegmentedControlSize.medium => 36.0,
          OiSegmentedControlSize.large => 44.0,
        };

    final fontSize = switch (widget.size) {
      OiSegmentedControlSize.small => 12.0,
      OiSegmentedControlSize.medium => 14.0,
      OiSegmentedControlSize.large => 16.0,
    };

    final iconSize = switch (widget.size) {
      OiSegmentedControlSize.small => 14.0,
      OiSegmentedControlSize.medium => 16.0,
      OiSegmentedControlSize.large => 18.0,
    };

    final horizontalPadding = switch (widget.size) {
      OiSegmentedControlSize.small => 8.0,
      OiSegmentedControlSize.medium => 12.0,
      OiSegmentedControlSize.large => 16.0,
    };

    // Resolve the base radius value from the theme override or sm scale.
    final baseRadius = themeData?.borderRadius?.topLeft ?? radius.sm.topLeft;
    final inset = themeData?.inset ?? 0;

    final children = <Widget>[];

    for (var i = 0; i < widget.segments.length; i++) {
      final segment = widget.segments[i];
      final isSelected = segment.value == widget.selected;
      final isFirst = i == 0;
      final isLast = i == widget.segments.length - 1;
      final isEnabled = widget.enabled && segment.enabled;
      final iconOnly = !widget.showLabels && segment.icon != null;

      // Compute per-segment border radius: left on first, right on last.
      final segmentRadius = inset > 0
          ? themeData?.innerRadius ?? BorderRadius.all(baseRadius)
          : BorderRadius.only(
              topLeft: isFirst ? baseRadius : Radius.zero,
              bottomLeft: isFirst ? baseRadius : Radius.zero,
              topRight: isLast ? baseRadius : Radius.zero,
              bottomRight: isLast ? baseRadius : Radius.zero,
            );

      final bgColor = isSelected
          ? selectedColor
          : inset > 0
          ? const Color(0x00000000)
          : backgroundColor;
      final textColor = isSelected ? selectedTextColor : unselectedTextColor;

      // Build label content.
      Widget labelWidget = Text(
        segment.label,
        style: (themeData?.labelStyle ?? const TextStyle()).copyWith(
          fontSize: themeData?.labelStyle?.fontSize ?? fontSize,
          fontWeight:
              themeData?.labelStyle?.fontWeight ??
              (isSelected ? FontWeight.w600 : FontWeight.w400),
          color: textColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );

      // Prepend icon if present.
      if (iconOnly) {
        labelWidget = OiIcon.decorative(
          icon: segment.icon,
          size: iconSize,
          color: textColor,
        );
      } else if (segment.icon != null) {
        labelWidget = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OiIcon.raw(segment.icon, size: iconSize, color: textColor),
            const SizedBox(width: 4),
            Flexible(child: labelWidget),
          ],
        );
      }

      // Build the segment border. Shared borders: only the left border is
      // drawn on non-first segments to avoid double borders.
      final segmentBorder = Border(
        top: BorderSide(color: borderColor),
        bottom: BorderSide(color: borderColor),
        left: isFirst
            ? BorderSide(color: borderColor)
            : BorderSide(color: borderColor, width: 0.5),
        right: isLast
            ? BorderSide(color: borderColor)
            : BorderSide(color: borderColor, width: 0.5),
      );

      Widget segmentWidget = AnimatedContainer(
        duration: animDuration,
        height: (segmentHeight - 2 * inset).clamp(0, double.infinity),
        width: iconOnly && !widget.expand ? segmentHeight - 2 * inset : null,
        padding: iconOnly
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: segmentRadius,
          border: inset > 0 ? null : segmentBorder,
        ),
        alignment: Alignment.center,
        child: labelWidget,
      );

      // Keep the name, selected state and activation action on one button.
      // The arrow-key focus handler is an implementation detail, not another
      // accessible control nested inside the segment.
      segmentWidget = MergeSemantics(
        child: Semantics(
          selected: isSelected,
          child: OiTappable(
            semanticLabel: segment.semanticLabel ?? segment.label,
            onTap: isEnabled
                ? () {
                    _segmentFocusNodes[i].requestFocus();
                    if (!isSelected) {
                      widget.onChanged(segment.value);
                    } else {
                      widget.onReselected?.call(segment.value);
                    }
                  }
                : null,
            enabled: isEnabled,
            child: _SegmentKeyboardHandler<T>(
              index: i,
              enabled: isEnabled,
              focusNode: _segmentFocusNodes[i],
              nextEnabledIndex: _nextEnabledIndex,
              onSelectIndex: _selectSegmentAt,
              child: ExcludeSemantics(child: segmentWidget),
            ),
          ),
        ),
      );

      if (widget.expand) {
        segmentWidget = Expanded(child: segmentWidget);
      }

      if (children.isNotEmpty &&
          widget.showLabels &&
          (themeData?.spacing ?? 0) > 0) {
        children.add(SizedBox(width: themeData!.spacing));
      }
      children.add(segmentWidget);
    }

    Widget row = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      children: children,
    );
    if (inset > 0) {
      row = DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: themeData?.borderRadius ?? BorderRadius.all(baseRadius),
        ),
        child: Padding(padding: EdgeInsets.all(inset), child: row),
      );
    }
    // Wrap with group-level semantics.
    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: row,
    );
  }
}

/// Internal widget that handles keyboard arrow-key navigation within a segment.
class _SegmentKeyboardHandler<T> extends StatelessWidget {
  const _SegmentKeyboardHandler({
    required this.index,
    required this.enabled,
    required this.focusNode,
    required this.nextEnabledIndex,
    required this.onSelectIndex,
    required this.child,
  });

  final int index;
  final bool enabled;
  final FocusNode focusNode;
  final int? Function(int start, int delta) nextEnabledIndex;
  final ValueChanged<int> onSelectIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      includeSemantics: false,
      onKeyEvent: (node, event) {
        if (!enabled) return KeyEventResult.ignored;
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        int delta;
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          delta = 1;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          delta = -1;
        } else {
          return KeyEventResult.ignored;
        }

        final nextIndex = nextEnabledIndex(index, delta);
        if (nextIndex != null && nextIndex != index) {
          onSelectIndex(nextIndex);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
