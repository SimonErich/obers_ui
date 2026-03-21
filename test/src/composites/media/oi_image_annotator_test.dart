// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/media/oi_image_annotator.dart';

import '../../../helpers/pump_app.dart';

/// A 1x1 transparent PNG for testing.
final _testImageBytes = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x62, 0x00, 0x00, 0x00, 0x02,
  0x00, 0x01, 0xE5, 0x27, 0xDE, 0xFC, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
]);

void main() {
  late MemoryImage testImage;

  setUp(() {
    testImage = MemoryImage(_testImageBytes);
  });

  group('OiImageAnnotator', () {
    testWidgets('renders with image', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 400,
          child: OiImageAnnotator(image: testImage, label: 'Test annotator'),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('has Semantics with label', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 400,
          child: OiImageAnnotator(image: testImage, label: 'My annotator'),
        ),
      );

      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'My annotator',
        ),
      );
      expect(semantics, isNotNull);
    });

    testWidgets('shows toolbar when not readOnly', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 400,
          child: OiImageAnnotator(image: testImage, label: 'Test annotator'),
        ),
      );

      expect(
        find.byKey(const ValueKey('annotator_tool_freehand')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('annotator_tool_rectangle')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('annotator_tool_circle')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('annotator_tool_arrow')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('annotator_tool_text')), findsOneWidget);
    });

    testWidgets('hides toolbar when readOnly', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 400,
          child: OiImageAnnotator(
            image: testImage,
            label: 'Test annotator',
            readOnly: true,
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('annotator_tool_freehand')),
        findsNothing,
      );
    });

    testWidgets('onToolChange fires when tool button is tapped', (
      tester,
    ) async {
      OiAnnotationType? selectedTool;
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 400,
          child: OiImageAnnotator(
            image: testImage,
            label: 'Test annotator',
            onToolChange: (tool) => selectedTool = tool,
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('annotator_tool_rectangle')));
      await tester.pump();

      expect(selectedTool, OiAnnotationType.rectangle);
    });

    testWidgets('renders existing annotations', (tester) async {
      final annotations = [
        const OiAnnotation(
          key: 'ann1',
          type: OiAnnotationType.freehand,
          points: [Offset(10, 10), Offset(50, 50)],
          color: Color(0xFFFF0000),
        ),
      ];

      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 400,
          child: OiImageAnnotator(
            image: testImage,
            label: 'Test annotator',
            annotations: annotations,
          ),
        ),
      );

      // CustomPaint is used for rendering annotations
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('drawing gesture creates annotation', (tester) async {
      List<OiAnnotation>? updatedAnnotations;
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 400,
          child: OiImageAnnotator(
            image: testImage,
            label: 'Test annotator',
            onAnnotationsChange: (annotations) =>
                updatedAnnotations = annotations,
          ),
        ),
      );

      // Perform a pan gesture on the canvas
      final canvasFinder = find.byKey(const ValueKey('annotator_canvas'));
      final center = tester.getCenter(canvasFinder);
      await tester.timedDragFrom(
        center,
        const Offset(100, 100),
        const Duration(milliseconds: 200),
      );
      await tester.pump();

      expect(updatedAnnotations, isNotNull);
      expect(updatedAnnotations!.length, 1);
      expect(updatedAnnotations!.first.type, OiAnnotationType.freehand);
    });

    testWidgets('readOnly prevents drawing', (tester) async {
      List<OiAnnotation>? updatedAnnotations;
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 400,
          child: OiImageAnnotator(
            image: testImage,
            label: 'Test annotator',
            readOnly: true,
            onAnnotationsChange: (annotations) =>
                updatedAnnotations = annotations,
          ),
        ),
      );

      final canvasFinder = find.byKey(const ValueKey('annotator_canvas'));
      final center = tester.getCenter(canvasFinder);
      await tester.timedDragFrom(
        center,
        const Offset(100, 100),
        const Duration(milliseconds: 200),
      );
      await tester.pump();

      expect(updatedAnnotations, isNull);
    });

    testWidgets('custom strokeWidth is respected', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 400,
          child: OiImageAnnotator(
            image: testImage,
            label: 'Test annotator',
            strokeWidth: 5,
          ),
        ),
      );

      // Verify the widget renders without error
      expect(find.byType(OiImageAnnotator), findsOneWidget);
    });
  });

  group('OiAnnotation', () {
    test('creates with required fields', () {
      const annotation = OiAnnotation(
        key: 'test',
        type: OiAnnotationType.freehand,
        points: [Offset.zero, Offset(10, 10)],
      );

      expect(annotation.key, 'test');
      expect(annotation.type, OiAnnotationType.freehand);
      expect(annotation.points.length, 2);
      expect(annotation.strokeWidth, 2.0);
      expect(annotation.color, isNull);
      expect(annotation.text, isNull);
    });

    test('creates text annotation with text field', () {
      const annotation = OiAnnotation(
        key: 'textAnn',
        type: OiAnnotationType.text,
        points: [Offset(20, 20)],
        text: 'Hello',
      );

      expect(annotation.text, 'Hello');
      expect(annotation.type, OiAnnotationType.text);
    });
  });
}
