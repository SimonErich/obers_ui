import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' hide OiFormController;
import 'package:obers_ui_forms/src/controllers/oi_form_controller.dart';
import 'package:obers_ui_forms/src/widgets/oi_auto_form.dart';
import 'package:obers_ui_forms/src/widgets/oi_form_scope.dart';

/// A form-aware text input that auto-binds to [OiFormScope].
///
/// Automatically reads value, writes changes, displays errors, and shows
/// the label from the form controller. No manual `onChanged` wiring needed.
///
/// ```dart
/// OiAutoFormTextInput<SignupFields>(
///   fieldKey: SignupFields.name,
///   label: 'Full Name',
///   placeholder: 'Enter your name',
/// )
/// ```
class OiAutoFormTextInput<E extends Enum> extends StatefulWidget {
  const OiAutoFormTextInput({
    required this.fieldKey,
    this.label,
    this.placeholder,
    this.hint,
    this.leading,
    this.trailing,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autofocus = false,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.showCounter = false,
    this.hideIf,
    this.showIf,
    this.revalidateOnChangeOf,
    super.key,
  });

  /// The enum key linking this input to its field controller.
  final E fieldKey;

  /// Label displayed above the input.
  final String? label;

  /// Placeholder text shown when empty.
  final String? placeholder;

  /// Hint text shown below the input.
  final String? hint;

  /// Widget displayed at the leading edge.
  final Widget? leading;

  /// Widget displayed at the trailing edge.
  final Widget? trailing;

  /// Maximum number of lines (1 for single-line, >1 for multiline).
  final int maxLines;

  /// Minimum number of lines.
  final int? minLines;

  /// Maximum character length.
  final int? maxLength;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Text input action (done, next, etc.).
  final TextInputAction? textInputAction;

  /// Whether to obscure text (password mode).
  final bool obscureText;

  /// Whether to autofocus.
  final bool autofocus;

  /// Input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Text capitalization.
  final TextCapitalization textCapitalization;

  /// Whether to show character counter.
  final bool showCounter;

  /// Hide when condition is true.
  final bool Function(OiFormController<E> controller)? hideIf;

  /// Show when condition is true (precedence over hideIf).
  final bool Function(OiFormController<E> controller)? showIf;

  /// Re-validate when these fields change.
  final List<E>? revalidateOnChangeOf;

  /// Creates a password variant with obscured text.
  const OiAutoFormTextInput.password({
    required this.fieldKey,
    this.label,
    this.placeholder,
    this.hint,
    this.hideIf,
    this.showIf,
    this.revalidateOnChangeOf,
    super.key,
  }) : maxLines = 1,
       minLines = null,
       maxLength = null,
       keyboardType = null,
       textInputAction = null,
       obscureText = true,
       autofocus = false,
       inputFormatters = null,
       textCapitalization = TextCapitalization.none,
       showCounter = false,
       leading = null,
       trailing = null;

  /// Creates a multiline variant.
  const OiAutoFormTextInput.multiline({
    required this.fieldKey,
    this.label,
    this.placeholder,
    this.hint,
    this.maxLines = 5,
    this.minLines,
    this.maxLength,
    this.hideIf,
    this.showIf,
    this.revalidateOnChangeOf,
    this.showCounter = false,
    super.key,
  }) : keyboardType = TextInputType.multiline,
       textInputAction = TextInputAction.newline,
       obscureText = false,
       autofocus = false,
       inputFormatters = null,
       textCapitalization = TextCapitalization.sentences,
       leading = null,
       trailing = null;

  @override
  State<OiAutoFormTextInput<E>> createState() => _OiAutoFormTextInputState<E>();
}

class _OiAutoFormTextInputState<E extends Enum>
    extends State<OiAutoFormTextInput<E>> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  bool _isSyncing = false;
  OiFormController<E>? _controller;
  final Map<E, VoidCallback> _revalidateListeners = {};

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = OiFormScope.maybeOf<E>(context);
    if (controller != _controller) {
      _removeRevalidateListeners();
      _controller = controller;
      _setupRevalidateListeners();
    }
    _syncFromController();
  }

  void _setupRevalidateListeners() {
    if (_controller == null || widget.revalidateOnChangeOf == null) return;
    for (final key in widget.revalidateOnChangeOf!) {
      void listener() {
        _controller!
            .getInputController(widget.fieldKey)
            .validateSync(_controller);
      }

      _revalidateListeners[key] = listener;
      _controller!.getInputController(key).addListener(listener);
    }
  }

  void _removeRevalidateListeners() {
    if (_controller == null) return;
    for (final entry in _revalidateListeners.entries) {
      try {
        _controller!.getInputController(entry.key).removeListener(entry.value);
      } catch (_) {}
    }
    _revalidateListeners.clear();
  }

  void _syncFromController() {
    final controller = OiFormScope.maybeOf<E>(context);
    if (controller == null) return;

    final currentValue = controller.get<String>(widget.fieldKey) ?? '';
    if (_textController.text != currentValue) {
      _isSyncing = true;
      _textController.text = currentValue;
      _isSyncing = false;
    }
  }

  void _onChanged(String value) {
    if (_isSyncing) return;
    final controller = OiFormScope.maybeOf<E>(context);
    controller?.set<String>(widget.fieldKey, value);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      final controller = OiFormScope.maybeOf<E>(context);
      controller?.onFieldBlur(widget.fieldKey);
    }
  }

  void _onSubmitted(String value) {
    // Enter-to-submit for single-line fields
    if (widget.maxLines == 1) {
      final controller = OiFormScope.maybeOf<E>(context);
      final onSubmit = OiAutoForm.onSubmitOf<E>(context);
      if (controller != null && onSubmit != null) {
        controller.submit(onSubmit);
      }
    }
  }

  @override
  void dispose() {
    _removeRevalidateListeners();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  bool _isVisible(OiFormController<E>? controller) {
    if (controller == null) return true;
    if (widget.showIf != null) return widget.showIf!(controller);
    if (widget.hideIf != null) return !widget.hideIf!(controller);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = OiFormScope.maybeOf<E>(context);
    final field = controller?.getInputController(widget.fieldKey);
    final error = field?.errors.isNotEmpty == true ? field!.errors.first : null;
    final enabled = field?.enabled ?? true;
    final isRequired = field?.required ?? false;

    if (!_isVisible(controller)) {
      return const SizedBox.shrink();
    }

    // Pass error directly to OiTextInput for border styling + error display.
    // Do NOT wrap in OiFormElement to avoid duplicate error rendering.
    final labelText = widget.label != null && isRequired
        ? '${widget.label!} *'
        : widget.label;

    Widget input = OiTextInput(
      controller: _textController,
      label: labelText,
      placeholder: widget.placeholder,
      hint: widget.hint,
      error: error,
      leading: widget.leading,
      trailing: widget.trailing,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      autofocus: widget.autofocus,
      inputFormatters: widget.inputFormatters,
      textCapitalization: widget.textCapitalization,
      showCounter: widget.showCounter,
      enabled: enabled,
      focusNode: _focusNode,
      onChanged: _onChanged,
      onSubmitted: _onSubmitted,
    );

    if (!enabled) {
      input = Opacity(opacity: 0.6, child: IgnorePointer(child: input));
    }

    return input;
  }
}
