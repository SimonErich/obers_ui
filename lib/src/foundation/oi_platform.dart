import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/widgets.dart';

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
  });

  /// The host platform.
  final TargetPlatform platform;

  /// The height of the on-screen keyboard in logical pixels.
  ///
  /// Sourced from [MediaQueryData.viewInsets.bottom].
  final double keyboardHeight;

  /// Whether the on-screen keyboard is currently visible.
  ///
  /// True when [keyboardHeight] is greater than zero.
  final bool keyboardVisible;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiPlatformData &&
        other.platform == platform &&
        other.keyboardHeight == keyboardHeight &&
        other.keyboardVisible == keyboardVisible;
  }

  @override
  int get hashCode => Object.hash(platform, keyboardHeight, keyboardVisible);

  @override
  String toString() =>
      'OiPlatformData(platform: $platform, keyboardHeight: $keyboardHeight, '
      'keyboardVisible: $keyboardVisible)';
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
  factory OiPlatform.fromContext({
    required BuildContext context,
    required Widget child,
    TargetPlatform? platform,
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
}
