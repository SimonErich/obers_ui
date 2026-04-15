import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// Whether the current platform supports native video playback.
bool get isSupported => true;

/// Tracks which view types have already been registered to avoid duplicates.
final Set<String> _registeredViewTypes = {};

/// Creates a web video surface backed by an HTML `<video>` element.
///
/// Returns a record containing the Flutter [Widget] to embed and the
/// underlying [web.HTMLVideoElement] so callers can control playback
/// (pause, seek, dispose).
({Widget widget, web.HTMLVideoElement element}) buildVideoSurface({
  required String src,
  required bool loop,
}) {
  final viewType = 'oi-video-${src.hashCode}';

  final element =
      web.document.createElement('video') as web.HTMLVideoElement
        ..src = src
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.borderRadius = '8px'
        ..style.display = 'block'
        ..style.backgroundColor = 'black'
        ..controls = true
        ..autoplay = true
        ..muted = true // browsers require muted for autoplay
        ..loop = loop;

  if (!_registeredViewTypes.contains(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) => element,
    );
    _registeredViewTypes.add(viewType);
  }

  return (
    widget: HtmlElementView(viewType: viewType),
    element: element,
  );
}

/// Disposes a video element by pausing and clearing its source.
void disposeVideoElement(web.HTMLVideoElement element) {
  element
    ..pause()
    ..src = ''
    ..load(); // reset the media element
}
