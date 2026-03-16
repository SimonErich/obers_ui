// Test files do not need public API docs.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_example/main.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('app launches and shows catalog', ($) async {
    await $.pumpWidgetAndSettle(const ObersUiExample());

    expect($(const Text('obers_ui Catalog')), findsOneWidget);
  });
}
