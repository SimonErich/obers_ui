import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../helpers/knob_helpers.dart';

List<OiDashboardCard> _buildSampleCards() => [
      OiDashboardCard(
        key: 'revenue',
        title: 'Revenue',
        child: Center(
          child: Text(
            '\$24,500',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      OiDashboardCard(
        key: 'users',
        title: 'Active Users',
        child: Center(
          child: Text(
            '1,284',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      OiDashboardCard(
        key: 'orders',
        title: 'Orders Today',
        columnSpan: 2,
        child: Center(
          child: Text(
            '156 orders processed',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      OiDashboardCard(
        key: 'chart',
        title: 'Sales Trend',
        columnSpan: 2,
        rowSpan: 2,
        child: const Center(child: Text('Chart placeholder')),
      ),
      OiDashboardCard(
        key: 'tasks',
        title: 'Pending Tasks',
        child: const Center(child: Text('12 tasks remaining')),
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
        final editable = context.knobs.boolean(
          label: 'Editable',
          initialValue: false,
        );

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
