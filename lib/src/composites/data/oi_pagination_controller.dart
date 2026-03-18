import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Controls pagination state for a data table or list.
///
/// Tracks [currentPage], [pageSize], and [totalItems] and exposes derived
/// values such as [totalPages], [startIndex], [endIndex], and navigation
/// predicates. Notifies listeners whenever state changes.
///
/// ```dart
/// final ctrl = OiPaginationController(pageSize: 10, totalItems: 95);
/// ctrl.nextPage();
/// print(ctrl.currentPage); // 1
/// ```
///
/// {@category Composites}
class OiPaginationController extends ChangeNotifier {
  /// Creates an [OiPaginationController].
  ///
  /// [currentPage] must be >= 0.
  /// [pageSize] must be >= 1.
  /// [totalItems] must be >= 0.
  OiPaginationController({
    int currentPage = 0,
    int pageSize = 25,
    int totalItems = 0,
    this.serverSide = false,
  }) : assert(currentPage >= 0, 'currentPage must be >= 0'),
       assert(pageSize >= 1, 'pageSize must be >= 1'),
       assert(totalItems >= 0, 'totalItems must be >= 0'),
       _currentPage = currentPage,
       _pageSize = pageSize,
       _totalItems = totalItems;

  /// Whether pagination is managed server-side.
  ///
  /// When `true` the table skips client-side slicing and relies on the
  /// consumer to provide the correct page of rows.
  final bool serverSide;

  int _currentPage;
  int _pageSize;
  int _totalItems;

  /// The zero-based index of the currently visible page.
  int get currentPage => _currentPage;

  /// The maximum number of items shown per page.
  int get pageSize => _pageSize;

  /// The total number of items across all pages.
  int get totalItems => _totalItems;

  /// The total number of pages, always >= 1 when [totalItems] > 0.
  ///
  /// Returns 0 when [totalItems] is 0.
  int get totalPages => _totalItems == 0 ? 0 : (_totalItems / _pageSize).ceil();

  /// The zero-based index of the first item on the current page.
  int get startIndex => _currentPage * _pageSize;

  /// The zero-based index (exclusive) of the last item on the current page.
  int get endIndex => math.min((_currentPage + 1) * _pageSize, _totalItems);

  /// Whether a next page exists.
  bool get hasNextPage => _currentPage < totalPages - 1;

  /// Whether a previous page exists.
  bool get hasPreviousPage => _currentPage > 0;

  /// Whether the controller is on the first page.
  bool get isFirstPage => _currentPage == 0;

  /// Whether the controller is on the last page.
  bool get isLastPage => totalPages == 0 || _currentPage >= totalPages - 1;

  /// Navigates to [page], clamped to [0, totalPages - 1].
  ///
  /// Does nothing when [totalItems] is 0 or [page] equals [currentPage].
  void goToPage(int page) {
    if (_totalItems == 0) return;
    final clamped = page.clamp(0, totalPages - 1);
    if (clamped == _currentPage) return;
    _currentPage = clamped;
    notifyListeners();
  }

  /// Advances to the next page if one exists.
  void nextPage() {
    if (!hasNextPage) return;
    _currentPage++;
    notifyListeners();
  }

  /// Retreats to the previous page if one exists.
  void previousPage() {
    if (!hasPreviousPage) return;
    _currentPage--;
    notifyListeners();
  }

  /// Jumps to the first page.
  void firstPage() {
    if (_currentPage == 0) return;
    _currentPage = 0;
    notifyListeners();
  }

  /// Jumps to the last page.
  ///
  /// Does nothing when [totalItems] is 0.
  void lastPage() {
    if (_totalItems == 0) return;
    final last = totalPages - 1;
    if (_currentPage == last) return;
    _currentPage = last;
    notifyListeners();
  }

  /// Updates [pageSize] and resets to page 0.
  ///
  /// [size] must be >= 1.
  void setPageSize(int size) {
    assert(size >= 1, 'pageSize must be >= 1');
    if (_pageSize == size) return;
    _pageSize = size;
    _currentPage = 0;
    notifyListeners();
  }

  /// Updates [totalItems], adjusting [currentPage] downward if it would
  /// exceed the new last page.
  ///
  /// [total] must be >= 0.
  void setTotalItems(int total) {
    assert(total >= 0, 'totalItems must be >= 0');
    if (_totalItems == total) return;
    _totalItems = total;
    final pages = totalPages;
    if (pages > 0 && _currentPage >= pages) {
      _currentPage = pages - 1;
    } else if (pages == 0) {
      _currentPage = 0;
    }
    notifyListeners();
  }
}
