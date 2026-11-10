// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

Widget _toast() => Center(
  child: OiToast(
    label: 'Toast',
    message: 'Upload failed',
    duration: null,
    onDismiss: () {},
    action: OiButton.ghost(
      label: 'Retry upload',
      size: OiButtonSize.small,
      onTap: () {},
    ),
  ),
);

void main() {
  testWidgets('a wide toast keeps message, action and dismiss in one row', (
    tester,
  ) async {
    await tester.pumpObers(_toast(), surfaceSize: const Size(800, 600));

    final message = tester.getRect(find.text('Upload failed'));
    final action = tester.getRect(find.text('Retry upload'));
    final dismiss = tester.getRect(find.byType(OiIconButton));

    expect(action.left, greaterThanOrEqualTo(message.right));
    expect(dismiss.left, greaterThanOrEqualTo(action.right));
    expect(action.center.dy, closeTo(message.center.dy, 1));
    expect(dismiss.center.dy, closeTo(message.center.dy, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a narrow toast moves the action under the message', (
    tester,
  ) async {
    await tester.pumpObers(_toast(), surfaceSize: const Size(220, 400));

    final toast = tester.getRect(find.byType(OiToast));
    final message = tester.getRect(find.text('Upload failed'));
    final action = tester.getRect(find.text('Retry upload'));
    final dismiss = tester.getRect(find.byType(OiIconButton));

    expect(tester.takeException(), isNull);
    expect(message.width, greaterThan(0));
    // The dismiss control stays beside the message, the action drops under it
    // at the trailing edge.
    expect(dismiss.center.dy, closeTo(message.center.dy, 1));
    expect(action.top, greaterThanOrEqualTo(message.bottom));
    expect(action.top, greaterThanOrEqualTo(dismiss.bottom));
    expect(action.overlaps(dismiss), isFalse);
    for (final rect in [message, action, dismiss]) {
      expect(toast.contains(rect.topLeft), isTrue);
      expect(toast.contains(rect.bottomRight), isTrue);
    }
  });

  testWidgets('an action wider than the toast shrinks to fit', (tester) async {
    await tester.pumpObers(_toast(), surfaceSize: const Size(120, 400));

    final toast = tester.getRect(find.byType(OiToast));
    final action = tester.getRect(find.text('Retry upload'));

    expect(tester.takeException(), isNull);
    expect(action.width, lessThan(toast.width));
    expect(toast.contains(action.topLeft), isTrue);
    expect(toast.contains(action.bottomRight), isTrue);
  });

  testWidgets('the shrunken action still takes taps', (tester) async {
    var taps = 0;
    await tester.pumpObers(
      Center(
        child: OiToast(
          label: 'Toast',
          message: 'Upload failed',
          duration: null,
          action: OiButton.ghost(
            label: 'Retry upload',
            size: OiButtonSize.small,
            onTap: () => taps++,
          ),
        ),
      ),
      surfaceSize: const Size(120, 400),
    );

    await tester.tap(find.text('Retry upload'));
    await tester.pump();

    expect(taps, 1);
  });
}
