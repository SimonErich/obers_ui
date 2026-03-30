import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiWizard;
import 'package:obers_ui/src/composites/forms/oi_wizard.dart' show OiWizard;
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
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
/// When [enabledSteps] is provided, only those steps are interactive;
/// all other steps appear visually disabled. This is useful for wizard
/// forms where the user must complete steps sequentially and cannot
/// jump to future steps.
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
    this.enabledSteps,
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

  /// Optional set of step indices that are enabled (interactive).
  ///
  /// When null, all steps are enabled if [onStepTap] is provided.
  /// When provided, only steps in this set are tappable and show hover
  /// effects; all other steps appear visually disabled.
  final Set<int>? enabledSteps;

  /// Whether a step at [index] is enabled for interaction.
  bool _isStepEnabled(int index) {
    if (onStepTap == null) return false;
    if (enabledSteps == null) return true;
    return enabledSteps!.contains(index);
  }

  // ---------------------------------------------------------------------------
  // Build helpers
  // ---------------------------------------------------------------------------

  /// Builds a single step circle at [index].
  Widget _buildStep(BuildContext context, int index) {
    return _OiStepCircle(
      index: index,
      isCurrent: index == currentStep,
      isCompleted: completedSteps.contains(index),
      isError: errorSteps.contains(index),
      isEnabled: _isStepEnabled(index),
      isDisabled: enabledSteps != null && !enabledSteps!.contains(index),
      icon: stepIcons != null && index < stepIcons!.length
          ? stepIcons![index]
          : null,
      onTap: _isStepEnabled(index) ? () => onStepTap!(index) : null,
    );
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

// -----------------------------------------------------------------------------
// Step circle (private)
// -----------------------------------------------------------------------------

/// A single step circle with hover and disabled state support.
class _OiStepCircle extends StatefulWidget {
  const _OiStepCircle({
    required this.index,
    required this.isCurrent,
    required this.isCompleted,
    required this.isError,
    required this.isEnabled,
    required this.isDisabled,
    this.icon,
    this.onTap,
  });

  final int index;
  final bool isCurrent;
  final bool isCompleted;
  final bool isError;
  final bool isEnabled;
  final bool isDisabled;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  State<_OiStepCircle> createState() => _OiStepCircleState();
}

class _OiStepCircleState extends State<_OiStepCircle> {
  bool _hovered = false;

  static const IconData _checkIcon = OiIcons.check;
  static const IconData _errorIcon = OiIcons.circleAlert;
  static const _circleSize = 28.0;

  Color _borderColor(OiColorScheme colors) {
    if (widget.isDisabled) return colors.borderSubtle;
    if (widget.isError) return colors.error.base;
    if (widget.isCompleted) return colors.success.base;
    if (_hovered) return colors.primary.base;
    if (widget.isCurrent) return colors.primary.base;
    return colors.borderSubtle;
  }

  Color _fillColor(OiColorScheme colors) {
    if (widget.isDisabled) return colors.surface;
    if (widget.isError) return colors.error.base;
    if (widget.isCompleted) return colors.success.base;
    if (widget.isCurrent) return colors.primary.base;
    if (_hovered) return colors.primary.base.withValues(alpha: 0.2);
    return colors.surface;
  }

  Color _contentColor(OiColorScheme colors) {
    if (widget.isDisabled) return colors.textMuted;
    if (widget.isError || widget.isCompleted || widget.isCurrent) {
      return colors.textOnPrimary;
    }
    if (_hovered) return colors.primary.base;
    return colors.textMuted;
  }

  Widget? _buildIcon(OiColorScheme colors) {
    final color = _contentColor(colors);
    if (widget.isError) {
      return Icon(_errorIcon, size: 14, color: color);
    }
    if (widget.isCompleted) {
      return Icon(_checkIcon, size: 14, color: color);
    }
    if (widget.icon != null) {
      return Icon(widget.icon, size: 14, color: color);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icon = _buildIcon(colors);

    Widget circle = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: _circleSize,
      height: _circleSize,
      decoration: BoxDecoration(
        color: _fillColor(colors),
        shape: BoxShape.circle,
        border: Border.all(color: _borderColor(colors), width: 2),
      ),
      child: Center(
        child: icon ??
            Text(
              '${widget.index + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _contentColor(colors),
              ),
            ),
      ),
    );

    if (widget.isEnabled) {
      circle = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: circle,
        ),
      );
    }

    return circle;
  }
}
