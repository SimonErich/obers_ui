import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/behaviors/oi_keyboard_explore_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_accessibility_bridge.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_hit_tester.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';
import 'package:obers_ui_charts/src/models/oi_chart_state_models.dart';
import 'package:obers_ui/obers_ui.dart' show OiChartThemeData;

import 'dart:ui' show Offset, Size;

import 'package:flutter/widgets.dart';

// ── Test doubles ─────────────────────────────────────────────────────────────

class _FakeController extends OiChartController {
  @override
  Set<OiChartDataRef> get selection => {};

  @override
  OiChartSelectionState get selectionState => OiChartSelectionState.empty;

  @override
  void select(Set<OiChartDataRef> refs) {}

  @override
  void clearSelection() {}

  @override
  OiChartDataRef? get hovered => null;

  @override
  OiChartHoverState get hoverState => OiChartHoverState.empty;

  @override
  void hover(OiChartDataRef? ref) {}

  @override
  OiChartViewportState get viewportState => OiChartViewportState();

  @override
  void resetZoom() {}

  @override
  void setVisibleDomain({
    double? xMin,
    double? xMax,
    double? yMin,
    double? yMax,
  }) {}

  @override
  OiChartLegendState get legendState => OiChartLegendState.empty;

  @override
  void toggleSeries(String seriesId) {}

  @override
  void focusSeries(String seriesId) {}

  @override
  OiChartFocusState get focusState => OiChartFocusState.empty;

  @override
  bool get isLoading => false;

  @override
  String? get error => null;
}

class _FakeHitTester extends OiChartHitTester {
  @override
  OiChartHitResult? hitTest(Offset position, {double tolerance = 16}) => null;

  @override
  List<OiChartHitResult> hitTestAll(Offset position, {double tolerance = 16}) =>
      [];
}

class _FakeAccessibilityBridge extends OiChartAccessibilityBridge {
  final List<String> announcements = [];

  @override
  void announce(String message, {bool assertive = false}) {
    announcements.add(message);
  }

  @override
  String describeDataPoint(OiChartDataRef ref) => '';

  @override
  String describeSelection(Set<OiChartDataRef> refs) => '';

  @override
  void focusDataPoint(OiChartDataRef ref) {}

  @override
  bool get reducedMotion => false;

  @override
  bool get highContrast => false;

  @override
  BuildContext get context => throw UnimplementedError();
}

KeyDownEvent _key(LogicalKeyboardKey key) => KeyDownEvent(
  logicalKey: key,
  physicalKey: const PhysicalKeyboardKey(0x00000001),
  timeStamp: Duration.zero,
);

void main() {
  late OiKeyboardExploreBehavior behavior;
  late _FakeAccessibilityBridge bridge;
  late List<(int, int)> focused;
  late List<(int, int)> selected;
  late int clearedCount;

  setUp(() {
    focused = [];
    selected = [];
    clearedCount = 0;

    behavior = OiKeyboardExploreBehavior(
      onPointFocused: (s, p) => focused.add((s, p)),
      onPointSelected: (s, p) => selected.add((s, p)),
      onSelectionCleared: () => clearedCount++,
    );

    bridge = _FakeAccessibilityBridge();
  });

  OiChartBehaviorContext _makeContext() {
    return OiChartBehaviorContext(
      buildContext: _StubBuildContext(),
      controller: _FakeController(),
      viewport: const OiChartViewport(size: Size(400, 300)),
      hitTester: _FakeHitTester(),
      theme: _stubTheme(),
      accessibilityBridge: bridge,
    );
  }

  group('OiKeyboardExploreBehavior', () {
    test('left/right navigates points with wrapping', () {
      behavior.configure(seriesCount: 2, pointCount: 3);

      behavior.handleKeyEvent(_key(LogicalKeyboardKey.arrowRight));
      expect(behavior.focusedPointIndex, 1);
      expect(focused.last, (0, 1));

      behavior.handleKeyEvent(_key(LogicalKeyboardKey.arrowRight));
      expect(behavior.focusedPointIndex, 2);

      // Wraps around
      behavior.handleKeyEvent(_key(LogicalKeyboardKey.arrowRight));
      expect(behavior.focusedPointIndex, 0);

      // Left from 0 wraps to end
      behavior.handleKeyEvent(_key(LogicalKeyboardKey.arrowLeft));
      expect(behavior.focusedPointIndex, 2);
    });

    test('up/down switches series with wrapping', () {
      behavior.configure(seriesCount: 3, pointCount: 5);

      behavior.handleKeyEvent(_key(LogicalKeyboardKey.arrowDown));
      expect(behavior.focusedSeriesIndex, 1);
      expect(focused.last, (1, 0));

      behavior.handleKeyEvent(_key(LogicalKeyboardKey.arrowDown));
      expect(behavior.focusedSeriesIndex, 2);

      // Wraps around
      behavior.handleKeyEvent(_key(LogicalKeyboardKey.arrowDown));
      expect(behavior.focusedSeriesIndex, 0);

      // Up from 0 wraps to end
      behavior.handleKeyEvent(_key(LogicalKeyboardKey.arrowUp));
      expect(behavior.focusedSeriesIndex, 2);
    });

    test('enter selects focused point', () {
      behavior.configure(seriesCount: 2, pointCount: 5);
      behavior.handleKeyEvent(_key(LogicalKeyboardKey.arrowRight));

      behavior.handleKeyEvent(_key(LogicalKeyboardKey.enter));
      expect(selected, [(0, 1)]);
    });

    test('escape clears selection', () {
      behavior.configure(seriesCount: 2, pointCount: 5);

      behavior.handleKeyEvent(_key(LogicalKeyboardKey.escape));
      expect(clearedCount, 1);
    });

    test('announces via accessibility bridge when attached', () {
      behavior.attach(_makeContext());
      behavior.configure(seriesCount: 2, pointCount: 5);

      behavior.handleKeyEvent(_key(LogicalKeyboardKey.arrowRight));

      expect(bridge.announcements, ['Series 1, point 2']);

      behavior.handleKeyEvent(_key(LogicalKeyboardKey.arrowDown));
      expect(bridge.announcements.last, 'Series 2, point 2');

      behavior.detach();
    });

    test('does not announce when not attached', () {
      behavior.configure(seriesCount: 2, pointCount: 5);

      behavior.handleKeyEvent(_key(LogicalKeyboardKey.arrowRight));
      // No crash, no announcement
      expect(bridge.announcements, isEmpty);
    });

    test('returns false for unhandled keys', () {
      behavior.configure(seriesCount: 2, pointCount: 5);

      expect(behavior.handleKeyEvent(_key(LogicalKeyboardKey.space)), isFalse);
    });

    test('returns false when no data configured', () {
      // seriesCount and pointCount are 0
      expect(
        behavior.handleKeyEvent(_key(LogicalKeyboardKey.arrowRight)),
        isFalse,
      );
    });

    test('reset returns indices to origin', () {
      behavior.configure(seriesCount: 3, pointCount: 5);
      behavior.handleKeyEvent(_key(LogicalKeyboardKey.arrowRight));
      behavior.handleKeyEvent(_key(LogicalKeyboardKey.arrowDown));
      expect(behavior.focusedPointIndex, 1);
      expect(behavior.focusedSeriesIndex, 1);

      behavior.reset();
      expect(behavior.focusedPointIndex, 0);
      expect(behavior.focusedSeriesIndex, 0);
    });
  });
}

// ── Minimal stubs ────────────────────────────────────────────────────────────

class _StubBuildContext extends Fake implements BuildContext {}

// Create a minimal chart theme for testing.
OiChartThemeData _stubTheme() {
  return const OiChartThemeData();
}
