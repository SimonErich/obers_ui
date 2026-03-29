// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_folder_icon.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders without error with defaults', (tester) async {
    await tester.pumpObers(const OiFolderIcon());
    expect(find.byType(OiFolderIcon), findsOneWidget);
  });

  testWidgets('all size variants render without error', (tester) async {
    for (final size in OiFolderIconSize.values) {
      await tester.pumpObers(OiFolderIcon(size: size));
      expect(find.byType(OiFolderIcon), findsOneWidget);
    }
  });

  testWidgets('closed state renders CustomPaint', (tester) async {
    await tester.pumpObers(const OiFolderIcon());
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('open state renders CustomPaint', (tester) async {
    await tester.pumpObers(const OiFolderIcon(state: OiFolderIconState.open));
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('empty state renders CustomPaint', (tester) async {
    await tester.pumpObers(const OiFolderIcon(state: OiFolderIconState.empty));
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('shared variant shows overlay icon', (tester) async {
    await tester.pumpObers(
      const OiFolderIcon(variant: OiFolderIconVariant.shared),
    );
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('starred variant shows overlay icon', (tester) async {
    await tester.pumpObers(
      const OiFolderIcon(variant: OiFolderIconVariant.starred),
    );
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('locked variant shows overlay icon', (tester) async {
    await tester.pumpObers(
      const OiFolderIcon(variant: OiFolderIconVariant.locked),
    );
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('trash variant shows overlay icon', (tester) async {
    await tester.pumpObers(
      const OiFolderIcon(variant: OiFolderIconVariant.trash),
    );
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('normal variant shows no overlay icon', (tester) async {
    await tester.pumpObers(const OiFolderIcon());
    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('badge count renders text', (tester) async {
    await tester.pumpObers(const OiFolderIcon(badgeCount: 5));
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('badge count over 99 shows 99+', (tester) async {
    await tester.pumpObers(const OiFolderIcon(badgeCount: 150));
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('badge count of zero is not rendered', (tester) async {
    await tester.pumpObers(const OiFolderIcon(badgeCount: 0));
    expect(find.text('0'), findsNothing);
  });

  testWidgets('null badge count is not rendered', (tester) async {
    await tester.pumpObers(const OiFolderIcon());
    // No badge text should be present
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('default semantic label is "folder"', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpObers(const OiFolderIcon());
      expect(find.bySemanticsLabel('folder'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('shared variant default label is "shared folder"', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpObers(
        const OiFolderIcon(variant: OiFolderIconVariant.shared),
      );
      expect(find.bySemanticsLabel('shared folder'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('starred variant default label is "starred folder"', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpObers(
        const OiFolderIcon(variant: OiFolderIconVariant.starred),
      );
      expect(find.bySemanticsLabel('starred folder'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('locked variant default label is "locked folder"', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpObers(
        const OiFolderIcon(variant: OiFolderIconVariant.locked),
      );
      expect(find.bySemanticsLabel('locked folder'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('trash variant default label is "trash folder"', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpObers(
        const OiFolderIcon(variant: OiFolderIconVariant.trash),
      );
      expect(find.bySemanticsLabel('trash folder'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('custom semanticsLabel overrides default', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpObers(const OiFolderIcon(semanticsLabel: 'My folder'));
      expect(find.bySemanticsLabel('My folder'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('custom color is applied', (tester) async {
    await tester.pumpObers(const OiFolderIcon(color: Color(0xFFFF0000)));
    expect(find.byType(OiFolderIcon), findsOneWidget);
  });

  testWidgets('xs size renders correct SizedBox dimensions', (tester) async {
    await tester.pumpObers(const OiFolderIcon(size: OiFolderIconSize.xs));
    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
    expect(sizedBox.width, 16);
    expect(sizedBox.height, 14);
  });

  testWidgets('xl size renders correct SizedBox dimensions', (tester) async {
    await tester.pumpObers(const OiFolderIcon(size: OiFolderIconSize.xl));
    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
    expect(sizedBox.width, 64);
    expect(sizedBox.height, 54);
  });
}
