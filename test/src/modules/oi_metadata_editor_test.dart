// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/modules/oi_metadata_editor.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OiMetadataEditor', () {
    testWidgets('fields render with key-value pairs', (tester) async {
      await tester.pumpObers(
        OiMetadataEditor(
          fields: const [
            OiMetadataField(key: 'Name', value: 'Alice'),
            OiMetadataField(key: 'Age', value: '30'),
          ],
          onChange: (_) {},
          label: 'Metadata',
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
    });

    testWidgets('add field works', (tester) async {
      List<OiMetadataField>? updatedFields;
      await tester.pumpObers(
        OiMetadataEditor(
          fields: const [OiMetadataField(key: 'Existing', value: 'val')],
          onChange: (f) => updatedFields = f,
          label: 'Metadata',
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.text('Add field'), findsOneWidget);

      await tester.tap(find.text('Add field'));
      await tester.pump();
      expect(updatedFields, isNotNull);
      expect(updatedFields!.length, 2);
    });

    testWidgets('remove field works', (tester) async {
      List<OiMetadataField>? updatedFields;
      await tester.pumpObers(
        OiMetadataEditor(
          fields: const [OiMetadataField(key: 'ToRemove', value: 'val')],
          onChange: (f) => updatedFields = f,
          label: 'Metadata',
          allowRemove: true,
        ),
        surfaceSize: const Size(400, 600),
      );

      // Tap the remove button (the close icon).
      await tester.tap(find.bySemanticsLabel('Remove ToRemove'));
      await tester.pump();
      expect(updatedFields, isNotNull);
      expect(updatedFields!.isEmpty, isTrue);
    });

    testWidgets('type-aware input renders for boolean', (tester) async {
      List<OiMetadataField>? updatedFields;
      await tester.pumpObers(
        OiMetadataEditor(
          fields: const [
            OiMetadataField(
              key: 'Active',
              value: false,
              type: OiMetadataType.boolean,
            ),
          ],
          onChange: (f) => updatedFields = f,
          label: 'Metadata',
        ),
        surfaceSize: const Size(400, 600),
      );

      // Boolean field should show "No" for false.
      expect(find.text('No'), findsOneWidget);

      // Tap to toggle.
      await tester.tap(find.text('No'));
      await tester.pump();
      expect(updatedFields, isNotNull);
      expect(updatedFields!.first.value, isTrue);
    });

    testWidgets('type-aware input renders for number', (tester) async {
      await tester.pumpObers(
        OiMetadataEditor(
          fields: const [
            OiMetadataField(
              key: 'Count',
              value: 42,
              type: OiMetadataType.number,
            ),
          ],
          onChange: (_) {},
          label: 'Metadata',
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.text('Count'), findsOneWidget);
    });

    testWidgets('onChange fires on field edit', (tester) async {
      List<OiMetadataField>? updatedFields;
      await tester.pumpObers(
        OiMetadataEditor(
          fields: const [OiMetadataField(key: 'Title', value: 'Old')],
          onChange: (f) => updatedFields = f,
          label: 'Metadata',
        ),
        surfaceSize: const Size(400, 600),
      );

      // Find the text input and enter new text.
      await tester.enterText(find.byType(EditableText).first, 'New');
      await tester.pump();
      expect(updatedFields, isNotNull);
      expect(updatedFields!.first.value, 'New');
    });

    testWidgets('disabled blocks editing', (tester) async {
      await tester.pumpObers(
        OiMetadataEditor(
          fields: const [OiMetadataField(key: 'Locked', value: 'val')],
          onChange: (_) {},
          label: 'Metadata',
          enabled: false,
        ),
        surfaceSize: const Size(400, 600),
      );

      // Add button should not be visible when disabled.
      expect(find.text('Add field'), findsNothing);

      // Remove icons should not be visible when disabled.
      expect(find.bySemanticsLabel('Remove Locked'), findsNothing);
    });

    testWidgets('availableKeys restricts new fields', (tester) async {
      List<OiMetadataField>? updatedFields;
      await tester.pumpObers(
        OiMetadataEditor(
          fields: const [],
          onChange: (f) => updatedFields = f,
          label: 'Metadata',
          availableKeys: const ['Color', 'Size'],
        ),
        surfaceSize: const Size(400, 600),
      );

      await tester.tap(find.text('Add field'));
      await tester.pump();
      expect(updatedFields, isNotNull);
      expect(updatedFields!.first.key, 'Color');
    });

    testWidgets('semantics label is applied', (tester) async {
      await tester.pumpObers(
        OiMetadataEditor(
          fields: const [],
          onChange: (_) {},
          label: 'Properties Editor',
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.bySemanticsLabel('Properties Editor'), findsOneWidget);
    });
  });
}
