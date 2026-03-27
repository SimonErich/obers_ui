// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_path_bar.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/navigation/oi_breadcrumbs.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final segments = [
    const OiPathSegment(id: 'root', label: 'Home'),
    const OiPathSegment(id: 'docs', label: 'Documents'),
    const OiPathSegment(id: 'work', label: 'Work'),
  ];

  testWidgets('renders breadcrumbs in default mode', (tester) async {
    await tester.pumpObers(OiPathBar(segments: segments, onNavigate: (_) {}));
    expect(find.byType(OiBreadcrumbs), findsOneWidget);
  });

  testWidgets('shows folder icon when showIcon is true', (tester) async {
    await tester.pumpObers(OiPathBar(segments: segments, onNavigate: (_) {}));
    // folder icon code point 0xe2c7
    const folderIcon = OiIcons.folder;
    expect(find.byIcon(folderIcon), findsOneWidget);
  });

  testWidgets('hides folder icon when showIcon is false', (tester) async {
    await tester.pumpObers(
      OiPathBar(segments: segments, onNavigate: (_) {}, showIcon: false),
    );
    const folderIcon = OiIcons.folder;
    expect(find.byIcon(folderIcon), findsNothing);
  });

  testWidgets('tapping breadcrumb area enters edit mode when editable', (
    tester,
  ) async {
    await tester.pumpObers(OiPathBar(segments: segments, onNavigate: (_) {}));

    // Tap on the breadcrumb area to enter edit mode
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    expect(find.byType(OiTextInput), findsOneWidget);
  });

  testWidgets('edit mode does not activate when editable is false', (
    tester,
  ) async {
    await tester.pumpObers(
      OiPathBar(segments: segments, onNavigate: (_) {}, editable: false),
    );

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // Should still be in breadcrumb mode
    expect(find.byType(OiBreadcrumbs), findsOneWidget);
    expect(find.byType(OiTextInput), findsNothing);
  });

  testWidgets('edit mode text input contains full path', (tester) async {
    await tester.pumpObers(OiPathBar(segments: segments, onNavigate: (_) {}));

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    final textInput = tester.widget<OiTextInput>(find.byType(OiTextInput));
    expect(textInput.controller!.text, 'Home / Documents / Work');
  });

  testWidgets('submitting path calls onPathSubmit', (tester) async {
    String? submittedPath;
    await tester.pumpObers(
      OiPathBar(
        segments: segments,
        onNavigate: (_) {},
        onPathSubmit: (path) => submittedPath = path,
      ),
    );

    // Enter edit mode
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // Submit the text input
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(submittedPath, 'Home / Documents / Work');
  });

  testWidgets('returns to breadcrumb mode after submit', (tester) async {
    await tester.pumpObers(
      OiPathBar(segments: segments, onNavigate: (_) {}, onPathSubmit: (_) {}),
    );

    // Enter edit mode
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    // Submit
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byType(OiBreadcrumbs), findsOneWidget);
  });

  testWidgets('default semantics label is "Path navigation"', (tester) async {
    await tester.pumpObers(OiPathBar(segments: segments, onNavigate: (_) {}));
    final semantics = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .where((s) => s.properties.label == 'Path navigation')
        .toList();
    expect(semantics, isNotEmpty);
  });

  testWidgets('custom semanticsLabel overrides default', (tester) async {
    await tester.pumpObers(
      OiPathBar(
        segments: segments,
        onNavigate: (_) {},
        semanticsLabel: 'File path',
      ),
    );
    final semantics = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .where((s) => s.properties.label == 'File path')
        .toList();
    expect(semantics, isNotEmpty);
  });

  testWidgets('empty segments renders without error', (tester) async {
    await tester.pumpObers(OiPathBar(segments: const [], onNavigate: (_) {}));
    expect(find.byType(OiPathBar), findsOneWidget);
  });

  testWidgets('does not show folder icon when segments are empty', (
    tester,
  ) async {
    await tester.pumpObers(OiPathBar(segments: const [], onNavigate: (_) {}));
    const folderIcon = OiIcons.folder;
    expect(find.byIcon(folderIcon), findsNothing);
  });
}
