import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiVisualizationComponent = WidgetbookComponent(
  name: 'Visualization',
  useCases: [
    WidgetbookUseCase(
      name: 'OiGauge',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 250,
            height: 250,
            child: OiGauge(
              label: 'Speed gauge',
              value: 72,
              segments: const [
                OiGaugeSegment(
                  from: 0,
                  to: 40,
                  color: Color(0xFF16A34A),
                  label: 'Low',
                ),
                OiGaugeSegment(
                  from: 40,
                  to: 75,
                  color: Color(0xFFEAB308),
                  label: 'Medium',
                ),
                OiGaugeSegment(
                  from: 75,
                  to: 100,
                  color: Color(0xFFDC2626),
                  label: 'High',
                ),
              ],
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiFunnelChart',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 300,
            height: 300,
            child: OiFunnelChart(
              label: 'Sales funnel',
              stages: const [
                OiFunnelStage(label: 'Visitors', value: 1000),
                OiFunnelStage(label: 'Leads', value: 600),
                OiFunnelStage(label: 'Prospects', value: 300),
                OiFunnelStage(label: 'Customers', value: 100),
              ],
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiHeatmap',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 350,
            height: 250,
            child: OiHeatmap(
              label: 'Activity heatmap',
              rowLabels: const ['Mon', 'Tue', 'Wed'],
              columnLabels: const ['9am', '12pm', '3pm', '6pm'],
              cells: const [
                OiHeatmapCell(row: 0, column: 0, value: 3),
                OiHeatmapCell(row: 0, column: 1, value: 7),
                OiHeatmapCell(row: 0, column: 2, value: 5),
                OiHeatmapCell(row: 0, column: 3, value: 2),
                OiHeatmapCell(row: 1, column: 0, value: 8),
                OiHeatmapCell(row: 1, column: 1, value: 4),
                OiHeatmapCell(row: 1, column: 2, value: 9),
                OiHeatmapCell(row: 1, column: 3, value: 1),
                OiHeatmapCell(row: 2, column: 0, value: 6),
                OiHeatmapCell(row: 2, column: 1, value: 2),
                OiHeatmapCell(row: 2, column: 2, value: 4),
                OiHeatmapCell(row: 2, column: 3, value: 7),
              ],
              showValues: true,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiRadarChart',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 300,
            height: 300,
            child: OiRadarChart(
              label: 'Skills radar',
              axes: const ['Speed', 'Power', 'Defense', 'Stamina', 'Agility'],
              series: const [
                OiRadarSeries(
                  label: 'Player A',
                  values: [80, 60, 70, 90, 85],
                ),
                OiRadarSeries(
                  label: 'Player B',
                  values: [65, 85, 55, 70, 75],
                ),
              ],
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiSankey',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 500,
            height: 300,
            child: OiSankey(
              label: 'Flow diagram',
              nodes: const [
                OiSankeyNode(key: 'a', label: 'Source A'),
                OiSankeyNode(key: 'b', label: 'Source B'),
                OiSankeyNode(key: 'c', label: 'Process'),
                OiSankeyNode(key: 'd', label: 'Output'),
              ],
              links: const [
                OiSankeyLink(source: 'a', target: 'c', value: 30),
                OiSankeyLink(source: 'b', target: 'c', value: 20),
                OiSankeyLink(source: 'c', target: 'd', value: 50),
              ],
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiTreemap',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 400,
            height: 300,
            child: OiTreemap(
              label: 'Disk usage',
              nodes: const [
                OiTreemapNode(key: 'docs', label: 'Documents', value: 40),
                OiTreemapNode(key: 'photos', label: 'Photos', value: 30),
                OiTreemapNode(key: 'music', label: 'Music', value: 20),
                OiTreemapNode(key: 'other', label: 'Other', value: 10),
              ],
              showValues: true,
            ),
          ),
        );
      },
    ),
  ],
);
