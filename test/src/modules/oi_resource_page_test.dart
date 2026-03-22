// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_card.dart';
import 'package:obers_ui/src/components/display/oi_pagination.dart';
import 'package:obers_ui/src/components/navigation/oi_breadcrumbs.dart';
import 'package:obers_ui/src/modules/oi_resource_page.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OiResourcePage', () {
    testWidgets('list variant renders create button and pagination', (
      tester,
    ) async {
      await tester.pumpObers(
        OiResourcePage(
          label: 'Users',
          title: 'Users',
          child: const Text('User list'),
          pagination: OiPagination(
            totalItems: 100,
            currentPage: 1,
            label: 'Pagination',
          ),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('Create'), findsOneWidget);
      expect(find.byType(OiPagination), findsOneWidget);
      expect(find.text('User list'), findsOneWidget);
    });

    testWidgets('show variant renders edit and delete buttons', (tester) async {
      await tester.pumpObers(
        const OiResourcePage(
          label: 'User Detail',
          title: 'User #1',
          variant: OiResourcePageVariant.show,
          child: Text('User detail'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('User detail'), findsOneWidget);
    });

    testWidgets('edit variant renders save and cancel in card', (tester) async {
      await tester.pumpObers(
        const OiResourcePage(
          label: 'Edit User',
          title: 'Edit User #1',
          variant: OiResourcePageVariant.edit,
          child: Text('Edit form'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(OiCard), findsOneWidget);
      expect(find.text('Edit form'), findsOneWidget);
    });

    testWidgets('create variant renders save and cancel in card', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiResourcePage(
          label: 'Create User',
          title: 'New User',
          variant: OiResourcePageVariant.create,
          child: Text('Create form'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(OiCard), findsOneWidget);
      expect(find.text('Create form'), findsOneWidget);
    });

    testWidgets('custom actions override defaults', (tester) async {
      await tester.pumpObers(
        const OiResourcePage(
          label: 'Users',
          title: 'Users',
          actions: [Text('CustomAction')],
          child: Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      // Custom action should be rendered.
      expect(find.text('CustomAction'), findsOneWidget);

      // Default 'Create' button should not appear.
      expect(find.text('Create'), findsNothing);
    });

    testWidgets('filters render for list variant only', (tester) async {
      await tester.pumpObers(
        OiResourcePage(
          label: 'Users',
          title: 'Users',
          filters: const Text('FilterWidget'),
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('FilterWidget'), findsOneWidget);
    });

    testWidgets('filters not rendered for show variant', (tester) async {
      await tester.pumpObers(
        const OiResourcePage(
          label: 'User',
          title: 'User',
          variant: OiResourcePageVariant.show,
          filters: Text('FilterWidget'),
          child: Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('FilterWidget'), findsNothing);
    });

    testWidgets('breadcrumbs render when provided', (tester) async {
      await tester.pumpObers(
        const OiResourcePage(
          label: 'Users',
          title: 'Users',
          breadcrumbs: [
            OiBreadcrumbItem(label: 'Home'),
            OiBreadcrumbItem(label: 'Users'),
          ],
          child: Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.byType(OiBreadcrumbs), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('wrapInCard: false renders without card', (tester) async {
      await tester.pumpObers(
        const OiResourcePage(
          label: 'Edit User',
          title: 'Edit',
          variant: OiResourcePageVariant.edit,
          wrapInCard: false,
          child: Text('No card content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('No card content'), findsOneWidget);
      expect(find.byType(OiCard), findsNothing);
    });

    testWidgets('title renders as heading', (tester) async {
      await tester.pumpObers(
        const OiResourcePage(
          label: 'Users',
          title: 'All Users',
          child: Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('All Users'), findsOneWidget);
    });

    testWidgets('a11y: semantics label applied', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpObers(
        const OiResourcePage(
          label: 'User Management',
          title: 'Users',
          child: Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'User Management',
        ),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets('onAction callback fires for default buttons', (tester) async {
      final actions = <String>[];

      await tester.pumpObers(
        OiResourcePage(
          label: 'Users',
          title: 'Users',
          onAction: actions.add,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      // Tap the Create button.
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(actions, contains('create'));
    });

    testWidgets('onAction fires for show variant buttons', (tester) async {
      final actions = <String>[];

      await tester.pumpObers(
        OiResourcePage(
          label: 'User',
          title: 'User #1',
          variant: OiResourcePageVariant.show,
          onAction: actions.add,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(actions, ['edit', 'delete']);
    });

    testWidgets('onAction fires for edit variant buttons', (tester) async {
      final actions = <String>[];

      await tester.pumpObers(
        OiResourcePage(
          label: 'Edit',
          title: 'Edit User',
          variant: OiResourcePageVariant.edit,
          onAction: actions.add,
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(actions, ['cancel', 'save']);
    });

    testWidgets('pagination not rendered for non-list variant', (tester) async {
      await tester.pumpObers(
        OiResourcePage(
          label: 'User',
          title: 'User',
          variant: OiResourcePageVariant.show,
          pagination: OiPagination(
            totalItems: 50,
            currentPage: 1,
            label: 'Pagination',
          ),
          child: const Text('Content'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.byType(OiPagination), findsNothing);
    });

    testWidgets('no title still renders action bar', (tester) async {
      await tester.pumpObers(
        const OiResourcePage(label: 'Users', child: Text('Content')),
        surfaceSize: const Size(1200, 800),
      );

      // Create button should still be visible even without a title.
      expect(find.text('Create'), findsOneWidget);
    });
  });
}
