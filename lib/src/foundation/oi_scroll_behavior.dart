import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Custom [ScrollBehavior] that strips Material's Android overscroll glow
/// and picks platform-appropriate physics.
///
/// Injected at the root of [OiApp] via [ScrollConfiguration] so every
/// scrollable in the tree inherits it automatically.
///
/// {@category Foundation}
class OiScrollBehavior extends ScrollBehavior {
  /// Creates an [OiScrollBehavior].
  const OiScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const BouncingScrollPhysics();
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const ClampingScrollPhysics();
    }
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
