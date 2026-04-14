import 'package:flutter/widgets.dart';

/// Whether the current platform supports native video playback.
bool get isSupported => false;

/// Stub video surface for non-web platforms.
///
/// Throws because it should never be called — callers must check
/// [isSupported] first.
({Widget widget, Never element}) buildVideoSurface({
  required String src,
  required bool loop,
}) =>
    throw UnsupportedError('Video playback is not supported on this platform');

/// Stub dispose — should never be called on non-web platforms.
void disposeVideoElement(dynamic element) =>
    throw UnsupportedError('Video playback is not supported on this platform');
