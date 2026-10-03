// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/overlays/oi_dialog.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_button_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'dialog actions wrap at320 and retain desktop order and callbacks',
    (tester) async {
      var stay = 0;
      var discard = 0;
      for (final width in [320.0, 600.0]) {
        final base = OiThemeData.light();
        await tester.pumpObers(
          Center(
            child: SizedBox(
              width: width - 64,
              child: OiDialog.confirm(
                label: 'Discard changes',
                title: 'Discard changes?',
                actions: [
                  OiButton.outline(label: 'Stay', onTap: () => stay++),
                  OiButton.primary(
                    label: 'Discard changes',
                    onTap: () => discard++,
                  ),
                ],
              ),
            ),
          ),
          // Ahem has square glyphs; keep each action narrower than its run.
          theme: base.copyWith(
            components: base.components.copyWith(
              button: const OiButtonThemeData(
                textStyle: TextStyle(fontSize: 10),
              ),
            ),
          ),
          surfaceSize: Size(width, 600),
        );
        await tester.pumpAndSettle();
        final first = tester.getRect(find.text('Stay'));
        final last = tester.getRect(find.text('Discard changes'));
        if (width == 320) {
          expect(last.top, greaterThan(first.bottom));
        } else {
          expect(last.top, first.top);
          expect(last.left, greaterThan(first.right));
        }
        expect(find.text('Stay').hitTestable(), findsOneWidget);
        expect(find.text('Discard changes').hitTestable(), findsOneWidget);
        await tester.tap(find.text('Stay'));
        await tester.tap(find.text('Discard changes'));
        expect(tester.takeException(), isNull);
      }
      expect(stay, 2);
      expect(discard, 2);
    },
  );

  testWidgets('renders title text', (tester) async {
    await tester.pumpObers(
      const OiDialog.standard(label: 'dialog', title: 'Confirm delete'),
    );
    expect(find.text('Confirm delete'), findsOneWidget);
  });

  testWidgets('renders content widget', (tester) async {
    await tester.pumpObers(
      const OiDialog.standard(label: 'dialog', content: Text('Are you sure?')),
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

  // Escape and scrim-dismiss behaviour is handled by OiDialogShell /
  // _OiDialogShellOverlay (tested in oi_dialog_shell_test.dart).
  // OiDialog itself only renders content (title, body, actions).

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
            dialog: const OiDialog.standard(label: 'shown', title: 'Shown'),
          ),
          child: const Text('tap'),
        ),
      ),
    );
    await tester.tap(find.text('tap'));
    await tester.pump();
    expect(find.text('Shown'), findsOneWidget);
  });

  // ── fullScreen enhancements ─────────────────────────────────────────────

  testWidgets('fullScreen: onSave callback is stored on widget', (
    tester,
  ) async {
    var saved = false;
    await tester.pumpObers(
      OiDialog.fullScreen(
        label: 'fs',
        title: 'Edit',
        onSave: () => saved = true,
        content: const Text('Body'),
      ),
    );
    final dialog = tester.widget<OiDialog>(find.byType(OiDialog));
    expect(dialog.onSave, isNotNull);
    dialog.onSave!();
    expect(saved, isTrue);
  });

  testWidgets('fullScreen: unsavedChanges suppresses scrim dismiss', (
    tester,
  ) async {
    var closed = false;
    await tester.pumpObers(
      OiDialog.fullScreen(
        label: 'fs',
        title: 'Edit',
        unsavedChanges: true,
        onClose: () => closed = true,
        content: const Text('Body'),
      ),
    );
    // Tap the scrim area — should NOT call onClose because
    // unsavedChanges overrides dismissible to false.
    await tester.tapAt(Offset.zero);
    await tester.pump();
    expect(closed, isFalse);
  });

  testWidgets('fullScreen: unsavedChanges defaults to false', (tester) async {
    await tester.pumpObers(
      const OiDialog.fullScreen(
        label: 'fs',
        title: 'Edit',
        content: Text('Body'),
      ),
    );
    final dialog = tester.widget<OiDialog>(find.byType(OiDialog));
    expect(dialog.unsavedChanges, isFalse);
  });
}
