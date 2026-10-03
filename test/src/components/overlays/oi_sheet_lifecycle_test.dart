import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('empty overlay opens closes and reopens asynchronous sheet', (
    tester,
  ) async {
    var result = 0;
    final controller = TextEditingController(text: '');
    addTearDown(controller.dispose);
    await tester.pumpObers(
      Builder(
        builder: (context) => OiButton.primary(
          label: 'Open',
          onTap: () async {
            final value = await OiSheet.showAsync<int>(
              context,
              label: 'Filters',
              side: OiPanelSide.right,
              builder: (close) => Column(
                children: [
                  OiTextInput(label: 'Search', controller: controller),
                  OiButton.primary(label: 'Apply', onTap: () => close(42)),
                ],
              ),
            );
            result = value ?? -1;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Apply'), findsOneWidget);
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.text('Apply'), findsNothing);
      expect(result, 42);
    }
  });
}
