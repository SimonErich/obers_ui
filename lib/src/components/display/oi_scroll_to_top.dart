import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A floating button that appears when the user scrolls past a threshold
/// and scrolls back to the top on tap.
///
/// Wrap any scrollable widget in [OiScrollToTop] and provide the same
/// [ScrollController] used by the scrollable.
///
/// {@category Components}
class OiScrollToTop extends StatefulWidget {
  /// Creates an [OiScrollToTop].
  const OiScrollToTop({
    required this.controller,
    required this.child,
    this.threshold = 200.0,
    this.button,
    this.alignment = Alignment.bottomRight,
    this.padding = const EdgeInsets.all(16),
    this.semanticLabel = 'Scroll to top',
    super.key,
  });

  /// The scroll controller attached to the scrollable child.
  final ScrollController controller;

  /// The scrollable child widget.
  final Widget child;

  /// Scroll distance after which the button appears. Default: 200.
  final double threshold;

  /// Custom button widget. When null, a default themed button is used.
  final Widget? button;

  /// Position of the button within the stack. Default: bottomRight.
  final Alignment alignment;

  /// Padding around the floating button. Default: 16 on all sides.
  final EdgeInsets padding;

  /// Accessibility label for the button. Default: "Scroll to top".
  final String semanticLabel;

  @override
  State<OiScrollToTop> createState() => _OiScrollToTopState();
}

class _OiScrollToTopState extends State<OiScrollToTop>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    widget.controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(OiScrollToTop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    _fadeController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = widget.controller.offset > widget.threshold;
    if (shouldShow != _visible) {
      _visible = shouldShow;
      if (_visible) {
        _fadeController.forward();
      } else {
        _fadeController.reverse();
      }
    }
  }

  void _scrollToTop() {
    widget.controller.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shadows = context.shadows;

    final defaultButton = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        boxShadow: shadows.md,
      ),
      child: Icon(
        OiIcons.chevronUp,
        size: 20,
        color: colors.text,
      ),
    );

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !_visible,
            child: FadeTransition(
              opacity: _fadeController,
              child: Align(
                alignment: widget.alignment,
                child: Padding(
                  padding: widget.padding,
                  child: OiTappable(
                    onTap: _scrollToTop,
                    semanticLabel: widget.semanticLabel,
                    child: widget.button ?? defaultButton,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
