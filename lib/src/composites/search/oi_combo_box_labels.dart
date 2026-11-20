import 'package:obers_ui/src/composites/search/oi_combo_box.dart';

/// The texts of an [OiComboBox] dropdown, in English by default; pass
/// translations to localize the combo box.
///
/// The no-results text and the section headings stay on the widget itself, as
/// [OiComboBox.noResultsLabel], [OiComboBox.recentLabel] and
/// [OiComboBox.favoritesLabel].
///
/// {@category Composites}
class OiComboBoxLabels {
  /// Creates an [OiComboBoxLabels].
  const OiComboBoxLabels({
    this.searchPlaceholder = 'Search…',
    this.loading = 'Loading…',
    this.create = englishCreate,
    this.loadMore = 'Load more…',
  });

  /// 'Create "Mango"': the default [create].
  static String englishCreate(String query) => 'Create "$query"';

  /// Placeholder of the search field in the dropdown.
  final String searchPlaceholder;

  /// Shown while an async search is running.
  final String loading;

  /// Label of the action that creates an option from the typed query.
  final String Function(String query) create;

  /// Label of the row that loads the next page of options.
  final String loadMore;
}
