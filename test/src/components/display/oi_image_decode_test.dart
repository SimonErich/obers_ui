import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('a thumbnail decodes original bytes within its pixel budget', (
    tester,
  ) async {
    final bytes = await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawRect(
        const ui.Rect.fromLTWH(0, 0, 80, 40),
        ui.Paint()..color = const ui.Color(0xFF123456),
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(80, 40);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      picture.dispose();
      return data!.buffer.asUint8List();
    });
    await tester.pumpObers(
      OiImage.provider(
        provider: MemoryImage(bytes!),
        alt: 'A large imported photo',
        cacheWidth: 20,
        cacheHeight: 20,
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pump();
    final image = tester.widget<RawImage>(find.byType(RawImage)).image!;
    expect(image.width, 20);
    expect(image.height, 10);
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('A large imported photo'), findsOneWidget);
    semantics.dispose();
  });
}
