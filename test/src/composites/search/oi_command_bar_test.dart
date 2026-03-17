// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/search/oi_command_bar.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const _commands = [
  OiCommand(
    id: 'open',
    label: 'Open File',
    description: 'Open a file from the workspace',
    icon: IconData(0xe873, fontFamily: 'MaterialIcons'),
    category: 'File',
    shortcut: SingleActivator(LogicalKeyboardKey.keyO, control: true),
    keywords: ['open', 'file', 'browse'],
    priority: 10,
  ),
  OiCommand(
    id: 'save',
    label: 'Save',
    description: 'Save the current file',
    icon: IconData(0xe161, fontFamily: 'MaterialIcons'),
    category: 'File',
    shortcut: SingleActivator(LogicalKeyboardKey.keyS, control: true),
    priority: 9,
  ),
  OiCommand(
    id: 'toggle-terminal',
    label: 'Toggle Terminal',
    category: 'View',
    icon: IconData(0xe8b8, fontFamily: 'MaterialIcons'),
    priority: 5,
  ),
  OiCommand(
    id: 'format',
    label: 'Format Document',
    category: 'Edit',
    keywords: ['prettier', 'beautify'],
  ),
  OiCommand(
    id: 'parent',
    label: 'Git',
    category: 'Source Control',
    children: [
      OiCommand(
        id: 'git-commit',
        label: 'Commit',
        description: 'Commit staged changes',
      ),
      OiCommand(
        id: 'git-push',
        label: 'Push',
        description: 'Push commits to remote',
      ),
    ],
  ),
];

Widget _commandBar({
  List<OiCommand>? commands,
  VoidCallback? onDismiss,
  bool showRecent = true,
  bool fuzzySearch = true,
  Widget Function(OiCommand)? previewBuilder,
}) {
  return SizedBox(
    width: 600,
    height: 500,
    child: OiCommandBar(
      label: 'Command Palette',
      commands: commands ?? _commands,
      onDismiss: onDismiss,
      showRecent: showRecent,
      fuzzySearch: fuzzySearch,
      previewBuilder: previewBuilder,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  testWidgets('renders without error', (tester) async {
    await tester.pumpObers(_commandBar());
    expect(find.byType(OiCommandBar), findsOneWidget);
  });

  testWidgets('commands render in list', (tester) async {
    await tester.pumpObers(_commandBar());
    // Commands should be visible.
    expect(find.text('Open File'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Toggle Terminal'), findsOneWidget);
  });

  testWidgets('search input renders', (tester) async {
    await tester.pumpObers(_commandBar());
    expect(find.byType(EditableText), findsWidgets);
  });

  testWidgets('typing filters commands', (tester) async {
    await tester.pumpObers(_commandBar());

    final editableTexts = find.byType(EditableText);
    await tester.enterText(editableTexts.first, 'save');
    await tester.pump();

    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Toggle Terminal'), findsNothing);
  });

  testWidgets('fuzzy search matches keywords', (tester) async {
    await tester.pumpObers(_commandBar());

    final editableTexts = find.byType(EditableText);
    await tester.enterText(editableTexts.first, 'prettier');
    await tester.pump();

    expect(find.text('Format Document'), findsOneWidget);
  });

  testWidgets('category headers show', (tester) async {
    await tester.pumpObers(_commandBar());

    // Category headers should be present.
    expect(find.text('File'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
  });

  testWidgets('enter executes highlighted command', (tester) async {
    var executed = false;
    final cmds = [
      OiCommand(
        id: 'test',
        label: 'Test Command',
        onExecute: () => executed = true,
      ),
    ];

    await tester.pumpObers(_commandBar(commands: cmds));

    // Press enter to execute the first (and only) command.
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(executed, isTrue);
  });

  testWidgets('arrow keys navigate commands', (tester) async {
    var executedId = '';
    final cmds = [
      OiCommand(
        id: 'a',
        label: 'Alpha',
        onExecute: () => executedId = 'a',
      ),
      OiCommand(
        id: 'b',
        label: 'Beta',
        onExecute: () => executedId = 'b',
      ),
      OiCommand(
        id: 'c',
        label: 'Gamma',
        onExecute: () => executedId = 'c',
      ),
    ];

    await tester.pumpObers(_commandBar(commands: cmds));

    // Initially highlighted at index 0 (Alpha).
    // Move down twice to highlight Gamma (index 2).
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    // Press enter.
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(executedId, equals('c'));
  });

  testWidgets('escape calls onDismiss', (tester) async {
    var dismissed = false;
    await tester.pumpObers(
      _commandBar(onDismiss: () => dismissed = true),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(dismissed, isTrue);
  });

  testWidgets('nested commands drill down', (tester) async {
    await tester.pumpObers(_commandBar());

    // Type 'git' to find the parent command.
    final editableTexts = find.byType(EditableText);
    await tester.enterText(editableTexts.first, 'git');
    await tester.pump();

    expect(find.text('Git'), findsOneWidget);

    // Press enter to drill into children.
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    // Should now see child commands.
    expect(find.text('Commit'), findsOneWidget);
    expect(find.text('Push'), findsOneWidget);

    // The parent label should appear as a breadcrumb.
    expect(find.text('Git'), findsOneWidget);
  });

  testWidgets('escape from nested goes back to parent', (tester) async {
    await tester.pumpObers(_commandBar());

    // Filter to Git and drill in.
    final editableTexts = find.byType(EditableText);
    await tester.enterText(editableTexts.first, 'git');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    // Now in sub-menu.
    expect(find.text('Commit'), findsOneWidget);

    // Press Escape to go back.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    // Should be back at top-level commands.
    expect(find.text('Open File'), findsOneWidget);
  });

  testWidgets('shortcut text shows for commands with shortcuts',
      (tester) async {
    await tester.pumpObers(_commandBar());

    // The shortcut for 'Open File' is Ctrl+O.
    expect(find.textContaining('Ctrl'), findsWidgets);
  });

  testWidgets('no commands shows "No commands found"', (tester) async {
    await tester.pumpObers(_commandBar());

    final editableTexts = find.byType(EditableText);
    await tester.enterText(editableTexts.first, 'zzzzzzz');
    await tester.pump();

    expect(find.text('No commands found'), findsOneWidget);
  });

  testWidgets('semantics include label', (tester) async {
    await tester.pumpObers(_commandBar());

    // Find the Semantics node with the command bar label.
    final semanticsWidgets =
        tester.widgetList<Semantics>(find.byType(Semantics));
    final matching = semanticsWidgets
        .where((s) =>
            s.properties.label != null &&
            s.properties.label!.contains('Command Palette'))
        .toList();
    expect(matching, hasLength(1));
  });

  testWidgets('preview builder renders for highlighted command',
      (tester) async {
    await tester.pumpObers(
      _commandBar(
        previewBuilder: (cmd) => Text('Preview: ${cmd.label}'),
      ),
    );

    // The first command is highlighted by default.
    expect(find.textContaining('Preview:'), findsOneWidget);
  });

  testWidgets('command tap executes', (tester) async {
    var executed = false;
    final cmds = [
      OiCommand(
        id: 'tap-test',
        label: 'Tap Me',
        onExecute: () => executed = true,
      ),
    ];

    await tester.pumpObers(_commandBar(commands: cmds));

    await tester.tap(find.text('Tap Me'));
    await tester.pump();

    expect(executed, isTrue);
  });

  testWidgets('description is shown for commands', (tester) async {
    await tester.pumpObers(_commandBar());

    expect(find.text('Open a file from the workspace'), findsOneWidget);
  });

  testWidgets('arrow up at top stays at top', (tester) async {
    var executedId = '';
    final cmds = [
      OiCommand(
        id: 'a',
        label: 'Alpha',
        onExecute: () => executedId = 'a',
      ),
      OiCommand(
        id: 'b',
        label: 'Beta',
        onExecute: () => executedId = 'b',
      ),
    ];

    await tester.pumpObers(_commandBar(commands: cmds));

    // Press up (already at top, should stay at 0).
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();

    // Press enter — should still execute Alpha.
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(executedId, equals('a'));
  });

  testWidgets('substring search works when fuzzy disabled', (tester) async {
    await tester.pumpObers(
      _commandBar(fuzzySearch: false),
    );

    final editableTexts = find.byType(EditableText);
    await tester.enterText(editableTexts.first, 'Terminal');
    await tester.pump();

    expect(find.text('Toggle Terminal'), findsOneWidget);
    expect(find.text('Save'), findsNothing);
  });
}
