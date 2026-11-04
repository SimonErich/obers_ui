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

// ── Main Widget ─────────────────────────────────────────────────────────────

/// The texts of an [OiSubscriptionManager], in English by default; pass translations
/// to localize the page.
///
/// {@category Modules}
class OiSubscriptionManagerLabels {
  /// Creates an [OiSubscriptionManagerLabels].
  const OiSubscriptionManagerLabels({
    this.perMonth = '/mo',
    this.perYear = '/yr',
    this.renewsOn = englishRenewsOn,
    this.formatDate = englishFormatDate,
    this.status = englishStatus,
    this.statusLabel = englishStatusLabel,
    this.upgrade = 'Upgrade',
    this.upgradeSemantic = 'Upgrade subscription plan',
    this.downgrade = 'Downgrade',
    this.downgradeSemantic = 'Downgrade subscription plan',
    this.cancel = 'Cancel',
    this.cancelSemantic = 'Cancel subscription',
    this.usage = 'Usage',
    this.quotaUsage = englishQuotaUsage,
    this.billingHistory = 'Billing History',
    this.paid = 'Paid',
    this.pending = 'Pending',
    this.failed = 'Failed',
    this.downloadInvoice = englishDownloadInvoice,
    this.paymentMethod = 'Payment Method',
    this.expires = englishExpires,
    this.update = 'Update',
    this.updateSemantic = 'Update payment method',
  });

  /// "Renews on Mar 5, 2026": the default [renewsOn].
  static String englishRenewsOn(String date) => 'Renews on $date';

  /// "Mar 5, 2026": the default [formatDate].
  static String englishFormatDate(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// "Active", "Trial", "Past Due", "Canceled", "Expired": the default
  /// [status].
  static String englishStatus(OiSubscriptionStatus status) => switch (status) {
    OiSubscriptionStatus.active => 'Active',
    OiSubscriptionStatus.trialing => 'Trial',
    OiSubscriptionStatus.pastDue => 'Past Due',
    OiSubscriptionStatus.canceled => 'Canceled',
    OiSubscriptionStatus.expired => 'Expired',
  };

  /// "Status: Active": the default [statusLabel].
  static String englishStatusLabel(String status) => 'Status: $status';

  /// "Storage usage": the default [quotaUsage].
  static String englishQuotaUsage(String quota) => '$quota usage';

  /// "Download invoice March 2026": the default [downloadInvoice].
  static String englishDownloadInvoice(String invoice) =>
      'Download invoice $invoice';

  /// "Expires 12/27": the default [expires].
  static String englishExpires(String date) => 'Expires $date';

  /// Suffix of a monthly price.
  final String perMonth;

  /// Suffix of a yearly price.
  final String perYear;

  /// Names the formatted renewal date.
  final String Function(String date) renewsOn;

  /// Formats the renewal and invoice dates.
  final String Function(DateTime date) formatDate;

  /// Names a subscription status.
  final String Function(OiSubscriptionStatus status) status;

  /// Screen-reader label of the named status.
  final String Function(String status) statusLabel;

  /// Label of the upgrade button.
  final String upgrade;

  /// Screen-reader label of the upgrade button.
  final String upgradeSemantic;

  /// Label of the downgrade button.
  final String downgrade;

  /// Screen-reader label of the downgrade button.
  final String downgradeSemantic;

  /// Label of the cancel button.
  final String cancel;

  /// Screen-reader label of the cancel button.
  final String cancelSemantic;

  /// Heading of the usage meters.
  final String usage;

  /// Screen-reader label of the named quota's meter.
  final String Function(String quota) quotaUsage;

  /// Heading of the invoices.
  final String billingHistory;

  /// Badge of a paid invoice.
  final String paid;

  /// Badge of a pending invoice.
  final String pending;

  /// Badge of a failed invoice.
  final String failed;

  /// Screen-reader label of the described invoice's download button.
  final String Function(String invoice) downloadInvoice;

  /// Heading of the payment method.
  final String paymentMethod;

  /// Names the payment method's expiry.
  final String Function(String date) expires;

  /// Label of the update payment method button.
  final String update;

  /// Screen-reader label of the update payment method button.
  final String updateSemantic;
}

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
    this.labels = const OiSubscriptionManagerLabels(),
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

  /// The page's texts; pass translations to localize it.
  final OiSubscriptionManagerLabels labels;

  /// Currency symbol used to format prices.
  final String currencySymbol;

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(2);
    final suffix = currentPlan.billingCycle == OiBillingCycle.monthly
        ? labels.perMonth
        : labels.perYear;
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
                labels.renewsOn(labels.formatDate(currentPlan.renewalDate!)),
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
                    label: labels.upgrade,
                    onTap: onUpgrade,
                    semanticLabel: labels.upgradeSemantic,
                  ),
                if (onDowngrade != null)
                  OiButton.ghost(
                    label: labels.downgrade,
                    onTap: onDowngrade,
                    semanticLabel: labels.downgradeSemantic,
                  ),
                if (onCancel != null)
                  OiButton.ghost(
                    label: labels.cancel,
                    onTap: () => onCancel!(),
                    semanticLabel: labels.cancelSemantic,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OiSubscriptionStatus status) {
    final statusLabel = labels.status(status);
    final color = switch (status) {
      OiSubscriptionStatus.active => OiBadgeColor.success,
      OiSubscriptionStatus.trialing => OiBadgeColor.info,
      OiSubscriptionStatus.pastDue => OiBadgeColor.warning,
      OiSubscriptionStatus.canceled => OiBadgeColor.error,
      OiSubscriptionStatus.expired => OiBadgeColor.neutral,
    };
    return Semantics(
      label: labels.statusLabel(statusLabel),
      child: OiBadge.soft(label: statusLabel, color: color),
    );
  }

  Widget _buildUsageMeters(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OiLabel.h3(labels.usage),
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
          label: labels.quotaUsage(quota.label),
        ),
      ],
    );
  }

  Widget _buildBillingHistory(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OiLabel.h3(labels.billingHistory),
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
      'paid' => OiBadge.soft(
        label: labels.paid,
        color: OiBadgeColor.success,
        size: OiBadgeSize.small,
      ),
      'pending' => OiBadge.soft(
        label: labels.pending,
        color: OiBadgeColor.warning,
        size: OiBadgeSize.small,
      ),
      'failed' => OiBadge.soft(
        label: labels.failed,
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
                  OiLabel.small(labels.formatDate(invoice.date)),
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
                semanticLabel: labels.downloadInvoice(invoice.description),
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
        OiLabel.h3(labels.paymentMethod),
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
                        OiLabel.small(labels.expires(pm.expiresAt!)),
                      ],
                    ],
                  ),
                ),
                if (onUpdatePayment != null)
                  OiButton.ghost(
                    label: labels.update,
                    onTap: onUpdatePayment,
                    semanticLabel: labels.updateSemantic,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
