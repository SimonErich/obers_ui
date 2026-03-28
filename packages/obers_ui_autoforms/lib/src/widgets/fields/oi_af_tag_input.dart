import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiTagInput;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form tag input that wraps [OiTagInput].
class OiAfTagInput<TField extends Enum> extends StatefulWidget {
  const OiAfTagInput({
    required this.field,
    this.label,
    this.hint,
    this.placeholder,
    this.maxTags,
    this.suggestions,
    this.asyncSuggestions,
    this.suggestionDebounce = const Duration(milliseconds: 300),
    this.allowCustomTags = true,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final String? label;
  final String? hint;
  final String? placeholder;
  final int? maxTags;
  final List<String>? suggestions;
  final Future<List<String>> Function(String query)? asyncSuggestions;
  final Duration suggestionDebounce;
  final bool allowCustomTags;
  final bool enabled;

  @override
  State<OiAfTagInput<TField>> createState() => _OiAfTagInputState<TField>();
}

class _OiAfTagInputState<TField extends Enum>
    extends State<OiAfTagInput<TField>>
    with OiAfFieldBinderMixin<OiAfTagInput<TField>, TField, List<String>> {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.tags;

  @override
  String? get widgetLabel => widget.label;

  @override
  bool get widgetEnabled => widget.enabled;

  void _handleChanged(List<String> value) {
    onValueChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    if (!fieldCtrl.isVisible) return const SizedBox.shrink();

    return OiTagInput(
      tags: typedValue ?? const [],
      onChanged: effectiveEnabled ? _handleChanged : null,
      label: widget.label,
      hint: widget.hint,
      error: fieldCtrl.primaryError,
      placeholder: widget.placeholder,
      enabled: effectiveEnabled,
      maxTags: widget.maxTags,
      suggestions: widget.suggestions,
      asyncSuggestions: widget.asyncSuggestions,
      suggestionDebounce: widget.suggestionDebounce,
      allowCustomTags: widget.allowCustomTags,
    );
  }
}
