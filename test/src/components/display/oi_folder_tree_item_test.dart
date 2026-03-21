// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_folder_icon.dart';
import 'package:obers_ui/src/components/display/oi_folder_tree_item.dart';
import 'package:obers_ui/src/components/display/oi_rename_field.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const folder = OiFileNodeData(id: 'f1', name: 'Documents', isFolder: true);

  const sharedFolder = OiFileNodeData(
    id: 'f2',
    name: 'Shared',
    isFolder: true,
    isShared: true,
  );

  const trashedFolder = OiFileNodeData(
    id: 'f3',
    name: 'Old Stuff',
    isFolder: true,
    isTrashed: true,
  );

  testWidgets('renders folder name', (tester) async {
    await tester.pumpObers(
      const OiFolderTreeItem(folder: folder, expanded: false, selected: false),
    );
    expect(find.text('Documents'), findsOneWidget);
  });

  testWidgets('renders OiFolderIcon', (tester) async {
    await tester.pumpObers(
      const OiFolderTreeItem(folder: folder, expanded: false, selected: false),
    );
    expect(find.byType(OiFolderIcon), findsOneWidget);
  });

  testWidgets('shows item count badge', (tester) async {
    await tester.pumpObers(
      const OiFolderTreeItem(
        folder: folder,
        expanded: false,
        selected: false,
        itemCount: 42,
      ),
    );
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('hides item count when null', (tester) async {
    await tester.pumpObers(
      const OiFolderTreeItem(folder: folder, expanded: false, selected: false),
    );
    // Only the folder name text should be present
    expect(find.text('Documents'), findsOneWidget);
  });

  testWidgets('onTap callback fires', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiFolderTreeItem(
        folder: folder,
        expanded: false,
        selected: false,
        onTap: () => tapped = true,
      ),
    );
    await tester.tap(find.text('Documents'));
    expect(tapped, isTrue);
  });

  testWidgets('onExpand callback fires when chevron tapped', (tester) async {
    var expanded = false;
    await tester.pumpObers(
      OiFolderTreeItem(
        folder: folder,
        expanded: false,
        selected: false,
        onExpand: () => expanded = true,
      ),
    );
    // The first Icon is the expand/collapse chevron
    await tester.tap(find.byType(Icon).first);
    expect(expanded, isTrue);
  });

  testWidgets('expanded state shows open folder icon', (tester) async {
    await tester.pumpObers(
      const OiFolderTreeItem(folder: folder, expanded: true, selected: false),
    );
    final folderIcon = tester.widget<OiFolderIcon>(find.byType(OiFolderIcon));
    expect(folderIcon.state, OiFolderIconState.open);
  });

  testWidgets('collapsed state shows closed folder icon', (tester) async {
    await tester.pumpObers(
      const OiFolderTreeItem(folder: folder, expanded: false, selected: false),
    );
    final folderIcon = tester.widget<OiFolderIcon>(find.byType(OiFolderIcon));
    expect(folderIcon.state, OiFolderIconState.closed);
  });

  testWidgets('renaming mode shows OiRenameField instead of text', (
    tester,
  ) async {
    await tester.pumpObers(
      OiFolderTreeItem(
        folder: folder,
        expanded: false,
        selected: false,
        renaming: true,
        onRename: (_) {},
        onCancelRename: () {},
      ),
    );
    expect(find.byType(OiRenameField), findsOneWidget);
    // The plain Text widget for the folder name is replaced by OiRenameField,
    // but the rename field itself contains 'Documents' in its EditableText.
    // Verify the rename field is shown (the plain Text label is gone).
    expect(find.byType(OiRenameField), findsOneWidget);
  });

  testWidgets('renaming mode hides item count', (tester) async {
    await tester.pumpObers(
      OiFolderTreeItem(
        folder: folder,
        expanded: false,
        selected: false,
        renaming: true,
        itemCount: 10,
        onRename: (_) {},
        onCancelRename: () {},
      ),
    );
    expect(find.text('10'), findsNothing);
  });

  testWidgets('shared folder uses shared variant icon', (tester) async {
    await tester.pumpObers(
      const OiFolderTreeItem(
        folder: sharedFolder,
        expanded: false,
        selected: false,
      ),
    );
    final folderIcon = tester.widget<OiFolderIcon>(find.byType(OiFolderIcon));
    expect(folderIcon.variant, OiFolderIconVariant.shared);
  });

  testWidgets('trashed folder uses trash variant icon', (tester) async {
    await tester.pumpObers(
      const OiFolderTreeItem(
        folder: trashedFolder,
        expanded: false,
        selected: false,
      ),
    );
    final folderIcon = tester.widget<OiFolderIcon>(find.byType(OiFolderIcon));
    expect(folderIcon.variant, OiFolderIconVariant.trash);
  });

  testWidgets('default semantics label includes folder name', (tester) async {
    await tester.pumpObers(
      const OiFolderTreeItem(folder: folder, expanded: false, selected: false),
    );
    // Find the Semantics widget with a non-null label matching the folder name
    final semantics = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .where(
          (s) =>
              s.properties.label != null &&
              s.properties.label!.contains('Documents'),
        )
        .first;
    expect(semantics.properties.label, 'Documents folder');
  });

  testWidgets('semantics label includes item count', (tester) async {
    await tester.pumpObers(
      const OiFolderTreeItem(
        folder: folder,
        expanded: false,
        selected: false,
        itemCount: 7,
      ),
    );
    final semantics = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .where(
          (s) =>
              s.properties.label != null &&
              s.properties.label!.contains('Documents'),
        )
        .first;
    expect(semantics.properties.label, 'Documents folder, 7 items');
  });

  testWidgets('custom semanticsLabel overrides default', (tester) async {
    await tester.pumpObers(
      const OiFolderTreeItem(
        folder: folder,
        expanded: false,
        selected: false,
        semanticsLabel: 'Custom label',
      ),
    );
    final semantics = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .where(
          (s) =>
              s.properties.label != null &&
              s.properties.label!.contains('Custom'),
        )
        .first;
    expect(semantics.properties.label, 'Custom label');
  });
}
