// Internal widget — no need for public doc comments on private class
// ignore_for_file: public_member_api_docs

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';

/// Internal OTP digit input rendered as a row of individual boxes.
///
/// Used by `OiTextInput.otp()` — not exported publicly.
class OiOtpInput extends StatefulWidget {
  const OiOtpInput({
    required this.length,
    this.onCompleted,
    this.onChanged,
    this.obscure = false,
    this.autofocus = true,
    this.enabled = true,
    this.error,
    super.key,
  });

  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool obscure;
  final bool autofocus;
  final bool enabled;
  final String? error;

  @override
  State<OiOtpInput> createState() => _OiOtpInputState();
}

class _OiOtpInputState extends State<OiOtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  bool _completedFired = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    for (var i = 0; i < widget.length; i++) {
      _controllers[i].addListener(() => _onControllerChanged(i));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _currentValue =>
      _controllers.map((c) => c.text).join();

  void _onControllerChanged(int index) {
    final text = _controllers[index].text;

    // Handle paste: if multi-character text was entered, distribute
    if (text.length > 1) {
      _distributePaste(text, index);
      return;
    }

    // Auto-advance on digit entry
    if (text.length == 1 && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    _notifyChanged();
  }

  void _distributePaste(String text, int startIndex) {
    // Remove non-digits
    final digits = text.replaceAll(RegExp('[^0-9]'), '');
    if (digits.isEmpty) {
      _controllers[startIndex].text = '';
      return;
    }

    for (var i = 0; i < digits.length && (startIndex + i) < widget.length; i++) {
      _controllers[startIndex + i].text = digits[i];
    }

    // Move focus to the next empty box or the last filled one
    final nextEmpty = _controllers.indexWhere(
      (c) => c.text.isEmpty,
    );
    if (nextEmpty >= 0) {
      _focusNodes[nextEmpty].requestFocus();
    } else {
      _focusNodes[widget.length - 1].requestFocus();
    }

    _notifyChanged();

    // Announce paste for accessibility
    // ignore: deprecated_member_use
    SemanticsService.announce('Code pasted', TextDirection.ltr);
  }

  void _notifyChanged() {
    final value = _currentValue;
    widget.onChanged?.call(value);

    if (value.length == widget.length && !_completedFired) {
      _completedFired = true;
      widget.onCompleted?.call(value);
    } else if (value.length < widget.length) {
      _completedFired = false;
    }
  }

  void _handleKeyEvent(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return;

    // Backspace on empty box: move to previous and clear it
    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      _notifyChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dec = context.decoration;
    final otpTheme = context.components.textInput?.otp;
    final hasError = widget.error != null && widget.error!.isNotEmpty;

    final boxWidth = otpTheme?.boxWidth ?? 48.0;
    final boxHeight = otpTheme?.boxHeight ?? 56.0;
    final gap = otpTheme?.gap ?? 8.0;
    final boxRadius = otpTheme?.boxRadius ?? BorderRadius.circular(8);

    Widget buildBox(int index) {
      final isFocused = _focusNodes[index].hasFocus;
      final hasFill = _controllers[index].text.isNotEmpty;

      Color bgColor;
      if (!widget.enabled) {
        bgColor = colors.surfaceSubtle;
      } else if (isFocused) {
        bgColor = otpTheme?.focusedBoxColor ?? colors.surface;
      } else if (hasFill) {
        bgColor = otpTheme?.filledBoxColor ?? colors.surface;
      } else {
        bgColor = otpTheme?.emptyBoxColor ?? colors.surface;
      }

      OiBorderStyle border;
      if (hasError) {
        border = dec.errorBorder;
      } else if (isFocused) {
        border = dec.focusBorder;
      } else {
        border = dec.defaultBorder;
      }

      return Semantics(
        label: 'Digit ${index + 1} of ${widget.length}',
        textField: true,
        child: SizedBox(
          width: boxWidth,
          height: boxHeight,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _handleKeyEvent(index, event),
            child: OiSurface(
              color: bgColor,
              border: border,
              borderRadius: boxRadius,
              child: Center(
                child: EditableText(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  style: otpTheme?.digitStyle ??
                      TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                  cursorColor: colors.primary.base,
                  backgroundCursorColor: colors.surfaceSubtle,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  obscureText: widget.obscure,
                  autofocus: widget.autofocus && index == 0,
                  readOnly: !widget.enabled,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget content = Opacity(
      opacity: widget.enabled ? 1.0 : 0.6,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            buildBox(i),
          ],
        ],
      ),
    );

    if (hasError) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          content,
          const SizedBox(height: 4),
          Semantics(
            liveRegion: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  OiIcons.circleAlert,
                  size: 14,
                  color: colors.error.base,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    widget.error!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.error.base,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return content;
  }
}
