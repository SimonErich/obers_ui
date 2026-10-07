import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart' as public;
import 'package:obers_ui/src/components/buttons/oi_button.dart' as direct;

void _action() {}

class _CandidateSubclass extends public.OiButton {
  const _CandidateSubclass({required super.label, super.key}) : super.primary();

  @override
  State<_CandidateSubclass> createState() => _CandidateState();
}

class _CandidateState extends State<_CandidateSubclass> {
  @override
  Widget build(BuildContext context) => SizedBox(
    key: ValueKey(widget.label ?? ''),
    width: widget.size == public.OiButtonSize.medium ? 17 : 29,
  );
}

void main() {
  test(
    'old imports, const constructors, field types and defaults remain valid',
    () {
      const regular = [
        public.OiButton.primary(label: 'Action'),
        public.OiButton.secondary(label: 'Action'),
        public.OiButton.outline(label: 'Action'),
        public.OiButton.ghost(label: 'Action'),
        public.OiButton.destructive(label: 'Action'),
        public.OiButton.soft(label: 'Action'),
      ];
      for (var i = 0; i < regular.length; i++) {
        final button = regular[i];
        final label = button.label;
        final icon = button.icon;
        final dropdown = button.dropdown;
        final onConfirm = button.onConfirm;
        expect(label, 'Action');
        expect(icon, isNull);
        expect(dropdown, isNull);
        expect(onConfirm, isNull);
        expect(button.variant, public.OiButtonVariant.values[i]);
        expect(button.size, public.OiButtonSize.medium);
        expect(button.iconPosition, public.OiIconPosition.leading);
        expect(button.enabled, isTrue);
        expect(button.loading, isFalse);
        expect(button.fullWidth, isFalse);
        expect(button.tooltip, isNull);
        expect(button.borderRadius, isNull);
      }
      const icon = public.OiButton.icon(
        icon: public.OiIcons.plus,
        label: 'Add',
      );
      const split = public.OiButton.split(
        label: 'Split',
        onTap: _action,
        dropdown: SizedBox(),
      );
      const countdown = public.OiButton.countdown(
        label: 'Wait',
        onTap: _action,
        seconds: 2,
      );
      const confirm = public.OiButton.confirm(
        label: 'Delete',
        confirmLabel: 'Really?',
        onConfirm: _action,
      );
      expect(icon.label, isNull);
      expect(icon.semanticLabel, 'Add');
      expect(icon.variant, public.OiButtonVariant.ghost);
      expect(split.dropdown, isA<SizedBox>());
      expect(countdown.countdownSeconds, 2);
      expect(confirm.confirmLabel, 'Really?');
      expect(confirm.variant, public.OiButtonVariant.destructive);
      expect(confirm.onConfirm, _action);
      expect(
        identical(public.OiButtonSize.medium, direct.OiButtonSize.medium),
        isTrue,
      );
      expect(
        'Inherited',
        const _CandidateSubclass(
          label: 'Inherited',
          key: ValueKey('subclass'),
        ).label,
      );
      const overridden = public.OiButton.primary(
        label: 'Override',
        size: public.OiButtonSize.large,
        enabled: false,
        loading: true,
        fullWidth: true,
        icon: public.OiIcons.plus,
        iconPosition: public.OiIconPosition.trailing,
        semanticLabel: 'Accessible',
        tooltip: 'Tip',
        key: ValueKey('legacy'),
      );
      expect(overridden.size, public.OiButtonSize.large);
      expect(overridden.enabled, isFalse);
      expect(overridden.loading, isTrue);
      expect(overridden.fullWidth, isTrue);
      expect(overridden.iconPosition, public.OiIconPosition.trailing);
      expect(overridden.semanticLabel, 'Accessible');
      expect(overridden.tooltip, 'Tip');
      expect(overridden.key, const ValueKey('legacy'));
    },
  );

  testWidgets(
    'existing subclass super constructor and custom state build work',
    (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: _CandidateSubclass(label: 'Inherited'),
        ),
      );
      expect(find.byKey(const ValueKey('Inherited')), findsOneWidget);
      expect(
        tester.widget<SizedBox>(find.byKey(const ValueKey('Inherited'))).width,
        17,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
