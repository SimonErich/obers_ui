part of '../oi_chat_window.dart';

// ── Internal widgets (streaming cursor, hover chrome) ─────────────────────────

class _StreamingCursor extends StatefulWidget {
  const _StreamingCursor({required this.color});

  final Color color;

  @override
  State<_StreamingCursor> createState() => _StreamingCursorState();
}

class _StreamingCursorState extends State<_StreamingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    unawaited(_controller.repeat(reverse: true));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: Text(
            '\u258C', // ▌
            style: TextStyle(color: widget.color, fontSize: 16),
          ),
        );
      },
    );
  }
}

/// Wraps [child] and shows [actionBar] on hover.
///
/// The action bar is positioned above user messages and below assistant
/// messages to avoid covering content.
class _HoverActionWrapper extends StatefulWidget {
  const _HoverActionWrapper({
    required this.child,
    required this.actionBar,
    required this.userAligned,
  });

  final Widget child;
  final Widget actionBar;
  final bool userAligned;

  @override
  State<_HoverActionWrapper> createState() => _HoverActionWrapperState();
}

class _HoverActionWrapperState extends State<_HoverActionWrapper> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          if (_hovered)
            Positioned(
              top: -28,
              right: widget.userAligned ? 0 : null,
              left: widget.userAligned ? null : 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: radius.sm,
                  border: Border.all(color: colors.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: colors.overlay.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: widget.actionBar,
              ),
            ),
        ],
      ),
    );
  }
}
