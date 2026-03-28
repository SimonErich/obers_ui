import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

const _sampleFaq = [
  OiFaqItem(
    question: 'How do I reset my password?',
    answer:
        'Navigate to **Settings > Account > Security** and click '
        '*Reset Password*. You will receive a confirmation email within '
        'a few minutes.',
    category: 'Account',
    keywords: ['password', 'reset', 'security'],
  ),
  OiFaqItem(
    question: 'Where can I find my invoices?',
    answer:
        'All invoices are available in the **Billing** section of your '
        'dashboard. You can download them as PDF or CSV.',
    category: 'Billing',
    keywords: ['invoice', 'billing', 'payment'],
  ),
  OiFaqItem(
    question: 'How do I invite team members?',
    answer:
        'Go to **Settings > Team** and click **Invite Member**. Enter '
        'their email address and select a role:\n\n'
        '- **Admin** - full access\n'
        '- **Editor** - can edit content\n'
        '- **Viewer** - read-only access',
    category: 'Team',
    keywords: ['team', 'invite', 'members', 'roles'],
  ),
  OiFaqItem(
    question: 'What payment methods do you accept?',
    answer:
        'We accept all major credit cards (Visa, Mastercard, AMEX), '
        'PayPal, and bank transfers for annual plans.',
    category: 'Billing',
    keywords: ['payment', 'credit card', 'paypal'],
  ),
  OiFaqItem(
    question: 'How do I export my data?',
    answer:
        'You can export your data from **Settings > Data > Export**. '
        'Supported formats include JSON, CSV, and XML. Large exports '
        'are processed in the background and you will be notified when '
        'they are ready.',
    category: 'Data',
    keywords: ['export', 'data', 'download', 'backup'],
  ),
];

final _sampleArticles = [
  const OiKnowledgeArticle(
    key: 'getting-started',
    title: 'Getting Started Guide',
    content:
        '# Getting Started\n\n'
        'Welcome to our platform! This guide will help you set up your '
        'account and get productive quickly.\n\n'
        '## Step 1: Create your workspace\n\n'
        'After signing up, create a workspace for your team.\n\n'
        '## Step 2: Invite your team\n\n'
        'Add team members from the Settings page.\n\n'
        '## Step 3: Start creating\n\n'
        'You are all set! Start creating projects and collaborating.',
    category: 'Onboarding',
    tags: ['getting started', 'setup', 'onboarding'],
  ),
  const OiKnowledgeArticle(
    key: 'keyboard-shortcuts',
    title: 'Keyboard Shortcuts',
    content:
        '# Keyboard Shortcuts\n\n'
        'Speed up your workflow with these shortcuts:\n\n'
        '- `Ctrl+N` - New project\n'
        '- `Ctrl+S` - Save\n'
        '- `Ctrl+Z` - Undo\n'
        '- `Ctrl+Shift+Z` - Redo\n'
        '- `Ctrl+K` - Quick search',
    category: 'Productivity',
    tags: ['shortcuts', 'keyboard', 'productivity'],
  ),
  const OiKnowledgeArticle(
    key: 'api-reference',
    title: 'API Reference Overview',
    content:
        '# API Reference\n\n'
        'Our REST API allows you to integrate with external tools.\n\n'
        '## Authentication\n\n'
        'Use Bearer token authentication for all API requests.\n\n'
        '## Rate Limits\n\n'
        '- Free plan: 100 requests/minute\n'
        '- Pro plan: 1000 requests/minute\n'
        '- Enterprise: unlimited',
    category: 'Developer',
    tags: ['api', 'developer', 'integration'],
  ),
];

final oiHelpCenterComponent = WidgetbookComponent(
  name: 'OiHelpCenter',
  useCases: [
    WidgetbookUseCase(
      name: 'Full',
      builder: (context) {
        final searchEnabled = context.knobs.boolean(
          label: 'Search Enabled',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 600,
            height: 700,
            child: OiHelpCenter(
              label: 'Help Center',
              faq: _sampleFaq,
              articles: _sampleArticles,
              searchEnabled: searchEnabled,
              onContactSubmit:
                  ({
                    required String subject,
                    required String message,
                    String? email,
                  }) async {
                    await Future<void>.delayed(const Duration(seconds: 1));
                    return true;
                  },
              onFeedbackSubmit: ({required int rating, String? comment}) async {
                await Future<void>.delayed(const Duration(seconds: 1));
                return true;
              },
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'FAQ Only',
      builder: (context) {
        return useCaseWrapper(
          const SizedBox(
            width: 600,
            height: 700,
            child: OiHelpCenter(
              label: 'FAQ',
              faq: _sampleFaq,
              showContact: false,
              showKnowledgeBase: false,
              showFeedback: false,
            ),
          ),
        );
      },
    ),
  ],
);
