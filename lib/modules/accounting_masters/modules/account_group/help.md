# Account Group

## Purpose
Account Group is the master for the hierarchical classification of ledgers used throughout the accounting module — e.g. `Sundry Debtors` sitting under `Current Assets`, or `Sales` sitting under `Direct Income`. Every group belongs to an `AccountNature` (Asset/Liability/Income/Expense/Equity) and optionally to a parent group, so groups form a tree that mirrors a traditional chart-of-accounts structure. This module is the only one of the four accounting masters with full CRUD (create, read, update, delete) support in the UI.

## Architecture
Full layered implementation:

- `models/account_group.dart` — `AccountGroup` (read model, includes UI-only `icon`/`color` and `demo` fallback data).
- `models/create_account_group_request.dart` — `CreateAccountGroupRequest`.
- `models/update_account_group_request.dart` — `UpdateAccountGroupRequest`.
- `services/account_group_service.dart` — `AccountGroupService`, raw HTTP via `ApiService` and `AccountingApiConfig`.
- `repository/account_group_repository.dart` — `AccountGroupRepository`, unwraps `ResponseModelWrapper` and throws `AppException`.
- `viewModel/account_group_view_model.dart` — `AccountGroupViewModel` (`ChangeNotifier`).
- `screens/account_group_screen.dart` — `AccountGroupScreen` (StatefulWidget shell).
- `state/account_group_screen_state.dart` — `AccountGroupScreenState` (all screen logic).
- `widgets/account_group_card.dart` — `AccountGroupCard` (mobile list row).
- `widgets/account_group_create_form.dart` — `AccountGroupCreateForm` (full-page create/edit form).

The create/edit form also reads `AccountNatureViewModel` (from the `account_nature` sub-module) via `Provider` to populate the "Account Nature" chip selector, and reads `AccountGroupViewModel.accountingGroups` to populate the "Under" (parent group) autocomplete — so this module has a cross-module dependency on `account_nature`'s viewModel.

## Screens

### AccountGroupScreen (`lib/modules/accounting_masters/modules/account_group/screens/account_group_screen.dart`)
**Purpose:** Thin `StatefulWidget` shell; all logic lives in `AccountGroupScreenState`.

**UI elements & actions:** None directly — delegates to its state class.

**Events & state changes:** None of its own.

### AccountGroupScreenState (`lib/modules/accounting_masters/modules/account_group/state/account_group_screen_state.dart`)
**Purpose:** Lists all account groups (searchable), and lets the user add, edit or delete a group. Renders a `DataTable`-style layout on wide screens (≥720px) and a card list on narrow screens.

**UI elements & actions:**
- **Search field** (`TextField`, hint "Search by name, alias or ID...") — `onChanged` calls `viewModel.setQuery`, which filters by name, id, or alias (case-insensitive substring match, via `filteredAccountGroups`).
- **"Add group" button** (`FilledButton.icon`, add icon) — calls `_openForm()` with no argument, pushing `AccountGroupCreateForm` in create mode.
- **Error banner** — shown when `viewModel.error != null`; displays the error message in a red-tinted `Container` with an error icon.
- **Loading state** — `CircularProgressIndicator` centered while `viewModel.isLoading`.
- **Empty state** (`_EmptyState`) — shown when the filtered list is empty: icon + "No accounting groups found" + "Try a different search or add a new group."
- **Wide-screen table** (`_AccountGroupTable`, a `Card` wrapping a horizontally scrollable `DataTable`) — columns: ID, Name, Alias, Under (resolves the parent group's name via `_underName`, falling back to `—`), Description (ellipsized), Status (`_StatusBadge`: green "Active" / grey "Inactive" pill), and an actions column with:
  - **Edit icon button** — calls `_openForm(group)` with the row's group to edit.
  - **Delete icon button** — calls `_confirmDelete(viewModel, group.id)`.
- **Narrow-screen list** (`ListView.separated` of `AccountGroupCard`) — each card has the same Edit/Delete icon buttons, wired to the same `_openForm`/`_confirmDelete` handlers.
- **Delete confirmation dialog** — `AlertDialog` titled "Delete group?" with body "This will remove the accounting group from your master." and Cancel/Delete actions; on confirm, calls `viewModel.deleteAccountGroup(id)`.
- **Add/Edit form navigation (`_openForm`)** — pushes `AccountGroupCreateForm(initialGroup: group)` (a `MaterialPageRoute`) and awaits its popped result. If the result is an `UpdateAccountGroupRequest`, calls `viewModel.updateAccountGroup(result)`; if it's a `CreateAccountGroupRequest`, calls `viewModel.addAccountGroup(result)`.

**Events & state changes:**
- `initState` schedules a post-frame callback that calls `viewModel.loadAccountGroups()` once the widget is mounted (loads the list on first entry to the screen).
- No `dispose` override.
- All API interactions and resulting state changes (loading/error/list refresh) are driven entirely by `AccountGroupViewModel`, which the screen `watch`es via `Provider`.

## ViewModel(s)

### AccountGroupViewModel (`lib/modules/accounting_masters/modules/account_group/viewModel/account_group_view_model.dart`)
`ChangeNotifier` holding all UI state for this module.

**State (getters):**
- `isLoading` (`bool`)
- `error` (`String?`)
- `query` (`String`, current search text)
- `accountingGroups` (`List<AccountGroup>`, unfiltered)
- `filteredAccountGroups` — computed: filters `accountingGroups` by `query` (trimmed, lowercased) matching name, id (as string), or alias.

**Methods:**
- `loadAccountGroups()` — sets `isLoading = true`, clears `error`, notifies; calls `_repository.fetchAccountGroups()`; on `AppException` sets `error` to `error.message`; on any other exception sets a generic `'Something went wrong. Please try again.'`; `finally` sets `isLoading = false` and notifies.
- `setQuery(String value)` — sets `_query` and notifies (drives `filteredAccountGroups`).
- `addAccountGroup(CreateAccountGroupRequest request)` — clears `error`, notifies; calls `_repository.createAccountGroup(request)`; on success reloads the list (`loadAccountGroups()`) and returns `true`; on `AppException` sets `error` and returns `false`; on other exception sets generic error and returns `false`.
- `updateAccountGroup(UpdateAccountGroupRequest request)` — same pattern as `addAccountGroup`, calling `_repository.updateAccountGroup(request)`.
- `deleteAccountGroup(int id)` — same pattern, calling `_repository.deleteAccountGroup(id)`.

## Repository / Service

### AccountGroupRepository (`lib/modules/accounting_masters/modules/account_group/repository/account_group_repository.dart`)
- `fetchAccountGroups()` — calls `service.fetchAccountGroups()`, wraps the JSON in `ResponseModelWrapper`; throws `AppException(wrapper.message ?? 'Could not load accounting groups.', code: wrapper.code)` if `!wrapper.success`; otherwise maps `wrapper.data?.result` (expected to be a `List`) through `AccountGroup.fromJson`, returning `[]` if the result isn't a list.
- `createAccountGroup(CreateAccountGroupRequest request)` — calls `service.createAccountGroup(request)`, unwraps, throws `AppException('Could not create accounting group.', ...)` on failure.
- `updateAccountGroup(UpdateAccountGroupRequest request)` — calls `service.updateAccountGroup(request.id, request)`, unwraps, throws `AppException('Could not update accounting group.', ...)` on failure.
- `deleteAccountGroup(int id)` — calls `service.deleteAccountGroup(id)`, unwraps, throws `AppException('Could not delete accounting group.', ...)` on failure.

### AccountGroupService (`lib/modules/accounting_masters/modules/account_group/services/account_group_service.dart`)
Raw HTTP calls via `ApiService`, no parsing:
- `fetchAccountGroups()` — `GET AccountingApiConfig.accountGroupAPI` (`/account_groups`).
- `createAccountGroup(request)` — `POST AccountingApiConfig.createAccountGroupAPI` (`/account_groups/create`) with `request.toJson()` as body.
- `updateAccountGroup(id, request)` — `PUT AccountingApiConfig.accountGroupEndpoint(id)` (`/account_groups/{id}`) with `request.toJson()` as body.
- `deleteAccountGroup(id)` — `DELETE AccountingApiConfig.accountGroupEndpoint(id)` (`/account_groups/{id}`).

## Models

### AccountGroup (`models/account_group.dart`)
Fields: `id` (int), `name` (String), `code` (int?), `alias` (String?), `description` (String?), `isActive` (bool, default `true`), `parentId` (int?, parent group in the hierarchy), `accountNatureId` (int?), `icon` (IconData, UI-only, default `Icons.account_tree_rounded`), `color` (Color, UI-only, default `AppColors.primary`). `fromJson` parses `id`, `name`, `code`, `alias`, `description`, `isActive`, `parentId`, `accountNatureId` from the backend `AccountGroupDTO`; `icon`/`color` are not set from JSON (they only exist on the static `demo` placeholder list of 8 sample groups used as fallback data when the backend list is empty, e.g. in the parent-picker).

### CreateAccountGroupRequest (`models/create_account_group_request.dart`)
Fields: `name` (String, required), `code` (int, required), `accountNatureId` (int, required), `alias` (String?), `description` (String?), `parentId` (int?). `toJson()` omits null `alias`/`description`/`parentId`.

### UpdateAccountGroupRequest (`models/update_account_group_request.dart`)
Same fields as `CreateAccountGroupRequest` plus `id` (int, required, identifies the group being edited; not included in `toJson()` — used only to build the PUT URL).

## Widgets

### AccountGroupCard (`widgets/account_group_card.dart`)
Row card used in the narrow-screen list. Shows a colored icon chip (`group.color`/`group.icon`), name, a subtitle of `id · aka {alias}` (alias part only if present), the description (if present, ellipsized), an Active/Inactive status pill, and optional Edit/Delete icon buttons (only rendered when `onEdit`/`onDelete` callbacks are supplied).

### AccountGroupCreateForm (`widgets/account_group_create_form.dart`)
Full-page `StatefulWidget` form (`Scaffold` + `AppBar`) for create or edit, distinguished by whether `initialGroup` is passed. Pops a `CreateAccountGroupRequest` or `UpdateAccountGroupRequest` on save, or `null` on cancel/back.

**Fields & validation:**
- **Name** (`TextFormField`, autofocus, word capitalization) — required; validator rejects empty/whitespace-only ("Enter a group name").
- **Code** (`TextFormField`, numeric keyboard) — required; validator rejects empty ("Enter a group code") and non-numeric input ("Enter a valid number").
- **Alias** (optional, word capitalization) — no validator.
- **Description** (optional, sentence capitalization, 3 lines) — no validator.
- **Under (parent group)** — an `Autocomplete<_ParentOption>` text field seeded with a synthetic "Primary" option (`id: null`, meaning no parent) plus one option per existing group (falling back to `AccountGroup.demo` if the live list is empty). Selecting an option sets `_parent` via `setState`.
- **Account Nature** — a `Wrap` of `ChoiceChip`s, one per nature from `AccountNatureViewModel.accountNatures` (or `AccountNature.demo` fallback). Wrapped in a `FormField<int>` whose validator requires a selection ("Select an account nature"); selecting a chip updates `_accountNatureId` and calls `field.didChange`.
- **Cancel** button — pops with no result.
- **Save/Update button** (`FilledButton.icon`) — calls `_submit()`, which validates the form, parses the code, builds either an `UpdateAccountGroupRequest` (if editing) or `CreateAccountGroupRequest` (if creating), and pops it.

**initState:** if `AccountNatureViewModel.accountNatures` is empty and not currently loading, schedules a post-frame callback to call `natureViewModel.loadAccountNatures()` (so the nature chips have data even if the user hasn't visited the Account Nature screen yet).

**dispose:** disposes all four `TextEditingController`s.
