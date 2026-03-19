// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/overlays/oi_dialog.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders title text', (tester) async {
    await tester.pumpObers(
      const OiDialog.standard(label: 'dialog', title: 'Confirm delete'),
    );
    expect(find.text('Confirm delete'), findsOneWidget);
  });

  testWidgets('renders content widget', (tester) async {
    await tester.pumpObers(
      const OiDialog.standard(
        label: 'dialog',
        content: Text('Are you sure?'),
      ),
    );
    expect(find.text('Are you sure?'), findsOneWidget);
  });

  testWidgets('renders action widgets', (tester) async {
    await tester.pumpObers(
      const OiDialog.standard(
        label: 'dialog',
        actions: [Text('Cancel'), Text('OK')],
      ),
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('Escape key calls onClose', (tester) async {
    var closed = false;
    await tester.pumpObers(
      OiDialog.standard(
        label: 'alert',
        title: 'Alert',
        onClose: () => closed = true,
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(closed, isTrue);
  });

  testWidgets('dismissible=true: tapping scrim calls onClose', (tester) async {
    var closed = false;
    await tester.pumpObers(
      OiDialog.standard(
        label: 'dismissible',
        title: 'Dismissible',
        onClose: () => closed = true,
      ),
    );
    // Tap far corner — outside the centered panel, on the scrim.
    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    expect(closed, isTrue);
  });

  testWidgets('dismissible=false: tapping scrim does not call onClose', (
    tester,
  ) async {
    var closed = false;
    await tester.pumpObers(
      OiDialog.standard(
        label: 'non-dismissible',
        title: 'Non-dismissible',
        dismissible: false,
        onClose: () => closed = true,
      ),
    );
    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    expect(closed, isFalse);
  });

  testWidgets('fullScreen variant builds without error', (tester) async {
    await tester.pumpObers(
      const OiDialog.fullScreen(
        label: 'full-screen',
        title: 'Full screen',
        content: Text('Content'),
      ),
    );
    expect(find.text('Full screen'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
  });

  testWidgets('form variant wraps content in scroll view', (tester) async {
    await tester.pumpObers(
      const OiDialog.form(
        label: 'form',
        title: 'Form',
        content: Text('Form content'),
      ),
    );
    expect(find.text('Form content'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('show() method inserts dialog into overlay', (tester) async {
    await tester.pumpObers(
      Builder(
        builder: (ctx) => GestureDetector(
          onTap: () => OiDialog.show(
            ctx,
            label: 'shown',
            dialog: const OiDialog.standard(
              label: 'shown',
              title: 'Shown',
            ),
          ),
          child: const Text('tap'),
        ),
      ),
    );
    await tester.tap(find.text('tap'));
    await tester.pump();
    expect(find.text('Shown'), findsOneWidget);
  });
}
