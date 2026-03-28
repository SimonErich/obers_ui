import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

// ── Test Enum ────────────────────────────────────────────────────────────────

enum TestField { name, email, password, age, agree, country, tags, startDate }

// ── Mock Reader ──────────────────────────────────────────────────────────────

class MockReader implements OiAfReader<TestField> {
  MockReader([this._values = const {}]);

  final Map<TestField, Object?> _values;

  @override
  TValue? get<TValue>(TestField field) {
    final v = _values[field];
    if (v is TValue) return v;
    return null;
  }

  @override
  TValue getOr<TValue>(TestField field, TValue fallback) => get<TValue>(field) ?? fallback;

  @override
  bool isFieldVisible(TestField field) => true;

  @override
  bool isFieldEnabled(TestField field) => true;

  @override
  bool isFieldDirty(TestField field) => false;
}

// ── Helper ───────────────────────────────────────────────────────────────────

OiAfValidationContext<TestField, T> _ctx<T>(
  TestField field,
  T? value, {
  Map<TestField, Object?> formValues = const {},
  OiAfValidationTrigger trigger = OiAfValidationTrigger.manual,
}) {
  return OiAfValidationContext<TestField, T>(
    field: field,
    value: value,
    form: MockReader(formValues),
    trigger: trigger,
    isRequired: false,
    isVisible: true,
    isEnabled: true,
  );
}

void main() {
  // ═════════════════════════════════════════════════════════════════════════
  //  PRESENCE / REQUIRED
  // ═════════════════════════════════════════════════════════════════════════

  group('OiAfValidators.requiredText', () {
    final validator = OiAfValidators.requiredText<TestField>();

    test('returns error for null', () {
      final result = validator(_ctx<String>(TestField.name, null));
      expect(result, isNotNull);
    });

    test('returns error for empty string', () {
      final result = validator(_ctx<String>(TestField.name, ''));
      expect(result, isNotNull);
    });

    test('returns error for whitespace-only string', () {
      final result = validator(_ctx<String>(TestField.name, '   '));
      expect(result, isNotNull);
    });

    test('returns null for non-empty string', () {
      final result = validator(_ctx<String>(TestField.name, 'hello'));
      expect(result, isNull);
    });

    test('uses custom message', () {
      final v = OiAfValidators.requiredText<TestField>(message: 'Gimme text');
      final result = v(_ctx<String>(TestField.name, null));
      expect(result, 'Gimme text');
    });
  });

  group('OiAfValidators.requiredValue', () {
    final validator = OiAfValidators.requiredValue<TestField>();

    test('returns error for null', () {
      expect(validator(_ctx<Object?>(TestField.age, null)), isNotNull);
    });

    test('returns error for empty string', () {
      expect(validator(_ctx<Object?>(TestField.name, '')), isNotNull);
    });

    test('returns error for empty list', () {
      expect(validator(_ctx<Object?>(TestField.tags, <String>[])), isNotNull);
    });

    test('returns null for non-null value', () {
      expect(validator(_ctx<Object?>(TestField.age, 42)), isNull);
    });

    test('returns null for non-empty list', () {
      expect(validator(_ctx<Object?>(TestField.tags, ['a'])), isNull);
    });
  });

  group('OiAfValidators.requiredTrue', () {
    final validator = OiAfValidators.requiredTrue<TestField>();

    test('returns error for null', () {
      expect(validator(_ctx<bool?>(TestField.agree, null)), isNotNull);
    });

    test('returns error for false', () {
      expect(validator(_ctx<bool?>(TestField.agree, false)), isNotNull);
    });

    test('returns null for true', () {
      expect(validator(_ctx<bool?>(TestField.agree, true)), isNull);
    });
  });

  group('OiAfValidators.requiredFalse', () {
    final validator = OiAfValidators.requiredFalse<TestField>();

    test('returns error for null', () {
      expect(validator(_ctx<bool?>(TestField.agree, null)), isNotNull);
    });

    test('returns error for true', () {
      expect(validator(_ctx<bool?>(TestField.agree, true)), isNotNull);
    });

    test('returns null for false', () {
      expect(validator(_ctx<bool?>(TestField.agree, false)), isNull);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  CONDITIONAL REQUIRED
  // ═════════════════════════════════════════════════════════════════════════

  group('OiAfValidators.requiredIf', () {
    test('required when other field equals value and field is empty', () {
      final validator = OiAfValidators.requiredIf<TestField>(
        TestField.country,
        'US',
      );
      final result = validator(_ctx<Object?>(
        TestField.name,
        null,
        formValues: {TestField.country: 'US'},
      ));
      expect(result, isNotNull);
    });

    test('not required when other field does not equal value', () {
      final validator = OiAfValidators.requiredIf<TestField>(
        TestField.country,
        'US',
      );
      final result = validator(_ctx<Object?>(
        TestField.name,
        null,
        formValues: {TestField.country: 'DE'},
      ));
      expect(result, isNull);
    });

    test('passes when condition met and value present', () {
      final validator = OiAfValidators.requiredIf<TestField>(
        TestField.country,
        'US',
      );
      final result = validator(_ctx<Object?>(
        TestField.name,
        'John',
        formValues: {TestField.country: 'US'},
      ));
      expect(result, isNull);
    });
  });

  group('OiAfValidators.requiredUnless', () {
    test('required when other field does NOT equal value', () {
      final validator = OiAfValidators.requiredUnless<TestField>(
        TestField.country,
        'skip',
      );
      final result = validator(_ctx<Object?>(
        TestField.name,
        null,
        formValues: {TestField.country: 'US'},
      ));
      expect(result, isNotNull);
    });

    test('not required when other field equals value', () {
      final validator = OiAfValidators.requiredUnless<TestField>(
        TestField.country,
        'skip',
      );
      final result = validator(_ctx<Object?>(
        TestField.name,
        null,
        formValues: {TestField.country: 'skip'},
      ));
      expect(result, isNull);
    });
  });

  group('OiAfValidators.requiredWith', () {
    test('required when at least one other field is present', () {
      final validator = OiAfValidators.requiredWith<TestField>(
        [TestField.email, TestField.age],
      );
      final result = validator(_ctx<Object?>(
        TestField.name,
        null,
        formValues: {TestField.email: 'a@b.com'},
      ));
      expect(result, isNotNull);
    });

    test('not required when all other fields are absent', () {
      final validator = OiAfValidators.requiredWith<TestField>(
        [TestField.email, TestField.age],
      );
      final result = validator(_ctx<Object?>(
        TestField.name,
        null,
        formValues: {},
      ));
      expect(result, isNull);
    });

    test('passes when required and value present', () {
      final validator = OiAfValidators.requiredWith<TestField>(
        [TestField.email],
      );
      final result = validator(_ctx<Object?>(
        TestField.name,
        'John',
        formValues: {TestField.email: 'a@b.com'},
      ));
      expect(result, isNull);
    });
  });

  group('OiAfValidators.requiredWithout', () {
    test('required when at least one other field is absent', () {
      final validator = OiAfValidators.requiredWithout<TestField>(
        [TestField.email, TestField.age],
      );
      final result = validator(_ctx<Object?>(
        TestField.name,
        null,
        formValues: {TestField.email: 'a@b.com'},
      ));
      expect(result, isNotNull);
    });

    test('not required when all other fields are present', () {
      final validator = OiAfValidators.requiredWithout<TestField>(
        [TestField.email, TestField.age],
      );
      final result = validator(_ctx<Object?>(
        TestField.name,
        null,
        formValues: {TestField.email: 'a@b.com', TestField.age: 25},
      ));
      expect(result, isNull);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  STRING RULES
  // ═════════════════════════════════════════════════════════════════════════

  group('OiAfValidators.minLength', () {
    final validator = OiAfValidators.minLength<TestField>(3);

    test('passes for null', () {
      expect(validator(_ctx<String>(TestField.name, null)), isNull);
    });

    test('passes for empty string', () {
      expect(validator(_ctx<String>(TestField.name, '')), isNull);
    });

    test('fails when too short', () {
      expect(validator(_ctx<String>(TestField.name, 'ab')), isNotNull);
    });

    test('passes when exactly min length', () {
      expect(validator(_ctx<String>(TestField.name, 'abc')), isNull);
    });

    test('passes when longer than min', () {
      expect(validator(_ctx<String>(TestField.name, 'abcdef')), isNull);
    });
  });

  group('OiAfValidators.maxLength', () {
    final validator = OiAfValidators.maxLength<TestField>(5);

    test('passes for null', () {
      expect(validator(_ctx<String>(TestField.name, null)), isNull);
    });

    test('passes for empty string', () {
      expect(validator(_ctx<String>(TestField.name, '')), isNull);
    });

    test('passes when exactly max length', () {
      expect(validator(_ctx<String>(TestField.name, 'abcde')), isNull);
    });

    test('fails when too long', () {
      expect(validator(_ctx<String>(TestField.name, 'abcdef')), isNotNull);
    });
  });

  group('OiAfValidators.email', () {
    final validator = OiAfValidators.email<TestField>();

    test('passes for null', () {
      expect(validator(_ctx<String>(TestField.email, null)), isNull);
    });

    test('passes for empty string', () {
      expect(validator(_ctx<String>(TestField.email, '')), isNull);
    });

    test('passes for valid email', () {
      expect(validator(_ctx<String>(TestField.email, 'test@example.com')), isNull);
    });

    test('fails for invalid email', () {
      expect(validator(_ctx<String>(TestField.email, 'not-an-email')), isNotNull);
    });

    test('fails for email missing domain', () {
      expect(validator(_ctx<String>(TestField.email, 'test@')), isNotNull);
    });
  });

  group('OiAfValidators.url', () {
    final validator = OiAfValidators.url<TestField>();

    test('passes for null', () {
      expect(validator(_ctx<String>(TestField.name, null)), isNull);
    });

    test('passes for empty string', () {
      expect(validator(_ctx<String>(TestField.name, '')), isNull);
    });

    test('passes for valid https URL', () {
      expect(validator(_ctx<String>(TestField.name, 'https://example.com')), isNull);
    });

    test('passes for valid http URL', () {
      expect(validator(_ctx<String>(TestField.name, 'http://example.com')), isNull);
    });

    test('fails for ftp URL when only http/https allowed', () {
      expect(validator(_ctx<String>(TestField.name, 'ftp://example.com')), isNotNull);
    });

    test('allows custom protocols', () {
      final v = OiAfValidators.url<TestField>(protocols: ['ftp']);
      expect(v(_ctx<String>(TestField.name, 'ftp://example.com')), isNull);
    });

    test('fails for non-URL', () {
      expect(validator(_ctx<String>(TestField.name, 'not a url')), isNotNull);
    });
  });

  group('OiAfValidators.regex', () {
    final validator = OiAfValidators.regex<TestField>(RegExp(r'^\d{3}$'));

    test('passes for null', () {
      expect(validator(_ctx<String>(TestField.name, null)), isNull);
    });

    test('passes for matching value', () {
      expect(validator(_ctx<String>(TestField.name, '123')), isNull);
    });

    test('fails for non-matching value', () {
      expect(validator(_ctx<String>(TestField.name, 'abc')), isNotNull);
    });
  });

  group('OiAfValidators.alpha', () {
    final validator = OiAfValidators.alpha<TestField>();

    test('passes for null', () {
      expect(validator(_ctx<String>(TestField.name, null)), isNull);
    });

    test('passes for letters only', () {
      expect(validator(_ctx<String>(TestField.name, 'Hello')), isNull);
    });

    test('fails for letters with numbers', () {
      expect(validator(_ctx<String>(TestField.name, 'Hello123')), isNotNull);
    });

    test('passes for unicode letters when asciiOnly is false', () {
      expect(validator(_ctx<String>(TestField.name, 'Ünïcödé')), isNull);
    });

    test('fails for unicode letters when asciiOnly is true', () {
      final v = OiAfValidators.alpha<TestField>(asciiOnly: true);
      expect(v(_ctx<String>(TestField.name, 'Ünïcödé')), isNotNull);
    });
  });

  group('OiAfValidators.alphaNumeric', () {
    final validator = OiAfValidators.alphaNumeric<TestField>();

    test('passes for null', () {
      expect(validator(_ctx<String>(TestField.name, null)), isNull);
    });

    test('passes for letters and numbers', () {
      expect(validator(_ctx<String>(TestField.name, 'Hello123')), isNull);
    });

    test('fails for special characters', () {
      expect(validator(_ctx<String>(TestField.name, 'Hello@123')), isNotNull);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  SECURE PASSWORD
  // ═════════════════════════════════════════════════════════════════════════

  group('OiAfValidators.securePassword', () {
    test('passes for null', () {
      final v = OiAfValidators.securePassword<TestField>();
      expect(v(_ctx<String>(TestField.password, null)), isNull);
    });

    test('passes for empty string', () {
      final v = OiAfValidators.securePassword<TestField>();
      expect(v(_ctx<String>(TestField.password, '')), isNull);
    });

    test('fails for too-short password', () {
      final v = OiAfValidators.securePassword<TestField>();
      expect(v(_ctx<String>(TestField.password, 'short')), isNotNull);
    });

    test('passes for long enough password', () {
      final v = OiAfValidators.securePassword<TestField>();
      expect(v(_ctx<String>(TestField.password, 'longEnoughPassword')), isNull);
    });

    test('fails when uppercase required but missing', () {
      final v = OiAfValidators.securePassword<TestField>(
        minLength: 1,
        requiresUppercase: true,
      );
      expect(v(_ctx<String>(TestField.password, 'alllower')), isNotNull);
    });

    test('passes when uppercase required and present', () {
      final v = OiAfValidators.securePassword<TestField>(
        minLength: 1,
        requiresUppercase: true,
      );
      expect(v(_ctx<String>(TestField.password, 'hasUpper')), isNull);
    });

    test('fails when lowercase required but missing', () {
      final v = OiAfValidators.securePassword<TestField>(
        minLength: 1,
        requiresLowercase: true,
      );
      expect(v(_ctx<String>(TestField.password, 'ALLUPPER')), isNotNull);
    });

    test('fails when digit required but missing', () {
      final v = OiAfValidators.securePassword<TestField>(
        minLength: 1,
        requiresDigit: true,
      );
      expect(v(_ctx<String>(TestField.password, 'noDigits')), isNotNull);
    });

    test('passes when digit required and present', () {
      final v = OiAfValidators.securePassword<TestField>(
        minLength: 1,
        requiresDigit: true,
      );
      expect(v(_ctx<String>(TestField.password, 'has1digit')), isNull);
    });

    test('fails when special char required but missing', () {
      final v = OiAfValidators.securePassword<TestField>(
        minLength: 1,
        requiresSpecialChar: true,
      );
      expect(v(_ctx<String>(TestField.password, 'nospecial')), isNotNull);
    });

    test('passes when special char required and present', () {
      final v = OiAfValidators.securePassword<TestField>(
        minLength: 1,
        requiresSpecialChar: true,
      );
      expect(v(_ctx<String>(TestField.password, 'has@special')), isNull);
    });

    test('combines multiple requirements', () {
      final v = OiAfValidators.securePassword<TestField>(
        requiresUppercase: true,
        requiresLowercase: true,
        requiresDigit: true,
        requiresSpecialChar: true,
      );
      expect(v(_ctx<String>(TestField.password, 'Aa1!xxxx')), isNull);
      expect(v(_ctx<String>(TestField.password, 'short')), isNotNull);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  NUMERIC RULES
  // ═════════════════════════════════════════════════════════════════════════

  group('OiAfValidators.min', () {
    final validator = OiAfValidators.min<TestField>(10);

    test('passes for null', () {
      expect(validator(_ctx<num?>(TestField.age, null)), isNull);
    });

    test('passes when equal to min', () {
      expect(validator(_ctx<num?>(TestField.age, 10)), isNull);
    });

    test('passes when greater than min', () {
      expect(validator(_ctx<num?>(TestField.age, 15)), isNull);
    });

    test('fails when less than min', () {
      expect(validator(_ctx<num?>(TestField.age, 5)), isNotNull);
    });
  });

  group('OiAfValidators.max', () {
    final validator = OiAfValidators.max<TestField>(100);

    test('passes for null', () {
      expect(validator(_ctx<num?>(TestField.age, null)), isNull);
    });

    test('passes when equal to max', () {
      expect(validator(_ctx<num?>(TestField.age, 100)), isNull);
    });

    test('fails when greater than max', () {
      expect(validator(_ctx<num?>(TestField.age, 101)), isNotNull);
    });
  });

  group('OiAfValidators.range', () {
    final validator = OiAfValidators.range<TestField>(1, 10);

    test('passes for null', () {
      expect(validator(_ctx<num?>(TestField.age, null)), isNull);
    });

    test('passes for value in range', () {
      expect(validator(_ctx<num?>(TestField.age, 5)), isNull);
    });

    test('passes for min boundary', () {
      expect(validator(_ctx<num?>(TestField.age, 1)), isNull);
    });

    test('passes for max boundary', () {
      expect(validator(_ctx<num?>(TestField.age, 10)), isNull);
    });

    test('fails below range', () {
      expect(validator(_ctx<num?>(TestField.age, 0)), isNotNull);
    });

    test('fails above range', () {
      expect(validator(_ctx<num?>(TestField.age, 11)), isNotNull);
    });
  });

  group('OiAfValidators.integer', () {
    final validator = OiAfValidators.integer<TestField>();

    test('passes for null', () {
      expect(validator(_ctx<num?>(TestField.age, null)), isNull);
    });

    test('passes for integer value', () {
      expect(validator(_ctx<num?>(TestField.age, 42)), isNull);
    });

    test('passes for double with no fraction', () {
      expect(validator(_ctx<num?>(TestField.age, 42.0)), isNull);
    });

    test('fails for double with fraction', () {
      expect(validator(_ctx<num?>(TestField.age, 42.5)), isNotNull);
    });
  });

  group('OiAfValidators.multipleOf', () {
    final validator = OiAfValidators.multipleOf<TestField>(5);

    test('passes for null', () {
      expect(validator(_ctx<num?>(TestField.age, null)), isNull);
    });

    test('passes for multiple of factor', () {
      expect(validator(_ctx<num?>(TestField.age, 15)), isNull);
    });

    test('fails for non-multiple', () {
      expect(validator(_ctx<num?>(TestField.age, 7)), isNotNull);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  CROSS-FIELD COMPARISON
  // ═════════════════════════════════════════════════════════════════════════

  group('OiAfValidators.equalsField', () {
    final validator = OiAfValidators.equalsField<TestField>(TestField.password);

    test('passes for null', () {
      expect(validator(_ctx<String>(TestField.name, null)), isNull);
    });

    test('passes for empty', () {
      expect(validator(_ctx<String>(TestField.name, '')), isNull);
    });

    test('passes when values match', () {
      final result = validator(_ctx<String>(
        TestField.name,
        'secret',
        formValues: {TestField.password: 'secret'},
      ));
      expect(result, isNull);
    });

    test('fails when values differ', () {
      final result = validator(_ctx<String>(
        TestField.name,
        'secret',
        formValues: {TestField.password: 'different'},
      ));
      expect(result, isNotNull);
    });
  });

  group('OiAfValidators.differentFromField', () {
    final validator = OiAfValidators.differentFromField<TestField>(TestField.email);

    test('passes for null', () {
      expect(validator(_ctx<Object?>(TestField.name, null)), isNull);
    });

    test('passes when values differ', () {
      final result = validator(_ctx<Object?>(
        TestField.name,
        'hello',
        formValues: {TestField.email: 'world'},
      ));
      expect(result, isNull);
    });

    test('fails when values match', () {
      final result = validator(_ctx<Object?>(
        TestField.name,
        'same',
        formValues: {TestField.email: 'same'},
      ));
      expect(result, isNotNull);
    });
  });

  group('OiAfValidators.isIn', () {
    final validator = OiAfValidators.isIn<TestField, String>(['a', 'b', 'c']);

    test('passes for null', () {
      expect(validator(_ctx<String>(TestField.name, null)), isNull);
    });

    test('passes for value in list', () {
      expect(validator(_ctx<String>(TestField.name, 'a')), isNull);
    });

    test('fails for value not in list', () {
      expect(validator(_ctx<String>(TestField.name, 'z')), isNotNull);
    });
  });

  group('OiAfValidators.notIn', () {
    final validator = OiAfValidators.notIn<TestField, String>(['admin', 'root']);

    test('passes for null', () {
      expect(validator(_ctx<String>(TestField.name, null)), isNull);
    });

    test('passes for value not in list', () {
      expect(validator(_ctx<String>(TestField.name, 'user')), isNull);
    });

    test('fails for value in list', () {
      expect(validator(_ctx<String>(TestField.name, 'admin')), isNotNull);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  DATE RULES
  // ═════════════════════════════════════════════════════════════════════════

  group('OiAfValidators.dateAfter', () {
    final cutoff = DateTime(2025);
    final validator = OiAfValidators.dateAfter<TestField>(cutoff);

    test('passes for null', () {
      expect(validator(_ctx<DateTime?>(TestField.startDate, null)), isNull);
    });

    test('passes for date after cutoff', () {
      expect(
        validator(_ctx<DateTime?>(TestField.startDate, DateTime(2025, 6))),
        isNull,
      );
    });

    test('fails for date before cutoff', () {
      expect(
        validator(_ctx<DateTime?>(TestField.startDate, DateTime(2024, 12))),
        isNotNull,
      );
    });

    test('fails for date equal to cutoff', () {
      expect(
        validator(_ctx<DateTime?>(TestField.startDate, DateTime(2025))),
        isNotNull,
      );
    });
  });

  group('OiAfValidators.dateBefore', () {
    final cutoff = DateTime(2025, 12, 31);
    final validator = OiAfValidators.dateBefore<TestField>(cutoff);

    test('passes for null', () {
      expect(validator(_ctx<DateTime?>(TestField.startDate, null)), isNull);
    });

    test('passes for date before cutoff', () {
      expect(
        validator(_ctx<DateTime?>(TestField.startDate, DateTime(2025))),
        isNull,
      );
    });

    test('fails for date after cutoff', () {
      expect(
        validator(_ctx<DateTime?>(TestField.startDate, DateTime(2026))),
        isNotNull,
      );
    });

    test('fails for date equal to cutoff', () {
      expect(
        validator(_ctx<DateTime?>(TestField.startDate, DateTime(2025, 12, 31))),
        isNotNull,
      );
    });
  });

  group('OiAfValidators.dateInFuture', () {
    test('passes for null', () {
      final v = OiAfValidators.dateInFuture<TestField>();
      expect(v(_ctx<DateTime?>(TestField.startDate, null)), isNull);
    });

    test('passes for tomorrow', () {
      final v = OiAfValidators.dateInFuture<TestField>();
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(v(_ctx<DateTime?>(TestField.startDate, tomorrow)), isNull);
    });

    test('passes for today when includeToday is true', () {
      final v = OiAfValidators.dateInFuture<TestField>();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(v(_ctx<DateTime?>(TestField.startDate, today)), isNull);
    });

    test('fails for yesterday', () {
      final v = OiAfValidators.dateInFuture<TestField>();
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(v(_ctx<DateTime?>(TestField.startDate, yesterday)), isNotNull);
    });

    test('fails for today when includeToday is false', () {
      final v = OiAfValidators.dateInFuture<TestField>(includeToday: false);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(v(_ctx<DateTime?>(TestField.startDate, today)), isNotNull);
    });
  });

  group('OiAfValidators.dateInPast', () {
    test('passes for null', () {
      final v = OiAfValidators.dateInPast<TestField>();
      expect(v(_ctx<DateTime?>(TestField.startDate, null)), isNull);
    });

    test('passes for yesterday', () {
      final v = OiAfValidators.dateInPast<TestField>();
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(v(_ctx<DateTime?>(TestField.startDate, yesterday)), isNull);
    });

    test('passes for today when includeToday is true', () {
      final v = OiAfValidators.dateInPast<TestField>();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(v(_ctx<DateTime?>(TestField.startDate, today)), isNull);
    });

    test('fails for tomorrow', () {
      final v = OiAfValidators.dateInPast<TestField>();
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(v(_ctx<DateTime?>(TestField.startDate, tomorrow)), isNotNull);
    });

    test('fails for today when includeToday is false', () {
      final v = OiAfValidators.dateInPast<TestField>(includeToday: false);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(v(_ctx<DateTime?>(TestField.startDate, today)), isNotNull);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  COLLECTION / ARRAY RULES
  // ═════════════════════════════════════════════════════════════════════════

  group('OiAfValidators.minItems', () {
    final validator = OiAfValidators.minItems<TestField>(2);

    test('passes for null', () {
      expect(validator(_ctx<List<Object?>?>(TestField.tags, null)), isNull);
    });

    test('passes for empty list', () {
      expect(validator(_ctx<List<Object?>?>(TestField.tags, [])), isNull);
    });

    test('fails when fewer than min items', () {
      expect(
        validator(_ctx<List<Object?>?>(TestField.tags, ['a'])),
        isNotNull,
      );
    });

    test('passes when exactly min items', () {
      expect(
        validator(_ctx<List<Object?>?>(TestField.tags, ['a', 'b'])),
        isNull,
      );
    });

    test('passes when more than min items', () {
      expect(
        validator(_ctx<List<Object?>?>(TestField.tags, ['a', 'b', 'c'])),
        isNull,
      );
    });
  });

  group('OiAfValidators.maxItems', () {
    final validator = OiAfValidators.maxItems<TestField>(3);

    test('passes for null', () {
      expect(validator(_ctx<List<Object?>?>(TestField.tags, null)), isNull);
    });

    test('passes when within limit', () {
      expect(
        validator(_ctx<List<Object?>?>(TestField.tags, ['a', 'b'])),
        isNull,
      );
    });

    test('passes when at limit', () {
      expect(
        validator(_ctx<List<Object?>?>(TestField.tags, ['a', 'b', 'c'])),
        isNull,
      );
    });

    test('fails when over limit', () {
      expect(
        validator(_ctx<List<Object?>?>(TestField.tags, ['a', 'b', 'c', 'd'])),
        isNotNull,
      );
    });
  });

  group('OiAfValidators.distinct', () {
    final validator = OiAfValidators.distinct<TestField>();

    test('passes for null', () {
      expect(validator(_ctx<List<Object?>?>(TestField.tags, null)), isNull);
    });

    test('passes for empty list', () {
      expect(validator(_ctx<List<Object?>?>(TestField.tags, [])), isNull);
    });

    test('passes for all unique items', () {
      expect(
        validator(_ctx<List<Object?>?>(TestField.tags, ['a', 'b', 'c'])),
        isNull,
      );
    });

    test('fails for duplicate items', () {
      expect(
        validator(_ctx<List<Object?>?>(TestField.tags, ['a', 'b', 'a'])),
        isNotNull,
      );
    });

    test('ignores case when ignoreCase is true', () {
      final v = OiAfValidators.distinct<TestField>(ignoreCase: true);
      expect(
        v(_ctx<List<Object?>?>(TestField.tags, ['A', 'a'])),
        isNotNull,
      );
    });

    test('does not ignore case by default', () {
      expect(
        validator(_ctx<List<Object?>?>(TestField.tags, ['A', 'a'])),
        isNull,
      );
    });
  });
}
