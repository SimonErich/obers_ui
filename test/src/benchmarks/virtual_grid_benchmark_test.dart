// Test helpers do not need public API docs.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OiVirtualGrid benchmark (REQ-0176)', () {
    const itemCount = 10000;

    testWidgets('renders 10k items without errors', (tester) async {
      await tester.pumpObers(
        OiVirtualGrid(
          itemCount: itemCount,
          crossAxisCount: 4,
          itemBuilder: (context, index) => SizedBox(
            child: Text('Cell $index'),
          ),
        ),
        surfaceSize: const Size(800, 800),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(OiVirtualGrid), findsOneWidget);
    });

    testWidgets('scrolls through 10k grid items without exceptions',
        (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpObers(
        OiVirtualGrid(
          itemCount: itemCount,
          crossAxisCount: 4,
          controller: controller,
          itemBuilder: (context, index) => SizedBox(
            child: Text('Cell $index'),
          ),
        ),
        surfaceSize: const Size(800, 800),
      );

      // Scroll forward in large jumps.
      for (var offset = 0.0; offset < 20000; offset += 5000) {
        controller.jumpTo(offset);
        await tester.pump();
        expect(tester.takeException(), isNull);
      }

      // Scroll back to start.
      controller.jumpTo(0);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('scrolls to end of 10k grid items', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpObers(
        OiVirtualGrid(
          itemCount: itemCount,
          crossAxisCount: 4,
          controller: controller,
          itemBuilder: (context, index) => SizedBox(
            child: Text('Cell $index'),
          ),
        ),
        surfaceSize: const Size(800, 800),
      );

      // Jump to the maximum scroll extent.
      await tester.pump();
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
