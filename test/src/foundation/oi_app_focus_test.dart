import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  testWidgets('view focus ignores a field detached during a form handoff', (
    tester,
  ) async {
    final first = FocusNode();
    final second = FocusNode();
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    await tester.pumpWidget(
      OiApp(
        home: Column(
          children: [
            Focus(
              focusNode: first,
              child: const SizedBox(width: 40, height: 40),
            ),
            Focus(
              focusNode: second,
              child: const SizedBox(width: 40, height: 40),
            ),
          ],
        ),
      ),
    );
    final render = first.context!.findRenderObject()!;
    // Web can dispatch view focus between removing an editor's render object
    // and detaching its FocusNode. Keep the element alive to reproduce that
    // interval, rather than merely testing an already disposed input.
    final parent = (render.parent! as RenderFlex)..remove(render as RenderBox);
    try {
      final policy = ReadingOrderTraversalPolicy();
      expect(
        policy.findFirstFocus(second, ignoreCurrentFocus: true),
        same(second),
      );
    } finally {
      parent.insert(render);
    }
  });
}
