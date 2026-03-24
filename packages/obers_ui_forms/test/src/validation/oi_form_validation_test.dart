import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_forms/obers_ui_forms.dart';

void main() {
  group('OiFormValidation.minLength', () {
    test('passes for string with length >= min', () {
      final validator = OiFormValidation.minLength(5);
      expect(validator.validate('hello', null), isNull);
    });

    test('fails for string with length < min', () {
      final validator = OiFormValidation.minLength(5);
      expect(validator.validate('hi', null), isNotNull);
      expect(validator.validate('hi', null), contains('at least 5'));
    });

    test('passes for null value', () {
      final validator = OiFormValidation.minLength(5);
      expect(validator.validate(null, null), isNull);
    });

    test('passes for empty string', () {
      final validator = OiFormValidation.minLength(5);
      expect(validator.validate('', null), isNull);
    });

    test('uses custom message', () {
      final validator = OiFormValidation.minLength(5, message: 'Too short');
      expect(validator.validate('hi', null), 'Too short');
    });
  });

  group('OiFormValidation.maxLength', () {
    test('passes for string within limit', () {
      final validator = OiFormValidation.maxLength(5);
      expect(validator.validate('hello', null), isNull);
    });

    test('fails for string exceeding limit', () {
      final validator = OiFormValidation.maxLength(5);
      expect(validator.validate('hello!', null), isNotNull);
    });
  });

  group('OiFormValidation.email', () {
    test('passes for valid email', () {
      final validator = OiFormValidation.email();
      expect(validator.validate('a@b.c', null), isNull);
      expect(validator.validate('user@example.com', null), isNull);
    });

    test('fails for invalid email', () {
      final validator = OiFormValidation.email();
      expect(validator.validate('notanemail', null), isNotNull);
      expect(validator.validate('missing@', null), isNotNull);
    });

    test('passes for null or empty', () {
      final validator = OiFormValidation.email();
      expect(validator.validate(null, null), isNull);
      expect(validator.validate('', null), isNull);
    });
  });

  group('OiFormValidation.url', () {
    test('passes for valid URL', () {
      final validator = OiFormValidation.url();
      expect(validator.validate('https://example.com', null), isNull);
    });

    test('fails for invalid URL', () {
      final validator = OiFormValidation.url();
      expect(validator.validate('not a url', null), isNotNull);
    });
  });

  group('OiFormValidation.regex', () {
    test('passes when pattern matches', () {
      final validator = OiFormValidation.regex(r'^[a-z]+$');
      expect(validator.validate('hello', null), isNull);
    });

    test('fails when pattern does not match', () {
      final validator = OiFormValidation.regex(r'^[a-z]+$');
      expect(validator.validate('Hello123', null), isNotNull);
    });

    test('returns descriptive error for invalid pattern', () {
      final validator = OiFormValidation.regex(r'[invalid');
      final result = validator.validate('test', null);
      expect(result, contains('Invalid regex pattern'));
    });
  });

  group('OiFormValidation.securePassword', () {
    test('passes when all constraints met', () {
      final validator = OiFormValidation.securePassword(
        minLength: 8,
        requiresUppercase: true,
        requiresSpecialChar: true,
        requiresDigit: true,
      );
      expect(validator.validate('Passw0rd!', null), isNull);
    });

    test('fails when too short', () {
      final validator = OiFormValidation.securePassword(minLength: 8);
      expect(validator.validate('short', null), isNotNull);
    });

    test('fails when missing uppercase', () {
      final validator = OiFormValidation.securePassword(
        requiresUppercase: true,
      );
      expect(validator.validate('alllowercase', null), isNotNull);
    });

    test('fails when missing special char', () {
      final validator = OiFormValidation.securePassword(
        requiresSpecialChar: true,
      );
      expect(validator.validate('NoSpecialChar1', null), isNotNull);
    });

    test('fails when missing digit', () {
      final validator = OiFormValidation.securePassword(requiresDigit: true);
      expect(validator.validate('NoDigitHere!', null), isNotNull);
    });
  });

  group('OiFormValidation.min', () {
    test('passes for value >= min', () {
      final validator = OiFormValidation.min(10);
      expect(validator.validate(10, null), isNull);
      expect(validator.validate(11, null), isNull);
    });

    test('fails for value < min', () {
      final validator = OiFormValidation.min(10);
      expect(validator.validate(9, null), isNotNull);
    });
  });

  group('OiFormValidation.max', () {
    test('passes for value <= max', () {
      final validator = OiFormValidation.max(10);
      expect(validator.validate(10, null), isNull);
      expect(validator.validate(9, null), isNull);
    });

    test('fails for value > max', () {
      final validator = OiFormValidation.max(10);
      expect(validator.validate(11, null), isNotNull);
    });
  });

  group('OiFormValidation.required', () {
    test('fails for null', () {
      final validator = OiFormValidation.required<String>();
      expect(validator.validate(null, null), isNotNull);
    });

    test('fails for empty string', () {
      final validator = OiFormValidation.required<String>();
      expect(validator.validate('', null), isNotNull);
    });

    test('passes for non-empty value', () {
      final validator = OiFormValidation.required<String>();
      expect(validator.validate('hello', null), isNull);
    });

    test('passes for non-null non-string', () {
      final validator = OiFormValidation.required<int>();
      expect(validator.validate(42, null), isNull);
    });
  });

  group('OiFormValidation.custom', () {
    test('receives value and returns null for valid', () {
      final validator = OiFormValidation.custom<String>((value, _) => null);
      expect(validator.validate('anything', null), isNull);
    });

    test('receives value and returns error message for invalid', () {
      final validator = OiFormValidation.custom<String>(
        (value, _) => value == 'bad' ? 'Value is bad' : null,
      );
      expect(validator.validate('bad', null), 'Value is bad');
      expect(validator.validate('good', null), isNull);
    });

    test('receives controller for cross-field validation', () {
      final controller = 'fake_controller';
      final validator = OiFormValidation.custom<String>(
        (value, ctrl) => ctrl == 'fake_controller' ? null : 'Wrong controller',
      );
      expect(validator.validate('value', controller), isNull);
    });
  });

  group('OiFormValidation.equals', () {
    // Note: equals requires a form controller with get<T>(key) method.
    // This will be tested more thoroughly in OiFormController tests.
    test('passes when values match', () {
      final validator = OiFormValidation.equals<String>(_TestField.name);
      // Create a mock controller-like object with get method
      final fakeController = _FakeController({'name': 'hello'});
      expect(validator.validate('hello', fakeController), isNull);
    });

    test('fails when values differ', () {
      final validator = OiFormValidation.equals<String>(_TestField.name);
      final fakeController = _FakeController({'name': 'hello'});
      expect(validator.validate('different', fakeController), isNotNull);
    });
  });
}

enum _TestField { name }

class _FakeController {
  _FakeController(this._values);
  final Map<String, dynamic> _values;

  T? get<T>(Enum key) => _values[key.name] as T?;
}
