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
    this.department,
    this.phone,
    this.location,
    this.status = 'active',
  });

  final String id;
  final String name;
  final String email;
  final String? role;
  final String? department;
  final String? phone;
  final String? location;
  final String status;

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts[0][0];
  }
}

// ── Core team ─────────────────────────────────────────────────────────────────

const kCurrentUser = MockUser(
  id: 'user-current',
  name: 'Leopold Brandauer',
  email: 'leopold@alpenglueck.at',
  role: 'CEO & Sachertorten-Sommelier',
  department: 'Executive',
  phone: '+43 1 234 5600',
  location: 'Wien',
);

const kHans = MockUser(
  id: 'user-hans',
  name: 'Hans Gruber',
  email: 'hans@alpenglueck.at',
  role: 'Head of Logistics',
  department: 'Operations',
  phone: '+43 1 234 5601',
  location: 'Wien',
);

const kLiesl = MockUser(
  id: 'user-liesl',
  name: 'Liesl Edelweiss',
  email: 'liesl@alpenglueck.at',
  role: 'Senior Developer',
  department: 'Engineering',
  phone: '+43 1 234 5602',
  location: 'Wien',
);

const kFranz = MockUser(
  id: 'user-franz',
  name: 'Franz Knödel',
  email: 'franz@alpenglueck.at',
  role: 'Marketing Manager',
  department: 'Marketing',
  phone: '+43 1 234 5603',
  location: 'Wien',
);

const kMaria = MockUser(
  id: 'user-maria',
  name: 'Maria Alpenrose',
  email: 'maria@alpenglueck.at',
  role: 'Head of Design',
  department: 'Design',
  phone: '+43 1 234 5604',
  location: 'Wien',
);

const kStefan = MockUser(
  id: 'user-stefan',
  name: 'Stefan Strudl',
  email: 'stefan@alpenglueck.at',
  role: 'Backend Engineer',
  department: 'Engineering',
  phone: '+43 1 234 5605',
  location: 'Graz',
);

const kAnna = MockUser(
  id: 'user-anna',
  name: 'Anna Mozartkugel',
  email: 'anna@alpenglueck.at',
  role: 'Product Manager',
  department: 'Product',
  phone: '+43 1 234 5606',
  location: 'Wien',
);

const kMaximilian = MockUser(
  id: 'user-max',
  name: 'Maximilian Schnitzel',
  email: 'max@alpenglueck.at',
  role: 'QA Lead',
  department: 'Quality',
  phone: '+43 1 234 5607',
  location: 'Wien',
);

// ── Additional staff ──────────────────────────────────────────────────────────

const kKlara = MockUser(
  id: 'user-klara',
  name: 'Klara Krapfen',
  email: 'klara@alpenglueck.at',
  role: 'Customer Support',
  department: 'Support',
  phone: '+43 1 234 5608',
  location: 'Wien',
);

const kWolfgang = MockUser(
  id: 'user-wolfi',
  name: 'Wolfgang Apfelstrudel',
  email: 'wolfi@alpenglueck.at',
  role: 'Warehouse Manager',
  department: 'Operations',
  phone: '+43 1 234 5609',
  location: 'Linz',
);

const kElisabeth = MockUser(
  id: 'user-elisabeth',
  name: 'Elisabeth Palatschinke',
  email: 'elisabeth@alpenglueck.at',
  role: 'Frontend Developer',
  department: 'Engineering',
  phone: '+43 1 234 5610',
  location: 'Wien',
);

const kPeter = MockUser(
  id: 'user-peter',
  name: 'Peter Kaiserschmarrn',
  email: 'peter@alpenglueck.at',
  role: 'Data Analyst',
  department: 'Product',
  phone: '+43 1 234 5611',
  location: 'Salzburg',
);

const kGertrud = MockUser(
  id: 'user-gertrud',
  name: 'Gertrud Topfenstrudel',
  email: 'gertrud@alpenglueck.at',
  role: 'Content Writer',
  department: 'Marketing',
  phone: '+43 1 234 5612',
  location: 'Wien',
);

const kFerdinand = MockUser(
  id: 'user-ferdinand',
  name: 'Ferdinand Leberkäse',
  email: 'ferdinand@alpenglueck.at',
  role: 'DevOps Engineer',
  department: 'Engineering',
  phone: '+43 1 234 5613',
  location: 'Graz',
);

const kRosalinde = MockUser(
  id: 'user-rosalinde',
  name: 'Rosalinde Marillenknödel',
  email: 'rosalinde@alpenglueck.at',
  role: 'HR Manager',
  department: 'Human Resources',
  phone: '+43 1 234 5614',
  location: 'Wien',
);

const kOtto = MockUser(
  id: 'user-otto',
  name: 'Otto Brezl',
  email: 'otto@alpenglueck.at',
  role: 'Shipping Coordinator',
  department: 'Operations',
  phone: '+43 1 234 5615',
  location: 'Linz',
);

const kTheresa = MockUser(
  id: 'user-theresa',
  name: 'Theresa Germknödel',
  email: 'theresa@alpenglueck.at',
  role: 'UX Researcher',
  department: 'Design',
  phone: '+43 1 234 5616',
  location: 'Wien',
);

const kIgnaz = MockUser(
  id: 'user-ignaz',
  name: 'Ignaz Zwetschgenröster',
  email: 'ignaz@alpenglueck.at',
  role: 'Finance Controller',
  department: 'Finance',
  phone: '+43 1 234 5617',
  location: 'Wien',
);

const kFriederike = MockUser(
  id: 'user-friederike',
  name: 'Friederike Sacherwürstel',
  email: 'friederike@alpenglueck.at',
  role: 'Social Media Manager',
  department: 'Marketing',
  phone: '+43 1 234 5618',
  location: 'Wien',
);

const kKaspar = MockUser(
  id: 'user-kaspar',
  name: 'Kaspar Heuriger',
  email: 'kaspar@alpenglueck.at',
  role: 'Sales Representative',
  department: 'Sales',
  phone: '+43 1 234 5619',
  location: 'Innsbruck',
);

const kHedwig = MockUser(
  id: 'user-hedwig',
  name: 'Hedwig Punschkrapferl',
  email: 'hedwig@alpenglueck.at',
  role: 'Support Agent',
  department: 'Support',
  phone: '+43 1 234 5620',
  location: 'Wien',
);

const kRupert = MockUser(
  id: 'user-rupert',
  name: 'Rupert Semmelknödel',
  email: 'rupert@alpenglueck.at',
  role: 'Inventory Specialist',
  department: 'Operations',
  phone: '+43 1 234 5621',
  location: 'Linz',
);

const kAugustine = MockUser(
  id: 'user-augustine',
  name: 'Augustine Linzertorte',
  email: 'augustine@alpenglueck.at',
  role: 'Graphic Designer',
  department: 'Design',
  phone: '+43 1 234 5622',
  location: 'Linz',
  status: 'on-leave',
);

const kVinzenz = MockUser(
  id: 'user-vinzenz',
  name: 'Vinzenz Tafelspitz',
  email: 'vinzenz@alpenglueck.at',
  role: 'Security Engineer',
  department: 'Engineering',
  phone: '+43 1 234 5623',
  location: 'Wien',
);

const kBrigitte = MockUser(
  id: 'user-brigitte',
  name: 'Brigitte Powidltascherl',
  email: 'brigitte@alpenglueck.at',
  role: 'Accountant',
  department: 'Finance',
  phone: '+43 1 234 5624',
  location: 'Wien',
  status: 'inactive',
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

/// All employees including additional staff (25 total).
const kAllUsers = [
  ...kCoreTeam,
  kKlara,
  kWolfgang,
  kElisabeth,
  kPeter,
  kGertrud,
  kFerdinand,
  kRosalinde,
  kOtto,
  kTheresa,
  kIgnaz,
  kFriederike,
  kKaspar,
  kHedwig,
  kRupert,
  kAugustine,
  kVinzenz,
  kBrigitte,
];
