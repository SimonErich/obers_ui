// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/shop/oi_address_form.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';

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
  email: 'jane@example.com',
);

Widget _buildAddressForm({
  String label = 'Shipping address',
  OiAddressData initialData = const OiAddressData(),
  ValueChanged<OiAddressData>? onChanged,
  bool enabled = true,
}) {
  return SingleChildScrollView(
    child: OiAddressForm(
      label: label,
      initialData: initialData,
      onChanged: onChanged,
      enabled: enabled,
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
        // 11 text inputs: first name, last name, company, line1, line2,
        // city, state, postal code, country, phone, email.
        expect(find.byType(OiTextInput), findsNWidgets(11));
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
        expect(find.text('Email address'), findsOneWidget);
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

      testWidgets('shipping constructor pre-fills initialData', (tester) async {
        await tester.pumpObers(
          const SingleChildScrollView(
            child: OiAddressForm.shipping(
              initialData: OiAddressData(firstName: 'Alice'),
            ),
          ),
          surfaceSize: _surfaceSize,
        );

        expect(find.text('Alice'), findsOneWidget);
      });

      testWidgets('billing constructor pre-fills initialData', (tester) async {
        await tester.pumpObers(
          const SingleChildScrollView(
            child: OiAddressForm.billing(
              initialData: OiAddressData(lastName: 'Smith'),
            ),
          ),
          surfaceSize: _surfaceSize,
        );

        expect(find.text('Smith'), findsOneWidget);
      });
    });

    // ── onChange firing ───────────────────────────────────────────────────

    group('onChange', () {
      testWidgets('fires onChanged with updated data on first name edit', (
        tester,
      ) async {
        OiAddressData? latest;
        await tester.pumpObers(
          _buildAddressForm(onChanged: (data) => latest = data),
          surfaceSize: _surfaceSize,
        );

        final inputs = find.byType(OiTextInput);
        // First OiTextInput is "First name".
        await tester.enterText(inputs.at(0), 'Jane');
        await tester.pump();

        expect(latest, isNotNull);
        expect(latest!.firstName, 'Jane');
      });

      testWidgets('fires onChanged with updated data on last name edit', (
        tester,
      ) async {
        OiAddressData? latest;
        await tester.pumpObers(
          _buildAddressForm(onChanged: (data) => latest = data),
          surfaceSize: _surfaceSize,
        );

        final inputs = find.byType(OiTextInput);
        // Second OiTextInput is "Last name".
        await tester.enterText(inputs.at(1), 'Doe');
        await tester.pump();

        expect(latest, isNotNull);
        expect(latest!.lastName, 'Doe');
      });

      testWidgets('fires onChanged with updated data on city edit', (
        tester,
      ) async {
        OiAddressData? latest;
        await tester.pumpObers(
          _buildAddressForm(onChanged: (data) => latest = data),
          surfaceSize: _surfaceSize,
        );

        final inputs = find.byType(OiTextInput);
        // Index 5 is "City".
        await tester.enterText(inputs.at(5), 'Bern');
        await tester.pump();

        expect(latest, isNotNull);
        expect(latest!.city, 'Bern');
      });

      testWidgets('fires onChanged with updated data on country edit', (
        tester,
      ) async {
        OiAddressData? latest;
        await tester.pumpObers(
          _buildAddressForm(onChanged: (data) => latest = data),
          surfaceSize: _surfaceSize,
        );

        final inputs = find.byType(OiTextInput);
        // Index 8 is "Country".
        await tester.enterText(inputs.at(8), 'Germany');
        await tester.pump();

        expect(latest, isNotNull);
        expect(latest!.country, 'Germany');
      });

      testWidgets('fires onChanged with updated data on email edit', (
        tester,
      ) async {
        OiAddressData? latest;
        await tester.pumpObers(
          _buildAddressForm(onChanged: (data) => latest = data),
          surfaceSize: _surfaceSize,
        );

        final inputs = find.byType(OiTextInput);
        // Index 10 is "Email".
        await tester.enterText(inputs.at(10), 'test@example.com');
        await tester.pump();

        expect(latest, isNotNull);
        expect(latest!.email, 'test@example.com');
      });

      testWidgets('fires onChanged with null for empty fields', (tester) async {
        OiAddressData? latest;
        await tester.pumpObers(
          _buildAddressForm(
            initialData: const OiAddressData(firstName: 'Jane'),
            onChanged: (data) => latest = data,
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

      testWidgets('trims whitespace before calling onChanged', (tester) async {
        OiAddressData? latest;
        await tester.pumpObers(
          _buildAddressForm(onChanged: (data) => latest = data),
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
      testWidgets('pre-fills all fields from initialData', (tester) async {
        final address = _sampleAddress();
        await tester.pumpObers(
          _buildAddressForm(initialData: address),
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
        expect(find.text('jane@example.com'), findsOneWidget);
      });

      testWidgets('partial initialData shows only filled fields', (
        tester,
      ) async {
        await tester.pumpObers(
          _buildAddressForm(
            initialData: const OiAddressData(
              firstName: 'Alice',
              city: 'Zürich',
            ),
          ),
          surfaceSize: _surfaceSize,
        );

        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Zürich'), findsOneWidget);
      });

      testWidgets('empty initialData shows no pre-filled values', (
        tester,
      ) async {
        await tester.pumpObers(_buildAddressForm(), surfaceSize: _surfaceSize);

        // None of the sample address values should appear.
        expect(find.text('Jane'), findsNothing);
        expect(find.text('Doe'), findsNothing);
        expect(find.text('Acme Inc.'), findsNothing);
      });
    });

    // ── enabled / disabled mode ──────────────────────────────────────────

    group('enabled / disabled mode', () {
      testWidgets('enabled=false disables all inputs', (tester) async {
        await tester.pumpObers(
          _buildAddressForm(enabled: false),
          surfaceSize: _surfaceSize,
        );

        final textInputs = tester.widgetList<OiTextInput>(
          find.byType(OiTextInput),
        );
        for (final input in textInputs) {
          expect(input.enabled, isFalse);
        }
      });

      testWidgets('enabled=true enables all inputs by default', (tester) async {
        await tester.pumpObers(_buildAddressForm(), surfaceSize: _surfaceSize);

        final textInputs = tester.widgetList<OiTextInput>(
          find.byType(OiTextInput),
        );
        for (final input in textInputs) {
          expect(input.enabled, isTrue);
        }
      });

      testWidgets('disabled form does not fire onChanged on edit attempt', (
        tester,
      ) async {
        var callCount = 0;
        await tester.pumpObers(
          _buildAddressForm(enabled: false, onChanged: (_) => callCount++),
          surfaceSize: _surfaceSize,
        );

        // Attempt to type in the first field — should be ignored.
        final inputs = find.byType(OiTextInput);
        await tester.enterText(inputs.at(0), 'Test');
        await tester.pump();

        // The widget is disabled, so the field may or may not accept text,
        // but the form should not propagate changes through onChanged.
        // The OiTextInput.enabled=false prevents editing.
        expect(callCount, 0);
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
          height: 1200,
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
              initialData: const OiAddressData(
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

      testWidgets('fields render narrower at compact breakpoint', (
        tester,
      ) async {
        await pumpAtBreakpoint(
          tester,
          OiApp(
            theme: OiThemeData.light(),
            home: _buildAddressForm(
              initialData: const OiAddressData(
                firstName: 'Jane',
                lastName: 'Doe',
              ),
            ),
          ),
          kCompactWidth,
          height: 1200,
        );

        expect(find.text('Jane'), findsOneWidget);
        expect(find.text('Doe'), findsOneWidget);

        // OiRow keeps Expanded children side by side at compact width,
        // but each field is narrower. Verify both fields fit within the
        // compact viewport.
        final janeBox = tester.getRect(find.text('Jane'));
        final doeBox = tester.getRect(find.text('Doe'));
        expect(janeBox.right, lessThanOrEqualTo(kCompactWidth));
        expect(doeBox.right, lessThanOrEqualTo(kCompactWidth));
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
        expect(textInputs[10].label, 'Email');
      });
    });

    // ── showName / showCompany / showPhone toggles ─────────────────────

    // Skip: OiAddressForm API does not expose showName/showCompany/showPhone
    // toggles — all 11 fields are always visible.
    group('showName/showCompany/showPhone toggles', () {
      testWidgets(
        'showName toggle controls name field visibility',
        skip: true,
        (tester) async {},
      );

      testWidgets(
        'showCompany toggle controls company field visibility',
        skip: true,
        (tester) async {},
      );

      testWidgets(
        'showPhone toggle controls phone field visibility',
        skip: true,
        (tester) async {},
      );
    });

    // ── Country select ────────────────────────────────────────────────

    // Skip: OiAddressForm uses a plain OiTextInput for country —
    // no dropdown/select with predefined country options.
    group('country select', () {
      testWidgets(
        'country select renders with country options',
        skip: true,
        (tester) async {},
      );
    });

    // ── State field switching ─────────────────────────────────────────

    // Skip: OiAddressForm uses a plain OiTextInput for state —
    // no dynamic switching between dropdown and text input per country.
    group('state field switching', () {
      testWidgets(
        'selecting country with states shows state dropdown',
        skip: true,
        (tester) async {},
      );

      testWidgets(
        'selecting country without states shows state text input',
        skip: true,
        (tester) async {},
      );
    });

    // ── Validation errors ─────────────────────────────────────────────

    // Skip: OiAddressForm has no built-in validation — it delegates
    // validation to the consumer via onChanged and OiAddressData.isComplete.
    group('validation errors', () {
      testWidgets(
        'validation shows error on empty required street field',
        skip: true,
        (tester) async {},
      );

      testWidgets(
        'validation shows error on empty required city field',
        skip: true,
        (tester) async {},
      );

      testWidgets(
        'validation shows error on empty required zip field',
        skip: true,
        (tester) async {},
      );
    });

    // ── Error message display ─────────────────────────────────────────

    // Skip: OiAddressForm has no error message display — it does not
    // accept error text or show inline validation messages.
    group('error message display', () {
      testWidgets(
        'error messages display below respective fields',
        skip: true,
        (tester) async {},
      );
    });

    // ── Multiple field edits ─────────────────────────────────────────────

    group('multiple field edits', () {
      testWidgets('accumulates changes across multiple fields', (tester) async {
        OiAddressData? latest;
        await tester.pumpObers(
          _buildAddressForm(onChanged: (data) => latest = data),
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
  });
}
