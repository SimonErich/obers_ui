// Golden tests have no public API.
// ignore_for_file: public_member_api_docs

import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

void main() {
  // ── OiBadge ───────────────────────────────────────────────────────────────

  testGoldens('OiBadge variants — light', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 4,
      children: {
        'Primary filled': const OiBadge.filled(label: 'New'),
        'Accent filled': const OiBadge.filled(
          label: 'Accent',
          color: OiBadgeColor.accent,
        ),
        'Success filled': const OiBadge.filled(
          label: 'OK',
          color: OiBadgeColor.success,
        ),
        'Warning filled': const OiBadge.filled(
          label: 'Warn',
          color: OiBadgeColor.warning,
        ),
        'Error filled': const OiBadge.filled(
          label: 'Err',
          color: OiBadgeColor.error,
        ),
        'Info filled': const OiBadge.filled(
          label: 'Info',
          color: OiBadgeColor.info,
        ),
        'Neutral filled': const OiBadge.filled(
          label: 'N/A',
          color: OiBadgeColor.neutral,
        ),
        'Soft': const OiBadge.soft(label: 'Draft'),
        'Outline': const OiBadge.outline(label: 'v2.1'),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_badge_variants_light');
  });

  testGoldens('OiBadge variants — dark', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 4,
      theme: OiThemeData.dark(),
      children: {
        'Primary filled': const OiBadge.filled(label: 'New'),
        'Accent filled': const OiBadge.filled(
          label: 'Accent',
          color: OiBadgeColor.accent,
        ),
        'Success filled': const OiBadge.filled(
          label: 'OK',
          color: OiBadgeColor.success,
        ),
        'Warning filled': const OiBadge.filled(
          label: 'Warn',
          color: OiBadgeColor.warning,
        ),
        'Error filled': const OiBadge.filled(
          label: 'Err',
          color: OiBadgeColor.error,
        ),
        'Info filled': const OiBadge.filled(
          label: 'Info',
          color: OiBadgeColor.info,
        ),
        'Neutral filled': const OiBadge.filled(
          label: 'N/A',
          color: OiBadgeColor.neutral,
        ),
        'Soft': const OiBadge.soft(label: 'Draft'),
        'Outline': const OiBadge.outline(label: 'v2.1'),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_badge_variants_dark');
  });

  // ── OiAvatar ──────────────────────────────────────────────────────────────

  testGoldens('OiAvatar variants — light', (tester) async {
    final builder = obersGoldenBuilder(
      children: {
        'Initials': const OiAvatar(
          semanticLabel: 'User avatar',
          initials: 'AB',
        ),
        'Icon': const OiAvatar(
          semanticLabel: 'Default avatar',
          icon: OiIcons.user,
        ),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_avatar_variants_light');
  });

  testGoldens('OiAvatar variants — dark', (tester) async {
    final builder = obersGoldenBuilder(
      theme: OiThemeData.dark(),
      children: {
        'Initials': const OiAvatar(
          semanticLabel: 'User avatar',
          initials: 'AB',
        ),
        'Icon': const OiAvatar(
          semanticLabel: 'Default avatar',
          icon: OiIcons.user,
        ),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_avatar_variants_dark');
  });

  // ── OiProgress ────────────────────────────────────────────────────────────

  testGoldens('OiProgress variants — light', (tester) async {
    final builder = obersGoldenBuilder(
      children: {
        'Linear 0%': const OiProgress.linear(),
        'Linear 50%': const OiProgress.linear(value: 0.5),
        'Linear 100%': const OiProgress.linear(value: 1),
        'Circular 75%': const OiProgress.circular(value: 0.75),
        'Steps 2/5': const OiProgress.steps(steps: 5, currentStep: 2),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_progress_variants_light');
  });

  testGoldens('OiProgress variants — dark', (tester) async {
    final builder = obersGoldenBuilder(
      theme: OiThemeData.dark(),
      children: {
        'Linear 0%': const OiProgress.linear(),
        'Linear 50%': const OiProgress.linear(value: 0.5),
        'Linear 100%': const OiProgress.linear(value: 1),
        'Circular 75%': const OiProgress.circular(value: 0.75),
        'Steps 2/5': const OiProgress.steps(steps: 5, currentStep: 2),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_progress_variants_dark');
  });
}
