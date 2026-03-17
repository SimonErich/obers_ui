import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// Scope that provides accessibility-related context to descendants.
///
/// Wrap your app (or a subtree) with this widget to enable [OiA11y]
/// utility methods. [OiApp] includes this automatically.
///
/// {@category Foundation}
class OiA11yScope extends InheritedWidget {
  /// Creates an [OiA11yScope].
  const OiA11yScope({
    required super.child,
    super.key,
  });

  @override
  bool updateShouldNotify(OiA11yScope oldWidget) => false;
}

/// Accessibility utilities for the obers_ui design system.
///
/// All methods are static and read from [BuildContext] when they need
/// platform/media information.
///
/// {@category Foundation}
abstract final class OiA11y {
  // Private constructor intentionally unreachable; class is static-only.
  // ignore: unused_element
  OiA11y._();

  /// The minimum touch target size in logical pixels on touch devices.
  ///
  /// Returns 48.0 on touch/mobile, 0.0 on pointer/desktop (no enforcement).
  static double minTouchTarget(BuildContext context) {
    if (kIsWeb) return 0;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
        return 48;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 0;
    }
  }

  /// Announces [message] to screen readers.
  ///
  /// When [isAssertive] is true, the announcement interrupts the screen
  /// reader immediately (use for errors and urgent updates).
  static void announce(
    BuildContext context,
    String message, {
    bool isAssertive = false,
  }) {
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      TextDirection.ltr,
      assertiveness: isAssertive
          ? Assertiveness.assertive
          : Assertiveness.polite,
    );
  }

  /// Whether the user has requested reduced motion.
  ///
  /// When true, animations should be suppressed or shortened.
  static bool reducedMotion(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context);
  }

  /// Whether the user has requested high-contrast mode.
  static bool highContrast(BuildContext context) {
    return MediaQuery.highContrastOf(context);
  }

  /// The current text scale factor.
  static double textScale(BuildContext context) {
    return MediaQuery.textScalerOf(context).scale(1);
  }

  /// Whether the user has requested bold text.
  static bool boldText(BuildContext context) {
    return MediaQuery.boldTextOf(context);
  }
}
