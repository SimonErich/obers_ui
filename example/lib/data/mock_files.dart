import 'package:obers_ui/obers_ui.dart';

/// Mock file system data for the file explorer mini-app.

// ── Folder tree ───────────────────────────────────────────────────────────────

final kFileTree = <OiFileNodeData>[
  // Root folders
  OiFileNodeData(
    id: 'f-docs',
    name: 'Documents',
    isFolder: true,
    parentId: 'root',
    itemCount: 4,
    modified: DateTime(2026, 3, 20),
  ),
  OiFileNodeData(
    id: 'f-images',
    name: 'Product Photos',
    isFolder: true,
    parentId: 'root',
    itemCount: 6,
    modified: DateTime(2026, 3, 18),
  ),
  OiFileNodeData(
    id: 'f-recipes',
    name: 'Secret Recipes',
    isFolder: true,
    parentId: 'root',
    itemCount: 3,
    modified: DateTime(2026, 3, 15),
    isLocked: true,
  ),
  OiFileNodeData(
    id: 'f-reports',
    name: 'Reports',
    isFolder: true,
    parentId: 'root',
    itemCount: 3,
    modified: DateTime(2026, 3, 21),
  ),
  OiFileNodeData(
    id: 'f-marketing',
    name: 'Marketing',
    isFolder: true,
    parentId: 'root',
    itemCount: 4,
    modified: DateTime(2026, 3, 19),
    isShared: true,
  ),

  // ── Documents ─────────────────────────────────────────────────────────────
  OiFileNodeData(
    id: 'doc-1',
    name: 'Business_Plan_2026.pdf',
    isFolder: false,
    parentId: 'f-docs',
    size: 4200000,
    mimeType: 'application/pdf',
    modified: DateTime(2026, 3, 20),
  ),
  OiFileNodeData(
    id: 'doc-2',
    name: 'Supplier_Contract_Graukase.docx',
    isFolder: false,
    parentId: 'f-docs',
    size: 890000,
    mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    modified: DateTime(2026, 3, 15),
  ),
  OiFileNodeData(
    id: 'doc-3',
    name: 'Employee_Handbook.pdf',
    isFolder: false,
    parentId: 'f-docs',
    size: 12400000,
    mimeType: 'application/pdf',
    modified: DateTime(2026, 2, 28),
    isShared: true,
  ),
  OiFileNodeData(
    id: 'doc-4',
    name: 'Coffee_Break_Policy.md',
    isFolder: false,
    parentId: 'f-docs',
    size: 3200,
    mimeType: 'text/markdown',
    modified: DateTime(2026, 3, 12),
    isFavorite: true,
  ),

  // ── Product Photos ────────────────────────────────────────────────────────
  OiFileNodeData(
    id: 'img-1',
    name: 'sachertorte_hero.jpg',
    isFolder: false,
    parentId: 'f-images',
    size: 3400000,
    mimeType: 'image/jpeg',
    modified: DateTime(2026, 3, 10),
  ),
  OiFileNodeData(
    id: 'img-2',
    name: 'schnitzel_kit_lifestyle.jpg',
    isFolder: false,
    parentId: 'f-images',
    size: 2800000,
    mimeType: 'image/jpeg',
    modified: DateTime(2026, 3, 8),
  ),
  OiFileNodeData(
    id: 'img-3',
    name: 'hiking_boot_detail.png',
    isFolder: false,
    parentId: 'f-images',
    size: 5100000,
    mimeType: 'image/png',
    modified: DateTime(2026, 3, 12),
  ),
  OiFileNodeData(
    id: 'img-4',
    name: 'mozartkugeln_gift_box.jpg',
    isFolder: false,
    parentId: 'f-images',
    size: 1900000,
    mimeType: 'image/jpeg',
    modified: DateTime(2026, 3, 5),
  ),
  OiFileNodeData(
    id: 'img-5',
    name: 'dirndl_lookbook.pdf',
    isFolder: false,
    parentId: 'f-images',
    size: 18600000,
    mimeType: 'application/pdf',
    modified: DateTime(2026, 2, 20),
  ),
  OiFileNodeData(
    id: 'img-6',
    name: 'almdudler_campaign.png',
    isFolder: false,
    parentId: 'f-images',
    size: 4200000,
    mimeType: 'image/png',
    modified: DateTime(2026, 3, 1),
  ),

  // ── Secret Recipes ────────────────────────────────────────────────────────
  OiFileNodeData(
    id: 'rec-1',
    name: 'Sachertorte_Original.pdf',
    isFolder: false,
    parentId: 'f-recipes',
    size: 156000,
    mimeType: 'application/pdf',
    modified: DateTime(2025, 12, 1),
    isLocked: true,
  ),
  OiFileNodeData(
    id: 'rec-2',
    name: 'Schnitzel_Secret_Ingredient.txt',
    isFolder: false,
    parentId: 'f-recipes',
    size: 420,
    mimeType: 'text/plain',
    modified: DateTime(2026, 1, 10),
    isLocked: true,
  ),
  OiFileNodeData(
    id: 'rec-3',
    name: 'Apfelstrudel_Omas_Version.pdf',
    isFolder: false,
    parentId: 'f-recipes',
    size: 234000,
    mimeType: 'application/pdf',
    modified: DateTime(2025, 11, 20),
    isLocked: true,
  ),

  // ── Reports ───────────────────────────────────────────────────────────────
  OiFileNodeData(
    id: 'rep-1',
    name: 'Q1_2026_Revenue_Report.xlsx',
    isFolder: false,
    parentId: 'f-reports',
    size: 1800000,
    mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    modified: DateTime(2026, 3, 21),
  ),
  OiFileNodeData(
    id: 'rep-2',
    name: 'Customer_Satisfaction_March.pdf',
    isFolder: false,
    parentId: 'f-reports',
    size: 3400000,
    mimeType: 'application/pdf',
    modified: DateTime(2026, 3, 19),
  ),
  OiFileNodeData(
    id: 'rep-3',
    name: 'Schnitzel_Consumption_Stats.csv',
    isFolder: false,
    parentId: 'f-reports',
    size: 45000,
    mimeType: 'text/csv',
    modified: DateTime(2026, 3, 18),
  ),

  // ── Marketing ─────────────────────────────────────────────────────────────
  OiFileNodeData(
    id: 'mkt-1',
    name: 'Spring_Campaign_Brief.pdf',
    isFolder: false,
    parentId: 'f-marketing',
    size: 2100000,
    mimeType: 'application/pdf',
    modified: DateTime(2026, 3, 14),
    isShared: true,
  ),
  OiFileNodeData(
    id: 'mkt-2',
    name: 'Social_Media_Calendar.xlsx',
    isFolder: false,
    parentId: 'f-marketing',
    size: 890000,
    mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    modified: DateTime(2026, 3, 17),
    isShared: true,
  ),
  OiFileNodeData(
    id: 'mkt-3',
    name: 'Brand_Guidelines_v3.pdf',
    isFolder: false,
    parentId: 'f-marketing',
    size: 7800000,
    mimeType: 'application/pdf',
    modified: DateTime(2026, 2, 10),
    isFavorite: true,
  ),
  OiFileNodeData(
    id: 'mkt-4',
    name: 'Newsletter_Template.html',
    isFolder: false,
    parentId: 'f-marketing',
    size: 32000,
    mimeType: 'text/html',
    modified: DateTime(2026, 3, 19),
  ),
];

/// Returns files for the given folder ID.
List<OiFileNodeData> filesForFolder(String folderId) {
  return kFileTree.where((f) => f.parentId == folderId).toList();
}

/// Returns only the root folders.
List<OiFileNodeData> get rootFolders =>
    kFileTree.where((f) => f.parentId == 'root' && f.isFolder).toList();

/// Builds tree nodes for the folder sidebar.
List<OiTreeNode<OiFileNodeData>> buildFolderTree(String parentId) {
  final folders =
      kFileTree.where((f) => f.parentId == parentId && f.isFolder).toList();
  return folders.map((folder) {
    return OiTreeNode<OiFileNodeData>(
      id: folder.id.toString(),
      label: folder.name,
      data: folder,
      children: buildFolderTree(folder.id.toString()),
      leaf: !kFileTree.any(
        (f) => f.parentId == folder.id.toString() && f.isFolder,
      ),
    );
  }).toList();
}

/// Storage data for the sidebar indicator.
const kStorageUsed = 2.4; // GB
const kStorageTotal = 10.0; // GB
