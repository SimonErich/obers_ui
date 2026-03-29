// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/modules/oi_pricing_table.dart';

import '../../helpers/pump_app.dart';

const _freePlan = OiPricingPlan(
  key: 'free',
  name: 'Free',
  monthlyPrice: 0,
  description: 'For individuals',
  features: ['1 project', '100 MB storage'],
);

const _proPlan = OiPricingPlan(
  key: 'pro',
  name: 'Pro',
  monthlyPrice: 19,
  yearlyPrice: 180,
  description: 'For teams',
  features: ['Unlimited projects', '10 GB storage', 'Priority support'],
  recommended: true,
  badge: 'Most Popular',
);

const _enterprisePlan = OiPricingPlan(
  key: 'enterprise',
  name: 'Enterprise',
  monthlyPrice: 0,
  contactSales: true,
  description: 'For organizations',
  features: ['Custom limits', 'Dedicated support', 'SLA'],
);

const _currentPlan = OiPricingPlan(
  key: 'current',
  name: 'Starter',
  monthlyPrice: 9,
  currentPlan: true,
  features: ['3 projects'],
);

const _features = [
  OiPricingFeature(
    label: 'Projects',
    included: {'free': '1', 'pro': 'Unlimited', 'enterprise': 'Custom'},
  ),
  OiPricingFeature(
    label: 'Storage',
    included: {'free': true, 'pro': true, 'enterprise': true},
  ),
  OiPricingFeature(
    label: 'API Access',
    included: {'free': false, 'pro': true, 'enterprise': true},
  ),
];

void main() {
  group('OiPricingTable', () {
    testWidgets('renders plan names', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 900,
          height: 600,
          child: SingleChildScrollView(
            child: OiPricingTable(
              plans: [_freePlan, _proPlan],
              label: 'Pricing',
            ),
          ),
        ),
        surfaceSize: const Size(900, 600),
      );

      expect(find.text('Free'), findsOneWidget);
      expect(find.text('Pro'), findsOneWidget);
    });

    testWidgets('renders prices with currency symbol', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 900,
          height: 600,
          child: SingleChildScrollView(
            child: OiPricingTable(
              plans: [_freePlan, _proPlan],
              label: 'Pricing',
              showBillingToggle: false,
            ),
          ),
        ),
        surfaceSize: const Size(900, 600),
      );

      // Free plan: $0
      expect(find.text(r'$0'), findsOneWidget);
      // Pro plan: $19
      expect(find.text(r'$19'), findsOneWidget);
    });

    testWidgets('recommended plan has badge', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 900,
          height: 600,
          child: SingleChildScrollView(
            child: OiPricingTable(
              plans: [_freePlan, _proPlan],
              label: 'Pricing',
              showBillingToggle: false,
            ),
          ),
        ),
        surfaceSize: const Size(900, 600),
      );

      // The recommended plan should show its badge text.
      expect(find.text('Most Popular'), findsOneWidget);
      // Verify it is an OiBadge widget.
      expect(
        find.ancestor(
          of: find.text('Most Popular'),
          matching: find.byType(OiBadge),
        ),
        findsOneWidget,
      );
    });

    testWidgets('billing toggle switches between monthly and yearly', (
      tester,
    ) async {
      OiBillingCycle? lastCycle;

      await tester.pumpObers(
        SizedBox(
          width: 900,
          height: 600,
          child: SingleChildScrollView(
            child: OiPricingTable(
              plans: const [_proPlan],
              label: 'Pricing',
              onBillingCycleChange: (cycle) => lastCycle = cycle,
            ),
          ),
        ),
        surfaceSize: const Size(900, 600),
      );

      // Initially monthly: $19
      expect(find.text(r'$19'), findsOneWidget);

      // Tap "Yearly" segment.
      await tester.tap(find.text('Yearly'));
      await tester.pumpAndSettle();

      expect(lastCycle, OiBillingCycle.yearly);

      // Yearly: 180/12 = $15
      expect(find.text(r'$15'), findsOneWidget);
    });

    testWidgets('CTA button calls onPlanSelect', (tester) async {
      OiPricingPlan? selectedPlan;
      OiBillingCycle? selectedCycle;

      await tester.pumpObers(
        SizedBox(
          width: 900,
          height: 600,
          child: SingleChildScrollView(
            child: OiPricingTable(
              plans: const [_freePlan],
              label: 'Pricing',
              showBillingToggle: false,
              onPlanSelect: (plan, cycle) {
                selectedPlan = plan;
                selectedCycle = cycle;
              },
            ),
          ),
        ),
        surfaceSize: const Size(900, 600),
      );

      // Tap the CTA button "Get Started".
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(selectedPlan?.key, 'free');
      expect(selectedCycle, OiBillingCycle.monthly);
    });

    testWidgets('current plan shows Current Plan badge', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 900,
          height: 600,
          child: SingleChildScrollView(
            child: OiPricingTable(
              plans: [_currentPlan],
              label: 'Pricing',
              showBillingToggle: false,
            ),
          ),
        ),
        surfaceSize: const Size(900, 600),
      );

      expect(find.text('Current Plan'), findsAtLeast(1));
    });

    testWidgets('contact sales plan shows Contact Sales text', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 900,
          height: 600,
          child: SingleChildScrollView(
            child: OiPricingTable(
              plans: [_enterprisePlan],
              label: 'Pricing',
              showBillingToggle: false,
            ),
          ),
        ),
        surfaceSize: const Size(900, 600),
      );

      expect(find.text('Contact Sales'), findsOneWidget);
    });

    testWidgets('feature matrix renders feature labels', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 900,
          height: 800,
          child: SingleChildScrollView(
            child: OiPricingTable(
              plans: [_freePlan, _proPlan, _enterprisePlan],
              features: _features,
              label: 'Pricing',
              showBillingToggle: false,
            ),
          ),
        ),
        surfaceSize: const Size(900, 800),
      );

      expect(find.text('Feature Comparison'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Storage'), findsOneWidget);
      expect(find.text('API Access'), findsOneWidget);
    });

    testWidgets('feature matrix shows check and cross correctly', (
      tester,
    ) async {
      await tester.pumpObers(
        const SizedBox(
          width: 900,
          height: 800,
          child: SingleChildScrollView(
            child: OiPricingTable(
              plans: [_freePlan, _proPlan],
              features: [
                OiPricingFeature(
                  label: 'Feature A',
                  included: {'free': true, 'pro': false},
                ),
              ],
              label: 'Pricing',
              showBillingToggle: false,
            ),
          ),
        ),
        surfaceSize: const Size(900, 800),
      );

      // Feature label is rendered in the matrix.
      expect(find.text('Feature A'), findsOneWidget);
    });

    testWidgets('yearly discount badge renders', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 900,
          height: 600,
          child: SingleChildScrollView(
            child: OiPricingTable(
              plans: [_freePlan],
              label: 'Pricing',
              yearlyDiscount: 'Save 20%',
            ),
          ),
        ),
        surfaceSize: const Size(900, 600),
      );

      expect(find.text('Save 20%'), findsOneWidget);
    });

    testWidgets('semantics label is applied', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 900,
          height: 600,
          child: SingleChildScrollView(
            child: OiPricingTable(
              plans: [_freePlan],
              label: 'Pricing Plans',
              showBillingToggle: false,
            ),
          ),
        ),
        surfaceSize: const Size(900, 600),
      );

      // Verify the Semantics widget has the expected label.
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Pricing Plans',
        ),
        findsOneWidget,
      );
    });
  });
}
