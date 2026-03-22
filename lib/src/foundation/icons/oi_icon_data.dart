import 'package:flutter/widgets.dart';

/// An icon glyph descriptor used by [OiIcon] and the [OiIcons] constants.
///
/// This typedef wraps Flutter's [IconData] so that widget signatures reference
/// a library-owned type. If the underlying icon representation changes in a
/// future version (e.g. switching from font-based to SVG-based icons), only
/// this typedef and the constants file need to be updated — all consumer code
/// remains source-compatible.
///
/// {@category Foundation}
typedef OiIconData = IconData;
