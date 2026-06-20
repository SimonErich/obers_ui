import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// A performance stress-test page for input fields.
///
/// Renders a large grid of [OiTextInput]s with a live frame-time readout so the
/// per-field cost of focus transitions and keystrokes is measurable. Use with
/// `flutter run --profile -d chrome`: pick a field count, hit Reset worst, then
/// click/tab through ~10 fields at a steady pace and read the worst frame.
///
/// Findings (profile, Chrome, 60 fields): a bare text field already costs
/// ~16.7ms/frame (web-renderer floor); the animated input frame adds ~7ms;
/// scoping the focus rebuild saves only ~1.3ms. So the dominant cost is the
/// web text/render path, not widget rebuilds.
class InputStressScreen extends StatefulWidget {
  const InputStressScreen({super.key});

  @override
  State<InputStressScreen> createState() => _InputStressScreenState();
}

class _InputStressScreenState extends State<InputStressScreen> {
  int _fieldCount = 60;

  Duration _lastFrame = Duration.zero;
  Duration _worstFrame = Duration.zero;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    super.dispose();
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    if (!mounted) return;
    for (final t in timings) {
      final span = t.totalSpan;
      _lastFrame = span;
      if (span > _worstFrame) _worstFrame = span;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  void _resetWorst() => setState(() => _worstFrame = Duration.zero);

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    final lastMs = _lastFrame.inMicroseconds / 1000.0;
    final worstMs = _worstFrame.inMicroseconds / 1000.0;
    final janky = worstMs > 16.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OiLabel.h2('Input Stress Test'),
          SizedBox(height: spacing.xs),
          const OiLabel.body(
            'Hit Reset worst, then click/tab through ~10 fields at a steady '
            'pace and read the worst frame. Measure in profile mode.',
          ),
          SizedBox(height: spacing.lg),

          // ── Live readout ──────────────────────────────────────────────
          Row(
            children: [
              _stat('Last frame', '${lastMs.toStringAsFixed(1)} ms', colors),
              SizedBox(width: spacing.lg),
              _stat(
                'Worst frame',
                '${worstMs.toStringAsFixed(1)} ms',
                colors,
                bad: janky,
              ),
              SizedBox(width: spacing.lg),
              _stat('Fields', '$_fieldCount', colors),
              SizedBox(width: spacing.lg),
              OiButton.outline(label: 'Reset worst', onTap: _resetWorst),
              SizedBox(width: spacing.sm),
              OiButton.outline(
                label: '+20 fields',
                onTap: () => setState(() => _fieldCount += 20),
              ),
            ],
          ),
          SizedBox(height: spacing.xl),

          // ── The grid of fields ────────────────────────────────────────
          Wrap(
            spacing: spacing.md,
            runSpacing: spacing.md,
            children: [
              for (var i = 0; i < _fieldCount; i++)
                SizedBox(
                  width: 260,
                  child: OiTextInput(
                    label: 'Field ${i + 1}',
                    placeholder: 'Type or focus me…',
                    hint: 'Hint line',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(
    String label,
    String value,
    OiColorScheme colors, {
    bool bad = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OiLabel.smallStrong(label),
        OiLabel.h4(value, color: bad ? colors.error.base : colors.text),
      ],
    );
  }
}
