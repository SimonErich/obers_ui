import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_image.dart';

/// A video player widget with controls and progress bar.
///
/// Note: This is a placeholder implementation. Full video playback
/// requires adding the `video_player` package dependency. The widget renders
/// a poster image (if provided) with a play button overlay and wires up
/// [onPlay] / [onPause] callbacks to a simulated play/pause toggle.
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
  ///
  /// In this placeholder the flag is stored but no actual playback occurs.
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

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      _isPlaying = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onPlay?.call();
      });
    }
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      widget.onPlay?.call();
    } else {
      widget.onPause?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final ar = widget.aspectRatio ?? 16 / 9;

    Widget content = Container(
      key: const Key('oi_video_player_surface'),
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
                  Text(
                    '\u25B6',
                    style: TextStyle(
                      fontSize: 32,
                      color: colors.textInverse,
                    ),
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
              child: GestureDetector(
                key: const Key('oi_video_player_controls'),
                onTap: _togglePlayback,
                behavior: HitTestBehavior.opaque,
                child: Center(
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
                        child: Text(
                          _isPlaying ? '\u23F8' : '\u25B6',
                          key: const Key('oi_video_player_play_icon'),
                          style: TextStyle(
                            fontSize: 24,
                            color: colors.textInverse,
                            height: 1,
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
}
