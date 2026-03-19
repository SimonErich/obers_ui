import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiFileToolbarComponent = WidgetbookComponent(
  name: 'OiFileToolbar',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        return useCaseWrapper(
          OiFileToolbar(
            label: 'File toolbar',
            breadcrumbs: const [
              OiBreadcrumbItem(label: 'Home'),
              OiBreadcrumbItem(label: 'Documents'),
              OiBreadcrumbItem(label: 'Projects'),
            ],
            onSearch: (query) {},
          ),
        );
      },
    ),
  ],
);
