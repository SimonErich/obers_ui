import 'package:flutter/widgets.dart';

/// Abstract interface for providing localized validation messages.
///
/// The default implementation ([OiAfDefaultMessageResolver]) returns
/// English messages. Override individual methods to customize.
abstract class OiAfMessageResolver {
  const OiAfMessageResolver();

  String requiredText(BuildContext context) => 'This field is required.';
  String invalidEmail(BuildContext context) => 'Please enter a valid email address.';
  String tooShort(BuildContext context, int min) => 'Must be at least $min characters.';
  String tooLong(BuildContext context, int max) => 'Must be at most $max characters.';
  String exactLength(BuildContext context, int length) => 'Must be exactly $length characters.';
  String lengthBetween(BuildContext context, int min, int max) => 'Must be between $min and $max characters.';
  String valuesDoNotMatch(BuildContext context) => 'The values do not match.';
  String validationFailed(BuildContext context) => 'Validation failed.';
  String submitFailed(BuildContext context) => 'Submission failed. Please try again.';
  String errorSummaryTitle(BuildContext context, int count) => '$count error${count == 1 ? '' : 's'} found';
  String minValue(BuildContext context, num min) => 'Must be at least $min.';
  String maxValue(BuildContext context, num max) => 'Must be at most $max.';
  String rangeValue(BuildContext context, num min, num max) => 'Must be between $min and $max.';
  String invalidUrl(BuildContext context) => 'Please enter a valid URL.';
  String invalidPattern(BuildContext context) => 'Invalid format.';
  String mustBeTrue(BuildContext context) => 'This must be accepted.';
  String mustBeFalse(BuildContext context) => 'This must be declined.';
  String passwordTooWeak(BuildContext context) => 'Password is too weak.';
  String minItems(BuildContext context, int min) => 'Must have at least $min item${min == 1 ? '' : 's'}.';
  String maxItems(BuildContext context, int max) => 'Must have at most $max item${max == 1 ? '' : 's'}.';
  String invalidJson(BuildContext context) => 'Invalid JSON.';
  String invalidUuid(BuildContext context) => 'Invalid UUID.';
  String mustBeInteger(BuildContext context) => 'Must be a whole number.';
  String fileTooLarge(BuildContext context, int maxKb) => 'File must not exceed ${maxKb}KB.';
  String invalidFileExtension(BuildContext context, List<String> allowed) =>
      'Allowed file types: ${allowed.join(', ')}.';
  String dateAfterError(BuildContext context, String date) => 'Must be after $date.';
  String dateBeforeError(BuildContext context, String date) => 'Must be before $date.';
  String dateFutureError(BuildContext context) => 'Must be a future date.';
  String datePastError(BuildContext context) => 'Must be a past date.';
  String differentFromField(BuildContext context) => 'Must be different.';
  String notInList(BuildContext context) => 'This value is not allowed.';
}

/// Default English message resolver.
final class OiAfDefaultMessageResolver extends OiAfMessageResolver {
  const OiAfDefaultMessageResolver();
}
