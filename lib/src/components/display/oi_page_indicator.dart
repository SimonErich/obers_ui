import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A row of dots indicating the current page in a paged view.
///
/// Commonly used with carousels, onboarding flows, galleries, and any
/// horizontally-paged content. The active dot is highlighted with a
/// distinct color and optionally larger size.
///
/// {@category Components}
class OiPageIndicator extends StatefulWidget {
  /// Creates an [OiPageIndicator] with circular dots.
  const OiPageIndicator({
    required this.count,
    required this.current,
    this.onDotTap,
    this.color,
    this.activeColor,
    this.size = 8.0,
    this.activeSize,
    this.spacing = 8.0,
    this.semanticLabel,
    super.key,
  }) : _isPill = false;

  /// Creates an [OiPageIndicator] with a pill-shaped active indicator.
  ///
  /// The active indicator stretches to a wider pill shape while inactive
  /// dots remain circular.
  const OiPageIndicator.pill({
    required this.count,
    required this.current,
    this.onDotTap,
    this.color,
    this.activeColor,
    this.size = 8.0,
    this.activeSize,
    this.spacing = 8.0,
    this.semanticLabel,
    super.key,
  }) : _isPill = true;

  /// Total number of pages.
  final int count;

  /// Index of the currently active page (zero-based).
  final int current;

  /// Color of inactive dots. Defaults to theme border subtle color.
  final Color? color;

  /// Color of the active dot. Defaults to theme primary color.
  final Color? activeColor;

  /// Diameter of each dot. Default: 8.
  final double size;

  /// Diameter (or height) of the active dot. Defaults to [size].
  final double? activeSize;

  /// Spacing between dots. Default: 8.
  final double spacing;

  /// Called with the tapped dot index when a dot is tapped.
  final ValueChanged<int>? onDotTap;

  /// Accessibility label for the indicator group.
  final String? semanticLabel;

  final bool _isPill;

  @override
  State<OiPageIndicator> createState() => _OiPageIndicatorState();
}

class _OiPageIndicatorState extends State<OiPageIndicator> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveColor = widget.color ?? colors.borderSubtle;
    final effectiveActiveColor = widget.activeColor ?? colors.primary.base;
    final effectiveActiveSize = widget.activeSize ?? widget.size;

    return Semantics(
      label:
          widget.semanticLabel ??
          'Page ${widget.current + 1} of ${widget.count}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.count, (index) {
          final isActive = index == widget.current;
          final isHovered = _hoveredIndex == index;
          final dotSize = isActive ? effectiveActiveSize : widget.size;

          Color dotColor;
          if (isActive) {
            dotColor = effectiveActiveColor;
          } else if (isHovered) {
            dotColor = effectiveActiveColor.withValues(alpha: 0.5);
          } else {
            dotColor = effectiveColor;
          }

          final double dotWidth;
          if (isActive && widget._isPill) {
            dotWidth = dotSize * 2.5;
          } else if (isHovered && widget._isPill) {
            dotWidth = dotSize * 1.5;
          } else {
            dotWidth = dotSize;
          }

          final double dotHeight;
          if (isHovered && !isActive) {
            dotHeight = dotSize * 1.25;
          } else {
            dotHeight = dotSize;
          }

          final double dotEffectiveWidth;
          if (isHovered && !isActive && !widget._isPill) {
            dotEffectiveWidth = dotWidth * 1.25;
          } else {
            dotEffectiveWidth = dotWidth;
          }

          // Reserve the max hover height so the row doesn't shift on hover.
          final maxHeight = (isActive ? dotSize : dotSize * 1.25) + 8;

          Widget dot = SizedBox(
            height: maxHeight,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: dotEffectiveWidth,
                height: dotHeight,
                decoration: BoxDecoration(
                  color: dotColor,
                  borderRadius: BorderRadius.circular(dotHeight / 2),
                ),
              ),
            ),
          );

          dot = MouseRegion(
            cursor: widget.onDotTap != null
                ? SystemMouseCursors.click
                : MouseCursor.defer,
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: dot,
          );

          if (widget.onDotTap != null) {
            dot = GestureDetector(
              onTap: () => widget.onDotTap!(index),
              behavior: HitTestBehavior.opaque,
              child: dot,
            );
          }

          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : widget.spacing),
            child: dot,
          );
        }),
      ),
    );
  }
}
