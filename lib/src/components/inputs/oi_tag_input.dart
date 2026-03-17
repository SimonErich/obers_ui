import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A tag/chip input that lets users add and remove string tags.
///
/// Existing [tags] are shown as removable chips inside the frame. A text
/// field at the end of the chip list lets users type new tags and confirm them
/// by pressing Enter or typing a comma. [maxTags] optionally limits how many
/// tags may be entered.
///
/// {@category Components}
class OiTagInput extends StatefulWidget {
  /// Creates an [OiTagInput].
  const OiTagInput({
    required this.tags,
    this.onChanged,
    this.label,
    this.hint,
    this.error,
    this.placeholder,
    this.enabled = true,
    this.maxTags,
    super.key,
  });

  /// The current list of tags.
  final List<String> tags;

  /// Called with the updated list when a tag is added or removed.
  final ValueChanged<List<String>>? onChanged;

  /// Optional label rendered above the frame.
  final String? label;

  /// Optional hint rendered below the frame.
  final String? hint;

  /// Validation error message.
  final String? error;

  /// Placeholder shown inside the text field when no text has been typed.
  final String? placeholder;

  /// Whether the field accepts interaction.
  final bool enabled;

  /// Maximum number of tags allowed. Unlimited when null.
  final int? maxTags;

  @override
  State<OiTagInput> createState() => _OiTagInputState();
}

class _OiTagInputState extends State<OiTagInput> {
  late TextEditingController _ctrl;
  late FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    final focused = _focusNode.hasFocus;
    if (focused != _focused) setState(() => _focused = focused);
  }

  bool get _canAdd =>
      widget.maxTags == null || widget.tags.length < widget.maxTags!;

  void _addTag(String raw) {
    final parts = raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);
    final newTags = List<String>.from(widget.tags);
    for (final tag in parts) {
      if (!newTags.contains(tag) && _canAdd) {
        newTags.add(tag);
      }
    }
    if (newTags.length != widget.tags.length) {
      widget.onChanged?.call(newTags);
    }
    _ctrl.clear();
  }

  void _removeTag(int index) {
    final newTags = List<String>.from(widget.tags)..removeAt(index);
    widget.onChanged?.call(newTags);
  }

  Widget _buildChip(BuildContext context, String tag, int index) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(right: 6, top: 2, bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary.base.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              color: colors.primary.base,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (widget.enabled) ...[
            const SizedBox(width: 4),
            OiTappable(
              onTap: () => _removeTag(index),
              child: Icon(
                const IconData(0xe5cd, fontFamily: 'MaterialIcons'),
                size: 14,
                color: colors.primary.base,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = _canAdd;
    final input = OiRawInputInline(
      controller: _ctrl,
      focusNode: _focusNode,
      placeholder: canAdd ? (widget.placeholder ?? 'Add tag…') : '',
      enabled: widget.enabled && canAdd,
      onSubmitted: _addTag,
      inputFormatters: [_CommaFormatter(onComma: _addTag)],
    );

    final chips = widget.tags.asMap().entries.map(
      (e) => _buildChip(context, e.value, e.key),
    );

    final content = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...chips,
        SizedBox(width: 80, child: input),
      ],
    );

    return OiInputFrame(
      label: widget.label,
      hint: widget.hint,
      error: widget.error,
      focused: _focused,
      enabled: widget.enabled,
      child: content,
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// A minimal inline raw-input that does not add leading/trailing Row wrappers.
class OiRawInputInline extends StatelessWidget {
  /// Creates an [OiRawInputInline].
  const OiRawInputInline({
    required this.controller,
    required this.focusNode,
    this.placeholder,
    this.enabled = true,
    this.onSubmitted,
    this.inputFormatters,
    super.key,
  });

  /// The controller managing the editable text.
  final TextEditingController controller;

  /// The focus node for this field.
  final FocusNode focusNode;

  /// Placeholder text shown when the field is empty.
  final String? placeholder;

  /// Whether the field accepts input.
  final bool enabled;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// Optional list of input formatters applied per keystroke.
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return EditableText(
      controller: controller,
      focusNode: focusNode,
      style: const TextStyle(fontSize: 13),
      cursorColor: const Color(0xFF2563EB),
      backgroundCursorColor: const Color(0xFF000000),
      onSubmitted: onSubmitted,
      readOnly: !enabled,
      inputFormatters: inputFormatters,
      textInputAction: TextInputAction.done,
      selectionColor: const Color(0x332563EB),
    );
  }
}

/// Intercepts comma characters and fires [onComma] with the accumulated text.
class _CommaFormatter extends TextInputFormatter {
  _CommaFormatter({required this.onComma});
  final ValueChanged<String> onComma;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.contains(',')) {
      final parts = newValue.text.split(',');
      final last = parts.last;
      final toAdd = parts.sublist(0, parts.length - 1).join(',');
      if (toAdd.isNotEmpty) {
        // Fire after the current frame to avoid re-entrant formatting.
        Future.microtask(() => onComma(toAdd));
      }
      return newValue.copyWith(
        text: last,
        selection: TextSelection.collapsed(offset: last.length),
      );
    }
    return newValue;
  }
}
