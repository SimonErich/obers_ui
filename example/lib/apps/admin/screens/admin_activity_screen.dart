import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_dashboard.dart';

/// Activity feed screen showing recent events.
class AdminActivityScreen extends StatelessWidget {
  const AdminActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OiActivityFeed(
      label: 'Recent activity',
      events: kActivityEvents,
    );
  }
}
