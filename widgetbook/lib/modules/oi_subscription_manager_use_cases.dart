import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final _proPlan = OiSubscriptionPlan(
  key: 'pro',
  name: 'Pro Plan',
  price: 29,
  renewalDate: DateTime(2026, 5, 15),
  features: const [
    'Unlimited projects',
    'Priority support',
    '100 GB storage',
    'Custom domains',
  ],
);

final _pastDuePlan = OiSubscriptionPlan(
  key: 'pro',
  name: 'Pro Plan',
  price: 29,
  status: OiSubscriptionStatus.pastDue,
  renewalDate: DateTime(2026, 4),
  features: const ['Unlimited projects', 'Priority support', '100 GB storage'],
);

const _usage = [
  OiUsageQuota(label: 'Storage', used: 75, limit: 100, unit: 'GB'),
  OiUsageQuota(label: 'API Calls', used: 9200, limit: 10000),
  OiUsageQuota(label: 'Team Seats', used: 4, limit: 10),
];

final _invoices = [
  OiInvoice(
    key: 'inv-1',
    date: DateTime(2026, 3),
    description: 'Pro Plan - March 2026',
    amount: 29,
  ),
  OiInvoice(
    key: 'inv-2',
    date: DateTime(2026, 2),
    description: 'Pro Plan - February 2026',
    amount: 29,
  ),
  OiInvoice(
    key: 'inv-3',
    date: DateTime(2026),
    description: 'Pro Plan - January 2026',
    amount: 29,
  ),
];

const _paymentMethod = OiPaymentMethodInfo(
  label: 'Visa ending in 4242',
  last4: '4242',
  brand: 'Visa',
  expiresAt: '12/27',
);

/// Widgetbook component for [OiSubscriptionManager].
final oiSubscriptionManagerComponent = WidgetbookComponent(
  name: 'OiSubscriptionManager',
  useCases: [
    WidgetbookUseCase(
      name: 'Active Subscription',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 800,
            height: 900,
            child: OiSubscriptionManager(
              label: 'Subscription Manager',
              currentPlan: _proPlan,
              usage: _usage,
              invoices: _invoices,
              paymentMethod: _paymentMethod,
              onUpgrade: () {},
              onDowngrade: () {},
              onCancel: () async => true,
              onUpdatePayment: () {},
              onInvoiceDownload: (_) {},
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Past Due',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 800,
            height: 900,
            child: OiSubscriptionManager(
              label: 'Subscription Manager',
              currentPlan: _pastDuePlan,
              usage: _usage,
              invoices: _invoices,
              paymentMethod: _paymentMethod,
              onUpgrade: () {},
              onUpdatePayment: () {},
              onInvoiceDownload: (_) {},
            ),
          ),
        );
      },
    ),
  ],
);
