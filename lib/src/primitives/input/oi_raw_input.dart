import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_text_selection_controls.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A low-level text input widget that wraps [EditableText] with optional
/// leading/trailing slots, placeholder support, and scroll-into-view on focus.
///
/// [OiRawInput] is intentionally free of Material or Cupertino styling so that
/// higher-level design tokens can be applied by callers.
///
/// {@category Primitives}
class OiRawInput extends StatefulWidget {
  /// Creates an [OiRawInput].
  const OiRawInput({
    required this.controller,
    required this.focusNode,
    this.placeholder,
    this.excludePlaceholderSemantics = false,
    this.leading,
    this.trailing,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.autofillHints,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.style,
    this.cursorColor,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autofocus = false,
    this.inputFormatters,
    this.scrollController,
    this.selectionControls,
    this.contextMenuBuilder = buildOiSelectionToolbar,
    super.key,
  });

  /// The controller managing the text being edited.
  final TextEditingController controller;

  /// The focus node for this input.
  final FocusNode focusNode;

  /// Placeholder text shown when [controller] text is empty.
  final String? placeholder;

  /// Prevents a visual placeholder from being merged into an explicit label.
  /// The owning input should expose it as a semantic hint instead.
  final bool excludePlaceholderSemantics;

  /// An optional widget placed before the text field.
  final Widget? leading;

  /// An optional widget placed after the text field.
  final Widget? trailing;

  /// The maximum number of lines for the input.
  ///
  /// Set to `1` (the default) for a single-line field. Set to `null` for
  /// an unlimited multi-line field.
  final int? maxLines;

  /// The minimum number of lines the field occupies.
  final int? minLines;

  /// The maximum number of characters the user may enter.
  final int? maxLength;

  /// The type of keyboard to display for this text field.
  final TextInputType keyboardType;

  /// The action button shown on the soft keyboard.
  final TextInputAction textInputAction;

  /// How the text should be capitalized when the user types.
  final TextCapitalization textCapitalization;

  /// Called when the text value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user finishes editing (e.g. presses Enter).
  final VoidCallback? onEditingComplete;

  /// Called when the user submits the input.
  final ValueChanged<String>? onSubmitted;

  /// Autofill hints forwarded to the platform editable control.
  final Iterable<String>? autofillHints;

  /// Whether the field accepts user input.
  ///
  /// Disabling releases focus and blocks focus requests while preserving the
  /// controller, selection and caller-owned [focusNode] settings.
  final bool enabled;

  /// Whether the field is read-only (shows text but ignores input).
  final bool readOnly;

  /// Whether to obscure the entered text (e.g. for passwords).
  final bool obscureText;

  /// The text style applied to the input. Defaults to [OiLabelVariant.body]
  /// from the active theme, or a plain [TextStyle] if no theme is present.
  final TextStyle? style;

  /// The color of the cursor. Defaults to `Color(0xFF000000)` when no theme
  /// is available.
  final Color? cursorColor;

  /// The width of the cursor in logical pixels.
  final double cursorWidth;

  /// The height of the cursor in logical pixels. Defaults to the line height.
  final double? cursorHeight;

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// How the text should be aligned vertically within the field.
  final TextAlignVertical? textAlignVertical;

  /// Whether the field should request focus when first inserted into the tree.
  final bool autofocus;

  /// Optional input formatters applied before [onChanged] is fired.
  final List<TextInputFormatter>? inputFormatters;

  /// An optional scroll controller for the internal [EditableText].
  final ScrollController? scrollController;

  /// Custom [TextSelectionControls] for the selection handles.
  ///
  /// When null, [OiTextSelectionControls] is used.
  final TextSelectionControls? selectionControls;

  /// Builder for the text selection context menu (Cut / Copy / Paste / …).
  ///
  /// Defaults to [buildOiSelectionToolbar].
  final EditableTextContextMenuBuilder contextMenuBuilder;

  @override
  State<OiRawInput> createState() => _OiRawInputState();
}

class _OiRawInputState extends State<OiRawInput>
    implements TextSelectionGestureDetectorBuilderDelegate {
  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => widget.enabled;

  late final TextSelectionGestureDetectorBuilder _selectionGestures;
  // EditableText treats changed selection controls as a replacement overlay.
  // Keep their identity stable across controller, focus and theme rebuilds.
  final OiTextSelectionControls _selectionControls = OiTextSelectionControls();
  // Track whether the placeholder should be visible.
  bool _showPlaceholder = true;

  @override
  void initState() {
    super.initState();
    _selectionGestures = TextSelectionGestureDetectorBuilder(delegate: this);
    _showPlaceholder = widget.controller.text.isEmpty;
    widget.controller.addListener(_handleTextChanged);
    widget.focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(OiRawInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChanged);
      widget.controller.addListener(_handleTextChanged);
      _showPlaceholder = widget.controller.text.isEmpty;
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChanged);
      widget.focusNode.addListener(_handleFocusChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    widget.focusNode.removeListener(_handleFocusChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    final empty = widget.controller.text.isEmpty;
    if (empty != _showPlaceholder) {
      setState(() => _showPlaceholder = empty);
    }
  }

  void _handleFocusChanged() {
    if (widget.focusNode.hasFocus) {
      // Scroll this widget into view after the frame is laid out.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final reduced =
              context.animations.reducedMotion ||
              MediaQuery.disableAnimationsOf(context);
          Scrollable.maybeOf(context)?.position; // trigger dependency

          Scrollable.ensureVisible(
            context,
            alignment: 0.5,
            duration: reduced
                ? Duration.zero
                : const Duration(milliseconds: 200),
          );
        }
      });
    }
  }

  void _handlePointerDown(PointerDownEvent _) {
    if (!widget.enabled || widget.readOnly) return;
    if (!widget.focusNode.hasFocus) {
      widget.focusNode.requestFocus();
    }
  }

  // ── Style helpers ─────────────────────────────────────────────────────────

  TextStyle _resolveStyle(BuildContext context) {
    if (widget.style != null) return widget.style!;
    final themeData = OiTheme.maybeOf(context);
    if (themeData != null) {
      return themeData.textTheme
          .styleFor(OiLabelVariant.small)
          .copyWith(color: themeData.colors.text, height: 1.2)
          .merge(themeData.components.textInput?.textStyle);
    }
    return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.2,
    );
  }

  Color _resolveCursorColor(BuildContext context) {
    if (widget.cursorColor != null) return widget.cursorColor!;
    final themeData = OiTheme.maybeOf(context);
    if (themeData != null) {
      return themeData.colors.primary.base;
    }
    return const Color(0xFF000000);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = _resolveStyle(context);
    final effectiveCursorColor = _resolveCursorColor(context);

    // The core EditableText widget.
    final editableText = EditableText(
      key: editableTextKey,
      controller: widget.controller,
      focusNode: widget.focusNode,
      style: effectiveStyle,
      cursorColor: effectiveCursorColor,
      backgroundCursorColor:
          OiTheme.maybeOf(context)?.colors.text ?? const Color(0xFF000000),
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      textCapitalization: widget.textCapitalization,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      readOnly: widget.readOnly || !widget.enabled,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      textAlign: widget.textAlign,
      autofocus: widget.autofocus,
      rendererIgnoresPointer: true,
      inputFormatters: [
        ...?widget.inputFormatters,
        if (widget.maxLength != null)
          LengthLimitingTextInputFormatter(widget.maxLength),
      ],
      scrollController: widget.scrollController,
      selectionControls: widget.selectionControls ?? _selectionControls,
      contextMenuBuilder: widget.contextMenuBuilder,
      // Required: renderedCursorColor drives the actual cursor painting.
      selectionColor: effectiveCursorColor.withValues(alpha: 0.3),
    );

    // One selection recognizer handles clicks and multi-taps together. Separate
    // double-tap recognition delays RenderEditable's single click, allowing it
    // to overwrite the caret after subsequent keyboard input.
    final interactiveEditable = _selectionGestures.buildGestureDetector(
      behavior: HitTestBehavior.translucent,
      child: editableText,
    );

    // Wrap in a Stack to overlay the placeholder text.
    var fieldWidget = interactiveEditable;
    if (widget.placeholder != null) {
      final themePlaceholderColor = OiTheme.maybeOf(
        context,
      )?.components.textInput?.placeholderColor;
      final defaultPlaceholderColor =
          (effectiveStyle.color ??
                  OiTheme.maybeOf(context)?.colors.text ??
                  const Color(0xFF000000))
              .withValues(alpha: 0.45);
      final placeholderColor = themePlaceholderColor ?? defaultPlaceholderColor;
      fieldWidget = Stack(
        fit: StackFit.passthrough,
        children: [
          if (_showPlaceholder)
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: widget.maxLines == 1
                      ? Alignment.centerLeft
                      : Alignment.topLeft,
                  child: ExcludeSemantics(
                    excluding: widget.excludePlaceholderSemantics,
                    child: Text(
                      widget.placeholder!,
                      style: effectiveStyle.copyWith(color: placeholderColor),
                      maxLines: widget.maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          interactiveEditable,
        ],
      );
    }

    // EditableText delegates enabled/focus semantics to its input wrapper.
    // Without this contract the web engine emits a disabled native text field.
    void focusInput() {
      if (!widget.enabled || !widget.focusNode.canRequestFocus) return;
      if (!widget.controller.selection.isValid) {
        widget.controller.selection = TextSelection.collapsed(
          offset: widget.controller.text.length,
        );
      }
      widget.focusNode.requestFocus();
    }

    // A temporarily disabled editor must release its input connection. Merely
    // making EditableText read-only leaves it focused and can retain a stale
    // read-only web editing configuration when it becomes enabled again.
    // ExcludeFocus also respects caller-owned FocusNode settings on re-enable.
    return ExcludeFocus(
      excluding: !widget.enabled,
      child: Semantics(
        enabled: widget.enabled,
        onTap: widget.enabled && !widget.readOnly ? focusInput : null,
        onFocus: widget.enabled ? focusInput : null,
        child: Listener(
          onPointerDown: _handlePointerDown,
          child: widget.leading == null && widget.trailing == null
              ? fieldWidget
              : Row(
                  children: [
                    if (widget.leading != null) widget.leading!,
                    Expanded(child: fieldWidget),
                    if (widget.trailing != null) widget.trailing!,
                  ],
                ),
        ),
      ),
    );
  }
}
