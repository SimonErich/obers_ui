import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_dashboard.dart';

/// Showcases [OiPipeline] and [OiTable] for return request management.
class AdminReturnsScreen extends StatefulWidget {
  const AdminReturnsScreen({super.key});

  @override
  State<AdminReturnsScreen> createState() => _AdminReturnsScreenState();
}

class _AdminReturnsScreenState extends State<AdminReturnsScreen> {
  int _selectedIndex = 0;

  int _statusIndex(String status) {
    final idx = kReturnStatuses.indexOf(status);
    return idx < 0 ? 0 : idx;
  }

  List<OiPipelineStage> _buildPipeline() {
    final selected = kMockReturns[_selectedIndex];
    final currentIdx = _statusIndex(selected['status']! as String);

    return [
      for (var i = 0; i < kReturnStatuses.length; i++)
        OiPipelineStage(
          label: _statusLabel(kReturnStatuses[i]),
          status: i < currentIdx
              ? OiPipelineStatus.completed
              : i == currentIdx
              ? OiPipelineStatus.running
              : OiPipelineStatus.pending,
        ),
    ];
  }

  String _statusLabel(String status) => switch (status) {
    'requested' => 'Requested',
    'approved' => 'Approved',
    'shipped-back' => 'Shipped Back',
    'inspected' => 'Inspected',
    'refunded' => 'Refunded',
    _ => status,
  };

  OiBadgeColor _statusBadgeColor(String status) => switch (status) {
    'refunded' => OiBadgeColor.success,
    'approved' => OiBadgeColor.info,
    'shipped-back' => OiBadgeColor.warning,
    'requested' => OiBadgeColor.accent,
    _ => OiBadgeColor.neutral,
  };

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OiLabel.h3('Returns'),
          SizedBox(height: spacing.xs),
          const OiLabel.caption('Return workflow and request management.'),
          SizedBox(height: spacing.lg),
          // Pipeline visualization for selected return.
          OiCard(
            label: 'Return workflow',
            child: Padding(
              padding: EdgeInsets.all(spacing.md),
              child: OiPipeline(
                label: 'Return workflow',
                stages: _buildPipeline(),
              ),
            ),
          ),
          SizedBox(height: spacing.lg),
          // Return requests table.
          OiTable<Map<String, Object>>(
            label: 'Return requests',
            rows: kMockReturns,
            rowKey: (row) => row['returnId']! as String,
            onRowTap: (row, index) => setState(() => _selectedIndex = index),
            striped: true,
            columns: [
              OiTableColumn(
                id: 'returnId',
                header: 'Return ID',
                valueGetter: (row) => row['returnId']! as String,
                width: 100,
              ),
              OiTableColumn(
                id: 'orderId',
                header: 'Order',
                valueGetter: (row) => row['orderId']! as String,
                width: 140,
              ),
              OiTableColumn(
                id: 'customer',
                header: 'Customer',
                valueGetter: (row) => row['customer']! as String,
              ),
              OiTableColumn(
                id: 'reason',
                header: 'Reason',
                valueGetter: (row) => row['reason']! as String,
              ),
              OiTableColumn(
                id: 'status',
                header: 'Status',
                valueGetter: (row) => row['status']! as String,
                cellBuilder: (ctx, row, _) {
                  final status = row['status']! as String;
                  return OiBadge.soft(
                    label: _statusLabel(status),
                    color: _statusBadgeColor(status),
                  );
                },
                width: 130,
              ),
              OiTableColumn(
                id: 'refundAmount',
                header: 'Refund',
                valueGetter: (row) => row['refundAmount']! as String,
                width: 100,
              ),
              OiTableColumn(
                id: 'requestDate',
                header: 'Requested',
                valueGetter: (row) => row['requestDate']! as String,
                width: 120,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
