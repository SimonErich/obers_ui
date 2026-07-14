import 'package:flutter/widgets.dart';

import 'package:obers_ui_autoforms/src/foundation/oi_af_message_resolver.dart';
import 'package:obers_ui_autoforms/src/validation/oi_af_validation_context.dart';

/// Resolver + [BuildContext] pair available during field validation.
final class OiAfValidationMessages {
  const OiAfValidationMessages({
    required this.resolver,
    required this.context,
  });

  final OiAfMessageResolver resolver;
  final BuildContext context;
}

/// Resolves a validator message: explicit override → resolver → English fallback.
String oiAfResolveValidatorMessage<TField extends Enum, TValue>(
  OiAfValidationContext<TField, TValue> ctx, {
  required String englishFallback,
  String? message,
  String Function(OiAfMessageResolver resolver, BuildContext context)? resolve,
}) {
  if (message != null) return message;
  final messages = ctx.messages;
  if (messages != null && resolve != null) {
    return resolve(messages.resolver, messages.context);
  }
  return englishFallback;
}
