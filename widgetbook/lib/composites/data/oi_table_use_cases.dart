import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

class _Person {
  const _Person(this.name, this.age, this.role, this.city);
  final String name;
  final int age;
  final String role;
  final String city;
}

const _sampleRows = [
  _Person('Alice', 30, 'Engineer', 'Berlin'),
  _Person('Bob', 25, 'Designer', 'Paris'),
  _Person('Charlie', 35, 'Manager', 'London'),
  _Person('Diana', 28, 'Analyst', 'Rome'),
  _Person('Eve', 32, 'Developer', 'Madrid'),
];

final _columns = <OiTableColumn<_Person>>[
  OiTableColumn(
    id: 'name',
    header: 'Name',
    valueGetter: (p) => p.name,
  ),
  OiTableColumn(
    id: 'age',
    header: 'Age',
    valueGetter: (p) => p.age.toString(),
  ),
  OiTableColumn(
    id: 'role',
    header: 'Role',
    valueGetter: (p) => p.role,
  ),
  OiTableColumn(
    id: 'city',
    header: 'City',
    valueGetter: (p) => p.city,
  ),
];

final oiTableComponent = WidgetbookComponent(
  name: 'OiTable',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final paginationMode = context.knobs.enumKnob<OiTablePaginationMode>(
          label: 'Pagination Mode',
          values: OiTablePaginationMode.values,
        );
        final selectable = context.knobs.boolean(
          label: 'Selectable',
          initialValue: true,
        );
        final multiSelect = context.knobs.boolean(
          label: 'Multi Select',
          initialValue: false,
        );
        final striped = context.knobs.boolean(
          label: 'Striped',
          initialValue: false,
        );
        final dense = context.knobs.boolean(
          label: 'Dense',
          initialValue: false,
        );
        final showColumnManager = context.knobs.boolean(
          label: 'Show Column Manager',
          initialValue: false,
        );
        final showStatusBar = context.knobs.boolean(
          label: 'Show Status Bar',
          initialValue: true,
        );
        final loading = context.knobs.boolean(
          label: 'Loading',
          initialValue: false,
        );

        return SizedBox(
          height: 400,
          child: OiTable<_Person>(
            label: 'Sample table',
            rows: _sampleRows,
            columns: _columns,
            paginationMode: paginationMode,
            selectable: selectable,
            multiSelect: multiSelect,
            rowKey: (p) => p.name,
            striped: striped,
            dense: dense,
            showColumnManager: showColumnManager,
            showStatusBar: showStatusBar,
            loading: loading,
          ),
        );
      },
    ),
  ],
);
