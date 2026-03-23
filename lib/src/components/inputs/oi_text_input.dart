import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/components/_internal/oi_otp_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/input/oi_raw_input.dart';

/// A themed single- or multi-line text input component.
///
/// Wraps [OiRawInput] inside an [OiInputFrame] which renders a label, border
/// (normal / focused / error), hint, and leading/trailing slots.
///
/// {@category Components}
class OiTextInput extends StatefulWidget {
  /// Creates an [OiTextInput].
  const OiTextInput({
    this.controller,
    this.label,
    this.hint,
    this.placeholder,
    this.error,
    this.leading,
    this.trailing,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.inputFormatters,
    this.focusNode,
    this.validator,
    this.autovalidateMode,
    this.onSaved,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.showCounter = false,
    this.counterBuilder,
    this.onTap,
    this.onTapOutside,
    super.key,
  })  : _isOtp = false,
        _otpLength = 0,
        _otpOnCompleted = null,
        _otpObscure = false,
        _isPassword = false;

  /// Creates a search-style [OiTextInput] with a leading search icon,
  /// "Search\u2026" placeholder, and [TextInputAction.search].
  const OiTextInput.search({
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.enabled = true,
    this.focusNode,
    super.key,
  })  : label = null,
        hint = null,
        placeholder = 'Search\u2026',
        error = null,
        leading = const Icon(
          OiIcons.search,
          size: 18,
        ),
        trailing = null,
        maxLines = 1,
        minLines = null,
        maxLength = null,
        keyboardType = null,
        textInputAction = TextInputAction.search,
        onEditingComplete = null,
        readOnly = false,
        obscureText = false,
        inputFormatters = null,
        validator = null,
        autovalidateMode = null,
        onSaved = null,
        textCapitalization = TextCapitalization.none,
        textAlign = TextAlign.start,
        showCounter = false,
        counterBuilder = null,
        onTap = null,
        onTapOutside = null,
        _isOtp = false,
        _otpLength = 0,
        _otpOnCompleted = null,
        _otpObscure = false,
        _isPassword = false;

  /// Creates a password-style [OiTextInput] with a trailing visibility toggle.
  ///
  /// The text is obscured by default. The trailing icon button allows the user
  /// to toggle between obscured and visible text.
  const OiTextInput.password({
    this.controller,
    this.label,
    this.hint,
    this.placeholder,
    this.error,
    this.leading,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.inputFormatters,
    this.focusNode,
    this.validator,
    this.autovalidateMode,
    this.onSaved,
    this.onTap,
    this.onTapOutside,
    super.key,
  })  : maxLines = 1,
        minLines = null,
        keyboardType = TextInputType.visiblePassword,
        textInputAction = null,
        obscureText = true,
        trailing = null,
        textCapitalization = TextCapitalization.none,
        textAlign = TextAlign.start,
        showCounter = false,
        counterBuilder = null,
        _isOtp = false,
        _otpLength = 0,
        _otpOnCompleted = null,
        _otpObscure = false,
        _isPassword = true;

  /// Creates a multiline text area.
  ///
  /// Equivalent to a `<textarea>` in HTML. The input grows vertically up to
  /// [maxLines] (unlimited by default) and starts at [minLines] height.
  const OiTextInput.multiline({
    this.controller,
    this.label,
    this.hint,
    this.placeholder,
    this.error,
    this.leading,
    this.trailing,
    this.maxLength,
    this.minLines = 3,
    this.maxLines,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.inputFormatters,
    this.focusNode,
    this.validator,
    this.autovalidateMode,
    this.onSaved,
    this.textCapitalization = TextCapitalization.sentences,
    this.textAlign = TextAlign.start,
    this.showCounter = false,
    this.counterBuilder,
    this.onTap,
    this.onTapOutside,
    super.key,
  })  : keyboardType = TextInputType.multiline,
        textInputAction = TextInputAction.newline,
        obscureText = false,
        _isOtp = false,
        _otpLength = 0,
        _otpOnCompleted = null,
        _otpObscure = false,
        _isPassword = false;

  /// Creates an OTP / PIN / verification code input.
  ///
  /// Renders as a row of individual digit boxes. Each box accepts a single
  /// digit and auto-advances focus on entry. Supports paste of full codes.
  const OiTextInput.otp({
    required int length,
    ValueChanged<String>? onCompleted,
    this.onChanged,
    bool obscure = false,
    this.autofocus = true,
    this.enabled = true,
    this.error,
    this.validator,
    this.autovalidateMode,
    this.onSaved,
    super.key,
  })  : _isOtp = true,
        _otpLength = length,
        _otpOnCompleted = onCompleted,
        _otpObscure = obscure,
        _isPassword = false,
        controller = null,
        label = null,
        hint = null,
        placeholder = null,
        leading = null,
        trailing = null,
        maxLines = 1,
        minLines = null,
        maxLength = null,
        keyboardType = TextInputType.number,
        textInputAction = null,
        onEditingComplete = null,
        onSubmitted = null,
        readOnly = false,
        obscureText = false,
        inputFormatters = null,
        focusNode = null,
        textCapitalization = TextCapitalization.none,
        textAlign = TextAlign.center,
        showCounter = false,
        counterBuilder = null,
        onTap = null,
        onTapOutside = null;

  /// An optional controller for the text field.
  ///
  /// When null an internal controller is created and managed automatically.
  final TextEditingController? controller;

  /// Optional label rendered above the input frame.
  final String? label;

  /// Optional hint text rendered below the input frame.
  final String? hint;

  /// Placeholder text shown inside the field when it is empty.
  final String? placeholder;

  /// Validation error message. When non-null the error border is shown and
  /// the message is rendered below the frame instead of [hint].
  final String? error;

  /// An optional widget placed at the start of the input row.
  final Widget? leading;

  /// An optional widget placed at the end of the input row.
  final Widget? trailing;

  /// Maximum number of lines. Defaults to 1 (single-line).
  final int? maxLines;

  /// Minimum number of lines the input occupies. Useful for multiline inputs.
  final int? minLines;

  /// Maximum number of characters the user may enter.
  final int? maxLength;

  /// Keyboard type hint for the platform IME.
  final TextInputType? keyboardType;

  /// The action button shown on the soft keyboard.
  final TextInputAction? textInputAction;

  /// Called when the text value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user finishes editing.
  final VoidCallback? onEditingComplete;

  /// Called when the user submits the input.
  final ValueChanged<String>? onSubmitted;

  /// Whether the field accepts input. Defaults to true.
  final bool enabled;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Whether to obscure the text (e.g. for passwords).
  final bool obscureText;

  /// Whether to request focus when first inserted into the tree.
  final bool autofocus;

  /// Optional list of input formatters applied to each keystroke.
  final List<TextInputFormatter>? inputFormatters;

  /// Optional external focus node. When null one is created internally.
  final FocusNode? focusNode;

  /// Validation function called by ancestor `Form.validate()`.
  ///
  /// Return `null` for valid, error string for invalid. When non-null,
  /// the widget internally wraps with [FormField<String>].
  final String? Function(String?)? validator;

  /// Controls when validation runs automatically.
  final AutovalidateMode? autovalidateMode;

  /// Called by `Form.save()` with the current value.
  final void Function(String?)? onSaved;

  /// Controls automatic capitalization behavior.
  final TextCapitalization textCapitalization;

  /// Text alignment within the input.
  final TextAlign textAlign;

  /// When `true` and [maxLength] is set, shows a character counter below
  /// the input (e.g. "3/50").
  final bool showCounter;

  /// Custom counter widget builder. Overrides default counter when provided.
  final Widget Function(
    BuildContext context, {
    required int currentLength,
    required int? maxLength,
    required bool isFocused,
  })? counterBuilder;

  /// Called when the input is tapped.
  final VoidCallback? onTap;

  /// Called when a tap occurs outside the input.
  final void Function(PointerDownEvent)? onTapOutside;

  // --- Internal OTP fields ---
  final bool _isOtp;
  final int _otpLength;
  final ValueChanged<String>? _otpOnCompleted;
  final bool _otpObscure;

  // --- Internal Password field ---
  final bool _isPassword;

  @override
  State<OiTextInput> createState() => _OiTextInputState();
}

class _OiTextInputState extends State<OiTextInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  bool _focused = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
      _ownsController = true;
    } else {
      _controller = widget.controller!;
    }
    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    } else {
      _focusNode = widget.focusNode!;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(OiTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) {
        _controller.dispose();
      }
      if (widget.controller == null) {
        _controller = TextEditingController();
        _ownsController = true;
      } else {
        _controller = widget.controller!;
        _ownsController = false;
      }
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      if (_ownsFocusNode) {
        _focusNode.dispose();
      }
      if (widget.focusNode == null) {
        _focusNode = FocusNode();
        _ownsFocusNode = true;
      } else {
        _focusNode = widget.focusNode!;
        _ownsFocusNode = false;
      }
      _focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    final focused = _focusNode.hasFocus;
    if (focused != _focused) {
      setState(() => _focused = focused);
    }
  }

  Widget _buildCounter(BuildContext context) {
    final currentLength = _controller.text.length;
    if (widget.counterBuilder != null) {
      return widget.counterBuilder!(
        context,
        currentLength: currentLength,
        maxLength: widget.maxLength,
        isFocused: _focused,
      );
    }
    final colors = context.colors;
    return Text(
      '$currentLength/${widget.maxLength}',
      style: TextStyle(
        fontSize: 12,
        color: colors.textMuted,
        height: 1.3,
      ),
    );
  }

  Widget _buildPasswordTrailing() {
    return GestureDetector(
      onTap: () => setState(() => _passwordVisible = !_passwordVisible),
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(
          _passwordVisible ? OiIcons.eyeOff : OiIcons.eye,
          size: 18,
          color: context.colors.textMuted,
        ),
      ),
    );
  }

  Widget _buildStandardInput({String? errorOverride}) {
    final effectiveObscure = widget._isPassword
        ? !_passwordVisible
        : widget.obscureText;

    final effectiveTrailing = widget._isPassword
        ? _buildPasswordTrailing()
        : widget.trailing;

    final showCounterWidget =
        widget.showCounter && widget.maxLength != null;

    final resolvedError = errorOverride ?? widget.error;

    Widget input = OiInputFrame(
      label: widget.label,
      hint: widget.hint,
      error: resolvedError,
      focused: _focused,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      leading: widget.leading,
      trailing: effectiveTrailing,
      counter: showCounterWidget ? _buildCounter(context) : null,
      child: OiRawInput(
        controller: _controller,
        focusNode: _focusNode,
        placeholder: widget.placeholder,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType ?? TextInputType.text,
        textInputAction: widget.textInputAction ?? TextInputAction.done,
        textCapitalization: widget.textCapitalization,
        textAlign: widget.textAlign,
        onChanged: (value) {
          widget.onChanged?.call(value);
          if (showCounterWidget) setState(() {});
        },
        onEditingComplete: widget.onEditingComplete,
        onSubmitted: widget.onSubmitted,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        obscureText: effectiveObscure,
        autofocus: widget.autofocus,
        inputFormatters: widget.inputFormatters,
      ),
    );

    if (widget.onTap != null || widget.onTapOutside != null) {
      input = TapRegion(
        onTapOutside: widget.onTapOutside,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.translucent,
          child: input,
        ),
      );
    }

    return input;
  }

  Widget _buildOtpInput(String? resolvedError) {
    return OiOtpInput(
      length: widget._otpLength,
      onCompleted: widget._otpOnCompleted,
      onChanged: widget.onChanged,
      obscure: widget._otpObscure,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      error: resolvedError,
    );
  }

  @override
  Widget build(BuildContext context) {
    // OTP mode
    if (widget._isOtp) {
      if (widget.validator != null) {
        return FormField<String>(
          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
          onSaved: widget.onSaved,
          builder: (FormFieldState<String> state) {
            final resolvedError = widget.error ?? state.errorText;
            return _buildOtpInput(resolvedError);
          },
        );
      }
      return _buildOtpInput(widget.error);
    }

    // Standard / password / search mode
    if (widget.validator != null) {
      return _OiTextInputFormField(
        validator: widget.validator!,
        autovalidateMode: widget.autovalidateMode,
        onSaved: widget.onSaved,
        controller: _controller,
        builder: (String? formError) {
          final resolvedError = widget.error ?? formError;
          return _buildStandardInput(errorOverride: resolvedError);
        },
      );
    }

    return _buildStandardInput();
  }
}

/// Wraps a [FormField<String>] that stays in sync with the given controller.
class _OiTextInputFormField extends StatefulWidget {
  const _OiTextInputFormField({
    required this.validator,
    required this.controller,
    required this.builder,
    this.autovalidateMode,
    this.onSaved,
  });

  final String? Function(String?) validator;
  final AutovalidateMode? autovalidateMode;
  final void Function(String?)? onSaved;
  final TextEditingController controller;
  final Widget Function(String? errorText) builder;

  @override
  State<_OiTextInputFormField> createState() => _OiTextInputFormFieldState();
}

class _OiTextInputFormFieldState extends State<_OiTextInputFormField> {
  final _fieldKey = GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncValue);
  }

  @override
  void didUpdateWidget(_OiTextInputFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncValue);
      widget.controller.addListener(_syncValue);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncValue);
    super.dispose();
  }

  void _syncValue() {
    _fieldKey.currentState?.didChange(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: _fieldKey,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      onSaved: widget.onSaved,
      initialValue: widget.controller.text,
      builder: (FormFieldState<String> state) {
        return widget.builder(state.errorText);
      },
    );
  }
}
