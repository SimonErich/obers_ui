import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen for overlay and dialog widgets.
class OverlaysScreen extends StatefulWidget {
  const OverlaysScreen({super.key});

  @override
  State<OverlaysScreen> createState() => _OverlaysScreenState();
}

class _OverlaysScreenState extends State<OverlaysScreen> {
  // ── Emoji picker state ────────────────────────────────────────────────────
  String _selectedEmoji = '';

  /// Wraps a button in a centered 160px-max-width container.
  Widget _centeredButton(Widget button) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: button,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OiLabel.h2('Overlays'),
          SizedBox(height: spacing.xs),
          OiLabel.body(
            'Modal dialogs, sheets, toasts, snack bars, and other overlay '
            'widgets. Each is triggered by a button tap.',
            color: colors.textSubtle,
          ),
          SizedBox(height: spacing.xl),

          // ── 1. OiDialog ───────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Dialog',
            widgetName: 'OiDialog',
            description:
                'A modal dialog overlay with scrim, focus trapping, and '
                'Escape-to-dismiss. Supports alert, confirm, standard, '
                'form, and full-screen variants.',
            examples: [
              ComponentExample(
                title: 'Dialog variants',
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Column(
                      children: [
                        OiButton.outline(
                          label: 'Alert dialog',
                          fullWidth: true,
                          onTap: () {
                            late final OiOverlayHandle handle;
                            handle = OiDialog.show(
                              context,
                              label: 'Alert',
                              dialog: OiDialog.alert(
                                label: 'Alert dialog',
                                title: 'Warning',
                                content: const OiLabel.body(
                                  'Something happened.',
                                ),
                                onClose: () => handle.dismiss(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        OiButton.outline(
                          label: 'Confirm dialog',
                          fullWidth: true,
                          onTap: () {
                            late final OiOverlayHandle handle;
                            handle = OiDialog.show(
                              context,
                              label: 'Confirm',
                              dialog: OiDialog.confirm(
                                label: 'Confirm dialog',
                                title: 'Delete item?',
                                content: const OiLabel.body(
                                  'This action cannot be undone.',
                                ),
                                actions: [
                                  OiButton.ghost(
                                    label: 'Cancel',
                                    onTap: () => handle.dismiss(),
                                  ),
                                  OiButton.primary(
                                    label: 'Delete',
                                    onTap: () => handle.dismiss(),
                                  ),
                                ],
                                onClose: () => handle.dismiss(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        OiButton.outline(
                          label: 'Standard dialog',
                          fullWidth: true,
                          onTap: () {
                            late final OiOverlayHandle handle;
                            handle = OiDialog.show(
                              context,
                              label: 'Standard',
                              dialog: OiDialog.standard(
                                label: 'Standard dialog',
                                title: 'Information',
                                content: const OiLabel.body(
                                  'This is a standard dialog with custom '
                                  'content.',
                                ),
                                actions: [
                                  OiButton.primary(
                                    label: 'OK',
                                    onTap: () => handle.dismiss(),
                                  ),
                                ],
                                onClose: () => handle.dismiss(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── 2. OiDialogShell ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Dialog Shell',
            widgetName: 'OiDialogShell',
            description:
                'A minimal, themeable dialog container. This is the low-level '
                'building block used by OiDialog. Use OiDialogShell.show() '
                'for fully custom dialog content with enter/exit animations '
                'and focus trapping.',
            examples: [
              ComponentExample(
                title: 'Custom dialog shell',
                child: _centeredButton(
                  OiButton.outline(
                    label: 'Open dialog shell',
                    fullWidth: true,
                    onTap: () {
                      OiDialogShell.show<void>(
                        context: context,
                        semanticLabel: 'Custom dialog',
                        builder: (close) => Padding(
                          padding: EdgeInsets.all(spacing.lg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const OiLabel.h3('Custom Shell'),
                              SizedBox(height: spacing.md),
                              const OiLabel.body(
                                'This dialog uses OiDialogShell directly '
                                'for full layout control.',
                              ),
                              SizedBox(height: spacing.lg),
                              Center(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 150),
                                  child: OiButton.primary(
                                    label: 'Close',
                                    fullWidth: true,
                                    onTap: () => close(null),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // ── 3. OiSheet ────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Sheet',
            widgetName: 'OiSheet',
            description:
                'A slide-in panel that animates from any edge of the screen. '
                'Supports snap points and drag-to-dismiss.',
            examples: [
              ComponentExample(
                title: 'Bottom sheet',
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Column(
                      children: [
                        OiButton.outline(
                          label: 'Bottom sheet',
                          fullWidth: true,
                          onTap: () {
                            late final OiOverlayHandle handle;
                            handle = OiSheet.show(
                              context,
                              label: 'Bottom sheet',
                              child: Padding(
                                padding: EdgeInsets.all(spacing.lg),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const OiLabel.h3('Sheet Content'),
                                    SizedBox(height: spacing.md),
                                    const OiLabel.body(
                                      'This is a bottom sheet with custom '
                                      'content.',
                                    ),
                                    SizedBox(height: spacing.lg),
                                    OiButton.primary(
                                      label: 'Dismiss',
                                      onTap: () => handle.dismiss(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        OiButton.outline(
                          label: 'Right sheet',
                          fullWidth: true,
                          onTap: () {
                            late final OiOverlayHandle handle;
                            handle = OiSheet.show(
                              context,
                              label: 'Right sheet',
                              side: OiPanelSide.right,
                              size: 300,
                              child: Padding(
                                padding: EdgeInsets.all(spacing.lg),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const OiLabel.h3('Side Panel'),
                                    SizedBox(height: spacing.md),
                                    const OiLabel.body(
                                      'A right-side sheet panel.',
                                    ),
                                    const Spacer(),
                                    OiButton.primary(
                                      label: 'Close',
                                      onTap: () => handle.dismiss(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── 4. OiToast ────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Toast',
            widgetName: 'OiToast',
            description:
                'A transient notification banner that auto-dismisses. '
                'Supports info, success, warning, and error severity levels.',
            examples: [
              ComponentExample(
                title: 'Toast levels',
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Column(
                      children: [
                        OiButton.outline(
                          label: 'Info toast',
                          fullWidth: true,
                          onTap: () => OiToast.show(
                            context,
                            message: 'This is an informational message.',
                          ),
                        ),
                        const SizedBox(height: 12),
                        OiButton.outline(
                          label: 'Success toast',
                          fullWidth: true,
                          onTap: () => OiToast.show(
                            context,
                            message: 'Action completed successfully!',
                            level: OiToastLevel.success,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OiButton.outline(
                          label: 'Warning toast',
                          fullWidth: true,
                          onTap: () => OiToast.show(
                            context,
                            message: 'Please review your input.',
                            level: OiToastLevel.warning,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OiButton.outline(
                          label: 'Error toast',
                          fullWidth: true,
                          onTap: () => OiToast.show(
                            context,
                            message: 'Something went wrong.',
                            level: OiToastLevel.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── 5. OiSnackBar ─────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Snack Bar',
            widgetName: 'OiSnackBar',
            description:
                'A transient notification bar at the bottom of the screen '
                'with an optional action button. Only one is shown at a time.',
            examples: [
              ComponentExample(
                title: 'Snack bar with action',
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Column(
                      children: [
                        OiButton.outline(
                          label: 'Show snack bar',
                          fullWidth: true,
                          onTap: () => OiSnackBar.show(
                            context,
                            message: 'Item deleted.',
                            actionLabel: 'Undo',
                            onAction: () {},
                          ),
                        ),
                        const SizedBox(height: 12),
                        OiButton.outline(
                          label: 'Simple snack bar',
                          fullWidth: true,
                          onTap: () => OiSnackBar.show(
                            context,
                            message: 'Settings saved.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── 6. OiContextMenu ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Context Menu',
            widgetName: 'OiContextMenu',
            description:
                'A right-click (or long-press) context menu. Wrap any widget '
                'with OiContextMenu to add a menu triggered by secondary tap.',
            examples: [
              ComponentExample(
                title: 'Right-click the area below',
                child: OiContextMenu(
                  label: 'Demo context menu',
                  items: [
                    OiMenuItem(
                      label: 'Cut',
                      icon: OiIcons.scissors,
                      onTap: () {},
                    ),
                    OiMenuItem(
                      label: 'Copy',
                      icon: OiIcons.copy,
                      onTap: () {},
                    ),
                    OiMenuItem(
                      label: 'Paste',
                      icon: OiIcons.clipboard,
                      onTap: () {},
                    ),
                    const OiMenuDivider(),
                    OiMenuItem(
                      label: 'Delete',
                      icon: OiIcons.trash,
                      onTap: () {},
                    ),
                  ],
                  child: Container(
                    padding: EdgeInsets.all(spacing.lg),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.borderSubtle),
                      borderRadius: context.radius.md,
                    ),
                    child: Center(
                      child: OiLabel.body(
                        'Right-click or long-press here',
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── 7. OiEmojiPicker ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Emoji Picker',
            widgetName: 'OiEmojiPicker',
            description:
                'A grid-based emoji picker with search and category tabs.',
            examples: [
              ComponentExample(
                title: 'Inline picker',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedEmoji.isNotEmpty) ...[
                      OiLabel.body('Selected: $_selectedEmoji'),
                      SizedBox(height: spacing.sm),
                    ],
                    SizedBox(
                      height: 300,
                      child: OiEmojiPicker(
                        onSelected: (emoji) =>
                            setState(() => _selectedEmoji = emoji),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── 8. OiDeleteDialog ─────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Delete Dialog',
            widgetName: 'OiDeleteDialog',
            description:
                'A confirmation dialog for file/folder deletion. Shows what '
                'will be deleted and has a destructive action button.',
            examples: [
              ComponentExample(
                title: 'Delete confirmation',
                child: _centeredButton(
                  OiButton.outline(
                    label: 'Show delete dialog',
                    fullWidth: true,
                    onTap: () {
                      late final OiOverlayHandle handle;
                      handle = OiDialog.show(
                        context,
                        label: 'Delete confirmation',
                        dialog: OiDialog.standard(
                          label: 'Delete dialog',
                          title: 'Delete files?',
                          content: const OiLabel.body(
                            'Are you sure you want to delete the selected '
                            'files? This action cannot be undone.',
                          ),
                          actions: [
                            OiButton.ghost(
                              label: 'Cancel',
                              onTap: () => handle.dismiss(),
                            ),
                            OiButton.primary(
                              label: 'Delete',
                              onTap: () => handle.dismiss(),
                            ),
                          ],
                          onClose: () => handle.dismiss(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // ── 9. OiNameDialog ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Name Dialog',
            widgetName: 'OiNameDialog',
            description:
                'A dialog that prompts the user to enter a name. Includes '
                'built-in validation for empty and invalid characters. '
                'Supports Enter to confirm and Escape to cancel.',
            examples: [
              ComponentExample(
                title: 'Create new folder',
                child: _centeredButton(
                  OiButton.outline(
                    label: 'Show name dialog',
                    fullWidth: true,
                    onTap: () {
                      late final OiOverlayHandle handle;
                      handle = OiDialog.show(
                        context,
                        label: 'Name dialog',
                        dialog: OiNameDialog(
                          title: 'New folder',
                          defaultName: 'Untitled',
                          onCreate: (name) => handle.dismiss(),
                          onCancel: () => handle.dismiss(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
