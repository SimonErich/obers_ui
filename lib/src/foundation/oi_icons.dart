import 'package:flutter/widgets.dart';

/// Centralized icon constants for obers_ui backed by Lucide icons.
///
/// Every constant wraps an [IconData] referencing the embedded
/// `lucide` font shipped with this package. All consumer code uses these
/// named constants and remains unaffected by the underlying icon set.
///
/// Icon set: [Lucide](https://lucide.dev) v0.577.0 — 1,951 icons.
///
/// {@category Foundation}
class OiIcons {
  const OiIcons._();

  static const _f = 'lucide';
  static const _p = 'obers_ui';

  // ── Arrows & Navigation ───────────────────────────────────────────

  /// a-arrow-down icon.
  static const aArrowDown = IconData(0xe585, fontFamily: _f, fontPackage: _p);

  /// a-arrow-up icon.
  static const aArrowUp = IconData(0xe586, fontFamily: _f, fontPackage: _p);

  /// arrow-big-down icon.
  static const arrowBigDown = IconData(0xe1e1, fontFamily: _f, fontPackage: _p);

  /// arrow-big-down-dash icon.
  static const arrowBigDownDash = IconData(0xe41d, fontFamily: _f, fontPackage: _p);

  /// arrow-big-left icon.
  static const arrowBigLeft = IconData(0xe1e2, fontFamily: _f, fontPackage: _p);

  /// arrow-big-left-dash icon.
  static const arrowBigLeftDash = IconData(0xe41e, fontFamily: _f, fontPackage: _p);

  /// arrow-big-right icon.
  static const arrowBigRight = IconData(0xe1e3, fontFamily: _f, fontPackage: _p);

  /// arrow-big-right-dash icon.
  static const arrowBigRightDash = IconData(0xe41f, fontFamily: _f, fontPackage: _p);

  /// arrow-big-up icon.
  static const arrowBigUp = IconData(0xe1e4, fontFamily: _f, fontPackage: _p);

  /// arrow-big-up-dash icon.
  static const arrowBigUpDash = IconData(0xe420, fontFamily: _f, fontPackage: _p);

  /// arrow-down icon.
  static const arrowDown = IconData(0xe042, fontFamily: _f, fontPackage: _p);

  /// arrow-down-0-1 icon.
  static const arrowDown01 = IconData(0xe413, fontFamily: _f, fontPackage: _p);

  /// arrow-down-1-0 icon.
  static const arrowDown10 = IconData(0xe414, fontFamily: _f, fontPackage: _p);

  /// arrow-down-a-z icon.
  static const arrowDownAZ = IconData(0xe415, fontFamily: _f, fontPackage: _p);

  /// arrow-down-az icon.
  static const arrowDownAz = IconData(0xe415, fontFamily: _f, fontPackage: _p);

  /// arrow-down-circle icon.
  static const arrowDownCircle = IconData(0xe078, fontFamily: _f, fontPackage: _p);

  /// arrow-down-from-line icon.
  static const arrowDownFromLine = IconData(0xe454, fontFamily: _f, fontPackage: _p);

  /// arrow-down-left icon.
  static const arrowDownLeft = IconData(0xe043, fontFamily: _f, fontPackage: _p);

  /// arrow-down-left-from-circle icon.
  static const arrowDownLeftFromCircle = IconData(0xe3f7, fontFamily: _f, fontPackage: _p);

  /// arrow-down-left-from-square icon.
  static const arrowDownLeftFromSquare = IconData(0xe5a1, fontFamily: _f, fontPackage: _p);

  /// arrow-down-left-square icon.
  static const arrowDownLeftSquare = IconData(0xe4b5, fontFamily: _f, fontPackage: _p);

  /// arrow-down-narrow-wide icon.
  static const arrowDownNarrowWide = IconData(0xe044, fontFamily: _f, fontPackage: _p);

  /// arrow-down-right icon.
  static const arrowDownRight = IconData(0xe045, fontFamily: _f, fontPackage: _p);

  /// arrow-down-right-from-circle icon.
  static const arrowDownRightFromCircle = IconData(0xe3f8, fontFamily: _f, fontPackage: _p);

  /// arrow-down-right-from-square icon.
  static const arrowDownRightFromSquare = IconData(0xe5a2, fontFamily: _f, fontPackage: _p);

  /// arrow-down-right-square icon.
  static const arrowDownRightSquare = IconData(0xe4b6, fontFamily: _f, fontPackage: _p);

  /// arrow-down-square icon.
  static const arrowDownSquare = IconData(0xe427, fontFamily: _f, fontPackage: _p);

  /// arrow-down-to-dot icon.
  static const arrowDownToDot = IconData(0xe44d, fontFamily: _f, fontPackage: _p);

  /// arrow-down-to-line icon.
  static const arrowDownToLine = IconData(0xe455, fontFamily: _f, fontPackage: _p);

  /// arrow-down-up icon.
  static const arrowDownUp = IconData(0xe046, fontFamily: _f, fontPackage: _p);

  /// arrow-down-wide-narrow icon.
  static const arrowDownWideNarrow = IconData(0xe047, fontFamily: _f, fontPackage: _p);

  /// arrow-down-z-a icon.
  static const arrowDownZA = IconData(0xe416, fontFamily: _f, fontPackage: _p);

  /// arrow-down-za icon.
  static const arrowDownZa = IconData(0xe416, fontFamily: _f, fontPackage: _p);

  /// arrow-left icon.
  static const arrowLeft = IconData(0xe048, fontFamily: _f, fontPackage: _p);

  /// arrow-left-circle icon.
  static const arrowLeftCircle = IconData(0xe079, fontFamily: _f, fontPackage: _p);

  /// arrow-left-from-line icon.
  static const arrowLeftFromLine = IconData(0xe456, fontFamily: _f, fontPackage: _p);

  /// arrow-left-right icon.
  static const arrowLeftRight = IconData(0xe24a, fontFamily: _f, fontPackage: _p);

  /// arrow-left-square icon.
  static const arrowLeftSquare = IconData(0xe428, fontFamily: _f, fontPackage: _p);

  /// arrow-left-to-line icon.
  static const arrowLeftToLine = IconData(0xe457, fontFamily: _f, fontPackage: _p);

  /// arrow-right icon.
  static const arrowRight = IconData(0xe049, fontFamily: _f, fontPackage: _p);

  /// arrow-right-circle icon.
  static const arrowRightCircle = IconData(0xe07a, fontFamily: _f, fontPackage: _p);

  /// arrow-right-from-line icon.
  static const arrowRightFromLine = IconData(0xe458, fontFamily: _f, fontPackage: _p);

  /// arrow-right-left icon.
  static const arrowRightLeft = IconData(0xe417, fontFamily: _f, fontPackage: _p);

  /// arrow-right-square icon.
  static const arrowRightSquare = IconData(0xe429, fontFamily: _f, fontPackage: _p);

  /// arrow-right-to-line icon.
  static const arrowRightToLine = IconData(0xe459, fontFamily: _f, fontPackage: _p);

  /// arrow-up icon.
  static const arrowUp = IconData(0xe04a, fontFamily: _f, fontPackage: _p);

  /// arrow-up-0-1 icon.
  static const arrowUp01 = IconData(0xe418, fontFamily: _f, fontPackage: _p);

  /// arrow-up-1-0 icon.
  static const arrowUp10 = IconData(0xe419, fontFamily: _f, fontPackage: _p);

  /// arrow-up-a-z icon.
  static const arrowUpAZ = IconData(0xe41a, fontFamily: _f, fontPackage: _p);

  /// arrow-up-az icon.
  static const arrowUpAz = IconData(0xe41a, fontFamily: _f, fontPackage: _p);

  /// arrow-up-circle icon.
  static const arrowUpCircle = IconData(0xe07b, fontFamily: _f, fontPackage: _p);

  /// arrow-up-down icon.
  static const arrowUpDown = IconData(0xe37d, fontFamily: _f, fontPackage: _p);

  /// arrow-up-from-dot icon.
  static const arrowUpFromDot = IconData(0xe44e, fontFamily: _f, fontPackage: _p);

  /// arrow-up-from-line icon.
  static const arrowUpFromLine = IconData(0xe45a, fontFamily: _f, fontPackage: _p);

  /// arrow-up-left icon.
  static const arrowUpLeft = IconData(0xe04b, fontFamily: _f, fontPackage: _p);

  /// arrow-up-left-from-circle icon.
  static const arrowUpLeftFromCircle = IconData(0xe3f9, fontFamily: _f, fontPackage: _p);

  /// arrow-up-left-from-square icon.
  static const arrowUpLeftFromSquare = IconData(0xe5a3, fontFamily: _f, fontPackage: _p);

  /// arrow-up-left-square icon.
  static const arrowUpLeftSquare = IconData(0xe4b7, fontFamily: _f, fontPackage: _p);

  /// arrow-up-narrow-wide icon.
  static const arrowUpNarrowWide = IconData(0xe04c, fontFamily: _f, fontPackage: _p);

  /// arrow-up-right icon.
  static const arrowUpRight = IconData(0xe04d, fontFamily: _f, fontPackage: _p);

  /// arrow-up-right-from-circle icon.
  static const arrowUpRightFromCircle = IconData(0xe3fa, fontFamily: _f, fontPackage: _p);

  /// arrow-up-right-from-square icon.
  static const arrowUpRightFromSquare = IconData(0xe5a4, fontFamily: _f, fontPackage: _p);

  /// arrow-up-right-square icon.
  static const arrowUpRightSquare = IconData(0xe4b8, fontFamily: _f, fontPackage: _p);

  /// arrow-up-square icon.
  static const arrowUpSquare = IconData(0xe42a, fontFamily: _f, fontPackage: _p);

  /// arrow-up-to-line icon.
  static const arrowUpToLine = IconData(0xe45b, fontFamily: _f, fontPackage: _p);

  /// arrow-up-wide-narrow icon.
  static const arrowUpWideNarrow = IconData(0xe41b, fontFamily: _f, fontPackage: _p);

  /// arrow-up-z-a icon.
  static const arrowUpZA = IconData(0xe41c, fontFamily: _f, fontPackage: _p);

  /// arrow-up-za icon.
  static const arrowUpZa = IconData(0xe41c, fontFamily: _f, fontPackage: _p);

  /// arrows-up-from-line icon.
  static const arrowsUpFromLine = IconData(0xe4d4, fontFamily: _f, fontPackage: _p);

  /// banknote-arrow-down icon.
  static const banknoteArrowDown = IconData(0xe64c, fontFamily: _f, fontPackage: _p);

  /// banknote-arrow-up icon.
  static const banknoteArrowUp = IconData(0xe64d, fontFamily: _f, fontPackage: _p);

  /// bow-arrow icon.
  static const bowArrow = IconData(0xe65e, fontFamily: _f, fontPackage: _p);

  /// calendar-arrow-down icon.
  static const calendarArrowDown = IconData(0xe5fe, fontFamily: _f, fontPackage: _p);

  /// calendar-arrow-up icon.
  static const calendarArrowUp = IconData(0xe5ff, fontFamily: _f, fontPackage: _p);

  /// chevron-down icon.
  static const chevronDown = IconData(0xe06d, fontFamily: _f, fontPackage: _p);

  /// chevron-down-circle icon.
  static const chevronDownCircle = IconData(0xe4dd, fontFamily: _f, fontPackage: _p);

  /// chevron-down-square icon.
  static const chevronDownSquare = IconData(0xe3cf, fontFamily: _f, fontPackage: _p);

  /// chevron-first icon.
  static const chevronFirst = IconData(0xe243, fontFamily: _f, fontPackage: _p);

  /// chevron-last icon.
  static const chevronLast = IconData(0xe244, fontFamily: _f, fontPackage: _p);

  /// chevron-left icon.
  static const chevronLeft = IconData(0xe06e, fontFamily: _f, fontPackage: _p);

  /// chevron-left-circle icon.
  static const chevronLeftCircle = IconData(0xe4de, fontFamily: _f, fontPackage: _p);

  /// chevron-left-square icon.
  static const chevronLeftSquare = IconData(0xe3d0, fontFamily: _f, fontPackage: _p);

  /// chevron-right icon.
  static const chevronRight = IconData(0xe06f, fontFamily: _f, fontPackage: _p);

  /// chevron-right-circle icon.
  static const chevronRightCircle = IconData(0xe4df, fontFamily: _f, fontPackage: _p);

  /// chevron-right-square icon.
  static const chevronRightSquare = IconData(0xe3d1, fontFamily: _f, fontPackage: _p);

  /// chevron-up icon.
  static const chevronUp = IconData(0xe070, fontFamily: _f, fontPackage: _p);

  /// chevron-up-circle icon.
  static const chevronUpCircle = IconData(0xe4e0, fontFamily: _f, fontPackage: _p);

  /// chevron-up-square icon.
  static const chevronUpSquare = IconData(0xe3d2, fontFamily: _f, fontPackage: _p);

  /// chevrons-down icon.
  static const chevronsDown = IconData(0xe071, fontFamily: _f, fontPackage: _p);

  /// chevrons-down-up icon.
  static const chevronsDownUp = IconData(0xe228, fontFamily: _f, fontPackage: _p);

  /// chevrons-left icon.
  static const chevronsLeft = IconData(0xe072, fontFamily: _f, fontPackage: _p);

  /// chevrons-left-right icon.
  static const chevronsLeftRight = IconData(0xe293, fontFamily: _f, fontPackage: _p);

  /// chevrons-left-right-ellipsis icon.
  static const chevronsLeftRightEllipsis = IconData(0xe61f, fontFamily: _f, fontPackage: _p);

  /// chevrons-right icon.
  static const chevronsRight = IconData(0xe073, fontFamily: _f, fontPackage: _p);

  /// chevrons-right-left icon.
  static const chevronsRightLeft = IconData(0xe294, fontFamily: _f, fontPackage: _p);

  /// chevrons-up icon.
  static const chevronsUp = IconData(0xe074, fontFamily: _f, fontPackage: _p);

  /// chevrons-up-down icon.
  static const chevronsUpDown = IconData(0xe211, fontFamily: _f, fontPackage: _p);

  /// circle-arrow-down icon.
  static const circleArrowDown = IconData(0xe078, fontFamily: _f, fontPackage: _p);

  /// circle-arrow-left icon.
  static const circleArrowLeft = IconData(0xe079, fontFamily: _f, fontPackage: _p);

  /// circle-arrow-out-down-left icon.
  static const circleArrowOutDownLeft = IconData(0xe3f7, fontFamily: _f, fontPackage: _p);

  /// circle-arrow-out-down-right icon.
  static const circleArrowOutDownRight = IconData(0xe3f8, fontFamily: _f, fontPackage: _p);

  /// circle-arrow-out-up-left icon.
  static const circleArrowOutUpLeft = IconData(0xe3f9, fontFamily: _f, fontPackage: _p);

  /// circle-arrow-out-up-right icon.
  static const circleArrowOutUpRight = IconData(0xe3fa, fontFamily: _f, fontPackage: _p);

  /// circle-arrow-right icon.
  static const circleArrowRight = IconData(0xe07a, fontFamily: _f, fontPackage: _p);

  /// circle-arrow-up icon.
  static const circleArrowUp = IconData(0xe07b, fontFamily: _f, fontPackage: _p);

  /// circle-chevron-down icon.
  static const circleChevronDown = IconData(0xe4dd, fontFamily: _f, fontPackage: _p);

  /// circle-chevron-left icon.
  static const circleChevronLeft = IconData(0xe4de, fontFamily: _f, fontPackage: _p);

  /// circle-chevron-right icon.
  static const circleChevronRight = IconData(0xe4df, fontFamily: _f, fontPackage: _p);

  /// circle-chevron-up icon.
  static const circleChevronUp = IconData(0xe4e0, fontFamily: _f, fontPackage: _p);

  /// circle-fading-arrow-up icon.
  static const circleFadingArrowUp = IconData(0xe618, fontFamily: _f, fontPackage: _p);

  /// clock-arrow-down icon.
  static const clockArrowDown = IconData(0xe600, fontFamily: _f, fontPackage: _p);

  /// clock-arrow-up icon.
  static const clockArrowUp = IconData(0xe601, fontFamily: _f, fontPackage: _p);

  /// compass icon.
  static const compass = IconData(0xe09b, fontFamily: _f, fontPackage: _p);

  /// corner-down-left icon.
  static const cornerDownLeft = IconData(0xe0a1, fontFamily: _f, fontPackage: _p);

  /// corner-down-right icon.
  static const cornerDownRight = IconData(0xe0a2, fontFamily: _f, fontPackage: _p);

  /// corner-left-down icon.
  static const cornerLeftDown = IconData(0xe0a3, fontFamily: _f, fontPackage: _p);

  /// corner-left-up icon.
  static const cornerLeftUp = IconData(0xe0a4, fontFamily: _f, fontPackage: _p);

  /// corner-right-down icon.
  static const cornerRightDown = IconData(0xe0a5, fontFamily: _f, fontPackage: _p);

  /// corner-right-up icon.
  static const cornerRightUp = IconData(0xe0a6, fontFamily: _f, fontPackage: _p);

  /// corner-up-left icon.
  static const cornerUpLeft = IconData(0xe0a7, fontFamily: _f, fontPackage: _p);

  /// corner-up-right icon.
  static const cornerUpRight = IconData(0xe0a8, fontFamily: _f, fontPackage: _p);

  /// decimals-arrow-left icon.
  static const decimalsArrowLeft = IconData(0xe65c, fontFamily: _f, fontPackage: _p);

  /// decimals-arrow-right icon.
  static const decimalsArrowRight = IconData(0xe65d, fontFamily: _f, fontPackage: _p);

  /// drafting-compass icon.
  static const draftingCompass = IconData(0xe527, fontFamily: _f, fontPackage: _p);

  /// file-braces-corner icon.
  static const fileBracesCorner = IconData(0xe36c, fontFamily: _f, fontPackage: _p);

  /// file-check-corner icon.
  static const fileCheckCorner = IconData(0xe0c2, fontFamily: _f, fontPackage: _p);

  /// file-code-corner icon.
  static const fileCodeCorner = IconData(0xe45e, fontFamily: _f, fontPackage: _p);

  /// file-minus-corner icon.
  static const fileMinusCorner = IconData(0xe0c7, fontFamily: _f, fontPackage: _p);

  /// file-plus-corner icon.
  static const filePlusCorner = IconData(0xe0ca, fontFamily: _f, fontPackage: _p);

  /// file-search-corner icon.
  static const fileSearchCorner = IconData(0xe324, fontFamily: _f, fontPackage: _p);

  /// file-type-corner icon.
  static const fileTypeCorner = IconData(0xe36d, fontFamily: _f, fontPackage: _p);

  /// file-x-corner icon.
  static const fileXCorner = IconData(0xe0ce, fontFamily: _f, fontPackage: _p);

  /// git-compare-arrows icon.
  static const gitCompareArrows = IconData(0xe553, fontFamily: _f, fontPackage: _p);

  /// git-pull-request-arrow icon.
  static const gitPullRequestArrow = IconData(0xe555, fontFamily: _f, fontPackage: _p);

  /// git-pull-request-create-arrow icon.
  static const gitPullRequestCreateArrow = IconData(0xe557, fontFamily: _f, fontPackage: _p);

  /// list-chevrons-down-up icon.
  static const listChevronsDownUp = IconData(0xe694, fontFamily: _f, fontPackage: _p);

  /// list-chevrons-up-down icon.
  static const listChevronsUpDown = IconData(0xe696, fontFamily: _f, fontPackage: _p);

  /// move icon.
  static const move = IconData(0xe121, fontFamily: _f, fontPackage: _p);

  /// move-3-d icon.
  static const move3D = IconData(0xe2e5, fontFamily: _f, fontPackage: _p);

  /// move-3d icon.
  static const move3d = IconData(0xe2e5, fontFamily: _f, fontPackage: _p);

  /// move-diagonal icon.
  static const moveDiagonal = IconData(0xe1c4, fontFamily: _f, fontPackage: _p);

  /// move-diagonal-2 icon.
  static const moveDiagonal2 = IconData(0xe1c5, fontFamily: _f, fontPackage: _p);

  /// move-down icon.
  static const moveDown = IconData(0xe48c, fontFamily: _f, fontPackage: _p);

  /// move-down-left icon.
  static const moveDownLeft = IconData(0xe48d, fontFamily: _f, fontPackage: _p);

  /// move-down-right icon.
  static const moveDownRight = IconData(0xe48e, fontFamily: _f, fontPackage: _p);

  /// move-horizontal icon.
  static const moveHorizontal = IconData(0xe1c6, fontFamily: _f, fontPackage: _p);

  /// move-left icon.
  static const moveLeft = IconData(0xe48f, fontFamily: _f, fontPackage: _p);

  /// move-right icon.
  static const moveRight = IconData(0xe490, fontFamily: _f, fontPackage: _p);

  /// move-up icon.
  static const moveUp = IconData(0xe491, fontFamily: _f, fontPackage: _p);

  /// move-up-left icon.
  static const moveUpLeft = IconData(0xe492, fontFamily: _f, fontPackage: _p);

  /// move-up-right icon.
  static const moveUpRight = IconData(0xe493, fontFamily: _f, fontPackage: _p);

  /// move-vertical icon.
  static const moveVertical = IconData(0xe1c7, fontFamily: _f, fontPackage: _p);

  /// navigation icon.
  static const navigation = IconData(0xe123, fontFamily: _f, fontPackage: _p);

  /// navigation-2 icon.
  static const navigation2 = IconData(0xe124, fontFamily: _f, fontPackage: _p);

  /// navigation-2-off icon.
  static const navigation2Off = IconData(0xe2a7, fontFamily: _f, fontPackage: _p);

  /// navigation-off icon.
  static const navigationOff = IconData(0xe2a8, fontFamily: _f, fontPackage: _p);

  /// redo icon.
  static const redo = IconData(0xe143, fontFamily: _f, fontPackage: _p);

  /// redo-2 icon.
  static const redo2 = IconData(0xe2a0, fontFamily: _f, fontPackage: _p);

  /// redo-dot icon.
  static const redoDot = IconData(0xe450, fontFamily: _f, fontPackage: _p);

  /// remove-formatting icon.
  static const removeFormatting = IconData(0xe3b3, fontFamily: _f, fontPackage: _p);

  /// route icon.
  static const route = IconData(0xe53e, fontFamily: _f, fontPackage: _p);

  /// route-off icon.
  static const routeOff = IconData(0xe53f, fontFamily: _f, fontPackage: _p);

  /// router icon.
  static const router = IconData(0xe3bf, fontFamily: _f, fontPackage: _p);

  /// signpost icon.
  static const signpost = IconData(0xe540, fontFamily: _f, fontPackage: _p);

  /// signpost-big icon.
  static const signpostBig = IconData(0xe541, fontFamily: _f, fontPackage: _p);

  /// square-arrow-down icon.
  static const squareArrowDown = IconData(0xe427, fontFamily: _f, fontPackage: _p);

  /// square-arrow-down-left icon.
  static const squareArrowDownLeft = IconData(0xe4b5, fontFamily: _f, fontPackage: _p);

  /// square-arrow-down-right icon.
  static const squareArrowDownRight = IconData(0xe4b6, fontFamily: _f, fontPackage: _p);

  /// square-arrow-left icon.
  static const squareArrowLeft = IconData(0xe428, fontFamily: _f, fontPackage: _p);

  /// square-arrow-out-down-left icon.
  static const squareArrowOutDownLeft = IconData(0xe5a1, fontFamily: _f, fontPackage: _p);

  /// square-arrow-out-down-right icon.
  static const squareArrowOutDownRight = IconData(0xe5a2, fontFamily: _f, fontPackage: _p);

  /// square-arrow-out-up-left icon.
  static const squareArrowOutUpLeft = IconData(0xe5a3, fontFamily: _f, fontPackage: _p);

  /// square-arrow-out-up-right icon.
  static const squareArrowOutUpRight = IconData(0xe5a4, fontFamily: _f, fontPackage: _p);

  /// square-arrow-right icon.
  static const squareArrowRight = IconData(0xe429, fontFamily: _f, fontPackage: _p);

  /// square-arrow-right-enter icon.
  static const squareArrowRightEnter = IconData(0xe6c3, fontFamily: _f, fontPackage: _p);

  /// square-arrow-right-exit icon.
  static const squareArrowRightExit = IconData(0xe6c4, fontFamily: _f, fontPackage: _p);

  /// square-arrow-up icon.
  static const squareArrowUp = IconData(0xe42a, fontFamily: _f, fontPackage: _p);

  /// square-arrow-up-left icon.
  static const squareArrowUpLeft = IconData(0xe4b7, fontFamily: _f, fontPackage: _p);

  /// square-arrow-up-right icon.
  static const squareArrowUpRight = IconData(0xe4b8, fontFamily: _f, fontPackage: _p);

  /// square-chevron-down icon.
  static const squareChevronDown = IconData(0xe3cf, fontFamily: _f, fontPackage: _p);

  /// square-chevron-left icon.
  static const squareChevronLeft = IconData(0xe3d0, fontFamily: _f, fontPackage: _p);

  /// square-chevron-right icon.
  static const squareChevronRight = IconData(0xe3d1, fontFamily: _f, fontPackage: _p);

  /// square-chevron-up icon.
  static const squareChevronUp = IconData(0xe3d2, fontFamily: _f, fontPackage: _p);

  /// square-round-corner icon.
  static const squareRoundCorner = IconData(0xe648, fontFamily: _f, fontPackage: _p);

  /// undo icon.
  static const undo = IconData(0xe19b, fontFamily: _f, fontPackage: _p);

  /// undo-2 icon.
  static const undo2 = IconData(0xe2a1, fontFamily: _f, fontPackage: _p);

  /// undo-dot icon.
  static const undoDot = IconData(0xe451, fontFamily: _f, fontPackage: _p);

  /// waves-arrow-down icon.
  static const wavesArrowDown = IconData(0xe6a9, fontFamily: _f, fontPackage: _p);

  /// waves-arrow-up icon.
  static const wavesArrowUp = IconData(0xe6aa, fontFamily: _f, fontPackage: _p);

  /// waypoints icon.
  static const waypoints = IconData(0xe542, fontFamily: _f, fontPackage: _p);

  /// wind-arrow-down icon.
  static const windArrowDown = IconData(0xe631, fontFamily: _f, fontPackage: _p);


  // ── Layout ────────────────────────────────────────────────────────

  /// align-center icon.
  static const alignCenter = IconData(0xe182, fontFamily: _f, fontPackage: _p);

  /// align-center-horizontal icon.
  static const alignCenterHorizontal = IconData(0xe26c, fontFamily: _f, fontPackage: _p);

  /// align-center-vertical icon.
  static const alignCenterVertical = IconData(0xe26d, fontFamily: _f, fontPackage: _p);

  /// align-end-horizontal icon.
  static const alignEndHorizontal = IconData(0xe26e, fontFamily: _f, fontPackage: _p);

  /// align-end-vertical icon.
  static const alignEndVertical = IconData(0xe26f, fontFamily: _f, fontPackage: _p);

  /// align-horizontal-distribute-center icon.
  static const alignHorizontalDistributeCenter = IconData(0xe03c, fontFamily: _f, fontPackage: _p);

  /// align-horizontal-distribute-end icon.
  static const alignHorizontalDistributeEnd = IconData(0xe03d, fontFamily: _f, fontPackage: _p);

  /// align-horizontal-distribute-start icon.
  static const alignHorizontalDistributeStart = IconData(0xe03e, fontFamily: _f, fontPackage: _p);

  /// align-horizontal-justify-center icon.
  static const alignHorizontalJustifyCenter = IconData(0xe272, fontFamily: _f, fontPackage: _p);

  /// align-horizontal-justify-end icon.
  static const alignHorizontalJustifyEnd = IconData(0xe273, fontFamily: _f, fontPackage: _p);

  /// align-horizontal-justify-start icon.
  static const alignHorizontalJustifyStart = IconData(0xe274, fontFamily: _f, fontPackage: _p);

  /// align-horizontal-space-around icon.
  static const alignHorizontalSpaceAround = IconData(0xe275, fontFamily: _f, fontPackage: _p);

  /// align-horizontal-space-between icon.
  static const alignHorizontalSpaceBetween = IconData(0xe276, fontFamily: _f, fontPackage: _p);

  /// align-justify icon.
  static const alignJustify = IconData(0xe184, fontFamily: _f, fontPackage: _p);

  /// align-left icon.
  static const alignLeft = IconData(0xe185, fontFamily: _f, fontPackage: _p);

  /// align-right icon.
  static const alignRight = IconData(0xe183, fontFamily: _f, fontPackage: _p);

  /// align-start-horizontal icon.
  static const alignStartHorizontal = IconData(0xe270, fontFamily: _f, fontPackage: _p);

  /// align-start-vertical icon.
  static const alignStartVertical = IconData(0xe271, fontFamily: _f, fontPackage: _p);

  /// align-vertical-distribute-center icon.
  static const alignVerticalDistributeCenter = IconData(0xe27e, fontFamily: _f, fontPackage: _p);

  /// align-vertical-distribute-end icon.
  static const alignVerticalDistributeEnd = IconData(0xe27f, fontFamily: _f, fontPackage: _p);

  /// align-vertical-distribute-start icon.
  static const alignVerticalDistributeStart = IconData(0xe280, fontFamily: _f, fontPackage: _p);

  /// align-vertical-justify-center icon.
  static const alignVerticalJustifyCenter = IconData(0xe277, fontFamily: _f, fontPackage: _p);

  /// align-vertical-justify-end icon.
  static const alignVerticalJustifyEnd = IconData(0xe278, fontFamily: _f, fontPackage: _p);

  /// align-vertical-justify-start icon.
  static const alignVerticalJustifyStart = IconData(0xe279, fontFamily: _f, fontPackage: _p);

  /// align-vertical-space-around icon.
  static const alignVerticalSpaceAround = IconData(0xe27a, fontFamily: _f, fontPackage: _p);

  /// align-vertical-space-between icon.
  static const alignVerticalSpaceBetween = IconData(0xe27b, fontFamily: _f, fontPackage: _p);

  /// between-horizonal-end icon.
  static const betweenHorizonalEnd = IconData(0xe591, fontFamily: _f, fontPackage: _p);

  /// between-horizonal-start icon.
  static const betweenHorizonalStart = IconData(0xe592, fontFamily: _f, fontPackage: _p);

  /// between-horizontal-end icon.
  static const betweenHorizontalEnd = IconData(0xe591, fontFamily: _f, fontPackage: _p);

  /// between-horizontal-start icon.
  static const betweenHorizontalStart = IconData(0xe592, fontFamily: _f, fontPackage: _p);

  /// between-vertical-end icon.
  static const betweenVerticalEnd = IconData(0xe593, fontFamily: _f, fontPackage: _p);

  /// between-vertical-start icon.
  static const betweenVerticalStart = IconData(0xe594, fontFamily: _f, fontPackage: _p);

  /// chart-column icon.
  static const chartColumn = IconData(0xe2a3, fontFamily: _f, fontPackage: _p);

  /// chart-column-big icon.
  static const chartColumnBig = IconData(0xe4a9, fontFamily: _f, fontPackage: _p);

  /// chart-column-decreasing icon.
  static const chartColumnDecreasing = IconData(0xe067, fontFamily: _f, fontPackage: _p);

  /// chart-column-increasing icon.
  static const chartColumnIncreasing = IconData(0xe2a4, fontFamily: _f, fontPackage: _p);

  /// chart-column-stacked icon.
  static const chartColumnStacked = IconData(0xe60a, fontFamily: _f, fontPackage: _p);

  /// chart-no-axes-column icon.
  static const chartNoAxesColumn = IconData(0xe068, fontFamily: _f, fontPackage: _p);

  /// chart-no-axes-column-decreasing icon.
  static const chartNoAxesColumnDecreasing = IconData(0xe069, fontFamily: _f, fontPackage: _p);

  /// chart-no-axes-column-increasing icon.
  static const chartNoAxesColumnIncreasing = IconData(0xe06a, fontFamily: _f, fontPackage: _p);

  /// columns icon.
  static const columns = IconData(0xe098, fontFamily: _f, fontPackage: _p);

  /// columns-2 icon.
  static const columns2 = IconData(0xe098, fontFamily: _f, fontPackage: _p);

  /// columns-3 icon.
  static const columns3 = IconData(0xe099, fontFamily: _f, fontPackage: _p);

  /// columns-3-cog icon.
  static const columns3Cog = IconData(0xe661, fontFamily: _f, fontPackage: _p);

  /// columns-4 icon.
  static const columns4 = IconData(0xe589, fontFamily: _f, fontPackage: _p);

  /// columns-settings icon.
  static const columnsSettings = IconData(0xe661, fontFamily: _f, fontPackage: _p);

  /// crown icon.
  static const crown = IconData(0xe1d6, fontFamily: _f, fontPackage: _p);

  /// file-chart-column icon.
  static const fileChartColumn = IconData(0xe311, fontFamily: _f, fontPackage: _p);

  /// file-chart-column-increasing icon.
  static const fileChartColumnIncreasing = IconData(0xe312, fontFamily: _f, fontPackage: _p);

  /// folder-kanban icon.
  static const folderKanban = IconData(0xe4c6, fontFamily: _f, fontPackage: _p);

  /// frown icon.
  static const frown = IconData(0xe0db, fontFamily: _f, fontPackage: _p);

  /// grid icon.
  static const grid = IconData(0xe0e9, fontFamily: _f, fontPackage: _p);

  /// grid-2-x-2 icon.
  static const grid2X2 = IconData(0xe4ff, fontFamily: _f, fontPackage: _p);

  /// grid-2-x-2-check icon.
  static const grid2X2Check = IconData(0xe5e4, fontFamily: _f, fontPackage: _p);

  /// grid-2-x-2-plus icon.
  static const grid2X2Plus = IconData(0xe628, fontFamily: _f, fontPackage: _p);

  /// grid-2-x-2-x icon.
  static const grid2X2X = IconData(0xe5e5, fontFamily: _f, fontPackage: _p);

  /// grid-2x2 icon.
  static const grid2x2 = IconData(0xe4ff, fontFamily: _f, fontPackage: _p);

  /// grid-2x2-check icon.
  static const grid2x2Check = IconData(0xe5e4, fontFamily: _f, fontPackage: _p);

  /// grid-2x2-plus icon.
  static const grid2x2Plus = IconData(0xe628, fontFamily: _f, fontPackage: _p);

  /// grid-2x2-x icon.
  static const grid2x2X = IconData(0xe5e5, fontFamily: _f, fontPackage: _p);

  /// grid-3-x-3 icon.
  static const grid3X3 = IconData(0xe0e9, fontFamily: _f, fontPackage: _p);

  /// grid-3x2 icon.
  static const grid3x2 = IconData(0xe66f, fontFamily: _f, fontPackage: _p);

  /// grid-3x3 icon.
  static const grid3x3 = IconData(0xe0e9, fontFamily: _f, fontPackage: _p);

  /// group icon.
  static const group = IconData(0xe464, fontFamily: _f, fontPackage: _p);

  /// inspection-panel icon.
  static const inspectionPanel = IconData(0xe583, fontFamily: _f, fontPackage: _p);

  /// kanban icon.
  static const kanban = IconData(0xe4dc, fontFamily: _f, fontPackage: _p);

  /// kanban-square icon.
  static const kanbanSquare = IconData(0xe170, fontFamily: _f, fontPackage: _p);

  /// kanban-square-dashed icon.
  static const kanbanSquareDashed = IconData(0xe16c, fontFamily: _f, fontPackage: _p);

  /// layout icon.
  static const layout = IconData(0xe12c, fontFamily: _f, fontPackage: _p);

  /// layout-dashboard icon.
  static const layoutDashboard = IconData(0xe1c1, fontFamily: _f, fontPackage: _p);

  /// layout-grid icon.
  static const layoutGrid = IconData(0xe0ff, fontFamily: _f, fontPackage: _p);

  /// layout-list icon.
  static const layoutList = IconData(0xe1d9, fontFamily: _f, fontPackage: _p);

  /// layout-panel-left icon.
  static const layoutPanelLeft = IconData(0xe470, fontFamily: _f, fontPackage: _p);

  /// layout-panel-top icon.
  static const layoutPanelTop = IconData(0xe471, fontFamily: _f, fontPackage: _p);

  /// layout-template icon.
  static const layoutTemplate = IconData(0xe207, fontFamily: _f, fontPackage: _p);

  /// microwave icon.
  static const microwave = IconData(0xe37a, fontFamily: _f, fontPackage: _p);

  /// panel-bottom icon.
  static const panelBottom = IconData(0xe42c, fontFamily: _f, fontPackage: _p);

  /// panel-bottom-close icon.
  static const panelBottomClose = IconData(0xe42d, fontFamily: _f, fontPackage: _p);

  /// panel-bottom-dashed icon.
  static const panelBottomDashed = IconData(0xe42e, fontFamily: _f, fontPackage: _p);

  /// panel-bottom-inactive icon.
  static const panelBottomInactive = IconData(0xe42e, fontFamily: _f, fontPackage: _p);

  /// panel-bottom-open icon.
  static const panelBottomOpen = IconData(0xe42f, fontFamily: _f, fontPackage: _p);

  /// panel-left icon.
  static const panelLeft = IconData(0xe12a, fontFamily: _f, fontPackage: _p);

  /// panel-left-close icon.
  static const panelLeftClose = IconData(0xe21c, fontFamily: _f, fontPackage: _p);

  /// panel-left-dashed icon.
  static const panelLeftDashed = IconData(0xe430, fontFamily: _f, fontPackage: _p);

  /// panel-left-inactive icon.
  static const panelLeftInactive = IconData(0xe430, fontFamily: _f, fontPackage: _p);

  /// panel-left-open icon.
  static const panelLeftOpen = IconData(0xe21d, fontFamily: _f, fontPackage: _p);

  /// panel-left-right-dashed icon.
  static const panelLeftRightDashed = IconData(0xe692, fontFamily: _f, fontPackage: _p);

  /// panel-right icon.
  static const panelRight = IconData(0xe431, fontFamily: _f, fontPackage: _p);

  /// panel-right-close icon.
  static const panelRightClose = IconData(0xe432, fontFamily: _f, fontPackage: _p);

  /// panel-right-dashed icon.
  static const panelRightDashed = IconData(0xe433, fontFamily: _f, fontPackage: _p);

  /// panel-right-inactive icon.
  static const panelRightInactive = IconData(0xe433, fontFamily: _f, fontPackage: _p);

  /// panel-right-open icon.
  static const panelRightOpen = IconData(0xe434, fontFamily: _f, fontPackage: _p);

  /// panel-top icon.
  static const panelTop = IconData(0xe435, fontFamily: _f, fontPackage: _p);

  /// panel-top-bottom-dashed icon.
  static const panelTopBottomDashed = IconData(0xe693, fontFamily: _f, fontPackage: _p);

  /// panel-top-close icon.
  static const panelTopClose = IconData(0xe436, fontFamily: _f, fontPackage: _p);

  /// panel-top-dashed icon.
  static const panelTopDashed = IconData(0xe437, fontFamily: _f, fontPackage: _p);

  /// panel-top-inactive icon.
  static const panelTopInactive = IconData(0xe437, fontFamily: _f, fontPackage: _p);

  /// panel-top-open icon.
  static const panelTopOpen = IconData(0xe438, fontFamily: _f, fontPackage: _p);

  /// panels-left-bottom icon.
  static const panelsLeftBottom = IconData(0xe12b, fontFamily: _f, fontPackage: _p);

  /// panels-left-right icon.
  static const panelsLeftRight = IconData(0xe099, fontFamily: _f, fontPackage: _p);

  /// panels-right-bottom icon.
  static const panelsRightBottom = IconData(0xe588, fontFamily: _f, fontPackage: _p);

  /// panels-top-bottom icon.
  static const panelsTopBottom = IconData(0xe58a, fontFamily: _f, fontPackage: _p);

  /// panels-top-left icon.
  static const panelsTopLeft = IconData(0xe12c, fontFamily: _f, fontPackage: _p);

  /// pilcrow icon.
  static const pilcrow = IconData(0xe3a3, fontFamily: _f, fontPackage: _p);

  /// pilcrow-left icon.
  static const pilcrowLeft = IconData(0xe5dc, fontFamily: _f, fontPackage: _p);

  /// pilcrow-right icon.
  static const pilcrowRight = IconData(0xe5dd, fontFamily: _f, fontPackage: _p);

  /// pilcrow-square icon.
  static const pilcrowSquare = IconData(0xe48b, fontFamily: _f, fontPackage: _p);

  /// rows icon.
  static const rows = IconData(0xe439, fontFamily: _f, fontPackage: _p);

  /// rows-2 icon.
  static const rows2 = IconData(0xe439, fontFamily: _f, fontPackage: _p);

  /// rows-3 icon.
  static const rows3 = IconData(0xe58a, fontFamily: _f, fontPackage: _p);

  /// rows-4 icon.
  static const rows4 = IconData(0xe58b, fontFamily: _f, fontPackage: _p);

  /// section icon.
  static const section = IconData(0xe5e8, fontFamily: _f, fontPackage: _p);

  /// separator-horizontal icon.
  static const separatorHorizontal = IconData(0xe1c8, fontFamily: _f, fontPackage: _p);

  /// separator-vertical icon.
  static const separatorVertical = IconData(0xe1c9, fontFamily: _f, fontPackage: _p);

  /// sidebar icon.
  static const sidebar = IconData(0xe12a, fontFamily: _f, fontPackage: _p);

  /// sidebar-close icon.
  static const sidebarClose = IconData(0xe21c, fontFamily: _f, fontPackage: _p);

  /// sidebar-open icon.
  static const sidebarOpen = IconData(0xe21d, fontFamily: _f, fontPackage: _p);

  /// solar-panel icon.
  static const solarPanel = IconData(0xe69f, fontFamily: _f, fontPackage: _p);

  /// space icon.
  static const space = IconData(0xe3dd, fontFamily: _f, fontPackage: _p);

  /// split icon.
  static const split = IconData(0xe440, fontFamily: _f, fontPackage: _p);

  /// split-square-horizontal icon.
  static const splitSquareHorizontal = IconData(0xe3b6, fontFamily: _f, fontPackage: _p);

  /// split-square-vertical icon.
  static const splitSquareVertical = IconData(0xe3b7, fontFamily: _f, fontPackage: _p);

  /// square-dashed-kanban icon.
  static const squareDashedKanban = IconData(0xe16c, fontFamily: _f, fontPackage: _p);

  /// square-kanban icon.
  static const squareKanban = IconData(0xe170, fontFamily: _f, fontPackage: _p);

  /// square-pilcrow icon.
  static const squarePilcrow = IconData(0xe48b, fontFamily: _f, fontPackage: _p);

  /// square-split-horizontal icon.
  static const squareSplitHorizontal = IconData(0xe3b6, fontFamily: _f, fontPackage: _p);

  /// square-split-vertical icon.
  static const squareSplitVertical = IconData(0xe3b7, fontFamily: _f, fontPackage: _p);

  /// table-cells-split icon.
  static const tableCellsSplit = IconData(0xe5c8, fontFamily: _f, fontPackage: _p);

  /// table-columns-split icon.
  static const tableColumnsSplit = IconData(0xe5c9, fontFamily: _f, fontPackage: _p);

  /// table-rows-split icon.
  static const tableRowsSplit = IconData(0xe5ca, fontFamily: _f, fontPackage: _p);

  /// text-align-center icon.
  static const textAlignCenter = IconData(0xe182, fontFamily: _f, fontPackage: _p);

  /// text-align-end icon.
  static const textAlignEnd = IconData(0xe183, fontFamily: _f, fontPackage: _p);

  /// text-align-justify icon.
  static const textAlignJustify = IconData(0xe184, fontFamily: _f, fontPackage: _p);

  /// text-align-start icon.
  static const textAlignStart = IconData(0xe185, fontFamily: _f, fontPackage: _p);

  /// text-wrap icon.
  static const textWrap = IconData(0xe248, fontFamily: _f, fontPackage: _p);

  /// ungroup icon.
  static const ungroup = IconData(0xe467, fontFamily: _f, fontPackage: _p);

  /// wrap-text icon.
  static const wrapText = IconData(0xe248, fontFamily: _f, fontPackage: _p);


  // ── Text & Typography ─────────────────────────────────────────────

  /// a-large-small icon.
  static const aLargeSmall = IconData(0xe587, fontFamily: _f, fontPackage: _p);

  /// baseline icon.
  static const baseline = IconData(0xe285, fontFamily: _f, fontPackage: _p);

  /// bold icon.
  static const bold = IconData(0xe05d, fontFamily: _f, fontPackage: _p);

  /// book-open-text icon.
  static const bookOpenText = IconData(0xe54a, fontFamily: _f, fontPackage: _p);

  /// book-text icon.
  static const bookText = IconData(0xe54b, fontFamily: _f, fontPackage: _p);

  /// book-type icon.
  static const bookType = IconData(0xe54c, fontFamily: _f, fontPackage: _p);

  /// briefcase icon.
  static const briefcase = IconData(0xe062, fontFamily: _f, fontPackage: _p);

  /// briefcase-business icon.
  static const briefcaseBusiness = IconData(0xe5d5, fontFamily: _f, fontPackage: _p);

  /// briefcase-conveyor-belt icon.
  static const briefcaseConveyorBelt = IconData(0xe62b, fontFamily: _f, fontPackage: _p);

  /// briefcase-medical icon.
  static const briefcaseMedical = IconData(0xe5d6, fontFamily: _f, fontPackage: _p);

  /// captions icon.
  static const captions = IconData(0xe3a4, fontFamily: _f, fontPackage: _p);

  /// captions-off icon.
  static const captionsOff = IconData(0xe5c1, fontFamily: _f, fontPackage: _p);

  /// case-lower icon.
  static const caseLower = IconData(0xe3d8, fontFamily: _f, fontPackage: _p);

  /// case-sensitive icon.
  static const caseSensitive = IconData(0xe3d9, fontFamily: _f, fontPackage: _p);

  /// case-upper icon.
  static const caseUpper = IconData(0xe3da, fontFamily: _f, fontPackage: _p);

  /// clipboard-list icon.
  static const clipboardList = IconData(0xe086, fontFamily: _f, fontPackage: _p);

  /// clipboard-type icon.
  static const clipboardType = IconData(0xe309, fontFamily: _f, fontPackage: _p);

  /// file-text icon.
  static const fileText = IconData(0xe0cc, fontFamily: _f, fontPackage: _p);

  /// file-type icon.
  static const fileType = IconData(0xe329, fontFamily: _f, fontPackage: _p);

  /// file-type-2 icon.
  static const fileType2 = IconData(0xe36d, fontFamily: _f, fontPackage: _p);

  /// heading icon.
  static const heading = IconData(0xe384, fontFamily: _f, fontPackage: _p);

  /// heading-1 icon.
  static const heading1 = IconData(0xe385, fontFamily: _f, fontPackage: _p);

  /// heading-2 icon.
  static const heading2 = IconData(0xe386, fontFamily: _f, fontPackage: _p);

  /// heading-3 icon.
  static const heading3 = IconData(0xe387, fontFamily: _f, fontPackage: _p);

  /// heading-4 icon.
  static const heading4 = IconData(0xe388, fontFamily: _f, fontPackage: _p);

  /// heading-5 icon.
  static const heading5 = IconData(0xe389, fontFamily: _f, fontPackage: _p);

  /// heading-6 icon.
  static const heading6 = IconData(0xe38a, fontFamily: _f, fontPackage: _p);

  /// indent icon.
  static const indent = IconData(0xe108, fontFamily: _f, fontPackage: _p);

  /// indent-decrease icon.
  static const indentDecrease = IconData(0xe107, fontFamily: _f, fontPackage: _p);

  /// indent-increase icon.
  static const indentIncrease = IconData(0xe108, fontFamily: _f, fontPackage: _p);

  /// italic icon.
  static const italic = IconData(0xe0fb, fontFamily: _f, fontPackage: _p);

  /// letter-text icon.
  static const letterText = IconData(0xe605, fontFamily: _f, fontPackage: _p);

  /// ligature icon.
  static const ligature = IconData(0xe43a, fontFamily: _f, fontPackage: _p);

  /// list icon.
  static const list = IconData(0xe106, fontFamily: _f, fontPackage: _p);

  /// list-check icon.
  static const listCheck = IconData(0xe5fa, fontFamily: _f, fontPackage: _p);

  /// list-checks icon.
  static const listChecks = IconData(0xe1d0, fontFamily: _f, fontPackage: _p);

  /// list-collapse icon.
  static const listCollapse = IconData(0xe59b, fontFamily: _f, fontPackage: _p);

  /// list-end icon.
  static const listEnd = IconData(0xe2df, fontFamily: _f, fontPackage: _p);

  /// list-filter icon.
  static const listFilter = IconData(0xe460, fontFamily: _f, fontPackage: _p);

  /// list-filter-plus icon.
  static const listFilterPlus = IconData(0xe639, fontFamily: _f, fontPackage: _p);

  /// list-indent-decrease icon.
  static const listIndentDecrease = IconData(0xe107, fontFamily: _f, fontPackage: _p);

  /// list-indent-increase icon.
  static const listIndentIncrease = IconData(0xe108, fontFamily: _f, fontPackage: _p);

  /// list-minus icon.
  static const listMinus = IconData(0xe23e, fontFamily: _f, fontPackage: _p);

  /// list-music icon.
  static const listMusic = IconData(0xe2e0, fontFamily: _f, fontPackage: _p);

  /// list-ordered icon.
  static const listOrdered = IconData(0xe1d1, fontFamily: _f, fontPackage: _p);

  /// list-plus icon.
  static const listPlus = IconData(0xe23f, fontFamily: _f, fontPackage: _p);

  /// list-restart icon.
  static const listRestart = IconData(0xe452, fontFamily: _f, fontPackage: _p);

  /// list-start icon.
  static const listStart = IconData(0xe2e1, fontFamily: _f, fontPackage: _p);

  /// list-todo icon.
  static const listTodo = IconData(0xe4c3, fontFamily: _f, fontPackage: _p);

  /// list-tree icon.
  static const listTree = IconData(0xe408, fontFamily: _f, fontPackage: _p);

  /// list-video icon.
  static const listVideo = IconData(0xe2e2, fontFamily: _f, fontPackage: _p);

  /// list-x icon.
  static const listX = IconData(0xe240, fontFamily: _f, fontPackage: _p);

  /// message-square-quote icon.
  static const messageSquareQuote = IconData(0xe572, fontFamily: _f, fontPackage: _p);

  /// message-square-text icon.
  static const messageSquareText = IconData(0xe575, fontFamily: _f, fontPackage: _p);

  /// notebook-text icon.
  static const notebookText = IconData(0xe598, fontFamily: _f, fontPackage: _p);

  /// notepad-text icon.
  static const notepadText = IconData(0xe599, fontFamily: _f, fontPackage: _p);

  /// notepad-text-dashed icon.
  static const notepadTextDashed = IconData(0xe59a, fontFamily: _f, fontPackage: _p);

  /// pc-case icon.
  static const pcCase = IconData(0xe446, fontFamily: _f, fontPackage: _p);

  /// quote icon.
  static const quote = IconData(0xe239, fontFamily: _f, fontPackage: _p);

  /// receipt-text icon.
  static const receiptText = IconData(0xe5ac, fontFamily: _f, fontPackage: _p);

  /// regex icon.
  static const regex = IconData(0xe1fc, fontFamily: _f, fontPackage: _p);

  /// scan-text icon.
  static const scanText = IconData(0xe538, fontFamily: _f, fontPackage: _p);

  /// scroll-text icon.
  static const scrollText = IconData(0xe45f, fontFamily: _f, fontPackage: _p);

  /// spell-check icon.
  static const spellCheck = IconData(0xe49a, fontFamily: _f, fontPackage: _p);

  /// spell-check-2 icon.
  static const spellCheck2 = IconData(0xe49b, fontFamily: _f, fontPackage: _p);

  /// strikethrough icon.
  static const strikethrough = IconData(0xe177, fontFamily: _f, fontPackage: _p);

  /// subscript icon.
  static const subscript = IconData(0xe25c, fontFamily: _f, fontPackage: _p);

  /// subtitles icon.
  static const subtitles = IconData(0xe3a4, fontFamily: _f, fontPackage: _p);

  /// superscript icon.
  static const superscript = IconData(0xe25e, fontFamily: _f, fontPackage: _p);

  /// text icon.
  static const text = IconData(0xe185, fontFamily: _f, fontPackage: _p);

  /// text-cursor icon.
  static const textCursor = IconData(0xe264, fontFamily: _f, fontPackage: _p);

  /// text-cursor-input icon.
  static const textCursorInput = IconData(0xe265, fontFamily: _f, fontPackage: _p);

  /// text-initial icon.
  static const textInitial = IconData(0xe605, fontFamily: _f, fontPackage: _p);

  /// text-quote icon.
  static const textQuote = IconData(0xe49e, fontFamily: _f, fontPackage: _p);

  /// text-search icon.
  static const textSearch = IconData(0xe5ad, fontFamily: _f, fontPackage: _p);

  /// text-select icon.
  static const textSelect = IconData(0xe3de, fontFamily: _f, fontPackage: _p);

  /// text-selection icon.
  static const textSelection = IconData(0xe3de, fontFamily: _f, fontPackage: _p);

  /// tool-case icon.
  static const toolCase = IconData(0xe67d, fontFamily: _f, fontPackage: _p);

  /// type icon.
  static const typeIcon = IconData(0xe198, fontFamily: _f, fontPackage: _p);

  /// type-outline icon.
  static const typeOutline = IconData(0xe602, fontFamily: _f, fontPackage: _p);

  /// underline icon.
  static const underline = IconData(0xe19a, fontFamily: _f, fontPackage: _p);

  /// whole-word icon.
  static const wholeWord = IconData(0xe3df, fontFamily: _f, fontPackage: _p);


  // ── Shapes ────────────────────────────────────────────────────────

  /// activity-square icon.
  static const activitySquare = IconData(0xe4b4, fontFamily: _f, fontPackage: _p);

  /// alert-circle icon.
  static const alertCircle = IconData(0xe077, fontFamily: _f, fontPackage: _p);

  /// alert-octagon icon.
  static const alertOctagon = IconData(0xe127, fontFamily: _f, fontPackage: _p);

  /// alert-triangle icon.
  static const alertTriangle = IconData(0xe193, fontFamily: _f, fontPackage: _p);

  /// asterisk-square icon.
  static const asteriskSquare = IconData(0xe168, fontFamily: _f, fontPackage: _p);

  /// book-heart icon.
  static const bookHeart = IconData(0xe548, fontFamily: _f, fontPackage: _p);

  /// bot-message-square icon.
  static const botMessageSquare = IconData(0xe5ce, fontFamily: _f, fontPackage: _p);

  /// calendar-heart icon.
  static const calendarHeart = IconData(0xe305, fontFamily: _f, fontPackage: _p);

  /// check-circle icon.
  static const checkCircle = IconData(0xe07c, fontFamily: _f, fontPackage: _p);

  /// check-circle-2 icon.
  static const checkCircle2 = IconData(0xe226, fontFamily: _f, fontPackage: _p);

  /// check-square icon.
  static const checkSquare = IconData(0xe16a, fontFamily: _f, fontPackage: _p);

  /// check-square-2 icon.
  static const checkSquare2 = IconData(0xe559, fontFamily: _f, fontPackage: _p);

  /// circle icon.
  static const circle = IconData(0xe076, fontFamily: _f, fontPackage: _p);

  /// circle-alert icon.
  static const circleAlert = IconData(0xe077, fontFamily: _f, fontPackage: _p);

  /// circle-check icon.
  static const circleCheck = IconData(0xe226, fontFamily: _f, fontPackage: _p);

  /// circle-check-big icon.
  static const circleCheckBig = IconData(0xe07c, fontFamily: _f, fontPackage: _p);

  /// circle-dashed icon.
  static const circleDashed = IconData(0xe4b0, fontFamily: _f, fontPackage: _p);

  /// circle-divide icon.
  static const circleDivide = IconData(0xe07d, fontFamily: _f, fontPackage: _p);

  /// circle-dollar-sign icon.
  static const circleDollarSign = IconData(0xe47d, fontFamily: _f, fontPackage: _p);

  /// circle-dot icon.
  static const circleDot = IconData(0xe345, fontFamily: _f, fontPackage: _p);

  /// circle-dot-dashed icon.
  static const circleDotDashed = IconData(0xe4b1, fontFamily: _f, fontPackage: _p);

  /// circle-ellipsis icon.
  static const circleEllipsis = IconData(0xe346, fontFamily: _f, fontPackage: _p);

  /// circle-equal icon.
  static const circleEqual = IconData(0xe400, fontFamily: _f, fontPackage: _p);

  /// circle-fading-plus icon.
  static const circleFadingPlus = IconData(0xe5bc, fontFamily: _f, fontPackage: _p);

  /// circle-gauge icon.
  static const circleGauge = IconData(0xe4e1, fontFamily: _f, fontPackage: _p);

  /// circle-help icon.
  static const circleHelp = IconData(0xe082, fontFamily: _f, fontPackage: _p);

  /// circle-minus icon.
  static const circleMinus = IconData(0xe07e, fontFamily: _f, fontPackage: _p);

  /// circle-off icon.
  static const circleOff = IconData(0xe401, fontFamily: _f, fontPackage: _p);

  /// circle-parking icon.
  static const circleParking = IconData(0xe3c9, fontFamily: _f, fontPackage: _p);

  /// circle-parking-off icon.
  static const circleParkingOff = IconData(0xe3ca, fontFamily: _f, fontPackage: _p);

  /// circle-pause icon.
  static const circlePause = IconData(0xe07f, fontFamily: _f, fontPackage: _p);

  /// circle-percent icon.
  static const circlePercent = IconData(0xe51a, fontFamily: _f, fontPackage: _p);

  /// circle-pile icon.
  static const circlePile = IconData(0xe6af, fontFamily: _f, fontPackage: _p);

  /// circle-play icon.
  static const circlePlay = IconData(0xe080, fontFamily: _f, fontPackage: _p);

  /// circle-plus icon.
  static const circlePlus = IconData(0xe081, fontFamily: _f, fontPackage: _p);

  /// circle-pound-sterling icon.
  static const circlePoundSterling = IconData(0xe66d, fontFamily: _f, fontPackage: _p);

  /// circle-power icon.
  static const circlePower = IconData(0xe550, fontFamily: _f, fontPackage: _p);

  /// circle-question-mark icon.
  static const circleQuestionMark = IconData(0xe082, fontFamily: _f, fontPackage: _p);

  /// circle-slash icon.
  static const circleSlash = IconData(0xe402, fontFamily: _f, fontPackage: _p);

  /// circle-slash-2 icon.
  static const circleSlash2 = IconData(0xe213, fontFamily: _f, fontPackage: _p);

  /// circle-slashed icon.
  static const circleSlashed = IconData(0xe213, fontFamily: _f, fontPackage: _p);

  /// circle-small icon.
  static const circleSmall = IconData(0xe640, fontFamily: _f, fontPackage: _p);

  /// circle-star icon.
  static const circleStar = IconData(0xe68d, fontFamily: _f, fontPackage: _p);

  /// circle-stop icon.
  static const circleStop = IconData(0xe083, fontFamily: _f, fontPackage: _p);

  /// circle-user icon.
  static const circleUser = IconData(0xe461, fontFamily: _f, fontPackage: _p);

  /// circle-user-round icon.
  static const circleUserRound = IconData(0xe462, fontFamily: _f, fontPackage: _p);

  /// circle-x icon.
  static const circleX = IconData(0xe084, fontFamily: _f, fontPackage: _p);

  /// code-square icon.
  static const codeSquare = IconData(0xe16b, fontFamily: _f, fontPackage: _p);

  /// diamond icon.
  static const diamond = IconData(0xe2d2, fontFamily: _f, fontPackage: _p);

  /// diamond-minus icon.
  static const diamondMinus = IconData(0xe5e1, fontFamily: _f, fontPackage: _p);

  /// diamond-percent icon.
  static const diamondPercent = IconData(0xe51b, fontFamily: _f, fontPackage: _p);

  /// diamond-plus icon.
  static const diamondPlus = IconData(0xe5e2, fontFamily: _f, fontPackage: _p);

  /// divide-circle icon.
  static const divideCircle = IconData(0xe07d, fontFamily: _f, fontPackage: _p);

  /// divide-square icon.
  static const divideSquare = IconData(0xe16d, fontFamily: _f, fontPackage: _p);

  /// dot-square icon.
  static const dotSquare = IconData(0xe16e, fontFamily: _f, fontPackage: _p);

  /// equal-square icon.
  static const equalSquare = IconData(0xe16f, fontFamily: _f, fontPackage: _p);

  /// file-heart icon.
  static const fileHeart = IconData(0xe31b, fontFamily: _f, fontPackage: _p);

  /// flag-triangle-left icon.
  static const flagTriangleLeft = IconData(0xe237, fontFamily: _f, fontPackage: _p);

  /// flag-triangle-right icon.
  static const flagTriangleRight = IconData(0xe238, fontFamily: _f, fontPackage: _p);

  /// folder-heart icon.
  static const folderHeart = IconData(0xe333, fontFamily: _f, fontPackage: _p);

  /// function-square icon.
  static const functionSquare = IconData(0xe22d, fontFamily: _f, fontPackage: _p);

  /// gantt-chart-square icon.
  static const ganttChartSquare = IconData(0xe624, fontFamily: _f, fontPackage: _p);

  /// gauge-circle icon.
  static const gaugeCircle = IconData(0xe4e1, fontFamily: _f, fontPackage: _p);

  /// hand-heart icon.
  static const handHeart = IconData(0xe5b9, fontFamily: _f, fontPackage: _p);

  /// heart icon.
  static const heart = IconData(0xe0f2, fontFamily: _f, fontPackage: _p);

  /// heart-crack icon.
  static const heartCrack = IconData(0xe2d6, fontFamily: _f, fontPackage: _p);

  /// heart-handshake icon.
  static const heartHandshake = IconData(0xe2d7, fontFamily: _f, fontPackage: _p);

  /// heart-minus icon.
  static const heartMinus = IconData(0xe651, fontFamily: _f, fontPackage: _p);

  /// heart-off icon.
  static const heartOff = IconData(0xe295, fontFamily: _f, fontPackage: _p);

  /// heart-plus icon.
  static const heartPlus = IconData(0xe652, fontFamily: _f, fontPackage: _p);

  /// heart-pulse icon.
  static const heartPulse = IconData(0xe36e, fontFamily: _f, fontPackage: _p);

  /// help-circle icon.
  static const helpCircle = IconData(0xe082, fontFamily: _f, fontPackage: _p);

  /// hexagon icon.
  static const hexagon = IconData(0xe0f3, fontFamily: _f, fontPackage: _p);

  /// house-heart icon.
  static const houseHeart = IconData(0xe695, fontFamily: _f, fontPackage: _p);

  /// key-square icon.
  static const keySquare = IconData(0xe4a4, fontFamily: _f, fontPackage: _p);

  /// library-square icon.
  static const librarySquare = IconData(0xe54f, fontFamily: _f, fontPackage: _p);

  /// loader-circle icon.
  static const loaderCircle = IconData(0xe10a, fontFamily: _f, fontPackage: _p);

  /// m-square icon.
  static const mSquare = IconData(0xe503, fontFamily: _f, fontPackage: _p);

  /// menu-square icon.
  static const menuSquare = IconData(0xe453, fontFamily: _f, fontPackage: _p);

  /// message-circle icon.
  static const messageCircle = IconData(0xe116, fontFamily: _f, fontPackage: _p);

  /// message-circle-check icon.
  static const messageCircleCheck = IconData(0xe6ba, fontFamily: _f, fontPackage: _p);

  /// message-circle-code icon.
  static const messageCircleCode = IconData(0xe562, fontFamily: _f, fontPackage: _p);

  /// message-circle-dashed icon.
  static const messageCircleDashed = IconData(0xe563, fontFamily: _f, fontPackage: _p);

  /// message-circle-heart icon.
  static const messageCircleHeart = IconData(0xe564, fontFamily: _f, fontPackage: _p);

  /// message-circle-more icon.
  static const messageCircleMore = IconData(0xe565, fontFamily: _f, fontPackage: _p);

  /// message-circle-off icon.
  static const messageCircleOff = IconData(0xe566, fontFamily: _f, fontPackage: _p);

  /// message-circle-plus icon.
  static const messageCirclePlus = IconData(0xe567, fontFamily: _f, fontPackage: _p);

  /// message-circle-question icon.
  static const messageCircleQuestion = IconData(0xe568, fontFamily: _f, fontPackage: _p);

  /// message-circle-question-mark icon.
  static const messageCircleQuestionMark = IconData(0xe568, fontFamily: _f, fontPackage: _p);

  /// message-circle-reply icon.
  static const messageCircleReply = IconData(0xe569, fontFamily: _f, fontPackage: _p);

  /// message-circle-warning icon.
  static const messageCircleWarning = IconData(0xe56a, fontFamily: _f, fontPackage: _p);

  /// message-circle-x icon.
  static const messageCircleX = IconData(0xe56b, fontFamily: _f, fontPackage: _p);

  /// message-square icon.
  static const messageSquare = IconData(0xe117, fontFamily: _f, fontPackage: _p);

  /// message-square-check icon.
  static const messageSquareCheck = IconData(0xe6bb, fontFamily: _f, fontPackage: _p);

  /// message-square-code icon.
  static const messageSquareCode = IconData(0xe56c, fontFamily: _f, fontPackage: _p);

  /// message-square-dashed icon.
  static const messageSquareDashed = IconData(0xe40b, fontFamily: _f, fontPackage: _p);

  /// message-square-diff icon.
  static const messageSquareDiff = IconData(0xe56d, fontFamily: _f, fontPackage: _p);

  /// message-square-dot icon.
  static const messageSquareDot = IconData(0xe56e, fontFamily: _f, fontPackage: _p);

  /// message-square-heart icon.
  static const messageSquareHeart = IconData(0xe56f, fontFamily: _f, fontPackage: _p);

  /// message-square-lock icon.
  static const messageSquareLock = IconData(0xe62c, fontFamily: _f, fontPackage: _p);

  /// message-square-more icon.
  static const messageSquareMore = IconData(0xe570, fontFamily: _f, fontPackage: _p);

  /// message-square-off icon.
  static const messageSquareOff = IconData(0xe571, fontFamily: _f, fontPackage: _p);

  /// message-square-plus icon.
  static const messageSquarePlus = IconData(0xe40c, fontFamily: _f, fontPackage: _p);

  /// message-square-reply icon.
  static const messageSquareReply = IconData(0xe573, fontFamily: _f, fontPackage: _p);

  /// message-square-share icon.
  static const messageSquareShare = IconData(0xe574, fontFamily: _f, fontPackage: _p);

  /// message-square-warning icon.
  static const messageSquareWarning = IconData(0xe576, fontFamily: _f, fontPackage: _p);

  /// message-square-x icon.
  static const messageSquareX = IconData(0xe577, fontFamily: _f, fontPackage: _p);

  /// messages-square icon.
  static const messagesSquare = IconData(0xe40d, fontFamily: _f, fontPackage: _p);

  /// minus-circle icon.
  static const minusCircle = IconData(0xe07e, fontFamily: _f, fontPackage: _p);

  /// minus-square icon.
  static const minusSquare = IconData(0xe171, fontFamily: _f, fontPackage: _p);

  /// moon-star icon.
  static const moonStar = IconData(0xe410, fontFamily: _f, fontPackage: _p);

  /// mouse-pointer-square-dashed icon.
  static const mousePointerSquareDashed = IconData(0xe509, fontFamily: _f, fontPackage: _p);

  /// octagon icon.
  static const octagon = IconData(0xe126, fontFamily: _f, fontPackage: _p);

  /// octagon-alert icon.
  static const octagonAlert = IconData(0xe127, fontFamily: _f, fontPackage: _p);

  /// octagon-minus icon.
  static const octagonMinus = IconData(0xe627, fontFamily: _f, fontPackage: _p);

  /// octagon-pause icon.
  static const octagonPause = IconData(0xe21b, fontFamily: _f, fontPackage: _p);

  /// octagon-x icon.
  static const octagonX = IconData(0xe128, fontFamily: _f, fontPackage: _p);

  /// parking-circle icon.
  static const parkingCircle = IconData(0xe3c9, fontFamily: _f, fontPackage: _p);

  /// parking-circle-off icon.
  static const parkingCircleOff = IconData(0xe3ca, fontFamily: _f, fontPackage: _p);

  /// parking-square icon.
  static const parkingSquare = IconData(0xe3cb, fontFamily: _f, fontPackage: _p);

  /// parking-square-off icon.
  static const parkingSquareOff = IconData(0xe3cc, fontFamily: _f, fontPackage: _p);

  /// pause-circle icon.
  static const pauseCircle = IconData(0xe07f, fontFamily: _f, fontPackage: _p);

  /// pause-octagon icon.
  static const pauseOctagon = IconData(0xe21b, fontFamily: _f, fontPackage: _p);

  /// pen-square icon.
  static const penSquare = IconData(0xe172, fontFamily: _f, fontPackage: _p);

  /// pentagon icon.
  static const pentagon = IconData(0xe52b, fontFamily: _f, fontPackage: _p);

  /// percent-circle icon.
  static const percentCircle = IconData(0xe51a, fontFamily: _f, fontPackage: _p);

  /// percent-diamond icon.
  static const percentDiamond = IconData(0xe51b, fontFamily: _f, fontPackage: _p);

  /// percent-square icon.
  static const percentSquare = IconData(0xe51c, fontFamily: _f, fontPackage: _p);

  /// pi-square icon.
  static const piSquare = IconData(0xe488, fontFamily: _f, fontPackage: _p);

  /// play-circle icon.
  static const playCircle = IconData(0xe080, fontFamily: _f, fontPackage: _p);

  /// play-square icon.
  static const playSquare = IconData(0xe481, fontFamily: _f, fontPackage: _p);

  /// plus-circle icon.
  static const plusCircle = IconData(0xe081, fontFamily: _f, fontPackage: _p);

  /// plus-square icon.
  static const plusSquare = IconData(0xe173, fontFamily: _f, fontPackage: _p);

  /// power-circle icon.
  static const powerCircle = IconData(0xe550, fontFamily: _f, fontPackage: _p);

  /// power-square icon.
  static const powerSquare = IconData(0xe551, fontFamily: _f, fontPackage: _p);

  /// rectangle-circle icon.
  static const rectangleCircle = IconData(0xe673, fontFamily: _f, fontPackage: _p);

  /// rotate-ccw-square icon.
  static const rotateCcwSquare = IconData(0xe5d0, fontFamily: _f, fontPackage: _p);

  /// rotate-cw-square icon.
  static const rotateCwSquare = IconData(0xe5d1, fontFamily: _f, fontPackage: _p);

  /// scan-heart icon.
  static const scanHeart = IconData(0xe63a, fontFamily: _f, fontPackage: _p);

  /// scissors-square icon.
  static const scissorsSquare = IconData(0xe4ec, fontFamily: _f, fontPackage: _p);

  /// scissors-square-dashed-bottom icon.
  static const scissorsSquareDashedBottom = IconData(0xe4eb, fontFamily: _f, fontPackage: _p);

  /// shapes icon.
  static const shapes = IconData(0xe4b3, fontFamily: _f, fontPackage: _p);

  /// sigma-square icon.
  static const sigmaSquare = IconData(0xe489, fontFamily: _f, fontPackage: _p);

  /// slash-square icon.
  static const slashSquare = IconData(0xe174, fontFamily: _f, fontPackage: _p);

  /// square icon.
  static const square = IconData(0xe167, fontFamily: _f, fontPackage: _p);

  /// square-activity icon.
  static const squareActivity = IconData(0xe4b4, fontFamily: _f, fontPackage: _p);

  /// square-asterisk icon.
  static const squareAsterisk = IconData(0xe168, fontFamily: _f, fontPackage: _p);

  /// square-bottom-dashed-scissors icon.
  static const squareBottomDashedScissors = IconData(0xe4eb, fontFamily: _f, fontPackage: _p);

  /// square-centerline-dashed-horizontal icon.
  static const squareCenterlineDashedHorizontal = IconData(0xe6c5, fontFamily: _f, fontPackage: _p);

  /// square-centerline-dashed-vertical icon.
  static const squareCenterlineDashedVertical = IconData(0xe6c6, fontFamily: _f, fontPackage: _p);

  /// square-chart-gantt icon.
  static const squareChartGantt = IconData(0xe169, fontFamily: _f, fontPackage: _p);

  /// square-check icon.
  static const squareCheck = IconData(0xe559, fontFamily: _f, fontPackage: _p);

  /// square-check-big icon.
  static const squareCheckBig = IconData(0xe16a, fontFamily: _f, fontPackage: _p);

  /// square-code icon.
  static const squareCode = IconData(0xe16b, fontFamily: _f, fontPackage: _p);

  /// square-dashed icon.
  static const squareDashed = IconData(0xe1cb, fontFamily: _f, fontPackage: _p);

  /// square-dashed-bottom icon.
  static const squareDashedBottom = IconData(0xe4c0, fontFamily: _f, fontPackage: _p);

  /// square-dashed-bottom-code icon.
  static const squareDashedBottomCode = IconData(0xe4c1, fontFamily: _f, fontPackage: _p);

  /// square-dashed-mouse-pointer icon.
  static const squareDashedMousePointer = IconData(0xe509, fontFamily: _f, fontPackage: _p);

  /// square-dashed-top-solid icon.
  static const squareDashedTopSolid = IconData(0xe66c, fontFamily: _f, fontPackage: _p);

  /// square-divide icon.
  static const squareDivide = IconData(0xe16d, fontFamily: _f, fontPackage: _p);

  /// square-dot icon.
  static const squareDot = IconData(0xe16e, fontFamily: _f, fontPackage: _p);

  /// square-equal icon.
  static const squareEqual = IconData(0xe16f, fontFamily: _f, fontPackage: _p);

  /// square-function icon.
  static const squareFunction = IconData(0xe22d, fontFamily: _f, fontPackage: _p);

  /// square-gantt-chart icon.
  static const squareGanttChart = IconData(0xe169, fontFamily: _f, fontPackage: _p);

  /// square-library icon.
  static const squareLibrary = IconData(0xe54f, fontFamily: _f, fontPackage: _p);

  /// square-m icon.
  static const squareM = IconData(0xe503, fontFamily: _f, fontPackage: _p);

  /// square-menu icon.
  static const squareMenu = IconData(0xe453, fontFamily: _f, fontPackage: _p);

  /// square-minus icon.
  static const squareMinus = IconData(0xe171, fontFamily: _f, fontPackage: _p);

  /// square-mouse-pointer icon.
  static const squareMousePointer = IconData(0xe202, fontFamily: _f, fontPackage: _p);

  /// square-parking icon.
  static const squareParking = IconData(0xe3cb, fontFamily: _f, fontPackage: _p);

  /// square-parking-off icon.
  static const squareParkingOff = IconData(0xe3cc, fontFamily: _f, fontPackage: _p);

  /// square-pause icon.
  static const squarePause = IconData(0xe684, fontFamily: _f, fontPackage: _p);

  /// square-pen icon.
  static const squarePen = IconData(0xe172, fontFamily: _f, fontPackage: _p);

  /// square-percent icon.
  static const squarePercent = IconData(0xe51c, fontFamily: _f, fontPackage: _p);

  /// square-pi icon.
  static const squarePi = IconData(0xe488, fontFamily: _f, fontPackage: _p);

  /// square-play icon.
  static const squarePlay = IconData(0xe481, fontFamily: _f, fontPackage: _p);

  /// square-plus icon.
  static const squarePlus = IconData(0xe173, fontFamily: _f, fontPackage: _p);

  /// square-power icon.
  static const squarePower = IconData(0xe551, fontFamily: _f, fontPackage: _p);

  /// square-radical icon.
  static const squareRadical = IconData(0xe5c3, fontFamily: _f, fontPackage: _p);

  /// square-scissors icon.
  static const squareScissors = IconData(0xe4ec, fontFamily: _f, fontPackage: _p);

  /// square-sigma icon.
  static const squareSigma = IconData(0xe489, fontFamily: _f, fontPackage: _p);

  /// square-slash icon.
  static const squareSlash = IconData(0xe174, fontFamily: _f, fontPackage: _p);

  /// square-square icon.
  static const squareSquare = IconData(0xe60e, fontFamily: _f, fontPackage: _p);

  /// square-stack icon.
  static const squareStack = IconData(0xe4a2, fontFamily: _f, fontPackage: _p);

  /// square-star icon.
  static const squareStar = IconData(0xe68e, fontFamily: _f, fontPackage: _p);

  /// square-stop icon.
  static const squareStop = IconData(0xe685, fontFamily: _f, fontPackage: _p);

  /// square-terminal icon.
  static const squareTerminal = IconData(0xe20a, fontFamily: _f, fontPackage: _p);

  /// square-user icon.
  static const squareUser = IconData(0xe465, fontFamily: _f, fontPackage: _p);

  /// square-user-round icon.
  static const squareUserRound = IconData(0xe466, fontFamily: _f, fontPackage: _p);

  /// square-x icon.
  static const squareX = IconData(0xe175, fontFamily: _f, fontPackage: _p);

  /// squares-exclude icon.
  static const squaresExclude = IconData(0xe657, fontFamily: _f, fontPackage: _p);

  /// squares-intersect icon.
  static const squaresIntersect = IconData(0xe658, fontFamily: _f, fontPackage: _p);

  /// squares-subtract icon.
  static const squaresSubtract = IconData(0xe659, fontFamily: _f, fontPackage: _p);

  /// squares-unite icon.
  static const squaresUnite = IconData(0xe65a, fontFamily: _f, fontPackage: _p);

  /// star icon.
  static const star = IconData(0xe176, fontFamily: _f, fontPackage: _p);

  /// star-half icon.
  static const starHalf = IconData(0xe20b, fontFamily: _f, fontPackage: _p);

  /// star-off icon.
  static const starOff = IconData(0xe2b0, fontFamily: _f, fontPackage: _p);

  /// stars icon.
  static const stars = IconData(0xe412, fontFamily: _f, fontPackage: _p);

  /// stop-circle icon.
  static const stopCircle = IconData(0xe083, fontFamily: _f, fontPackage: _p);

  /// terminal-square icon.
  static const terminalSquare = IconData(0xe20a, fontFamily: _f, fontPackage: _p);

  /// triangle icon.
  static const triangle = IconData(0xe192, fontFamily: _f, fontPackage: _p);

  /// triangle-alert icon.
  static const triangleAlert = IconData(0xe193, fontFamily: _f, fontPackage: _p);

  /// triangle-dashed icon.
  static const triangleDashed = IconData(0xe63d, fontFamily: _f, fontPackage: _p);

  /// triangle-right icon.
  static const triangleRight = IconData(0xe4ed, fontFamily: _f, fontPackage: _p);

  /// user-circle icon.
  static const userCircle = IconData(0xe461, fontFamily: _f, fontPackage: _p);

  /// user-circle-2 icon.
  static const userCircle2 = IconData(0xe462, fontFamily: _f, fontPackage: _p);

  /// user-square icon.
  static const userSquare = IconData(0xe465, fontFamily: _f, fontPackage: _p);

  /// user-square-2 icon.
  static const userSquare2 = IconData(0xe466, fontFamily: _f, fontPackage: _p);

  /// user-star icon.
  static const userStar = IconData(0xe687, fontFamily: _f, fontPackage: _p);

  /// vector-square icon.
  static const vectorSquare = IconData(0xe67c, fontFamily: _f, fontPackage: _p);

  /// x-circle icon.
  static const xCircle = IconData(0xe084, fontFamily: _f, fontPackage: _p);

  /// x-octagon icon.
  static const xOctagon = IconData(0xe128, fontFamily: _f, fontPackage: _p);

  /// x-square icon.
  static const xSquare = IconData(0xe175, fontFamily: _f, fontPackage: _p);


  // ── Math & Symbols ────────────────────────────────────────────────

  /// alarm-clock-minus icon.
  static const alarmClockMinus = IconData(0xe1ed, fontFamily: _f, fontPackage: _p);

  /// alarm-clock-plus icon.
  static const alarmClockPlus = IconData(0xe1ee, fontFamily: _f, fontPackage: _p);

  /// alarm-minus icon.
  static const alarmMinus = IconData(0xe1ed, fontFamily: _f, fontPackage: _p);

  /// alarm-plus icon.
  static const alarmPlus = IconData(0xe1ee, fontFamily: _f, fontPackage: _p);

  /// badge-minus icon.
  static const badgeMinus = IconData(0xe478, fontFamily: _f, fontPackage: _p);

  /// badge-percent icon.
  static const badgePercent = IconData(0xe479, fontFamily: _f, fontPackage: _p);

  /// badge-plus icon.
  static const badgePlus = IconData(0xe47a, fontFamily: _f, fontPackage: _p);

  /// battery-plus icon.
  static const batteryPlus = IconData(0xe63e, fontFamily: _f, fontPackage: _p);

  /// bell-minus icon.
  static const bellMinus = IconData(0xe1f0, fontFamily: _f, fontPackage: _p);

  /// bell-plus icon.
  static const bellPlus = IconData(0xe1f1, fontFamily: _f, fontPackage: _p);

  /// binary icon.
  static const binary = IconData(0xe1f2, fontFamily: _f, fontPackage: _p);

  /// book-minus icon.
  static const bookMinus = IconData(0xe3f2, fontFamily: _f, fontPackage: _p);

  /// book-plus icon.
  static const bookPlus = IconData(0xe3f3, fontFamily: _f, fontPackage: _p);

  /// bookmark-minus icon.
  static const bookmarkMinus = IconData(0xe23c, fontFamily: _f, fontPackage: _p);

  /// bookmark-plus icon.
  static const bookmarkPlus = IconData(0xe23d, fontFamily: _f, fontPackage: _p);

  /// calculator icon.
  static const calculator = IconData(0xe1bc, fontFamily: _f, fontPackage: _p);

  /// calendar-minus icon.
  static const calendarMinus = IconData(0xe2ba, fontFamily: _f, fontPackage: _p);

  /// calendar-minus-2 icon.
  static const calendarMinus2 = IconData(0xe5b5, fontFamily: _f, fontPackage: _p);

  /// calendar-plus icon.
  static const calendarPlus = IconData(0xe2bc, fontFamily: _f, fontPackage: _p);

  /// calendar-plus-2 icon.
  static const calendarPlus2 = IconData(0xe5b6, fontFamily: _f, fontPackage: _p);

  /// chart-pie icon.
  static const chartPie = IconData(0xe06b, fontFamily: _f, fontPackage: _p);

  /// clipboard-minus icon.
  static const clipboardMinus = IconData(0xe5be, fontFamily: _f, fontPackage: _p);

  /// clipboard-plus icon.
  static const clipboardPlus = IconData(0xe5bf, fontFamily: _f, fontPackage: _p);

  /// clock-plus icon.
  static const clockPlus = IconData(0xe667, fontFamily: _f, fontPackage: _p);

  /// copy-minus icon.
  static const copyMinus = IconData(0xe3fc, fontFamily: _f, fontPackage: _p);

  /// copy-plus icon.
  static const copyPlus = IconData(0xe3fd, fontFamily: _f, fontPackage: _p);

  /// divide icon.
  static const divide = IconData(0xe0b0, fontFamily: _f, fontPackage: _p);

  /// equal icon.
  static const equal = IconData(0xe1bd, fontFamily: _f, fontPackage: _p);

  /// equal-approximately icon.
  static const equalApproximately = IconData(0xe634, fontFamily: _f, fontPackage: _p);

  /// equal-not icon.
  static const equalNot = IconData(0xe1be, fontFamily: _f, fontPackage: _p);

  /// file-chart-pie icon.
  static const fileChartPie = IconData(0xe314, fontFamily: _f, fontPackage: _p);

  /// file-minus icon.
  static const fileMinus = IconData(0xe0c6, fontFamily: _f, fontPackage: _p);

  /// file-minus-2 icon.
  static const fileMinus2 = IconData(0xe0c7, fontFamily: _f, fontPackage: _p);

  /// file-pie-chart icon.
  static const filePieChart = IconData(0xe314, fontFamily: _f, fontPackage: _p);

  /// file-plus icon.
  static const filePlus = IconData(0xe0c9, fontFamily: _f, fontPackage: _p);

  /// file-plus-2 icon.
  static const filePlus2 = IconData(0xe0ca, fontFamily: _f, fontPackage: _p);

  /// folder-minus icon.
  static const folderMinus = IconData(0xe0d8, fontFamily: _f, fontPackage: _p);

  /// folder-plus icon.
  static const folderPlus = IconData(0xe0d9, fontFamily: _f, fontPackage: _p);

  /// funnel-plus icon.
  static const funnelPlus = IconData(0xe0dd, fontFamily: _f, fontPackage: _p);

  /// git-branch-minus icon.
  static const gitBranchMinus = IconData(0xe69c, fontFamily: _f, fontPackage: _p);

  /// git-branch-plus icon.
  static const gitBranchPlus = IconData(0xe1f4, fontFamily: _f, fontPackage: _p);

  /// hand-helping icon.
  static const handHelping = IconData(0xe3b8, fontFamily: _f, fontPackage: _p);

  /// hash icon.
  static const hash = IconData(0xe0ef, fontFamily: _f, fontPackage: _p);

  /// helping-hand icon.
  static const helpingHand = IconData(0xe3b8, fontFamily: _f, fontPackage: _p);

  /// hospital icon.
  static const hospital = IconData(0xe5d8, fontFamily: _f, fontPackage: _p);

  /// house-plus icon.
  static const housePlus = IconData(0xe5f1, fontFamily: _f, fontPackage: _p);

  /// image-minus icon.
  static const imageMinus = IconData(0xe1f6, fontFamily: _f, fontPackage: _p);

  /// image-plus icon.
  static const imagePlus = IconData(0xe1f7, fontFamily: _f, fontPackage: _p);

  /// infinity icon.
  static const infinity = IconData(0xe1e7, fontFamily: _f, fontPackage: _p);

  /// layers-plus icon.
  static const layersPlus = IconData(0xe6af, fontFamily: _f, fontPackage: _p);

  /// loader-pinwheel icon.
  static const loaderPinwheel = IconData(0xe5e6, fontFamily: _f, fontPackage: _p);

  /// mail-minus icon.
  static const mailMinus = IconData(0xe362, fontFamily: _f, fontPackage: _p);

  /// mail-plus icon.
  static const mailPlus = IconData(0xe364, fontFamily: _f, fontPackage: _p);

  /// map-minus icon.
  static const mapMinus = IconData(0xe686, fontFamily: _f, fontPackage: _p);

  /// map-pin icon.
  static const mapPin = IconData(0xe111, fontFamily: _f, fontPackage: _p);

  /// map-pin-check icon.
  static const mapPinCheck = IconData(0xe60f, fontFamily: _f, fontPackage: _p);

  /// map-pin-check-inside icon.
  static const mapPinCheckInside = IconData(0xe610, fontFamily: _f, fontPackage: _p);

  /// map-pin-house icon.
  static const mapPinHouse = IconData(0xe61c, fontFamily: _f, fontPackage: _p);

  /// map-pin-minus icon.
  static const mapPinMinus = IconData(0xe611, fontFamily: _f, fontPackage: _p);

  /// map-pin-minus-inside icon.
  static const mapPinMinusInside = IconData(0xe612, fontFamily: _f, fontPackage: _p);

  /// map-pin-off icon.
  static const mapPinOff = IconData(0xe2a6, fontFamily: _f, fontPackage: _p);

  /// map-pin-pen icon.
  static const mapPinPen = IconData(0xe655, fontFamily: _f, fontPackage: _p);

  /// map-pin-plus icon.
  static const mapPinPlus = IconData(0xe613, fontFamily: _f, fontPackage: _p);

  /// map-pin-plus-inside icon.
  static const mapPinPlusInside = IconData(0xe614, fontFamily: _f, fontPackage: _p);

  /// map-pin-x icon.
  static const mapPinX = IconData(0xe615, fontFamily: _f, fontPackage: _p);

  /// map-pin-x-inside icon.
  static const mapPinXInside = IconData(0xe616, fontFamily: _f, fontPackage: _p);

  /// map-pinned icon.
  static const mapPinned = IconData(0xe53d, fontFamily: _f, fontPackage: _p);

  /// map-plus icon.
  static const mapPlus = IconData(0xe63f, fontFamily: _f, fontPackage: _p);

  /// minus icon.
  static const minus = IconData(0xe11c, fontFamily: _f, fontPackage: _p);

  /// non-binary icon.
  static const nonBinary = IconData(0xe643, fontFamily: _f, fontPackage: _p);

  /// package-minus icon.
  static const packageMinus = IconData(0xe267, fontFamily: _f, fontPackage: _p);

  /// package-plus icon.
  static const packagePlus = IconData(0xe268, fontFamily: _f, fontPackage: _p);

  /// percent icon.
  static const percent = IconData(0xe132, fontFamily: _f, fontPackage: _p);

  /// philippine-peso icon.
  static const philippinePeso = IconData(0xe604, fontFamily: _f, fontPackage: _p);

  /// pi icon.
  static const pi = IconData(0xe472, fontFamily: _f, fontPackage: _p);

  /// piano icon.
  static const piano = IconData(0xe561, fontFamily: _f, fontPackage: _p);

  /// pickaxe icon.
  static const pickaxe = IconData(0xe5c6, fontFamily: _f, fontPackage: _p);

  /// picture-in-picture icon.
  static const pictureInPicture = IconData(0xe3ae, fontFamily: _f, fontPackage: _p);

  /// picture-in-picture-2 icon.
  static const pictureInPicture2 = IconData(0xe3af, fontFamily: _f, fontPackage: _p);

  /// pie-chart icon.
  static const pieChart = IconData(0xe06b, fontFamily: _f, fontPackage: _p);

  /// piggy-bank icon.
  static const piggyBank = IconData(0xe13a, fontFamily: _f, fontPackage: _p);

  /// pill icon.
  static const pill = IconData(0xe3bd, fontFamily: _f, fontPackage: _p);

  /// pill-bottle icon.
  static const pillBottle = IconData(0xe5ea, fontFamily: _f, fontPackage: _p);

  /// pin icon.
  static const pin = IconData(0xe259, fontFamily: _f, fontPackage: _p);

  /// pin-off icon.
  static const pinOff = IconData(0xe2b6, fontFamily: _f, fontPackage: _p);

  /// pipette icon.
  static const pipette = IconData(0xe13b, fontFamily: _f, fontPackage: _p);

  /// pizza icon.
  static const pizza = IconData(0xe354, fontFamily: _f, fontPackage: _p);

  /// plus icon.
  static const plus = IconData(0xe13d, fontFamily: _f, fontPackage: _p);

  /// radical icon.
  static const radical = IconData(0xe5c2, fontFamily: _f, fontPackage: _p);

  /// shield-minus icon.
  static const shieldMinus = IconData(0xe518, fontFamily: _f, fontPackage: _p);

  /// shield-plus icon.
  static const shieldPlus = IconData(0xe519, fontFamily: _f, fontPackage: _p);

  /// shopping-bag icon.
  static const shoppingBag = IconData(0xe15b, fontFamily: _f, fontPackage: _p);

  /// shopping-basket icon.
  static const shoppingBasket = IconData(0xe4ea, fontFamily: _f, fontPackage: _p);

  /// shopping-cart icon.
  static const shoppingCart = IconData(0xe15c, fontFamily: _f, fontPackage: _p);

  /// sigma icon.
  static const sigma = IconData(0xe201, fontFamily: _f, fontPackage: _p);

  /// smile-plus icon.
  static const smilePlus = IconData(0xe301, fontFamily: _f, fontPackage: _p);

  /// tally-1 icon.
  static const tally1 = IconData(0xe4d6, fontFamily: _f, fontPackage: _p);

  /// tally-2 icon.
  static const tally2 = IconData(0xe4d7, fontFamily: _f, fontPackage: _p);

  /// tally-3 icon.
  static const tally3 = IconData(0xe4d8, fontFamily: _f, fontPackage: _p);

  /// tally-4 icon.
  static const tally4 = IconData(0xe4d9, fontFamily: _f, fontPackage: _p);

  /// tally-5 icon.
  static const tally5 = IconData(0xe4da, fontFamily: _f, fontPackage: _p);

  /// ticket-minus icon.
  static const ticketMinus = IconData(0xe5af, fontFamily: _f, fontPackage: _p);

  /// ticket-percent icon.
  static const ticketPercent = IconData(0xe5b0, fontFamily: _f, fontPackage: _p);

  /// ticket-plus icon.
  static const ticketPlus = IconData(0xe5b1, fontFamily: _f, fontPackage: _p);

  /// tree-pine icon.
  static const treePine = IconData(0xe2f4, fontFamily: _f, fontPackage: _p);

  /// user-minus icon.
  static const userMinus = IconData(0xe1a1, fontFamily: _f, fontPackage: _p);

  /// user-minus-2 icon.
  static const userMinus2 = IconData(0xe46b, fontFamily: _f, fontPackage: _p);

  /// user-plus icon.
  static const userPlus = IconData(0xe1a2, fontFamily: _f, fontPackage: _p);

  /// user-plus-2 icon.
  static const userPlus2 = IconData(0xe46c, fontFamily: _f, fontPackage: _p);

  /// user-round-minus icon.
  static const userRoundMinus = IconData(0xe46b, fontFamily: _f, fontPackage: _p);

  /// user-round-plus icon.
  static const userRoundPlus = IconData(0xe46c, fontFamily: _f, fontPackage: _p);

  /// zodiac-pisces icon.
  static const zodiacPisces = IconData(0xe6d3, fontFamily: _f, fontPackage: _p);

  /// zodiac-scorpio icon.
  static const zodiacScorpio = IconData(0xe6d5, fontFamily: _f, fontPackage: _p);


  // ── Files & Folders ───────────────────────────────────────────────

  /// archive icon.
  static const archive = IconData(0xe041, fontFamily: _f, fontPackage: _p);

  /// archive-restore icon.
  static const archiveRestore = IconData(0xe2cd, fontFamily: _f, fontPackage: _p);

  /// archive-x icon.
  static const archiveX = IconData(0xe50c, fontFamily: _f, fontPackage: _p);

  /// book icon.
  static const book = IconData(0xe05e, fontFamily: _f, fontPackage: _p);

  /// book-a icon.
  static const bookA = IconData(0xe544, fontFamily: _f, fontPackage: _p);

  /// book-alert icon.
  static const bookAlert = IconData(0xe672, fontFamily: _f, fontPackage: _p);

  /// book-audio icon.
  static const bookAudio = IconData(0xe545, fontFamily: _f, fontPackage: _p);

  /// book-check icon.
  static const bookCheck = IconData(0xe546, fontFamily: _f, fontPackage: _p);

  /// book-copy icon.
  static const bookCopy = IconData(0xe3ec, fontFamily: _f, fontPackage: _p);

  /// book-dashed icon.
  static const bookDashed = IconData(0xe3ed, fontFamily: _f, fontPackage: _p);

  /// book-down icon.
  static const bookDown = IconData(0xe3ee, fontFamily: _f, fontPackage: _p);

  /// book-headphones icon.
  static const bookHeadphones = IconData(0xe547, fontFamily: _f, fontPackage: _p);

  /// book-image icon.
  static const bookImage = IconData(0xe549, fontFamily: _f, fontPackage: _p);

  /// book-key icon.
  static const bookKey = IconData(0xe3ef, fontFamily: _f, fontPackage: _p);

  /// book-lock icon.
  static const bookLock = IconData(0xe3f0, fontFamily: _f, fontPackage: _p);

  /// book-marked icon.
  static const bookMarked = IconData(0xe3f1, fontFamily: _f, fontPackage: _p);

  /// book-open icon.
  static const bookOpen = IconData(0xe05f, fontFamily: _f, fontPackage: _p);

  /// book-open-check icon.
  static const bookOpenCheck = IconData(0xe381, fontFamily: _f, fontPackage: _p);

  /// book-search icon.
  static const bookSearch = IconData(0xe6ab, fontFamily: _f, fontPackage: _p);

  /// book-template icon.
  static const bookTemplate = IconData(0xe3ed, fontFamily: _f, fontPackage: _p);

  /// book-up icon.
  static const bookUp = IconData(0xe3f4, fontFamily: _f, fontPackage: _p);

  /// book-up-2 icon.
  static const bookUp2 = IconData(0xe4a6, fontFamily: _f, fontPackage: _p);

  /// book-user icon.
  static const bookUser = IconData(0xe54d, fontFamily: _f, fontPackage: _p);

  /// book-x icon.
  static const bookX = IconData(0xe3f5, fontFamily: _f, fontPackage: _p);

  /// bookmark icon.
  static const bookmark = IconData(0xe060, fontFamily: _f, fontPackage: _p);

  /// bookmark-check icon.
  static const bookmarkCheck = IconData(0xe51f, fontFamily: _f, fontPackage: _p);

  /// bookmark-x icon.
  static const bookmarkX = IconData(0xe520, fontFamily: _f, fontPackage: _p);

  /// clipboard icon.
  static const clipboard = IconData(0xe085, fontFamily: _f, fontPackage: _p);

  /// clipboard-check icon.
  static const clipboardCheck = IconData(0xe219, fontFamily: _f, fontPackage: _p);

  /// clipboard-clock icon.
  static const clipboardClock = IconData(0xe688, fontFamily: _f, fontPackage: _p);

  /// clipboard-copy icon.
  static const clipboardCopy = IconData(0xe225, fontFamily: _f, fontPackage: _p);

  /// clipboard-edit icon.
  static const clipboardEdit = IconData(0xe307, fontFamily: _f, fontPackage: _p);

  /// clipboard-paste icon.
  static const clipboardPaste = IconData(0xe3e8, fontFamily: _f, fontPackage: _p);

  /// clipboard-pen icon.
  static const clipboardPen = IconData(0xe307, fontFamily: _f, fontPackage: _p);

  /// clipboard-pen-line icon.
  static const clipboardPenLine = IconData(0xe308, fontFamily: _f, fontPackage: _p);

  /// clipboard-signature icon.
  static const clipboardSignature = IconData(0xe308, fontFamily: _f, fontPackage: _p);

  /// clipboard-x icon.
  static const clipboardX = IconData(0xe222, fontFamily: _f, fontPackage: _p);

  /// copy icon.
  static const copy = IconData(0xe09e, fontFamily: _f, fontPackage: _p);

  /// copy-check icon.
  static const copyCheck = IconData(0xe3fb, fontFamily: _f, fontPackage: _p);

  /// copy-slash icon.
  static const copySlash = IconData(0xe3fe, fontFamily: _f, fontPackage: _p);

  /// copy-x icon.
  static const copyX = IconData(0xe3ff, fontFamily: _f, fontPackage: _p);

  /// copyleft icon.
  static const copyleft = IconData(0xe09f, fontFamily: _f, fontPackage: _p);

  /// copyright icon.
  static const copyright = IconData(0xe0a0, fontFamily: _f, fontPackage: _p);

  /// facebook icon.
  static const facebook = IconData(0xe0bc, fontFamily: _f, fontPackage: _p);

  /// file icon.
  static const file = IconData(0xe0c0, fontFamily: _f, fontPackage: _p);

  /// file-archive icon.
  static const fileArchive = IconData(0xe30d, fontFamily: _f, fontPackage: _p);

  /// file-audio icon.
  static const fileAudio = IconData(0xe31a, fontFamily: _f, fontPackage: _p);

  /// file-audio-2 icon.
  static const fileAudio2 = IconData(0xe31a, fontFamily: _f, fontPackage: _p);

  /// file-axis-3-d icon.
  static const fileAxis3D = IconData(0xe30e, fontFamily: _f, fontPackage: _p);

  /// file-axis-3d icon.
  static const fileAxis3d = IconData(0xe30e, fontFamily: _f, fontPackage: _p);

  /// file-badge icon.
  static const fileBadge = IconData(0xe30f, fontFamily: _f, fontPackage: _p);

  /// file-badge-2 icon.
  static const fileBadge2 = IconData(0xe30f, fontFamily: _f, fontPackage: _p);

  /// file-bar-chart icon.
  static const fileBarChart = IconData(0xe312, fontFamily: _f, fontPackage: _p);

  /// file-bar-chart-2 icon.
  static const fileBarChart2 = IconData(0xe311, fontFamily: _f, fontPackage: _p);

  /// file-box icon.
  static const fileBox = IconData(0xe310, fontFamily: _f, fontPackage: _p);

  /// file-braces icon.
  static const fileBraces = IconData(0xe36b, fontFamily: _f, fontPackage: _p);

  /// file-chart-line icon.
  static const fileChartLine = IconData(0xe313, fontFamily: _f, fontPackage: _p);

  /// file-check icon.
  static const fileCheck = IconData(0xe0c1, fontFamily: _f, fontPackage: _p);

  /// file-check-2 icon.
  static const fileCheck2 = IconData(0xe0c2, fontFamily: _f, fontPackage: _p);

  /// file-clock icon.
  static const fileClock = IconData(0xe315, fontFamily: _f, fontPackage: _p);

  /// file-code icon.
  static const fileCode = IconData(0xe0c3, fontFamily: _f, fontPackage: _p);

  /// file-code-2 icon.
  static const fileCode2 = IconData(0xe45e, fontFamily: _f, fontPackage: _p);

  /// file-cog icon.
  static const fileCog = IconData(0xe316, fontFamily: _f, fontPackage: _p);

  /// file-cog-2 icon.
  static const fileCog2 = IconData(0xe316, fontFamily: _f, fontPackage: _p);

  /// file-diff icon.
  static const fileDiff = IconData(0xe317, fontFamily: _f, fontPackage: _p);

  /// file-digit icon.
  static const fileDigit = IconData(0xe0c4, fontFamily: _f, fontPackage: _p);

  /// file-down icon.
  static const fileDown = IconData(0xe318, fontFamily: _f, fontPackage: _p);

  /// file-edit icon.
  static const fileEdit = IconData(0xe31f, fontFamily: _f, fontPackage: _p);

  /// file-exclamation-point icon.
  static const fileExclamationPoint = IconData(0xe319, fontFamily: _f, fontPackage: _p);

  /// file-headphone icon.
  static const fileHeadphone = IconData(0xe31a, fontFamily: _f, fontPackage: _p);

  /// file-image icon.
  static const fileImage = IconData(0xe31c, fontFamily: _f, fontPackage: _p);

  /// file-input icon.
  static const fileInput = IconData(0xe0c5, fontFamily: _f, fontPackage: _p);

  /// file-json icon.
  static const fileJson = IconData(0xe36b, fontFamily: _f, fontPackage: _p);

  /// file-json-2 icon.
  static const fileJson2 = IconData(0xe36c, fontFamily: _f, fontPackage: _p);

  /// file-key icon.
  static const fileKey = IconData(0xe31d, fontFamily: _f, fontPackage: _p);

  /// file-key-2 icon.
  static const fileKey2 = IconData(0xe31d, fontFamily: _f, fontPackage: _p);

  /// file-line-chart icon.
  static const fileLineChart = IconData(0xe313, fontFamily: _f, fontPackage: _p);

  /// file-lock icon.
  static const fileLock = IconData(0xe31e, fontFamily: _f, fontPackage: _p);

  /// file-lock-2 icon.
  static const fileLock2 = IconData(0xe31e, fontFamily: _f, fontPackage: _p);

  /// file-music icon.
  static const fileMusic = IconData(0xe55e, fontFamily: _f, fontPackage: _p);

  /// file-output icon.
  static const fileOutput = IconData(0xe0c8, fontFamily: _f, fontPackage: _p);

  /// file-pen icon.
  static const filePen = IconData(0xe31f, fontFamily: _f, fontPackage: _p);

  /// file-pen-line icon.
  static const filePenLine = IconData(0xe320, fontFamily: _f, fontPackage: _p);

  /// file-play icon.
  static const filePlay = IconData(0xe321, fontFamily: _f, fontPackage: _p);

  /// file-question icon.
  static const fileQuestion = IconData(0xe322, fontFamily: _f, fontPackage: _p);

  /// file-question-mark icon.
  static const fileQuestionMark = IconData(0xe322, fontFamily: _f, fontPackage: _p);

  /// file-scan icon.
  static const fileScan = IconData(0xe323, fontFamily: _f, fontPackage: _p);

  /// file-search icon.
  static const fileSearch = IconData(0xe0cb, fontFamily: _f, fontPackage: _p);

  /// file-search-2 icon.
  static const fileSearch2 = IconData(0xe324, fontFamily: _f, fontPackage: _p);

  /// file-signal icon.
  static const fileSignal = IconData(0xe325, fontFamily: _f, fontPackage: _p);

  /// file-signature icon.
  static const fileSignature = IconData(0xe320, fontFamily: _f, fontPackage: _p);

  /// file-sliders icon.
  static const fileSliders = IconData(0xe5a0, fontFamily: _f, fontPackage: _p);

  /// file-spreadsheet icon.
  static const fileSpreadsheet = IconData(0xe326, fontFamily: _f, fontPackage: _p);

  /// file-stack icon.
  static const fileStack = IconData(0xe4a1, fontFamily: _f, fontPackage: _p);

  /// file-symlink icon.
  static const fileSymlink = IconData(0xe327, fontFamily: _f, fontPackage: _p);

  /// file-terminal icon.
  static const fileTerminal = IconData(0xe328, fontFamily: _f, fontPackage: _p);

  /// file-up icon.
  static const fileUp = IconData(0xe32a, fontFamily: _f, fontPackage: _p);

  /// file-user icon.
  static const fileUser = IconData(0xe62d, fontFamily: _f, fontPackage: _p);

  /// file-video icon.
  static const fileVideo = IconData(0xe321, fontFamily: _f, fontPackage: _p);

  /// file-video-2 icon.
  static const fileVideo2 = IconData(0xe32b, fontFamily: _f, fontPackage: _p);

  /// file-video-camera icon.
  static const fileVideoCamera = IconData(0xe32b, fontFamily: _f, fontPackage: _p);

  /// file-volume icon.
  static const fileVolume = IconData(0xe32c, fontFamily: _f, fontPackage: _p);

  /// file-volume-2 icon.
  static const fileVolume2 = IconData(0xe325, fontFamily: _f, fontPackage: _p);

  /// file-warning icon.
  static const fileWarning = IconData(0xe319, fontFamily: _f, fontPackage: _p);

  /// file-x icon.
  static const fileX = IconData(0xe0cd, fontFamily: _f, fontPackage: _p);

  /// file-x-2 icon.
  static const fileX2 = IconData(0xe0ce, fontFamily: _f, fontPackage: _p);

  /// files icon.
  static const files = IconData(0xe0cf, fontFamily: _f, fontPackage: _p);

  /// folder icon.
  static const folder = IconData(0xe0d7, fontFamily: _f, fontPackage: _p);

  /// folder-archive icon.
  static const folderArchive = IconData(0xe32d, fontFamily: _f, fontPackage: _p);

  /// folder-check icon.
  static const folderCheck = IconData(0xe32e, fontFamily: _f, fontPackage: _p);

  /// folder-clock icon.
  static const folderClock = IconData(0xe32f, fontFamily: _f, fontPackage: _p);

  /// folder-closed icon.
  static const folderClosed = IconData(0xe330, fontFamily: _f, fontPackage: _p);

  /// folder-code icon.
  static const folderCode = IconData(0xe5fb, fontFamily: _f, fontPackage: _p);

  /// folder-cog icon.
  static const folderCog = IconData(0xe331, fontFamily: _f, fontPackage: _p);

  /// folder-cog-2 icon.
  static const folderCog2 = IconData(0xe331, fontFamily: _f, fontPackage: _p);

  /// folder-dot icon.
  static const folderDot = IconData(0xe4c5, fontFamily: _f, fontPackage: _p);

  /// folder-down icon.
  static const folderDown = IconData(0xe332, fontFamily: _f, fontPackage: _p);

  /// folder-edit icon.
  static const folderEdit = IconData(0xe338, fontFamily: _f, fontPackage: _p);

  /// folder-git icon.
  static const folderGit = IconData(0xe409, fontFamily: _f, fontPackage: _p);

  /// folder-git-2 icon.
  static const folderGit2 = IconData(0xe40a, fontFamily: _f, fontPackage: _p);

  /// folder-input icon.
  static const folderInput = IconData(0xe334, fontFamily: _f, fontPackage: _p);

  /// folder-key icon.
  static const folderKey = IconData(0xe335, fontFamily: _f, fontPackage: _p);

  /// folder-lock icon.
  static const folderLock = IconData(0xe336, fontFamily: _f, fontPackage: _p);

  /// folder-open icon.
  static const folderOpen = IconData(0xe247, fontFamily: _f, fontPackage: _p);

  /// folder-open-dot icon.
  static const folderOpenDot = IconData(0xe4c7, fontFamily: _f, fontPackage: _p);

  /// folder-output icon.
  static const folderOutput = IconData(0xe337, fontFamily: _f, fontPackage: _p);

  /// folder-pen icon.
  static const folderPen = IconData(0xe338, fontFamily: _f, fontPackage: _p);

  /// folder-root icon.
  static const folderRoot = IconData(0xe4c8, fontFamily: _f, fontPackage: _p);

  /// folder-search icon.
  static const folderSearch = IconData(0xe339, fontFamily: _f, fontPackage: _p);

  /// folder-search-2 icon.
  static const folderSearch2 = IconData(0xe33a, fontFamily: _f, fontPackage: _p);

  /// folder-symlink icon.
  static const folderSymlink = IconData(0xe33b, fontFamily: _f, fontPackage: _p);

  /// folder-sync icon.
  static const folderSync = IconData(0xe4c9, fontFamily: _f, fontPackage: _p);

  /// folder-tree icon.
  static const folderTree = IconData(0xe33c, fontFamily: _f, fontPackage: _p);

  /// folder-up icon.
  static const folderUp = IconData(0xe33d, fontFamily: _f, fontPackage: _p);

  /// folder-x icon.
  static const folderX = IconData(0xe33e, fontFamily: _f, fontPackage: _p);

  /// folders icon.
  static const folders = IconData(0xe33f, fontFamily: _f, fontPackage: _p);

  /// git-pull-request-draft icon.
  static const gitPullRequestDraft = IconData(0xe35b, fontFamily: _f, fontPackage: _p);

  /// notebook icon.
  static const notebook = IconData(0xe595, fontFamily: _f, fontPackage: _p);

  /// notebook-pen icon.
  static const notebookPen = IconData(0xe596, fontFamily: _f, fontPackage: _p);

  /// notebook-tabs icon.
  static const notebookTabs = IconData(0xe597, fontFamily: _f, fontPackage: _p);

  /// paperclip icon.
  static const paperclip = IconData(0xe12d, fontFamily: _f, fontPackage: _p);

  /// save icon.
  static const save = IconData(0xe14d, fontFamily: _f, fontPackage: _p);

  /// save-all icon.
  static const saveAll = IconData(0xe40f, fontFamily: _f, fontPackage: _p);

  /// save-off icon.
  static const saveOff = IconData(0xe5f3, fontFamily: _f, fontPackage: _p);

  /// swatch-book icon.
  static const swatchBook = IconData(0xe59f, fontFamily: _f, fontPackage: _p);


  // ── Media & Communication ─────────────────────────────────────────

  /// airplay icon.
  static const airplay = IconData(0xe039, fontFamily: _f, fontPackage: _p);

  /// antenna icon.
  static const antenna = IconData(0xe4e2, fontFamily: _f, fontPackage: _p);

  /// at-sign icon.
  static const atSign = IconData(0xe04e, fontFamily: _f, fontPackage: _p);

  /// audio-lines icon.
  static const audioLines = IconData(0xe55a, fontFamily: _f, fontPackage: _p);

  /// audio-waveform icon.
  static const audioWaveform = IconData(0xe55b, fontFamily: _f, fontPackage: _p);

  /// bell icon.
  static const bell = IconData(0xe059, fontFamily: _f, fontPackage: _p);

  /// bell-dot icon.
  static const bellDot = IconData(0xe42b, fontFamily: _f, fontPackage: _p);

  /// bell-electric icon.
  static const bellElectric = IconData(0xe57c, fontFamily: _f, fontPackage: _p);

  /// bell-off icon.
  static const bellOff = IconData(0xe05a, fontFamily: _f, fontPackage: _p);

  /// bell-ring icon.
  static const bellRing = IconData(0xe224, fontFamily: _f, fontPackage: _p);

  /// bug-play icon.
  static const bugPlay = IconData(0xe50e, fontFamily: _f, fontPackage: _p);

  /// camera icon.
  static const camera = IconData(0xe064, fontFamily: _f, fontPackage: _p);

  /// camera-off icon.
  static const cameraOff = IconData(0xe065, fontFamily: _f, fontPackage: _p);

  /// cast icon.
  static const cast = IconData(0xe066, fontFamily: _f, fontPackage: _p);

  /// castle icon.
  static const castle = IconData(0xe3e0, fontFamily: _f, fontPackage: _p);

  /// cctv icon.
  static const cctv = IconData(0xe57d, fontFamily: _f, fontPackage: _p);

  /// concierge-bell icon.
  static const conciergeBell = IconData(0xe378, fontFamily: _f, fontPackage: _p);

  /// contact icon.
  static const contact = IconData(0xe09c, fontFamily: _f, fontPackage: _p);

  /// contact-2 icon.
  static const contact2 = IconData(0xe463, fontFamily: _f, fontPackage: _p);

  /// contact-round icon.
  static const contactRound = IconData(0xe463, fontFamily: _f, fontPackage: _p);

  /// dumbbell icon.
  static const dumbbell = IconData(0xe3a1, fontFamily: _f, fontPackage: _p);

  /// fast-forward icon.
  static const fastForward = IconData(0xe0bd, fontFamily: _f, fontPackage: _p);

  /// headphone-off icon.
  static const headphoneOff = IconData(0xe629, fontFamily: _f, fontPackage: _p);

  /// headphones icon.
  static const headphones = IconData(0xe0f1, fontFamily: _f, fontPackage: _p);

  /// image icon.
  static const image = IconData(0xe0f6, fontFamily: _f, fontPackage: _p);

  /// image-down icon.
  static const imageDown = IconData(0xe53c, fontFamily: _f, fontPackage: _p);

  /// image-off icon.
  static const imageOff = IconData(0xe1c0, fontFamily: _f, fontPackage: _p);

  /// image-play icon.
  static const imagePlay = IconData(0xe5df, fontFamily: _f, fontPackage: _p);

  /// image-up icon.
  static const imageUp = IconData(0xe5cb, fontFamily: _f, fontPackage: _p);

  /// image-upscale icon.
  static const imageUpscale = IconData(0xe637, fontFamily: _f, fontPackage: _p);

  /// images icon.
  static const images = IconData(0xe5c4, fontFamily: _f, fontPackage: _p);

  /// inbox icon.
  static const inbox = IconData(0xe0f7, fontFamily: _f, fontPackage: _p);

  /// keyboard-music icon.
  static const keyboardMusic = IconData(0xe560, fontFamily: _f, fontPackage: _p);

  /// mail icon.
  static const mail = IconData(0xe10f, fontFamily: _f, fontPackage: _p);

  /// mail-check icon.
  static const mailCheck = IconData(0xe361, fontFamily: _f, fontPackage: _p);

  /// mail-open icon.
  static const mailOpen = IconData(0xe363, fontFamily: _f, fontPackage: _p);

  /// mail-question icon.
  static const mailQuestion = IconData(0xe365, fontFamily: _f, fontPackage: _p);

  /// mail-question-mark icon.
  static const mailQuestionMark = IconData(0xe365, fontFamily: _f, fontPackage: _p);

  /// mail-search icon.
  static const mailSearch = IconData(0xe366, fontFamily: _f, fontPackage: _p);

  /// mail-warning icon.
  static const mailWarning = IconData(0xe367, fontFamily: _f, fontPackage: _p);

  /// mail-x icon.
  static const mailX = IconData(0xe368, fontFamily: _f, fontPackage: _p);

  /// mailbox icon.
  static const mailbox = IconData(0xe3d4, fontFamily: _f, fontPackage: _p);

  /// mails icon.
  static const mails = IconData(0xe369, fontFamily: _f, fontPackage: _p);

  /// megaphone icon.
  static const megaphone = IconData(0xe235, fontFamily: _f, fontPackage: _p);

  /// megaphone-off icon.
  static const megaphoneOff = IconData(0xe370, fontFamily: _f, fontPackage: _p);

  /// mic icon.
  static const mic = IconData(0xe118, fontFamily: _f, fontPackage: _p);

  /// mic-2 icon.
  static const mic2 = IconData(0xe349, fontFamily: _f, fontPackage: _p);

  /// mic-off icon.
  static const micOff = IconData(0xe119, fontFamily: _f, fontPackage: _p);

  /// mic-vocal icon.
  static const micVocal = IconData(0xe349, fontFamily: _f, fontPackage: _p);

  /// microchip icon.
  static const microchip = IconData(0xe61a, fontFamily: _f, fontPackage: _p);

  /// microscope icon.
  static const microscope = IconData(0xe2e4, fontFamily: _f, fontPackage: _p);

  /// monitor-pause icon.
  static const monitorPause = IconData(0xe484, fontFamily: _f, fontPackage: _p);

  /// monitor-play icon.
  static const monitorPlay = IconData(0xe485, fontFamily: _f, fontPackage: _p);

  /// monitor-smartphone icon.
  static const monitorSmartphone = IconData(0xe3a2, fontFamily: _f, fontPackage: _p);

  /// monitor-speaker icon.
  static const monitorSpeaker = IconData(0xe210, fontFamily: _f, fontPackage: _p);

  /// monitor-stop icon.
  static const monitorStop = IconData(0xe486, fontFamily: _f, fontPackage: _p);

  /// music icon.
  static const music = IconData(0xe122, fontFamily: _f, fontPackage: _p);

  /// music-2 icon.
  static const music2 = IconData(0xe34a, fontFamily: _f, fontPackage: _p);

  /// music-3 icon.
  static const music3 = IconData(0xe34b, fontFamily: _f, fontPackage: _p);

  /// music-4 icon.
  static const music4 = IconData(0xe34c, fontFamily: _f, fontPackage: _p);

  /// pause icon.
  static const pause = IconData(0xe12e, fontFamily: _f, fontPackage: _p);

  /// phone icon.
  static const phone = IconData(0xe133, fontFamily: _f, fontPackage: _p);

  /// phone-call icon.
  static const phoneCall = IconData(0xe134, fontFamily: _f, fontPackage: _p);

  /// phone-forwarded icon.
  static const phoneForwarded = IconData(0xe135, fontFamily: _f, fontPackage: _p);

  /// phone-incoming icon.
  static const phoneIncoming = IconData(0xe136, fontFamily: _f, fontPackage: _p);

  /// phone-missed icon.
  static const phoneMissed = IconData(0xe137, fontFamily: _f, fontPackage: _p);

  /// phone-off icon.
  static const phoneOff = IconData(0xe138, fontFamily: _f, fontPackage: _p);

  /// phone-outgoing icon.
  static const phoneOutgoing = IconData(0xe139, fontFamily: _f, fontPackage: _p);

  /// play icon.
  static const play = IconData(0xe13c, fontFamily: _f, fontPackage: _p);

  /// podcast icon.
  static const podcast = IconData(0xe1fa, fontFamily: _f, fontPackage: _p);

  /// presentation icon.
  static const presentation = IconData(0xe4ae, fontFamily: _f, fontPackage: _p);

  /// projector icon.
  static const projector = IconData(0xe4af, fontFamily: _f, fontPackage: _p);

  /// radio icon.
  static const radio = IconData(0xe142, fontFamily: _f, fontPackage: _p);

  /// radio-receiver icon.
  static const radioReceiver = IconData(0xe1fb, fontFamily: _f, fontPackage: _p);

  /// radio-tower icon.
  static const radioTower = IconData(0xe404, fontFamily: _f, fontPackage: _p);

  /// rewind icon.
  static const rewind = IconData(0xe147, fontFamily: _f, fontPackage: _p);

  /// rss icon.
  static const rss = IconData(0xe14a, fontFamily: _f, fontPackage: _p);

  /// satellite icon.
  static const satellite = IconData(0xe447, fontFamily: _f, fontPackage: _p);

  /// satellite-dish icon.
  static const satelliteDish = IconData(0xe448, fontFamily: _f, fontPackage: _p);

  /// screen-share icon.
  static const screenShare = IconData(0xe14f, fontFamily: _f, fontPackage: _p);

  /// screen-share-off icon.
  static const screenShareOff = IconData(0xe150, fontFamily: _f, fontPackage: _p);

  /// send icon.
  static const send = IconData(0xe152, fontFamily: _f, fontPackage: _p);

  /// send-horizonal icon.
  static const sendHorizonal = IconData(0xe4f2, fontFamily: _f, fontPackage: _p);

  /// send-horizontal icon.
  static const sendHorizontal = IconData(0xe4f2, fontFamily: _f, fontPackage: _p);

  /// send-to-back icon.
  static const sendToBack = IconData(0xe4f3, fontFamily: _f, fontPackage: _p);

  /// signal icon.
  static const signal = IconData(0xe25f, fontFamily: _f, fontPackage: _p);

  /// signal-high icon.
  static const signalHigh = IconData(0xe260, fontFamily: _f, fontPackage: _p);

  /// signal-low icon.
  static const signalLow = IconData(0xe261, fontFamily: _f, fontPackage: _p);

  /// signal-medium icon.
  static const signalMedium = IconData(0xe262, fontFamily: _f, fontPackage: _p);

  /// signal-zero icon.
  static const signalZero = IconData(0xe263, fontFamily: _f, fontPackage: _p);

  /// skip-back icon.
  static const skipBack = IconData(0xe15f, fontFamily: _f, fontPackage: _p);

  /// skip-forward icon.
  static const skipForward = IconData(0xe160, fontFamily: _f, fontPackage: _p);

  /// smartphone icon.
  static const smartphone = IconData(0xe163, fontFamily: _f, fontPackage: _p);

  /// smartphone-charging icon.
  static const smartphoneCharging = IconData(0xe22e, fontFamily: _f, fontPackage: _p);

  /// smartphone-nfc icon.
  static const smartphoneNfc = IconData(0xe3c4, fontFamily: _f, fontPackage: _p);

  /// speaker icon.
  static const speaker = IconData(0xe166, fontFamily: _f, fontPackage: _p);

  /// switch-camera icon.
  static const switchCamera = IconData(0xe17c, fontFamily: _f, fontPackage: _p);

  /// tablet-smartphone icon.
  static const tabletSmartphone = IconData(0xe50a, fontFamily: _f, fontPackage: _p);

  /// tv icon.
  static const tv = IconData(0xe195, fontFamily: _f, fontPackage: _p);

  /// tv-2 icon.
  static const tv2 = IconData(0xe203, fontFamily: _f, fontPackage: _p);

  /// tv-minimal icon.
  static const tvMinimal = IconData(0xe203, fontFamily: _f, fontPackage: _p);

  /// tv-minimal-play icon.
  static const tvMinimalPlay = IconData(0xe5ec, fontFamily: _f, fontPackage: _p);

  /// video icon.
  static const video = IconData(0xe1a5, fontFamily: _f, fontPackage: _p);

  /// video-off icon.
  static const videoOff = IconData(0xe1a6, fontFamily: _f, fontPackage: _p);

  /// videotape icon.
  static const videotape = IconData(0xe4cb, fontFamily: _f, fontPackage: _p);

  /// voicemail icon.
  static const voicemail = IconData(0xe1a8, fontFamily: _f, fontPackage: _p);

  /// volume icon.
  static const volume = IconData(0xe1a9, fontFamily: _f, fontPackage: _p);

  /// volume-1 icon.
  static const volume1 = IconData(0xe1aa, fontFamily: _f, fontPackage: _p);

  /// volume-2 icon.
  static const volume2 = IconData(0xe1ab, fontFamily: _f, fontPackage: _p);

  /// volume-off icon.
  static const volumeOff = IconData(0xe626, fontFamily: _f, fontPackage: _p);

  /// volume-x icon.
  static const volumeX = IconData(0xe1ac, fontFamily: _f, fontPackage: _p);


  // ── Weather & Nature ──────────────────────────────────────────────

  /// app-window icon.
  static const appWindow = IconData(0xe426, fontFamily: _f, fontPackage: _p);

  /// app-window-mac icon.
  static const appWindowMac = IconData(0xe5d2, fontFamily: _f, fontPackage: _p);

  /// brain icon.
  static const brain = IconData(0xe3c6, fontFamily: _f, fontPackage: _p);

  /// brain-circuit icon.
  static const brainCircuit = IconData(0xe3c7, fontFamily: _f, fontPackage: _p);

  /// brain-cog icon.
  static const brainCog = IconData(0xe3c8, fontFamily: _f, fontPackage: _p);

  /// brick-wall-fire icon.
  static const brickWallFire = IconData(0xe653, fontFamily: _f, fontPackage: _p);

  /// cloud icon.
  static const cloud = IconData(0xe088, fontFamily: _f, fontPackage: _p);

  /// cloud-alert icon.
  static const cloudAlert = IconData(0xe633, fontFamily: _f, fontPackage: _p);

  /// cloud-backup icon.
  static const cloudBackup = IconData(0xe6af, fontFamily: _f, fontPackage: _p);

  /// cloud-check icon.
  static const cloudCheck = IconData(0xe66e, fontFamily: _f, fontPackage: _p);

  /// cloud-cog icon.
  static const cloudCog = IconData(0xe30a, fontFamily: _f, fontPackage: _p);

  /// cloud-download icon.
  static const cloudDownload = IconData(0xe089, fontFamily: _f, fontPackage: _p);

  /// cloud-drizzle icon.
  static const cloudDrizzle = IconData(0xe08a, fontFamily: _f, fontPackage: _p);

  /// cloud-fog icon.
  static const cloudFog = IconData(0xe214, fontFamily: _f, fontPackage: _p);

  /// cloud-hail icon.
  static const cloudHail = IconData(0xe08b, fontFamily: _f, fontPackage: _p);

  /// cloud-lightning icon.
  static const cloudLightning = IconData(0xe08c, fontFamily: _f, fontPackage: _p);

  /// cloud-moon icon.
  static const cloudMoon = IconData(0xe215, fontFamily: _f, fontPackage: _p);

  /// cloud-moon-rain icon.
  static const cloudMoonRain = IconData(0xe2fa, fontFamily: _f, fontPackage: _p);

  /// cloud-off icon.
  static const cloudOff = IconData(0xe08d, fontFamily: _f, fontPackage: _p);

  /// cloud-rain icon.
  static const cloudRain = IconData(0xe08e, fontFamily: _f, fontPackage: _p);

  /// cloud-rain-wind icon.
  static const cloudRainWind = IconData(0xe08f, fontFamily: _f, fontPackage: _p);

  /// cloud-snow icon.
  static const cloudSnow = IconData(0xe090, fontFamily: _f, fontPackage: _p);

  /// cloud-sun icon.
  static const cloudSun = IconData(0xe216, fontFamily: _f, fontPackage: _p);

  /// cloud-sun-rain icon.
  static const cloudSunRain = IconData(0xe2fb, fontFamily: _f, fontPackage: _p);

  /// cloud-sync icon.
  static const cloudSync = IconData(0xe6af, fontFamily: _f, fontPackage: _p);

  /// cloud-upload icon.
  static const cloudUpload = IconData(0xe091, fontFamily: _f, fontPackage: _p);

  /// cloudy icon.
  static const cloudy = IconData(0xe217, fontFamily: _f, fontPackage: _p);

  /// clover icon.
  static const clover = IconData(0xe092, fontFamily: _f, fontPackage: _p);

  /// download-cloud icon.
  static const downloadCloud = IconData(0xe089, fontFamily: _f, fontPackage: _p);

  /// droplet icon.
  static const droplet = IconData(0xe0b4, fontFamily: _f, fontPackage: _p);

  /// droplet-off icon.
  static const dropletOff = IconData(0xe638, fontFamily: _f, fontPackage: _p);

  /// droplets icon.
  static const droplets = IconData(0xe0b5, fontFamily: _f, fontPackage: _p);

  /// fire-extinguisher icon.
  static const fireExtinguisher = IconData(0xe57e, fontFamily: _f, fontPackage: _p);

  /// flame icon.
  static const flame = IconData(0xe0d2, fontFamily: _f, fontPackage: _p);

  /// flame-kindling icon.
  static const flameKindling = IconData(0xe53a, fontFamily: _f, fontPackage: _p);

  /// flower icon.
  static const flower = IconData(0xe2d3, fontFamily: _f, fontPackage: _p);

  /// flower-2 icon.
  static const flower2 = IconData(0xe2d4, fontFamily: _f, fontPackage: _p);

  /// haze icon.
  static const haze = IconData(0xe0f0, fontFamily: _f, fontPackage: _p);

  /// leaf icon.
  static const leaf = IconData(0xe2de, fontFamily: _f, fontPackage: _p);

  /// leafy-green icon.
  static const leafyGreen = IconData(0xe46f, fontFamily: _f, fontPackage: _p);

  /// monitor-cloud icon.
  static const monitorCloud = IconData(0xe699, fontFamily: _f, fontPackage: _p);

  /// moon icon.
  static const moon = IconData(0xe11e, fontFamily: _f, fontPackage: _p);

  /// mountain icon.
  static const mountain = IconData(0xe231, fontFamily: _f, fontPackage: _p);

  /// mountain-snow icon.
  static const mountainSnow = IconData(0xe232, fontFamily: _f, fontPackage: _p);

  /// palmtree icon.
  static const palmtree = IconData(0xe281, fontFamily: _f, fontPackage: _p);

  /// rainbow icon.
  static const rainbow = IconData(0xe4c2, fontFamily: _f, fontPackage: _p);

  /// snowflake icon.
  static const snowflake = IconData(0xe165, fontFamily: _f, fontPackage: _p);

  /// soap-dispenser-droplet icon.
  static const soapDispenserDroplet = IconData(0xe669, fontFamily: _f, fontPackage: _p);

  /// sprout icon.
  static const sprout = IconData(0xe1eb, fontFamily: _f, fontPackage: _p);

  /// sun icon.
  static const sun = IconData(0xe178, fontFamily: _f, fontPackage: _p);

  /// sun-dim icon.
  static const sunDim = IconData(0xe299, fontFamily: _f, fontPackage: _p);

  /// sun-medium icon.
  static const sunMedium = IconData(0xe2b1, fontFamily: _f, fontPackage: _p);

  /// sun-moon icon.
  static const sunMoon = IconData(0xe2b2, fontFamily: _f, fontPackage: _p);

  /// sun-snow icon.
  static const sunSnow = IconData(0xe372, fontFamily: _f, fontPackage: _p);

  /// sunrise icon.
  static const sunrise = IconData(0xe179, fontFamily: _f, fontPackage: _p);

  /// sunset icon.
  static const sunset = IconData(0xe17a, fontFamily: _f, fontPackage: _p);

  /// tent-tree icon.
  static const tentTree = IconData(0xe53b, fontFamily: _f, fontPackage: _p);

  /// thermometer icon.
  static const thermometer = IconData(0xe186, fontFamily: _f, fontPackage: _p);

  /// thermometer-snowflake icon.
  static const thermometerSnowflake = IconData(0xe187, fontFamily: _f, fontPackage: _p);

  /// thermometer-sun icon.
  static const thermometerSun = IconData(0xe188, fontFamily: _f, fontPackage: _p);

  /// tornado icon.
  static const tornado = IconData(0xe218, fontFamily: _f, fontPackage: _p);

  /// train icon.
  static const train = IconData(0xe2a9, fontFamily: _f, fontPackage: _p);

  /// train-front icon.
  static const trainFront = IconData(0xe506, fontFamily: _f, fontPackage: _p);

  /// train-front-tunnel icon.
  static const trainFrontTunnel = IconData(0xe507, fontFamily: _f, fontPackage: _p);

  /// train-track icon.
  static const trainTrack = IconData(0xe508, fontFamily: _f, fontPackage: _p);

  /// tree-deciduous icon.
  static const treeDeciduous = IconData(0xe2f3, fontFamily: _f, fontPackage: _p);

  /// tree-palm icon.
  static const treePalm = IconData(0xe281, fontFamily: _f, fontPackage: _p);

  /// trees icon.
  static const trees = IconData(0xe2f5, fontFamily: _f, fontPackage: _p);

  /// umbrella icon.
  static const umbrella = IconData(0xe199, fontFamily: _f, fontPackage: _p);

  /// umbrella-off icon.
  static const umbrellaOff = IconData(0xe543, fontFamily: _f, fontPackage: _p);

  /// upload-cloud icon.
  static const uploadCloud = IconData(0xe091, fontFamily: _f, fontPackage: _p);

  /// vegan icon.
  static const vegan = IconData(0xe39d, fontFamily: _f, fontPackage: _p);

  /// waves icon.
  static const waves = IconData(0xe283, fontFamily: _f, fontPackage: _p);

  /// waves-ladder icon.
  static const wavesLadder = IconData(0xe63b, fontFamily: _f, fontPackage: _p);

  /// wind icon.
  static const wind = IconData(0xe1b0, fontFamily: _f, fontPackage: _p);


  // ── Maps & Travel ─────────────────────────────────────────────────

  /// binoculars icon.
  static const binoculars = IconData(0xe621, fontFamily: _f, fontPackage: _p);

  /// earth icon.
  static const earth = IconData(0xe1f3, fontFamily: _f, fontPackage: _p);

  /// earth-lock icon.
  static const earthLock = IconData(0xe5cc, fontFamily: _f, fontPackage: _p);

  /// flag icon.
  static const flag = IconData(0xe0d1, fontFamily: _f, fontPackage: _p);

  /// flag-off icon.
  static const flagOff = IconData(0xe292, fontFamily: _f, fontPackage: _p);

  /// globe icon.
  static const globe = IconData(0xe0e8, fontFamily: _f, fontPackage: _p);

  /// globe-2 icon.
  static const globe2 = IconData(0xe1f3, fontFamily: _f, fontPackage: _p);

  /// globe-lock icon.
  static const globeLock = IconData(0xe5cd, fontFamily: _f, fontPackage: _p);

  /// globe-off icon.
  static const globeOff = IconData(0xe6b5, fontFamily: _f, fontPackage: _p);

  /// globe-x icon.
  static const globeX = IconData(0xe6b6, fontFamily: _f, fontPackage: _p);

  /// hotel icon.
  static const hotel = IconData(0xe3e2, fontFamily: _f, fontPackage: _p);

  /// landmark icon.
  static const landmark = IconData(0xe23a, fontFamily: _f, fontPackage: _p);

  /// locate icon.
  static const locate = IconData(0xe1da, fontFamily: _f, fontPackage: _p);

  /// locate-fixed icon.
  static const locateFixed = IconData(0xe1db, fontFamily: _f, fontPackage: _p);

  /// locate-off icon.
  static const locateOff = IconData(0xe282, fontFamily: _f, fontPackage: _p);

  /// location-edit icon.
  static const locationEdit = IconData(0xe655, fontFamily: _f, fontPackage: _p);

  /// luggage icon.
  static const luggage = IconData(0xe2ca, fontFamily: _f, fontPackage: _p);

  /// map icon.
  static const map = IconData(0xe110, fontFamily: _f, fontPackage: _p);

  /// milestone icon.
  static const milestone = IconData(0xe298, fontFamily: _f, fontPackage: _p);

  /// plane icon.
  static const plane = IconData(0xe1de, fontFamily: _f, fontPackage: _p);

  /// plane-landing icon.
  static const planeLanding = IconData(0xe3cd, fontFamily: _f, fontPackage: _p);

  /// plane-takeoff icon.
  static const planeTakeoff = IconData(0xe3ce, fontFamily: _f, fontPackage: _p);

  /// table-of-contents icon.
  static const tableOfContents = IconData(0xe61e, fontFamily: _f, fontPackage: _p);

  /// tent icon.
  static const tent = IconData(0xe227, fontFamily: _f, fontPackage: _p);

  /// ticket icon.
  static const ticket = IconData(0xe20f, fontFamily: _f, fontPackage: _p);

  /// ticket-check icon.
  static const ticketCheck = IconData(0xe5ae, fontFamily: _f, fontPackage: _p);

  /// ticket-slash icon.
  static const ticketSlash = IconData(0xe5b2, fontFamily: _f, fontPackage: _p);

  /// ticket-x icon.
  static const ticketX = IconData(0xe5b3, fontFamily: _f, fontPackage: _p);

  /// tickets icon.
  static const tickets = IconData(0xe622, fontFamily: _f, fontPackage: _p);

  /// tickets-plane icon.
  static const ticketsPlane = IconData(0xe623, fontFamily: _f, fontPackage: _p);


  // ── Charts & Data ─────────────────────────────────────────────────

  /// activity icon.
  static const activity = IconData(0xe038, fontFamily: _f, fontPackage: _p);

  /// area-chart icon.
  static const areaChart = IconData(0xe4d3, fontFamily: _f, fontPackage: _p);

  /// bar-chart icon.
  static const barChart = IconData(0xe06a, fontFamily: _f, fontPackage: _p);

  /// bar-chart-2 icon.
  static const barChart2 = IconData(0xe068, fontFamily: _f, fontPackage: _p);

  /// bar-chart-3 icon.
  static const barChart3 = IconData(0xe2a3, fontFamily: _f, fontPackage: _p);

  /// bar-chart-4 icon.
  static const barChart4 = IconData(0xe2a4, fontFamily: _f, fontPackage: _p);

  /// bar-chart-big icon.
  static const barChartBig = IconData(0xe4a9, fontFamily: _f, fontPackage: _p);

  /// bar-chart-horizontal icon.
  static const barChartHorizontal = IconData(0xe2a2, fontFamily: _f, fontPackage: _p);

  /// bar-chart-horizontal-big icon.
  static const barChartHorizontalBig = IconData(0xe4a7, fontFamily: _f, fontPackage: _p);

  /// barcode icon.
  static const barcode = IconData(0xe533, fontFamily: _f, fontPackage: _p);

  /// barrel icon.
  static const barrel = IconData(0xe675, fontFamily: _f, fontPackage: _p);

  /// candlestick-chart icon.
  static const candlestickChart = IconData(0xe4a8, fontFamily: _f, fontPackage: _p);

  /// chart-area icon.
  static const chartArea = IconData(0xe4d3, fontFamily: _f, fontPackage: _p);

  /// chart-bar icon.
  static const chartBar = IconData(0xe2a2, fontFamily: _f, fontPackage: _p);

  /// chart-bar-big icon.
  static const chartBarBig = IconData(0xe4a7, fontFamily: _f, fontPackage: _p);

  /// chart-bar-decreasing icon.
  static const chartBarDecreasing = IconData(0xe607, fontFamily: _f, fontPackage: _p);

  /// chart-bar-increasing icon.
  static const chartBarIncreasing = IconData(0xe608, fontFamily: _f, fontPackage: _p);

  /// chart-bar-stacked icon.
  static const chartBarStacked = IconData(0xe609, fontFamily: _f, fontPackage: _p);

  /// chart-candlestick icon.
  static const chartCandlestick = IconData(0xe4a8, fontFamily: _f, fontPackage: _p);

  /// chart-gantt icon.
  static const chartGantt = IconData(0xe624, fontFamily: _f, fontPackage: _p);

  /// chart-line icon.
  static const chartLine = IconData(0xe2a5, fontFamily: _f, fontPackage: _p);

  /// chart-network icon.
  static const chartNetwork = IconData(0xe60b, fontFamily: _f, fontPackage: _p);

  /// chart-no-axes-combined icon.
  static const chartNoAxesCombined = IconData(0xe60c, fontFamily: _f, fontPackage: _p);

  /// chart-no-axes-gantt icon.
  static const chartNoAxesGantt = IconData(0xe4c4, fontFamily: _f, fontPackage: _p);

  /// chart-scatter icon.
  static const chartScatter = IconData(0xe48a, fontFamily: _f, fontPackage: _p);

  /// chart-spline icon.
  static const chartSpline = IconData(0xe60d, fontFamily: _f, fontPackage: _p);

  /// diameter icon.
  static const diameter = IconData(0xe526, fontFamily: _f, fontPackage: _p);

  /// gantt-chart icon.
  static const ganttChart = IconData(0xe4c4, fontFamily: _f, fontPackage: _p);

  /// gauge icon.
  static const gauge = IconData(0xe1bf, fontFamily: _f, fontPackage: _p);

  /// git-graph icon.
  static const gitGraph = IconData(0xe554, fontFamily: _f, fontPackage: _p);

  /// line-chart icon.
  static const lineChart = IconData(0xe2a5, fontFamily: _f, fontPackage: _p);

  /// parking-meter icon.
  static const parkingMeter = IconData(0xe500, fontFamily: _f, fontPackage: _p);

  /// scan-barcode icon.
  static const scanBarcode = IconData(0xe535, fontFamily: _f, fontPackage: _p);

  /// scatter-chart icon.
  static const scatterChart = IconData(0xe48a, fontFamily: _f, fontPackage: _p);

  /// trending-down icon.
  static const trendingDown = IconData(0xe190, fontFamily: _f, fontPackage: _p);

  /// trending-up icon.
  static const trendingUp = IconData(0xe191, fontFamily: _f, fontPackage: _p);

  /// trending-up-down icon.
  static const trendingUpDown = IconData(0xe625, fontFamily: _f, fontPackage: _p);


  // ── Devices & Hardware ────────────────────────────────────────────

  /// battery icon.
  static const battery = IconData(0xe053, fontFamily: _f, fontPackage: _p);

  /// battery-charging icon.
  static const batteryCharging = IconData(0xe054, fontFamily: _f, fontPackage: _p);

  /// battery-full icon.
  static const batteryFull = IconData(0xe055, fontFamily: _f, fontPackage: _p);

  /// battery-low icon.
  static const batteryLow = IconData(0xe056, fontFamily: _f, fontPackage: _p);

  /// battery-medium icon.
  static const batteryMedium = IconData(0xe057, fontFamily: _f, fontPackage: _p);

  /// battery-warning icon.
  static const batteryWarning = IconData(0xe3ac, fontFamily: _f, fontPackage: _p);

  /// bluetooth icon.
  static const bluetooth = IconData(0xe05c, fontFamily: _f, fontPackage: _p);

  /// bluetooth-connected icon.
  static const bluetoothConnected = IconData(0xe1b8, fontFamily: _f, fontPackage: _p);

  /// bluetooth-off icon.
  static const bluetoothOff = IconData(0xe1b9, fontFamily: _f, fontPackage: _p);

  /// bluetooth-searching icon.
  static const bluetoothSearching = IconData(0xe1ba, fontFamily: _f, fontPackage: _p);

  /// cable icon.
  static const cable = IconData(0xe4e3, fontFamily: _f, fontPackage: _p);

  /// cable-car icon.
  static const cableCar = IconData(0xe4fc, fontFamily: _f, fontPackage: _p);

  /// circuit-board icon.
  static const circuitBoard = IconData(0xe403, fontFamily: _f, fontPackage: _p);

  /// cpu icon.
  static const cpu = IconData(0xe0a9, fontFamily: _f, fontPackage: _p);

  /// database icon.
  static const database = IconData(0xe0ad, fontFamily: _f, fontPackage: _p);

  /// database-backup icon.
  static const databaseBackup = IconData(0xe3ab, fontFamily: _f, fontPackage: _p);

  /// database-search icon.
  static const databaseSearch = IconData(0xe6b1, fontFamily: _f, fontPackage: _p);

  /// database-zap icon.
  static const databaseZap = IconData(0xe50b, fontFamily: _f, fontPackage: _p);

  /// hard-drive icon.
  static const hardDrive = IconData(0xe0ed, fontFamily: _f, fontPackage: _p);

  /// hard-drive-download icon.
  static const hardDriveDownload = IconData(0xe4e5, fontFamily: _f, fontPackage: _p);

  /// hard-drive-upload icon.
  static const hardDriveUpload = IconData(0xe4e6, fontFamily: _f, fontPackage: _p);

  /// house-plug icon.
  static const housePlug = IconData(0xe5f0, fontFamily: _f, fontPackage: _p);

  /// house-wifi icon.
  static const houseWifi = IconData(0xe63c, fontFamily: _f, fontPackage: _p);

  /// keyboard icon.
  static const keyboard = IconData(0xe284, fontFamily: _f, fontPackage: _p);

  /// keyboard-off icon.
  static const keyboardOff = IconData(0xe5de, fontFamily: _f, fontPackage: _p);

  /// laptop icon.
  static const laptop = IconData(0xe1cd, fontFamily: _f, fontPackage: _p);

  /// laptop-2 icon.
  static const laptop2 = IconData(0xe1d8, fontFamily: _f, fontPackage: _p);

  /// laptop-minimal icon.
  static const laptopMinimal = IconData(0xe1d8, fontFamily: _f, fontPackage: _p);

  /// laptop-minimal-check icon.
  static const laptopMinimalCheck = IconData(0xe632, fontFamily: _f, fontPackage: _p);

  /// memory-stick icon.
  static const memoryStick = IconData(0xe445, fontFamily: _f, fontPackage: _p);

  /// monitor icon.
  static const monitor = IconData(0xe11d, fontFamily: _f, fontPackage: _p);

  /// monitor-check icon.
  static const monitorCheck = IconData(0xe482, fontFamily: _f, fontPackage: _p);

  /// monitor-cog icon.
  static const monitorCog = IconData(0xe603, fontFamily: _f, fontPackage: _p);

  /// monitor-dot icon.
  static const monitorDot = IconData(0xe483, fontFamily: _f, fontPackage: _p);

  /// monitor-down icon.
  static const monitorDown = IconData(0xe421, fontFamily: _f, fontPackage: _p);

  /// monitor-off icon.
  static const monitorOff = IconData(0xe1dc, fontFamily: _f, fontPackage: _p);

  /// monitor-up icon.
  static const monitorUp = IconData(0xe422, fontFamily: _f, fontPackage: _p);

  /// monitor-x icon.
  static const monitorX = IconData(0xe487, fontFamily: _f, fontPackage: _p);

  /// mouse icon.
  static const mouse = IconData(0xe28e, fontFamily: _f, fontPackage: _p);

  /// mouse-left icon.
  static const mouseLeft = IconData(0xe6bf, fontFamily: _f, fontPackage: _p);

  /// mouse-off icon.
  static const mouseOff = IconData(0xe5db, fontFamily: _f, fontPackage: _p);

  /// mouse-pointer icon.
  static const mousePointer = IconData(0xe11f, fontFamily: _f, fontPackage: _p);

  /// mouse-pointer-2 icon.
  static const mousePointer2 = IconData(0xe1c3, fontFamily: _f, fontPackage: _p);

  /// mouse-pointer-2-off icon.
  static const mousePointer2Off = IconData(0xe6a6, fontFamily: _f, fontPackage: _p);

  /// mouse-pointer-ban icon.
  static const mousePointerBan = IconData(0xe5e7, fontFamily: _f, fontPackage: _p);

  /// mouse-pointer-click icon.
  static const mousePointerClick = IconData(0xe120, fontFamily: _f, fontPackage: _p);

  /// mouse-right icon.
  static const mouseRight = IconData(0xe6c0, fontFamily: _f, fontPackage: _p);

  /// nfc icon.
  static const nfc = IconData(0xe3c3, fontFamily: _f, fontPackage: _p);

  /// plug icon.
  static const plug = IconData(0xe37f, fontFamily: _f, fontPackage: _p);

  /// plug-2 icon.
  static const plug2 = IconData(0xe380, fontFamily: _f, fontPackage: _p);

  /// plug-zap icon.
  static const plugZap = IconData(0xe45c, fontFamily: _f, fontPackage: _p);

  /// plug-zap-2 icon.
  static const plugZap2 = IconData(0xe45c, fontFamily: _f, fontPackage: _p);

  /// power icon.
  static const power = IconData(0xe140, fontFamily: _f, fontPackage: _p);

  /// power-off icon.
  static const powerOff = IconData(0xe209, fontFamily: _f, fontPackage: _p);

  /// printer icon.
  static const printer = IconData(0xe141, fontFamily: _f, fontPackage: _p);

  /// printer-check icon.
  static const printerCheck = IconData(0xe5f5, fontFamily: _f, fontPackage: _p);

  /// printer-x icon.
  static const printerX = IconData(0xe6c1, fontFamily: _f, fontPackage: _p);

  /// server icon.
  static const server = IconData(0xe153, fontFamily: _f, fontPackage: _p);

  /// server-cog icon.
  static const serverCog = IconData(0xe341, fontFamily: _f, fontPackage: _p);

  /// server-crash icon.
  static const serverCrash = IconData(0xe1e9, fontFamily: _f, fontPackage: _p);

  /// server-off icon.
  static const serverOff = IconData(0xe1ea, fontFamily: _f, fontPackage: _p);

  /// tablet icon.
  static const tablet = IconData(0xe17e, fontFamily: _f, fontPackage: _p);

  /// tablets icon.
  static const tablets = IconData(0xe3be, fontFamily: _f, fontPackage: _p);

  /// unplug icon.
  static const unplug = IconData(0xe45d, fontFamily: _f, fontPackage: _p);

  /// usb icon.
  static const usb = IconData(0xe356, fontFamily: _f, fontPackage: _p);

  /// wifi icon.
  static const wifi = IconData(0xe1ae, fontFamily: _f, fontPackage: _p);

  /// wifi-cog icon.
  static const wifiCog = IconData(0xe674, fontFamily: _f, fontPackage: _p);

  /// wifi-high icon.
  static const wifiHigh = IconData(0xe5f7, fontFamily: _f, fontPackage: _p);

  /// wifi-low icon.
  static const wifiLow = IconData(0xe5f8, fontFamily: _f, fontPackage: _p);

  /// wifi-off icon.
  static const wifiOff = IconData(0xe1af, fontFamily: _f, fontPackage: _p);

  /// wifi-pen icon.
  static const wifiPen = IconData(0xe663, fontFamily: _f, fontPackage: _p);

  /// wifi-sync icon.
  static const wifiSync = IconData(0xe681, fontFamily: _f, fontPackage: _p);

  /// wifi-zero icon.
  static const wifiZero = IconData(0xe5f9, fontFamily: _f, fontPackage: _p);


  // ── Development ───────────────────────────────────────────────────

  /// blocks icon.
  static const blocks = IconData(0xe4fa, fontFamily: _f, fontPackage: _p);

  /// braces icon.
  static const braces = IconData(0xe36a, fontFamily: _f, fontPackage: _p);

  /// brackets icon.
  static const brackets = IconData(0xe443, fontFamily: _f, fontPackage: _p);

  /// bug icon.
  static const bug = IconData(0xe20c, fontFamily: _f, fontPackage: _p);

  /// bug-off icon.
  static const bugOff = IconData(0xe50d, fontFamily: _f, fontPackage: _p);

  /// code icon.
  static const code = IconData(0xe093, fontFamily: _f, fontPackage: _p);

  /// code-2 icon.
  static const code2 = IconData(0xe206, fontFamily: _f, fontPackage: _p);

  /// code-xml icon.
  static const codeXml = IconData(0xe206, fontFamily: _f, fontPackage: _p);

  /// codepen icon.
  static const codepen = IconData(0xe094, fontFamily: _f, fontPackage: _p);

  /// codesandbox icon.
  static const codesandbox = IconData(0xe095, fontFamily: _f, fontPackage: _p);

  /// component icon.
  static const component = IconData(0xe2ad, fontFamily: _f, fontPackage: _p);

  /// container icon.
  static const container = IconData(0xe4d5, fontFamily: _f, fontPackage: _p);

  /// curly-braces icon.
  static const curlyBraces = IconData(0xe36a, fontFamily: _f, fontPackage: _p);

  /// git-branch icon.
  static const gitBranch = IconData(0xe0e2, fontFamily: _f, fontPackage: _p);

  /// git-commit icon.
  static const gitCommit = IconData(0xe0e3, fontFamily: _f, fontPackage: _p);

  /// git-commit-horizontal icon.
  static const gitCommitHorizontal = IconData(0xe0e3, fontFamily: _f, fontPackage: _p);

  /// git-commit-vertical icon.
  static const gitCommitVertical = IconData(0xe552, fontFamily: _f, fontPackage: _p);

  /// git-compare icon.
  static const gitCompare = IconData(0xe359, fontFamily: _f, fontPackage: _p);

  /// git-fork icon.
  static const gitFork = IconData(0xe28d, fontFamily: _f, fontPackage: _p);

  /// git-merge icon.
  static const gitMerge = IconData(0xe0e4, fontFamily: _f, fontPackage: _p);

  /// git-merge-conflict icon.
  static const gitMergeConflict = IconData(0xe6b4, fontFamily: _f, fontPackage: _p);

  /// git-pull-request icon.
  static const gitPullRequest = IconData(0xe0e5, fontFamily: _f, fontPackage: _p);

  /// git-pull-request-closed icon.
  static const gitPullRequestClosed = IconData(0xe35a, fontFamily: _f, fontPackage: _p);

  /// git-pull-request-create icon.
  static const gitPullRequestCreate = IconData(0xe556, fontFamily: _f, fontPackage: _p);

  /// github icon.
  static const github = IconData(0xe0e6, fontFamily: _f, fontPackage: _p);

  /// gitlab icon.
  static const gitlab = IconData(0xe0e7, fontFamily: _f, fontPackage: _p);

  /// inspect icon.
  static const inspect = IconData(0xe202, fontFamily: _f, fontPackage: _p);

  /// qr-code icon.
  static const qrCode = IconData(0xe1df, fontFamily: _f, fontPackage: _p);

  /// scan-qr-code icon.
  static const scanQrCode = IconData(0xe5f6, fontFamily: _f, fontPackage: _p);

  /// search-code icon.
  static const searchCode = IconData(0xe4ab, fontFamily: _f, fontPackage: _p);

  /// terminal icon.
  static const terminal = IconData(0xe181, fontFamily: _f, fontPackage: _p);

  /// variable icon.
  static const variable = IconData(0xe473, fontFamily: _f, fontPackage: _p);

  /// webhook icon.
  static const webhook = IconData(0xe374, fontFamily: _f, fontPackage: _p);

  /// webhook-off icon.
  static const webhookOff = IconData(0xe5b7, fontFamily: _f, fontPackage: _p);

  /// workflow icon.
  static const workflow = IconData(0xe425, fontFamily: _f, fontPackage: _p);

  /// zodiac-sagittarius icon.
  static const zodiacSagittarius = IconData(0xe6d4, fontFamily: _f, fontPackage: _p);


  // ── Security ──────────────────────────────────────────────────────

  /// alarm-clock icon.
  static const alarmClock = IconData(0xe03a, fontFamily: _f, fontPackage: _p);

  /// alarm-clock-check icon.
  static const alarmClockCheck = IconData(0xe1ec, fontFamily: _f, fontPackage: _p);

  /// alarm-clock-off icon.
  static const alarmClockOff = IconData(0xe23b, fontFamily: _f, fontPackage: _p);

  /// badge icon.
  static const badge = IconData(0xe474, fontFamily: _f, fontPackage: _p);

  /// badge-alert icon.
  static const badgeAlert = IconData(0xe475, fontFamily: _f, fontPackage: _p);

  /// badge-cent icon.
  static const badgeCent = IconData(0xe50f, fontFamily: _f, fontPackage: _p);

  /// badge-check icon.
  static const badgeCheck = IconData(0xe241, fontFamily: _f, fontPackage: _p);

  /// badge-dollar-sign icon.
  static const badgeDollarSign = IconData(0xe476, fontFamily: _f, fontPackage: _p);

  /// badge-euro icon.
  static const badgeEuro = IconData(0xe510, fontFamily: _f, fontPackage: _p);

  /// badge-help icon.
  static const badgeHelp = IconData(0xe47b, fontFamily: _f, fontPackage: _p);

  /// badge-indian-rupee icon.
  static const badgeIndianRupee = IconData(0xe511, fontFamily: _f, fontPackage: _p);

  /// badge-info icon.
  static const badgeInfo = IconData(0xe477, fontFamily: _f, fontPackage: _p);

  /// badge-japanese-yen icon.
  static const badgeJapaneseYen = IconData(0xe512, fontFamily: _f, fontPackage: _p);

  /// badge-pound-sterling icon.
  static const badgePoundSterling = IconData(0xe513, fontFamily: _f, fontPackage: _p);

  /// badge-question-mark icon.
  static const badgeQuestionMark = IconData(0xe47b, fontFamily: _f, fontPackage: _p);

  /// badge-russian-ruble icon.
  static const badgeRussianRuble = IconData(0xe514, fontFamily: _f, fontPackage: _p);

  /// badge-swiss-franc icon.
  static const badgeSwissFranc = IconData(0xe515, fontFamily: _f, fontPackage: _p);

  /// badge-turkish-lira icon.
  static const badgeTurkishLira = IconData(0xe67e, fontFamily: _f, fontPackage: _p);

  /// badge-x icon.
  static const badgeX = IconData(0xe47c, fontFamily: _f, fontPackage: _p);

  /// brick-wall-shield icon.
  static const brickWallShield = IconData(0xe690, fontFamily: _f, fontPackage: _p);

  /// calendar-clock icon.
  static const calendarClock = IconData(0xe304, fontFamily: _f, fontPackage: _p);

  /// clock icon.
  static const clock = IconData(0xe087, fontFamily: _f, fontPackage: _p);

  /// clock-1 icon.
  static const clock1 = IconData(0xe24b, fontFamily: _f, fontPackage: _p);

  /// clock-10 icon.
  static const clock10 = IconData(0xe24c, fontFamily: _f, fontPackage: _p);

  /// clock-11 icon.
  static const clock11 = IconData(0xe24d, fontFamily: _f, fontPackage: _p);

  /// clock-12 icon.
  static const clock12 = IconData(0xe24e, fontFamily: _f, fontPackage: _p);

  /// clock-2 icon.
  static const clock2 = IconData(0xe24f, fontFamily: _f, fontPackage: _p);

  /// clock-3 icon.
  static const clock3 = IconData(0xe250, fontFamily: _f, fontPackage: _p);

  /// clock-4 icon.
  static const clock4 = IconData(0xe251, fontFamily: _f, fontPackage: _p);

  /// clock-5 icon.
  static const clock5 = IconData(0xe252, fontFamily: _f, fontPackage: _p);

  /// clock-6 icon.
  static const clock6 = IconData(0xe253, fontFamily: _f, fontPackage: _p);

  /// clock-7 icon.
  static const clock7 = IconData(0xe254, fontFamily: _f, fontPackage: _p);

  /// clock-8 icon.
  static const clock8 = IconData(0xe255, fontFamily: _f, fontPackage: _p);

  /// clock-9 icon.
  static const clock9 = IconData(0xe256, fontFamily: _f, fontPackage: _p);

  /// clock-alert icon.
  static const clockAlert = IconData(0xe62a, fontFamily: _f, fontPackage: _p);

  /// clock-check icon.
  static const clockCheck = IconData(0xe69e, fontFamily: _f, fontPackage: _p);

  /// clock-fading icon.
  static const clockFading = IconData(0xe64a, fontFamily: _f, fontPackage: _p);

  /// door-closed-locked icon.
  static const doorClosedLocked = IconData(0xe664, fontFamily: _f, fontPackage: _p);

  /// eye icon.
  static const eye = IconData(0xe0ba, fontFamily: _f, fontPackage: _p);

  /// eye-closed icon.
  static const eyeClosed = IconData(0xe62e, fontFamily: _f, fontPackage: _p);

  /// eye-off icon.
  static const eyeOff = IconData(0xe0bb, fontFamily: _f, fontPackage: _p);

  /// fingerprint icon.
  static const fingerprint = IconData(0xe2cb, fontFamily: _f, fontPackage: _p);

  /// fingerprint-pattern icon.
  static const fingerprintPattern = IconData(0xe2cb, fontFamily: _f, fontPackage: _p);

  /// id-card icon.
  static const idCard = IconData(0xe617, fontFamily: _f, fontPackage: _p);

  /// id-card-lanyard icon.
  static const idCardLanyard = IconData(0xe670, fontFamily: _f, fontPackage: _p);

  /// key icon.
  static const key = IconData(0xe0fd, fontFamily: _f, fontPackage: _p);

  /// key-round icon.
  static const keyRound = IconData(0xe4a3, fontFamily: _f, fontPackage: _p);

  /// lock icon.
  static const lock = IconData(0xe10b, fontFamily: _f, fontPackage: _p);

  /// lock-keyhole icon.
  static const lockKeyhole = IconData(0xe531, fontFamily: _f, fontPackage: _p);

  /// lock-keyhole-open icon.
  static const lockKeyholeOpen = IconData(0xe532, fontFamily: _f, fontPackage: _p);

  /// lock-open icon.
  static const lockOpen = IconData(0xe10c, fontFamily: _f, fontPackage: _p);

  /// rotate-ccw-key icon.
  static const rotateCcwKey = IconData(0xe650, fontFamily: _f, fontPackage: _p);

  /// scan icon.
  static const scan = IconData(0xe257, fontFamily: _f, fontPackage: _p);

  /// scan-eye icon.
  static const scanEye = IconData(0xe536, fontFamily: _f, fontPackage: _p);

  /// scan-face icon.
  static const scanFace = IconData(0xe371, fontFamily: _f, fontPackage: _p);

  /// scan-line icon.
  static const scanLine = IconData(0xe258, fontFamily: _f, fontPackage: _p);

  /// scan-search icon.
  static const scanSearch = IconData(0xe537, fontFamily: _f, fontPackage: _p);

  /// shield icon.
  static const shield = IconData(0xe158, fontFamily: _f, fontPackage: _p);

  /// shield-alert icon.
  static const shieldAlert = IconData(0xe1fe, fontFamily: _f, fontPackage: _p);

  /// shield-ban icon.
  static const shieldBan = IconData(0xe159, fontFamily: _f, fontPackage: _p);

  /// shield-check icon.
  static const shieldCheck = IconData(0xe1ff, fontFamily: _f, fontPackage: _p);

  /// shield-close icon.
  static const shieldClose = IconData(0xe200, fontFamily: _f, fontPackage: _p);

  /// shield-ellipsis icon.
  static const shieldEllipsis = IconData(0xe516, fontFamily: _f, fontPackage: _p);

  /// shield-half icon.
  static const shieldHalf = IconData(0xe517, fontFamily: _f, fontPackage: _p);

  /// shield-off icon.
  static const shieldOff = IconData(0xe15a, fontFamily: _f, fontPackage: _p);

  /// shield-question icon.
  static const shieldQuestion = IconData(0xe40e, fontFamily: _f, fontPackage: _p);

  /// shield-question-mark icon.
  static const shieldQuestionMark = IconData(0xe40e, fontFamily: _f, fontPackage: _p);

  /// shield-user icon.
  static const shieldUser = IconData(0xe647, fontFamily: _f, fontPackage: _p);

  /// shield-x icon.
  static const shieldX = IconData(0xe200, fontFamily: _f, fontPackage: _p);

  /// unlock icon.
  static const unlock = IconData(0xe10c, fontFamily: _f, fontPackage: _p);

  /// unlock-keyhole icon.
  static const unlockKeyhole = IconData(0xe532, fontFamily: _f, fontPackage: _p);

  /// user-key icon.
  static const userKey = IconData(0xe6c8, fontFamily: _f, fontPackage: _p);

  /// user-lock icon.
  static const userLock = IconData(0xe660, fontFamily: _f, fontPackage: _p);

  /// user-round-key icon.
  static const userRoundKey = IconData(0xe6c9, fontFamily: _f, fontPackage: _p);


  // ── Users & People ────────────────────────────────────────────────

  /// accessibility icon.
  static const accessibility = IconData(0xe297, fontFamily: _f, fontPackage: _p);

  /// angry icon.
  static const angry = IconData(0xe2fc, fontFamily: _f, fontPackage: _p);

  /// annoyed icon.
  static const annoyed = IconData(0xe2fd, fontFamily: _f, fontPackage: _p);

  /// baby icon.
  static const baby = IconData(0xe2ce, fontFamily: _f, fontPackage: _p);

  /// ghost icon.
  static const ghost = IconData(0xe20e, fontFamily: _f, fontPackage: _p);

  /// hand icon.
  static const hand = IconData(0xe1d7, fontFamily: _f, fontPackage: _p);

  /// hand-coins icon.
  static const handCoins = IconData(0xe5b8, fontFamily: _f, fontPackage: _p);

  /// hand-fist icon.
  static const handFist = IconData(0xe68b, fontFamily: _f, fontPackage: _p);

  /// hand-grab icon.
  static const handGrab = IconData(0xe1e6, fontFamily: _f, fontPackage: _p);

  /// hand-metal icon.
  static const handMetal = IconData(0xe22c, fontFamily: _f, fontPackage: _p);

  /// hand-platter icon.
  static const handPlatter = IconData(0xe5ba, fontFamily: _f, fontPackage: _p);

  /// handbag icon.
  static const handbag = IconData(0xe689, fontFamily: _f, fontPackage: _p);

  /// handshake icon.
  static const handshake = IconData(0xe5c0, fontFamily: _f, fontPackage: _p);

  /// laugh icon.
  static const laugh = IconData(0xe300, fontFamily: _f, fontPackage: _p);

  /// meh icon.
  static const meh = IconData(0xe114, fontFamily: _f, fontPackage: _p);

  /// person-standing icon.
  static const personStanding = IconData(0xe21e, fontFamily: _f, fontPackage: _p);

  /// skull icon.
  static const skull = IconData(0xe221, fontFamily: _f, fontPackage: _p);

  /// smile icon.
  static const smile = IconData(0xe164, fontFamily: _f, fontPackage: _p);

  /// thumbs-down icon.
  static const thumbsDown = IconData(0xe189, fontFamily: _f, fontPackage: _p);

  /// thumbs-up icon.
  static const thumbsUp = IconData(0xe18a, fontFamily: _f, fontPackage: _p);

  /// user icon.
  static const user = IconData(0xe19f, fontFamily: _f, fontPackage: _p);

  /// user-2 icon.
  static const user2 = IconData(0xe468, fontFamily: _f, fontPackage: _p);

  /// user-check icon.
  static const userCheck = IconData(0xe1a0, fontFamily: _f, fontPackage: _p);

  /// user-check-2 icon.
  static const userCheck2 = IconData(0xe469, fontFamily: _f, fontPackage: _p);

  /// user-cog icon.
  static const userCog = IconData(0xe342, fontFamily: _f, fontPackage: _p);

  /// user-cog-2 icon.
  static const userCog2 = IconData(0xe46a, fontFamily: _f, fontPackage: _p);

  /// user-pen icon.
  static const userPen = IconData(0xe5fc, fontFamily: _f, fontPackage: _p);

  /// user-round icon.
  static const userRound = IconData(0xe468, fontFamily: _f, fontPackage: _p);

  /// user-round-check icon.
  static const userRoundCheck = IconData(0xe469, fontFamily: _f, fontPackage: _p);

  /// user-round-cog icon.
  static const userRoundCog = IconData(0xe46a, fontFamily: _f, fontPackage: _p);

  /// user-round-pen icon.
  static const userRoundPen = IconData(0xe5fd, fontFamily: _f, fontPackage: _p);

  /// user-round-search icon.
  static const userRoundSearch = IconData(0xe578, fontFamily: _f, fontPackage: _p);

  /// user-round-x icon.
  static const userRoundX = IconData(0xe46d, fontFamily: _f, fontPackage: _p);

  /// user-search icon.
  static const userSearch = IconData(0xe579, fontFamily: _f, fontPackage: _p);

  /// user-x icon.
  static const userX = IconData(0xe1a3, fontFamily: _f, fontPackage: _p);

  /// user-x-2 icon.
  static const userX2 = IconData(0xe46d, fontFamily: _f, fontPackage: _p);

  /// users icon.
  static const users = IconData(0xe1a4, fontFamily: _f, fontPackage: _p);

  /// users-2 icon.
  static const users2 = IconData(0xe46e, fontFamily: _f, fontPackage: _p);

  /// users-round icon.
  static const usersRound = IconData(0xe46e, fontFamily: _f, fontPackage: _p);


  // ── Shopping & Commerce ───────────────────────────────────────────

  /// baggage-claim icon.
  static const baggageClaim = IconData(0xe2c9, fontFamily: _f, fontPackage: _p);

  /// banknote icon.
  static const banknote = IconData(0xe052, fontFamily: _f, fontPackage: _p);

  /// banknote-x icon.
  static const banknoteX = IconData(0xe64e, fontFamily: _f, fontPackage: _p);

  /// bitcoin icon.
  static const bitcoin = IconData(0xe05b, fontFamily: _f, fontPackage: _p);

  /// chess-bishop icon.
  static const chessBishop = IconData(0xe6a0, fontFamily: _f, fontPackage: _p);

  /// coins icon.
  static const coins = IconData(0xe097, fontFamily: _f, fontPackage: _p);

  /// credit-card icon.
  static const creditCard = IconData(0xe0aa, fontFamily: _f, fontPackage: _p);

  /// dollar-sign icon.
  static const dollarSign = IconData(0xe0b1, fontFamily: _f, fontPackage: _p);

  /// euro icon.
  static const euro = IconData(0xe0b8, fontFamily: _f, fontPackage: _p);

  /// gift icon.
  static const gift = IconData(0xe0e1, fontFamily: _f, fontPackage: _p);

  /// instagram icon.
  static const instagram = IconData(0xe0fa, fontFamily: _f, fontPackage: _p);

  /// package icon.
  static const package = IconData(0xe129, fontFamily: _f, fontPackage: _p);

  /// package-2 icon.
  static const package2 = IconData(0xe340, fontFamily: _f, fontPackage: _p);

  /// package-check icon.
  static const packageCheck = IconData(0xe266, fontFamily: _f, fontPackage: _p);

  /// package-open icon.
  static const packageOpen = IconData(0xe2cc, fontFamily: _f, fontPackage: _p);

  /// package-search icon.
  static const packageSearch = IconData(0xe269, fontFamily: _f, fontPackage: _p);

  /// package-x icon.
  static const packageX = IconData(0xe26a, fontFamily: _f, fontPackage: _p);

  /// pound-sterling icon.
  static const poundSterling = IconData(0xe13f, fontFamily: _f, fontPackage: _p);

  /// receipt icon.
  static const receipt = IconData(0xe3d3, fontFamily: _f, fontPackage: _p);

  /// receipt-cent icon.
  static const receiptCent = IconData(0xe5a5, fontFamily: _f, fontPackage: _p);

  /// receipt-euro icon.
  static const receiptEuro = IconData(0xe5a6, fontFamily: _f, fontPackage: _p);

  /// receipt-indian-rupee icon.
  static const receiptIndianRupee = IconData(0xe5a7, fontFamily: _f, fontPackage: _p);

  /// receipt-japanese-yen icon.
  static const receiptJapaneseYen = IconData(0xe5a8, fontFamily: _f, fontPackage: _p);

  /// receipt-pound-sterling icon.
  static const receiptPoundSterling = IconData(0xe5a9, fontFamily: _f, fontPackage: _p);

  /// receipt-russian-ruble icon.
  static const receiptRussianRuble = IconData(0xe5aa, fontFamily: _f, fontPackage: _p);

  /// receipt-swiss-franc icon.
  static const receiptSwissFranc = IconData(0xe5ab, fontFamily: _f, fontPackage: _p);

  /// receipt-turkish-lira icon.
  static const receiptTurkishLira = IconData(0xe67f, fontFamily: _f, fontPackage: _p);

  /// store icon.
  static const store = IconData(0xe3e4, fontFamily: _f, fontPackage: _p);

  /// tag icon.
  static const tag = IconData(0xe17f, fontFamily: _f, fontPackage: _p);

  /// tags icon.
  static const tags = IconData(0xe35c, fontFamily: _f, fontPackage: _p);

  /// truck icon.
  static const truck = IconData(0xe194, fontFamily: _f, fontPackage: _p);

  /// truck-electric icon.
  static const truckElectric = IconData(0xe65f, fontFamily: _f, fontPackage: _p);

  /// wallet icon.
  static const wallet = IconData(0xe204, fontFamily: _f, fontPackage: _p);

  /// wallet-2 icon.
  static const wallet2 = IconData(0xe4cd, fontFamily: _f, fontPackage: _p);

  /// wallet-cards icon.
  static const walletCards = IconData(0xe4cc, fontFamily: _f, fontPackage: _p);

  /// wallet-minimal icon.
  static const walletMinimal = IconData(0xe4cd, fontFamily: _f, fontPackage: _p);


  // ── Medical & Health ──────────────────────────────────────────────

  /// ambulance icon.
  static const ambulance = IconData(0xe5bb, fontFamily: _f, fontPackage: _p);

  /// bandage icon.
  static const bandage = IconData(0xe61d, fontFamily: _f, fontPackage: _p);

  /// cross icon.
  static const cross = IconData(0xe1e5, fontFamily: _f, fontPackage: _p);

  /// crosshair icon.
  static const crosshair = IconData(0xe0ac, fontFamily: _f, fontPackage: _p);

  /// dna icon.
  static const dna = IconData(0xe393, fontFamily: _f, fontPackage: _p);

  /// dna-off icon.
  static const dnaOff = IconData(0xe394, fontFamily: _f, fontPackage: _p);

  /// fork-knife-crossed icon.
  static const forkKnifeCrossed = IconData(0xe2f7, fontFamily: _f, fontPackage: _p);

  /// stethoscope icon.
  static const stethoscope = IconData(0xe2f1, fontFamily: _f, fontPackage: _p);

  /// syringe icon.
  static const syringe = IconData(0xe2f2, fontFamily: _f, fontPackage: _p);

  /// utensils-crossed icon.
  static const utensilsCrossed = IconData(0xe2f7, fontFamily: _f, fontPackage: _p);


  // ── Food & Drink ──────────────────────────────────────────────────

  /// apple icon.
  static const apple = IconData(0xe34e, fontFamily: _f, fontPackage: _p);

  /// banana icon.
  static const banana = IconData(0xe34f, fontFamily: _f, fontPackage: _p);

  /// beef icon.
  static const beef = IconData(0xe3a5, fontFamily: _f, fontPackage: _p);

  /// beer icon.
  static const beer = IconData(0xe2cf, fontFamily: _f, fontPackage: _p);

  /// beer-off icon.
  static const beerOff = IconData(0xe5d9, fontFamily: _f, fontPackage: _p);

  /// bottle-wine icon.
  static const bottleWine = IconData(0xe67b, fontFamily: _f, fontPackage: _p);

  /// cake icon.
  static const cake = IconData(0xe344, fontFamily: _f, fontPackage: _p);

  /// cake-slice icon.
  static const cakeSlice = IconData(0xe4b9, fontFamily: _f, fontPackage: _p);

  /// candy icon.
  static const candy = IconData(0xe391, fontFamily: _f, fontPackage: _p);

  /// candy-cane icon.
  static const candyCane = IconData(0xe4ba, fontFamily: _f, fontPackage: _p);

  /// candy-off icon.
  static const candyOff = IconData(0xe392, fontFamily: _f, fontPackage: _p);

  /// carrot icon.
  static const carrot = IconData(0xe25a, fontFamily: _f, fontPackage: _p);

  /// cherry icon.
  static const cherry = IconData(0xe350, fontFamily: _f, fontPackage: _p);

  /// citrus icon.
  static const citrus = IconData(0xe375, fontFamily: _f, fontPackage: _p);

  /// coffee icon.
  static const coffee = IconData(0xe096, fontFamily: _f, fontPackage: _p);

  /// cookie icon.
  static const cookie = IconData(0xe26b, fontFamily: _f, fontPackage: _p);

  /// cup-soda icon.
  static const cupSoda = IconData(0xe2d1, fontFamily: _f, fontPackage: _p);

  /// donut icon.
  static const donut = IconData(0xe4bc, fontFamily: _f, fontPackage: _p);

  /// egg icon.
  static const egg = IconData(0xe25d, fontFamily: _f, fontPackage: _p);

  /// egg-fried icon.
  static const eggFried = IconData(0xe351, fontFamily: _f, fontPackage: _p);

  /// egg-off icon.
  static const eggOff = IconData(0xe395, fontFamily: _f, fontPackage: _p);

  /// fish icon.
  static const fish = IconData(0xe3a6, fontFamily: _f, fontPackage: _p);

  /// fish-off icon.
  static const fishOff = IconData(0xe3b0, fontFamily: _f, fontPackage: _p);

  /// fish-symbol icon.
  static const fishSymbol = IconData(0xe4f4, fontFamily: _f, fontPackage: _p);

  /// fishing-hook icon.
  static const fishingHook = IconData(0xe6af, fontFamily: _f, fontPackage: _p);

  /// fishing-rod icon.
  static const fishingRod = IconData(0xe6b3, fontFamily: _f, fontPackage: _p);

  /// grape icon.
  static const grape = IconData(0xe352, fontFamily: _f, fontPackage: _p);

  /// ham icon.
  static const ham = IconData(0xe5d7, fontFamily: _f, fontPackage: _p);

  /// hamburger icon.
  static const hamburger = IconData(0xe665, fontFamily: _f, fontPackage: _p);

  /// hammer icon.
  static const hammer = IconData(0xe0ec, fontFamily: _f, fontPackage: _p);

  /// ice-cream icon.
  static const iceCream = IconData(0xe353, fontFamily: _f, fontPackage: _p);

  /// ice-cream-2 icon.
  static const iceCream2 = IconData(0xe3a7, fontFamily: _f, fontPackage: _p);

  /// ice-cream-bowl icon.
  static const iceCreamBowl = IconData(0xe3a7, fontFamily: _f, fontPackage: _p);

  /// ice-cream-cone icon.
  static const iceCreamCone = IconData(0xe353, fontFamily: _f, fontPackage: _p);

  /// lollipop icon.
  static const lollipop = IconData(0xe4bd, fontFamily: _f, fontPackage: _p);

  /// milk icon.
  static const milk = IconData(0xe399, fontFamily: _f, fontPackage: _p);

  /// milk-off icon.
  static const milkOff = IconData(0xe39a, fontFamily: _f, fontPackage: _p);

  /// nut icon.
  static const nut = IconData(0xe39b, fontFamily: _f, fontPackage: _p);

  /// nut-off icon.
  static const nutOff = IconData(0xe39c, fontFamily: _f, fontPackage: _p);

  /// popcorn icon.
  static const popcorn = IconData(0xe4be, fontFamily: _f, fontPackage: _p);

  /// salad icon.
  static const salad = IconData(0xe3a8, fontFamily: _f, fontPackage: _p);

  /// sandwich icon.
  static const sandwich = IconData(0xe3a9, fontFamily: _f, fontPackage: _p);

  /// soup icon.
  static const soup = IconData(0xe3aa, fontFamily: _f, fontPackage: _p);

  /// utensils icon.
  static const utensils = IconData(0xe2f6, fontFamily: _f, fontPackage: _p);

  /// wheat icon.
  static const wheat = IconData(0xe39e, fontFamily: _f, fontPackage: _p);

  /// wheat-off icon.
  static const wheatOff = IconData(0xe39f, fontFamily: _f, fontPackage: _p);

  /// wine icon.
  static const wine = IconData(0xe2f8, fontFamily: _f, fontPackage: _p);

  /// wine-off icon.
  static const wineOff = IconData(0xe3a0, fontFamily: _f, fontPackage: _p);


  // ── Animals ───────────────────────────────────────────────────────

  /// bird icon.
  static const bird = IconData(0xe3c5, fontFamily: _f, fontPackage: _p);

  /// birdhouse icon.
  static const birdhouse = IconData(0xe69a, fontFamily: _f, fontPackage: _p);

  /// cat icon.
  static const cat = IconData(0xe38c, fontFamily: _f, fontPackage: _p);

  /// chess-pawn icon.
  static const chessPawn = IconData(0xe6a3, fontFamily: _f, fontPackage: _p);

  /// dog icon.
  static const dog = IconData(0xe38d, fontFamily: _f, fontPackage: _p);

  /// iteration-ccw icon.
  static const iterationCcw = IconData(0xe423, fontFamily: _f, fontPackage: _p);

  /// iteration-cw icon.
  static const iterationCw = IconData(0xe424, fontFamily: _f, fontPackage: _p);

  /// paw-print icon.
  static const pawPrint = IconData(0xe4f5, fontFamily: _f, fontPackage: _p);

  /// rabbit icon.
  static const rabbit = IconData(0xe4f6, fontFamily: _f, fontPackage: _p);

  /// rat icon.
  static const rat = IconData(0xe3eb, fontFamily: _f, fontPackage: _p);

  /// ratio icon.
  static const ratio = IconData(0xe4e8, fontFamily: _f, fontPackage: _p);

  /// refrigerator icon.
  static const refrigerator = IconData(0xe37b, fontFamily: _f, fontPackage: _p);

  /// snail icon.
  static const snail = IconData(0xe4f8, fontFamily: _f, fontPackage: _p);

  /// squirrel icon.
  static const squirrel = IconData(0xe49f, fontFamily: _f, fontPackage: _p);

  /// turtle icon.
  static const turtle = IconData(0xe4f9, fontFamily: _f, fontPackage: _p);

  /// vibrate icon.
  static const vibrate = IconData(0xe223, fontFamily: _f, fontPackage: _p);

  /// vibrate-off icon.
  static const vibrateOff = IconData(0xe29d, fontFamily: _f, fontPackage: _p);


  // ── Buildings ─────────────────────────────────────────────────────

  /// brick-wall icon.
  static const brickWall = IconData(0xe581, fontFamily: _f, fontPackage: _p);

  /// building icon.
  static const building = IconData(0xe1cc, fontFamily: _f, fontPackage: _p);

  /// building-2 icon.
  static const building2 = IconData(0xe290, fontFamily: _f, fontPackage: _p);

  /// church icon.
  static const church = IconData(0xe3e1, fontFamily: _f, fontPackage: _p);

  /// construction icon.
  static const construction = IconData(0xe3b4, fontFamily: _f, fontPackage: _p);

  /// door-closed icon.
  static const doorClosed = IconData(0xe3d5, fontFamily: _f, fontPackage: _p);

  /// door-open icon.
  static const doorOpen = IconData(0xe3d6, fontFamily: _f, fontPackage: _p);

  /// factory icon.
  static const factory = IconData(0xe29f, fontFamily: _f, fontPackage: _p);

  /// fence icon.
  static const fence = IconData(0xe582, fontFamily: _f, fontPackage: _p);

  /// home icon.
  static const home = IconData(0xe0f5, fontFamily: _f, fontPackage: _p);

  /// house icon.
  static const house = IconData(0xe0f5, fontFamily: _f, fontPackage: _p);

  /// school icon.
  static const school = IconData(0xe3e3, fontFamily: _f, fontPackage: _p);

  /// school-2 icon.
  static const school2 = IconData(0xe3e5, fontFamily: _f, fontPackage: _p);

  /// toy-brick icon.
  static const toyBrick = IconData(0xe347, fontFamily: _f, fontPackage: _p);

  /// warehouse icon.
  static const warehouse = IconData(0xe3e6, fontFamily: _f, fontPackage: _p);


  // ── Vehicles & Transport ──────────────────────────────────────────

  /// bike icon.
  static const bike = IconData(0xe1d2, fontFamily: _f, fontPackage: _p);

  /// bus icon.
  static const bus = IconData(0xe1d4, fontFamily: _f, fontPackage: _p);

  /// bus-front icon.
  static const busFront = IconData(0xe4fb, fontFamily: _f, fontPackage: _p);

  /// car icon.
  static const car = IconData(0xe1d5, fontFamily: _f, fontPackage: _p);

  /// car-front icon.
  static const carFront = IconData(0xe4fd, fontFamily: _f, fontPackage: _p);

  /// car-taxi-front icon.
  static const carTaxiFront = IconData(0xe4fe, fontFamily: _f, fontPackage: _p);

  /// caravan icon.
  static const caravan = IconData(0xe539, fontFamily: _f, fontPackage: _p);

  /// card-sim icon.
  static const cardSim = IconData(0xe671, fontFamily: _f, fontPackage: _p);

  /// forklift icon.
  static const forklift = IconData(0xe3c1, fontFamily: _f, fontPackage: _p);

  /// fuel icon.
  static const fuel = IconData(0xe2af, fontFamily: _f, fontPackage: _p);

  /// motorbike icon.
  static const motorbike = IconData(0xe698, fontFamily: _f, fontPackage: _p);

  /// rocket icon.
  static const rocket = IconData(0xe286, fontFamily: _f, fontPackage: _p);

  /// sailboat icon.
  static const sailboat = IconData(0xe37e, fontFamily: _f, fontPackage: _p);

  /// ship icon.
  static const ship = IconData(0xe3ba, fontFamily: _f, fontPackage: _p);

  /// ship-wheel icon.
  static const shipWheel = IconData(0xe502, fontFamily: _f, fontPackage: _p);

  /// tractor icon.
  static const tractor = IconData(0xe504, fontFamily: _f, fontPackage: _p);


  // ── Tools & Utilities ─────────────────────────────────────────────

  /// alarm-check icon.
  static const alarmCheck = IconData(0xe1ec, fontFamily: _f, fontPackage: _p);

  /// alarm-smoke icon.
  static const alarmSmoke = IconData(0xe57b, fontFamily: _f, fontPackage: _p);

  /// axe icon.
  static const axe = IconData(0xe050, fontFamily: _f, fontPackage: _p);

  /// axis-3-d icon.
  static const axis3D = IconData(0xe2fe, fontFamily: _f, fontPackage: _p);

  /// axis-3d icon.
  static const axis3d = IconData(0xe2fe, fontFamily: _f, fontPackage: _p);

  /// ban icon.
  static const ban = IconData(0xe051, fontFamily: _f, fontPackage: _p);

  /// biceps-flexed icon.
  static const bicepsFlexed = IconData(0xe5eb, fontFamily: _f, fontPackage: _p);

  /// bolt icon.
  static const bolt = IconData(0xe58c, fontFamily: _f, fontPackage: _p);

  /// boom-box icon.
  static const boomBox = IconData(0xe4ee, fontFamily: _f, fontPackage: _p);

  /// box icon.
  static const box = IconData(0xe061, fontFamily: _f, fontPackage: _p);

  /// box-select icon.
  static const boxSelect = IconData(0xe1cb, fontFamily: _f, fontPackage: _p);

  /// boxes icon.
  static const boxes = IconData(0xe2d0, fontFamily: _f, fontPackage: _p);

  /// brush icon.
  static const brush = IconData(0xe1d3, fontFamily: _f, fontPackage: _p);

  /// brush-cleaning icon.
  static const brushCleaning = IconData(0xe666, fontFamily: _f, fontPackage: _p);

  /// calendar icon.
  static const calendar = IconData(0xe063, fontFamily: _f, fontPackage: _p);

  /// calendar-1 icon.
  static const calendar1 = IconData(0xe630, fontFamily: _f, fontPackage: _p);

  /// calendar-check icon.
  static const calendarCheck = IconData(0xe2b7, fontFamily: _f, fontPackage: _p);

  /// calendar-check-2 icon.
  static const calendarCheck2 = IconData(0xe2b8, fontFamily: _f, fontPackage: _p);

  /// calendar-cog icon.
  static const calendarCog = IconData(0xe5ed, fontFamily: _f, fontPackage: _p);

  /// calendar-days icon.
  static const calendarDays = IconData(0xe2b9, fontFamily: _f, fontPackage: _p);

  /// calendar-fold icon.
  static const calendarFold = IconData(0xe5b4, fontFamily: _f, fontPackage: _p);

  /// calendar-off icon.
  static const calendarOff = IconData(0xe2bb, fontFamily: _f, fontPackage: _p);

  /// calendar-range icon.
  static const calendarRange = IconData(0xe2bd, fontFamily: _f, fontPackage: _p);

  /// calendar-search icon.
  static const calendarSearch = IconData(0xe306, fontFamily: _f, fontPackage: _p);

  /// calendar-sync icon.
  static const calendarSync = IconData(0xe636, fontFamily: _f, fontPackage: _p);

  /// calendar-x icon.
  static const calendarX = IconData(0xe2be, fontFamily: _f, fontPackage: _p);

  /// calendar-x-2 icon.
  static const calendarX2 = IconData(0xe2bf, fontFamily: _f, fontPackage: _p);

  /// calendars icon.
  static const calendars = IconData(0xe6a7, fontFamily: _f, fontPackage: _p);

  /// check icon.
  static const check = IconData(0xe06c, fontFamily: _f, fontPackage: _p);

  /// check-check icon.
  static const checkCheck = IconData(0xe38e, fontFamily: _f, fontPackage: _p);

  /// check-line icon.
  static const checkLine = IconData(0xe66b, fontFamily: _f, fontPackage: _p);

  /// cog icon.
  static const cog = IconData(0xe30b, fontFamily: _f, fontPackage: _p);

  /// crop icon.
  static const crop = IconData(0xe0ab, fontFamily: _f, fontPackage: _p);

  /// delete icon.
  static const delete = IconData(0xe0ae, fontFamily: _f, fontPackage: _p);

  /// diff icon.
  static const diff = IconData(0xe30c, fontFamily: _f, fontPackage: _p);

  /// download icon.
  static const download = IconData(0xe0b2, fontFamily: _f, fontPackage: _p);

  /// drill icon.
  static const drill = IconData(0xe58d, fontFamily: _f, fontPackage: _p);

  /// eraser icon.
  static const eraser = IconData(0xe28f, fontFamily: _f, fontPackage: _p);

  /// expand icon.
  static const expand = IconData(0xe21a, fontFamily: _f, fontPackage: _p);

  /// external-link icon.
  static const externalLink = IconData(0xe0b9, fontFamily: _f, fontPackage: _p);

  /// filter icon.
  static const filter = IconData(0xe0dc, fontFamily: _f, fontPackage: _p);

  /// filter-x icon.
  static const filterX = IconData(0xe3b5, fontFamily: _f, fontPackage: _p);

  /// flashlight icon.
  static const flashlight = IconData(0xe0d3, fontFamily: _f, fontPackage: _p);

  /// flashlight-off icon.
  static const flashlightOff = IconData(0xe0d4, fontFamily: _f, fontPackage: _p);

  /// flip-horizontal icon.
  static const flipHorizontal = IconData(0xe35d, fontFamily: _f, fontPackage: _p);

  /// flip-horizontal-2 icon.
  static const flipHorizontal2 = IconData(0xe35e, fontFamily: _f, fontPackage: _p);

  /// flip-vertical icon.
  static const flipVertical = IconData(0xe35f, fontFamily: _f, fontPackage: _p);

  /// flip-vertical-2 icon.
  static const flipVertical2 = IconData(0xe360, fontFamily: _f, fontPackage: _p);

  /// fork-knife icon.
  static const forkKnife = IconData(0xe2f6, fontFamily: _f, fontPackage: _p);

  /// funnel icon.
  static const funnel = IconData(0xe0dc, fontFamily: _f, fontPackage: _p);

  /// funnel-x icon.
  static const funnelX = IconData(0xe3b5, fontFamily: _f, fontPackage: _p);

  /// highlighter icon.
  static const highlighter = IconData(0xe0f4, fontFamily: _f, fontPackage: _p);

  /// history icon.
  static const history = IconData(0xe1f5, fontFamily: _f, fontPackage: _p);

  /// hourglass icon.
  static const hourglass = IconData(0xe296, fontFamily: _f, fontPackage: _p);

  /// lamp icon.
  static const lamp = IconData(0xe2d8, fontFamily: _f, fontPackage: _p);

  /// lamp-ceiling icon.
  static const lampCeiling = IconData(0xe2d9, fontFamily: _f, fontPackage: _p);

  /// lamp-desk icon.
  static const lampDesk = IconData(0xe2da, fontFamily: _f, fontPackage: _p);

  /// lamp-floor icon.
  static const lampFloor = IconData(0xe2db, fontFamily: _f, fontPackage: _p);

  /// lamp-wall-down icon.
  static const lampWallDown = IconData(0xe2dc, fontFamily: _f, fontPackage: _p);

  /// lamp-wall-up icon.
  static const lampWallUp = IconData(0xe2dd, fontFamily: _f, fontPackage: _p);

  /// lens-convex icon.
  static const lensConvex = IconData(0xe6b8, fontFamily: _f, fontPackage: _p);

  /// lightbulb icon.
  static const lightbulb = IconData(0xe1c2, fontFamily: _f, fontPackage: _p);

  /// lightbulb-off icon.
  static const lightbulbOff = IconData(0xe208, fontFamily: _f, fontPackage: _p);

  /// link icon.
  static const link = IconData(0xe102, fontFamily: _f, fontPackage: _p);

  /// link-2 icon.
  static const link2 = IconData(0xe103, fontFamily: _f, fontPackage: _p);

  /// link-2-off icon.
  static const link2Off = IconData(0xe104, fontFamily: _f, fontPackage: _p);

  /// linkedin icon.
  static const linkedin = IconData(0xe105, fontFamily: _f, fontPackage: _p);

  /// log-in icon.
  static const logIn = IconData(0xe10d, fontFamily: _f, fontPackage: _p);

  /// log-out icon.
  static const logOut = IconData(0xe10e, fontFamily: _f, fontPackage: _p);

  /// logs icon.
  static const logs = IconData(0xe5f4, fontFamily: _f, fontPackage: _p);

  /// magnet icon.
  static const magnet = IconData(0xe2b5, fontFamily: _f, fontPackage: _p);

  /// maximize icon.
  static const maximize = IconData(0xe112, fontFamily: _f, fontPackage: _p);

  /// maximize-2 icon.
  static const maximize2 = IconData(0xe113, fontFamily: _f, fontPackage: _p);

  /// merge icon.
  static const merge = IconData(0xe43f, fontFamily: _f, fontPackage: _p);

  /// minimize icon.
  static const minimize = IconData(0xe11a, fontFamily: _f, fontPackage: _p);

  /// minimize-2 icon.
  static const minimize2 = IconData(0xe11b, fontFamily: _f, fontPackage: _p);

  /// paint-bucket icon.
  static const paintBucket = IconData(0xe2e6, fontFamily: _f, fontPackage: _p);

  /// paint-roller icon.
  static const paintRoller = IconData(0xe59e, fontFamily: _f, fontPackage: _p);

  /// paintbrush icon.
  static const paintbrush = IconData(0xe2e7, fontFamily: _f, fontPackage: _p);

  /// paintbrush-2 icon.
  static const paintbrush2 = IconData(0xe2e8, fontFamily: _f, fontPackage: _p);

  /// paintbrush-vertical icon.
  static const paintbrushVertical = IconData(0xe2e8, fontFamily: _f, fontPackage: _p);

  /// palette icon.
  static const palette = IconData(0xe1dd, fontFamily: _f, fontPackage: _p);

  /// pen icon.
  static const pen = IconData(0xe12f, fontFamily: _f, fontPackage: _p);

  /// pen-box icon.
  static const penBox = IconData(0xe172, fontFamily: _f, fontPackage: _p);

  /// pen-line icon.
  static const penLine = IconData(0xe130, fontFamily: _f, fontPackage: _p);

  /// pen-off icon.
  static const penOff = IconData(0xe5ee, fontFamily: _f, fontPackage: _p);

  /// pen-tool icon.
  static const penTool = IconData(0xe131, fontFamily: _f, fontPackage: _p);

  /// pencil icon.
  static const pencil = IconData(0xe1f9, fontFamily: _f, fontPackage: _p);

  /// pencil-line icon.
  static const pencilLine = IconData(0xe4f0, fontFamily: _f, fontPackage: _p);

  /// pencil-off icon.
  static const pencilOff = IconData(0xe5ef, fontFamily: _f, fontPackage: _p);

  /// pencil-ruler icon.
  static const pencilRuler = IconData(0xe4f1, fontFamily: _f, fontPackage: _p);

  /// pocket-knife icon.
  static const pocketKnife = IconData(0xe4a0, fontFamily: _f, fontPackage: _p);

  /// recycle icon.
  static const recycle = IconData(0xe2e9, fontFamily: _f, fontPackage: _p);

  /// refresh-ccw icon.
  static const refreshCcw = IconData(0xe144, fontFamily: _f, fontPackage: _p);

  /// refresh-ccw-dot icon.
  static const refreshCcwDot = IconData(0xe4b2, fontFamily: _f, fontPackage: _p);

  /// refresh-cw icon.
  static const refreshCw = IconData(0xe145, fontFamily: _f, fontPackage: _p);

  /// refresh-cw-off icon.
  static const refreshCwOff = IconData(0xe498, fontFamily: _f, fontPackage: _p);

  /// repeat icon.
  static const repeat = IconData(0xe146, fontFamily: _f, fontPackage: _p);

  /// repeat-1 icon.
  static const repeat1 = IconData(0xe1fd, fontFamily: _f, fontPackage: _p);

  /// repeat-2 icon.
  static const repeat2 = IconData(0xe411, fontFamily: _f, fontPackage: _p);

  /// replace icon.
  static const replace = IconData(0xe3db, fontFamily: _f, fontPackage: _p);

  /// replace-all icon.
  static const replaceAll = IconData(0xe3dc, fontFamily: _f, fontPackage: _p);

  /// rotate-3-d icon.
  static const rotate3D = IconData(0xe2ea, fontFamily: _f, fontPackage: _p);

  /// rotate-3d icon.
  static const rotate3d = IconData(0xe2ea, fontFamily: _f, fontPackage: _p);

  /// rotate-ccw icon.
  static const rotateCcw = IconData(0xe148, fontFamily: _f, fontPackage: _p);

  /// rotate-cw icon.
  static const rotateCw = IconData(0xe149, fontFamily: _f, fontPackage: _p);

  /// ruler icon.
  static const ruler = IconData(0xe14b, fontFamily: _f, fontPackage: _p);

  /// ruler-dimension-line icon.
  static const rulerDimensionLine = IconData(0xe662, fontFamily: _f, fontPackage: _p);

  /// scissors icon.
  static const scissors = IconData(0xe14e, fontFamily: _f, fontPackage: _p);

  /// scissors-line-dashed icon.
  static const scissorsLineDashed = IconData(0xe4e9, fontFamily: _f, fontPackage: _p);

  /// search icon.
  static const search = IconData(0xe151, fontFamily: _f, fontPackage: _p);

  /// search-alert icon.
  static const searchAlert = IconData(0xe6af, fontFamily: _f, fontPackage: _p);

  /// search-check icon.
  static const searchCheck = IconData(0xe4aa, fontFamily: _f, fontPackage: _p);

  /// search-slash icon.
  static const searchSlash = IconData(0xe4ac, fontFamily: _f, fontPackage: _p);

  /// search-x icon.
  static const searchX = IconData(0xe4ad, fontFamily: _f, fontPackage: _p);

  /// settings icon.
  static const settings = IconData(0xe154, fontFamily: _f, fontPackage: _p);

  /// settings-2 icon.
  static const settings2 = IconData(0xe245, fontFamily: _f, fontPackage: _p);

  /// share icon.
  static const share = IconData(0xe155, fontFamily: _f, fontPackage: _p);

  /// share-2 icon.
  static const share2 = IconData(0xe156, fontFamily: _f, fontPackage: _p);

  /// shovel icon.
  static const shovel = IconData(0xe15d, fontFamily: _f, fontPackage: _p);

  /// shrink icon.
  static const shrink = IconData(0xe220, fontFamily: _f, fontPackage: _p);

  /// slice icon.
  static const slice = IconData(0xe2f0, fontFamily: _f, fontPackage: _p);

  /// sliders icon.
  static const sliders = IconData(0xe162, fontFamily: _f, fontPackage: _p);

  /// sliders-horizontal icon.
  static const slidersHorizontal = IconData(0xe29a, fontFamily: _f, fontPackage: _p);

  /// sliders-vertical icon.
  static const slidersVertical = IconData(0xe162, fontFamily: _f, fontPackage: _p);

  /// sparkle icon.
  static const sparkle = IconData(0xe47e, fontFamily: _f, fontPackage: _p);

  /// sparkles icon.
  static const sparkles = IconData(0xe412, fontFamily: _f, fontPackage: _p);

  /// stamp icon.
  static const stamp = IconData(0xe3bb, fontFamily: _f, fontPackage: _p);

  /// table-cells-merge icon.
  static const tableCellsMerge = IconData(0xe5c7, fontFamily: _f, fontPackage: _p);

  /// timer icon.
  static const timer = IconData(0xe1e0, fontFamily: _f, fontPackage: _p);

  /// timer-off icon.
  static const timerOff = IconData(0xe249, fontFamily: _f, fontPackage: _p);

  /// timer-reset icon.
  static const timerReset = IconData(0xe236, fontFamily: _f, fontPackage: _p);

  /// toggle-left icon.
  static const toggleLeft = IconData(0xe18b, fontFamily: _f, fontPackage: _p);

  /// toggle-right icon.
  static const toggleRight = IconData(0xe18c, fontFamily: _f, fontPackage: _p);

  /// toolbox icon.
  static const toolbox = IconData(0xe6b0, fontFamily: _f, fontPackage: _p);

  /// trash icon.
  static const trash = IconData(0xe18d, fontFamily: _f, fontPackage: _p);

  /// trash-2 icon.
  static const trash2 = IconData(0xe18e, fontFamily: _f, fontPackage: _p);

  /// unlink icon.
  static const unlink = IconData(0xe19c, fontFamily: _f, fontPackage: _p);

  /// unlink-2 icon.
  static const unlink2 = IconData(0xe19d, fontFamily: _f, fontPackage: _p);

  /// upload icon.
  static const upload = IconData(0xe19e, fontFamily: _f, fontPackage: _p);

  /// wand icon.
  static const wand = IconData(0xe246, fontFamily: _f, fontPackage: _p);

  /// wand-2 icon.
  static const wand2 = IconData(0xe357, fontFamily: _f, fontPackage: _p);

  /// wand-sparkles icon.
  static const wandSparkles = IconData(0xe357, fontFamily: _f, fontPackage: _p);

  /// watch icon.
  static const watch = IconData(0xe1ad, fontFamily: _f, fontPackage: _p);

  /// wrench icon.
  static const wrench = IconData(0xe1b1, fontFamily: _f, fontPackage: _p);

  /// x icon.
  static const x = IconData(0xe1b2, fontFamily: _f, fontPackage: _p);

  /// x-line-top icon.
  static const xLineTop = IconData(0xe6ca, fontFamily: _f, fontPackage: _p);

  /// zap icon.
  static const zap = IconData(0xe1b4, fontFamily: _f, fontPackage: _p);

  /// zap-off icon.
  static const zapOff = IconData(0xe1b5, fontFamily: _f, fontPackage: _p);

  /// zoom-in icon.
  static const zoomIn = IconData(0xe1b6, fontFamily: _f, fontPackage: _p);

  /// zoom-out icon.
  static const zoomOut = IconData(0xe1b7, fontFamily: _f, fontPackage: _p);


  // ── Miscellaneous ─────────────────────────────────────────────────

  /// air-vent icon.
  static const airVent = IconData(0xe34d, fontFamily: _f, fontPackage: _p);

  /// album icon.
  static const album = IconData(0xe03b, fontFamily: _f, fontPackage: _p);

  /// ampersand icon.
  static const ampersand = IconData(0xe49c, fontFamily: _f, fontPackage: _p);

  /// ampersands icon.
  static const ampersands = IconData(0xe49d, fontFamily: _f, fontPackage: _p);

  /// amphora icon.
  static const amphora = IconData(0xe61b, fontFamily: _f, fontPackage: _p);

  /// anchor icon.
  static const anchor = IconData(0xe03f, fontFamily: _f, fontPackage: _p);

  /// anvil icon.
  static const anvil = IconData(0xe580, fontFamily: _f, fontPackage: _p);

  /// aperture icon.
  static const aperture = IconData(0xe040, fontFamily: _f, fontPackage: _p);

  /// armchair icon.
  static const armchair = IconData(0xe2c0, fontFamily: _f, fontPackage: _p);

  /// asterisk icon.
  static const asterisk = IconData(0xe1ef, fontFamily: _f, fontPackage: _p);

  /// atom icon.
  static const atom = IconData(0xe3d7, fontFamily: _f, fontPackage: _p);

  /// award icon.
  static const award = IconData(0xe04f, fontFamily: _f, fontPackage: _p);

  /// backpack icon.
  static const backpack = IconData(0xe2c8, fontFamily: _f, fontPackage: _p);

  /// balloon icon.
  static const balloon = IconData(0xe6af, fontFamily: _f, fontPackage: _p);

  /// bath icon.
  static const bath = IconData(0xe2ab, fontFamily: _f, fontPackage: _p);

  /// beaker icon.
  static const beaker = IconData(0xe058, fontFamily: _f, fontPackage: _p);

  /// bean icon.
  static const bean = IconData(0xe38f, fontFamily: _f, fontPackage: _p);

  /// bean-off icon.
  static const beanOff = IconData(0xe390, fontFamily: _f, fontPackage: _p);

  /// bed icon.
  static const bed = IconData(0xe2c1, fontFamily: _f, fontPackage: _p);

  /// bed-double icon.
  static const bedDouble = IconData(0xe2c2, fontFamily: _f, fontPackage: _p);

  /// bed-single icon.
  static const bedSingle = IconData(0xe2c3, fontFamily: _f, fontPackage: _p);

  /// biohazard icon.
  static const biohazard = IconData(0xe441, fontFamily: _f, fontPackage: _p);

  /// blend icon.
  static const blend = IconData(0xe59c, fontFamily: _f, fontPackage: _p);

  /// blinds icon.
  static const blinds = IconData(0xe3c0, fontFamily: _f, fontPackage: _p);

  /// bomb icon.
  static const bomb = IconData(0xe2ff, fontFamily: _f, fontPackage: _p);

  /// bone icon.
  static const bone = IconData(0xe358, fontFamily: _f, fontPackage: _p);

  /// bot icon.
  static const bot = IconData(0xe1bb, fontFamily: _f, fontPackage: _p);

  /// bot-off icon.
  static const botOff = IconData(0xe5e0, fontFamily: _f, fontPackage: _p);

  /// bring-to-front icon.
  static const bringToFront = IconData(0xe4ef, fontFamily: _f, fontPackage: _p);

  /// bubbles icon.
  static const bubbles = IconData(0xe654, fontFamily: _f, fontPackage: _p);

  /// cannabis icon.
  static const cannabis = IconData(0xe5d4, fontFamily: _f, fontPackage: _p);

  /// cannabis-off icon.
  static const cannabisOff = IconData(0xe6af, fontFamily: _f, fontPackage: _p);

  /// cassette-tape icon.
  static const cassetteTape = IconData(0xe4ca, fontFamily: _f, fontPackage: _p);

  /// chef-hat icon.
  static const chefHat = IconData(0xe2ac, fontFamily: _f, fontPackage: _p);

  /// chess-king icon.
  static const chessKing = IconData(0xe6a1, fontFamily: _f, fontPackage: _p);

  /// chess-knight icon.
  static const chessKnight = IconData(0xe6a2, fontFamily: _f, fontPackage: _p);

  /// chess-queen icon.
  static const chessQueen = IconData(0xe6a4, fontFamily: _f, fontPackage: _p);

  /// chess-rook icon.
  static const chessRook = IconData(0xe6a5, fontFamily: _f, fontPackage: _p);

  /// chrome icon.
  static const chrome = IconData(0xe075, fontFamily: _f, fontPackage: _p);

  /// chromium icon.
  static const chromium = IconData(0xe075, fontFamily: _f, fontPackage: _p);

  /// cigarette icon.
  static const cigarette = IconData(0xe2c6, fontFamily: _f, fontPackage: _p);

  /// cigarette-off icon.
  static const cigaretteOff = IconData(0xe2c7, fontFamily: _f, fontPackage: _p);

  /// clapperboard icon.
  static const clapperboard = IconData(0xe29b, fontFamily: _f, fontPackage: _p);

  /// closed-caption icon.
  static const closedCaption = IconData(0xe68a, fontFamily: _f, fontPackage: _p);

  /// club icon.
  static const club = IconData(0xe496, fontFamily: _f, fontPackage: _p);

  /// combine icon.
  static const combine = IconData(0xe44c, fontFamily: _f, fontPackage: _p);

  /// command icon.
  static const command = IconData(0xe09a, fontFamily: _f, fontPackage: _p);

  /// computer icon.
  static const computer = IconData(0xe4e4, fontFamily: _f, fontPackage: _p);

  /// cone icon.
  static const cone = IconData(0xe523, fontFamily: _f, fontPackage: _p);

  /// contrast icon.
  static const contrast = IconData(0xe09d, fontFamily: _f, fontPackage: _p);

  /// cooking-pot icon.
  static const cookingPot = IconData(0xe584, fontFamily: _f, fontPackage: _p);

  /// creative-commons icon.
  static const creativeCommons = IconData(0xe3b2, fontFamily: _f, fontPackage: _p);

  /// croissant icon.
  static const croissant = IconData(0xe2ae, fontFamily: _f, fontPackage: _p);

  /// cuboid icon.
  static const cuboid = IconData(0xe524, fontFamily: _f, fontPackage: _p);

  /// currency icon.
  static const currency = IconData(0xe230, fontFamily: _f, fontPackage: _p);

  /// cylinder icon.
  static const cylinder = IconData(0xe525, fontFamily: _f, fontPackage: _p);

  /// dam icon.
  static const dam = IconData(0xe606, fontFamily: _f, fontPackage: _p);

  /// dessert icon.
  static const dessert = IconData(0xe4bb, fontFamily: _f, fontPackage: _p);

  /// dice-1 icon.
  static const dice1 = IconData(0xe287, fontFamily: _f, fontPackage: _p);

  /// dice-2 icon.
  static const dice2 = IconData(0xe288, fontFamily: _f, fontPackage: _p);

  /// dice-3 icon.
  static const dice3 = IconData(0xe289, fontFamily: _f, fontPackage: _p);

  /// dice-4 icon.
  static const dice4 = IconData(0xe28a, fontFamily: _f, fontPackage: _p);

  /// dice-5 icon.
  static const dice5 = IconData(0xe28b, fontFamily: _f, fontPackage: _p);

  /// dice-6 icon.
  static const dice6 = IconData(0xe28c, fontFamily: _f, fontPackage: _p);

  /// dices icon.
  static const dices = IconData(0xe2c5, fontFamily: _f, fontPackage: _p);

  /// disc icon.
  static const disc = IconData(0xe0af, fontFamily: _f, fontPackage: _p);

  /// disc-2 icon.
  static const disc2 = IconData(0xe3f6, fontFamily: _f, fontPackage: _p);

  /// disc-3 icon.
  static const disc3 = IconData(0xe494, fontFamily: _f, fontPackage: _p);

  /// disc-album icon.
  static const discAlbum = IconData(0xe55c, fontFamily: _f, fontPackage: _p);

  /// dock icon.
  static const dock = IconData(0xe5d3, fontFamily: _f, fontPackage: _p);

  /// dot icon.
  static const dot = IconData(0xe44f, fontFamily: _f, fontPackage: _p);

  /// drama icon.
  static const drama = IconData(0xe521, fontFamily: _f, fontPackage: _p);

  /// dribbble icon.
  static const dribbble = IconData(0xe0b3, fontFamily: _f, fontPackage: _p);

  /// drone icon.
  static const drone = IconData(0xe676, fontFamily: _f, fontPackage: _p);

  /// drum icon.
  static const drum = IconData(0xe55d, fontFamily: _f, fontPackage: _p);

  /// drumstick icon.
  static const drumstick = IconData(0xe25b, fontFamily: _f, fontPackage: _p);

  /// ear icon.
  static const ear = IconData(0xe382, fontFamily: _f, fontPackage: _p);

  /// ear-off icon.
  static const earOff = IconData(0xe383, fontFamily: _f, fontPackage: _p);

  /// eclipse icon.
  static const eclipse = IconData(0xe59d, fontFamily: _f, fontPackage: _p);

  /// edit icon.
  static const edit = IconData(0xe172, fontFamily: _f, fontPackage: _p);

  /// edit-2 icon.
  static const edit2 = IconData(0xe12f, fontFamily: _f, fontPackage: _p);

  /// edit-3 icon.
  static const edit3 = IconData(0xe130, fontFamily: _f, fontPackage: _p);

  /// ellipse icon.
  static const ellipse = IconData(0xe6b2, fontFamily: _f, fontPackage: _p);

  /// ellipsis icon.
  static const ellipsis = IconData(0xe0b6, fontFamily: _f, fontPackage: _p);

  /// ellipsis-vertical icon.
  static const ellipsisVertical = IconData(0xe0b7, fontFamily: _f, fontPackage: _p);

  /// ethernet-port icon.
  static const ethernetPort = IconData(0xe620, fontFamily: _f, fontPackage: _p);

  /// ev-charger icon.
  static const evCharger = IconData(0xe697, fontFamily: _f, fontPackage: _p);

  /// fan icon.
  static const fan = IconData(0xe379, fontFamily: _f, fontPackage: _p);

  /// feather icon.
  static const feather = IconData(0xe0be, fontFamily: _f, fontPackage: _p);

  /// ferris-wheel icon.
  static const ferrisWheel = IconData(0xe47f, fontFamily: _f, fontPackage: _p);

  /// figma icon.
  static const figma = IconData(0xe0bf, fontFamily: _f, fontPackage: _p);

  /// film icon.
  static const film = IconData(0xe0d0, fontFamily: _f, fontPackage: _p);

  /// flask-conical icon.
  static const flaskConical = IconData(0xe0d5, fontFamily: _f, fontPackage: _p);

  /// flask-conical-off icon.
  static const flaskConicalOff = IconData(0xe396, fontFamily: _f, fontPackage: _p);

  /// flask-round icon.
  static const flaskRound = IconData(0xe0d6, fontFamily: _f, fontPackage: _p);

  /// focus icon.
  static const focus = IconData(0xe29e, fontFamily: _f, fontPackage: _p);

  /// fold-horizontal icon.
  static const foldHorizontal = IconData(0xe43b, fontFamily: _f, fontPackage: _p);

  /// fold-vertical icon.
  static const foldVertical = IconData(0xe43c, fontFamily: _f, fontPackage: _p);

  /// footprints icon.
  static const footprints = IconData(0xe3b9, fontFamily: _f, fontPackage: _p);

  /// form icon.
  static const form = IconData(0xe6a8, fontFamily: _f, fontPackage: _p);

  /// form-input icon.
  static const formInput = IconData(0xe21f, fontFamily: _f, fontPackage: _p);

  /// forward icon.
  static const forward = IconData(0xe229, fontFamily: _f, fontPackage: _p);

  /// frame icon.
  static const frame = IconData(0xe291, fontFamily: _f, fontPackage: _p);

  /// framer icon.
  static const framer = IconData(0xe0da, fontFamily: _f, fontPackage: _p);

  /// fullscreen icon.
  static const fullscreen = IconData(0xe534, fontFamily: _f, fontPackage: _p);

  /// gallery-horizontal icon.
  static const galleryHorizontal = IconData(0xe4ce, fontFamily: _f, fontPackage: _p);

  /// gallery-horizontal-end icon.
  static const galleryHorizontalEnd = IconData(0xe4cf, fontFamily: _f, fontPackage: _p);

  /// gallery-thumbnails icon.
  static const galleryThumbnails = IconData(0xe4d0, fontFamily: _f, fontPackage: _p);

  /// gallery-vertical icon.
  static const galleryVertical = IconData(0xe4d1, fontFamily: _f, fontPackage: _p);

  /// gallery-vertical-end icon.
  static const galleryVerticalEnd = IconData(0xe4d2, fontFamily: _f, fontPackage: _p);

  /// gamepad icon.
  static const gamepad = IconData(0xe0de, fontFamily: _f, fontPackage: _p);

  /// gamepad-2 icon.
  static const gamepad2 = IconData(0xe0df, fontFamily: _f, fontPackage: _p);

  /// gamepad-directional icon.
  static const gamepadDirectional = IconData(0xe69b, fontFamily: _f, fontPackage: _p);

  /// gavel icon.
  static const gavel = IconData(0xe0e0, fontFamily: _f, fontPackage: _p);

  /// gem icon.
  static const gem = IconData(0xe242, fontFamily: _f, fontPackage: _p);

  /// georgian-lari icon.
  static const georgianLari = IconData(0xe678, fontFamily: _f, fontPackage: _p);

  /// glass-water icon.
  static const glassWater = IconData(0xe2d5, fontFamily: _f, fontPackage: _p);

  /// glasses icon.
  static const glasses = IconData(0xe20d, fontFamily: _f, fontPackage: _p);

  /// goal icon.
  static const goal = IconData(0xe4a5, fontFamily: _f, fontPackage: _p);

  /// gpu icon.
  static const gpu = IconData(0xe66a, fontFamily: _f, fontPackage: _p);

  /// grab icon.
  static const grab = IconData(0xe1e6, fontFamily: _f, fontPackage: _p);

  /// graduation-cap icon.
  static const graduationCap = IconData(0xe234, fontFamily: _f, fontPackage: _p);

  /// grip icon.
  static const grip = IconData(0xe3b1, fontFamily: _f, fontPackage: _p);

  /// grip-horizontal icon.
  static const gripHorizontal = IconData(0xe0ea, fontFamily: _f, fontPackage: _p);

  /// grip-vertical icon.
  static const gripVertical = IconData(0xe0eb, fontFamily: _f, fontPackage: _p);

  /// guitar icon.
  static const guitar = IconData(0xe55f, fontFamily: _f, fontPackage: _p);

  /// hard-hat icon.
  static const hardHat = IconData(0xe0ee, fontFamily: _f, fontPackage: _p);

  /// hat-glasses icon.
  static const hatGlasses = IconData(0xe683, fontFamily: _f, fontPackage: _p);

  /// hd icon.
  static const hd = IconData(0xe6af, fontFamily: _f, fontPackage: _p);

  /// hdmi-port icon.
  static const hdmiPort = IconData(0xe4e7, fontFamily: _f, fontPackage: _p);

  /// headset icon.
  static const headset = IconData(0xe5bd, fontFamily: _f, fontPackage: _p);

  /// heater icon.
  static const heater = IconData(0xe58e, fontFamily: _f, fontPackage: _p);

  /// helicopter icon.
  static const helicopter = IconData(0xe69d, fontFamily: _f, fontPackage: _p);

  /// hop icon.
  static const hop = IconData(0xe397, fontFamily: _f, fontPackage: _p);

  /// hop-off icon.
  static const hopOff = IconData(0xe398, fontFamily: _f, fontPackage: _p);

  /// import icon.
  static const importIcon = IconData(0xe22f, fontFamily: _f, fontPackage: _p);

  /// indian-rupee icon.
  static const indianRupee = IconData(0xe0f8, fontFamily: _f, fontPackage: _p);

  /// info icon.
  static const info = IconData(0xe0f9, fontFamily: _f, fontPackage: _p);

  /// japanese-yen icon.
  static const japaneseYen = IconData(0xe0fc, fontFamily: _f, fontPackage: _p);

  /// joystick icon.
  static const joystick = IconData(0xe355, fontFamily: _f, fontPackage: _p);

  /// kayak icon.
  static const kayak = IconData(0xe68f, fontFamily: _f, fontPackage: _p);

  /// land-plot icon.
  static const landPlot = IconData(0xe528, fontFamily: _f, fontPackage: _p);

  /// languages icon.
  static const languages = IconData(0xe0fe, fontFamily: _f, fontPackage: _p);

  /// lasso icon.
  static const lasso = IconData(0xe1ce, fontFamily: _f, fontPackage: _p);

  /// lasso-select icon.
  static const lassoSelect = IconData(0xe1cf, fontFamily: _f, fontPackage: _p);

  /// layers icon.
  static const layers = IconData(0xe529, fontFamily: _f, fontPackage: _p);

  /// layers-2 icon.
  static const layers2 = IconData(0xe52a, fontFamily: _f, fontPackage: _p);

  /// layers-3 icon.
  static const layers3 = IconData(0xe529, fontFamily: _f, fontPackage: _p);

  /// lectern icon.
  static const lectern = IconData(0xe5e9, fontFamily: _f, fontPackage: _p);

  /// lens-concave icon.
  static const lensConcave = IconData(0xe6b7, fontFamily: _f, fontPackage: _p);

  /// library icon.
  static const library = IconData(0xe100, fontFamily: _f, fontPackage: _p);

  /// library-big icon.
  static const libraryBig = IconData(0xe54e, fontFamily: _f, fontPackage: _p);

  /// life-buoy icon.
  static const lifeBuoy = IconData(0xe101, fontFamily: _f, fontPackage: _p);

  /// line-dot-right-horizontal icon.
  static const lineDotRightHorizontal = IconData(0xe6b9, fontFamily: _f, fontPackage: _p);

  /// line-squiggle icon.
  static const lineSquiggle = IconData(0xe67a, fontFamily: _f, fontPackage: _p);

  /// loader icon.
  static const loader = IconData(0xe109, fontFamily: _f, fontPackage: _p);

  /// loader-2 icon.
  static const loader2 = IconData(0xe10a, fontFamily: _f, fontPackage: _p);

  /// mars icon.
  static const mars = IconData(0xe641, fontFamily: _f, fontPackage: _p);

  /// mars-stroke icon.
  static const marsStroke = IconData(0xe642, fontFamily: _f, fontPackage: _p);

  /// martini icon.
  static const martini = IconData(0xe2e3, fontFamily: _f, fontPackage: _p);

  /// medal icon.
  static const medal = IconData(0xe36f, fontFamily: _f, fontPackage: _p);

  /// menu icon.
  static const menu = IconData(0xe115, fontFamily: _f, fontPackage: _p);

  /// metronome icon.
  static const metronome = IconData(0xe6bc, fontFamily: _f, fontPackage: _p);

  /// mirror-rectangular icon.
  static const mirrorRectangular = IconData(0xe6bd, fontFamily: _f, fontPackage: _p);

  /// mirror-round icon.
  static const mirrorRound = IconData(0xe6be, fontFamily: _f, fontPackage: _p);

  /// more-horizontal icon.
  static const moreHorizontal = IconData(0xe0b6, fontFamily: _f, fontPackage: _p);

  /// more-vertical icon.
  static const moreVertical = IconData(0xe0b7, fontFamily: _f, fontPackage: _p);

  /// network icon.
  static const network = IconData(0xe125, fontFamily: _f, fontPackage: _p);

  /// newspaper icon.
  static const newspaper = IconData(0xe348, fontFamily: _f, fontPackage: _p);

  /// omega icon.
  static const omega = IconData(0xe619, fontFamily: _f, fontPackage: _p);

  /// option icon.
  static const option = IconData(0xe1f8, fontFamily: _f, fontPackage: _p);

  /// orbit icon.
  static const orbit = IconData(0xe3e7, fontFamily: _f, fontPackage: _p);

  /// origami icon.
  static const origami = IconData(0xe5e3, fontFamily: _f, fontPackage: _p);

  /// outdent icon.
  static const outdent = IconData(0xe107, fontFamily: _f, fontPackage: _p);

  /// panda icon.
  static const panda = IconData(0xe668, fontFamily: _f, fontPackage: _p);

  /// parentheses icon.
  static const parentheses = IconData(0xe444, fontFamily: _f, fontPackage: _p);

  /// party-popper icon.
  static const partyPopper = IconData(0xe343, fontFamily: _f, fontPackage: _p);

  /// pocket icon.
  static const pocket = IconData(0xe13e, fontFamily: _f, fontPackage: _p);

  /// pointer icon.
  static const pointer = IconData(0xe1e8, fontFamily: _f, fontPackage: _p);

  /// pointer-off icon.
  static const pointerOff = IconData(0xe57f, fontFamily: _f, fontPackage: _p);

  /// popsicle icon.
  static const popsicle = IconData(0xe4bf, fontFamily: _f, fontPackage: _p);

  /// proportions icon.
  static const proportions = IconData(0xe5cf, fontFamily: _f, fontPackage: _p);

  /// puzzle icon.
  static const puzzle = IconData(0xe29c, fontFamily: _f, fontPackage: _p);

  /// pyramid icon.
  static const pyramid = IconData(0xe52c, fontFamily: _f, fontPackage: _p);

  /// radar icon.
  static const radar = IconData(0xe497, fontFamily: _f, fontPackage: _p);

  /// radiation icon.
  static const radiation = IconData(0xe442, fontFamily: _f, fontPackage: _p);

  /// radius icon.
  static const radius = IconData(0xe52d, fontFamily: _f, fontPackage: _p);

  /// rail-symbol icon.
  static const railSymbol = IconData(0xe501, fontFamily: _f, fontPackage: _p);

  /// rectangle-ellipsis icon.
  static const rectangleEllipsis = IconData(0xe21f, fontFamily: _f, fontPackage: _p);

  /// rectangle-goggles icon.
  static const rectangleGoggles = IconData(0xe656, fontFamily: _f, fontPackage: _p);

  /// rectangle-horizontal icon.
  static const rectangleHorizontal = IconData(0xe376, fontFamily: _f, fontPackage: _p);

  /// rectangle-vertical icon.
  static const rectangleVertical = IconData(0xe377, fontFamily: _f, fontPackage: _p);

  /// reply icon.
  static const reply = IconData(0xe22a, fontFamily: _f, fontPackage: _p);

  /// reply-all icon.
  static const replyAll = IconData(0xe22b, fontFamily: _f, fontPackage: _p);

  /// ribbon icon.
  static const ribbon = IconData(0xe558, fontFamily: _f, fontPackage: _p);

  /// rocking-chair icon.
  static const rockingChair = IconData(0xe233, fontFamily: _f, fontPackage: _p);

  /// roller-coaster icon.
  static const rollerCoaster = IconData(0xe480, fontFamily: _f, fontPackage: _p);

  /// rose icon.
  static const rose = IconData(0xe691, fontFamily: _f, fontPackage: _p);

  /// russian-ruble icon.
  static const russianRuble = IconData(0xe14c, fontFamily: _f, fontPackage: _p);

  /// saudi-riyal icon.
  static const saudiRiyal = IconData(0xe64b, fontFamily: _f, fontPackage: _p);

  /// scale icon.
  static const scale = IconData(0xe212, fontFamily: _f, fontPackage: _p);

  /// scale-3-d icon.
  static const scale3D = IconData(0xe2eb, fontFamily: _f, fontPackage: _p);

  /// scale-3d icon.
  static const scale3d = IconData(0xe2eb, fontFamily: _f, fontPackage: _p);

  /// scaling icon.
  static const scaling = IconData(0xe2ec, fontFamily: _f, fontPackage: _p);

  /// scooter icon.
  static const scooter = IconData(0xe6ac, fontFamily: _f, fontPackage: _p);

  /// scroll icon.
  static const scroll = IconData(0xe2ed, fontFamily: _f, fontPackage: _p);

  /// sheet icon.
  static const sheet = IconData(0xe157, fontFamily: _f, fontPackage: _p);

  /// shell icon.
  static const shell = IconData(0xe4f7, fontFamily: _f, fontPackage: _p);

  /// shelving-unit icon.
  static const shelvingUnit = IconData(0xe6c2, fontFamily: _f, fontPackage: _p);

  /// shirt icon.
  static const shirt = IconData(0xe1ca, fontFamily: _f, fontPackage: _p);

  /// shower-head icon.
  static const showerHead = IconData(0xe37c, fontFamily: _f, fontPackage: _p);

  /// shredder icon.
  static const shredder = IconData(0xe65b, fontFamily: _f, fontPackage: _p);

  /// shrimp icon.
  static const shrimp = IconData(0xe649, fontFamily: _f, fontPackage: _p);

  /// shrub icon.
  static const shrub = IconData(0xe2ee, fontFamily: _f, fontPackage: _p);

  /// shuffle icon.
  static const shuffle = IconData(0xe15e, fontFamily: _f, fontPackage: _p);

  /// signature icon.
  static const signature = IconData(0xe5f2, fontFamily: _f, fontPackage: _p);

  /// siren icon.
  static const siren = IconData(0xe2ef, fontFamily: _f, fontPackage: _p);

  /// slack icon.
  static const slack = IconData(0xe161, fontFamily: _f, fontPackage: _p);

  /// slash icon.
  static const slash = IconData(0xe51d, fontFamily: _f, fontPackage: _p);

  /// sofa icon.
  static const sofa = IconData(0xe2c4, fontFamily: _f, fontPackage: _p);

  /// sort-asc icon.
  static const sortAsc = IconData(0xe04c, fontFamily: _f, fontPackage: _p);

  /// sort-desc icon.
  static const sortDesc = IconData(0xe047, fontFamily: _f, fontPackage: _p);

  /// spade icon.
  static const spade = IconData(0xe499, fontFamily: _f, fontPackage: _p);

  /// speech icon.
  static const speech = IconData(0xe51e, fontFamily: _f, fontPackage: _p);

  /// spline icon.
  static const spline = IconData(0xe38b, fontFamily: _f, fontPackage: _p);

  /// spline-pointer icon.
  static const splinePointer = IconData(0xe64f, fontFamily: _f, fontPackage: _p);

  /// spool icon.
  static const spool = IconData(0xe677, fontFamily: _f, fontPackage: _p);

  /// spotlight icon.
  static const spotlight = IconData(0xe682, fontFamily: _f, fontPackage: _p);

  /// spray-can icon.
  static const sprayCan = IconData(0xe495, fontFamily: _f, fontPackage: _p);

  /// squircle icon.
  static const squircle = IconData(0xe57a, fontFamily: _f, fontPackage: _p);

  /// squircle-dashed icon.
  static const squircleDashed = IconData(0xe679, fontFamily: _f, fontPackage: _p);

  /// step-back icon.
  static const stepBack = IconData(0xe3e9, fontFamily: _f, fontPackage: _p);

  /// step-forward icon.
  static const stepForward = IconData(0xe3ea, fontFamily: _f, fontPackage: _p);

  /// sticker icon.
  static const sticker = IconData(0xe302, fontFamily: _f, fontPackage: _p);

  /// sticky-note icon.
  static const stickyNote = IconData(0xe303, fontFamily: _f, fontPackage: _p);

  /// stone icon.
  static const stone = IconData(0xe6af, fontFamily: _f, fontPackage: _p);

  /// stretch-horizontal icon.
  static const stretchHorizontal = IconData(0xe27c, fontFamily: _f, fontPackage: _p);

  /// stretch-vertical icon.
  static const stretchVertical = IconData(0xe27d, fontFamily: _f, fontPackage: _p);

  /// swiss-franc icon.
  static const swissFranc = IconData(0xe17b, fontFamily: _f, fontPackage: _p);

  /// sword icon.
  static const sword = IconData(0xe2b3, fontFamily: _f, fontPackage: _p);

  /// swords icon.
  static const swords = IconData(0xe2b4, fontFamily: _f, fontPackage: _p);

  /// table icon.
  static const table = IconData(0xe17d, fontFamily: _f, fontPackage: _p);

  /// table-2 icon.
  static const table2 = IconData(0xe2f9, fontFamily: _f, fontPackage: _p);

  /// table-config icon.
  static const tableConfig = IconData(0xe661, fontFamily: _f, fontPackage: _p);

  /// table-properties icon.
  static const tableProperties = IconData(0xe4db, fontFamily: _f, fontPackage: _p);

  /// tangent icon.
  static const tangent = IconData(0xe52e, fontFamily: _f, fontPackage: _p);

  /// target icon.
  static const target = IconData(0xe180, fontFamily: _f, fontPackage: _p);

  /// telescope icon.
  static const telescope = IconData(0xe5c5, fontFamily: _f, fontPackage: _p);

  /// test-tube icon.
  static const testTube = IconData(0xe405, fontFamily: _f, fontPackage: _p);

  /// test-tube-2 icon.
  static const testTube2 = IconData(0xe406, fontFamily: _f, fontPackage: _p);

  /// test-tube-diagonal icon.
  static const testTubeDiagonal = IconData(0xe406, fontFamily: _f, fontPackage: _p);

  /// test-tubes icon.
  static const testTubes = IconData(0xe407, fontFamily: _f, fontPackage: _p);

  /// theater icon.
  static const theater = IconData(0xe522, fontFamily: _f, fontPackage: _p);

  /// toilet icon.
  static const toilet = IconData(0xe635, fontFamily: _f, fontPackage: _p);

  /// torus icon.
  static const torus = IconData(0xe52f, fontFamily: _f, fontPackage: _p);

  /// touchpad icon.
  static const touchpad = IconData(0xe449, fontFamily: _f, fontPackage: _p);

  /// touchpad-off icon.
  static const touchpadOff = IconData(0xe44a, fontFamily: _f, fontPackage: _p);

  /// towel-rack icon.
  static const towelRack = IconData(0xe6c7, fontFamily: _f, fontPackage: _p);

  /// tower-control icon.
  static const towerControl = IconData(0xe3bc, fontFamily: _f, fontPackage: _p);

  /// traffic-cone icon.
  static const trafficCone = IconData(0xe505, fontFamily: _f, fontPackage: _p);

  /// tram-front icon.
  static const tramFront = IconData(0xe2a9, fontFamily: _f, fontPackage: _p);

  /// transgender icon.
  static const transgender = IconData(0xe644, fontFamily: _f, fontPackage: _p);

  /// trello icon.
  static const trello = IconData(0xe18f, fontFamily: _f, fontPackage: _p);

  /// trophy icon.
  static const trophy = IconData(0xe373, fontFamily: _f, fontPackage: _p);

  /// turkish-lira icon.
  static const turkishLira = IconData(0xe680, fontFamily: _f, fontPackage: _p);

  /// turntable icon.
  static const turntable = IconData(0xe68c, fontFamily: _f, fontPackage: _p);

  /// twitch icon.
  static const twitch = IconData(0xe196, fontFamily: _f, fontPackage: _p);

  /// twitter icon.
  static const twitter = IconData(0xe197, fontFamily: _f, fontPackage: _p);

  /// unfold-horizontal icon.
  static const unfoldHorizontal = IconData(0xe43d, fontFamily: _f, fontPackage: _p);

  /// unfold-vertical icon.
  static const unfoldVertical = IconData(0xe43e, fontFamily: _f, fontPackage: _p);

  /// university icon.
  static const university = IconData(0xe3e5, fontFamily: _f, fontPackage: _p);

  /// utility-pole icon.
  static const utilityPole = IconData(0xe3c2, fontFamily: _f, fontPackage: _p);

  /// van icon.
  static const van = IconData(0xe6ad, fontFamily: _f, fontPackage: _p);

  /// vault icon.
  static const vault = IconData(0xe58f, fontFamily: _f, fontPackage: _p);

  /// venetian-mask icon.
  static const venetianMask = IconData(0xe2aa, fontFamily: _f, fontPackage: _p);

  /// venus icon.
  static const venus = IconData(0xe645, fontFamily: _f, fontPackage: _p);

  /// venus-and-mars icon.
  static const venusAndMars = IconData(0xe646, fontFamily: _f, fontPackage: _p);

  /// verified icon.
  static const verified = IconData(0xe241, fontFamily: _f, fontPackage: _p);

  /// view icon.
  static const view = IconData(0xe1a7, fontFamily: _f, fontPackage: _p);

  /// volleyball icon.
  static const volleyball = IconData(0xe62f, fontFamily: _f, fontPackage: _p);

  /// vote icon.
  static const vote = IconData(0xe3ad, fontFamily: _f, fontPackage: _p);

  /// wallpaper icon.
  static const wallpaper = IconData(0xe44b, fontFamily: _f, fontPackage: _p);

  /// washing-machine icon.
  static const washingMachine = IconData(0xe590, fontFamily: _f, fontPackage: _p);

  /// webcam icon.
  static const webcam = IconData(0xe205, fontFamily: _f, fontPackage: _p);

  /// weight icon.
  static const weight = IconData(0xe530, fontFamily: _f, fontPackage: _p);

  /// weight-tilde icon.
  static const weightTilde = IconData(0xe6ae, fontFamily: _f, fontPackage: _p);

  /// worm icon.
  static const worm = IconData(0xe5da, fontFamily: _f, fontPackage: _p);

  /// youtube icon.
  static const youtube = IconData(0xe1b3, fontFamily: _f, fontPackage: _p);

  /// zodiac-aquarius icon.
  static const zodiacAquarius = IconData(0xe6cb, fontFamily: _f, fontPackage: _p);

  /// zodiac-aries icon.
  static const zodiacAries = IconData(0xe6cc, fontFamily: _f, fontPackage: _p);

  /// zodiac-cancer icon.
  static const zodiacCancer = IconData(0xe6cd, fontFamily: _f, fontPackage: _p);

  /// zodiac-capricorn icon.
  static const zodiacCapricorn = IconData(0xe6ce, fontFamily: _f, fontPackage: _p);

  /// zodiac-gemini icon.
  static const zodiacGemini = IconData(0xe6cf, fontFamily: _f, fontPackage: _p);

  /// zodiac-leo icon.
  static const zodiacLeo = IconData(0xe6d0, fontFamily: _f, fontPackage: _p);

  /// zodiac-libra icon.
  static const zodiacLibra = IconData(0xe6d1, fontFamily: _f, fontPackage: _p);

  /// zodiac-ophiuchus icon.
  static const zodiacOphiuchus = IconData(0xe6d2, fontFamily: _f, fontPackage: _p);

  /// zodiac-taurus icon.
  static const zodiacTaurus = IconData(0xe6d6, fontFamily: _f, fontPackage: _p);

  /// zodiac-virgo icon.
  static const zodiacVirgo = IconData(0xe6d7, fontFamily: _f, fontPackage: _p);

}
