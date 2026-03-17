import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_avatar.dart';
import 'package:obers_ui/src/composites/social/oi_avatar_stack.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// Displays a "typing..." indicator showing which users are actively typing.
///
/// Formats the message contextually:
/// - 1 user: "Alice is typing..."
/// - 2 users: "Alice and Bob are typing..."
/// - 3+ users: "3 people are typing..."
///
/// When [showAvatars] is `true` and [userDetails] is provided, small avatars
/// are shown alongside the text.
///
/// The trailing dots are animated with a looping opacity cycle.
///
/// {@category Composites}
class OiTypingIndicator extends StatefulWidget {
  /// Creates an [OiTypingIndicator].
  const OiTypingIndicator({
    required this.typingUsers,
    super.key,
    this.showAvatars = false,
    this.userDetails,
  });

  /// The names of users who are currently typing. An empty list renders
  /// nothing.
  final List<String> typingUsers;

  /// Whether to show small avatars next to the typing text.
  final bool showAvatars;

  /// Optional avatar details corresponding to [typingUsers]. When provided
  /// and [showAvatars] is `true`, an [OiAvatar] is rendered for each user.
  final List<OiAvatarStackItem>? userDetails;

  @override
  State<OiTypingIndicator> createState() => _OiTypingIndicatorState();
}

class _OiTypingIndicatorState extends State<OiTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _buildMessage() {
    final names = widget.typingUsers;
    if (names.length == 1) {
      return '${names.first} is typing';
    } else if (names.length == 2) {
      return '${names[0]} and ${names[1]} are typing';
    } else {
      return '${names.length} people are typing';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.typingUsers.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final message = _buildMessage();

    return Semantics(
      label: '$message...',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showAvatars && widget.userDetails != null) ...[
            ...widget.userDetails!.map(
              (u) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: OiAvatar(
                  semanticLabel: u.label,
                  imageUrl: u.imageUrl,
                  initials: u.initials,
                  size: OiAvatarSize.xs,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            message,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(width: 2),
          _AnimatedDots(controller: _controller, color: colors.textMuted),
        ],
      ),
    );
  }
}

/// Three dots whose opacity animates in sequence to create a wave effect.
class _AnimatedDots extends StatelessWidget {
  const _AnimatedDots({required this.controller, required this.color});

  /// The animation controller driving the dot cycle.
  final AnimationController controller;

  /// The color of the dots.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Stagger each dot by a third of the cycle.
            final phase = (controller.value + i / 3) % 1.0;
            final opacity = 0.3 + 0.7 * _triangle(phase);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Opacity(
                opacity: opacity,
                child: Text(
                  '.',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  /// A triangle wave that peaks at 0.5 and returns to 0 at 0 and 1.
  static double _triangle(double t) {
    return t < 0.5 ? t * 2 : 2 - t * 2;
  }
}
