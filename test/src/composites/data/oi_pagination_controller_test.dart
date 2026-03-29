// Tests do not require documentation comments.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/data/oi_pagination_controller.dart';

void main() {
  group('OiPaginationController', () {
    // ── Initial state ────────────────────────────────────────────────────────

    test('default constructor has expected initial values', () {
      final ctrl = OiPaginationController();
      expect(ctrl.currentPage, 0);
      expect(ctrl.pageSize, 25);
      expect(ctrl.totalItems, 0);
      expect(ctrl.totalPages, 0);
      expect(ctrl.startIndex, 0);
      expect(ctrl.endIndex, 0);
      expect(ctrl.hasNextPage, isFalse);
      expect(ctrl.hasPreviousPage, isFalse);
      expect(ctrl.isFirstPage, isTrue);
      expect(ctrl.isLastPage, isTrue);
    });

    test('custom initial values are stored', () {
      final ctrl = OiPaginationController(
        currentPage: 2,
        pageSize: 10,
        totalItems: 95,
      );
      expect(ctrl.currentPage, 2);
      expect(ctrl.pageSize, 10);
      expect(ctrl.totalItems, 95);
    });

    // ── Derived properties ───────────────────────────────────────────────────

    test('totalPages rounds up correctly', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 95);
      expect(ctrl.totalPages, 10);
    });

    test('totalPages is 1 when items exactly fill one page', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 10);
      expect(ctrl.totalPages, 1);
    });

    test('totalPages is 0 when totalItems is 0', () {
      final ctrl = OiPaginationController();
      expect(ctrl.totalPages, 0);
    });

    test('startIndex is currentPage * pageSize', () {
      final ctrl = OiPaginationController(
        currentPage: 3,
        pageSize: 10,
        totalItems: 50,
      );
      expect(ctrl.startIndex, 30);
    });

    test('endIndex is min of next page start and totalItems', () {
      final ctrl = OiPaginationController(
        currentPage: 3,
        pageSize: 10,
        totalItems: 35,
      );
      expect(ctrl.endIndex, 35); // last partial page
    });

    test('endIndex on full page equals (page+1)*pageSize', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 50);
      expect(ctrl.endIndex, 10);
    });

    test('hasNextPage is false on last page', () {
      final ctrl = OiPaginationController(
        currentPage: 4,
        pageSize: 10,
        totalItems: 50,
      );
      expect(ctrl.hasNextPage, isFalse);
    });

    test('hasNextPage is true when not on last page', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 50);
      expect(ctrl.hasNextPage, isTrue);
    });

    test('hasPreviousPage is false on first page', () {
      final ctrl = OiPaginationController(totalItems: 50);
      expect(ctrl.hasPreviousPage, isFalse);
    });

    test('hasPreviousPage is true beyond first page', () {
      final ctrl = OiPaginationController(
        currentPage: 1,
        pageSize: 10,
        totalItems: 50,
      );
      expect(ctrl.hasPreviousPage, isTrue);
    });

    test('isFirstPage is true only on page 0', () {
      final ctrl = OiPaginationController(
        currentPage: 1,
        pageSize: 10,
        totalItems: 50,
      );
      expect(ctrl.isFirstPage, isFalse);
    });

    test('isLastPage is true on last page', () {
      final ctrl = OiPaginationController(
        currentPage: 4,
        pageSize: 10,
        totalItems: 50,
      );
      expect(ctrl.isLastPage, isTrue);
    });

    // ── goToPage ─────────────────────────────────────────────────────────────

    test('goToPage navigates to specified page', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 100)
        ..goToPage(5);
      expect(ctrl.currentPage, 5);
    });

    test('goToPage clamps to last page when over range', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 30)
        ..goToPage(99);
      expect(ctrl.currentPage, 2);
    });

    test('goToPage clamps to 0 when negative', () {
      final ctrl = OiPaginationController(
        currentPage: 2,
        pageSize: 10,
        totalItems: 50,
      )..goToPage(-5);
      expect(ctrl.currentPage, 0);
    });

    test('goToPage does nothing when totalItems is 0', () {
      final ctrl = OiPaginationController()..goToPage(3);
      expect(ctrl.currentPage, 0);
    });

    test('goToPage notifies listeners', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 50);
      var notified = false;
      ctrl
        ..addListener(() => notified = true)
        ..goToPage(2);
      expect(notified, isTrue);
    });

    test('goToPage does not notify when page unchanged', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 50);
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..goToPage(0);
      expect(count, 0);
    });

    // ── nextPage ─────────────────────────────────────────────────────────────

    test('nextPage increments currentPage', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 50)
        ..nextPage();
      expect(ctrl.currentPage, 1);
    });

    test('nextPage does nothing on last page', () {
      final ctrl = OiPaginationController(
        currentPage: 4,
        pageSize: 10,
        totalItems: 50,
      )..nextPage();
      expect(ctrl.currentPage, 4);
    });

    test('nextPage notifies listeners', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 50);
      var notified = false;
      ctrl
        ..addListener(() => notified = true)
        ..nextPage();
      expect(notified, isTrue);
    });

    // ── previousPage ─────────────────────────────────────────────────────────

    test('previousPage decrements currentPage', () {
      final ctrl = OiPaginationController(
        currentPage: 3,
        pageSize: 10,
        totalItems: 50,
      )..previousPage();
      expect(ctrl.currentPage, 2);
    });

    test('previousPage does nothing on first page', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 50)
        ..previousPage();
      expect(ctrl.currentPage, 0);
    });

    test('previousPage notifies listeners', () {
      final ctrl = OiPaginationController(
        currentPage: 2,
        pageSize: 10,
        totalItems: 50,
      );
      var notified = false;
      ctrl
        ..addListener(() => notified = true)
        ..previousPage();
      expect(notified, isTrue);
    });

    // ── firstPage / lastPage ─────────────────────────────────────────────────

    test('firstPage jumps to page 0', () {
      final ctrl = OiPaginationController(
        currentPage: 4,
        pageSize: 10,
        totalItems: 50,
      )..firstPage();
      expect(ctrl.currentPage, 0);
    });

    test('firstPage does not notify when already on page 0', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 50);
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..firstPage();
      expect(count, 0);
    });

    test('lastPage jumps to last page', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 50)
        ..lastPage();
      expect(ctrl.currentPage, 4);
    });

    test('lastPage does nothing when totalItems is 0', () {
      final ctrl = OiPaginationController()..lastPage();
      expect(ctrl.currentPage, 0);
    });

    test('lastPage does not notify when already on last page', () {
      final ctrl = OiPaginationController(
        currentPage: 4,
        pageSize: 10,
        totalItems: 50,
      );
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..lastPage();
      expect(count, 0);
    });

    // ── setPageSize ──────────────────────────────────────────────────────────

    test('setPageSize updates pageSize and resets to page 0', () {
      final ctrl = OiPaginationController(
        currentPage: 3,
        pageSize: 10,
        totalItems: 100,
      )..setPageSize(25);
      expect(ctrl.pageSize, 25);
      expect(ctrl.currentPage, 0);
    });

    test('setPageSize notifies listeners', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 50);
      var notified = false;
      ctrl
        ..addListener(() => notified = true)
        ..setPageSize(20);
      expect(notified, isTrue);
    });

    test('setPageSize does not notify when value unchanged', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 50);
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..setPageSize(10);
      expect(count, 0);
    });

    // ── setTotalItems ────────────────────────────────────────────────────────

    test('setTotalItems updates totalItems', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 50)
        ..setTotalItems(200);
      expect(ctrl.totalItems, 200);
    });

    test('setTotalItems adjusts currentPage when page goes out of range', () {
      final ctrl = OiPaginationController(
        currentPage: 4,
        pageSize: 10,
        totalItems: 50,
      )..setTotalItems(15); // only 2 pages now
      expect(ctrl.currentPage, 1);
    });

    test('setTotalItems resets to page 0 when totalItems becomes 0', () {
      final ctrl = OiPaginationController(
        currentPage: 2,
        pageSize: 10,
        totalItems: 50,
      )..setTotalItems(0);
      expect(ctrl.currentPage, 0);
    });

    test('setTotalItems notifies listeners', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 50);
      var notified = false;
      ctrl
        ..addListener(() => notified = true)
        ..setTotalItems(100);
      expect(notified, isTrue);
    });

    test('setTotalItems does not notify when value unchanged', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 50);
      var count = 0;
      ctrl
        ..addListener(() => count++)
        ..setTotalItems(50);
      expect(count, 0);
    });

    // ── Edge cases ───────────────────────────────────────────────────────────

    test('single item: totalPages=1, endIndex=1', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 1);
      expect(ctrl.totalPages, 1);
      expect(ctrl.endIndex, 1);
      expect(ctrl.isLastPage, isTrue);
    });

    test('exact page boundary: last item fills page exactly', () {
      final ctrl = OiPaginationController(
        currentPage: 4,
        pageSize: 10,
        totalItems: 50,
      );
      expect(ctrl.endIndex, 50);
      expect(ctrl.isLastPage, isTrue);
    });

    test('full round-trip navigation: first -> last -> first', () {
      final ctrl = OiPaginationController(pageSize: 10, totalItems: 50)
        ..lastPage();
      expect(ctrl.currentPage, 4);
      ctrl.firstPage();
      expect(ctrl.currentPage, 0);
    });
  });
}
