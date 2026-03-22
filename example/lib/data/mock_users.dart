/// Shared user identities used across all mini-apps.
///
/// The team at Alpenglueck GmbH — a fictional Austrian e-commerce company
/// selling premium Alpine lifestyle products.
class MockUser {
  const MockUser({
    required this.id,
    required this.name,
    required this.email,
    this.role,
  });

  final String id;
  final String name;
  final String email;
  final String? role;

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts[0][0];
  }
}

// ── The team ──────────────────────────────────────────────────────────────────

const kCurrentUser = MockUser(
  id: 'user-current',
  name: 'Leopold Brandauer',
  email: 'leopold@alpenglueck.at',
  role: 'CEO & Sachertorten-Sommelier',
);

const kHans = MockUser(
  id: 'user-hans',
  name: 'Hans Gruber',
  email: 'hans@alpenglueck.at',
  role: 'Head of Logistics',
);

const kLiesl = MockUser(
  id: 'user-liesl',
  name: 'Liesl Edelweiss',
  email: 'liesl@alpenglueck.at',
  role: 'Senior Developer',
);

const kFranz = MockUser(
  id: 'user-franz',
  name: 'Franz Knödel',
  email: 'franz@alpenglueck.at',
  role: 'Marketing Manager',
);

const kMaria = MockUser(
  id: 'user-maria',
  name: 'Maria Alpenrose',
  email: 'maria@alpenglueck.at',
  role: 'Head of Design',
);

const kStefan = MockUser(
  id: 'user-stefan',
  name: 'Stefan Strudl',
  email: 'stefan@alpenglueck.at',
  role: 'Backend Engineer',
);

const kAnna = MockUser(
  id: 'user-anna',
  name: 'Anna Mozartkugel',
  email: 'anna@alpenglueck.at',
  role: 'Product Manager',
);

const kMaximilian = MockUser(
  id: 'user-max',
  name: 'Maximilian Schnitzel',
  email: 'max@alpenglueck.at',
  role: 'QA Lead',
);

// Additional employees for the admin user table.
const kKlara = MockUser(
  id: 'user-klara',
  name: 'Klara Krapfen',
  email: 'klara@alpenglueck.at',
  role: 'Customer Support',
);

const kWolfgang = MockUser(
  id: 'user-wolfi',
  name: 'Wolfgang Apfelstrudel',
  email: 'wolfi@alpenglueck.at',
  role: 'Warehouse Manager',
);

/// Core team (used in chat, kanban, comments).
const kCoreTeam = [
  kCurrentUser,
  kHans,
  kLiesl,
  kFranz,
  kMaria,
  kStefan,
  kAnna,
  kMaximilian,
];

/// All employees including additional staff.
const kAllUsers = [
  ...kCoreTeam,
  kKlara,
  kWolfgang,
];
