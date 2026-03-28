import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

/// Widgetbook component for [OiMaintenancePage].
final oiMaintenancePageComponent = WidgetbookComponent(
  name: 'OiMaintenancePage',
  useCases: [
    WidgetbookUseCase(
      name: 'Maintenance',
      builder: (context) => useCaseWrapper(
        OiMaintenancePage.maintenance(
          onRetry: () {},
          estimatedReturn: DateTime.now().add(const Duration(hours: 2)),
        ),
      ),
    ),
    WidgetbookUseCase(
      name: 'Not Found',
      builder: (context) =>
          useCaseWrapper(OiMaintenancePage.notFound(onRetry: () {})),
    ),
    WidgetbookUseCase(
      name: 'Server Error',
      builder: (context) =>
          useCaseWrapper(OiMaintenancePage.serverError(onRetry: () {})),
    ),
    WidgetbookUseCase(
      name: 'Offline',
      builder: (context) =>
          useCaseWrapper(OiMaintenancePage.offline(onRetry: () {})),
    ),
  ],
);
