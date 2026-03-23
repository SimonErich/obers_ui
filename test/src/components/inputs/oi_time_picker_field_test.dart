// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders label and placeholder when no value', (tester) async {
    await tester.pumpObers(
      const OiTimePickerField(
        label: 'Start Time',
        placeholder: 'Pick a time',
      ),
    );

    expect(find.text('Start Time'), findsOneWidget);
    expect(find.text('Pick a time'), findsOneWidget);
  });

  testWidgets('shows formatted time when value set (24h)', (tester) async {
    await tester.pumpObers(
      const OiTimePickerField(
        value: OiTimeOfDay(hour: 14, minute: 30),
      ),
    );

    expect(find.text('14:30'), findsOneWidget);
  });

  testWidgets('shows formatted time when value set (12h)', (tester) async {
    await tester.pumpObers(
      const OiTimePickerField(
        value: OiTimeOfDay(hour: 14, minute: 5),
        use24Hour: false,
      ),
    );

    expect(find.text('02:05 PM'), findsOneWidget);
  });

  testWidgets('renders clock icon', (tester) async {
    await tester.pumpObers(
      const OiTimePickerField(),
    );

    expect(find.byIcon(OiIcons.clock), findsOneWidget);
  });
}
