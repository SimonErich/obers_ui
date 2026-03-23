import 'dart:ui';

import 'package:flutter/foundation.dart';

/// A single node in a hierarchical chart (e.g. treemap).
@immutable
class OiHierarchicalNode {
  const OiHierarchicalNode({
    required this.key,
    required this.label,
    required this.value,
    this.color,
    this.children = const [],
  });

  final String key;
  final String label;
  final double value;
  final Color? color;
  final List<OiHierarchicalNode> children;

  /// Whether this node has children.
  bool get isLeaf => children.isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiHierarchicalNode &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          label == other.label &&
          value == other.value &&
          color == other.color;

  @override
  int get hashCode => Object.hash(key, label, value, color);
}

/// Data contract for hierarchical chart types (e.g. treemap).
class OiHierarchicalData {
  const OiHierarchicalData({required this.roots});

  final List<OiHierarchicalNode> roots;

  bool get isEmpty => roots.isEmpty;

  /// Sum of all root-level node values.
  double get totalValue => roots.fold(0, (sum, n) => sum + n.value);
}
