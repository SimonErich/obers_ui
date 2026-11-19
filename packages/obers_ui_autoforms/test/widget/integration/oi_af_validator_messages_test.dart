import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';
import 'package:obers_ui_autoforms/src/validation/oi_af_validation_messages.dart';

import '../../fixtures/test_enums.dart';

final class _LocalizedResolver extends OiAfMessageResolver {
  const _LocalizedResolver();

  @override
  String invalidIpAddress(BuildContext context) => 'L_IP';

  @override
  String invalidIpV4Address(BuildContext context) => 'L_IPV4';

  @override
  String invalidIpV6Address(BuildContext context) => 'L_IPV6';

  @override
  String notMultipleOf(BuildContext context, num factor) =>
      'L_MULTIPLE_$factor';

  @override
  String decimalPlaces(BuildContext context, int min, int? max) =>
      'L_DECIMAL_${min}_$max';

  @override
  String digitsBetween(BuildContext context, int min, int max) =>
      'L_DIGITS_${min}_$max';

  @override
  String itemsNotDistinct(BuildContext context) => 'L_DISTINCT';

  @override
  String dateTodayOrLater(BuildContext context) => 'L_TODAY_OR_LATER';

  @override
  String dateTodayOrEarlier(BuildContext context) => 'L_TODAY_OR_EARLIER';
}

void main() {
  late BuildContext context;

  Future<void> pumpContext(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    context = tester.element(find.byType(SizedBox));
  }

  OiAfValidationContext<TestField, T> ctx<T>(
    T? value, {
    bool localized = true,
  }) {
    return OiAfValidationContext<TestField, T>(
      field: TestField.name,
      value: value,
      form: MockReader(),
      trigger: OiAfValidationTrigger.manual,
      isRequired: false,
      isVisible: true,
      isEnabled: true,
      messages: localized
          ? OiAfValidationMessages(
              resolver: const _LocalizedResolver(),
              context: context,
            )
          : null,
    );
  }

  group('validators resolve their default message', () {
    testWidgets('ipAddress', (tester) async {
      await pumpContext(tester);

      expect(OiAfValidators.ipAddress<TestField>()(ctx('nope')), 'L_IP');
      expect(
        OiAfValidators.ipAddress<TestField>(v4Only: true)(ctx('::1')),
        'L_IPV4',
      );
      expect(
        OiAfValidators.ipAddress<TestField>(v6Only: true)(ctx('1.2.3.4')),
        'L_IPV6',
      );
    });

    testWidgets('multipleOf, decimal and digitsBetween', (tester) async {
      await pumpContext(tester);

      expect(
        OiAfValidators.multipleOf<TestField>(5)(ctx<num?>(7)),
        'L_MULTIPLE_5',
      );
      expect(
        OiAfValidators.decimal<TestField>(2, maxPlaces: 3)(ctx<num?>(1.5)),
        'L_DECIMAL_2_3',
      );
      expect(
        OiAfValidators.digitsBetween<TestField>(2, 4)(ctx<num?>(1)),
        'L_DIGITS_2_4',
      );
    });

    testWidgets('distinct', (tester) async {
      await pumpContext(tester);

      expect(
        OiAfValidators.distinct<TestField>()(ctx<List<Object?>?>(['a', 'a'])),
        'L_DISTINCT',
      );
    });

    testWidgets('dateInFuture and dateInPast including today', (tester) async {
      await pumpContext(tester);
      final now = DateTime.now();

      expect(
        OiAfValidators.dateInFuture<TestField>()(
          ctx<DateTime?>(now.subtract(const Duration(days: 2))),
        ),
        'L_TODAY_OR_LATER',
      );
      expect(
        OiAfValidators.dateInPast<TestField>()(
          ctx<DateTime?>(now.add(const Duration(days: 2))),
        ),
        'L_TODAY_OR_EARLIER',
      );
    });

    testWidgets('an explicit message still wins', (tester) async {
      await pumpContext(tester);

      expect(
        OiAfValidators.multipleOf<TestField>(5, message: 'mine')(ctx<num?>(7)),
        'mine',
      );
    });

    testWidgets('English stays the fallback without a resolver', (
      tester,
    ) async {
      await pumpContext(tester);

      expect(
        OiAfValidators.multipleOf<TestField>(5)(ctx<num?>(7, localized: false)),
        'Must be a multiple of 5.',
      );
      expect(
        OiAfValidators.distinct<TestField>()(
          ctx<List<Object?>?>(['a', 'a'], localized: false),
        ),
        'All items must be unique.',
      );
    });
  });
}
