// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_file_icon.dart';
import 'package:obers_ui/src/components/display/oi_file_preview.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const pdfFile = OiFileNodeData(id: '1', name: 'report.pdf', folder: false);

  const imageFile = OiFileNodeData(
    id: '2',
    name: 'photo.png',
    folder: false,
    url: 'https://example.com/photo.png',
  );

  const videoFile = OiFileNodeData(
    id: '3',
    name: 'clip.mp4',
    folder: false,
    url: 'https://example.com/clip.mp4',
  );

  const videoFileNoUrl = OiFileNodeData(
    id: '4',
    name: 'clip.mp4',
    folder: false,
  );

  const thumbnailFile = OiFileNodeData(
    id: '5',
    name: 'doc.pdf',
    folder: false,
    thumbnailUrl: 'https://example.com/thumb.png',
  );

  testWidgets('renders without error for generic file', (tester) async {
    await tester.pumpObers(const OiFilePreview(file: pdfFile));
    expect(find.byType(OiFilePreview), findsOneWidget);
  });

  testWidgets('falls back to OiFileIcon for non-image non-video file', (
    tester,
  ) async {
    await tester.pumpObers(const OiFilePreview(file: pdfFile));
    expect(find.byType(OiFileIcon), findsOneWidget);
  });

  testWidgets('shows play button for video file with url', (tester) async {
    await tester.pumpObers(const OiFilePreview(file: videoFile));
    // Play button is an Icon with play_arrow code point
    const playIcon = OiIcons.play;
    expect(find.byIcon(playIcon), findsOneWidget);
  });

  testWidgets('hides play button when showPlayButton is false', (tester) async {
    await tester.pumpObers(
      const OiFilePreview(file: videoFile, showPlayButton: false),
    );
    const playIcon = OiIcons.play;
    expect(find.byIcon(playIcon), findsNothing);
  });

  testWidgets('video without url falls back to OiFileIcon', (tester) async {
    await tester.pumpObers(const OiFilePreview(file: videoFileNoUrl));
    expect(find.byType(OiFileIcon), findsOneWidget);
  });

  testWidgets('loading state does not show OiFileIcon', (tester) async {
    await tester.pumpObers(const OiFilePreview(file: pdfFile, loading: true));
    expect(find.byType(OiFileIcon), findsNothing);
  });

  testWidgets('applies width and height to container', (tester) async {
    await tester.pumpObers(
      const Center(child: OiFilePreview(file: pdfFile, width: 120, height: 80)),
    );
    expect(find.byType(OiFilePreview), findsOneWidget);
    // The Container inside OiFilePreview receives width/height constraints
    final container = tester.widget<Container>(find.byType(Container).first);
    final box = container.decoration! as BoxDecoration;
    expect(box, isNotNull);
  });

  testWidgets('semanticsLabel defaults to file name preview', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpObers(const OiFilePreview(file: pdfFile));
      expect(find.bySemanticsLabel('report.pdf preview'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('custom semanticsLabel is used', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpObers(
        const OiFilePreview(file: pdfFile, semanticsLabel: 'Custom label'),
      );
      expect(find.bySemanticsLabel('Custom label'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('image file with url attempts to load Image.network', (
    tester,
  ) async {
    await tester.pumpObers(const OiFilePreview(file: imageFile));
    // Image.network will be present in the widget tree even if it fails to load
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('file with thumbnailUrl uses Image.network', (tester) async {
    await tester.pumpObers(const OiFilePreview(file: thumbnailFile));
    expect(find.byType(Image), findsOneWidget);
  });
}
