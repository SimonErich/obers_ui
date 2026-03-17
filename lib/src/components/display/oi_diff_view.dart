import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// The rendering mode for an [OiDiffView].
///
/// {@category Components}
enum OiDiffMode {
  /// Added and removed lines shown in separate left/right columns.
  sideBySide,

  /// All lines interleaved in a single column with color coding.
  unified,
}

/// A single line in a diff, annotated with its change type.
///
/// {@category Components}
class OiDiffLine {
  /// Creates an [OiDiffLine].
  const OiDiffLine({
    required this.content,
    this.lineNumber,
    this.isAdded = false,
    this.isRemoved = false,
    this.isContext = false,
  });

  /// The text content of this line.
  final String content;

  /// The optional line number in the source file.
  final int? lineNumber;

  /// Whether this line was added.
  final bool isAdded;

  /// Whether this line was removed.
  final bool isRemoved;

  /// Whether this line is unchanged context.
  final bool isContext;
}

/// A diff viewer that renders a list of [OiDiffLine] entries.
///
/// Supports [OiDiffMode.unified] (all lines interleaved, default) and
/// [OiDiffMode.sideBySide] (removed on left, added on right). Added lines
/// receive a green background; removed lines receive a red background.
///
/// {@category Components}
class OiDiffView extends StatelessWidget {
  /// Creates an [OiDiffView].
  const OiDiffView({
    required this.lines,
    this.mode = OiDiffMode.unified,
    this.showLineNumbers = true,
    super.key,
  });

  /// The diff lines to display.
  final List<OiDiffLine> lines;

  /// The rendering mode.
  final OiDiffMode mode;

  /// Whether to render line numbers.
  final bool showLineNumbers;

  @override
  Widget build(BuildContext context) {
    if (mode == OiDiffMode.sideBySide) {
      return _buildSideBySide(context);
    }
    return _buildUnified(context);
  }

  Widget _buildUnified(BuildContext context) {
    final colors = context.colors;
    const monoStyle = TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: lines.map((line) {
          final bg = line.isAdded
              ? colors.success.base.withValues(alpha: 0.12)
              : line.isRemoved
                  ? colors.error.base.withValues(alpha: 0.12)
                  : null;

          final prefix = line.isAdded
              ? '+ '
              : line.isRemoved
                  ? '- '
                  : '  ';

          final textColor = line.isAdded
              ? colors.success.base
              : line.isRemoved
                  ? colors.error.base
                  : colors.text;

          Widget row = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showLineNumbers && line.lineNumber != null)
                  Text(
                    '${line.lineNumber!}'.padLeft(4),
                    style: monoStyle.copyWith(color: colors.textMuted),
                  ),
                if (showLineNumbers && line.lineNumber != null)
                  const SizedBox(width: 12),
                Text(
                  '$prefix${line.content}',
                  style: monoStyle.copyWith(color: textColor),
                ),
              ],
            ),
          );

          if (bg != null) {
            row = ColoredBox(color: bg, child: row);
          }

          return row;
        }).toList(),
      ),
    );
  }

  Widget _buildSideBySide(BuildContext context) {
    final colors = context.colors;
    const monoStyle = TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.5);

    final removed = lines.where((l) => l.isRemoved || l.isContext).toList();
    final added = lines.where((l) => l.isAdded || l.isContext).toList();
    final maxLen = removed.length > added.length ? removed.length : added.length;

    Widget column(List<OiDiffLine> colLines, {required bool isAddedSide}) {
      return Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(maxLen, (i) {
            if (i >= colLines.length) return const SizedBox(height: 22);
            final line = colLines[i];
            final bg = isAddedSide && line.isAdded
                ? colors.success.base.withValues(alpha: 0.12)
                : !isAddedSide && line.isRemoved
                    ? colors.error.base.withValues(alpha: 0.12)
                    : null;
            final textColor = isAddedSide && line.isAdded
                ? colors.success.base
                : !isAddedSide && line.isRemoved
                    ? colors.error.base
                    : colors.text;

            Widget cell = Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              child: Text(
                line.content,
                style: monoStyle.copyWith(color: textColor),
              ),
            );
            if (bg != null) cell = ColoredBox(color: bg, child: cell);
            return cell;
          }),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          column(removed, isAddedSide: false),
          Container(width: 1, color: colors.border),
          column(added, isAddedSide: true),
        ],
      ),
    );
  }
}
