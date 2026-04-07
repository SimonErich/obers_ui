import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

import 'package:obers_ui_example/data/mock_dashboard.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

String _eur(double amount) => '\u20AC${amount.toStringAsFixed(2)}';

OiBadgeColor _statusColor(String status) => switch (status) {
  'confirmed' => OiBadgeColor.info,
  'shipped' => OiBadgeColor.warning,
  'delivered' => OiBadgeColor.success,
  'returned' => OiBadgeColor.error,
  _ => OiBadgeColor.neutral,
};

int _statusToStep(String status) => switch (status) {
  'confirmed' => 1,
  'shipped' => 2,
  'delivered' || 'returned' => 3,
  _ => 0,
};

Set<int> _completedSteps(String status) => switch (status) {
  'confirmed' => {0},
  'shipped' => {0, 1},
  'delivered' => {0, 1, 2, 3},
  'returned' => {0, 1, 2},
  _ => {},
};

Set<int> _errorSteps(String status) =>
    status == 'returned' ? {3} : {};

// ── Field enum ──────────────────────────────────────────────────────────────

enum _OrderField { customer, address, paymentMethod, product, quantity }

// ── Options ─────────────────────────────────────────────────────────────────

const _paymentOptions = [
  OiAfOption(value: 'Visa', label: 'Visa'),
  OiAfOption(value: 'EPS Bank Transfer', label: 'EPS Bank Transfer'),
  OiAfOption(value: 'Klarna', label: 'Klarna'),
  OiAfOption(value: 'Nachnahme', label: 'Nachnahme'),
];

const _productCatalog = <Map<String, Object>>[
  {'name': 'Original Sacher-Torte', 'price': 38.90},
  {'name': 'Mozartkugeln Gift Box (24 pcs)', 'price': 29.90},
  {'name': 'Alpine Hiking Boot "Gipfelstürmer"', 'price': 289.00},
  {'name': 'Viennese Coffee Set', 'price': 64.90},
  {'name': 'Almdudler Party Pack', 'price': 18.90},
  {'name': 'Zillertaler Graukäse', 'price': 24.90},
  {'name': 'Wiener Schnitzel Home Kit', 'price': 34.50},
  {'name': 'Lederhosen "Bergkönig"', 'price': 189.00},
  {'name': 'Dirndl "Almsommer"', 'price': 159.00},
];

List<OiAfOption<String>> get _productOptions => [
      for (final p in _productCatalog)
        OiAfOption(
          value: p['name']! as String,
          label:
              '${p['name']} (${_eur(p['price']! as double)})',
        ),
    ];

// ── Controller ──────────────────────────────────────────────────────────────

class _CreateOrderController
    extends OiAfController<_OrderField, Map<String, dynamic>> {
  final lineItems = <Map<String, Object>>[];

  @override
  void defineFields() {
    // Step 1 — Customer
    addTextField(_OrderField.customer, required: true);
    addTextField(_OrderField.address, required: true);
    addSelectField<String>(
      _OrderField.paymentMethod,
      required: true,
      options: _paymentOptions,
    );

    // Step 2 — Items (used for the add-item form within step 2)
    addSelectField<String>(
      _OrderField.product,
      options: _productOptions,
    );
    addNumberField(
      _OrderField.quantity,
      initialValue: 1,
      min: 1,
      max: 99,
    );
  }

  @override
  Map<String, dynamic> buildData() => json();

  double get orderTotal {
    var total = 0.0;
    for (final item in lineItems) {
      total += item['total']! as double;
    }
    return total;
  }

  void addCurrentItem() {
    final productName = get<String>(_OrderField.product);
    if (productName == null) return;
    final product = _productCatalog.firstWhere(
      (p) => p['name'] == productName,
    );
    final unitPrice = product['price']! as double;
    final qty = getOr<num>(_OrderField.quantity, 1).toInt();
    lineItems.add(<String, Object>{
      'product': productName,
      'quantity': qty,
      'unitPrice': unitPrice,
      'total': unitPrice * qty,
    });
    set(_OrderField.product, null);
    set(_OrderField.quantity, 1);
    notifyListeners();
  }

  void removeItem(int index) {
    lineItems.removeAt(index);
    notifyListeners();
  }

  Future<bool> validateStep(int step) async {
    final fields = _fieldsForStep(step);
    final results = await Future.wait(
      fields.map((f) => validate(field: f)),
    );
    return results.every((r) => r);
  }

  static List<_OrderField> _fieldsForStep(int step) {
    switch (step) {
      case 0:
        return [
          _OrderField.customer,
          _OrderField.address,
          _OrderField.paymentMethod,
        ];
      case 1:
        return [];
      default:
        return [];
    }
  }
}

// ── Screen ──────────────────────────────────────────────────────────────────

/// Orders table screen showing recent shop orders.
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  Map<String, OiColumnFilter> _activeFilters = {};
  List<Map<String, Object>> _orders = List<Map<String, Object>>.of(kMockOrders);
  var _orderCounter = kMockOrders.length;

  // ── Filter definitions ────────────────────────────────────────────────

  static const _filterDefinitions = <OiFilterDefinition>[
    OiFilterDefinition(
      key: 'status',
      label: 'Status',
      type: OiFilterType.multiSelect,
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
      type: OiFilterType.date,
    ),
    OiFilterDefinition(
      key: 'customer',
      label: 'Customer',
      type: OiFilterType.text,
      suggestions: [
        'Maria Hinterberger',
        'Thomas Oberhuber',
        'Eva Schneider',
        'Karl Huber',
        'Sophie Maier',
        'Florian Berger',
        'Anna Gruber',
        'Lukas Wagner',
        'Christina Bauer',
        'Michael Pichler',
        'Sabine Hofer',
        'Andreas Steiner',
      ],
    ),
  ];

  // ── Filtered rows ─────────────────────────────────────────────────────

  List<Map<String, Object>> get _filteredOrders {
    var orders = _orders;

    final statusFilter = _activeFilters['status'];
    if (statusFilter != null && statusFilter.value != null) {
      final statusValues = statusFilter.value as List<String>;
      if (statusValues.isNotEmpty) {
        orders = orders
            .where((o) => statusValues.contains(o['status']))
            .toList();
      }
    }

    final dateFilter = _activeFilters['date'];
    if (dateFilter != null && dateFilter.value is DateTime) {
      final selectedDate = dateFilter.value as DateTime;
      final dateStr =
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      orders = orders.where((o) => o['date'] == dateStr).toList();
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

  // ── Create order dialog ───────────────────────────────────────────────

  void _openCreateOrderDialog() {
    final controller = _CreateOrderController();
    var currentStep = 0;
    final completedSteps = <int>{};

    const stepLabels = [
      'Customer Information',
      'Line Items',
      'Review & Confirm',
    ];

    showOiDialog<Map<String, Object>>(
      context,
      dismissible: false,
      builder: (_, close) => StatefulBuilder(
        builder: (context, setDialogState) {
          final spacing = context.spacing;

          Future<void> goNext() async {
            final valid = await controller.validateStep(currentStep);
            if (!valid) return;
            if (currentStep < 2) {
              setDialogState(() {
                completedSteps.add(currentStep);
                currentStep++;
              });
            }
          }

          void goBack() {
            if (currentStep > 0) {
              setDialogState(() => currentStep--);
            }
          }

          void submit() {
            final data = controller.buildData();
            _orderCounter++;
            final orderNumber =
                'AG-2026-${_orderCounter.toString().padLeft(4, '0')}';
            close(<String, Object>{
              'orderNumber': orderNumber,
              'customer': data['customer'] as String,
              'items': controller.lineItems.length,
              'total': _eur(controller.orderTotal),
              'status': 'pending',
              'date': DateTime.now().toIso8601String().substring(0, 10),
              'paymentMethod': data['paymentMethod'] as String,
              'shippingAddress': data['address'] as String,
              'lineItems':
                  List<Map<String, Object>>.of(controller.lineItems),
            });
          }

          return OiDialog.form(
            label: 'Create order',
            title: 'Create Order',
            onClose: () => close(),
            content: SizedBox(
              width: 480,
              child: OiAfForm<_OrderField, Map<String, dynamic>>(
                controller: controller,
                autofocusFirstField: true,
                onSubmit: (_, __) async {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OiStepper(
                      totalSteps: 3,
                      currentStep: currentStep,
                      completedSteps: completedSteps,
                      stepLabels: stepLabels,
                    ),
                    SizedBox(height: spacing.md),

                    // ── Step content ──
                    if (currentStep == 0) ...[
                      const OiAfTextInput<_OrderField>(
                        field: _OrderField.customer,
                        label: 'Customer Name',
                        placeholder: 'e.g. Maria Hinterberger',
                      ),
                      SizedBox(height: spacing.md),
                      const OiAfTextInput<_OrderField>(
                        field: _OrderField.address,
                        label: 'Shipping Address',
                        placeholder:
                            'e.g. Getreidegasse 12, 5020 Salzburg',
                      ),
                      SizedBox(height: spacing.md),
                      const OiAfSelect<_OrderField, String>(
                        field: _OrderField.paymentMethod,
                        label: 'Payment Method',
                        placeholder: 'Select payment method',
                        options: _paymentOptions,
                      ),
                    ],

                    if (currentStep == 1)
                      ListenableBuilder(
                        listenable: controller,
                        builder: (context, _) => _buildItemsStep(
                          context,
                          controller,
                          setDialogState,
                        ),
                      ),

                    if (currentStep == 2)
                      ListenableBuilder(
                        listenable: controller,
                        builder: (context, _) =>
                            _buildReviewStep(context, controller),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              if (currentStep > 0)
                OiButton.secondary(
                  label: 'Back',
                  icon: OiIcons.chevronLeft,
                  onTap: goBack,
                ),
              const Spacer(),
              OiButton.ghost(
                label: 'Cancel',
                onTap: () => close(),
              ),
              if (currentStep < 2)
                OiButton.primary(
                  label: 'Next',
                  icon: OiIcons.chevronRight,
                  onTap: goNext,
                )
              else
                ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) => OiButton.primary(
                    label: 'Create Order',
                    icon: OiIcons.check,
                    enabled: controller.lineItems.isNotEmpty,
                    onTap: submit,
                  ),
                ),
            ],
          );
        },
      ),
    ).then((newOrder) {
      if (newOrder != null && mounted) {
        setState(() {
          _orders = [newOrder, ..._orders];
        });
        OiToast.show(
          context,
          message: "Order ${newOrder['orderNumber']} created",
          level: OiToastLevel.success,
        );
      }
    });
  }

  Widget _buildItemsStep(
    BuildContext context,
    _CreateOrderController controller,
    StateSetter setDialogState,
  ) {
    final spacing = context.spacing;
    final colors = context.colors;
    final selectedProduct = controller.get<String>(_OrderField.product);
    final qty = controller.getOr<num>(_OrderField.quantity, 1).toInt();

    // Look up unit price for the subtotal preview.
    var unitPrice = 0.0;
    if (selectedProduct != null) {
      final product = _productCatalog.cast<Map<String, Object>?>().firstWhere(
            (p) => p!['name'] == selectedProduct,
            orElse: () => null,
          );
      if (product != null) unitPrice = product['price']! as double;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Add item form ──
        OiCard(
          child: Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OiAfSelect<_OrderField, String>(
                  field: _OrderField.product,
                  label: 'Product',
                  placeholder: 'Select a product',
                  options: _productOptions,
                ),
                SizedBox(height: spacing.sm),
                const OiAfNumberInput<_OrderField>(
                  field: _OrderField.quantity,
                  label: 'Quantity',
                  min: 1,
                  max: 99,
                ),
                if (selectedProduct != null) ...[
                  SizedBox(height: spacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OiLabel.body(
                      'Subtotal: ${_eur(unitPrice * qty)}',
                    ),
                  ),
                ],
                SizedBox(height: spacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: OiButton.outline(
                    label: 'Add Item',
                    icon: OiIcons.plus,
                    size: OiButtonSize.small,
                    enabled: selectedProduct != null,
                    onTap: () => setDialogState(controller.addCurrentItem),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: spacing.md),

        // ── Item list ──
        if (controller.lineItems.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.lg),
            child: Center(
              child: OiLabel.small(
                'No items added yet.',
                color: colors.textMuted,
              ),
            ),
          )
        else ...[
          for (var i = 0; i < controller.lineItems.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: spacing.sm),
              child: _LineItemRow(
                item: controller.lineItems[i],
                onRemove: () =>
                    setDialogState(() => controller.removeItem(i)),
              ),
            ),
          SizedBox(height: spacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: OiLabel.bodyStrong(
              'Total: ${_eur(controller.orderTotal)}',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewStep(
    BuildContext context,
    _CreateOrderController controller,
  ) {
    final spacing = context.spacing;
    final data = controller.buildData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        OiDetailView(
          label: 'Order review',
          sections: [
            OiDetailSection(
              title: 'Customer',
              fields: [
                OiDetailField(
                  label: 'Name',
                  value: data['customer'] as String? ?? '',
                ),
                OiDetailField(
                  label: 'Address',
                  value: data['address'] as String? ?? '',
                ),
                OiDetailField(
                  label: 'Payment',
                  value: data['paymentMethod'] as String? ?? '',
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: spacing.md),
        const OiLabel.smallStrong('Items'),
        SizedBox(height: spacing.sm),
        for (final item in controller.lineItems)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: OiLabel.body(item['product']! as String),
                ),
                OiLabel.body(
                  '${item['quantity']}x ${_eur(item['unitPrice']! as double)}',
                ),
                SizedBox(width: spacing.md),
                OiLabel.bodyStrong(
                  _eur(item['total']! as double),
                ),
              ],
            ),
          ),
        SizedBox(height: spacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: OiLabel.h4(
            'Total: ${_eur(controller.orderTotal)}',
          ),
        ),
      ],
    );
  }

  // ── Detail sheet ──────────────────────────────────────────────────────

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
            OiLabel.h3('Order ${order['orderNumber']}'),
            SizedBox(height: spacing.sm),
            OiBadge.soft(label: status, color: _statusColor(status)),
            SizedBox(height: spacing.lg),
            const OiLabel.caption('Order Progress'),
            SizedBox(height: spacing.sm),
            OiStepper(
              totalSteps: 4,
              currentStep: _statusToStep(status),
              completedSteps: _completedSteps(status),
              errorSteps: _errorSteps(status),
              stepLabels: const [
                'Placed',
                'Confirmed',
                'Shipped',
                'Delivered',
              ],
            ),
            SizedBox(height: spacing.lg),
            OiDetailView(
              label: 'Order details',
              labelWidth: 150,
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
                        _eur(row['unitPrice']! as double),
                  ),
                  OiTableColumn<Map<String, Object>>(
                    id: 'total',
                    header: 'Total',
                    valueGetter: (row) =>
                        _eur(row['total']! as double),
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

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _filteredOrders;

    return OiResourcePage(
      label: 'Orders',
      title: 'Orders',
      wrapInCard: false,
      onAction: (action) {
        if (action == 'create') _openCreateOrderDialog();
      },
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
            width: 150,
          ),
          OiTableColumn<Map<String, Object>>(
            id: 'customer',
            header: 'Customer',
            valueGetter: (row) => row['customer']! as String,
            width: 220,
          ),
          OiTableColumn<Map<String, Object>>(
            id: 'items',
            header: 'Items',
            valueGetter: (row) => '${row['items']}',
            width: 80,
          ),
          OiTableColumn<Map<String, Object>>(
            id: 'total',
            header: 'Total',
            valueGetter: (row) => row['total']! as String,
            width: 120,
          ),
          OiTableColumn<Map<String, Object>>(
            id: 'status',
            header: 'Status',
            valueGetter: (row) => row['status']! as String,
            cellBuilder: (_, row, __) {
              final status = row['status']! as String;
              return OiBadge.soft(
                label: status,
                color: _statusColor(status),
              );
            },
            width: 130,
          ),
          OiTableColumn<Map<String, Object>>(
            id: 'date',
            header: 'Date',
            valueGetter: (row) => row['date']! as String,
            width: 120,
          ),
        ],
      ),
    );
  }
}

// ── Line item row ───────────────────────────────────────────────────────────

class _LineItemRow extends StatelessWidget {
  const _LineItemRow({required this.item, required this.onRemove});

  final Map<String, Object> item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OiLabel.body(item['product']! as String),
              OiLabel.caption(
                '${item['quantity']}x ${_eur(item['unitPrice']! as double)}'
                ' = ${_eur(item['total']! as double)}',
              ),
            ],
          ),
        ),
        SizedBox(width: spacing.sm),
        OiButton.ghost(
          label: 'Remove',
          icon: OiIcons.trash2,
          size: OiButtonSize.small,
          onTap: onRemove,
        ),
      ],
    );
  }
}
