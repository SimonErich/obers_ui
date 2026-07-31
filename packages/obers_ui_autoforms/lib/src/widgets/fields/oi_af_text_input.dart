import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiTextInput;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form text input that wraps [OiTextInput].
class OiAfTextInput<TField extends Enum> extends StatefulWidget {
  const OiAfTextInput({
    required this.field,
    this.label,
    this.hint,
    this.placeholder,
    this.leading,
    this.trailing,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.obscureText = false,
    this.autofocus = false,
    this.readOnly = false,
    this.enabled = true,
    this.inputFormatters,
    this.showCounter = false,
    this.semanticLabel,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.onBlur,
    this.onFocus,
    this.counterBuilder,
    super.key,
  }) : _isPassword = false,
       _isSearch = false;

  /// Creates a password-style text input with visibility toggle.
  const OiAfTextInput.password({
    required this.field,
    this.label,
    this.hint,
    this.placeholder,
    this.leading,
    this.trailing,
    this.autofocus = false,
    this.readOnly = false,
    this.enabled = true,
    this.semanticLabel,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.onBlur,
    this.onFocus,
    this.counterBuilder,
    super.key,
  }) : maxLines = 1,
       minLines = null,
       maxLength = null,
       keyboardType = null,
       textInputAction = null,
       textCapitalization = TextCapitalization.none,
       textAlign = TextAlign.start,
       obscureText = true,
       inputFormatters = null,
       showCounter = false,
       _isPassword = true,
       _isSearch = false;

  /// Creates a multiline text input.
  const OiAfTextInput.multiline({
    required this.field,
    this.label,
    this.hint,
    this.placeholder,
    this.leading,
    this.trailing,
    this.maxLines,
    this.minLines = 3,
    this.maxLength,
    this.autofocus = false,
    this.readOnly = false,
    this.enabled = true,
    this.inputFormatters,
    this.showCounter = false,
    this.semanticLabel,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.onBlur,
    this.onFocus,
    this.counterBuilder,
    super.key,
  }) : keyboardType = TextInputType.multiline,
       textInputAction = TextInputAction.newline,
       textCapitalization = TextCapitalization.sentences,
       textAlign = TextAlign.start,
       obscureText = false,
       _isPassword = false,
       _isSearch = false;

  /// Creates a search-style text input with a leading search icon.
  const OiAfTextInput.search({
    required this.field,
    this.label,
    this.hint,
    this.autofocus = false,
    this.enabled = true,
    this.semanticLabel,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.onBlur,
    this.onFocus,
    super.key,
  }) : placeholder = null,
       leading = null,
       trailing = null,
       maxLines = 1,
       minLines = null,
       maxLength = null,
       keyboardType = null,
       textInputAction = null,
       textCapitalization = TextCapitalization.none,
       textAlign = TextAlign.start,
       obscureText = false,
       readOnly = false,
       inputFormatters = null,
       showCounter = false,
       counterBuilder = null,
       _isPassword = false,
       _isSearch = true;

  final TField field;
  final String? label;
  final String? hint;
  final String? placeholder;
  final Widget? leading;
  final Widget? trailing;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final bool obscureText;
  final bool autofocus;
  final bool readOnly;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final bool showCounter;
  final String? semanticLabel;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final void Function(PointerDownEvent)? onTapOutside;
  final VoidCallback? onBlur;
  final VoidCallback? onFocus;
  final Widget Function(
    BuildContext context, {
    required int currentLength,
    required int? maxLength,
    required bool focused,
  })?
  counterBuilder;
  final bool _isPassword;
  final bool _isSearch;

  @override
  State<OiAfTextInput<TField>> createState() => _OiAfTextInputState<TField>();
}

class _OiAfTextInputState<TField extends Enum>
    extends State<OiAfTextInput<TField>>
    with OiAfFieldBinderMixin<OiAfTextInput<TField>, TField, String> {
  late TextEditingController _textController;
  bool _syncing = false;

  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.text;

  @override
  String? get widgetLabel => widget.label;

  @override
  bool get widgetEnabled => widget.enabled;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    focusNode.addListener(_handleTextFocusCallbacks);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTextController();
  }

  @override
  void didUpdateWidget(covariant OiAfTextInput<TField> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.field != widget.field) {
      _syncTextController();
    }
  }

  void _syncTextController() {
    final fieldValue = typedValue ?? '';
    if (_textController.text != fieldValue) {
      _syncing = true;
      _textController.text = fieldValue;
      _syncing = false;
    }
  }

  void _syncFromController() {
    _syncTextController();
  }

  @override
  void onFieldControllerChanged() {
    _syncFromController();
  }

  void _handleChanged(String value) {
    if (_syncing) return;
    fieldCtrl.setValue(value);
    widget.onChanged?.call(value);
  }

  void _handleTextFocusCallbacks() {
    if (focusNode.hasFocus) {
      widget.onFocus?.call();
    } else {
      widget.onBlur?.call();
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(_handleTextFocusCallbacks);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!fieldCtrl.isVisible) return const SizedBox.shrink();

    if (widget._isSearch) {
      return OiTextInput.search(
        controller: _textController,
        focusNode: focusNode,
        onChanged: _handleChanged,
        onSubmitted: (v) {
          onFieldSubmitted(v);
          widget.onSubmitted?.call(v);
        },
        enabled: effectiveEnabled,
        autofocus: widget.autofocus,
      );
    }

    if (widget._isPassword) {
      return OiTextInput.password(
        controller: _textController,
        focusNode: focusNode,
        label: widget.label,
        hint: widget.hint,
        placeholder: widget.placeholder,
        onChanged: _handleChanged,
        onSubmitted: (v) {
          onFieldSubmitted(v);
          widget.onSubmitted?.call(v);
        },
        enabled: effectiveEnabled,
        autofocus: widget.autofocus,
        readOnly: widget.readOnly,
        error: fieldCtrl.primaryError,
        onTap: widget.onTap,
        onTapOutside: widget.onTapOutside,
      );
    }

    return OiTextInput(
      controller: _textController,
      label: widget.label,
      hint: widget.hint,
      placeholder: widget.placeholder,
      leading: widget.leading,
      trailing: widget.trailing,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      textAlign: widget.textAlign,
      obscureText: widget.obscureText,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      enabled: effectiveEnabled,
      inputFormatters: widget.inputFormatters,
      showCounter: widget.showCounter,
      counterBuilder: widget.counterBuilder,
      focusNode: focusNode,
      error: fieldCtrl.primaryError,
      onChanged: _handleChanged,
      onSubmitted: (v) {
        onFieldSubmitted(v);
        widget.onSubmitted?.call(v);
      },
      onTap: widget.onTap,
      onTapOutside: widget.onTapOutside,
    );
  }
}
