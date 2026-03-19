part of 'oi_table.dart';

// ── _OiTableLoadingBar ────────────────────────────────────────────────────

/// An indeterminate loading bar shown when [OiTableController.loading] is
/// `true`. Renders a thin animated bar across the top of the table body.
class _OiTableLoadingBar extends StatefulWidget {
  const _OiTableLoadingBar();

  @override
  State<_OiTableLoadingBar> createState() => _OiTableLoadingBarState();
}

class _OiTableLoadingBarState extends State<_OiTableLoadingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = context.animations.reducedMotion;
    _ctrl.duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 1500);
    if (reduced && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.value = 0;
    } else if (!reduced && !_ctrl.isAnimating) {
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          key: const Key('oi_table_loading_bar'),
          painter: _LoadingBarPainter(progress: _ctrl.value),
          size: const Size(double.infinity, 3),
        );
      },
    );
  }
}

class _LoadingBarPainter extends CustomPainter {
  const _LoadingBarPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Background track.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFE5E7EB),
    );
    // Animated bar segment.
    final barWidth = size.width * 0.3;
    final start = (size.width + barWidth) * progress - barWidth;
    canvas.drawRect(
      Rect.fromLTWH(start, 0, barWidth, size.height),
      Paint()..color = const Color(0xFF2563EB),
    );
  }

  @override
  bool shouldRepaint(_LoadingBarPainter old) => old.progress != progress;
}

// ── _OiTableSpinner ───────────────────────────────────────────────────────────

class _OiTableSpinner extends StatefulWidget {
  const _OiTableSpinner();

  @override
  State<_OiTableSpinner> createState() => _OiTableSpinnerState();
}

class _OiTableSpinnerState extends State<_OiTableSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = context.animations.reducedMotion;
    _ctrl.duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 800);
    if (reduced && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.value = 0;
    } else if (!reduced && !_ctrl.isAnimating) {
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CustomPaint(painter: _SpinnerPainter()),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      0,
      4.2,
      false,
      Paint()
        ..color = const Color(0xFF2563EB)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => false;
}
