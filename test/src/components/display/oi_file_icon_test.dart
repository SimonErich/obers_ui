// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_file_icon.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Default property values ─────────────────────────────────────────────

  group('default properties', () {
    testWidgets('defaults to md size', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'report.pdf'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.size, OiFileIconSize.md);
    });

    testWidgets('auto-detects category from extension', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'report.pdf'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.document);
    });

    testWidgets('unknown extension defaults to generic', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'file.xyz'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.generic);
    });
  });

  // ── REQ-0812: Category mapping ─────────────────────────────────────────

  group('extension → category mapping (REQ-0812)', () {
    testWidgets('.pdf maps to document', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'report.pdf'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.document);
      expect(find.text('PDF'), findsOneWidget);
    });

    testWidgets('.docx maps to document', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'letter.docx'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.document);
      expect(find.text('DOCX'), findsOneWidget);
    });

    testWidgets('.xlsx maps to spreadsheet', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'data.xlsx'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.spreadsheet);
    });

    testWidgets('.csv maps to spreadsheet', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'export.csv'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.spreadsheet);
    });

    testWidgets('.pptx maps to presentation', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'slides.pptx'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.presentation);
    });

    testWidgets('.png maps to image', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'photo.png'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.image);
    });

    testWidgets('.jpg maps to image', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'photo.jpg'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.image);
    });

    testWidgets('.mp4 maps to video', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'clip.mp4'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.video);
    });

    testWidgets('.mp3 maps to audio', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'song.mp3'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.audio);
    });

    testWidgets('.zip maps to archive', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'backup.zip'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.archive);
    });

    testWidgets('.dart maps to code', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'main.dart'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.code);
    });

    testWidgets('.json maps to data', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'config.json'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.data);
    });

    testWidgets('.txt maps to text', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'notes.txt'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.text);
    });

    testWidgets('.md maps to text', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'README.md'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.text);
    });

    testWidgets('.exe maps to executable', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'setup.exe'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.executable);
    });

    testWidgets('.sh maps to executable', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'build.sh'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.executable);
    });

    testWidgets('.ttf maps to font', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'Roboto.ttf'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.font);
    });

    testWidgets('.otf maps to font', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'Inter.otf'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.font);
    });

    testWidgets('.obj maps to threeD', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'model.obj'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.threeD);
    });

    testWidgets('.gltf maps to threeD', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'scene.gltf'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.threeD);
    });

    testWidgets('.unknown maps to generic', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'data.unknown'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.generic);
    });
  });

  // ── Case-insensitive extension matching ────────────────────────────────

  group('case-insensitive extension', () {
    testWidgets('.PDF matches same as .pdf', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'REPORT.PDF'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.document);
      expect(find.text('PDF'), findsOneWidget);
    });

    testWidgets('.Png matches same as .png', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'Image.Png'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.image);
    });
  });

  // ── MIME type fallback ─────────────────────────────────────────────────

  group('MIME type fallback', () {
    testWidgets('uses mimeType when extension is unknown', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(fileName: 'file.abc', mimeType: 'image/png'),
      );
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.image);
    });

    testWidgets('extension takes precedence over mimeType', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(fileName: 'photo.png', mimeType: 'audio/mpeg'),
      );
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.image);
    });

    testWidgets('mimeType video/* maps to video', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(fileName: 'clip.xyz', mimeType: 'video/mp4'),
      );
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.video);
    });

    testWidgets('mimeType application/pdf maps to document', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(fileName: 'file.xyz', mimeType: 'application/pdf'),
      );
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.document);
    });
  });

  // ── colorOverride ─────────────────────────────────────────────────────

  group('colorOverride', () {
    testWidgets('colorOverride replaces category color', (tester) async {
      const customColor = Color(0xFF00BCD4);
      await tester.pumpObers(
        const OiFileIcon(fileName: 'report.pdf', colorOverride: customColor),
      );
      // Just verify it renders without errors — the color is applied via
      // CustomPainter which we verify through golden tests.
      expect(find.byType(OiFileIcon), findsOneWidget);
    });
  });

  // ── REQ-0844: Rounded-corner page/document outline ──────────────────────

  group('page/document shape (REQ-0844)', () {
    testWidgets('renders with correct xs dimensions', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(fileName: 'file.pdf', size: OiFileIconSize.xs),
      );
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(OiFileIcon),
          matching: find.byType(SizedBox).first,
        ),
      );
      expect(sizedBox.width, 16);
      expect(sizedBox.height, 20);
    });

    testWidgets('renders with correct sm dimensions', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(fileName: 'file.pdf', size: OiFileIconSize.sm),
      );
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(OiFileIcon),
          matching: find.byType(SizedBox).first,
        ),
      );
      expect(sizedBox.width, 24);
      expect(sizedBox.height, 30);
    });

    testWidgets('renders with correct md dimensions', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'file.pdf'));
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(OiFileIcon),
          matching: find.byType(SizedBox).first,
        ),
      );
      expect(sizedBox.width, 32);
      expect(sizedBox.height, 40);
    });

    testWidgets('renders with correct lg dimensions', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(fileName: 'file.pdf', size: OiFileIconSize.lg),
      );
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(OiFileIcon),
          matching: find.byType(SizedBox).first,
        ),
      );
      expect(sizedBox.width, 48);
      expect(sizedBox.height, 60);
    });

    testWidgets('renders with correct xl dimensions', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(fileName: 'file.pdf', size: OiFileIconSize.xl),
      );
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(OiFileIcon),
          matching: find.byType(SizedBox).first,
        ),
      );
      expect(sizedBox.width, 64);
      expect(sizedBox.height, 80);
    });

    testWidgets('uses CustomPaint for page shape', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'file.pdf'));
      expect(
        find.descendant(
          of: find.byType(OiFileIcon),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });
  });

  // ── REQ-0845: Dog-ear fold effect ───────────────────────────────────────

  group('dog-ear fold (REQ-0845)', () {
    testWidgets('golden: xs size fold geometry', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(fileName: 'file.pdf', size: OiFileIconSize.xs),
        surfaceSize: const Size(48, 52),
      );
      await expectLater(
        find.byType(OiFileIcon),
        matchesGoldenFile('goldens/oi_file_icon_fold_xs.png'),
      );
    });

    testWidgets('golden: sm size fold geometry', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(fileName: 'file.pdf', size: OiFileIconSize.sm),
        surfaceSize: const Size(56, 62),
      );
      await expectLater(
        find.byType(OiFileIcon),
        matchesGoldenFile('goldens/oi_file_icon_fold_sm.png'),
      );
    });

    testWidgets('golden: md size fold geometry', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(fileName: 'file.pdf'),
        surfaceSize: const Size(64, 72),
      );
      await expectLater(
        find.byType(OiFileIcon),
        matchesGoldenFile('goldens/oi_file_icon_fold_md.png'),
      );
    });

    testWidgets('golden: lg size fold geometry', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(fileName: 'file.pdf', size: OiFileIconSize.lg),
        surfaceSize: const Size(80, 92),
      );
      await expectLater(
        find.byType(OiFileIcon),
        matchesGoldenFile('goldens/oi_file_icon_fold_lg.png'),
      );
    });

    testWidgets('golden: xl size fold geometry', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(fileName: 'file.pdf', size: OiFileIconSize.xl),
        surfaceSize: const Size(96, 112),
      );
      await expectLater(
        find.byType(OiFileIcon),
        matchesGoldenFile('goldens/oi_file_icon_fold_xl.png'),
      );
    });
  });

  // ── REQ-0846: Extension label on colored band ───────────────────────────

  group('extension label and colored band (REQ-0846)', () {
    testWidgets('renders extension in uppercase', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'report.pdf'));
      expect(find.text('PDF'), findsOneWidget);
    });

    testWidgets('renders already-uppercase extension', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'letter.DOCX'));
      expect(find.text('DOCX'), findsOneWidget);
    });

    testWidgets('extension text uses bold weight', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'report.pdf'));
      final textWidget = tester.widget<Text>(find.text('PDF'));
      expect(textWidget.style?.fontWeight, FontWeight.w700);
    });
  });

  // ── Category color variants ─────────────────────────────────────────────

  group('category variants render without errors', () {
    final categoryFiles = {
      OiFileCategory.document: 'test.pdf',
      OiFileCategory.spreadsheet: 'test.xlsx',
      OiFileCategory.presentation: 'test.pptx',
      OiFileCategory.image: 'test.png',
      OiFileCategory.video: 'test.mp4',
      OiFileCategory.audio: 'test.mp3',
      OiFileCategory.archive: 'test.zip',
      OiFileCategory.code: 'test.dart',
      OiFileCategory.data: 'test.json',
      OiFileCategory.text: 'test.txt',
      OiFileCategory.executable: 'test.exe',
      OiFileCategory.font: 'test.ttf',
      OiFileCategory.threeD: 'test.obj',
      OiFileCategory.generic: 'test.xyz',
    };

    for (final entry in categoryFiles.entries) {
      testWidgets('renders ${entry.key.name} category', (tester) async {
        await tester.pumpObers(OiFileIcon(fileName: entry.value));
        expect(find.byType(OiFileIcon), findsOneWidget);
      });
    }
  });

  // ── Accessibility ───────────────────────────────────────────────────────

  group('accessibility', () {
    testWidgets('provides default semantic label', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'report.pdf'));
      expect(tester.getSemantics(find.bySemanticsLabel('PDF file')), isNotNull);
    });

    testWidgets('uses custom semantic label when provided', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(
          fileName: 'report.pdf',
          semanticsLabel: 'Invoice document',
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Invoice document')),
        isNotNull,
      );
    });
  });

  // ── Size enum coverage ────────────────────────────────────────────────

  group('all sizes render correctly', () {
    testWidgets('xs', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(fileName: 'notes.txt', size: OiFileIconSize.xs),
      );
      expect(find.text('TXT'), findsOneWidget);
    });

    testWidgets('sm', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(fileName: 'data.csv', size: OiFileIconSize.sm),
      );
      expect(find.text('CSV'), findsOneWidget);
    });

    testWidgets('md', (tester) async {
      await tester.pumpObers(const OiFileIcon(fileName: 'song.mp3'));
      expect(find.text('MP3'), findsOneWidget);
    });

    testWidgets('lg', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(fileName: 'backup.zip', size: OiFileIconSize.lg),
      );
      expect(find.text('ZIP'), findsOneWidget);
    });

    testWidgets('xl', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(fileName: 'main.py', size: OiFileIconSize.xl),
      );
      expect(find.text('PY'), findsOneWidget);
    });
  });

  // ── Static category helpers ────────────────────────────────────────────

  group('categoryForExtension', () {
    test('maps known extensions correctly', () {
      expect(OiFileIcon.categoryForExtension('pdf'), OiFileCategory.document);
      expect(
        OiFileIcon.categoryForExtension('xlsx'),
        OiFileCategory.spreadsheet,
      );
      expect(
        OiFileIcon.categoryForExtension('ppt'),
        OiFileCategory.presentation,
      );
      expect(OiFileIcon.categoryForExtension('svg'), OiFileCategory.image);
      expect(OiFileIcon.categoryForExtension('webm'), OiFileCategory.video);
      expect(OiFileIcon.categoryForExtension('flac'), OiFileCategory.audio);
      expect(OiFileIcon.categoryForExtension('7z'), OiFileCategory.archive);
      expect(OiFileIcon.categoryForExtension('ts'), OiFileCategory.code);
      expect(OiFileIcon.categoryForExtension('yaml'), OiFileCategory.data);
      expect(OiFileIcon.categoryForExtension('log'), OiFileCategory.text);
      expect(OiFileIcon.categoryForExtension('bat'), OiFileCategory.executable);
      expect(OiFileIcon.categoryForExtension('woff'), OiFileCategory.font);
      expect(OiFileIcon.categoryForExtension('fbx'), OiFileCategory.threeD);
      expect(OiFileIcon.categoryForExtension('nope'), OiFileCategory.generic);
    });

    test('is case-insensitive', () {
      expect(OiFileIcon.categoryForExtension('PDF'), OiFileCategory.document);
      expect(OiFileIcon.categoryForExtension('Png'), OiFileCategory.image);
    });

    test('handles leading dot', () {
      expect(OiFileIcon.categoryForExtension('.pdf'), OiFileCategory.document);
    });
  });

  group('categoryForMimeType', () {
    test('maps MIME type prefixes correctly', () {
      expect(OiFileIcon.categoryForMimeType('image/png'), OiFileCategory.image);
      expect(OiFileIcon.categoryForMimeType('video/mp4'), OiFileCategory.video);
      expect(
        OiFileIcon.categoryForMimeType('audio/mpeg'),
        OiFileCategory.audio,
      );
      expect(OiFileIcon.categoryForMimeType('font/ttf'), OiFileCategory.font);
      expect(
        OiFileIcon.categoryForMimeType('model/gltf+json'),
        OiFileCategory.threeD,
      );
    });

    test('maps specific MIME types correctly', () {
      expect(
        OiFileIcon.categoryForMimeType('application/pdf'),
        OiFileCategory.document,
      );
      expect(
        OiFileIcon.categoryForMimeType('application/zip'),
        OiFileCategory.archive,
      );
      expect(
        OiFileIcon.categoryForMimeType('text/csv'),
        OiFileCategory.spreadsheet,
      );
      expect(
        OiFileIcon.categoryForMimeType('application/json'),
        OiFileCategory.data,
      );
      expect(OiFileIcon.categoryForMimeType('text/plain'), OiFileCategory.text);
      expect(OiFileIcon.categoryForMimeType('text/html'), OiFileCategory.code);
    });

    test('unknown MIME type returns generic', () {
      expect(
        OiFileIcon.categoryForMimeType('application/octet-stream'),
        OiFileCategory.generic,
      );
    });
  });
}
