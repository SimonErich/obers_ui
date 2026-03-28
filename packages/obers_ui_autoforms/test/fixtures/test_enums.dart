import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

/// Shared test field enum used across test files.
enum TestField {
  name,
  email,
  password,
  confirmPassword,
  age,
  agree,
  country,
  fullName,
  notes,
  tags,
}

/// A mock [OiAfReader] for unit testing validators and tracking reader.
class MockReader implements OiAfReader<TestField> {
  MockReader([this._values = const {}]);

  final Map<TestField, Object?> _values;

  @override
  TValue? get<TValue>(TestField field) {
    final v = _values[field];
    if (v is TValue) return v;
    return null;
  }

  @override
  TValue getOr<TValue>(TestField field, TValue fallback) =>
      get<TValue>(field) ?? fallback;

  @override
  bool isFieldVisible(TestField field) => true;

  @override
  bool isFieldEnabled(TestField field) => true;

  @override
  bool isFieldDirty(TestField field) => false;
}

/// A configurable test controller.
class TestController extends OiAfController<TestField, Map<String, dynamic>> {
  TestController({this.onDefineFields, this.onBuildData});

  final void Function(TestController)? onDefineFields;
  final Map<String, dynamic> Function(TestController)? onBuildData;

  @override
  void defineFields() {
    if (onDefineFields != null) {
      onDefineFields!(this);
    } else {
      addTextField(TestField.name, initialValue: '');
      addTextField(TestField.email, initialValue: '');
    }
  }

  @override
  Map<String, dynamic> buildData() {
    if (onBuildData != null) return onBuildData!(this);
    return json();
  }
}
