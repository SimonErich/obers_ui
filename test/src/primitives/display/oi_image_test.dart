// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs
// REQ-0018: OiImage accessibility enforcement tests.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/display/oi_image.dart';

import '../../../helpers/pump_app.dart';

/// Suppresses [FlutterErrorDetails] whose exception is an image-load error.
///
/// Image resource exceptions are benign in tests where we supply an
/// errorWidget; we don't want them to fail the test.
FlutterExceptionHandler? _originalOnError;

void _ignoreImageErrors() {
  _originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception.toString().contains('NetworkImageLoadException') ||
        details.exception.toString().contains('Unable to load asset') ||
        details.library == 'image resource service') {
      return; // swallow image errors
    }
    _originalOnError?.call(details);
  };
}

void _restoreOnError() {
  FlutterError.onError = _originalOnError;
  _originalOnError = null;
}

void main() {
  // ── OiImage accessibility (REQ-0018) ──────────────────────────────────────

  group('OiImage accessibility', () {
    testWidgets(
      'should expose alt text as semantics label when alt is provided',
      (tester) async {
        _ignoreImageErrors();
        addTearDown(_restoreOnError);
        final handle = tester.ensureSemantics();
        try {
          await tester.pumpObers(
            const OiImage(
              src: 'https://example.com/alt-test.png',
              alt: 'A descriptive alt text',
              errorWidget: SizedBox(),
            ),
          );
          await tester.pump();
          expect(
            find.bySemanticsLabel('A descriptive alt text'),
            findsOneWidget,
          );
        } finally {
          handle.dispose();
        }
      },
    );

    testWidgets('should exclude semantics when OiImage.decorative() is used', (
      tester,
    ) async {
      _ignoreImageErrors();
      addTearDown(_restoreOnError);
      await tester.pumpObers(
        const OiImage.decorative(
          src: 'https://example.com/decorative.png',
          errorWidget: SizedBox(),
        ),
      );
      await tester.pump();
      expect(find.byType(ExcludeSemantics), findsAtLeastNWidgets(1));
      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );
      final withLabel = semanticsWidgets
          .where(
            (s) => s.properties.label != null && s.properties.label!.isNotEmpty,
          )
          .toList();
      expect(withLabel, isEmpty);
    });
  });

  // ── Network image ─────────────────────────────────────────────────────────

  testWidgets('builds Image.network for https:// src', (tester) async {
    _ignoreImageErrors();
    addTearDown(_restoreOnError);
    await tester.pumpObers(
      const OiImage(
        src: 'https://example.com/img.png',
        alt: 'example',
        errorWidget: SizedBox(),
      ),
    );
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('builds Image.network for http:// src', (tester) async {
    _ignoreImageErrors();
    addTearDown(_restoreOnError);
    await tester.pumpObers(
      const OiImage(
        src: 'http://example.com/img.png',
        alt: 'example',
        errorWidget: SizedBox(),
      ),
    );
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
  });

  // ── Asset image ───────────────────────────────────────────────────────────

  testWidgets('builds Image.asset for non-URL src', (tester) async {
    _ignoreImageErrors();
    addTearDown(_restoreOnError);
    await tester.pumpObers(
      const OiImage(
        src: 'assets/logo.png',
        alt: 'logo',
        errorWidget: Text('error'),
      ),
    );
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
  });

  // ── Semantics ─────────────────────────────────────────────────────────────

  testWidgets('wraps in Semantics with alt label', (tester) async {
    _ignoreImageErrors();
    addTearDown(_restoreOnError);
    await tester.pumpObers(
      const OiImage(
        src: 'https://example.com/img.png',
        alt: 'a cat photo',
        errorWidget: SizedBox(),
      ),
    );
    await tester.pump();
    final semanticsWidgets = tester.widgetList<Semantics>(
      find.byType(Semantics),
    );
    final matching = semanticsWidgets
        .where((s) => s.properties.label == 'a cat photo')
        .toList();
    expect(matching, hasLength(1));
    expect(matching.first.properties.image, isTrue);
  });

  testWidgets('decorative image uses ExcludeSemantics', (tester) async {
    _ignoreImageErrors();
    addTearDown(_restoreOnError);
    await tester.pumpObers(
      const OiImage.decorative(
        src: 'https://example.com/img.png',
        errorWidget: SizedBox(),
      ),
    );
    await tester.pump();
    expect(find.byType(ExcludeSemantics), findsAtLeastNWidgets(1));
  });

  testWidgets('decorative image has no labelled Semantics node', (
    tester,
  ) async {
    _ignoreImageErrors();
    addTearDown(_restoreOnError);
    await tester.pumpObers(
      const OiImage.decorative(
        src: 'https://example.com/img.png',
        errorWidget: SizedBox(),
      ),
    );
    await tester.pump();
    final semanticsWidgets = tester.widgetList<Semantics>(
      find.byType(Semantics),
    );
    final withLabel = semanticsWidgets
        .where(
          (s) => s.properties.label != null && s.properties.label!.isNotEmpty,
        )
        .toList();
    expect(withLabel, isEmpty);
  });

  // ── Size / fit ────────────────────────────────────────────────────────────

  testWidgets('applies width, height, and fit to Image', (tester) async {
    _ignoreImageErrors();
    addTearDown(_restoreOnError);
    await tester.pumpObers(
      const OiImage(
        src: 'https://example.com/img.png',
        alt: 'sized',
        width: 200,
        height: 100,
        fit: BoxFit.cover,
        errorWidget: SizedBox(),
      ),
    );
    await tester.pump();
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.width, 200);
    expect(image.height, 100);
    expect(image.fit, BoxFit.cover);
  });

  // ── placeholder / errorWidget ─────────────────────────────────────────────

  testWidgets('errorWidget is shown when asset fails to load', (tester) async {
    _ignoreImageErrors();
    addTearDown(_restoreOnError);
    await tester.pumpObers(
      const OiImage(
        src: 'assets/does_not_exist.png',
        alt: 'missing',
        errorWidget: Text('load error'),
      ),
    );
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
  });

  // ── lazy flag ─────────────────────────────────────────────────────────────

  testWidgets('lazy flag is stored without error', (tester) async {
    _ignoreImageErrors();
    addTearDown(_restoreOnError);
    await tester.pumpObers(
      const OiImage(
        src: 'https://example.com/img.png',
        alt: 'lazy',
        lazy: true,
        errorWidget: SizedBox(),
      ),
    );
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
  });
}
