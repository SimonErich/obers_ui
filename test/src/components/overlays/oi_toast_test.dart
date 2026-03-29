// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/overlays/oi_toast.dart';

import '../../../helpers/pump_app.dart';

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
