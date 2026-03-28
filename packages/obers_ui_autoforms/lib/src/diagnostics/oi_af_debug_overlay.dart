import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiLabel, OiSurface;
import 'package:obers_ui_autoforms/src/runtime/controller/oi_af_controller.dart';

/// A developer-facing debug overlay that visualizes the current form state.
///
/// Renders [OiAfController.debugSnapshot] data in a scrollable panel showing
/// aggregate form state and per-field details (value, dirty, touched, visible,
/// enabled, errors).
///
/// Intended for development only. Wrap in `kDebugMode` guards in production.
class OiAfDebugOverlay<TField extends Enum, TData> extends StatelessWidget {
  const OiAfDebugOverlay({required this.controller, super.key});

  /// The form controller to inspect.
  final OiAfController<TField, TData> controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final snapshot = controller.debugSnapshot();
        final fields = snapshot['fields'] as Map<String, dynamic>? ?? const {};

        return OiSurface(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const OiLabel.h4('Form Debug'),
                  const SizedBox(height: 8),
                  _buildAggregate(snapshot),
                  const SizedBox(height: 12),
                  const OiLabel.h4('Fields'),
                  const SizedBox(height: 4),
                  ...fields.entries.map(
                    (e) => _buildField(e.key, e.value as Map<String, dynamic>),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAggregate(Map<String, dynamic> snapshot) {
    final items = [
      'valid: ${snapshot['isValid']}',
      'dirty: ${snapshot['isDirty']}',
      'touched: ${snapshot['isTouched']}',
      'enabled: ${snapshot['isEnabled']}',
      'submitting: ${snapshot['isSubmitting']}',
      'submitted: ${snapshot['hasSubmitted']} (${snapshot['submitCount']}x)',
    ];

    final globalErrors = snapshot['globalErrors'] as List? ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: items.map(OiLabel.caption).toList(),
        ),
        if (globalErrors.isNotEmpty) ...[
          const SizedBox(height: 4),
          OiLabel.caption('global errors: $globalErrors'),
        ],
      ],
    );
  }

  Widget _buildField(String name, Map<String, dynamic> state) {
    final errors = state['errors'] as List? ?? const [];
    final visible = state['isVisible'] as bool? ?? true;
    final enabled = state['isEnabled'] as bool? ?? true;
    final dirty = state['isDirty'] as bool? ?? false;
    final touched = state['isTouched'] as bool? ?? false;

    final flags = [
      if (dirty) 'dirty',
      if (touched) 'touched',
      if (!visible) 'hidden',
      if (!enabled) 'disabled',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OiLabel.caption(
            '$name: ${state['value']}${flags.isNotEmpty ? ' [${flags.join(', ')}]' : ''}',
          ),
          if (errors.isNotEmpty) OiLabel.caption('  errors: $errors'),
        ],
      ),
    );
  }
}
