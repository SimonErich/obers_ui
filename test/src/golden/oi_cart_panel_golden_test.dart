// Golden tests have no public API.

import 'package:alchemist/alchemist.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

const _items = [
  OiCartItem(productKey: 'p1', name: 'Widget A', unitPrice: 50),
  OiCartItem(productKey: 'p2', name: 'Widget B', unitPrice: 25, quantity: 2),
];

const _summary = OiCartSummary(
  subtotal: 100,
  discount: 10,
  discountLabel: 'SAVE10',
  shipping: 5,
  tax: 19,
  total: 114,
);

// ── Tests ────────────────────────────────────────────────────────────────────

Future<void> main() async {
  // ── Full cart ──────────────────────────────────────────────────────────────

  await goldenTest(
    'OiCartPanel full cart — light',
    fileName: 'oi_cart_panel_full_light',
    builder: () => obersGoldenGroup(
      columns: 1,
      cellSize: const Size(440, 560),
      children: {
        'Full cart': const SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: OiCartPanel(
              items: _items,
              summary: _summary,
              label: 'Shopping cart',
            ),
          ),
        ),
      },
    ),
  );

  await goldenTest(
    'OiCartPanel full cart — dark',
    fileName: 'oi_cart_panel_full_dark',
    builder: () => obersGoldenGroup(
      columns: 1,
      cellSize: const Size(440, 560),
      theme: OiThemeData.dark(),
      children: {
        'Full cart': const SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: OiCartPanel(
              items: _items,
              summary: _summary,
              label: 'Shopping cart',
            ),
          ),
        ),
      },
    ),
  );

  // ── Empty cart ─────────────────────────────────────────────────────────────

  await goldenTest(
    'OiCartPanel empty cart — light',
    fileName: 'oi_cart_panel_empty_light',
    builder: () => obersGoldenGroup(
      columns: 1,
      cellSize: const Size(440, 360),
      children: {
        'Empty cart': const SizedBox(
          width: 400,
          child: OiCartPanel(
            items: [],
            summary: OiCartSummary(subtotal: 0, total: 0),
            label: 'Shopping cart',
          ),
        ),
      },
    ),
  );

  await goldenTest(
    'OiCartPanel empty cart — dark',
    fileName: 'oi_cart_panel_empty_dark',
    builder: () => obersGoldenGroup(
      columns: 1,
      cellSize: const Size(440, 360),
      theme: OiThemeData.dark(),
      children: {
        'Empty cart': const SizedBox(
          width: 400,
          child: OiCartPanel(
            items: [],
            summary: OiCartSummary(subtotal: 0, total: 0),
            label: 'Shopping cart',
          ),
        ),
      },
    ),
  );
}
