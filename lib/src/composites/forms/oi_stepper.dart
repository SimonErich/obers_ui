import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiWizard;
import 'package:obers_ui/src/composites/forms/oi_wizard.dart' show OiWizard;
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// The style of the stepper.
///
/// Determines the layout direction and visual density of the step indicators.
///
/// {@category Composites}
enum OiStepperStyle {
  /// Steps are laid out in a horizontal row with connecting lines.
  horizontal,

  /// Steps are laid out in a vertical column with connecting lines.
  vertical,

  /// A compact text-only mode showing "Step N of M".
  compact,
}

/// A visual step indicator showing progress through a multi-step process.
///
/// Used by [OiWizard] but also available standalone. Shows steps as
/// connected dots/circles with labels, highlighting the current step
/// and marking completed/error steps.
///
/// {@category Composites}
class OiStepper extends StatelessWidget {
  /// Creates an [OiStepper].
  const OiStepper({
    required this.totalSteps,
    required this.currentStep,
    super.key,
    this.stepLabels,
    this.stepIcons,
    this.style = OiStepperStyle.horizontal,
    this.onStepTap,
    this.completedSteps = const {},
    this.errorSteps = const {},
  });

  /// The total number of steps in the process.
  final int totalSteps;

  /// The zero-based index of the currently active step.
  final int currentStep;

  /// Optional labels displayed below (horizontal) or beside (vertical)
  /// each step indicator. Must have [totalSteps] entries when provided.
  final List<String>? stepLabels;

  /// Optional icons displayed inside each step circle.
  /// Must have [totalSteps] entries when provided.
  final List<IconData>? stepIcons;

  /// The visual layout style of the stepper.
  final OiStepperStyle style;

  /// Called when the user taps a step circle, with the step index.
  final ValueChanged<int>? onStepTap;

  /// Set of step indices that are completed. Completed steps show a
  /// checkmark icon.
  final Set<int> completedSteps;

  /// Set of step indices that have errors. Error steps show an error icon
  /// and use the error color.
  final Set<int> errorSteps;

  // ---------------------------------------------------------------------------
  // Icon constants
  // ---------------------------------------------------------------------------

  /// Material Icons check mark.
  static const IconData _checkIcon = IconData(
    0xe5ca,
    fontFamily: 'MaterialIcons',
  );

  /// Material Icons error (exclamation circle).
  static const IconData _errorIcon = IconData(
    0xe000,
    fontFamily: 'MaterialIcons',
  );

  // ---------------------------------------------------------------------------
  // Build helpers
  // ---------------------------------------------------------------------------

  /// Returns the color for a step at [index].
  Color _stepColor(BuildContext context, int index) {
    final colors = context.colors;
    if (errorSteps.contains(index)) return colors.error.base;
    if (completedSteps.contains(index)) return colors.success.base;
    if (index == currentStep) return colors.primary.base;
    return colors.borderSubtle;
  }

  /// Builds the icon inside a step circle at [index].
  Widget? _stepIcon(BuildContext context, int index) {
    final colors = context.colors;
    if (errorSteps.contains(index)) {
      return Icon(_errorIcon, size: 14, color: colors.textOnPrimary);
    }
    if (completedSteps.contains(index)) {
      return Icon(_checkIcon, size: 14, color: colors.textOnPrimary);
    }
    if (stepIcons != null && index < stepIcons!.length) {
      return Icon(
        stepIcons![index],
        size: 14,
        color: index == currentStep ? colors.textOnPrimary : colors.textMuted,
      );
    }
    return null;
  }

  /// Builds a single step circle at [index].
  Widget _buildStep(BuildContext context, int index) {
    final colors = context.colors;
    final color = _stepColor(context, index);
    final isCurrent = index == currentStep;
    const circleSize = 28.0;

    final icon = _stepIcon(context, index);

    Widget circle = Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        color:
            (completedSteps.contains(index) ||
                errorSteps.contains(index) ||
                isCurrent)
            ? color
            : colors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child:
            icon ??
            Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isCurrent ? colors.textOnPrimary : colors.textMuted,
              ),
            ),
      ),
    );

    if (onStepTap != null) {
      circle = GestureDetector(
        onTap: () => onStepTap!(index),
        behavior: HitTestBehavior.opaque,
        child: circle,
      );
    }

    return circle;
  }

  /// Builds a connector line between steps.
  Widget _buildConnector(BuildContext context, int beforeIndex) {
    final colors = context.colors;
    final isCompleted = completedSteps.contains(beforeIndex);
    final lineColor = isCompleted ? colors.success.base : colors.borderSubtle;

    if (style == OiStepperStyle.horizontal) {
      return Expanded(child: Container(height: 2, color: lineColor));
    }

    return Container(width: 2, height: 24, color: lineColor);
  }

  /// Builds the compact representation: "Step N of M".
  Widget _buildCompact(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'Step ${currentStep + 1} of $totalSteps',
      child: Text(
        'Step ${currentStep + 1} of $totalSteps',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colors.text,
        ),
      ),
    );
  }

  /// Builds the horizontal layout.
  Widget _buildHorizontal(BuildContext context) {
    final children = <Widget>[];

    for (var i = 0; i < totalSteps; i++) {
      if (i > 0) {
        children.add(_buildConnector(context, i - 1));
      }

      final step = _buildStep(context, i);

      if (stepLabels != null && i < stepLabels!.length) {
        children.add(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              step,
              const SizedBox(height: 4),
              Text(
                stepLabels![i],
                style: TextStyle(
                  fontSize: 11,
                  color: i == currentStep
                      ? context.colors.text
                      : context.colors.textMuted,
                ),
              ),
            ],
          ),
        );
      } else {
        children.add(step);
      }
    }

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  /// Builds the vertical layout.
  Widget _buildVertical(BuildContext context) {
    final children = <Widget>[];

    for (var i = 0; i < totalSteps; i++) {
      if (i > 0) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 13),
            child: _buildConnector(context, i - 1),
          ),
        );
      }

      final step = _buildStep(context, i);

      if (stepLabels != null && i < stepLabels!.length) {
        children.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              step,
              const SizedBox(width: 8),
              Text(
                stepLabels![i],
                style: TextStyle(
                  fontSize: 13,
                  color: i == currentStep
                      ? context.colors.text
                      : context.colors.textMuted,
                ),
              ),
            ],
          ),
        );
      } else {
        children.add(step);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (style) {
      case OiStepperStyle.compact:
        content = _buildCompact(context);
      case OiStepperStyle.horizontal:
        content = _buildHorizontal(context);
      case OiStepperStyle.vertical:
        content = _buildVertical(context);
    }

    return Semantics(
      label: 'Step ${currentStep + 1} of $totalSteps',
      child: content,
    );
  }
}
