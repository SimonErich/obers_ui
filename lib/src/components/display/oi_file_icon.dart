import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// The file category, which determines the color of the extension band.
///
/// {@category Components}
enum OiFileCategory {
  /// Documents such as PDF, DOC, DOCX, TXT, RTF.
  document,

  /// Spreadsheets such as XLS, XLSX, CSV.
  spreadsheet,

  /// Presentations such as PPT, PPTX, KEY.
  presentation,

  /// Images such as PNG, JPG, SVG, GIF, WEBP.
  image,

  /// Videos such as MP4, MOV, AVI, MKV.
  video,

  /// Audio files such as MP3, WAV, FLAC, AAC.
  audio,

  /// Archives such as ZIP, RAR, 7Z, TAR, GZ.
  archive,

  /// Source code such as JS, TS, PY, DART, HTML, CSS.
  code,

  /// Data files such as JSON, XML, YAML, SQL.
  data,

  /// Fallback for unrecognised file types.
  generic,
}

/// The size of an [OiFileIcon].
///
/// {@category Components}
enum OiFileIconSize {
  /// 32 × 40 dp.
  small,

  /// 48 × 60 dp.
  medium,

  /// 64 × 80 dp.
  large,
}

/// A file-type icon with a rounded page outline, dog-ear fold, and extension
/// label.
///
/// The icon renders as a document/page shape (not a circle) with rounded
/// corners, a triangular fold in the top-right corner, and a colored band
/// at the bottom displaying the file extension in bold uppercase.
///
/// The band color is determined by the [category] of the file.
///
/// ```dart
/// OiFileIcon(extension: 'PDF', category: OiFileCategory.document)
/// OiFileIcon(extension: 'XLSX', category: OiFileCategory.spreadsheet)
/// OiFileIcon(extension: 'MP4', category: OiFileCategory.video, size: OiFileIconSize.large)
/// ```
///
/// {@category Components}
class OiFileIcon extends StatelessWidget {
  /// Creates an [OiFileIcon].
  const OiFileIcon({
    required this.extension,
    this.category = OiFileCategory.generic,
    this.size = OiFileIconSize.medium,
    this.semanticLabel,
    super.key,
  });

  /// The file extension label (e.g. `'PDF'`, `'DOCX'`).
  ///
  /// Rendered in bold uppercase on the colored band at the bottom.
  final String extension;

  /// The file category, which determines the band color.
  final OiFileCategory category;

  /// The icon size.
  final OiFileIconSize size;

  /// Accessibility label announced by screen readers.
  ///
  /// When `null`, defaults to `'$extension file'`.
  final String? semanticLabel;

  // ---------------------------------------------------------------------------
  // Dimension helpers
  // ---------------------------------------------------------------------------

  ({
    double width,
    double height,
    double foldSize,
    double bandHeight,
    double fontSize,
    double radius,
  })
  _dimensions() {
    switch (size) {
      case OiFileIconSize.small:
        return (
          width: 32,
          height: 40,
          foldSize: 8,
          bandHeight: 14,
          fontSize: 8,
          radius: 3,
        );
      case OiFileIconSize.medium:
        return (
          width: 48,
          height: 60,
          foldSize: 12,
          bandHeight: 20,
          fontSize: 11,
          radius: 4,
        );
      case OiFileIconSize.large:
        return (
          width: 64,
          height: 80,
          foldSize: 16,
          bandHeight: 26,
          fontSize: 14,
          radius: 6,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Color helpers
  // ---------------------------------------------------------------------------

  Color _bandColor(OiColorScheme colors) {
    switch (category) {
      case OiFileCategory.document:
        return colors.error.base;
      case OiFileCategory.spreadsheet:
        return colors.success.base;
      case OiFileCategory.presentation:
        return colors.warning.base;
      case OiFileCategory.image:
        return const Color(0xFF7C3AED);
      case OiFileCategory.video:
        return const Color(0xFFDB2777);
      case OiFileCategory.audio:
        return colors.accent.base;
      case OiFileCategory.archive:
        return colors.warning.dark;
      case OiFileCategory.code:
        return colors.primary.base;
      case OiFileCategory.data:
        return colors.info.base;
      case OiFileCategory.generic:
        return colors.textMuted;
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dims = _dimensions();
    final band = _bandColor(colors);
    final label = semanticLabel ?? '${extension.toUpperCase()} file';

    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: SizedBox(
          width: dims.width,
          height: dims.height,
          child: CustomPaint(
            painter: _FileIconPainter(
              pageColor: colors.surface,
              borderColor: colors.border,
              foldColor: colors.surfaceHover,
              foldBorderColor: colors.border,
              bandColor: band,
              foldSize: dims.foldSize,
              bandHeight: dims.bandHeight,
              radius: dims.radius,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: dims.bandHeight,
                child: Center(
                  child: Text(
                    extension.toUpperCase(),
                    style: TextStyle(
                      fontSize: dims.fontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFFFFF),
                      height: 1,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the file icon shape: rounded page, dog-ear fold, colored band.
class _FileIconPainter extends CustomPainter {
  _FileIconPainter({
    required this.pageColor,
    required this.borderColor,
    required this.foldColor,
    required this.foldBorderColor,
    required this.bandColor,
    required this.foldSize,
    required this.bandHeight,
    required this.radius,
  });

  final Color pageColor;
  final Color borderColor;
  final Color foldColor;
  final Color foldBorderColor;
  final Color bandColor;
  final double foldSize;
  final double bandHeight;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = radius;
    final fold = foldSize;

    // ── Page outline path (with dog-ear cutout in top-right) ──────────────
    final pagePath = Path()
      // Start at top-left, after the radius arc
      ..moveTo(0, r)
      // Top-left rounded corner
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      // Top edge, stop before the fold
      ..lineTo(w - fold, 0)
      // Diagonal fold line (top-right dog-ear)
      ..lineTo(w, fold)
      // Right edge
      ..lineTo(w, h - r)
      // Bottom-right rounded corner
      ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
      // Bottom edge
      ..lineTo(r, h)
      // Bottom-left rounded corner
      ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
      // Left edge back to start
      ..close();

    // Fill the page
    final pagePaint = Paint()
      ..color = pageColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(pagePath, pagePaint);

    // ── Colored band at the bottom ────────────────────────────────────────
    final bandTop = h - bandHeight;
    final bandPath = Path()
      ..moveTo(0, bandTop)
      ..lineTo(w, bandTop)
      ..lineTo(w, h - r)
      ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
      ..lineTo(r, h)
      ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
      ..close();

    final bandPaint = Paint()
      ..color = bandColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(bandPath, bandPaint);

    // ── Page border ───────────────────────────────────────────────────────
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(pagePath, borderPaint);

    // ── Dog-ear fold triangle ─────────────────────────────────────────────
    final foldPath = Path()
      ..moveTo(w - fold, 0)
      ..lineTo(w - fold, fold)
      ..lineTo(w, fold)
      ..close();

    final foldPaint = Paint()
      ..color = foldColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(foldPath, foldPaint);

    // Fold border
    final foldBorderPaint = Paint()
      ..color = foldBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(foldPath, foldBorderPaint);
  }

  @override
  bool shouldRepaint(_FileIconPainter oldDelegate) =>
      pageColor != oldDelegate.pageColor ||
      borderColor != oldDelegate.borderColor ||
      foldColor != oldDelegate.foldColor ||
      foldBorderColor != oldDelegate.foldBorderColor ||
      bandColor != oldDelegate.bandColor ||
      foldSize != oldDelegate.foldSize ||
      bandHeight != oldDelegate.bandHeight ||
      radius != oldDelegate.radius;
}
