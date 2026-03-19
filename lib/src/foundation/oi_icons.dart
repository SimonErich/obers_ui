import 'package:flutter/widgets.dart';

/// Centralized icon constants for obers\_ui.
///
/// Provides all icons used across the library as named constants,
/// eliminating direct Material [Icons] class dependencies. Each constant
/// wraps a [IconData] with `fontFamily: 'MaterialIcons'`.
///
/// {@category Foundation}
class OiIcons {
  const OiIcons._();

  // ── Navigation ──────────────────────────────────────────────────────

  /// Left chevron arrow for back navigation.
  static const chevronLeft = IconData(0xe5c4, fontFamily: 'MaterialIcons');

  /// Right chevron arrow for forward navigation.
  static const chevronRight = IconData(0xe5cc, fontFamily: 'MaterialIcons');

  /// Navigate-next arrow (right).
  static const navigateNext = IconData(0xe5c8, fontFamily: 'MaterialIcons');

  /// Navigate-before arrow (left).
  static const navigateBefore = IconData(0xe5cb, fontFamily: 'MaterialIcons');

  /// Downward expand arrow (keyboard arrow down).
  static const expandMore = IconData(0xe5cf, fontFamily: 'MaterialIcons');

  /// Upward collapse arrow (keyboard arrow up).
  static const expandLess = IconData(0xe5ce, fontFamily: 'MaterialIcons');

  /// Dropdown arrow indicator.
  static const arrowDropDown = IconData(0xe5c5, fontFamily: 'MaterialIcons');

  /// Upward arrow indicator.
  static const arrowUpward = IconData(0xe5c7, fontFamily: 'MaterialIcons');

  // ── Actions ─────────────────────────────────────────────────────────

  /// Add / plus icon for creating new items.
  static const add = IconData(0xe145, fontFamily: 'MaterialIcons');

  /// Edit / pencil icon for modifying content.
  static const edit = IconData(0xe24c, fontFamily: 'MaterialIcons');

  /// Delete / trash-can icon for removing items.
  static const delete = IconData(0xe872, fontFamily: 'MaterialIcons');

  /// Close / dismiss icon (clear).
  static const close = IconData(0xe5cd, fontFamily: 'MaterialIcons');

  /// Check mark for confirming or completing.
  static const check = IconData(0xe5ca, fontFamily: 'MaterialIcons');

  /// Done / check mark (alternative).
  static const done = IconData(0xe876, fontFamily: 'MaterialIcons');

  /// Search magnifying glass.
  static const search = IconData(0xe8b6, fontFamily: 'MaterialIcons');

  /// Download arrow for saving files locally.
  static const download = IconData(0xe164, fontFamily: 'MaterialIcons');

  /// Cloud upload icon.
  static const cloudUpload = IconData(0xe2cc, fontFamily: 'MaterialIcons');

  /// Upload file icon.
  static const uploadFile = IconData(0xe9e4, fontFamily: 'MaterialIcons');

  /// Play arrow for media playback.
  static const playArrow = IconData(0xe037, fontFamily: 'MaterialIcons');

  /// Reply arrow icon.
  static const reply = IconData(0xe16a, fontFamily: 'MaterialIcons');

  // ── Clipboard & Content ─────────────────────────────────────────────

  /// Content copy icon for clipboard operations.
  static const contentCopy = IconData(0xe14d, fontFamily: 'MaterialIcons');

  /// Content paste icon for clipboard operations.
  static const contentPaste = IconData(0xeb80, fontFamily: 'MaterialIcons');

  /// Attach file icon for adding attachments.
  static const attachFile = IconData(0xe226, fontFamily: 'MaterialIcons');

  /// Bulleted list icon.
  static const formatListBulleted =
      IconData(0xe152, fontFamily: 'MaterialIcons');

  // ── Files & Folders ─────────────────────────────────────────────────

  /// Closed folder icon.
  static const folder = IconData(0xe2c7, fontFamily: 'MaterialIcons');

  /// Open folder icon.
  static const folderOpen = IconData(0xe89e, fontFamily: 'MaterialIcons');

  /// Create new folder icon.
  static const createNewFolder = IconData(0xe417, fontFamily: 'MaterialIcons');

  /// Move file to another folder.
  static const driveFileMove = IconData(0xf090, fontFamily: 'MaterialIcons');

  /// Generic file icon (insert drive file).
  static const insertDriveFile = IconData(0xe66d, fontFamily: 'MaterialIcons');

  /// Document description icon.
  static const description = IconData(0xe24d, fontFamily: 'MaterialIcons');

  /// Text snippet icon for plain-text content.
  static const textSnippet = IconData(0xf189, fontFamily: 'MaterialIcons');

  /// Compressed archive / zip folder icon.
  static const folderZip = IconData(0xeb2e, fontFamily: 'MaterialIcons');

  // ── File Types ──────────────────────────────────────────────────────

  /// Image file type icon.
  static const image = IconData(0xe3f4, fontFamily: 'MaterialIcons');

  /// Video file type icon.
  static const videoFile = IconData(0xf056, fontFamily: 'MaterialIcons');

  /// Audio file type icon.
  static const audioFile = IconData(0xebad, fontFamily: 'MaterialIcons');

  /// PDF document icon.
  static const pictureAsPdf = IconData(0xe7a2, fontFamily: 'MaterialIcons');

  /// Spreadsheet / table chart icon.
  static const tableChart = IconData(0xe99c, fontFamily: 'MaterialIcons');

  /// Slideshow / presentation icon.
  static const slideshow = IconData(0xe8b8, fontFamily: 'MaterialIcons');

  /// Source code file icon.
  static const code = IconData(0xe86f, fontFamily: 'MaterialIcons');

  /// Data / JSON object icon.
  static const dataObject = IconData(0xf579, fontFamily: 'MaterialIcons');

  // ── Layout & View ───────────────────────────────────────────────────

  /// List view icon.
  static const viewList = IconData(0xe8ef, fontFamily: 'MaterialIcons');

  /// Grid view icon.
  static const gridView = IconData(0xe3ea, fontFamily: 'MaterialIcons');

  /// Dashboard / drag indicator icon.
  static const dashboardCustomize =
      IconData(0xe945, fontFamily: 'MaterialIcons');

  // ── Feedback & Status ───────────────────────────────────────────────

  /// Thumb up / like icon.
  static const thumbUp = IconData(0xe8dc, fontFamily: 'MaterialIcons');

  /// Thumb down / dislike icon.
  static const thumbDown = IconData(0xe8db, fontFamily: 'MaterialIcons');

  /// Informational circle icon.
  static const info = IconData(0xe80d, fontFamily: 'MaterialIcons');

  /// Warning triangle icon.
  static const warning = IconData(0xe002, fontFamily: 'MaterialIcons');

  /// Error outline icon (exclamation in circle).
  static const errorOutline = IconData(0xe000, fontFamily: 'MaterialIcons');

  /// Check circle icon (filled success indicator).
  static const checkCircle = IconData(0xe86c, fontFamily: 'MaterialIcons');

  /// Play circle filled icon (running/active indicator).
  static const playCircleFilled = IconData(0xe627, fontFamily: 'MaterialIcons');

  /// Radio button unchecked (empty circle for pending state).
  static const radioButtonUnchecked =
      IconData(0xef4a, fontFamily: 'MaterialIcons');

  /// Block / prohibited icon.
  static const block = IconData(0xe044, fontFamily: 'MaterialIcons');

  /// Star / favourite icon.
  static const star = IconData(0xe838, fontFamily: 'MaterialIcons');

  // ── People & Identity ───────────────────────────────────────────────

  /// Single person icon.
  static const person = IconData(0xe7fd, fontFamily: 'MaterialIcons');

  /// Group / people icon.
  static const group = IconData(0xe7fb, fontFamily: 'MaterialIcons');

  /// Emoji / mood smiley icon.
  static const emojiEmotions = IconData(0xe571, fontFamily: 'MaterialIcons');

  // ── Time & Scheduling ───────────────────────────────────────────────

  /// Clock / access time icon.
  static const accessTime = IconData(0xe3c9, fontFamily: 'MaterialIcons');

  /// Schedule / clock icon (alternative).
  static const schedule = IconData(0xe41e, fontFamily: 'MaterialIcons');

  /// Calendar / event icon.
  static const event = IconData(0xe0d3, fontFamily: 'MaterialIcons');

  /// History / recent icon.
  static const history = IconData(0xe889, fontFamily: 'MaterialIcons');

  /// Notifications / bell icon.
  static const notifications = IconData(0xe7f5, fontFamily: 'MaterialIcons');

  // ── Security ────────────────────────────────────────────────────────

  /// Lock / padlock icon.
  static const lock = IconData(0xe897, fontFamily: 'MaterialIcons');
}
