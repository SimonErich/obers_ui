// Tests do not require documentation comments.

import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/input/oi_raw_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Helper ─────────────────────────────────────────────────────────────────

  Widget buildInput({
    TextEditingController? controller,
    FocusNode? focusNode,
    String? placeholder,
    Widget? leading,
    Widget? trailing,
    int? maxLines = 1,
    bool enabled = true,
    bool obscureText = false,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) {
    return OiRawInput(
      controller: controller ?? TextEditingController(),
      focusNode: focusNode ?? FocusNode(),
      placeholder: placeholder,
      leading: leading,
      trailing: trailing,
      maxLines: maxLines,
      enabled: enabled,
      obscureText: obscureText,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }

  // ── Renders EditableText ───────────────────────────────────────────────────

  testWidgets('renders EditableText', (tester) async {
    await tester.pumpObers(buildInput());
    expect(find.byType(EditableText), findsOneWidget);
  });

  testWidgets(
    'enabled input exposes editable web semantics and accessible focus',
    (tester) async {
      final handle = tester.ensureSemantics();
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpObers(buildInput(focusNode: focus));
      final node = tester.getSemantics(find.byType(EditableText));
      expect(node.flagsCollection.isEnabled, Tristate.isTrue);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      node.owner!.performAction(
        node.id,
        SemanticsAction.tap,
      );
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      handle.dispose();
    },
  );

  // ── Placeholder ────────────────────────────────────────────────────────────

  testWidgets('placeholder visible when controller text is empty', (
    tester,
  ) async {
    await tester.pumpObers(buildInput(placeholder: 'Enter text'));
    expect(find.text('Enter text'), findsOneWidget);
  });

  testWidgets('placeholder hidden when controller has text', (tester) async {
    final controller = TextEditingController(text: 'hello');
    await tester.pumpObers(
      buildInput(controller: controller, placeholder: 'Enter text'),
    );
    expect(find.text('Enter text'), findsNothing);
  });

  testWidgets('placeholder hides after text is entered', (tester) async {
    final controller = TextEditingController();
    await tester.pumpObers(
      buildInput(controller: controller, placeholder: 'Type here'),
    );
    expect(find.text('Type here'), findsOneWidget);

    controller.text = 'a';
    await tester.pump();
    expect(find.text('Type here'), findsNothing);
  });

  testWidgets('no placeholder widget when placeholder is null', (tester) async {
    await tester.pumpObers(buildInput());
    expect(
      find.descendant(
        of: find.byType(OiRawInput),
        matching: find.byType(Stack),
      ),
      findsNothing,
    );
  });

  // ── Leading / trailing ─────────────────────────────────────────────────────

  testWidgets('leading widget renders', (tester) async {
    await tester.pumpObers(
      buildInput(leading: const Text('L', key: Key('leading'))),
    );
    expect(find.byKey(const Key('leading')), findsOneWidget);
  });

  testWidgets('trailing widget renders', (tester) async {
    await tester.pumpObers(
      buildInput(trailing: const Text('R', key: Key('trailing'))),
    );
    expect(find.byKey(const Key('trailing')), findsOneWidget);
  });

  testWidgets('both leading and trailing render inside Row', (tester) async {
    await tester.pumpObers(
      buildInput(
        leading: const Text('L', key: Key('leading')),
        trailing: const Text('R', key: Key('trailing')),
      ),
    );
    expect(find.byType(Row), findsOneWidget);
    expect(find.byKey(const Key('leading')), findsOneWidget);
    expect(find.byKey(const Key('trailing')), findsOneWidget);
  });

  // ── onChanged ─────────────────────────────────────────────────────────────

  testWidgets('onChanged fires when text changes', (tester) async {
    final received = <String>[];
    await tester.pumpObers(buildInput(onChanged: received.add));
    await tester.enterText(find.byType(EditableText), 'hi');
    expect(received, isNotEmpty);
    expect(received.last, 'hi');
  });

  // ── onSubmitted ───────────────────────────────────────────────────────────

  testWidgets('onSubmitted fires on submit action', (tester) async {
    final submitted = <String>[];
    await tester.pumpObers(
      buildInput(onSubmitted: submitted.add, onChanged: (_) {}),
    );
    await tester.enterText(find.byType(EditableText), 'send');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(submitted, contains('send'));
  });

  // ── enabled = false ───────────────────────────────────────────────────────

  testWidgets('enabled=false makes field readOnly', (tester) async {
    final controller = TextEditingController(text: 'initial');
    await tester.pumpObers(buildInput(controller: controller, enabled: false));
    final et = tester.widget<EditableText>(find.byType(EditableText));
    expect(et.readOnly, isTrue);
  });

  testWidgets('disabling releases focus and reenabling permits editing', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'MISSING');
    final focus = FocusNode();
    final enabled = ValueNotifier(true);
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    addTearDown(enabled.dispose);
    await tester.pumpObers(
      ValueListenableBuilder<bool>(
        valueListenable: enabled,
        builder: (context, value, child) => buildInput(
          controller: controller,
          focusNode: focus,
          enabled: value,
        ),
      ),
    );
    focus.requestFocus();
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 7);

    enabled.value = false;
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isFalse);
    focus.requestFocus();
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isFalse);
    expect(controller.text, 'MISSING');
    expect(
      controller.selection,
      const TextSelection(baseOffset: 0, extentOffset: 7),
    );

    focus.canRequestFocus = false;
    enabled.value = true;
    await tester.pumpAndSettle();
    expect(focus.canRequestFocus, isFalse);
    focus.canRequestFocus = true;
    await tester.tap(find.byType(EditableText));
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);
    await tester.enterText(find.byType(EditableText), 'lunch15');
    expect(controller.text, 'lunch15');
  });

  // ── obscureText ───────────────────────────────────────────────────────────

  testWidgets('obscureText passed through to EditableText', (tester) async {
    await tester.pumpObers(buildInput(obscureText: true));
    final et = tester.widget<EditableText>(find.byType(EditableText));
    expect(et.obscureText, isTrue);
  });

  testWidgets('obscureText false by default', (tester) async {
    await tester.pumpObers(buildInput());
    final et = tester.widget<EditableText>(find.byType(EditableText));
    expect(et.obscureText, isFalse);
  });

  // ── maxLines ──────────────────────────────────────────────────────────────

  testWidgets('maxLines passed through to EditableText', (tester) async {
    await tester.pumpObers(buildInput(maxLines: 4));
    final et = tester.widget<EditableText>(find.byType(EditableText));
    expect(et.maxLines, 4);
  });

  testWidgets('maxLines null (unlimited) passed through', (tester) async {
    await tester.pumpObers(buildInput(maxLines: null));
    final et = tester.widget<EditableText>(find.byType(EditableText));
    expect(et.maxLines, isNull);
  });

  // ── reducedMotion ─────────────────────────────────────────────────────────

  testWidgets('ensureVisible uses Duration.zero when reducedMotion', (
    tester,
  ) async {
    final focusNode = FocusNode();
    final scrollController = ScrollController();
    await tester.pumpObers(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: SizedBox(
          height: 200,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                const SizedBox(height: 800),
                buildInput(focusNode: focusNode, placeholder: 'input'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Scroll position starts at 0 — the input is off-screen.
    expect(scrollController.offset, 0.0);

    // Focus the input, which triggers ensureVisible.
    focusNode.requestFocus();
    // One pump to process the focus change, one for the post-frame callback.
    await tester.pump();
    await tester.pump();

    // With Duration.zero, the scroll should have jumped instantly —
    // no animation frames needed. The offset must be non-zero.
    expect(scrollController.offset, greaterThan(0));
    expect(find.byType(EditableText), findsOneWidget);

    scrollController.dispose();
  });
}
