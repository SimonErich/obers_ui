// Tests for OiAccountSwitcher.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_avatar.dart';
import 'package:obers_ui/src/components/navigation/oi_account_switcher.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';

import '../../../helpers/pump_app.dart';

class _Workspace {
  const _Workspace(this.id, this.name);
  final String id;
  final String name;
  @override
  String toString() => name;
}

const _workspaces = [
  _Workspace('1', 'Acme Corp'),
  _Workspace('2', 'Globex Inc'),
  _Workspace('3', 'Initech'),
];

void main() {
  // ── Rendering ──────────────────────────────────────────────────────────

  testWidgets('renders trigger with active account name', (tester) async {
    await tester.pumpObers(
      OiAccountSwitcher<_Workspace>(
        accounts: _workspaces,
        activeAccount: _workspaces.first,
        onSelect: (_) {},
        label: 'Switch workspace',
        labelOf: (w) => w.name,
        avatarOf: (w) => w.name.substring(0, 2),
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('Acme Corp'), findsOneWidget);
  });

  testWidgets('compact mode shows only avatar (no name text)', (tester) async {
    await tester.pumpObers(
      OiAccountSwitcher<_Workspace>(
        accounts: _workspaces,
        activeAccount: _workspaces.first,
        onSelect: (_) {},
        label: 'Switch workspace',
        labelOf: (w) => w.name,
        avatarOf: (w) => w.name.substring(0, 2),
        compact: true,
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.byType(OiAvatar), findsOneWidget);
    // In compact mode the account name should not appear outside the avatar.
    expect(find.text('Acme Corp'), findsNothing);
  });

  // ── Dropdown interaction ───────────────────────────────────────────────

  testWidgets('tapping trigger opens dropdown with account names', (
    tester,
  ) async {
    await tester.pumpObers(
      OiAccountSwitcher<_Workspace>(
        accounts: _workspaces,
        activeAccount: _workspaces.first,
        onSelect: (_) {},
        label: 'Switch workspace',
        labelOf: (w) => w.name,
        avatarOf: (w) => w.name.substring(0, 2),
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.text('Acme Corp'));
    await tester.pumpAndSettle();

    expect(find.text('Globex Inc'), findsOneWidget);
    expect(find.text('Initech'), findsOneWidget);
  });

  testWidgets('selecting an account calls onSelect', (tester) async {
    _Workspace? selected;
    await tester.pumpObers(
      OiAccountSwitcher<_Workspace>(
        accounts: _workspaces,
        activeAccount: _workspaces.first,
        onSelect: (w) => selected = w,
        label: 'Switch workspace',
        labelOf: (w) => w.name,
        avatarOf: (w) => w.name.substring(0, 2),
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.text('Acme Corp'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Globex Inc'));
    await tester.pumpAndSettle();

    expect(selected?.id, '2');
  });

  testWidgets('active account marked with check icon in dropdown', (
    tester,
  ) async {
    await tester.pumpObers(
      OiAccountSwitcher<_Workspace>(
        accounts: _workspaces,
        activeAccount: _workspaces.first,
        onSelect: (_) {},
        label: 'Switch workspace',
        labelOf: (w) => w.name,
        avatarOf: (w) => w.name.substring(0, 2),
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.text('Acme Corp'));
    await tester.pumpAndSettle();

    // The check icon should appear for the active account.
    expect(find.byIcon(OiIcons.check), findsOneWidget);
  });

  testWidgets('add account action appears when callback provided', (
    tester,
  ) async {
    var addTapped = false;
    await tester.pumpObers(
      OiAccountSwitcher<_Workspace>(
        accounts: _workspaces,
        activeAccount: _workspaces.first,
        onSelect: (_) {},
        label: 'Switch workspace',
        labelOf: (w) => w.name,
        avatarOf: (w) => w.name.substring(0, 2),
        onAddAccount: () => addTapped = true,
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.text('Acme Corp'));
    await tester.pumpAndSettle();

    expect(find.text('Add account'), findsOneWidget);

    await tester.tap(find.text('Add account'));
    await tester.pumpAndSettle();

    expect(addTapped, isTrue);
  });

  testWidgets('searchable filters accounts', (tester) async {
    await tester.pumpObers(
      OiAccountSwitcher<_Workspace>(
        accounts: _workspaces,
        activeAccount: _workspaces.first,
        onSelect: (_) {},
        label: 'Switch workspace',
        labelOf: (w) => w.name,
        avatarOf: (w) => w.name.substring(0, 2),
        searchable: true,
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.text('Acme Corp'));
    await tester.pumpAndSettle();

    // All three accounts visible initially.
    expect(find.text('Globex Inc'), findsOneWidget);
    expect(find.text('Initech'), findsOneWidget);

    // Type a search query to filter.
    await tester.enterText(find.byType(EditableText), 'Glob');
    await tester.pumpAndSettle();

    expect(find.text('Globex Inc'), findsOneWidget);
    expect(find.text('Initech'), findsNothing);
  });

  testWidgets('descriptionOf shows subtitle', (tester) async {
    await tester.pumpObers(
      OiAccountSwitcher<_Workspace>(
        accounts: _workspaces,
        activeAccount: _workspaces.first,
        onSelect: (_) {},
        label: 'Switch workspace',
        labelOf: (w) => w.name,
        avatarOf: (w) => w.name.substring(0, 2),
        descriptionOf: (w) => 'ID: ${w.id}',
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.text('Acme Corp'));
    await tester.pumpAndSettle();

    expect(find.text('ID: 1'), findsOneWidget);
    expect(find.text('ID: 2'), findsOneWidget);
  });

  // ── Edge cases ─────────────────────────────────────────────────────────

  testWidgets('single account: no dropdown on tap', (tester) async {
    await tester.pumpObers(
      OiAccountSwitcher<_Workspace>(
        accounts: const [_Workspace('1', 'Solo Corp')],
        activeAccount: const _Workspace('1', 'Solo Corp'),
        onSelect: (_) {},
        label: 'Switch workspace',
        labelOf: (w) => w.name,
        avatarOf: (w) => w.name.substring(0, 2),
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('Solo Corp'), findsOneWidget);

    // Tap should be a no-op — no dropdown items should appear.
    await tester.tap(find.text('Solo Corp'));
    await tester.pumpAndSettle();

    // Still only the trigger text, no duplicate from a dropdown.
    expect(find.text('Solo Corp'), findsOneWidget);
  });
}
