// Test helpers do not need public API docs.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OiVirtualList benchmark (REQ-0176)', () {
    const itemCount = 100000;

    testWidgets('renders 100k items without errors', (tester) async {
      await tester.pumpObers(
        OiVirtualList(
          itemCount: itemCount,
          itemBuilder: (context, index) => SizedBox(
            height: 48,
            child: Text('Item $index'),
          ),
        ),
        surfaceSize: const Size(400, 800),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(OiVirtualList), findsOneWidget);
    });

    testWidgets('scrolls through 100k items without exceptions',
        (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpObers(
        OiVirtualList(
          itemCount: itemCount,
          controller: controller,
          itemBuilder: (context, index) => SizedBox(
            height: 48,
            child: Text('Item $index'),
          ),
        ),
        surfaceSize: const Size(400, 800),
      );

      // Scroll forward in large jumps.
      for (var offset = 0.0; offset < 50000; offset += 10000) {
        controller.jumpTo(offset);
        await tester.pump();
        expect(tester.takeException(), isNull);
      }

      // Scroll back to start.
      controller.jumpTo(0);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('scrolls to end of 100k item list', timeout: const Timeout(Duration(seconds: 30)), (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpObers(
        OiVirtualList(
          itemCount: itemCount,
          controller: controller,
          itemBuilder: (context, index) => SizedBox(
            height: 48,
            child: Text('Item $index'),
          ),
        ),
        surfaceSize: const Size(400, 800),
      );

      // Jump to the maximum scroll extent.
      await tester.pump();
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
