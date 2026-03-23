import 'dart:ui';

import 'package:flutter/foundation.dart';

/// A node in a flow chart (e.g. Sankey, funnel).
@immutable
class OiFlowNode {
  const OiFlowNode({
    required this.key,
    required this.label,
    this.color,
  });

  final String key;
  final String label;
  final Color? color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiFlowNode &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          label == other.label &&
          color == other.color;

  @override
  int get hashCode => Object.hash(key, label, color);
}

/// A weighted link between two nodes in a flow chart.
@immutable
class OiFlowLink {
  const OiFlowLink({
    required this.sourceKey,
    required this.targetKey,
    required this.value,
    this.color,
  });

  final String sourceKey;
  final String targetKey;
  final double value;
  final Color? color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiFlowLink &&
          runtimeType == other.runtimeType &&
          sourceKey == other.sourceKey &&
          targetKey == other.targetKey &&
          value == other.value &&
          color == other.color;

  @override
  int get hashCode => Object.hash(sourceKey, targetKey, value, color);
}

/// Data contract for flow chart types (e.g. Sankey, funnel).
class OiFlowData {
  const OiFlowData({
    required this.nodes,
    required this.links,
  });

  final List<OiFlowNode> nodes;
  final List<OiFlowLink> links;

  bool get isEmpty => nodes.isEmpty;

  /// Returns the set of node keys referenced by links but not in [nodes].
  Set<String> get danglingLinks {
    final nodeKeys = nodes.map((n) => n.key).toSet();
    final result = <String>{};
    for (final link in links) {
      if (!nodeKeys.contains(link.sourceKey)) result.add(link.sourceKey);
      if (!nodeKeys.contains(link.targetKey)) result.add(link.targetKey);
    }
    return result;
  }
}
