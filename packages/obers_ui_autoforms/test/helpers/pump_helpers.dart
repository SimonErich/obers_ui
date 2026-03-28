import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

/// Wraps [child] in an [OiApp] for widget testing.
Widget pumpAutoForm(Widget child) => OiApp(home: child);

/// Wraps a form with controller in an [OiApp] for widget testing.
Widget pumpFormWithController<TField extends Enum, TData>({
  required OiAfController<TField, TData> controller,
  required Widget child,
  Future<void> Function(TData, OiAfController<TField, TData>)? onSubmit,
  OiAfValidateMode validateMode = OiAfValidateMode.onBlurThenChange,
  bool enabled = true,
}) {
  return OiApp(
    home: OiAfForm<TField, TData>(
      controller: controller,
      onSubmit: onSubmit,
      validateMode: validateMode,
      enabled: enabled,
      child: child,
    ),
  );
}
