import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'selection works by pointer and keyboard without moving overlays',
    (
      tester,
    ) async {
      var selected = false;
      const overlayKey = ValueKey('overlay');
      await tester.pumpObers(
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: SizedBox(
              width: 120,
              child: OiMediaTile(
                label: 'Sample',
                selected: selected,
                onChanged: (value) => setState(() => selected = value),
                overlays: const [
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: SizedBox(key: overlayKey, width: 16, height: 16),
                  ),
                ],
                child: const ColoredBox(color: Color(0xff123456)),
              ),
            ),
          ),
        ),
      );
      final rect = tester.getRect(find.byKey(overlayKey));
      await tester.tap(find.byType(OiMediaTile));
      await tester.pumpAndSettle();
      expect(selected, isTrue);
      expect(tester.getRect(find.byKey(overlayKey)), rect);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(selected, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
