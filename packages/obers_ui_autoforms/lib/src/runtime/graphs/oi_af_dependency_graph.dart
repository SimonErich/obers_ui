import 'package:obers_ui_autoforms/src/definitions/oi_af_field_definition.dart';

/// Manages the derived-field dependency graph with topological sorting
/// and cycle detection.
///
/// Built once during controller initialization from field definitions.
class OiAfDependencyGraph<TField extends Enum> {
  OiAfDependencyGraph();

  /// Inverse dependency map: when field X changes, which derived fields
  /// need recomputation?
  final Map<TField, Set<TField>> _derivedDeps = {};

  /// Topologically sorted derived fields (dependencies before dependents).
  late final List<TField> _sortedOrder;

  /// The inverse dependency map.
  Map<TField, Set<TField>> get derivedDeps => Map.unmodifiable(_derivedDeps);

  /// Topologically sorted derived field order.
  List<TField> get sortedOrder => List.unmodifiable(_sortedOrder);

  /// Returns the set of derived fields that depend on [changedField],
  /// or an empty set if none.
  Set<TField> dependentsOf(TField changedField) =>
      _derivedDeps[changedField] ?? const {};

  /// Builds the dependency graph from field definitions and computes the
  /// topological sort order with full cycle detection.
  void build({
    required Map<TField, OiAfFieldDefinition<TField, dynamic>> definitions,
    required List<TField> fieldOrder,
  }) {
    // Build inverse dependency map.
    for (final def in definitions.values) {
      if (def.derive != null) {
        for (final dep in def.dependsOn) {
          _derivedDeps.putIfAbsent(dep, () => {}).add(def.field);
        }
      }
    }

    // Full cycle detection + topological sort via DFS.
    final visited = <TField>{};
    final inStack = <TField>{};
    final sorted = <TField>[];

    void visit(TField field) {
      if (visited.contains(field)) return;
      assert(
        !inStack.contains(field),
        'Circular derived dependency detected involving field $field.',
      );
      inStack.add(field);
      final def = definitions[field]!;
      for (final dep in def.dependsOn) {
        assert(
          definitions.containsKey(dep),
          'Field $field depends on unregistered field $dep.',
        );
        if (definitions[dep]!.derive != null) {
          visit(dep);
        }
      }
      inStack.remove(field);
      visited.add(field);
      sorted.add(field);
    }

    for (final field in fieldOrder) {
      if (definitions[field]!.derive != null) {
        visit(field);
      }
    }

    _sortedOrder = sorted;
  }
}
