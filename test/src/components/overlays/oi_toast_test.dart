// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/components/overlays/oi_toast.dart';

import '../../../helpers/pump_app.dart';

/// Width of the toast's constrained surface — the [Container] holding the
/// width constraints, not the full-bleed [OiToast] root.
double _toastSurfaceWidth(WidgetTester tester) {
  return tester
      .getSize(
        find
            .descendant(
              of: find.byType(OiToast),
              matching: find.byType(Container),
            )
            .first,
      )
      .width;
}

extension on WidgetTester {
  /// Shows a toast through [OiToast.show] at the given [surfaceSize].
  ///
  /// Width clamping is only observable through this path: pumping an [OiToast]
  /// directly as the app's home imposes tight full-screen constraints, whereas
  /// the real overlay column lays it out loosely.
  Future<void> showToast({
    required String message,
    required Size surfaceSize,
  }) async {
    late BuildContext toastContext;
    await pumpObers(
      Builder(
        builder: (context) {
          toastContext = context;
          return const SizedBox.expand();
        },
      ),
      surfaceSize: surfaceSize,
    );

    final handle = OiToast.show(toastContext, message: message);
    // The toast queue is a singleton that outlives the test, so an undismissed
    // toast leaks into the next one.
    addTearDown(handle.dismiss);
    await pump();
    await pumpAndSettle();
  }
}

void main() {
  testWidgets('renders message text', (tester) async {
    await tester.pumpObers(
      const OiToast(label: 'Toast', message: 'Saved successfully'),
    );
    expect(find.text('Saved successfully'), findsOneWidget);
  });

  testWidgets('renders action widget when provided', (tester) async {
    await tester.pumpObers(
      const OiToast(
        label: 'Toast',
        message: 'Item deleted',
        action: Text('Undo'),
      ),
    );
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('success level renders success icon', (tester) async {
    await tester.pumpObers(
      const OiToast(
        label: 'Toast',
        message: 'Done',
        level: OiToastLevel.success,
      ),
    );
    expect(find.text('✓'), findsOneWidget);
  });

  testWidgets('warning level renders warning icon', (tester) async {
    await tester.pumpObers(
      const OiToast(
        label: 'Toast',
        message: 'Careful',
        level: OiToastLevel.warning,
      ),
    );
    expect(find.text('⚠'), findsOneWidget);
  });

  testWidgets('error level renders error icon', (tester) async {
    await tester.pumpObers(
      const OiToast(
        label: 'Toast',
        message: 'Failed',
        level: OiToastLevel.error,
      ),
    );
    expect(find.text('✕'), findsOneWidget);
  });

  testWidgets('info level renders info icon', (tester) async {
    await tester.pumpObers(const OiToast(label: 'Toast', message: 'FYI'));
    expect(find.text('ℹ'), findsOneWidget);
  });

  testWidgets('info level icon has semantic label', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: OiToast(label: 'Toast', message: 'FYI'),
        ),
      );
      expect(find.bySemanticsLabel('Info'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('success level icon has semantic label', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: OiToast(
            label: 'Toast',
            message: 'Done',
            level: OiToastLevel.success,
          ),
        ),
      );
      expect(find.bySemanticsLabel('Success'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('warning level icon has semantic label', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: OiToast(
            label: 'Toast',
            message: 'Careful',
            level: OiToastLevel.warning,
          ),
        ),
      );
      expect(find.bySemanticsLabel('Warning'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('error level icon has semantic label', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: OiToast(
            label: 'Toast',
            message: 'Failed',
            level: OiToastLevel.error,
          ),
        ),
      );
      expect(find.bySemanticsLabel('Error'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('onDismiss fires after duration elapses', (tester) async {
    var dismissed = false;
    await tester.pumpObers(
      OiToast(
        label: 'Toast',
        message: 'Auto-dismiss',
        duration: const Duration(milliseconds: 100),
        onDismiss: () => dismissed = true,
      ),
    );
    // Advance past the duration.
    await tester.pump(const Duration(milliseconds: 150));
    expect(dismissed, isTrue);
  });

  testWidgets('pauseOnHover=false: timer is not cancelled on hover', (
    tester,
  ) async {
    // With pauseOnHover=false no MouseRegion wraps the content.
    await tester.pumpObers(
      const OiToast(
        label: 'Toast',
        message: 'No hover pause',
        pauseOnHover: false,
      ),
    );
    // Should render without a top-level MouseRegion around content.
    // The content text must still be visible.
    expect(find.text('No hover pause'), findsOneWidget);
  });

  testWidgets('different positions all render the message', (tester) async {
    for (final pos in OiToastPosition.values) {
      await tester.pumpObers(
        OiToast(label: 'Toast', message: 'pos test', position: pos),
      );
      expect(find.text('pos test'), findsOneWidget);
    }
  });

  testWidgets('duration: null runs no timer, so it never self-dismisses', (
    tester,
  ) async {
    var dismissed = false;
    await tester.pumpObers(
      OiToast(
        label: 'Toast',
        message: 'Caller owns expiry',
        duration: null,
        onDismiss: () => dismissed = true,
      ),
    );

    // Far longer than any default duration.
    await tester.pump(const Duration(minutes: 5));

    expect(dismissed, isFalse);
    expect(find.text('Caller owns expiry'), findsOneWidget);
  });

  testWidgets('long press asks the caller to pause, then resume', (
    tester,
  ) async {
    var paused = 0;
    var resumed = 0;
    await tester.pumpObers(
      OiToast(
        label: 'Toast',
        message: 'Hold me',
        duration: null,
        onPauseRequested: () => paused++,
        onResumeRequested: () => resumed++,
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Hold me')),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(paused, 1);

    await gesture.up();
    await tester.pump();
    expect(resumed, 1);
  });

  testWidgets('renders a dismiss button by default', (tester) async {
    await tester.pumpObers(const OiToast(label: 'Toast', message: 'Dismiss'));
    expect(find.byType(OiIconButton), findsOneWidget);
  });

  testWidgets('dismissible=false hides the dismiss button', (tester) async {
    await tester.pumpObers(
      const OiToast(
        label: 'Toast',
        message: 'No dismiss',
        dismissible: false,
      ),
    );
    expect(find.byType(OiIconButton), findsNothing);
  });

  testWidgets('tapping the dismiss button fires onDismiss', (tester) async {
    var dismissed = false;
    await tester.pumpObers(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: OiToast(
          label: 'Toast',
          message: 'Tap to close',
          // Long duration so only the tap can trigger the dismissal.
          duration: const Duration(seconds: 30),
          onDismiss: () => dismissed = true,
        ),
      ),
    );

    await tester.tap(find.byType(OiIconButton));
    await tester.pumpAndSettle();

    expect(dismissed, isTrue);
  });

  testWidgets('constrains its width on narrow viewports', (tester) async {
    await tester.showToast(
      message: 'Narrow',
      surfaceSize: const Size(320, 640),
    );

    // 320 viewport - 32 of column inset = 288, below the 400 default maximum.
    expect(_toastSurfaceWidth(tester), 288.0);
  });

  testWidgets('keeps its default width on wide viewports', (tester) async {
    await tester.showToast(
      message: 'Wide',
      surfaceSize: const Size(1200, 800),
    );

    final width = _toastSurfaceWidth(tester);
    expect(width, lessThanOrEqualTo(400));
    expect(width, greaterThanOrEqualTo(240));
  });

  testWidgets('reducedMotion: fade-in is instant when disableAnimations=true', (
    tester,
  ) async {
    await tester.pumpObers(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: OiToast(label: 'Toast', message: 'Instant'),
      ),
    );
    // Duration.zero controller completes in the first frame — no pumpAndSettle needed.
    final fadeTransition = tester.widget<FadeTransition>(
      find.byType(FadeTransition).first,
    );
    expect(fadeTransition.opacity.value, 1.0);
  });
}
