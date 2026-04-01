part of '../oi_context_menu.dart';

class _ContextMenuRoot extends StatefulWidget {
  const _ContextMenuRoot({
    required this.position,
    required this.items,
    required this.onClose,
  });

  final Offset position;
  final List<OiMenuItem> items;
  final VoidCallback onClose;

  @override
  State<_ContextMenuRoot> createState() => _ContextMenuRootState();
}

class _ContextMenuRootState extends State<_ContextMenuRoot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced =
        context.animations.reducedMotion ||
        (MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    _controller.duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 150);
    if (!_controller.isAnimating && _controller.value == 0) {
      unawaited(_controller.forward());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Alignment _scaleAlignment(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    const padding = 8.0;
    const estimate = 200.0;

    final overflowsRight =
        widget.position.dx + estimate > screen.width - padding;
    final overflowsBottom =
        widget.position.dy + estimate > screen.height - padding;

    return Alignment(overflowsRight ? 1 : -1, overflowsBottom ? 1 : -1);
  }

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _CursorPositionDelegate(
        cursorPosition: widget.position,
        screenPadding: const EdgeInsets.all(8),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: _scaleAlignment(context),
          child: _MenuPanel(items: widget.items, onClose: widget.onClose),
        ),
      ),
    );
  }
}
