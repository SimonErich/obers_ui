import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// Pipeline screen for the Project mini-app.
///
/// Shows a CI/CD-style deployment pipeline for the Q1 Relaunch project with
/// five stages and descriptive cards below.
class ProjectPipelineScreen extends StatelessWidget {
  const ProjectPipelineScreen({super.key});

  static const _stages = [
    OiPipelineStage(
      label: 'Development',
      status: OiPipelineStatus.completed,
      duration: Duration(days: 5, hours: 3),
    ),
    OiPipelineStage(
      label: 'Code Review',
      status: OiPipelineStatus.completed,
      duration: Duration(hours: 8, minutes: 45),
    ),
    OiPipelineStage(
      label: 'QA Testing',
      status: OiPipelineStatus.running,
      duration: Duration(hours: 2, minutes: 12),
    ),
    OiPipelineStage(label: 'Staging', status: OiPipelineStatus.pending),
    OiPipelineStage(label: 'Production', status: OiPipelineStatus.pending),
  ];

  static const _stageDescriptions = [
    _StageInfo(
      title: 'Development',
      description:
          'Feature branches merged into develop. '
          'All unit tests passing, code coverage at 94%.',
      icon: OiIcons.code,
      status: OiPipelineStatus.completed,
    ),
    _StageInfo(
      title: 'Code Review',
      description:
          'Pull requests reviewed by two team members. '
          'No critical findings, minor style fixes applied.',
      icon: OiIcons.eye,
      status: OiPipelineStatus.completed,
    ),
    _StageInfo(
      title: 'QA Testing',
      description:
          'Integration and E2E tests running. '
          '37 of 52 test suites completed, no failures so far.',
      icon: OiIcons.flaskConical,
      status: OiPipelineStatus.running,
    ),
    _StageInfo(
      title: 'Staging',
      description:
          'Deploy to staging environment for final UAT. '
          'Performance benchmarks and security scan pending.',
      icon: OiIcons.server,
      status: OiPipelineStatus.pending,
    ),
    _StageInfo(
      title: 'Production',
      description:
          'Blue-green deployment to production. '
          'Automated rollback configured, monitoring dashboards ready.',
      icon: OiIcons.rocket,
      status: OiPipelineStatus.pending,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const OiLabel.h3('Deployment Pipeline'),
          SizedBox(height: spacing.xs),
          const OiLabel.caption('Q1 Relaunch — Release v2.4.0'),
          SizedBox(height: spacing.lg),

          // Pipeline widget
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: OiPipeline(
              stages: _stages,
              label: 'Q1 Relaunch Deployment Pipeline',
            ),
          ),
          SizedBox(height: spacing.xl),

          // Stage detail cards
          const OiLabel.h4('Stage Details'),
          SizedBox(height: spacing.md),
          ..._stageDescriptions.map(
            (info) => Padding(
              padding: EdgeInsets.only(bottom: spacing.sm),
              child: _buildStageCard(context, info, colors, spacing),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageCard(
    BuildContext context,
    _StageInfo info,
    OiColorScheme colors,
    OiSpacingScale spacing,
  ) {
    final stageColor = OiPipeline.statusColor(info.status, context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: stageColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Icon(info.icon, size: 20, color: stageColor)),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: OiLabel.bodyStrong(info.title)),
                    Icon(
                      OiPipeline.statusIcon(info.status),
                      size: 16,
                      color: stageColor,
                    ),
                  ],
                ),
                SizedBox(height: spacing.xs),
                OiLabel.caption(info.description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StageInfo {
  const _StageInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.status,
  });

  final String title;
  final String description;
  final IconData icon;
  final OiPipelineStatus status;
}
