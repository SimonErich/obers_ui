// Tests are internal; doc comments on local helpers are not required.
// ignore_for_file: public_member_api_docs

import 'package:flutter/physics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/utils/spring_physics.dart';

void main() {
  group('OiSpringPhysics', () {
    group('spring', () {
      test('creates a SpringDescription with default values', () {
        final s = OiSpringPhysics.spring();
        expect(s.mass, 1.0);
        expect(s.stiffness, 180.0);
        expect(s.damping, 20.0);
      });

      test('creates a SpringDescription with custom values', () {
        final s = OiSpringPhysics.spring(damping: 30, stiffness: 400, mass: 2);
        expect(s.mass, 2.0);
        expect(s.stiffness, 400.0);
        expect(s.damping, 30.0);
      });

      test('accepts zero damping', () {
        final s = OiSpringPhysics.spring(damping: 0);
        expect(s.damping, 0.0);
      });
    });

    group('presets', () {
      test('gentle is a valid SpringDescription', () {
        final s = OiSpringPhysics.gentle;
        expect(s, isA<SpringDescription>());
        expect(s.mass, greaterThan(0));
        expect(s.stiffness, greaterThan(0));
        expect(s.damping, greaterThan(0));
      });

      test('standard is a valid SpringDescription', () {
        final s = OiSpringPhysics.standard;
        expect(s, isA<SpringDescription>());
        expect(s.mass, greaterThan(0));
        expect(s.stiffness, greaterThan(0));
        expect(s.damping, greaterThan(0));
      });

      test('snappy is a valid SpringDescription', () {
        final s = OiSpringPhysics.snappy;
        expect(s, isA<SpringDescription>());
        expect(s.mass, greaterThan(0));
        expect(s.stiffness, greaterThan(0));
        expect(s.damping, greaterThan(0));
      });

      test('bouncy is a valid SpringDescription', () {
        final s = OiSpringPhysics.bouncy;
        expect(s, isA<SpringDescription>());
        expect(s.mass, greaterThan(0));
        expect(s.stiffness, greaterThan(0));
        expect(s.damping, greaterThan(0));
      });

      test('gentle is less stiff than standard', () {
        expect(
          OiSpringPhysics.gentle.stiffness,
          lessThan(OiSpringPhysics.standard.stiffness),
        );
      });

      test('snappy is stiffer than standard', () {
        expect(
          OiSpringPhysics.snappy.stiffness,
          greaterThan(OiSpringPhysics.standard.stiffness),
        );
      });

      test('bouncy has lower damping than snappy', () {
        expect(
          OiSpringPhysics.bouncy.damping,
          lessThan(OiSpringPhysics.snappy.damping),
        );
      });
    });

    group('estimateDuration', () {
      test('returns a positive duration', () {
        final d = OiSpringPhysics.estimateDuration(OiSpringPhysics.standard);
        expect(d.inMilliseconds, greaterThan(0));
      });

      test('gentle spring takes longer than snappy spring', () {
        final gentleDuration = OiSpringPhysics.estimateDuration(
          OiSpringPhysics.gentle,
        );
        final snappyDuration = OiSpringPhysics.estimateDuration(
          OiSpringPhysics.snappy,
        );
        expect(
          gentleDuration.inMilliseconds,
          greaterThan(snappyDuration.inMilliseconds),
        );
      });

      test('lower threshold produces longer duration', () {
        final short = OiSpringPhysics.estimateDuration(
          OiSpringPhysics.standard,
          threshold: 0.01,
        );
        final long = OiSpringPhysics.estimateDuration(
          OiSpringPhysics.standard,
          threshold: 0.0001,
        );
        expect(long.inMilliseconds, greaterThan(short.inMilliseconds));
      });

      test('returns large duration for undamped spring', () {
        final undamped = OiSpringPhysics.spring(damping: 0);
        final d = OiSpringPhysics.estimateDuration(undamped);
        expect(d.inSeconds, greaterThanOrEqualTo(10));
      });

      test('higher damping produces shorter duration', () {
        final lowDamping = OiSpringPhysics.spring(damping: 10);
        final highDamping = OiSpringPhysics.spring(damping: 40);
        final dLow = OiSpringPhysics.estimateDuration(lowDamping);
        final dHigh = OiSpringPhysics.estimateDuration(highDamping);
        expect(dHigh.inMilliseconds, lessThan(dLow.inMilliseconds));
      });

      test('duration is reasonable for standard spring', () {
        final d = OiSpringPhysics.estimateDuration(OiSpringPhysics.standard);
        // Should be somewhere between 100ms and 5s
        expect(d.inMilliseconds, greaterThan(100));
        expect(d.inMilliseconds, lessThan(5000));
      });
    });
  });
}
