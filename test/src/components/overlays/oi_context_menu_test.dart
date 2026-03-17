// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/overlays/oi_context_menu.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('long-press shows menu items', (tester) async {
    await tester.pumpObers(
      const OiContextMenu(
        items: [
          OiMenuItem(label: 'Copy'),
          OiMenuItem(label: 'Paste'),
        ],
        child: Text('target'),
      ),
    );
    await tester.longPress(find.text('target'));
    await tester.pump();
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Paste'), findsOneWidget);
  });

  testWidgets('tapping an item calls onTap and closes menu', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiContextMenu(
        items: [
          OiMenuItem(label: 'Action', onTap: () => tapped = true),
        ],
        child: const Text('target'),
      ),
    );
    await tester.longPress(find.text('target'));
    await tester.pump();
    await tester.tap(find.text('Action'));
    await tester.pump();
    expect(tapped, isTrue);
    // Menu should be gone after tap.
    expect(find.text('Action'), findsNothing);
  });

  testWidgets('disabled item does not call onTap', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiContextMenu(
        items: [
          OiMenuItem(label: 'Disabled', disabled: true, onTap: () => tapped = true),
        ],
        child: const Text('target'),
      ),
    );
    await tester.longPress(find.text('target'));
    await tester.pump();
    await tester.tap(find.text('Disabled'), warnIfMissed: false);
    await tester.pump();
    expect(tapped, isFalse);
  });

  testWidgets('Escape key dismisses the menu', (tester) async {
    await tester.pumpObers(
      const OiContextMenu(
        items: [OiMenuItem(label: 'Item')],
        child: Text('target'),
      ),
    );
    await tester.longPress(find.text('target'));
    await tester.pump();
    expect(find.text('Item'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.text('Item'), findsNothing);
  });

  testWidgets('right-click shows menu (secondary pointer button)',
      (tester) async {
    await tester.pumpObers(
      const OiContextMenu(
        items: [OiMenuItem(label: 'Right-click item')],
        child: Text('target'),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('target')),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(find.text('Right-click item'), findsOneWidget);
  });

  testWidgets('tapping barrier closes the menu', (tester) async {
    await tester.pumpObers(
      const OiContextMenu(
        items: [OiMenuItem(label: 'CloseMe')],
        child: Text('target'),
      ),
    );
    await tester.longPress(find.text('target'));
    await tester.pump();
    expect(find.text('CloseMe'), findsOneWidget);

    // Tap in the top-left corner (on the barrier, away from the menu).
    await tester.tapAt(const Offset(1, 1));
    await tester.pump();
    expect(find.text('CloseMe'), findsNothing);
  });

  testWidgets('enabled=false suppresses context menu', (tester) async {
    await tester.pumpObers(
      const OiContextMenu(
        items: [OiMenuItem(label: 'Hidden')],
        enabled: false,
        child: Text('target'),
      ),
    );
    await tester.longPress(find.text('target'));
    await tester.pump();
    expect(find.text('Hidden'), findsNothing);
  });

  testWidgets('separator renders as divider (no text)', (tester) async {
    await tester.pumpObers(
      const OiContextMenu(
        items: [
          OiMenuItem(label: 'Above'),
          OiMenuItem(label: '', separator: true),
          OiMenuItem(label: 'Below'),
        ],
        child: Text('target'),
      ),
    );
    await tester.longPress(find.text('target'));
    await tester.pump();
    expect(find.text('Above'), findsOneWidget);
    expect(find.text('Below'), findsOneWidget);
  });
}
