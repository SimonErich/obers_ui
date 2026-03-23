import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_animation_config.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A custom page route with configurable transition animations.
///
/// [OiPageRoute] supports the five transition types defined by
/// [OiPageTransitionType]: fade, slide horizontal, slide vertical,
/// scale up, and none.
///
/// When the platform has disabled animations
/// (`MediaQuery.disableAnimationsOf` returns `true`), all transitions
/// fall back to an instant swap regardless of the configured type.
///
/// Use the [OiPageRoute.of] factory to automatically read transition
/// defaults from the nearest [OiTheme].
///
/// {@category Foundation}
class OiPageRoute<T> extends PageRoute<T> {
  /// Creates an [OiPageRoute] with explicit transition configuration.
  OiPageRoute({
    required this.builder,
    this.transition = OiPageTransitionType.fade,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    this.maintainState = true,
    super.fullscreenDialog,
    this.barrierColor,
    this.barrierDismissible = false,
    super.settings,
  })  : _transitionDuration =
            transitionDuration ?? const Duration(milliseconds: 250),
        _reverseTransitionDuration =
            reverseTransitionDuration ?? const Duration(milliseconds: 200);

  /// Creates an [OiPageRoute] that reads transition defaults from the
  /// nearest [OiTheme].
  ///
  /// If no theme is available, falls back to [OiPageTransitionType.fade]
  /// with a 250 ms duration.
  factory OiPageRoute.of({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    OiPageTransitionType? transition,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    final themeData = OiTheme.maybeOf(context);
    final animations = themeData?.animations;
    final effectiveTransition = transition ??
        animations?.defaultPageTransition ??
        OiPageTransitionType.fade;
    final effectiveDuration =
        animations?.pageTransitionDuration ??
        const Duration(milliseconds: 250);

    return OiPageRoute<T>(
      builder: builder,
      transition: effectiveTransition,
      transitionDuration: effectiveDuration,
      reverseTransitionDuration: effectiveDuration,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      settings: settings,
    );
  }

  /// Builds the page content.
  final Widget Function(BuildContext) builder;

  /// The transition animation type.
  final OiPageTransitionType transition;

  final Duration _transitionDuration;
  final Duration _reverseTransitionDuration;

  @override
  final bool maintainState;

  @override
  final Color? barrierColor;

  @override
  final bool barrierDismissible;

  @override
  String? get barrierLabel => null;

  @override
  bool get opaque => true;

  @override
  Duration get transitionDuration => _transitionDuration;

  @override
  Duration get reverseTransitionDuration => _reverseTransitionDuration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: builder(context),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Respect the platform "reduce motion" / "disable animations" setting.
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return child;
    }

    switch (transition) {
      case OiPageTransitionType.fade:
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: child,
        );

      case OiPageTransitionType.slideHorizontal:
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        final begin = isRtl ? const Offset(-1, 0) : const Offset(1, 0);
        return SlideTransition(
          position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        );

      case OiPageTransitionType.slideVertical:
        return SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                  .animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        );

      case OiPageTransitionType.scaleUp:
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );

      case OiPageTransitionType.none:
        return child;
    }
  }
}

/// A [Page] that creates an [OiPageRoute] with configurable transitions.
///
/// Use this with the declarative [Navigator] API (e.g. `Navigator.pages`).
///
/// ```dart
/// Navigator(
///   pages: [
///     OiTransitionPage(
///       child: HomePage(),
///       transition: OiPageTransitionType.fade,
///     ),
///   ],
/// )
/// ```
///
/// {@category Foundation}
class OiTransitionPage<T> extends Page<T> {
  /// Creates an [OiTransitionPage].
  const OiTransitionPage({
    required this.child,
    this.transition = OiPageTransitionType.fade,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.maintainState = true,
    this.fullscreenDialog = false,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  /// The widget displayed by this page.
  final Widget child;

  /// The transition animation type.
  final OiPageTransitionType transition;

  /// Duration of the forward transition. Defaults to 250 ms if not provided.
  final Duration? transitionDuration;

  /// Duration of the reverse transition. Defaults to 200 ms if not provided.
  final Duration? reverseTransitionDuration;

  /// Whether the route should remain in memory when it is not visible.
  final bool maintainState;

  /// Whether this page is a full-screen dialog.
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(BuildContext context) {
    return OiPageRoute<T>(
      builder: (_) => child,
      transition: transition,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      settings: this,
    );
  }
}
