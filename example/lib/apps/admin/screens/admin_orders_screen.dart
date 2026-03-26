import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_dashboard.dart';

/// Orders table screen showing recent shop orders.
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  Map<String, OiColumnFilter> _activeFilters = {};

  // ── Status helpers ──────────────────────────────────────────────────────

  OiBadgeColor _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return OiBadgeColor.info;
      case 'shipped':
        return OiBadgeColor.warning;
      case 'delivered':
        return OiBadgeColor.success;
      case 'returned':
        return OiBadgeColor.error;
      case 'pending':
      default:
        return OiBadgeColor.neutral;
    }
  }

  /// Maps a status string to a zero-based step index for the stepper.
  int _statusToStep(String status) {
    switch (status) {
      case 'confirmed':
        return 1;
      case 'shipped':
        return 2;
      case 'delivered':
        return 3;
      case 'returned':
        return 3;
      case 'pending':
      default:
        return 0;
    }
  }

  /// Returns the set of completed step indices for the given status.
  Set<int> _completedSteps(String status) {
    switch (status) {
      case 'confirmed':
        return {0};
      case 'shipped':
        return {0, 1};
      case 'delivered':
        return {0, 1, 2, 3};
      case 'returned':
        return {0, 1, 2};
      case 'pending':
      default:
        return {};
    }
  }

  /// Returns error step indices (only for returned orders).
  Set<int> _errorSteps(String status) {
    if (status == 'returned') return {3};
    return {};
  }

  // ── Filter definitions ──────────────────────────────────────────────────

  static const _filterDefinitions = <OiFilterDefinition>[
    OiFilterDefinition(
      key: 'status',
      label: 'Status',
      type: OiFilterType.select,
      options: [
        OiSelectOption(value: 'pending', label: 'Pending'),
        OiSelectOption(value: 'confirmed', label: 'Confirmed'),
        OiSelectOption(value: 'shipped', label: 'Shipped'),
        OiSelectOption(value: 'delivered', label: 'Delivered'),
        OiSelectOption(value: 'returned', label: 'Returned'),
      ],
    ),
    OiFilterDefinition(
      key: 'date',
      label: 'Date',
      type: OiFilterType.dateRange,
    ),
    OiFilterDefinition(
      key: 'customer',
      label: 'Customer',
      type: OiFilterType.text,
    ),
  ];

  // ── Filtered rows ───────────────────────────────────────────────────────

  List<Map<String, Object>> get _filteredOrders {
    var orders = kMockOrders;

    final statusFilter = _activeFilters['status'];
    if (statusFilter != null && statusFilter.value != null) {
      final statusValue = statusFilter.value as String;
      if (statusValue.isNotEmpty) {
        orders = orders.where((o) => o['status'] == statusValue).toList();
      }
    }

    final customerFilter = _activeFilters['customer'];
    if (customerFilter != null && customerFilter.value != null) {
      final query = (customerFilter.value as String).toLowerCase();
      if (query.isNotEmpty) {
        orders = orders
            .where(
              (o) => (o['customer']! as String).toLowerCase().contains(query),
            )
            .toList();
      }
    }

    return orders;
  }

  // ── Sheet ───────────────────────────────────────────────────────────────

  void _openOrderSheet(Map<String, Object> order) {
    final spacing = context.spacing;
    final status = order['status']! as String;
    final lineItems = order['lineItems']! as List<Map<String, Object>>;

    OiSheet.show(
      context,
      label: 'Order ${order['orderNumber']}',
      side: OiPanelSide.right,
      size: 480,
      onClose: () {},
      child: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──
            OiLabel.h3('Order ${order['orderNumber']}'),
            SizedBox(height: spacing.sm),
            OiBadge.soft(label: status, color: _statusColor(status)),
            SizedBox(height: spacing.lg),

            // ── Stepper: order progress ──
            const OiLabel.caption('Order Progress'),
            SizedBox(height: spacing.sm),
            OiStepper(
              totalSteps: 4,
              currentStep: _statusToStep(status),
              completedSteps: _completedSteps(status),
              errorSteps: _errorSteps(status),
              stepLabels: const ['Placed', 'Confirmed', 'Shipped', 'Delivered'],
            ),
            SizedBox(height: spacing.lg),

            // ── Detail view: order metadata ──
            OiDetailView(
              label: 'Order details',
              sections: [
                OiDetailSection(
                  title: 'Order Information',
                  fields: [
                    OiDetailField(
                      label: 'Customer',
                      value: order['customer']! as String,
                    ),
                    OiDetailField(
                      label: 'Date',
                      value: order['date']! as String,
                    ),
                    OiDetailField(
                      label: 'Payment Method',
                      value: order['paymentMethod']! as String,
                    ),
                    OiDetailField(
                      label: 'Shipping Address',
                      value: order['shippingAddress']! as String,
                    ),
                    OiDetailField(
                      label: 'Total',
                      value: order['total']! as String,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: spacing.lg),

            // ── Line items table ──
            const OiLabel.smallStrong('Line Items'),
            SizedBox(height: spacing.sm),
            SizedBox(
              height: (lineItems.length * 48.0) + 56,
              child: OiTable<Map<String, Object>>(
                label: 'Line items for ${order['orderNumber']}',
                rows: lineItems,
                columns: [
                  OiTableColumn<Map<String, Object>>(
                    id: 'product',
                    header: 'Product',
                    valueGetter: (row) => row['product']! as String,
                  ),
                  OiTableColumn<Map<String, Object>>(
                    id: 'quantity',
                    header: 'Qty',
                    valueGetter: (row) => '${row['quantity']}',
                  ),
                  OiTableColumn<Map<String, Object>>(
                    id: 'unitPrice',
                    header: 'Unit Price',
                    valueGetter: (row) =>
                        '\u20AC${(row['unitPrice']! as double).toStringAsFixed(2)}',
                  ),
                  OiTableColumn<Map<String, Object>>(
                    id: 'total',
                    header: 'Total',
                    valueGetter: (row) =>
                        '\u20AC${(row['total']! as double).toStringAsFixed(2)}',
                  ),
                ],
                showStatusBar: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _filteredOrders;

    return OiResourcePage(
      label: 'Orders',
      title: 'Orders',
      filters: OiFilterBar(
        filters: _filterDefinitions,
        activeFilters: _activeFilters,
        onFilterChange: (filters) {
          setState(() => _activeFilters = filters);
        },
      ),
      child: OiTable<Map<String, Object>>(
        label: 'Recent orders',
        rows: filteredOrders,
        paginationMode: OiTablePaginationMode.pages,
        onRowTap: (row, _) => _openOrderSheet(row),
        columns: [
          OiTableColumn<Map<String, Object>>(
            id: 'orderNumber',
            header: 'Order #',
            valueGetter: (row) => row['orderNumber']! as String,
          ),
          OiTableColumn<Map<String, Object>>(
            id: 'customer',
            header: 'Customer',
            valueGetter: (row) => row['customer']! as String,
          ),
          OiTableColumn<Map<String, Object>>(
            id: 'items',
            header: 'Items',
            valueGetter: (row) => '${row['items']}',
          ),
          OiTableColumn<Map<String, Object>>(
            id: 'total',
            header: 'Total',
            valueGetter: (row) => row['total']! as String,
          ),
          OiTableColumn<Map<String, Object>>(
            id: 'status',
            header: 'Status',
            valueGetter: (row) => row['status']! as String,
            cellBuilder: (context, row, _) => OiBadge.soft(
              label: row['status']! as String,
              color: _statusColor(row['status']! as String),
            ),
          ),
          OiTableColumn<Map<String, Object>>(
            id: 'date',
            header: 'Date',
            valueGetter: (row) => row['date']! as String,
          ),
        ],
      ),
    );
  }
}
