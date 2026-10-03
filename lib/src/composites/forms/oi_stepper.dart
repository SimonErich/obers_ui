import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiWizard;
import 'package:obers_ui/src/composites/forms/oi_wizard.dart' show OiWizard;
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

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
    this.stepDetails,
    this.labelStyle,
    this.timeline = false,
    this.completedColor,
    this.currentOutlined = false,
    this.indicatorSize = 28,
    this.stepIcons,
    this.style = OiStepperStyle.horizontal,
    this.onStepTap,
    this.completedSteps = const {},
    this.errorSteps = const {},
    this.enabledSteps,
  }) : assert(indicatorSize > 0, 'indicatorSize must be greater than zero.');

  /// The total number of steps in the process.
  final int totalSteps;

  /// The zero-based index of the currently active step.
  final int currentStep;

  /// Optional labels displayed below (horizontal) or beside (vertical)
  /// each step indicator. Must have [totalSteps] entries when provided.
  final List<String>? stepLabels;

  /// Optional record details under each label. Horizontal steps share the
  /// available width and align their indicators above the details.
  final List<Widget>? stepDetails;

  /// Typography for milestone labels, inherited from the active theme.
  final TextStyle? labelStyle;

  /// Connects vertical detailed items beside their intrinsic content height.
  /// Horizontal and compact layouts retain their ordinary presentation.
  final bool timeline;

  /// Overrides the completed indicator and connector color.
  final Color? completedColor;

  /// Draws the current indicator as an outlined circle instead of a solid fill.
  final bool currentOutlined;

  /// Diameter of each indicator, independent of the text scale.
  final double indicatorSize;

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
      current: index == currentStep,
      completed: completedSteps.contains(index),
      errored: errorSteps.contains(index),
      enabled: _isStepEnabled(index),
      disabled: enabledSteps != null && !enabledSteps!.contains(index),
      icon: stepIcons != null && index < stepIcons!.length
          ? stepIcons![index]
          : null,
      completedColor: completedColor,
      currentOutlined: currentOutlined,
      size: indicatorSize,
      borderColor: context.components.stepper?.indicatorBorderColor,
      borderWidth:
          context.components.stepper?.indicatorBorderWidth ??
          (timeline && style == OiStepperStyle.vertical ? 1 : 2),
      onTap: _isStepEnabled(index) ? () => onStepTap!(index) : null,
    );
  }

  /// Builds a connector line between steps.
  Widget _buildConnector(BuildContext context, int beforeIndex) {
    final colors = context.colors;
    final isCompleted = completedSteps.contains(beforeIndex);
    final lineColor = isCompleted
        ? completedColor ?? colors.success.base
        : context.components.stepper?.connectorColor ?? colors.borderSubtle;

    if (style == OiStepperStyle.horizontal) {
      return Expanded(child: Container(height: 2, color: lineColor));
    }

    return Container(width: 2, height: 24, color: lineColor);
  }

  /// Builds the compact representation: "Step N of M".
  Widget _buildCompact(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: currentStep < 0
          ? '$totalSteps planned steps'
          : 'Step ${currentStep + 1} of $totalSteps',
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
    if (stepDetails != null) return _buildDetailedHorizontal(context);
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

  Widget _buildDetailedHorizontal(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < totalSteps; i++)
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStep(context, i),
                  if (i < totalSteps - 1) ...[
                    const SizedBox(width: 8),
                    _buildConnector(context, i),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              if (stepLabels != null && i < stepLabels!.length)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OiLabel.body(
                    stepLabels![i],
                    style: TextStyle(
                      fontWeight: i <= currentStep
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),
              if (i < stepDetails!.length)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: stepDetails![i],
                ),
            ],
          ),
        ),
    ],
  );

  /// Builds the vertical layout.
  Widget _buildVertical(BuildContext context) {
    if (timeline && stepDetails != null) {
      return _buildTimeline(context);
    }
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
            crossAxisAlignment: stepDetails == null
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              step,
              SizedBox(width: stepDetails == null ? 8 : 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (stepDetails == null)
                      Text(
                        stepLabels![i],
                        style: TextStyle(
                          fontSize: 13,
                          color: i == currentStep
                              ? context.colors.text
                              : context.colors.textMuted,
                        ),
                      )
                    else
                      OiLabel.variant(
                        stepLabels![i],
                        variant: OiLabelVariant.body,
                        style: labelStyle,
                      ),
                    if (stepDetails != null && i < stepDetails!.length)
                      stepDetails![i],
                  ],
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

  Widget _buildTimeline(BuildContext context) {
    final appearance = context.components.stepper;
    final spacing = appearance?.stepSpacing ?? 20;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < totalSteps; i++)
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: i < totalSteps - 1
                  ? indicatorSize + 32
                  : indicatorSize,
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: indicatorSize,
                    child: Column(
                      children: [
                        _buildStep(context, i),
                        if (i < totalSteps - 1) ...[
                          const SizedBox(height: 4),
                          Expanded(
                            child: Container(
                              width: 2,
                              constraints: const BoxConstraints(minHeight: 24),
                              decoration: BoxDecoration(
                                color: completedSteps.contains(i)
                                    ? completedColor ??
                                          context.colors.success.base
                                    : appearance?.connectorColor ??
                                          context.colors.border,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: i < totalSteps - 1 ? spacing : 0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (stepLabels != null && i < stepLabels!.length)
                            OiLabel.body(stepLabels![i], style: labelStyle),
                          if (i < stepDetails!.length) ...[
                            SizedBox(height: appearance?.detailsSpacing ?? 2),
                            stepDetails![i],
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
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
      label: currentStep < 0
          ? '$totalSteps planned steps'
          : 'Step ${currentStep + 1} of $totalSteps',
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
    required this.current,
    required this.completed,
    required this.errored,
    required this.enabled,
    required this.disabled,
    this.icon,
    this.onTap,
    this.completedColor,
    this.currentOutlined = false,
    this.size = 28,
    this.borderColor,
    this.borderWidth = 2,
  });

  final int index;
  final bool current;
  final bool completed;
  final bool errored;
  final bool enabled;
  final bool disabled;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? completedColor;
  final bool currentOutlined;
  final double size;
  final Color? borderColor;
  final double borderWidth;

  @override
  State<_OiStepCircle> createState() => _OiStepCircleState();
}

class _OiStepCircleState extends State<_OiStepCircle> {
  bool _hovered = false;

  static const IconData _checkIcon = OiIcons.check;
  static const IconData _errorIcon = OiIcons.circleAlert;
  Color _borderColor(OiColorScheme colors) {
    if (widget.disabled) return colors.borderSubtle;
    if (widget.errored) return colors.error.base;
    if (widget.completed) return widget.completedColor ?? colors.success.base;
    if (_hovered) return colors.primary.base;
    if (widget.current) return colors.primary.base;
    return widget.borderColor ?? colors.borderSubtle;
  }

  Color _fillColor(OiColorScheme colors) {
    if (widget.disabled) return colors.surface;
    if (widget.errored) return colors.error.base;
    if (widget.completed) return widget.completedColor ?? colors.success.base;
    if (widget.current) {
      return widget.currentOutlined ? colors.surface : colors.primary.base;
    }
    if (_hovered) return colors.primary.base.withValues(alpha: 0.2);
    return colors.surface;
  }

  Color _contentColor(OiColorScheme colors) {
    if (widget.disabled) return colors.textMuted;
    if (widget.current &&
        widget.currentOutlined &&
        !widget.completed &&
        !widget.errored) {
      return colors.primary.base;
    }
    if (widget.errored || widget.completed || widget.current) {
      return colors.textOnPrimary;
    }
    if (_hovered) return colors.primary.base;
    return colors.textMuted;
  }

  Widget? _buildIcon(OiColorScheme colors) {
    final color = _contentColor(colors);
    if (widget.errored) {
      return OiIcon.raw(_errorIcon, size: 14, color: color);
    }
    if (widget.completed) {
      return OiIcon.raw(_checkIcon, size: 14, color: color);
    }
    if (widget.icon != null) {
      return OiIcon.raw(widget.icon, size: 14, color: color);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icon = _buildIcon(colors);

    Widget circle = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: _fillColor(colors),
        shape: BoxShape.circle,
        border: Border.all(
          color: _borderColor(colors),
          width: widget.current || widget.completed || widget.errored
              ? 2
              : widget.borderWidth,
        ),
      ),
      child: Center(
        child:
            icon ??
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

    if (widget.enabled) {
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
