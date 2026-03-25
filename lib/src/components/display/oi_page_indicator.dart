import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A row of dots indicating the current page in a paged view.
///
/// Commonly used with carousels, onboarding flows, galleries, and any
/// horizontally-paged content. The active dot is highlighted with a
/// distinct color and optionally larger size.
///
/// {@category Components}
class OiPageIndicator extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveColor = color ?? colors.borderSubtle;
    final effectiveActiveColor = activeColor ?? colors.primary.base;
    final effectiveActiveSize = activeSize ?? size;

    return Semantics(
      label: semanticLabel ?? 'Page ${current + 1} of $count',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          final isActive = index == current;
          final dotSize = isActive ? effectiveActiveSize : size;
          final dotColor = isActive ? effectiveActiveColor : effectiveColor;

          final double dotWidth;
          if (isActive && _isPill) {
            dotWidth = dotSize * 2.5;
          } else {
            dotWidth = dotSize;
          }

          Widget dot = AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: dotWidth,
            height: dotSize,
            decoration: BoxDecoration(
              color: dotColor,
              borderRadius: BorderRadius.circular(dotSize / 2),
            ),
          );

          if (onDotTap != null) {
            dot = GestureDetector(
              onTap: () => onDotTap!(index),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: dot,
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : spacing),
            child: dot,
          );
        }),
      ),
    );
  }
}
