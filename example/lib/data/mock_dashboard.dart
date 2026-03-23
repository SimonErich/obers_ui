import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_users.dart';

// ── Metric card data ────────────────────────────────────────────────────────

/// A single dashboard metric with trend information.
class MockMetricData {
  const MockMetricData({
    required this.label,
    required this.value,
    required this.subValue,
    required this.trend,
    required this.trendPercent,
  });

  final String label;
  final String value;
  final String subValue;
  final OiMetricTrend trend;
  final double trendPercent;
}

const kDashboardMetrics = [
  MockMetricData(
    label: 'Revenue',
    value: '\u20AC127,450',
    subValue: 'vs \u20AC117,280 last month',
    trend: OiMetricTrend.up,
    trendPercent: 8.7,
  ),
  MockMetricData(
    label: 'Orders',
    value: '2,847',
    subValue: 'vs 2,534 last month',
    trend: OiMetricTrend.up,
    trendPercent: 12.3,
  ),
  MockMetricData(
    label: 'Active Users',
    value: '1,284',
    subValue: 'vs 1,244 last month',
    trend: OiMetricTrend.up,
    trendPercent: 3.2,
  ),
  MockMetricData(
    label: 'Satisfaction',
    value: '4.7/5',
    subValue: 'based on 892 reviews',
    trend: OiMetricTrend.neutral,
    trendPercent: 0.1,
  ),
];

// ── Monthly sales ───────────────────────────────────────────────────────────

/// Revenue per month in thousands of euros.
/// Seasonal spikes: April (Easter), October (harvest season), December (Christmas).
const kMonthlySales = <String, double>{
  'Jan': 82.4,
  'Feb': 76.1,
  'Mar': 91.3,
  'Apr': 118.6,
  'May': 95.2,
  'Jun': 88.7,
  'Jul': 93.5,
  'Aug': 84.9,
  'Sep': 97.8,
  'Oct': 121.4,
  'Nov': 104.2,
  'Dec': 142.8,
};

// ── Category breakdown ──────────────────────────────────────────────────────

/// Product category sales as percentages.
const kCategoryBreakdown = <String, double>{
  'Food & Sweets': 34.2,
  'Traditional Clothing': 22.8,
  'Outdoor & Hiking': 18.5,
  'Coffee & Beverages': 12.3,
  'Gifts & Souvenirs': 8.1,
  'Other': 4.1,
};

// ── Conversion funnel ───────────────────────────────────────────────────────

/// Sales funnel stages with visitor counts.
const kFunnelStages = <({String label, int value})>[
  (label: 'Visitors', value: 12400),
  (label: 'Product Views', value: 8200),
  (label: 'Added to Cart', value: 3100),
  (label: 'Checkout Started', value: 1850),
  (label: 'Orders Placed', value: 1284),
];

// ── Heatmap data ────────────────────────────────────────────────────────────

/// Activity heatmap: 7 days (Mon-Sun) x 24 hours.
/// Values 0-100 representing relative activity intensity.
/// Peaks during business hours (9-17), lower on weekends.
const kHeatmapData = <List<int>>[
  // Mon
  [2, 1, 1, 0, 0, 1, 3, 12, 38, 62, 71, 68, 55, 64, 72, 70, 58, 42, 28, 18, 12, 8, 5, 3],
  // Tue
  [2, 1, 0, 0, 1, 1, 4, 14, 42, 65, 74, 72, 58, 67, 75, 73, 61, 45, 30, 20, 14, 9, 6, 3],
  // Wed
  [3, 1, 1, 0, 0, 1, 3, 13, 40, 63, 76, 78, 60, 69, 77, 74, 63, 48, 32, 22, 15, 10, 6, 4],
  // Thu
  [2, 1, 0, 0, 0, 1, 4, 15, 44, 68, 80, 76, 62, 70, 78, 75, 65, 50, 34, 24, 16, 11, 7, 4],
  // Fri
  [3, 1, 1, 0, 0, 1, 3, 11, 36, 58, 66, 64, 52, 60, 65, 62, 54, 40, 26, 18, 13, 9, 6, 3],
  // Sat
  [4, 2, 1, 1, 0, 0, 1, 4, 10, 22, 30, 35, 32, 34, 36, 33, 28, 22, 16, 12, 9, 7, 5, 3],
  // Sun
  [3, 2, 1, 1, 0, 0, 1, 3, 8, 18, 24, 28, 26, 28, 30, 27, 22, 18, 14, 10, 8, 6, 4, 2],
];

// ── Radar chart ─────────────────────────────────────────────────────────────

/// Radar chart axes.
const kRadarCategories = <String>[
  'Quality',
  'Price',
  'Delivery',
  'Support',
  'Selection',
  'Packaging',
];

/// Two series for comparison: current quarter vs last quarter.
/// Values on a 0-100 scale.
const kRadarValues = <List<double>>[
  // This Quarter
  [88, 72, 81, 90, 76, 84],
  // Last Quarter
  [82, 75, 74, 85, 70, 78],
];

// ── Employee table data ─────────────────────────────────────────────────────

/// Employee directory for the dashboard table.
/// Uses all 25 kAllUsers entries with extended fields.
final kEmployeeTableData = <Map<String, Object>>[
  for (final entry in _employeeEntries)
    {
      'name': entry.user.name,
      'role': entry.user.role!,
      'department': entry.user.department ?? 'General',
      'email': entry.user.email,
      'phone': entry.user.phone ?? '',
      'location': entry.user.location ?? '',
      'status': entry.user.status,
      'joined': entry.joined,
      'ordersProcessed': entry.ordersProcessed,
    },
];

class _EmployeeEntry {
  const _EmployeeEntry(this.user, this.joined, this.ordersProcessed);
  final MockUser user;
  final String joined;
  final int ordersProcessed;
}

const _employeeEntries = [
  _EmployeeEntry(kCurrentUser, '2019-03-15', 0),
  _EmployeeEntry(kHans, '2020-06-01', 4821),
  _EmployeeEntry(kLiesl, '2020-09-14', 0),
  _EmployeeEntry(kFranz, '2021-01-10', 312),
  _EmployeeEntry(kMaria, '2020-11-22', 0),
  _EmployeeEntry(kStefan, '2021-04-05', 0),
  _EmployeeEntry(kAnna, '2021-07-18', 156),
  _EmployeeEntry(kMaximilian, '2022-02-28', 2347),
  _EmployeeEntry(kKlara, '2022-08-12', 6218),
  _EmployeeEntry(kWolfgang, '2023-01-09', 8934),
  _EmployeeEntry(kElisabeth, '2023-04-17', 0),
  _EmployeeEntry(kPeter, '2023-06-03', 87),
  _EmployeeEntry(kGertrud, '2023-08-21', 0),
  _EmployeeEntry(kFerdinand, '2023-10-02', 0),
  _EmployeeEntry(kRosalinde, '2024-01-15', 0),
  _EmployeeEntry(kOtto, '2024-03-11', 3412),
  _EmployeeEntry(kTheresa, '2024-05-06', 0),
  _EmployeeEntry(kIgnaz, '2024-07-22', 0),
  _EmployeeEntry(kFriederike, '2024-09-09', 0),
  _EmployeeEntry(kKaspar, '2024-11-18', 542),
  _EmployeeEntry(kHedwig, '2025-01-06', 1893),
  _EmployeeEntry(kRupert, '2025-03-24', 2156),
  _EmployeeEntry(kAugustine, '2025-06-02', 0),
  _EmployeeEntry(kVinzenz, '2025-08-18', 0),
  _EmployeeEntry(kBrigitte, '2025-10-30', 0),
];

/// Available roles for the inline role editor.
const kRoleOptions = [
  'CEO & Sachertorten-Sommelier',
  'Head of Logistics',
  'Senior Developer',
  'Frontend Developer',
  'Backend Engineer',
  'DevOps Engineer',
  'Security Engineer',
  'Marketing Manager',
  'Content Writer',
  'Social Media Manager',
  'Head of Design',
  'UX Researcher',
  'Graphic Designer',
  'Product Manager',
  'Data Analyst',
  'QA Lead',
  'Customer Support',
  'Support Agent',
  'Warehouse Manager',
  'Shipping Coordinator',
  'Inventory Specialist',
  'Sales Representative',
  'HR Manager',
  'Finance Controller',
  'Accountant',
];

/// Available departments for the inline department editor.
const kDepartmentOptions = [
  'Executive',
  'Engineering',
  'Design',
  'Marketing',
  'Product',
  'Operations',
  'Support',
  'Quality',
  'Human Resources',
  'Finance',
  'Sales',
];

// ── Activity events ─────────────────────────────────────────────────────────

/// Recent activity feed entries.
final kActivityEvents = <OiActivityEvent>[
  OiActivityEvent(
    key: 'act-1',
    title: 'New order #4712 received',
    description: 'Mozartkugeln Geschenkbox (24 pieces) shipped to Salzburg',
    timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    icon: OiIcons.shoppingCart,
    category: 'Orders',
  ),
  OiActivityEvent(
    key: 'act-2',
    title: 'Product review: 5 stars',
    description: '"Best Sachertorte outside Vienna!" — Kunde aus Graz',
    timestamp: DateTime.now().subtract(const Duration(minutes: 47)),
    icon: OiIcons.star,
    category: 'Reviews',
  ),
  OiActivityEvent(
    key: 'act-3',
    title: 'New customer registered',
    description: 'Maria Hinterberger from Innsbruck joined the shop',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    icon: OiIcons.userPlus,
    category: 'Users',
  ),
  OiActivityEvent(
    key: 'act-4',
    title: 'Low stock warning',
    description: 'Almdudler Sirup — only 8 units remaining in warehouse',
    timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 15)),
    icon: OiIcons.triangleAlert,
    category: 'Inventory',
  ),
  OiActivityEvent(
    key: 'act-5',
    title: 'Flash sale activated',
    description: 'Dirndl collection: 20% off for the next 48 hours',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    icon: OiIcons.tag,
    category: 'Marketing',
  ),
  OiActivityEvent(
    key: 'act-6',
    title: 'Database backup completed',
    description: 'Full backup finished in 4m 32s — 2.8 GB archived',
    timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    icon: OiIcons.cloudUpload,
    category: 'System',
  ),
  OiActivityEvent(
    key: 'act-7',
    title: 'Return request #318',
    description: 'Lederhosen size exchange — customer wants L instead of M',
    timestamp: DateTime.now().subtract(const Duration(hours: 11)),
    icon: OiIcons.receiptText,
    category: 'Orders',
  ),
  OiActivityEvent(
    key: 'act-8',
    title: 'Newsletter sent',
    description: 'Spring collection preview — 12,847 subscribers reached',
    timestamp: DateTime.now().subtract(const Duration(hours: 23)),
    icon: OiIcons.mail,
    category: 'Marketing',
  ),
];

// ── Notifications ───────────────────────────────────────────────────────────

/// Dashboard notification items.
final kNotifications = <OiNotification>[
  OiNotification(
    key: 'notif-1',
    title: 'Order #4712 requires attention',
    body: 'Payment verification pending for Mozartkugeln Geschenkbox shipment.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    icon: OiIcons.shoppingCart,
    category: 'Orders',
  ),
  OiNotification(
    key: 'notif-2',
    title: 'Inventory alert: Bergkäse',
    body: 'Stock level dropped below the reorder threshold (15 units).',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    icon: OiIcons.triangleAlert,
    category: 'Inventory',
  ),
  OiNotification(
    key: 'notif-3',
    title: 'New review on Steirisches Kürbiskernöl',
    body: '4-star review: "Excellent quality, slightly slow delivery."',
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    read: true,
    icon: OiIcons.star,
    category: 'Reviews',
  ),
  OiNotification(
    key: 'notif-4',
    title: 'Weekly sales report ready',
    body: 'Revenue up 8.7% compared to last week. Full report available.',
    timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    read: true,
    icon: OiIcons.trendingUp,
    category: 'Reports',
  ),
  OiNotification(
    key: 'notif-5',
    title: 'Team meeting in 30 minutes',
    body: 'Sprint review with the Alpenglueck product team at 14:00.',
    timestamp: DateTime.now().subtract(const Duration(hours: 12)),
    icon: OiIcons.bell,
    category: 'Calendar',
  ),
  OiNotification(
    key: 'notif-6',
    title: 'Supplier invoice received',
    body: 'Tiroler Speck GmbH — invoice #2026-0389 for \u20AC3,420.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    read: true,
    icon: OiIcons.mail,
    category: 'Finance',
  ),
];

// ── Order data ──────────────────────────────────────────────────────────────

/// Mock orders for the admin orders table — now with line item details.
final kMockOrders = <Map<String, Object>>[
  {
    'orderNumber': 'AG-2026-0042',
    'customer': 'Maria Hinterberger',
    'items': 3,
    'total': '\u20AC107.30',
    'status': 'confirmed',
    'date': '2026-03-22',
    'paymentMethod': 'Visa',
    'shippingAddress': 'Getreidegasse 12, 5020 Salzburg',
    'lineItems': <Map<String, Object>>[
      {'product': 'Original Sacher-Torte', 'quantity': 1, 'unitPrice': 38.90, 'total': 38.90},
      {'product': 'Mozartkugeln Gift Box (24 pcs)', 'quantity': 2, 'unitPrice': 29.90, 'total': 59.80},
      {'product': 'Shipping', 'quantity': 1, 'unitPrice': 5.90, 'total': 5.90},
    ],
  },
  {
    'orderNumber': 'AG-2026-0041',
    'customer': 'Thomas Oberhuber',
    'items': 1,
    'total': '\u20AC289.00',
    'status': 'shipped',
    'date': '2026-03-21',
    'paymentMethod': 'EPS Bank Transfer',
    'shippingAddress': 'Mariahilfer Str. 88, 1070 Wien',
    'lineItems': <Map<String, Object>>[
      {'product': 'Alpine Hiking Boot "Gipfelstürmer"', 'quantity': 1, 'unitPrice': 289.00, 'total': 289.00},
    ],
  },
  {
    'orderNumber': 'AG-2026-0040',
    'customer': 'Eva Schneider',
    'items': 5,
    'total': '\u20AC184.20',
    'status': 'confirmed',
    'date': '2026-03-21',
    'paymentMethod': 'Klarna',
    'shippingAddress': 'Innrain 42, 6020 Innsbruck',
    'lineItems': <Map<String, Object>>[
      {'product': 'Viennese Coffee Set', 'quantity': 1, 'unitPrice': 64.90, 'total': 64.90},
      {'product': 'Almdudler Party Pack', 'quantity': 2, 'unitPrice': 18.90, 'total': 37.80},
      {'product': 'Zillertaler Graukäse', 'quantity': 2, 'unitPrice': 24.90, 'total': 49.80},
      {'product': 'Express Shipping', 'quantity': 1, 'unitPrice': 12.90, 'total': 12.90},
    ],
  },
  {
    'orderNumber': 'AG-2026-0039',
    'customer': 'Karl Huber',
    'items': 2,
    'total': '\u20AC68.40',
    'status': 'delivered',
    'date': '2026-03-20',
    'paymentMethod': 'Visa',
    'shippingAddress': 'Hauptplatz 7, 4020 Linz',
    'lineItems': <Map<String, Object>>[
      {'product': 'Wiener Schnitzel Home Kit', 'quantity': 1, 'unitPrice': 34.50, 'total': 34.50},
      {'product': 'Original Sacher-Torte', 'quantity': 1, 'unitPrice': 38.90, 'total': 38.90},
    ],
  },
  {
    'orderNumber': 'AG-2026-0038',
    'customer': 'Sophie Maier',
    'items': 1,
    'total': '\u20AC39.90',
    'status': 'delivered',
    'date': '2026-03-19',
    'paymentMethod': 'Nachnahme',
    'shippingAddress': 'Rathausplatz 1, 8010 Graz',
    'lineItems': <Map<String, Object>>[
      {'product': 'Mozartkugeln Gift Box (24 pcs)', 'quantity': 1, 'unitPrice': 29.90, 'total': 29.90},
      {'product': 'Shipping', 'quantity': 1, 'unitPrice': 5.90, 'total': 5.90},
    ],
  },
  {
    'orderNumber': 'AG-2026-0037',
    'customer': 'Florian Berger',
    'items': 4,
    'total': '\u20AC412.50',
    'status': 'returned',
    'date': '2026-03-18',
    'paymentMethod': 'EPS Bank Transfer',
    'shippingAddress': 'Erzherzog-Johann-Str. 15, 8010 Graz',
    'lineItems': <Map<String, Object>>[
      {'product': 'Lederhosen "Bergkönig"', 'quantity': 1, 'unitPrice': 189.00, 'total': 189.00},
      {'product': 'Dirndl "Almsommer"', 'quantity': 1, 'unitPrice': 159.00, 'total': 159.00},
      {'product': 'Viennese Coffee Set', 'quantity': 1, 'unitPrice': 64.90, 'total': 64.90},
    ],
  },
  {
    'orderNumber': 'AG-2026-0036',
    'customer': 'Anna Gruber',
    'items': 2,
    'total': '\u20AC57.00',
    'status': 'shipped',
    'date': '2026-03-17',
    'paymentMethod': 'Visa',
    'shippingAddress': 'Landstraße 33, 4020 Linz',
    'lineItems': <Map<String, Object>>[
      {'product': 'Almdudler Party Pack', 'quantity': 3, 'unitPrice': 18.90, 'total': 56.70},
    ],
  },
  {
    'orderNumber': 'AG-2026-0035',
    'customer': 'Lukas Wagner',
    'items': 1,
    'total': '\u20AC389.00',
    'status': 'pending',
    'date': '2026-03-17',
    'paymentMethod': 'Klarna',
    'shippingAddress': 'Kaiserstraße 5, 6900 Bregenz',
    'lineItems': <Map<String, Object>>[
      {'product': 'Alpine Hiking Boot "Gipfelstürmer"', 'quantity': 1, 'unitPrice': 289.00, 'total': 289.00},
      {'product': 'Alm-Bote Mountain Courier', 'quantity': 1, 'unitPrice': 24.90, 'total': 24.90},
    ],
  },
  {
    'orderNumber': 'AG-2026-0034',
    'customer': 'Christina Bauer',
    'items': 3,
    'total': '\u20AC127.60',
    'status': 'delivered',
    'date': '2026-03-16',
    'paymentMethod': 'Visa',
    'shippingAddress': 'Mozartstraße 9, 5020 Salzburg',
    'lineItems': <Map<String, Object>>[
      {'product': 'Original Sacher-Torte', 'quantity': 2, 'unitPrice': 38.90, 'total': 77.80},
      {'product': 'Mozartkugeln Gift Box (24 pcs)', 'quantity': 1, 'unitPrice': 29.90, 'total': 29.90},
      {'product': 'Shipping', 'quantity': 1, 'unitPrice': 5.90, 'total': 5.90},
    ],
  },
  {
    'orderNumber': 'AG-2026-0033',
    'customer': 'Michael Pichler',
    'items': 2,
    'total': '\u20AC348.00',
    'status': 'confirmed',
    'date': '2026-03-15',
    'paymentMethod': 'EPS Bank Transfer',
    'shippingAddress': 'Herrengasse 21, 1010 Wien',
    'lineItems': <Map<String, Object>>[
      {'product': 'Dirndl "Almsommer"', 'quantity': 1, 'unitPrice': 159.00, 'total': 159.00},
      {'product': 'Lederhosen "Bergkönig"', 'quantity': 1, 'unitPrice': 189.00, 'total': 189.00},
    ],
  },
  {
    'orderNumber': 'AG-2026-0032',
    'customer': 'Sabine Hofer',
    'items': 1,
    'total': '\u20AC64.90',
    'status': 'shipped',
    'date': '2026-03-14',
    'paymentMethod': 'Visa',
    'shippingAddress': 'Bahnhofstraße 14, 9020 Klagenfurt',
    'lineItems': <Map<String, Object>>[
      {'product': 'Viennese Coffee Set', 'quantity': 1, 'unitPrice': 64.90, 'total': 64.90},
    ],
  },
  {
    'orderNumber': 'AG-2026-0031',
    'customer': 'Andreas Steiner',
    'items': 6,
    'total': '\u20AC213.40',
    'status': 'delivered',
    'date': '2026-03-13',
    'paymentMethod': 'Nachnahme',
    'shippingAddress': 'Tiroler Straße 3, 6020 Innsbruck',
    'lineItems': <Map<String, Object>>[
      {'product': 'Zillertaler Graukäse', 'quantity': 3, 'unitPrice': 24.90, 'total': 74.70},
      {'product': 'Wiener Schnitzel Home Kit', 'quantity': 2, 'unitPrice': 34.50, 'total': 69.00},
      {'product': 'Almdudler Party Pack', 'quantity': 3, 'unitPrice': 18.90, 'total': 56.70},
      {'product': 'Express Shipping', 'quantity': 1, 'unitPrice': 12.90, 'total': 12.90},
    ],
  },
];

// ── Return requests ─────────────────────────────────────────────────────────

/// Mock return requests for the admin returns screen.
final kMockReturns = <Map<String, Object>>[
  {
    'returnId': 'RET-001',
    'orderId': 'AG-2026-0037',
    'customer': 'Florian Berger',
    'reason': 'Wrong size — Lederhosen too tight',
    'status': 'refunded',
    'requestDate': '2026-03-19',
    'items': 'Lederhosen "Bergkönig" (1x)',
    'refundAmount': '\u20AC189.00',
  },
  {
    'returnId': 'RET-002',
    'orderId': 'AG-2026-0031',
    'customer': 'Andreas Steiner',
    'reason': 'Graukäse did not survive transit — arrived too warm',
    'status': 'approved',
    'requestDate': '2026-03-20',
    'items': 'Zillertaler Graukäse (3x)',
    'refundAmount': '\u20AC74.70',
  },
  {
    'returnId': 'RET-003',
    'orderId': 'AG-2026-0034',
    'customer': 'Christina Bauer',
    'reason': 'Duplicate order — placed by accident',
    'status': 'shipped-back',
    'requestDate': '2026-03-20',
    'items': 'Original Sacher-Torte (1x)',
    'refundAmount': '\u20AC38.90',
  },
  {
    'returnId': 'RET-004',
    'orderId': 'AG-2026-0032',
    'customer': 'Sabine Hofer',
    'reason': 'Coffee set missing one cup',
    'status': 'requested',
    'requestDate': '2026-03-21',
    'items': 'Viennese Coffee Set (1x)',
    'refundAmount': '\u20AC64.90',
  },
  {
    'returnId': 'RET-005',
    'orderId': 'AG-2026-0039',
    'customer': 'Karl Huber',
    'reason': 'Changed mind about the Schnitzel kit',
    'status': 'requested',
    'requestDate': '2026-03-22',
    'items': 'Wiener Schnitzel Home Kit (1x)',
    'refundAmount': '\u20AC34.50',
  },
  {
    'returnId': 'RET-006',
    'orderId': 'AG-2026-0033',
    'customer': 'Michael Pichler',
    'reason': 'Dirndl color differs from product photo',
    'status': 'approved',
    'requestDate': '2026-03-22',
    'items': 'Dirndl "Almsommer" (1x)',
    'refundAmount': '\u20AC159.00',
  },
];

/// Possible return pipeline statuses in order.
const kReturnStatuses = [
  'requested',
  'approved',
  'shipped-back',
  'inspected',
  'refunded',
];

// ── Permissions ─────────────────────────────────────────────────────────────

/// Role definitions for the OiPermissions widget.
const kMockRoles = <({String key, String label, String description, int color})>[
  (key: 'admin', label: 'Administrator', description: 'Full system access', color: 0xFFE53935),
  (key: 'editor', label: 'Editor', description: 'Content and product management', color: 0xFF1E88E5),
  (key: 'viewer', label: 'Viewer', description: 'Read-only access', color: 0xFF43A047),
  (key: 'support', label: 'Support', description: 'Customer support operations', color: 0xFFFB8C00),
];

/// Permission items for the matrix.
const kMockPermissions = <({String key, String label, String description})>[
  (key: 'users.read', label: 'View Users', description: 'See the employee directory'),
  (key: 'users.write', label: 'Edit Users', description: 'Modify user profiles and roles'),
  (key: 'users.delete', label: 'Delete Users', description: 'Remove user accounts'),
  (key: 'orders.read', label: 'View Orders', description: 'See order list and details'),
  (key: 'orders.write', label: 'Manage Orders', description: 'Update order status'),
  (key: 'orders.refund', label: 'Process Refunds', description: 'Issue refunds and returns'),
  (key: 'products.read', label: 'View Products', description: 'Browse the product catalog'),
  (key: 'products.write', label: 'Edit Products', description: 'Add and modify products'),
  (key: 'settings.read', label: 'View Settings', description: 'See system configuration'),
  (key: 'settings.write', label: 'Edit Settings', description: 'Change system configuration'),
  (key: 'reports.read', label: 'View Reports', description: 'Access analytics dashboards'),
  (key: 'reports.export', label: 'Export Reports', description: 'Download report data'),
];

/// Initial permission matrix: role key → set of permission keys.
final kMockPermissionMatrix = <String, Set<String>>{
  'admin': {
    'users.read', 'users.write', 'users.delete',
    'orders.read', 'orders.write', 'orders.refund',
    'products.read', 'products.write',
    'settings.read', 'settings.write',
    'reports.read', 'reports.export',
  },
  'editor': {
    'users.read',
    'orders.read', 'orders.write',
    'products.read', 'products.write',
    'settings.read',
    'reports.read',
  },
  'viewer': {
    'users.read',
    'orders.read',
    'products.read',
    'reports.read',
  },
  'support': {
    'users.read',
    'orders.read', 'orders.write', 'orders.refund',
    'products.read',
    'reports.read',
  },
};

// ── API keys ────────────────────────────────────────────────────────────────

/// Mock API keys for the settings screen.
const kMockApiKeys = <({String name, String key, String created, bool active})>[
  (name: 'Production API Key', key: 'ak_prod_7f3b9c2e1a4d8f6b0e5c3a9d2f1b8e4a', created: '2025-11-15', active: true),
  (name: 'Staging API Key', key: 'ak_stg_2c4e8f1b9a3d7e5c0f6b2a8d4e1c9f3b', created: '2026-01-20', active: true),
  (name: 'Development API Key', key: 'ak_dev_9d1f3b7e2c5a8d4f0b6e3c9a1d8f2b5e', created: '2026-02-10', active: false),
];

// ── Command bar ─────────────────────────────────────────────────────────────

/// Command bar entries for the admin search (labels only — icons added in UI).
const kAdminCommandEntries = <({String id, String label, String category, String? description})>[
  (id: 'nav-overview', label: 'Go to Overview', category: 'Navigation', description: 'Dashboard overview'),
  (id: 'nav-users', label: 'Go to Users', category: 'Navigation', description: 'Employee directory'),
  (id: 'nav-permissions', label: 'Go to Permissions', category: 'Navigation', description: 'Roles & permissions matrix'),
  (id: 'nav-orders', label: 'Go to Orders', category: 'Navigation', description: 'Order management'),
  (id: 'nav-returns', label: 'Go to Returns', category: 'Navigation', description: 'Return requests'),
  (id: 'nav-settings', label: 'Go to Settings', category: 'Navigation', description: 'System settings'),
  (id: 'nav-activity', label: 'Go to Activity', category: 'Navigation', description: 'Activity feed'),
  (id: 'nav-notifications', label: 'Go to Notifications', category: 'Navigation', description: 'Notification center'),
  (id: 'act-export-users', label: 'Export Users', category: 'Actions', description: 'Download employee CSV'),
  (id: 'act-export-orders', label: 'Export Orders', category: 'Actions', description: 'Download orders CSV'),
  (id: 'act-new-user', label: 'Create New User', category: 'Actions', description: 'Add a new employee'),
  (id: 'act-toggle-theme', label: 'Toggle Theme', category: 'Preferences', description: 'Switch light/dark mode'),
];

// ── Sankey chart data ───────────────────────────────────────────────────────

/// Customer journey flow for OiSankey visualization.
const kSankeyNodes = <({Object key, String label})>[
  (key: 'social', label: 'Social Media'),
  (key: 'search', label: 'Search'),
  (key: 'direct', label: 'Direct'),
  (key: 'email', label: 'Email Campaign'),
  (key: 'browse', label: 'Product Browse'),
  (key: 'cart', label: 'Add to Cart'),
  (key: 'checkout', label: 'Checkout'),
  (key: 'purchase', label: 'Purchase'),
  (key: 'abandon', label: 'Abandoned'),
];

const kSankeyLinks = <({Object source, Object target, double value})>[
  (source: 'social', target: 'browse', value: 3200),
  (source: 'search', target: 'browse', value: 5800),
  (source: 'direct', target: 'browse', value: 2100),
  (source: 'email', target: 'browse', value: 1300),
  (source: 'browse', target: 'cart', value: 4500),
  (source: 'browse', target: 'abandon', value: 7900),
  (source: 'cart', target: 'checkout', value: 3200),
  (source: 'cart', target: 'abandon', value: 1300),
  (source: 'checkout', target: 'purchase', value: 2847),
  (source: 'checkout', target: 'abandon', value: 353),
];

// ── Treemap chart data ──────────────────────────────────────────────────────

/// Revenue by product category for OiTreemap visualization.
const kTreemapNodes = <({Object key, String label, double value})>[
  (key: 'food', label: 'Food & Sweets', value: 45200),
  (key: 'clothing', label: 'Tracht & Clothing', value: 38900),
  (key: 'beverages', label: 'Beverages', value: 18900),
  (key: 'footwear', label: 'Footwear', value: 15200),
  (key: 'coffee', label: 'Coffee & Accessories', value: 12300),
  (key: 'gifts', label: 'Gifts & Souvenirs', value: 9250),
];
