import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/shop/oi_shipping_option.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';
import 'package:obers_ui/src/primitives/animation/oi_shimmer.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

/// A picker that lists [OiShippingMethod]s and lets the user select one.
///
/// Coverage: REQ-0006
///
/// Renders a vertical list of [OiShippingOption] rows. The currently selected
/// method is highlighted. Tapping a row fires [onSelect] with the chosen
/// [OiShippingMethod]. When [methods] is empty an accessible empty-state
/// message is shown. When [loading] is `true`, shimmer placeholders are
/// displayed instead of the methods list.
///
/// {@category Components}
class OiShippingMethodPicker extends StatelessWidget {
  /// Creates an [OiShippingMethodPicker].
  const OiShippingMethodPicker({
    required this.label,
    required this.methods,
    this.onSelect,
    this.selectedKey,
    this.currencyCode = 'EUR',
    this.emptyLabel = 'No shipping methods available',
    this.loading = false,
    super.key,
  });

  /// Accessibility label for the picker region.
  final String label;

  /// Available shipping methods.
  final List<OiShippingMethod> methods;

  /// Called when the user selects a shipping method.
  final ValueChanged<OiShippingMethod>? onSelect;

  /// Key of the currently selected method.
  final Object? selectedKey;

  /// ISO 4217 currency code for price formatting. Defaults to `'EUR'`.
  final String currencyCode;

  /// Text shown when [methods] is empty.
  final String emptyLabel;

  /// Whether the picker is in a loading state.
  ///
  /// When `true`, shimmer placeholders are shown instead of methods.
  final bool loading;

  Widget _buildShimmerPlaceholders(BuildContext context) {
    final sp = context.spacing;
    final colors = context.colors;
    final breakpoint = context.breakpoint;

    Widget shimmerRow() {
      return OiSurface(
        borderRadius: context.radius.sm,
        border: OiBorderStyle.solid(colors.borderSubtle, 1),
        padding: EdgeInsets.all(sp.md),
        child: OiRow(
          breakpoint: breakpoint,
          gap: OiResponsive(sp.sm),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OiShimmer(
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.surfaceSubtle,
                ),
              ),
            ),
            Expanded(
              child: OiColumn(
                breakpoint: breakpoint,
                gap: const OiResponsive(4),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OiRow(
                    breakpoint: breakpoint,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: OiShimmer(
                          child: Container(
                            height: 14,
                            width: 120,
                            color: colors.surfaceSubtle,
                          ),
                        ),
                      ),
                      OiShimmer(
                        child: Container(
                          height: 14,
                          width: 50,
                          color: colors.surfaceSubtle,
                        ),
                      ),
                    ],
                  ),
                  OiShimmer(
                    child: Container(
                      height: 12,
                      width: 180,
                      color: colors.surfaceSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [shimmerRow(), shimmerRow(), shimmerRow()],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.colors;
    return OiLabel.small(emptyLabel, color: colors.textMuted);
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    Widget content;
    if (loading) {
      content = _buildShimmerPlaceholders(context);
    } else if (methods.isEmpty) {
      content = _buildEmptyState(context);
    } else {
      content = OiColumn(
        breakpoint: breakpoint,
        gap: OiResponsive(sp.xs),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final method in methods)
            OiShippingOption(
              method: method,
              label: method.label,
              selected: method.key == selectedKey,
              onSelect: onSelect,
              currencyCode: currencyCode,
            ),
        ],
      );
    }

    return Semantics(
      label: label,
      child: OiColumn(
        breakpoint: breakpoint,
        gap: OiResponsive(sp.sm),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OiLabel.bodyStrong(label),
          ExcludeSemantics(child: content),
        ],
      ),
    );
  }
}
