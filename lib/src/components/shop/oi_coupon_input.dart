import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_coupon_result.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

// Material Icons codepoints.
const IconData _kCheckIcon = OiIcons.circleCheck;
const IconData _kCloseIcon = OiIcons.x;

/// A text input field with 'Apply' button for discount/coupon codes.
///
/// Coverage: REQ-0032
///
/// Shows success or error inline after applying. When a valid code is applied,
/// shows a green check, the applied code, and a remove (X) button. Invalid
/// codes show a red error message. Empty submit is prevented.
///
/// Composes [OiRow], [OiTextInput], [OiButton], [OiLabel], [OiIcon].
///
/// {@category Components}
class OiCouponInput extends StatefulWidget {
  /// Creates an [OiCouponInput].
  const OiCouponInput({
    required this.label,
    required this.onApply,
    this.onRemove,
    this.appliedCode,
    this.loading = false,
    super.key,
  });

  /// Accessibility label / visible label for the input.
  final String label;

  /// Called when the user taps 'Apply'. Returns an [OiCouponResult].
  final Future<OiCouponResult> Function(String code) onApply;

  /// Called when the user removes the applied code.
  final VoidCallback? onRemove;

  /// The currently applied coupon code. When non-null, shows applied mode.
  final String? appliedCode;

  /// Whether the Apply button should show a loading state.
  ///
  /// Defaults to `false`.
  final bool loading;

  @override
  State<OiCouponInput> createState() => _OiCouponInputState();
}

class _OiCouponInputState extends State<OiCouponInput> {
  late final TextEditingController _controller;
  String? _errorMessage;
  bool _submitting = false;
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final empty = _controller.text.trim().isEmpty;
    if (empty != _isEmpty) {
      setState(() => _isEmpty = empty);
    }
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  Future<void> _handleApply() async {
    final code = _controller.text.trim();
    if (code.isEmpty || _submitting) return;

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.onApply(code);
      if (!mounted) return;

      if (result.valid) {
        _controller.clear();
        setState(() => _submitting = false);
      } else {
        setState(() {
          _submitting = false;
          _errorMessage = result.message ?? 'Invalid code';
        });
      }
    } on Exception catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  void _handleRemove() {
    _controller.clear();
    setState(() {
      _errorMessage = null;
      _submitting = false;
    });
    widget.onRemove?.call();
  }

  Widget _buildInputMode(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;

    final isLoading = widget.loading || _submitting;
    final buttonEnabled = !_isEmpty && !isLoading;

    final children = <Widget>[
      OiRow(
        breakpoint: breakpoint,
        gap: OiResponsive(sp.sm),
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: OiTextInput(
              controller: _controller,
              placeholder: 'Enter coupon code',
              label: widget.label,
              enabled: !isLoading,
              onSubmitted: buttonEnabled ? (_) => _handleApply() : null,
            ),
          ),
          OiButton.primary(
            label: 'Apply',
            onTap: buttonEnabled ? _handleApply : null,
            enabled: buttonEnabled,
            loading: isLoading,
          ),
        ],
      ),
    ];

    if (_errorMessage != null) {
      children.add(
        Padding(
          padding: EdgeInsets.only(top: sp.xs),
          child: OiLabel.small(
            _errorMessage!,
            key: const Key('coupon_error'),
            color: context.colors.error.base,
          ),
        ),
      );
    }

    return OiColumn(
      breakpoint: breakpoint,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildAppliedMode(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;
    final colors = context.colors;

    return OiRow(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      children: [
        OiIcon(
          icon: _kCheckIcon,
          label: 'Applied',
          size: 18,
          color: colors.success.base,
        ),
        Expanded(
          child: OiLabel.bodyStrong(
            widget.appliedCode!,
            key: const Key('coupon_applied_code'),
          ),
        ),
        OiButton.ghost(
          label: 'Remove coupon',
          icon: _kCloseIcon,
          size: OiButtonSize.small,
          onTap: _handleRemove,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      child: widget.appliedCode != null
          ? _buildAppliedMode(context)
          : _buildInputMode(context),
    );
  }
}
