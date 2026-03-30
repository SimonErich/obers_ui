import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// A single step in an [OiPipelineProgress] sequence.
///
/// Each step has a required [label] and optional [detail] text shown when the
/// step is active. An optional [subProgress] widget can display granular
/// progress (e.g. a linear bar or percentage) beneath the active step.
///
/// {@category Components}
class OiPipelineProgressStep {
  /// Creates a pipeline step with a [label] and optional [detail] and
  /// [subProgress].
  const OiPipelineProgressStep({
    required this.label,
    this.detail,
    this.subProgress,
    this.estimatedDuration,
  });

  /// The display name of this step.
  final String label;

  /// Optional secondary description shown when this step is active.
  final String? detail;

  /// Optional child widget shown below the active step for granular progress.
  final Widget? subProgress;

  /// Optional human-readable estimated duration shown next to the step label
  /// (e.g. `'~30s'`, `'1–2 min'`). Shown for the active and future steps.
  final String? estimatedDuration;
}

/// A vertical multi-step pipeline progress indicator.
///
/// Displays a list of [steps] connected by thin vertical lines, with visual
/// state indicators for completed, active, and future steps:
///
/// - **Completed** steps show a green checkmark icon and muted label.
/// - **Active** step shows a circular spinner, bold label, optional
///   [OiPipelineProgressStep.detail] text, and optional
///   [OiPipelineProgressStep.subProgress] widget.
/// - **Future** steps show a grey circle icon and muted label.
/// - **Error** state replaces the active spinner with a red X icon, displays
///   the [error] message, and shows a retry button when [onRetry] is provided.
///
/// An optional cancel button is rendered at the bottom when [onCancel] is
/// provided.
///
/// ```dart
/// OiPipelineProgress(
///   label: 'Deploying service',
///   currentStepIndex: 1,
///   steps: [
///     OiPipelineProgressStep(label: 'Build'),
///     OiPipelineProgressStep(label: 'Test', detail: 'Running 48 tests'),
///     OiPipelineProgressStep(label: 'Deploy'),
///   ],
/// )
/// ```
///
/// {@category Components}
class OiPipelineProgress extends StatelessWidget {
  /// Creates an [OiPipelineProgress] pipeline indicator.
  const OiPipelineProgress({
    required this.steps,
    required this.currentStepIndex,
    required this.label,
    this.onCancel,
    this.error,
    this.onRetry,
    this.collapseCompleted = false,
    super.key,
  });

  /// The ordered list of pipeline steps.
  final List<OiPipelineProgressStep> steps;

  /// Zero-based index of the currently active step.
  final int currentStepIndex;

  /// Accessibility label for the pipeline widget.
  final String label;

  /// Called when the user taps the cancel button. When null, no cancel button
  /// is shown.
  final VoidCallback? onCancel;

  /// When non-null, the current step is shown in an error state with this
  /// message displayed.
  final String? error;

  /// Called when the user taps the retry button in an error state. When null
  /// and [error] is set, no retry button is shown.
  final VoidCallback? onRetry;

  /// When `true`, completed steps are collapsed into a single summary line
  /// showing only the count of completed steps.
  ///
  /// Useful when the pipeline has many steps and scrolling past them all is
  /// cumbersome.
  final bool collapseCompleted;

  // ── Constants ────────────────────────────────────────────────────────────

  static const double _iconSize = 20;
  static const double _lineWidth = 1;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    // When collapseCompleted is true, count completed steps and replace them
    // with a single summary row before the active step.
    final completedCount = currentStepIndex.clamp(0, steps.length);
    final showCollapsedSummary = collapseCompleted && completedCount > 0;

    final visibleIndices = <int>[];
    for (var i = 0; i < steps.length; i++) {
      if (collapseCompleted && i < completedCount) continue;
      visibleIndices.add(i);
    }

    return Semantics(
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collapsed summary for completed steps.
          if (showCollapsedSummary) ...[
            Row(
              children: [
                OiIcon.decorative(
                  icon: OiIcons.check,
                  size: _iconSize,
                  color: colors.success.base,
                ),
                SizedBox(width: spacing.sm),
                OiLabel.body(
                  '$completedCount step${completedCount == 1 ? '' : 's'} completed',
                  color: colors.textMuted,
                ),
              ],
            ),
            if (visibleIndices.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  left: _iconSize / 2 - _lineWidth / 2,
                ),
                child: Container(
                  width: _lineWidth,
                  height: spacing.md,
                  color: colors.borderSubtle,
                ),
              ),
          ],

          for (var vi = 0; vi < visibleIndices.length; vi++) ...[
            _buildStep(context, visibleIndices[vi]),
            if (vi < visibleIndices.length - 1)
              Padding(
                padding: const EdgeInsets.only(
                  left: _iconSize / 2 - _lineWidth / 2,
                ),
                child: Container(
                  width: _lineWidth,
                  height: spacing.md,
                  color: colors.borderSubtle,
                ),
              ),
          ],
          if (onCancel != null) ...[
            SizedBox(height: spacing.md),
            OiButton.ghost(
              label: 'Cancel',
              onTap: onCancel,
              size: OiButtonSize.small,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, int index) {
    final colors = context.colors;
    final spacing = context.spacing;
    final step = steps[index];

    final isCompleted = index < currentStepIndex;
    final isActive = index == currentStepIndex;
    final hasError = isActive && error != null;

    // Determine the leading icon widget.
    final Widget leadingIcon;
    if (isCompleted) {
      leadingIcon = OiIcon.decorative(
        icon: OiIcons.check,
        size: _iconSize,
        color: colors.success.base,
      );
    } else if (hasError) {
      leadingIcon = OiIcon.decorative(
        icon: OiIcons.x,
        size: _iconSize,
        color: colors.error.base,
      );
    } else if (isActive) {
      leadingIcon = const SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: OiProgress.circular(
          indeterminate: true,
          size: 16,
          strokeWidth: 2,
        ),
      );
    } else {
      leadingIcon = OiIcon.decorative(
        icon: OiIcons.circle,
        size: _iconSize,
        color: colors.textMuted,
      );
    }

    // Determine text style.
    final Color labelColor;
    if (hasError) {
      labelColor = colors.error.base;
    } else if (isActive) {
      labelColor = colors.text;
    } else {
      labelColor = colors.textMuted;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leadingIcon,
        SizedBox(width: spacing.sm),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: isActive
                        ? OiLabel.smallStrong(step.label, color: labelColor)
                        : OiLabel.small(step.label, color: labelColor),
                  ),
                  if (step.estimatedDuration != null && !isCompleted)
                    Padding(
                      padding: EdgeInsets.only(left: spacing.xs),
                      child: OiLabel.tiny(
                        step.estimatedDuration!,
                        color: colors.textMuted,
                      ),
                    ),
                ],
              ),
              if (isActive && !hasError && step.detail != null) ...[
                SizedBox(height: spacing.xs),
                OiLabel.small(step.detail!, color: colors.textSubtle),
              ],
              if (hasError) ...[
                SizedBox(height: spacing.xs),
                OiLabel.small(error!, color: colors.error.base),
                if (onRetry != null) ...[
                  SizedBox(height: spacing.sm),
                  Align(
                    widthFactor: 1,
                    child: UnconstrainedBox(
                      child: OiButton.outline(
                        label: 'Retry',
                        onTap: onRetry,
                        size: OiButtonSize.small,
                      ),
                    ),
                  ),
                ],
              ],
              if (isActive && !hasError && step.subProgress != null) ...[
                SizedBox(height: spacing.sm),
                step.subProgress!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
