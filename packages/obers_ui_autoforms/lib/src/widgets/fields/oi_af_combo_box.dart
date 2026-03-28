import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiComboBox;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form combo box that wraps [OiComboBox].
class OiAfComboBox<TField extends Enum, TValue> extends StatefulWidget {
  const OiAfComboBox({
    required this.field,
    required this.label,
    required this.labelOf,
    this.items = const [],
    this.search,
    this.onCreate,
    this.placeholder,
    this.clearable = true,
    this.hint,
    this.groupBy,
    this.groupOrder,
    this.recentItems,
    this.favoriteItems,
    this.virtualScroll = false,
    this.itemHeight,
    this.loadMore,
    this.moreAvailable = false,
    this.optionBuilder,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final String label;
  final String Function(TValue) labelOf;
  final List<TValue> items;
  final Future<List<TValue>> Function(String query)? search;
  final ValueChanged<String>? onCreate;
  final String? placeholder;
  final bool clearable;
  final String? hint;
  final String Function(TValue)? groupBy;
  final List<String>? groupOrder;
  final List<TValue>? recentItems;
  final List<TValue>? favoriteItems;
  final bool virtualScroll;
  final double? itemHeight;
  final Future<List<TValue>> Function()? loadMore;
  final bool moreAvailable;
  final Widget Function(
    TValue, {
    required bool highlighted,
    required bool selected,
  })?
  optionBuilder;
  final bool enabled;

  @override
  State<OiAfComboBox<TField, TValue>> createState() =>
      _OiAfComboBoxState<TField, TValue>();
}

class _OiAfComboBoxState<TField extends Enum, TValue>
    extends State<OiAfComboBox<TField, TValue>>
    with OiAfFieldBinderMixin<OiAfComboBox<TField, TValue>, TField, TValue> {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.comboBox;

  @override
  String? get widgetLabel => widget.label;

  @override
  bool get widgetEnabled => widget.enabled;

  void _handleSelect(TValue? value) {
    onValueChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    if (!fieldCtrl.isVisible) return const SizedBox.shrink();

    return OiComboBox<TValue>(
      label: widget.label,
      labelOf: widget.labelOf,
      items: widget.items,
      value: typedValue,
      onSelect: effectiveEnabled ? _handleSelect : null,
      search: widget.search,
      onCreate: widget.onCreate,
      placeholder: widget.placeholder,
      clearable: widget.clearable,
      enabled: effectiveEnabled,
      hint: widget.hint,
      error: fieldCtrl.primaryError,
      groupBy: widget.groupBy,
      groupOrder: widget.groupOrder,
      recentItems: widget.recentItems,
      favoriteItems: widget.favoriteItems,
      virtualScroll: widget.virtualScroll,
      itemHeight: widget.itemHeight,
      loadMore: widget.loadMore,
      moreAvailable: widget.moreAvailable,
      optionBuilder: widget.optionBuilder,
    );
  }
}
