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
  late List<OiMetadataField> _fields;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _fields = List<OiMetadataField>.from(widget.fields);
    _syncControllers();
  }

  @override
  void didUpdateWidget(OiMetadataEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fields != oldWidget.fields) {
      _fields = List<OiMetadataField>.from(widget.fields);
      _syncControllers();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncControllers() {
    // Remove controllers for indices that no longer exist.
    _controllers.keys
        .where((i) => i >= _fields.length)
        .toList()
        .forEach((i) {
      _controllers.remove(i)?.dispose();
    });

    // Create or update controllers for current fields.
    for (var i = 0; i < _fields.length; i++) {
      final field = _fields[i];
      if (field.type == OiMetadataType.boolean) continue;
      final text = '${field.value}';
      if (_controllers.containsKey(i)) {
        if (_controllers[i]!.text != text) {
          _controllers[i]!.text = text;
        }
      } else {
        _controllers[i] = TextEditingController(text: text);
      }
    }
  }

  void _emitChange() {
    widget.onChange(List<OiMetadataField>.unmodifiable(_fields));
  }

  void _updateField(int index, OiMetadataField updated) {
    setState(() {
      _fields[index] = updated;
    });
    _emitChange();
  }

  void _removeField(int index) {
    setState(() {
      _fields.removeAt(index);
      // Dispose removed controller and rebuild the map with shifted indices.
      final old = Map<int, TextEditingController>.from(_controllers);
      _controllers.clear();
      for (final entry in old.entries) {
        if (entry.key == index) {
          entry.value.dispose();
        } else if (entry.key > index) {
          _controllers[entry.key - 1] = entry.value;
        } else {
          _controllers[entry.key] = entry.value;
        }
      }
    });
    _emitChange();
  }

  void _addField() {
    final existingKeys = _fields.map((f) => f.key).toSet();

    String newKey;
    if (widget.availableKeys != null && widget.availableKeys!.isNotEmpty) {
      final available = widget.availableKeys!.where(
        (k) => !existingKeys.contains(k),
      );
      if (available.isEmpty) return;
      newKey = available.first;
    } else {
      var counter = _fields.length + 1;
      newKey = 'Key $counter';
      while (existingKeys.contains(newKey)) {
        counter++;
        newKey = 'Key $counter';
      }
    }

    setState(() {
      _fields.add(OiMetadataField(key: newKey, value: ''));
      _syncControllers();
    });
    _emitChange();
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
          for (var i = 0; i < _fields.length; i++)
            _buildFieldRow(context, i, _fields[i]),
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
            _RemoveButton(
              onTap: () => _removeField(index),
              label: 'Remove ${field.key}',
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
          controller: _controllers[index],
          enabled: widget.enabled,
          onChanged: (v) => _updateField(
            index,
            OiMetadataField(key: field.key, value: v, type: field.type),
          ),
        );

      case OiMetadataType.number:
        return OiTextInput(
          controller: _controllers[index],
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
          controller: _controllers[index],
          enabled: widget.enabled,
          placeholder: 'YYYY-MM-DD',
          onChanged: (v) => _updateField(
            index,
            OiMetadataField(key: field.key, value: v, type: field.type),
          ),
        );

      case OiMetadataType.select:
        return OiTextInput(
          controller: _controllers[index],
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
      child: Center(
        child: OiTappable(
          onTap: _addField,
          semanticLabel: 'Add field',
          clipBorderRadius: BorderRadius.circular(6),
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
      ),
    );
  }
}

class _RemoveButton extends StatefulWidget {
  const _RemoveButton({required this.onTap, required this.label});

  final VoidCallback onTap;
  final String label;

  @override
  State<_RemoveButton> createState() => _RemoveButtonState();
}

class _RemoveButtonState extends State<_RemoveButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: widget.label,
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: AnimatedScale(
              scale: _hovered ? 1.3 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              child: Icon(
                OiIcons.x,
                size: 18,
                color: colors.error.base,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
