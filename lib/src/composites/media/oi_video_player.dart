import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/composites/media/_oi_video_player_stub.dart'
    if (dart.library.js_interop) 'package:obers_ui/src/composites/media/_oi_video_player_web.dart'
    as platform;
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_image.dart';

/// A video player widget with controls and progress bar.
///
/// On web, clicking play embeds a native HTML `<video>` element for actual
/// playback. On other platforms, displays a poster image (if provided) with a
/// play button overlay and wires up [onPlay] / [onPause] callbacks.
///
/// {@category Composites}
class OiVideoPlayer extends StatefulWidget {
  /// Creates an [OiVideoPlayer].
  const OiVideoPlayer({
    required this.src,
    required this.label,
    this.autoPlay = false,
    super.key,
    this.loop = false,
    this.showControls = true,
    this.aspectRatio,
    this.posterUrl,
    this.onPlay,
    this.onPause,
  });

  /// The video source URL.
  final String src;

  /// Semantic label for the video player.
  final String label;

  /// Whether the video should start playing automatically.
  final bool autoPlay;

  /// Whether the video should loop when it reaches the end.
  final bool loop;

  /// Whether playback controls (play/pause) are visible.
  final bool showControls;

  /// The aspect ratio (width / height) of the video container.
  ///
  /// Defaults to 16:9 when null.
  final double? aspectRatio;

  /// An optional poster image URL shown before playback starts.
  final String? posterUrl;

  /// Called when playback starts or resumes.
  final VoidCallback? onPlay;

  /// Called when playback is paused.
  final VoidCallback? onPause;

  @override
  State<OiVideoPlayer> createState() => _OiVideoPlayerState();
}

class _OiVideoPlayerState extends State<OiVideoPlayer> {
  bool _isPlaying = false;
  bool _playHovered = false;

  /// The embedded video widget, created once when playback starts on web.
  Widget? _videoSurface;

  /// The underlying platform video element for controlling playback.
  dynamic _videoElement;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      _isPlaying = true;
      _createVideoSurface();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onPlay?.call();
      });
    }
  }

  @override
  void didUpdateWidget(OiVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src || oldWidget.loop != widget.loop) {
      _disposeVideoSurface();
      if (_isPlaying) {
        _createVideoSurface();
      }
    }
  }

  @override
  void dispose() {
    _disposeVideoSurface();
    super.dispose();
  }

  void _createVideoSurface() {
    if (!platform.isSupported || _videoSurface != null) return;
    final result = platform.buildVideoSurface(
      src: widget.src,
      loop: widget.loop,
    );
    _videoSurface = result.widget;
    _videoElement = result.element;
  }

  void _disposeVideoSurface() {
    if (_videoElement != null) {
      platform.disposeVideoElement(_videoElement);
      _videoElement = null;
    }
    _videoSurface = null;
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _createVideoSurface();
      } else {
        _disposeVideoSurface();
      }
    });
    if (_isPlaying) {
      widget.onPlay?.call();
    } else {
      widget.onPause?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ar = widget.aspectRatio ?? 16 / 9;

    Widget content;

    if (_isPlaying && _videoSurface != null) {
      // Web playback: show the native HTML video element.
      content = DecoratedBox(
        key: const Key('oi_video_player_surface'),
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _videoSurface,
        ),
      );
    } else {
      // Poster / placeholder with play button overlay.
      content = _buildPoster(context);
    }

    content = AspectRatio(
      key: const Key('oi_video_player_aspect'),
      aspectRatio: ar,
      child: content,
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label,
      child: content,
    );
  }

  Widget _buildPoster(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    return DecoratedBox(
      key: const Key('oi_video_player_poster'),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Poster image
          if (widget.posterUrl != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: OiImage.decorative(
                  key: const Key('oi_video_player_poster'),
                  src: widget.posterUrl!,
                  fit: BoxFit.cover,
                  errorWidget: const SizedBox.shrink(),
                ),
              ),
            ),

          // Placeholder info when no poster
          if (widget.posterUrl == null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    OiIcons.play,
                    size: 32,
                    color: colors.textInverse,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.src,
                    key: const Key('oi_video_player_src'),
                    style: textTheme.small.copyWith(
                      color: colors.textInverse.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

          // Play/pause overlay
          if (widget.showControls)
            Positioned.fill(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _playHovered = true),
                onExit: (_) => setState(() => _playHovered = false),
                child: GestureDetector(
                  key: const Key('oi_video_player_controls'),
                  onTap: _togglePlayback,
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedScale(
                      scale: _playHovered ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colors.overlay,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Semantics(
                            label: _isPlaying ? 'Pause' : 'Play',
                            button: true,
                            child: Icon(
                              _isPlaying ? OiIcons.pause : OiIcons.play,
                              key: const Key('oi_video_player_play_icon'),
                              size: 24,
                              color: colors.textInverse,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Progress bar placeholder at the bottom
          if (widget.showControls)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                key: const Key('oi_video_player_progress'),
                height: 4,
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.primary.base,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
