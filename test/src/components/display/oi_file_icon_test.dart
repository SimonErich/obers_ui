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
      await tester.pumpObers(const OiFileIcon(extension: 'PDF'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.size, OiFileIconSize.md);
    });

    testWidgets('defaults to generic category', (tester) async {
      await tester.pumpObers(const OiFileIcon(extension: 'PDF'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.generic);
    });
  });

  // ── REQ-0844: Rounded-corner page/document outline ──────────────────────

  group('page/document shape (REQ-0844)', () {
    testWidgets('renders with correct xs dimensions', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(extension: 'PDF', size: OiFileIconSize.xs),
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
        const OiFileIcon(extension: 'PDF', size: OiFileIconSize.sm),
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
      await tester.pumpObers(const OiFileIcon(extension: 'PDF'));
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
        const OiFileIcon(extension: 'PDF', size: OiFileIconSize.lg),
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
        const OiFileIcon(extension: 'PDF', size: OiFileIconSize.xl),
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
      await tester.pumpObers(const OiFileIcon(extension: 'PDF'));
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
        const OiFileIcon(
          extension: 'PDF',
          category: OiFileCategory.document,
          size: OiFileIconSize.xs,
        ),
        surfaceSize: const Size(48, 52),
      );
      await expectLater(
        find.byType(OiFileIcon),
        matchesGoldenFile('goldens/oi_file_icon_fold_xs.png'),
      );
    });

    testWidgets('golden: sm size fold geometry', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(
          extension: 'PDF',
          category: OiFileCategory.document,
          size: OiFileIconSize.sm,
        ),
        surfaceSize: const Size(56, 62),
      );
      await expectLater(
        find.byType(OiFileIcon),
        matchesGoldenFile('goldens/oi_file_icon_fold_sm.png'),
      );
    });

    testWidgets('golden: md size fold geometry', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(
          extension: 'PDF',
          category: OiFileCategory.document,
          size: OiFileIconSize.md,
        ),
        surfaceSize: const Size(64, 72),
      );
      await expectLater(
        find.byType(OiFileIcon),
        matchesGoldenFile('goldens/oi_file_icon_fold_md.png'),
      );
    });

    testWidgets('golden: lg size fold geometry', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(
          extension: 'PDF',
          category: OiFileCategory.document,
          size: OiFileIconSize.lg,
        ),
        surfaceSize: const Size(80, 92),
      );
      await expectLater(
        find.byType(OiFileIcon),
        matchesGoldenFile('goldens/oi_file_icon_fold_lg.png'),
      );
    });

    testWidgets('golden: xl size fold geometry', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(
          extension: 'PDF',
          category: OiFileCategory.document,
          size: OiFileIconSize.xl,
        ),
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
      await tester.pumpObers(const OiFileIcon(extension: 'pdf'));
      expect(find.text('PDF'), findsOneWidget);
    });

    testWidgets('renders already-uppercase extension', (tester) async {
      await tester.pumpObers(const OiFileIcon(extension: 'DOCX'));
      expect(find.text('DOCX'), findsOneWidget);
    });

    testWidgets('extension text uses bold weight', (tester) async {
      await tester.pumpObers(const OiFileIcon(extension: 'pdf'));
      final textWidget = tester.widget<Text>(find.text('PDF'));
      expect(textWidget.style?.fontWeight, FontWeight.w700);
    });
  });

  // ── Category color variants ─────────────────────────────────────────────

  group('category variants render without errors', () {
    for (final cat in OiFileCategory.values) {
      testWidgets('renders ${cat.name} category', (tester) async {
        await tester.pumpObers(OiFileIcon(extension: 'EXT', category: cat));
        expect(find.text('EXT'), findsOneWidget);
      });
    }
  });

  // ── Accessibility ───────────────────────────────────────────────────────

  group('accessibility', () {
    testWidgets('provides default semantic label', (tester) async {
      await tester.pumpObers(const OiFileIcon(extension: 'pdf'));
      expect(tester.getSemantics(find.bySemanticsLabel('PDF file')), isNotNull);
    });

    testWidgets('uses custom semantic label when provided', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(extension: 'pdf', semanticLabel: 'Invoice document'),
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
        const OiFileIcon(
          extension: 'TXT',
          category: OiFileCategory.document,
          size: OiFileIconSize.xs,
        ),
      );
      expect(find.text('TXT'), findsOneWidget);
    });

    testWidgets('sm', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(
          extension: 'CSV',
          category: OiFileCategory.spreadsheet,
          size: OiFileIconSize.sm,
        ),
      );
      expect(find.text('CSV'), findsOneWidget);
    });

    testWidgets('md', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(
          extension: 'MP3',
          category: OiFileCategory.audio,
          size: OiFileIconSize.md,
        ),
      );
      expect(find.text('MP3'), findsOneWidget);
    });

    testWidgets('lg', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(
          extension: 'ZIP',
          category: OiFileCategory.archive,
          size: OiFileIconSize.lg,
        ),
      );
      expect(find.text('ZIP'), findsOneWidget);
    });

    testWidgets('xl', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(
          extension: 'PY',
          category: OiFileCategory.code,
          size: OiFileIconSize.xl,
        ),
      );
      expect(find.text('PY'), findsOneWidget);
    });
  });
}
