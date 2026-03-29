import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_avatar.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_spacing_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// User profile data for an [OiProfilePage].
///
/// {@category Modules}
@immutable
class OiProfileData {
  /// Creates an [OiProfileData].
  const OiProfileData({
    required this.name,
    required this.email,
    this.avatarUrl,
    this.role,
    this.phone,
    this.bio,
  });

  /// The user's display name.
  final String name;

  /// The user's email address.
  final String email;

  /// An optional URL for the user's avatar image.
  final String? avatarUrl;

  /// An optional role or title (e.g. "Admin", "Developer").
  final String? role;

  /// An optional phone number.
  final String? phone;

  /// An optional biography or description.
  final String? bio;
}

/// A linked external account in an [OiProfilePage].
///
/// {@category Modules}
@immutable
class OiLinkedAccount {
  /// Creates an [OiLinkedAccount].
  const OiLinkedAccount({
    required this.provider,
    required this.label,
    this.icon,
    this.connected = false,
    this.username,
  });

  /// A unique identifier for the provider (e.g. "google", "github").
  final String provider;

  /// The human-readable name of the provider (e.g. "Google", "GitHub").
  final String label;

  /// An optional icon for the provider.
  final IconData? icon;

  /// Whether this account is currently connected.
  final bool connected;

  /// The connected username, if available.
  final String? username;
}

/// A custom section in an [OiProfilePage].
///
/// {@category Modules}
@immutable
class OiProfileSection {
  /// Creates an [OiProfileSection].
  const OiProfileSection({required this.title, required this.child, this.icon});

  /// The section heading text.
  final String title;

  /// The content widget for this section.
  final Widget child;

  /// An optional icon displayed next to the section heading.
  final IconData? icon;
}

// ---------------------------------------------------------------------------
// Main widget
// ---------------------------------------------------------------------------

/// A user profile page with avatar, editable fields, linked accounts,
/// and a danger zone for account deletion.
///
/// {@category Modules}
class OiProfilePage extends StatefulWidget {
  /// Creates an [OiProfilePage].
  const OiProfilePage({
    required this.profile,
    required this.label,
    this.onAvatarChange,
    this.onFieldSave,
    this.onPasswordChange,
    this.linkedAccounts,
    this.onAccountLink,
    this.onAccountUnlink,
    this.onDeleteAccount,
    this.sections = const [],
    this.showDangerZone = true,
    super.key,
  });

  /// The profile data to display.
  final OiProfileData profile;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Called when the user requests to change their avatar.
  final Future<void> Function(Object imageData)? onAvatarChange;

  /// Called when the user saves a field. Returns `true` on success.
  final Future<bool> Function(String field, String value)? onFieldSave;

  /// Called when the user changes their password. Returns `true` on success.
  final Future<bool> Function(String current, String newPassword)?
  onPasswordChange;

  /// The list of linked external accounts to display.
  final List<OiLinkedAccount>? linkedAccounts;

  /// Called when the user requests to link an account.
  final void Function(OiLinkedAccount)? onAccountLink;

  /// Called when the user requests to unlink an account.
  final void Function(OiLinkedAccount)? onAccountUnlink;

  /// Called when the user confirms account deletion. Returns `true` on success.
  final Future<bool> Function()? onDeleteAccount;

  /// Additional custom sections to render below linked accounts.
  final List<OiProfileSection> sections;

  /// Whether to show the danger zone for account deletion.
  final bool showDangerZone;

  @override
  State<OiProfilePage> createState() => _OiProfilePageState();
}

class _OiProfilePageState extends State<OiProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;

  final ScrollController _scrollController = ScrollController();

  /// Keys for each section so the sidebar can scroll to them.
  final GlobalKey _personalInfoKey = GlobalKey();
  final GlobalKey _linkedAccountsKey = GlobalKey();
  final GlobalKey _dangerZoneKey = GlobalKey();
  final Map<int, GlobalKey> _customSectionKeys = {};

  int _activeNavIndex = 0;

  bool _deleteConfirmPending = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _initCustomSectionKeys();
  }

  void _initCustomSectionKeys() {
    for (var i = 0; i < widget.sections.length; i++) {
      _customSectionKeys.putIfAbsent(i, GlobalKey.new);
    }
  }

  @override
  void didUpdateWidget(OiProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _nameController.text = widget.profile.name;
      _emailController.text = widget.profile.email;
      _phoneController.text = widget.profile.phone ?? '';
      _bioController.text = widget.profile.bio ?? '';
    }
    if (oldWidget.sections.length != widget.sections.length) {
      _initCustomSectionKeys();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Field saving
  // ---------------------------------------------------------------------------

  Future<void> _saveField(String field, String value) async {
    await widget.onFieldSave?.call(field, value);
  }

  // ---------------------------------------------------------------------------
  // Delete account
  // ---------------------------------------------------------------------------

  Future<void> _handleDelete() async {
    if (!_deleteConfirmPending) {
      setState(() => _deleteConfirmPending = true);
      return;
    }
    setState(() => _deleteConfirmPending = false);
    await widget.onDeleteAccount?.call();
  }

  // ---------------------------------------------------------------------------
  // Navigation helpers
  // ---------------------------------------------------------------------------

  /// Builds the ordered list of sidebar navigation entries with their keys.
  List<_NavEntry> _buildNavEntries() {
    final entries = <_NavEntry>[
      _NavEntry('Personal Information', _personalInfoKey),
    ];
    if (widget.linkedAccounts != null && widget.linkedAccounts!.isNotEmpty) {
      entries.add(_NavEntry('Linked Accounts', _linkedAccountsKey));
    }
    for (var i = 0; i < widget.sections.length; i++) {
      entries.add(_NavEntry(widget.sections[i].title, _customSectionKeys[i]!));
    }
    if (widget.showDangerZone) {
      entries.add(_NavEntry('Danger Zone', _dangerZoneKey));
    }
    return entries;
  }

  void _scrollToSection(int index) {
    final entries = _buildNavEntries();
    if (index < 0 || index >= entries.length) return;

    final key = entries[index].key;
    final ctx = key.currentContext;
    if (ctx != null) {
      unawaited(
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
      );
    }
    setState(() => _activeNavIndex = index);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final sp = context.spacing;
    final isDesktop =
        context.breakpoint.minWidth >= OiBreakpoint.expanded.minWidth;

    return Semantics(
      label: widget.label,
      container: true,
      child: isDesktop
          ? _buildDesktopLayout(context, sp)
          : _buildMobileLayout(context, sp),
    );
  }

  // ---------------------------------------------------------------------------
  // Mobile layout (unchanged single column)
  // ---------------------------------------------------------------------------

  Widget _buildMobileLayout(BuildContext context, OiSpacingScale sp) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: sp.md, vertical: sp.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAvatarSection(context),
              SizedBox(height: sp.xl),
              _buildPersonalInfo(context),
              if (widget.linkedAccounts != null &&
                  widget.linkedAccounts!.isNotEmpty) ...[
                SizedBox(height: sp.xl),
                _buildLinkedAccounts(context),
              ],
              ..._buildCustomSections(context),
              if (widget.showDangerZone) ...[
                SizedBox(height: sp.xl),
                _buildDangerZone(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Desktop layout (2-column with sidebar)
  // ---------------------------------------------------------------------------

  Widget _buildDesktopLayout(BuildContext context, OiSpacingScale sp) {
    final colors = context.colors;
    final entries = _buildNavEntries();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sp.md, vertical: sp.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Left sidebar ---
              SizedBox(
                width: 280,
                child: Container(
                  padding: EdgeInsets.all(sp.lg),
                  decoration: BoxDecoration(
                    color: colors.surfaceSubtle,
                    borderRadius: context.radius.lg,
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    children: [
                      // Large avatar
                      OiAvatar(
                        semanticLabel:
                            'Profile photo of ${widget.profile.name}',
                        imageUrl: widget.profile.avatarUrl,
                        initials: _initialsFromName(widget.profile.name),
                        size: OiAvatarSize.xl,
                      ),
                      SizedBox(height: sp.md),
                      OiLabel.h3(
                        widget.profile.name,
                        textAlign: TextAlign.center,
                      ),
                      if (widget.profile.role != null) ...[
                        SizedBox(height: sp.xs),
                        OiLabel.small(
                          widget.profile.role!,
                          color: colors.textMuted,
                          textAlign: TextAlign.center,
                        ),
                      ],
                      SizedBox(height: sp.xl),
                      const OiDivider(),
                      SizedBox(height: sp.md),
                      // Section nav list
                      ...List.generate(entries.length, (i) {
                        final entry = entries[i];
                        final isActive = _activeNavIndex == i;
                        return Padding(
                          padding: EdgeInsets.only(bottom: sp.xs),
                          child: OiTappable(
                            onTap: () => _scrollToSection(i),
                            semanticLabel: 'Navigate to ${entry.title}',
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: sp.sm,
                                vertical: sp.sm,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? colors.primary.base.withValues(alpha: 0.1)
                                    : null,
                                borderRadius: context.radius.sm,
                              ),
                              child: OiLabel.body(
                                entry.title,
                                color: isActive
                                    ? colors.primary.base
                                    : colors.text,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              SizedBox(width: sp.lg),
              // --- Right content ---
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.only(bottom: sp.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPersonalInfo(context),
                      if (widget.linkedAccounts != null &&
                          widget.linkedAccounts!.isNotEmpty) ...[
                        SizedBox(height: sp.xl),
                        _buildLinkedAccounts(context),
                      ],
                      ..._buildCustomSections(context),
                      if (widget.showDangerZone) ...[
                        SizedBox(height: sp.xl),
                        _buildDangerZone(context),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Avatar section
  // ---------------------------------------------------------------------------

  Widget _buildAvatarSection(BuildContext context) {
    final colors = context.colors;
    final sp = context.spacing;

    return Column(
      children: [
        // Avatar with camera overlay
        SizedBox(
          width: 88,
          height: 88,
          child: Stack(
            children: [
              OiAvatar(
                semanticLabel: 'Profile photo of ${widget.profile.name}',
                imageUrl: widget.profile.avatarUrl,
                initials: _initialsFromName(widget.profile.name),
                size: OiAvatarSize.xl,
              ),
              if (widget.onAvatarChange != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: OiTappable(
                    onTap: () => widget.onAvatarChange?.call('image_picker'),
                    semanticLabel: 'Change profile photo',
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colors.primary.base,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                      child: Center(
                        child: Icon(
                          OiIcons.camera,
                          size: 14,
                          color: colors.primary.foreground,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: sp.sm),
        OiLabel.h3(widget.profile.name, textAlign: TextAlign.center),
        if (widget.profile.role != null) ...[
          SizedBox(height: sp.xs),
          OiLabel.small(
            widget.profile.role!,
            color: colors.textMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Personal information
  // ---------------------------------------------------------------------------

  Widget _buildPersonalInfo(BuildContext context) {
    final sp = context.spacing;
    final colors = context.colors;

    return Column(
      key: _personalInfoKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Row(
            children: [
              Icon(OiIcons.user, size: 18, color: colors.text),
              SizedBox(width: sp.xs),
              const OiLabel.h4('Personal Information'),
            ],
          ),
        ),
        SizedBox(height: sp.md),
        _buildFieldRow(
          context,
          label: 'Name',
          controller: _nameController,
          field: 'name',
        ),
        SizedBox(height: sp.sm),
        _buildFieldRow(
          context,
          label: 'Email',
          controller: _emailController,
          field: 'email',
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: sp.sm),
        _buildFieldRow(
          context,
          label: 'Phone',
          controller: _phoneController,
          field: 'phone',
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: sp.sm),
        _buildFieldRow(
          context,
          label: 'Bio',
          controller: _bioController,
          field: 'bio',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildFieldRow(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String field,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final sp = context.spacing;

    return Row(
      crossAxisAlignment: maxLines > 1
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: OiTextInput(
            controller: controller,
            label: label,
            keyboardType: keyboardType,
            maxLines: maxLines,
          ),
        ),
        if (widget.onFieldSave != null) ...[
          SizedBox(width: sp.sm),
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? sp.lg : 0),
            child: OiButton.ghost(
              label: 'Save $label',
              icon: OiIcons.check,
              size: OiButtonSize.small,
              onTap: () => _saveField(field, controller.text),
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Linked accounts
  // ---------------------------------------------------------------------------

  Widget _buildLinkedAccounts(BuildContext context) {
    final sp = context.spacing;
    final colors = context.colors;
    final accounts = widget.linkedAccounts!;

    return Column(
      key: _linkedAccountsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Row(
            children: [
              Icon(OiIcons.link, size: 18, color: colors.text),
              SizedBox(width: sp.xs),
              const OiLabel.h4('Linked Accounts'),
            ],
          ),
        ),
        SizedBox(height: sp.md),
        ...accounts.map((account) => _buildAccountRow(context, account)),
      ],
    );
  }

  Widget _buildAccountRow(BuildContext context, OiLinkedAccount account) {
    final sp = context.spacing;
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: sp.sm),
      child: Column(
        children: [
          Row(
            children: [
              if (account.icon != null) ...[
                Icon(account.icon, size: 20, color: colors.text),
                SizedBox(width: sp.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OiLabel.body(account.label),
                    if (account.connected && account.username != null)
                      OiLabel.small(account.username!, color: colors.textMuted),
                  ],
                ),
              ),
              if (account.connected)
                Padding(
                  padding: EdgeInsets.only(right: sp.sm),
                  child: const OiBadge.soft(
                    label: 'Connected',
                    color: OiBadgeColor.success,
                  ),
                ),
              if (account.connected && widget.onAccountUnlink != null)
                OiButton.ghost(
                  label: 'Disconnect',
                  size: OiButtonSize.small,
                  onTap: () => widget.onAccountUnlink?.call(account),
                )
              else if (!account.connected && widget.onAccountLink != null)
                OiButton.primary(
                  label: 'Connect',
                  size: OiButtonSize.small,
                  onTap: () => widget.onAccountLink?.call(account),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: sp.sm),
            child: const OiDivider(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Custom sections
  // ---------------------------------------------------------------------------

  List<Widget> _buildCustomSections(BuildContext context) {
    final sp = context.spacing;
    final colors = context.colors;

    return List.generate(widget.sections.length, (i) {
      final section = widget.sections[i];
      return Padding(
        key: _customSectionKeys[i],
        padding: EdgeInsets.only(top: sp.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Row(
                children: [
                  if (section.icon != null) ...[
                    Icon(section.icon, size: 18, color: colors.text),
                    SizedBox(width: sp.xs),
                  ],
                  OiLabel.h4(section.title),
                ],
              ),
            ),
            SizedBox(height: sp.md),
            section.child,
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Danger zone
  // ---------------------------------------------------------------------------

  Widget _buildDangerZone(BuildContext context) {
    final sp = context.spacing;
    final colors = context.colors;

    return Container(
      key: _dangerZoneKey,
      padding: EdgeInsets.all(sp.md),
      decoration: BoxDecoration(
        borderRadius: context.radius.md,
        border: Border.all(color: colors.error.base),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Row(
              children: [
                Icon(OiIcons.shield, size: 18, color: colors.error.base),
                SizedBox(width: sp.xs),
                OiLabel.h4('Danger Zone', color: colors.error.base),
              ],
            ),
          ),
          SizedBox(height: sp.sm),
          OiLabel.small(
            'Permanently delete your account and all associated data. '
            'This action cannot be undone.',
            color: colors.textMuted,
          ),
          SizedBox(height: sp.md),
          OiButton.destructive(
            label: _deleteConfirmPending
                ? 'Are you sure? Tap again to confirm'
                : 'Delete Account',
            icon: OiIcons.trash2,
            onTap: widget.onDeleteAccount != null ? _handleDelete : null,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '';
  }
}

// ---------------------------------------------------------------------------
// Internal nav entry model
// ---------------------------------------------------------------------------

@immutable
class _NavEntry {
  const _NavEntry(this.title, this.key);

  final String title;
  final GlobalKey key;
}
