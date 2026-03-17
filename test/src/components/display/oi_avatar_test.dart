// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_avatar.dart';
import 'package:obers_ui/src/primitives/animation/oi_shimmer.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders initials when no image', (tester) async {
    await tester.pumpObers(
      const OiAvatar(semanticLabel: 'User', initials: 'AB'),
    );
    expect(find.text('AB'), findsOneWidget);
  });

  testWidgets('initials truncated to two characters', (tester) async {
    await tester.pumpObers(
      const OiAvatar(semanticLabel: 'User', initials: 'abcdef'),
    );
    expect(find.text('AB'), findsOneWidget);
  });

  testWidgets('renders icon fallback when no image or initials', (
    tester,
  ) async {
    const icon = IconData(0xe318, fontFamily: 'MaterialIcons');
    await tester.pumpObers(const OiAvatar(semanticLabel: 'User', icon: icon));
    expect(find.byIcon(icon), findsOneWidget);
  });

  testWidgets('skeleton shows OiShimmer', (tester) async {
    await tester.pumpObers(
      const OiAvatar(semanticLabel: 'Loading', skeleton: true),
    );
    expect(find.byType(OiShimmer), findsOneWidget);
  });

  testWidgets('skeleton hides initials', (tester) async {
    await tester.pumpObers(
      const OiAvatar(semanticLabel: 'Loading', initials: 'AB', skeleton: true),
    );
    expect(find.text('AB'), findsNothing);
  });

  testWidgets('presence ring renders Stack', (tester) async {
    await tester.pumpObers(
      const OiAvatar(
        semanticLabel: 'User',
        initials: 'AB',
        presence: OiPresenceStatus.online,
      ),
    );
    expect(find.byType(Stack), findsOneWidget);
  });

  testWidgets('all size variants render without error', (tester) async {
    for (final size in OiAvatarSize.values) {
      await tester.pumpObers(
        OiAvatar(semanticLabel: 'User', initials: 'XY', size: size),
      );
      expect(find.text('XY'), findsOneWidget);
    }
  });
}
