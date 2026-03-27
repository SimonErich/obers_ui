// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/components/navigation/oi_action_bar.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final testActions = [
    OiActionBarItem(
      icon: OiIcons.pencil,
      label: 'Edit',
      semanticLabel: 'Edit item',
      onTap: () {},
    ),
    OiActionBarItem(
      icon: OiIcons.trash,
      label: 'Delete',
      semanticLabel: 'Delete item',
      onTap: () {},
      variant: OiButtonVariant.destructive,
    ),
    OiActionBarItem(
      icon: OiIcons.archive,
      label: 'Archive',
      semanticLabel: 'Archive item',
      onTap: () {},
    ),
  ];

  // ── Rendering ────────────────────────────────────────────────────────────

  testWidgets('renders all action buttons', (tester) async {
    await tester.pumpObers(
      OiActionBar(label: 'Test actions', actions: testActions),
    );

    expect(find.byType(OiIconButton), findsNWidgets(3));
  });

  // ── Interaction ──────────────────────────────────────────────────────────

  testWidgets('tapping action calls onTap', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiActionBar(
        label: 'Test actions',
        actions: [
          OiActionBarItem(
            icon: OiIcons.pencil,
            label: 'Edit',
            semanticLabel: 'Edit item',
            onTap: () => tapped = true,
          ),
        ],
      ),
    );

    await tester.tap(find.byType(OiIconButton));
    expect(tapped, isTrue);
  });

  testWidgets('disabled action does not fire onTap', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiActionBar(
        label: 'Test actions',
        actions: [
          OiActionBarItem(
            icon: OiIcons.pencil,
            label: 'Edit',
            semanticLabel: 'Edit item',
            onTap: () => tapped = true,
            enabled: false,
          ),
        ],
      ),
    );

    await tester.tap(find.byType(OiIconButton));
    expect(tapped, isFalse);
  });

  // ── Toggled ──────────────────────────────────────────────────────────────

  testWidgets('toggled action has primary variant', (tester) async {
    await tester.pumpObers(
      OiActionBar(
        label: 'Test actions',
        actions: [
          OiActionBarItem(
            icon: OiIcons.pencil,
            label: 'Edit',
            semanticLabel: 'Edit item',
            toggled: true,
          ),
        ],
      ),
    );

    final iconButton = tester.widget<OiIconButton>(find.byType(OiIconButton));
    expect(iconButton.variant, OiButtonVariant.primary);
  });

  // ── Leading & trailing ────────────────────────────────────────────────────

  testWidgets('leading and trailing widgets render', (tester) async {
    await tester.pumpObers(
      OiActionBar(
        label: 'Test actions',
        actions: testActions,
        leading: const SizedBox(key: Key('leading')),
        trailing: const SizedBox(key: Key('trailing')),
      ),
    );

    expect(find.byKey(const Key('leading')), findsOneWidget);
    expect(find.byKey(const Key('trailing')), findsOneWidget);
  });

  // ── Show labels ──────────────────────────────────────────────────────────

  testWidgets('showLabels=true displays text labels', (tester) async {
    await tester.pumpObers(
      OiActionBar(
        label: 'Test actions',
        actions: [
          OiActionBarItem(
            icon: OiIcons.pencil,
            label: 'Edit',
            semanticLabel: 'Edit item',
            onTap: () {},
          ),
        ],
        showLabels: true,
      ),
    );

    // When showLabels is true, OiButton is used instead of OiIconButton.
    expect(find.byType(OiButton), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
  });

  // ── Separator ─────────────────────────────────────────────────────────────

  testWidgets('separator renders between groups', (tester) async {
    await tester.pumpObers(
      OiActionBar(
        label: 'Test actions',
        separator: true,
        actions: [
          OiActionBarItem(
            icon: OiIcons.pencil,
            label: 'Edit',
            semanticLabel: 'Edit item',
            group: 'a',
          ),
          OiActionBarItem(
            icon: OiIcons.trash,
            label: 'Delete',
            semanticLabel: 'Delete item',
            group: 'b',
          ),
        ],
      ),
    );

    // The separator is a Container with width: 1, height: 20.
    final separators = find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.constraints != null &&
          w.constraints!.maxWidth == 1 &&
          w.constraints!.maxHeight == 20,
    );
    expect(separators, findsOneWidget);
  });

  // ── Empty state ───────────────────────────────────────────────────────────

  testWidgets('empty actions returns SizedBox.shrink', (tester) async {
    await tester.pumpObers(
      const OiActionBar(label: 'Test actions', actions: []),
    );

    expect(find.byType(SizedBox), findsOneWidget);
  });

  // ── Loading ───────────────────────────────────────────────────────────────

  testWidgets('loading action shows different state', (tester) async {
    await tester.pumpObers(
      OiActionBar(
        label: 'Test actions',
        actions: [
          OiActionBarItem(
            icon: OiIcons.pencil,
            label: 'Edit',
            semanticLabel: 'Edit item',
            loading: true,
          ),
        ],
      ),
    );

    // Loading replaces the OiIconButton with a SizedBox containing the spinner.
    expect(find.byType(OiIconButton), findsNothing);
    // The loading state renders a SizedBox with a spinner inside.
    expect(find.byType(SizedBox), findsWidgets);
  });

  // ── Badge ─────────────────────────────────────────────────────────────────

  testWidgets('badge renders on action', (tester) async {
    await tester.pumpObers(
      OiActionBar(
        actions: [
          OiActionBarItem(
            icon: OiIcons.pencil,
            label: 'Inbox',
            semanticLabel: 'Inbox',
            onTap: () {},
            badge: '5',
          ),
        ],
        label: 'Actions',
      ),
    );
    expect(find.text('5'), findsOneWidget);
  });

  // ── Overflow actions ──────────────────────────────────────────────────────

  testWidgets('empty overflowActions does not show more button', (
    tester,
  ) async {
    await tester.pumpObers(
      OiActionBar(
        actions: [
          OiActionBarItem(
            icon: OiIcons.pencil,
            label: 'Edit',
            semanticLabel: 'Edit',
            onTap: () {},
          ),
        ],
        overflowActions: const [],
        label: 'Actions',
      ),
    );
    // Should not find a "more" button.
    expect(find.bySemanticsLabel('More actions'), findsNothing);
  });

  testWidgets('non-empty overflowActions shows more button', (tester) async {
    await tester.pumpObers(
      OiActionBar(
        actions: [
          OiActionBarItem(
            icon: OiIcons.pencil,
            label: 'Edit',
            semanticLabel: 'Edit',
            onTap: () {},
          ),
        ],
        overflowActions: [
          OiActionBarItem(
            icon: OiIcons.archive,
            label: 'Archive',
            semanticLabel: 'Archive',
            onTap: () {},
          ),
        ],
        label: 'Actions',
      ),
    );
    expect(find.bySemanticsLabel('More actions'), findsOneWidget);
  });

  testWidgets('tapping more button then overflow item fires onTap', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpObers(
      OiActionBar(
        actions: [
          OiActionBarItem(
            icon: OiIcons.pencil,
            label: 'Edit',
            semanticLabel: 'Edit',
            onTap: () {},
          ),
        ],
        overflowActions: [
          OiActionBarItem(
            icon: OiIcons.archive,
            label: 'Archive',
            semanticLabel: 'Archive',
            onTap: () => tapped = true,
          ),
        ],
        label: 'Actions',
      ),
      surfaceSize: const Size(400, 300),
    );

    // Tap the more button to open the overflow popover.
    await tester.tap(find.bySemanticsLabel('More actions'));
    await tester.pumpAndSettle();

    // The overflow item label should now be visible.
    expect(find.text('Archive'), findsOneWidget);

    // Tap the overflow item.
    await tester.tap(find.text('Archive'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  // ── Confirm ───────────────────────────────────────────────────────────────

  testWidgets('confirm action requires two taps', (tester) async {
    var executed = false;
    await tester.pumpObers(
      OiActionBar(
        actions: [
          OiActionBarItem(
            icon: OiIcons.trash,
            label: 'Delete',
            semanticLabel: 'Delete',
            confirm: 'Are you sure?',
            onTap: () => executed = true,
          ),
        ],
        label: 'Actions',
      ),
    );
    // First tap shows confirmation.
    await tester.tap(find.bySemanticsLabel('Delete'));
    await tester.pump();
    expect(executed, isFalse);
    // Confirm text should appear.
    expect(find.text('Are you sure?'), findsOneWidget);
    // Second tap executes.
    await tester.tap(find.text('Are you sure?'));
    await tester.pump();
    expect(executed, isTrue);
  });
}
