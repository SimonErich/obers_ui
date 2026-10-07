part of '../oi_toast.dart';

class _OiToastState extends State<OiToast> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  Timer? _timer;
  bool _hovered = false;
  bool _animationStarted = false;
  bool _dismissing = false;

  static const Duration _animDuration = Duration(milliseconds: 220);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scheduleTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    _controller.duration = reduced ? Duration.zero : _animDuration;
    if (!_animationStarted) {
      _animationStarted = true;
      _controller.forward();
    }
  }

  void _scheduleTimer() {
    _timer?.cancel();
    final duration = widget.duration;
    if (duration != null) _timer = Timer(duration, _dismiss);
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    widget.onPauseRequested?.call();
  }

  void _resumeTimer() {
    widget.onResumeRequested?.call();
    if (_timer == null && !_hovered) {
      _scheduleTimer();
    }
  }

  Future<void> _dismiss() async {
    if (!mounted || _dismissing) return;
    _dismissing = true;
    await _controller.reverse();
    if (mounted) widget.onDismiss?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget toast = _OiToastSurface(toast: widget, onDismiss: _dismiss);

    if (widget.pauseOnHover) {
      toast = MouseRegion(
        onEnter: (_) {
          _hovered = true;
          _pauseTimer();
        },
        onExit: (_) {
          _hovered = false;
          _resumeTimer();
        },
        child: toast,
      );
    }

    // Pause on long-press for touch devices.
    toast = GestureDetector(
      onLongPressStart: (_) => _pauseTimer(),
      onLongPressEnd: (_) => _resumeTimer(),
      child: toast,
    );

    return FadeTransition(
      opacity: _opacity,
      alwaysIncludeSemantics: true,
      child: toast,
    );
  }
}
