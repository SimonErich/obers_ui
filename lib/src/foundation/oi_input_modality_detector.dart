import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/_hover_detect_stub.dart'
    if (dart.library.js_interop) 'package:obers_ui/src/foundation/_hover_detect_web.dart'
    if (dart.library.io) 'package:obers_ui/src/foundation/_hover_detect_io.dart';
import 'package:obers_ui/src/foundation/oi_platform.dart';

/// Detects the current [OiInputModality] based on pointer events and provides
/// an updated [OiPlatformData] via [OiPlatform].
///
/// Place this widget above [OiPlatform.fromContext] in the widget tree. It
/// wraps its child in a [Listener] that captures all pointer-down events and
/// maps the [PointerDeviceKind] to [OiInputModality].
///
/// On web, the initial modality is seeded from the `hover` media query: if the
/// device does not support hover, the initial modality is [OiInputModality.touch].
///
/// {@category Foundation}
class OiInputModalityDetector extends StatefulWidget {
  /// Creates an [OiInputModalityDetector].
  const OiInputModalityDetector({required this.child, super.key});

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<OiInputModalityDetector> createState() =>
      _OiInputModalityDetectorState();
}

class _OiInputModalityDetectorState extends State<OiInputModalityDetector> {
  late OiInputModality _modality;

  @override
  void initState() {
    super.initState();
    _modality = supportsHoverMediaQuery()
        ? OiInputModality.pointer
        : OiInputModality.touch;
  }

  void _onPointerEvent(PointerEvent event) {
    final newModality = _mapDeviceKind(event.kind);
    if (newModality != null && newModality != _modality) {
      setState(() {
        _modality = newModality;
      });
    }
  }

  static OiInputModality? _mapDeviceKind(PointerDeviceKind kind) {
    switch (kind) {
      case PointerDeviceKind.touch:
      case PointerDeviceKind.stylus:
      case PointerDeviceKind.invertedStylus:
        return OiInputModality.touch;
      case PointerDeviceKind.mouse:
      case PointerDeviceKind.trackpad:
        return OiInputModality.pointer;
      case PointerDeviceKind.unknown:
        return null;
    }
  }

  /// The current input modality detected by this widget.
  OiInputModality get modality => _modality;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerEvent,
      onPointerPanZoomStart: _onPointerEvent,
      onPointerSignal: _onPointerEvent,
      child: _OiInputModalityProvider(modality: _modality, child: widget.child),
    );
  }
}

/// Internal widget that rebuilds [OiPlatform.fromContext] with the detected
/// input modality.
class _OiInputModalityProvider extends StatelessWidget {
  const _OiInputModalityProvider({required this.modality, required this.child});

  final OiInputModality modality;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OiPlatform.fromContext(
      context: context,
      inputModality: modality,
      child: child,
    );
  }
}
