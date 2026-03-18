// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_file_icon.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Default property values ─────────────────────────────────────────────

  group('default properties', () {
    testWidgets('defaults to medium size', (tester) async {
      await tester.pumpObers(const OiFileIcon(extension: 'PDF'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.size, OiFileIconSize.medium);
    });

    testWidgets('defaults to generic category', (tester) async {
      await tester.pumpObers(const OiFileIcon(extension: 'PDF'));
      final icon = tester.widget<OiFileIcon>(find.byType(OiFileIcon));
      expect(icon.category, OiFileCategory.generic);
    });
  });

  // ── REQ-0844: Rounded-corner page/document outline ──────────────────────

  group('page/document shape (REQ-0844)', () {
    testWidgets('renders with correct medium dimensions', (tester) async {
      await tester.pumpObers(const OiFileIcon(extension: 'PDF'));
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(OiFileIcon),
          matching: find.byType(SizedBox).first,
        ),
      );
      expect(sizedBox.width, 48);
      expect(sizedBox.height, 60);
    });

    testWidgets('renders with correct small dimensions', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(extension: 'PDF', size: OiFileIconSize.small),
      );
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(OiFileIcon),
          matching: find.byType(SizedBox).first,
        ),
      );
      expect(sizedBox.width, 32);
      expect(sizedBox.height, 40);
    });

    testWidgets('renders with correct large dimensions', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(extension: 'PDF', size: OiFileIconSize.large),
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
    testWidgets('golden: small size fold geometry', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(
          extension: 'PDF',
          category: OiFileCategory.document,
          size: OiFileIconSize.small,
        ),
        surfaceSize: const Size(64, 72),
      );
      await expectLater(
        find.byType(OiFileIcon),
        matchesGoldenFile('goldens/oi_file_icon_fold_small.png'),
      );
    });

    testWidgets('golden: medium size fold geometry', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(
          extension: 'PDF',
          category: OiFileCategory.document,
          size: OiFileIconSize.medium,
        ),
        surfaceSize: const Size(80, 92),
      );
      await expectLater(
        find.byType(OiFileIcon),
        matchesGoldenFile('goldens/oi_file_icon_fold_medium.png'),
      );
    });

    testWidgets('golden: large size fold geometry', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(
          extension: 'PDF',
          category: OiFileCategory.document,
          size: OiFileIconSize.large,
        ),
        surfaceSize: const Size(96, 112),
      );
      await expectLater(
        find.byType(OiFileIcon),
        matchesGoldenFile('goldens/oi_file_icon_fold_large.png'),
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

  // ── Size enum coverage ──────────────────────────────────────────────────

  group('all sizes render correctly', () {
    testWidgets('small', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(
          extension: 'MP3',
          category: OiFileCategory.audio,
          size: OiFileIconSize.small,
        ),
      );
      expect(find.text('MP3'), findsOneWidget);
    });

    testWidgets('medium', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(
          extension: 'ZIP',
          category: OiFileCategory.archive,
        ),
      );
      expect(find.text('ZIP'), findsOneWidget);
    });

    testWidgets('large', (tester) async {
      await tester.pumpObers(
        const OiFileIcon(
          extension: 'PY',
          category: OiFileCategory.code,
          size: OiFileIconSize.large,
        ),
      );
      expect(find.text('PY'), findsOneWidget);
    });
  });
}
