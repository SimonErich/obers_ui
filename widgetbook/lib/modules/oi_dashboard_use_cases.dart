import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

List<OiDashboardCard> _buildSampleCards() => [
  const OiDashboardCard(
    key: 'revenue',
    title: 'Revenue',
    child: Center(
      child: Text(
        r'$24,500',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
      ),
    ),
  ),
  const OiDashboardCard(
    key: 'users',
    title: 'Active Users',
    child: Center(
      child: Text(
        '1,284',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
      ),
    ),
  ),
  const OiDashboardCard(
    key: 'orders',
    title: 'Orders Today',
    columnSpan: 2,
    child: Center(
      child: Text('156 orders processed', style: TextStyle(fontSize: 16)),
    ),
  ),
  const OiDashboardCard(
    key: 'chart',
    title: 'Sales Trend',
    columnSpan: 2,
    rowSpan: 2,
    child: Center(child: Text('Chart placeholder')),
  ),
  const OiDashboardCard(
    key: 'tasks',
    title: 'Pending Tasks',
    child: Center(child: Text('12 tasks remaining')),
  ),
];

final oiDashboardComponent = WidgetbookComponent(
  name: 'OiDashboard',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final columns = context.knobs.int.slider(
          label: 'Columns',
          initialValue: 4,
          min: 1,
          max: 6,
        );
        final editable = context.knobs.boolean(label: 'Editable');

        return useCaseWrapper(
          SizedBox(
            height: 600,
            width: 900,
            child: OiDashboard(
              cards: _buildSampleCards(),
              label: 'Dashboard',
              columns: columns,
              editable: editable,
              onLayoutChange: (_) {},
            ),
          ),
        );
      },
    ),
  ],
);
