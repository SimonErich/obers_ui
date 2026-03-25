import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
// The barrel hides OiReactionData (chat variant) and OiFileData.
// OiChatMessage.reactions expects the chat-module variant, so import directly.
// ignore: implementation_imports
import 'package:obers_ui/src/modules/oi_chat.dart' as chat;

import 'package:obers_ui_example/apps/chat/logic/chat_auto_responder.dart';
import 'package:obers_ui_example/data/mock_chat.dart';
import 'package:obers_ui_example/data/mock_users.dart';
import 'package:obers_ui_example/shell/showcase_shell.dart';
import 'package:obers_ui_example/theme/theme_state.dart';

/// Chat mini-app with channels, DMs, reactions, reply preview, and
/// auto-replies.
class ChatApp extends StatefulWidget {
  const ChatApp({required this.themeState, super.key});

  final ThemeState themeState;

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  String _activeChannelId = kChannels.first.id;
  final Map<String, List<OiChatMessage>> _channelMessages = {};
  final Map<String, int> _unreadCounts = {};
  List<String> _typingUsers = [];
  late ChatAutoResponder _autoResponder;
  int _messageCounter = 0;

  // Sidebar search filter.
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Reply state.
  OiChatMessage? _replyingTo;

  // Sheet states.
  bool _pinnedSheetOpen = false;
  bool _infoSheetOpen = false;
  bool _profileSheetOpen = false;
  MockUser? _profileUser;

  @override
  void initState() {
    super.initState();

    // Pre-populate messages for every channel.
    for (final channel in kChannels) {
      _channelMessages[channel.id] = buildChannelMessages(channel.id);
      _unreadCounts[channel.id] = channel.unreadCount;
    }

    _autoResponder = _createAutoResponder();
  }

  ChatAutoResponder _createAutoResponder() {
    return ChatAutoResponder(
      onTypingChange: (users) {
        if (mounted) setState(() => _typingUsers = users);
      },
      onResponse: (senderId, senderName, content) {
        if (!mounted) return;
        setState(() {
          _messageCounter++;
          _channelMessages[_activeChannelId]!.add(
            OiChatMessage(
              key: 'auto-$_messageCounter',
              senderId: senderId,
              senderName: senderName,
              content: content,
              timestamp: DateTime.now(),
            ),
          );
        });
      },
    );
  }

  @override
  void dispose() {
    _autoResponder.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSend(String text) {
    setState(() {
      _messageCounter++;
      _channelMessages[_activeChannelId]!.add(
        OiChatMessage(
          key: 'sent-$_messageCounter',
          senderId: kCurrentUser.id,
          senderName: kCurrentUser.name,
          content: _replyingTo != null
              ? '> ${_replyingTo!.senderName}: ${_replyingTo!.content.length > 60 ? '${_replyingTo!.content.substring(0, 60)}...' : _replyingTo!.content}\n\n$text'
              : text,
          timestamp: DateTime.now(),
        ),
      );
      _replyingTo = null;
    });
    _autoResponder.trigger(text, kCurrentUser.id);
  }

  void _onReact(OiChatMessage message, String emoji) {
    setState(() {
      final messages = _channelMessages[_activeChannelId]!;
      final index = messages.indexWhere((m) => m.key == message.key);
      if (index < 0) return;

      final existing = messages[index];
      final reactions = List<chat.OiReactionData>.from(
        existing.reactions ?? [],
      );

      final reactionIndex = reactions.indexWhere((r) => r.emoji == emoji);
      if (reactionIndex >= 0) {
        final r = reactions[reactionIndex];
        if (r.reacted) {
          // Remove our reaction.
          if (r.count <= 1) {
            reactions.removeAt(reactionIndex);
          } else {
            reactions[reactionIndex] = chat.OiReactionData(
              emoji: r.emoji,
              count: r.count - 1,
              reacted: false,
              reactorNames: r.reactorNames,
            );
          }
        } else {
          // Add our reaction.
          reactions[reactionIndex] = chat.OiReactionData(
            emoji: r.emoji,
            count: r.count + 1,
            reacted: true,
            reactorNames: r.reactorNames,
          );
        }
      } else {
        // Brand new reaction.
        reactions.add(
          chat.OiReactionData(
            emoji: emoji,
            count: 1,
            reacted: true,
            reactorNames: [kCurrentUser.name],
          ),
        );
      }

      messages[index] = OiChatMessage(
        key: existing.key,
        senderId: existing.senderId,
        senderName: existing.senderName,
        content: existing.content,
        timestamp: existing.timestamp,
        senderAvatar: existing.senderAvatar,
        reactions: reactions,
        attachments: existing.attachments,
        pending: existing.pending,
      );
    });
  }

  void _selectChannel(String channelId) {
    setState(() {
      _activeChannelId = channelId;
      _unreadCounts[channelId] = 0;
      _typingUsers = [];
      _replyingTo = null;
    });
    _autoResponder.dispose();
    _autoResponder = _createAutoResponder();
  }

  MockChannel get _activeChannel =>
      kChannels.firstWhere((c) => c.id == _activeChannelId);

  /// Return the other user in a DM channel.
  MockUser? _dmPartner(MockChannel channel) {
    if (!channel.isDM) return null;
    return channel.members.firstWhere(
      (u) => u.id != kCurrentUser.id,
      orElse: () => channel.members.first,
    );
  }

  void _closePinnedSheet() => setState(() => _pinnedSheetOpen = false);

  void _closeInfoSheet() => setState(() => _infoSheetOpen = false);

  void _closeProfileSheet() => setState(() {
        _profileSheetOpen = false;
        _profileUser = null;
      });

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Chat',
      themeState: widget.themeState,
      child: Stack(
        children: [
          OiSplitPane(
            initialRatio: 0.22,
            minRatio: 0.15,
            maxRatio: 0.35,
            leading: _buildChannelSidebar(context),
            trailing: _buildMainPanel(context),
          ),
          // Pinned messages sheet.
          OiSheet(
            label: 'Pinned messages',
            open: _pinnedSheetOpen,
            side: OiPanelSide.right,
            size: 360,
            onClose: () => setState(() => _pinnedSheetOpen = false),
            child: _buildPinnedSheet(context),
          ),
          // Channel info sheet.
          OiSheet(
            label: 'Channel details',
            open: _infoSheetOpen,
            side: OiPanelSide.right,
            size: 360,
            onClose: () => setState(() => _infoSheetOpen = false),
            child: _buildInfoSheet(context),
          ),
          // User profile sheet.
          if (_profileUser != null)
            OiSheet(
              label: 'User profile',
              open: _profileSheetOpen,
              side: OiPanelSide.right,
              size: 360,
              onClose: () => setState(() {
                _profileSheetOpen = false;
                _profileUser = null;
              }),
              child: _buildProfileSheet(context, _profileUser!),
            ),
        ],
      ),
    );
  }

  // ── Main panel (header + reply preview + chat) ─────────────────────────────

  Widget _buildMainPanel(BuildContext context) {
    return Column(
      children: [
        _buildChannelHeader(context),
        if (_replyingTo != null)
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border(
                bottom: BorderSide(color: context.colors.borderSubtle),
              ),
            ),
            child: OiReplyPreview(
              senderName: _replyingTo!.senderName,
              content: _replyingTo!.content,
              dismissible: true,
              onDismiss: () => setState(() => _replyingTo = null),
            ),
          ),
        Expanded(
          child: OiChat(
            label: 'Chat messages',
            messages: _channelMessages[_activeChannelId] ?? [],
            currentUserId: kCurrentUser.id,
            onSend: _onSend,
            onReact: _onReact,
            onAttach: (_) {
              OiToast.show(context, message: 'File attachments coming soon');
            },
            typingUsers: _typingUsers.isNotEmpty ? _typingUsers : null,
          ),
        ),
      ],
    );
  }

  // ── Channel header bar ─────────────────────────────────────────────────────

  Widget _buildChannelHeader(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final channel = _activeChannel;

    final avatarItems = channel.members
        .map((u) => OiAvatarStackItem(label: u.name, initials: u.initials))
        .toList();

    return Container(
      height: 52,
      padding: EdgeInsets.symmetric(horizontal: spacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.borderSubtle)),
      ),
      child: Row(
        children: [
          // Channel name.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OiLabel.bodyStrong(channel.isDM ? channel.name : channel.name),
                if (channel.topic.isNotEmpty)
                  OiLabel.caption(
                    channel.topic,
                    color: colors.textMuted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          // Member avatars.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.sm),
            child: OiAvatarStack(users: avatarItems, size: OiAvatarSize.xs),
          ),
          // Pin button.
          OiIconButton(
            icon: OiIcons.mapPin,
            semanticLabel: 'Pinned messages',
            size: OiButtonSize.small,
            onTap: () => setState(() {
              _pinnedSheetOpen = !_pinnedSheetOpen;
              _infoSheetOpen = false;
            }),
          ),
          SizedBox(width: spacing.xs),
          // Info button.
          OiIconButton(
            icon: OiIcons.info,
            semanticLabel: 'Channel details',
            size: OiButtonSize.small,
            onTap: () => setState(() {
              _infoSheetOpen = !_infoSheetOpen;
              _pinnedSheetOpen = false;
            }),
          ),
        ],
      ),
    );
  }

  // ── Channel sidebar ────────────────────────────────────────────────────────

  Widget _buildChannelSidebar(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    final channels = kChannels.where((c) => !c.isDM).toList();
    final dms = kChannels.where((c) => c.isDM).toList();

    // Filter by search query.
    final filteredChannels = _searchQuery.isEmpty
        ? channels
        : channels
              .where(
                (c) =>
                    c.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();
    final filteredDms = _searchQuery.isEmpty
        ? dms
        : dms
              .where(
                (c) =>
                    c.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

    return ColoredBox(
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search input.
          Padding(
            padding: EdgeInsets.all(spacing.sm),
            child: OiTextInput.search(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ── Channels section ──
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.xs,
                  ),
                  child: OiLabel.overline('CHANNELS', color: colors.textMuted),
                ),
                for (final channel in filteredChannels)
                  _buildChannelEntry(context, channel),

                // New channel button.
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xs,
                  ),
                  child: OiButton.ghost(
                    label: 'New Channel',
                    icon: OiIcons.plus,
                    size: OiButtonSize.small,
                    onTap: () {
                      OiToast.show(
                        context,
                        message: 'Channel creation coming soon',
                      );
                    },
                  ),
                ),

                SizedBox(height: spacing.sm),

                // ── Direct Messages section ──
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.xs,
                  ),
                  child: OiLabel.overline(
                    'DIRECT MESSAGES',
                    color: colors.textMuted,
                  ),
                ),
                for (final dm in filteredDms) _buildDmEntry(context, dm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelEntry(BuildContext context, MockChannel channel) {
    final colors = context.colors;
    final spacing = context.spacing;
    final isActive = channel.id == _activeChannelId;
    final unread = _unreadCounts[channel.id] ?? 0;

    return OiTappable(
      semanticLabel: 'Select channel ${channel.name}',
      onTap: () => _selectChannel(channel.id),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? colors.primary.base.withValues(alpha: 0.1) : null,
        ),
        child: Row(
          children: [
            Icon(
              OiIcons.hash,
              size: 14,
              color: isActive ? colors.primary.base : colors.textSubtle,
            ),
            SizedBox(width: spacing.xs),
            Expanded(
              child: OiLabel.body(
                channel.name.replaceFirst('#', ''),
                color: isActive ? colors.primary.base : colors.text,
              ),
            ),
            if (unread > 0)
              OiBadge.soft(label: '$unread', size: OiBadgeSize.small),
          ],
        ),
      ),
    );
  }

  Widget _buildDmEntry(BuildContext context, MockChannel dm) {
    final colors = context.colors;
    final spacing = context.spacing;
    final isActive = dm.id == _activeChannelId;
    final unread = _unreadCounts[dm.id] ?? 0;
    final partner = _dmPartner(dm);
    final isOnline = partner != null && kOnlineUsers.contains(partner.id);

    return OiTappable(
      semanticLabel: 'Open DM with ${dm.name}',
      onTap: () => _selectChannel(dm.id),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? colors.primary.base.withValues(alpha: 0.1) : null,
        ),
        child: Row(
          children: [
            // Avatar with live ring for online users.
            GestureDetector(
              onTap: () {
                if (partner != null) {
                  setState(() {
                    _profileUser = partner;
                    _profileSheetOpen = true;
                    _pinnedSheetOpen = false;
                    _infoSheetOpen = false;
                  });
                }
              },
              child: OiLiveRing(
                active: isOnline,
                child: OiAvatar(
                  semanticLabel: dm.name,
                  initials: partner?.initials,
                  size: OiAvatarSize.xs,
                ),
              ),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: OiLabel.body(
                dm.name,
                color: isActive ? colors.primary.base : colors.text,
              ),
            ),
            if (unread > 0)
              OiBadge.soft(
                label: '$unread',
                size: OiBadgeSize.small,
                color: OiBadgeColor.accent,
              ),
          ],
        ),
      ),
    );
  }

  // ── Pinned messages sheet ──────────────────────────────────────────────────

  Widget _buildPinnedSheet(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final channel = _activeChannel;
    final pinnedKeys = kPinnedMessages[channel.id] ?? [];
    final messages = _channelMessages[channel.id] ?? [];
    final pinned = messages.where((m) => pinnedKeys.contains(m.key)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Row(
            children: [
              Icon(OiIcons.mapPin, size: 18, color: colors.primary.base),
              SizedBox(width: spacing.sm),
              const Expanded(child: OiLabel.h4('Pinned Messages')),
              OiIconButton(
                icon: OiIcons.x,
                semanticLabel: 'Close pinned messages',
                size: OiButtonSize.small,
                onTap: _closePinnedSheet,
              ),
            ],
          ),
        ),
        Expanded(
          child: pinned.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(spacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(OiIcons.mapPin, size: 40, color: colors.textMuted),
                        SizedBox(height: spacing.sm),
                        OiLabel.body(
                          'No pinned messages',
                          color: colors.textMuted,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: spacing.sm),
                  itemCount: pinned.length,
                  separatorBuilder: (_, __) => SizedBox(height: spacing.xs),
                  itemBuilder: (context, index) {
                    final msg = pinned[index];
                    return OiListTile(
                      title: msg.senderName,
                      subtitle: msg.content,
                      dense: true,
                      onTap: () {
                        setState(() {
                          _replyingTo = msg;
                          _pinnedSheetOpen = false;
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Channel info sheet ─────────────────────────────────────────────────────

  Widget _buildInfoSheet(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final channel = _activeChannel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Row(
            children: [
              Icon(
                OiIcons.info,
                size: 18,
                color: colors.primary.base,
              ),
              SizedBox(width: spacing.sm),
              const Expanded(child: OiLabel.h4('Channel Details')),
              OiIconButton(
                icon: OiIcons.x,
                semanticLabel: 'Close channel details',
                size: OiButtonSize.small,
                onTap: _closeInfoSheet,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OiLabel.overline('NAME', color: colors.textMuted),
              SizedBox(height: spacing.xs),
              OiLabel.body(channel.name),
              SizedBox(height: spacing.md),
              OiLabel.overline('DESCRIPTION', color: colors.textMuted),
              SizedBox(height: spacing.xs),
              OiLabel.body(channel.description),
              if (channel.topic.isNotEmpty) ...[
                SizedBox(height: spacing.md),
                OiLabel.overline('TOPIC', color: colors.textMuted),
                SizedBox(height: spacing.xs),
                OiLabel.body(channel.topic),
              ],
              SizedBox(height: spacing.md),
              OiLabel.overline(
                'MEMBERS (${channel.members.length})',
                color: colors.textMuted,
              ),
              SizedBox(height: spacing.sm),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: channel.members.length,
            itemBuilder: (context, index) {
              final member = channel.members[index];
              final isOnline = kOnlineUsers.contains(member.id);
              return OiListTile(
                leading: OiAvatar(
                  semanticLabel: member.name,
                  initials: member.initials,
                  size: OiAvatarSize.sm,
                  presence: isOnline
                      ? OiPresenceStatus.online
                      : OiPresenceStatus.offline,
                ),
                title: member.name,
                subtitle: member.role,
                dense: true,
                onTap: () {
                  setState(() {
                    _profileUser = member;
                    _profileSheetOpen = true;
                    _infoSheetOpen = false;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ── User profile sheet ─────────────────────────────────────────────────────

  Widget _buildProfileSheet(BuildContext context, MockUser user) {
    final colors = context.colors;
    final spacing = context.spacing;
    final isOnline = kOnlineUsers.contains(user.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Row(
            children: [
              const Expanded(child: OiLabel.h4('Profile')),
              OiIconButton(
                icon: OiIcons.x,
                semanticLabel: 'Close profile',
                size: OiButtonSize.small,
                onTap: _closeProfileSheet,
              ),
            ],
          ),
        ),
        // Avatar.
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.md),
          child: Column(
            children: [
              OiAvatar(
                semanticLabel: user.name,
                initials: user.initials,
                size: OiAvatarSize.xl,
                presence: isOnline
                    ? OiPresenceStatus.online
                    : OiPresenceStatus.offline,
              ),
              SizedBox(height: spacing.md),
              OiLabel.h3(user.name),
              SizedBox(height: spacing.xs),
              if (user.role != null)
                OiLabel.body(user.role!, color: colors.textMuted),
              SizedBox(height: spacing.lg),
            ],
          ),
        ),
        // Details.
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileField(context, 'Email', user.email),
              if (user.phone != null)
                _profileField(context, 'Phone', user.phone!),
              if (user.department != null)
                _profileField(context, 'Department', user.department!),
              if (user.location != null)
                _profileField(context, 'Location', user.location!),
              _profileField(context, 'Status', isOnline ? 'Online' : 'Offline'),
            ],
          ),
        ),
        SizedBox(height: spacing.lg),
        // Action buttons.
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.md),
          child: Row(
            children: [
              Expanded(
                child: OiButton.primary(
                  label: 'Message',
                  icon: OiIcons.messageSquare,
                  onTap: () {
                    // Find or indicate DM channel for this user.
                    final dmChannel = kChannels.cast<MockChannel?>().firstWhere(
                      (c) => c!.isDM && c.members.any((m) => m.id == user.id),
                      orElse: () => null,
                    );
                    if (dmChannel != null) {
                      setState(() {
                        _profileSheetOpen = false;
                        _profileUser = null;
                      });
                      _selectChannel(dmChannel.id);
                    } else {
                      OiToast.show(
                        context,
                        message: 'No DM channel with ${user.name}',
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _profileField(BuildContext context, String label, String value) {
    final colors = context.colors;
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OiLabel.overline(label.toUpperCase(), color: colors.textMuted),
          SizedBox(height: spacing.xs),
          OiLabel.body(value),
        ],
      ),
    );
  }
}
