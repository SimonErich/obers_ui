import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_card.dart';
import 'package:obers_ui/src/components/display/oi_drop_highlight.dart';
import 'package:obers_ui/src/components/feedback/oi_sentiment.dart';
import 'package:obers_ui/src/components/inputs/oi_switch.dart';
import 'package:obers_ui/src/components/navigation/oi_accordion.dart';
import 'package:obers_ui/src/components/navigation/oi_drawer.dart';
import 'package:obers_ui/src/components/navigation/oi_tabs.dart';
import 'package:obers_ui/src/components/navigation/oi_time_picker.dart';
import 'package:obers_ui/src/components/overlays/oi_sheet.dart';
import 'package:obers_ui/src/components/overlays/oi_toast.dart';
import 'package:obers_ui/src/components/panels/oi_panel.dart';
import 'package:obers_ui/src/composites/forms/oi_wizard.dart';

import '../helpers/pump_app.dart';

/// REQ-0032: Reduced motion per platform — respects
/// `MediaQuery.disableAnimations` (iOS "Reduce Motion") and
/// `prefers-reduced-motion` on web. When active, all animations complete
/// instantly — no spring physics, no stagger delays, no shimmer loops.
void main() {
  // ── OiCard ────────────────────────────────────────────────────────────────

  group('REQ-0032 OiCard reduced motion', () {
    testWidgets('collapsible card collapses instantly with disableAnimations', (
      tester,
    ) async {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: OiCard(
            collapsible: true,
            title: Text('Title'),
            child: Text('body content'),
          ),
        ),
      );

      // Find the chevron and tap it to collapse.
      final chevronFinder = find.byType(GestureDetector).last;
      await tester.tap(chevronFinder);
      await tester.pump();

      // SizeTransition should snap to 0 instantly — no intermediate frames.
      final st = tester.widget<SizeTransition>(find.byType(SizeTransition));
      expect(st.sizeFactor.value, 0.0);
    });

    testWidgets('AnimatedRotation uses Duration.zero with disableAnimations', (
      tester,
    ) async {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: OiCard(
            collapsible: true,
            title: Text('Title'),
            child: Text('body content'),
          ),
        ),
      );

      final rotation = tester.widget<AnimatedRotation>(
        find.byType(AnimatedRotation),
      );
      expect(rotation.duration, Duration.zero);
    });
  });

  // ── OiAccordion ───────────────────────────────────────────────────────────

  group('REQ-0032 OiAccordion reduced motion', () {
    testWidgets('section expand completes instantly with disableAnimations', (
      tester,
    ) async {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: OiAccordion(
            sections: [
              OiAccordionSection(
                title: 'Section A',
                content: Text('Content A'),
              ),
            ],
          ),
        ),
      );

      // Section starts collapsed (initiallyExpanded defaults to false).
      // Tap header to expand.
      await tester.tap(find.text('Section A'));
      await tester.pump();

      // SizeTransition should snap to 1.0 instantly.
      final st = tester.widget<SizeTransition>(find.byType(SizeTransition));
      expect(st.sizeFactor.value, 1.0);
    });

    testWidgets('AnimatedRotation uses Duration.zero with disableAnimations', (
      tester,
    ) async {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: OiAccordion(
            sections: [
              OiAccordionSection(
                title: 'Section A',
                content: Text('Content A'),
              ),
            ],
          ),
        ),
      );

      final rotation = tester.widget<AnimatedRotation>(
        find.byType(AnimatedRotation),
      );
      expect(rotation.duration, Duration.zero);
    });
  });

  // ── OiSwitch ──────────────────────────────────────────────────────────────

  group('REQ-0032 OiSwitch reduced motion', () {
    testWidgets('toggle uses Duration.zero with disableAnimations', (
      tester,
    ) async {
      await tester.pumpObers(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: OiSwitch(value: false, onChanged: (_) {}),
        ),
      );

      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      for (final c in containers) {
        expect(c.duration, Duration.zero);
      }
    });
  });

  // ── OiSentiment ───────────────────────────────────────────────────────────

  group('REQ-0032 OiSentiment reduced motion', () {
    testWidgets('AnimatedContainer uses Duration.zero with disableAnimations', (
      tester,
    ) async {
      await tester.pumpObers(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: OiSentiment(
            emojis: const ['😊', '😐', '😢'],
            onChanged: (_) {},
          ),
        ),
      );

      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      for (final c in containers) {
        expect(c.duration, Duration.zero);
      }
    });
  });

  // ── OiDropHighlight ───────────────────────────────────────────────────────

  group('REQ-0032 OiDropHighlight reduced motion', () {
    testWidgets('AnimatedOpacity uses Duration.zero with disableAnimations', (
      tester,
    ) async {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: OiDropHighlight(
            active: true,
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.duration, Duration.zero);
    });
  });

  // ── OiTabs ────────────────────────────────────────────────────────────────

  group('REQ-0032 OiTabs reduced motion', () {
    testWidgets('tab animations use Duration.zero with disableAnimations', (
      tester,
    ) async {
      await tester.pumpObers(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: OiTabs(
            selectedIndex: 0,
            onSelected: (_) {},
            tabs: const [
              OiTabItem(label: 'Tab 1'),
              OiTabItem(label: 'Tab 2'),
            ],
          ),
        ),
      );

      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      for (final c in containers) {
        expect(c.duration, Duration.zero);
      }
    });
  });

  // ── OiDrawer ──────────────────────────────────────────────────────────────

  group('REQ-0032 OiDrawer reduced motion', () {
    testWidgets(
      'slide and opacity animations use Duration.zero with disableAnimations',
      (tester) async {
        await tester.pumpObers(
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: OiDrawer(open: true, child: Text('Drawer content')),
          ),
        );

        final opacity = tester.widget<AnimatedOpacity>(
          find.byType(AnimatedOpacity),
        );
        expect(opacity.duration, Duration.zero);

        final slide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
        expect(slide.duration, Duration.zero);
      },
    );
  });

  // ── OiTimePicker ──────────────────────────────────────────────────────────

  group('REQ-0032 OiTimePicker reduced motion', () {
    testWidgets(
      'AM/PM toggle AnimatedContainer uses Duration.zero with disableAnimations',
      (tester) async {
        await tester.pumpObers(
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: OiTimePicker(use24Hour: false),
          ),
        );

        final containers = tester.widgetList<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        for (final c in containers) {
          expect(c.duration, Duration.zero);
        }
      },
    );
  });

  // ── OiSheet ───────────────────────────────────────────────────────────────

  group('REQ-0032 OiSheet reduced motion', () {
    testWidgets('slide animation completes instantly with disableAnimations', (
      tester,
    ) async {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: OiSheet(
            label: 'Test sheet',
            open: true,
            child: Text('Sheet content'),
          ),
        ),
      );
      await tester.pump();

      // SlideTransition should be at final position immediately.
      final slide = tester.widget<SlideTransition>(
        find.byType(SlideTransition),
      );
      expect(slide.position.value, Offset.zero);
    });
  });

  // ── OiToast ───────────────────────────────────────────────────────────────

  group('REQ-0032 OiToast reduced motion', () {
    testWidgets('fade-in completes instantly with disableAnimations', (
      tester,
    ) async {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: OiToast(label: 'Test toast', message: 'Hello'),
        ),
      );
      await tester.pump();

      final fade = tester.widget<FadeTransition>(find.byType(FadeTransition));
      expect(fade.opacity.value, 1.0);
    });
  });

  // ── OiPanel ───────────────────────────────────────────────────────────────

  group('REQ-0032 OiPanel reduced motion', () {
    testWidgets('slide animation completes instantly with disableAnimations', (
      tester,
    ) async {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: OiPanel(
            label: 'Test panel',
            open: true,
            child: Text('Panel content'),
          ),
        ),
      );
      await tester.pump();

      final slide = tester.widget<SlideTransition>(
        find.byType(SlideTransition),
      );
      expect(slide.position.value, Offset.zero);
    });
  });

  // ── OiWizard ──────────────────────────────────────────────────────────────

  group('REQ-0032 OiWizard reduced motion', () {
    testWidgets('AnimatedSwitcher uses Duration.zero with disableAnimations', (
      tester,
    ) async {
      await tester.pumpObers(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: OiWizard(
            steps: [
              OiWizardStep(
                title: 'Step 1',
                builder: (_) => const Text('Step 1 content'),
              ),
              OiWizardStep(
                title: 'Step 2',
                builder: (_) => const Text('Step 2 content'),
              ),
            ],
          ),
        ),
      );

      final switcher = tester.widget<AnimatedSwitcher>(
        find.byType(AnimatedSwitcher),
      );
      expect(switcher.duration, Duration.zero);
    });
  });
}
