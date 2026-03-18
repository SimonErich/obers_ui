// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/components/feedback/oi_thumbs.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders two icon buttons', (tester) async {
    await tester.pumpObers(const OiThumbs());
    expect(find.byType(OiIconButton), findsNWidgets(2));
  });

  testWidgets('tapping thumbs up fires onChanged with up', (tester) async {
    OiThumbsValue? received;
    await tester.pumpObers(OiThumbs(onChanged: (v) => received = v));
    await tester.tap(find.byType(OiIconButton).first);
    await tester.pump();
    expect(received, OiThumbsValue.up);
  });

  testWidgets('tapping thumbs down fires onChanged with down', (tester) async {
    OiThumbsValue? received;
    await tester.pumpObers(OiThumbs(onChanged: (v) => received = v));
    await tester.tap(find.byType(OiIconButton).last);
    await tester.pump();
    expect(received, OiThumbsValue.down);
  });

  testWidgets('tapping active thumb again returns none', (tester) async {
    OiThumbsValue? received;
    await tester.pumpObers(
      OiThumbs(value: OiThumbsValue.up, onChanged: (v) => received = v),
    );
    await tester.tap(find.byType(OiIconButton).first);
    await tester.pump();
    expect(received, OiThumbsValue.none);
  });

  testWidgets('enabled=false blocks onChanged', (tester) async {
    OiThumbsValue? received;
    await tester.pumpObers(
      OiThumbs(enabled: false, onChanged: (v) => received = v),
    );
    await tester.tap(find.byType(OiIconButton).first, warnIfMissed: false);
    await tester.pump();
    expect(received, isNull);
  });

  testWidgets('showCount=true displays upCount and downCount', (tester) async {
    await tester.pumpObers(
      const OiThumbs(showCount: true, upCount: 12, downCount: 3),
    );
    expect(find.text('12'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('showCount=false hides counts', (tester) async {
    await tester.pumpObers(const OiThumbs(upCount: 12, downCount: 3));
    expect(find.text('12'), findsNothing);
    expect(find.text('3'), findsNothing);
  });

  testWidgets('label is included in semantics', (tester) async {
    await tester.pumpObers(const OiThumbs(label: 'Was this helpful?'));
    expect(find.bySemanticsLabel(RegExp('Was this helpful')), findsOneWidget);
  });
}
