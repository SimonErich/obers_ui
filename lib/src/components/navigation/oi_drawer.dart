import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A slide-in navigation drawer that animates from the left edge.
///
/// When [open] is `true` the drawer slides into view; when `false` it slides
/// back off-screen. A semi-transparent scrim is placed behind the drawer when
/// it is open; tapping the scrim calls [onClose].
///
/// The drawer itself is a plain [DecoratedBox] (surface colour + right-side
/// shadow) that wraps [child]. Its width defaults to 280 logical pixels.
///
/// ```dart
/// OiDrawer(
///   open: _drawerOpen,
///   onClose: () => setState(() => _drawerOpen = false),
///   child: MyNavContent(),
/// )
/// ```
///
/// {@category Components}
class OiDrawer extends StatelessWidget {
  /// Creates an [OiDrawer].
  const OiDrawer({
    required this.child,
    required this.open,
    this.width = 280,
    this.onClose,
    super.key,
  });

  /// The navigation content rendered inside the drawer.
  final Widget child;

  /// The width of the drawer in logical pixels. Defaults to 280.
  final double width;

  /// Whether the drawer is currently visible.
  final bool open;

  /// Called when the drawer should close (e.g. the user taps the scrim).
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Slide offset: 0.0 = fully visible (left edge at 0), -1.0 = hidden.
    final slideOffset = open ? 0.0 : -1.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Scrim ────────────────────────────────────────────────────────────
        if (open)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: 1,
              duration: context.animations.reducedMotion ||
                      MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: GestureDetector(
                onTap: onClose,
                child: ColoredBox(color: colors.overlay),
              ),
            ),
          )
        else
          const SizedBox.shrink(),

        // ── Drawer panel ─────────────────────────────────────────────────────
        AnimatedSlide(
          offset: Offset(slideOffset, 0),
          duration: context.animations.reducedMotion ||
                  MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: width,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 24,
                      offset: Offset(4, 0),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
