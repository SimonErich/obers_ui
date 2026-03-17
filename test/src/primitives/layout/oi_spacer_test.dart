// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/layout/oi_spacer.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Fixed size ─────────────────────────────────────────────────────────────

  testWidgets('size renders a vertical SizedBox by default', (tester) async {
    await tester.pumpObers(
      const Column(children: [OiSpacer(size: 24)]),
    );
    final box = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(box.height, 24);
    expect(box.width, isNull);
  });

  testWidgets('size with horizontal axis renders a horizontal SizedBox',
      (tester) async {
    await tester.pumpObers(
      const Row(children: [OiSpacer(size: 16, axis: Axis.horizontal)]),
    );
    final box = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(box.width, 16);
    expect(box.height, isNull);
  });

  // ── Flex ───────────────────────────────────────────────────────────────────

  testWidgets('flex renders a Spacer with given flex', (tester) async {
    await tester.pumpObers(
      const Row(children: [OiSpacer(flex: 2)]),
    );
    final spacer = tester.widget<Spacer>(find.byType(Spacer));
    expect(spacer.flex, 2);
  });

  testWidgets('neither size nor flex renders Spacer with flex 1', (tester) async {
    await tester.pumpObers(
      const Row(children: [OiSpacer()]),
    );
    final spacer = tester.widget<Spacer>(find.byType(Spacer));
    expect(spacer.flex, 1);
  });

  testWidgets('flex takes precedence over size', (tester) async {
    await tester.pumpObers(
      const Row(children: [OiSpacer(size: 10, flex: 3)]),
    );
    // When flex is set, a Spacer is rendered with the correct flex value.
    final spacer = tester.widget<Spacer>(find.byType(Spacer));
    expect(spacer.flex, 3);
  });
}
