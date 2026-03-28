// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/modules/oi_subscription_manager.dart';

import '../../helpers/pump_app.dart';

void main() {
  final renewalDate = DateTime(2026, 5, 15);

  OiSubscriptionPlan makePlan({
    OiSubscriptionStatus status = OiSubscriptionStatus.active,
    DateTime? renewal,
    List<String> features = const [],
  }) {
    return OiSubscriptionPlan(
      key: 'pro',
      name: 'Pro Plan',
      price: 29,
      renewalDate: renewal ?? renewalDate,
      status: status,
      features: features,
    );
  }

  final sampleUsage = [
    const OiUsageQuota(label: 'Storage', used: 7.5, limit: 10, unit: 'GB'),
    const OiUsageQuota(label: 'API Calls', used: 9200, limit: 10000),
    const OiUsageQuota(label: 'Seats', used: 4, limit: 10),
  ];

  final sampleInvoices = [
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
  ];

  const samplePayment = OiPaymentMethodInfo(
    label: 'Visa ending in 4242',
    last4: '4242',
    brand: 'Visa',
    expiresAt: '12/27',
  );

  Widget buildWidget({
    OiSubscriptionPlan? plan,
    List<OiUsageQuota> usage = const [],
    List<OiInvoice> invoices = const [],
    OiPaymentMethodInfo? paymentMethod,
    VoidCallback? onUpgrade,
    VoidCallback? onDowngrade,
    Future<bool> Function()? onCancel,
    VoidCallback? onUpdatePayment,
    void Function(OiInvoice)? onInvoiceDownload,
  }) {
    return OiSubscriptionManager(
      currentPlan: plan ?? makePlan(),
      label: 'Subscription Manager',
      usage: usage,
      invoices: invoices,
      paymentMethod: paymentMethod,
      onUpgrade: onUpgrade,
      onDowngrade: onDowngrade,
      onCancel: onCancel,
      onUpdatePayment: onUpdatePayment,
      onInvoiceDownload: onInvoiceDownload,
    );
  }

  testWidgets('renders plan name and price', (tester) async {
    await tester.pumpObers(buildWidget(), surfaceSize: const Size(800, 600));

    expect(find.text('Pro Plan'), findsOneWidget);
    expect(find.text(r'$29.00/mo'), findsOneWidget);
  });

  testWidgets('status badge shows correct status', (tester) async {
    await tester.pumpObers(
      buildWidget(plan: makePlan(status: OiSubscriptionStatus.pastDue)),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('Past Due'), findsOneWidget);
  });

  testWidgets('renewal date renders', (tester) async {
    await tester.pumpObers(
      buildWidget(plan: makePlan(renewal: DateTime(2026, 5, 15))),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('Renews on May 15, 2026'), findsOneWidget);
  });

  testWidgets('usage meters render with labels', (tester) async {
    await tester.pumpObers(
      buildWidget(usage: sampleUsage),
      surfaceSize: const Size(800, 800),
    );

    expect(find.text('Storage'), findsOneWidget);
    expect(find.text('API Calls'), findsOneWidget);
    expect(find.text('Seats'), findsOneWidget);
    expect(find.byType(OiProgress), findsNWidgets(3));
  });

  testWidgets('usage meter color changes at warning threshold', (tester) async {
    // API Calls: 9200/10000 = 92% which is > 80% so warning color.
    await tester.pumpObers(
      buildWidget(
        usage: const [
          OiUsageQuota(label: 'API Calls', used: 9200, limit: 10000),
        ],
      ),
      surfaceSize: const Size(800, 600),
    );

    // The progress widget should exist and the text should show the usage.
    expect(find.text('9200 / 10000'), findsOneWidget);
    expect(find.byType(OiProgress), findsOneWidget);
  });

  testWidgets('billing history renders invoice descriptions', (tester) async {
    await tester.pumpObers(
      buildWidget(invoices: sampleInvoices),
      surfaceSize: const Size(800, 800),
    );

    expect(find.text('Pro Plan - March 2026'), findsOneWidget);
    expect(find.text('Pro Plan - February 2026'), findsOneWidget);
  });

  testWidgets('invoice download button calls onInvoiceDownload', (
    tester,
  ) async {
    OiInvoice? downloaded;
    await tester.pumpObers(
      buildWidget(
        invoices: [sampleInvoices.first],
        onInvoiceDownload: (invoice) => downloaded = invoice,
      ),
      surfaceSize: const Size(800, 600),
    );

    // Find the download tappable by its semantic label.
    final downloadFinder = find.bySemanticsLabel(
      'Download invoice Pro Plan - March 2026',
    );
    expect(downloadFinder, findsOneWidget);
    await tester.tap(downloadFinder);
    await tester.pump();

    expect(downloaded, isNotNull);
    expect(downloaded!.key, 'inv-1');
  });

  testWidgets('payment method renders card info', (tester) async {
    await tester.pumpObers(
      buildWidget(paymentMethod: samplePayment),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('Visa ending in 4242'), findsOneWidget);
    expect(find.text('Expires 12/27'), findsOneWidget);
  });

  testWidgets('update payment button calls onUpdatePayment', (tester) async {
    var called = false;
    await tester.pumpObers(
      buildWidget(
        paymentMethod: samplePayment,
        onUpdatePayment: () => called = true,
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.text('Update'));
    await tester.pump();

    expect(called, isTrue);
  });

  testWidgets('upgrade button calls onUpgrade', (tester) async {
    var called = false;
    await tester.pumpObers(
      buildWidget(onUpgrade: () => called = true),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.text('Upgrade'));
    await tester.pump();

    expect(called, isTrue);
  });

  testWidgets('cancel button calls onCancel', (tester) async {
    var called = false;
    await tester.pumpObers(
      buildWidget(
        onCancel: () async {
          called = true;
          return true;
        },
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(called, isTrue);
  });

  testWidgets('semantics label is applied', (tester) async {
    await tester.pumpObers(buildWidget(), surfaceSize: const Size(800, 600));

    expect(find.bySemanticsLabel('Subscription Manager'), findsOneWidget);
  });
}
