// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/shop/oi_address_form.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';
import 'package:obers_ui/src/models/oi_country_option.dart';

import '../../../helpers/platform_helpers.dart';
import '../../../helpers/pump_app.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

const _surfaceSize = Size(800, 1000);

OiAddressData _sampleAddress() => const OiAddressData(
  firstName: 'Jane',
  lastName: 'Doe',
  company: 'Acme Inc.',
  line1: '123 Main St',
  line2: 'Apt 4B',
  city: 'Zürich',
  state: 'ZH',
  postalCode: '8001',
  country: 'Switzerland',
  phone: '+41 44 123 4567',
);

List<OiCountryOption> _sampleCountries() => const [
  OiCountryOption(
    code: 'US',
    name: 'United States',
    states: [
      OiStateOption(name: 'California', code: 'CA'),
      OiStateOption(name: 'New York', code: 'NY'),
      OiStateOption(name: 'Texas', code: 'TX'),
    ],
  ),
  OiCountryOption(code: 'CH', name: 'Switzerland'),
  OiCountryOption(
    code: 'DE',
    name: 'Germany',
    states: [
      OiStateOption(name: 'Bavaria', code: 'BY'),
      OiStateOption(name: 'Berlin', code: 'BE'),
      OiStateOption(name: 'Hamburg', code: 'HH'),
    ],
  ),
];

Widget _buildAddressForm({
  String label = 'Shipping address',
  OiAddressData? initialValue,
  ValueChanged<OiAddressData>? onChange,
  bool showName = true,
  bool showCompany = true,
  bool showPhone = true,
  List<OiCountryOption>? countries,
  bool readOnly = false,
  ValueChanged<OiAddressData>? onSubmit,
  String? error,
  GlobalKey<State>? formKey,
}) {
  return SingleChildScrollView(
    child: OiAddressForm(
      key: formKey,
      label: label,
      initialValue: initialValue,
      onChange: onChange,
      showName: showName,
      showCompany: showCompany,
      showPhone: showPhone,
      countries: countries,
      readOnly: readOnly,
      onSubmit: onSubmit,
      error: error,
    ),
  );
}

void main() {
  group('OiAddressForm', () {
    // ── Default fields render ─────────────────────────────────────────────

    group('default fields render', () {
      testWidgets('renders all text input fields', (tester) async {
        await tester.pumpObers(_buildAddressForm(), surfaceSize: _surfaceSize);

        expect(find.byType(OiAddressForm), findsOneWidget);
        // 10 text inputs: first name, last name, company, line1, line2,
        // city, state, postal code, country, phone.
        expect(find.byType(OiTextInput), findsNWidgets(10));
      });

      testWidgets('renders field placeholder texts', (tester) async {
        await tester.pumpObers(_buildAddressForm(), surfaceSize: _surfaceSize);

        expect(find.text('First name'), findsWidgets);
        expect(find.text('Last name'), findsWidgets);
        expect(find.text('Company (optional)'), findsOneWidget);
        expect(find.text('Street address'), findsOneWidget);
        expect(find.text('Apartment, suite, etc. (optional)'), findsOneWidget);
        expect(find.text('City'), findsWidgets);
        expect(find.text('State / Province'), findsWidgets);
        expect(find.text('Postal code'), findsWidgets);
        expect(find.text('Country'), findsWidgets);
        expect(find.text('Phone number'), findsOneWidget);
      });

      testWidgets('displays the form label', (tester) async {
        await tester.pumpObers(
          _buildAddressForm(label: 'Billing address'),
          surfaceSize: _surfaceSize,
        );

        expect(find.text('Billing address'), findsOneWidget);
      });
    });

    // ── Named constructors ────────────────────────────────────────────────

    group('named constructors', () {
      testWidgets('shipping constructor uses "Shipping address" label', (
        tester,
      ) async {
        await tester.pumpObers(
          const SingleChildScrollView(child: OiAddressForm.shipping()),
          surfaceSize: _surfaceSize,
        );

        expect(find.text('Shipping address'), findsOneWidget);
      });

      testWidgets('billing constructor uses "Billing address" label', (
        tester,
      ) async {
        await tester.pumpObers(
          const SingleChildScrollView(child: OiAddressForm.billing()),
          surfaceSize: _surfaceSize,
        );

        expect(find.text('Billing address'), findsOneWidget);
      });

      testWidgets('shipping constructor pre-fills initialValue', (
        tester,
      ) async {
        await tester.pumpObers(
          const SingleChildScrollView(
            child: OiAddressForm.shipping(
              initialValue: OiAddressData(firstName: 'Alice'),
            ),
          ),
          surfaceSize: _surfaceSize,
        );

        expect(find.text('Alice'), findsOneWidget);
      });

      testWidgets('billing constructor pre-fills initialValue', (tester) async {
        await tester.pumpObers(
          const SingleChildScrollView(
            child: OiAddressForm.billing(
              initialValue: OiAddressData(lastName: 'Smith'),
            ),
          ),
          surfaceSize: _surfaceSize,
        );

        expect(find.text('Smith'), findsOneWidget);
      });
    });

    // ── onChange firing ───────────────────────────────────────────────────

    group('onChange', () {
      testWidgets('fires onChange with updated data on first name edit', (
        tester,
      ) async {
        OiAddressData? latest;
        await tester.pumpObers(
          _buildAddressForm(onChange: (data) => latest = data),
          surfaceSize: _surfaceSize,
        );

        final inputs = find.byType(OiTextInput);
        // First OiTextInput is "First name".
        await tester.enterText(inputs.at(0), 'Jane');
        await tester.pump();

        expect(latest, isNotNull);
        expect(latest!.firstName, 'Jane');
      });

      testWidgets('fires onChange with updated data on last name edit', (
        tester,
      ) async {
        OiAddressData? latest;
        await tester.pumpObers(
          _buildAddressForm(onChange: (data) => latest = data),
          surfaceSize: _surfaceSize,
        );

        final inputs = find.byType(OiTextInput);
        // Second OiTextInput is "Last name".
        await tester.enterText(inputs.at(1), 'Doe');
        await tester.pump();

        expect(latest, isNotNull);
        expect(latest!.lastName, 'Doe');
      });

      testWidgets('fires onChange with updated data on city edit', (
        tester,
      ) async {
        OiAddressData? latest;
        await tester.pumpObers(
          _buildAddressForm(onChange: (data) => latest = data),
          surfaceSize: _surfaceSize,
        );

        final inputs = find.byType(OiTextInput);
        // Index 5 is "City".
        await tester.enterText(inputs.at(5), 'Bern');
        await tester.pump();

        expect(latest, isNotNull);
        expect(latest!.city, 'Bern');
      });

      testWidgets('fires onChange with updated data on country edit', (
        tester,
      ) async {
        OiAddressData? latest;
        await tester.pumpObers(
          _buildAddressForm(onChange: (data) => latest = data),
          surfaceSize: _surfaceSize,
        );

        final inputs = find.byType(OiTextInput);
        // Index 8 is "Country".
        await tester.enterText(inputs.at(8), 'Germany');
        await tester.pump();

        expect(latest, isNotNull);
        expect(latest!.country, 'Germany');
      });

      testWidgets('fires onChange with null for empty fields', (tester) async {
        OiAddressData? latest;
        await tester.pumpObers(
          _buildAddressForm(
            initialValue: const OiAddressData(firstName: 'Jane'),
            onChange: (data) => latest = data,
          ),
          surfaceSize: _surfaceSize,
        );

        // Clear the first name field.
        final inputs = find.byType(OiTextInput);
        await tester.enterText(inputs.at(0), '');
        await tester.pump();

        expect(latest, isNotNull);
        expect(latest!.firstName, isNull);
      });

      testWidgets('trims whitespace before calling onChange', (tester) async {
        OiAddressData? latest;
        await tester.pumpObers(
          _buildAddressForm(onChange: (data) => latest = data),
          surfaceSize: _surfaceSize,
        );

        final inputs = find.byType(OiTextInput);
        await tester.enterText(inputs.at(0), '  Jane  ');
        await tester.pump();

        expect(latest!.firstName, 'Jane');
      });
    });

    // ── initialValue pre-fill ─────────────────────────────────────────────

    group('initialValue pre-fill', () {
      testWidgets('pre-fills all fields from initialValue', (tester) async {
        final address = _sampleAddress();
        await tester.pumpObers(
          _buildAddressForm(initialValue: address),
          surfaceSize: _surfaceSize,
        );

        expect(find.text('Jane'), findsOneWidget);
        expect(find.text('Doe'), findsOneWidget);
        expect(find.text('Acme Inc.'), findsOneWidget);
        expect(find.text('123 Main St'), findsOneWidget);
        expect(find.text('Apt 4B'), findsOneWidget);
        expect(find.text('Zürich'), findsOneWidget);
        expect(find.text('ZH'), findsOneWidget);
        expect(find.text('8001'), findsOneWidget);
        expect(find.text('Switzerland'), findsOneWidget);
        expect(find.text('+41 44 123 4567'), findsOneWidget);
      });

      testWidgets('partial initialValue shows only filled fields', (
        tester,
      ) async {
        await tester.pumpObers(
          _buildAddressForm(
            initialValue: const OiAddressData(
              firstName: 'Alice',
              city: 'Zürich',
            ),
          ),
          surfaceSize: _surfaceSize,
        );

        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Zürich'), findsOneWidget);
      });

      testWidgets('null initialValue shows no pre-filled values', (
        tester,
      ) async {
        await tester.pumpObers(_buildAddressForm(), surfaceSize: _surfaceSize);

        // None of the sample address values should appear.
        expect(find.text('Jane'), findsNothing);
        expect(find.text('Doe'), findsNothing);
        expect(find.text('Acme Inc.'), findsNothing);
      });
    });

    // ── readOnly mode ────────────────────────────────────────────────────

    group('readOnly mode', () {
      testWidgets('readOnly=true makes all text inputs read-only', (
        tester,
      ) async {
        await tester.pumpObers(
          _buildAddressForm(readOnly: true, initialValue: _sampleAddress()),
          surfaceSize: _surfaceSize,
        );

        final textInputs = tester.widgetList<OiTextInput>(
          find.byType(OiTextInput),
        );
        for (final input in textInputs) {
          expect(input.readOnly, isTrue);
        }
      });

      testWidgets('readOnly=true disables all text inputs', (tester) async {
        await tester.pumpObers(
          _buildAddressForm(readOnly: true),
          surfaceSize: _surfaceSize,
        );

        final textInputs = tester.widgetList<OiTextInput>(
          find.byType(OiTextInput),
        );
        for (final input in textInputs) {
          expect(input.enabled, isFalse);
        }
      });

      testWidgets('readOnly=true disables OiSelect fields', (tester) async {
        await tester.pumpObers(
          _buildAddressForm(
            readOnly: true,
            countries: _sampleCountries(),
            initialValue: const OiAddressData(country: 'US'),
          ),
          surfaceSize: _surfaceSize,
        );

        final selects = tester.widgetList<OiSelect<String>>(
          find.byType(OiSelect<String>),
        );
        for (final select in selects) {
          expect(select.enabled, isFalse);
        }
      });
    });

    // ── Responsive layout ────────────────────────────────────────────────

    group('responsive layout', () {
      testWidgets('renders at narrow breakpoint without overflow', (
        tester,
      ) async {
        await pumpAtBreakpoint(
          tester,
          OiApp(theme: OiThemeData.light(), home: _buildAddressForm()),
          kCompactWidth,
          height: 1600,
        );

        expect(find.byType(OiAddressForm), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('renders at wide breakpoint without overflow', (
        tester,
      ) async {
        await pumpAtBreakpoint(
          tester,
          OiApp(theme: OiThemeData.light(), home: _buildAddressForm()),
          kExpandedWidth,
        );

        expect(find.byType(OiAddressForm), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('paired fields side by side at wide breakpoint', (
        tester,
      ) async {
        await pumpAtBreakpoint(
          tester,
          OiApp(
            theme: OiThemeData.light(),
            home: _buildAddressForm(
              initialValue: const OiAddressData(
                firstName: 'Jane',
                lastName: 'Doe',
              ),
            ),
          ),
          kExpandedWidth,
        );

        expect(find.text('Jane'), findsOneWidget);
        expect(find.text('Doe'), findsOneWidget);

        // Verify name fields are on the same row (same y) but different
        // columns (different x), confirming two-column layout.
        final janeBox = tester.getRect(find.text('Jane'));
        final doeBox = tester.getRect(find.text('Doe'));
        expect(janeBox.top, doeBox.top);
        expect(janeBox.left, isNot(doeBox.left));
      });

      testWidgets('fields stack vertically at compact breakpoint', (
        tester,
      ) async {
        await pumpAtBreakpoint(
          tester,
          OiApp(
            theme: OiThemeData.light(),
            home: _buildAddressForm(
              initialValue: const OiAddressData(
                firstName: 'Jane',
                lastName: 'Doe',
              ),
            ),
          ),
          kCompactWidth,
          height: 1600,
        );

        expect(find.text('Jane'), findsOneWidget);
        expect(find.text('Doe'), findsOneWidget);

        // At compact, name fields should be stacked vertically (different y).
        final janeBox = tester.getRect(find.text('Jane'));
        final doeBox = tester.getRect(find.text('Doe'));
        expect(janeBox.top, isNot(doeBox.top));
      });
    });

    // ── Accessibility semantics ──────────────────────────────────────────

    group('accessibility semantics', () {
      testWidgets('form has semantic label', (tester) async {
        await tester.pumpObers(
          _buildAddressForm(label: 'Delivery address'),
          surfaceSize: _surfaceSize,
        );

        expect(
          find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label == 'Delivery address',
          ),
          findsOneWidget,
        );
      });

      testWidgets('each text input has a label for accessibility', (
        tester,
      ) async {
        await tester.pumpObers(_buildAddressForm(), surfaceSize: _surfaceSize);

        final textInputs = tester.widgetList<OiTextInput>(
          find.byType(OiTextInput),
        );
        for (final input in textInputs) {
          expect(input.label, isNotNull);
          expect(input.label, isNotEmpty);
        }
      });

      testWidgets('semantic tree is generated without errors', (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpObers(_buildAddressForm(), surfaceSize: _surfaceSize);

        expect(tester.takeException(), isNull);
        handle.dispose();
      });

      testWidgets('all interactive fields have semantic labels', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpObers(
          _buildAddressForm(countries: _sampleCountries()),
          surfaceSize: _surfaceSize,
        );

        // OiSelect fields also have labels.
        final selects = tester.widgetList<OiSelect<String>>(
          find.byType(OiSelect<String>),
        );
        for (final select in selects) {
          expect(select.label, isNotNull);
          expect(select.label, isNotEmpty);
        }

        expect(tester.takeException(), isNull);
        handle.dispose();
      });
    });

    // ── Field labels ─────────────────────────────────────────────────────

    group('field labels', () {
      testWidgets('all input fields have correct labels', (tester) async {
        await tester.pumpObers(_buildAddressForm(), surfaceSize: _surfaceSize);

        final textInputs = tester
            .widgetList<OiTextInput>(find.byType(OiTextInput))
            .toList();
        expect(textInputs[0].label, 'First name');
        expect(textInputs[1].label, 'Last name');
        expect(textInputs[2].label, 'Company');
        expect(textInputs[3].label, 'Address line 1');
        expect(textInputs[4].label, 'Address line 2');
        expect(textInputs[5].label, 'City');
        expect(textInputs[6].label, 'State / Province');
        expect(textInputs[7].label, 'Postal code');
        expect(textInputs[8].label, 'Country');
        expect(textInputs[9].label, 'Phone');
      });
    });

    // ── showName / showCompany / showPhone toggles ─────────────────────

    group('showName/showCompany/showPhone toggles', () {
      testWidgets('hides name fields when showName is false', (tester) async {
        await tester.pumpObers(
          _buildAddressForm(showName: false),
          surfaceSize: _surfaceSize,
        );

        // Without name fields, we lose 2 text inputs (first name, last name).
        // Default has 10 → should be 8.
        expect(find.byType(OiTextInput), findsNWidgets(8));
        expect(
          find.byWidgetPredicate(
            (w) => w is OiTextInput && w.label == 'First name',
          ),
          findsNothing,
        );
        expect(
          find.byWidgetPredicate(
            (w) => w is OiTextInput && w.label == 'Last name',
          ),
          findsNothing,
        );
      });

      testWidgets('shows name fields when showName is true', (tester) async {
        await tester.pumpObers(
          // Explicitly testing default true value shows name fields.
          // ignore: avoid_redundant_argument_values
          _buildAddressForm(showName: true),
          surfaceSize: _surfaceSize,
        );

        expect(
          find.byWidgetPredicate(
            (w) => w is OiTextInput && w.label == 'First name',
          ),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate(
            (w) => w is OiTextInput && w.label == 'Last name',
          ),
          findsOneWidget,
        );
      });

      testWidgets('hides company field when showCompany is false', (
        tester,
      ) async {
        await tester.pumpObers(
          _buildAddressForm(showCompany: false),
          surfaceSize: _surfaceSize,
        );

        // Without company, we lose 1 text input. Default 10 → 9.
        expect(find.byType(OiTextInput), findsNWidgets(9));
        expect(
          find.byWidgetPredicate(
            (w) => w is OiTextInput && w.label == 'Company',
          ),
          findsNothing,
        );
      });

      testWidgets('hides phone field when showPhone is false', (tester) async {
        await tester.pumpObers(
          _buildAddressForm(showPhone: false),
          surfaceSize: _surfaceSize,
        );

        // Without phone, we lose 1 text input. Default 10 → 9.
        expect(find.byType(OiTextInput), findsNWidgets(9));
        expect(
          find.byWidgetPredicate((w) => w is OiTextInput && w.label == 'Phone'),
          findsNothing,
        );
      });

      testWidgets('multiple toggles can be combined', (tester) async {
        await tester.pumpObers(
          _buildAddressForm(
            showName: false,
            showCompany: false,
            showPhone: false,
          ),
          surfaceSize: _surfaceSize,
        );

        // Without name (2), company (1), phone (1) → 10 - 4 = 6.
        expect(find.byType(OiTextInput), findsNWidgets(6));
      });
    });

    // ── Country select ────────────────────────────────────────────────

    group('country select', () {
      testWidgets('renders OiSelect for country when countries list provided', (
        tester,
      ) async {
        await tester.pumpObers(
          _buildAddressForm(countries: _sampleCountries()),
          surfaceSize: _surfaceSize,
        );

        // Should have an OiSelect for country.
        expect(find.byType(OiSelect<String>), findsOneWidget);
        // One fewer OiTextInput (country replaced by select). 10 - 1 = 9.
        expect(find.byType(OiTextInput), findsNWidgets(9));
      });

      testWidgets('renders text input for country when no countries list', (
        tester,
      ) async {
        await tester.pumpObers(_buildAddressForm(), surfaceSize: _surfaceSize);

        expect(find.byType(OiSelect<String>), findsNothing);
        expect(find.byType(OiTextInput), findsNWidgets(10));
      });

      testWidgets('country OiSelect has correct label', (tester) async {
        await tester.pumpObers(
          _buildAddressForm(countries: _sampleCountries()),
          surfaceSize: _surfaceSize,
        );

        final select = tester.widget<OiSelect<String>>(
          find.byType(OiSelect<String>),
        );
        expect(select.label, 'Country');
      });
    });

    // ── State field switching ─────────────────────────────────────────

    group('state field switching', () {
      testWidgets('renders state as text input when no countries provided', (
        tester,
      ) async {
        await tester.pumpObers(_buildAddressForm(), surfaceSize: _surfaceSize);

        expect(
          find.byWidgetPredicate(
            (w) => w is OiTextInput && w.label == 'State / Province',
          ),
          findsOneWidget,
        );
      });

      testWidgets('renders state as text input when country has no states', (
        tester,
      ) async {
        // Pre-select Switzerland (no states).
        await tester.pumpObers(
          _buildAddressForm(
            countries: _sampleCountries(),
            initialValue: const OiAddressData(country: 'CH'),
          ),
          surfaceSize: _surfaceSize,
        );

        // State should be a text input, not a select.
        expect(
          find.byWidgetPredicate(
            (w) => w is OiTextInput && w.label == 'State / Province',
          ),
          findsOneWidget,
        );
      });

      testWidgets('renders state as dropdown when country has states', (
        tester,
      ) async {
        // Pre-select US (has states).
        await tester.pumpObers(
          _buildAddressForm(
            countries: _sampleCountries(),
            initialValue: const OiAddressData(country: 'US'),
          ),
          surfaceSize: _surfaceSize,
        );

        // State should be an OiSelect. Country is also OiSelect → 2 total.
        expect(find.byType(OiSelect<String>), findsNWidgets(2));
      });
    });

    // ── Validation errors ─────────────────────────────────────────────

    group('validation errors', () {
      testWidgets('validation shows errors on empty required fields', (
        tester,
      ) async {
        final formKey = GlobalKey<State>();
        await tester.pumpObers(
          _buildAddressForm(formKey: formKey, onSubmit: (_) {}),
          surfaceSize: _surfaceSize,
        );

        // Trigger submit via the state's submit method.
        final state = formKey.currentState!;
        // `submit()` is an internal method not exposed through the public interface.
        (state as dynamic).submit();
        await tester.pump();

        // Validation errors should appear for required fields.
        expect(find.text('Street address is required'), findsOneWidget);
        expect(find.text('City is required'), findsOneWidget);
        expect(find.text('Postal code is required'), findsOneWidget);
        expect(find.text('Country is required'), findsOneWidget);
      });

      testWidgets('validation clears errors when fields are filled', (
        tester,
      ) async {
        final formKey = GlobalKey<State>();
        OiAddressData? submitted;
        await tester.pumpObers(
          _buildAddressForm(
            formKey: formKey,
            onSubmit: (data) => submitted = data,
          ),
          surfaceSize: _surfaceSize,
        );

        // First trigger with empty fields to show errors.
        (formKey.currentState! as dynamic).submit();
        await tester.pump();
        expect(find.text('Street address is required'), findsOneWidget);

        // Now fill the required fields.
        final inputs = find.byType(OiTextInput);
        await tester.enterText(inputs.at(3), '123 Main St'); // line1
        await tester.enterText(inputs.at(5), 'Zürich'); // city
        await tester.enterText(inputs.at(7), '8001'); // postalCode
        // Country is at index 8 — but after validation errors, need to
        // re-find. The country field is a text input (no countries provided).
        await tester.pump();
        // Re-find inputs after pump.
        final inputsAfter = find.byType(OiTextInput);
        await tester.enterText(inputsAfter.at(8), 'Switzerland'); // country
        await tester.pump();

        // Submit again — should succeed.
        (formKey.currentState! as dynamic).submit();
        await tester.pump();

        expect(submitted, isNotNull);
        expect(find.text('Street address is required'), findsNothing);
      });

      testWidgets('does not fire onSubmit when validation fails', (
        tester,
      ) async {
        final formKey = GlobalKey<State>();
        var submitCount = 0;
        await tester.pumpObers(
          _buildAddressForm(formKey: formKey, onSubmit: (_) => submitCount++),
          surfaceSize: _surfaceSize,
        );

        // `submit()` is an internal method not exposed through the public interface.
        (formKey.currentState! as dynamic).submit();
        await tester.pump();

        expect(submitCount, 0);
      });

      testWidgets('fires onSubmit with valid data', (tester) async {
        final formKey = GlobalKey<State>();
        OiAddressData? submitted;
        await tester.pumpObers(
          _buildAddressForm(
            formKey: formKey,
            initialValue: const OiAddressData(
              line1: '123 Main St',
              city: 'Zürich',
              postalCode: '8001',
              country: 'Switzerland',
            ),
            onSubmit: (data) => submitted = data,
          ),
          surfaceSize: _surfaceSize,
        );

        // `submit()` is an internal method not exposed through the public interface.
        (formKey.currentState! as dynamic).submit();
        await tester.pump();

        expect(submitted, isNotNull);
        expect(submitted!.line1, '123 Main St');
        expect(submitted!.city, 'Zürich');
        expect(submitted!.postalCode, '8001');
        expect(submitted!.country, 'Switzerland');
      });
    });

    // ── Error message display ─────────────────────────────────────────

    group('error message display', () {
      testWidgets('displays global error message from error parameter', (
        tester,
      ) async {
        await tester.pumpObers(
          _buildAddressForm(error: 'Address is invalid'),
          surfaceSize: _surfaceSize,
        );

        expect(find.text('Address is invalid'), findsOneWidget);
      });

      testWidgets('no error shown when error is null', (tester) async {
        await tester.pumpObers(_buildAddressForm(), surfaceSize: _surfaceSize);

        expect(find.text('Address is invalid'), findsNothing);
      });
    });

    // ── Multiple field edits ─────────────────────────────────────────────

    group('multiple field edits', () {
      testWidgets('accumulates changes across multiple fields', (tester) async {
        OiAddressData? latest;
        await tester.pumpObers(
          _buildAddressForm(onChange: (data) => latest = data),
          surfaceSize: _surfaceSize,
        );

        final inputs = find.byType(OiTextInput);
        await tester.enterText(inputs.at(0), 'Jane');
        await tester.pump();
        await tester.enterText(inputs.at(1), 'Doe');
        await tester.pump();
        await tester.enterText(inputs.at(5), 'Bern');
        await tester.pump();

        expect(latest!.firstName, 'Jane');
        expect(latest!.lastName, 'Doe');
        expect(latest!.city, 'Bern');
      });
    });

    // ── Controller disposal ──────────────────────────────────────────────

    group('controller disposal', () {
      testWidgets('disposes controllers without error', (tester) async {
        await tester.pumpObers(_buildAddressForm(), surfaceSize: _surfaceSize);

        // Replace the widget to trigger dispose.
        await tester.pumpObers(
          const SizedBox.shrink(),
          surfaceSize: _surfaceSize,
        );

        // No exception means controllers disposed properly.
        expect(tester.takeException(), isNull);
      });
    });
  });
}
