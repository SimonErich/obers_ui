// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_color_palette_picker.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const redSlot = OiColorSlot(
    id: 'primary',
    label: 'Primary',
    value: Color(0xFFEF4444),
  );
  const blueSlot = OiColorSlot(
    id: 'accent',
    label: 'Accent',
    value: Color(0xFF3B82F6),
  );
  const unsetSlot = OiColorSlot(id: 'bg', label: 'Background');

  final testPresets = [
    const OiColorPalette(
      id: 'warm',
      name: 'Warm',
      colors: {'primary': Color(0xFFEF4444), 'accent': Color(0xFFF97316)},
    ),
    const OiColorPalette(
      id: 'cool',
      name: 'Cool',
      colors: {'primary': Color(0xFF3B82F6), 'accent': Color(0xFF06B6D4)},
    ),
  ];

  testWidgets('renders slot circles for each slot', (tester) async {
    await tester.pumpObers(
      OiColorPalettePicker(
        label: 'Colors',
        slots: const [redSlot, blueSlot, unsetSlot],
        onSlotChanged: (_, __) {},
      ),
    );
    // Each slot gets an OiTappable wrapper.
    // There should be at least 3 tappable widgets for the 3 slots.
    expect(find.byType(OiTappable), findsAtLeast(3));
  });

  testWidgets('filled slot shows colored circle', (tester) async {
    await tester.pumpObers(
      OiColorPalettePicker(
        label: 'Colors',
        slots: const [redSlot],
        onSlotChanged: (_, __) {},
      ),
    );
    // A filled slot renders a DecoratedBox with a color — look for the
    // DecoratedBox inside the 28x28 SizedBox that has a non-null color.
    final decoratedBoxes = find.byType(DecoratedBox);
    expect(decoratedBoxes, findsAtLeastNWidgets(1));

    // The first DecoratedBox in the slot should be the filled circle.
    final box = tester.widget<DecoratedBox>(decoratedBoxes.first);
    final decoration = box.decoration;
    expect(decoration, isA<BoxDecoration>());
    final boxDec = decoration as BoxDecoration;
    expect(boxDec.color, equals(const Color(0xFFEF4444)));
  });

  testWidgets('unset slot shows empty circle (no fill)', (tester) async {
    await tester.pumpObers(
      OiColorPalettePicker(
        label: 'Colors',
        slots: const [unsetSlot],
        onSlotChanged: (_, __) {},
      ),
    );
    // An unset slot renders a CustomPaint with _DashedCirclePainter.
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
  });

  testWidgets('compact mode hides slot labels', (tester) async {
    await tester.pumpObers(
      OiColorPalettePicker(
        label: 'Colors',
        slots: const [redSlot, unsetSlot],
        onSlotChanged: (_, __) {},
      ),
    );
    // compact=true (default) — slot labels should NOT appear as text.
    expect(find.text('Primary'), findsNothing);
    expect(find.text('Background'), findsNothing);
  });

  testWidgets('non-compact mode shows slot labels', (tester) async {
    await tester.pumpObers(
      OiColorPalettePicker(
        label: 'Colors',
        compact: false,
        slots: const [redSlot, unsetSlot],
        onSlotChanged: (_, __) {},
      ),
    );
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Background'), findsOneWidget);
  });

  testWidgets('preset cards render when showPresets=true', (tester) async {
    await tester.pumpObers(
      OiColorPalettePicker(
        label: 'Colors',
        slots: const [redSlot],
        onSlotChanged: (_, __) {},
        presets: testPresets,
      ),
    );
    expect(find.text('Warm'), findsOneWidget);
    expect(find.text('Cool'), findsOneWidget);
  });

  testWidgets('no presets when showPresets=false', (tester) async {
    await tester.pumpObers(
      OiColorPalettePicker(
        label: 'Colors',
        slots: const [redSlot],
        onSlotChanged: (_, __) {},
        showPresets: false,
        presets: testPresets,
      ),
    );
    expect(find.text('Warm'), findsNothing);
    expect(find.text('Cool'), findsNothing);
  });

  testWidgets('tapping a preset fires onPresetSelected', (tester) async {
    OiColorPalette? selected;
    await tester.pumpObers(
      OiColorPalettePicker(
        label: 'Colors',
        slots: const [redSlot],
        onSlotChanged: (_, __) {},
        presets: testPresets,
        onPresetSelected: (p) => selected = p,
      ),
    );
    // Tap the first preset card ("Warm").
    await tester.tap(find.text('Warm'));
    await tester.pump();
    expect(selected, isNotNull);
    expect(selected!.id, equals('warm'));
  });

  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(
      OiColorPalettePicker(
        label: 'Brand colors',
        slots: const [redSlot],
        onSlotChanged: (_, __) {},
      ),
    );
    // The outermost Semantics widget should carry the label.
    final semantics = find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == 'Brand colors',
    );
    expect(semantics, findsAtLeastNWidgets(1));
  });

  testWidgets('renders without error with empty slots', (tester) async {
    await tester.pumpObers(
      OiColorPalettePicker(
        label: 'Colors',
        slots: const [],
        onSlotChanged: (_, __) {},
      ),
    );
    expect(find.byType(OiColorPalettePicker), findsOneWidget);
  });
}
