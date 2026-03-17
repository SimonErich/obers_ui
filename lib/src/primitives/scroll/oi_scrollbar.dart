import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';

/// A platform-adaptive scrollbar that wraps any scrollable [child].
///
/// On pointer devices ([OiDensity.compact] or [OiDensity.dense]) the scrollbar
/// renders with full thumb visibility and an optional track, matching desktop
/// conventions. On touch devices ([OiDensity.comfortable]) it renders as a
/// thin overlay bar that is only visible while scrolling (unless [alwaysShow]
/// is `true`).
///
/// Uses [RawScrollbar] from `package:flutter/widgets.dart` — no Material
/// dependency.
///
/// ```dart
/// OiScrollbar(
///   controller: _scrollController,
///   child: ListView.builder(
///     controller: _scrollController,
///     itemCount: 100,
///     itemBuilder: (_, i) => Text('Item $i'),
///   ),
/// )
/// ```
///
/// {@category Primitives}
class OiScrollbar extends StatelessWidget {
  /// Creates an [OiScrollbar].
  const OiScrollbar({
    required this.child,
    this.controller,
    this.alwaysShow,
    this.showTrack,
    this.thickness,
    this.radius,
    super.key,
  });

  /// The scrollable child to wrap.
  final Widget child;

  /// The scroll controller that drives this scrollbar.
  ///
  /// Must be the same controller attached to the scrollable inside [child].
  final ScrollController? controller;

  /// Whether to always show the scrollbar thumb, even when not scrolling.
  ///
  /// Defaults to `true` on pointer devices, `false` on touch devices.
  final bool? alwaysShow;

  /// Whether to show the scrollbar track (the background rail).
  ///
  /// Defaults to `true` on pointer devices, `false` on touch devices.
  final bool? showTrack;

  /// Thickness of the scrollbar thumb in logical pixels.
  ///
  /// Defaults to `8.0` on pointer devices and `3.0` on touch devices.
  final double? thickness;

  /// Radius of the scrollbar thumb corners.
  final Radius? radius;

  @override
  Widget build(BuildContext context) {
    final density = OiDensityScope.of(context);
    final isPointer =
        density == OiDensity.compact || density == OiDensity.dense;

    if (isPointer) {
      final thumbVisible = alwaysShow ?? true;
      // Track requires thumb to also be visible; suppress track when thumb
      // is hidden to avoid the RawScrollbar invariant assertion.
      final trackVisible = thumbVisible && (showTrack ?? true);
      return RawScrollbar(
        controller: controller,
        thumbVisibility: thumbVisible,
        trackVisibility: trackVisible,
        thickness: thickness ?? 8,
        radius: radius ?? const Radius.circular(4),
        child: child,
      );
    }

    // Touch device — thin overlay scrollbar.
    return RawScrollbar(
      controller: controller,
      thumbVisibility: alwaysShow ?? false,
      trackVisibility: showTrack ?? false,
      thickness: thickness ?? 3,
      radius: radius ?? const Radius.circular(2),
      child: child,
    );
  }
}
