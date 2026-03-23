// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'dart:ui' show Offset, Size;

import 'package:flutter/widgets.dart' show EdgeInsets;
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_controller.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_sync_group.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_viewport.dart';

void main() {
  group('OiChartSyncGroup', () {
    // ── Crosshair sync ────────────────────────────────────────────────────

    test('syncCrosshair broadcasts to listeners', () {
      final group = OiChartSyncGroup(groupId: 'g1');
      double? received;
      group.addCrosshairListener((x) => received = x);

      group.syncCrosshair(0.5);

      expect(received, 0.5);
      expect(group.lastCrosshairX, 0.5);
      group.dispose();
    });

    test('syncCrosshair broadcasts null to clear', () {
      final group = OiChartSyncGroup(groupId: 'g1');
      double? received = 1.0;
      group.addCrosshairListener((x) => received = x);

      group.syncCrosshair(null);

      expect(received, isNull);
      group.dispose();
    });

    test('syncCrosshair is no-op when option disabled', () {
      final group = OiChartSyncGroup(
        groupId: 'g1',
        options: const OiChartSyncOptions(syncCrosshair: false),
      );
      double? received;
      group.addCrosshairListener((x) => received = x);

      group.syncCrosshair(0.5);

      expect(received, isNull);
      group.dispose();
    });

    // ── Selection sync ────────────────────────────────────────────────────

    test('syncSelection broadcasts to listeners', () {
      final group = OiChartSyncGroup(groupId: 'g1');
      Set<OiChartDataRef>? received;
      group.addSelectionListener((s) => received = s);

      final refs = {const OiChartDataRef(seriesIndex: 0, dataIndex: 3)};
      group.syncSelection(refs);

      expect(received, refs);
      expect(group.lastSelection, refs);
      group.dispose();
    });

    test('syncSelection is no-op when option disabled', () {
      final group = OiChartSyncGroup(
        groupId: 'g1',
        options: const OiChartSyncOptions(syncSelection: false),
      );
      Set<OiChartDataRef>? received;
      group.addSelectionListener((s) => received = s);

      group.syncSelection(
        {const OiChartDataRef(seriesIndex: 0, dataIndex: 0)},
      );

      expect(received, isNull);
      group.dispose();
    });

    // ── Viewport sync ─────────────────────────────────────────────────────

    test('syncViewport broadcasts when option enabled', () {
      final group = OiChartSyncGroup(
        groupId: 'g1',
        options: const OiChartSyncOptions(syncViewport: true),
      );
      OiChartViewport? received;
      group.addViewportListener((v) => received = v);

      const viewport = OiChartViewport(size: Size(400, 300));
      group.syncViewport(viewport);

      expect(received, viewport);
      expect(group.lastViewport, viewport);
      group.dispose();
    });

    test('syncViewport is no-op by default', () {
      final group = OiChartSyncGroup(groupId: 'g1');
      OiChartViewport? received;
      group.addViewportListener((v) => received = v);

      group.syncViewport(const OiChartViewport(size: Size(400, 300)));

      expect(received, isNull);
      group.dispose();
    });

    // ── Keyboard focus sync ───────────────────────────────────────────────

    test('syncKeyboardFocus broadcasts to listeners', () {
      final group = OiChartSyncGroup(groupId: 'g1');
      double? received;
      group.addKeyboardFocusListener((x) => received = x);

      group.syncKeyboardFocus(0.75);

      expect(received, 0.75);
      expect(group.lastKeyboardFocusX, 0.75);
      group.dispose();
    });

    test('syncKeyboardFocus is no-op when option disabled', () {
      final group = OiChartSyncGroup(
        groupId: 'g1',
        options: const OiChartSyncOptions(syncKeyboardFocus: false),
      );
      double? received;
      group.addKeyboardFocusListener((x) => received = x);

      group.syncKeyboardFocus(0.5);

      expect(received, isNull);
      group.dispose();
    });

    // ── Listener removal ──────────────────────────────────────────────────

    test('removing a listener stops notifications', () {
      final group = OiChartSyncGroup(groupId: 'g1');
      var count = 0;
      void listener(double? _) => count++;
      group.addCrosshairListener(listener);

      group.syncCrosshair(0.1);
      expect(count, 1);

      group.removeCrosshairListener(listener);
      group.syncCrosshair(0.2);
      expect(count, 1);
      group.dispose();
    });

    // ── Participant management ────────────────────────────────────────────

    test('participant count tracks registrations', () {
      final group = OiChartSyncGroup(groupId: 'g1');
      expect(group.participantCount, 0);

      group.registerParticipant();
      expect(group.participantCount, 1);

      group.registerParticipant();
      expect(group.participantCount, 2);

      group.unregisterParticipant();
      expect(group.participantCount, 1);

      group.unregisterParticipant();
      expect(group.participantCount, 0);
      group.dispose();
    });

    test('unregisterParticipant does not go below zero', () {
      final group = OiChartSyncGroup(groupId: 'g1');
      group.unregisterParticipant();
      expect(group.participantCount, 0);
      group.dispose();
    });

    // ── ChangeNotifier ────────────────────────────────────────────────────

    test('notifies generic listeners on sync actions', () {
      final group = OiChartSyncGroup(groupId: 'g1');
      var count = 0;
      group.addListener(() => count++);

      group.syncCrosshair(0.5);
      group.syncSelection(const {});

      expect(count, 2);
      group.dispose();
    });

    // ── groupId ───────────────────────────────────────────────────────────

    test('groupId returns the constructor value', () {
      final group = OiChartSyncGroup(groupId: 'my-group');
      expect(group.groupId, 'my-group');
      group.dispose();
    });

    // ── dispose clears listeners ──────────────────────────────────────────

    test('dispose clears all listener lists', () {
      final group = OiChartSyncGroup(
        groupId: 'g1',
        options: const OiChartSyncOptions(syncViewport: true),
      );
      group.addCrosshairListener((_) {});
      group.addSelectionListener((_) {});
      group.addViewportListener((_) {});
      group.addKeyboardFocusListener((_) {});
      group.dispose();

      // No way to inspect internals, but we verify dispose doesn't throw.
    });
  });

  group('OiChartSyncGroupRegistry', () {
    setUp(() {
      OiChartSyncGroupRegistry.instance.reset();
    });

    test('get creates a new group', () {
      final group = OiChartSyncGroupRegistry.instance.get('dashboard-1');
      expect(group.groupId, 'dashboard-1');
      expect(OiChartSyncGroupRegistry.instance.groupCount, 1);
    });

    test('get returns the same group for the same name', () {
      final a = OiChartSyncGroupRegistry.instance.get('dashboard-1');
      final b = OiChartSyncGroupRegistry.instance.get('dashboard-1');
      expect(identical(a, b), isTrue);
    });

    test('get creates separate groups for different names', () {
      final a = OiChartSyncGroupRegistry.instance.get('group-a');
      final b = OiChartSyncGroupRegistry.instance.get('group-b');
      expect(identical(a, b), isFalse);
      expect(OiChartSyncGroupRegistry.instance.groupCount, 2);
    });

    test('find returns null for unknown groups', () {
      expect(OiChartSyncGroupRegistry.instance.find('unknown'), isNull);
    });

    test('find returns existing group', () {
      final group = OiChartSyncGroupRegistry.instance.get('test');
      expect(
        identical(OiChartSyncGroupRegistry.instance.find('test'), group),
        isTrue,
      );
    });

    test('contains returns true for existing groups', () {
      OiChartSyncGroupRegistry.instance.get('test');
      expect(OiChartSyncGroupRegistry.instance.contains('test'), isTrue);
      expect(OiChartSyncGroupRegistry.instance.contains('other'), isFalse);
    });

    test('remove disposes group with no participants', () {
      OiChartSyncGroupRegistry.instance.get('test');
      final removed = OiChartSyncGroupRegistry.instance.remove('test');
      expect(removed, isTrue);
      expect(OiChartSyncGroupRegistry.instance.groupCount, 0);
    });

    test('remove refuses to dispose group with participants', () {
      final group = OiChartSyncGroupRegistry.instance.get('test');
      group.registerParticipant();
      final removed = OiChartSyncGroupRegistry.instance.remove('test');
      expect(removed, isFalse);
      expect(OiChartSyncGroupRegistry.instance.groupCount, 1);
      group.unregisterParticipant();
    });

    test('remove returns false for unknown group', () {
      final removed = OiChartSyncGroupRegistry.instance.remove('unknown');
      expect(removed, isFalse);
    });

    test('reset clears all groups', () {
      OiChartSyncGroupRegistry.instance.get('a');
      OiChartSyncGroupRegistry.instance.get('b');
      OiChartSyncGroupRegistry.instance.reset();
      expect(OiChartSyncGroupRegistry.instance.groupCount, 0);
    });
  });

  group('OiChartSyncOptions', () {
    test('defaults have crosshair, selection, and keyboard true; viewport false', () {
      const options = OiChartSyncOptions();
      expect(options.syncCrosshair, isTrue);
      expect(options.syncSelection, isTrue);
      expect(options.syncViewport, isFalse);
      expect(options.syncKeyboardFocus, isTrue);
    });

    test('equality for identical options', () {
      const a = OiChartSyncOptions();
      const b = OiChartSyncOptions();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality for different options', () {
      const a = OiChartSyncOptions();
      const b = OiChartSyncOptions(syncViewport: true);
      expect(a, isNot(equals(b)));
    });
  });
}
