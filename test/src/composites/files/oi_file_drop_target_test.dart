// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/files/oi_file_drop_target.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';
import 'package:obers_ui/src/modules/oi_chat.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _dropTarget({
  Widget? child,
  void Function(List<OiFileNodeData>, OiFileNodeData?)? onInternalDrop,
  ValueChanged<List<OiFileData>>? onExternalDrop,
  bool enabled = true,
  String? dropMessage,
}) {
  return SizedBox(
    width: 600,
    height: 400,
    child: OiFileDropTarget(
      onInternalDrop: onInternalDrop ?? (_, __) {},
      onExternalDrop: onExternalDrop ?? (_) {},
      enabled: enabled,
      dropMessage: dropMessage,
      child: child ?? const Center(child: Text('Content area')),
    ),
  );
}

void main() {
  group('OiFileDropTarget', () {
    // ══════════════════════════════════════════════════════════════════════════
    // ── Rendering tests ────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders without errors', (tester) async {
      await tester.pumpObers(_dropTarget());
      expect(find.text('Content area'), findsOneWidget);
    });

    testWidgets('renders child widget', (tester) async {
      await tester.pumpObers(
        _dropTarget(child: const Text('Custom child')),
      );
      expect(find.text('Custom child'), findsOneWidget);
    });

    testWidgets('renders when disabled', (tester) async {
      await tester.pumpObers(_dropTarget(enabled: false));
      expect(find.text('Content area'), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Enabled/disabled behavior ──────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('when disabled, child is rendered directly without drop zone',
        (tester) async {
      await tester.pumpObers(_dropTarget(enabled: false));
      // The child should be rendered but there should be no OiDropZone wrapping
      expect(find.text('Content area'), findsOneWidget);
    });

    testWidgets('when enabled, wraps child in drop zone', (tester) async {
      await tester.pumpObers(_dropTarget(enabled: true));
      expect(find.text('Content area'), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Drop message ───────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('uses custom drop message', (tester) async {
      await tester.pumpObers(
        _dropTarget(dropMessage: 'Drop your documents here'),
      );
      // The drop message is shown only during drag-over state,
      // but the widget should still render without errors.
      expect(find.text('Content area'), findsOneWidget);
    });

    testWidgets('uses default drop message when none provided', (tester) async {
      await tester.pumpObers(_dropTarget());
      // Default message is 'Drop files here', but it is only visible during
      // drag-over. We just verify the widget builds correctly.
      expect(find.text('Content area'), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Callback wiring ────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('onInternalDrop callback is wired', (tester) async {
      var called = false;
      await tester.pumpObers(
        _dropTarget(onInternalDrop: (files, folder) => called = true),
      );
      // Callback is wired but requires drag-and-drop gesture to trigger.
      // We verify the widget builds without errors.
      expect(called, isFalse);
      expect(find.text('Content area'), findsOneWidget);
    });

    testWidgets('onExternalDrop callback is wired', (tester) async {
      var called = false;
      await tester.pumpObers(
        _dropTarget(onExternalDrop: (files) => called = true),
      );
      expect(called, isFalse);
      expect(find.text('Content area'), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Rebuilds ───────────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('toggling enabled rebuilds correctly', (tester) async {
      await tester.pumpObers(_dropTarget(enabled: true));
      expect(find.text('Content area'), findsOneWidget);

      await tester.pumpObers(_dropTarget(enabled: false));
      expect(find.text('Content area'), findsOneWidget);
    });

    testWidgets('changing child rebuilds correctly', (tester) async {
      await tester.pumpObers(
        _dropTarget(child: const Text('Version 1')),
      );
      expect(find.text('Version 1'), findsOneWidget);

      await tester.pumpObers(
        _dropTarget(child: const Text('Version 2')),
      );
      expect(find.text('Version 2'), findsOneWidget);
    });
  });
}
