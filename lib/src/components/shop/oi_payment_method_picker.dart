import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/shop/oi_payment_option.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';

/// A picker that lists [OiPaymentMethod]s and lets the user select one.
///
/// Coverage: REQ-0009
///
/// Renders a vertical list of [OiPaymentOption] rows. The currently selected
/// method is highlighted. Tapping a row fires [onSelect] with the chosen
/// [OiPaymentMethod]. When [methods] is empty, only the [addNewCard] slot
/// is shown if provided.
///
/// {@category Components}
class OiPaymentMethodPicker extends StatelessWidget {
  /// Creates an [OiPaymentMethodPicker].
  const OiPaymentMethodPicker({
    required this.label,
    required this.methods,
    this.onSelect,
    this.selectedKey,
    this.addNewCard,
    super.key,
  });

  /// Accessibility label for the picker region.
  final String label;

  /// Available payment methods.
  final List<OiPaymentMethod> methods;

  /// Called when the user selects a payment method.
  final ValueChanged<OiPaymentMethod>? onSelect;

  /// Key of the currently selected method.
  final Object? selectedKey;

  /// Optional widget rendered below the method list, separated by a divider.
  ///
  /// Typically used to offer an "Add new card" action. When [methods] is empty,
  /// the slot renders without a divider.
  final Widget? addNewCard;

  @override
  Widget build(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    final children = <Widget>[OiLabel.bodyStrong(label)];

    if (methods.isNotEmpty) {
      children.add(
        ExcludeSemantics(
          child: OiColumn(
            breakpoint: breakpoint,
            gap: OiResponsive(sp.xs),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final method in methods)
                OiPaymentOption(
                  method: method,
                  label: method.label,
                  selected: method.key == selectedKey,
                  onSelect: onSelect,
                ),
            ],
          ),
        ),
      );
      if (addNewCard != null) {
        children
          ..add(const OiDivider())
          ..add(addNewCard!);
      }
    } else if (addNewCard != null) {
      children.add(addNewCard!);
    }

    return Semantics(
      label: label,
      child: OiColumn(
        breakpoint: breakpoint,
        gap: OiResponsive(sp.xs),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
