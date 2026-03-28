import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

const _samplePlans = [
  OiPricingPlan(
    key: 'free',
    name: 'Free',
    monthlyPrice: 0,
    description: 'For hobby projects and experimentation.',
    features: ['1 project', '100 MB storage', 'Community support'],
  ),
  OiPricingPlan(
    key: 'pro',
    name: 'Pro',
    monthlyPrice: 19,
    yearlyPrice: 180,
    description: 'For professionals and growing teams.',
    features: [
      'Unlimited projects',
      '10 GB storage',
      'Priority support',
      'API access',
      'Custom domain',
    ],
    recommended: true,
    badge: 'Most Popular',
  ),
  OiPricingPlan(
    key: 'enterprise',
    name: 'Enterprise',
    monthlyPrice: 0,
    contactSales: true,
    description: 'For large organizations with custom needs.',
    features: [
      'Everything in Pro',
      'Unlimited storage',
      'Dedicated support',
      'SLA guarantee',
      'SSO & SAML',
    ],
  ),
];

const _sampleFeatures = [
  OiPricingFeature(
    label: 'Projects',
    included: {'free': '1', 'pro': 'Unlimited', 'enterprise': 'Unlimited'},
  ),
  OiPricingFeature(
    label: 'Storage',
    included: {'free': '100 MB', 'pro': '10 GB', 'enterprise': 'Unlimited'},
  ),
  OiPricingFeature(
    label: 'API Access',
    included: {'free': false, 'pro': true, 'enterprise': true},
  ),
  OiPricingFeature(
    label: 'Custom Domain',
    included: {'free': false, 'pro': true, 'enterprise': true},
  ),
  OiPricingFeature(
    label: 'SSO & SAML',
    included: {'free': false, 'pro': false, 'enterprise': true},
  ),
];

/// Widgetbook component for [OiPricingTable].
final oiPricingTableComponent = WidgetbookComponent(
  name: 'OiPricingTable',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final billingCycle = context.knobs.enumKnob(
          label: 'Initial Billing Cycle',
          values: OiBillingCycle.values,
        );
        final showToggle = context.knobs.boolean(
          label: 'Show Billing Toggle',
          initialValue: true,
        );
        final showDiscount = context.knobs.boolean(
          label: 'Show Yearly Discount',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 960,
            child: SingleChildScrollView(
              child: OiPricingTable(
                plans: _samplePlans,
                label: 'Pricing Plans',
                billingCycle: billingCycle,
                showBillingToggle: showToggle,
                yearlyDiscount: showDiscount ? 'Save 20%' : null,
                onPlanSelect: (_, __) {},
                onBillingCycleChange: (_) {},
              ),
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'With Feature Matrix',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 960,
            child: SingleChildScrollView(
              child: OiPricingTable(
                plans: _samplePlans,
                features: _sampleFeatures,
                label: 'Pricing Comparison',
                yearlyDiscount: 'Save 20%',
                onPlanSelect: (_, __) {},
                onBillingCycleChange: (_) {},
              ),
            ),
          ),
        );
      },
    ),
  ],
);
