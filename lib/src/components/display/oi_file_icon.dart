import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/utils/file_utils.dart';

/// The file category, which determines the color of the extension band.
///
/// {@category Components}
enum OiFileCategory {
  /// Documents such as PDF, DOC, DOCX, RTF.
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

  /// Plain text files such as TXT, MD, LOG.
  text,

  /// Executable files such as EXE, APP, SH, BAT.
  executable,

  /// Font files such as TTF, OTF, WOFF.
  font,

  /// 3D model files such as OBJ, FBX, GLTF.
  threeD,

  /// Fallback for unrecognised file types.
  generic,
}

/// The size of an [OiFileIcon].
///
/// {@category Components}
enum OiFileIconSize {
  /// 16 × 20 dp.
  xs,

  /// 24 × 30 dp.
  sm,

  /// 32 × 40 dp.
  md,

  /// 48 × 60 dp.
  lg,

  /// 64 × 80 dp.
  xl,
}

/// A file-type icon with a rounded page outline, dog-ear fold, and extension
/// label.
///
/// The icon renders as a document/page shape (not a circle) with rounded
/// corners, a triangular fold in the top-right corner, and a colored band
/// at the bottom displaying the file extension in bold uppercase.
///
/// The band color is determined automatically from the file extension, or can
/// be overridden with [colorOverride].
///
/// ```dart
/// OiFileIcon(fileName: 'report.pdf')
/// OiFileIcon(fileName: 'data.xlsx', size: OiFileIconSize.lg)
/// OiFileIcon(fileName: 'photo.png', colorOverride: Color(0xFF00BCD4))
/// ```
///
/// {@category Components}
class OiFileIcon extends StatelessWidget {
  /// Creates an [OiFileIcon] from a file name.
  ///
  /// The extension and category are auto-detected from [fileName].
  /// When [mimeType] is provided it takes precedence over the extension
  /// for category detection when the extension is ambiguous or unknown.
  const OiFileIcon({
    required this.fileName,
    this.mimeType,
    this.size = OiFileIconSize.md,
    this.colorOverride,
    this.semanticsLabel,
    super.key,
  });

  /// The file name (e.g. `'report.pdf'`, `'photo.PNG'`).
  ///
  /// The extension is extracted and used to determine the category and
  /// the label rendered on the colored band.
  final String fileName;

  /// Optional MIME type used as a fallback for category detection when the
  /// extension is ambiguous or unrecognised.
  final String? mimeType;

  /// The icon size.
  final OiFileIconSize size;

  /// Overrides the category-based accent color for the band.
  final Color? colorOverride;

  /// Accessibility label announced by screen readers.
  ///
  /// When `null`, defaults to `'$extension file'`.
  final String? semanticsLabel;

  // ---------------------------------------------------------------------------
  // Extension & category helpers
  // ---------------------------------------------------------------------------

  /// Extracts the file extension from [fileName] (lowercase, without dot).
  String get _extension => OiFileUtils.extension(fileName);

  /// The uppercase extension label shown on the band.
  String get _label => _extension.isEmpty ? '?' : _extension.toUpperCase();

  /// Maps a file extension to an [OiFileCategory].
  static OiFileCategory categoryForExtension(String ext) {
    final normalized = ext.toLowerCase().replaceFirst('.', '');
    return switch (normalized) {
      'pdf' ||
      'doc' ||
      'docx' ||
      'rtf' ||
      'odt' ||
      'pages' => OiFileCategory.document,
      'xls' ||
      'xlsx' ||
      'csv' ||
      'ods' ||
      'numbers' => OiFileCategory.spreadsheet,
      'ppt' ||
      'pptx' ||
      'odp' ||
      'key' ||
      'keynote' => OiFileCategory.presentation,
      'png' ||
      'jpg' ||
      'jpeg' ||
      'gif' ||
      'svg' ||
      'webp' ||
      'bmp' ||
      'ico' ||
      'tiff' ||
      'tif' => OiFileCategory.image,
      'mp4' ||
      'mov' ||
      'avi' ||
      'mkv' ||
      'webm' ||
      'flv' ||
      'm4v' => OiFileCategory.video,
      'mp3' ||
      'wav' ||
      'flac' ||
      'aac' ||
      'ogg' ||
      'wma' ||
      'm4a' => OiFileCategory.audio,
      'zip' ||
      'rar' ||
      '7z' ||
      'tar' ||
      'gz' ||
      'bz2' ||
      'xz' => OiFileCategory.archive,
      'dart' ||
      'js' ||
      'ts' ||
      'tsx' ||
      'jsx' ||
      'py' ||
      'rs' ||
      'go' ||
      'html' ||
      'css' ||
      'scss' ||
      'java' ||
      'kt' ||
      'swift' ||
      'c' ||
      'cpp' ||
      'h' ||
      'rb' ||
      'php' ||
      'lua' ||
      'r' => OiFileCategory.code,
      'json' ||
      'xml' ||
      'yaml' ||
      'yml' ||
      'sql' ||
      'toml' => OiFileCategory.data,
      'txt' || 'md' || 'log' || 'ini' || 'cfg' => OiFileCategory.text,
      'exe' ||
      'app' ||
      'sh' ||
      'bat' ||
      'cmd' ||
      'msi' ||
      'dmg' => OiFileCategory.executable,
      'ttf' || 'otf' || 'woff' || 'woff2' || 'eot' => OiFileCategory.font,
      'obj' ||
      'fbx' ||
      'gltf' ||
      'glb' ||
      'stl' ||
      '3ds' => OiFileCategory.threeD,
      _ => OiFileCategory.generic,
    };
  }

  /// Maps a MIME type to an [OiFileCategory].
  static OiFileCategory categoryForMimeType(String mime) {
    final normalized = mime.toLowerCase().trim();
    if (normalized.startsWith('image/')) return OiFileCategory.image;
    if (normalized.startsWith('video/')) return OiFileCategory.video;
    if (normalized.startsWith('audio/')) return OiFileCategory.audio;
    if (normalized.startsWith('font/')) return OiFileCategory.font;
    if (normalized.startsWith('model/')) return OiFileCategory.threeD;
    return switch (normalized) {
      'application/pdf' => OiFileCategory.document,
      'application/msword' ||
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document' =>
        OiFileCategory.document,
      'application/vnd.ms-excel' ||
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
      'text/csv' => OiFileCategory.spreadsheet,
      'application/vnd.ms-powerpoint' ||
      'application/vnd.openxmlformats-officedocument.presentationml.presentation' =>
        OiFileCategory.presentation,
      'application/zip' ||
      'application/x-rar-compressed' ||
      'application/vnd.rar' ||
      'application/x-tar' ||
      'application/gzip' ||
      'application/x-7z-compressed' => OiFileCategory.archive,
      'application/json' ||
      'application/xml' ||
      'text/xml' => OiFileCategory.data,
      'text/plain' => OiFileCategory.text,
      'text/html' ||
      'text/css' ||
      'application/javascript' ||
      'text/javascript' => OiFileCategory.code,
      'application/x-executable' ||
      'application/x-sh' ||
      'application/x-msdos-program' => OiFileCategory.executable,
      _ => OiFileCategory.generic,
    };
  }

  /// Resolves the [OiFileCategory] for this icon.
  ///
  /// Uses the extension first. Falls back to [mimeType] when the extension
  /// yields [OiFileCategory.generic] and a MIME type is available.
  OiFileCategory get category {
    final fromExt = categoryForExtension(_extension);
    if (fromExt != OiFileCategory.generic || mimeType == null) return fromExt;
    return categoryForMimeType(mimeType!);
  }

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
      case OiFileIconSize.xs:
        return (
          width: 16,
          height: 20,
          foldSize: 4,
          bandHeight: 7,
          fontSize: 5,
          radius: 2,
        );
      case OiFileIconSize.sm:
        return (
          width: 24,
          height: 30,
          foldSize: 6,
          bandHeight: 10,
          fontSize: 6,
          radius: 2,
        );
      case OiFileIconSize.md:
        return (
          width: 32,
          height: 40,
          foldSize: 8,
          bandHeight: 14,
          fontSize: 8,
          radius: 3,
        );
      case OiFileIconSize.lg:
        return (
          width: 48,
          height: 60,
          foldSize: 12,
          bandHeight: 20,
          fontSize: 11,
          radius: 4,
        );
      case OiFileIconSize.xl:
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
    if (colorOverride != null) return colorOverride!;

    switch (category) {
      case OiFileCategory.document:
        // .pdf → red, .doc/.docx → blue (primary)
        final ext = _extension;
        if (ext == 'pdf') return colors.error.base;
        return colors.primary.base;
      case OiFileCategory.spreadsheet:
        return colors.success.base;
      case OiFileCategory.presentation:
        return colors.warning.base;
      case OiFileCategory.image:
        return colors.accent.base;
      case OiFileCategory.video:
        return const Color(0xFF7C3AED); // Purple
      case OiFileCategory.audio:
        return const Color(0xFFDB2777); // Pink
      case OiFileCategory.archive:
        return colors.warning.dark;
      case OiFileCategory.code:
        return const Color(0xFF06B6D4); // Cyan
      case OiFileCategory.data:
        return colors.info.base;
      case OiFileCategory.text:
        return colors.textMuted;
      case OiFileCategory.executable:
        return const Color(0xFF374151); // Dark gray
      case OiFileCategory.font:
        return const Color(0xFF4F46E5); // Indigo
      case OiFileCategory.threeD:
        return const Color(0xFF8B5CF6); // Violet
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
    final label = semanticsLabel ?? '$_label file';

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
                    _label,
                    style: TextStyle(
                      fontSize: dims.fontSize,
                      fontWeight: FontWeight.w700,
                      color: colors.textOnPrimary,
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
