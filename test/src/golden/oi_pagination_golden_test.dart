// Golden tests have no public API.
// ignore_for_file: public_member_api_docs

import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

void main() {
  // ── Pages variant ───────────────────────────────────────────────────────

  testGoldens('OiPagination pages variant — light', (tester) async {
    final builder = obersGoldenBuilder(
      children: {
        'Page 1 of 4': OiPagination(
          totalItems: 100,
          currentPage: 0,
          label: 'items',
          onPageChange: (_) {},
          showPerPage: false,
          showTotal: false,
          showFirstLast: false,
        ),
        'Page 2 of 4': OiPagination(
          totalItems: 100,
          currentPage: 1,
          label: 'items',
          onPageChange: (_) {},
          showPerPage: false,
          showTotal: false,
          showFirstLast: false,
        ),
        'With total': OiPagination(
          totalItems: 100,
          currentPage: 0,
          label: 'items',
          onPageChange: (_) {},
          showPerPage: false,
          showFirstLast: false,
        ),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_pagination_pages_light');
  });

  testGoldens('OiPagination pages variant — dark', (tester) async {
    final builder = obersGoldenBuilder(
      theme: OiThemeData.dark(),
      children: {
        'Page 1 of 4': OiPagination(
          totalItems: 100,
          currentPage: 0,
          label: 'items',
          onPageChange: (_) {},
          showPerPage: false,
          showTotal: false,
          showFirstLast: false,
        ),
        'Page 2 of 4': OiPagination(
          totalItems: 100,
          currentPage: 1,
          label: 'items',
          onPageChange: (_) {},
          showPerPage: false,
          showTotal: false,
          showFirstLast: false,
        ),
        'With total': OiPagination(
          totalItems: 100,
          currentPage: 0,
          label: 'items',
          onPageChange: (_) {},
          showPerPage: false,
          showFirstLast: false,
        ),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_pagination_pages_dark');
  });

  // ── Compact variant ─────────────────────────────────────────────────────

  testGoldens('OiPagination compact variant — light', (tester) async {
    final builder = obersGoldenBuilder(
      children: {
        'Page 1 of 4': OiPagination.compact(
          totalItems: 100,
          currentPage: 0,
          label: 'items',
          onPageChange: (_) {},
        ),
        'Page 3 of 4': OiPagination.compact(
          totalItems: 100,
          currentPage: 2,
          label: 'items',
          onPageChange: (_) {},
        ),
        'Last page': OiPagination.compact(
          totalItems: 100,
          currentPage: 3,
          label: 'items',
          onPageChange: (_) {},
        ),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_pagination_compact_light');
  });

  testGoldens('OiPagination compact variant — dark', (tester) async {
    final builder = obersGoldenBuilder(
      theme: OiThemeData.dark(),
      children: {
        'Page 1 of 4': OiPagination.compact(
          totalItems: 100,
          currentPage: 0,
          label: 'items',
          onPageChange: (_) {},
        ),
        'Page 3 of 4': OiPagination.compact(
          totalItems: 100,
          currentPage: 2,
          label: 'items',
          onPageChange: (_) {},
        ),
        'Last page': OiPagination.compact(
          totalItems: 100,
          currentPage: 3,
          label: 'items',
          onPageChange: (_) {},
        ),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_pagination_compact_dark');
  });
}
