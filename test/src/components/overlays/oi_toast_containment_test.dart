import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('twelve default toasts fit a normal viewport and all clean up', (
    tester,
  ) async {
    final context = await _pumpContext(tester);
    final handles = <OiOverlayHandle>[];
    try {
      for (var i = 0; i < 12; i++) {
        handles.add(
          OiToast.show(
            context,
            message: 'Notification $i',
            duration: const Duration(seconds: 60),
          ),
        );
      }
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(OiToast), findsNWidgets(12));
      expect(handles.every((handle) => !handle.isDismissed), isTrue);
    } finally {
      await _dismissAll(tester, handles);
    }
    expect(handles.every((handle) => handle.isDismissed), isTrue);
    expect(find.byType(OiToast), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fourteen non-dismissible toasts fit and all clean up', (
    tester,
  ) async {
    final context = await _pumpContext(tester);
    final handles = <OiOverlayHandle>[];
    try {
      for (var i = 0; i < 14; i++) {
        handles.add(
          OiToast.show(
            context,
            message: 'Notification $i',
            duration: const Duration(seconds: 60),
            dismissible: false,
          ),
        );
      }
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(OiToast), findsNWidgets(14));
      expect(find.byType(OiIconButton), findsNothing);
    } finally {
      await _dismissAll(tester, handles);
    }
    expect(handles.every((handle) => handle.isDismissed), isTrue);
    expect(find.byType(OiToast), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final position in OiToastPosition.values) {
    testWidgets(
      '${position.name} keeps every action and localized close reachable',
      (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        final context = await _pumpContext(tester);
        final handles = <OiOverlayHandle>[];
        final actions = <int>[];
        final dismissed = <int>[];
        try {
          for (var i = 0; i < 12; i++) {
            handles.add(
              OiToast.show(
                context,
                message: 'Notification $i',
                position: position,
                duration: const Duration(seconds: 60),
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
          final isTop = position.name.startsWith('top');
          final initial = isTop ? 0 : 11;
          final distant = isTop ? 11 : 0;
          expect(
            find.text('Notification $initial').hitTestable(),
            findsOneWidget,
          );
          expect(
            find.text('Notification $distant').hitTestable(),
            findsNothing,
          );
          final scroll = find.byType(SingleChildScrollView);
          expect(tester.getSize(scroll).width, 400);
          await tester.drag(scroll, Offset(0, isTop ? -500 : 500));
          await tester.pumpAndSettle();
          expect(
            find.text('Notification $distant').hitTestable(),
            findsOneWidget,
          );
          await tester.drag(scroll, Offset(0, isTop ? 500 : -500));
          await tester.pumpAndSettle();
          expect(
            find.text('Notification $initial').hitTestable(),
            findsOneWidget,
          );

          for (var i = 0; i < 12; i++) {
            await tester.ensureVisible(find.text('Undo $i'));
            await tester.pumpAndSettle();
            await tester.tap(find.text('Undo $i'));
            await tester.pumpAndSettle();
            expect(actions, List.generate(i + 1, (index) => index));
            final close = find.descendant(
              of: _toast(i),
              matching: find.byType(OiIconButton),
            );
            await tester.ensureVisible(close);
            await tester.pumpAndSettle();
            final labeledClose = find.bySemanticsLabel('Schließen $i');
            expect(labeledClose.hitTestable(), findsOneWidget);
            await tester.tap(labeledClose);
            await tester.pumpAndSettle();
            expect(dismissed, List.generate(i + 1, (index) => index));
            expect(_toast(i), findsNothing);
          }
          expect(find.byType(OiToast), findsNothing);
        } finally {
          await _dismissAll(tester, handles);
          semantics.dispose();
        }
        expect(dismissed, hasLength(12));
        expect(handles.every((handle) => handle.isDismissed), isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final position in OiToastPosition.values) {
    testWidgets(
      '${position.name} preserves small-stack geometry and outside taps',
      (tester) async {
        var underlying = 0;
        var dismissed = 0;
        final isTop = position.name.startsWith('top');
        final context = await _pumpContext(
          tester,
          child: Stack(
            children: [
              Positioned(
                left: 16,
                top: isTop ? 32 : 728,
                child: OiButton.primary(
                  label: 'Left control',
                  onTap: () => underlying++,
                ),
              ),
              Positioned(
                right: 16,
                top: isTop ? 32 : 728,
                child: OiButton.primary(
                  label: 'Right control',
                  onTap: () => underlying++,
                ),
              ),
            ],
          ),
        );
        final handle = OiToast.show(
          context,
          message: 'Notification 0',
          position: position,
          duration: const Duration(seconds: 60),
          onDismiss: () => dismissed++,
        );
        try {
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final x = switch (position) {
            OiToastPosition.topLeft || OiToastPosition.bottomLeft => 16.0,
            OiToastPosition.topCenter || OiToastPosition.bottomCenter => 400.0,
            OiToastPosition.topRight || OiToastPosition.bottomRight => 784.0,
          };
          expect(
            tester.getRect(find.byType(OiToast)),
            Rect.fromLTWH(x, isTop ? 16 : 714, 400, 62),
          );
          expect(
            tester.getSize(find.byType(SingleChildScrollView)),
            const Size(400, 70),
          );
          final isLeft =
              position == OiToastPosition.topLeft ||
              position == OiToastPosition.bottomLeft;
          await tester.tap(
            find.text(isLeft ? 'Right control' : 'Left control'),
          );
          await tester.pumpAndSettle();
          expect(underlying, 1);
          expect(dismissed, 0);
          await tester.tap(find.byType(OiIconButton));
          await tester.pumpAndSettle();
          expect(dismissed, 1);
          expect(find.byType(OiToast), findsNothing);
        } finally {
          await _dismissAll(tester, [handle]);
        }
        expect(dismissed, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'two long toasts survive a narrow resize with every close reachable',
    (tester) async {
      final context = await _pumpContext(tester);
      final messages = List.generate(
        2,
        (index) =>
            'Notification $index has a long description '
            'that must wrap without losing its accessible close control when the window becomes narrow.',
      );
      final handles = <OiOverlayHandle>[];
      final dismissed = <int>[];
      try {
        for (var i = 0; i < 2; i++) {
          handles.add(
            OiToast.show(
              context,
              message: messages[i],
              duration: null,
              dismissLabel: 'Cerrar $i',
              onDismiss: () => dismissed.add(i),
            ),
          );
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.binding.setSurfaceSize(const Size(220, 300));
        tester.view.physicalSize = const Size(220, 300);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(OiToast), findsNWidgets(2));
        expect(
          tester.getSize(find.byType(SingleChildScrollView)),
          const Size(188, 284),
        );
        for (var i = 0; i < 2; i++) {
          final toast = find.byWidgetPredicate(
            (widget) => widget is OiToast && widget.message == messages[i],
          );
          expect(tester.getSize(toast).width, 188);
          expect(find.text(messages[i]), findsOneWidget);
          final close = find.descendant(
            of: toast,
            matching: find.byType(OiIconButton),
          );
          await tester.ensureVisible(close);
          await tester.pumpAndSettle();
          expect(close.hitTestable(), findsOneWidget);
          await tester.tap(close);
          await tester.pumpAndSettle();
          expect(dismissed, List.generate(i + 1, (index) => index));
        }
        expect(find.byType(OiToast), findsNothing);
      } finally {
        await _dismissAll(tester, handles);
      }
      expect(dismissed, [0, 1]);
      expect(handles.every((handle) => handle.isDismissed), isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}

Finder _toast(int index) => find.byWidgetPredicate(
  (widget) => widget is OiToast && widget.message == 'Notification $index',
);

Future<BuildContext> _pumpContext(
  WidgetTester tester, {
  Size size = const Size(1200, 800),
  Widget? child,
}) async {
  final anchor = GlobalKey();
  await tester.pumpObers(
    SizedBox.expand(key: anchor, child: child),
    surfaceSize: size,
  );
  return anchor.currentContext!;
}

Future<void> _dismissAll(
  WidgetTester tester,
  List<OiOverlayHandle> handles,
) async {
  for (final handle in handles) {
    handle.dismiss();
  }
  await tester.pump();
}
