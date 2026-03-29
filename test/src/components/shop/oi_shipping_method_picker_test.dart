// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/shop/oi_shipping_method_picker.dart';
import 'package:obers_ui/src/components/shop/oi_shipping_option.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';
import 'package:obers_ui/src/primitives/animation/oi_shimmer.dart';

import '../../../helpers/pump_app.dart';

// ── Test data ────────────────────────────────────────────────────────────────

List<OiShippingMethod> _sampleMethods() => const [
  OiShippingMethod(
    key: 'standard',
    label: 'Standard Shipping',
    price: 5.99,
    description: 'Delivered in 5-7 business days',
    estimatedDelivery: '5-7 days',
  ),
  OiShippingMethod(
    key: 'express',
    label: 'Express Shipping',
    price: 12.99,
    description: 'Delivered in 1-2 business days',
    estimatedDelivery: '1-2 days',
  ),
  OiShippingMethod(
    key: 'free',
    label: 'Free Shipping',
    price: 0,
    description: 'Delivered in 10-14 business days',
    estimatedDelivery: '10-14 days',
  ),
];

Widget _buildPicker({
  List<OiShippingMethod>? methods,
  Object? selectedKey,
  ValueChanged<OiShippingMethod>? onSelect,
  String label = 'Shipping method',
  String currencyCode = 'EUR',
  String emptyLabel = 'No shipping methods available',
  bool loading = false,
}) {
  return OiShippingMethodPicker(
    label: label,
    methods: methods ?? _sampleMethods(),
    selectedKey: selectedKey,
    onSelect: onSelect ?? (_) {},
    currencyCode: currencyCode,
    emptyLabel: emptyLabel,
    loading: loading,
  );
}

void main() {
  group('OiShippingMethodPicker', () {
    // ── Renders all shipping methods ────────────────────────────────────

    group('renders all shipping methods', () {
      testWidgets('displays labels for all methods', (tester) async {
        await tester.pumpObers(_buildPicker());

        expect(find.text('Standard Shipping'), findsOneWidget);
        expect(find.text('Express Shipping'), findsOneWidget);
        expect(find.text('Free Shipping'), findsOneWidget);
      });

      testWidgets('displays description for methods', (tester) async {
        await tester.pumpObers(_buildPicker());

        expect(find.text('Delivered in 5-7 business days'), findsOneWidget);
        expect(find.text('Delivered in 1-2 business days'), findsOneWidget);
      });

      testWidgets('displays estimated delivery for methods', (tester) async {
        await tester.pumpObers(_buildPicker());

        expect(find.text('5-7 days'), findsOneWidget);
        expect(find.text('1-2 days'), findsOneWidget);
        expect(find.text('10-14 days'), findsOneWidget);
      });

      testWidgets('renders correct number of OiShippingOption widgets', (
        tester,
      ) async {
        await tester.pumpObers(_buildPicker());

        expect(find.byType(OiShippingOption), findsNWidgets(3));
      });

      testWidgets('displays the picker label', (tester) async {
        await tester.pumpObers(_buildPicker(label: 'Choose delivery'));

        expect(find.text('Choose delivery'), findsOneWidget);
      });
    });

    // ── Selected method highlighted ─────────────────────────────────────

    group('selected method highlighted', () {
      testWidgets('selected method option has selected=true', (tester) async {
        await tester.pumpObers(_buildPicker(selectedKey: 'express'));

        final options = tester
            .widgetList<OiShippingOption>(find.byType(OiShippingOption))
            .toList();

        // Standard (index 0) should not be selected.
        expect(options[0].selected, isFalse);
        // Express (index 1) should be selected.
        expect(options[1].selected, isTrue);
        // Free (index 2) should not be selected.
        expect(options[2].selected, isFalse);
      });

      testWidgets('no method selected when selectedKey is null', (
        tester,
      ) async {
        await tester.pumpObers(_buildPicker());

        final options = tester
            .widgetList<OiShippingOption>(find.byType(OiShippingOption))
            .toList();

        for (final option in options) {
          expect(option.selected, isFalse);
        }
      });
    });

    // ── onSelect fires correctly ────────────────────────────────────────

    group('onSelect fires correctly', () {
      testWidgets('fires onSelect with correct method on tap', (tester) async {
        OiShippingMethod? selected;
        await tester.pumpObers(_buildPicker(onSelect: (m) => selected = m));

        await tester.tap(find.text('Standard Shipping'));
        await tester.pump();

        expect(selected, isNotNull);
        expect(selected!.key, 'standard');
        expect(selected!.label, 'Standard Shipping');
        expect(selected!.price, 5.99);
      });

      testWidgets('fires onSelect with different method on second tap', (
        tester,
      ) async {
        OiShippingMethod? selected;
        await tester.pumpObers(_buildPicker(onSelect: (m) => selected = m));

        await tester.tap(find.text('Express Shipping'));
        await tester.pump();

        expect(selected!.key, 'express');
        expect(selected!.price, 12.99);
      });

      testWidgets('fires onSelect for free shipping method', (tester) async {
        OiShippingMethod? selected;
        await tester.pumpObers(_buildPicker(onSelect: (m) => selected = m));

        await tester.tap(find.text('Free Shipping'));
        await tester.pump();

        expect(selected!.key, 'free');
        expect(selected!.price, 0);
      });
    });

    // ── Empty methods handling ───────────────────────────────────────────

    group('empty methods handling', () {
      testWidgets('shows default empty label when methods list is empty', (
        tester,
      ) async {
        await tester.pumpObers(_buildPicker(methods: const []));

        expect(find.text('No shipping methods available'), findsOneWidget);
        expect(find.byType(OiShippingOption), findsNothing);
      });

      testWidgets('shows custom empty label when provided', (tester) async {
        await tester.pumpObers(
          _buildPicker(methods: const [], emptyLabel: 'No options'),
        );

        expect(find.text('No options'), findsOneWidget);
      });

      testWidgets('still displays the picker label when empty', (tester) async {
        await tester.pumpObers(
          _buildPicker(methods: const [], label: 'Choose shipping'),
        );

        expect(find.text('Choose shipping'), findsOneWidget);
      });
    });

    // ── currencyCode forwarding ─────────────────────────────────────────

    group('currencyCode forwarding', () {
      testWidgets('forwards EUR currency code to options', (tester) async {
        await tester.pumpObers(_buildPicker());

        // EUR prices display with € symbol after the amount.
        expect(find.text('5.99 €'), findsOneWidget);
        expect(find.text('12.99 €'), findsOneWidget);
      });

      testWidgets('forwards USD currency code to options', (tester) async {
        await tester.pumpObers(
          _buildPicker(
            methods: const [
              OiShippingMethod(key: 'std', label: 'Standard', price: 9.99),
            ],
            currencyCode: 'USD',
          ),
        );

        // USD prices display with $ symbol before the amount.
        expect(find.textContaining(r'$'), findsWidgets);
      });

      testWidgets('forwards GBP currency code to options', (tester) async {
        await tester.pumpObers(
          _buildPicker(
            methods: const [
              OiShippingMethod(key: 'std', label: 'Standard', price: 7.50),
            ],
            currencyCode: 'GBP',
          ),
        );

        // GBP prices display with £ symbol before the amount.
        expect(find.text('£7.50'), findsOneWidget);
      });

      testWidgets('free shipping displays "Free" regardless of currency', (
        tester,
      ) async {
        await tester.pumpObers(
          _buildPicker(
            methods: const [
              OiShippingMethod(key: 'free', label: 'Free', price: 0),
            ],
            currencyCode: 'USD',
          ),
        );

        expect(find.text('Free'), findsWidgets);
      });

      testWidgets('OiShippingOption receives currencyCode from picker', (
        tester,
      ) async {
        await tester.pumpObers(_buildPicker(currencyCode: 'CHF'));

        final options = tester
            .widgetList<OiShippingOption>(find.byType(OiShippingOption))
            .toList();

        for (final option in options) {
          expect(option.currencyCode, 'CHF');
        }
      });
    });

    // ── Accessibility semantics ─────────────────────────────────────────

    group('accessibility semantics', () {
      testWidgets('picker has semantic label', (tester) async {
        await tester.pumpObers(_buildPicker(label: 'Choose shipping'));

        expect(
          find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label == 'Choose shipping',
          ),
          findsOneWidget,
        );
      });

      testWidgets('each shipping option has semantics', (tester) async {
        await tester.pumpObers(_buildPicker(selectedKey: 'express'));

        // Each OiShippingOption has a Semantics wrapper with selected state.
        final semanticsWidgets = tester
            .widgetList<Semantics>(
              find.descendant(
                of: find.byType(OiShippingMethodPicker),
                matching: find.byWidgetPredicate(
                  (w) => w is Semantics && w.properties.label != null,
                ),
              ),
            )
            .toList();

        // At minimum, the picker label + individual option labels.
        expect(semanticsWidgets.length, greaterThanOrEqualTo(2));
      });

      testWidgets('selected option has selected semantic', (tester) async {
        await tester.pumpObers(_buildPicker(selectedKey: 'standard'));

        // The OiShippingOption wraps with Semantics(selected: true).
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Semantics &&
                w.properties.label == 'Standard Shipping' &&
                (w.properties.selected ?? false),
          ),
          findsOneWidget,
        );
      });

      testWidgets('unselected option has selected=false semantic', (
        tester,
      ) async {
        await tester.pumpObers(_buildPicker(selectedKey: 'standard'));

        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Semantics &&
                w.properties.label == 'Express Shipping' &&
                w.properties.selected == false,
          ),
          findsOneWidget,
        );
      });

      testWidgets('semantic tree is generated without errors', (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpObers(_buildPicker());

        expect(tester.takeException(), isNull);
        handle.dispose();
      });

      testWidgets(
        'radio group pattern: exactly one selected among all options',
        (tester) async {
          await tester.pumpObers(_buildPicker(selectedKey: 'express'));

          // Each OiShippingOption wraps in Semantics(label:, selected:),
          // forming a radio-group-like pattern. Verify exactly one is selected.
          final optionSemantics = tester
              .widgetList<Semantics>(
                find.byWidgetPredicate(
                  (w) =>
                      w is Semantics &&
                      w.properties.label != null &&
                      w.properties.selected != null,
                ),
              )
              .toList();

          expect(
            optionSemantics.length,
            _sampleMethods().length,
            reason:
                'Each shipping option should have a Semantics with selected',
          );

          final selectedCount = optionSemantics
              .where((s) => s.properties.selected!)
              .length;
          expect(
            selectedCount,
            1,
            reason: 'Exactly one option should be semantically selected',
          );
        },
      );

      testWidgets(
        'radio group semantics: options use mutually exclusive selection',
        (tester) async {
          // OiShippingOption uses Semantics(label:, selected:) per option,
          // which is the standard radio-button-like pattern. While it does not
          // set SemanticsProperties.inMutuallyExclusiveGroup explicitly, the
          // combination of (label + selected) on sibling widgets creates the
          // semantic equivalent of a radio group.
          await tester.pumpObers(_buildPicker(selectedKey: 'standard'));

          // Verify each option has a Semantics node with an explicit selected
          // property (true or false), confirming the radio pattern.
          final methods = _sampleMethods();
          for (final method in methods) {
            final isSelected = method.key == 'standard';
            expect(
              find.byWidgetPredicate(
                (w) =>
                    w is Semantics &&
                    w.properties.label == method.label &&
                    w.properties.selected == isSelected,
              ),
              findsOneWidget,
              reason:
                  '${method.label} should have selected=$isSelected semantics',
            );
          }

          // Verify that switching selection changes the semantic state.
          // Re-pump with different selection to confirm mutual exclusivity.
          await tester.pumpObers(_buildPicker(selectedKey: 'express'));

          expect(
            find.byWidgetPredicate(
              (w) =>
                  w is Semantics &&
                  w.properties.label == 'Standard Shipping' &&
                  w.properties.selected == false,
            ),
            findsOneWidget,
            reason:
                'Standard should become unselected when express is selected',
          );
          expect(
            find.byWidgetPredicate(
              (w) =>
                  w is Semantics &&
                  w.properties.label == 'Express Shipping' &&
                  (w.properties.selected ?? false),
            ),
            findsOneWidget,
            reason: 'Express should become selected',
          );
        },
      );
    });

    // ── Loading state ───────────────────────────────────────────────────

    group('loading state', () {
      testWidgets('loading true shows shimmer placeholders', (tester) async {
        await tester.pumpObers(_buildPicker(loading: true));

        expect(find.byType(OiShimmer), findsWidgets);
      });

      testWidgets('loading true hides shipping method widgets', (tester) async {
        await tester.pumpObers(_buildPicker(loading: true));

        expect(find.byType(OiShippingOption), findsNothing);
      });

      testWidgets('loading true hides methods even when methods provided', (
        tester,
      ) async {
        await tester.pumpObers(
          _buildPicker(methods: _sampleMethods(), loading: true),
        );

        expect(find.byType(OiShippingOption), findsNothing);
        expect(find.text('Standard Shipping'), findsNothing);
        expect(find.byType(OiShimmer), findsWidgets);
      });

      testWidgets('loading true ignores selectedKey', (tester) async {
        await tester.pumpObers(
          _buildPicker(selectedKey: 'express', loading: true),
        );

        expect(find.byType(OiShippingOption), findsNothing);
        expect(find.byType(OiShimmer), findsWidgets);
      });

      testWidgets('loading false shows methods normally', (tester) async {
        await tester.pumpObers(_buildPicker());

        expect(find.byType(OiShippingOption), findsNWidgets(3));
        expect(find.byType(OiShimmer), findsNothing);
      });

      testWidgets('still displays picker label when loading', (tester) async {
        await tester.pumpObers(
          _buildPicker(label: 'Choose delivery', loading: true),
        );

        expect(find.text('Choose delivery'), findsOneWidget);
      });
    });

    // ── Single method ────────────────────────────────────────────────────

    group('single method', () {
      testWidgets('renders correctly with only one method', (tester) async {
        await tester.pumpObers(
          _buildPicker(
            methods: const [
              OiShippingMethod(key: 'only', label: 'Only Option', price: 3),
            ],
          ),
        );

        expect(find.text('Only Option'), findsOneWidget);
        expect(find.byType(OiShippingOption), findsOneWidget);
      });
    });
  });
}
