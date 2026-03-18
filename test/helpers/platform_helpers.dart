// Public API docs are intentionally omitted for test helpers.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_platform.dart';

/// Pumps [child] wrapped in a touch-modality app at the given screen width.
Future<void> pumpTouchApp(
  WidgetTester tester,
  Widget child, {
  double width = 390,
  double height = 844,
}) async {
  await tester.binding.setSurfaceSize(Size(width, height));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(width, height)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: OiPlatform(
          data: OiPlatformData(
            platform: TargetPlatform.android,
            keyboardHeight: 0,
            keyboardVisible: false,
            inputModality: OiInputModality.touch,
          ),
          child: child,
        ),
      ),
    ),
  );
}

/// Pumps [child] wrapped in a pointer-modality app at the given screen width.
Future<void> pumpPointerApp(
  WidgetTester tester,
  Widget child, {
  double width = 1280,
  double height = 800,
}) async {
  await tester.binding.setSurfaceSize(Size(width, height));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(width, height)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: OiPlatform(
          data: OiPlatformData(
            platform: TargetPlatform.linux,
            keyboardHeight: 0,
            keyboardVisible: false,
            inputModality: OiInputModality.pointer,
          ),
          child: child,
        ),
      ),
    ),
  );
}

/// Pumps [child] at a specific screen width to simulate a breakpoint.
Future<void> pumpAtBreakpoint(
  WidgetTester tester,
  Widget child,
  double width, {
  double height = 800,
}) async {
  await tester.binding.setSurfaceSize(Size(width, height));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(width, height)),
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    ),
  );
}

/// Simulates the software keyboard appearing with the given height.
Future<void> showKeyboard(WidgetTester tester, {double height = 302}) async {
  final view = tester.view;
  final logicalWidth = view.physicalSize.width / view.devicePixelRatio;
  final logicalHeight = view.physicalSize.height / view.devicePixelRatio;
  await tester.binding.setSurfaceSize(Size(logicalWidth, logicalHeight));
  view.viewInsets = FakeViewPadding(bottom: height);
  addTearDown(view.resetViewInsets);
  await tester.pump();
}

/// Pumps [child] with simulated safe area insets (e.g. notch, home indicator).
Future<void> withSafeArea(
  WidgetTester tester,
  Widget child, {
  double top = 44,
  double bottom = 34,
  double left = 0,
  double right = 0,
}) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      ),
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    ),
  );
}

/// Pumps [child] with a specific [TargetPlatform] override.
Future<void> withPlatform(
  WidgetTester tester,
  Widget child,
  TargetPlatform platform,
) async {
  await tester.pumpWidget(
    Theme(
      data: ThemeData(platform: platform),
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    ),
  );
}
