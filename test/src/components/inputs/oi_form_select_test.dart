// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders with label and placeholder', (tester) async {
    await tester.pumpObers(
      OiFormSelect<String>(
        options: const ['Apple', 'Banana', 'Cherry'],
        labelOf: (v) => v,
        label: 'Fruit',
        placeholder: 'Pick a fruit',
      ),
    );

    expect(find.text('Fruit'), findsOneWidget);
    expect(find.text('Pick a fruit'), findsOneWidget);
  });

  testWidgets('shows selected value text', (tester) async {
    await tester.pumpObers(
      OiFormSelect<String>(
        options: const ['Apple', 'Banana', 'Cherry'],
        labelOf: (v) => v,
        value: 'Banana',
      ),
    );

    expect(find.text('Banana'), findsOneWidget);
  });

  testWidgets('validator error displays on form.validate()', (tester) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpObers(
      Form(
        key: formKey,
        child: OiFormSelect<String>(
          options: const ['Apple', 'Banana'],
          labelOf: (v) => v,
          validator: (value) => value == null ? 'Selection required' : null,
        ),
      ),
    );

    formKey.currentState!.validate();
    await tester.pumpAndSettle();

    expect(find.text('Selection required'), findsOneWidget);
  });

  testWidgets('manual error overrides validator', (tester) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpObers(
      Form(
        key: formKey,
        child: OiFormSelect<String>(
          options: const ['Apple', 'Banana'],
          labelOf: (v) => v,
          error: 'Manual error',
          validator: (value) => value == null ? 'Validator error' : null,
        ),
      ),
    );

    // Manual error is shown before validation.
    expect(find.text('Manual error'), findsOneWidget);

    // After validation the manual error still takes precedence.
    formKey.currentState!.validate();
    await tester.pumpAndSettle();

    expect(find.text('Manual error'), findsOneWidget);
    expect(find.text('Validator error'), findsNothing);
  });

  testWidgets('Form.save calls onSaved', (tester) async {
    final formKey = GlobalKey<FormState>();
    String? savedValue;

    await tester.pumpObers(
      Form(
        key: formKey,
        child: OiFormSelect<String>(
          options: const ['Apple', 'Banana'],
          labelOf: (v) => v,
          value: 'Apple',
          validator: (_) => null,
          onSaved: (value) => savedValue = value,
        ),
      ),
    );

    formKey.currentState!.save();
    await tester.pumpAndSettle();

    expect(savedValue, 'Apple');
  });
}
