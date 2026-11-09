import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/paint_pixels.dart';

const ValueKey<String> _anchor = ValueKey('toast-fallback-anchor');
const ValueKey<String> _raster = ValueKey('toast-fallback-raster');
const _frame = Size(1200, 800);
const _backing = Color(0xff050607);

Future<OverlayEntry> _pumpHost(
  WidgetTester tester, {
  OiThemeData? theme,
}) async {
  // pumpObers/capturePaint install OiApp, which would bypass this fallback.
  tester.view.physicalSize = _frame;
  tester.view.devicePixelRatio = 1;
  final entry = OverlayEntry(
    builder: (_) => const ColoredBox(key: _anchor, color: _backing),
  );
  await tester.pumpWidget(
    RepaintBoundary(
      key: _raster,
      child: OiTheme(
        data: theme ?? OiThemeData.light(),
        child: OiDensityScope(
          density: OiDensity.compact,
          child: OiPlatform(
            data: const OiPlatformData(
              platform: TargetPlatform.linux,
              keyboardHeight: 0,
              keyboardVisible: false,
              inputModality: OiInputModality.pointer,
            ),
            child: MediaQuery(
              data: const MediaQueryData(size: _frame, disableAnimations: true),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontFamily: 'Ahem',
                    fontSize: 14,
                    height: 1,
                  ),
                  child: Overlay(initialEntries: [entry]),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  expect(OiOverlays.maybeOf(tester.element(find.byKey(_anchor))), isNull);
  return entry;
}

Future<void> _unmount(
  WidgetTester tester,
  OverlayEntry anchor,
  List<OiOverlayHandle> handles,
) async {
  try {
    for (final handle in handles) {
      handle.dismiss();
    }
    await tester.pump();
    expect(find.byType(OiToast), findsNothing);
  } finally {
    anchor
      ..remove()
      ..dispose();
    await tester.pumpWidget(const SizedBox());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }
}

void main() {
  testWidgets('native Overlay fallback supports actions and localized close', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final anchor = await _pumpHost(tester);
    final handles = <OiOverlayHandle>[];
    var actions = 0;
    var dismissals = 0;
    try {
      final handle = OiToast.show(
        tester.element(find.byKey(_anchor)),
        message: 'Fallback notification',
        duration: null,
        dismissLabel: 'Benachrichtigung schließen',
        action: OiButton.primary(label: 'Retry', onTap: () => actions++),
        onDismiss: () => dismissals++,
      );
      handles.add(handle);
      await tester.pumpAndSettle();
      expect(find.text('Fallback notification'), findsOneWidget);
      expect(handle.isDismissed, isFalse);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(actions, 1);
      expect(dismissals, 0);
      expect(handle.isDismissed, isFalse);
      final close = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Benachrichtigung schließen',
      );
      expect(close, findsOneWidget);
      expect(tester.getSemantics(close).label, 'Benachrichtigung schließen');
      await tester.tap(find.byType(OiIconButton));
      await tester.pumpAndSettle();
      expect(dismissals, 1);
      expect(handle.isDismissed, isTrue);
      expect(find.byType(OiToast), findsNothing);
      handle.dismiss();
      expect(dismissals, 1);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
      await _unmount(tester, anchor, handles);
    }
  });

  testWidgets(
    'fallback manual handle dismissal cancels expiry without callback',
    (
      tester,
    ) async {
      final anchor = await _pumpHost(tester);
      final handles = <OiOverlayHandle>[];
      var dismissals = 0;
      try {
        final handle = OiToast.show(
          tester.element(find.byKey(_anchor)),
          message: 'Manual fallback',
          duration: const Duration(milliseconds: 100),
          onDismiss: () => dismissals++,
        );
        handles.add(handle);
        await tester.pump();
        expect(handle.isDismissed, isFalse);
        expect(find.text('Manual fallback'), findsOneWidget);
        handle
          ..dismiss()
          ..dismiss();
        expect(handle.isDismissed, isTrue);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(dismissals, 0);
        expect(find.byType(OiToast), findsNothing);
        final successor = OiToast.show(
          tester.element(find.byKey(_anchor)),
          message: 'Fallback successor',
          duration: null,
          onDismiss: () => dismissals++,
        );
        handles.add(successor);
        await tester.pumpAndSettle();
        handle
          ..update()
          ..dismiss();
        await tester.pump();
        expect(successor.isDismissed, isFalse);
        expect(find.text('Fallback successor'), findsOneWidget);
        successor.dismiss();
        await tester.pump();
        expect(dismissals, 0);
        expect(tester.takeException(), isNull);
      } finally {
        await _unmount(tester, anchor, handles);
      }
    },
  );

  testWidgets(
    'authored toast theme affects real padding, clip and color pixels',
    (
      tester,
    ) async {
      const background = Color(0xff234567);
      const foreground = Color(0xffedba45);
      const padding = EdgeInsets.fromLTRB(13, 5, 19, 11);
      const radius = BorderRadius.only(
        topLeft: Radius.circular(6),
        topRight: Radius.circular(14),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(10),
      );
      final base = OiThemeData.light();
      final theme = base.copyWith(
        colors: base.colors.copyWith(text: foreground),
        components: base.components.copyWith(
          toast: const OiToastThemeData(
            backgroundColor: background,
            borderRadius: radius,
            padding: padding,
            iconSize: 20,
            gap: 9,
            shadow: [],
          ),
        ),
      );
      final anchor = await _pumpHost(tester, theme: theme);
      final handles = <OiOverlayHandle>[];
      try {
        handles.add(
          OiToast.show(
            tester.element(find.byKey(_anchor)),
            message: 'Themed toast',
            duration: null,
            dismissible: false,
          ),
        );
        await tester.pumpAndSettle();
        final card = tester.getRect(find.byType(OiToast));
        final icon = tester.getRect(find.text('ℹ'));
        final message = tester.getRect(find.text('Themed toast'));
        final content = icon.expandToInclude(message);
        expect(card.width, 400);
        expect(icon.height, 20);
        expect(icon.left - card.left, 1 + 4 + padding.left);
        expect(message.left - icon.right, 9);
        expect(card.right - message.right, 1 + padding.right);
        expect(content.top - card.top, 1 + padding.top);
        expect(card.bottom - content.bottom, 1 + padding.bottom);
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text('Themed toast'),
        );
        expect(paragraph.text.style!.color, foreground);
        final pixels = (await tester.runAsync(() async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(_raster),
          );
          final image = await boundary.toImage();
          final data = await image.toByteData(
            format: ui.ImageByteFormat.rawStraightRgba,
          );
          final result = PaintPixels(
            image.width,
            image.height,
            data!.buffer.asUint8List(),
          );
          image.dispose();
          return result;
        }))!;
        final backgroundSample = pixels.rgba(
          (card.right - 8).floor(),
          card.center.dy.floor(),
        );
        // Outside the authored radius14, but inside the legacy radius8 corner.
        final cornerSample = pixels.rgba(
          (card.right - 3).floor(),
          (card.top + 3).floor(),
        );
        expect(backgroundSample, [35, 69, 103, 255]);
        expect(cornerSample, [5, 6, 7, 255]);
        var foregroundPixels = 0;
        for (var offset = 0; offset < pixels.bytes.length; offset += 4) {
          if (pixels.bytes[offset] == 237 &&
              pixels.bytes[offset + 1] == 186 &&
              pixels.bytes[offset + 2] == 69 &&
              pixels.bytes[offset + 3] == 255) {
            foregroundPixels++;
          }
        }
        expect(foregroundPixels, greaterThan(0));
        debugPrint(
          jsonEncode({
            'fallbackThemePixels': true,
            'frame': [pixels.width, pixels.height],
            'card': [card.left, card.top, card.width, card.height],
            'icon': [icon.left, icon.top, icon.width, icon.height],
            'message': [
              message.left,
              message.top,
              message.width,
              message.height,
            ],
            'backgroundSample': backgroundSample,
            'cornerSample': cornerSample,
            'foregroundPixels': foregroundPixels,
          }),
        );
        expect(handles.single.isDismissed, isFalse);
        expect(tester.takeException(), isNull);
      } finally {
        await _unmount(tester, anchor, handles);
      }
    },
  );
}
