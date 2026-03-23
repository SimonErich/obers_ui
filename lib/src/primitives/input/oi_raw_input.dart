import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
    super.key,
  });

  /// The controller managing the text being edited.
  final TextEditingController controller;

  /// The focus node for this input.
  final FocusNode focusNode;

  /// Placeholder text shown when [controller] text is empty.
  final String? placeholder;

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

  /// Whether the field accepts user input.
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

  @override
  State<OiRawInput> createState() => _OiRawInputState();
}

class _OiRawInputState extends State<OiRawInput> {
  // Track whether the placeholder should be visible.
  bool _showPlaceholder = true;

  @override
  void initState() {
    super.initState();
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

  // ── Word selection ───────────────────────────────────────────────────────

  void _selectWordAtCursor() {
    final text = widget.controller.text;
    if (text.isEmpty) return;

    final offset = widget.controller.selection.baseOffset.clamp(0, text.length);

    // Find word boundaries around the cursor position.
    var start = offset;
    var end = offset;

    while (start > 0 && _isWordChar(text[start - 1])) {
      start--;
    }
    while (end < text.length && _isWordChar(text[end])) {
      end++;
    }

    if (start != end) {
      widget.controller.selection = TextSelection(
        baseOffset: start,
        extentOffset: end,
      );
    }
  }

  static bool _isWordChar(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 0x30 && code <= 0x39) || // 0-9
        (code >= 0x41 && code <= 0x5A) || // A-Z
        (code >= 0x61 && code <= 0x7A) || // a-z
        code == 0x5F || // _
        code >= 0x80; // non-ASCII (accented chars, etc.)
  }

  // ── Style helpers ─────────────────────────────────────────────────────────

  TextStyle _resolveStyle(BuildContext context) {
    if (widget.style != null) return widget.style!;
    final themeData = OiTheme.maybeOf(context);
    if (themeData != null) {
      return themeData.textTheme.styleFor(OiLabelVariant.body);
    }
    return const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
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
      controller: widget.controller,
      focusNode: widget.focusNode,
      style: effectiveStyle,
      cursorColor: effectiveCursorColor,
      backgroundCursorColor: const Color(0xFF000000),
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
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
      inputFormatters: widget.inputFormatters,
      scrollController: widget.scrollController,
      // Required: renderedCursorColor drives the actual cursor painting.
      selectionColor: effectiveCursorColor.withValues(alpha: 0.3),
    );

    // Wrap in a GestureDetector to support double-tap word selection.
    // Use onDoubleTapDown so EditableText still receives the gesture for
    // cursor positioning. The actual selection is applied in a post-frame
    // callback so it runs after EditableText has processed the tap.
    final interactiveEditable = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTapDown: (_) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) _selectWordAtCursor();
        });
      },
      child: editableText,
    );

    // Wrap in a Stack to overlay the placeholder text.
    var fieldWidget = interactiveEditable as Widget;
    if (widget.placeholder != null) {
      fieldWidget = Stack(
        fit: StackFit.passthrough,
        children: [
          if (_showPlaceholder)
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.placeholder!,
                    style: effectiveStyle.copyWith(
                      color: (effectiveStyle.color ?? const Color(0xFF000000))
                          .withValues(alpha: 0.45),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          editableText,
        ],
      );
    }

    // Build the Row with optional leading / trailing.
    if (widget.leading == null && widget.trailing == null) {
      return fieldWidget;
    }

    return Row(
      children: [
        if (widget.leading != null) widget.leading!,
        Expanded(child: fieldWidget),
        if (widget.trailing != null) widget.trailing!,
      ],
    );
  }
}
