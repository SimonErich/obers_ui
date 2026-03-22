import 'package:obers_ui/obers_ui.dart';

/// Countries and their subdivisions for address-form demos.
///
/// Focused on Austria and its neighbours — because the Alpenglueck GmbH
/// does not ship to Antarctica (yet).
const kCountries = <OiCountryOption>[
  // ── Austria ──────────────────────────────────────────────────────────────
  OiCountryOption(
    code: 'AT',
    name: 'Austria',
    states: [
      OiStateOption(name: 'Burgenland', code: 'B'),
      OiStateOption(name: 'Carinthia', code: 'K'),
      OiStateOption(name: 'Lower Austria', code: 'N'),
      OiStateOption(name: 'Upper Austria', code: 'O'),
      OiStateOption(name: 'Salzburg', code: 'S'),
      OiStateOption(name: 'Styria', code: 'ST'),
      OiStateOption(name: 'Tyrol', code: 'T'),
      OiStateOption(name: 'Vorarlberg', code: 'V'),
      OiStateOption(name: 'Vienna', code: 'W'),
    ],
  ),

  // ── Germany ──────────────────────────────────────────────────────────────
  OiCountryOption(
    code: 'DE',
    name: 'Germany',
  ),

  // ── Switzerland ──────────────────────────────────────────────────────────
  OiCountryOption(
    code: 'CH',
    name: 'Switzerland',
  ),

  // ── Italy ────────────────────────────────────────────────────────────────
  OiCountryOption(
    code: 'IT',
    name: 'Italy',
  ),

  // ── Hungary ──────────────────────────────────────────────────────────────
  OiCountryOption(
    code: 'HU',
    name: 'Hungary',
  ),

  // ── Czech Republic ───────────────────────────────────────────────────────
  OiCountryOption(
    code: 'CZ',
    name: 'Czech Republic',
  ),

  // ── Slovakia ─────────────────────────────────────────────────────────────
  OiCountryOption(
    code: 'SK',
    name: 'Slovakia',
  ),

  // ── Slovenia ─────────────────────────────────────────────────────────────
  OiCountryOption(
    code: 'SI',
    name: 'Slovenia',
  ),
];
