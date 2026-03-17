import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A single section within an [OiAccordion].
///
/// {@category Components}
@immutable
class OiAccordionSection {
  /// Creates an [OiAccordionSection].
  const OiAccordionSection({
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
  });

  /// The heading text shown in the section header.
  final String title;

  /// The content revealed when this section is expanded.
  final Widget content;

  /// Whether this section starts in the expanded state.
  final bool initiallyExpanded;
}

/// A vertically stacked set of collapsible content sections.
///
/// Each [OiAccordionSection] shows a tappable header row with a chevron icon.
/// Tapping the header expands or collapses the section with a smooth size
/// animation.
///
/// When [allowMultiple] is `false` (the default), opening one section
/// automatically collapses any other open section.  When `true`, any number
/// of sections may be open simultaneously.
///
/// {@category Components}
class OiAccordion extends StatefulWidget {
  /// Creates an [OiAccordion].
  const OiAccordion({
    required this.sections,
    this.allowMultiple = false,
    super.key,
  });

  /// The list of sections to display.
  final List<OiAccordionSection> sections;

  /// Whether multiple sections may be expanded at the same time.
  ///
  /// Defaults to `false`.
  final bool allowMultiple;

  @override
  State<OiAccordion> createState() => _OiAccordionState();
}

class _OiAccordionState extends State<OiAccordion>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.sections.length, (i) {
      final section = widget.sections[i];
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        value: section.initiallyExpanded ? 1.0 : 0.0,
      );
    });
    _animations = _controllers.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.easeInOut);
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool _isOpen(int index) => _controllers[index].value > 0;

  void _toggle(int index) {
    final isCurrentlyOpen = _isOpen(index);
    if (!widget.allowMultiple) {
      // Close all others.
      for (var i = 0; i < _controllers.length; i++) {
        if (i != index && _controllers[i].value > 0) {
          _controllers[i].reverse();
        }
      }
    }
    if (isCurrentlyOpen) {
      _controllers[index].reverse();
    } else {
      _controllers[index].forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.sections.length, (i) {
        final section = widget.sections[i];
        final isLast = i == widget.sections.length - 1;

        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (context, _) {
            final open = _controllers[i].value > 0;
            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: isLast
                      ? BorderSide.none
                      : BorderSide(color: colors.borderSubtle),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OiTappable(
                    onTap: () => _toggle(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              section.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colors.text,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: open ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: Icon(
                              // chevron_down icon from MaterialIcons
                              const IconData(
                                0xe5cf,
                                fontFamily: 'MaterialIcons',
                              ),
                              size: 18,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizeTransition(
                    sizeFactor: _animations[i],
                    axisAlignment: -1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: section.content,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
