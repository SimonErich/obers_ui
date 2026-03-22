import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ---------------------------------------------------------------------------
// Supporting types
// ---------------------------------------------------------------------------

/// The type of a metadata value in an [OiMetadataEditor].
enum OiMetadataType {
  /// Free-form text value.
  text,

  /// Numeric value.
  number,

  /// Date value.
  date,

  /// Boolean toggle value.
  boolean,

  /// Value chosen from a fixed set of options.
  select,
}

/// A single key-value field in an [OiMetadataEditor].
///
/// Each field has a [key] (label), a [value], and a [type] that determines
/// which input widget is rendered for editing.
@immutable
class OiMetadataField {
  /// Creates an [OiMetadataField].
  const OiMetadataField({
    required this.key,
    required this.value,
    this.type = OiMetadataType.text,
  });

  /// The label / key of this metadata entry.
  final String key;

  /// The current value of this metadata entry.
  final dynamic value;

  /// The type of value, which determines the input widget used for editing.
  final OiMetadataType type;
}

// ---------------------------------------------------------------------------
// OiMetadataEditor
// ---------------------------------------------------------------------------

/// A key-value metadata editor with add/remove/edit fields.
///
/// Renders a list of key-value pairs with type-aware inputs
/// for each value. Supports adding new fields and removing existing ones.
///
/// {@category Modules}
class OiMetadataEditor extends StatefulWidget {
  /// Creates an [OiMetadataEditor].
  const OiMetadataEditor({
    required this.fields,
    required this.onChange,
    required this.label,
    super.key,
    this.enabled = true,
    this.allowAdd = true,
    this.allowRemove = true,
    this.availableKeys,
  });

  /// The current list of metadata fields.
  final List<OiMetadataField> fields;

  /// Called whenever the field list changes (add, remove, or edit).
  final ValueChanged<List<OiMetadataField>> onChange;

  /// Accessible label for the editor.
  final String label;

  /// Whether editing is enabled.
  final bool enabled;

  /// Whether the user may add new fields.
  final bool allowAdd;

  /// Whether the user may remove existing fields.
  final bool allowRemove;

  /// When provided, restricts new-field keys to this set of values.
  final List<String>? availableKeys;

  @override
  State<OiMetadataEditor> createState() => _OiMetadataEditorState();
}

class _OiMetadataEditorState extends State<OiMetadataEditor> {
  void _updateField(int index, OiMetadataField updated) {
    final fields = List<OiMetadataField>.from(widget.fields);
    fields[index] = updated;
    widget.onChange(fields);
  }

  void _removeField(int index) {
    final fields = List<OiMetadataField>.from(widget.fields)..removeAt(index);
    widget.onChange(fields);
  }

  void _addField() {
    final fields = List<OiMetadataField>.from(widget.fields);
    final existingKeys = fields.map((f) => f.key).toSet();

    String newKey;
    if (widget.availableKeys != null && widget.availableKeys!.isNotEmpty) {
      final available = widget.availableKeys!.where(
        (k) => !existingKeys.contains(k),
      );
      if (available.isEmpty) return;
      newKey = available.first;
    } else {
      var counter = fields.length + 1;
      newKey = 'Key $counter';
      while (existingKeys.contains(newKey)) {
        counter++;
        newKey = 'Key $counter';
      }
    }

    fields.add(OiMetadataField(key: newKey, value: ''));
    widget.onChange(fields);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      container: true,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.fields.length; i++)
            _buildFieldRow(context, i, widget.fields[i]),
          if (widget.allowAdd && widget.enabled) _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildFieldRow(
    BuildContext context,
    int index,
    OiMetadataField field,
  ) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                field.key,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _buildValueInput(context, index, field)),
          if (widget.allowRemove && widget.enabled) ...[
            const SizedBox(width: 8),
            OiTappable(
              onTap: () => _removeField(index),
              semanticLabel: 'Remove ${field.key}',
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(
                  OiIcons.xMark,
                  size: 18,
                  color: colors.error.base,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildValueInput(
    BuildContext context,
    int index,
    OiMetadataField field,
  ) {
    final colors = context.colors;

    switch (field.type) {
      case OiMetadataType.text:
        return OiTextInput(
          controller: TextEditingController(text: '${field.value}'),
          enabled: widget.enabled,
          onChanged: (v) => _updateField(
            index,
            OiMetadataField(key: field.key, value: v, type: field.type),
          ),
        );

      case OiMetadataType.number:
        return OiTextInput(
          controller: TextEditingController(text: '${field.value}'),
          enabled: widget.enabled,
          keyboardType: TextInputType.number,
          onChanged: (v) {
            final parsed = num.tryParse(v);
            _updateField(
              index,
              OiMetadataField(
                key: field.key,
                value: parsed ?? v,
                type: field.type,
              ),
            );
          },
        );

      case OiMetadataType.boolean:
        final boolValue = field.value == true;
        return OiTappable(
          onTap: widget.enabled
              ? () => _updateField(
                  index,
                  OiMetadataField(
                    key: field.key,
                    value: !boolValue,
                    type: field.type,
                  ),
                )
              : null,
          semanticLabel: '${field.key}: ${boolValue ? "on" : "off"}',
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: boolValue ? colors.primary.base : colors.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: boolValue
                          ? colors.primary.base
                          : colors.borderSubtle,
                    ),
                  ),
                  child: boolValue
                      ? Icon(
                          OiIcons.check,
                          size: 14,
                          color: colors.primary.foreground,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  boolValue ? 'Yes' : 'No',
                  style: TextStyle(fontSize: 13, color: colors.text),
                ),
              ],
            ),
          ),
        );

      case OiMetadataType.date:
        return OiTextInput(
          controller: TextEditingController(text: '${field.value}'),
          enabled: widget.enabled,
          placeholder: 'YYYY-MM-DD',
          onChanged: (v) => _updateField(
            index,
            OiMetadataField(key: field.key, value: v, type: field.type),
          ),
        );

      case OiMetadataType.select:
        return OiTextInput(
          controller: TextEditingController(text: '${field.value}'),
          enabled: widget.enabled,
          onChanged: (v) => _updateField(
            index,
            OiMetadataField(key: field.key, value: v, type: field.type),
          ),
        );
    }
  }

  Widget _buildAddButton(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OiTappable(
        onTap: _addField,
        semanticLabel: 'Add field',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                OiIcons.plus,
                size: 16,
                color: colors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                'Add field',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
