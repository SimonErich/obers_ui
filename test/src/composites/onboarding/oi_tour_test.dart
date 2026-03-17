// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/onboarding/oi_tour.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiTour', () {
    testWidgets('renders tooltip for the first step', (tester) async {
      final key1 = GlobalKey();
      final key2 = GlobalKey();
      await tester.pumpObers(
        OiTour(
          steps: [
            OiTourStep(target: key1, title: 'Step 1', description: 'Desc 1'),
            OiTourStep(target: key2, title: 'Step 2', description: 'Desc 2'),
          ],
          child: Column(
            children: [
              SizedBox(key: key1, width: 100, height: 50),
              SizedBox(key: key2, width: 100, height: 50),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('Desc 1'), findsOneWidget);
    });

    testWidgets('advances to next step when Next is tapped', (tester) async {
      final key1 = GlobalKey();
      final key2 = GlobalKey();
      int? changedTo;
      await tester.pumpObers(
        OiTour(
          steps: [
            OiTourStep(target: key1, title: 'Step 1', description: 'Desc 1'),
            OiTourStep(target: key2, title: 'Step 2', description: 'Desc 2'),
          ],
          onStepChange: (step) => changedTo = step,
          child: Column(
            children: [
              SizedBox(key: key1, width: 100, height: 50),
              SizedBox(key: key2, width: 100, height: 50),
            ],
          ),
        ),
      );
      await tester.pump();

      // Tap Next.
      await tester.tap(find.byKey(const Key('oi_tour_next')));
      await tester.pump();
      await tester.pump();

      expect(find.text('Step 2'), findsOneWidget);
      expect(changedTo, 1);
    });

    testWidgets('Previous goes back to earlier step', (tester) async {
      final key1 = GlobalKey();
      final key2 = GlobalKey();
      await tester.pumpObers(
        OiTour(
          steps: [
            OiTourStep(target: key1, title: 'Step 1', description: 'Desc 1'),
            OiTourStep(target: key2, title: 'Step 2', description: 'Desc 2'),
          ],
          child: Column(
            children: [
              SizedBox(key: key1, width: 100, height: 50),
              SizedBox(key: key2, width: 100, height: 50),
            ],
          ),
        ),
      );
      await tester.pump();

      // Go to step 2.
      await tester.tap(find.byKey(const Key('oi_tour_next')));
      await tester.pump();
      await tester.pump();

      // Go back.
      await tester.tap(find.byKey(const Key('oi_tour_previous')));
      await tester.pump();
      await tester.pump();

      expect(find.text('Step 1'), findsOneWidget);
    });

    testWidgets('Skip fires onSkip callback', (tester) async {
      final key1 = GlobalKey();
      var skipped = false;
      await tester.pumpObers(
        OiTour(
          steps: [
            OiTourStep(target: key1, title: 'Step 1', description: 'Desc 1'),
          ],
          onSkip: () => skipped = true,
          child: SizedBox(key: key1, width: 100, height: 50),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('oi_tour_skip')));
      await tester.pump();

      expect(skipped, isTrue);
    });

    testWidgets('Finish fires onComplete on last step', (tester) async {
      final key1 = GlobalKey();
      var completed = false;
      await tester.pumpObers(
        OiTour(
          steps: [
            OiTourStep(target: key1, title: 'Step 1', description: 'Desc 1'),
          ],
          onComplete: () => completed = true,
          child: SizedBox(key: key1, width: 100, height: 50),
        ),
      );
      await tester.pump();

      // The only step should show "Finish" instead of "Next".
      expect(find.text('Finish'), findsOneWidget);

      await tester.tap(find.byKey(const Key('oi_tour_next')));
      await tester.pump();

      expect(completed, isTrue);
    });

    testWidgets('progress indicator shows step count', (tester) async {
      final key1 = GlobalKey();
      final key2 = GlobalKey();
      await tester.pumpObers(
        OiTour(
          steps: [
            OiTourStep(target: key1, title: 'Step 1', description: 'Desc 1'),
            OiTourStep(target: key2, title: 'Step 2', description: 'Desc 2'),
          ],
          child: Column(
            children: [
              SizedBox(key: key1, width: 100, height: 50),
              SizedBox(key: key2, width: 100, height: 50),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Step 1 of 2'), findsOneWidget);
    });

    testWidgets('overlay covers screen via spotlight', (tester) async {
      final key1 = GlobalKey();
      await tester.pumpObers(
        OiTour(
          steps: [
            OiTourStep(target: key1, title: 'Step 1', description: 'Desc 1'),
          ],
          child: Center(child: SizedBox(key: key1, width: 100, height: 50)),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('oi_spotlight_overlay')), findsOneWidget);
    });

    testWidgets('empty steps renders child only', (tester) async {
      await tester.pumpObers(const OiTour(steps: [], child: Text('No tour')));
      await tester.pump();

      expect(find.text('No tour'), findsOneWidget);
      expect(find.byKey(const Key('oi_tour_tooltip')), findsNothing);
    });

    testWidgets('dismissOnOutsideTap skips tour on outside tap', (
      tester,
    ) async {
      final key1 = GlobalKey();
      var skipped = false;
      await tester.pumpObers(
        OiTour(
          steps: [
            OiTourStep(target: key1, title: 'Step 1', description: 'Desc 1'),
          ],
          dismissOnOutsideTap: true,
          onSkip: () => skipped = true,
          child: Center(child: SizedBox(key: key1, width: 100, height: 50)),
        ),
      );
      await tester.pump();

      // Tap outside the spotlight area.
      await tester.tapAt(Offset.zero);
      await tester.pump();

      expect(skipped, isTrue);
    });

    testWidgets('showProgress=false hides step counter', (tester) async {
      final key1 = GlobalKey();
      await tester.pumpObers(
        OiTour(
          steps: [
            OiTourStep(target: key1, title: 'Step 1', description: 'Desc 1'),
          ],
          showProgress: false,
          child: SizedBox(key: key1, width: 100, height: 50),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('oi_tour_progress')), findsNothing);
    });

    testWidgets('showSkip=false hides Skip button', (tester) async {
      final key1 = GlobalKey();
      await tester.pumpObers(
        OiTour(
          steps: [
            OiTourStep(target: key1, title: 'Step 1', description: 'Desc 1'),
          ],
          showSkip: false,
          child: SizedBox(key: key1, width: 100, height: 50),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('oi_tour_skip')), findsNothing);
    });
  });
}
