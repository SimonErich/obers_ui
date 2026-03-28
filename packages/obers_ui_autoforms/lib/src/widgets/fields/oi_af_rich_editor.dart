import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart'
    show OiRichContent, OiRichEditor, OiRichEditorController, OiToolbarMode;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form rich text editor that wraps [OiRichEditor].
///
/// The field value is stored as a serialized string representation
/// of the rich content.
class OiAfRichEditor<TField extends Enum> extends StatefulWidget {
  const OiAfRichEditor({
    required this.field,
    required this.label,
    this.toolbar = OiToolbarMode.fixed,
    this.placeholder,
    this.readOnly = false,
    this.autoFocus = false,
    this.minHeight,
    this.maxHeight,
    this.enableCodeBlocks = true,
    this.enableTables = false,
    this.enableFileEmbed = false,
    this.showWordCount = false,
    this.enableDragReorder = false,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final String label;
  final OiToolbarMode toolbar;
  final String? placeholder;
  final bool readOnly;
  final bool autoFocus;
  final double? minHeight;
  final double? maxHeight;
  final bool enableCodeBlocks;
  final bool enableTables;
  final bool enableFileEmbed;
  final bool showWordCount;
  final bool enableDragReorder;
  final bool enabled;

  @override
  State<OiAfRichEditor<TField>> createState() => _OiAfRichEditorState<TField>();
}

class _OiAfRichEditorState<TField extends Enum>
    extends State<OiAfRichEditor<TField>>
    with OiAfFieldBinderMixin<OiAfRichEditor<TField>, TField, String> {
  late OiRichEditorController _editorController;

  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.richText;

  @override
  String? get widgetLabel => widget.label;

  @override
  bool get widgetEnabled => widget.enabled;

  @override
  void initState() {
    super.initState();
    _editorController = OiRichEditorController();
  }

  @override
  void onFieldControllerChanged() {
    // Sync from field controller to editor if value changed externally.
    final fieldValue = typedValue;
    if (fieldValue != null &&
        fieldValue != _editorController.content.toPlainText()) {
      _editorController.content = OiRichContent.fromPlainText(fieldValue);
    }
  }

  void _handleContentChanged(OiRichContent content) {
    final text = content.toPlainText();
    fieldCtrl.setValue(text);
  }

  @override
  void dispose() {
    _editorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!fieldCtrl.isVisible) return const SizedBox.shrink();

    return OiRichEditor(
      controller: _editorController,
      label: widget.label,
      toolbar: widget.toolbar,
      placeholder: widget.placeholder,
      readOnly: widget.readOnly || !effectiveEnabled,
      autoFocus: widget.autoFocus,
      minHeight: widget.minHeight,
      maxHeight: widget.maxHeight,
      enableCodeBlocks: widget.enableCodeBlocks,
      enableTables: widget.enableTables,
      enableFileEmbed: widget.enableFileEmbed,
      showWordCount: widget.showWordCount,
      enableDragReorder: widget.enableDragReorder,
      onChange: effectiveEnabled ? _handleContentChanged : null,
    );
  }
}
