import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'dialog result waits for focused content teardown before owner disposal',
    (tester) async {
      var contentDisposed = false;
      bool? completedAfterDisposal;
      var opens = 0;
      await tester.pumpObers(
        Builder(
          builder: (context) => OiButton.primary(
            label: 'Open dialog',
            onTap: () async {
              contentDisposed = false;
              final controller = TextEditingController();
              await showOiDialog<bool>(
                context,
                builder: (_, close) => OiDialog.standard(
                  label: 'Input dialog',
                  content: _DisposalProbe(
                    onDispose: () => contentDisposed = true,
                    child: OiTextInput(controller: controller, label: 'Name'),
                  ),
                  actions: [
                    OiButton.primary(label: 'Done', onTap: () => close(true)),
                  ],
                ),
              );
              completedAfterDisposal = contentDisposed;
              controller.dispose();
              opens++;
            },
          ),
        ),
      );
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.text('Open dialog'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(EditableText));
        await tester.enterText(find.byType(EditableText), 'Focused input');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        expect(completedAfterDisposal, isTrue);
        expect(opens, i + 1);
        expect(find.byType(EditableText), findsNothing);
        expect(tester.takeException(), isNull);
      }
    },
  );
}

class _DisposalProbe extends StatefulWidget {
  const _DisposalProbe({required this.onDispose, required this.child});
  final VoidCallback onDispose;
  final Widget child;
  @override
  State<_DisposalProbe> createState() => _DisposalProbeState();
}

class _DisposalProbeState extends State<_DisposalProbe> {
  @override
  Widget build(BuildContext context) => widget.child;
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }
}
