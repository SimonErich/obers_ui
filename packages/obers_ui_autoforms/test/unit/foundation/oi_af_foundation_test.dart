import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

// ── Test helpers ────────────────────────────────────────────────────────────

enum _F { a, b, c }

class _MockReader implements OiAfReader<_F> {
  _MockReader([this._values = const {}]);
  final Map<_F, Object?> _values;

  @override
  TValue? get<TValue>(_F field) {
    final v = _values[field];
    if (v is TValue) return v;
    return null;
  }

  @override
  TValue getOr<TValue>(_F field, TValue fallback) =>
      get<TValue>(field) ?? fallback;

  @override
  bool isFieldVisible(_F field) => true;

  @override
  bool isFieldEnabled(_F field) => true;

  @override
  bool isFieldDirty(_F field) => false;
}

// ── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // ── OiAfTrackingReader ──────────────────────────────────────────────────

  group('OiAfTrackingReader', () {
    test('get() records field access', () {
      final delegate = _MockReader({_F.a: 'hello'});
      final tracker = OiAfTrackingReader<_F>(delegate);

      final result = tracker.get<String>(_F.a);

      expect(result, 'hello');
      expect(tracker.readFields, contains(_F.a));
    });

    test('getOr() records field access and returns fallback when null', () {
      final delegate = _MockReader();
      final tracker = OiAfTrackingReader<_F>(delegate);

      final result = tracker.getOr<int>(_F.b, 42);

      expect(result, 42);
      expect(tracker.readFields, contains(_F.b));
    });

    test('getOr() returns value when present', () {
      final delegate = _MockReader({_F.a: 10});
      final tracker = OiAfTrackingReader<_F>(delegate);

      final result = tracker.getOr<int>(_F.a, 42);

      expect(result, 10);
      expect(tracker.readFields, contains(_F.a));
    });

    test('isFieldVisible() records field access', () {
      final tracker = OiAfTrackingReader<_F>(_MockReader());

      final result = tracker.isFieldVisible(_F.c);

      expect(result, true);
      expect(tracker.readFields, contains(_F.c));
    });

    test('isFieldEnabled() records field access', () {
      final tracker = OiAfTrackingReader<_F>(_MockReader());

      final result = tracker.isFieldEnabled(_F.a);

      expect(result, true);
      expect(tracker.readFields, contains(_F.a));
    });

    test('isFieldDirty() records field access', () {
      final tracker = OiAfTrackingReader<_F>(_MockReader());

      final result = tracker.isFieldDirty(_F.b);

      expect(result, false);
      expect(tracker.readFields, contains(_F.b));
    });

    test('tracks multiple distinct field accesses', () {
      final tracker = OiAfTrackingReader<_F>(_MockReader())
        ..get<String>(_F.a)
        ..getOr<int>(_F.b, 0)
        ..isFieldVisible(_F.c);

      expect(tracker.readFields, {_F.a, _F.b, _F.c});
    });

    test('readFields deduplicates repeated accesses', () {
      final tracker = OiAfTrackingReader<_F>(_MockReader())
        ..get<String>(_F.a)
        ..get<String>(_F.a)
        ..getOr<String>(_F.a, '');

      expect(tracker.readFields.length, 1);
      expect(tracker.readFields, {_F.a});
    });

    test('reset() clears readFields', () {
      final tracker = OiAfTrackingReader<_F>(_MockReader())
        ..get<String>(_F.a)
        ..isFieldVisible(_F.b);
      expect(tracker.readFields, isNotEmpty);

      tracker.reset();

      expect(tracker.readFields, isEmpty);
    });

    test('readFields returns unmodifiable set', () {
      final tracker = OiAfTrackingReader<_F>(_MockReader())..get<String>(_F.a);

      expect(
        () => tracker.readFields.add(_F.b),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  // ── OiAfOption ──────────────────────────────────────────────────────────

  group('OiAfOption', () {
    test('equality: same value and label are equal', () {
      const a = OiAfOption<int>(value: 1, label: 'One');
      const b = OiAfOption<int>(value: 1, label: 'One');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality: different value', () {
      const a = OiAfOption<int>(value: 1, label: 'One');
      const b = OiAfOption<int>(value: 2, label: 'One');

      expect(a, isNot(equals(b)));
    });

    test('inequality: different label', () {
      const a = OiAfOption<int>(value: 1, label: 'One');
      const b = OiAfOption<int>(value: 1, label: 'Uno');

      expect(a, isNot(equals(b)));
    });

    test('enabled defaults to true', () {
      const option = OiAfOption<String>(value: 'x', label: 'X');
      expect(option.enabled, true);
    });

    test('group is null by default', () {
      const option = OiAfOption<String>(value: 'x', label: 'X');
      expect(option.group, isNull);
    });

    test('group property is preserved', () {
      const option = OiAfOption<String>(
        value: 'x',
        label: 'X',
        group: 'Letters',
      );
      expect(option.group, 'Letters');
    });

    test('equality includes enabled and group', () {
      const a = OiAfOption<int>(
        value: 1,
        label: 'One',
        enabled: false,
        group: 'G',
      );
      const b = OiAfOption<int>(value: 1, label: 'One', group: 'G');

      expect(a, isNot(equals(b)));
    });

    test('toString contains label and value', () {
      const option = OiAfOption<int>(value: 42, label: 'Answer');
      expect(option.toString(), contains('Answer'));
      expect(option.toString(), contains('42'));
    });
  });

  // ── OiAfSubmitResult ────────────────────────────────────────────────────

  group('OiAfSubmitResult', () {
    test('OiAfSubmitSuccess holds data', () {
      const result = OiAfSubmitSuccess<String>('ok');

      expect(result.data, 'ok');
      expect(result, isA<OiAfSubmitResult<String>>());
    });

    test('OiAfSubmitInvalid holds fieldErrors and globalErrors', () {
      const result = OiAfSubmitInvalid<String>(
        fieldErrors: {
          _F.a: ['Required'],
        },
        globalErrors: ['Form-level error'],
      );

      expect(result.fieldErrors[_F.a], ['Required']);
      expect(result.globalErrors, ['Form-level error']);
      expect(result, isA<OiAfSubmitResult<String>>());
    });

    test('OiAfSubmitFailure holds error, stackTrace, and globalErrors', () {
      final trace = StackTrace.current;
      final result = OiAfSubmitFailure<String>(
        error: 'Something went wrong',
        stackTrace: trace,
        globalErrors: const ['Server error'],
      );

      expect(result.error, 'Something went wrong');
      expect(result.stackTrace, trace);
      expect(result.globalErrors, ['Server error']);
      expect(result, isA<OiAfSubmitResult<String>>());
    });

    test('OiAfSubmitFailure data is optional', () {
      final result = OiAfSubmitFailure<String>(
        error: 'err',
        stackTrace: StackTrace.current,
        globalErrors: const [],
        data: 'partial',
      );

      expect(result.data, 'partial');
    });

    test('sealed class pattern matching covers all cases', () {
      final results = <OiAfSubmitResult<int>>[
        const OiAfSubmitSuccess(42),
        const OiAfSubmitInvalid(fieldErrors: {}, globalErrors: []),
        OiAfSubmitFailure(
          error: 'e',
          stackTrace: StackTrace.current,
          globalErrors: const [],
        ),
      ];

      for (final r in results) {
        final label = switch (r) {
          OiAfSubmitSuccess() => 'success',
          OiAfSubmitInvalid() => 'invalid',
          OiAfSubmitFailure() => 'failure',
        };
        expect(label, isNotEmpty);
      }
    });
  });

  // ── OiAfAggregateState ──────────────────────────────────────────────────

  group('OiAfAggregateState', () {
    OiAfAggregateState make({int fieldErrors = 0, int globalErrors = 0}) {
      return OiAfAggregateState(
        isValid: fieldErrors == 0 && globalErrors == 0,
        isDirty: false,
        isTouched: false,
        isEnabled: true,
        isSubmitting: false,
        isValidating: false,
        hasSubmitted: false,
        submitCount: 0,
        fieldErrorCount: fieldErrors,
        globalErrorCount: globalErrors,
      );
    }

    test('constructs with all fields', () {
      const state = OiAfAggregateState(
        isValid: true,
        isDirty: true,
        isTouched: true,
        isEnabled: true,
        isSubmitting: false,
        isValidating: false,
        hasSubmitted: true,
        submitCount: 3,
        fieldErrorCount: 0,
        globalErrorCount: 0,
      );

      expect(state.isValid, true);
      expect(state.isDirty, true);
      expect(state.isTouched, true);
      expect(state.isEnabled, true);
      expect(state.isSubmitting, false);
      expect(state.isValidating, false);
      expect(state.hasSubmitted, true);
      expect(state.submitCount, 3);
      expect(state.fieldErrorCount, 0);
      expect(state.globalErrorCount, 0);
    });

    test('hasErrors is true when fieldErrorCount > 0', () {
      final state = make(fieldErrors: 2);
      expect(state.hasErrors, true);
    });

    test('hasErrors is true when globalErrorCount > 0', () {
      final state = make(globalErrors: 1);
      expect(state.hasErrors, true);
    });

    test('hasErrors is false when no errors', () {
      final state = make();
      expect(state.hasErrors, false);
    });

    test('totalErrorCount sums field and global errors', () {
      final state = make(fieldErrors: 3, globalErrors: 2);
      expect(state.totalErrorCount, 5);
    });

    test('totalErrorCount is zero when no errors', () {
      final state = make();
      expect(state.totalErrorCount, 0);
    });
  });

  // ── OiAfDefaultMessageResolver ──────────────────────────────────────────

  group('OiAfDefaultMessageResolver', () {
    testWidgets('returns non-empty strings for key messages', (tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      final context = tester.element(find.byType(SizedBox));
      const resolver = OiAfDefaultMessageResolver();

      expect(resolver.requiredText(context), isNotEmpty);
      expect(resolver.invalidEmail(context), isNotEmpty);
      expect(resolver.tooShort(context, 3), isNotEmpty);
      expect(resolver.tooShort(context, 3), contains('3'));
      expect(resolver.tooLong(context, 50), isNotEmpty);
      expect(resolver.tooLong(context, 50), contains('50'));
      expect(resolver.exactLength(context, 10), isNotEmpty);
      expect(resolver.lengthBetween(context, 2, 8), isNotEmpty);
      expect(resolver.valuesDoNotMatch(context), isNotEmpty);
      expect(resolver.validationFailed(context), isNotEmpty);
      expect(resolver.submitFailed(context), isNotEmpty);
      expect(resolver.errorSummaryTitle(context, 1), isNotEmpty);
      expect(resolver.errorSummaryTitle(context, 3), contains('3'));
      expect(resolver.minValue(context, 5), isNotEmpty);
      expect(resolver.maxValue(context, 100), isNotEmpty);
      expect(resolver.rangeValue(context, 1, 10), isNotEmpty);
      expect(resolver.invalidUrl(context), isNotEmpty);
      expect(resolver.invalidPattern(context), isNotEmpty);
      expect(resolver.mustBeTrue(context), isNotEmpty);
      expect(resolver.mustBeFalse(context), isNotEmpty);
      expect(resolver.passwordTooWeak(context), isNotEmpty);
      expect(resolver.minItems(context, 2), isNotEmpty);
      expect(resolver.maxItems(context, 5), isNotEmpty);
      expect(resolver.invalidJson(context), isNotEmpty);
      expect(resolver.invalidUuid(context), isNotEmpty);
      expect(resolver.mustBeInteger(context), isNotEmpty);
      expect(resolver.fileTooLarge(context, 1024), isNotEmpty);
      expect(
        resolver.invalidFileExtension(context, ['pdf', 'png']),
        isNotEmpty,
      );
      expect(resolver.dateAfterError(context, '2024-01-01'), isNotEmpty);
      expect(resolver.dateBeforeError(context, '2024-12-31'), isNotEmpty);
      expect(resolver.dateFutureError(context), isNotEmpty);
      expect(resolver.datePastError(context), isNotEmpty);
      expect(resolver.differentFromField(context), isNotEmpty);
      expect(resolver.notInList(context), isNotEmpty);
    });

    testWidgets('singular vs plural in errorSummaryTitle', (tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      final context = tester.element(find.byType(SizedBox));
      const resolver = OiAfDefaultMessageResolver();

      final singular = resolver.errorSummaryTitle(context, 1);
      final plural = resolver.errorSummaryTitle(context, 2);

      expect(singular, contains('error'));
      expect(singular, isNot(contains('errors')));
      expect(plural, contains('errors'));
    });
  });

  // ── Enums ───────────────────────────────────────────────────────────────

  group('Enums', () {
    test('OiAfFieldType has 21 values', () {
      expect(OiAfFieldType.values.length, 21);
    });

    test('OiAfFieldType contains expected values', () {
      expect(OiAfFieldType.values, contains(OiAfFieldType.text));
      expect(OiAfFieldType.values, contains(OiAfFieldType.number));
      expect(OiAfFieldType.values, contains(OiAfFieldType.checkbox));
      expect(OiAfFieldType.values, contains(OiAfFieldType.switcher));
      expect(OiAfFieldType.values, contains(OiAfFieldType.select));
      expect(OiAfFieldType.values, contains(OiAfFieldType.file));
      expect(OiAfFieldType.values, contains(OiAfFieldType.array));
      expect(OiAfFieldType.values, contains(OiAfFieldType.slider));
      expect(OiAfFieldType.values, contains(OiAfFieldType.richText));
    });

    test('OiAfValidateMode has onBlurThenChange', () {
      expect(
        OiAfValidateMode.values,
        contains(OiAfValidateMode.onBlurThenChange),
      );
    });

    test('OiAfValidationTrigger has dependencyChange', () {
      expect(
        OiAfValidationTrigger.values,
        contains(OiAfValidationTrigger.dependencyChange),
      );
    });

    test('OiAfDeriveMode has expected values', () {
      expect(OiAfDeriveMode.values, contains(OiAfDeriveMode.onChange));
      expect(OiAfDeriveMode.values, contains(OiAfDeriveMode.onInit));
      expect(OiAfDeriveMode.values, contains(OiAfDeriveMode.onSubmit));
    });

    test('OiAfResetMode has expected values', () {
      expect(OiAfResetMode.values, contains(OiAfResetMode.toInitial));
      expect(OiAfResetMode.values, contains(OiAfResetMode.clear));
    });

    test('OiAfValueSource has expected values', () {
      expect(OiAfValueSource.values, contains(OiAfValueSource.user));
      expect(OiAfValueSource.values, contains(OiAfValueSource.derived));
      expect(OiAfValueSource.values, contains(OiAfValueSource.restore));
    });
  });
}
