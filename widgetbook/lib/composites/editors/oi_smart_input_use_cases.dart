import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final _mentionRecognizer = OiPatternRecognizer(
  trigger: '@',
  pattern: RegExp(r'@\w+'),
  style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
  showSuggestions: true,
);

final _hashtagRecognizer = OiPatternRecognizer(
  trigger: '#',
  pattern: RegExp(r'#\w+'),
  style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w600),
);

final oiSmartInputComponent = WidgetbookComponent(
  name: 'OiSmartInput',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 400,
            child: OiSmartInput(
              label: 'Smart input',
              placeholder: 'Type @mention or #tag...',
              recognizers: [_mentionRecognizer, _hashtagRecognizer],
              onSuggestionQuery: (trigger, query) async {
                if (trigger == '@') {
                  final users = ['Alice', 'Bob', 'Charlie'];
                  return users
                      .where(
                        (u) => u.toLowerCase().contains(query.toLowerCase()),
                      )
                      .map((u) => OiSuggestion(value: '@$u ', label: u))
                      .toList();
                }
                return [];
              },
            ),
          ),
        );
      },
    ),
  ],
);
