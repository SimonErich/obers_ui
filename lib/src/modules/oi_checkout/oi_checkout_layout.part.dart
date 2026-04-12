part of '../oi_checkout.dart';

// ── Step routing, navigation bar, and responsive layouts ─────────────────────

extension _OiCheckoutLayout on _OiCheckoutState {
  // ── Step content router ───────────────────────────────────────────────────

  Widget _buildStepContent(BuildContext context) {
    final step = widget.steps[_currentStepIndex];
    switch (step) {
      case OiCheckoutStep.address:
        return _buildAddressStep(context);
      case OiCheckoutStep.shipping:
        return _buildShippingStep(context);
      case OiCheckoutStep.payment:
        return _buildPaymentStep(context);
      case OiCheckoutStep.review:
        return _buildReviewStep(context);
    }
  }

  // ── Navigation bar ────────────────────────────────────────────────────────

  Widget _buildNavBar(BuildContext context) {
    final isFirst = _currentStepIndex == 0;
    final isReview = widget.steps[_currentStepIndex] == OiCheckoutStep.review;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onCancel != null)
              OiButton.ghost(label: 'Cancel', onTap: widget.onCancel),
            if (!isFirst)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: OiButton.outline(
                  label: 'Previous',
                  onTap: _isPlacingOrder ? null : _goPrevious,
                ),
              ),
          ],
        ),
        if (isReview)
          OiButton.primary(
            label: widget.placeOrderLabel ?? 'Place Order',
            onTap: _isPlacingOrder ? null : _handlePlaceOrder,
            loading: _isPlacingOrder,
          )
        else
          OiButton.primary(label: 'Next', onTap: _goNext),
      ],
    );
  }

  // ── Desktop layout ────────────────────────────────────────────────────────

  Widget _buildDesktopLayout(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: OiColumn(
            breakpoint: breakpoint,
            gap: OiResponsive(sp.md),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OiStepper(
                totalSteps: widget.steps.length,
                currentStep: _currentStepIndex,
                stepLabels: widget.steps.map(_stepLabel).toList(),
                completedSteps: _completedSteps,
                onStepTap: _goToStep,
              ),
              _buildStepContent(context),
              _buildNavBar(context),
            ],
          ),
        ),
        if (widget.showSummary) ...[
          SizedBox(width: sp.lg),
          SizedBox(
            width: 320,
            child: OiOrderSummary(
              summary: widget.summary,
              items: widget.items,
              label: 'Order summary',
              currencyCode: widget.currencyCode,
              expandedByDefault: true,
            ),
          ),
        ],
      ],
    );
  }

  // ── Mobile layout ─────────────────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.md),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showSummary)
          OiAccordion(
            sections: [
              OiAccordionSection(
                title: 'Order Summary',
                content: OiOrderSummary(
                  summary: widget.summary,
                  items: widget.items,
                  label: 'Order summary',
                  currencyCode: widget.currencyCode,
                ),
              ),
            ],
          ),
        OiStepper(
          totalSteps: widget.steps.length,
          currentStep: _currentStepIndex,
          stepLabels: widget.steps.map(_stepLabel).toList(),
          completedSteps: _completedSteps,
          onStepTap: _goToStep,
          style: OiStepperStyle.compact,
        ),
        _buildStepContent(context),
        _buildNavBar(context),
      ],
    );
  }
}
