# Account Nature

## Purpose
Account Nature classifies accounts by their fundamental accounting category — `Asset`, `Liability`, `Income`, `Expense`, `Equity`. It is the top of the accounting classification hierarchy: every `AccountGroup` (see the `account_group` sub-module) must be assigned to one account nature. This module supports listing, searching, creating and deleting natures, but not editing an existing one.

## Architecture
- `models/account_nature.dart` — `AccountNature` (read model, includes UI-only `icon`/`color` and `demo` fallback data of the 5 standard natures).
- `models/create_account_nature_request.dart` — `CreateAccountNatureRequest`.
- `services/account_nature_service.dart` — `AccountNatureService`, raw HTTP via `ApiService` and `AccountingApiConfig`.
- `repository/account_nature_repository.dart` — `AccountNatureRepository`, unwraps `ResponseModelWrapper`, throws `AppException`.
- `viewModel/account_nature_view_model.dart` — `AccountNatureViewModel` (`ChangeNotifier`).
- `screens/account_nature_screen.dart` — `AccountNatureScreen` (StatefulWidget shell).
- `state/account_nature_screen_state.dart` — `AccountNatureScreenState` (all screen logic).
- `widgets/account_nature_add_dialog.dart` — `AccountNatureAddDialog` (create-only dialog form).
- `widgets/account_nature_card.dart` — `AccountNatureCard` (mobile list row).

There is no `UpdateAccountNatureRequest` model and no update method anywhere in this module's stack — only create and delete are supported. This module's viewModel is also consumed by the `account_group` sub-module's create/edit form (`AccountGroupCreateForm`), which reads `AccountNatureViewModel.accountNatures` to populate its nature-selection chips.

## Screens

### AccountNatureScreen (`lib/modules/accounting_masters/modules/account_nature/screens/account_nature_screen.dart`)
**Purpose:** Thin `StatefulWidget` shell; all logic lives in `AccountNatureScreenState`.

**UI elements & actions:** None directly — delegates to its state class.

**Events & state changes:** None of its own.

### AccountNatureScreenState (`lib/modules/accounting_masters/modules/account_nature/state/account_nature_screen_state.dart`)
**Purpose:** Lists all account natures (searchable), and lets the user add or delete a nature. Renders a read-only custom table (`_NatureTable`, built from flex rows rather than `DataTable`) on wide screens (≥720px) and a card list (`AccountNatureCard`) on narrow screens.

**UI elements & actions:**
- **Search field** (`TextField`, hint "Search by name, code or ID...") — `onChanged` calls `viewModel.setQuery`, filtering by name, id, code, or description (case-insensitive substring match via `filteredAccountNatures`).
- **"Add nature" button** (`FilledButton.icon`, add icon) — calls `_openAddDialog()`, which shows `AccountNatureAddDialog` and, if it returns a `CreateAccountNatureRequest`, calls `viewModel.addAccountNature(result)`.
- **Error banner** — shown when `viewModel.error != null`; red-tinted `Container` with error icon and message.
- **Loading state** — `CircularProgressIndicator` centered while `viewModel.isLoading`.
- **Empty state** (`_EmptyState`) — icon + "No account natures found" + "Try a different search or add a new nature."
- **Wide-screen table** (`_NatureTable`) — a bordered, rounded container with a pinned header (SL NO, NAME, CODE, DESCRIPTION columns) and a scrollable `ListView.separated` of `_NatureTableRow`s, with zebra striping on odd rows. This table is **read-only** — no edit/delete actions on the rows; the code comment explicitly notes "deleting only happens from the card view."
- **Narrow-screen list** (`ListView.separated` of `AccountNatureCard`) — each card has a **Delete** icon button, calling `_confirmDelete(viewModel, nature.id)`. No edit action anywhere (consistent with no update support).
- **Delete confirmation dialog** — `AlertDialog` titled "Delete nature?" with body "This will remove the account nature from your master." and Cancel/Delete actions; on confirm, calls `viewModel.deleteAccountNature(id)`.

**Events & state changes:**
- `initState` schedules a post-frame callback that calls `viewModel.loadAccountNatures()` once mounted.
- No `dispose` override.
- All loading/error/list state comes from `AccountNatureViewModel`, watched via `Provider`.

## ViewModel(s)

### AccountNatureViewModel (`lib/modules/accounting_masters/modules/account_nature/viewModel/account_nature_view_model.dart`)
`ChangeNotifier` holding all UI state for this module.

**State (getters):**
- `isLoading` (`bool`)
- `error` (`String?`)
- `query` (`String`)
- `accountNatures` (`List<AccountNature>`, unfiltered)
- `filteredAccountNatures` — computed: filters by `query` (trimmed, lowercased) matching name, id (as string), code (as string), or description.

**Methods:**
- `loadAccountNatures()` — sets `isLoading = true`, clears `error`, notifies; calls `_repository.fetchAccountNatures()`; on `AppException` sets `error` to `error.message`; on any other exception sets `'Something went wrong. Please try again.'`; `finally` sets `isLoading = false` and notifies.
- `setQuery(String value)` — sets `_query` and notifies.
- `addAccountNature(CreateAccountNatureRequest request)` — clears `error`, notifies; calls `_repository.createAccountNature(request)`; on success reloads the list and returns `true`; on `AppException` sets `error` and returns `false`; on other exception sets generic error and returns `false`.
- `deleteAccountNature(int id)` — same pattern, calling `_repository.deleteAccountNature(id)`.

## Repository / Service

### AccountNatureRepository (`lib/modules/accounting_masters/modules/account_nature/repository/account_nature_repository.dart`)
- `fetchAccountNatures()` — calls `service.fetchAccountNatures()`, wraps in `ResponseModelWrapper`; throws `AppException(wrapper.message ?? 'Could not load account natures.', code: wrapper.code)` if `!wrapper.success`; otherwise maps `wrapper.data?.result` through `AccountNature.fromJson`, returning `[]` if not a `List`.
- `createAccountNature(CreateAccountNatureRequest request)` — calls `service.createAccountNature(request)`, unwraps, throws `AppException('Could not create account nature.', ...)` on failure.
- `deleteAccountNature(int id)` — calls `service.deleteAccountNature(id)`, unwraps, throws `AppException('Could not delete account nature.', ...)` on failure.

### AccountNatureService (`lib/modules/accounting_masters/modules/account_nature/services/account_nature_service.dart`)
Raw HTTP calls via `ApiService`, no parsing:
- `fetchAccountNatures()` — `GET AccountingApiConfig.accountNatureAPI` (`/account_natures`).
- `createAccountNature(request)` — `POST AccountingApiConfig.createAccountNatureAPI` (`/account_natures/create`) with `request.toJson()` as body.
- `deleteAccountNature(id)` — `DELETE AccountingApiConfig.accountNatureEndpoint(id)` (`/account_natures/{id}`).

## Models

### AccountNature (`models/account_nature.dart`)
Fields: `id` (int), `name` (String), `code` (int?), `description` (String?), `icon` (IconData, UI-only, default `Icons.category_rounded`), `color` (Color, UI-only, default `AppColors.primary`). `fromJson` parses `id`, `name`, `code`, `description` from the backend `AccountNatureDTO`; `icon`/`color` are not set from JSON. A static `demo` list of the 5 standard natures (Asset, Liability, Income, Expense, Equity, each with its own icon/color) serves as fallback data — e.g. consumed by `AccountGroupCreateForm`'s nature-chip picker when the live list is empty.

### CreateAccountNatureRequest (`models/create_account_nature_request.dart`)
Fields: `name` (String, required), `code` (int?), `description` (String?). `toJson()` omits null `code`/`description`.

## Widgets

### AccountNatureAddDialog (`widgets/account_nature_add_dialog.dart`)
`StatefulWidget` `AlertDialog` for creating a new nature. Pops a `CreateAccountNatureRequest` on save, or `null` on cancel.

**Fields & validation:**
- **Name** (`TextFormField`, autofocus, word capitalization, category icon prefix) — required; validator rejects empty/whitespace ("Enter a nature name").
- **Code** (`TextFormField`, numeric keyboard, digits-only input formatter, tag icon prefix, optional) — no validator; parsed with `int.tryParse` on submit (so non-numeric/empty input becomes `null`).
- **Description** (`TextFormField`, sentence capitalization, 3 lines, notes icon prefix, optional) — no validator; empty text becomes `null` on submit.
- **Cancel** button — pops with no result.
- **Save button** (`FilledButton.icon`) — calls `_submit()`, which validates then pops a `CreateAccountNatureRequest` built from the three fields.

Dialog width is responsive: 90% of screen width on screens narrower than 480px, else a fixed 420px.

**dispose:** disposes all three `TextEditingController`s.

### AccountNatureCard (`widgets/account_nature_card.dart`)
Row card used in the narrow-screen list. Shows a colored icon chip (`nature.color`/`nature.icon`), name, a subtitle of `id · code {code}` (code part only if present), the description (if present, ellipsized), and an optional Delete icon button (only rendered when `onDelete` is supplied — no Edit button exists on this card).
