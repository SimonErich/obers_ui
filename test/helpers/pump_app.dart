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
      // Also set view physical size so MediaQuery.sizeOf() reflects the
      // test size (setSurfaceSize alone does not update MediaQuery).
      binding.platformDispatcher.views.first.physicalSize = surfaceSize;
      binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
      addTearDown(() async {
        await binding.setSurfaceSize(null);
        binding.platformDispatcher.views.first.resetPhysicalSize();
        binding.platformDispatcher.views.first.resetDevicePixelRatio();
      });
    }

    await pumpWidget(OiApp(theme: theme ?? OiThemeData.light(), home: widget));
  }
}
