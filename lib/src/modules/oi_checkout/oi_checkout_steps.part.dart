part of '../oi_checkout.dart';

// ── Shipping, payment, and review step UI ────────────────────────────────────

extension _OiCheckoutSteps on _OiCheckoutState {
  String _stepLabel(OiCheckoutStep step) {
    switch (step) {
      case OiCheckoutStep.address:
        return widget.labels.addressStep;
      case OiCheckoutStep.shipping:
        return widget.labels.shippingStep;
      case OiCheckoutStep.payment:
        return widget.labels.paymentStep;
      case OiCheckoutStep.review:
        return widget.labels.reviewStep;
    }
  }

  // ── Shipping step ─────────────────────────────────────────────────────────

  Widget _buildShippingStep(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;
    final methods = widget.shippingMethods ?? [];

    if (methods.isEmpty) {
      return OiLabel.body(widget.labels.noShippingOptions);
    }

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OiLabel.h3(widget.labels.shippingMethod),
        for (final method in methods)
          OiShippingOption(
            method: method,
            label: widget.labels.shippingOption(method.label),
            freeLabel: widget.labels.free,
            selected: _selectedShipping?.key == method.key,
            currencyCode: widget.currencyCode,
            onSelect: (m) {
              _setSelectedShipping(m);
              widget.onShippingMethodChange?.call(m);
            },
          ),
      ],
    );
  }

  // ── Payment step ──────────────────────────────────────────────────────────

  Widget _buildPaymentStep(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;
    final methods = widget.paymentMethods ?? [];

    if (methods.isEmpty) {
      return OiLabel.body(widget.labels.noPaymentOptions);
    }

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OiLabel.h3(widget.labels.paymentMethod),
        for (final method in methods)
          OiPaymentOption(
            method: method,
            label: widget.labels.paymentOption(method.label),
            defaultLabel: widget.labels.defaultPayment,
            selected: _selectedPayment?.key == method.key,
            onSelect: (m) {
              _setSelectedPayment(m);
              widget.onPaymentMethodChange?.call(m);
            },
          ),
      ],
    );
  }

  // ── Review step ───────────────────────────────────────────────────────────

  Widget _buildReviewStep(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;
    final colors = context.colors;

    Widget editLink(String text, OiCheckoutStep target) {
      final targetIndex = widget.steps.indexOf(target);
      if (targetIndex < 0) return const SizedBox.shrink();
      return GestureDetector(
        onTap: _isPlacingOrder ? null : () => _goToStep(targetIndex),
        child: Semantics(
          label: widget.labels.editSection(text),
          button: true,
          child: OiLabel.link(widget.labels.edit, color: colors.primary.base),
        ),
      );
    }

    Widget sectionHeader(String title, OiCheckoutStep target) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [OiLabel.bodyStrong(title), editLink(title, target)],
      );
    }

    String formatAddress(OiAddressData addr) {
      final parts = <String>[
        if (addr.firstName != null || addr.lastName != null)
          [addr.firstName ?? '', addr.lastName ?? ''].join(' ').trim(),
        if (addr.line1 != null) addr.line1!,
        if (addr.line2 != null && addr.line2!.isNotEmpty) addr.line2!,
        [
          addr.city ?? '',
          addr.state ?? '',
          addr.postalCode ?? '',
        ].where((s) => s.isNotEmpty).join(', '),
        if (addr.country != null) addr.country!,
      ];
      return parts.where((s) => s.isNotEmpty).join('\n');
    }

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.md),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OiLabel.h3(widget.labels.reviewTitle),

        // Shipping address.
        if (widget.steps.contains(OiCheckoutStep.address)) ...[
          sectionHeader(widget.labels.shippingAddress, OiCheckoutStep.address),
          OiLabel.body(formatAddress(_shippingAddress)),
          if (!_sameBilling) ...[
            SizedBox(height: sp.xs),
            sectionHeader(widget.labels.billingAddress, OiCheckoutStep.address),
            OiLabel.body(formatAddress(_billingAddress)),
          ],
          const OiDivider(),
        ],

        // Shipping method.
        if (widget.steps.contains(OiCheckoutStep.shipping) &&
            _selectedShipping != null) ...[
          sectionHeader(widget.labels.shippingMethod, OiCheckoutStep.shipping),
          OiLabel.body(_selectedShipping!.label),
          if (_selectedShipping!.estimatedDelivery != null)
            OiLabel.small(_selectedShipping!.estimatedDelivery!),
          const OiDivider(),
        ],

        // Payment method.
        if (widget.steps.contains(OiCheckoutStep.payment) &&
            _selectedPayment != null) ...[
          sectionHeader(widget.labels.paymentMethod, OiCheckoutStep.payment),
          OiLabel.body(_selectedPayment!.label),
          if (_selectedPayment!.description != null)
            OiLabel.small(_selectedPayment!.description!),
          const OiDivider(),
        ],

        // Error message.
        if (_orderError != null)
          Container(
            padding: EdgeInsets.all(sp.sm),
            decoration: BoxDecoration(
              color: colors.error.muted,
              borderRadius: context.radius.sm,
            ),
            child: OiLabel.body(_orderError!, color: colors.error.base),
          ),
      ],
    );
  }
}
