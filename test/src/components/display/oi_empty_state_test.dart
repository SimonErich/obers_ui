// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders title', (tester) async {
    await tester.pumpObers(const OiEmptyState(title: 'Nothing here'));
    expect(find.text('Nothing here'), findsOneWidget);
  });

  testWidgets('renders icon when provided', (tester) async {
    const icon = IconData(0xe88e, fontFamily: 'MaterialIcons');
    await tester.pumpObers(const OiEmptyState(title: 'Empty', icon: icon));
    expect(find.byIcon(icon), findsOneWidget);
  });

  testWidgets('illustration takes priority over icon', (tester) async {
    const icon = IconData(0xe88e, fontFamily: 'MaterialIcons');
    await tester.pumpObers(
      const OiEmptyState(
        title: 'Empty',
        icon: icon,
        illustration: SizedBox(key: Key('illus'), width: 64, height: 64),
      ),
    );
    expect(find.byKey(const Key('illus')), findsOneWidget);
    expect(find.byIcon(icon), findsNothing);
  });

  testWidgets('renders description when provided', (tester) async {
    await tester.pumpObers(
      const OiEmptyState(title: 'Empty', description: 'Try adding some items.'),
    );
    expect(find.text('Try adding some items.'), findsOneWidget);
  });

  testWidgets('renders action slot when provided', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiEmptyState(
        title: 'Empty',
        action: GestureDetector(
          onTap: () => tapped = true,
          child: const Text('Add item'),
        ),
      ),
    );
    await tester.tap(find.text('Add item'));
    expect(tapped, isTrue);
  });

  // ── Factory constructor tests ──────────────────────────────────────────────

  group('OiEmptyState.notFound', () {
    testWidgets('renders default title', (tester) async {
      await tester.pumpObers(OiEmptyState.notFound());
      expect(find.text('Page not found'), findsOneWidget);
    });

    testWidgets('accepts title override', (tester) async {
      await tester.pumpObers(OiEmptyState.notFound(title: 'Lost'));
      expect(find.text('Lost'), findsOneWidget);
      expect(find.text('Page not found'), findsNothing);
    });

    testWidgets('renders description', (tester) async {
      await tester.pumpObers(
        OiEmptyState.notFound(description: 'The page does not exist.'),
      );
      expect(find.text('The page does not exist.'), findsOneWidget);
    });

    testWidgets('renders action button and fires callback', (tester) async {
      var tapped = false;
      await tester.pumpObers(
        OiEmptyState.notFound(
          actionLabel: 'Go home',
          onAction: () => tapped = true,
        ),
      );
      expect(find.byType(OiButton), findsOneWidget);
      expect(find.text('Go home'), findsOneWidget);
      await tester.tap(find.text('Go home'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('OiEmptyState.forbidden', () {
    testWidgets('renders default title', (tester) async {
      await tester.pumpObers(OiEmptyState.forbidden());
      expect(find.text('Access denied'), findsOneWidget);
    });

    testWidgets('accepts title override', (tester) async {
      await tester.pumpObers(OiEmptyState.forbidden(title: 'No access'));
      expect(find.text('No access'), findsOneWidget);
    });

    testWidgets('renders description', (tester) async {
      await tester.pumpObers(
        OiEmptyState.forbidden(description: 'Contact your admin.'),
      );
      expect(find.text('Contact your admin.'), findsOneWidget);
    });

    testWidgets('renders action button and fires callback', (tester) async {
      var tapped = false;
      await tester.pumpObers(
        OiEmptyState.forbidden(
          actionLabel: 'Request access',
          onAction: () => tapped = true,
        ),
      );
      expect(find.byType(OiButton), findsOneWidget);
      await tester.tap(find.text('Request access'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('OiEmptyState.error', () {
    testWidgets('renders default title', (tester) async {
      await tester.pumpObers(OiEmptyState.error());
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('accepts title override', (tester) async {
      await tester.pumpObers(OiEmptyState.error(title: 'Oops'));
      expect(find.text('Oops'), findsOneWidget);
    });

    testWidgets('renders description', (tester) async {
      await tester.pumpObers(
        OiEmptyState.error(description: 'Try again later.'),
      );
      expect(find.text('Try again later.'), findsOneWidget);
    });

    testWidgets('renders action button and fires callback', (tester) async {
      var tapped = false;
      await tester.pumpObers(
        OiEmptyState.error(actionLabel: 'Retry', onAction: () => tapped = true),
      );
      expect(find.byType(OiButton), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('shows error object in debug mode', (tester) async {
      final error = Exception('DB connection failed');
      await tester.pumpObers(OiEmptyState.error(error: error));
      // kDebugMode is true in test environment.
      expect(find.textContaining('DB connection failed'), findsOneWidget);
    });

    testWidgets('appends error to description in debug mode', (tester) async {
      final error = Exception('timeout');
      await tester.pumpObers(
        OiEmptyState.error(description: 'Something broke.', error: error),
      );
      expect(find.textContaining('Something broke.'), findsOneWidget);
      expect(find.textContaining('timeout'), findsOneWidget);
    });
  });
}
