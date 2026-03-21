// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/shop/oi_coupon_input.dart';
import 'package:obers_ui/src/models/oi_coupon_result.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiCouponInput', () {
    testWidgets('shows text input and Apply button', (tester) async {
      await tester.pumpObers(
        OiCouponInput(
          label: 'Coupon',
          onApply: (_) async => const OiCouponResult(valid: true),
        ),
        surfaceSize: const Size(400, 200),
      );
      expect(find.byType(OiTextInput), findsOneWidget);
      expect(find.text('Apply'), findsOneWidget);
    });

    testWidgets('Apply button disabled when input is empty', (tester) async {
      await tester.pumpObers(
        OiCouponInput(
          label: 'Coupon',
          onApply: (_) async => const OiCouponResult(valid: true),
        ),
        surfaceSize: const Size(400, 200),
      );
      // Find the OiButton by text — it should be disabled (enabled: false).
      final button = tester.widget<OiButton>(
        find.widgetWithText(OiButton, 'Apply'),
      );
      expect(button.enabled, isFalse);
    });

    testWidgets('Apply button enabled when text entered', (tester) async {
      await tester.pumpObers(
        OiCouponInput(
          label: 'Coupon',
          onApply: (_) async => const OiCouponResult(valid: true),
        ),
        surfaceSize: const Size(400, 200),
      );
      await tester.enterText(find.byType(OiTextInput), 'SAVE10');
      await tester.pump();

      final button = tester.widget<OiButton>(
        find.widgetWithText(OiButton, 'Apply'),
      );
      expect(button.enabled, isTrue);
    });

    testWidgets('calls onApply with entered code on tap', (tester) async {
      String? receivedCode;
      await tester.pumpObers(
        OiCouponInput(
          label: 'Coupon',
          onApply: (code) async {
            receivedCode = code;
            return const OiCouponResult(valid: true);
          },
        ),
        surfaceSize: const Size(400, 200),
      );
      await tester.enterText(find.byType(OiTextInput), 'SAVE10');
      await tester.pump();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(receivedCode, 'SAVE10');
    });

    testWidgets('shows applied mode when appliedCode provided', (tester) async {
      await tester.pumpObers(
        OiCouponInput(
          label: 'Coupon',
          onApply: (_) async => const OiCouponResult(valid: true),
          appliedCode: 'SUMMER20',
        ),
        surfaceSize: const Size(400, 200),
      );
      // Should show the applied code and check icon, not the text input.
      expect(find.byKey(const Key('coupon_applied_code')), findsOneWidget);
      expect(find.byType(OiIcon), findsOneWidget);
      expect(find.byType(OiTextInput), findsNothing);
    });

    testWidgets('shows error message when invalid result', (tester) async {
      await tester.pumpObers(
        OiCouponInput(
          label: 'Coupon',
          onApply: (_) async =>
              const OiCouponResult(valid: false, message: 'Invalid code'),
        ),
        surfaceSize: const Size(400, 200),
      );
      await tester.enterText(find.byType(OiTextInput), 'BAD');
      await tester.pump();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('coupon_error')), findsOneWidget);
    });

    testWidgets('fires onRemove when remove button tapped in applied mode', (
      tester,
    ) async {
      var removed = false;
      await tester.pumpObers(
        OiCouponInput(
          label: 'Coupon',
          onApply: (_) async => const OiCouponResult(valid: true),
          appliedCode: 'SUMMER20',
          onRemove: () => removed = true,
        ),
        surfaceSize: const Size(400, 200),
      );
      await tester.tap(find.text('Remove coupon'));
      await tester.pump();
      expect(removed, isTrue);
    });

    testWidgets('loading state shows loading on button', (tester) async {
      await tester.pumpObers(
        OiCouponInput(
          label: 'Coupon',
          onApply: (_) async => const OiCouponResult(valid: true),
          loading: true,
        ),
        surfaceSize: const Size(400, 200),
      );
      final button = tester.widget<OiButton>(
        find.widgetWithText(OiButton, 'Apply'),
      );
      expect(button.loading, isTrue);
    });

    testWidgets('error clears on new input', (tester) async {
      await tester.pumpObers(
        OiCouponInput(
          label: 'Coupon',
          onApply: (_) async =>
              const OiCouponResult(valid: false, message: 'Invalid code'),
        ),
        surfaceSize: const Size(400, 200),
      );

      // Trigger error first.
      await tester.enterText(find.byType(OiTextInput), 'BAD');
      await tester.pump();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('coupon_error')), findsOneWidget);

      // Type new text — error should clear.
      await tester.enterText(find.byType(OiTextInput), 'GOOD');
      await tester.pump();
      expect(find.byKey(const Key('coupon_error')), findsNothing);
    });

    testWidgets('handles onApply exception gracefully', (tester) async {
      await tester.pumpObers(
        OiCouponInput(
          label: 'Coupon',
          onApply: (_) async => throw Exception('Network error'),
        ),
        surfaceSize: const Size(400, 200),
      );
      await tester.enterText(find.byType(OiTextInput), 'CODE');
      await tester.pump();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('coupon_error')), findsOneWidget);
    });

    testWidgets('accessibility label present', (tester) async {
      await tester.pumpObers(
        OiCouponInput(
          label: 'Discount code',
          onApply: (_) async => const OiCouponResult(valid: true),
        ),
        surfaceSize: const Size(400, 200),
      );
      expect(find.bySemanticsLabel('Discount code'), findsOneWidget);
    });
  });
}
