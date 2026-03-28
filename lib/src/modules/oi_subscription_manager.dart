import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/modules/oi_pricing_table.dart' show OiBillingCycle;
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ── Data Models ─────────────────────────────────────────────────────────────

/// Subscription status.
///
/// {@category Modules}
enum OiSubscriptionStatus {
  /// The subscription is active and in good standing.
  active,

  /// The subscription is in a trial period.
  trialing,

  /// Payment has failed and the subscription is past due.
  pastDue,

  /// The subscription has been canceled.
  canceled,

  /// The subscription has expired.
  expired,
}

/// Current subscription plan details.
///
/// {@category Modules}
@immutable
class OiSubscriptionPlan {
  /// Creates an [OiSubscriptionPlan].
  const OiSubscriptionPlan({
    required this.key,
    required this.name,
    required this.price,
    this.billingCycle = OiBillingCycle.monthly,
    this.renewalDate,
    this.status = OiSubscriptionStatus.active,
    this.features = const [],
  });

  /// Unique key for the plan.
  final String key;

  /// Display name of the plan.
  final String name;

  /// Price amount.
  final double price;

  /// Billing cycle (monthly or yearly).
  final OiBillingCycle billingCycle;

  /// Next renewal date. Null if canceled or expired.
  final DateTime? renewalDate;

  /// Current subscription status.
  final OiSubscriptionStatus status;

  /// List of features included in this plan.
  final List<String> features;
}

/// A usage quota meter.
///
/// {@category Modules}
@immutable
class OiUsageQuota {
  /// Creates an [OiUsageQuota].
  const OiUsageQuota({
    required this.label,
    required this.used,
    required this.limit,
    this.unit = '',
    this.icon,
  });

  /// Human-readable label for the quota.
  final String label;

  /// Current usage amount.
  final double used;

  /// Maximum allowed usage.
  final double limit;

  /// Unit suffix (e.g. "GB", "calls").
  final String unit;

  /// Optional icon for the quota.
  final IconData? icon;
}

/// A billing history entry.
///
/// {@category Modules}
@immutable
class OiInvoice {
  /// Creates an [OiInvoice].
  const OiInvoice({
    required this.key,
    required this.date,
    required this.description,
    required this.amount,
    this.status = 'paid',
    this.downloadUrl,
  });

  /// Unique identifier for the invoice.
  final Object key;

  /// Invoice date.
  final DateTime date;

  /// Description of the invoice line.
  final String description;

  /// Invoice amount.
  final double amount;

  /// Payment status (e.g. "paid", "pending", "failed").
  final String status;

  /// Optional URL to download the invoice PDF.
  final String? downloadUrl;
}

/// Payment method info.
///
/// {@category Modules}
@immutable
class OiPaymentMethodInfo {
  /// Creates an [OiPaymentMethodInfo].
  const OiPaymentMethodInfo({
    required this.label,
    this.last4,
    this.brand,
    this.expiresAt,
    this.icon,
  });

  /// Human-readable label for the payment method.
  final String label;

  /// Last four digits of the card number.
  final String? last4;

  /// Card brand (e.g. "Visa", "Mastercard").
  final String? brand;

  /// Expiration date string (e.g. "12/25").
  final String? expiresAt;

  /// Optional icon for the payment method.
  final IconData? icon;
}

// ── Month name lookup ───────────────────────────────────────────────────────

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatDate(DateTime date) {
  final month = _monthNames[date.month - 1];
  return '$month ${date.day}, ${date.year}';
}

// ── Main Widget ─────────────────────────────────────────────────────────────

/// A subscription management page with current plan, usage meters,
/// billing history, and payment method.
///
/// {@category Modules}
class OiSubscriptionManager extends StatelessWidget {
  /// Creates an [OiSubscriptionManager].
  const OiSubscriptionManager({
    required this.currentPlan,
    required this.label,
    this.usage = const [],
    this.invoices = const [],
    this.paymentMethod,
    this.onUpgrade,
    this.onDowngrade,
    this.onCancel,
    this.onUpdatePayment,
    this.onInvoiceDownload,
    this.currencySymbol = r'$',
    super.key,
  });

  /// The current subscription plan to display.
  final OiSubscriptionPlan currentPlan;

  /// Semantic label for the entire page.
  final String label;

  /// Usage quota meters to display.
  final List<OiUsageQuota> usage;

  /// Billing history entries.
  final List<OiInvoice> invoices;

  /// Payment method info. When null, the payment section is hidden.
  final OiPaymentMethodInfo? paymentMethod;

  /// Called when the user taps the "Upgrade" button.
  final VoidCallback? onUpgrade;

  /// Called when the user taps the "Downgrade" button.
  final VoidCallback? onDowngrade;

  /// Called when the user taps the "Cancel" button.
  /// Returns a [Future<bool>] to indicate whether the cancellation
  /// was confirmed.
  final Future<bool> Function()? onCancel;

  /// Called when the user taps the "Update" payment button.
  final VoidCallback? onUpdatePayment;

  /// Called when the user taps a download button on an invoice.
  final void Function(OiInvoice)? onInvoiceDownload;

  /// Currency symbol used to format prices.
  final String currencySymbol;

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(2);
    final suffix = currentPlan.billingCycle == OiBillingCycle.monthly
        ? '/mo'
        : '/yr';
    return '$currencySymbol$formatted$suffix';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final isDesktop =
        context.breakpoint.minWidth >= OiBreakpoint.expanded.minWidth;

    return Semantics(
      label: label,
      container: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: isDesktop
                ? _buildDesktopLayout(context)
                : _buildMobileLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCurrentPlan(context),
        if (usage.isNotEmpty) ...[
          SizedBox(height: spacing.xl),
          _buildUsageMeters(context),
        ],
        if (invoices.isNotEmpty) ...[
          SizedBox(height: spacing.xl),
          _buildBillingHistory(context),
        ],
        if (paymentMethod != null) ...[
          SizedBox(height: spacing.xl),
          _buildPaymentMethod(context),
        ],
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final spacing = context.spacing;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentPlan(context),
              if (usage.isNotEmpty) ...[
                SizedBox(height: spacing.xl),
                _buildUsageMeters(context),
              ],
            ],
          ),
        ),
        SizedBox(width: spacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (invoices.isNotEmpty) _buildBillingHistory(context),
              if (invoices.isNotEmpty && paymentMethod != null)
                SizedBox(height: spacing.xl),
              if (paymentMethod != null) _buildPaymentMethod(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPlan(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: radius.md,
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: OiLabel.h4(currentPlan.name)),
                _buildStatusBadge(currentPlan.status),
              ],
            ),
            SizedBox(height: spacing.sm),
            OiLabel.h2(_formatPrice(currentPlan.price)),
            if (currentPlan.renewalDate != null) ...[
              SizedBox(height: spacing.xs),
              OiLabel.small(
                'Renews on ${_formatDate(currentPlan.renewalDate!)}',
              ),
            ],
            if (currentPlan.features.isNotEmpty) ...[
              SizedBox(height: spacing.md),
              const OiDivider(),
              SizedBox(height: spacing.md),
              ...currentPlan.features.map(
                (feature) => Padding(
                  padding: EdgeInsets.only(bottom: spacing.xs),
                  child: Row(
                    children: [
                      Icon(OiIcons.check, size: 16, color: colors.success.base),
                      SizedBox(width: spacing.sm),
                      Expanded(child: OiLabel.body(feature)),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: spacing.lg),
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: [
                if (onUpgrade != null)
                  OiButton.primary(
                    label: 'Upgrade',
                    onTap: onUpgrade,
                    semanticLabel: 'Upgrade subscription plan',
                  ),
                if (onDowngrade != null)
                  OiButton.ghost(
                    label: 'Downgrade',
                    onTap: onDowngrade,
                    semanticLabel: 'Downgrade subscription plan',
                  ),
                if (onCancel != null)
                  OiButton.ghost(
                    label: 'Cancel',
                    onTap: () => onCancel!(),
                    semanticLabel: 'Cancel subscription',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OiSubscriptionStatus status) {
    final String statusLabel;
    final Widget badge;
    switch (status) {
      case OiSubscriptionStatus.active:
        statusLabel = 'Active';
        badge = const OiBadge.soft(
          label: 'Active',
          color: OiBadgeColor.success,
        );
      case OiSubscriptionStatus.trialing:
        statusLabel = 'Trial';
        badge = const OiBadge.soft(label: 'Trial', color: OiBadgeColor.info);
      case OiSubscriptionStatus.pastDue:
        statusLabel = 'Past Due';
        badge = const OiBadge.soft(
          label: 'Past Due',
          color: OiBadgeColor.warning,
        );
      case OiSubscriptionStatus.canceled:
        statusLabel = 'Canceled';
        badge = const OiBadge.soft(
          label: 'Canceled',
          color: OiBadgeColor.error,
        );
      case OiSubscriptionStatus.expired:
        statusLabel = 'Expired';
        badge = const OiBadge.soft(
          label: 'Expired',
          color: OiBadgeColor.neutral,
        );
    }
    return Semantics(label: 'Status: $statusLabel', child: badge);
  }

  Widget _buildUsageMeters(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OiLabel.h3('Usage'),
        SizedBox(height: spacing.md),
        ...usage.map(
          (quota) => Padding(
            padding: EdgeInsets.only(bottom: spacing.md),
            child: _buildUsageItem(context, quota),
          ),
        ),
      ],
    );
  }

  Widget _buildUsageItem(BuildContext context, OiUsageQuota quota) {
    final colors = context.colors;
    final spacing = context.spacing;
    final ratio = quota.limit > 0 ? (quota.used / quota.limit) : 0.0;
    final clampedRatio = ratio.clamp(0.0, 1.0);

    // Determine color based on usage percentage.
    final Color progressColor;
    if (ratio > 0.95) {
      progressColor = colors.error.base;
    } else if (ratio > 0.80) {
      progressColor = colors.warning.base;
    } else {
      progressColor = colors.success.base;
    }

    final usedStr = quota.used % 1 == 0
        ? quota.used.toInt().toString()
        : quota.used.toStringAsFixed(1);
    final limitStr = quota.limit % 1 == 0
        ? quota.limit.toInt().toString()
        : quota.limit.toStringAsFixed(1);
    final unitSuffix = quota.unit.isNotEmpty ? ' ${quota.unit}' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (quota.icon != null) ...[
              Icon(quota.icon, size: 16, color: colors.textSubtle),
              SizedBox(width: spacing.xs),
            ],
            Expanded(child: OiLabel.bodyStrong(quota.label)),
            OiLabel.small('$usedStr / $limitStr$unitSuffix'),
          ],
        ),
        SizedBox(height: spacing.xs),
        OiProgress.linear(
          value: clampedRatio,
          color: progressColor,
          label: '${quota.label} usage',
        ),
      ],
    );
  }

  Widget _buildBillingHistory(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OiLabel.h3('Billing History'),
        SizedBox(height: spacing.md),
        ...invoices.map(
          (invoice) => Padding(
            padding: EdgeInsets.only(bottom: spacing.sm),
            child: _buildInvoiceRow(context, invoice),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceRow(BuildContext context, OiInvoice invoice) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    final statusBadge = switch (invoice.status.toLowerCase()) {
      'paid' => const OiBadge.soft(
        label: 'Paid',
        color: OiBadgeColor.success,
        size: OiBadgeSize.small,
      ),
      'pending' => const OiBadge.soft(
        label: 'Pending',
        color: OiBadgeColor.warning,
        size: OiBadgeSize.small,
      ),
      'failed' => const OiBadge.soft(
        label: 'Failed',
        color: OiBadgeColor.error,
        size: OiBadgeSize.small,
      ),
      _ => OiBadge.soft(
        label: invoice.status,
        color: OiBadgeColor.neutral,
        size: OiBadgeSize.small,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: radius.sm,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OiLabel.body(invoice.description),
                  SizedBox(height: spacing.xs),
                  OiLabel.small(_formatDate(invoice.date)),
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            OiLabel.bodyStrong(
              '$currencySymbol${invoice.amount.toStringAsFixed(2)}',
            ),
            SizedBox(width: spacing.sm),
            statusBadge,
            if (onInvoiceDownload != null) ...[
              SizedBox(width: spacing.sm),
              OiTappable(
                semanticLabel: 'Download invoice ${invoice.description}',
                onTap: () => onInvoiceDownload!(invoice),
                child: Icon(
                  OiIcons.download,
                  size: 18,
                  color: colors.textSubtle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final pm = paymentMethod!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OiLabel.h3('Payment Method'),
        SizedBox(height: spacing.md),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: radius.md,
            border: Border.all(color: colors.border),
          ),
          child: Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Row(
              children: [
                Icon(
                  pm.icon ?? OiIcons.creditCard,
                  size: 24,
                  color: colors.text,
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OiLabel.bodyStrong(pm.label),
                      if (pm.expiresAt != null) ...[
                        SizedBox(height: spacing.xs),
                        OiLabel.small('Expires ${pm.expiresAt}'),
                      ],
                    ],
                  ),
                ),
                if (onUpdatePayment != null)
                  OiButton.ghost(
                    label: 'Update',
                    onTap: onUpdatePayment,
                    semanticLabel: 'Update payment method',
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
