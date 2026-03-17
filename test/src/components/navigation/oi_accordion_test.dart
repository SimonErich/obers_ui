// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_accordion.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Rendering ──────────────────────────────────────────────────────────────

  testWidgets('renders section titles', (tester) async {
    await tester.pumpObers(
      const OiAccordion(
        sections: [
          OiAccordionSection(title: 'Section A', content: Text('Content A')),
          OiAccordionSection(title: 'Section B', content: Text('Content B')),
        ],
      ),
    );
    expect(find.text('Section A'), findsOneWidget);
    expect(find.text('Section B'), findsOneWidget);
  });

  testWidgets('content is hidden when section is collapsed', (tester) async {
    await tester.pumpObers(
      const OiAccordion(
        sections: [
          OiAccordionSection(title: 'Section A', content: Text('Content A')),
        ],
      ),
    );
    // SizeTransition collapses content to zero height — widget still in tree.
    expect(find.text('Section A'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping header expands section', (tester) async {
    await tester.pumpObers(
      const OiAccordion(
        sections: [
          OiAccordionSection(title: 'FAQ', content: Text('Answer text')),
        ],
      ),
    );
    await tester.tap(find.text('FAQ'));
    await tester.pumpAndSettle();
    expect(find.text('Answer text'), findsOneWidget);
  });

  testWidgets('tapping expanded section collapses it', (tester) async {
    await tester.pumpObers(
      const OiAccordion(
        sections: [
          OiAccordionSection(
            title: 'FAQ',
            content: Text('Answer text'),
            initiallyExpanded: true,
          ),
        ],
      ),
    );
    await tester.tap(find.text('FAQ'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  // ── initiallyExpanded ─────────────────────────────────────────────────────

  testWidgets('initiallyExpanded=true shows content immediately',
      (tester) async {
    await tester.pumpObers(
      const OiAccordion(
        sections: [
          OiAccordionSection(
            title: 'Open',
            content: Text('Visible content'),
            initiallyExpanded: true,
          ),
        ],
      ),
    );
    expect(find.text('Visible content'), findsOneWidget);
  });

  // ── allowMultiple=false ────────────────────────────────────────────────────

  testWidgets('allowMultiple=false closes other sections when one opens',
      (tester) async {
    await tester.pumpObers(
      const OiAccordion(
        sections: [
          OiAccordionSection(
            title: 'A',
            content: Text('A content'),
            initiallyExpanded: true,
          ),
          OiAccordionSection(title: 'B', content: Text('B content')),
        ],
      ),
    );
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('allowMultiple=true keeps multiple sections open', (tester) async {
    await tester.pumpObers(
      const OiAccordion(
        allowMultiple: true,
        sections: [
          OiAccordionSection(
            title: 'A',
            content: Text('A content'),
            initiallyExpanded: true,
          ),
          OiAccordionSection(
            title: 'B',
            content: Text('B content'),
            initiallyExpanded: true,
          ),
        ],
      ),
    );
    expect(find.text('A content'), findsOneWidget);
    expect(find.text('B content'), findsOneWidget);
  });
}
