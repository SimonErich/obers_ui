// Tests do not require documentation comments.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/dialogs/oi_upload_dialog.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiUploadDialog', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpObers(
        OiUploadDialog(onUpload: (_, _) {}),
        surfaceSize: const Size(600, 800),
      );
      expect(find.byType(OiUploadDialog), findsOneWidget);
    });

    testWidgets('shows Upload Files title by default', (tester) async {
      await tester.pumpObers(
        OiUploadDialog(onUpload: (_, _) {}),
        surfaceSize: const Size(600, 800),
      );
      expect(find.text('Upload Files'), findsOneWidget);
    });

    testWidgets('shows destination path in title when provided', (
      tester,
    ) async {
      await tester.pumpObers(
        OiUploadDialog(onUpload: (_, _) {}, destinationPath: '/Documents'),
        surfaceSize: const Size(600, 800),
      );
      expect(find.text('Upload to: /Documents'), findsOneWidget);
      expect(find.text('Upload Files'), findsNothing);
    });

    testWidgets('shows drop zone text', (tester) async {
      await tester.pumpObers(
        OiUploadDialog(onUpload: (_, _) {}),
        surfaceSize: const Size(600, 800),
      );
      expect(find.text('Drop files here or browse'), findsOneWidget);
    });

    testWidgets('shows conflict resolution selector', (tester) async {
      await tester.pumpObers(
        OiUploadDialog(onUpload: (_, _) {}),
        surfaceSize: const Size(600, 800),
      );
      expect(find.text('If file exists:'), findsOneWidget);
    });

    testWidgets('Upload button present when no files added', (tester) async {
      await tester.pumpObers(
        OiUploadDialog(onUpload: (_, _) {}),
        surfaceSize: const Size(600, 800),
      );
      expect(find.widgetWithText(OiButton, 'Upload'), findsOneWidget);
    });

    testWidgets('Upload button does not fire callback when no files', (
      tester,
    ) async {
      var called = false;
      await tester.pumpObers(
        OiUploadDialog(onUpload: (_, _) => called = true),
        surfaceSize: const Size(600, 800),
      );
      await tester.tap(
        find.widgetWithText(OiButton, 'Upload'),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(called, isFalse);
    });

    testWidgets('tapping Cancel fires onCancel', (tester) async {
      var cancelled = false;
      await tester.pumpObers(
        OiUploadDialog(onUpload: (_, _) {}, onCancel: () => cancelled = true),
        surfaceSize: const Size(600, 800),
      );
      await tester.tap(find.widgetWithText(OiButton, 'Cancel'));
      await tester.pump();
      expect(cancelled, isTrue);
    });

    testWidgets('ESC key fires onCancel', (tester) async {
      var cancelled = false;
      await tester.pumpObers(
        OiUploadDialog(onUpload: (_, _) {}, onCancel: () => cancelled = true),
        surfaceSize: const Size(600, 800),
      );
      final kl = tester.widget<KeyboardListener>(find.byType(KeyboardListener));
      kl.focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(cancelled, isTrue);
    });

    testWidgets('has correct semantics label', (tester) async {
      await tester.pumpObers(
        OiUploadDialog(onUpload: (_, _) {}),
        surfaceSize: const Size(600, 800),
      );
      expect(find.bySemanticsLabel(RegExp('Upload dialog')), findsOneWidget);
    });

    testWidgets('does not show file list when no files added', (tester) async {
      await tester.pumpObers(
        OiUploadDialog(onUpload: (_, _) {}),
        surfaceSize: const Size(600, 800),
      );
      expect(find.text('Files to upload:'), findsNothing);
    });

    testWidgets('default conflict resolution is ask', (tester) async {
      await tester.pumpObers(
        OiUploadDialog(onUpload: (_, _) {}),
        surfaceSize: const Size(600, 800),
      );
      expect(find.text('Ask'), findsOneWidget);
    });

    testWidgets('custom default resolution is respected', (tester) async {
      await tester.pumpObers(
        OiUploadDialog(
          onUpload: (_, _) {},
          defaultResolution: OiConflictResolution.replace,
        ),
        surfaceSize: const Size(600, 800),
      );
      expect(find.text('Replace'), findsOneWidget);
    });

    testWidgets('renders with allowed extensions constraint', (tester) async {
      await tester.pumpObers(
        OiUploadDialog(
          onUpload: (_, _) {},
          allowedExtensions: const ['pdf', 'docx'],
        ),
        surfaceSize: const Size(600, 800),
      );
      expect(find.byType(OiUploadDialog), findsOneWidget);
    });

    testWidgets('renders with max file size constraint', (tester) async {
      await tester.pumpObers(
        OiUploadDialog(onUpload: (_, _) {}, maxFileSize: 1024 * 1024),
        surfaceSize: const Size(600, 800),
      );
      expect(find.byType(OiUploadDialog), findsOneWidget);
    });

    testWidgets('renders with max files constraint', (tester) async {
      await tester.pumpObers(
        OiUploadDialog(onUpload: (_, _) {}, maxFiles: 5),
        surfaceSize: const Size(600, 800),
      );
      expect(find.byType(OiUploadDialog), findsOneWidget);
    });

    testWidgets('Cancel and Upload buttons are both visible', (tester) async {
      await tester.pumpObers(
        OiUploadDialog(onUpload: (_, _) {}),
        surfaceSize: const Size(600, 800),
      );
      expect(find.widgetWithText(OiButton, 'Cancel'), findsOneWidget);
      expect(find.widgetWithText(OiButton, 'Upload'), findsOneWidget);
    });
  });
}
