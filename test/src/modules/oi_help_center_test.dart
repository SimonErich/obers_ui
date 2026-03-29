// Tests do not require documentation comments.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_markdown.dart';
import 'package:obers_ui/src/components/feedback/oi_star_rating.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/modules/oi_help_center.dart';

import '../../helpers/pump_app.dart';

const _faq = [
  OiFaqItem(
    question: 'How do I reset my password?',
    answer: 'Go to **Settings** and click *Reset Password*.',
    keywords: ['password', 'reset', 'account'],
  ),
  OiFaqItem(
    question: 'Where are my invoices?',
    answer: 'Invoices are in the **Billing** section.',
    category: 'Billing',
  ),
  OiFaqItem(
    question: 'How to contact support?',
    answer: 'Use the contact form or email us.',
    keywords: ['support', 'email'],
  ),
];

final _articles = [
  const OiKnowledgeArticle(
    key: 'getting-started',
    title: 'Getting Started',
    content: '# Getting Started\n\nWelcome to the platform.',
    category: 'Onboarding',
    tags: ['intro', 'setup'],
  ),
  const OiKnowledgeArticle(
    key: 'billing-guide',
    title: 'Billing Guide',
    content: '# Billing\n\nManage your subscription here.',
    category: 'Billing',
    tags: ['billing', 'payment'],
  ),
];

void main() {
  group('OiHelpCenter', () {
    testWidgets('renders FAQ tab with questions', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 800,
          height: 600,
          child: OiHelpCenter(
            label: 'Help',
            faq: _faq,
            showContact: false,
            showKnowledgeBase: false,
            showFeedback: false,
          ),
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('How do I reset my password?'), findsOneWidget);
      expect(find.text('Where are my invoices?'), findsOneWidget);
      expect(find.text('How to contact support?'), findsOneWidget);
    });

    testWidgets('tapping FAQ item expands answer', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 800,
          height: 600,
          child: OiHelpCenter(
            label: 'Help',
            faq: _faq,
            showContact: false,
            showKnowledgeBase: false,
            showFeedback: false,
          ),
        ),
        surfaceSize: const Size(800, 600),
      );

      // Answer should not be visible initially.
      expect(find.byType(OiMarkdown), findsNothing);

      // Tap the first question.
      await tester.tap(find.text('How do I reset my password?'));
      await tester.pumpAndSettle();

      // OiMarkdown should now be visible with the answer.
      expect(find.byType(OiMarkdown), findsOneWidget);
    });

    testWidgets('contact form renders fields', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 800,
          height: 600,
          child: OiHelpCenter(
            label: 'Help',
            showFaq: false,
            showKnowledgeBase: false,
            showFeedback: false,
          ),
        ),
        surfaceSize: const Size(800, 600),
      );

      // Should show the contact tab content with input fields.
      expect(find.text('Subject'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(find.text('Email (optional)'), findsOneWidget);
    });

    testWidgets('contact submit calls onContactSubmit', (tester) async {
      final completer = Completer<bool>();
      String? capturedSubject;
      String? capturedMessage;

      await tester.pumpObers(
        SizedBox(
          width: 800,
          height: 600,
          child: OiHelpCenter(
            label: 'Help',
            showFaq: false,
            showKnowledgeBase: false,
            showFeedback: false,
            onContactSubmit:
                ({
                  required subject,
                  required message,
                  email,
                }) {
                  capturedSubject = subject;
                  capturedMessage = message;
                  return completer.future;
                },
          ),
        ),
        surfaceSize: const Size(800, 600),
      );

      // Fill in the fields via the widget tester.
      // Index 0 is the search bar, 1 = Subject, 2 = Email, 3 = Message.
      final inputs = find.byType(OiTextInput);
      await tester.enterText(inputs.at(1), 'Test Subject');
      await tester.pump();
      await tester.enterText(inputs.at(3), 'Test Message Body');
      await tester.pump();

      // Tap submit.
      await tester.tap(find.text('Send message'));
      await tester.pump();

      completer.complete(true);
      await tester.pumpAndSettle();

      expect(capturedSubject, 'Test Subject');
      expect(capturedMessage, 'Test Message Body');

      // Should show success state.
      expect(find.text('Message sent'), findsOneWidget);
    });

    testWidgets('knowledge base renders article titles', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 800,
          height: 600,
          child: OiHelpCenter(
            label: 'Help',
            articles: _articles,
            showFaq: false,
            showContact: false,
            showFeedback: false,
          ),
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Getting Started'), findsOneWidget);
      expect(find.text('Billing Guide'), findsOneWidget);
    });

    testWidgets('tapping article shows detail view', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 800,
          height: 600,
          child: OiHelpCenter(
            label: 'Help',
            articles: _articles,
            showFaq: false,
            showContact: false,
            showFeedback: false,
          ),
        ),
        surfaceSize: const Size(800, 600),
      );

      await tester.tap(find.text('Getting Started'));
      await tester.pumpAndSettle();

      // Detail view should show article content via OiMarkdown.
      expect(find.byType(OiMarkdown), findsOneWidget);
      // Back button should be visible.
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('back button returns to article list', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 800,
          height: 600,
          child: OiHelpCenter(
            label: 'Help',
            articles: _articles,
            showFaq: false,
            showContact: false,
            showFeedback: false,
          ),
        ),
        surfaceSize: const Size(800, 600),
      );

      // Go into article detail.
      await tester.tap(find.text('Getting Started'));
      await tester.pumpAndSettle();
      expect(find.text('Back'), findsOneWidget);

      // Go back.
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      // Should be back to the list.
      expect(find.text('Getting Started'), findsOneWidget);
      expect(find.text('Billing Guide'), findsOneWidget);
    });

    testWidgets('feedback tab renders star rating', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 800,
          height: 600,
          child: OiHelpCenter(
            label: 'Help',
            showFaq: false,
            showContact: false,
            showKnowledgeBase: false,
          ),
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.byType(OiStarRating), findsOneWidget);
      expect(find.text('How would you rate your experience?'), findsOneWidget);
    });

    testWidgets('search filters FAQ items', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 800,
          height: 600,
          child: OiHelpCenter(
            label: 'Help',
            faq: _faq,
            showContact: false,
            showKnowledgeBase: false,
            showFeedback: false,
          ),
        ),
        surfaceSize: const Size(800, 600),
      );

      // All questions visible initially.
      expect(find.text('How do I reset my password?'), findsOneWidget);
      expect(find.text('Where are my invoices?'), findsOneWidget);

      // Type a search query.
      final searchInput = find.byType(OiTextInput);
      await tester.enterText(searchInput.first, 'invoice');
      await tester.pumpAndSettle();

      // Only the matching question should be visible.
      expect(find.text('Where are my invoices?'), findsOneWidget);
      expect(find.text('How do I reset my password?'), findsNothing);
    });

    testWidgets('hidden tabs not shown', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 800,
          height: 600,
          child: OiHelpCenter(
            label: 'Help',
            faq: _faq,
            showContact: false,
            showFeedback: false,
          ),
        ),
        surfaceSize: const Size(800, 600),
      );

      // Contact and Feedback tabs should not appear.
      expect(find.text('Contact'), findsNothing);
      expect(find.text('Feedback'), findsNothing);

      // FAQ and Articles tabs should appear.
      expect(find.text('FAQ'), findsOneWidget);
      expect(find.text('Articles'), findsOneWidget);
    });

    testWidgets('semantics label is applied', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 800,
          height: 600,
          child: OiHelpCenter(label: 'Application Help Center', faq: _faq),
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics && w.properties.label == 'Application Help Center',
        ),
        findsOneWidget,
      );
    });
  });
}
