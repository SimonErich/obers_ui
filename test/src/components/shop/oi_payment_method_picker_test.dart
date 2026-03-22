// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/shop/oi_payment_method_picker.dart';
import 'package:obers_ui/src/components/shop/oi_payment_option.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';

import '../../../helpers/pump_app.dart';

// ── Test data ────────────────────────────────────────────────────────────────

const _visa = OiPaymentMethod(
  key: 'visa',
  label: 'Visa',
  description: 'Ending in 4242',
  lastFour: '4242',
);

const _mastercard = OiPaymentMethod(
  key: 'mastercard',
  label: 'Mastercard',
  description: 'Ending in 5555',
  lastFour: '5555',
  isDefault: true,
);

const _amex = OiPaymentMethod(
  key: 'amex',
  label: 'Amex',
  description: 'Ending in 1234',
  lastFour: '1234',
);

List<OiPaymentMethod> _samplePaymentMethods() => const [
  _visa,
  _mastercard,
  _amex,
];

Widget _buildPicker({
  List<OiPaymentMethod>? methods,
  Object? selectedKey,
  ValueChanged<OiPaymentMethod>? onSelect,
  String label = 'Payment method',
  Widget? addNewCard,
}) {
  return OiPaymentMethodPicker(
    label: label,
    methods: methods ?? _samplePaymentMethods(),
    selectedKey: selectedKey,
    onSelect: onSelect ?? (_) {},
    addNewCard: addNewCard,
  );
}

void main() {
  group('OiPaymentMethodPicker', () {
    // ── All methods render ──────────────────────────────────────────────

    group('all methods render', () {
      testWidgets('displays labels for all methods', (tester) async {
        await tester.pumpObers(_buildPicker());

        expect(find.text('Visa'), findsOneWidget);
        expect(find.text('Mastercard'), findsOneWidget);
        expect(find.text('Amex'), findsOneWidget);
      });

      testWidgets('displays descriptions for methods', (tester) async {
        await tester.pumpObers(_buildPicker());

        expect(find.text('Ending in 4242'), findsOneWidget);
        expect(find.text('Ending in 5555'), findsOneWidget);
        expect(find.text('Ending in 1234'), findsOneWidget);
      });

      testWidgets('renders correct number of OiPaymentOption widgets', (
        tester,
      ) async {
        await tester.pumpObers(_buildPicker());

        expect(find.byType(OiPaymentOption), findsNWidgets(3));
      });

      testWidgets('displays the picker label', (tester) async {
        await tester.pumpObers(_buildPicker(label: 'Choose payment'));

        expect(find.text('Choose payment'), findsOneWidget);
      });
    });

    // ── Selected method highlighted ─────────────────────────────────────

    group('selected method highlighted', () {
      testWidgets('selected method option has selected=true', (tester) async {
        await tester.pumpObers(_buildPicker(selectedKey: 'mastercard'));

        final options = tester
            .widgetList<OiPaymentOption>(find.byType(OiPaymentOption))
            .toList();

        expect(options[0].selected, isFalse);
        expect(options[1].selected, isTrue);
        expect(options[2].selected, isFalse);
      });

      testWidgets('no method selected when selectedKey is null', (
        tester,
      ) async {
        await tester.pumpObers(_buildPicker());

        final options = tester
            .widgetList<OiPaymentOption>(find.byType(OiPaymentOption))
            .toList();

        for (final option in options) {
          expect(option.selected, isFalse);
        }
      });
    });

    // ── onSelect fires correctly ────────────────────────────────────────

    group('onSelect fires correctly', () {
      testWidgets('fires onSelect with correct method on tap', (tester) async {
        OiPaymentMethod? selected;
        await tester.pumpObers(_buildPicker(onSelect: (m) => selected = m));

        await tester.tap(find.text('Visa'));
        await tester.pump();

        expect(selected, isNotNull);
        expect(selected!.key, 'visa');
        expect(selected!.label, 'Visa');
      });

      testWidgets('fires onSelect with different method on second tap', (
        tester,
      ) async {
        OiPaymentMethod? selected;
        await tester.pumpObers(_buildPicker(onSelect: (m) => selected = m));

        await tester.tap(find.text('Amex'));
        await tester.pump();

        expect(selected!.key, 'amex');
      });

      testWidgets('fires onSelect for default-marked method', (tester) async {
        OiPaymentMethod? selected;
        await tester.pumpObers(_buildPicker(onSelect: (m) => selected = m));

        await tester.tap(find.text('Mastercard'));
        await tester.pump();

        expect(selected!.key, 'mastercard');
        expect(selected!.isDefault, isTrue);
      });
    });

    // ── addNewCard slot renders below divider ────────────────────────────

    group('addNewCard slot renders below divider', () {
      testWidgets('addNewCard widget is rendered', (tester) async {
        await tester.pumpObers(
          _buildPicker(addNewCard: const Text('+ Add new card')),
        );

        expect(find.text('+ Add new card'), findsOneWidget);
      });

      testWidgets('divider is present when addNewCard and methods exist', (
        tester,
      ) async {
        await tester.pumpObers(
          _buildPicker(addNewCard: const Text('+ Add new card')),
        );

        expect(find.byType(OiDivider), findsOneWidget);
      });

      testWidgets('divider appears before addNewCard in tree order', (
        tester,
      ) async {
        await tester.pumpObers(
          _buildPicker(addNewCard: const Text('+ Add new card')),
        );

        // Both should be present — tree order is divider then addNewCard.
        final dividerOffset = tester.getTopLeft(find.byType(OiDivider));
        final addCardOffset = tester.getTopLeft(find.text('+ Add new card'));

        expect(
          dividerOffset.dy,
          lessThan(addCardOffset.dy),
          reason: 'Divider should appear above addNewCard widget',
        );
      });
    });

    // ── No divider when addNewCard absent ────────────────────────────────

    group('no divider when addNewCard absent', () {
      testWidgets('no OiDivider when addNewCard is null', (tester) async {
        await tester.pumpObers(_buildPicker());

        expect(find.byType(OiDivider), findsNothing);
      });

      testWidgets('no addNewCard slot rendered', (tester) async {
        await tester.pumpObers(_buildPicker());

        expect(find.text('+ Add new card'), findsNothing);
      });
    });

    // ── Empty methods with addNewCard ────────────────────────────────────

    group('empty methods with addNewCard', () {
      testWidgets('addNewCard renders when methods is empty', (tester) async {
        await tester.pumpObers(
          _buildPicker(
            methods: const [],
            addNewCard: const Text('+ Add new card'),
          ),
        );

        expect(find.text('+ Add new card'), findsOneWidget);
      });

      testWidgets('no divider when methods is empty', (tester) async {
        await tester.pumpObers(
          _buildPicker(
            methods: const [],
            addNewCard: const Text('+ Add new card'),
          ),
        );

        expect(find.byType(OiDivider), findsNothing);
      });

      testWidgets('empty methods without addNewCard renders nothing extra', (
        tester,
      ) async {
        await tester.pumpObers(_buildPicker(methods: const []));

        expect(find.byType(OiPaymentOption), findsNothing);
        expect(find.byType(OiDivider), findsNothing);
      });
    });

    // ── Accessibility radio group semantics ──────────────────────────────

    group('accessibility radio group semantics', () {
      testWidgets('picker has semantic label', (tester) async {
        await tester.pumpObers(_buildPicker(label: 'Choose payment'));

        expect(
          find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label == 'Choose payment',
          ),
          findsOneWidget,
        );
      });

      testWidgets('each payment option has semantics with selected state', (
        tester,
      ) async {
        await tester.pumpObers(_buildPicker(selectedKey: 'visa'));

        final methods = _samplePaymentMethods();
        for (final method in methods) {
          final isSelected = method.key == 'visa';
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
      });

      testWidgets(
        'radio group pattern: exactly one selected among all options',
        (tester) async {
          await tester.pumpObers(_buildPicker(selectedKey: 'amex'));

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
            _samplePaymentMethods().length,
            reason: 'Each payment option should have a Semantics with selected',
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

      testWidgets('semantic tree is generated without errors', (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpObers(_buildPicker());

        expect(tester.takeException(), isNull);
        handle.dispose();
      });
    });

    // ── Keyboard arrow key navigation between options ────────────────────

    group('keyboard arrow key navigation between options', () {
      testWidgets('tab moves focus to first option', (tester) async {
        await tester.pumpObers(_buildPicker(selectedKey: 'visa'));

        // Tab to focus the first focusable option.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        final primaryFocus = FocusManager.instance.primaryFocus;
        expect(primaryFocus, isNotNull, reason: 'Tab should give focus');
      });

      testWidgets('arrow down moves focus to a different node', (tester) async {
        await tester.pumpObers(_buildPicker(selectedKey: 'visa'));

        // Tab to focus the first option.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        final focusBefore = FocusManager.instance.primaryFocus;

        // Arrow-down to move focus.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        final focusAfter = FocusManager.instance.primaryFocus;
        expect(
          focusAfter,
          isNot(equals(focusBefore)),
          reason: 'Focus should move to a different node after arrow-down',
        );
      });

      testWidgets('arrow up moves focus to a different node', (tester) async {
        await tester.pumpObers(_buildPicker(selectedKey: 'visa'));

        // Tab twice to reach the second option.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        final focusBefore = FocusManager.instance.primaryFocus;

        // Arrow-up to move focus back.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();

        final focusAfter = FocusManager.instance.primaryFocus;
        expect(
          focusAfter,
          isNot(equals(focusBefore)),
          reason: 'Focus should move to a different node after arrow-up',
        );
      });

      testWidgets('enter on focused option triggers onSelected', (
        tester,
      ) async {
        OiPaymentMethod? selected;
        await tester.pumpObers(
          _buildPicker(onSelect: (m) => selected = m, selectedKey: 'visa'),
        );

        // Tab to focus the first option.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // Press Enter to activate the focused option.
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(selected, isNotNull, reason: 'onSelect should fire on Enter');
        expect(selected!.key, 'visa');
      });

      testWidgets('space on focused option triggers onSelected', (
        tester,
      ) async {
        OiPaymentMethod? selected;
        await tester.pumpObers(
          _buildPicker(onSelect: (m) => selected = m, selectedKey: 'visa'),
        );

        // Tab to focus the first option.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // Press Space to activate the focused option.
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();

        expect(selected, isNotNull, reason: 'onSelect should fire on Space');
        expect(selected!.key, 'visa');
      });

      testWidgets('tab then enter on second option selects it', (tester) async {
        OiPaymentMethod? selected;
        await tester.pumpObers(
          _buildPicker(onSelect: (m) => selected = m, selectedKey: 'visa'),
        );

        // Tab twice to reach the second option.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // Press Enter to select.
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(
          selected,
          isNotNull,
          reason: 'onSelect should fire on Enter for second option',
        );
        expect(selected!.key, 'mastercard');
      });

      testWidgets('keyboard nav on single item does not crash', (tester) async {
        await tester.pumpObers(
          _buildPicker(methods: const [_visa], selectedKey: 'visa'),
        );

        // Tab to focus the single option.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();

        expect(find.byType(OiPaymentOption), findsOneWidget);
      });
    });
  });
}
