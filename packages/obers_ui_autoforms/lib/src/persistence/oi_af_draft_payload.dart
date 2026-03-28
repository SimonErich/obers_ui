import 'package:flutter/foundation.dart';

/// A typed wrapper around a persisted form draft.
///
/// Contains the serialized field data along with metadata for identifying
/// and timestamping the draft.
@immutable
final class OiAfDraftPayload {
  const OiAfDraftPayload({
    required this.formId,
    required this.data,
    this.key,
    this.savedAt,
  });

  /// Creates an [OiAfDraftPayload] from a raw JSON map.
  ///
  /// The map should contain `formId`, `data`, and optionally `key` and
  /// `savedAt` (as ISO 8601 string).
  factory OiAfDraftPayload.fromJson(Map<String, dynamic> json) {
    return OiAfDraftPayload(
      formId: json['formId'] as String,
      key: json['key'] as String?,
      data: Map<String, dynamic>.from(json['data'] as Map),
      savedAt: json['savedAt'] != null
          ? DateTime.parse(json['savedAt'] as String)
          : null,
    );
  }

  /// Unique identifier for the form type.
  final String formId;

  /// Optional sub-key for distinguishing drafts of the same form type
  /// (e.g. entity ID).
  final String? key;

  /// The serialized field values.
  final Map<String, dynamic> data;

  /// When this draft was saved.
  final DateTime? savedAt;

  /// Serializes this payload to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
    'formId': formId,
    if (key != null) 'key': key,
    'data': data,
    if (savedAt != null) 'savedAt': savedAt!.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiAfDraftPayload && other.formId == formId && other.key == key;

  @override
  int get hashCode => Object.hash(formId, key);

  @override
  String toString() => 'OiAfDraftPayload(formId: $formId, key: $key)';
}
