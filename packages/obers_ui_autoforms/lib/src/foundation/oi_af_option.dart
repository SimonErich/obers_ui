import 'package:flutter/foundation.dart';

/// A selectable option for select, radio, combo box, and segmented fields.
@immutable
final class OiAfOption<T> {
  const OiAfOption({
    required this.value,
    required this.label,
    this.enabled = true,
    this.group,
  });

  /// The underlying value this option represents.
  final T value;

  /// The human-readable label shown in the UI.
  final String label;

  /// Whether this option can be selected.
  final bool enabled;

  /// Optional group label for grouped option lists.
  final String? group;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiAfOption<T> &&
          other.value == value &&
          other.label == label &&
          other.enabled == enabled &&
          other.group == group;

  @override
  int get hashCode => Object.hash(value, label, enabled, group);

  @override
  String toString() => 'OiAfOption($label: $value)';
}
