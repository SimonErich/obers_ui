import 'package:obers_ui_forms/src/validation/oi_form_validator.dart';

/// Static factory methods for creating common form validators.
///
/// ```dart
/// OiFormInputController<String>(
///   validation: [
///     OiFormValidation.required(),
///     OiFormValidation.minLength(5),
///     OiFormValidation.email(),
///   ],
/// )
/// ```
abstract final class OiFormValidation {
  /// Validates that the value is not null and not empty.
  static OiSyncFormValidator<T> required<T>({String? message}) {
    return OiSyncFormValidator<T>((value, _) {
      if (value == null) return message ?? 'This field is required';
      if (value is String && value.isEmpty) {
        return message ?? 'This field is required';
      }
      return null;
    });
  }

  /// Validates that a string value has at least [length] characters.
  static OiSyncFormValidator<String> minLength(int length, {String? message}) {
    return OiSyncFormValidator<String>((value, _) {
      if (value == null || value.isEmpty) return null;
      if (value.length < length) {
        return message ?? 'Must be at least $length characters';
      }
      return null;
    });
  }

  /// Validates that a string value has at most [length] characters.
  static OiSyncFormValidator<String> maxLength(int length, {String? message}) {
    return OiSyncFormValidator<String>((value, _) {
      if (value == null || value.isEmpty) return null;
      if (value.length > length) {
        return message ?? 'Must be at most $length characters';
      }
      return null;
    });
  }

  /// Validates that a numeric value is at least [min].
  static OiSyncFormValidator<T> min<T extends num>(T min, {String? message}) {
    return OiSyncFormValidator<T>((value, _) {
      if (value == null) return null;
      if (value < min) {
        return message ?? 'Must be at least $min';
      }
      return null;
    });
  }

  /// Validates that a numeric value is at most [max].
  static OiSyncFormValidator<T> max<T extends num>(T max, {String? message}) {
    return OiSyncFormValidator<T>((value, _) {
      if (value == null) return null;
      if (value > max) {
        return message ?? 'Must be at most $max';
      }
      return null;
    });
  }

  /// Validates that the value is a valid email address.
  static OiSyncFormValidator<String> email({String? message}) {
    return OiSyncFormValidator<String>((value, _) {
      if (value == null || value.isEmpty) return null;
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
      );
      if (!emailRegex.hasMatch(value)) {
        return message ?? 'Please enter a valid email address';
      }
      return null;
    });
  }

  /// Validates that the value is a valid URL.
  static OiSyncFormValidator<String> url({String? message}) {
    return OiSyncFormValidator<String>((value, _) {
      if (value == null || value.isEmpty) return null;
      final uri = Uri.tryParse(value);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        return message ?? 'Please enter a valid URL';
      }
      return null;
    });
  }

  /// Validates that the value matches the given [pattern].
  static OiSyncFormValidator<String> regex(String pattern, {String? message}) {
    return OiSyncFormValidator<String>((value, _) {
      if (value == null || value.isEmpty) return null;
      try {
        final regex = RegExp(pattern);
        if (!regex.hasMatch(value)) {
          return message ?? 'Value does not match the required pattern';
        }
        return null;
      } on FormatException {
        return 'Invalid regex pattern: $pattern';
      }
    });
  }

  /// Validates that the value is a secure password.
  static OiSyncFormValidator<String> securePassword({
    int minLength = 8,
    bool requiresUppercase = false,
    bool requiresLowercase = false,
    bool requiresDigit = false,
    bool requiresSpecialChar = false,
    String? message,
  }) {
    return OiSyncFormValidator<String>((value, _) {
      if (value == null || value.isEmpty) return null;
      if (value.length < minLength) {
        return message ?? 'Password must be at least $minLength characters';
      }
      if (requiresUppercase && !value.contains(RegExp('[A-Z]'))) {
        return message ?? 'Password must contain an uppercase letter';
      }
      if (requiresLowercase && !value.contains(RegExp('[a-z]'))) {
        return message ?? 'Password must contain a lowercase letter';
      }
      if (requiresDigit && !value.contains(RegExp('[0-9]'))) {
        return message ?? 'Password must contain a digit';
      }
      if (requiresSpecialChar &&
          !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        return message ?? 'Password must contain a special character';
      }
      return null;
    });
  }

  /// Validates that the value equals another field's value.
  ///
  /// The [fieldKey] is the enum key of the field to compare against.
  /// This validator requires the form controller to be passed during
  /// validation to access the other field's value.
  static OiSyncFormValidator<T> equals<T>(Enum fieldKey, {String? message}) {
    return OiSyncFormValidator<T>((value, controller) {
      if (value == null) return null;
      // The controller will be cast to OiFormController in validate()
      // ignore: avoid_dynamic_calls
      final otherValue = controller?.get<T>(fieldKey);
      if (value != otherValue) {
        return message ?? 'Values do not match';
      }
      return null;
    });
  }

  /// Creates a custom synchronous validator.
  static OiSyncFormValidator<T> custom<T>(
    String? Function(T? value, dynamic controller) validate,
  ) {
    return OiSyncFormValidator<T>(validate);
  }

  /// Creates a custom asynchronous validator with debounce.
  static OiAsyncFormValidator<T> asyncCustom<T>(
    Future<String?> Function(T? value, dynamic controller) validate, {
    Duration debounce = const Duration(milliseconds: 300),
  }) {
    return OiAsyncFormValidator<T>(validate, debounce: debounce);
  }
}
