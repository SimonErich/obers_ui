import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/composites/forms/oi_stepper.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

// ── OiWizardContext ─────────────────────────────────────────────────────────

/// Context passed to wizard step builders.
///
/// Provides access to the shared [values] map, navigation helpers, and the
/// ability to set values from within a step.
///
/// {@category Composites}
class OiWizardContext {
  /// Creates an [OiWizardContext].
  OiWizardContext({
    required this.values,
    required this.currentStep,
    required this.totalSteps,
    required this.goNext,
    required this.goPrevious,
    required this.goToStep,
    required this.setValue,
  });

  /// The shared values map across all wizard steps.
  final Map<String, dynamic> values;

  /// The zero-based index of the currently displayed step.
  final int currentStep;

  /// The total number of steps in the wizard.
  final int totalSteps;

  /// Advances to the next step.
  final VoidCallback goNext;

  /// Returns to the previous step.
  final VoidCallback goPrevious;

  /// Jumps to a specific step by [index].
  final ValueChanged<int> goToStep;

  /// Sets a value in the shared values map.
  final void Function(String key, dynamic value) setValue;
}

// ── OiWizardStep ────────────────────────────────────────────────────────────

/// A step in the wizard.
///
/// Each step has a [title], an optional [subtitle] and [icon], and a
/// [builder] that receives an [OiWizardContext]. The optional [validate]
/// function determines whether the user may advance past this step.
///
/// {@category Composites}
class OiWizardStep {
  /// Creates an [OiWizardStep].
  const OiWizardStep({
    required this.title,
    required this.builder, this.subtitle,
    this.icon,
    this.validate,
    this.optional = false,
  });

  /// The title shown in the stepper and step header.
  final String title;

  /// An optional subtitle shown below the title.
  final String? subtitle;

  /// An optional icon for the step in the stepper.
  final IconData? icon;

  /// Builder that returns the step's content widget.
  final Widget Function(OiWizardContext) builder;

  /// Validation function that receives all values and returns `true` when
  /// the step is valid and the user may advance.
  final bool Function(Map<String, dynamic>)? validate;

  /// Whether this step can be skipped.
  final bool optional;
}

// ── OiWizard ────────────────────────────────────────────────────────────────

/// A multi-step form wizard with step navigation and validation.
///
/// Steps through a sequence of [OiWizardStep]s with Next/Previous
/// navigation, per-step validation, and an optional summary step.
/// An [OiStepper] is rendered above the step content to indicate progress.
///
/// {@category Composites}
class OiWizard extends StatefulWidget {
  /// Creates an [OiWizard].
  const OiWizard({
    required this.steps, super.key,
    this.onComplete,
    this.onCancel,
    this.onStepChange,
    this.linear = true,
    this.allowSkip = false,
    this.showSummary = true,
    this.stepperStyle = OiStepperStyle.horizontal,
    this.animated = true,
    this.initialValues,
  });

  /// The steps in the wizard.
  final List<OiWizardStep> steps;

  /// Called when the user completes the last step with the final values.
  final ValueChanged<Map<String, dynamic>>? onComplete;

  /// Called when the user cancels the wizard.
  final VoidCallback? onCancel;

  /// Called each time the active step changes, with the new step index.
  final ValueChanged<int>? onStepChange;

  /// When `true` the user must complete steps in order. When `false` the
  /// user may tap any step in the stepper to jump to it.
  final bool linear;

  /// Whether the user may skip non-optional steps.
  final bool allowSkip;

  /// Whether to show a summary step at the end before completing.
  final bool showSummary;

  /// The visual style of the stepper indicator.
  final OiStepperStyle stepperStyle;

  /// Whether to animate transitions between steps.
  final bool animated;

  /// Initial values seeded into the wizard's shared value map.
  final Map<String, dynamic>? initialValues;

  @override
  State<OiWizard> createState() => _OiWizardState();
}

class _OiWizardState extends State<OiWizard> {
  late int _currentStep;
  late Map<String, dynamic> _values;
  final Set<int> _completedSteps = {};
  final Set<int> _errorSteps = {};

  @override
  void initState() {
    super.initState();
    _currentStep = 0;
    _values = Map<String, dynamic>.from(widget.initialValues ?? {});
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _goToStep(int index) {
    if (index < 0 || index >= widget.steps.length) return;

    // In linear mode, only allow advancing one step at a time (or going back).
    if (widget.linear && index > _currentStep + 1) return;

    setState(() {
      _currentStep = index;
    });
    widget.onStepChange?.call(index);
  }

  void _goNext() {
    // Validate current step before advancing.
    final step = widget.steps[_currentStep];
    if (step.validate != null && !step.validate!(_values)) {
      setState(() {
        _errorSteps.add(_currentStep);
      });
      return;
    }

    setState(() {
      _errorSteps.remove(_currentStep);
      _completedSteps.add(_currentStep);
    });

    if (_currentStep < widget.steps.length - 1) {
      _goToStep(_currentStep + 1);
    } else {
      // Last step — complete.
      widget.onComplete?.call(Map<String, dynamic>.unmodifiable(_values));
    }
  }

  void _goPrevious() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  void _setValue(String key, dynamic value) {
    setState(() {
      _values[key] = value;
    });
  }

  void _handleStepTap(int index) {
    if (!widget.linear) {
      _goToStep(index);
    }
  }

  // ---------------------------------------------------------------------------
  // Summary
  // ---------------------------------------------------------------------------

  Widget _buildSummary(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.text,
          ),
        ),
        const SizedBox(height: 8),
        for (final entry in _values.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text(
                  '${entry.key}: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colors.text,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${entry.value}',
                    style: TextStyle(fontSize: 13, color: colors.textMuted),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final step = widget.steps[_currentStep];
    final isFirstStep = _currentStep == 0;
    final isLastStep = _currentStep == widget.steps.length - 1;

    final wizardContext = OiWizardContext(
      values: _values,
      currentStep: _currentStep,
      totalSteps: widget.steps.length,
      goNext: _goNext,
      goPrevious: _goPrevious,
      goToStep: _goToStep,
      setValue: _setValue,
    );

    final stepContent = step.builder(wizardContext);

    Widget body;
    if (widget.animated) {
      body = AnimatedSwitcher(
        duration: context.animations.reducedMotion ||
                MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 250),
        child: KeyedSubtree(key: ValueKey(_currentStep), child: stepContent),
      );
    } else {
      body = stepContent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stepper indicator.
        OiStepper(
          totalSteps: widget.steps.length,
          currentStep: _currentStep,
          style: widget.stepperStyle,
          stepLabels: widget.steps.map((s) => s.title).toList(),
          stepIcons: widget.steps.any((s) => s.icon != null)
              ? widget.steps.map((s) => s.icon ?? const IconData(0)).toList()
              : null,
          completedSteps: _completedSteps,
          errorSteps: _errorSteps,
          onStepTap: widget.linear ? null : _handleStepTap,
        ),
        const SizedBox(height: 16),

        // Step title.
        Text(
          step.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.text,
          ),
        ),
        if (step.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            step.subtitle!,
            style: TextStyle(fontSize: 13, color: colors.textMuted),
          ),
        ],
        const SizedBox(height: 16),

        // Step content.
        body,

        // Optional summary when on the last step.
        if (widget.showSummary && isLastStep && _values.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSummary(context),
        ],

        const SizedBox(height: 16),

        // Navigation buttons.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: Cancel / Previous.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.onCancel != null)
                  GestureDetector(
                    onTap: widget.onCancel,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: 14, color: colors.textMuted),
                      ),
                    ),
                  ),
                if (!isFirstStep)
                  GestureDetector(
                    onTap: _goPrevious,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.border),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Previous',
                        style: TextStyle(fontSize: 14, color: colors.text),
                      ),
                    ),
                  ),
              ],
            ),

            // Right side: Skip / Next / Complete.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.allowSkip && step.optional && !isLastStep)
                  GestureDetector(
                    onTap: () => _goToStep(_currentStep + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(fontSize: 14, color: colors.textMuted),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: _goNext,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.base,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isLastStep ? 'Complete' : 'Next',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textOnPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
