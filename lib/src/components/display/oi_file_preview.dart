import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_file_icon.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';

/// A thumbnail preview of a file.
///
/// Shows an actual image thumbnail for image/video files, and falls back to
/// [OiFileIcon] for unsupported types. A shimmer placeholder is shown while
/// loading.
///
/// ```dart
/// OiFilePreview(file: myFile)
/// OiFilePreview(file: videoFile, showPlayButton: true)
/// ```
///
/// {@category Components}
class OiFilePreview extends StatelessWidget {
  /// Creates an [OiFilePreview].
  const OiFilePreview({
    required this.file,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.showPlayButton = true,
    this.loading = false,
    this.semanticsLabel,
    super.key,
  });

  /// The file to preview.
  final OiFileNodeData file;

  /// Preview width.
  final double? width;

  /// Preview height.
  final double? height;

  /// How to fit the image within the bounds.
  final BoxFit fit;

  /// Whether to show a play button overlay for video files.
  final bool showPlayButton;

  /// When true, shows a shimmer loading placeholder.
  final bool loading;

  /// Accessibility label.
  final String? semanticsLabel;

  bool get _isImage {
    final ext = file.resolvedExtension.toLowerCase();
    return const {
      'png',
      'jpg',
      'jpeg',
      'gif',
      'svg',
      'webp',
      'bmp',
      'ico',
      'tiff',
      'tif',
    }.contains(ext);
  }

  bool get _isVideo {
    final ext = file.resolvedExtension.toLowerCase();
    return const {
      'mp4',
      'mov',
      'avi',
      'mkv',
      'webm',
      'flv',
      'm4v',
    }.contains(ext);
  }

  bool get _hasThumbnail =>
      file.thumbnailUrl != null && file.thumbnailUrl!.isNotEmpty;

  bool get _hasUrl => file.url != null && file.url!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = semanticsLabel ?? '${file.name} preview';

    return Semantics(
      label: label,
      image: _isImage || _hasThumbnail,
      child: ExcludeSemantics(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: colors.surfaceSubtle,
            borderRadius: BorderRadius.circular(4),
          ),
          clipBehavior: Clip.antiAlias,
          child: loading ? _buildShimmer(colors) : _buildContent(colors),
        ),
      ),
    );
  }

  Widget _buildShimmer(dynamic colors) {
    return Container(color: (colors as dynamic).surfaceHover as Color);
  }

  Widget _buildContent(dynamic colors) {
    // 1. If thumbnailUrl is set, load image
    if (_hasThumbnail) {
      return _buildImagePreview(file.thumbnailUrl!);
    }

    // 2. If image type with URL, load directly
    if (_isImage && _hasUrl) {
      return _buildImagePreview(file.url!);
    }

    // 3. If video with thumbnail or URL, show with play button
    if (_isVideo && _hasUrl) {
      return Stack(
        alignment: Alignment.center,
        children: [
          _buildIconFallback(),
          if (showPlayButton)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xCC000000),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                OiIcons.play, // play_arrow
                color: Color(0xFFFFFFFF),
                size: 20,
              ),
            ),
        ],
      );
    }

    // 4. Fallback to OiFileIcon
    return _buildIconFallback();
  }

  Widget _buildImagePreview(String url) {
    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) => _buildIconFallback(),
    );
  }

  Widget _buildIconFallback() {
    return Center(
      child: OiFileIcon(
        fileName: file.name,
        mimeType: file.mimeType,
        size: OiFileIconSize.lg,
      ),
    );
  }
}
