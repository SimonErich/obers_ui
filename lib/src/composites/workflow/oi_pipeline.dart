import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// The status of a pipeline stage.
///
/// Each status maps to a distinct visual treatment (icon and color) in
/// the [OiPipeline] widget.
enum OiPipelineStatus {
  /// The stage has not yet started.
  pending,

  /// The stage is currently executing.
  running,

  /// The stage finished successfully.
  completed,

  /// The stage encountered an error.
  failed,

  /// The stage was intentionally skipped.
  skipped,
}

/// A stage in the pipeline.
///
/// Each stage has a [label], a [status], an optional [content] widget
/// rendered inside the stage card, and an optional [duration] for timing
/// information.
class OiPipelineStage {
  /// Creates an [OiPipelineStage].
  const OiPipelineStage({
    required this.label,
    required this.status,
    this.content,
    this.duration,
  });

  /// The display label for this stage.
  final String label;

  /// The current status of this stage.
  final OiPipelineStatus status;

  /// Optional content widget shown inside the stage card.
  final Widget? content;

  /// Optional duration for running or completed stages.
  final Duration? duration;
}

/// A linear pipeline/workflow view showing sequential stages with status.
///
/// Like CI/CD pipeline visualization. Each stage shows its status
/// (pending, running, completed, failed, skipped) with connecting arrows.
///
/// {@category Composites}
class OiPipeline extends StatelessWidget {
  /// Creates an [OiPipeline].
  const OiPipeline({
    required this.stages,
    required this.label,
    this.direction = Axis.horizontal,
    this.onStageTap,
    super.key,
  });

  /// The stages in the pipeline.
  final List<OiPipelineStage> stages;

  /// Accessibility label for the pipeline.
  final String label;

  /// The direction of the pipeline layout.
  final Axis direction;

  /// Called when a stage is tapped, with the stage index.
  final ValueChanged<int>? onStageTap;

  // ---------------------------------------------------------------------------
  // Status helpers
  // ---------------------------------------------------------------------------

  /// Returns the color for a given status.
  static Color statusColor(OiPipelineStatus status, BuildContext context) {
    final colors = context.colors;
    switch (status) {
      case OiPipelineStatus.completed:
        return colors.success.base;
      case OiPipelineStatus.failed:
        return colors.error.base;
      case OiPipelineStatus.running:
        return colors.info.base;
      case OiPipelineStatus.pending:
      case OiPipelineStatus.skipped:
        return colors.textMuted;
    }
  }

  /// Returns the icon data for a given status.
  static IconData statusIcon(OiPipelineStatus status) {
    switch (status) {
      case OiPipelineStatus.completed:
        return OiIcons.circleCheck; // check_circle
      case OiPipelineStatus.failed:
        return OiIcons.circleAlert; // error
      case OiPipelineStatus.running:
        return OiIcons.circlePlay; // play_circle_filled
      case OiPipelineStatus.pending:
        return OiIcons.ban; // radio_button_unchecked
      case OiPipelineStatus.skipped:
        return OiIcons.ban; // block
    }
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    if (d.inMinutes > 0) {
      return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    }
    return '${d.inSeconds}s';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  Widget _buildStage(BuildContext context, int index) {
    final stage = stages[index];
    final colors = context.colors;
    final stageColor = statusColor(stage.status, context);

    Widget stageWidget = Container(
      key: ValueKey('oi_pipeline_stage_$index'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: stageColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon(stage.status), color: stageColor, size: 24),
          const SizedBox(height: 4),
          Text(
            stage.label,
            style: TextStyle(
              color: colors.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (stage.duration != null) ...[
            const SizedBox(height: 2),
            Text(
              _formatDuration(stage.duration!),
              key: ValueKey('oi_pipeline_duration_$index'),
              style: TextStyle(color: colors.textMuted, fontSize: 11),
            ),
          ],
          if (stage.content != null) ...[
            const SizedBox(height: 4),
            stage.content!,
          ],
        ],
      ),
    );

    if (onStageTap != null) {
      stageWidget = GestureDetector(
        onTap: () => onStageTap!(index),
        child: stageWidget,
      );
    }

    return stageWidget;
  }

  Widget _buildArrow(BuildContext context, int index) {
    final colors = context.colors;
    final isHorizontal = direction == Axis.horizontal;
    const arrowSize = 16.0;

    return SizedBox(
      key: ValueKey('oi_pipeline_arrow_$index'),
      width: isHorizontal ? arrowSize : null,
      height: isHorizontal ? null : arrowSize,
      child: Center(
        child: Icon(
          isHorizontal
              ? OiIcons.chevronRight // chevron_right
              : OiIcons.chevronDown, // expand_more
          color: colors.textMuted,
          size: arrowSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (var i = 0; i < stages.length; i++) {
      if (i > 0) {
        children.add(_buildArrow(context, i));
      }
      children.add(_buildStage(context, i));
    }

    Widget pipeline;
    if (direction == Axis.horizontal) {
      pipeline = Row(mainAxisSize: MainAxisSize.min, children: children);
    } else {
      pipeline = Column(mainAxisSize: MainAxisSize.min, children: children);
    }

    return Semantics(label: label, child: pipeline);
  }
}
