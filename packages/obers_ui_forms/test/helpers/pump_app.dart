import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart' hide OiFormController;

/// Test helper extension to wrap widgets with [OiApp].
extension PumpObers on WidgetTester {
  /// Wraps [widget] in [OiApp] with an optional [theme].
  Future<void> pumpObers(Widget widget, {OiThemeData? theme}) async {
    await pumpWidget(OiApp(theme: theme ?? OiThemeData.light(), home: widget));
  }
}
