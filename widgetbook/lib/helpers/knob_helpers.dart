import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Extension to add common knob patterns for obers_ui widgets.
extension OiKnobs on KnobsBuilder {
  /// Knob for any Dart enum via dropdown.
  T enumKnob<T extends Enum>({
    required String label,
    required List<T> values,
    T? initialValue,
  }) => object.dropdown(
    label: label,
    options: values,
    initialOption: initialValue ?? values.first,
    labelBuilder: (T v) => v.name,
  );

  /// Icon selection knob with common Material icons.
  IconData iconKnob({String label = 'Icon'}) {
    final options = <IconData>[
      Icons.home,
      Icons.search,
      Icons.settings,
      Icons.notifications,
      Icons.person,
      Icons.edit,
      Icons.delete,
      Icons.add,
      Icons.close,
      Icons.check,
      Icons.star,
      Icons.folder,
      Icons.description,
      Icons.download,
      Icons.upload,
    ];
    return object.dropdown<IconData>(
      label: label,
      options: options,
      initialOption: options.first,
      labelBuilder: _iconName,
    );
  }
}

String _iconName(IconData icon) {
  const names = <int, String>{
    0xe88a: 'home',
    0xe8b6: 'search',
    0xe8b8: 'settings',
    0xe7f4: 'notifications',
    0xe7fd: 'person',
    0xe3c9: 'edit',
    0xe872: 'delete',
    0xe145: 'add',
    0xe5cd: 'close',
    0xe5ca: 'check',
    0xe838: 'star',
    0xe2c7: 'folder',
    0xe873: 'description',
    0xf090: 'download',
    0xf09b: 'upload',
  };
  return names[icon.codePoint] ?? 'icon';
}

/// Wraps a use case child in a centered, padded container.
Widget useCaseWrapper(Widget child) {
  return Center(
    child: Padding(padding: const EdgeInsets.all(24), child: child),
  );
}

/// Wraps a use case child in a scrollable column for token catalogs.
Widget catalogWrapper(Widget child) {
  return SingleChildScrollView(padding: const EdgeInsets.all(24), child: child);
}
