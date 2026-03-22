import 'package:obers_ui/obers_ui.dart';
// The barrel file hides OiReactionData (chat) and OiFileData from oi_chat.dart
// in favour of the simpler OiReactionData from oi_reaction_bar.dart.
// OiChatMessage.reactions expects the chat-module variant, so import it
// directly and alias to avoid the name clash.
// ignore: implementation_imports
import 'package:obers_ui/src/modules/oi_chat.dart' as chat;

import 'package:obers_ui_example/data/mock_users.dart';

// ── Timestamps ───────────────────────────────────────────────────────────────

final now = DateTime.now();

// ── Channel model ────────────────────────────────────────────────────────────

class MockChannel {
  const MockChannel({
    required this.id,
    required this.name,
    required this.description,
    this.topic = '',
    this.members = const [],
    this.unreadCount = 0,
    this.isDM = false,
  });

  final String id;
  final String name;
  final String description;
  final String topic;
  final List<MockUser> members;
  final int unreadCount;
  final bool isDM;
}

// ── Online users ─────────────────────────────────────────────────────────────

const kOnlineUsers = {
  'user-hans',
  'user-liesl',
  'user-anna',
  'user-stefan',
  'user-current',
};

// ── Channels ─────────────────────────────────────────────────────────────────

final kChannels = [
  const MockChannel(
    id: 'general',
    name: '#general',
    description: 'Company-wide announcements and water-cooler chat',
    topic: 'Kaffeepause at 15:00 sharp. No exceptions.',
    members: [
      kCurrentUser,
      kHans,
      kLiesl,
      kFranz,
      kMaria,
      kStefan,
      kAnna,
      kMaximilian,
      kKlara,
    ],
    unreadCount: 3,
  ),
  const MockChannel(
    id: 'food-reviews',
    name: '#food-reviews',
    description: 'Reviews of Beisl, Heurigen, and office snacks',
    topic: 'Semmelknoedel rating scale now official company policy.',
    members: [kCurrentUser, kHans, kFranz, kLiesl, kMaximilian, kKlara, kMaria],
  ),
  const MockChannel(
    id: 'alpine-adventures',
    name: '#alpine-adventures',
    description: 'Hiking trips, ski reports, and mountain emergencies',
    topic: 'Next hike: Rax via Hoyos-Steig, Saturday 08:00.',
    members: [kCurrentUser, kHans, kLiesl, kStefan, kMaria],
  ),
  const MockChannel(
    id: 'office-banter',
    name: '#office-banter',
    description: 'The channel HR pretends not to read',
    topic: 'Manner Schnitten theft investigations ongoing.',
    members: [
      kCurrentUser,
      kStefan,
      kFranz,
      kAnna,
      kLiesl,
      kHans,
      kMaria,
      kMaximilian,
    ],
    unreadCount: 12,
  ),
  const MockChannel(
    id: 'development',
    name: '#development',
    description: 'PRs, deployments, and existential code reviews',
    topic: 'Production deploy Monday 06:00. Croissants as hazard pay.',
    members: [
      kCurrentUser,
      kLiesl,
      kStefan,
      kMaximilian,
      kAnna,
      kHans,
      kMaria,
      kFranz,
    ],
  ),
  // ── DM channels ──────────────────────────────────────────────────────────
  const MockChannel(
    id: 'dm-hans',
    name: 'Hans Gruber',
    description: 'Direct message',
    members: [kCurrentUser, kHans],
    isDM: true,
    unreadCount: 2,
  ),
  const MockChannel(
    id: 'dm-liesl',
    name: 'Liesl Edelweiss',
    description: 'Direct message',
    members: [kCurrentUser, kLiesl],
    isDM: true,
  ),
  const MockChannel(
    id: 'dm-anna',
    name: 'Anna Mozartkugel',
    description: 'Direct message',
    members: [kCurrentUser, kAnna],
    isDM: true,
    unreadCount: 1,
  ),
];

// ── Pinned messages ──────────────────────────────────────────────────────────

const kPinnedMessages = <String, List<String>>{
  'general': ['gen-1', 'gen-4'],
  'food-reviews': ['food-2'],
  'alpine-adventures': ['alp-1'],
  'office-banter': ['bant-6'],
  'development': ['dev-1', 'dev-6'],
};

// ── Channel messages ─────────────────────────────────────────────────────────

List<OiChatMessage> buildChannelMessages(String channelId) {
  switch (channelId) {
    case 'general':
      return _generalMessages();
    case 'food-reviews':
      return _foodReviewMessages();
    case 'alpine-adventures':
      return _alpineMessages();
    case 'office-banter':
      return _officeBanterMessages();
    case 'development':
      return _developmentMessages();
    case 'dm-hans':
      return _dmHansMessages();
    case 'dm-liesl':
      return _dmLieslMessages();
    case 'dm-anna':
      return _dmAnnaMessages();
    default:
      return [];
  }
}

List<OiChatMessage> _generalMessages() => [
  OiChatMessage(
    key: 'gen-1',
    senderId: kAnna.id,
    senderName: kAnna.name,
    content:
        'Reminder: Mandatory Kaffeepause at 15:00 today. '
        'Attendance is tracked. Excuses involving "deadlines" '
        'will not be accepted.',
    timestamp: now.subtract(const Duration(hours: 4, minutes: 32)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\u2615',
        count: 7,
        reacted: true,
        reactorNames: ['Hans', 'Liesl', 'Franz', 'Maria', 'Stefan'],
      ),
      const chat.OiReactionData(
        emoji: '\ud83d\ude4f',
        count: 3,
        reacted: false,
        reactorNames: ['Wolfgang', 'Klara', 'Maximilian'],
      ),
    ],
  ),
  OiChatMessage(
    key: 'gen-2',
    senderId: kFranz.id,
    senderName: kFranz.name,
    content:
        'Can we please settle the Topfenstrudel debate once and for all? '
        'Warm with vanilla sauce is the ONLY correct answer. '
        'I will not be taking questions.',
    timestamp: now.subtract(const Duration(hours: 3, minutes: 50)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83d\udd25',
        count: 4,
        reacted: true,
        reactorNames: ['Leopold', 'Hans', 'Maria'],
      ),
      const chat.OiReactionData(
        emoji: '\ud83d\udc4e',
        count: 2,
        reacted: false,
        reactorNames: ['Stefan', 'Liesl'],
      ),
    ],
  ),
  OiChatMessage(
    key: 'gen-3',
    senderId: kStefan.id,
    senderName: kStefan.name,
    content:
        'Franz, you are objectively wrong. Cold Topfenstrudel with '
        'Staubzucker is a perfectly valid life choice.',
    timestamp: now.subtract(const Duration(hours: 3, minutes: 45)),
  ),
  OiChatMessage(
    key: 'gen-4',
    senderId: kMaria.id,
    senderName: kMaria.name,
    content:
        'Moving on from pastry warfare \u2014 the Q1 dashboard redesign '
        'mockups are ready for review. I used the new color tokens. '
        'Please check the Figma link in #development.',
    timestamp: now.subtract(const Duration(hours: 2, minutes: 15)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83c\udf1f',
        count: 5,
        reacted: true,
        reactorNames: ['Anna', 'Liesl', 'Leopold', 'Hans'],
      ),
    ],
  ),
  OiChatMessage(
    key: 'gen-5',
    senderId: kCurrentUser.id,
    senderName: kCurrentUser.name,
    content:
        'The mockups look great, Maria. Let us schedule a review for '
        'tomorrow morning. And Franz \u2014 warm with vanilla sauce, '
        'obviously.',
    timestamp: now.subtract(const Duration(hours: 1, minutes: 40)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83d\ude02',
        count: 3,
        reacted: false,
        reactorNames: ['Franz', 'Anna', 'Stefan'],
      ),
    ],
  ),
];

List<OiChatMessage> _foodReviewMessages() => [
  OiChatMessage(
    key: 'food-1',
    senderId: kHans.id,
    senderName: kHans.name,
    content:
        'Went to Gasthaus Zum Goldenen Hirsch yesterday. '
        'The Tafelspitz was transcendent \u2014 perfectly boiled, '
        'served with Apfelkren and Schnittlauchsauce. '
        '11/10, would restructure my calendar around it.',
    timestamp: now.subtract(const Duration(hours: 6, minutes: 10)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83e\udd24',
        count: 6,
        reacted: true,
        reactorNames: ['Franz', 'Leopold', 'Maria', 'Anna', 'Stefan'],
      ),
    ],
  ),
  OiChatMessage(
    key: 'food-2',
    senderId: kFranz.id,
    senderName: kFranz.name,
    content:
        'I propose we adopt a standardized Semmelkn\u00f6del rating '
        'scale:\n'
        '\u2b50 1 \u2014 Sad tennis ball\n'
        '\u2b50\u2b50 2 \u2014 Acceptable but your Oma would cry\n'
        '\u2b50\u2b50\u2b50 3 \u2014 Solid Beisl quality\n'
        '\u2b50\u2b50\u2b50\u2b50 4 \u2014 Worth a detour\n'
        '\u2b50\u2b50\u2b50\u2b50\u2b50 5 \u2014 Oma-approved perfection',
    timestamp: now.subtract(const Duration(hours: 5, minutes: 30)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83d\udcaf',
        count: 5,
        reacted: true,
        reactorNames: ['Hans', 'Leopold', 'Maria', 'Liesl'],
      ),
      const chat.OiReactionData(
        emoji: '\ud83d\ude02',
        count: 3,
        reacted: false,
        reactorNames: ['Stefan', 'Anna', 'Maximilian'],
      ),
    ],
  ),
  OiChatMessage(
    key: 'food-3',
    senderId: kMaximilian.id,
    senderName: kMaximilian.name,
    content:
        'Can we talk about the office coffee machine? '
        'It produces a liquid that is technically coffee in the same way '
        'that a PDF is technically a document. '
        'It meets the minimum definition and nothing more.',
    timestamp: now.subtract(const Duration(hours: 4, minutes: 45)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83d\ude2d',
        count: 8,
        reacted: true,
        reactorNames: [
          'Hans',
          'Liesl',
          'Franz',
          'Maria',
          'Stefan',
          'Anna',
          'Leopold',
        ],
      ),
    ],
  ),
  OiChatMessage(
    key: 'food-4',
    senderId: kLiesl.id,
    senderName: kLiesl.name,
    content:
        'I brought my own Bialetti to the office. Life is too short '
        'for machine coffee. Come to desk 14 for a proper Mokka.',
    timestamp: now.subtract(const Duration(hours: 4, minutes: 20)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\u2615',
        count: 4,
        reacted: false,
        reactorNames: ['Maximilian', 'Stefan', 'Hans'],
      ),
      const chat.OiReactionData(
        emoji: '\u2764\ufe0f',
        count: 3,
        reacted: true,
        reactorNames: ['Franz', 'Anna'],
      ),
    ],
  ),
  OiChatMessage(
    key: 'food-5',
    senderId: kKlara.id,
    senderName: kKlara.name,
    content:
        'Update: Someone left Kaiserschmarrn in the kitchen. '
        'It vanished in 4 minutes. New office record.',
    timestamp: now.subtract(const Duration(hours: 3, minutes: 5)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83c\udfc6',
        count: 3,
        reacted: false,
        reactorNames: ['Franz', 'Hans', 'Wolfgang'],
      ),
    ],
  ),
];

List<OiChatMessage> _alpineMessages() => [
  OiChatMessage(
    key: 'alp-1',
    senderId: kHans.id,
    senderName: kHans.name,
    content:
        'Who is in for the Rax hike this Saturday? '
        'Planning to take the Hoyos-Steig route. '
        'Weather forecast says clear skies and 12\u00b0C at the summit.',
    timestamp: now.subtract(const Duration(days: 1, hours: 3)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\u26f0\ufe0f',
        count: 4,
        reacted: true,
        reactorNames: ['Leopold', 'Liesl', 'Stefan'],
      ),
    ],
  ),
  OiChatMessage(
    key: 'alp-2',
    senderId: kLiesl.id,
    senderName: kLiesl.name,
    content:
        'Count me in! I will bring the Jause. '
        'Last time Hans forgot the Speck and we almost had a mutiny.',
    timestamp: now.subtract(const Duration(days: 1, hours: 2, minutes: 40)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83d\ude02',
        count: 5,
        reacted: true,
        reactorNames: ['Hans', 'Stefan', 'Franz', 'Maria'],
      ),
    ],
  ),
  OiChatMessage(
    key: 'alp-3',
    senderId: kHans.id,
    senderName: kHans.name,
    content:
        'That was ONE time, Liesl. ONE TIME. '
        'Anyway, here is the trail map for everyone.',
    timestamp: now.subtract(const Duration(days: 1, hours: 2, minutes: 30)),
    attachments: [
      const chat.OiFileData(
        name: 'rax_hoyos_steig_trail_map.pdf',
        size: 2458624,
        mimeType: 'application/pdf',
      ),
    ],
  ),
  OiChatMessage(
    key: 'alp-4',
    senderId: kStefan.id,
    senderName: kStefan.name,
    content:
        'I am in. Meeting point at the Raxseilbahn parking lot at 08:00? '
        'And Hans, maybe also bring a first-aid kit this time. '
        'Your track record with loose rocks is... documented.',
    timestamp: now.subtract(const Duration(days: 1, hours: 1, minutes: 55)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83e\ude79',
        count: 2,
        reacted: false,
        reactorNames: ['Liesl', 'Maria'],
      ),
      const chat.OiReactionData(
        emoji: '\ud83d\udc4d',
        count: 3,
        reacted: true,
        reactorNames: ['Hans', 'Leopold'],
      ),
    ],
  ),
  OiChatMessage(
    key: 'alp-5',
    senderId: kMaria.id,
    senderName: kMaria.name,
    content:
        'Can not make Saturday but please take photos for the '
        'company Instagram. Last hike post got 400 likes \u2014 '
        'more than any product post. Our audience has spoken.',
    timestamp: now.subtract(const Duration(days: 1, hours: 1, minutes: 20)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83d\udcf8',
        count: 3,
        reacted: false,
        reactorNames: ['Hans', 'Liesl', 'Stefan'],
      ),
    ],
  ),
];

List<OiChatMessage> _officeBanterMessages() => [
  OiChatMessage(
    key: 'bant-1',
    senderId: kStefan.id,
    senderName: kStefan.name,
    content:
        'URGENT: Someone ate my labeled Manner Schnitten from the fridge. '
        'The label said "STEFAN \u2014 DO NOT TOUCH" in three languages. '
        'I have trust issues now.',
    timestamp: now.subtract(const Duration(hours: 2, minutes: 55)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83d\ude31',
        count: 4,
        reacted: false,
        reactorNames: ['Anna', 'Liesl', 'Hans', 'Maria'],
      ),
      const chat.OiReactionData(
        emoji: '\ud83d\ude08',
        count: 1,
        reacted: false,
        reactorNames: ['Franz'],
      ),
    ],
  ),
  OiChatMessage(
    key: 'bant-2',
    senderId: kFranz.id,
    senderName: kFranz.name,
    content:
        'I have no idea what you are talking about. '
        'Completely unrelated, but Manner Schnitten taste best '
        'when they belong to someone else.',
    timestamp: now.subtract(const Duration(hours: 2, minutes: 48)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83d\ude02',
        count: 7,
        reacted: true,
        reactorNames: [
          'Leopold',
          'Liesl',
          'Hans',
          'Maria',
          'Anna',
          'Maximilian',
        ],
      ),
    ],
  ),
  OiChatMessage(
    key: 'bant-3',
    senderId: kAnna.id,
    senderName: kAnna.name,
    content:
        'I checked the kitchen security camera footage. '
        'Franz, your alibi of "being in a meeting" falls apart '
        'at exactly 14:07 when you are clearly visible opening the '
        'fridge with surgical precision.',
    timestamp: now.subtract(const Duration(hours: 2, minutes: 40)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83d\udd2e',
        count: 3,
        reacted: false,
        reactorNames: ['Stefan', 'Liesl', 'Hans'],
      ),
      const chat.OiReactionData(
        emoji: '\ud83d\udea8',
        count: 2,
        reacted: true,
        reactorNames: ['Maximilian'],
      ),
    ],
  ),
  OiChatMessage(
    key: 'bant-4',
    senderId: kFranz.id,
    senderName: kFranz.name,
    content:
        'I was getting milk for my coffee. The Manner Schnitten '
        'fell into my hand accidentally. Several times.',
    timestamp: now.subtract(const Duration(hours: 2, minutes: 35)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83e\udd25',
        count: 6,
        reacted: true,
        reactorNames: ['Stefan', 'Anna', 'Liesl', 'Hans', 'Maria'],
      ),
    ],
  ),
  OiChatMessage(
    key: 'bant-5',
    senderId: kStefan.id,
    senderName: kStefan.name,
    content:
        'Franz, you owe me one pack of Manner Schnitten. '
        'The Neapolitan ones. Not the off-brand supermarket version. '
        'I have standards.',
    timestamp: now.subtract(const Duration(hours: 2, minutes: 28)),
  ),
  OiChatMessage(
    key: 'bant-6',
    senderId: kCurrentUser.id,
    senderName: kCurrentUser.name,
    content:
        'As CEO, I am legally required to remind everyone that '
        'snack theft is grounds for a strongly-worded Slack message. '
        'Franz, buy the man his Schnitten.',
    timestamp: now.subtract(const Duration(hours: 2, minutes: 10)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83d\ude4f',
        count: 4,
        reacted: false,
        reactorNames: ['Stefan', 'Anna', 'Liesl', 'Hans'],
      ),
      const chat.OiReactionData(
        emoji: '\ud83d\udc51',
        count: 2,
        reacted: false,
        reactorNames: ['Maria', 'Maximilian'],
      ),
    ],
  ),
];

List<OiChatMessage> _developmentMessages() => [
  OiChatMessage(
    key: 'dev-1',
    senderId: kLiesl.id,
    senderName: kLiesl.name,
    content:
        'Deploying v2.4.1 to staging in 10 minutes. '
        'Changes: new checkout flow, updated shipping calculator, '
        'and 47 lint fixes that haunted my dreams.',
    timestamp: now.subtract(const Duration(hours: 5, minutes: 20)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83d\ude80',
        count: 3,
        reacted: true,
        reactorNames: ['Stefan', 'Anna'],
      ),
    ],
  ),
  OiChatMessage(
    key: 'dev-2',
    senderId: kStefan.id,
    senderName: kStefan.name,
    content:
        'PR #342 is ready for review. Refactored the payment gateway '
        'integration. Reduced the function from 400 lines to 120. '
        'The previous author will remain anonymous to protect the guilty.',
    timestamp: now.subtract(const Duration(hours: 4, minutes: 50)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83e\udeb6',
        count: 2,
        reacted: false,
        reactorNames: ['Liesl', 'Anna'],
      ),
      const chat.OiReactionData(
        emoji: '\ud83d\ude4c',
        count: 3,
        reacted: true,
        reactorNames: ['Leopold', 'Maximilian'],
      ),
    ],
    attachments: [
      const chat.OiFileData(
        name: 'payment_refactor_diff.patch',
        size: 34816,
        mimeType: 'text/x-diff',
      ),
    ],
  ),
  OiChatMessage(
    key: 'dev-3',
    senderId: kMaximilian.id,
    senderName: kMaximilian.name,
    content:
        'I wrote 23 new test cases for the checkout flow. '
        'Found 3 edge cases where the shipping cost was calculated '
        'in Schilling instead of Euro. We are not in 2001 anymore.',
    timestamp: now.subtract(const Duration(hours: 4, minutes: 15)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83d\udc1b',
        count: 4,
        reacted: true,
        reactorNames: ['Liesl', 'Stefan', 'Anna'],
      ),
    ],
  ),
  OiChatMessage(
    key: 'dev-4',
    senderId: kLiesl.id,
    senderName: kLiesl.name,
    content:
        'Staging deploy complete. Green across the board. '
        'Stefan, your refactor actually works. I am genuinely surprised. '
        'And impressed. Mostly surprised.',
    timestamp: now.subtract(const Duration(hours: 3, minutes: 30)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83d\ude02',
        count: 5,
        reacted: true,
        reactorNames: ['Stefan', 'Anna', 'Leopold', 'Maximilian'],
      ),
      const chat.OiReactionData(
        emoji: '\u2705',
        count: 3,
        reacted: false,
        reactorNames: ['Hans', 'Maria', 'Franz'],
      ),
    ],
  ),
  OiChatMessage(
    key: 'dev-5',
    senderId: kStefan.id,
    senderName: kStefan.name,
    content:
        'Your confidence in me is truly heartwarming, Liesl. '
        'I will add "code that works" to my CV.',
    timestamp: now.subtract(const Duration(hours: 3, minutes: 20)),
  ),
  OiChatMessage(
    key: 'dev-6',
    senderId: kAnna.id,
    senderName: kAnna.name,
    content:
        'Production deploy is scheduled for Monday 06:00. '
        'Liesl and Stefan on standby. Croissants will be provided '
        'as hazard pay.',
    timestamp: now.subtract(const Duration(hours: 2, minutes: 45)),
    reactions: [
      const chat.OiReactionData(
        emoji: '\ud83e\udd50',
        count: 4,
        reacted: true,
        reactorNames: ['Liesl', 'Stefan', 'Leopold'],
      ),
    ],
  ),
];

// ── DM messages ──────────────────────────────────────────────────────────────

List<OiChatMessage> _dmHansMessages() => [
  OiChatMessage(
    key: 'dm-hans-1',
    senderId: kHans.id,
    senderName: kHans.name,
    content:
        'Leopold, quick question \u2014 are we ordering new hiking gear '
        'for the team this quarter? The boots budget from last year '
        'is still unspent.',
    timestamp: now.subtract(const Duration(hours: 3, minutes: 10)),
  ),
  OiChatMessage(
    key: 'dm-hans-2',
    senderId: kCurrentUser.id,
    senderName: kCurrentUser.name,
    content:
        'Yes, let us do it. Put together a list and send it to Anna '
        'for approval. Keep it under 5k and we should be fine.',
    timestamp: now.subtract(const Duration(hours: 2, minutes: 55)),
  ),
  OiChatMessage(
    key: 'dm-hans-3',
    senderId: kHans.id,
    senderName: kHans.name,
    content:
        'Perfect. Also, I found a great deal on Lowa Renegade GTX boots. '
        '30% off if we order 10+ pairs. Should I pull the trigger?',
    timestamp: now.subtract(const Duration(hours: 2, minutes: 40)),
  ),
  OiChatMessage(
    key: 'dm-hans-4',
    senderId: kCurrentUser.id,
    senderName: kCurrentUser.name,
    content:
        'Do it. Good boots are a legitimate business expense when '
        'half our team meetings happen on mountain trails.',
    timestamp: now.subtract(const Duration(hours: 2, minutes: 30)),
  ),
];

List<OiChatMessage> _dmLieslMessages() => [
  OiChatMessage(
    key: 'dm-liesl-1',
    senderId: kLiesl.id,
    senderName: kLiesl.name,
    content:
        'Hey Leopold, heads up \u2014 the staging deploy went smoothly '
        'but I noticed some memory spikes on the checkout service. '
        'Nothing critical yet, monitoring it.',
    timestamp: now.subtract(const Duration(hours: 4, minutes: 20)),
  ),
  OiChatMessage(
    key: 'dm-liesl-2',
    senderId: kCurrentUser.id,
    senderName: kCurrentUser.name,
    content:
        'Thanks for the heads up. Keep me posted if it gets worse. '
        'Do we need to delay the Monday production deploy?',
    timestamp: now.subtract(const Duration(hours: 4)),
  ),
  OiChatMessage(
    key: 'dm-liesl-3',
    senderId: kLiesl.id,
    senderName: kLiesl.name,
    content:
        'Not yet. Stefan thinks it might be a connection pool issue. '
        'We are adding more instrumentation this afternoon. '
        'If it is still spiking by Friday, we push the deploy.',
    timestamp: now.subtract(const Duration(hours: 3, minutes: 45)),
  ),
];

List<OiChatMessage> _dmAnnaMessages() => [
  OiChatMessage(
    key: 'dm-anna-1',
    senderId: kAnna.id,
    senderName: kAnna.name,
    content:
        'Leopold, the Q2 product roadmap draft is ready. '
        'Can we schedule 30 minutes tomorrow to go through it?',
    timestamp: now.subtract(const Duration(hours: 1, minutes: 30)),
  ),
  OiChatMessage(
    key: 'dm-anna-2',
    senderId: kCurrentUser.id,
    senderName: kCurrentUser.name,
    content: 'Sure, how about 10:00? I have a gap before the all-hands.',
    timestamp: now.subtract(const Duration(hours: 1, minutes: 15)),
  ),
  OiChatMessage(
    key: 'dm-anna-3',
    senderId: kAnna.id,
    senderName: kAnna.name,
    content:
        'Perfect. I will send the calendar invite. Also, Franz wants '
        'to add a "Snack Budget Transparency Report" to the roadmap. '
        'I told him no, but he is persistent.',
    timestamp: now.subtract(const Duration(hours: 1, minutes: 5)),
  ),
];

// ── Auto-response pools ──────────────────────────────────────────────────────

const kFoodResponses = [
  'That reminds me, has anyone tried the Kaiserschmarrn at the new place on Mariahilfer Strasse?',
  'Nothing a good Melange and a slice of Sachertorte cannot fix.',
  'Controversial opinion: Bosna from a Wuerstelstand beats any restaurant.',
  'I once had a Schnitzel so big it needed its own postcode.',
  'The only valid cheese is Bergkaese aged at least 12 months. Fight me.',
  'My Oma would have strong opinions about this. All of them correct.',
  'If it does not come with a side of Erdaepfelsalat, is it even a meal?',
  'Someone bring Punschkrapferl to the next standup. Non-negotiable.',
];

const kWorkResponses = [
  'LGTM, but I would rename that variable. You know which one.',
  'That PR needs more tests. I can feel the bugs from here.',
  'Deploying to staging now. Everyone hold your Schnitzel.',
  'I refactored that module last week. It sparks joy now.',
  'The CI pipeline is green. I repeat: the CI pipeline is GREEN.',
  'Can we add that to the backlog? The backlog where dreams go to retire.',
  'Pair programming session? I will bring the Kaffee, you bring the patience.',
  'That bug has been there since the Habsburg Empire. Time to fix it.',
];

const kGeneralResponses = [
  'Servus! Just got back from a Kaffeepause that turned into a marathon.',
  'Has anyone seen my Kugelschreiber? It is the good one from Mueller.',
  'Meeting room 3 smells like someone reheated Leberkaese again.',
  'I am convinced the office plant is judging our code quality.',
  'The wifi password is still "Kaiserschmarrn2024" and I think that is beautiful.',
  'Can we get a standing desk? My back has filed a formal complaint.',
  'Noted. Adding it to my growing collection of things to remember.',
  'The printer is jammed. This is not news. This is a lifestyle.',
];

// ── Auto-response picker ─────────────────────────────────────────────────────

int _foodIndex = 0;
int _workIndex = 0;
int _generalIndex = 0;

const _foodKeywords = [
  'schnitzel',
  'torte',
  'coffee',
  'kaffee',
  'cheese',
  'kaese',
  'strudel',
  'knoedel',
  'tafelspitz',
  'gulasch',
  'wuerstel',
  'beisl',
  'heuriger',
  'wein',
  'bier',
  'semmel',
  'kaiserschmarrn',
  'sachertorte',
  'apfelstrudel',
  'palatschinken',
  'food',
  'eat',
  'lunch',
  'dinner',
  'hungry',
];

const _workKeywords = [
  'deploy',
  'pr',
  'code',
  'bug',
  'test',
  'merge',
  'commit',
  'pipeline',
  'release',
  'refactor',
  'review',
  'staging',
  'production',
  'sprint',
  'ticket',
  'jira',
  'build',
  'lint',
  'ci',
  'fix',
];

String pickAutoResponse(String incomingMessage) {
  final lower = incomingMessage.toLowerCase();

  for (final keyword in _foodKeywords) {
    if (lower.contains(keyword)) {
      final response = kFoodResponses[_foodIndex % kFoodResponses.length];
      _foodIndex++;
      return response;
    }
  }

  for (final keyword in _workKeywords) {
    if (lower.contains(keyword)) {
      final response = kWorkResponses[_workIndex % kWorkResponses.length];
      _workIndex++;
      return response;
    }
  }

  final response = kGeneralResponses[_generalIndex % kGeneralResponses.length];
  _generalIndex++;
  return response;
}
