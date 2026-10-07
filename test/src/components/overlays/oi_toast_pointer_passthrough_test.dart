import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  for (final position in OiToastPosition.values) {
    testWidgets('${position.name} preserves gap, card and scroll pointers', (
      tester,
    ) async {
      final target = ValueNotifier(Offset.zero);
      final anchor = GlobalKey();
      var underlyingTaps = 0;
      final actions = <int>[];
      final dismissed = <int>[];
      final handles = <OiOverlayHandle>[];
      await tester.pumpObers(
        Stack(
          fit: StackFit.expand,
          children: [
            SizedBox.expand(key: anchor),
            ValueListenableBuilder(
              valueListenable: target,
              builder: (context, point, child) => Positioned(
                left: point.dx - 90,
                top: point.dy - 18,
                width: 200,
                height: 48,
                child: OiButton.primary(
                  label: 'Gap',
                  onTap: () => underlyingTaps++,
                ),
              ),
            ),
          ],
        ),
        surfaceSize: const Size(1200, 800),
      );
      final context = anchor.currentContext!;
      final underlying = find.byWidgetPredicate(
        (widget) => widget is OiButton && widget.label == 'Gap',
      );
      Finder toast(int index) => find.byWidgetPredicate(
        (widget) => widget is OiToast && widget.message == 'Toast $index',
      );
      Finder close(int index) => find.descendant(
        of: toast(index),
        matching: find.byType(OiIconButton),
      );
      Future<void> tapThroughUnderlay(Offset point) async {
        target.value = point;
        await tester.pump();
        expect(tester.getRect(underlying).contains(point), isTrue);
        await tester.tapAt(point);
        await tester.pumpAndSettle();
      }

      try {
        for (var i = 0; i < 2; i++) {
          handles.add(
            OiToast.show(
              context,
              message: 'Toast $i',
              position: position,
              duration: null,
              dismissLabel: 'Schließen $i',
              onDismiss: () => dismissed.add(i),
              action: OiButton.ghost(
                label: 'Undo $i',
                size: OiButtonSize.small,
                onTap: () => actions.add(i),
              ),
            ),
          );
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final first = tester.getRect(toast(0));
        final last = tester.getRect(toast(1));
        final interEntry = Offset(first.left + 90, first.bottom + 4);
        final trailing = Offset(last.left + 90, last.bottom + 4);
        expect(interEntry.dy, lessThan(last.top));
        for (final point in [interEntry, trailing]) {
          expect(first.contains(point) || last.contains(point), isFalse);
          final before = underlyingTaps;
          await tapThroughUnderlay(point);
          expect(underlyingTaps, before + 1);
        }

        await tapThroughUnderlay(tester.getCenter(find.text('Toast 0')));
        expect(underlyingTaps, 2);
        expect(actions, isEmpty);
        expect(dismissed, isEmpty);
        await tapThroughUnderlay(tester.getCenter(find.text('Undo 0')));
        expect(underlyingTaps, 2);
        expect(actions, [0]);
        expect(
          tester.widget<OiIconButton>(close(0)).semanticLabel,
          'Schließen 0',
        );
        await tapThroughUnderlay(tester.getCenter(close(0)));
        expect(underlyingTaps, 2);
        expect(dismissed, [0]);
        expect(handles.first.isDismissed, isTrue);
        handles.last.dismiss();
        await tester.pump();
        actions.clear();
        dismissed.clear();

        for (var i = 0; i < 12; i++) {
          handles.add(
            OiToast.show(
              context,
              message: 'Toast $i',
              position: position,
              duration: null,
              dismissLabel: 'Schließen $i',
              onDismiss: () => dismissed.add(i),
              action: OiButton.ghost(
                label: 'Undo $i',
                size: OiButtonSize.small,
                onTap: () => actions.add(i),
              ),
            ),
          );
        }
        await tester.pumpAndSettle();
        final isTop = position.name.startsWith('top');
        final initial = isTop ? 0 : 11;
        final distant = isTop ? 11 : 0;
        expect(find.text('Toast $initial').hitTestable(), findsOneWidget);
        expect(find.text('Toast $distant').hitTestable(), findsNothing);
        await tester.drag(
          find.text('Toast $initial'),
          Offset(0, isTop ? -500 : 500),
        );
        await tester.pumpAndSettle();
        expect(find.text('Toast $distant').hitTestable(), findsOneWidget);
        await tester.tap(find.text('Undo $distant'));
        await tester.pumpAndSettle();
        expect(actions, [distant]);
        await tester.tap(close(distant));
        await tester.pumpAndSettle();
        expect(dismissed, [distant]);
        expect(handles[distant + 2].isDismissed, isTrue);
        expect(underlyingTaps, 2);
        expect(tester.takeException(), isNull);
      } finally {
        for (final handle in handles) {
          handle.dismiss();
        }
        await tester.pump();
        await tester.pumpObers(const SizedBox.shrink());
        target.dispose();
      }
      expect(handles.every((handle) => handle.isDismissed), isTrue);
      expect(find.byType(OiToast), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
