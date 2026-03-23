import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Theme data for reorderable list components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiReorderableListThemeData {
  /// Creates an [OiReorderableListThemeData].
  const OiReorderableListThemeData({
    this.dragHandleColor,
    this.placeholderColor,
    this.dragElevation,
  });

  /// The color of the drag handle icon.
  final Color? dragHandleColor;

  /// The color of the placeholder shown at the original position during drag.
  final Color? placeholderColor;

  /// The box shadow applied to the item being dragged.
  final List<BoxShadow>? dragElevation;

  /// Creates a copy with optionally overridden values.
  OiReorderableListThemeData copyWith({
    Color? dragHandleColor,
    Color? placeholderColor,
    List<BoxShadow>? dragElevation,
  }) {
    return OiReorderableListThemeData(
      dragHandleColor: dragHandleColor ?? this.dragHandleColor,
      placeholderColor: placeholderColor ?? this.placeholderColor,
      dragElevation: dragElevation ?? this.dragElevation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiReorderableListThemeData) return false;
    if (dragElevation != null && other.dragElevation != null) {
      if (!listEquals(dragElevation, other.dragElevation)) return false;
    } else if (dragElevation != other.dragElevation) {
      return false;
    }
    return other.dragHandleColor == dragHandleColor &&
        other.placeholderColor == placeholderColor;
  }

  @override
  int get hashCode => Object.hash(
        dragHandleColor,
        placeholderColor,
        dragElevation == null ? null : Object.hashAll(dragElevation!),
      );
}
