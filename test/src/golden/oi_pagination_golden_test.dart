// Golden tests have no public API.

import 'package:alchemist/alchemist.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

Future<void> main() async {
  // ── Pages variant ───────────────────────────────────────────────────────

  await goldenTest(
    'OiPagination pages variant — light',
    fileName: 'oi_pagination_pages_light',
    builder: () => obersGoldenGroup(
      cellSize: const Size(420, 120),
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
    ),
  );

  await goldenTest(
    'OiPagination pages variant — dark',
    fileName: 'oi_pagination_pages_dark',
    builder: () => obersGoldenGroup(
      theme: OiThemeData.dark(),
      cellSize: const Size(420, 120),
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
    ),
  );

  // ── Compact variant ─────────────────────────────────────────────────────

  await goldenTest(
    'OiPagination compact variant — light',
    fileName: 'oi_pagination_compact_light',
    builder: () => obersGoldenGroup(
      cellSize: const Size(420, 120),
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
    ),
  );

  await goldenTest(
    'OiPagination compact variant — dark',
    fileName: 'oi_pagination_compact_dark',
    builder: () => obersGoldenGroup(
      theme: OiThemeData.dark(),
      cellSize: const Size(420, 120),
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
    ),
  );
}
