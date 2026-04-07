part of '../oi_context_menu.dart';

class _SubMenuWrapper extends StatefulWidget {
  const _SubMenuWrapper({
    required this.parentRect,
    required this.items,
    required this.onClose,
    required this.onCloseSubMenu,
  });

  final Rect parentRect;
  final List<OiMenuItem> items;
  final VoidCallback onClose;
  final VoidCallback onCloseSubMenu;

  @override
  State<_SubMenuWrapper> createState() => _SubMenuWrapperState();
}

class _SubMenuWrapperState extends State<_SubMenuWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
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
        : const Duration(milliseconds: 120);
    if (!_controller.isAnimating && _controller.value == 0) {
      unawaited(_controller.forward());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _SubMenuPositionDelegate(
        parentRect: widget.parentRect,
        screenPadding: const EdgeInsets.all(8),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: Alignment.topLeft,
          child: _MenuPanel(
            items: widget.items,
            onClose: widget.onClose,
            onCloseSubMenu: widget.onCloseSubMenu,
            isSubMenu: true,
          ),
        ),
      ),
    );
  }
}
