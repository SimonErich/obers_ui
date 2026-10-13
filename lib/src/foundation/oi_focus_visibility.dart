import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Whether keyboard focus should be visible, like CSS `:focus-visible`: true
/// after a key press, false again once a pointer (mouse, touch, stylus) goes
/// down.
///
/// Flutter's [FocusManager.highlightMode] treats a mouse like a keyboard
/// ([FocusHighlightMode.traditional]), so a focus ring would also show after
/// a click, e.g. on a menu item that gets focus when its menu opens. Focus
/// indicators use this instead, so they show only while the keyboard is
/// used. An explicit [FocusManager.highlightStrategy] still wins:
/// [FocusHighlightStrategy.alwaysTraditional] always shows them,
/// [FocusHighlightStrategy.alwaysTouch] never does.
///
/// ```dart
/// ListenableBuilder(
///   listenable: OiFocusVisibility.listenable,
///   builder: (context, child) => focused && OiFocusVisibility.visible
///       ? FocusRing(child: child!)
///       : child!,
///   child: content,
/// )
/// ```
///
/// {@category Foundation}
abstract final class OiFocusVisibility {
  static final ValueNotifier<bool> _keyboard = ValueNotifier(false);
  static bool _listening = false;

  /// Notifies on the first key press after pointer use and the first
  /// pointer down after keyboard use. A change of
  /// [FocusManager.highlightStrategy] is reported by
  /// [FocusManager.addHighlightModeListener] instead.
  static Listenable get listenable {
    _listen();
    return _keyboard;
  }

  /// Whether focus indicators should show now.
  static bool get visible {
    _listen();
    return switch (FocusManager.instance.highlightStrategy) {
      FocusHighlightStrategy.alwaysTraditional => true,
      FocusHighlightStrategy.alwaysTouch => false,
      FocusHighlightStrategy.automatic => _keyboard.value,
    };
  }

  /// Forgets the last input, as if no key had been pressed yet. Call it at
  /// the start of a test: the test binding drops all keyboard handlers
  /// between tests, so this one is added again.
  @visibleForTesting
  static void reset() {
    if (_listening) {
      HardwareKeyboard.instance
        ..removeHandler(_onKey)
        ..addHandler(_onKey);
    }
    _keyboard.value = false;
  }

  /// Starts following keys and pointers on first use, once.
  static void _listen() {
    if (_listening) return;
    _listening = true;
    HardwareKeyboard.instance.addHandler(_onKey);
    GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
  }

  static bool _onKey(KeyEvent event) {
    if (event is KeyDownEvent) _keyboard.value = true;
    // Only watching: the key goes on to whoever handles it.
    return false;
  }

  static void _onPointer(PointerEvent event) {
    if (event is PointerDownEvent) _keyboard.value = false;
  }
}
