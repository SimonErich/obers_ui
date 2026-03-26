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
    final reduced =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    _ctrl.duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 1500);
    if (reduced && _ctrl.isAnimating) {
      _ctrl
        ..stop()
        ..value = 0;
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
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          key: const Key('oi_table_loading_bar'),
          painter: _LoadingBarPainter(
            progress: _ctrl.value,
            trackColor: colors.borderSubtle,
            barColor: colors.primary.base,
          ),
          size: const Size(double.infinity, 3),
        );
      },
    );
  }
}

class _LoadingBarPainter extends CustomPainter {
  const _LoadingBarPainter({
    required this.progress,
    required this.trackColor,
    required this.barColor,
  });

  final double progress;
  final Color trackColor;
  final Color barColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Background track.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = trackColor,
    );
    // Animated bar segment.
    final barWidth = size.width * 0.3;
    final start = (size.width + barWidth) * progress - barWidth;
    canvas.drawRect(
      Rect.fromLTWH(start, 0, barWidth, size.height),
      Paint()..color = barColor,
    );
  }

  @override
  bool shouldRepaint(_LoadingBarPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.barColor != barColor;
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
    final reduced =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    _ctrl.duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 800);
    if (reduced && _ctrl.isAnimating) {
      _ctrl
        ..stop()
        ..value = 0;
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
    final spinnerColor = context.colors.primary.base;
    return RotationTransition(
      turns: _ctrl,
      child: SizedBox(
        width: 24,
        height: 24,
        child: CustomPaint(painter: _SpinnerPainter(color: spinnerColor)),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      0,
      4.2,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => old.color != color;
}
