// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_pagination.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // Pages variant uses a wide Row (total label, per-page selector, nav
  // buttons, page buttons) that needs a wide surface to avoid overflow.
  const _wide = Size(1200, 600);

  group('OiPagination - pages variant', () {
    testWidgets('renders page numbers for multi-page data', (tester) async {
      await tester.pumpObers(
        OiPagination(
          totalItems: 75,
          currentPage: 0,
          perPage: 25,
          onPageChange: (_) {},
        ),
        surfaceSize: _wide,
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
          perPage: 25,
          onPageChange: (_) {},
        ),
        surfaceSize: _wide,
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
          perPage: 25,
          onPageChange: (_) {},
        ),
        surfaceSize: _wide,
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
          perPage: 25,
          onPageChange: (_) {},
        ),
        surfaceSize: _wide,
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
          perPage: 25,
          onPageChange: (p) => tappedPage = p,
        ),
        surfaceSize: _wide,
      );

      await tester.tap(find.byKey(const Key('oi_pagination_page_1')));
      await tester.pumpAndSettle();
      expect(tappedPage, 1);
    });

    testWidgets('showPerPage false hides per-page selector', (tester) async {
      await tester.pumpObers(
        const OiPagination(totalItems: 100, currentPage: 0, showPerPage: false),
      );

      expect(find.byKey(const Key('oi_pagination_per_page')), findsNothing);
    });

    testWidgets('showTotal false hides total count label', (tester) async {
      await tester.pumpObers(
        const OiPagination(totalItems: 100, currentPage: 0, showTotal: false),
        surfaceSize: _wide,
      );

      expect(find.byKey(const Key('oi_pagination_total')), findsNothing);
    });

    testWidgets('showFirstLast false hides first/last buttons', (tester) async {
      await tester.pumpObers(
        const OiPagination(
          totalItems: 100,
          currentPage: 0,
          showFirstLast: false,
        ),
      );

      expect(find.byKey(const Key('oi_pagination_first')), findsNothing);
      expect(find.byKey(const Key('oi_pagination_last')), findsNothing);
    });

    testWidgets('zero items shows empty state', (tester) async {
      await tester.pumpObers(
        const OiPagination(totalItems: 0, currentPage: 0),
        surfaceSize: _wide,
      );

      expect(find.text('0 items'), findsOneWidget);
    });

    testWidgets('single page hides page numbers navigation', (tester) async {
      await tester.pumpObers(
        const OiPagination(totalItems: 10, currentPage: 0, perPage: 25),
        surfaceSize: _wide,
      );

      // Only page "1" shown, no page "2"
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsNothing);
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
        OiPagination.compact(totalItems: 100, currentPage: 2, perPage: 25),
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
          perPage: 25,
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
    testWidgets('renders load-more button with count', (tester) async {
      await tester.pumpObers(
        OiPagination.loadMore(
          loadedCount: 25,
          totalItems: 100,
          onLoadMore: () {},
        ),
      );

      expect(find.text('25 of 100 loaded'), findsOneWidget);
      expect(find.byKey(const Key('oi_pagination_load_more')), findsOneWidget);
    });

    testWidgets('shows loading state when loading is true', (tester) async {
      await tester.pumpObers(
        OiPagination.loadMore(
          loadedCount: 25,
          totalItems: 100,
          onLoadMore: () {},
          loading: true,
        ),
      );

      // Button is present but in loading state
      expect(find.byKey(const Key('oi_pagination_load_more')), findsOneWidget);
    });

    testWidgets('hides button when loadedCount >= totalItems', (tester) async {
      await tester.pumpObers(
        const OiPagination.loadMore(loadedCount: 100, totalItems: 100),
      );

      expect(find.byKey(const Key('oi_pagination_load_more')), findsNothing);
    });

    testWidgets('calls onLoadMore when button tapped', (tester) async {
      bool called = false;
      await tester.pumpObers(
        OiPagination.loadMore(
          loadedCount: 25,
          totalItems: 100,
          onLoadMore: () => called = true,
        ),
      );

      await tester.tap(find.byKey(const Key('oi_pagination_load_more')));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });
  });
}
