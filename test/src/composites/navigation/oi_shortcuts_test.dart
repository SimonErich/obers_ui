// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/navigation/oi_shortcuts.dart';

import '../../../helpers/pump_app.dart';

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('OiShortcutActivator', () {
    test('primary uses Ctrl on Linux', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final activator = OiShortcutActivator.primary(LogicalKeyboardKey.keyZ);
      expect(activator.control, isTrue);
      expect(activator.meta, isFalse);
    });

    test('primary uses Meta (Cmd) on macOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final activator = OiShortcutActivator.primary(LogicalKeyboardKey.keyZ);
      expect(activator.control, isFalse);
      expect(activator.meta, isTrue);
    });

    test('primary passes shift and alt through', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final activator = OiShortcutActivator.primary(
        LogicalKeyboardKey.keyZ,
        shift: true,
        alt: true,
      );
      expect(activator.shift, isTrue);
      expect(activator.alt, isTrue);
    });

    test('displayLabel shows Ctrl+Z on Linux', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final activator = OiShortcutActivator.primary(LogicalKeyboardKey.keyZ);
      expect(activator.displayLabel, 'Ctrl+Z');
    });

    test('displayLabel shows Cmd+Z on macOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final activator = OiShortcutActivator.primary(LogicalKeyboardKey.keyZ);
      expect(activator.displayLabel, 'Cmd+Z');
    });

    test('displayLabel includes Shift when present', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final activator = OiShortcutActivator.primary(
        LogicalKeyboardKey.keyZ,
        shift: true,
      );
      expect(activator.displayLabel, 'Ctrl+Shift+Z');
    });

    test('displayLabel includes Alt on Linux', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final activator = OiShortcutActivator.primary(
        LogicalKeyboardKey.keyZ,
        alt: true,
      );
      expect(activator.displayLabel, 'Ctrl+Alt+Z');
    });

    test('displayLabel shows Opt on macOS for alt', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final activator = OiShortcutActivator.primary(
        LogicalKeyboardKey.keyZ,
        alt: true,
      );
      expect(activator.displayLabel, 'Cmd+Opt+Z');
    });
  });

  group('OiShortcuts', () {
    testWidgets('shortcut fires callback when key combination pressed', (
      tester,
    ) async {
      var fired = false;
      await tester.pumpObers(
        OiShortcuts(
          shortcuts: [
            OiShortcutBinding(
              activator: const OiShortcutActivator(
                LogicalKeyboardKey.keyS,
                control: true,
              ),
              label: 'Save',
              onInvoke: () => fired = true,
            ),
          ],
          child: const SizedBox.square(dimension: 100),
        ),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(fired, isTrue);
    });

    testWidgets('multiple shortcuts can coexist', (tester) async {
      var saveFired = false;
      var undoFired = false;

      await tester.pumpObers(
        OiShortcuts(
          shortcuts: [
            OiShortcutBinding(
              activator: const OiShortcutActivator(
                LogicalKeyboardKey.keyS,
                control: true,
              ),
              label: 'Save',
              onInvoke: () => saveFired = true,
            ),
            OiShortcutBinding(
              activator: const OiShortcutActivator(
                LogicalKeyboardKey.keyZ,
                control: true,
              ),
              label: 'Undo',
              onInvoke: () => undoFired = true,
            ),
          ],
          child: const SizedBox.square(dimension: 100),
        ),
      );

      // Fire save.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(saveFired, isTrue);
      expect(undoFired, isFalse);

      // Fire undo.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(undoFired, isTrue);
    });

    testWidgets('help dialog opens on "?" key', (tester) async {
      await tester.pumpObers(
        OiShortcuts(
          shortcuts: [
            OiShortcutBinding(
              activator: const OiShortcutActivator(
                LogicalKeyboardKey.keyS,
                control: true,
              ),
              label: 'Save',
              category: 'File',
              onInvoke: () {},
            ),
          ],
          child: const SizedBox.square(dimension: 100),
        ),
      );

      // "?" is Shift + Slash.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();

      expect(find.text('Keyboard Shortcuts'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('File'), findsOneWidget);
    });

    testWidgets('shortcuts listed in help dialog with categories', (
      tester,
    ) async {
      await tester.pumpObers(
        OiShortcuts(
          shortcuts: [
            OiShortcutBinding(
              activator: const OiShortcutActivator(
                LogicalKeyboardKey.keyS,
                control: true,
              ),
              label: 'Save',
              category: 'File',
              onInvoke: () {},
            ),
            OiShortcutBinding(
              activator: const OiShortcutActivator(
                LogicalKeyboardKey.keyZ,
                control: true,
              ),
              label: 'Undo',
              category: 'Edit',
              onInvoke: () {},
            ),
            OiShortcutBinding(
              activator: const OiShortcutActivator(
                LogicalKeyboardKey.keyC,
                control: true,
              ),
              label: 'Copy',
              category: 'Edit',
              onInvoke: () {},
            ),
          ],
          child: const SizedBox.square(dimension: 100),
        ),
      );

      // Open help.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();

      expect(find.text('File'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('uncategorized shortcuts appear under General', (tester) async {
      await tester.pumpObers(
        OiShortcuts(
          shortcuts: [
            OiShortcutBinding(
              activator: const OiShortcutActivator(
                LogicalKeyboardKey.keyS,
                control: true,
              ),
              label: 'Save',
              onInvoke: () {},
            ),
          ],
          child: const SizedBox.square(dimension: 100),
        ),
      );

      // Open help.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();

      expect(find.text('General'), findsOneWidget);
    });

    testWidgets('showHelpOnQuestionMark=false disables help', (tester) async {
      await tester.pumpObers(
        OiShortcuts(
          showHelpOnQuestionMark: false,
          shortcuts: [
            OiShortcutBinding(
              activator: const OiShortcutActivator(
                LogicalKeyboardKey.keyS,
                control: true,
              ),
              label: 'Save',
              onInvoke: () {},
            ),
          ],
          child: const SizedBox.square(dimension: 100),
        ),
      );

      // "?" should not open help.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();

      expect(find.text('Keyboard Shortcuts'), findsNothing);
    });

    testWidgets('help dialog can be dismissed by tapping Close', (
      tester,
    ) async {
      await tester.pumpObers(
        OiShortcuts(
          shortcuts: [
            OiShortcutBinding(
              activator: const OiShortcutActivator(
                LogicalKeyboardKey.keyS,
                control: true,
              ),
              label: 'Save',
              onInvoke: () {},
            ),
          ],
          child: const SizedBox.square(dimension: 100),
        ),
      );

      // Open help.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(find.text('Keyboard Shortcuts'), findsOneWidget);

      // Tap the Close text to dismiss.
      await tester.tap(find.text('Close'));
      await tester.pump();
      expect(find.text('Keyboard Shortcuts'), findsNothing);
    });
  });

  group('OiShortcutBinding', () {
    test('stores all provided fields', () {
      final binding = OiShortcutBinding(
        activator: const OiShortcutActivator(
          LogicalKeyboardKey.keyS,
          control: true,
        ),
        label: 'Save',
        description: 'Save the current document',
        category: 'File',
        onInvoke: () {},
      );

      expect(binding.label, 'Save');
      expect(binding.description, 'Save the current document');
      expect(binding.category, 'File');
    });

    test('description and category default to null', () {
      final binding = OiShortcutBinding(
        activator: const OiShortcutActivator(
          LogicalKeyboardKey.keyS,
          control: true,
        ),
        label: 'Save',
        onInvoke: () {},
      );

      expect(binding.description, isNull);
      expect(binding.category, isNull);
    });
  });
}
