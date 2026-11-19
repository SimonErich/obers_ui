// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_axis_painter.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_canvas.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';

const _plotBounds = Rect.fromLTWH(200, 0, 200, 200);
const _style = TextStyle(fontSize: 10);

// The test font draws every glyph as a square, so this label is 200 wide.
const _longLabel = 'AAAAAAAAAAAAAAAAAAAA';

/// Paints [painter] and returns the paragraph it drew with its offset.
({ui.Paragraph paragraph, Offset offset}) _paintLabel(
  OiChartLabelPainter painter,
) {
  final canvas = TestRecordingCanvas();
  painter.paint(
    OiChartCanvasContext(
      canvas: canvas,
      size: const Size(400, 200),
      viewport: const OiChartViewport(size: Size(400, 200)),
      plotBounds: _plotBounds,
      devicePixelRatio: 1,
    ),
  );
  final call = canvas.invocations.singleWhere(
    (i) => i.invocation.memberName == #drawParagraph,
  );
  final args = call.invocation.positionalArguments;
  return (paragraph: args[0] as ui.Paragraph, offset: args[1] as Offset);
}

OiChartLabelPainter _painter({
  double maxLabelWidth = 80,
  TextDirection textDirection = TextDirection.ltr,
}) {
  return OiChartLabelPainter(
    edge: OiChartAxisEdge.left,
    labels: const [_longLabel],
    tickPositions: const [100],
    labelStyle: _style,
    labelGap: 0,
    maxLabelWidth: maxLabelWidth,
    textDirection: textDirection,
  );
}

void main() {
  setUp(OiChartLabelPainter.clearCache);
  tearDown(OiChartLabelPainter.clearCache);

  group('OiChartLabelPainter text cache', () {
    test('two axes with different maxLabelWidth lay out separately', () {
      final narrow = _paintLabel(_painter());
      final wide = _paintLabel(_painter(maxLabelWidth: 300));

      // A left-edge label ends at the plot edge, so its x offset is the
      // plot edge minus its laid-out width.
      expect(_plotBounds.left - narrow.offset.dx, lessThanOrEqualTo(80));
      expect(_plotBounds.left - wide.offset.dx, 200);
    });

    test('the same label, style and width reuse one layout', () {
      final first = _paintLabel(_painter());
      final second = _paintLabel(_painter());

      expect(identical(first.paragraph, second.paragraph), isTrue);
    });

    test('text direction is part of the cache key', () {
      final ltr = _paintLabel(_painter());
      final rtl = _paintLabel(_painter(textDirection: TextDirection.rtl));

      expect(identical(ltr.paragraph, rtl.paragraph), isFalse);
    });
  });

  group('OiChartLabelPainter.shouldRepaint', () {
    test('is true when the text direction changes', () {
      expect(
        _painter(textDirection: TextDirection.rtl).shouldRepaint(_painter()),
        isTrue,
      );
      expect(_painter().shouldRepaint(_painter()), isFalse);
    });
  });
}
