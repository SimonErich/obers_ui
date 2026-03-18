import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/modules/oi_file_manager.dart';
import 'package:obers_ui/src/utils/file_utils.dart';

/// A single row in the list view of a file explorer.
///
/// Displays a file/folder icon, name, size, and modified date. When
/// [searchQuery] is non-null the matching portion of the file name is
/// highlighted.
///
/// {@category Components}
class OiFileTile extends StatelessWidget {
  /// Creates an [OiFileTile].
  const OiFileTile({
    required this.file,
    this.selected = false,
    this.onTap,
    this.onDoubleTap,
    this.searchQuery,
    this.semanticsLabel,
    super.key,
  });

  /// The file or folder to display.
  final OiFileNode file;

  /// Whether this tile is currently selected.
  final bool selected;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;

  /// Called when the tile is double-tapped.
  final VoidCallback? onDoubleTap;

  /// When non-null, the matching substring in the file name is highlighted.
  final String? searchQuery;

  /// Accessibility label. Defaults to the file name.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      label: semanticsLabel ?? file.name,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.muted.withValues(alpha: 0.15)
                : null,
            border: Border(bottom: BorderSide(color: colors.borderSubtle)),
          ),
          child: Row(
            children: [
              Icon(
                file.folder
                    ? const IconData(0xe2c7, fontFamily: 'MaterialIcons')
                    : const IconData(0xe24d, fontFamily: 'MaterialIcons'),
                size: 24,
                color: file.folder ? colors.warning.base : colors.textSubtle,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: _buildName(context),
              ),
              if (file.size != null)
                Text(
                  OiFileUtils.formatSize(file.size!),
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildName(BuildContext context) {
    final colors = context.colors;
    final normalStyle = TextStyle(color: colors.text, fontSize: 14);

    if (searchQuery == null || searchQuery!.isEmpty) {
      return Text(
        file.name,
        style: normalStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final spans = _highlightSpans(
      file.name,
      searchQuery!,
      normalStyle,
      normalStyle.copyWith(
        fontWeight: FontWeight.w700,
        color: colors.primary.base,
      ),
    );

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Builds [TextSpan] children that highlight the first case-insensitive
/// occurrence of [query] within [text].
List<TextSpan> _highlightSpans(
  String text,
  String query,
  TextStyle normal,
  TextStyle highlighted,
) {
  final lowerText = text.toLowerCase();
  final lowerQuery = query.toLowerCase();
  final index = lowerText.indexOf(lowerQuery);

  if (index < 0) {
    return [TextSpan(text: text, style: normal)];
  }

  final before = text.substring(0, index);
  final match = text.substring(index, index + query.length);
  final after = text.substring(index + query.length);

  return [
    if (before.isNotEmpty) TextSpan(text: before, style: normal),
    TextSpan(text: match, style: highlighted),
    if (after.isNotEmpty) TextSpan(text: after, style: normal),
  ];
}
