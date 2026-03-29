import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show State;
import 'package:obers_ui/obers_ui.dart' show OiFileManager, OiFileToolbar;

/// Debounces search queries so that non-empty values fire after a 300 ms pause
/// while empty values (clear) fire immediately.
///
/// Both [OiFileToolbar] and [OiFileManager] share this helper to avoid
/// duplicating the debounce/immediate-clear logic.
///
/// {@category Foundation}
class OiSearchDebounce {
  /// Active debounce timer, if any.
  Timer? _timer;

  /// Processes a search [query].
  ///
  /// * Empty queries invoke [onSearch] synchronously so the consumer can clear
  ///   filters without delay.
  /// * Non-empty queries are debounced by 300 ms; rapid keystrokes restart the
  ///   timer so only the final value fires.
  void call(String query, ValueChanged<String> onSearch) {
    _timer?.cancel();
    if (query.isEmpty) {
      onSearch(query);
      return;
    }
    _timer = Timer(const Duration(milliseconds: 300), () {
      onSearch(query);
    });
  }

  /// Cancels any pending debounce timer without firing the callback.
  void cancel() {
    _timer?.cancel();
  }

  /// Releases resources. Equivalent to [cancel] but follows the conventional
  /// dispose naming for use in [State.dispose].
  void dispose() {
    _timer?.cancel();
  }
}
