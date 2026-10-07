import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('body inset override preserves header and dock gutters', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiDockedPage(
        bodyPadding: EdgeInsets.only(top: 8, bottom: 32),
        header: SizedBox(key: ValueKey('header'), height: 64),
        dock: SizedBox(key: ValueKey('dock'), height: 52),
        child: SizedBox(key: ValueKey('body'), height: 250),
      ),
      surfaceSize: const Size(390, 790),
    );
    final body = tester.getRect(find.byKey(const ValueKey('body')));
    final header = tester.getRect(find.byKey(const ValueKey('header')));
    final dock = tester.getRect(find.byKey(const ValueKey('dock')));
    expect(body.left, 0);
    expect(body.width, 390);
    // The themed header retains 24 pixels of bottom padding.
    expect(body.top - header.bottom, 24 + 8);
    expect(header.left, greaterThan(0));
    expect(dock.left, header.left);
    expect(dock.right, header.right);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sliver page builds visible grid items and retains fixed dock', (
    tester,
  ) async {
    var built = 0;
    await tester.pumpObers(
      OiDockedPage.slivers(
        dock: const OiButton.primary(label: 'Save'),
        slivers: [
          OiSliverGrid(
            itemCount: 1000,
            crossAxisCount: 3,
            itemBuilder: (context, index) {
              built++;
              return OiLabel.body('Item $index');
            },
          ),
        ],
      ),
      surfaceSize: const Size(390, 790),
    );
    expect(built, lessThan(40));
    final dock = tester.getRect(find.byType(OiButton));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1500));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(OiButton)).bottom, dock.bottom);
    expect(built, lessThan(80));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'dock stays above keyboard and content scrolls within safe areas',
    (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpObers(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 600),
            padding: EdgeInsets.only(top: 24),
            viewInsets: EdgeInsets.only(bottom: 200),
          ),
          child: OiDockedPage(
            header: const SizedBox(height: 64, child: OiLabel.h1('Header')),
            dock: OiButton.primary(label: 'Save', onTap: () => taps++),
            child: const SizedBox(
              height: 1000,
              child: OiLabel.body('Long body'),
            ),
          ),
        ),
        surfaceSize: const Size(320, 600),
      );
      final dockRect = tester.getRect(find.byType(OiButton));
      expect(dockRect.bottom, lessThanOrEqualTo(400));
      expect(
        tester.getTopLeft(find.text('Header')).dy,
        greaterThanOrEqualTo(24),
      );
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(OiButton)).bottom, dockRect.bottom);
      await tester.tap(find.text('Save'));
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
