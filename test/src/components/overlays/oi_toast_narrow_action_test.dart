import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'narrow toast keeps its message and canonical action fully usable',
    (
      tester,
    ) async {
      final anchor = GlobalKey();
      final handles = <OiOverlayHandle>[];
      var actions = 0;
      var dismissals = 0;
      await tester.pumpObers(
        SizedBox.expand(key: anchor),
        surfaceSize: const Size(1200, 800),
      );
      OiOverlayHandle showUploadFailure() => OiToast.show(
        anchor.currentContext!,
        message: 'Upload failed',
        duration: null,
        dismissLabel: 'Schließen',
        onDismiss: () => dismissals++,
        action: OiButton.ghost(
          label: 'Retry upload',
          size: OiButtonSize.small,
          onTap: () => actions++,
        ),
      );
      try {
        handles.add(showUploadFailure());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(
          find.text('Retry upload'),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pump();
        expect(actions, 1);
        expect(dismissals, 0);
        expect(handles.first.isDismissed, isFalse);
        await tester.tap(
          find.byType(OiIconButton),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pumpAndSettle();
        expect(dismissals, 1);
        expect(handles.first.isDismissed, isTrue);
        expect(find.byType(OiToast), findsNothing);

        await tester.binding.setSurfaceSize(const Size(220, 300));
        tester.view.physicalSize = const Size(220, 300);
        await tester.pump();
        handles.add(showUploadFailure());
        await tester.pumpAndSettle();
        final error = tester.takeException();
        final action = find.byWidgetPredicate(
          (widget) => widget is OiButton && widget.label == 'Retry upload',
        );
        final close = find.byType(OiIconButton);
        final actionRect = tester.getRect(action);
        final closeRect = tester.getRect(close);
        final messageRect = tester.getRect(find.text('Upload failed'));
        List<double> coordinates(Rect rect) => [
          rect.left,
          rect.top,
          rect.width,
          rect.height,
        ];
        debugPrint(
          jsonEncode({
            'narrowAction': {
              'viewport': [220, 300],
              'dpr': tester.view.devicePixelRatio,
              'error': error?.toString(),
              'toast': coordinates(tester.getRect(find.byType(OiToast))),
              'action': coordinates(actionRect),
              'close': coordinates(closeRect),
              'message': coordinates(messageRect),
              'widePositiveControl': {
                'actions': actions,
                'dismissals': dismissals,
              },
            },
          }),
        );
        expect(tester.widget<OiIconButton>(close).semanticLabel, 'Schließen');
        await tester.tap(
          find.text('Retry upload'),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pump();
        expect(actions, 2);
        expect(dismissals, 1);
        expect(handles.last.isDismissed, isFalse);
        await tester.tap(close, kind: PointerDeviceKind.mouse);
        await tester.pumpAndSettle();
        expect(dismissals, 2);
        expect(handles.last.isDismissed, isTrue);
        debugPrint(
          jsonEncode({
            'narrowPositiveControl': {
              'actions': actions,
              'dismissals': dismissals,
            },
          }),
        );
        expect(
          error,
          isNull,
          reason: 'A real action must not overflow the toast',
        );
        const viewport = Rect.fromLTWH(0, 0, 220, 300);
        for (final rect in [actionRect, closeRect, messageRect]) {
          expect(rect.width, greaterThan(0));
          expect(viewport.contains(rect.topLeft), isTrue);
          expect(viewport.contains(rect.bottomRight), isTrue);
        }
        expect(actionRect.overlaps(closeRect), isFalse);
        expect(tester.takeException(), isNull);
      } finally {
        for (final handle in handles) {
          handle.dismiss();
        }
        await tester.pump();
      }
      expect(handles.every((handle) => handle.isDismissed), isTrue);
      expect(find.byType(OiToast), findsNothing);
    },
  );
}
