// Tests do not require documentation comments.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/dialogs/oi_delete_dialog.dart';
import 'package:obers_ui/src/components/inputs/oi_checkbox.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';

import '../../../helpers/pump_app.dart';

/// Focuses the [KeyboardListener] inside the widget tree so ESC events
/// are received.
void _focusKeyboardListener(WidgetTester tester) {
  final kl = tester.widget<KeyboardListener>(find.byType(KeyboardListener));
  kl.focusNode.requestFocus();
}

OiFileNodeData _file(String name, {bool folder = false, int? itemCount}) =>
    OiFileNodeData(id: name, name: name, folder: folder, itemCount: itemCount);

void main() {
  group('OiDeleteDialog', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpObers(
        OiDeleteDialog(files: [_file('readme.txt')], onDelete: () {}),
      );
      expect(find.byType(OiDeleteDialog), findsOneWidget);
    });

    testWidgets('shows singular title for one file', (tester) async {
      await tester.pumpObers(
        OiDeleteDialog(files: [_file('readme.txt')], onDelete: () {}),
      );
      expect(find.text('Delete readme.txt?'), findsOneWidget);
    });

    testWidgets('shows plural title for multiple files', (tester) async {
      await tester.pumpObers(
        OiDeleteDialog(
          files: [_file('a.txt'), _file('b.txt'), _file('c.txt')],
          onDelete: () {},
        ),
      );
      expect(find.text('Delete 3 items?'), findsOneWidget);
    });

    testWidgets('shows file names in list', (tester) async {
      await tester.pumpObers(
        OiDeleteDialog(
          files: [_file('a.txt'), _file('b.pdf')],
          onDelete: () {},
        ),
      );
      expect(find.text('a.txt'), findsOneWidget);
      expect(find.text('b.pdf'), findsOneWidget);
    });

    testWidgets('shows folder item count', (tester) async {
      await tester.pumpObers(
        OiDeleteDialog(
          files: [_file('Photos', folder: true, itemCount: 42)],
          onDelete: () {},
        ),
      );
      expect(find.text('Photos (42 items inside)'), findsOneWidget);
    });

    testWidgets('truncates list beyond 5 items', (tester) async {
      final files = List.generate(7, (i) => _file('file_$i.txt'));
      await tester.pumpObers(OiDeleteDialog(files: files, onDelete: () {}));
      expect(find.text('file_0.txt'), findsOneWidget);
      expect(find.text('file_4.txt'), findsOneWidget);
      expect(find.text('file_5.txt'), findsNothing);
      expect(find.text('and 2 more...'), findsOneWidget);
    });

    testWidgets('shows permanent warning when permanent is true', (
      tester,
    ) async {
      await tester.pumpObers(
        OiDeleteDialog(
          files: [_file('data.csv')],
          onDelete: () {},
          permanent: true,
        ),
      );
      expect(find.text('This action cannot be undone.'), findsOneWidget);
    });

    testWidgets('hides permanent warning when permanent is false', (
      tester,
    ) async {
      await tester.pumpObers(
        OiDeleteDialog(files: [_file('data.csv')], onDelete: () {}),
      );
      expect(find.text('This action cannot be undone.'), findsNothing);
    });

    testWidgets('shows dont ask again checkbox when enabled', (tester) async {
      await tester.pumpObers(
        OiDeleteDialog(
          files: [_file('a.txt')],
          onDelete: () {},
          showDontAskAgain: true,
        ),
      );
      expect(find.text("Don't ask me again"), findsOneWidget);
      expect(find.byType(OiCheckbox), findsOneWidget);
    });

    testWidgets('hides dont ask again checkbox when disabled', (tester) async {
      await tester.pumpObers(
        OiDeleteDialog(files: [_file('a.txt')], onDelete: () {}),
      );
      expect(find.text("Don't ask me again"), findsNothing);
    });

    testWidgets('tapping Delete fires onDelete', (tester) async {
      var deleted = false;
      await tester.pumpObers(
        OiDeleteDialog(files: [_file('a.txt')], onDelete: () => deleted = true),
      );
      await tester.tap(find.widgetWithText(OiButton, 'Delete'));
      await tester.pump();
      expect(deleted, isTrue);
    });

    testWidgets('tapping Cancel fires onCancel', (tester) async {
      var cancelled = false;
      await tester.pumpObers(
        OiDeleteDialog(
          files: [_file('a.txt')],
          onDelete: () {},
          onCancel: () => cancelled = true,
        ),
      );
      await tester.tap(find.widgetWithText(OiButton, 'Cancel'));
      await tester.pump();
      expect(cancelled, isTrue);
    });

    testWidgets('ESC key fires onCancel', (tester) async {
      var cancelled = false;
      await tester.pumpObers(
        OiDeleteDialog(
          files: [_file('a.txt')],
          onDelete: () {},
          onCancel: () => cancelled = true,
        ),
      );
      _focusKeyboardListener(tester);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(cancelled, isTrue);
    });

    testWidgets('tapping dont ask again checkbox fires callback', (
      tester,
    ) async {
      bool? received;
      await tester.pumpObers(
        OiDeleteDialog(
          files: [_file('a.txt')],
          onDelete: () {},
          showDontAskAgain: true,
          onDontAskAgainChange: (v) => received = v,
        ),
      );
      await tester.tap(find.byType(OiCheckbox));
      await tester.pump();
      expect(received, isNotNull);
    });

    testWidgets('has correct semantics label', (tester) async {
      await tester.pumpObers(
        OiDeleteDialog(files: [_file('a.txt')], onDelete: () {}),
      );
      expect(
        find.bySemanticsLabel(RegExp('Delete confirmation dialog')),
        findsOneWidget,
      );
    });
  });
}
