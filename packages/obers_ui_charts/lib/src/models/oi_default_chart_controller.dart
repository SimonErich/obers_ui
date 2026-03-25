import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';
import 'package:obers_ui_charts/src/models/oi_chart_state_models.dart';

/// Default concrete implementation of `OiChartController`.
///
/// Manages selection, hover, viewport, legend, and focus state with
/// `ChangeNotifier`-based notification.
///
/// {@category Models}
class OiDefaultChartController extends OiChartController {
  /// Creates an [OiDefaultChartController].
  OiDefaultChartController();

  // ── Selection ──────────────────────────────────────────────────────────

  OiChartSelectionState _selectionState = OiChartSelectionState.empty;

  @override
  OiChartSelectionState get selectionState => _selectionState;

  @override
  Set<OiChartDataRef> get selection => _selectionState.selectedRefs;

  @override
  void select(Set<OiChartDataRef> refs) {
    _selectionState = _selectionState.copyWith(
      selectedRefs: refs,
      timestamp: DateTime.now(),
    );
    notifyListeners();
  }

  @override
  void clearSelection() {
    if (!_selectionState.hasSelection) return;
    _selectionState = OiChartSelectionState.empty;
    notifyListeners();
  }

  // ── Hover ────────────────────────────────────────────────────────────

  OiChartHoverState _hoverState = OiChartHoverState.empty;

  @override
  OiChartHoverState get hoverState => _hoverState;

  @override
  OiChartDataRef? get hovered => _hoverState.ref;

  @override
  void hover(OiChartDataRef? ref) {
    if (_hoverState.ref == ref) return;
    _hoverState = OiChartHoverState(ref: ref);
    notifyListeners();
  }

  // ── Viewport ─────────────────────────────────────────────────────────

  final OiChartViewportState _viewportState = OiChartViewportState();

  @override
  OiChartViewportState get viewportState => _viewportState;

  @override
  void resetZoom() {
    if (!_viewportState.isZoomed) return;
    _viewportState.reset();
    notifyListeners();
  }

  @override
  void setVisibleDomain({
    double? xMin,
    double? xMax,
    double? yMin,
    double? yMax,
  }) {
    _viewportState
      ..xMin = xMin
      ..xMax = xMax
      ..yMin = yMin
      ..yMax = yMax;
    notifyListeners();
  }

  // ── Legend ────────────────────────────────────────────────────────────

  OiChartLegendState _legendState = OiChartLegendState.empty;

  @override
  OiChartLegendState get legendState => _legendState;

  @override
  void toggleSeries(String seriesId) {
    final hidden = Set<String>.of(_legendState.hiddenSeriesIds);
    if (hidden.contains(seriesId)) {
      hidden.remove(seriesId);
    } else {
      hidden.add(seriesId);
    }
    _legendState = _legendState.copyWith(hiddenSeriesIds: hidden);
    notifyListeners();
  }

  @override
  void focusSeries(String seriesId) {
    final current = _legendState.focusedSeriesId;
    final newFocus = current == seriesId ? null : seriesId;
    _legendState = OiChartLegendState(
      hiddenSeriesIds: _legendState.hiddenSeriesIds,
      focusedSeriesId: newFocus,
      expandedGroups: _legendState.expandedGroups,
    );
    notifyListeners();
  }

  // ── Focus ────────────────────────────────────────────────────────────

  final OiChartFocusState _focusState = OiChartFocusState.empty;

  @override
  OiChartFocusState get focusState => _focusState;

  // ── Data lifecycle ───────────────────────────────────────────────────

  bool _isLoading = false;
  String? _error;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  /// Sets the loading state and notifies listeners.
  void setLoading({required bool loading}) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }

  /// Sets the error state and notifies listeners.
  void setError(String? error) {
    if (_error == error) return;
    _error = error;
    notifyListeners();
  }
}
