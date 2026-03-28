/// Abstract persistence driver for form draft storage.
abstract class OiAfPersistenceDriver {
  /// Load a saved draft.
  Future<Map<String, dynamic>?> loadDraft({
    required String formId,
    String? key,
  });

  /// Save a draft.
  Future<void> saveDraft({
    required String formId,
    required Map<String, dynamic> json,
    String? key,
  });

  /// Delete a saved draft.
  Future<void> deleteDraft({
    required String formId,
    String? key,
  });
}
