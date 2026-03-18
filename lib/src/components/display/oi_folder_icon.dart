import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// The open/closed state of an [OiFolderIcon].
///
/// {@category Components}
enum OiFolderIconState {
  /// Classic closed folder shape.
  closed,

  /// Front face tilted slightly, revealing the interior.
  open,

  /// Same as closed but with lighter fill and dashed outline.
  empty,
}

/// Special folder variants for [OiFolderIcon].
///
/// {@category Components}
enum OiFolderIconVariant {
  /// Standard folder.
  normal,

  /// Shared folder with people icon overlay.
  shared,

  /// Starred/favorite folder.
  starred,

  /// Locked/read-only folder.
  locked,

  /// Trash folder.
  trash,
}

/// The size of an [OiFolderIcon].
///
/// {@category Components}
enum OiFolderIconSize {
  /// 16 × 14 dp.
  xs,

  /// 24 × 20 dp.
  sm,

  /// 32 × 28 dp.
  md,

  /// 48 × 40 dp.
  lg,

  /// 64 × 54 dp.
  xl,
}

/// A folder icon with open/closed states, color customization, special folder
/// variants (shared, starred, locked), and optional badge overlay.
///
/// ```dart
/// OiFolderIcon()
/// OiFolderIcon(state: OiFolderIconState.open)
/// OiFolderIcon(variant: OiFolderIconVariant.shared)
/// ```
///
/// {@category Components}
class OiFolderIcon extends StatelessWidget {
  /// Creates an [OiFolderIcon].
  const OiFolderIcon({
    this.state = OiFolderIconState.closed,
    this.variant = OiFolderIconVariant.normal,
    this.size = OiFolderIconSize.md,
    this.color,
    this.badgeCount,
    this.semanticsLabel,
    super.key,
  });

  /// The open/closed state of the folder.
  final OiFolderIconState state;

  /// The folder variant (normal, shared, starred, locked, trash).
  final OiFolderIconVariant variant;

  /// The icon size.
  final OiFolderIconSize size;

  /// Overrides the default folder color.
  final Color? color;

  /// Optional badge count shown as an overlay.
  final int? badgeCount;

  /// Accessibility label announced by screen readers.
  final String? semanticsLabel;

  ({double width, double height, double tabWidth, double tabHeight, double overlaySize, double fontSize})
      _dimensions() {
    return switch (size) {
      OiFolderIconSize.xs => (
        width: 16,
        height: 14,
        tabWidth: 7,
        tabHeight: 3,
        overlaySize: 6,
        fontSize: 5,
      ),
      OiFolderIconSize.sm => (
        width: 24,
        height: 20,
        tabWidth: 10,
        tabHeight: 4,
        overlaySize: 8,
        fontSize: 6,
      ),
      OiFolderIconSize.md => (
        width: 32,
        height: 28,
        tabWidth: 14,
        tabHeight: 6,
        overlaySize: 10,
        fontSize: 7,
      ),
      OiFolderIconSize.lg => (
        width: 48,
        height: 40,
        tabWidth: 20,
        tabHeight: 8,
        overlaySize: 14,
        fontSize: 9,
      ),
      OiFolderIconSize.xl => (
        width: 64,
        height: 54,
        tabWidth: 28,
        tabHeight: 10,
        overlaySize: 18,
        fontSize: 11,
      ),
    };
  }

  String get _defaultLabel {
    final prefix = switch (variant) {
      OiFolderIconVariant.normal => '',
      OiFolderIconVariant.shared => 'shared ',
      OiFolderIconVariant.starred => 'starred ',
      OiFolderIconVariant.locked => 'locked ',
      OiFolderIconVariant.trash => 'trash ',
    };
    return '${prefix}folder';
  }

  IconData? get _variantOverlayIcon {
    return switch (variant) {
      OiFolderIconVariant.normal => null,
      OiFolderIconVariant.shared =>
        const IconData(0xe7fb, fontFamily: 'MaterialIcons'), // people
      OiFolderIconVariant.starred =>
        const IconData(0xe838, fontFamily: 'MaterialIcons'), // star
      OiFolderIconVariant.locked =>
        const IconData(0xe897, fontFamily: 'MaterialIcons'), // lock
      OiFolderIconVariant.trash =>
        const IconData(0xe872, fontFamily: 'MaterialIcons'), // delete
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dims = _dimensions();
    final folderColor = color ?? colors.warning.base;
    final label = semanticsLabel ?? _defaultLabel;

    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: SizedBox(
          width: dims.width,
          height: dims.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(dims.width, dims.height),
                painter: _FolderIconPainter(
                  folderColor: folderColor,
                  borderColor: colors.border,
                  state: state,
                  tabWidth: dims.tabWidth,
                  tabHeight: dims.tabHeight,
                ),
              ),
              if (_variantOverlayIcon != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(
                    _variantOverlayIcon,
                    size: dims.overlaySize,
                    color: colors.textSubtle,
                  ),
                ),
              if (badgeCount != null && badgeCount! > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: colors.error.base,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeCount! > 99 ? '99+' : '$badgeCount',
                      style: TextStyle(
                        fontSize: dims.fontSize,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFFFFF),
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderIconPainter extends CustomPainter {
  _FolderIconPainter({
    required this.folderColor,
    required this.borderColor,
    required this.state,
    required this.tabWidth,
    required this.tabHeight,
  });

  final Color folderColor;
  final Color borderColor;
  final OiFolderIconState state;
  final double tabWidth;
  final double tabHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = 2.0;

    final fillPaint = Paint()
      ..color = state == OiFolderIconState.empty
          ? folderColor.withValues(alpha: 0.3)
          : folderColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    if (state == OiFolderIconState.empty) {
      strokePaint.strokeWidth = 1;
      // Dashed effect simulated with a lighter fill
    }

    // Tab on top-left
    final tabPath = Path()
      ..moveTo(0, tabHeight + r)
      ..arcToPoint(Offset(r, tabHeight), radius: Radius.circular(r))
      ..lineTo(tabWidth - r, tabHeight)
      ..lineTo(tabWidth + 2, tabHeight + tabHeight * 0.5)
      ..lineTo(w - r, tabHeight + tabHeight * 0.5)
      ..arcToPoint(
        Offset(w, tabHeight + tabHeight * 0.5 + r),
        radius: Radius.circular(r),
      )
      ..lineTo(w, h - r)
      ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
      ..lineTo(r, h)
      ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
      ..close();

    // Tab top
    final tabTopPath = Path()
      ..moveTo(0, tabHeight + r)
      ..arcToPoint(Offset(r, tabHeight), radius: Radius.circular(r))
      ..lineTo(r, r)
      ..arcToPoint(Offset(r + r, 0), radius: Radius.circular(r))
      ..lineTo(tabWidth - r, 0)
      ..arcToPoint(
        Offset(tabWidth, r),
        radius: Radius.circular(r),
      )
      ..lineTo(tabWidth, tabHeight)
      ..close();

    canvas.drawPath(tabTopPath, fillPaint);
    canvas.drawPath(tabTopPath, strokePaint);

    // Folder body: slightly different for open state
    if (state == OiFolderIconState.open) {
      // Draw a slightly tilted front face for open state
      final openOffset = h * 0.08;
      final openPath = Path()
        ..moveTo(0, tabHeight + tabHeight * 0.5 + openOffset)
        ..lineTo(w, tabHeight + tabHeight * 0.5)
        ..lineTo(w, h - r)
        ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
        ..lineTo(r, h)
        ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
        ..close();

      canvas.drawPath(openPath, fillPaint);
      canvas.drawPath(openPath, strokePaint);
    } else {
      canvas.drawPath(tabPath, fillPaint);
      canvas.drawPath(tabPath, strokePaint);
    }
  }

  @override
  bool shouldRepaint(_FolderIconPainter oldDelegate) =>
      folderColor != oldDelegate.folderColor ||
      borderColor != oldDelegate.borderColor ||
      state != oldDelegate.state ||
      tabWidth != oldDelegate.tabWidth ||
      tabHeight != oldDelegate.tabHeight;
}
