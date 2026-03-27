import 'package:flutter/widgets.dart';

/// Tracks which [OiSelect] is currently open within a subtree.
///
/// When any [OiSelect] opens, it notifies this notifier with its own key so
/// that sibling selects can close themselves. Wrap a group of selects (or an
/// entire form) with [OiSelectScope] to enable mutual exclusion.
///
/// {@category Components}
class OiSelectScope extends StatefulWidget {
  /// Creates an [OiSelectScope].
  const OiSelectScope({required this.child, super.key});

  /// The widget subtree that shares the select group.
  final Widget child;

  // Returns the nearest [OiSelectScopeNotifier] above [context], or null.
  static OiSelectScopeNotifier? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_OiSelectScopeInherited>()
        ?.notifier;
  }

  @override
  State<OiSelectScope> createState() => _OiSelectScopeState();
}

class _OiSelectScopeState extends State<OiSelectScope> {
  final OiSelectScopeNotifier _notifier = OiSelectScopeNotifier();

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OiSelectScopeInherited(notifier: _notifier, child: widget.child);
  }
}

/// The notifier for [OiSelectScope], tracking which select is open.
///
/// {@category Components}
class OiSelectScopeNotifier extends ChangeNotifier {
  Object? _openKey;

  /// Requests that the select with [key] becomes the open one.
  void requestOpen(Object key) {
    if (_openKey == key) return;
    _openKey = key;
    notifyListeners();
  }

  /// Requests that the select with [key] closes.
  void requestClose(Object key) {
    if (_openKey != key) return;
    _openKey = null;
    notifyListeners();
  }

  /// Returns whether the select with [key] is currently open.
  bool open(Object key) => _openKey == key;
}

class _OiSelectScopeInherited extends InheritedNotifier<OiSelectScopeNotifier> {
  const _OiSelectScopeInherited({
    required super.notifier,
    required super.child,
  });
}
