import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// Supported export formats for [OiExportButton].
///
/// {@category Components}
enum OiExportFormat {
  /// Comma-separated values.
  csv,

  /// Microsoft Excel spreadsheet.
  xlsx,

  /// JavaScript Object Notation.
  json,

  /// Portable Document Format.
  pdf;

  /// A human-readable label for this format.
  String get label {
    switch (this) {
      case OiExportFormat.csv:
        return 'CSV';
      case OiExportFormat.xlsx:
        return 'Excel (XLSX)';
      case OiExportFormat.json:
        return 'JSON';
      case OiExportFormat.pdf:
        return 'PDF';
    }
  }
}

/// A button that triggers data export in various formats.
///
/// When a single format is configured, renders as a direct-action
/// [OiButton.outline]. When multiple formats are available, renders as
/// [OiButton.split] with a dropdown for format selection.
///
/// ```dart
/// OiExportButton(
///   label: 'Export',
///   onExport: (format) async => downloadFile(format),
///   formats: [OiExportFormat.csv, OiExportFormat.xlsx],
/// )
/// ```
///
/// {@category Components}
class OiExportButton extends StatefulWidget {
  /// Creates an [OiExportButton].
  const OiExportButton({
    required this.label,
    required this.onExport,
    this.formats = const [OiExportFormat.csv],
    this.loading = false,
    super.key,
  }) : assert(formats.length > 0, 'formats must not be empty');

  /// The button label.
  final String label;

  /// Async callback invoked with the selected [OiExportFormat].
  final Future<void> Function(OiExportFormat format) onExport;

  /// The available export formats. Defaults to `[OiExportFormat.csv]`.
  final List<OiExportFormat> formats;

  /// Whether the button is currently in a loading state.
  final bool loading;

  @override
  State<OiExportButton> createState() => _OiExportButtonState();
}

class _OiExportButtonState extends State<OiExportButton> {
  bool _loading = false;

  bool get _isLoading => _loading || widget.loading;

  Future<void> _handleExport(OiExportFormat format) async {
    if (_isLoading) return;
    setState(() => _loading = true);
    try {
      await widget.onExport(format);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _buildFormatList(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 160),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: context.radius.md,
            border: Border.all(color: colors.border),
            boxShadow: context.shadows.sm,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final format in widget.formats)
                  GestureDetector(
                    onTap: () => _handleExport(format),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.sm,
                        vertical: spacing.xs,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OiIcon.decorative(
                            icon: _formatIcon(format),
                            size: 16,
                            color: colors.text,
                          ),
                          SizedBox(width: spacing.sm),
                          OiLabel.body(format.label),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _formatIcon(OiExportFormat format) {
    switch (format) {
      case OiExportFormat.csv:
        return OiIcons.table; // table_chart
      case OiExportFormat.xlsx:
        return OiIcons.layoutGrid; // grid_on
      case OiExportFormat.json:
        return OiIcons.code; // code
      case OiExportFormat.pdf:
        return OiIcons.fileText; // picture_as_pdf
    }
  }

  Widget _buildSingleButton(BuildContext context) {
    final format = widget.formats.first;
    return OiButton.outline(
      label: widget.label,
      icon: OiIcons.download, // file_download
      onTap: _isLoading ? null : () => _handleExport(format),
      loading: _isLoading,
      semanticLabel: '${widget.label} as ${format.label}',
    );
  }

  Widget _buildSplitButton(BuildContext context) {
    final primaryFormat = widget.formats.first;
    return Semantics(
      label: '${widget.label} format options',
      child: OiButton.split(
        label: widget.label,
        variant: OiButtonVariant.outline,
        onTap: () => _handleExport(primaryFormat),
        enabled: !_isLoading,
        dropdown: _buildFormatList(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.formats.length == 1) {
      return _buildSingleButton(context);
    }
    return _buildSplitButton(context);
  }
}
