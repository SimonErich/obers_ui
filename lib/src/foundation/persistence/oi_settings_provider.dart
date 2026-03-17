import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';

/// An [InheritedWidget] that provides an [OiSettingsDriver] to the subtree.
///
/// Place this near the root of the widget tree to supply a shared driver:
///
/// ```dart
/// OiSettingsProvider(
///   driver: OiLocalStorageDriver(),
///   child: MyApp(),
/// )
/// ```
///
/// Widgets can retrieve the driver with [OiSettingsProvider.of]:
///
/// ```dart
/// final driver = OiSettingsProvider.of(context);
/// ```
///
/// Returns `null` when no [OiSettingsProvider] is present in the tree.
///
/// {@category Foundation}
class OiSettingsProvider extends InheritedWidget {
  /// Creates an [OiSettingsProvider].
  const OiSettingsProvider({
    required this.driver,
    required super.child,
    super.key,
  });

  /// The driver made available to the subtree.
  final OiSettingsDriver driver;

  /// Returns the nearest [OiSettingsDriver] in the widget tree, or `null`
  /// when no [OiSettingsProvider] is present.
  static OiSettingsDriver? of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<OiSettingsProvider>();
    return provider?.driver;
  }

  @override
  bool updateShouldNotify(OiSettingsProvider oldWidget) =>
      driver != oldWidget.driver;
}
