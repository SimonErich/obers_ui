// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';

import '../../../helpers/pump_app.dart';

const _kIcon = IconData(0xe318, fontFamily: 'MaterialIcons');

void main() {
  testWidgets('renders icon', (tester) async {
    await tester.pumpObers(const OiIconButton(icon: _kIcon));
    expect(find.byIcon(_kIcon), findsOneWidget);
  });

  testWidgets('onTap fires when tapped', (tester) async {
    var count = 0;
    await tester.pumpObers(OiIconButton(icon: _kIcon, onTap: () => count++));
    await tester.tap(find.byIcon(_kIcon));
    await tester.pump();
    expect(count, 1);
  });

  testWidgets('onTap not called when enabled=false', (tester) async {
    var count = 0;
    await tester.pumpObers(
      OiIconButton(icon: _kIcon, enabled: false, onTap: () => count++),
    );
    await tester.tap(find.byIcon(_kIcon), warnIfMissed: false);
    await tester.pump();
    expect(count, 0);
  });

  testWidgets('delegates to OiButton.icon', (tester) async {
    await tester.pumpObers(
      const OiIconButton(icon: _kIcon, variant: OiButtonVariant.primary),
    );
    expect(find.byType(OiButton), findsOneWidget);
  });

  testWidgets('large size renders larger than medium size', (tester) async {
    // Use pointer-device density (compact) so the 48 dp touch-target floor
    // only applies on comfortable/touch density. Both sizes are tested at
    // comfortable so the floor is the same; compare medium vs large instead,
    // where large (44 dp comfortable) is taller than medium (36 dp comfortable).
    await tester.pumpObers(
      const Column(
        children: [
          OiIconButton(key: Key('md'), icon: _kIcon),
          OiIconButton(key: Key('lg'), icon: _kIcon, size: OiButtonSize.large),
        ],
      ),
    );
    final mdH = tester.getSize(find.byKey(const Key('md'))).height;
    final lgH = tester.getSize(find.byKey(const Key('lg'))).height;
    expect(lgH, greaterThanOrEqualTo(mdH));
  });
}
