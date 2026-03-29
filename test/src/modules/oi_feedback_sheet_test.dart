// Tests do not require documentation comments.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/feedback/oi_sentiment.dart';
import 'package:obers_ui/src/components/feedback/oi_star_rating.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/modules/oi_feedback_sheet.dart';

import '../../helpers/pump_app.dart';

void main() {
  Widget buildSheet({
    OiFeedbackRatingType ratingType = OiFeedbackRatingType.sentiment,
    Future<bool> Function(OiFeedbackData)? onSubmit,
    bool showEmail = true,
    List<OiFeedbackCategory> categories = OiFeedbackCategory.values,
  }) {
    return SizedBox(
      width: 500,
      height: 700,
      child: SingleChildScrollView(
        child: OiFeedbackSheet(
          label: 'Feedback',
          ratingType: ratingType,
          onSubmit: onSubmit,
          showEmail: showEmail,
          categories: categories,
        ),
      ),
    );
  }

  testWidgets('renders rating section with sentiment by default', (
    tester,
  ) async {
    await tester.pumpObers(buildSheet(), surfaceSize: const Size(800, 600));

    expect(find.byType(OiSentiment), findsOneWidget);
    expect(find.text('How was your experience?'), findsOneWidget);
  });

  testWidgets('renders star rating when ratingType is stars', (tester) async {
    await tester.pumpObers(
      buildSheet(ratingType: OiFeedbackRatingType.stars),
      surfaceSize: const Size(800, 600),
    );

    expect(find.byType(OiStarRating), findsOneWidget);
    expect(find.byType(OiSentiment), findsNothing);
  });

  testWidgets('renders category chips', (tester) async {
    await tester.pumpObers(buildSheet(), surfaceSize: const Size(800, 600));

    expect(find.text('Bug Report'), findsOneWidget);
    expect(find.text('Feature Request'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
  });

  testWidgets('selecting a category highlights it', (tester) async {
    await tester.pumpObers(buildSheet(), surfaceSize: const Size(800, 600));

    // Tap the "Bug Report" category chip.
    await tester.tap(find.text('Bug Report'));
    await tester.pumpAndSettle();

    // The chip should now be selected. We verify by finding a Semantics
    // widget with selected=true for the "Bug Report" label.
    final semantics = tester.widgetList<Semantics>(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Bug Report',
      ),
    );
    expect(semantics.any((s) => s.properties.selected ?? false), isTrue);
  });

  testWidgets('message input renders', (tester) async {
    await tester.pumpObers(buildSheet(), surfaceSize: const Size(800, 600));

    // OiTextInput with label "Message" should be present.
    final inputs = tester.widgetList<OiTextInput>(find.byType(OiTextInput));
    expect(inputs.any((i) => i.label == 'Message'), isTrue);
  });

  testWidgets('submit button calls onSubmit with correct data', (tester) async {
    final completer = Completer<OiFeedbackData>();

    await tester.pumpObers(
      buildSheet(
        onSubmit: (data) async {
          completer.complete(data);
          return true;
        },
      ),
      surfaceSize: const Size(800, 600),
    );

    // Select a category first.
    await tester.tap(find.text('General'));
    await tester.pumpAndSettle();

    // Tap the submit button.
    await tester.tap(find.text('Submit Feedback'));
    await tester.pumpAndSettle();

    final data = await completer.future;
    expect(data.category, OiFeedbackCategory.general);
  });

  testWidgets('submit button disabled when no category selected', (
    tester,
  ) async {
    var called = false;

    await tester.pumpObers(
      buildSheet(
        onSubmit: (data) async {
          called = true;
          return true;
        },
      ),
      surfaceSize: const Size(800, 600),
    );

    // Do NOT select a category. Tap the submit button.
    await tester.tap(find.text('Submit Feedback'));
    await tester.pumpAndSettle();

    expect(called, isFalse);
  });

  testWidgets('thank-you state shows after successful submission', (
    tester,
  ) async {
    await tester.pumpObers(
      buildSheet(onSubmit: (_) async => true),
      surfaceSize: const Size(800, 600),
    );

    // Select a category to enable submit.
    await tester.tap(find.text('Bug Report'));
    await tester.pumpAndSettle();

    // Submit the form.
    await tester.tap(find.text('Submit Feedback'));
    await tester.pumpAndSettle();

    // Thank-you state is shown.
    expect(find.text('Thank you!'), findsOneWidget);
    expect(find.text('Your feedback helps us improve.'), findsOneWidget);

    // Form elements are gone.
    expect(find.text('Submit Feedback'), findsNothing);
  });

  testWidgets('email field renders when showEmail is true', (tester) async {
    await tester.pumpObers(buildSheet(), surfaceSize: const Size(800, 600));

    final inputs = tester.widgetList<OiTextInput>(find.byType(OiTextInput));
    expect(inputs.any((i) => i.label == 'Email (optional)'), isTrue);
  });

  testWidgets('email field hidden when showEmail is false', (tester) async {
    await tester.pumpObers(
      buildSheet(showEmail: false),
      surfaceSize: const Size(800, 600),
    );

    final inputs = tester.widgetList<OiTextInput>(find.byType(OiTextInput));
    expect(inputs.any((i) => i.label == 'Email (optional)'), isFalse);
  });

  testWidgets('semantics label is applied', (tester) async {
    await tester.pumpObers(buildSheet(), surfaceSize: const Size(800, 600));

    final semantics = find.byWidgetPredicate(
      (w) =>
          w is Semantics &&
          w.properties.label == 'Feedback' &&
          w.container,
    );
    expect(semantics, findsOneWidget);
  });
}
