import 'dart:async';
import 'dart:convert';

import 'package:obers_ui_autoforms/src/definitions/oi_af_field_definition.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_typedefs.dart';
import 'package:obers_ui_autoforms/src/validation/oi_af_validation_context.dart';

/// Built-in validator factories inspired by Laravel's validation rules.
///
/// All content validators (length, pattern, etc.) ignore null/empty values —
/// they do not duplicate required logic. Only `required*` validators reject
/// empty values.
abstract final class OiAfValidators {
  // ═══════════════════════════════════════════
  //  PRESENCE / REQUIRED
  // ═══════════════════════════════════════════

  /// Value must be non-null and non-empty string (after trim).
  static OiAfValidator<TField, String> requiredText<TField extends Enum>({
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.trim().isEmpty) return message ?? 'This field is required.';
        return null;
      };

  /// Value must be non-null. For collections, must be non-empty.
  static OiAfValidator<TField, Object?> requiredValue<TField extends Enum>({
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return message ?? 'This field is required.';
        if (v is String && v.trim().isEmpty) return message ?? 'This field is required.';
        if (v is List && v.isEmpty) return message ?? 'This field is required.';
        return null;
      };

  /// Value must be exactly `true`.
  static OiAfValidator<TField, bool?> requiredTrue<TField extends Enum>({
    String? message,
  }) =>
      (ctx) {
        if (ctx.value != true) return message ?? 'This must be accepted.';
        return null;
      };

  /// Value must be exactly `false`.
  static OiAfValidator<TField, bool?> requiredFalse<TField extends Enum>({
    String? message,
  }) =>
      (ctx) {
        if (ctx.value ?? true) return message ?? 'This must be declined.';
        return null;
      };

  /// Required only if another field equals a specific value.
  static OiAfValidator<TField, Object?> requiredIf<TField extends Enum>(
    TField otherField,
    Object? value, {
    String? message,
  }) =>
      (ctx) {
        if (ctx.form.get<Object?>(otherField) != value) return null;
        if (_isEmpty(ctx.value)) return message ?? 'This field is required.';
        return null;
      };

  /// Required unless another field equals a specific value.
  static OiAfValidator<TField, Object?> requiredUnless<TField extends Enum>(
    TField otherField,
    Object? value, {
    String? message,
  }) =>
      (ctx) {
        if (ctx.form.get<Object?>(otherField) == value) return null;
        if (_isEmpty(ctx.value)) return message ?? 'This field is required.';
        return null;
      };

  /// Required only when any of the other fields are present.
  static OiAfValidator<TField, Object?> requiredWith<TField extends Enum>(
    List<TField> otherFields, {
    String? message,
  }) =>
      (ctx) {
        final anyPresent = otherFields.any((f) => !_isEmpty(ctx.form.get<Object?>(f)));
        if (!anyPresent) return null;
        if (_isEmpty(ctx.value)) return message ?? 'This field is required.';
        return null;
      };

  /// Required only when ALL other fields are present.
  static OiAfValidator<TField, Object?> requiredWithAll<TField extends Enum>(
    List<TField> otherFields, {
    String? message,
  }) =>
      (ctx) {
        final allPresent = otherFields.every((f) => !_isEmpty(ctx.form.get<Object?>(f)));
        if (!allPresent) return null;
        if (_isEmpty(ctx.value)) return message ?? 'This field is required.';
        return null;
      };

  /// Required only when any of the other fields are absent.
  static OiAfValidator<TField, Object?> requiredWithout<TField extends Enum>(
    List<TField> otherFields, {
    String? message,
  }) =>
      (ctx) {
        final anyAbsent = otherFields.any((f) => _isEmpty(ctx.form.get<Object?>(f)));
        if (!anyAbsent) return null;
        if (_isEmpty(ctx.value)) return message ?? 'This field is required.';
        return null;
      };

  /// Required only when ALL other fields are absent.
  static OiAfValidator<TField, Object?> requiredWithoutAll<TField extends Enum>(
    List<TField> otherFields, {
    String? message,
  }) =>
      (ctx) {
        final allAbsent = otherFields.every((f) => _isEmpty(ctx.form.get<Object?>(f)));
        if (!allAbsent) return null;
        if (_isEmpty(ctx.value)) return message ?? 'This field is required.';
        return null;
      };

  // ═══════════════════════════════════════════
  //  STRING RULES
  // ═══════════════════════════════════════════

  /// Minimum character length.
  static OiAfValidator<TField, String> minLength<TField extends Enum>(
    int min, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        if (v.length < min) return message ?? 'Must be at least $min characters.';
        return null;
      };

  /// Maximum character length.
  static OiAfValidator<TField, String> maxLength<TField extends Enum>(
    int max, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        if (v.length > max) return message ?? 'Must be at most $max characters.';
        return null;
      };

  /// Exact character length.
  static OiAfValidator<TField, String> exactLength<TField extends Enum>(
    int length, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        if (v.length != length) return message ?? 'Must be exactly $length characters.';
        return null;
      };

  /// Character length between min and max (inclusive).
  static OiAfValidator<TField, String> lengthBetween<TField extends Enum>(
    int min,
    int max, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        if (v.length < min || v.length > max) {
          return message ?? 'Must be between $min and $max characters.';
        }
        return null;
      };

  /// Valid email address format.
  static OiAfValidator<TField, String> email<TField extends Enum>({
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value?.trim();
        if (v == null || v.isEmpty) return null;
        if (!_emailRegex.hasMatch(v)) {
          return message ?? 'Please enter a valid email address.';
        }
        return null;
      };

  /// Valid URL format.
  static OiAfValidator<TField, String> url<TField extends Enum>({
    List<String> protocols = const ['http', 'https'],
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        final uri = Uri.tryParse(v);
        if (uri == null || !uri.hasScheme || !protocols.contains(uri.scheme)) {
          return message ?? 'Please enter a valid URL.';
        }
        return null;
      };

  /// Matches a regular expression.
  static OiAfValidator<TField, String> regex<TField extends Enum>(
    RegExp pattern, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        if (!pattern.hasMatch(v)) return message ?? 'Invalid format.';
        return null;
      };

  /// Does NOT match a regular expression.
  static OiAfValidator<TField, String> notRegex<TField extends Enum>(
    RegExp pattern, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        if (pattern.hasMatch(v)) return message ?? 'Invalid format.';
        return null;
      };

  /// Only alphabetic characters.
  static OiAfValidator<TField, String> alpha<TField extends Enum>({
    bool asciiOnly = false,
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        final pattern = asciiOnly ? RegExp(r'^[a-zA-Z]+$') : RegExp(r'^\p{L}+$', unicode: true);
        if (!pattern.hasMatch(v)) {
          return message ?? 'Must contain only letters.';
        }
        return null;
      };

  /// Only alphanumeric characters.
  static OiAfValidator<TField, String> alphaNumeric<TField extends Enum>({
    bool asciiOnly = false,
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        final pattern =
            asciiOnly ? RegExp(r'^[a-zA-Z0-9]+$') : RegExp(r'^[\p{L}\p{N}]+$', unicode: true);
        if (!pattern.hasMatch(v)) {
          return message ?? 'Must contain only letters and numbers.';
        }
        return null;
      };

  /// Alphanumeric plus dashes and underscores.
  static OiAfValidator<TField, String> alphaDash<TField extends Enum>({
    bool asciiOnly = false,
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        final pattern = asciiOnly
            ? RegExp(r'^[a-zA-Z0-9_-]+$')
            : RegExp(r'^[\p{L}\p{N}_-]+$', unicode: true);
        if (!pattern.hasMatch(v)) {
          return message ?? 'Must contain only letters, numbers, dashes, and underscores.';
        }
        return null;
      };

  /// Must start with one of the given prefixes.
  static OiAfValidator<TField, String> startsWith<TField extends Enum>(
    List<String> prefixes, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        if (!prefixes.any(v.startsWith)) {
          return message ?? 'Must start with one of: ${prefixes.join(', ')}.';
        }
        return null;
      };

  /// Must end with one of the given suffixes.
  static OiAfValidator<TField, String> endsWith<TField extends Enum>(
    List<String> suffixes, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        if (!suffixes.any(v.endsWith)) {
          return message ?? 'Must end with one of: ${suffixes.join(', ')}.';
        }
        return null;
      };

  /// Must NOT start with any of the given prefixes.
  static OiAfValidator<TField, String> doesntStartWith<TField extends Enum>(
    List<String> prefixes, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        if (prefixes.any(v.startsWith)) {
          return message ?? 'Must not start with: ${prefixes.join(', ')}.';
        }
        return null;
      };

  /// Must NOT end with any of the given suffixes.
  static OiAfValidator<TField, String> doesntEndWith<TField extends Enum>(
    List<String> suffixes, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        if (suffixes.any(v.endsWith)) {
          return message ?? 'Must not end with: ${suffixes.join(', ')}.';
        }
        return null;
      };

  /// Must be entirely lowercase.
  static OiAfValidator<TField, String> lowercase<TField extends Enum>({
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        if (v != v.toLowerCase()) return message ?? 'Must be lowercase.';
        return null;
      };

  /// Must be entirely uppercase.
  static OiAfValidator<TField, String> uppercase<TField extends Enum>({
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        if (v != v.toUpperCase()) return message ?? 'Must be uppercase.';
        return null;
      };

  /// Only 7-bit ASCII characters.
  static OiAfValidator<TField, String> ascii<TField extends Enum>({
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        if (!RegExp(r'^[\x00-\x7F]*$').hasMatch(v)) {
          return message ?? 'Must contain only ASCII characters.';
        }
        return null;
      };

  /// Must be valid JSON.
  static OiAfValidator<TField, String> json<TField extends Enum>({
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        try {
          jsonDecode(v);
          return null;
        } on FormatException catch (_) {
          return message ?? 'Invalid JSON.';
        }
      };

  /// Must be a valid UUID.
  static OiAfValidator<TField, String> uuid<TField extends Enum>({
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        if (!_uuidRegex.hasMatch(v)) return message ?? 'Invalid UUID.';
        return null;
      };

  /// Must be a valid ULID.
  static OiAfValidator<TField, String> ulid<TField extends Enum>({
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        if (!_ulidRegex.hasMatch(v)) return message ?? 'Invalid ULID.';
        return null;
      };

  /// Must be a valid IP address.
  static OiAfValidator<TField, String> ipAddress<TField extends Enum>({
    bool v4Only = false,
    bool v6Only = false,
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        final isV4 = _ipV4Regex.hasMatch(v);
        final isV6 = v.contains(':') && RegExp(r'^[0-9a-fA-F:]+$').hasMatch(v);
        if (v4Only && !isV4) return message ?? 'Must be an IPv4 address.';
        if (v6Only && !isV6) return message ?? 'Must be an IPv6 address.';
        if (!isV4 && !isV6) return message ?? 'Invalid IP address.';
        return null;
      };

  /// Must be a valid hex color.
  static OiAfValidator<TField, String> hexColor<TField extends Enum>({
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        if (!_hexColorRegex.hasMatch(v)) return message ?? 'Invalid hex color.';
        return null;
      };

  /// Secure password with configurable requirements.
  static OiAfValidator<TField, String> securePassword<TField extends Enum>({
    int minLength = 8,
    bool requiresUppercase = false,
    bool requiresLowercase = false,
    bool requiresDigit = false,
    bool requiresSpecialChar = false,
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        final errors = <String>[];
        if (v.length < minLength) errors.add('at least $minLength characters');
        if (requiresUppercase && !v.contains(RegExp('[A-Z]'))) errors.add('an uppercase letter');
        if (requiresLowercase && !v.contains(RegExp('[a-z]'))) errors.add('a lowercase letter');
        if (requiresDigit && !v.contains(RegExp('[0-9]'))) errors.add('a digit');
        if (requiresSpecialChar && !v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
          errors.add('a special character');
        }
        if (errors.isNotEmpty) {
          return message ?? 'Password must contain ${errors.join(', ')}.';
        }
        return null;
      };

  // ═══════════════════════════════════════════
  //  NUMERIC RULES
  // ═══════════════════════════════════════════

  /// Minimum numeric value.
  static OiAfValidator<TField, num?> min<TField extends Enum>(
    num min, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        if (v < min) return message ?? 'Must be at least $min.';
        return null;
      };

  /// Maximum numeric value.
  static OiAfValidator<TField, num?> max<TField extends Enum>(
    num max, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        if (v > max) return message ?? 'Must be at most $max.';
        return null;
      };

  /// Numeric value between min and max (inclusive).
  static OiAfValidator<TField, num?> range<TField extends Enum>(
    num min,
    num max, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        if (v < min || v > max) return message ?? 'Must be between $min and $max.';
        return null;
      };

  /// Must be greater than another field's value.
  static OiAfValidator<TField, num?> greaterThanField<TField extends Enum>(
    TField other, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        final otherVal = ctx.form.get<num?>(other);
        if (otherVal != null && v <= otherVal) {
          return message ?? 'Must be greater than ${other.name}.';
        }
        return null;
      };

  /// Must be less than another field's value.
  static OiAfValidator<TField, num?> lessThanField<TField extends Enum>(
    TField other, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        final otherVal = ctx.form.get<num?>(other);
        if (otherVal != null && v >= otherVal) {
          return message ?? 'Must be less than ${other.name}.';
        }
        return null;
      };

  /// Must be a multiple of the given value.
  static OiAfValidator<TField, num?> multipleOf<TField extends Enum>(
    num factor, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        if (v % factor != 0) return message ?? 'Must be a multiple of $factor.';
        return null;
      };

  /// Must be an integer (no decimals).
  static OiAfValidator<TField, num?> integer<TField extends Enum>({
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        if (v != v.toInt()) return message ?? 'Must be a whole number.';
        return null;
      };

  /// Must have specific decimal places.
  static OiAfValidator<TField, num?> decimal<TField extends Enum>(
    int minPlaces, {
    int? maxPlaces,
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        final parts = v.toString().split('.');
        final places = parts.length > 1 ? parts[1].length : 0;
        if (places < minPlaces || (maxPlaces != null && places > maxPlaces)) {
          final range = maxPlaces != null ? '$minPlaces to $maxPlaces' : '$minPlaces';
          return message ?? 'Must have $range decimal places.';
        }
        return null;
      };

  /// Number of digits between min and max.
  static OiAfValidator<TField, num?> digitsBetween<TField extends Enum>(
    int min,
    int max, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        final digits = v.abs().toInt().toString().length;
        if (digits < min || digits > max) {
          return message ?? 'Must have between $min and $max digits.';
        }
        return null;
      };

  // ═══════════════════════════════════════════
  //  COMPARISON / CROSS-FIELD
  // ═══════════════════════════════════════════

  /// Must equal another field's value.
  static OiAfValidator<TField, String> equalsField<TField extends Enum>(
    TField other, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        final otherVal = ctx.form.get<String>(other);
        if (v != otherVal) return message ?? 'The values do not match.';
        return null;
      };

  /// Must NOT equal another field's value.
  static OiAfValidator<TField, Object?> differentFromField<TField extends Enum>(
    TField other, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        final otherVal = ctx.form.get<Object?>(other);
        if (v == otherVal) return message ?? 'Must be different.';
        return null;
      };

  /// Value must be in a fixed list.
  static OiAfValidator<TField, TValue> isIn<TField extends Enum, TValue>(
    List<TValue> allowed, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        if (!allowed.contains(v)) return message ?? 'This value is not allowed.';
        return null;
      };

  /// Value must NOT be in a fixed list.
  static OiAfValidator<TField, TValue> notIn<TField extends Enum, TValue>(
    List<TValue> disallowed, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        if (disallowed.contains(v)) return message ?? 'This value is not allowed.';
        return null;
      };

  // ═══════════════════════════════════════════
  //  DATE RULES
  // ═══════════════════════════════════════════

  /// Date must be after a specific date.
  static OiAfValidator<TField, DateTime?> dateAfter<TField extends Enum>(
    DateTime date, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        if (!v.isAfter(date)) return message ?? 'Must be after ${_formatDate(date)}.';
        return null;
      };

  /// Date must be after another field's date value.
  static OiAfValidator<TField, DateTime?> dateAfterField<TField extends Enum>(
    TField otherField, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        final other = ctx.form.get<DateTime?>(otherField);
        if (other != null && !v.isAfter(other)) {
          return message ?? 'Must be after ${otherField.name}.';
        }
        return null;
      };

  /// Date must be after or equal to a date.
  static OiAfValidator<TField, DateTime?> dateAfterOrEqual<TField extends Enum>(
    DateTime date, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        if (v.isBefore(date)) return message ?? 'Must be on or after ${_formatDate(date)}.';
        return null;
      };

  /// Date must be before a date.
  static OiAfValidator<TField, DateTime?> dateBefore<TField extends Enum>(
    DateTime date, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        if (!v.isBefore(date)) return message ?? 'Must be before ${_formatDate(date)}.';
        return null;
      };

  /// Date must be before another field's date value.
  static OiAfValidator<TField, DateTime?> dateBeforeField<TField extends Enum>(
    TField otherField, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        final other = ctx.form.get<DateTime?>(otherField);
        if (other != null && !v.isBefore(other)) {
          return message ?? 'Must be before ${otherField.name}.';
        }
        return null;
      };

  /// Date must be before or equal to a date.
  static OiAfValidator<TField, DateTime?> dateBeforeOrEqual<TField extends Enum>(
    DateTime date, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        if (v.isAfter(date)) return message ?? 'Must be on or before ${_formatDate(date)}.';
        return null;
      };

  /// Date must equal exactly this date (date only, ignoring time).
  static OiAfValidator<TField, DateTime?> dateEquals<TField extends Enum>(
    DateTime date, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        if (v.year != date.year || v.month != date.month || v.day != date.day) {
          return message ?? 'Must be ${_formatDate(date)}.';
        }
        return null;
      };

  /// Date must be today or in the future.
  static OiAfValidator<TField, DateTime?> dateInFuture<TField extends Enum>({
    bool includeToday = true,
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final dateOnly = DateTime(v.year, v.month, v.day);
        if (includeToday && dateOnly.isBefore(today)) {
          return message ?? 'Must be today or later.';
        }
        if (!includeToday && !dateOnly.isAfter(today)) {
          return message ?? 'Must be a future date.';
        }
        return null;
      };

  /// Date must be today or in the past.
  static OiAfValidator<TField, DateTime?> dateInPast<TField extends Enum>({
    bool includeToday = true,
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final dateOnly = DateTime(v.year, v.month, v.day);
        if (includeToday && dateOnly.isAfter(today)) {
          return message ?? 'Must be today or earlier.';
        }
        if (!includeToday && !dateOnly.isBefore(today)) {
          return message ?? 'Must be a past date.';
        }
        return null;
      };

  // ═══════════════════════════════════════════
  //  COLLECTION / ARRAY RULES
  // ═══════════════════════════════════════════

  /// List must have minimum N items.
  static OiAfValidator<TField, List<Object?>?> minItems<TField extends Enum>(
    int min, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        if (v.length < min) {
          return message ?? 'Must have at least $min item${min == 1 ? '' : 's'}.';
        }
        return null;
      };

  /// List must have maximum N items.
  static OiAfValidator<TField, List<Object?>?> maxItems<TField extends Enum>(
    int max, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        if (v.length > max) {
          return message ?? 'Must have at most $max item${max == 1 ? '' : 's'}.';
        }
        return null;
      };

  /// List must have exactly N items.
  static OiAfValidator<TField, List<Object?>?> exactItems<TField extends Enum>(
    int count, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null) return null;
        if (v.length != count) {
          return message ?? 'Must have exactly $count item${count == 1 ? '' : 's'}.';
        }
        return null;
      };

  /// List must contain all of the given values.
  static OiAfValidator<TField, List<TValue>?> contains<TField extends Enum, TValue>(
    List<TValue> required, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        for (final item in required) {
          if (!v.contains(item)) {
            return message ?? 'Must contain all required values.';
          }
        }
        return null;
      };

  /// List must NOT contain any of the given values.
  static OiAfValidator<TField, List<TValue>?> doesntContain<TField extends Enum, TValue>(
    List<TValue> forbidden, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        for (final item in forbidden) {
          if (v.contains(item)) {
            return message ?? 'Contains a forbidden value.';
          }
        }
        return null;
      };

  /// All items in the list must be unique.
  static OiAfValidator<TField, List<Object?>?> distinct<TField extends Enum>({
    bool ignoreCase = false,
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        final items = ignoreCase
            ? v.map((e) => e is String ? e.toLowerCase() : e).toList()
            : v;
        if (items.toSet().length != items.length) {
          return message ?? 'All items must be unique.';
        }
        return null;
      };

  // ═══════════════════════════════════════════
  //  FILE RULES
  // ═══════════════════════════════════════════

  /// File must not exceed max size in KB.
  static OiAfValidator<TField, List<OiAfFileValue>?> maxFileSize<TField extends Enum>(
    int maxKb, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        for (final file in v) {
          if (file.sizeInBytes != null && file.sizeInBytes! > maxKb * 1024) {
            return message ?? 'File "${file.name}" exceeds ${maxKb}KB.';
          }
        }
        return null;
      };

  /// File must have one of these extensions.
  static OiAfValidator<TField, List<OiAfFileValue>?> fileExtensions<TField extends Enum>(
    List<String> allowed, {
    String? message,
  }) =>
      (ctx) {
        final v = ctx.value;
        if (v == null || v.isEmpty) return null;
        final lowerAllowed = allowed.map((e) => e.toLowerCase()).toSet();
        for (final file in v) {
          final ext = file.extension?.toLowerCase() ?? file.name.split('.').last.toLowerCase();
          if (!lowerAllowed.contains(ext)) {
            return message ?? 'Allowed file types: ${allowed.join(', ')}.';
          }
        }
        return null;
      };

  // ═══════════════════════════════════════════
  //  UTILITY
  // ═══════════════════════════════════════════

  /// Stop running further validators on first failure.
  static OiAfValidator<TField, TValue> bail<TField extends Enum, TValue>() =>
      (ctx) => null; // sentinel; handled by validation runner

  /// Custom validator.
  static OiAfValidator<TField, TValue> custom<TField extends Enum, TValue>(
    FutureOr<String?> Function(OiAfValidationContext<TField, TValue>) fn,
  ) =>
      fn;

  // ═══════════════════════════════════════════
  //  PRIVATE HELPERS
  // ═══════════════════════════════════════════

  static bool _isEmpty(Object? value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is List) return value.isEmpty;
    return false;
  }

  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static final _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
  );

  static final _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static final _ulidRegex = RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$');

  static final _hexColorRegex = RegExp(r'^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');

  static final _ipV4Regex = RegExp(
    r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
  );
}
