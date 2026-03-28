import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_page_indicator.dart';
import 'package:obers_ui/src/components/inputs/oi_segmented_control.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

// ── Data Models ─────────────────────────────────────────────────────────────

/// Billing cycle for pricing.
///
/// {@category Modules}
enum OiBillingCycle {
  /// Billed every month.
  monthly,

  /// Billed annually.
  yearly,
}

/// A feature row in a pricing comparison matrix.
///
/// {@category Modules}
@immutable
class OiPricingFeature {
  /// Creates an [OiPricingFeature].
  const OiPricingFeature({
    required this.label,
    required this.included,
    this.tooltip,
  });

  /// Human-readable label for the feature.
  final String label;

  /// Maps plan key to inclusion: `true` = check, `false` = cross,
  /// `String` = custom text.
  final Map<String, Object> included;

  /// Optional tooltip for the feature label.
  final String? tooltip;
}

/// A pricing plan.
///
/// {@category Modules}
@immutable
class OiPricingPlan {
  /// Creates an [OiPricingPlan].
  const OiPricingPlan({
    required this.key,
    required this.name,
    required this.monthlyPrice,
    this.yearlyPrice,
    this.description,
    this.features = const [],
    this.ctaLabel = 'Get Started',
    this.recommended = false,
    this.currentPlan = false,
    this.contactSales = false,
    this.badge,
  });

  /// Unique key for the plan (used in feature map lookups).
  final String key;

  /// Display name of the plan.
  final String name;

  /// Price per month when billed monthly.
  final double monthlyPrice;

  /// Price per year when billed yearly. If null, monthly price * 12 is assumed.
  final double? yearlyPrice;

  /// Short description below the plan name.
  final String? description;

  /// List of feature descriptions shown on the plan card.
  final List<String> features;

  /// Label for the call-to-action button.
  final String ctaLabel;

  /// Whether this plan should be visually highlighted as recommended.
  final bool recommended;

  /// Whether this is the user's current plan.
  final bool currentPlan;

  /// Whether the plan requires contacting sales instead of showing a price.
  final bool contactSales;

  /// Optional badge text (e.g. "Popular", "Best Value").
  final String? badge;
}

// ── Main Widget ─────────────────────────────────────────────────────────────

/// A pricing plan comparison table with feature matrix, billing cycle
/// toggle, and recommended plan highlighting.
///
/// {@category Modules}
class OiPricingTable extends StatefulWidget {
  /// Creates an [OiPricingTable].
  const OiPricingTable({
    required this.plans,
    required this.label,
    this.features = const [],
    this.onPlanSelect,
    this.onBillingCycleChange,
    this.billingCycle = OiBillingCycle.monthly,
    this.showBillingToggle = true,
    this.yearlyDiscount,
    this.currencySymbol = r'$',
    this.showFeatureMatrix = true,
    this.maxWidth = 1200,
    this.mobileBreakpoint = OiBreakpoint.expanded,
    super.key,
  });

  /// The list of plans to display.
  final List<OiPricingPlan> plans;

  /// Accessibility label for the entire pricing table.
  final String label;

  /// Feature rows for the comparison matrix below the plans.
  final List<OiPricingFeature> features;

  /// Called when a plan's CTA button is tapped.
  final void Function(OiPricingPlan plan, OiBillingCycle cycle)? onPlanSelect;

  /// Called when the billing cycle is toggled.
  final ValueChanged<OiBillingCycle>? onBillingCycleChange;

  /// The initial billing cycle. Defaults to [OiBillingCycle.monthly].
  final OiBillingCycle billingCycle;

  /// Whether to show the monthly/yearly toggle. Defaults to `true`.
  final bool showBillingToggle;

  /// Discount label shown next to the yearly option (e.g. "Save 20%").
  final String? yearlyDiscount;

  /// Currency symbol prefix for prices. Defaults to `$`.
  final String currencySymbol;

  /// Whether to render the feature comparison matrix. Defaults to `true`.
  final bool showFeatureMatrix;

  /// Maximum width for the pricing table. Defaults to 1200.
  final double maxWidth;

  /// Breakpoint below which mobile layout is used.
  final OiBreakpoint mobileBreakpoint;

  @override
  State<OiPricingTable> createState() => _OiPricingTableState();
}

class _OiPricingTableState extends State<OiPricingTable> {
  late OiBillingCycle _billingCycle;
  late PageController _mobilePageController;
  int _mobileActivePlan = 0;

  @override
  void initState() {
    super.initState();
    _billingCycle = widget.billingCycle;
    // Start on the recommended plan if there is one.
    final recommendedIndex = widget.plans.indexWhere((p) => p.recommended);
    _mobileActivePlan = recommendedIndex >= 0 ? recommendedIndex : 0;
    _mobilePageController = PageController(
      initialPage: _mobileActivePlan,
      viewportFraction: 0.85,
    );
  }

  @override
  void didUpdateWidget(OiPricingTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.billingCycle != widget.billingCycle) {
      _billingCycle = widget.billingCycle;
    }
  }

  @override
  void dispose() {
    _mobilePageController.dispose();
    super.dispose();
  }

  void _toggleBillingCycle(OiBillingCycle cycle) {
    setState(() => _billingCycle = cycle);
    widget.onBillingCycleChange?.call(cycle);
  }

  bool _isMobile(double width) {
    return width < widget.mobileBreakpoint.minWidth;
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sp = context.spacing;

    return Semantics(
      label: widget.label,
      container: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mobile = _isMobile(constraints.maxWidth);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showBillingToggle) ...[
                  _buildBillingToggle(context),
                  SizedBox(height: sp.lg),
                ],
                if (mobile)
                  _buildMobilePlans(context)
                else
                  _buildDesktopPlans(context),
                if (widget.showFeatureMatrix && widget.features.isNotEmpty) ...[
                  SizedBox(height: sp.xl),
                  _buildFeatureMatrix(context),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Billing Toggle ──────────────────────────────────────────────────────

  Widget _buildBillingToggle(BuildContext context) {
    final sp = context.spacing;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OiSegmentedControl<OiBillingCycle>(
          segments: const [
            OiSegment<OiBillingCycle>(
              value: OiBillingCycle.monthly,
              label: 'Monthly',
            ),
            OiSegment<OiBillingCycle>(
              value: OiBillingCycle.yearly,
              label: 'Yearly',
            ),
          ],
          selected: _billingCycle,
          onChanged: _toggleBillingCycle,
          semanticLabel: 'Billing cycle',
        ),
        if (widget.yearlyDiscount != null) ...[
          SizedBox(width: sp.sm),
          OiBadge.soft(
            label: widget.yearlyDiscount!,
            color: OiBadgeColor.success,
            size: OiBadgeSize.small,
          ),
        ],
      ],
    );
  }

  // ── Desktop Plans ───────────────────────────────────────────────────────

  Widget _buildDesktopPlans(BuildContext context) {
    final sp = context.spacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < widget.plans.length; i++) ...[
          Expanded(child: _buildPlanCard(context, widget.plans[i])),
          if (i < widget.plans.length - 1) SizedBox(width: sp.md),
        ],
      ],
    );
  }

  // ── Mobile Plans ────────────────────────────────────────────────────────

  Widget _buildMobilePlans(BuildContext context) {
    final sp = context.spacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Scale card height based on available width, with a reasonable range.
            final cardHeight = (constraints.maxWidth * 1.1).clamp(360.0, 520.0);
            return SizedBox(
              height: cardHeight,
              child: PageView.builder(
                controller: _mobilePageController,
                itemCount: widget.plans.length,
                onPageChanged: (index) {
                  setState(() => _mobileActivePlan = index);
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: sp.xs),
                    child: _buildPlanCard(context, widget.plans[index]),
                  );
                },
              ),
            );
          },
        ),
        SizedBox(height: sp.md),
        OiPageIndicator(
          count: widget.plans.length,
          current: _mobileActivePlan,
          semanticLabel:
              'Plan ${_mobileActivePlan + 1} of '
              '${widget.plans.length}',
        ),
      ],
    );
  }

  // ── Plan Card ───────────────────────────────────────────────────────────

  Widget _buildPlanCard(BuildContext context, OiPricingPlan plan) {
    final colors = context.colors;
    final sp = context.spacing;
    final rd = context.radius;

    final isRecommended = plan.recommended;
    final borderColor = isRecommended
        ? colors.primary.base
        : colors.borderSubtle;
    final borderWidth = isRecommended ? 2.0 : 1.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: rd.lg,
      ),
      child: Padding(
        padding: EdgeInsets.all(sp.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Plan header: badges and name
            Row(
              children: [
                Expanded(child: OiLabel.h4(plan.name)),
                if (isRecommended)
                  OiBadge.filled(
                    label: plan.badge ?? 'Recommended',
                    size: OiBadgeSize.small,
                  )
                else if (plan.badge != null)
                  OiBadge.soft(label: plan.badge!, size: OiBadgeSize.small),
              ],
            ),
            if (plan.currentPlan) ...[
              SizedBox(height: sp.xs),
              const Align(
                alignment: AlignmentDirectional.centerStart,
                child: OiBadge.outline(
                  label: 'Current Plan',
                  color: OiBadgeColor.info,
                  size: OiBadgeSize.small,
                ),
              ),
            ],
            SizedBox(height: sp.md),

            // Price
            _buildPrice(context, plan),
            SizedBox(height: sp.xs),

            // Description
            if (plan.description != null) ...[
              OiLabel.small(plan.description!, color: colors.textSubtle),
              SizedBox(height: sp.md),
            ],

            // Divider
            const OiDivider(),
            SizedBox(height: sp.md),

            // Features list
            ...plan.features.map(
              (feature) => Padding(
                padding: EdgeInsets.only(bottom: sp.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OiIcon.decorative(
                      icon: OiIcons.check,
                      size: 16,
                      color: colors.success.base,
                    ),
                    SizedBox(width: sp.sm),
                    Expanded(child: OiLabel.small(feature)),
                  ],
                ),
              ),
            ),

            SizedBox(height: sp.lg),

            // CTA Button
            if (isRecommended)
              OiButton.primary(
                label: plan.currentPlan ? 'Current Plan' : plan.ctaLabel,
                onTap: plan.currentPlan
                    ? null
                    : () => widget.onPlanSelect?.call(plan, _billingCycle),
                enabled: !plan.currentPlan,
                fullWidth: true,
              )
            else
              OiButton.ghost(
                label: plan.currentPlan ? 'Current Plan' : plan.ctaLabel,
                onTap: plan.currentPlan
                    ? null
                    : () => widget.onPlanSelect?.call(plan, _billingCycle),
                enabled: !plan.currentPlan,
                fullWidth: true,
              ),
          ],
        ),
      ),
    );
  }

  // ── Price Display ───────────────────────────────────────────────────────

  Widget _buildPrice(BuildContext context, OiPricingPlan plan) {
    final colors = context.colors;
    final sp = context.spacing;

    if (plan.contactSales) {
      return const OiLabel.h2('Contact Sales');
    }

    final double price;
    final String suffix;

    if (_billingCycle == OiBillingCycle.yearly) {
      if (plan.yearlyPrice != null) {
        // Show yearly price divided by 12 to show monthly equivalent.
        price = plan.yearlyPrice! / 12;
      } else {
        price = plan.monthlyPrice;
      }
      suffix = '/mo';
    } else {
      price = plan.monthlyPrice;
      suffix = '/mo';
    }

    // Format price: remove trailing zeros.
    final priceStr = price == price.roundToDouble()
        ? price.toInt().toString()
        : price.toStringAsFixed(2);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        OiLabel.h2('${widget.currencySymbol}$priceStr'),
        SizedBox(width: sp.xs),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: OiLabel.small(suffix, color: colors.textMuted),
        ),
      ],
    );
  }

  // ── Feature Matrix ──────────────────────────────────────────────────────

  Widget _buildFeatureMatrix(BuildContext context) {
    final colors = context.colors;
    final sp = context.spacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const OiLabel.h3('Feature Comparison'),
        SizedBox(height: sp.md),

        // Header row
        _buildFeatureRow(
          context,
          label: '',
          cells: widget.plans.map((p) => p.name).toList(),
          isHeader: true,
        ),
        const OiDivider(),
        SizedBox(height: sp.xs),

        // Feature rows
        for (int i = 0; i < widget.features.length; i++) ...[
          _buildFeatureRow(
            context,
            label: widget.features[i].label,
            cells: widget.plans.map((plan) {
              final value = widget.features[i].included[plan.key];
              return value;
            }).toList(),
          ),
          if (i < widget.features.length - 1)
            Padding(
              padding: EdgeInsets.symmetric(vertical: sp.xs),
              child: OiDivider(
                color: colors.borderSubtle.withValues(alpha: 0.5),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildFeatureRow(
    BuildContext context, {
    required String label,
    required List<Object?> cells,
    bool isHeader = false,
  }) {
    final sp = context.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: sp.xs),
      child: Row(
        children: [
          // Feature label column (takes ~40% of width).
          Expanded(
            flex: 2,
            child: isHeader ? const SizedBox.shrink() : OiLabel.small(label),
          ),

          // Plan value columns.
          ...cells.map(
            (cell) => Expanded(
              child: Center(
                child: _buildCellContent(context, cell, isHeader: isHeader),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCellContent(
    BuildContext context,
    Object? value, {
    bool isHeader = false,
  }) {
    final colors = context.colors;

    if (isHeader) {
      return OiLabel.small(
        value?.toString() ?? '',
        textAlign: TextAlign.center,
        color: colors.textSubtle,
      );
    }

    if (value == true) {
      return Semantics(
        label: 'Included',
        child: OiIcon.decorative(
          icon: OiIcons.check,
          size: 16,
          color: colors.success.base,
        ),
      );
    }

    if (value == false || value == null) {
      return Semantics(
        label: 'Not included',
        child: OiIcon.decorative(
          icon: OiIcons.x,
          size: 16,
          color: colors.textMuted,
        ),
      );
    }

    // String or custom text.
    return OiLabel.small(value.toString(), textAlign: TextAlign.center);
  }
}
