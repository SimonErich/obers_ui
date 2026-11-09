part of '../oi_button.dart';

class _OiButtonState extends State<OiButton> {
  final WidgetStatesController _states = WidgetStatesController();

  void _statesChanged() {
    if (mounted) setState(() {});
  }

  bool _usesStateBackground(BuildContext context, [OiButtonVariant? variant]) {
    final style = _variantStyle(
      _buttonTheme(context),
      variant ?? widget.variant,
    );
    return style?.backgroundHover != null || style?.backgroundPressed != null;
  }

  /// Whether [OiTappable]'s hover/press overlay is skipped for [variant].
  ///
  /// It is skipped when the theme paints its own per-state fill, so the
  /// overlay does not tint that colour, and for ghost buttons, which signal
  /// hover by colouring their label instead of a grey background.
  bool _suppressOverlay(BuildContext context, [OiButtonVariant? variant]) =>
      (variant ?? widget.variant) == OiButtonVariant.ghost ||
      _usesStateBackground(context, variant);

  /// Whether the theme gives [variant] a look of its own for disabled, which
  /// then replaces the generic fade.
  bool _hasDisabledOverride(BuildContext context, [OiButtonVariant? variant]) {
    final style = _variantStyle(
      _buttonTheme(context),
      variant ?? widget.variant,
    );
    return style?.backgroundDisabled != null ||
        style?.foregroundDisabled != null ||
        style?.borderDisabled != null;
  }

  // ── Confirm state ──────────────────────────────────────────────────────────
  bool _confirmPending = false;

  // ── Split dropdown state ───────────────────────────────────────────────────
  bool _dropdownVisible = false;

  // ── Countdown state ────────────────────────────────────────────────────────
  int _remaining = 0;
  Timer? _countdownTimer;

  void _toggleDropdownVisible() {
    setState(() => _dropdownVisible = !_dropdownVisible);
  }

  void _setConfirmPending(bool value) {
    if (_confirmPending == value) return;
    setState(() => _confirmPending = value);
  }

  void _tickCountdown() {
    setState(() {
      _remaining--;
      if (_remaining <= 0) {
        _remaining = 0;
        _countdownTimer?.cancel();
      }
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _tickCountdown();
    });
  }

  @override
  void initState() {
    super.initState();
    _states.addListener(_statesChanged);
    if (widget._kind == _OiButtonKind.countdown &&
        widget.countdownSeconds != null) {
      _remaining = widget.countdownSeconds!;
      _startCountdown();
    }
  }

  @override
  void didUpdateWidget(OiButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget._kind == _OiButtonKind.countdown &&
        widget.countdownSeconds != oldWidget.countdownSeconds) {
      _countdownTimer?.cancel();
      _remaining = widget.countdownSeconds ?? 0;
      if (_remaining > 0) _startCountdown();
    }
  }

  @override
  void dispose() {
    _states
      ..removeListener(_statesChanged)
      ..dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    switch (widget._kind) {
      case _OiButtonKind.icon:
        return _OiButtonIcon(state: this);
      case _OiButtonKind.split:
        return _OiButtonSplit(state: this);
      case _OiButtonKind.countdown:
        return _OiButtonCountdown(state: this);
      case _OiButtonKind.confirm:
        return _OiButtonConfirm(state: this);
      case _OiButtonKind.standard:
        return _OiButtonStandard(state: this);
    }
  }
}
