import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

const _environments = [
  OiDevEnvironment(
    key: 'dev',
    label: 'Development',
    url: 'https://dev.api.example.com',
  ),
  OiDevEnvironment(
    key: 'staging',
    label: 'Staging',
    url: 'https://staging.api.example.com',
  ),
  OiDevEnvironment(
    key: 'prod',
    label: 'Production',
    url: 'https://api.example.com',
  ),
];

const _featureFlags = [
  OiFeatureFlag(
    key: 'dark_mode',
    label: 'Dark Mode',
    description: 'Enable the dark theme for all users',
  ),
  OiFeatureFlag(
    key: 'new_checkout',
    label: 'New Checkout Flow',
    description: 'Redesigned multi-step checkout',
  ),
  OiFeatureFlag(
    key: 'ai_assist',
    label: 'AI Assistant',
    description: 'Show AI assistant in the sidebar',
  ),
  OiFeatureFlag(
    key: 'beta_api',
    label: 'Beta API',
    description: 'Use v2 beta API endpoints',
  ),
];

final _now = DateTime.now();

List<OiLogEntry> _buildSampleLogs() => [
  OiLogEntry(
    message: 'Application started',
    level: OiLogLevel.info,
    timestamp: _now.subtract(const Duration(minutes: 10)),
    source: 'Main',
  ),
  OiLogEntry(
    message: 'Connecting to staging server...',
    level: OiLogLevel.debug,
    timestamp: _now.subtract(const Duration(minutes: 9)),
    source: 'Http',
  ),
  OiLogEntry(
    message: 'Authentication successful',
    level: OiLogLevel.info,
    timestamp: _now.subtract(const Duration(minutes: 8)),
    source: 'Auth',
  ),
  OiLogEntry(
    message: 'Rate limit approaching (85%)',
    level: OiLogLevel.warning,
    timestamp: _now.subtract(const Duration(minutes: 7)),
    source: 'Http',
  ),
  OiLogEntry(
    message: 'Feature flag "new_checkout" enabled',
    level: OiLogLevel.debug,
    timestamp: _now.subtract(const Duration(minutes: 6)),
  ),
  OiLogEntry(
    message: 'WebSocket connection lost',
    level: OiLogLevel.error,
    timestamp: _now.subtract(const Duration(minutes: 5)),
    source: 'WS',
  ),
  OiLogEntry(
    message: 'Reconnecting in 3s...',
    level: OiLogLevel.warning,
    timestamp: _now.subtract(const Duration(minutes: 4)),
    source: 'WS',
  ),
  OiLogEntry(
    message: 'WebSocket reconnected',
    level: OiLogLevel.info,
    timestamp: _now.subtract(const Duration(minutes: 3)),
    source: 'WS',
  ),
  OiLogEntry(
    message: 'Cache cleared (42 entries)',
    level: OiLogLevel.debug,
    timestamp: _now.subtract(const Duration(minutes: 2)),
  ),
  OiLogEntry(
    message: 'Failed to sync user preferences',
    level: OiLogLevel.error,
    timestamp: _now.subtract(const Duration(minutes: 1)),
    source: 'Sync',
  ),
];

final oiDevMenuComponent = WidgetbookComponent(
  name: 'OiDevMenu',
  useCases: [
    WidgetbookUseCase(
      name: 'Standalone',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(width: 500, height: 600, child: _StandaloneDevMenu()),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Trigger Mode',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(width: 500, height: 600, child: _TriggerDevMenu()),
        );
      },
    ),
  ],
);

class _StandaloneDevMenu extends StatefulWidget {
  @override
  State<_StandaloneDevMenu> createState() => _StandaloneDevMenuState();
}

class _StandaloneDevMenuState extends State<_StandaloneDevMenu> {
  String _currentEnv = 'dev';
  Map<String, bool> _flagValues = {
    'dark_mode': false,
    'new_checkout': true,
    'ai_assist': false,
    'beta_api': false,
  };

  @override
  Widget build(BuildContext context) {
    return OiDevMenu(
      label: 'Developer Menu',
      environments: _environments,
      currentEnvironment: _currentEnv,
      onEnvironmentChange: (String key) => setState(() => _currentEnv = key),
      featureFlags: _featureFlags,
      featureFlagValues: _flagValues,
      onFeatureFlagChange: (String key, {required bool value}) => setState(() {
        _flagValues = Map<String, bool>.from(_flagValues)..[key] = value;
      }),
      actions: [
        OiDevAction(label: 'Clear Cache', onTap: () {}, icon: OiIcons.trash),
        OiDevAction(label: 'Force Sync', onTap: () {}, icon: OiIcons.zap),
        OiDevAction(
          label: 'Reset All Data',
          onTap: () {},
          icon: OiIcons.alertTriangle,
          destructive: true,
        ),
      ],
      logs: _buildSampleLogs(),
      onCopyLogs: () {},
    );
  }
}

class _TriggerDevMenu extends StatefulWidget {
  @override
  State<_TriggerDevMenu> createState() => _TriggerDevMenuState();
}

class _TriggerDevMenuState extends State<_TriggerDevMenu> {
  String _currentEnv = 'staging';
  Map<String, bool> _flagValues = {
    'dark_mode': true,
    'new_checkout': false,
    'ai_assist': true,
    'beta_api': false,
  };

  @override
  Widget build(BuildContext context) {
    return OiDevMenu.trigger(
      label: 'Developer Menu',
      environments: _environments,
      currentEnvironment: _currentEnv,
      onEnvironmentChange: (String key) => setState(() => _currentEnv = key),
      featureFlags: _featureFlags,
      featureFlagValues: _flagValues,
      onFeatureFlagChange: (String key, {required bool value}) => setState(() {
        _flagValues = Map<String, bool>.from(_flagValues)..[key] = value;
      }),
      actions: [
        OiDevAction(label: 'Clear Cache', onTap: () {}, icon: OiIcons.trash),
        OiDevAction(
          label: 'Reset All Data',
          onTap: () {},
          icon: OiIcons.alertTriangle,
          destructive: true,
        ),
      ],
      logs: _buildSampleLogs(),
      onCopyLogs: () {},
      child: const Center(
        child: OiLabel.body('Triple-tap anywhere to open the dev menu'),
      ),
    );
  }
}
