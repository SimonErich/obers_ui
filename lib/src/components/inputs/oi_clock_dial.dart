import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_time_input.dart'
    show OiTimeOfDay;
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// What screen readers call the two faces of an [OiClockDial].
@immutable
class OiClockDialLabels {
  /// Creates the labels; English by default.
  const OiClockDialLabels({this.hours = 'Hour', this.minutes = 'Minute'});

  /// The face that picks the hour.
  final String hours;

  /// The face that picks the minute.
  final String minutes;
}

/// A clock face for picking a time of day with taps: the hour on the outer
/// ring (12 and 1–11) or the inner one (00 and 13–23), then the face turns
/// to minutes, and a tap on a minute (steps of five; drag for the exact
/// one) reports the time through [onChanged]. The readout above the face
/// switches between the two faces.
///
/// The pick is marked with the theme's primary fill and its foreground
/// colour; the digits are the theme's code face.
class OiClockDial extends StatefulWidget {
  /// Creates a clock dial starting at [value], or 9:00 when null.
  const OiClockDial({
    required this.onChanged,
    this.value,
    this.labels = const OiClockDialLabels(),
    this.size = 240,
    super.key,
  });

  /// The time to start from; 9:00 when null.
  final OiTimeOfDay? value;

  /// Called once a minute is picked.
  final ValueChanged<OiTimeOfDay> onChanged;

  /// The words for the two faces.
  final OiClockDialLabels labels;

  /// The face's diameter.
  final double size;

  @override
  State<OiClockDial> createState() => _OiClockDialState();
}

enum _Face { hours, minutes }

class _OiClockDialState extends State<OiClockDial> {
  late int _hour = widget.value?.hour ?? 9;
  late int _minute = widget.value?.minute ?? 0;
  _Face _face = _Face.hours;
  bool _dragging = false;

  double get _radius => widget.size / 2;
  double get _outer => _radius - 24;
  double get _inner => _radius - 64;

  /// The angle of [position] from the face's centre, 0 at the top and
  /// growing clockwise, and its distance from the centre.
  ({double angle, double distance}) _polar(Offset position) {
    final dx = position.dx - _radius;
    final dy = position.dy - _radius;
    final angle = (math.atan2(dx, -dy) + 2 * math.pi) % (2 * math.pi);
    return (angle: angle, distance: math.sqrt(dx * dx + dy * dy));
  }

  void _select(Offset position, {required bool exact}) {
    final (:angle, :distance) = _polar(position);
    setState(() {
      switch (_face) {
        case _Face.hours:
          final index = (angle / (math.pi / 6)).round() % 12;
          final inner = distance < (_outer + _inner) / 2;
          _hour = inner
              ? (index == 0 ? 0 : 12 + index)
              : (index == 0 ? 12 : index);
        case _Face.minutes:
          _minute = exact
              ? (angle / (2 * math.pi) * 60).round() % 60
              : (angle / (math.pi / 6)).round() % 12 * 5;
      }
    });
  }

  void _commit() {
    switch (_face) {
      case _Face.hours:
        setState(() => _face = _Face.minutes);
      case _Face.minutes:
        widget.onChanged(OiTimeOfDay(hour: _hour, minute: _minute));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final readout = context.textTheme.code.copyWith(fontSize: 32, height: 1);
    final hours = _face == _Face.hours;

    Widget part(String text, {required bool active, required _Face face}) =>
        OiTappable(
          onTap: () => setState(() => _face = face),
          semanticLabel: face == _Face.hours
              ? widget.labels.hours
              : widget.labels.minutes,
          child: Text(
            text,
            style: readout.copyWith(
              color: active ? colors.text : colors.textMuted,
            ),
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            part(
              _hour.toString().padLeft(2, '0'),
              active: hours,
              face: _Face.hours,
            ),
            Text(':', style: readout.copyWith(color: colors.textMuted)),
            part(
              _minute.toString().padLeft(2, '0'),
              active: !hours,
              face: _Face.minutes,
            ),
          ],
        ),
        SizedBox(height: spacing.sm),
        Semantics(
          label: hours ? widget.labels.hours : widget.labels.minutes,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _select(d.localPosition, exact: false),
            onTapUp: (_) => _commit(),
            onPanStart: (d) {
              _dragging = true;
              _select(d.localPosition, exact: true);
            },
            onPanUpdate: (d) => _select(d.localPosition, exact: true),
            onPanEnd: (_) {
              _dragging = false;
              _commit();
            },
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _DialPainter(
                face: _face,
                hour: _hour,
                minute: _minute,
                outer: _outer,
                inner: _inner,
                track: colors.surfaceHover,
                hand: colors.primary.base,
                onHand: colors.primary.foreground,
                text: colors.text,
                textMuted: colors.textMuted,
                digits: context.textTheme.code,
                exactMinute: _dragging,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.face,
    required this.hour,
    required this.minute,
    required this.outer,
    required this.inner,
    required this.track,
    required this.hand,
    required this.onHand,
    required this.text,
    required this.textMuted,
    required this.digits,
    required this.exactMinute,
  });

  final _Face face;
  final int hour;
  final int minute;
  final double outer;
  final double inner;
  final Color track;
  final Color hand;
  final Color onHand;
  final Color text;
  final Color textMuted;
  final TextStyle digits;
  final bool exactMinute;

  static const _pick = 18.0;

  Offset _at(Offset centre, double radius, double angle) =>
      centre + Offset(math.sin(angle) * radius, -math.cos(angle) * radius);

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    canvas.drawCircle(centre, size.width / 2, Paint()..color = track);

    final double angle;
    final double radius;
    switch (face) {
      case _Face.hours:
        angle = (hour % 12) * math.pi / 6;
        radius = hour == 0 || hour > 12 ? inner : outer;
      case _Face.minutes:
        angle = minute * math.pi / 30;
        radius = outer;
    }
    final end = _at(centre, radius, angle);
    canvas
      ..drawLine(
        centre,
        end,
        Paint()
          ..color = hand
          ..strokeWidth = 2,
      )
      ..drawCircle(centre, 4, Paint()..color = hand)
      ..drawCircle(end, _pick, Paint()..color = hand);

    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      switch (face) {
        case _Face.hours:
          final outerHour = i == 0 ? 12 : i;
          final innerHour = i == 0 ? 0 : 12 + i;
          _label(
            canvas,
            _at(centre, outer, a),
            '$outerHour',
            picked: hour == outerHour,
            muted: false,
          );
          _label(
            canvas,
            _at(centre, inner, a),
            innerHour.toString().padLeft(2, '0'),
            picked: hour == innerHour,
            muted: true,
          );
        case _Face.minutes:
          final m = i * 5;
          _label(
            canvas,
            _at(centre, outer, a),
            m.toString().padLeft(2, '0'),
            picked: minute == m,
            muted: false,
          );
      }
    }
  }

  void _label(
    Canvas canvas,
    Offset at,
    String value, {
    required bool picked,
    required bool muted,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: digits.copyWith(
          color: picked ? onHand : (muted ? textMuted : text),
          fontSize: muted ? 12 : 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.face != face ||
      old.hour != hour ||
      old.minute != minute ||
      old.exactMinute != exactMinute ||
      old.track != track ||
      old.hand != hand;
}
