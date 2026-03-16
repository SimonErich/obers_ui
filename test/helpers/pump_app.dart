import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helper extension to wrap widgets with the required app scaffold.
///
/// Usage:
/// ```dart
/// testWidgets('my widget test', (tester) async {
///   await tester.pumpObers(const MyWidget());
///   expect(find.byType(MyWidget), findsOneWidget);
/// });
/// ```
extension PumpObers on WidgetTester {
  /// Wraps [widget] in a [MaterialApp] with optional theme configuration.
  ///
  /// When the obers_ui theme system is implemented, this will automatically
  /// inject [FlubluTheme] into the widget tree.
  Future<void> pumpObers(
    Widget widget, {
    ThemeData? theme,
    Size? surfaceSize,
  }) async {
    if (surfaceSize != null) {
      await binding.setSurfaceSize(surfaceSize);
      addTeardownSurfaceSize();
    }

    await pumpWidget(
      MaterialApp(
        theme: theme ?? ThemeData.light(),
        home: Scaffold(body: widget),
      ),
    );
  }

  /// Resets the surface size after a test.
  void addTeardownSurfaceSize() {
    addTearDown(() => binding.setSurfaceSize(null));
  }
}
