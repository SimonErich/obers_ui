import 'package:flutter/widgets.dart';

/// Describes a remote user's cursor position on a shared surface.
///
/// {@category Composites}
class OiRemoteCursor {
  /// Creates an [OiRemoteCursor].
  const OiRemoteCursor({
    required this.userId,
    required this.name,
    required this.color,
    required this.position,
    required this.lastMoved,
  });

  /// A unique identifier for the remote user.
  final String userId;

  /// The display name of the remote user.
  final String name;

  /// The color used to render this user's cursor.
  final Color color;

  /// The cursor position in logical pixels relative to the shared surface.
  final Offset position;

  /// The time the cursor was last moved. Used to fade out stale cursors.
  final DateTime lastMoved;
}

/// Overlays remote users' cursors on top of a shared [child] surface.
///
/// Each cursor is drawn at the position specified by [OiRemoteCursor.position]
/// with the user's assigned [OiRemoteCursor.color]. User names are shown next
/// to the cursor when [showNames] is `true`.
///
/// Cursors that have not been moved for longer than [fadeAfter] are rendered
/// at reduced opacity to indicate inactivity.
///
/// {@category Composites}
class OiCursorPresence extends StatelessWidget {
  /// Creates an [OiCursorPresence].
  const OiCursorPresence({
    required this.child,
    required this.cursors,
    super.key,
    this.showNames = true,
    this.fadeAfter = const Duration(seconds: 5),
  });

  /// The shared surface widget over which cursors are drawn.
  final Widget child;

  /// The list of remote cursors to render.
  final List<OiRemoteCursor> cursors;

  /// Whether to show the user's name next to their cursor.
  final bool showNames;

  /// Cursors inactive for longer than this duration are rendered at reduced
  /// opacity. Defaults to 5 seconds.
  final Duration fadeAfter;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Stack(
      children: [
        Positioned.fill(child: child),
        ...cursors.map((cursor) {
          final elapsed = now.difference(cursor.lastMoved);
          final isStale = elapsed > fadeAfter;
          final opacity = isStale ? 0.3 : 1.0;

          return Positioned(
            left: cursor.position.dx,
            top: cursor.position.dy,
            child: Opacity(
              opacity: opacity,
              child: _CursorWidget(cursor: cursor, showName: showNames),
            ),
          );
        }),
      ],
    );
  }
}

class _CursorWidget extends StatelessWidget {
  const _CursorWidget({required this.cursor, required this.showName});

  final OiRemoteCursor cursor;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomPaint(
          size: const Size(12, 18),
          painter: _CursorPainter(color: cursor.color),
        ),
        if (showName)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: cursor.color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              cursor.name,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
      ],
    );
  }
}

class _CursorPainter extends CustomPainter {
  _CursorPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width * 0.7, size.height * 0.65)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CursorPainter oldDelegate) => color != oldDelegate.color;
}
