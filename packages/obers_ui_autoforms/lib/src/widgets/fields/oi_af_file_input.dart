import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiFileInput;
import 'package:obers_ui_autoforms/src/definitions/oi_af_field_definition.dart'
    show OiAfFileValue;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form file input that wraps [OiFileInput].
///
/// The controller stores files as [List]<[OiAfFileValue]> while the underlying
/// [OiFileInput] works with [List]<[String]> (file paths). This widget bridges
/// the two representations automatically.
class OiAfFileInput<TField extends Enum> extends StatefulWidget {
  const OiAfFileInput({
    required this.field,
    this.label,
    this.hint,
    this.multipleFiles = false,
    this.allowedExtensions,
    this.dropZone = false,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final String? label;
  final String? hint;
  final bool multipleFiles;
  final List<String>? allowedExtensions;
  final bool dropZone;
  final bool enabled;

  @override
  State<OiAfFileInput<TField>> createState() => _OiAfFileInputState<TField>();
}

class _OiAfFileInputState<TField extends Enum>
    extends State<OiAfFileInput<TField>>
    with
        OiAfFieldBinderMixin<
          OiAfFileInput<TField>,
          TField,
          List<OiAfFileValue>
        > {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.file;

  @override
  String? get widgetLabel => widget.label;

  @override
  bool get widgetEnabled => widget.enabled;

  void _handleChanged(List<String> paths) {
    final files = paths
        .map((path) => OiAfFileValue(name: path.split('/').last, path: path))
        .toList();
    onValueChanged(files);
  }

  @override
  Widget build(BuildContext context) {
    if (!fieldCtrl.isVisible) return const SizedBox.shrink();

    final paths = typedValue?.map((f) => f.path).toList();

    return OiFileInput(
      value: paths,
      onChanged: effectiveEnabled ? _handleChanged : null,
      label: widget.label,
      hint: widget.hint,
      error: fieldCtrl.primaryError,
      enabled: effectiveEnabled,
      multipleFiles: widget.multipleFiles,
      allowedExtensions: widget.allowedExtensions,
      dropZone: widget.dropZone,
    );
  }
}
