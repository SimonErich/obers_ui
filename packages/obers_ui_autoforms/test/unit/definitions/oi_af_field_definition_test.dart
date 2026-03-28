import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

// ── Test helpers ────────────────────────────────────────────────────────────

enum _F { a, b }

// ── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // ── OiAfTextFieldDef ────────────────────────────────────────────────────

  group('OiAfTextFieldDef', () {
    test('type is OiAfFieldType.text', () {
      const def = OiAfTextFieldDef<_F>(field: _F.a);
      expect(def.type, OiAfFieldType.text);
    });

    test('field is stored correctly', () {
      const def = OiAfTextFieldDef<_F>(field: _F.b);
      expect(def.field, _F.b);
    });

    test('default values', () {
      const def = OiAfTextFieldDef<_F>(field: _F.a);
      expect(def.required, false);
      expect(def.save, true);
      expect(def.clearErrorsOnChange, true);
      expect(def.validateOnInit, false);
      expect(def.excludeWhenHidden, true);
      expect(def.clearValueWhenHidden, false);
      expect(def.skipValidationWhenDisabled, true);
      expect(def.validateModeOverride, isNull);
      expect(def.initialValue, isNull);
      expect(def.validators, isEmpty);
      expect(def.revalidateWhen, isEmpty);
      expect(def.visibleWhen, isNull);
      expect(def.enabledWhen, isNull);
      expect(def.dependsOn, isEmpty);
      expect(def.deriveMode, OiAfDeriveMode.onChange);
      expect(
        def.derivedOverrideMode,
        OiAfDerivedOverrideMode.stopAfterUserEdit,
      );
      expect(def.derive, isNull);
    });

    test('initialValue can be set', () {
      const def = OiAfTextFieldDef<_F>(field: _F.a, initialValue: 'hello');
      expect(def.initialValue, 'hello');
    });

    test('required can be set to true', () {
      const def = OiAfTextFieldDef<_F>(field: _F.a, required: true);
      expect(def.required, true);
    });
  });

  // ── OiAfNumberFieldDef ──────────────────────────────────────────────────

  group('OiAfNumberFieldDef', () {
    test('type is OiAfFieldType.number', () {
      const def = OiAfNumberFieldDef<_F>(field: _F.a);
      expect(def.type, OiAfFieldType.number);
    });

    test('has min/max/step/decimalPlaces fields', () {
      const def = OiAfNumberFieldDef<_F>(
        field: _F.a,
        min: 0,
        max: 100,
        step: 5,
        decimalPlaces: 2,
      );

      expect(def.min, 0);
      expect(def.max, 100);
      expect(def.step, 5);
      expect(def.decimalPlaces, 2);
    });

    test('default values for number-specific fields', () {
      const def = OiAfNumberFieldDef<_F>(field: _F.a);
      expect(def.min, isNull);
      expect(def.max, isNull);
      expect(def.step, 1);
      expect(def.decimalPlaces, isNull);
    });

    test('inherits base defaults', () {
      const def = OiAfNumberFieldDef<_F>(field: _F.a);
      expect(def.required, false);
      expect(def.save, true);
    });
  });

  // ── OiAfBoolFieldDef ────────────────────────────────────────────────────

  group('OiAfBoolFieldDef', () {
    test('type defaults to OiAfFieldType.checkbox', () {
      const def = OiAfBoolFieldDef<_F>(field: _F.a);
      expect(def.type, OiAfFieldType.checkbox);
    });

    test('type can be set to switcher', () {
      const def = OiAfBoolFieldDef<_F>(
        field: _F.a,
        type: OiAfFieldType.switcher,
      );
      expect(def.type, OiAfFieldType.switcher);
    });

    test('tristate defaults to false', () {
      const def = OiAfBoolFieldDef<_F>(field: _F.a);
      expect(def.tristate, false);
    });

    test('tristate can be enabled', () {
      const def = OiAfBoolFieldDef<_F>(field: _F.a, tristate: true);
      expect(def.tristate, true);
    });

    test('initialValue supports null for tristate', () {
      const def = OiAfBoolFieldDef<_F>(
        field: _F.a,
        tristate: true,
      );
      expect(def.initialValue, isNull);
    });

    test('initialValue can be true or false', () {
      const defTrue = OiAfBoolFieldDef<_F>(field: _F.a, initialValue: true);
      const defFalse = OiAfBoolFieldDef<_F>(field: _F.b, initialValue: false);
      expect(defTrue.initialValue, true);
      expect(defFalse.initialValue, false);
    });
  });

  // ── OiAfSelectFieldDef ──────────────────────────────────────────────────

  group('OiAfSelectFieldDef', () {
    test('type is OiAfFieldType.select', () {
      const def = OiAfSelectFieldDef<_F, String>(field: _F.a);
      expect(def.type, OiAfFieldType.select);
    });

    test('options list defaults to empty', () {
      const def = OiAfSelectFieldDef<_F, String>(field: _F.a);
      expect(def.options, isEmpty);
    });

    test('options can be provided', () {
      const def = OiAfSelectFieldDef<_F, String>(
        field: _F.a,
        options: [
          OiAfOption(value: 'a', label: 'Alpha'),
          OiAfOption(value: 'b', label: 'Beta'),
        ],
      );

      expect(def.options.length, 2);
      expect(def.options[0].value, 'a');
      expect(def.options[0].label, 'Alpha');
      expect(def.options[1].value, 'b');
    });

    test('inherits base defaults', () {
      const def = OiAfSelectFieldDef<_F, int>(field: _F.a);
      expect(def.required, false);
      expect(def.save, true);
      expect(def.initialValue, isNull);
    });
  });

  // ── OiAfFileFieldDef ────────────────────────────────────────────────────

  group('OiAfFileFieldDef', () {
    test('type is OiAfFieldType.file', () {
      const def = OiAfFileFieldDef<_F>(field: _F.a);
      expect(def.type, OiAfFieldType.file);
    });

    test('maxFiles and acceptedTypes default to null', () {
      const def = OiAfFileFieldDef<_F>(field: _F.a);
      expect(def.maxFiles, isNull);
      expect(def.acceptedTypes, isNull);
    });

    test('maxFiles and acceptedTypes can be set', () {
      const def = OiAfFileFieldDef<_F>(
        field: _F.a,
        maxFiles: 5,
        acceptedTypes: ['pdf', 'png', 'jpg'],
      );

      expect(def.maxFiles, 5);
      expect(def.acceptedTypes, ['pdf', 'png', 'jpg']);
    });

    test('value type is List<OiAfFileValue>', () {
      const def = OiAfFileFieldDef<_F>(field: _F.a);
      expect(def, isA<OiAfFieldDefinition<_F, List<OiAfFileValue>>>());
    });
  });

  // ── OiAfSliderFieldDef ──────────────────────────────────────────────────

  group('OiAfSliderFieldDef', () {
    test('type is OiAfFieldType.slider', () {
      const def = OiAfSliderFieldDef<_F>(field: _F.a);
      expect(def.type, OiAfFieldType.slider);
    });

    test('default min/max/divisions/isRange', () {
      const def = OiAfSliderFieldDef<_F>(field: _F.a);
      expect(def.min, 0);
      expect(def.max, 100);
      expect(def.divisions, isNull);
      expect(def.isRange, false);
    });

    test('custom min/max/divisions/isRange', () {
      const def = OiAfSliderFieldDef<_F>(
        field: _F.a,
        min: 10,
        max: 200,
        divisions: 19,
        isRange: true,
      );

      expect(def.min, 10);
      expect(def.max, 200);
      expect(def.divisions, 19);
      expect(def.isRange, true);
    });
  });

  // ── OiAfArrayFieldDef ──────────────────────────────────────────────────

  group('OiAfArrayFieldDef', () {
    test('type is OiAfFieldType.array', () {
      final def = OiAfArrayFieldDef<_F, String>(
        field: _F.a,
        createEmpty: () => '',
      );
      expect(def.type, OiAfFieldType.array);
    });

    test('createEmpty factory works', () {
      final def = OiAfArrayFieldDef<_F, Map<String, String>>(
        field: _F.a,
        createEmpty: () => {'name': '', 'value': ''},
      );

      final item = def.createEmpty();
      expect(item, isA<Map<String, String>>());
      expect(item['name'], '');
    });

    test('minItems and maxItems default to null', () {
      final def = OiAfArrayFieldDef<_F, String>(
        field: _F.a,
        createEmpty: () => '',
      );
      expect(def.minItems, isNull);
      expect(def.maxItems, isNull);
    });

    test('minItems and maxItems can be set', () {
      final def = OiAfArrayFieldDef<_F, String>(
        field: _F.a,
        createEmpty: () => '',
        minItems: 1,
        maxItems: 10,
      );

      expect(def.minItems, 1);
      expect(def.maxItems, 10);
    });

    test('value type is List<TItem>', () {
      final def = OiAfArrayFieldDef<_F, int>(field: _F.a, createEmpty: () => 0);
      expect(def, isA<OiAfFieldDefinition<_F, List<int>>>());
    });
  });

  // ── OiAfDraftPayload ───────────────────────────────────────────────────

  group('OiAfDraftPayload', () {
    test('constructs with required fields', () {
      const payload = OiAfDraftPayload(
        formId: 'user-form',
        data: {'name': 'Alice'},
      );

      expect(payload.formId, 'user-form');
      expect(payload.data, {'name': 'Alice'});
      expect(payload.key, isNull);
      expect(payload.savedAt, isNull);
    });

    test('constructs with all fields', () {
      final now = DateTime(2025, 3, 28, 12);
      final payload = OiAfDraftPayload(
        formId: 'user-form',
        key: 'user-123',
        data: const {'name': 'Bob'},
        savedAt: now,
      );

      expect(payload.formId, 'user-form');
      expect(payload.key, 'user-123');
      expect(payload.data['name'], 'Bob');
      expect(payload.savedAt, now);
    });

    test('fromJson/toJson roundtrip', () {
      final now = DateTime(2025, 3, 28, 12);
      final original = OiAfDraftPayload(
        formId: 'test-form',
        key: 'draft-1',
        data: const {'field1': 'value1', 'field2': 42},
        savedAt: now,
      );

      final json = original.toJson();
      final restored = OiAfDraftPayload.fromJson(json);

      expect(restored.formId, original.formId);
      expect(restored.key, original.key);
      expect(restored.data, original.data);
      expect(restored.savedAt, original.savedAt);
    });

    test('fromJson/toJson roundtrip without optional fields', () {
      const original = OiAfDraftPayload(formId: 'minimal', data: {'x': 1});

      final json = original.toJson();
      final restored = OiAfDraftPayload.fromJson(json);

      expect(restored.formId, 'minimal');
      expect(restored.data, {'x': 1});
      expect(restored.key, isNull);
      expect(restored.savedAt, isNull);
    });

    test('toJson omits null optional fields', () {
      const payload = OiAfDraftPayload(formId: 'f', data: {});

      final json = payload.toJson();
      expect(json.containsKey('key'), false);
      expect(json.containsKey('savedAt'), false);
      expect(json.containsKey('formId'), true);
      expect(json.containsKey('data'), true);
    });

    test('equality is based on formId and key', () {
      const a = OiAfDraftPayload(formId: 'form', key: 'k1', data: {'a': 1});
      const b = OiAfDraftPayload(formId: 'form', key: 'k1', data: {'b': 2});
      const c = OiAfDraftPayload(formId: 'form', key: 'k2', data: {'a': 1});

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('toString contains formId and key', () {
      const payload = OiAfDraftPayload(
        formId: 'my-form',
        key: 'draft-x',
        data: {},
      );

      expect(payload.toString(), contains('my-form'));
      expect(payload.toString(), contains('draft-x'));
    });
  });
}
