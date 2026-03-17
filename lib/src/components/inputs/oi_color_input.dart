import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/components/inputs/oi_slider.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart'
    show OiFloating;

/// A color-picker input showing a swatch preview and optional hex field.
///
/// Tapping the swatch opens an [OiFloating] overlay with a grid of 16 preset
/// colors plus a hex [TextField]-style entry. When [showOpacity] is `true` an
/// [OiSlider] for the alpha channel is also shown.
///
/// {@category Components}
class OiColorInput extends StatefulWidget {
  /// Creates an [OiColorInput].
  const OiColorInput({
    this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.error,
    this.enabled = true,
    this.showHex = true,
    this.showOpacity = false,
    super.key,
  });

  /// The currently selected color.
  final Color? value;

  /// Called when the user selects a color.
  final ValueChanged<Color?>? onChanged;

  /// Optional label rendered above the frame.
  final String? label;

  /// Optional hint rendered below the frame.
  final String? hint;

  /// Validation error message.
  final String? error;

  /// Whether the field accepts interaction.
  final bool enabled;

  /// Whether to show the hex text input inside the picker.
  final bool showHex;

  /// Whether to show an opacity slider inside the picker.
  final bool showOpacity;

  @override
  State<OiColorInput> createState() => _OiColorInputState();
}

// 16 common preset colors.
const List<Color> _kPresets = [
  Color(0xFFEF4444), // red
  Color(0xFFF97316), // orange
  Color(0xFFF59E0B), // amber
  Color(0xFF84CC16), // lime
  Color(0xFF22C55E), // green
  Color(0xFF14B8A6), // teal
  Color(0xFF06B6D4), // cyan
  Color(0xFF3B82F6), // blue
  Color(0xFF6366F1), // indigo
  Color(0xFF8B5CF6), // violet
  Color(0xFFEC4899), // pink
  Color(0xFF111827), // near-black
  Color(0xFF374151), // gray-700
  Color(0xFF9CA3AF), // gray-400
  Color(0xFFE5E7EB), // gray-200
  Color(0xFFFFFFFF), // white
];

String _colorToHex(Color c) {
  final r = (c.r * 255).round();
  final g = (c.g * 255).round();
  final b = (c.b * 255).round();
  return '#${r.toRadixString(16).padLeft(2, '0')}'
      '${g.toRadixString(16).padLeft(2, '0')}'
      '${b.toRadixString(16).padLeft(2, '0')}';
}

Color? _hexToColor(String hex) {
  final clean = hex.replaceAll('#', '').trim();
  if (clean.length == 6) {
    final v = int.tryParse('FF$clean', radix: 16);
    if (v != null) return Color(v);
  } else if (clean.length == 8) {
    final v = int.tryParse(clean, radix: 16);
    if (v != null) return Color(v);
  }
  return null;
}

class _OiColorInputState extends State<OiColorInput> {
  bool _open = false;
  late TextEditingController _hexCtrl;
  late FocusNode _hexFocus;
  double _opacity = 1;

  @override
  void initState() {
    super.initState();
    _hexCtrl = TextEditingController(
      text: widget.value != null ? _colorToHex(widget.value!) : '',
    );
    _hexFocus = FocusNode();
    _opacity = widget.value?.a ?? 1.0;
  }

  @override
  void didUpdateWidget(OiColorInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_hexFocus.hasFocus) {
      _hexCtrl.text =
          widget.value != null ? _colorToHex(widget.value!) : '';
      _opacity = widget.value?.a ?? 1.0;
    }
  }

  @override
  void dispose() {
    _hexCtrl.dispose();
    _hexFocus.dispose();
    super.dispose();
  }

  void _selectPreset(Color c) {
    final withOpacity = c.withValues(alpha: _opacity);
    widget.onChanged?.call(withOpacity);
    _hexCtrl.text = _colorToHex(withOpacity);
    setState(() => _open = false);
  }

  void _commitHex(String hex) {
    final c = _hexToColor(hex);
    if (c != null) {
      widget.onChanged?.call(c.withValues(alpha: _opacity));
    }
  }

  Widget _buildPicker(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.overlay,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preset grid.
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _kPresets.map((c) {
              final isSelected = widget.value != null &&
                  _colorToHex(widget.value!) == _colorToHex(c);
              return OiTappable(
                onTap: () => _selectPreset(c),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? colors.primary.base
                          : colors.border,
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (widget.showHex) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colors.border),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: EditableText(
                controller: _hexCtrl,
                focusNode: _hexFocus,
                style: TextStyle(fontSize: 13, color: colors.text),
                cursorColor: colors.primary.base,
                backgroundCursorColor: colors.border,
                onSubmitted: _commitHex,
                selectionColor: colors.primary.base.withValues(alpha: 0.2),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp('[#0-9a-fA-F]'),
                  ),
                  LengthLimitingTextInputFormatter(9),
                ],
              ),
            ),
          ],
          if (widget.showOpacity) ...[
            const SizedBox(height: 12),
            Text(
              'Opacity',
              style: TextStyle(fontSize: 12, color: colors.textMuted),
            ),
            const SizedBox(height: 4),
            OiSlider(
              value: _opacity,
              min: 0,
              max: 1,
              onChanged: (v) {
                setState(() => _opacity = v);
                if (widget.value != null) {
                  widget.onChanged
                      ?.call(widget.value!.withValues(alpha: v));
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayColor = widget.value ?? const Color(0x00000000);

    final swatch = GestureDetector(
      onTap: widget.enabled ? () => setState(() => _open = !_open) : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: displayColor,
          shape: BoxShape.circle,
          border: Border.all(color: colors.border),
        ),
      ),
    );

    final hexText = widget.value != null
        ? _colorToHex(widget.value!)
        : '—';

    final anchor = OiInputFrame(
      label: widget.label,
      hint: widget.hint,
      error: widget.error,
      focused: _open,
      enabled: widget.enabled,
      leading: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: swatch,
      ),
      child: Text(
        hexText,
        style: TextStyle(fontSize: 13, color: colors.text),
      ),
    );

    return OiFloating(
      visible: _open,
      anchor: anchor,
      child: UnconstrainedBox(
        alignment: Alignment.topLeft,
        child: _buildPicker(context),
      ),
    );
  }
}
