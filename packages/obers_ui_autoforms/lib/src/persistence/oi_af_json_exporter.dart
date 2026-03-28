import 'package:obers_ui_autoforms/src/persistence/oi_af_draft_payload.dart';
import 'package:obers_ui_autoforms/src/persistence/oi_af_persistence_driver.dart';
import 'package:obers_ui_autoforms/src/runtime/controller/oi_af_controller.dart';

/// Utility for exporting form data as JSON and managing drafts.
///
/// Bridges the [OiAfController]'s `json()` output with the
/// [OiAfPersistenceDriver] for saving/loading/deleting drafts.
class OiAfJsonExporter<TField extends Enum, TData> {
  OiAfJsonExporter({
    required this.controller,
    required this.formId,
    required this.driver,
    this.key,
  });

  /// The form controller whose data to export.
  final OiAfController<TField, TData> controller;

  /// Unique identifier for the form type.
  final String formId;

  /// Persistence driver for draft storage.
  final OiAfPersistenceDriver driver;

  /// Optional sub-key for distinguishing drafts (e.g. entity ID).
  final String? key;

  /// Exports the current form state as a [OiAfDraftPayload].
  OiAfDraftPayload export() {
    return OiAfDraftPayload(
      formId: formId,
      key: key,
      data: controller.json(),
      savedAt: DateTime.now(),
    );
  }

  /// Saves the current form state as a draft via the driver.
  Future<void> saveDraft() async {
    final payload = export();
    await driver.saveDraft(formId: formId, key: key, json: payload.toJson());
  }

  /// Loads a draft and restores it into the controller.
  ///
  /// Returns `true` if a draft was found and restored, `false` otherwise.
  Future<bool> loadDraft() async {
    final json = await driver.loadDraft(formId: formId, key: key);
    if (json == null) return false;
    final payload = OiAfDraftPayload.fromJson(json);
    final values = <TField, Object?>{};
    for (final field in controller.registeredFields) {
      final name = field.name;
      if (payload.data.containsKey(name)) {
        values[field] = payload.data[name];
      }
    }
    controller.restore(values);
    return true;
  }

  /// Deletes the stored draft via the driver.
  Future<void> deleteDraft() async {
    await driver.deleteDraft(formId: formId, key: key);
  }
}
