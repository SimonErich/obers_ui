// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders label text', (tester) async {
    await tester.pumpObers(const OiBadge(label: 'New'));
    expect(find.text('New'), findsOneWidget);
  });

  testWidgets('dot mode renders no text', (tester) async {
    await tester.pumpObers(const OiBadge(label: 'ignored', dot: true));
    expect(find.text('ignored'), findsNothing);
  });

  testWidgets('dot mode exposes label as semantic text indicator', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiBadge(
        label: 'Error status',
        color: OiBadgeColor.error,
        dot: true,
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Error status')),
      isNotNull,
    );
  });

  testWidgets('renders with success color', (tester) async {
    await tester.pumpObers(
      const OiBadge(label: 'OK', color: OiBadgeColor.success),
    );
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('renders with error color', (tester) async {
    await tester.pumpObers(
      const OiBadge(label: 'Error', color: OiBadgeColor.error),
    );
    expect(find.text('Error'), findsOneWidget);
  });

  testWidgets('renders small size', (tester) async {
    await tester.pumpObers(const OiBadge(label: 'sm', size: OiBadgeSize.small));
    expect(find.text('sm'), findsOneWidget);
  });

  testWidgets('renders large size', (tester) async {
    await tester.pumpObers(const OiBadge(label: 'lg', size: OiBadgeSize.large));
    expect(find.text('lg'), findsOneWidget);
  });

  testWidgets('renders soft style', (tester) async {
    await tester.pumpObers(
      const OiBadge(label: 'soft', style: OiBadgeStyle.soft),
    );
    expect(find.text('soft'), findsOneWidget);
  });

  testWidgets('renders outline style', (tester) async {
    await tester.pumpObers(
      const OiBadge(label: 'out', style: OiBadgeStyle.outline),
    );
    expect(find.text('out'), findsOneWidget);
  });

  testWidgets('renders with icon', (tester) async {
    const icon = IconData(0xe318, fontFamily: 'MaterialIcons');
    await tester.pumpObers(const OiBadge(label: 'with icon', icon: icon));
    expect(find.text('with icon'), findsOneWidget);
    expect(find.byType(Icon), findsOneWidget);
  });
}
