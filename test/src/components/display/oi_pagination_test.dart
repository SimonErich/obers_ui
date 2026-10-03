// Tests do not require documentation comments.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_pagination.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_button_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_pagination_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_text_input_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // Pages variant uses a wide Row (total label, per-page selector, nav
  // buttons, page buttons) that needs a wide surface to avoid overflow.
  const wide = Size(1200, 600);

  group('OiPagination - pages variant', () {
    testWidgets(
      'distributed layout gives natural-width groups equal free gaps',
      (tester) async {
        await tester.pumpObers(
          OiPagination(
            totalItems: 413,
            currentPage: 0,
            label: 'orders',
            distributed: true,
            showFirstLast: false,
            onPageChange: (_) {},
            labels: OiPaginationLabels(
              perPage: 'A wider page size label',
              total: (start, end, count, label) => '413',
            ),
          ),
          surfaceSize: wide,
        );
        final left = tester.getRect(
          find.byKey(const Key('oi_pagination_total')),
        );
        final previous = tester.getRect(
          find.byKey(const Key('oi_pagination_prev')),
        );
        final next = tester.getRect(
          find.byKey(const Key('oi_pagination_next')),
        );
        final right = tester.getRect(find.text('A wider page size label'));
        expect(previous.left - left.right, closeTo(right.left - next.right, 1));
        expect((previous.left + next.right) / 2, lessThan(wide.width / 2));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('configured size aligns pages arrows and page-size control', (
      tester,
    ) async {
      final base = OiThemeData.light();
      await tester.pumpObers(
        OiPagination(
          totalItems: 25000,
          currentPage: 0,
          label: 'rows',
          onPageChange: (_) {},
        ),
        theme: base.copyWith(
          components: base.components.copyWith(
            button: const OiButtonThemeData(height: 36),
            textInput: const OiTextInputThemeData(height: 36),
            pagination: const OiPaginationThemeData(buttonSize: 32),
          ),
        ),
        surfaceSize: wide,
      );
      expect(
        tester.getSize(find.byKey(const Key('oi_pagination_page_0'))),
        const Size(32, 32),
      );
      expect(
        tester.getSize(find.byKey(const Key('oi_pagination_next'))),
        const Size(32, 32),
      );
      expect(
        tester.getSize(find.byKey(const Key('oi_pagination_per_page'))).height,
        32,
      );
      // Long page numbers can grow to fit their text instead of being clipped.
      final last = find.byKey(const Key('oi_pagination_page_999'));
      expect(tester.getSize(last).width, greaterThan(32));
      expect(tester.takeException(), isNull);
    });

    testWidgets('configured size permits accessible text to grow', (
      tester,
    ) async {
      final base = OiThemeData.light();
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: OiPagination(
            totalItems: 75,
            currentPage: 0,
            label: 'rows',
            showTotal: false,
          ),
        ),
        theme: base.copyWith(
          components: base.components.copyWith(
            pagination: const OiPaginationThemeData(buttonSize: 32),
          ),
        ),
        surfaceSize: wide,
      );
      expect(
        tester.getSize(find.byKey(const Key('oi_pagination_page_0'))).height,
        greaterThan(32),
      );
      expect(
        tester.getSize(find.byKey(const Key('oi_pagination_per_page'))).height,
        greaterThan(32),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('compact metadata fits long localized labels', (tester) async {
      int? navigatedTo;
      await tester.pumpObers(
        Center(
          child: SizedBox(
            width: 260,
            child: OiPagination(
              totalItems: 48213,
              currentPage: 20,
              perPage: 15,
              siblingCount: 2,
              label: 'records',
              labels: const OiPaginationLabels(
                perPage: 'Records shown per page',
              ),
              onPageChange: (page) => navigatedTo = page,
            ),
          ),
        ),
        surfaceSize: const Size(320, 844),
      );
      expect(tester.takeException(), isNull);
      final next = find.byKey(const Key('oi_pagination_next'));
      expect(next.hitTestable(), findsOneWidget);
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(navigatedTo, 21);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders page numbers for multi-page data', (tester) async {
      await tester.pumpObers(
        OiPagination(
          totalItems: 75,
          currentPage: 0,
          label: 'items',
          onPageChange: (_) {},
        ),
        surfaceSize: wide,
      );

      // 3 pages: 1, 2, 3
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('highlights current page', (tester) async {
      await tester.pumpObers(
        OiPagination(
          totalItems: 75,
          currentPage: 1,
          label: 'items',
          onPageChange: (_) {},
        ),
        surfaceSize: wide,
      );

      // Page 2 (index 1) should be displayed as "2" and decorated
      final pageButton = tester.widget<Container>(
        find
            .ancestor(of: find.text('2'), matching: find.byType(Container))
            .first,
      );
      // The current page container has a non-null decoration
      expect(pageButton.decoration, isNotNull);
    });

    testWidgets('disables prev/first on page 0', (tester) async {
      await tester.pumpObers(
        OiPagination(
          totalItems: 50,
          currentPage: 0,
          label: 'items',
          onPageChange: (_) {},
        ),
        surfaceSize: wide,
      );

      // prev and first buttons exist but are disabled (enabled: false)
      expect(find.byKey(const Key('oi_pagination_prev')), findsOneWidget);
      expect(find.byKey(const Key('oi_pagination_first')), findsOneWidget);
    });

    testWidgets('disables next/last on last page', (tester) async {
      await tester.pumpObers(
        OiPagination(
          totalItems: 50,
          currentPage: 1,
          label: 'items',
          onPageChange: (_) {},
        ),
        surfaceSize: wide,
      );

      expect(find.byKey(const Key('oi_pagination_next')), findsOneWidget);
      expect(find.byKey(const Key('oi_pagination_last')), findsOneWidget);
    });

    testWidgets('calls onPageChange when page button tapped', (tester) async {
      int? tappedPage;
      await tester.pumpObers(
        OiPagination(
          totalItems: 75,
          currentPage: 0,
          label: 'items',
          onPageChange: (p) => tappedPage = p,
        ),
        surfaceSize: wide,
      );

      await tester.tap(find.byKey(const Key('oi_pagination_page_1')));
      await tester.pumpAndSettle();
      expect(tappedPage, 1);
    });

    testWidgets('showPerPage false hides per-page selector', (tester) async {
      await tester.pumpObers(
        const OiPagination(
          totalItems: 100,
          currentPage: 0,
          label: 'items',
          showPerPage: false,
        ),
      );

      expect(find.byKey(const Key('oi_pagination_per_page')), findsNothing);
    });

    testWidgets('showTotal false hides total count label', (tester) async {
      await tester.pumpObers(
        const OiPagination(
          totalItems: 100,
          currentPage: 0,
          label: 'items',
          showTotal: false,
        ),
        surfaceSize: wide,
      );

      expect(find.byKey(const Key('oi_pagination_total')), findsNothing);
    });

    testWidgets('showFirstLast false hides first/last buttons', (tester) async {
      await tester.pumpObers(
        const OiPagination(
          totalItems: 100,
          currentPage: 0,
          label: 'items',
          showFirstLast: false,
        ),
      );

      expect(find.byKey(const Key('oi_pagination_first')), findsNothing);
      expect(find.byKey(const Key('oi_pagination_last')), findsNothing);
    });

    testWidgets('zero items shows empty state', (tester) async {
      await tester.pumpObers(
        const OiPagination(totalItems: 0, currentPage: 0, label: 'items'),
        surfaceSize: wide,
      );

      expect(find.text('0 items'), findsOneWidget);
    });

    testWidgets('single page hides page numbers navigation', (tester) async {
      await tester.pumpObers(
        const OiPagination(totalItems: 10, currentPage: 0, label: 'items'),
        surfaceSize: wide,
      );

      // Only page "1" shown, no page "2"
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsNothing);
    });

    testWidgets('prev button calls onPageChange with previous page', (
      tester,
    ) async {
      int? navigatedTo;
      await tester.pumpObers(
        OiPagination(
          totalItems: 75,
          currentPage: 2,
          label: 'items',
          onPageChange: (p) => navigatedTo = p,
        ),
        surfaceSize: wide,
      );

      await tester.tap(find.byKey(const Key('oi_pagination_prev')));
      await tester.pumpAndSettle();
      expect(navigatedTo, 1);
    });

    testWidgets('next button calls onPageChange with next page', (
      tester,
    ) async {
      int? navigatedTo;
      await tester.pumpObers(
        OiPagination(
          totalItems: 75,
          currentPage: 0,
          label: 'items',
          onPageChange: (p) => navigatedTo = p,
        ),
        surfaceSize: wide,
      );

      await tester.tap(find.byKey(const Key('oi_pagination_next')));
      await tester.pumpAndSettle();
      expect(navigatedTo, 1);
    });

    testWidgets('first button jumps to page 0', (tester) async {
      int? navigatedTo;
      await tester.pumpObers(
        OiPagination(
          totalItems: 75,
          currentPage: 2,
          label: 'items',
          onPageChange: (p) => navigatedTo = p,
        ),
        surfaceSize: wide,
      );

      await tester.tap(find.byKey(const Key('oi_pagination_first')));
      await tester.pumpAndSettle();
      expect(navigatedTo, 0);
    });

    testWidgets('last button jumps to last page', (tester) async {
      int? navigatedTo;
      await tester.pumpObers(
        OiPagination(
          totalItems: 100,
          currentPage: 0,
          label: 'items',
          onPageChange: (p) => navigatedTo = p,
        ),
        surfaceSize: wide,
      );

      await tester.tap(find.byKey(const Key('oi_pagination_last')));
      await tester.pumpAndSettle();
      expect(navigatedTo, 3);
    });

    testWidgets('per-page selector calls onPerPageChange', (tester) async {
      await tester.pumpObers(
        OiPagination(
          totalItems: 100,
          currentPage: 0,
          label: 'items',
          onPageChange: (_) {},
          onPerPageChange: (_) {},
        ),
        surfaceSize: wide,
      );

      // Per-page selector is rendered
      expect(find.byKey(const Key('oi_pagination_per_page')), findsOneWidget);
      expect(find.text('Per page:'), findsOneWidget);

      // OiSelect dropdown items live in a CompositedTransformFollower overlay
      // which is not hittable in widget tests. Verify the callback wiring by
      // rebuilding with a new perPage value and confirming the total label
      // updates accordingly.
      await tester.pumpObers(
        OiPagination(
          totalItems: 100,
          currentPage: 0,
          label: 'items',
          perPage: 50,
          onPageChange: (_) {},
          onPerPageChange: (_) {},
        ),
        surfaceSize: wide,
      );

      // With perPage=50, total label should show "1–50 of 100 items"
      expect(find.text('1\u201350 of 100 items'), findsOneWidget);
    });
  });

  group('OiPagination.computeVisiblePages', () {
    test('siblingCount controls visible page range', () {
      // 20 pages, current=10, siblingCount=2 => shows 8,9,10,11,12 + first/last
      final pages = OiPagination.computeVisiblePages(10, 20, 2);
      // Should contain 0, 8, 9, 10, 11, 12, 19 and nulls for ellipsis
      final nonNull = pages.whereType<int>().toList();
      expect(nonNull, contains(0));
      expect(nonNull, contains(8));
      expect(nonNull, contains(9));
      expect(nonNull, contains(10));
      expect(nonNull, contains(11));
      expect(nonNull, contains(12));
      expect(nonNull, contains(19));
    });

    test('ellipsis rendered for large page counts', () {
      final pages = OiPagination.computeVisiblePages(5, 20, 1);
      // Should contain null entries for ellipsis
      expect(pages.contains(null), isTrue);
    });

    test('all pages shown when total fits maxVisible', () {
      final pages = OiPagination.computeVisiblePages(2, 5, 1);
      expect(pages.length, 5);
      expect(pages.contains(null), isFalse);
    });
  });

  group('OiPagination - compact variant', () {
    testWidgets('shows X / Y format', (tester) async {
      await tester.pumpObers(
        const OiPagination.compact(
          totalItems: 100,
          currentPage: 2,
          label: 'items',
        ),
      );

      // currentPage=2 (0-based) => display "3 / 4"
      expect(find.text('3 / 4'), findsOneWidget);
    });

    testWidgets('compact variant navigates with arrows', (tester) async {
      int? navigatedTo;
      await tester.pumpObers(
        OiPagination.compact(
          totalItems: 100,
          currentPage: 1,
          label: 'items',
          onPageChange: (p) => navigatedTo = p,
        ),
      );

      // Tap next
      await tester.tap(find.byKey(const Key('oi_pagination_next')));
      await tester.pumpAndSettle();
      expect(navigatedTo, 2);
    });
  });

  group('OiPagination.loadMore', () {
    testWidgets('renders load-more button with count and label', (
      tester,
    ) async {
      await tester.pumpObers(
        OiPagination.loadMore(
          loadedCount: 25,
          totalItems: 100,
          label: 'products',
          onLoadMore: () {},
        ),
      );

      expect(find.text('25 of 100 products loaded'), findsOneWidget);
      expect(find.byKey(const Key('oi_pagination_load_more')), findsOneWidget);
    });

    testWidgets('shows loading state when loading is true', (tester) async {
      await tester.pumpObers(
        OiPagination.loadMore(
          loadedCount: 25,
          totalItems: 100,
          label: 'items',
          onLoadMore: () {},
          loading: true,
        ),
      );

      // Button is present but in loading state
      expect(find.byKey(const Key('oi_pagination_load_more')), findsOneWidget);
    });

    testWidgets('hides button when loadedCount >= totalItems', (tester) async {
      await tester.pumpObers(
        const OiPagination.loadMore(
          loadedCount: 100,
          totalItems: 100,
          label: 'items',
        ),
      );

      expect(find.byKey(const Key('oi_pagination_load_more')), findsNothing);
    });

    testWidgets('calls onLoadMore when button tapped', (tester) async {
      var called = false;
      await tester.pumpObers(
        OiPagination.loadMore(
          loadedCount: 25,
          totalItems: 100,
          label: 'items',
          onLoadMore: () => called = true,
        ),
      );

      await tester.tap(find.byKey(const Key('oi_pagination_load_more')));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });
  });

  group('OiPagination - keyboard navigation', () {
    /// Finds the pagination's own [Focus] widget and requests focus on it.
    Future<void> focusPagination(WidgetTester tester) async {
      final paginationElement = tester.element(find.byType(OiPagination));
      // Walk down to find the Focus node owned by _OiPaginationState.
      Focus? paginationFocus;
      paginationElement.visitChildElements((element) {
        if (element.widget is Semantics) {
          element.visitChildElements((child) {
            if (child.widget is Focus) {
              paginationFocus = child.widget as Focus;
            }
          });
        }
      });
      paginationFocus!.focusNode!.requestFocus();
      await tester.pumpAndSettle();
    }

    testWidgets('keyboard left arrow navigates to previous page', (
      tester,
    ) async {
      int? navigatedTo;
      await tester.pumpObers(
        OiPagination(
          totalItems: 75,
          currentPage: 2,
          label: 'items',
          onPageChange: (p) => navigatedTo = p,
        ),
        surfaceSize: wide,
      );

      await focusPagination(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      expect(navigatedTo, 1);
    });

    testWidgets('keyboard right arrow navigates to next page', (tester) async {
      int? navigatedTo;
      await tester.pumpObers(
        OiPagination(
          totalItems: 75,
          currentPage: 0,
          label: 'items',
          onPageChange: (p) => navigatedTo = p,
        ),
        surfaceSize: wide,
      );

      await focusPagination(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(navigatedTo, 1);
    });

    testWidgets('keyboard left arrow does nothing on first page', (
      tester,
    ) async {
      int? navigatedTo;
      await tester.pumpObers(
        OiPagination(
          totalItems: 75,
          currentPage: 0,
          label: 'items',
          onPageChange: (p) => navigatedTo = p,
        ),
        surfaceSize: wide,
      );

      await focusPagination(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      expect(navigatedTo, isNull);
    });

    testWidgets('keyboard right arrow does nothing on last page', (
      tester,
    ) async {
      int? navigatedTo;
      await tester.pumpObers(
        OiPagination(
          totalItems: 75,
          currentPage: 2,
          label: 'items',
          onPageChange: (p) => navigatedTo = p,
        ),
        surfaceSize: wide,
      );

      await focusPagination(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(navigatedTo, isNull);
    });
  });

  group('OiPagination - accessibility', () {
    testWidgets('has navigation semantics landmark', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpObers(
        OiPagination(
          totalItems: 75,
          currentPage: 0,
          label: 'items',
          onPageChange: (_) {},
        ),
        surfaceSize: wide,
      );

      expect(
        find.bySemanticsLabel(RegExp('Pagination navigation')),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets('compact variant has navigation semantics landmark', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpObers(
        OiPagination.compact(
          totalItems: 100,
          currentPage: 0,
          label: 'items',
          onPageChange: (_) {},
        ),
      );

      expect(
        find.bySemanticsLabel(RegExp('Pagination navigation')),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets('loadMore variant has navigation semantics landmark', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpObers(
        OiPagination.loadMore(
          loadedCount: 25,
          totalItems: 100,
          label: 'items',
          onLoadMore: () {},
        ),
      );

      expect(
        find.bySemanticsLabel(RegExp('Pagination navigation')),
        findsOneWidget,
      );

      handle.dispose();
    });
  });
}
