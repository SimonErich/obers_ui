import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // Regression: OiRawInput passed a new OiTextSelectionControls on every
  // build, so EditableText rebuilt its selection overlay mid-build of the
  // OiOverlays overlay ("Null check operator", duplicate GlobalKey) — on
  // Android a white flicker on every keystroke.
  testWidgets('a sheet with a focused input survives keyboard changes', (
    tester,
  ) async {
    late BuildContext ctx;
    await tester.pumpObers(
      Builder(
        builder: (c) {
          ctx = c;
          return const SizedBox();
        },
      ),
      surfaceSize: const Size(400, 800),
    );

    final controller = TextEditingController();
    addTearDown(controller.dispose);
    unawaited(
      OiSheet.showAsync<void>(
        ctx,
        label: 'Sheet',
        builder: (close) => OiTextInput(controller: controller, label: 'Title'),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final inset in [300.0, 320.0, 300.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: inset);
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'inset $inset');
    }
    tester.view.resetViewInsets();
  });
}
