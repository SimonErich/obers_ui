// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/search/oi_command_bar.dart';

import '../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

List<OiCommand> _commands({
  VoidCallback? onOpen,
  VoidCallback? onSave,
  VoidCallback? onFormat,
}) =>
    [
      OiCommand(
        id: 'open',
        label: 'Open File',
        description: 'Open a file from the workspace',
        category: 'File',
        shortcut:
            const SingleActivator(LogicalKeyboardKey.keyO, control: true),
        keywords: const ['open', 'file', 'browse'],
        priority: 10,
        onExecute: onOpen,
      ),
      OiCommand(
        id: 'save',
        label: 'Save',
        description: 'Save the current file',
        category: 'File',
        priority: 9,
        onExecute: onSave,
      ),
      const OiCommand(
        id: 'toggle-terminal',
        label: 'Toggle Terminal',
        category: 'View',
        priority: 5,
      ),
      OiCommand(
        id: 'format',
        label: 'Format Document',
        category: 'Edit',
        keywords: const ['prettier', 'beautify'],
        onExecute: onFormat,
      ),
      const OiCommand(
        id: 'git',
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
  bool fuzzySearch = true,
}) {
  return SizedBox(
    width: 600,
    height: 500,
    child: OiCommandBar(
      label: 'Command Palette',
      commands: commands ?? _commands(),
      onDismiss: onDismiss,
      fuzzySearch: fuzzySearch,
    ),
  );
}

// ── Integration tests ─────────────────────────────────────────────────────────

void main() {
  group('Command bar search → execute flow', () {
    testWidgets('all commands render initially', (tester) async {
      await tester.pumpObers(
        _commandBar(),
        surfaceSize: const Size(700, 600),
      );

      expect(find.text('Open File'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Toggle Terminal'), findsOneWidget);
      expect(find.text('Format Document'), findsOneWidget);
    });

    testWidgets('type query to filter commands', (tester) async {
      await tester.pumpObers(
        _commandBar(),
        surfaceSize: const Size(700, 600),
      );

      final input = find.byType(EditableText);
      await tester.enterText(input.first, 'save');
      await tester.pump();

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Toggle Terminal'), findsNothing);
      expect(find.text('Open File'), findsNothing);
    });

    testWidgets('fuzzy search matches keywords', (tester) async {
      await tester.pumpObers(
        _commandBar(),
        surfaceSize: const Size(700, 600),
      );

      final input = find.byType(EditableText);
      await tester.enterText(input.first, 'prettier');
      await tester.pump();

      expect(find.text('Format Document'), findsOneWidget);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('clear search restores all commands', (tester) async {
      await tester.pumpObers(
        _commandBar(),
        surfaceSize: const Size(700, 600),
      );

      final input = find.byType(EditableText);

      // Filter down.
      await tester.enterText(input.first, 'save');
      await tester.pump();
      expect(find.text('Toggle Terminal'), findsNothing);

      // Clear search.
      await tester.enterText(input.first, '');
      await tester.pump();

      expect(find.text('Open File'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Toggle Terminal'), findsOneWidget);
    });

    testWidgets('enter executes the highlighted command', (tester) async {
      var executed = false;
      final cmds = [
        OiCommand(
          id: 'action',
          label: 'Do Thing',
          onExecute: () => executed = true,
        ),
      ];

      await tester.pumpObers(
        _commandBar(commands: cmds),
        surfaceSize: const Size(700, 600),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(executed, isTrue);
    });

    testWidgets('arrow keys navigate then enter executes', (tester) async {
      var executedId = '';
      final cmds = [
        OiCommand(
          id: 'first',
          label: 'First',
          onExecute: () => executedId = 'first',
        ),
        OiCommand(
          id: 'second',
          label: 'Second',
          onExecute: () => executedId = 'second',
        ),
        OiCommand(
          id: 'third',
          label: 'Third',
          onExecute: () => executedId = 'third',
        ),
      ];

      await tester.pumpObers(
        _commandBar(commands: cmds),
        surfaceSize: const Size(700, 600),
      );

      // Move down to "Second".
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Execute.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(executedId, 'second');
    });

    testWidgets('search then execute filtered result', (tester) async {
      var saveExecuted = false;

      await tester.pumpObers(
        _commandBar(
          commands: _commands(onSave: () => saveExecuted = true),
        ),
        surfaceSize: const Size(700, 600),
      );

      // Type to filter to just "Save".
      final input = find.byType(EditableText);
      await tester.enterText(input.first, 'save');
      await tester.pump();

      // Press enter to execute the filtered (and highlighted) command.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(saveExecuted, isTrue);
    });

    testWidgets('escape dismisses the command bar', (tester) async {
      var dismissed = false;

      await tester.pumpObers(
        _commandBar(onDismiss: () => dismissed = true),
        surfaceSize: const Size(700, 600),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('drill into nested commands', (tester) async {
      await tester.pumpObers(
        _commandBar(),
        surfaceSize: const Size(700, 600),
      );

      // Search for the parent "Git" command.
      final input = find.byType(EditableText);
      await tester.enterText(input.first, 'git');
      await tester.pump();

      expect(find.text('Git'), findsOneWidget);

      // Press enter to drill into children.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      // Child commands should now be visible.
      expect(find.text('Commit'), findsOneWidget);
      expect(find.text('Push'), findsOneWidget);
    });
  });
}
