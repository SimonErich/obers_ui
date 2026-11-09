import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/components/overlays/oi_sheet.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// Read-only presentation of a wizard step; form state belongs to the host.
@immutable
class OiWizardStepPresentation {
  /// Creates a presentation entry.
  const OiWizardStepPresentation({
    required this.title,
    this.description,
    this.summary,
  });

  /// Step title.
  final String title;

  /// Short explanation below the title.
  final String? description;

  /// Optional completed/selected record summary.
  final Widget? summary;
}

/// Controlled wizard frame with step navigation and a persistent summary.
///
/// This widget owns no form values or validation. The host supplies enabled
/// and completed steps and changes [currentStep] after validating navigation.
class OiWizardLayout extends StatelessWidget {
  /// Creates a controlled wizard presentation.
  const OiWizardLayout({
    required this.steps,
    required this.currentStep,
    required this.child,
    this.completedSteps = const {},
    this.enabledSteps = const {},
    this.onStepTap,
    this.header,
    this.stepHeader,
    this.stepHeaderPadding,
    this.stepHeaderMinHeight = 132,
    this.footer,
    this.aside,
    this.asideFooter,
    this.navigationWidth = 264,
    this.navigationFooter,
    this.asideWidth = 360,
    this.asideLabel = 'Summary',
    this.scrollable = false,
    this.contentPadding,
    this.contentCard = true,
    super.key,
  }) : assert(
         currentStep >= 0 && currentStep < steps.length,
         'currentStep must identify a declared step.',
       ),
       assert(
         stepHeaderMinHeight >= 0,
         'stepHeaderMinHeight must not be negative.',
       );

  /// Navigation entries.
  final List<OiWizardStepPresentation> steps;

  /// Controlled active index.
  final int currentStep;

  /// Current step body.
  final Widget child;

  /// Steps which may be revisited.
  final Set<int> completedSteps;

  /// Steps which may be entered.
  final Set<int> enabledSteps;

  /// Navigation request; the host decides whether it succeeds.
  final ValueChanged<int>? onStepTap;

  /// Full-width workflow header.
  final Widget? header;

  /// Heading and introduction above the current step's scrolling content.
  /// Kept visible while inputs scroll; on frames shorter than 480 logical
  /// pixels it scrolls with the body so inputs remain reachable.
  final Widget? stepHeader;

  /// Padding of [stepHeader], defaulting to the content padding without its
  /// bottom inset. Body padding starts with the theme's large spacing instead.
  final EdgeInsetsGeometry? stepHeaderPadding;

  /// Minimum padded header height, keeping short introductions aligned between
  /// steps. Longer headings grow naturally, including at larger text scales.
  final double stepHeaderMinHeight;

  /// Actions pinned below the current step content.
  final Widget? footer;

  /// Live summary panel.
  final Widget? aside;

  /// Content pinned below the independently scrollable summary.
  final Widget? asideFooter;

  /// Navigation width on desktop.
  final double navigationWidth;

  /// Supporting workflow guidance below desktop step navigation.
  final Widget? navigationFooter;

  /// Summary width on wide screens.
  final double asideWidth;

  /// Accessible summary label on compact screens.
  final String asideLabel;

  /// Scroll intrinsically sized content. Tables should own their scrolling.
  final bool scrollable;

  /// Inner padding of the active step surface.
  final EdgeInsetsGeometry? contentPadding;

  /// Groups the step and pinned footer within a themed card surface.
  final bool contentCard;

  bool _enabled(int index) =>
      index == currentStep ||
      enabledSteps.contains(index) ||
      completedSteps.contains(index);
  void _navigate(int index) {
    if (_enabled(index)) onStepTap?.call(index);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 1100;
      final sideNavigation = constraints.maxWidth >= 800;
      final space = context.spacing.lg;
      final topSpace = header == null ? space : context.spacing.sm;
      final innerPadding = contentPadding ?? EdgeInsets.all(context.spacing.xl);
      final resolvedPadding = innerPadding.resolve(Directionality.of(context));
      final body = Padding(
        padding: stepHeader == null
            ? innerPadding
            : resolvedPadding.copyWith(top: space),
        child: child,
      );
      final heading = stepHeader == null
          ? null
          : ConstrainedBox(
              constraints: BoxConstraints(minHeight: stepHeaderMinHeight),
              child: Padding(
                padding:
                    stepHeaderPadding ?? resolvedPadding.copyWith(bottom: 0),
                child: stepHeader,
              ),
            );
      final content = LayoutBuilder(
        builder: (context, bodyConstraints) {
          final pinHeader = heading != null && bodyConstraints.maxHeight >= 480;
          final scrollContent = pinHeader || heading == null
              ? body
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [heading, body],
                );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (pinHeader) heading,
              Expanded(
                child: scrollable
                    ? SingleChildScrollView(
                        key: ValueKey(currentStep),
                        child: scrollContent,
                      )
                    : scrollContent,
              ),
              if (footer != null)
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: context.colors.borderSubtle),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.xl,
                    vertical: context.spacing.md,
                  ),
                  child: footer,
                ),
            ],
          );
        },
      );
      final card = context.components.card;
      final main = Padding(
        padding: EdgeInsets.fromLTRB(space, topSpace, space, space),
        child: contentCard
            ? OiSurface(
                border: OiBorderStyle(
                  lineStyle: OiBorderLineStyle.solid,
                  color: card?.borderColor ?? context.colors.border,
                  width: card?.borderWidth ?? 1,
                ),
                borderRadius: card?.borderRadius ?? context.radius.lg,
                shadow: card?.shadow,
                color: card?.backgroundColor,
                child: content,
              )
            : content,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?header,
          if (!sideNavigation)
            Padding(
              padding: EdgeInsets.all(context.spacing.md),
              child: OiSelect<int>(
                label: 'Wizard step',
                value: currentStep,
                options: [
                  for (var i = 0; i < steps.length; i++)
                    OiSelectOption(
                      value: i,
                      label: '${i + 1}. ${steps[i].title}',
                      enabled: _enabled(i),
                    ),
                ],
                onChanged: onStepTap == null
                    ? null
                    : (index) {
                        if (index != null) _navigate(index);
                      },
              ),
            ),
          if ((aside != null || asideFooter != null) && !wide)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: space),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: OiButton.soft(
                  label: asideLabel,
                  onTap: () => OiSheet.show(
                    context,
                    label: asideLabel,
                    side: OiPanelSide.right,
                    size: asideWidth,
                    scrollable: true,
                    showHeader: true,
                    footer: asideFooter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(space, 0, space, space),
                      child: aside ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: sideNavigation ? space : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (sideNavigation)
                    SizedBox(
                      width: navigationWidth,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: topSpace + space,
                          bottom: space,
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < steps.length; i++)
                              _step(context, i),
                            if (navigationFooter != null)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  start: 36,
                                  top: 4,
                                  end: 16,
                                ),
                                child: navigationFooter,
                              ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(child: main),
                  if ((aside != null || asideFooter != null) && wide)
                    SizedBox(
                      width: asideWidth + space,
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          0,
                          topSpace,
                          space,
                          space,
                        ),
                        child: OiSurface(
                          border: OiBorderStyle(
                            lineStyle: OiBorderLineStyle.solid,
                            color: card?.borderColor ?? context.colors.border,
                            width: card?.borderWidth ?? 1,
                          ),
                          borderRadius: card?.borderRadius ?? context.radius.lg,
                          shadow: card?.shadow,
                          color: card?.backgroundColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.all(space),
                                  child: aside,
                                ),
                              ),
                              if (asideFooter != null)
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    space,
                                    0,
                                    space,
                                    space,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      OiDivider(
                                        color: context.colors.borderSubtle,
                                      ),
                                      const SizedBox(height: 16),
                                      asideFooter!,
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );

  Widget _step(BuildContext context, int index) {
    final step = steps[index];
    final active = index == currentStep;
    final done = completedSteps.contains(index);
    final enabled = _enabled(index);
    final colors = context.colors;
    return OiTappable(
      enabled: enabled && onStepTap != null,
      disabledOpacity: 1,
      onTap: () => _navigate(index),
      semanticLabel:
          '${index + 1}. ${step.title}${active
              ? ', current step'
              : done
              ? ', completed'
              : ''}',
      child: Semantics(
        selected: active,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: done ? colors.primary.base : colors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: active || done
                              ? colors.primary.base
                              : colors.border,
                          width: active ? 2 : 1,
                        ),
                      ),
                      child: done
                          ? OiIcon.decorative(
                              icon: OiIcons.check,
                              size: 14,
                              color: colors.primary.foreground,
                            )
                          : OiLabel.small(
                              '${index + 1}',
                              color: active
                                  ? colors.primary.base
                                  : colors.textMuted,
                            ),
                    ),
                    if (index < steps.length - 1)
                      Expanded(
                        child: Center(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: done
                                ? colors.primary.base
                                : colors.borderSubtle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OiLabel.variant(
                        step.title,
                        variant: active
                            ? OiLabelVariant.bodyStrong
                            : OiLabelVariant.body,
                        color: active || done ? colors.text : colors.textMuted,
                        style: TextStyle(
                          height: 24 / 14,
                          fontWeight: active ? null : FontWeight.w500,
                        ),
                      ),
                      if (step.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: OiLabel.variant(
                            step.description!,
                            variant: OiLabelVariant.small,
                            color: colors.textMuted,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 16 / 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: .12,
                            ),
                          ),
                        ),
                      if (step.summary != null)
                        Padding(
                          padding: EdgeInsets.only(top: context.spacing.xs),
                          child: step.summary,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
