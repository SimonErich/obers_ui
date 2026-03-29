// Golden tests have no public API.

import 'package:flutter/widgets.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
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

void main() {
  // ── Full cart ──────────────────────────────────────────────────────────────

  testGoldens('OiCartPanel full cart — light', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 1,
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
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_cart_panel_full_light');
  });

  testGoldens('OiCartPanel full cart — dark', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 1,
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
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_cart_panel_full_dark');
  });

  // ── Empty cart ─────────────────────────────────────────────────────────────

  testGoldens('OiCartPanel empty cart — light', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 1,
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
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_cart_panel_empty_light');
  });

  testGoldens('OiCartPanel empty cart — dark', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 1,
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
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_cart_panel_empty_dark');
  });
}
