import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_card.dart';
import 'package:obers_ui/src/components/navigation/oi_breadcrumbs.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

// ── Variant ──────────────────────────────────────────────────────────────────

/// The variant of an [OiResourcePage], determining its default actions
/// and layout.
///
/// {@category Modules}
///
/// Coverage: REQ-0031
enum OiResourcePageVariant {
  /// List view — shows Create button, filters, and pagination.
  list,

  /// Detail/show view — shows Edit and Delete buttons.
  show,

  /// Edit view — shows Save and Cancel buttons inside a card.
  edit,

  /// Create view — shows Save and Cancel buttons inside a card.
  create,
}

// ── Callback ─────────────────────────────────────────────────────────────────

/// Callback for [OiResourcePage] default action buttons.
///
/// Action names are: `'create'`, `'edit'`, `'delete'`, `'save'`, `'cancel'`.
typedef OiResourceAction = void Function(String action);

// ── OiResourcePage ──────────────────────────────────────────────────────────

/// A generic CRUD page scaffold providing layout for list / show / edit /
/// create views.
///
/// This is a pure layout widget — it arranges a title area, action bar,
/// content area, and pagination area. The [variant] controls which default
/// action buttons are shown:
///
/// - **list**: Create button + optional [filters] + optional [pagination].
/// - **show**: Edit + Delete buttons.
/// - **edit / create**: Save + Cancel buttons, content wrapped in [OiCard].
///
/// Providing [actions] overrides the variant defaults entirely.
///
/// {@category Modules}
///
/// Coverage: REQ-0031
class OiResourcePage extends StatelessWidget {
  /// Creates an [OiResourcePage].
  const OiResourcePage({
    required this.child,
    required this.label,
    this.title,
    this.variant = OiResourcePageVariant.list,
    this.actions,
    this.filters,
    this.pagination,
    this.breadcrumbs,
    this.wrapInCard = true,
    this.onAction,
    super.key,
  });

  /// The main content area.
  final Widget child;

  /// Accessibility label for the page.
  final String label;

  /// Optional page title displayed as a heading.
  final String? title;

  /// The page variant controlling default actions and layout.
  final OiResourcePageVariant variant;

  /// Custom action widgets. When provided, variant defaults are not shown.
  final List<Widget>? actions;

  /// Optional filter widgets, rendered only for the [OiResourcePageVariant.list]
  /// variant.
  final Widget? filters;

  /// Optional pagination widget, rendered only for the
  /// [OiResourcePageVariant.list] variant.
  final Widget? pagination;

  /// Optional breadcrumb items rendered above the title area.
  final List<OiBreadcrumbItem>? breadcrumbs;

  /// Whether to wrap the content in an [OiCard]. Defaults to `true`.
  final bool wrapInCard;

  /// Called when a default action button is pressed.
  ///
  /// Action names: `'create'`, `'edit'`, `'delete'`, `'save'`, `'cancel'`.
  final OiResourceAction? onAction;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Semantics(
      label: label,
      container: true,
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (breadcrumbs != null && breadcrumbs!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: spacing.sm),
                child: OiBreadcrumbs(items: breadcrumbs!),
              ),
            _buildTitleBar(context),
            if (variant == OiResourcePageVariant.list && filters != null)
              Padding(
                padding: EdgeInsets.only(top: spacing.sm),
                child: filters,
              ),
            SizedBox(height: spacing.md),
            Expanded(child: _buildContent(context)),
            if (variant == OiResourcePageVariant.list && pagination != null)
              _buildPaginationArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    final actionWidgets = _buildActionBar(context);

    return Row(
      children: [
        if (title != null)
          Expanded(child: OiLabel.h2(title!))
        else
          const Spacer(),
        ...actionWidgets,
      ],
    );
  }

  List<Widget> _buildActionBar(BuildContext context) {
    final spacing = context.spacing;

    if (actions != null) {
      return [
        for (final action in actions!)
          Padding(
            padding: EdgeInsets.only(left: spacing.sm),
            child: action,
          ),
      ];
    }

    return _buildDefaultActions(context);
  }

  List<Widget> _buildDefaultActions(BuildContext context) {
    final spacing = context.spacing;
    final raw = switch (variant) {
      OiResourcePageVariant.list => _listActions(context),
      OiResourcePageVariant.show => _showActions(context),
      OiResourcePageVariant.edit => _editCreateActions(context),
      OiResourcePageVariant.create => _editCreateActions(context),
    };

    return [
      for (final w in raw)
        Padding(
          padding: EdgeInsets.only(left: spacing.sm),
          child: w,
        ),
    ];
  }

  Widget _buildContent(BuildContext context) {
    final shouldWrap =
        wrapInCard &&
        (variant == OiResourcePageVariant.edit ||
            variant == OiResourcePageVariant.create);

    if (shouldWrap) {
      return OiCard(child: child);
    }

    if (wrapInCard &&
        (variant == OiResourcePageVariant.list ||
            variant == OiResourcePageVariant.show)) {
      return OiCard(child: child);
    }

    return child;
  }

  Widget _buildPaginationArea(BuildContext context) {
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.only(top: spacing.md),
      child: pagination,
    );
  }

  List<Widget> _listActions(BuildContext context) {
    return [
      OiButton.primary(
        label: 'Create',
        icon: OiIcons.plus, // add
        onTap: () => onAction?.call('create'),
      ),
    ];
  }

  List<Widget> _showActions(BuildContext context) {
    return [
      OiButton.outline(
        label: 'Edit',
        icon: OiIcons.pencil, // edit
        onTap: () => onAction?.call('edit'),
      ),
      OiButton.destructive(
        label: 'Delete',
        icon: OiIcons.trash, // delete
        onTap: () => onAction?.call('delete'),
      ),
    ];
  }

  List<Widget> _editCreateActions(BuildContext context) {
    return [
      OiButton.ghost(label: 'Cancel', onTap: () => onAction?.call('cancel')),
      OiButton.primary(
        label: 'Save',
        icon: OiIcons.archiveBoxArrowDown, // save
        onTap: () => onAction?.call('save'),
      ),
    ];
  }
}
