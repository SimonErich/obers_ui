import 'package:flutter/foundation.dart';

/// A state or province subdivision within a country.
///
/// Coverage: REQ-0001
///
/// {@category Models}
@immutable
class OiStateOption {
  /// Creates an [OiStateOption].
  const OiStateOption({required this.name, required this.code});

  /// Human-readable state/province name (e.g. 'California').
  final String name;

  /// State/province code (e.g. 'CA').
  final String code;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiStateOption) return false;
    return name == other.name && code == other.code;
  }

  @override
  int get hashCode => Object.hash(name, code);

  @override
  String toString() => 'OiStateOption(name: $name, code: $code)';
}

/// A country option for address forms with optional state/province subdivisions.
///
/// Coverage: REQ-0001, REQ-0013, REQ-0014
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

  /// Optional list of state/province subdivisions for this country.
  final List<OiStateOption>? states;

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
          : states as List<OiStateOption>?,
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
