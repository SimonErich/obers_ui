// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_card.dart';
import 'package:obers_ui/src/components/display/oi_key_value.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('short trailing values leave remaining width to the label', (
    tester,
  ) async {
    await tester.pumpObers(
      const Center(
        child: SizedBox(
          width: 312,
          child: OiKeyValue(
            label: 'Delivery · framework agreement',
            value: '€0.00',
            direction: Axis.horizontal,
            valueAtEnd: true,
            labelWidget: Text('Delivery · framework agreement'),
          ),
        ),
      ),
    );
    final label = tester.getRect(find.text('Delivery · framework agreement'));
    final value = tester.getRect(find.text('€0.00'));
    expect(label.width, greaterThan(220));
    expect(
      value.right,
      closeTo(tester.getRect(find.byType(OiKeyValue)).right, .1),
    );
    expect(value.left, greaterThan(label.right));
    expect(tester.takeException(), isNull);
  });

  testWidgets('long trailing values remain bounded at narrow widths', (
    tester,
  ) async {
    await tester.pumpObers(
      const Center(
        child: SizedBox(
          width: 180,
          child: OiKeyValue(
            label: 'Reference',
            value: 'An unusually long value which must wrap safely',
            direction: Axis.horizontal,
            valueAtEnd: true,
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester
          .getSize(find.text('An unusually long value which must wrap safely'))
          .width,
      lessThanOrEqualTo(90),
    );
  });

  testWidgets('custom trailing totals can use more room beside a short label', (
    tester,
  ) async {
    await tester.pumpObers(
      const Center(
        child: SizedBox(
          width: 248,
          child: OiKeyValue(
            label: 'Total',
            value: '€35.90',
            direction: Axis.horizontal,
            valueAtEnd: true,
            valueMaxWidthFraction: .75,
            valueWidget: SizedBox(
              key: ValueKey('total'),
              width: 170,
              height: 20,
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byKey(const ValueKey('total'))).width, 170);
    expect(tester.takeException(), isNull);
  });

  testWidgets('trailing summaries wrap labels and retain group slots', (
    tester,
  ) async {
    await tester.pumpObers(
      SizedBox(
        width: 280,
        child: OiKeyValue.group(
          dividers: false,
          children: const [
            OiKeyValue(
              label: 'Total',
              value: '€41.31',
              direction: Axis.horizontal,
              valueAtEnd: true,
              padding: EdgeInsets.zero,
              labelWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total'),
                  Text('Includes tax and delivery charges'),
                ],
              ),
              valueWidget: Text('€41.31', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
    expect(find.text('Includes tax and delivery charges'), findsOneWidget);
    final row = tester.widget<OiKeyValue>(find.byType(OiKeyValue));
    expect(row.valueAtEnd, isTrue);
    expect(row.padding, EdgeInsets.zero);
    expect(
      tester.getTopLeft(find.text('€41.31')).dx,
      greaterThan(tester.getTopLeft(find.text('Total')).dx),
    );
    expect(
      tester.getBottomRight(find.text('€41.31')).dx,
      closeTo(tester.getBottomRight(find.byType(OiKeyValue)).dx, .1),
    );
    expect(tester.takeException(), isNull);
  });

  // ── Rendering ─────────────────────────────────────────────────────────────

  testWidgets('renders label and value', (tester) async {
    await tester.pumpObers(const OiKeyValue(label: 'Name', value: 'John Doe'));
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
  });

  testWidgets('shows emptyText when value is null', (tester) async {
    await tester.pumpObers(const OiKeyValue(label: 'Email', value: null));
    expect(find.text('---'), findsOneWidget);
  });

  testWidgets('shows custom emptyText', (tester) async {
    await tester.pumpObers(
      const OiKeyValue(label: 'Phone', value: null, emptyText: 'Not provided'),
    );
    expect(find.text('Not provided'), findsOneWidget);
  });

  testWidgets('empty string value shows emptyText', (tester) async {
    await tester.pumpObers(const OiKeyValue(label: 'Field', value: ''));
    expect(find.text('---'), findsOneWidget);
  });

  // ── Copyable ──────────────────────────────────────────────────────────────

  testWidgets('copyable wraps value in OiCopyable', (tester) async {
    await tester.pumpObers(
      const OiKeyValue(label: 'ID', value: 'abc-123', copyable: true),
    );
    expect(find.text('abc-123'), findsOneWidget);
  });

  // ── Tap ───────────────────────────────────────────────────────────────────

  testWidgets('onTap makes row tappable', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiKeyValue(
        label: 'Link',
        value: 'example.com',
        onTap: () => tapped = true,
      ),
    );
    await tester.tap(find.text('example.com'));
    expect(tapped, isTrue);
  });

  // ── Value widget ──────────────────────────────────────────────────────────

  testWidgets('valueWidget overrides text value', (tester) async {
    await tester.pumpObers(
      const OiKeyValue(
        label: 'Status',
        value: 'active',
        valueWidget: OiBadge.filled(label: 'Active'),
      ),
    );
    expect(find.byType(OiBadge), findsOneWidget);
  });

  // ── Direction ─────────────────────────────────────────────────────────────

  testWidgets('horizontal direction renders correctly', (tester) async {
    await tester.pumpObers(
      const OiKeyValue(
        label: 'Name',
        value: 'John',
        direction: Axis.horizontal,
      ),
    );
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('John'), findsOneWidget);
  });

  testWidgets('vertical direction renders correctly', (tester) async {
    await tester.pumpObers(
      const OiKeyValue(label: 'Name', value: 'John', direction: Axis.vertical),
    );
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('John'), findsOneWidget);
  });

  // ── Leading / Trailing ────────────────────────────────────────────────────

  testWidgets('leading widget renders', (tester) async {
    await tester.pumpObers(
      const OiKeyValue(
        label: 'Email',
        value: 'john@example.com',
        leading: OiIcon.decorative(icon: IconData(0xe800)),
      ),
    );
    expect(find.byType(OiIcon), findsOneWidget);
  });

  testWidgets('trailing widget renders', (tester) async {
    await tester.pumpObers(
      OiKeyValue(
        label: 'Role',
        value: 'Admin',
        trailing: OiIconButton(
          icon: OiIcons.pencil,
          semanticLabel: 'Edit',
          onTap: () {},
        ),
      ),
    );
    expect(find.byType(OiIconButton), findsOneWidget);
  });

  // ── Group ─────────────────────────────────────────────────────────────────

  testWidgets('group renders multiple rows with dividers', (tester) async {
    await tester.pumpObers(
      OiKeyValue.group(
        children: const [
          OiKeyValue(label: 'Name', value: 'John'),
          OiKeyValue(label: 'Email', value: 'john@test.com'),
          OiKeyValue(label: 'Role', value: 'Admin'),
        ],
      ),
    );
    expect(find.byType(OiKeyValue), findsNWidgets(3));
    // 2 dividers between 3 items.
    expect(find.byType(Container), findsAtLeast(2));
  });

  testWidgets('group with title renders section header', (tester) async {
    await tester.pumpObers(
      OiKeyValue.group(
        title: 'Contact Info',
        children: const [OiKeyValue(label: 'Name', value: 'John')],
      ),
    );
    expect(find.text('Contact Info'), findsOneWidget);
  });

  testWidgets('group with wrapInCard wraps in OiCard', (tester) async {
    await tester.pumpObers(
      OiKeyValue.group(
        wrapInCard: true,
        children: const [OiKeyValue(label: 'Name', value: 'John')],
      ),
    );
    expect(find.byType(OiCard), findsOneWidget);
  });

  // ── Dense ─────────────────────────────────────────────────────────────────

  testWidgets('dense mode renders', (tester) async {
    await tester.pumpObers(
      const OiKeyValue(label: 'X', value: 'Y', dense: true),
    );
    final kv = tester.widget<OiKeyValue>(find.byType(OiKeyValue));
    expect(kv.dense, isTrue);
  });
}
