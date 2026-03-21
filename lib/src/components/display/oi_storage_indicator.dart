import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_spacing_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/utils/file_utils.dart';

/// A category in a storage breakdown for [OiStorageIndicator].
///
/// {@category Components}
@immutable
class OiStorageCategory {
  /// Creates an [OiStorageCategory].
  const OiStorageCategory({
    required this.label,
    required this.bytes,
    required this.color,
  });

  /// Display label (e.g. "Documents").
  final String label;

  /// Bytes used by this category.
  final int bytes;

  /// Color for this category's segment.
  final Color color;
}

/// A compact storage usage indicator showing used/total space with a progress
/// bar and optional breakdown by category.
///
/// ```dart
/// OiStorageIndicator(
///   usedBytes: 6500000000,
///   totalBytes: 10000000000,
/// )
/// ```
///
/// {@category Components}
class OiStorageIndicator extends StatelessWidget {
  /// Creates an [OiStorageIndicator].
  const OiStorageIndicator({
    required this.usedBytes,
    required this.totalBytes,
    this.breakdown,
    this.compact = false,
    this.semanticsLabel,
    super.key,
  });

  /// Bytes currently used.
  final int usedBytes;

  /// Total available bytes.
  final int totalBytes;

  /// Optional breakdown of storage by category.
  final List<OiStorageCategory>? breakdown;

  /// When true, renders a compact single-line layout.
  final bool compact;

  /// Accessibility label.
  final String? semanticsLabel;

  double get _percentage =>
      totalBytes > 0 ? (usedBytes / totalBytes).clamp(0.0, 1.0) : 0.0;

  Color _barColor(OiColorScheme colors) {
    final pct = _percentage * 100;
    if (pct > 90) return colors.error.base;
    if (pct > 70) return colors.warning.base;
    return colors.success.base;
  }

  /// Returns a text status label so color is never the sole indicator
  /// of storage urgency (REQ-0025).
  String _statusLabel() {
    final pct = _percentage * 100;
    if (pct > 90) return 'Critical';
    if (pct > 70) return 'Warning';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final usedLabel = OiFileUtils.formatSize(usedBytes);
    final totalLabel = OiFileUtils.formatSize(totalBytes);
    final label = semanticsLabel ?? '$usedLabel of $totalLabel used';

    return Semantics(
      label: label,
      value: '${(_percentage * 100).round()}%',
      child: ExcludeSemantics(
        child: compact
            ? _buildCompact(colors, usedLabel, totalLabel)
            : _buildFull(colors, spacing, usedLabel, totalLabel),
      ),
    );
  }

  Widget _buildCompact(OiColorScheme colors, String used, String total) {
    final status = _statusLabel();
    return Row(
      children: [
        Expanded(child: _buildProgressBar(colors, 4)),
        const SizedBox(width: 8),
        Text(
          '$used / $total',
          style: TextStyle(fontSize: 11, color: colors.textMuted),
        ),
        if (status.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _barColor(colors),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFull(
    OiColorScheme colors,
    OiSpacingScale spacing,
    String used,
    String total,
  ) {
    final status = _statusLabel();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Storage',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.text,
          ),
        ),
        SizedBox(height: spacing.xs),
        _buildProgressBar(colors, 6),
        SizedBox(height: spacing.xs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$used of $total',
              style: TextStyle(fontSize: 11, color: colors.textMuted),
            ),
            if (status.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _barColor(colors),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar(OiColorScheme colors, double height) {
    if (breakdown != null && breakdown!.isNotEmpty) {
      return _buildSegmentedBar(colors, height);
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceHover,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _percentage,
        child: Container(
          decoration: BoxDecoration(
            color: _barColor(colors),
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedBar(OiColorScheme colors, double height) {
    final total = totalBytes > 0 ? totalBytes : 1;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceHover,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          for (final category in breakdown!)
            Flexible(
              flex: ((category.bytes / total) * 1000).round().clamp(1, 1000),
              child: Container(color: category.color),
            ),
          // Remaining empty space
          Flexible(
            flex:
                (((totalBytes - usedBytes).clamp(0, totalBytes) / total) * 1000)
                    .round()
                    .clamp(0, 1000),
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
