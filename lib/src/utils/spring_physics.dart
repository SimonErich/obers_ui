import 'dart:math';

import 'package:flutter/physics.dart';

/// Spring physics simulation utilities.
///
/// Provides factory methods for creating [SpringDescription] instances
/// and predefined spring presets for common animation scenarios.
///
/// {@category Utils}
class OiSpringPhysics {
  const OiSpringPhysics._();

  /// Creates a [SpringDescription] from [damping], [stiffness], and [mass].
  ///
  /// These parameters directly map to [SpringDescription]'s constructor.
  static SpringDescription spring({
    double damping = 20.0,
    double stiffness = 180.0,
    double mass = 1.0,
  }) {
    return SpringDescription(
      mass: mass,
      stiffness: stiffness,
      damping: damping,
    );
  }

  /// A slow, gentle spring with minimal bounce.
  ///
  /// Suitable for subtle transitions and background animations.
  static SpringDescription get gentle =>
      const SpringDescription(mass: 1, stiffness: 100, damping: 26);

  /// A balanced spring suitable for most UI animations.
  ///
  /// Provides a natural feel with moderate speed and slight overshoot.
  static SpringDescription get standard =>
      const SpringDescription(mass: 1, stiffness: 180, damping: 20);

  /// A fast, responsive spring with minimal overshoot.
  ///
  /// Suitable for quick interactions like button presses and toggles.
  static SpringDescription get snappy =>
      const SpringDescription(mass: 1, stiffness: 400, damping: 30);

  /// A playful spring with noticeable bounce.
  ///
  /// Suitable for attention-grabbing animations and fun interactions.
  static SpringDescription get bouncy =>
      const SpringDescription(mass: 1, stiffness: 300, damping: 12);

  /// Calculates the approximate duration of a spring animation.
  ///
  /// The duration is estimated as the time it takes for the spring's
  /// amplitude to decay below [threshold] (default 0.001).
  static Duration estimateDuration(
    SpringDescription spring, {
    double threshold = 0.001,
  }) {
    // For a damped harmonic oscillator: amplitude ~ exp(-gamma * t)
    // where gamma = damping / (2 * mass)
    // We solve for t when exp(-gamma * t) = threshold
    // t = -ln(threshold) / gamma

    final gamma = spring.damping / (2.0 * spring.mass);

    if (gamma <= 0) {
      // Undamped: would oscillate forever; return a large duration.
      return const Duration(seconds: 10);
    }

    final seconds = -log(threshold) / gamma;
    final millis = (seconds * 1000).ceil();
    return Duration(milliseconds: millis);
  }
}
