// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_image_preview_card.dart';
import 'package:obers_ui/src/primitives/animation/oi_shimmer.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ────────────────────────────────────────────────────────────────────

Widget _card({
  String alt = 'Test image',
  String? imageUrl,
  Widget? statusBadge,
  VoidCallback? onTap,
  VoidCallback? onEdit,
  bool loading = false,
  bool regenerating = false,
  bool enableZoom = false,
  String? versionLabel,
}) {
  return SizedBox(
    width: 200,
    height: 200,
    child: OiImagePreviewCard(
      alt: alt,
      imageUrl: imageUrl,
      statusBadge: statusBadge,
      onTap: onTap,
      onEdit: onEdit,
      loading: loading,
      regenerating: regenerating,
      enableZoom: enableZoom,
      versionLabel: versionLabel,
    ),
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  // ── Rendering ────────────────────────────────────────────────────────────

  group('Rendering', () {
    testWidgets('renders without error when imageUrl is null', (tester) async {
      await tester.pumpObers(_card());
      expect(find.byType(OiImagePreviewCard), findsOneWidget);
    });

    testWidgets('shows shimmer when imageUrl is null', (tester) async {
      await tester.pumpObers(_card());
      expect(find.byType(OiShimmer), findsOneWidget);
    });

    testWidgets('shows shimmer when loading is true', (tester) async {
      await tester.pumpObers(
        _card(imageUrl: 'https://example.com/img.png', loading: true),
      );
      expect(find.byType(OiShimmer), findsOneWidget);
    });

    testWidgets('renders Image.network when imageUrl is provided', (
      tester,
    ) async {
      await tester.pumpObers(_card(imageUrl: 'https://example.com/img.png'));
      // Image.network creates an Image widget internally.
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('shows shimmer overlay when regenerating is true', (
      tester,
    ) async {
      await tester.pumpObers(
        _card(imageUrl: 'https://example.com/img.png', regenerating: true),
      );
      // Should have both Image and OiShimmer in the tree.
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(OiShimmer), findsOneWidget);
    });

    testWidgets('wraps image in InteractiveViewer when enableZoom is true', (
      tester,
    ) async {
      await tester.pumpObers(
        _card(imageUrl: 'https://example.com/img.png', enableZoom: true),
      );
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });
  });

  // ── Overlays ─────────────────────────────────────────────────────────────

  group('Overlays', () {
    testWidgets('statusBadge renders when provided', (tester) async {
      await tester.pumpObers(
        _card(
          statusBadge: const SizedBox(key: Key('badge'), width: 20, height: 20),
        ),
      );
      expect(find.byKey(const Key('badge')), findsOneWidget);
    });

    testWidgets('versionLabel renders when provided', (tester) async {
      await tester.pumpObers(_card(versionLabel: 'v3'));
      expect(find.text('v3'), findsOneWidget);
    });
  });

  // ── Interaction ──────────────────────────────────────────────────────────

  group('Interaction', () {
    testWidgets('onTap fires callback', (tester) async {
      var tapped = false;
      await tester.pumpObers(_card(onTap: () => tapped = true));

      await tester.tap(find.byType(OiImagePreviewCard));
      expect(tapped, isTrue);
    });

    testWidgets('wraps in OiTappable when onTap is provided', (tester) async {
      await tester.pumpObers(_card(onTap: () {}));
      expect(
        find
                .ancestor(
                  of: find.byType(OiImagePreviewCard),
                  matching: find.byType(OiTappable),
                )
                .evaluate()
                .isNotEmpty ||
            find
                .descendant(
                  of: find.byType(OiImagePreviewCard),
                  matching: find.byType(OiTappable),
                )
                .evaluate()
                .isNotEmpty,
        isTrue,
      );
    });

    testWidgets('does not wrap in OiTappable when onTap is null', (
      tester,
    ) async {
      await tester.pumpObers(_card());
      expect(
        find.descendant(
          of: find.byType(OiImagePreviewCard),
          matching: find.byType(OiTappable),
        ),
        findsNothing,
      );
    });
  });

  // ── Accessibility ────────────────────────────────────────────────────────

  group('Accessibility', () {
    testWidgets('has semantics with alt text', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpObers(_card(alt: 'Beautiful landscape'));
        expect(find.bySemanticsLabel('Beautiful landscape'), findsOneWidget);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('Semantics node has image flag', (tester) async {
      await tester.pumpObers(_card(alt: 'Photo'));
      final semantics = tester.widget<Semantics>(
        find.descendant(
          of: find.byType(OiImagePreviewCard),
          matching: find.byWidgetPredicate(
            (w) => w is Semantics && (w.properties.image ?? false),
          ),
        ),
      );
      expect(semantics.properties.label, 'Photo');
      expect(semantics.properties.image, isTrue);
    });
  });

  // ── Edge cases ───────────────────────────────────────────────────────────

  group('Edge cases', () {
    testWidgets('no error when all optional params are null', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 200,
          height: 200,
          child: OiImagePreviewCard(alt: 'Minimal'),
        ),
      );
      expect(find.byType(OiImagePreviewCard), findsOneWidget);
    });
  });
}
