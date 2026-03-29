// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_sliver_header.dart';

import '../../../helpers/pump_app.dart';

Widget _buildScrollView({
  required Widget header,
  int childCount = 20,
}) {
  return CustomScrollView(
    slivers: [
      header,
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => SizedBox(height: 100, child: Text('Item $i')),
          childCount: childCount,
        ),
      ),
    ],
  );
}

void main() {
  group('OiSliverHeader', () {
    // ── Rendering ────────────────────────────────────────────────────────────

    testWidgets('renders title widget', (tester) async {
      await tester.pumpObers(
        _buildScrollView(
          header: const OiSliverHeader(title: Text('My Title')),
        ),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('My Title'), findsOneWidget);
    });

    testWidgets('renders leading widget', (tester) async {
      await tester.pumpObers(
        _buildScrollView(
          header: const OiSliverHeader(
            title: Text('Title'),
            leading: Text('Back'),
          ),
        ),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('renders trailing widget', (tester) async {
      await tester.pumpObers(
        _buildScrollView(
          header: const OiSliverHeader(
            title: Text('Title'),
            trailing: Text('Action'),
          ),
        ),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Action'), findsOneWidget);
    });

    testWidgets('renders subtitle below title', (tester) async {
      await tester.pumpObers(
        _buildScrollView(
          header: const OiSliverHeader(
            title: Text('Title'),
            subtitle: Text('Subtitle'),
          ),
        ),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Subtitle'), findsOneWidget);
    });

    testWidgets('renders actions', (tester) async {
      await tester.pumpObers(
        _buildScrollView(
          header: const OiSliverHeader(
            title: Text('Title'),
            actions: [Text('Act1'), Text('Act2')],
          ),
        ),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Act1'), findsOneWidget);
      expect(find.text('Act2'), findsOneWidget);
    });

    // ── Pinned behavior ──────────────────────────────────────────────────────

    testWidgets('pinned header stays visible after scroll', (tester) async {
      await tester.pumpObers(
        _buildScrollView(
          header: const OiSliverHeader(
            title: Text('Header'),
          ),
          childCount: 50,
        ),
        surfaceSize: const Size(400, 600),
      );
      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(find.text('Header'), findsOneWidget);
    });

    testWidgets('non-pinned header scrolls away', (tester) async {
      await tester.pumpObers(
        _buildScrollView(
          header: const OiSliverHeader(
            title: Text('Header'),
            pinned: false,
          ),
          childCount: 50,
        ),
        surfaceSize: const Size(400, 600),
      );
      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(find.text('Header'), findsNothing);
    });

    // ── Simple constructor ───────────────────────────────────────────────────

    testWidgets('simple constructor creates a pinned header with title', (
      tester,
    ) async {
      await tester.pumpObers(
        _buildScrollView(
          header: OiSliverHeader.simple(title: 'Simple Header'),
          childCount: 50,
        ),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Simple Header'), findsOneWidget);

      // Scroll and verify it stays pinned.
      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(find.text('Simple Header'), findsOneWidget);
    });

    testWidgets('simple constructor with onBack renders back button', (
      tester,
    ) async {
      var backPressed = false;
      await tester.pumpObers(
        _buildScrollView(
          header: OiSliverHeader.simple(
            title: 'Detail',
            onBack: () => backPressed = true,
          ),
        ),
        surfaceSize: const Size(400, 600),
      );
      // The back button is a GestureDetector wrapping an Icon.
      expect(find.byType(GestureDetector), findsWidgets);
      // Tap the back icon (chevron-left).
      await tester.tap(find.byType(Icon).first);
      await tester.pump();
      expect(backPressed, isTrue);
    });

    // ── Large constructor ────────────────────────────────────────────────────

    testWidgets('large constructor renders title', (tester) async {
      await tester.pumpObers(
        _buildScrollView(
          header: OiSliverHeader.large(title: 'Large Title'),
        ),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Large Title'), findsOneWidget);
    });

    // ── Semantics ────────────────────────────────────────────────────────────

    testWidgets('semantic label is applied when provided', (tester) async {
      await tester.pumpObers(
        _buildScrollView(
          header: const OiSliverHeader(
            title: Text('Title'),
            semanticLabel: 'Page header',
          ),
        ),
        surfaceSize: const Size(400, 600),
      );
      // The Semantics widget with header: true and the label is rendered
      // inside the delegate. Verify it exists in the widget tree.
      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );
      final hasPageHeader = semanticsWidgets.any(
        (s) => s.properties.label == 'Page header',
      );
      expect(
        hasPageHeader,
        isTrue,
        reason: 'A Semantics widget with label "Page header" should exist',
      );
    });
  });
}
