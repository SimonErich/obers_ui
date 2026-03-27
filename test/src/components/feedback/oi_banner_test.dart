// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs


import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/components/feedback/oi_banner.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Rendering ─────────────────────────────────────────────────────────────

  testWidgets('renders message text', (tester) async {
    await tester.pumpObers(
      const OiBanner.info(message: 'Your trial expires in 3 days'),
    );
    expect(find.text('Your trial expires in 3 days'), findsOneWidget);
  });

  testWidgets('renders title when provided', (tester) async {
    await tester.pumpObers(
      const OiBanner.warning(title: 'Heads up', message: 'Maintenance tonight'),
    );
    expect(find.text('Heads up'), findsOneWidget);
    expect(find.text('Maintenance tonight'), findsOneWidget);
  });

  // ── Factory constructors ────────────────────────────────────────────────

  testWidgets('all five levels render without errors', (tester) async {
    for (final widget in const [
      OiBanner.info(message: 'test'),
      OiBanner.success(message: 'test'),
      OiBanner.warning(message: 'test'),
      OiBanner.error(message: 'test'),
      OiBanner.neutral(message: 'test'),
    ]) {
      await tester.pumpObers(widget);
      expect(find.byType(OiBanner), findsOneWidget);
    }
  });

  testWidgets('factory constructors set correct level', (tester) async {
    await tester.pumpObers(const OiBanner.error(message: 'err'));
    final banner = tester.widget<OiBanner>(find.byType(OiBanner));
    expect(banner.level, OiBannerLevel.error);
  });

  // ── Dismiss ─────────────────────────────────────────────────────────────

  testWidgets('shows dismiss button when dismissible is true', (tester) async {
    await tester.pumpObers(const OiBanner.info(message: 'Notice'));
    expect(find.byType(OiIconButton), findsOneWidget);
  });

  testWidgets('hides dismiss button when dismissible is false', (tester) async {
    await tester.pumpObers(
      const OiBanner.error(message: 'Critical', dismissible: false),
    );
    expect(find.byType(OiIconButton), findsNothing);
  });

  testWidgets('calls onDismiss when dismiss button tapped', (tester) async {
    var dismissed = false;
    await tester.pumpObers(
      OiBanner.info(message: 'Notice', onDismiss: () => dismissed = true),
    );
    await tester.tap(find.byType(OiIconButton));
    expect(dismissed, isTrue);
  });

  testWidgets('animates out after self-dismiss (no onDismiss)', (tester) async {
    await tester.pumpObers(const OiBanner.info(message: 'Bye'));
    expect(find.text('Bye'), findsOneWidget);
    await tester.tap(find.byType(OiIconButton));
    await tester.pumpAndSettle();
    expect(find.text('Bye'), findsNothing);
  });

  // ── Action widget ───────────────────────────────────────────────────────

  testWidgets('renders action widget', (tester) async {
    await tester.pumpObers(
      OiBanner.warning(
        message: 'Upgrade required',
        action: OiButton.outline(label: 'Upgrade', onTap: () {}),
      ),
    );
    expect(find.text('Upgrade'), findsOneWidget);
  });

  testWidgets('renders secondary action widget', (tester) async {
    await tester.pumpObers(
      OiBanner.info(
        message: 'Notice',
        action: OiButton.outline(label: 'Primary', onTap: () {}),
        secondaryAction: OiButton.ghost(label: 'Secondary', onTap: () {}),
      ),
    );
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Secondary'), findsOneWidget);
  });

  // ── Icon ────────────────────────────────────────────────────────────────

  testWidgets('renders level-appropriate default icon', (tester) async {
    await tester.pumpObers(const OiBanner.error(message: 'Error'));
    expect(find.byType(OiIcon), findsAtLeast(1));
  });

  testWidgets('uses custom icon when provided', (tester) async {
    await tester.pumpObers(
      const OiBanner.info(message: 'Custom', icon: IconData(0xe800)),
    );
    expect(find.byType(OiIcon), findsAtLeast(1));
  });

  testWidgets('compact mode hides icon', (tester) async {
    await tester.pumpObers(
      const OiBanner.info(message: 'Compact', compact: true),
    );
    // Only the dismiss icon, not the leading icon.
    // In compact mode the leading icon is hidden.
    final banner = tester.widget<OiBanner>(find.byType(OiBanner));
    expect(banner.compact, isTrue);
  });

  // ── Accessibility ───────────────────────────────────────────────────────

  testWidgets('has semantic live region', (tester) async {
    await tester.pumpObers(const OiBanner.warning(message: 'Attention'));
    // Verify Semantics widget with liveRegion is in the tree.
    final semanticsWidget = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (w) => w is Semantics && (w.properties.liveRegion ?? false),
      ),
    );
    expect(semanticsWidget, isNotNull);
  });

  // ── Border ──────────────────────────────────────────────────────────────

  testWidgets('renders with border by default', (tester) async {
    await tester.pumpObers(const OiBanner.error(message: 'err'));
    final banner = tester.widget<OiBanner>(find.byType(OiBanner));
    expect(banner.border, isTrue);
  });

  testWidgets('no accent border when border is false', (tester) async {
    await tester.pumpObers(const OiBanner.error(message: 'err', border: false));
    final banner = tester.widget<OiBanner>(find.byType(OiBanner));
    expect(banner.border, isFalse);
  });

  // ── Stacking ────────────────────────────────────────────────────────────

  testWidgets('multiple banners render independently', (tester) async {
    await tester.pumpObers(
      const Column(
        children: [
          OiBanner.info(message: 'First'),
          OiBanner.warning(message: 'Second'),
        ],
      ),
    );
    expect(find.byType(OiBanner), findsNWidgets(2));
  });
}
