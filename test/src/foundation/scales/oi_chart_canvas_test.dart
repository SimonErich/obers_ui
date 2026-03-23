// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:ui';

import 'package:flutter/widgets.dart' show EdgeInsets, Key;
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_canvas.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_layer.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_viewport.dart';

import '../../../helpers/pump_app.dart';

// ── Test painters ─────────────────────────────────────────────────────────────

class _RecordingPainter extends OiChartLayerPainter {
  _RecordingPainter({this.id = ''});

  final String id;
  int paintCount = 0;
  OiChartCanvasContext? lastContext;
  bool repaintResult = true;

  @override
  void paint(OiChartCanvasContext context) {
    paintCount++;
    lastContext = context;
  }

  @override
  bool shouldRepaint(covariant _RecordingPainter oldPainter) => repaintResult;
}

class _DrawRectPainter extends OiChartLayerPainter {
  _DrawRectPainter({required this.color});

  final Color color;

  @override
  void paint(OiChartCanvasContext context) {
    context.canvas.drawRect(
      context.plotBounds,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _DrawRectPainter oldPainter) =>
      color != oldPainter.color;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

OiChartViewport _viewport({
  Size size = const Size(400, 300),
  double dpr = 1.0,
}) {
  return OiChartViewport(
    size: size,
    padding: const EdgeInsets.all(16),
    axisInsets: const OiAxisInsets(left: 40, bottom: 24),
    devicePixelRatio: dpr,
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('OiChartCanvasContext', () {
    test('snapToPixel snaps at 1x DPR', () {
      const ctx = OiChartCanvasContext(
        canvas: null as dynamic,
        size: Size(400, 300),
        viewport: OiChartViewport(size: Size(400, 300)),
        plotBounds: Rect.fromLTRB(56, 16, 384, 260),
        devicePixelRatio: 1.0,
      );
      expect(ctx.snapToPixel(10.3), 10.0);
      expect(ctx.snapToPixel(10.7), 11.0);
    });

    test('snapToPixel snaps at 2x DPR', () {
      const ctx = OiChartCanvasContext(
        canvas: null as dynamic,
        size: Size(400, 300),
        viewport: OiChartViewport(size: Size(400, 300)),
        plotBounds: Rect.fromLTRB(56, 16, 384, 260),
        devicePixelRatio: 2.0,
      );
      expect(ctx.snapToPixel(10.3), 10.5);
      expect(ctx.snapToPixel(10.1), 10.0);
    });

    test('snapOffsetToPixel snaps both components', () {
      const ctx = OiChartCanvasContext(
        canvas: null as dynamic,
        size: Size(400, 300),
        viewport: OiChartViewport(size: Size(400, 300)),
        plotBounds: Rect.fromLTRB(56, 16, 384, 260),
        devicePixelRatio: 2.0,
      );
      final snapped = ctx.snapOffsetToPixel(const Offset(10.3, 20.1));
      expect(snapped.dx, 10.5);
      expect(snapped.dy, 20.0);
    });
  });

  group('OiChartCanvas widget', () {
    testWidgets('renders CustomPaint with key', (tester) async {
      final vp = _viewport();
      await tester.pumpObers(
        OiChartCanvas(viewport: vp, layers: const []),
      );
      expect(find.byKey(const Key('oi_chart_canvas')), findsOneWidget);
    });

    testWidgets('paints layers in z-order', (tester) async {
      final painter1 = _RecordingPainter(id: 'first');
      final painter2 = _RecordingPainter(id: 'second');

      final vp = _viewport();
      await tester.pumpObers(
        OiChartCanvas(
          viewport: vp,
          layers: [
            OiChartLayer(
              id: 'overlay',
              role: OiChartLayerRole.overlay,
              painter: painter2,
            ),
            OiChartLayer(
              id: 'grid',
              role: OiChartLayerRole.grid,
              painter: painter1,
            ),
          ],
        ),
      );

      // Both painters should have been called.
      expect(painter1.paintCount, 1);
      expect(painter2.paintCount, 1);
    });

    testWidgets('skips invisible layers', (tester) async {
      final visiblePainter = _RecordingPainter();
      final invisiblePainter = _RecordingPainter();

      final vp = _viewport();
      await tester.pumpObers(
        OiChartCanvas(
          viewport: vp,
          layers: [
            OiChartLayer(
              id: 'visible',
              painter: visiblePainter,
            ),
            OiChartLayer(
              id: 'invisible',
              painter: invisiblePainter,
              visible: false,
            ),
          ],
        ),
      );

      expect(visiblePainter.paintCount, 1);
      expect(invisiblePainter.paintCount, 0);
    });

    testWidgets('skips layers with null painters', (tester) async {
      final vp = _viewport();
      await tester.pumpObers(
        OiChartCanvas(
          viewport: vp,
          layers: [
            OiChartLayer(id: 'empty'),
          ],
        ),
      );
      // Should not throw.
      expect(find.byKey(const Key('oi_chart_canvas')), findsOneWidget);
    });

    testWidgets('provides correct plotBounds to painters', (tester) async {
      final painter = _RecordingPainter();
      final vp = _viewport();

      await tester.pumpObers(
        OiChartCanvas(
          viewport: vp,
          layers: [
            OiChartLayer(id: 'test', painter: painter),
          ],
        ),
      );

      expect(painter.lastContext, isNotNull);
      expect(painter.lastContext!.plotBounds, vp.plotBounds);
      expect(painter.lastContext!.devicePixelRatio, vp.devicePixelRatio);
    });

    testWidgets('provides correct DPR to painters', (tester) async {
      final painter = _RecordingPainter();
      final vp = _viewport(dpr: 3.0);

      await tester.pumpObers(
        OiChartCanvas(
          viewport: vp,
          layers: [
            OiChartLayer(id: 'test', painter: painter),
          ],
        ),
      );

      expect(painter.lastContext!.devicePixelRatio, 3.0);
    });
  });

  group('OiChartLayerPainter', () {
    test('shouldRepaint defaults to true', () {
      final painter = _RecordingPainter();
      expect(painter.shouldRepaint(_RecordingPainter()), isTrue);
    });

    test('shouldRepaint respects override', () {
      final painter = _RecordingPainter()..repaintResult = false;
      expect(painter.shouldRepaint(_RecordingPainter()), isFalse);
    });
  });

  group('_OiChartCanvasPainter shouldRepaint', () {
    test('paints without error on canvas', () {
      final painter = _DrawRectPainter(color: const Color(0xFF000000));
      final vp = _viewport();

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      final context = OiChartCanvasContext(
        canvas: canvas,
        size: vp.size,
        viewport: vp,
        plotBounds: vp.plotBounds,
        devicePixelRatio: vp.devicePixelRatio,
      );

      painter.paint(context);
      recorder.endRecording();
    });
  });
}
