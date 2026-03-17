import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

/// Test helper extension to wrap widgets with [OiApp].
extension PumpObers on WidgetTester {
  /// Wraps [widget] in [OiApp] with an optional [theme] and [surfaceSize].
  Future<void> pumpObers(
    Widget widget, {
    OiThemeData? theme,
    Size? surfaceSize,
  }) async {
    if (surfaceSize != null) {
      await binding.setSurfaceSize(surfaceSize);
      addTeardownSurfaceSize();
    }

    await pumpWidget(
      OiApp(
        theme: theme ?? OiThemeData.light(),
        home: widget,
      ),
    );
  }

  /// Resets the surface size after a test.
  void addTeardownSurfaceSize() {
    addTearDown(() => binding.setSurfaceSize(null));
  }
}
