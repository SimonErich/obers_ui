// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_card.dart';
import 'package:obers_ui/src/composites/data/oi_detail_view.dart';
import 'package:obers_ui/src/models/oi_field_type.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final testSections = [
    const OiDetailSection(
      title: 'Section 1',
      fields: [
        OiDetailField(label: 'Name', value: 'Alice'),
        OiDetailField(label: 'Age', value: 30, type: OiFieldType.number),
      ],
    ),
    const OiDetailSection(
      title: 'Section 2',
      fields: [OiDetailField(label: 'Email', value: 'alice@example.com')],
    ),
  ];

  testWidgets('OiColumn is used instead of raw Column', (tester) async {
    await tester.pumpObers(OiDetailView(sections: testSections));

    expect(find.byType(OiColumn), findsWidgets);
  });

  testWidgets('OiCard wraps detail view by default', (tester) async {
    await tester.pumpObers(OiDetailView(sections: testSections));

    expect(find.byType(OiCard), findsOneWidget);
  });

  testWidgets('wrapInCard false skips OiCard', (tester) async {
    await tester.pumpObers(
      OiDetailView(sections: testSections, wrapInCard: false),
    );

    expect(find.byType(OiCard), findsNothing);
  });

  testWidgets('OiSurface wraps each section', (tester) async {
    await tester.pumpObers(OiDetailView(sections: testSections));

    // 2 sections → at least 2 OiSurface widgets.
    expect(find.byType(OiSurface), findsAtLeast(2));
  });
}
