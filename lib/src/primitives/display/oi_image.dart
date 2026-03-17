import 'package:flutter/widgets.dart';

/// A flexible image widget with semantics, loading states, and error handling.
///
/// [OiImage] renders a network or asset image and wraps it in a
/// [Semantics] node so that screen readers can describe the image.
///
/// - For URLs beginning with `http://` or `https://`, [Image.network] is used.
/// - For all other [src] values, [Image.asset] is used.
/// - Supply [placeholder] to show a widget while the image loads.
/// - Supply [errorWidget] to show a widget when loading fails.
/// - Set [lazy] to `true` to opt into deferred loading behaviour (stored as
///   metadata; full viewport-based lazy loading requires additional
///   infrastructure that ships in a later phase).
///
/// Use [OiImage.decorative] for purely decorative images that should be
/// excluded from the accessibility tree.
///
/// {@category Primitives}
class OiImage extends StatelessWidget {
  /// Creates an [OiImage] with an accessibility [alt] label.
  const OiImage({
    required this.src,
    required this.alt,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.lazy = false,
    super.key,
  }) : _decorative = false;

  /// Creates a purely decorative [OiImage] excluded from the accessibility
  /// tree.
  const OiImage.decorative({
    required this.src,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.lazy = false,
    super.key,
  }) : alt = '',
       _decorative = true;

  /// The image source: a network URL (`http://` / `https://`) or asset path.
  final String src;

  /// The accessibility description announced by screen readers.
  ///
  /// Empty for decorative images created via [OiImage.decorative].
  final String alt;

  /// Optional width constraint in logical pixels.
  final double? width;

  /// Optional height constraint in logical pixels.
  final double? height;

  /// How the image should be inscribed into the allocated space.
  final BoxFit? fit;

  /// Widget shown while the image is loading (network images only).
  final Widget? placeholder;

  /// Widget shown when the image fails to load.
  final Widget? errorWidget;

  /// When `true`, deferred loading is requested.
  ///
  /// This flag is stored for future use; full viewport-based lazy loading
  /// will be implemented in a later phase.
  final bool lazy;

  final bool _decorative;

  bool get _isNetwork =>
      src.startsWith('http://') || src.startsWith('https://');

  Widget _buildImage() {
    if (_isNetwork) {
      return Image.network(
        src,
        width: width,
        height: height,
        fit: fit,
        filterQuality: lazy ? FilterQuality.low : FilterQuality.medium,
        loadingBuilder: placeholder == null
            ? null
            : (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return placeholder!;
              },
        errorBuilder: errorWidget == null
            ? null
            : (context, error, stackTrace) => errorWidget!,
      );
    }

    return Image.asset(
      src,
      width: width,
      height: height,
      fit: fit,
      filterQuality: lazy ? FilterQuality.low : FilterQuality.medium,
      errorBuilder: errorWidget == null
          ? null
          : (context, error, stackTrace) => errorWidget!,
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
