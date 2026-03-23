import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A file-picker input that opens the platform file browser.
///
/// Selected file names are shown as removable chips. When [multipleFiles] is
/// `false` only one file may be selected at a time. [allowedExtensions]
/// restricts which file types are listed. When [dropZone] is `true` a dashed
/// drop-target area is rendered beneath the chip list (UI only; actual
/// drag-and-drop requires platform channels not implemented here).
///
/// {@category Components}
class OiFileInput extends StatefulWidget {
  /// Creates an [OiFileInput].
  const OiFileInput({
    this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.error,
    this.enabled = true,
    this.multipleFiles = false,
    this.allowedExtensions,
    this.dropZone = false,
    super.key,
  });

  /// The currently selected file paths.
  final List<String>? value;

  /// Called with the updated file-path list when the selection changes.
  final ValueChanged<List<String>>? onChanged;

  /// Optional label rendered above the frame.
  final String? label;

  /// Optional hint rendered below the frame.
  final String? hint;

  /// Validation error message.
  final String? error;

  /// Whether the field accepts interaction.
  final bool enabled;

  /// Whether multiple files may be selected at once.
  final bool multipleFiles;

  /// Restricts selectable files to these extensions (e.g. `['pdf', 'png']`).
  final List<String>? allowedExtensions;

  /// When true a drop-zone UI hint is shown beneath the file chips.
  final bool dropZone;

  @override
  State<OiFileInput> createState() => _OiFileInputState();
}

class _OiFileInputState extends State<OiFileInput> {
  bool _picking = false;

  Future<void> _pick() async {
    if (!widget.enabled || _picking) return;
    setState(() => _picking = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: widget.multipleFiles,
        type: widget.allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: widget.allowedExtensions,
      );
      if (result != null) {
        final paths = result.files.map((f) => f.path ?? f.name).toList();
        widget.onChanged?.call(paths);
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _removeFile(int index) {
    final updated = List<String>.from(widget.value ?? [])..removeAt(index);
    widget.onChanged?.call(updated);
  }

  Widget _buildChip(BuildContext context, String name, int index) {
    final colors = context.colors;
    final short = name.split('/').last.split(r'\').last;
    return Container(
      margin: const EdgeInsets.only(right: 6, top: 2, bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceHover,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            OiIcons.mail,
            size: 14,
            color: colors.textMuted,
          ),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              short,
              style: TextStyle(fontSize: 12, color: colors.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.enabled) ...[
            const SizedBox(width: 4),
            OiTappable(
              onTap: () => _removeFile(index),
              child: Icon(
                OiIcons.x,
                size: 14,
                color: colors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropZone(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: 64,
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Center(
        child: Text(
          'Drop files here',
          style: TextStyle(fontSize: 13, color: colors.textMuted),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final files = widget.value ?? [];

    final pickButton = OiTappable(
      onTap: widget.enabled ? _pick : null,
      enabled: widget.enabled,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors.primary.base.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.primary.base.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_picking)
              SizedBox(
                width: 14,
                height: 14,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.primary.base, width: 2),
                  ),
                ),
              )
            else
              Icon(
                OiIcons.mail,
                size: 16,
                color: colors.primary.base,
              ),
            const SizedBox(width: 6),
            Text(
              widget.multipleFiles ? 'Choose files…' : 'Choose file…',
              style: TextStyle(
                fontSize: 13,
                color: colors.primary.base,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (files.isNotEmpty)
          Wrap(
            children: files
                .asMap()
                .entries
                .map((e) => _buildChip(context, e.value, e.key))
                .toList(),
          ),
        if (files.isNotEmpty) const SizedBox(height: 6),
        pickButton,
        if (widget.dropZone) _buildDropZone(context),
      ],
    );

    return OiInputFrame(
      label: widget.label,
      hint: widget.hint,
      error: widget.error,
      enabled: widget.enabled,
      child: content,
    );
  }
}
