import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/animation/oi_shimmer.dart';

/// A horizontal shimmer placeholder line.
///
/// Used inside an [OiSkeletonGroup] to represent a single line of text or
/// other narrow content while data is loading.
///
/// {@category Components}
class OiSkeletonLine extends StatelessWidget {
  /// Creates an [OiSkeletonLine].
  const OiSkeletonLine({
    this.width,
    this.height = 14,
    super.key,
  });

  /// Optional width constraint. Defaults to filling available width.
  final double? width;

  /// Height of the line in logical pixels. Defaults to 14.
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return OiShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.surfaceHover,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}

/// A rectangular shimmer placeholder block.
///
/// Used inside an [OiSkeletonGroup] to represent images, cards, or other
/// rectangular content while data is loading.
///
/// {@category Components}
class OiSkeletonBox extends StatelessWidget {
  /// Creates an [OiSkeletonBox].
  const OiSkeletonBox({
    this.width,
    this.height,
    super.key,
  });

  /// Optional width constraint. Defaults to filling available width.
  final double? width;

  /// Optional height constraint.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return OiShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.surfaceHover,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

/// A group of skeleton elements that can be toggled on/off together.
///
/// When [active] is `true` (the default), all [OiShimmer]-based children
/// animate. When `false` the children are rendered without shimmer by
/// replacing the [OiShimmer] `active` flag via an inherited [_SkeletonScope].
///
/// In practice [OiSkeletonLine] and [OiSkeletonBox] always wrap their content
/// in [OiShimmer] — the `active` propagation is handled per-widget via
/// [_SkeletonScope].
///
/// {@category Components}
class OiSkeletonGroup extends StatelessWidget {
  /// Creates an [OiSkeletonGroup].
  const OiSkeletonGroup({
    required this.children,
    this.active = true,
    super.key,
  });

  /// The skeleton elements to render.
  final List<Widget> children;

  /// When `false`, the shimmer animation is suppressed for all children.
  final bool active;

  @override
  Widget build(BuildContext context) {
    return _SkeletonScope(
      active: active,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inherited scope
// ---------------------------------------------------------------------------

/// An [InheritedWidget] that propagates the skeleton [active] state.
///
/// [OiSkeletonLine] and [OiSkeletonBox] can read this to conditionally
/// suppress the shimmer effect.
class _SkeletonScope extends InheritedWidget {
  const _SkeletonScope({required this.active, required super.child});

  /// Whether skeletons within this scope should animate.
  final bool active;

  @override
  bool updateShouldNotify(_SkeletonScope old) => old.active != active;
}
