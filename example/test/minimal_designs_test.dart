import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/minimal_designs.dart';

void main() {
  late Uint8List mediaBytes;
  setUpAll(() async {
    mediaBytes = await File('assets/minimal_designs/photo.png').readAsBytes();
    for (final family in ['Figtree', 'Newsreader']) {
      final bytes = await File(
        'assets/minimal_designs/$family.ttf',
      ).readAsBytes();
      await (FontLoader(
        family,
      )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    }
    final icons = await File(
      '../lib/src/foundation/icons/lucide.ttf',
    ).readAsBytes();
    await (FontLoader(
      'packages/obers_ui/lucide',
    )..addFont(Future.value(ByteData.sublistView(icons)))).load();
  });

  for (final quiet in [true, false]) {
    for (final settings in [
      (
        name: 'phone',
        size: const Size(390, 790),
        scale: 1.0,
        dpr: 1.0,
        rtl: false,
      ),
      (
        name: 'desktop',
        size: const Size(1280, 760),
        scale: 1.0,
        dpr: 1.0,
        rtl: false,
      ),
      (
        name: 'large_rtl',
        size: const Size(375, 790),
        scale: 2.0,
        dpr: 1.0,
        rtl: true,
      ),
      (
        name: 'phone_dpr2',
        size: const Size(390, 790),
        scale: 1.0,
        dpr: 2.0,
        rtl: false,
      ),
    ]) {
      testWidgets(
        '${quiet ? 'quiet' : 'workshop'} ${settings.name} public-module golden',
        (tester) async {
          tester.view.physicalSize = settings.size * settings.dpr;
          tester.view.devicePixelRatio = settings.dpr;
          await tester.binding.setSurfaceSize(settings.size);
          addTearDown(() async {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
            await tester.binding.setSurfaceSize(null);
          });
          final key = GlobalKey();
          await tester.pumpWidget(
            OiApp(
              theme: minimalDesignTheme(quiet: quiet),
              home: Builder(
                builder: (context) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(settings.scale),
                    disableAnimations: true,
                  ),
                  child: Directionality(
                    textDirection: settings.rtl
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: RepaintBoundary(
                      key: key,
                      child: MinimalDesignScreen(
                        quiet: quiet,
                        onChangeDesign: () {},
                        image: MemoryImage(mediaBytes),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 80)),
          );
          await tester.pumpAndSettle();
          for (
            var attempt = 0;
            attempt < 40 &&
                tester.widget<RawImage>(find.byType(RawImage)).image == null;
            attempt++
          ) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 25)),
            );
            await tester.pump();
          }
          expect(
            tester.widget<RawImage>(find.byType(RawImage)).image,
            isNotNull,
          );
          expect(tester.takeException(), isNull);
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await tester.runAsync(
            () => boundary.toImage(pixelRatio: settings.dpr),
          );
          if (image == null) {
            fail('The rendered example image was not captured.');
          }
          await expectLater(
            image,
            matchesGoldenFile(
              'goldens/${quiet ? 'quiet' : 'workshop'}_${settings.name}.png',
            ),
          );
          image.dispose();
        },
      );
    }
  }

  testWidgets('both designs retain independent selection and save behavior', (
    tester,
  ) async {
    var quiet = true;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => OiApp(
          theme: minimalDesignTheme(quiet: quiet),
          home: MinimalDesignScreen(
            quiet: quiet,
            image: FileImage(File('assets/minimal_designs/photo.png')),
            onChangeDesign: () => setState(() => quiet = !quiet),
          ),
        ),
      ),
    );
    await tester.ensureVisible(find.text('Punchy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Punchy'));
    await tester.pump();
    expect(find.text('Selected: Punchy'), findsOneWidget);
    await tester.tap(find.text('Save selection'));
    await tester.pump();
    expect(find.text('Selection saved'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Change design'));
    await tester.pump();
    expect(find.text('Workshop'), findsOneWidget);
    expect(find.text('Selected: Expert'), findsOneWidget);
    // The example performs controlled UI actions, not a simulated video export.
  });
}
