import 'package:flutter/widgets.dart';

/// Describes a remote user's selection on a shared surface.
///
/// Selections can be either text ranges ([textRange]) or object-based
/// ([selectedKeys]), but typically not both at once.
///
/// {@category Composites}
class OiRemoteSelection {
  /// Creates an [OiRemoteSelection].
  const OiRemoteSelection({
    required this.userId,
    required this.name,
    required this.color,
    this.textRange,
    this.selectedKeys,
  });

  /// A unique identifier for the remote user.
  final String userId;

  /// The display name of the remote user.
  final String name;

  /// The highlight color used for this user's selection.
  final Color color;

  /// An optional text range representing selected characters.
  final TextRange? textRange;

  /// An optional set of object keys representing selected items.
  final Set<Object>? selectedKeys;
}

/// Renders a [child] alongside selection metadata from remote users.
///
/// The [selections] list provides information about what each remote user
/// has selected. Consumers can use [OiSelectionPresence.selectionsOf] to
/// query which selections contain a given key and render highlights
/// accordingly.
///
/// {@category Composites}
class OiSelectionPresence extends StatelessWidget {
  /// Creates an [OiSelectionPresence].
  const OiSelectionPresence({
    required this.child,
    required this.selections,
    super.key,
  });

  /// The child widget that represents the shared content surface.
  final Widget child;

  /// The list of remote selections to expose to descendant widgets.
  final List<OiRemoteSelection> selections;

  /// Returns all [OiRemoteSelection] entries from [selections] whose
  /// [OiRemoteSelection.selectedKeys] contain [key].
  ///
  /// Useful for highlighting individual items in a list or canvas.
  static List<OiRemoteSelection> selectionsOf(
    List<OiRemoteSelection> selections,
    Object key,
  ) {
    return selections
        .where((s) => s.selectedKeys?.contains(key) ?? false)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return _OiSelectionPresenceScope(selections: selections, child: child);
  }
}

/// An [InheritedWidget] that provides selection data to descendants.
class _OiSelectionPresenceScope extends InheritedWidget {
  const _OiSelectionPresenceScope({
    required this.selections,
    required super.child,
  });

  /// The remote selections available to descendants.
  final List<OiRemoteSelection> selections;

  @override
  bool updateShouldNotify(_OiSelectionPresenceScope oldWidget) {
    return selections != oldWidget.selections;
  }
}
