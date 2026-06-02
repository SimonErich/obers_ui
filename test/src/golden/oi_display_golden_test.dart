// Golden tests have no public API.

import 'package:alchemist/alchemist.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

Future<void> main() async {
  // ── OiBadge ───────────────────────────────────────────────────────────────

  await goldenTest(
    'OiBadge variants — light',
    fileName: 'oi_badge_variants_light',
    builder: () => obersGoldenGroup(
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
    ),
  );

  await goldenTest(
    'OiBadge variants — dark',
    fileName: 'oi_badge_variants_dark',
    builder: () => obersGoldenGroup(
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
    ),
  );

  // ── OiAvatar ──────────────────────────────────────────────────────────────

  await goldenTest(
    'OiAvatar variants — light',
    fileName: 'oi_avatar_variants_light',
    builder: () => obersGoldenGroup(
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
    ),
  );

  await goldenTest(
    'OiAvatar variants — dark',
    fileName: 'oi_avatar_variants_dark',
    builder: () => obersGoldenGroup(
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
    ),
  );

  // ── OiProgress ────────────────────────────────────────────────────────────

  await goldenTest(
    'OiProgress variants — light',
    fileName: 'oi_progress_variants_light',
    builder: () => obersGoldenGroup(
      children: {
        'Linear 0%': const OiProgress.linear(),
        'Linear 50%': const OiProgress.linear(value: 0.5),
        'Linear 100%': const OiProgress.linear(value: 1),
        'Circular 75%': const OiProgress.circular(value: 0.75),
        'Steps 2/5': const OiProgress.steps(steps: 5, currentStep: 2),
      },
    ),
  );

  await goldenTest(
    'OiProgress variants — dark',
    fileName: 'oi_progress_variants_dark',
    builder: () => obersGoldenGroup(
      theme: OiThemeData.dark(),
      children: {
        'Linear 0%': const OiProgress.linear(),
        'Linear 50%': const OiProgress.linear(value: 0.5),
        'Linear 100%': const OiProgress.linear(value: 1),
        'Circular 75%': const OiProgress.circular(value: 0.75),
        'Steps 2/5': const OiProgress.steps(steps: 5, currentStep: 2),
      },
    ),
  );
}
