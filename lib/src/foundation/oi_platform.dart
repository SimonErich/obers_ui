import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiApp;
import 'package:obers_ui/src/foundation/oi_app.dart' show OiApp;

/// The input modality currently in use.
///
/// Determined by the most recent [PointerDeviceKind] event.
///
/// {@category Foundation}
enum OiInputModality {
  /// Touch or stylus input.
  touch,

  /// Mouse or trackpad input.
  pointer,
}

/// Immutable snapshot of platform and device context.
///
/// Provided to the widget tree by [OiPlatform].
///
/// {@category Foundation}
@immutable
class OiPlatformData {
  /// Creates an [OiPlatformData].
  const OiPlatformData({
    required this.platform,
    required this.keyboardHeight,
    required this.keyboardVisible,
    required this.inputModality,
  });

  /// The host platform.
  final TargetPlatform platform;

  /// The height of the on-screen keyboard in logical pixels.
  ///
  /// Sourced from `MediaQueryData.viewInsets.bottom`.
  final double keyboardHeight;

  /// Whether the on-screen keyboard is currently visible.
  ///
  /// True when [keyboardHeight] is greater than zero.
  final bool keyboardVisible;

  /// The current input modality.
  final OiInputModality inputModality;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiPlatformData &&
        other.platform == platform &&
        other.keyboardHeight == keyboardHeight &&
        other.keyboardVisible == keyboardVisible &&
        other.inputModality == inputModality;
  }

  @override
  int get hashCode =>
      Object.hash(platform, keyboardHeight, keyboardVisible, inputModality);

  @override
  String toString() =>
      'OiPlatformData(platform: $platform, keyboardHeight: $keyboardHeight, '
      'keyboardVisible: $keyboardVisible, inputModality: $inputModality)';
}

/// An [InheritedWidget] that provides [OiPlatformData] to its descendants.
///
/// Wrap your app root (or any subtree) with [OiPlatform] to expose
/// platform context. [OiApp] includes this automatically.
///
/// {@category Foundation}
class OiPlatform extends InheritedWidget {
  /// Creates an [OiPlatform] with explicit [data].
  const OiPlatform({required this.data, required super.child, super.key});

  /// Creates an [OiPlatform] that derives its data from [MediaQuery].
  ///
  /// [platform] defaults to [defaultTargetPlatform].
  /// [inputModality] defaults to [OiInputModality.pointer].
  factory OiPlatform.fromContext({
    required BuildContext context,
    required Widget child,
    TargetPlatform? platform,
    OiInputModality inputModality = OiInputModality.pointer,
    Key? key,
  }) {
    final insets = MediaQuery.viewInsetsOf(context);
    final keyboardHeight = insets.bottom;
    return OiPlatform(
      key: key,
      data: OiPlatformData(
        platform: platform ?? defaultTargetPlatform,
        keyboardHeight: keyboardHeight,
        keyboardVisible: keyboardHeight > 0,
        inputModality: inputModality,
      ),
      child: child,
    );
  }

  /// The platform data available to descendants.
  final OiPlatformData data;

  /// Returns the nearest [OiPlatformData] from [context].
  ///
  /// Asserts that an [OiPlatform] exists in the widget tree.
  static OiPlatformData of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<OiPlatform>();
    assert(result != null, 'No OiPlatform found in context');
    return result!.data;
  }

  /// Returns the nearest [OiPlatformData] from [context], or null if none.
  static OiPlatformData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OiPlatform>()?.data;
  }

  @override
  bool updateShouldNotify(OiPlatform oldWidget) => data != oldWidget.data;
}

/// Extensions on [BuildContext] for convenient platform access.
///
/// {@category Foundation}
extension OiPlatformExt on BuildContext {
  /// The nearest [OiPlatformData] from this context.
  ///
  /// Asserts that an [OiPlatform] exists in the widget tree.
  OiPlatformData get platform => OiPlatform.of(this);

  /// The current [OiInputModality] from the nearest [OiPlatform].
  OiInputModality get inputModality => OiPlatform.of(this).inputModality;
}
