import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/shop/oi_shipping_option.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';

/// A picker that lists [OiShippingMethod]s and lets the user select one.
///
/// Coverage: REQ-0022
///
/// Renders a vertical list of [OiShippingOption] rows. The currently selected
/// method is highlighted. Tapping a row fires [onSelected] with the chosen
/// [OiShippingMethod]. When [methods] is empty an accessible empty-state
/// message is shown.
///
/// {@category Components}
class OiShippingMethodPicker extends StatelessWidget {
  /// Creates an [OiShippingMethodPicker].
  const OiShippingMethodPicker({
    required this.label,
    required this.methods,
    required this.onSelected,
    this.selectedKey,
    this.currencyCode = 'EUR',
    this.emptyLabel = 'No shipping methods available',
    super.key,
  });

  /// Accessibility label for the picker region.
  final String label;

  /// Available shipping methods.
  final List<OiShippingMethod> methods;

  /// Called when the user selects a shipping method.
  final ValueChanged<OiShippingMethod> onSelected;

  /// Key of the currently selected method.
  final Object? selectedKey;

  /// ISO 4217 currency code for price formatting. Defaults to `'EUR'`.
  final String currencyCode;

  /// Text shown when [methods] is empty.
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;
    final colors = context.colors;

    Widget content;
    if (methods.isEmpty) {
      content = OiLabel.body(emptyLabel, color: colors.textMuted);
    } else {
      content = OiColumn(
        breakpoint: breakpoint,
        gap: OiResponsive(sp.sm),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final method in methods)
            OiShippingOption(
              method: method,
              label: method.label,
              selected: method.key == selectedKey,
              onSelect: onSelected,
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
