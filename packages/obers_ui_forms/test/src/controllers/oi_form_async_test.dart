import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_forms/obers_ui_forms.dart';

enum AsyncFields { email, username }

class AsyncFormController extends OiFormController<AsyncFields> {
  AsyncFormController({this.asyncDelay = Duration.zero});

  final Duration asyncDelay;

  @override
  Map<AsyncFields, OiFormInputController<dynamic>> inputs() => {
    AsyncFields.email: OiFormInputController<String>(
      validation: [
        OiFormValidation.asyncCustom<String>(
          (value, _) async {
            await Future<void>.delayed(asyncDelay);
            if (value == 'taken@example.com') return 'Email already taken';
            return null;
          },
          debounce: Duration.zero, // No debounce in tests
        ),
      ],
    ),
    AsyncFields.username: OiFormInputController<String>(),
  };
}

void main() {
  group('Async validation', () {
    test('async validator resolves and updates field error', () async {
      final controller = AsyncFormController();

      controller.set<String>(AsyncFields.email, 'taken@example.com');
      await controller.validateAsync();

      expect(controller.getError(AsyncFields.email), isNotEmpty);
      expect(
        controller.getError(AsyncFields.email).first,
        'Email already taken',
      );

      controller.dispose();
    });

    test('async validator passes for valid value', () async {
      final controller = AsyncFormController();

      controller.set<String>(AsyncFields.email, 'valid@example.com');
      await controller.validateAsync();

      expect(controller.getError(AsyncFields.email), isEmpty);

      controller.dispose();
    });

    test('isValidating true during async run, false after', () async {
      final controller = AsyncFormController(
        asyncDelay: const Duration(milliseconds: 50),
      );

      controller.set<String>(AsyncFields.email, 'test@example.com');

      final field = controller.getInputController(AsyncFields.email);
      // Start async validation (don't await)
      final future = field.validateAsync(controller);
      expect(field.isValidating, isTrue);

      await future;
      expect(field.isValidating, isFalse);

      controller.dispose();
    });

    test('rapid value changes cancel previous async validation', () async {
      final controller = AsyncFormController(
        asyncDelay: const Duration(milliseconds: 50),
      );

      final field = controller.getInputController(AsyncFields.email);

      // Start first validation
      controller.set<String>(AsyncFields.email, 'taken@example.com');
      // ignore: unawaited_futures
      field.validateAsync(controller);

      // Immediately change value, cancelling previous
      controller.set<String>(AsyncFields.email, 'valid@example.com');
      await field.validateAsync(controller);

      // Only the latest result should apply (valid email)
      expect(field.errors, isEmpty);

      controller.dispose();
    });

    test('async validator throws → caught, generic error', () async {
      final controller = _ThrowingAsyncController();

      controller.set<String>(AsyncFields.email, 'any@value.com');
      final field = controller.getInputController(AsyncFields.email);
      await field.validateAsync(controller);

      expect(field.errors, contains('Validation error'));

      controller.dispose();
    });

    test('submit waits for async validation then proceeds', () async {
      final controller = AsyncFormController();
      var submitted = false;

      controller.set<String>(AsyncFields.email, 'valid@example.com');
      await controller.submit((data, ctrl) => submitted = true);

      expect(submitted, isTrue);

      controller.dispose();
    });

    test('submit does not call onSubmit when invalid', () async {
      final controller = AsyncFormController();
      var submitted = false;

      controller.set<String>(AsyncFields.email, 'taken@example.com');
      await controller.submit((data, ctrl) => submitted = true);

      expect(submitted, isFalse);

      controller.dispose();
    });
  });

  group('Debounce', () {
    test('debounce delays async validation', () async {
      final controller = _DebouncedController();

      final field = controller.getInputController(AsyncFields.email);
      controller.set<String>(AsyncFields.email, 'test@example.com');

      // Start async validation with debounce
      final future = field.validateAsync(controller);

      // Should not be validating yet (debounced)
      expect(field.isValidating, isFalse);

      // Wait for debounce + validation
      await future;
      expect(field.isValidating, isFalse);

      controller.dispose();
    });
  });
}

class _ThrowingAsyncController extends OiFormController<AsyncFields> {
  @override
  Map<AsyncFields, OiFormInputController<dynamic>> inputs() => {
    AsyncFields.email: OiFormInputController<String>(
      validation: [
        OiFormValidation.asyncCustom<String>(
          (_, _) async => throw Exception('Network error'),
          debounce: Duration.zero,
        ),
      ],
    ),
    AsyncFields.username: OiFormInputController<String>(),
  };
}

class _DebouncedController extends OiFormController<AsyncFields> {
  @override
  Map<AsyncFields, OiFormInputController<dynamic>> inputs() => {
    AsyncFields.email: OiFormInputController<String>(
      validation: [
        OiFormValidation.asyncCustom<String>(
          (_, _) async => null,
          debounce: const Duration(milliseconds: 10),
        ),
      ],
    ),
    AsyncFields.username: OiFormInputController<String>(),
  };
}
