import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/composites/onboarding/oi_spotlight.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart';

/// A single step in a guided tour.
///
/// Each step spotlights a [target] widget and displays a tooltip with
/// [title], [description], and optional [customContent].
///
/// {@category Composites}
class OiTourStep {
  /// Creates an [OiTourStep].
  const OiTourStep({
    required this.target,
    required this.title,
    required this.description,
    this.position = OiFloatingAlignment.bottomCenter,
    this.customContent,
    this.actionLabel,
    this.onAction,
  });

  /// The [GlobalKey] of the widget to spotlight for this step.
  final GlobalKey target;

  /// The heading text shown in the tooltip.
  final String title;

  /// The body text shown in the tooltip.
  final String description;

  /// Where the tooltip appears relative to the spotlighted widget.
  final OiFloatingAlignment position;

  /// Optional custom content rendered below the description.
  final Widget? customContent;

  /// Optional label for an extra action button.
  final String? actionLabel;

  /// Callback invoked when the extra action button is tapped.
  final VoidCallback? onAction;
}

/// A guided tour that highlights target widgets with tooltips.
///
/// Steps through a sequence of [OiTourStep]s, spotlighting each target
/// and showing a tooltip with title, description, and navigation buttons.
///
/// {@category Composites}
class OiTour extends StatefulWidget {
  /// Creates an [OiTour].
  const OiTour({
    required this.steps,
    this.onComplete,
    this.onSkip,
    this.onStepChange,
    this.showProgress = true,
    this.showSkip = true,
    this.overlayColor,
    this.dismissOnOutsideTap = false,
    this.child,
    super.key,
  });

  /// The ordered list of tour steps.
  final List<OiTourStep> steps;

  /// Called when the user completes the final step.
  final VoidCallback? onComplete;

  /// Called when the user taps Skip.
  final VoidCallback? onSkip;

  /// Called each time the current step index changes.
  final ValueChanged<int>? onStepChange;

  /// Whether to show a progress indicator (e.g. "Step 1 of 3").
  final bool showProgress;

  /// Whether to show a Skip button.
  final bool showSkip;

  /// The overlay color passed to [OiSpotlight].
  final Color? overlayColor;

  /// When `true`, tapping outside the spotlight dismisses the tour.
  final bool dismissOnOutsideTap;

  /// The child widget tree rendered beneath the tour overlay.
  final Widget? child;

  @override
  State<OiTour> createState() => _OiTourState();
}

class _OiTourState extends State<OiTour> {
  int _currentStep = 0;
  bool _dismissed = false;

  void _next() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      widget.onStepChange?.call(_currentStep);
    } else {
      setState(() {
        _dismissed = true;
      });
      widget.onComplete?.call();
    }
  }

  void _previous() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      widget.onStepChange?.call(_currentStep);
    }
  }

  void _skip() {
    setState(() {
      _dismissed = true;
    });
    widget.onSkip?.call();
  }

  void _handleOutsideTap() {
    if (widget.dismissOnOutsideTap) {
      _skip();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child ?? const SizedBox.shrink();

    if (_dismissed || widget.steps.isEmpty) {
      return child;
    }

    final step = widget.steps[_currentStep];
    final isLastStep = _currentStep == widget.steps.length - 1;

    // The tooltip must sit above the spotlight overlay in the Stack so that
    // it can receive taps. The spotlight overlay uses HitTestBehavior.opaque,
    // which would otherwise intercept taps on the tooltip buttons.
    return Stack(
      children: [
        // Spotlight with child underneath.
        OiSpotlight(
          target: step.target,
          overlayColor: widget.overlayColor,
          onTapOutside: _handleOutsideTap,
          child: child,
        ),
        // Tooltip rendered above the spotlight overlay.
        _TourTooltip(
          key: ValueKey('oi_tour_tooltip_$_currentStep'),
          step: step,
          currentStep: _currentStep,
          totalSteps: widget.steps.length,
          showProgress: widget.showProgress,
          showSkip: widget.showSkip,
          isLastStep: isLastStep,
          onNext: _next,
          onPrevious: _currentStep > 0 ? _previous : null,
          onSkip: _skip,
        ),
      ],
    );
  }
}

/// The tooltip card rendered during a tour step.
class _TourTooltip extends StatefulWidget {
  const _TourTooltip({
    required this.step,
    required this.currentStep,
    required this.totalSteps,
    required this.showProgress,
    required this.showSkip,
    required this.isLastStep,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
    super.key,
  });

  final OiTourStep step;
  final int currentStep;
  final int totalSteps;
  final bool showProgress;
  final bool showSkip;
  final bool isLastStep;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;
  final VoidCallback onSkip;

  @override
  State<_TourTooltip> createState() => _TourTooltipState();
}

class _TourTooltipState extends State<_TourTooltip> {
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTargetRect();
    });
  }

  @override
  void didUpdateWidget(_TourTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.step.target != oldWidget.step.target) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateTargetRect();
      });
    }
  }

  void _updateTargetRect() {
    final renderObject =
        widget.step.target.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final offset = renderObject.localToGlobal(Offset.zero);
      final size = renderObject.size;
      if (mounted) {
        setState(() {
          _targetRect = Rect.fromLTWH(
            offset.dx,
            offset.dy,
            size.width,
            size.height,
          );
        });
      }
    }
  }

  Offset _tooltipOffset() {
    if (_targetRect == null) return Offset.zero;
    const gap = 16.0;
    switch (widget.step.position) {
      case OiFloatingAlignment.topStart:
      case OiFloatingAlignment.topCenter:
      case OiFloatingAlignment.topEnd:
        return Offset(_targetRect!.left, _targetRect!.top - gap);
      case OiFloatingAlignment.bottomStart:
      case OiFloatingAlignment.bottomCenter:
      case OiFloatingAlignment.bottomEnd:
        return Offset(_targetRect!.left, _targetRect!.bottom + gap);
      case OiFloatingAlignment.leftStart:
      case OiFloatingAlignment.leftCenter:
      case OiFloatingAlignment.leftEnd:
        return Offset(_targetRect!.left - gap, _targetRect!.top);
      case OiFloatingAlignment.rightStart:
      case OiFloatingAlignment.rightCenter:
      case OiFloatingAlignment.rightEnd:
        return Offset(_targetRect!.right + gap, _targetRect!.top);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_targetRect == null) return const SizedBox.shrink();

    final colors = context.colors;
    final textTheme = context.textTheme;
    final offset = _tooltipOffset();

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        key: const Key('oi_tour_tooltip'),
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: colors.overlay.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title.
            Text(
              widget.step.title,
              style: textTheme.h4.copyWith(color: colors.text),
            ),
            const SizedBox(height: 8),
            // Description.
            Text(
              widget.step.description,
              style: textTheme.body.copyWith(color: colors.textSubtle),
            ),
            // Custom content.
            if (widget.step.customContent != null) ...[
              const SizedBox(height: 8),
              widget.step.customContent!,
            ],
            const SizedBox(height: 16),
            // Progress indicator.
            if (widget.showProgress)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Step ${widget.currentStep + 1} of ${widget.totalSteps}',
                  key: const Key('oi_tour_progress'),
                  style: textTheme.small.copyWith(color: colors.textMuted),
                ),
              ),
            // Navigation buttons.
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                if (widget.showSkip)
                  GestureDetector(
                    onTap: widget.onSkip,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Skip',
                        key: const Key('oi_tour_skip'),
                        style: textTheme.small.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                  ),
                if (widget.onPrevious != null)
                  GestureDetector(
                    onTap: widget.onPrevious,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Previous',
                        key: const Key('oi_tour_previous'),
                        style: textTheme.small.copyWith(
                          color: colors.primary.base,
                        ),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: widget.onNext,
                  child: Container(
                    key: const Key('oi_tour_next'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.base,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.isLastStep ? 'Finish' : 'Next',
                      style: textTheme.small.copyWith(
                        color: colors.textOnPrimary,
                      ),
                    ),
                  ),
                ),
                // Custom action button.
                if (widget.step.actionLabel != null)
                  GestureDetector(
                    onTap: widget.step.onAction,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        widget.step.actionLabel!,
                        style: textTheme.small.copyWith(
                          color: colors.primary.base,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
