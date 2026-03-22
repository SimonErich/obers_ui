import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'mock_users.dart';

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
/// Uses all 10 kAllUsers entries.
final kEmployeeTableData = <Map<String, Object>>[
  {
    'name': kCurrentUser.name,
    'role': kCurrentUser.role!,
    'department': 'Executive',
    'email': kCurrentUser.email,
    'joined': '2019-03-15',
    'ordersProcessed': 0,
  },
  {
    'name': kHans.name,
    'role': kHans.role!,
    'department': 'Operations',
    'email': kHans.email,
    'joined': '2020-06-01',
    'ordersProcessed': 4821,
  },
  {
    'name': kLiesl.name,
    'role': kLiesl.role!,
    'department': 'Engineering',
    'email': kLiesl.email,
    'joined': '2020-09-14',
    'ordersProcessed': 0,
  },
  {
    'name': kFranz.name,
    'role': kFranz.role!,
    'department': 'Marketing',
    'email': kFranz.email,
    'joined': '2021-01-10',
    'ordersProcessed': 312,
  },
  {
    'name': kMaria.name,
    'role': kMaria.role!,
    'department': 'Design',
    'email': kMaria.email,
    'joined': '2020-11-22',
    'ordersProcessed': 0,
  },
  {
    'name': kStefan.name,
    'role': kStefan.role!,
    'department': 'Engineering',
    'email': kStefan.email,
    'joined': '2021-04-05',
    'ordersProcessed': 0,
  },
  {
    'name': kAnna.name,
    'role': kAnna.role!,
    'department': 'Product',
    'email': kAnna.email,
    'joined': '2021-07-18',
    'ordersProcessed': 156,
  },
  {
    'name': kMaximilian.name,
    'role': kMaximilian.role!,
    'department': 'Quality',
    'email': kMaximilian.email,
    'joined': '2022-02-28',
    'ordersProcessed': 2347,
  },
  {
    'name': kKlara.name,
    'role': kKlara.role!,
    'department': 'Support',
    'email': kKlara.email,
    'joined': '2022-08-12',
    'ordersProcessed': 6218,
  },
  {
    'name': kWolfgang.name,
    'role': kWolfgang.role!,
    'department': 'Operations',
    'email': kWolfgang.email,
    'joined': '2023-01-09',
    'ordersProcessed': 8934,
  },
];

// ── Activity events ─────────────────────────────────────────────────────────

/// Recent activity feed entries.
final kActivityEvents = <OiActivityEvent>[
  OiActivityEvent(
    key: 'act-1',
    title: 'New order #4712 received',
    description: 'Mozartkugeln Geschenkbox (24 pieces) shipped to Salzburg',
    timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    icon: const IconData(0xe8cc, fontFamily: 'MaterialIcons'), // shopping_cart
    category: 'Orders',
  ),
  OiActivityEvent(
    key: 'act-2',
    title: 'Product review: 5 stars',
    description: '"Best Sachertorte outside Vienna!" — Kunde aus Graz',
    timestamp: DateTime.now().subtract(const Duration(minutes: 47)),
    icon: const IconData(0xe838, fontFamily: 'MaterialIcons'), // star
    category: 'Reviews',
  ),
  OiActivityEvent(
    key: 'act-3',
    title: 'New customer registered',
    description: 'Maria Hinterberger from Innsbruck joined the shop',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    icon: const IconData(0xea4a, fontFamily: 'MaterialIcons'), // person_add
    category: 'Users',
  ),
  OiActivityEvent(
    key: 'act-4',
    title: 'Low stock warning',
    description: 'Almdudler Sirup — only 8 units remaining in warehouse',
    timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 15)),
    icon: const IconData(0xe002, fontFamily: 'MaterialIcons'), // warning
    category: 'Inventory',
  ),
  OiActivityEvent(
    key: 'act-5',
    title: 'Flash sale activated',
    description: 'Dirndl collection: 20% off for the next 48 hours',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    icon: const IconData(0xe54e, fontFamily: 'MaterialIcons'), // local_offer
    category: 'Marketing',
  ),
  OiActivityEvent(
    key: 'act-6',
    title: 'Database backup completed',
    description: 'Full backup finished in 4m 32s — 2.8 GB archived',
    timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    icon: const IconData(0xe14f, fontFamily: 'MaterialIcons'), // backup
    category: 'System',
  ),
  OiActivityEvent(
    key: 'act-7',
    title: 'Return request #318',
    description: 'Lederhosen size exchange — customer wants L instead of M',
    timestamp: DateTime.now().subtract(const Duration(hours: 11)),
    icon: const IconData(0xe860, fontFamily: 'MaterialIcons'), // assignment_return
    category: 'Orders',
  ),
  OiActivityEvent(
    key: 'act-8',
    title: 'Newsletter sent',
    description: 'Spring collection preview — 12,847 subscribers reached',
    timestamp: DateTime.now().subtract(const Duration(hours: 23)),
    icon: const IconData(0xe0be, fontFamily: 'MaterialIcons'), // email
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
    icon: const IconData(0xe8cc, fontFamily: 'MaterialIcons'), // shopping_cart
    category: 'Orders',
  ),
  OiNotification(
    key: 'notif-2',
    title: 'Inventory alert: Bergkäse',
    body: 'Stock level dropped below the reorder threshold (15 units).',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    icon: const IconData(0xe002, fontFamily: 'MaterialIcons'), // warning
    category: 'Inventory',
  ),
  OiNotification(
    key: 'notif-3',
    title: 'New review on Steirisches Kürbiskernöl',
    body: '4-star review: "Excellent quality, slightly slow delivery."',
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    read: true,
    icon: const IconData(0xe838, fontFamily: 'MaterialIcons'), // star
    category: 'Reviews',
  ),
  OiNotification(
    key: 'notif-4',
    title: 'Weekly sales report ready',
    body: 'Revenue up 8.7% compared to last week. Full report available.',
    timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    read: true,
    icon: const IconData(0xe8e5, fontFamily: 'MaterialIcons'), // trending_up
    category: 'Reports',
  ),
  OiNotification(
    key: 'notif-5',
    title: 'Team meeting in 30 minutes',
    body: 'Sprint review with the Alpenglueck product team at 14:00.',
    timestamp: DateTime.now().subtract(const Duration(hours: 12)),
    icon: const IconData(0xe7f4, fontFamily: 'MaterialIcons'), // notifications
    category: 'Calendar',
  ),
  OiNotification(
    key: 'notif-6',
    title: 'Supplier invoice received',
    body: 'Tiroler Speck GmbH — invoice #2026-0389 for \u20AC3,420.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    read: true,
    icon: const IconData(0xe0be, fontFamily: 'MaterialIcons'), // email
    category: 'Finance',
  ),
];
