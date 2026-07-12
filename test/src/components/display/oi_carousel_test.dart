// Tests do not require documentation comments.

import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

List<Widget> _pages([int count = 3]) => [
  for (var i = 0; i < count; i++)
    Center(key: Key('page_$i'), child: Text('Page $i')),
];

Widget _carousel({
  int count = 3,
  bool autoplay = false,
  Duration interval = const Duration(seconds: 1),
  bool loop = false,
  bool showArrows = true,
  bool showIndicator = true,
  bool pauseOnHover = true,
  ValueChanged<int>? onPageChanged,
}) {
  return SizedBox(
    width: 400,
    height: 240,
    child: OiCarousel(
      label: 'Gallery',
      items: _pages(count),
      autoplay: autoplay,
      autoplayInterval: interval,
      loop: loop,
      showArrows: showArrows,
      showIndicator: showIndicator,
      pauseOnHover: pauseOnHover,
      onPageChanged: onPageChanged,
    ),
  );
}

void main() {
  group('OiCarousel', () {
    testWidgets('renders the first page', (tester) async {
      await tester.pumpObers(_carousel());
      expect(find.byKey(const Key('oi_carousel')), findsOneWidget);
      expect(find.text('Page 0'), findsOneWidget);
    });

    testWidgets('shows the empty key when there are no items', (tester) async {
      await tester.pumpObers(_carousel(count: 0));
      expect(find.byKey(const Key('oi_carousel_empty')), findsOneWidget);
    });

    testWidgets('hides arrows and indicator for a single page', (tester) async {
      await tester.pumpObers(_carousel(count: 1));
      expect(find.byKey(const Key('oi_carousel_next')), findsNothing);
      expect(find.byType(OiPageIndicator), findsNothing);
    });

    testWidgets('renders the dot indicator when enabled', (tester) async {
      await tester.pumpObers(_carousel());
      expect(find.byType(OiPageIndicator), findsOneWidget);
    });

    testWidgets('the next arrow advances the page', (tester) async {
      int? changedTo;
      await tester.pumpObers(_carousel(onPageChanged: (i) => changedTo = i));
      await tester.tap(find.byKey(const Key('oi_carousel_next')));
      await tester.pumpAndSettle();
      expect(changedTo, 1);
      expect(find.text('Page 1'), findsOneWidget);
    });

    testWidgets('a horizontal drag changes the page', (tester) async {
      int? changedTo;
      await tester.pumpObers(_carousel(onPageChanged: (i) => changedTo = i));
      await tester.drag(
        find.byKey(const Key('oi_carousel_pageview')),
        const Offset(-400, 0),
      );
      await tester.pumpAndSettle();
      expect(changedTo, 1);
    });

    testWidgets(
      'the previous arrow is disabled on the first page without loop',
      (
        tester,
      ) async {
        int? changedTo;
        await tester.pumpObers(_carousel(onPageChanged: (i) => changedTo = i));
        await tester.tap(find.byKey(const Key('oi_carousel_prev')));
        await tester.pumpAndSettle();
        expect(changedTo, isNull);
        expect(find.text('Page 0'), findsOneWidget);
      },
    );

    testWidgets('loop wraps from the first page back to the last', (
      tester,
    ) async {
      int? changedTo;
      await tester.pumpObers(
        _carousel(loop: true, onPageChanged: (i) => changedTo = i),
      );
      await tester.tap(find.byKey(const Key('oi_carousel_prev')));
      await tester.pumpAndSettle();
      expect(changedTo, 2);
    });

    testWidgets('autoplay advances the page after the interval', (
      tester,
    ) async {
      int? changedTo;
      await tester.pumpObers(
        _carousel(
          autoplay: true,
          onPageChanged: (i) => changedTo = i,
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(changedTo, 1);
    });

    testWidgets('autoplay pauses while the pointer hovers', (tester) async {
      int? changedTo;
      await tester.pumpObers(
        _carousel(
          autoplay: true,
          onPageChanged: (i) => changedTo = i,
        ),
      );
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.byType(OiCarousel)));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(changedTo, isNull);
    });

    testWidgets('has a semantics label', (tester) async {
      await tester.pumpObers(_carousel());
      final semantics = tester.getSemantics(find.byType(OiCarousel));
      expect(semantics.label, contains('Gallery'));
    });
  });
}
