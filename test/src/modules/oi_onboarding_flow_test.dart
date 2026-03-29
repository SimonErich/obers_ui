// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_page_indicator.dart';
import 'package:obers_ui/src/modules/oi_onboarding_flow.dart';

import '../../helpers/pump_app.dart';

void main() {
  List<OiOnboardingPage> samplePages({int count = 3}) {
    return List.generate(
      count,
      (i) => OiOnboardingPage(
        title: 'Page ${i + 1} Title',
        description: 'Page ${i + 1} description text.',
      ),
    );
  }

  Widget buildFlow({
    List<OiOnboardingPage>? pages,
    VoidCallback? onComplete,
    VoidCallback? onSkip,
    ValueChanged<int>? onPageChange,
    bool showSkip = true,
    bool showPageIndicator = true,
  }) {
    return SizedBox(
      width: 800,
      height: 600,
      child: OiOnboardingFlow(
        label: 'Onboarding',
        pages: pages ?? samplePages(),
        onComplete: onComplete,
        onSkip: onSkip,
        onPageChange: onPageChange,
        showSkip: showSkip,
        showPageIndicator: showPageIndicator,
      ),
    );
  }

  testWidgets('renders first page title and description', (tester) async {
    await tester.pumpObers(buildFlow(), surfaceSize: const Size(800, 600));

    expect(find.text('Page 1 Title'), findsOneWidget);
    expect(find.text('Page 1 description text.'), findsOneWidget);
  });

  testWidgets('next button advances to next page', (tester) async {
    await tester.pumpObers(buildFlow(), surfaceSize: const Size(800, 600));

    // Tap next.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Page 2 Title'), findsOneWidget);
  });

  testWidgets('last page shows done button instead of next', (tester) async {
    await tester.pumpObers(
      buildFlow(pages: samplePages(count: 1)),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
  });

  testWidgets('done button calls onComplete', (tester) async {
    var completed = false;
    await tester.pumpObers(
      buildFlow(
        pages: samplePages(count: 1),
        onComplete: () => completed = true,
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
  });

  testWidgets('skip button calls onSkip', (tester) async {
    var skipped = false;
    await tester.pumpObers(
      buildFlow(onSkip: () => skipped = true),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(skipped, isTrue);
  });

  testWidgets('skip button hidden when showSkip is false', (tester) async {
    await tester.pumpObers(
      buildFlow(showSkip: false),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('Skip'), findsNothing);
  });

  testWidgets('page indicator shows correct count', (tester) async {
    await tester.pumpObers(buildFlow(), surfaceSize: const Size(800, 600));

    final indicator = tester.widget<OiPageIndicator>(
      find.byType(OiPageIndicator),
    );
    expect(indicator.count, 3);
    expect(indicator.current, 0);
  });

  testWidgets('onPageChange callback fires on page change', (tester) async {
    int? changedTo;
    await tester.pumpObers(
      buildFlow(onPageChange: (index) => changedTo = index),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(changedTo, 1);
  });

  testWidgets('illustration renders when provided', (tester) async {
    const illustrationKey = Key('test-illustration');
    final pages = [
      const OiOnboardingPage(
        title: 'With Illustration',
        description: 'Has an image.',
        illustration: SizedBox(key: illustrationKey, width: 100, height: 100),
      ),
    ];

    await tester.pumpObers(
      buildFlow(pages: pages),
      surfaceSize: const Size(800, 600),
    );

    expect(find.byKey(illustrationKey), findsOneWidget);
  });

  testWidgets('semantics label is applied', (tester) async {
    await tester.pumpObers(buildFlow(), surfaceSize: const Size(800, 600));

    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Onboarding',
      ),
    );
    expect(semantics.properties.label, 'Onboarding');
    expect(semantics.container, isTrue);
  });
}
