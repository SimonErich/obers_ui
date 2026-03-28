import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ── Data Models ─────────────────────────────────────────────────────────────

/// A single step within a workflow phase.
///
/// {@category Composites}
@immutable
class OiWorkflowStep {
  /// Creates an [OiWorkflowStep].
  const OiWorkflowStep({
    required this.id,
    required this.label,
    this.icon,
    this.estimatedTime,
  });

  /// Unique identifier for this step.
  final String id;

  /// Display label for this step.
  final String label;

  /// Optional icon displayed alongside the step label.
  final IconData? icon;

  /// Optional estimated time hint shown below the step label (e.g. `'~2 min'`).
  final String? estimatedTime;
}

/// A phase containing one or more [OiWorkflowStep]s.
///
/// {@category Composites}
@immutable
class OiWorkflowPhase {
  /// Creates an [OiWorkflowPhase].
  const OiWorkflowPhase({
    required this.id,
    required this.label,
    required this.steps,
    this.icon,
    this.badge,
  });

  /// Unique identifier for this phase.
  final String id;

  /// Display label for this phase.
  final String label;

  /// Optional icon displayed alongside the phase label.
  final IconData? icon;

  /// The steps that belong to this phase.
  final List<OiWorkflowStep> steps;

  /// Optional badge widget overlaid on the phase pill (e.g. an issue count).
  ///
  /// Displayed as a small overlay in the top-right corner of the pill.
  final Widget? badge;
}

/// The layout orientation of an [OiWorkflowStepper].
///
/// {@category Composites}
enum OiWorkflowStepperOrientation {
  /// Phase row on top, step row below — the default horizontal layout.
  horizontal,

  /// Both phase pills and step pills stack vertically, suitable for sidebars.
  vertical,
}

// ── Widget ──────────────────────────────────────────────────────────────────

/// A two-row horizontal stepper showing phases (top row) and steps within
/// the current phase (bottom row).
///
/// Phases are displayed as connected pills. The bottom row shows only the
/// steps belonging to [currentPhaseId], filtering out any steps whose IDs
/// appear in [skippedStepIds].
///
/// Step interaction is controlled by [completedStepIds], [enabledStepIds],
/// and the [onStepTap] callback. Only completed or explicitly enabled steps
/// are tappable.
///
/// Set [orientation] to [OiWorkflowStepperOrientation.vertical] to use a
/// sidebar-friendly stacked layout instead of the default two-row layout.
///
/// {@category Composites}
class OiWorkflowStepper extends StatelessWidget {
  /// Creates an [OiWorkflowStepper].
  const OiWorkflowStepper({
    required this.phases,
    required this.currentPhaseId,
    required this.currentStepId,
    required this.label,
    this.onStepTap,
    this.completedStepIds = const {},
    this.enabledStepIds = const {},
    this.skippedStepIds = const {},
    this.orientation = OiWorkflowStepperOrientation.horizontal,
    super.key,
  });

  /// The phases in this workflow.
  final List<OiWorkflowPhase> phases;

  /// The ID of the currently active phase.
  final String currentPhaseId;

  /// The ID of the currently active step.
  final String currentStepId;

  /// Accessibility label for the entire stepper.
  final String label;

  /// Called when the user taps a completed or enabled step.
  final void Function(String phaseId, String stepId)? onStepTap;

  /// IDs of steps that have been completed.
  final Set<String> completedStepIds;

  /// IDs of future steps that are tappable (enabled for navigation).
  final Set<String> enabledStepIds;

  /// IDs of steps that should be hidden (skipped).
  final Set<String> skippedStepIds;

  /// The layout orientation of the stepper. Defaults to
  /// [OiWorkflowStepperOrientation.horizontal].
  final OiWorkflowStepperOrientation orientation;

  // ── Phase state helpers ─────────────────────────────────────────────────

  /// Returns `true` when all non-skipped steps in [phase] are completed.
  bool _isPhaseCompleted(OiWorkflowPhase phase) {
    final nonSkipped = phase.steps.where((s) => !skippedStepIds.contains(s.id));
    if (nonSkipped.isEmpty) return false;
    return nonSkipped.every((s) => completedStepIds.contains(s.id));
  }

  // ── Phase row ───────────────────────────────────────────────────────────

  Widget _buildPhaseRow(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    final children = <Widget>[];

    for (var i = 0; i < phases.length; i++) {
      final phase = phases[i];

      // Insert connecting line between pills.
      if (i > 0) {
        children.add(
          Container(
            key: ValueKey('oi_wfs_phase_line_$i'),
            width: spacing.md,
            height: 1,
            color: colors.borderSubtle,
          ),
        );
      }

      final isCurrent = phase.id == currentPhaseId;
      final isCompleted = _isPhaseCompleted(phase);

      // Determine visual treatment.
      Color background;
      Color textColor;
      Color borderColor;

      if (isCurrent) {
        background = colors.primary.base;
        textColor = colors.textOnPrimary;
        borderColor = colors.primary.base;
      } else if (isCompleted) {
        background = colors.surface;
        textColor = colors.success.base;
        borderColor = colors.success.base;
      } else {
        background = colors.surface;
        textColor = colors.textMuted;
        borderColor = colors.borderSubtle;
      }

      final pillContent = <Widget>[];

      // Show checkmark icon for completed phases, custom icon otherwise.
      if (isCompleted) {
        pillContent
          ..add(
            OiIcon.decorative(
              icon: OiIcons.check,
              size: 14,
              color: colors.success.base,
            ),
          )
          ..add(SizedBox(width: spacing.xs));
      } else if (phase.icon != null) {
        pillContent
          ..add(
            OiIcon.decorative(icon: phase.icon!, size: 14, color: textColor),
          )
          ..add(SizedBox(width: spacing.xs));
      }

      pillContent.add(OiLabel.small(phase.label, color: textColor));

      Widget pill = Container(
        key: ValueKey('oi_wfs_phase_${phase.id}'),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs,
        ),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: borderColor),
          borderRadius: radius.full,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: pillContent),
      );

      // Wrap in Stack when a badge overlay is provided.
      if (phase.badge != null) {
        pill = Stack(
          clipBehavior: Clip.none,
          children: [
            pill,
            Positioned(top: -6, right: -6, child: phase.badge!),
          ],
        );
      }

      children.add(pill);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  // ── Step row ────────────────────────────────────────────────────────────

  Widget _buildStepRow(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    // Find the current phase.
    final currentPhase = phases.cast<OiWorkflowPhase?>().firstWhere(
      (p) => p!.id == currentPhaseId,
      orElse: () => null,
    );
    if (currentPhase == null) return const SizedBox.shrink();

    // Filter out skipped steps.
    final visibleSteps = currentPhase.steps.where(
      (s) => !skippedStepIds.contains(s.id),
    );

    final children = <Widget>[];

    for (final step in visibleSteps) {
      if (children.isNotEmpty) {
        children.add(SizedBox(width: spacing.sm));
      }

      final isCurrent = step.id == currentStepId;
      final isCompleted = completedStepIds.contains(step.id);
      final isEnabled = enabledStepIds.contains(step.id);
      final isTappable =
          (isCompleted || isEnabled) && !isCurrent && onStepTap != null;

      // Determine visual treatment.
      Color background;
      Color textColor;
      Color borderColor;

      if (isCurrent) {
        background = colors.primary.base;
        textColor = colors.textOnPrimary;
        borderColor = colors.primary.base;
      } else if (isCompleted) {
        background = colors.surface;
        textColor = colors.success.base;
        borderColor = colors.success.base;
      } else if (isEnabled) {
        background = colors.surface;
        textColor = colors.text;
        borderColor = colors.borderSubtle;
      } else {
        // Disabled future step.
        background = colors.surface;
        textColor = colors.textMuted;
        borderColor = colors.borderSubtle;
      }

      final pillContent = <Widget>[];

      if (isCompleted) {
        pillContent
          ..add(
            OiIcon.decorative(
              icon: OiIcons.check,
              size: 14,
              color: colors.success.base,
            ),
          )
          ..add(SizedBox(width: spacing.xs));
      } else if (step.icon != null) {
        pillContent
          ..add(OiIcon.decorative(icon: step.icon!, size: 14, color: textColor))
          ..add(SizedBox(width: spacing.xs));
      }

      pillContent.add(OiLabel.small(step.label, color: textColor));

      // Append estimated time hint when provided.
      if (step.estimatedTime != null) {
        pillContent
          ..add(SizedBox(width: spacing.xs))
          ..add(
            OiLabel.tiny(
              step.estimatedTime!,
              color: isCurrent
                  ? colors.textOnPrimary.withValues(alpha: 0.7)
                  : colors.textMuted,
            ),
          );
      }

      Widget pill = Container(
        key: ValueKey('oi_wfs_step_${step.id}'),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs,
        ),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: borderColor),
          borderRadius: radius.full,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: pillContent),
      );

      if (isTappable) {
        pill = OiTappable(
          semanticLabel: step.label,
          clipBorderRadius: radius.full,
          onTap: () => onStepTap!(currentPhaseId, step.id),
          child: pill,
        );
      }

      children.add(pill);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  // ── Vertical phase+step column ──────────────────────────────────────────

  Widget _buildVerticalLayout(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final radius = context.radius;

    final items = <Widget>[];

    for (final phase in phases) {
      final isCurrent = phase.id == currentPhaseId;
      final isCompleted = _isPhaseCompleted(phase);

      Color textColor;
      Color borderColor;
      Color background;

      if (isCurrent) {
        background = colors.primary.base;
        textColor = colors.textOnPrimary;
        borderColor = colors.primary.base;
      } else if (isCompleted) {
        background = colors.surface;
        textColor = colors.success.base;
        borderColor = colors.success.base;
      } else {
        background = colors.surface;
        textColor = colors.textMuted;
        borderColor = colors.borderSubtle;
      }

      final leadingIcon = isCompleted
          ? OiIcon.decorative(
              icon: OiIcons.check,
              size: 14,
              color: colors.success.base,
            )
          : phase.icon != null
          ? OiIcon.decorative(icon: phase.icon!, size: 14, color: textColor)
          : null;

      Widget header = Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs,
        ),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: borderColor),
          borderRadius: radius.full,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              leadingIcon,
              SizedBox(width: spacing.xs),
            ],
            OiLabel.small(phase.label, color: textColor),
          ],
        ),
      );

      if (phase.badge != null) {
        header = Stack(
          clipBehavior: Clip.none,
          children: [
            header,
            Positioned(top: -6, right: -6, child: phase.badge!),
          ],
        );
      }

      items.add(
        Padding(
          padding: EdgeInsets.only(bottom: spacing.xs),
          child: header,
        ),
      );

      // If this is the current phase, show its steps indented below.
      if (isCurrent) {
        final visibleSteps = phase.steps.where(
          (s) => !skippedStepIds.contains(s.id),
        );
        for (final step in visibleSteps) {
          final isStepCurrent = step.id == currentStepId;
          final isStepCompleted = completedStepIds.contains(step.id);
          final isStepEnabled = enabledStepIds.contains(step.id);
          final isTappable =
              (isStepCompleted || isStepEnabled) &&
              !isStepCurrent &&
              onStepTap != null;

          Color stepBg;
          Color stepText;
          Color stepBorder;
          if (isStepCurrent) {
            stepBg = colors.primary.base.withValues(alpha: 0.12);
            stepText = colors.primary.base;
            stepBorder = colors.primary.base;
          } else if (isStepCompleted) {
            stepBg = colors.surface;
            stepText = colors.success.base;
            stepBorder = colors.success.base;
          } else if (isStepEnabled) {
            stepBg = colors.surface;
            stepText = colors.text;
            stepBorder = colors.borderSubtle;
          } else {
            stepBg = colors.surface;
            stepText = colors.textMuted;
            stepBorder = colors.borderSubtle;
          }

          final stepPillContent = <Widget>[
            if (isStepCompleted) ...[
              OiIcon.decorative(
                icon: OiIcons.check,
                size: 12,
                color: colors.success.base,
              ),
              SizedBox(width: spacing.xs),
            ] else if (step.icon != null) ...[
              OiIcon.decorative(icon: step.icon!, size: 12, color: stepText),
              SizedBox(width: spacing.xs),
            ],
            OiLabel.small(step.label, color: stepText),
            if (step.estimatedTime != null) ...[
              SizedBox(width: spacing.xs),
              OiLabel.tiny(
                step.estimatedTime!,
                color: isStepCurrent
                    ? colors.primary.base.withValues(alpha: 0.7)
                    : colors.textMuted,
              ),
            ],
          ];

          Widget stepPill = Container(
            key: ValueKey('oi_wfs_vstep_${step.id}'),
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.xs,
            ),
            decoration: BoxDecoration(
              color: stepBg,
              border: Border.all(color: stepBorder),
              borderRadius: radius.full,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: stepPillContent,
            ),
          );

          if (isTappable) {
            stepPill = OiTappable(
              semanticLabel: step.label,
              clipBorderRadius: radius.full,
              onTap: () => onStepTap!(phase.id, step.id),
              child: stepPill,
            );
          }

          items.add(
            Padding(
              padding: EdgeInsets.only(left: spacing.md, bottom: spacing.xs),
              child: stepPill,
            ),
          );
        }
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    if (orientation == OiWorkflowStepperOrientation.vertical) {
      return Semantics(label: label, child: _buildVerticalLayout(context));
    }

    return Semantics(
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPhaseRow(context),
          SizedBox(height: spacing.sm),
          _buildStepRow(context),
        ],
      ),
    );
  }
}
