import 'package:flutter/foundation.dart';

/// A country option for address forms with optional state/province subdivisions.
///
/// Coverage: REQ-0013, REQ-0014
///
/// {@category Models}
@immutable
class OiCountryOption {
  /// Creates an [OiCountryOption].
  const OiCountryOption({required this.code, required this.name, this.states});

  /// ISO 3166-1 alpha-2 country code (e.g. 'US', 'DE').
  final String code;

  /// Human-readable country name (e.g. 'United States').
  final String name;

  /// Optional list of state/province names for this country.
  final List<String>? states;

  /// Returns a copy with the specified fields replaced.
  OiCountryOption copyWith({
    String? code,
    String? name,
    Object? states = _sentinel,
  }) {
    return OiCountryOption(
      code: code ?? this.code,
      name: name ?? this.name,
      states: identical(states, _sentinel)
          ? this.states
          : states as List<String>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiCountryOption) return false;
    return code == other.code &&
        name == other.name &&
        listEquals(states, other.states);
  }

  @override
  int get hashCode =>
      Object.hash(code, name, states == null ? null : Object.hashAll(states!));

  @override
  String toString() =>
      'OiCountryOption(code: $code, name: $name, states: $states)';
}

/// Sentinel used by [OiCountryOption.copyWith] to distinguish an explicit
/// `null` from "not provided".
const Object _sentinel = Object();
