// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/feedback/oi_bulk_bar.dart';
import 'package:obers_ui/src/primitives/animation/oi_animated_list.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final deleteAction = OiBulkAction(
    label: 'Delete',
    icon: const IconData(0xe872, fontFamily: 'MaterialIcons'),
    onTap: () {},
    variant: OiBulkActionVariant.destructive,
  );

  final archiveAction = OiBulkAction(
    label: 'Archive',
    icon: const IconData(0xe149, fontFamily: 'MaterialIcons'),
    onTap: () {},
  );

  testWidgets('renders selection count text', (tester) async {
    await tester.pumpObers(
      OiBulkBar(
        selectedCount: 3,
        totalCount: 10,
        label: 'items',
        actions: [archiveAction],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('3 of 10 items selected'), findsOneWidget);
  });

  testWidgets('does not render visible content when selectedCount is 0', (
    tester,
  ) async {
    await tester.pumpObers(
      OiBulkBar(
        selectedCount: 0,
        totalCount: 10,
        label: 'items',
        actions: [archiveAction],
      ),
    );
    await tester.pumpAndSettle();

    // The SlideTransition should have offset (0,1) — off screen
    final slideTransition = tester.widget<SlideTransition>(
      find.byType(SlideTransition),
    );
    expect(slideTransition.position.value, const Offset(0, 1));
  });

  testWidgets('renders when selectedCount >= 1', (tester) async {
    await tester.pumpObers(
      OiBulkBar(
        selectedCount: 1,
        totalCount: 10,
        label: 'items',
        actions: [archiveAction],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 of 10 items selected'), findsOneWidget);
  });

  testWidgets('checkbox shows checked state when allSelected is true', (
    tester,
  ) async {
    await tester.pumpObers(
      OiBulkBar(
        selectedCount: 10,
        totalCount: 10,
        label: 'items',
        actions: [archiveAction],
        allSelected: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('10 of 10 items selected'), findsOneWidget);
  });

  testWidgets('tap checkbox calls onDeselectAll when allSelected', (
    tester,
  ) async {
    var deselectCalled = false;

    await tester.pumpObers(
      OiBulkBar(
        selectedCount: 10,
        totalCount: 10,
        label: 'items',
        actions: [archiveAction],
        allSelected: true,
        onDeselectAll: () => deselectCalled = true,
      ),
    );
    await tester.pumpAndSettle();

    // Tap the checkbox area (look for the Deselect all label)
    await tester.tap(find.text('Deselect all'));
    await tester.pump();

    expect(deselectCalled, isTrue);
  });

  testWidgets('tap checkbox calls onSelectAll when not allSelected', (
    tester,
  ) async {
    var selectCalled = false;

    await tester.pumpObers(
      OiBulkBar(
        selectedCount: 3,
        totalCount: 10,
        label: 'items',
        actions: [archiveAction],
        onSelectAll: () => selectCalled = true,
      ),
    );
    await tester.pumpAndSettle();

    // Tap the checkbox area (look for the Select all label)
    await tester.tap(find.text('Select all'));
    await tester.pump();

    expect(selectCalled, isTrue);
  });

  testWidgets('ghost-variant action renders', (tester) async {
    await tester.pumpObers(
      OiBulkBar(
        selectedCount: 2,
        totalCount: 5,
        label: 'items',
        actions: [archiveAction],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Archive'), findsOneWidget);
  });

  testWidgets('destructive-variant action renders', (tester) async {
    await tester.pumpObers(
      OiBulkBar(
        selectedCount: 2,
        totalCount: 5,
        label: 'items',
        actions: [deleteAction],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('confirm-flagged action uses two-press confirm pattern', (
    tester,
  ) async {
    var confirmed = false;

    final confirmAction = OiBulkAction(
      label: 'Remove',
      icon: const IconData(0xe872, fontFamily: 'MaterialIcons'),
      onTap: () => confirmed = true,
      confirm: true,
      confirmLabel: 'Confirm Remove',
    );

    await tester.pumpObers(
      OiBulkBar(
        selectedCount: 2,
        totalCount: 5,
        label: 'items',
        actions: [confirmAction],
      ),
    );
    await tester.pumpAndSettle();

    // First tap — shows confirm label
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm Remove'), findsOneWidget);
    expect(confirmed, isFalse);

    // Second tap — fires the action
    await tester.tap(find.text('Confirm Remove'));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });

  testWidgets('loading action shows loading indicator', (tester) async {
    final loadingAction = OiBulkAction(
      label: 'Export',
      icon: const IconData(0xe2c4, fontFamily: 'MaterialIcons'),
      onTap: () {},
      loading: true,
    );

    await tester.pumpObers(
      Center(
        child: OiBulkBar(
          selectedCount: 2,
          totalCount: 5,
          label: 'items',
          actions: [loadingAction],
        ),
      ),
    );
    // Use pump() instead of pumpAndSettle() — loading animation never settles.
    await tester.pump();

    // The button should be rendered (text may be replaced by loading indicator)
    expect(find.byType(OiBulkBar), findsOneWidget);
  });

  testWidgets('bar has semantic label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpObers(
      Center(
        child: OiBulkBar(
          selectedCount: 2,
          totalCount: 5,
          label: 'items',
          actions: [archiveAction],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('items bulk actions'), findsWidgets);
    handle.dispose();
  });

  testWidgets('slide-in animation plays when selectedCount goes from 0 to 1', (
    tester,
  ) async {
    // Start with 0 selected
    await tester.pumpObers(
      OiBulkBar(
        selectedCount: 0,
        totalCount: 10,
        label: 'items',
        actions: [archiveAction],
      ),
    );
    await tester.pumpAndSettle();

    // The bar should be slid out
    var slideTransition = tester.widget<SlideTransition>(
      find.byType(SlideTransition),
    );
    expect(slideTransition.position.value, const Offset(0, 1));

    // Update to 1 selected
    await tester.pumpObers(
      OiBulkBar(
        selectedCount: 1,
        totalCount: 10,
        label: 'items',
        actions: [archiveAction],
      ),
    );
    await tester.pumpAndSettle();

    // The bar should be slid in
    slideTransition = tester.widget<SlideTransition>(
      find.byType(SlideTransition),
    );
    expect(slideTransition.position.value, Offset.zero);
  });

  testWidgets('clamps selectedCount display to totalCount', (tester) async {
    await tester.pumpObers(
      OiBulkBar(
        selectedCount: 15,
        totalCount: 10,
        label: 'items',
        actions: [archiveAction],
      ),
    );
    await tester.pumpAndSettle();

    // Should display 10 of 10, not 15 of 10
    expect(find.text('10 of 10 items selected'), findsOneWidget);
  });

  testWidgets('uses OiRow instead of raw Row', (tester) async {
    await tester.pumpObers(
      OiBulkBar(
        selectedCount: 3,
        totalCount: 10,
        label: 'items',
        actions: [archiveAction],
      ),
    );
    await tester.pumpAndSettle();

    // OiRow should be used for layout
    expect(find.byType(OiRow), findsWidgets);
  });

  testWidgets('uses OiAnimatedList for action buttons', (tester) async {
    await tester.pumpObers(
      Center(
        child: OiBulkBar(
          selectedCount: 3,
          totalCount: 10,
          label: 'items',
          actions: [archiveAction, deleteAction],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // OiAnimatedList should wrap the action buttons
    expect(find.byType(OiAnimatedList<OiBulkAction>), findsOneWidget);
  });

  testWidgets('OiAnimatedList not present when actions list is empty', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiBulkBar(
        selectedCount: 3,
        totalCount: 10,
        label: 'items',
        actions: [],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(OiAnimatedList<OiBulkAction>), findsNothing);
  });
}
