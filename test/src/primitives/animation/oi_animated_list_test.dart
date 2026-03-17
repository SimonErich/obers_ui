// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/animation/oi_animated_list.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. Renders initial items ──────────────────────────────────────────────

  testWidgets('renders all initial items', (tester) async {
    await tester.pumpObers(
      OiAnimatedList<String>(
        items: const ['alpha', 'beta', 'gamma'],
        itemBuilder: (_, item, animation, index) =>
            SizeTransition(sizeFactor: animation, child: Text(item)),
      ),
    );
    await tester.pump();

    expect(find.text('alpha'), findsOneWidget);
    expect(find.text('beta'), findsOneWidget);
    expect(find.text('gamma'), findsOneWidget);
  });

  // ── 2. Insert adds item ───────────────────────────────────────────────────

  testWidgets('insert adds item and runs animation', (tester) async {
    final controller = OiAnimatedListController<String>();

    await tester.pumpObers(
      OiAnimatedList<String>(
        items: const ['a', 'b'],
        controller: controller,
        itemBuilder: (_, item, animation, index) =>
            SizeTransition(sizeFactor: animation, child: Text(item)),
      ),
    );
    await tester.pump();

    expect(find.text('c'), findsNothing);

    controller.insert(0, 'c');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('c'), findsOneWidget);
  });

  // ── 3. Remove removes item ────────────────────────────────────────────────

  testWidgets('remove removes item after animation completes', (tester) async {
    final controller = OiAnimatedListController<String>();

    await tester.pumpObers(
      OiAnimatedList<String>(
        items: const ['x', 'y', 'z'],
        controller: controller,
        itemBuilder: (_, item, animation, index) =>
            SizeTransition(sizeFactor: animation, child: Text(item)),
      ),
    );
    await tester.pump();

    expect(find.text('x'), findsOneWidget);

    controller.remove(0);
    // Let the remove animation play out.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('x'), findsNothing);
    expect(find.text('y'), findsOneWidget);
    expect(find.text('z'), findsOneWidget);
  });

  // ── 4. insertAll appends multiple items ───────────────────────────────────

  testWidgets('insertAll appends items', (tester) async {
    final controller = OiAnimatedListController<String>();

    await tester.pumpObers(
      OiAnimatedList<String>(
        items: const ['first'],
        controller: controller,
        itemBuilder: (_, item, animation, index) =>
            SizeTransition(sizeFactor: animation, child: Text(item)),
      ),
    );
    await tester.pump();

    controller.insertAll(['second', 'third']);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('second'), findsOneWidget);
    expect(find.text('third'), findsOneWidget);
  });

  // ── 5. Custom removeBuilder is used ──────────────────────────────────────

  testWidgets('custom removeBuilder is called during remove', (tester) async {
    final controller = OiAnimatedListController<String>();
    var removeBuilderCalled = false;

    await tester.pumpObers(
      OiAnimatedList<String>(
        items: const ['one', 'two'],
        controller: controller,
        itemBuilder: (_, item, animation, index) =>
            SizeTransition(sizeFactor: animation, child: Text(item)),
        removeBuilder: (_, item, animation) {
          removeBuilderCalled = true;
          return FadeTransition(opacity: animation, child: Text(item));
        },
      ),
    );
    await tester.pump();

    controller.remove(0);
    await tester.pump();

    expect(removeBuilderCalled, isTrue);
    await tester.pumpAndSettle();
  });

  // ── 6. shrinkWrap=true is forwarded ──────────────────────────────────────

  testWidgets('shrinkWrap=true does not throw', (tester) async {
    await tester.pumpObers(
      OiAnimatedList<String>(
        items: const ['item'],
        shrinkWrap: true,
        itemBuilder: (_, item, animation, index) =>
            SizeTransition(sizeFactor: animation, child: Text(item)),
      ),
    );
    await tester.pump();
    expect(find.text('item'), findsOneWidget);
  });
}
