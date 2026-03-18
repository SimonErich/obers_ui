import 'package:web/web.dart' as web;

/// Checks the `hover` media query on web to determine if a hover-capable
/// pointing device is available.
bool supportsHoverMediaQuery() =>
    web.window.matchMedia('(hover: hover)').matches;
