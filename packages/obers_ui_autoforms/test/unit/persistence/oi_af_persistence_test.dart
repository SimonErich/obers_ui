import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════════════
  //  OiAfDraftPayload
  // ═══════════════════════════════════════════════════════════════════════

  group('OiAfDraftPayload', () {
    test('toJson produces expected map', () {
      final now = DateTime(2026, 3, 28, 12);
      final payload = OiAfDraftPayload(
        formId: 'signup',
        key: 'user-123',
        data: const {'name': 'John', 'email': 'john@example.com'},
        savedAt: now,
      );

      final json = payload.toJson();

      expect(json['formId'], 'signup');
      expect(json['key'], 'user-123');
      expect(json['data'], {'name': 'John', 'email': 'john@example.com'});
      expect(json['savedAt'], now.toIso8601String());
    });

    test('fromJson roundtrips correctly', () {
      final original = OiAfDraftPayload(
        formId: 'signup',
        key: 'user-123',
        data: const {'name': 'John'},
        savedAt: DateTime(2026, 3, 28, 12),
      );

      final restored = OiAfDraftPayload.fromJson(original.toJson());

      expect(restored.formId, original.formId);
      expect(restored.key, original.key);
      expect(restored.data, original.data);
      expect(restored.savedAt, original.savedAt);
    });

    test('toJson omits null key and savedAt', () {
      const payload = OiAfDraftPayload(
        formId: 'signup',
        data: {'name': 'John'},
      );

      final json = payload.toJson();

      expect(json.containsKey('key'), isFalse);
      expect(json.containsKey('savedAt'), isFalse);
    });

    test('equality based on formId and key', () {
      const a = OiAfDraftPayload(
        formId: 'signup',
        key: 'user-1',
        data: {'name': 'A'},
      );
      const b = OiAfDraftPayload(
        formId: 'signup',
        key: 'user-1',
        data: {'name': 'B'},
      );
      const c = OiAfDraftPayload(
        formId: 'signup',
        key: 'user-2',
        data: {'name': 'A'},
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  //  OiAfPersistenceDriver — contract test
  // ═══════════════════════════════════════════════════════════════════════

  group('OiAfPersistenceDriver', () {
    test('in-memory driver roundtrips save/load/delete', () async {
      final driver = _InMemoryDriver();

      // Initially no draft.
      final loaded = await driver.loadDraft(formId: 'test');
      expect(loaded, isNull);

      // Save a draft.
      await driver.saveDraft(
        formId: 'test',
        json: {
          'data': {'name': 'John'},
        },
      );

      // Load it back.
      final restored = await driver.loadDraft(formId: 'test');
      expect(restored, isNotNull);
      expect(restored!['data'], {'name': 'John'});

      // Delete it.
      await driver.deleteDraft(formId: 'test');
      final afterDelete = await driver.loadDraft(formId: 'test');
      expect(afterDelete, isNull);
    });

    test('key differentiates drafts with same formId', () async {
      final driver = _InMemoryDriver();

      await driver.saveDraft(formId: 'form', key: 'a', json: {'v': 1});
      await driver.saveDraft(formId: 'form', key: 'b', json: {'v': 2});

      final a = await driver.loadDraft(formId: 'form', key: 'a');
      final b = await driver.loadDraft(formId: 'form', key: 'b');

      expect(a!['v'], 1);
      expect(b!['v'], 2);
    });
  });
}

/// Simple in-memory persistence driver for testing.
class _InMemoryDriver extends OiAfPersistenceDriver {
  final Map<String, Map<String, dynamic>> _store = {};

  String _storageKey(String formId, String? key) =>
      key != null ? '$formId::$key' : formId;

  @override
  Future<Map<String, dynamic>?> loadDraft({
    required String formId,
    String? key,
  }) async {
    return _store[_storageKey(formId, key)];
  }

  @override
  Future<void> saveDraft({
    required String formId,
    required Map<String, dynamic> json,
    String? key,
  }) async {
    _store[_storageKey(formId, key)] = json;
  }

  @override
  Future<void> deleteDraft({required String formId, String? key}) async {
    _store.remove(_storageKey(formId, key));
  }
}
