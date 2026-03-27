import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_avatar.dart';
import 'package:obers_ui/src/components/display/oi_list_tile.dart';
import 'package:obers_ui/src/components/display/oi_popover.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A workspace / organization / account selector dropdown.
///
/// Renders a trigger showing the active account's avatar and name (or just the
/// avatar in [compact] mode). Tapping the trigger opens a popover listing all
/// available accounts. The active account is highlighted with a check icon.
///
/// Optionally supports search filtering ([searchable]), an "Add account" action
/// ([onAddAccount]), and custom [header] / [footer] widgets inside the dropdown.
///
/// {@category Components}
class OiAccountSwitcher<T> extends StatefulWidget {
  /// Creates an [OiAccountSwitcher].
  const OiAccountSwitcher({
    required this.accounts,
    required this.activeAccount,
    required this.onSelect,
    required this.label,
    this.labelOf,
    this.avatarOf,
    this.descriptionOf,
    this.colorOf,
    this.accountKey,
    this.onAddAccount,
    this.addAccountLabel,
    this.searchable = false,
    this.searchHint,
    this.compact = false,
    this.maxVisible,
    this.header,
    this.footer,
    this.semanticLabel,
    super.key,
  });

  /// All available accounts.
  final List<T> accounts;

  /// The currently active account.
  final T activeAccount;

  /// Called when the user selects an account.
  final ValueChanged<T> onSelect;

  /// Accessible label for screen readers.
  final String label;

  /// Returns the display name for an account. Defaults to [toString].
  final String Function(T)? labelOf;

  /// Returns the avatar initials or URL for an account.
  final String Function(T)? avatarOf;

  /// Returns a subtitle description for an account.
  final String Function(T)? descriptionOf;

  /// Returns an accent color for an account.
  final Color Function(T)? colorOf;

  /// Returns a unique key for an account. Useful when [T] does not
  /// implement [==].
  final Object Function(T)? accountKey;

  /// Called when the user taps "Add account". Hidden when `null`.
  final VoidCallback? onAddAccount;

  /// Label for the add-account action. Defaults to `'Add account'`.
  final String? addAccountLabel;

  /// Whether the dropdown shows a search field.
  final bool searchable;

  /// Placeholder text for the search field.
  final String? searchHint;

  /// When `true`, the trigger shows only the avatar (no name text).
  final bool compact;

  /// Maximum number of accounts visible before scrolling. Defaults to 8.
  final int? maxVisible;

  /// Custom header widget placed at the top of the dropdown.
  final Widget? header;

  /// Custom footer widget placed at the bottom of the dropdown.
  final Widget? footer;

  /// Optional semantic label override for the trigger.
  final String? semanticLabel;

  @override
  State<OiAccountSwitcher<T>> createState() => _OiAccountSwitcherState<T>();
}

class _OiAccountSwitcherState<T> extends State<OiAccountSwitcher<T>> {
  bool _isOpen = false;
  String _searchQuery = '';

  String _labelFor(T account) =>
      widget.labelOf?.call(account) ?? account.toString();

  String? _avatarFor(T account) => widget.avatarOf?.call(account);

  String? _descriptionFor(T account) => widget.descriptionOf?.call(account);

  bool _isActive(T account) {
    if (widget.accountKey != null) {
      return widget.accountKey!(account) ==
          widget.accountKey!(widget.activeAccount);
    }
    return account == widget.activeAccount;
  }

  List<T> get _filteredAccounts {
    if (_searchQuery.isEmpty) return widget.accounts;
    final query = _searchQuery.toLowerCase();
    return widget.accounts
        .where((a) => _labelFor(a).toLowerCase().contains(query))
        .toList();
  }

  void _handleSelect(T account) {
    setState(() {
      _isOpen = false;
      _searchQuery = '';
    });
    widget.onSelect(account);
  }

  void _handleAddAccount() {
    setState(() {
      _isOpen = false;
      _searchQuery = '';
    });
    widget.onAddAccount?.call();
  }

  Widget _buildTrigger(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final active = widget.activeAccount;
    final avatar = _avatarFor(active);
    final name = _labelFor(active);

    final color = widget.colorOf?.call(active);

    final avatarWidget = OiAvatar(
      semanticLabel: name,
      initials: avatar,
      size: OiAvatarSize.sm,
      backgroundColor: color,
    );

    final content = widget.compact
        ? avatarWidget
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              avatarWidget,
              SizedBox(width: spacing.sm),
              Flexible(
                child: OiLabel.bodyStrong(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: spacing.xs),
              OiIcon.decorative(
                icon: OiIcons.chevronDown,
                size: 16,
                color: colors.textMuted,
              ),
            ],
          );

    return OiTappable(
      semanticLabel: widget.semanticLabel ?? widget.label,
      onTap: widget.accounts.length > 1
          ? () => setState(() => _isOpen = !_isOpen)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: content,
      ),
    );
  }

  Widget _buildDropdownContent(BuildContext context) {
    final spacing = context.spacing;
    final filtered = _filteredAccounts;
    final maxVisible = widget.maxVisible ?? 8;

    final accountList = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final account in filtered)
          OiListTile(
            title: _labelFor(account),
            subtitle: _descriptionFor(account),
            leading: OiAvatar(
              semanticLabel: _labelFor(account),
              initials: _avatarFor(account),
              size: OiAvatarSize.xs,
              backgroundColor: widget.colorOf?.call(account),
            ),
            trailing: _isActive(account)
                ? const OiIcon.decorative(icon: OiIcons.check, size: 16)
                : null,
            selected: _isActive(account),
            onTap: () => _handleSelect(account),
            dense: true,
          ),
      ],
    );

    final needsScroll = filtered.length > maxVisible;
    final listWidget = needsScroll
        ? SizedBox(
            // Approximate 40dp per dense tile.
            height: maxVisible * 40.0,
            child: SingleChildScrollView(child: accountList),
          )
        : accountList;

    return UnconstrainedBox(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.header != null) ...[
              widget.header!,
              SizedBox(height: spacing.xs),
            ],
            if (widget.searchable) ...[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                child: OiTextInput(
                  placeholder: widget.searchHint ?? 'Search accounts\u2026',
                  leading: const OiIcon.decorative(
                    icon: OiIcons.search,
                    size: 18,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                  autofocus: true,
                ),
              ),
            ],
            Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.xs),
              child: listWidget,
            ),
            if (widget.onAddAccount != null) ...[
              OiListTile(
                title: widget.addAccountLabel ?? 'Add account',
                leading: const OiIcon.decorative(icon: OiIcons.plus, size: 16),
                onTap: _handleAddAccount,
                dense: true,
              ),
            ],
            if (widget.footer != null) ...[
              SizedBox(height: spacing.xs),
              widget.footer!,
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trigger = _buildTrigger(context);

    if (widget.accounts.length <= 1) return trigger;

    return OiPopover(
      label: widget.label,
      open: _isOpen,
      onClose: () => setState(() {
        _isOpen = false;
        _searchQuery = '';
      }),
      anchor: trigger,
      content: _buildDropdownContent(context),
    );
  }
}
