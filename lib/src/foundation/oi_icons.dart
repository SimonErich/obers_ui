import 'package:flutter/widgets.dart';

/// Centralized icon constants for obers_ui backed by Heroicons Solid.
///
/// Every constant wraps an [IconData] referencing the embedded
/// `HeroiconsSolid` font shipped with this package. To switch icon sets,
/// replace this file and the font asset — all consumer code uses these
/// named constants and remains unaffected.
///
/// Icon set: [Heroicons](https://heroicons.com) v2.2.0 — 324 solid icons.
///
/// {@category Foundation}
class OiIcons {
  const OiIcons._();

  static const _f = 'HeroiconsSolid';
  static const _p = 'obers_ui';

  // ── Navigation ────────────────────────────────────────────────────

  /// Chevron left icon.
  static const chevronLeft = IconData(0xf1d0, fontFamily: _f, fontPackage: _p);

  /// Chevron right icon.
  static const chevronRight = IconData(0xf1cf, fontFamily: _f, fontPackage: _p);

  /// Chevron up icon.
  static const chevronUp = IconData(0xf1cd, fontFamily: _f, fontPackage: _p);

  /// Chevron down icon.
  static const chevronDown = IconData(0xf1d1, fontFamily: _f, fontPackage: _p);

  /// Chevron double left icon.
  static const chevronDoubleLeft = IconData(0xf1d4, fontFamily: _f, fontPackage: _p);

  /// Chevron double right icon.
  static const chevronDoubleRight = IconData(0xf1d3, fontFamily: _f, fontPackage: _p);

  /// Chevron double up icon.
  static const chevronDoubleUp = IconData(0xf1d2, fontFamily: _f, fontPackage: _p);

  /// Chevron double down icon.
  static const chevronDoubleDown = IconData(0xf1d5, fontFamily: _f, fontPackage: _p);

  /// Chevron up down icon.
  static const chevronUpDown = IconData(0xf1ce, fontFamily: _f, fontPackage: _p);

  /// Arrow left icon.
  static const arrowLeft = IconData(0xf233, fontFamily: _f, fontPackage: _p);

  /// Arrow right icon.
  static const arrowRight = IconData(0xf228, fontFamily: _f, fontPackage: _p);

  /// Arrow up icon.
  static const arrowUp = IconData(0xf212, fontFamily: _f, fontPackage: _p);

  /// Arrow down icon.
  static const arrowDown = IconData(0xf238, fontFamily: _f, fontPackage: _p);

  /// Arrow up left icon.
  static const arrowUpLeft = IconData(0xf217, fontFamily: _f, fontPackage: _p);

  /// Arrow up right icon.
  static const arrowUpRight = IconData(0xf214, fontFamily: _f, fontPackage: _p);

  /// Arrow down left icon.
  static const arrowDownLeft = IconData(0xf23d, fontFamily: _f, fontPackage: _p);

  /// Arrow down right icon.
  static const arrowDownRight = IconData(0xf23a, fontFamily: _f, fontPackage: _p);

  /// Arrow long left icon.
  static const arrowLongLeft = IconData(0xf231, fontFamily: _f, fontPackage: _p);

  /// Arrow long right icon.
  static const arrowLongRight = IconData(0xf230, fontFamily: _f, fontPackage: _p);

  /// Arrow long up icon.
  static const arrowLongUp = IconData(0xf22f, fontFamily: _f, fontPackage: _p);

  /// Arrow long down icon.
  static const arrowLongDown = IconData(0xf232, fontFamily: _f, fontPackage: _p);

  /// Arrow small left icon.
  static const arrowSmallLeft = IconData(0xf226, fontFamily: _f, fontPackage: _p);

  /// Arrow small right icon.
  static const arrowSmallRight = IconData(0xf225, fontFamily: _f, fontPackage: _p);

  /// Arrow small up icon.
  static const arrowSmallUp = IconData(0xf224, fontFamily: _f, fontPackage: _p);

  /// Arrow small down icon.
  static const arrowSmallDown = IconData(0xf227, fontFamily: _f, fontPackage: _p);

  /// Arrow uturn left icon.
  static const arrowUturnLeft = IconData(0xf210, fontFamily: _f, fontPackage: _p);

  /// Arrow uturn right icon.
  static const arrowUturnRight = IconData(0xf20f, fontFamily: _f, fontPackage: _p);

  /// Arrow uturn up icon.
  static const arrowUturnUp = IconData(0xf20e, fontFamily: _f, fontPackage: _p);

  /// Arrow uturn down icon.
  static const arrowUturnDown = IconData(0xf211, fontFamily: _f, fontPackage: _p);

  /// Arrow path icon.
  static const arrowPath = IconData(0xf22d, fontFamily: _f, fontPackage: _p);

  /// Arrow path rounded square icon.
  static const arrowPathRoundedSquare = IconData(0xf22e, fontFamily: _f, fontPackage: _p);

  /// Arrow trending up icon.
  static const arrowTrendingUp = IconData(0xf221, fontFamily: _f, fontPackage: _p);

  /// Arrow trending down icon.
  static const arrowTrendingDown = IconData(0xf222, fontFamily: _f, fontPackage: _p);

  /// Arrows pointing in icon.
  static const arrowsPointingIn = IconData(0xf20d, fontFamily: _f, fontPackage: _p);

  /// Arrows pointing out icon.
  static const arrowsPointingOut = IconData(0xf20c, fontFamily: _f, fontPackage: _p);

  /// Arrows right left icon.
  static const arrowsRightLeft = IconData(0xf20b, fontFamily: _f, fontPackage: _p);

  /// Arrows up down icon.
  static const arrowsUpDown = IconData(0xf20a, fontFamily: _f, fontPackage: _p);

  /// Arrow turn down left icon.
  static const arrowTurnDownLeft = IconData(0xf220, fontFamily: _f, fontPackage: _p);

  /// Arrow turn down right icon.
  static const arrowTurnDownRight = IconData(0xf21f, fontFamily: _f, fontPackage: _p);

  /// Arrow turn left down icon.
  static const arrowTurnLeftDown = IconData(0xf21e, fontFamily: _f, fontPackage: _p);

  /// Arrow turn left up icon.
  static const arrowTurnLeftUp = IconData(0xf21d, fontFamily: _f, fontPackage: _p);

  /// Arrow turn right down icon.
  static const arrowTurnRightDown = IconData(0xf21c, fontFamily: _f, fontPackage: _p);

  /// Arrow turn right up icon.
  static const arrowTurnRightUp = IconData(0xf21b, fontFamily: _f, fontPackage: _p);

  /// Arrow turn up left icon.
  static const arrowTurnUpLeft = IconData(0xf21a, fontFamily: _f, fontPackage: _p);

  /// Arrow turn up right icon.
  static const arrowTurnUpRight = IconData(0xf219, fontFamily: _f, fontPackage: _p);

  // ── Actions ───────────────────────────────────────────────────────

  /// Plus icon.
  static const plus = IconData(0xf143, fontFamily: _f, fontPackage: _p);

  /// Plus small icon.
  static const plusSmall = IconData(0xf144, fontFamily: _f, fontPackage: _p);

  /// Plus circle icon.
  static const plusCircle = IconData(0xf145, fontFamily: _f, fontPackage: _p);

  /// Minus icon.
  static const minus = IconData(0xf15b, fontFamily: _f, fontPackage: _p);

  /// Minus small icon.
  static const minusSmall = IconData(0xf15c, fontFamily: _f, fontPackage: _p);

  /// Minus circle icon.
  static const minusCircle = IconData(0xf15d, fontFamily: _f, fontPackage: _p);

  /// X mark icon.
  static const xMark = IconData(0xf101, fontFamily: _f, fontPackage: _p);

  /// X circle icon.
  static const xCircle = IconData(0xf102, fontFamily: _f, fontPackage: _p);

  /// Check icon.
  static const check = IconData(0xf1d6, fontFamily: _f, fontPackage: _p);

  /// Check circle icon.
  static const checkCircle = IconData(0xf1d7, fontFamily: _f, fontPackage: _p);

  /// Check badge icon.
  static const checkBadge = IconData(0xf1d8, fontFamily: _f, fontPackage: _p);

  /// Magnifying glass icon.
  static const magnifyingGlass = IconData(0xf162, fontFamily: _f, fontPackage: _p);

  /// Magnifying glass plus icon.
  static const magnifyingGlassPlus = IconData(0xf163, fontFamily: _f, fontPackage: _p);

  /// Magnifying glass minus icon.
  static const magnifyingGlassMinus = IconData(0xf164, fontFamily: _f, fontPackage: _p);

  /// Magnifying glass circle icon.
  static const magnifyingGlassCircle = IconData(0xf165, fontFamily: _f, fontPackage: _p);

  /// Pencil icon.
  static const pencil = IconData(0xf14f, fontFamily: _f, fontPackage: _p);

  /// Pencil square icon.
  static const pencilSquare = IconData(0xf150, fontFamily: _f, fontPackage: _p);

  /// Trash icon.
  static const trash = IconData(0xf117, fontFamily: _f, fontPackage: _p);

  /// Share icon.
  static const share = IconData(0xf12f, fontFamily: _f, fontPackage: _p);

  /// Link icon.
  static const link = IconData(0xf169, fontFamily: _f, fontPackage: _p);

  /// Link slash icon.
  static const linkSlash = IconData(0xf16a, fontFamily: _f, fontPackage: _p);

  /// Arrow down tray icon.
  static const arrowDownTray = IconData(0xf239, fontFamily: _f, fontPackage: _p);

  /// Arrow up tray icon.
  static const arrowUpTray = IconData(0xf213, fontFamily: _f, fontPackage: _p);

  /// Arrow top right on square icon.
  static const arrowTopRightOnSquare = IconData(0xf223, fontFamily: _f, fontPackage: _p);

  /// Arrow right on rectangle icon.
  static const arrowRightOnRectangle = IconData(0xf22a, fontFamily: _f, fontPackage: _p);

  /// Arrow left on rectangle icon.
  static const arrowLeftOnRectangle = IconData(0xf235, fontFamily: _f, fontPackage: _p);

  /// Arrow up on square icon.
  static const arrowUpOnSquare = IconData(0xf215, fontFamily: _f, fontPackage: _p);

  /// Arrow up on square stack icon.
  static const arrowUpOnSquareStack = IconData(0xf216, fontFamily: _f, fontPackage: _p);

  /// Arrow down on square icon.
  static const arrowDownOnSquare = IconData(0xf23b, fontFamily: _f, fontPackage: _p);

  /// Arrow down on square stack icon.
  static const arrowDownOnSquareStack = IconData(0xf23c, fontFamily: _f, fontPackage: _p);

  /// Arrow right start on rectangle icon.
  static const arrowRightStartOnRectangle = IconData(0xf229, fontFamily: _f, fontPackage: _p);

  /// Arrow right end on rectangle icon.
  static const arrowRightEndOnRectangle = IconData(0xf22b, fontFamily: _f, fontPackage: _p);

  /// Arrow left start on rectangle icon.
  static const arrowLeftStartOnRectangle = IconData(0xf234, fontFamily: _f, fontPackage: _p);

  /// Arrow left end on rectangle icon.
  static const arrowLeftEndOnRectangle = IconData(0xf236, fontFamily: _f, fontPackage: _p);

  /// Arrow up circle icon.
  static const arrowUpCircle = IconData(0xf218, fontFamily: _f, fontPackage: _p);

  /// Arrow down circle icon.
  static const arrowDownCircle = IconData(0xf23e, fontFamily: _f, fontPackage: _p);

  /// Arrow left circle icon.
  static const arrowLeftCircle = IconData(0xf237, fontFamily: _f, fontPackage: _p);

  /// Arrow right circle icon.
  static const arrowRightCircle = IconData(0xf22c, fontFamily: _f, fontPackage: _p);

  /// Power icon.
  static const power = IconData(0xf142, fontFamily: _f, fontPackage: _p);

  /// Backspace icon.
  static const backspace = IconData(0xf208, fontFamily: _f, fontPackage: _p);

  /// Qr code icon.
  static const qrCode = IconData(0xf13d, fontFamily: _f, fontPackage: _p);

  /// Funnel icon.
  static const funnel = IconData(0xf186, fontFamily: _f, fontPackage: _p);

  /// Adjustments horizontal icon.
  static const adjustmentsHorizontal = IconData(0xf243, fontFamily: _f, fontPackage: _p);

  /// Adjustments vertical icon.
  static const adjustmentsVertical = IconData(0xf242, fontFamily: _f, fontPackage: _p);

  /// Bars arrow up icon.
  static const barsArrowUp = IconData(0xf1fe, fontFamily: _f, fontPackage: _p);

  /// Bars arrow down icon.
  static const barsArrowDown = IconData(0xf1ff, fontFamily: _f, fontPackage: _p);

  // ── Communication ─────────────────────────────────────────────────

  /// Chat bubble left icon.
  static const chatBubbleLeft = IconData(0xf1db, fontFamily: _f, fontPackage: _p);

  /// Chat bubble left right icon.
  static const chatBubbleLeftRight = IconData(0xf1dc, fontFamily: _f, fontPackage: _p);

  /// Chat bubble left ellipsis icon.
  static const chatBubbleLeftEllipsis = IconData(0xf1dd, fontFamily: _f, fontPackage: _p);

  /// Chat bubble oval left icon.
  static const chatBubbleOvalLeft = IconData(0xf1d9, fontFamily: _f, fontPackage: _p);

  /// Chat bubble oval left ellipsis icon.
  static const chatBubbleOvalLeftEllipsis = IconData(0xf1da, fontFamily: _f, fontPackage: _p);

  /// Chat bubble bottom center icon.
  static const chatBubbleBottomCenter = IconData(0xf1de, fontFamily: _f, fontPackage: _p);

  /// Chat bubble bottom center text icon.
  static const chatBubbleBottomCenterText = IconData(0xf1df, fontFamily: _f, fontPackage: _p);

  /// Envelope icon.
  static const envelope = IconData(0xf199, fontFamily: _f, fontPackage: _p);

  /// Envelope open icon.
  static const envelopeOpen = IconData(0xf19a, fontFamily: _f, fontPackage: _p);

  /// Inbox icon.
  static const inbox = IconData(0xf171, fontFamily: _f, fontPackage: _p);

  /// Inbox stack icon.
  static const inboxStack = IconData(0xf172, fontFamily: _f, fontPackage: _p);

  /// Inbox arrow down icon.
  static const inboxArrowDown = IconData(0xf173, fontFamily: _f, fontPackage: _p);

  /// Phone icon.
  static const phone = IconData(0xf14a, fontFamily: _f, fontPackage: _p);

  /// Phone x mark icon.
  static const phoneXMark = IconData(0xf14b, fontFamily: _f, fontPackage: _p);

  /// Phone arrow up right icon.
  static const phoneArrowUpRight = IconData(0xf14c, fontFamily: _f, fontPackage: _p);

  /// Phone arrow down left icon.
  static const phoneArrowDownLeft = IconData(0xf14d, fontFamily: _f, fontPackage: _p);

  /// Megaphone icon.
  static const megaphone = IconData(0xf15f, fontFamily: _f, fontPackage: _p);

  /// Bell icon.
  static const bell = IconData(0xf1f6, fontFamily: _f, fontPackage: _p);

  /// Bell alert icon.
  static const bellAlert = IconData(0xf1f9, fontFamily: _f, fontPackage: _p);

  /// Bell slash icon.
  static const bellSlash = IconData(0xf1f8, fontFamily: _f, fontPackage: _p);

  /// Bell snooze icon.
  static const bellSnooze = IconData(0xf1f7, fontFamily: _f, fontPackage: _p);

  /// At symbol icon.
  static const atSymbol = IconData(0xf209, fontFamily: _f, fontPackage: _p);

  /// Rss icon.
  static const rss = IconData(0xf134, fontFamily: _f, fontPackage: _p);

  /// Signal icon.
  static const signal = IconData(0xf129, fontFamily: _f, fontPackage: _p);

  /// Signal slash icon.
  static const signalSlash = IconData(0xf12a, fontFamily: _f, fontPackage: _p);

  // ── Content & Editing ─────────────────────────────────────────────

  /// Document icon.
  static const document = IconData(0xf19e, fontFamily: _f, fontPackage: _p);

  /// Document text icon.
  static const documentText = IconData(0xf19f, fontFamily: _f, fontPackage: _p);

  /// Document plus icon.
  static const documentPlus = IconData(0xf1a0, fontFamily: _f, fontPackage: _p);

  /// Document minus icon.
  static const documentMinus = IconData(0xf1a1, fontFamily: _f, fontPackage: _p);

  /// Document check icon.
  static const documentCheck = IconData(0xf1aa, fontFamily: _f, fontPackage: _p);

  /// Document duplicate icon.
  static const documentDuplicate = IconData(0xf1a3, fontFamily: _f, fontPackage: _p);

  /// Document magnifying glass icon.
  static const documentMagnifyingGlass = IconData(0xf1a2, fontFamily: _f, fontPackage: _p);

  /// Document chart bar icon.
  static const documentChartBar = IconData(0xf1ab, fontFamily: _f, fontPackage: _p);

  /// Document arrow up icon.
  static const documentArrowUp = IconData(0xf1ac, fontFamily: _f, fontPackage: _p);

  /// Document arrow down icon.
  static const documentArrowDown = IconData(0xf1ad, fontFamily: _f, fontPackage: _p);

  /// Document currency dollar icon.
  static const documentCurrencyDollar = IconData(0xf1a8, fontFamily: _f, fontPackage: _p);

  /// Document currency euro icon.
  static const documentCurrencyEuro = IconData(0xf1a7, fontFamily: _f, fontPackage: _p);

  /// Document currency pound icon.
  static const documentCurrencyPound = IconData(0xf1a6, fontFamily: _f, fontPackage: _p);

  /// Document currency rupee icon.
  static const documentCurrencyRupee = IconData(0xf1a5, fontFamily: _f, fontPackage: _p);

  /// Document currency yen icon.
  static const documentCurrencyYen = IconData(0xf1a4, fontFamily: _f, fontPackage: _p);

  /// Document currency bangladeshi icon.
  static const documentCurrencyBangladeshi = IconData(0xf1a9, fontFamily: _f, fontPackage: _p);

  /// Clipboard icon.
  static const clipboard = IconData(0xf1c8, fontFamily: _f, fontPackage: _p);

  /// Clipboard document icon.
  static const clipboardDocument = IconData(0xf1c9, fontFamily: _f, fontPackage: _p);

  /// Clipboard document list icon.
  static const clipboardDocumentList = IconData(0xf1ca, fontFamily: _f, fontPackage: _p);

  /// Clipboard document check icon.
  static const clipboardDocumentCheck = IconData(0xf1cb, fontFamily: _f, fontPackage: _p);

  /// Paper clip icon.
  static const paperClip = IconData(0xf153, fontFamily: _f, fontPackage: _p);

  /// Paper airplane icon.
  static const paperAirplane = IconData(0xf154, fontFamily: _f, fontPackage: _p);

  /// Newspaper icon.
  static const newspaper = IconData(0xf158, fontFamily: _f, fontPackage: _p);

  /// Book open icon.
  static const bookOpen = IconData(0xf1f2, fontFamily: _f, fontPackage: _p);

  /// Bookmark icon.
  static const bookmark = IconData(0xf1ef, fontFamily: _f, fontPackage: _p);

  /// Bookmark square icon.
  static const bookmarkSquare = IconData(0xf1f0, fontFamily: _f, fontPackage: _p);

  /// Bookmark slash icon.
  static const bookmarkSlash = IconData(0xf1f1, fontFamily: _f, fontPackage: _p);

  /// Academic cap icon.
  static const academicCap = IconData(0xf244, fontFamily: _f, fontPackage: _p);

  /// Bold icon.
  static const bold = IconData(0xf1f5, fontFamily: _f, fontPackage: _p);

  /// Italic icon.
  static const italic = IconData(0xf16f, fontFamily: _f, fontPackage: _p);

  /// Underline icon.
  static const underline = IconData(0xf113, fontFamily: _f, fontPackage: _p);

  /// Strikethrough icon.
  static const strikethrough = IconData(0xf11d, fontFamily: _f, fontPackage: _p);

  /// H1 icon.
  static const h1 = IconData(0xf17e, fontFamily: _f, fontPackage: _p);

  /// H2 icon.
  static const h2 = IconData(0xf17d, fontFamily: _f, fontPackage: _p);

  /// H3 icon.
  static const h3 = IconData(0xf17c, fontFamily: _f, fontPackage: _p);

  /// Numbered list icon.
  static const numberedList = IconData(0xf156, fontFamily: _f, fontPackage: _p);

  /// List bullet icon.
  static const listBullet = IconData(0xf168, fontFamily: _f, fontPackage: _p);

  /// Hashtag icon.
  static const hashtag = IconData(0xf178, fontFamily: _f, fontPackage: _p);

  /// Language icon.
  static const language = IconData(0xf16d, fontFamily: _f, fontPackage: _p);

  // ── Files & Folders ───────────────────────────────────────────────

  /// Folder icon.
  static const folder = IconData(0xf188, fontFamily: _f, fontPackage: _p);

  /// Folder open icon.
  static const folderOpen = IconData(0xf18a, fontFamily: _f, fontPackage: _p);

  /// Folder plus icon.
  static const folderPlus = IconData(0xf189, fontFamily: _f, fontPackage: _p);

  /// Folder minus icon.
  static const folderMinus = IconData(0xf18b, fontFamily: _f, fontPackage: _p);

  /// Folder arrow down icon.
  static const folderArrowDown = IconData(0xf18c, fontFamily: _f, fontPackage: _p);

  /// Archive box icon.
  static const archiveBox = IconData(0xf23f, fontFamily: _f, fontPackage: _p);

  /// Archive box arrow down icon.
  static const archiveBoxArrowDown = IconData(0xf241, fontFamily: _f, fontPackage: _p);

  /// Archive box x mark icon.
  static const archiveBoxXMark = IconData(0xf240, fontFamily: _f, fontPackage: _p);

  /// Cloud icon.
  static const cloud = IconData(0xf1c4, fontFamily: _f, fontPackage: _p);

  /// Cloud arrow up icon.
  static const cloudArrowUp = IconData(0xf1c5, fontFamily: _f, fontPackage: _p);

  /// Cloud arrow down icon.
  static const cloudArrowDown = IconData(0xf1c6, fontFamily: _f, fontPackage: _p);

  /// Server icon.
  static const server = IconData(0xf130, fontFamily: _f, fontPackage: _p);

  /// Server stack icon.
  static const serverStack = IconData(0xf131, fontFamily: _f, fontPackage: _p);

  /// Circle stack icon.
  static const circleStack = IconData(0xf1cc, fontFamily: _f, fontPackage: _p);

  /// Rectangle stack icon.
  static const rectangleStack = IconData(0xf136, fontFamily: _f, fontPackage: _p);

  /// Square 2 stack icon.
  static const square2Stack = IconData(0xf124, fontFamily: _f, fontPackage: _p);

  /// Square 3 stack 3d icon.
  static const square3Stack3d = IconData(0xf123, fontFamily: _f, fontPackage: _p);

  // ── Media ─────────────────────────────────────────────────────────

  /// Photo icon.
  static const photo = IconData(0xf149, fontFamily: _f, fontPackage: _p);

  /// Camera icon.
  static const camera = IconData(0xf1e3, fontFamily: _f, fontPackage: _p);

  /// Film icon.
  static const film = IconData(0xf190, fontFamily: _f, fontPackage: _p);

  /// Video camera icon.
  static const videoCamera = IconData(0xf10a, fontFamily: _f, fontPackage: _p);

  /// Video camera slash icon.
  static const videoCameraSlash = IconData(0xf10b, fontFamily: _f, fontPackage: _p);

  /// Musical note icon.
  static const musicalNote = IconData(0xf159, fontFamily: _f, fontPackage: _p);

  /// Microphone icon.
  static const microphone = IconData(0xf15e, fontFamily: _f, fontPackage: _p);

  /// Speaker wave icon.
  static const speakerWave = IconData(0xf126, fontFamily: _f, fontPackage: _p);

  /// Speaker x mark icon.
  static const speakerXMark = IconData(0xf125, fontFamily: _f, fontPackage: _p);

  /// Play icon.
  static const play = IconData(0xf146, fontFamily: _f, fontPackage: _p);

  /// Play circle icon.
  static const playCircle = IconData(0xf148, fontFamily: _f, fontPackage: _p);

  /// Play pause icon.
  static const playPause = IconData(0xf147, fontFamily: _f, fontPackage: _p);

  /// Pause icon.
  static const pause = IconData(0xf151, fontFamily: _f, fontPackage: _p);

  /// Pause circle icon.
  static const pauseCircle = IconData(0xf152, fontFamily: _f, fontPackage: _p);

  /// Stop icon.
  static const stop = IconData(0xf11e, fontFamily: _f, fontPackage: _p);

  /// Stop circle icon.
  static const stopCircle = IconData(0xf11f, fontFamily: _f, fontPackage: _p);

  /// Forward icon.
  static const forward = IconData(0xf187, fontFamily: _f, fontPackage: _p);

  /// Backward icon.
  static const backward = IconData(0xf207, fontFamily: _f, fontPackage: _p);

  /// Radio icon.
  static const radio = IconData(0xf13a, fontFamily: _f, fontPackage: _p);

  // ── Data & Charts ─────────────────────────────────────────────────

  /// Chart bar icon.
  static const chartBar = IconData(0xf1e1, fontFamily: _f, fontPackage: _p);

  /// Chart bar square icon.
  static const chartBarSquare = IconData(0xf1e2, fontFamily: _f, fontPackage: _p);

  /// Chart pie icon.
  static const chartPie = IconData(0xf1e0, fontFamily: _f, fontPackage: _p);

  /// Presentation chart bar icon.
  static const presentationChartBar = IconData(0xf141, fontFamily: _f, fontPackage: _p);

  /// Presentation chart line icon.
  static const presentationChartLine = IconData(0xf140, fontFamily: _f, fontPackage: _p);

  /// Table cells icon.
  static const tableCells = IconData(0xf11a, fontFamily: _f, fontPackage: _p);

  /// Calculator icon.
  static const calculator = IconData(0xf1e7, fontFamily: _f, fontPackage: _p);

  /// Variable icon.
  static const variable = IconData(0xf10c, fontFamily: _f, fontPackage: _p);

  /// Percent badge icon.
  static const percentBadge = IconData(0xf14e, fontFamily: _f, fontPackage: _p);

  /// Equals icon.
  static const equals = IconData(0xf198, fontFamily: _f, fontPackage: _p);

  /// Divide icon.
  static const divide = IconData(0xf1ae, fontFamily: _f, fontPackage: _p);

  /// Currency dollar icon.
  static const currencyDollar = IconData(0xf1b7, fontFamily: _f, fontPackage: _p);

  /// Currency euro icon.
  static const currencyEuro = IconData(0xf1b6, fontFamily: _f, fontPackage: _p);

  /// Currency pound icon.
  static const currencyPound = IconData(0xf1b5, fontFamily: _f, fontPackage: _p);

  /// Currency rupee icon.
  static const currencyRupee = IconData(0xf1b4, fontFamily: _f, fontPackage: _p);

  /// Currency yen icon.
  static const currencyYen = IconData(0xf1b3, fontFamily: _f, fontPackage: _p);

  /// Currency bangladeshi icon.
  static const currencyBangladeshi = IconData(0xf1b8, fontFamily: _f, fontPackage: _p);

  /// Banknotes icon.
  static const banknotes = IconData(0xf206, fontFamily: _f, fontPackage: _p);

  /// Credit card icon.
  static const creditCard = IconData(0xf1bb, fontFamily: _f, fontPackage: _p);

  /// Receipt percent icon.
  static const receiptPercent = IconData(0xf139, fontFamily: _f, fontPackage: _p);

  /// Receipt refund icon.
  static const receiptRefund = IconData(0xf138, fontFamily: _f, fontPackage: _p);

  /// Scale icon.
  static const scale = IconData(0xf133, fontFamily: _f, fontPackage: _p);

  // ── People ────────────────────────────────────────────────────────

  /// User icon.
  static const user = IconData(0xf10e, fontFamily: _f, fontPackage: _p);

  /// Users icon.
  static const users = IconData(0xf10d, fontFamily: _f, fontPackage: _p);

  /// User plus icon.
  static const userPlus = IconData(0xf10f, fontFamily: _f, fontPackage: _p);

  /// User minus icon.
  static const userMinus = IconData(0xf110, fontFamily: _f, fontPackage: _p);

  /// User group icon.
  static const userGroup = IconData(0xf111, fontFamily: _f, fontPackage: _p);

  /// User circle icon.
  static const userCircle = IconData(0xf112, fontFamily: _f, fontPackage: _p);

  /// Identification icon.
  static const identification = IconData(0xf174, fontFamily: _f, fontPackage: _p);

  /// Finger print icon.
  static const fingerPrint = IconData(0xf18f, fontFamily: _f, fontPackage: _p);

  /// Hand raised icon.
  static const handRaised = IconData(0xf17b, fontFamily: _f, fontPackage: _p);

  /// Hand thumb up icon.
  static const handThumbUp = IconData(0xf179, fontFamily: _f, fontPackage: _p);

  /// Hand thumb down icon.
  static const handThumbDown = IconData(0xf17a, fontFamily: _f, fontPackage: _p);

  /// Face smile icon.
  static const faceSmile = IconData(0xf191, fontFamily: _f, fontPackage: _p);

  /// Face frown icon.
  static const faceFrown = IconData(0xf192, fontFamily: _f, fontPackage: _p);

  // ── Layout & View ─────────────────────────────────────────────────

  /// Squares 2x2 icon.
  static const squares2x2 = IconData(0xf122, fontFamily: _f, fontPackage: _p);

  /// Squares plus icon.
  static const squaresPlus = IconData(0xf121, fontFamily: _f, fontPackage: _p);

  /// Rectangle group icon.
  static const rectangleGroup = IconData(0xf137, fontFamily: _f, fontPackage: _p);

  /// View columns icon.
  static const viewColumns = IconData(0xf109, fontFamily: _f, fontPackage: _p);

  /// Viewfinder circle icon.
  static const viewfinderCircle = IconData(0xf108, fontFamily: _f, fontPackage: _p);

  /// Eye icon.
  static const eye = IconData(0xf193, fontFamily: _f, fontPackage: _p);

  /// Eye slash icon.
  static const eyeSlash = IconData(0xf194, fontFamily: _f, fontPackage: _p);

  /// Eye dropper icon.
  static const eyeDropper = IconData(0xf195, fontFamily: _f, fontPackage: _p);

  /// Bars 2 icon.
  static const bars2 = IconData(0xf205, fontFamily: _f, fontPackage: _p);

  /// Bars 3 icon.
  static const bars3 = IconData(0xf201, fontFamily: _f, fontPackage: _p);

  /// Bars 3 bottom left icon.
  static const bars3BottomLeft = IconData(0xf204, fontFamily: _f, fontPackage: _p);

  /// Bars 3 bottom right icon.
  static const bars3BottomRight = IconData(0xf203, fontFamily: _f, fontPackage: _p);

  /// Bars 3 center left icon.
  static const bars3CenterLeft = IconData(0xf202, fontFamily: _f, fontPackage: _p);

  /// Bars 4 icon.
  static const bars4 = IconData(0xf200, fontFamily: _f, fontPackage: _p);

  /// Queue list icon.
  static const queueList = IconData(0xf13b, fontFamily: _f, fontPackage: _p);

  /// Ellipsis horizontal icon.
  static const ellipsisHorizontal = IconData(0xf19c, fontFamily: _f, fontPackage: _p);

  /// Ellipsis horizontal circle icon.
  static const ellipsisHorizontalCircle = IconData(0xf19d, fontFamily: _f, fontPackage: _p);

  /// Ellipsis vertical icon.
  static const ellipsisVertical = IconData(0xf19b, fontFamily: _f, fontPackage: _p);

  /// Cursor arrow rays icon.
  static const cursorArrowRays = IconData(0xf1b2, fontFamily: _f, fontPackage: _p);

  /// Cursor arrow ripple icon.
  static const cursorArrowRipple = IconData(0xf1b1, fontFamily: _f, fontPackage: _p);

  /// Slash icon.
  static const slash = IconData(0xf128, fontFamily: _f, fontPackage: _p);

  // ── Status & Feedback ─────────────────────────────────────────────

  /// Exclamation triangle icon.
  static const exclamationTriangle = IconData(0xf196, fontFamily: _f, fontPackage: _p);

  /// Exclamation circle icon.
  static const exclamationCircle = IconData(0xf197, fontFamily: _f, fontPackage: _p);

  /// Information circle icon.
  static const informationCircle = IconData(0xf170, fontFamily: _f, fontPackage: _p);

  /// Question mark circle icon.
  static const questionMarkCircle = IconData(0xf13c, fontFamily: _f, fontPackage: _p);

  /// No symbol icon.
  static const noSymbol = IconData(0xf157, fontFamily: _f, fontPackage: _p);

  /// Shield check icon.
  static const shieldCheck = IconData(0xf12e, fontFamily: _f, fontPackage: _p);

  /// Shield exclamation icon.
  static const shieldExclamation = IconData(0xf12d, fontFamily: _f, fontPackage: _p);

  /// Bug ant icon.
  static const bugAnt = IconData(0xf1ed, fontFamily: _f, fontPackage: _p);

  /// Light bulb icon.
  static const lightBulb = IconData(0xf16b, fontFamily: _f, fontPackage: _p);

  /// Fire icon.
  static const fire = IconData(0xf18e, fontFamily: _f, fontPackage: _p);

  /// Bolt icon.
  static const bolt = IconData(0xf1f3, fontFamily: _f, fontPackage: _p);

  /// Bolt slash icon.
  static const boltSlash = IconData(0xf1f4, fontFamily: _f, fontPackage: _p);

  /// Sparkles icon.
  static const sparkles = IconData(0xf127, fontFamily: _f, fontPackage: _p);

  /// Star icon.
  static const star = IconData(0xf120, fontFamily: _f, fontPackage: _p);

  /// Heart icon.
  static const heart = IconData(0xf177, fontFamily: _f, fontPackage: _p);

  /// Flag icon.
  static const flag = IconData(0xf18d, fontFamily: _f, fontPackage: _p);

  /// Trophy icon.
  static const trophy = IconData(0xf116, fontFamily: _f, fontPackage: _p);

  /// Gift icon.
  static const gift = IconData(0xf183, fontFamily: _f, fontPackage: _p);

  /// Gift top icon.
  static const giftTop = IconData(0xf184, fontFamily: _f, fontPackage: _p);

  /// Cake icon.
  static const cake = IconData(0xf1e8, fontFamily: _f, fontPackage: _p);

  /// Beaker icon.
  static const beaker = IconData(0xf1fa, fontFamily: _f, fontPackage: _p);

  // ── Appearance & Settings ─────────────────────────────────────────

  /// Sun icon.
  static const sun = IconData(0xf11c, fontFamily: _f, fontPackage: _p);

  /// Moon icon.
  static const moon = IconData(0xf15a, fontFamily: _f, fontPackage: _p);

  /// Cog icon.
  static const cog = IconData(0xf1bf, fontFamily: _f, fontPackage: _p);

  /// Cog 6 tooth icon.
  static const cog6Tooth = IconData(0xf1c1, fontFamily: _f, fontPackage: _p);

  /// Cog 8 tooth icon.
  static const cog8Tooth = IconData(0xf1c0, fontFamily: _f, fontPackage: _p);

  /// Swatch icon.
  static const swatch = IconData(0xf11b, fontFamily: _f, fontPackage: _p);

  /// Paint brush icon.
  static const paintBrush = IconData(0xf155, fontFamily: _f, fontPackage: _p);

  // ── Objects ───────────────────────────────────────────────────────

  /// Home icon.
  static const home = IconData(0xf175, fontFamily: _f, fontPackage: _p);

  /// Home modern icon.
  static const homeModern = IconData(0xf176, fontFamily: _f, fontPackage: _p);

  /// Building office icon.
  static const buildingOffice = IconData(0xf1ea, fontFamily: _f, fontPackage: _p);

  /// Building office 2 icon.
  static const buildingOffice2 = IconData(0xf1eb, fontFamily: _f, fontPackage: _p);

  /// Building library icon.
  static const buildingLibrary = IconData(0xf1ec, fontFamily: _f, fontPackage: _p);

  /// Building storefront icon.
  static const buildingStorefront = IconData(0xf1e9, fontFamily: _f, fontPackage: _p);

  /// Briefcase icon.
  static const briefcase = IconData(0xf1ee, fontFamily: _f, fontPackage: _p);

  /// Shopping cart icon.
  static const shoppingCart = IconData(0xf12b, fontFamily: _f, fontPackage: _p);

  /// Shopping bag icon.
  static const shoppingBag = IconData(0xf12c, fontFamily: _f, fontPackage: _p);

  /// Ticket icon.
  static const ticket = IconData(0xf118, fontFamily: _f, fontPackage: _p);

  /// Tag icon.
  static const tag = IconData(0xf119, fontFamily: _f, fontPackage: _p);

  /// Key icon.
  static const key = IconData(0xf16e, fontFamily: _f, fontPackage: _p);

  /// Lock closed icon.
  static const lockClosed = IconData(0xf167, fontFamily: _f, fontPackage: _p);

  /// Lock open icon.
  static const lockOpen = IconData(0xf166, fontFamily: _f, fontPackage: _p);

  /// Wrench icon.
  static const wrench = IconData(0xf103, fontFamily: _f, fontPackage: _p);

  /// Wrench screwdriver icon.
  static const wrenchScrewdriver = IconData(0xf104, fontFamily: _f, fontPackage: _p);

  /// Scissors icon.
  static const scissors = IconData(0xf132, fontFamily: _f, fontPackage: _p);

  /// Printer icon.
  static const printer = IconData(0xf13f, fontFamily: _f, fontPackage: _p);

  /// Map icon.
  static const map = IconData(0xf160, fontFamily: _f, fontPackage: _p);

  /// Map pin icon.
  static const mapPin = IconData(0xf161, fontFamily: _f, fontPackage: _p);

  /// Globe alt icon.
  static const globeAlt = IconData(0xf182, fontFamily: _f, fontPackage: _p);

  /// Globe americas icon.
  static const globeAmericas = IconData(0xf181, fontFamily: _f, fontPackage: _p);

  /// Globe asia australia icon.
  static const globeAsiaAustralia = IconData(0xf180, fontFamily: _f, fontPackage: _p);

  /// Globe europe africa icon.
  static const globeEuropeAfrica = IconData(0xf17f, fontFamily: _f, fontPackage: _p);

  /// Lifebuoy icon.
  static const lifebuoy = IconData(0xf16c, fontFamily: _f, fontPackage: _p);

  /// Rocket launch icon.
  static const rocketLaunch = IconData(0xf135, fontFamily: _f, fontPackage: _p);

  /// Truck icon.
  static const truck = IconData(0xf115, fontFamily: _f, fontPackage: _p);

  /// Wallet icon.
  static const wallet = IconData(0xf107, fontFamily: _f, fontPackage: _p);

  /// Puzzle piece icon.
  static const puzzlePiece = IconData(0xf13e, fontFamily: _f, fontPackage: _p);

  /// Cube icon.
  static const cube = IconData(0xf1b9, fontFamily: _f, fontPackage: _p);

  /// Cube transparent icon.
  static const cubeTransparent = IconData(0xf1ba, fontFamily: _f, fontPackage: _p);

  /// Command line icon.
  static const commandLine = IconData(0xf1be, fontFamily: _f, fontPackage: _p);

  /// Code bracket icon.
  static const codeBracket = IconData(0xf1c2, fontFamily: _f, fontPackage: _p);

  /// Code bracket square icon.
  static const codeBracketSquare = IconData(0xf1c3, fontFamily: _f, fontPackage: _p);

  /// Cpu chip icon.
  static const cpuChip = IconData(0xf1bc, fontFamily: _f, fontPackage: _p);

  /// Wifi icon.
  static const wifi = IconData(0xf106, fontFamily: _f, fontPackage: _p);

  /// Tv icon.
  static const tv = IconData(0xf114, fontFamily: _f, fontPackage: _p);

  /// Device phone mobile icon.
  static const devicePhoneMobile = IconData(0xf1b0, fontFamily: _f, fontPackage: _p);

  /// Device tablet icon.
  static const deviceTablet = IconData(0xf1af, fontFamily: _f, fontPackage: _p);

  /// Computer desktop icon.
  static const computerDesktop = IconData(0xf1bd, fontFamily: _f, fontPackage: _p);

  /// Window icon.
  static const window = IconData(0xf105, fontFamily: _f, fontPackage: _p);

  /// Battery 0 icon.
  static const battery0 = IconData(0xf1fd, fontFamily: _f, fontPackage: _p);

  /// Battery 50 icon.
  static const battery50 = IconData(0xf1fb, fontFamily: _f, fontPackage: _p);

  /// Battery 100 icon.
  static const battery100 = IconData(0xf1fc, fontFamily: _f, fontPackage: _p);

  /// Gif icon.
  static const gif = IconData(0xf185, fontFamily: _f, fontPackage: _p);

  // ── Time ──────────────────────────────────────────────────────────

  /// Clock icon.
  static const clock = IconData(0xf1c7, fontFamily: _f, fontPackage: _p);

  /// Calendar icon.
  static const calendar = IconData(0xf1e4, fontFamily: _f, fontPackage: _p);

  /// Calendar days icon.
  static const calendarDays = IconData(0xf1e5, fontFamily: _f, fontPackage: _p);

  /// Calendar date range icon.
  static const calendarDateRange = IconData(0xf1e6, fontFamily: _f, fontPackage: _p);

  // ── Backward-compatible aliases ────────────────────────────────

  /// Alias for [clock] (backward compatibility).
  static const accessTime = clock;

  /// Alias for [userCircle] (backward compatibility).
  static const accountCircle = userCircle;

  /// Alias for [plus] (backward compatibility).
  static const add = plus;

  /// Alias for [chevronDown] (backward compatibility).
  static const arrowDropDown = chevronDown;

  /// Alias for [arrowUp] (backward compatibility).
  static const arrowUpward = arrowUp;

  /// Alias for [paperClip] (backward compatibility).
  static const attachFile = paperClip;

  /// Alias for [musicalNote] (backward compatibility).
  static const audioFile = musicalNote;

  /// Alias for [noSymbol] (backward compatibility).
  static const block = noSymbol;

  /// Alias for [xMark] (backward compatibility).
  static const close = xMark;

  /// Alias for [cloudArrowUp] (backward compatibility).
  static const cloudUpload = cloudArrowUp;

  /// Alias for [codeBracket] (backward compatibility).
  static const code = codeBracket;

  /// Alias for [clipboardDocument] (backward compatibility).
  static const contentCopy = clipboardDocument;

  /// Alias for [clipboard] (backward compatibility).
  static const contentPaste = clipboard;

  /// Alias for [folderPlus] (backward compatibility).
  static const createNewFolder = folderPlus;

  /// Alias for [moon] (backward compatibility).
  static const darkMode = moon;

  /// Alias for [squares2x2] (backward compatibility).
  static const dashboardCustomize = squares2x2;

  /// Alias for [circleStack] (backward compatibility).
  static const dataObject = circleStack;

  /// Alias for [trash] (backward compatibility).
  static const delete = trash;

  /// Alias for [documentText] (backward compatibility).
  static const description = documentText;

  /// Alias for [check] (backward compatibility).
  static const done = check;

  /// Alias for [arrowDownTray] (backward compatibility).
  static const download = arrowDownTray;

  /// Alias for [folderArrowDown] (backward compatibility).
  static const driveFileMove = folderArrowDown;

  /// Alias for [pencil] (backward compatibility).
  static const edit = pencil;

  /// Alias for [faceSmile] (backward compatibility).
  static const emojiEmotions = faceSmile;

  /// Alias for [exclamationCircle] (backward compatibility).
  static const errorOutline = exclamationCircle;

  /// Alias for [calendarDays] (backward compatibility).
  static const event = calendarDays;

  /// Alias for [chevronUp] (backward compatibility).
  static const expandLess = chevronUp;

  /// Alias for [chevronDown] (backward compatibility).
  static const expandMore = chevronDown;

  /// Alias for [archiveBox] (backward compatibility).
  static const folderZip = archiveBox;

  /// Alias for [listBullet] (backward compatibility).
  static const formatListBulleted = listBullet;

  /// Alias for [squares2x2] (backward compatibility).
  static const gridView = squares2x2;

  /// Alias for [userGroup] (backward compatibility).
  static const group = userGroup;

  /// Alias for [clock] (backward compatibility).
  static const history = clock;

  /// Alias for [photo] (backward compatibility).
  static const image = photo;

  /// Alias for [informationCircle] (backward compatibility).
  static const info = informationCircle;

  /// Alias for [document] (backward compatibility).
  static const insertDriveFile = document;

  /// Alias for [sun] (backward compatibility).
  static const lightMode = sun;

  /// Alias for [lockClosed] (backward compatibility).
  static const lock = lockClosed;

  /// Alias for [arrowRightOnRectangle] (backward compatibility).
  static const logout = arrowRightOnRectangle;

  /// Alias for [computerDesktop] (backward compatibility).
  static const monitor = computerDesktop;

  /// Alias for [chevronLeft] (backward compatibility).
  static const navigateBefore = chevronLeft;

  /// Alias for [chevronRight] (backward compatibility).
  static const navigateNext = chevronRight;

  /// Alias for [bell] (backward compatibility).
  static const notifications = bell;

  /// Alias for [user] (backward compatibility).
  static const person = user;

  /// Alias for [documentText] (backward compatibility).
  static const pictureAsPdf = documentText;

  /// Alias for [play] (backward compatibility).
  static const playArrow = play;

  /// Alias for [playCircle] (backward compatibility).
  static const playCircleFilled = playCircle;

  /// Alias for [noSymbol] (backward compatibility).
  static const radioButtonUnchecked = noSymbol;

  /// Alias for [arrowUturnLeft] (backward compatibility).
  static const reply = arrowUturnLeft;

  /// Alias for [clock] (backward compatibility).
  static const schedule = clock;

  /// Alias for [magnifyingGlass] (backward compatibility).
  static const search = magnifyingGlass;

  /// Alias for [cog] (backward compatibility).
  static const settings = cog;

  /// Alias for [presentationChartBar] (backward compatibility).
  static const slideshow = presentationChartBar;

  /// Alias for [tableCells] (backward compatibility).
  static const tableChart = tableCells;

  /// Alias for [documentText] (backward compatibility).
  static const textSnippet = documentText;

  /// Alias for [handThumbDown] (backward compatibility).
  static const thumbDown = handThumbDown;

  /// Alias for [handThumbUp] (backward compatibility).
  static const thumbUp = handThumbUp;

  /// Alias for [arrowUpTray] (backward compatibility).
  static const uploadFile = arrowUpTray;

  /// Alias for [videoCamera] (backward compatibility).
  static const videoFile = videoCamera;

  /// Alias for [bars3] (backward compatibility).
  static const viewList = bars3;

  /// Alias for [exclamationTriangle] (backward compatibility).
  static const warning = exclamationTriangle;
}

