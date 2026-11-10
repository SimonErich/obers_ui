import 'package:flutter/widgets.dart';

/// A component-level image widget with required accessibility alt text.
///
/// [OiImage] renders a network or asset image and wraps it in a
/// [Semantics] node so that screen readers can describe the image.
///
/// - For URLs beginning with `http://` or `https://`, [NetworkImage] is used.
/// - For all other [src] values, [AssetImage] is used.
/// - Supply [placeholder] to show a widget while the image loads.
/// - Supply [errorWidget] to show a widget when loading fails.
///
/// **Accessibility (REQ-0014):** [alt] is required so every meaningful image
/// has an accessible description announced by screen readers. Use
/// [OiImage.decorative] for purely decorative images that should be
/// excluded from the accessibility tree.
///
/// {@category Components}
class OiImage extends StatelessWidget {
  /// Creates an [OiImage] with a required accessibility [alt] label.
  ///
  /// The [alt] parameter is required — omitting it is a compile error,
  /// enforcing REQ-0014.
  const OiImage({
    required this.src,
    required this.alt,
    this.width,
    this.height,
    this.fit,
    this.cacheWidth,
    this.cacheHeight,
    this.filterQuality = FilterQuality.medium,
    this.placeholder,
    this.errorWidget,
    super.key,
  }) : _provider = null,
       _decorative = false;

  /// Creates a purely decorative [OiImage] excluded from the accessibility
  /// tree.
  ///
  /// Use this constructor for images that convey no information (e.g.
  /// background textures, decorative flourishes). No [alt] text is needed.
  const OiImage.decorative({
    required this.src,
    this.width,
    this.height,
    this.fit,
    this.cacheWidth,
    this.cacheHeight,
    this.filterQuality = FilterQuality.medium,
    this.placeholder,
    this.errorWidget,
    super.key,
  }) : _provider = null,
       alt = '',
       _decorative = true;

  /// Renders an existing provider, including authenticated network or local
  /// memory/file images, with the same alt, loading and error behavior.
  const OiImage.provider({
    required ImageProvider<Object> provider,
    required this.alt,
    this.width,
    this.height,
    this.fit,
    this.cacheWidth,
    this.cacheHeight,
    this.filterQuality = FilterQuality.medium,
    this.placeholder,
    this.errorWidget,
    super.key,
  }) : _provider = provider,
       src = '',
       _decorative = false;

  final ImageProvider<Object>? _provider;

  /// The image source: a network URL (`http://` / `https://`) or asset path.
  final String src;

  /// The accessibility description announced by screen readers.
  ///
  /// Required for meaningful images. Empty for decorative images created
  /// via [OiImage.decorative].
  final String alt;

  /// Optional width constraint in logical pixels.
  final double? width;

  /// Optional height constraint in logical pixels.
  final double? height;

  /// How the image should be inscribed into the allocated space.
  final BoxFit? fit;

  /// Optional decoded width in physical pixels; originals are never resized.
  final int? cacheWidth;

  /// Optional decoded height in physical pixels; aspect ratio is always preserved.
  final int? cacheHeight;

  /// Sampling quality used when painting the decoded image.
  final FilterQuality filterQuality;

  /// Widget shown while the image is loading.
  final Widget? placeholder;

  /// Widget shown when the image fails to load.
  final Widget? errorWidget;

  final bool _decorative;

  ImageProvider<Object> _sourceProvider() =>
      _provider ??
      (src.startsWith('http://') || src.startsWith('https://')
          ? NetworkImage(src)
          : AssetImage(src));

  Widget _buildImage() {
    final original = _sourceProvider();
    final image = cacheWidth == null && cacheHeight == null
        ? original
        : ResizeImage(
            original,
            width: cacheWidth,
            height: cacheHeight,
            policy: ResizeImagePolicy.fit,
          );
    return Image(
      image: image,
      width: width,
      height: height,
      fit: fit,
      filterQuality: filterQuality,
      frameBuilder: placeholder == null
          ? null
          : (context, child, frame, sync) =>
                sync || frame != null ? child : placeholder!,
      errorBuilder: errorWidget == null
          ? null
          : (context, error, trace) => errorWidget!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();

    if (_decorative) {
      return ExcludeSemantics(child: image);
    }

    return Semantics(image: true, label: alt, child: image);
  }
}
