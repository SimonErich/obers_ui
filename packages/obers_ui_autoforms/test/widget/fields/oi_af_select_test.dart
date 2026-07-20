// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

enum _F { fruit, color }

class _Ctrl extends OiAfController<_F, Map<String, dynamic>> {
  _Ctrl({String? initialFruit}) : _initialFruit = initialFruit;
  final String? _initialFruit;

  @override
  void defineFields() {
    addSelectField<String>(_F.fruit, initialValue: _initialFruit);
    addSelectField<String>(_F.color);
  }

  @override
  Map<String, dynamic> buildData() => json();
}

const _kFruitOpts = [
  OiAfOption(value: 'a', label: 'Apple'),
  OiAfOption(value: 'b', label: 'Banana'),
];

const _kColorOpts = [
  OiAfOption(value: 'r', label: 'Red'),
  OiAfOption(value: 'g', label: 'Green'),
];

Widget _wrap({required _Ctrl controller, required Widget child}) {
  return OiApp(
    home: OiAfForm<_F, Map<String, dynamic>>(
      controller: controller,
      child: child,
    ),
  );
}

void main() {
  group('OiAfSelect', () {
    late _Ctrl ctrl;

    setUp(() {
      ctrl = _Ctrl(initialFruit: 'a');
    });

    tearDown(() {
      ctrl.dispose();
    });

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        _wrap(
          controller: ctrl,
          child: const OiAfSelect<_F, String>(
            field: _F.fruit,
            options: _kFruitOpts,
          ),
        ),
      );
      expect(find.byType(OiAfSelect<_F, String>), findsOneWidget);
    });

    testWidgets('shows selected value from controller', (tester) async {
      await tester.pumpWidget(
        _wrap(
          controller: ctrl,
          child: const OiAfSelect<_F, String>(
            field: _F.fruit,
            options: _kFruitOpts,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Apple'), findsOneWidget);
    });

    testWidgets('opens dropdown on tap', (tester) async {
      await tester.pumpWidget(
        _wrap(
          controller: ctrl,
          child: const OiAfSelect<_F, String>(
            field: _F.fruit,
            options: _kFruitOpts,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('label prop is forwarded to OiSelect', (tester) async {
      await tester.pumpWidget(
        _wrap(
          controller: ctrl,
          child: const OiAfSelect<_F, String>(
            field: _F.fruit,
            options: _kFruitOpts,
            label: 'Fruit',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Fruit'), findsOneWidget);
    });

    // ── Constrained-parent regression ──────────────────────────────────────

    testWidgets('selected value shown in constrained Expanded column', (
      tester,
    ) async {
      const size = Size(320, 400);
      await tester.binding.setSurfaceSize(size);
      tester.binding.platformDispatcher.views.first.physicalSize = size;
      tester.binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
        tester.binding.platformDispatcher.views.first.resetPhysicalSize();
        tester.binding.platformDispatcher.views.first.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _wrap(
          controller: ctrl,
          child: const Row(
            children: [
              Expanded(
                child: OiAfSelect<_F, String>(
                  field: _F.fruit,
                  options: _kFruitOpts,
                ),
              ),
              Expanded(
                child: OiAfSelect<_F, String>(
                  field: _F.color,
                  options: _kColorOpts,
                  placeholder: 'Color',
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The initial value 'a' → 'Apple' must appear in the left column trigger.
      expect(
        find.text('Apple'),
        findsOneWidget,
        reason: 'selected value shown in constrained Expanded column',
      );
    });

    testWidgets('dropdown stays near right-column anchor on narrow screen', (
      tester,
    ) async {
      // 320 px wide, 2 columns = 160 px each.  The dropdown is at least
      // 200 px wide — wider than one column.  After the fix, it must NOT
      // jump to the left screen edge but stay as close to the anchor as
      // possible (right edge pinned to safeRight).
      const size = Size(320, 400);
      await tester.binding.setSurfaceSize(size);
      tester.binding.platformDispatcher.views.first.physicalSize = size;
      tester.binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
        tester.binding.platformDispatcher.views.first.resetPhysicalSize();
        tester.binding.platformDispatcher.views.first.resetDevicePixelRatio();
      });

      final rightCtrl = _Ctrl();
      addTearDown(rightCtrl.dispose);

      await tester.pumpWidget(
        _wrap(
          controller: rightCtrl,
          child: const Row(
            children: [
              Expanded(
                child: OiAfSelect<_F, String>(
                  field: _F.color,
                  options: _kColorOpts,
                  placeholder: 'Left',
                ),
              ),
              Expanded(
                child: OiAfSelect<_F, String>(
                  key: Key('right'),
                  field: _F.fruit,
                  options: _kFruitOpts,
                  placeholder: 'Right',
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final anchorRect = tester.getRect(find.byKey(const Key('right')));

      await tester.tap(find.byKey(const Key('right')));
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsAtLeastNWidgets(1));

      final dropItemRect = tester.getRect(find.text('Apple').last);

      // Must appear below the anchor.
      expect(
        dropItemRect.top,
        greaterThanOrEqualTo(anchorRect.bottom - 1),
        reason: 'dropdown below anchor',
      );
      // Must stay on screen.
      expect(dropItemRect.left, greaterThanOrEqualTo(0), reason: 'on screen');
      // KEY: must NOT jump to the far-left edge (x≈8).  The 240 px dropdown
      // is wider than the 160 px column, so it can't align to anchor.left.
      // After the fix the right edge is pinned to safeRight; container right
      // = itemRight + 12 px padding must exceed half-screen (160).
      final dropContainerRight = dropItemRect.right + 12;
      expect(
        dropContainerRight,
        greaterThan(160),
        reason: 'right-pinned, not left-jumped',
      );
    });
  });
}
