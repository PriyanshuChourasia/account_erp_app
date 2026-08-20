# State

## Purpose
Maintains the master list of states/regions, each belonging to a parent country. Used to record sub-national divisions (e.g. Maharashtra under India, California under the United States) for the organisation's address/reference data. Users can view, search, add, and delete states, selecting the parent country from an autocomplete field backed by the country master.

## Architecture
Follows the standard module layering:

- `models/state_master.dart` — `StateMaster`, the plain Dart model (named `StateMaster` rather than `State` to avoid clashing with Flutter's `State`), with `fromJson` and demo seed data.
- `models/create_state_request.dart` — `CreateStateRequest`, the create-payload model with `toJson`.
- `services/state_service.dart` — `StateService`, raw HTTP calls via `ApiService`.
- `repository/state_repository.dart` — `StateRepository`, unwraps `ResponseModelWrapper` and throws `AppException`.
- `viewModel/state_view_model.dart` — `StateViewModel` (`ChangeNotifier`), all UI state; notably also depends on the **country** sub-module's `CountryRepository` to load countries for name resolution and the country picker.
- `screens/state_screen.dart` — `StateScreen`, the `StatefulWidget` shell.
- `state/state_screen_state.dart` — `StateScreenState`, the screen's logic.
- `widgets/state_add_dialog.dart` — `StateAddDialog`, the add-state form dialog with country `Autocomplete`.
- `widgets/state_card.dart` — `StateCard`, a row widget for narrow layouts.

Data flow: `StateScreenState` → `StateViewModel` → `StateRepository`/`CountryRepository` → `StateService`/`CountryService` → `ApiService`. This is the only sub-module in this domain that cross-depends on a sibling module's repository.

## Screens

### StateScreen (`screens/state_screen.dart`) / StateScreenState (`state/state_screen_state.dart`)
**Purpose:** Lists all states, lets the user search, add a new state (picking its parent country), and delete an existing one. Renders as a table on wide screens (≥720px) and a card list on narrow screens.

**UI elements & actions:**
- Search `TextField` ("Search by name, code or country...") — `onChanged` calls `viewModel.setQuery(value)`, filtering in-memory by name, id, code, or resolved country name.
- "Add state" `FilledButton.icon` — calls `_openAddDialog()`, opening `StateAddDialog` via `showDialog<CreateStateRequest>`; on a non-null result, calls `context.read<StateViewModel>().addState(result)`.
- Delete action (icon button per row/card, tooltip "Delete state") — calls `_confirmDelete(viewModel, id)`, showing an `AlertDialog` ("Delete state?" / "This will remove the state from your master.") with Cancel/Delete; on confirm calls `viewModel.deleteState(id)`.
- Wide layout (`_StateTable`): `DataTable` with columns ID, Name, Code, Country (resolved via `viewModel.countryNameOf(state)`), Description, Status (`_StatusBadge`), and a trailing delete icon button per row.
- Narrow layout: `ListView.separated` of `StateCard` widgets, each showing the resolved country name and its own delete icon button.
- Empty state (`_EmptyState`): icon, "No states found", hint to search differently or add a new state.
- Error banner: shown above the list when `viewModel.error != null`.

**Form validation (in `StateAddDialog`):**
- Name is required ("Enter a state name").
- Code is optional; input restricted to `[A-Za-z0-9_-]` and auto-uppercased via `_UpperCaseTextFormatter`, re-uppercased/trimmed on submit.
- Country is required — selected via an `Autocomplete<Country>` field; validator returns "Select a country" if none chosen. Options come from `context.watch<StateViewModel>().countries`, falling back to `Country.demo` when that list is empty.
- Description is optional free text (up to 3 lines).

**Events & state changes:**
- `initState` schedules a post-frame callback that calls both `viewModel.loadStates()` and `viewModel.loadCountries()` once mounted, so both the state list and the country lookup/picker data are fetched on first build.
- Loading state: `viewModel.isLoading` shows a centered `CircularProgressIndicator`.
- After a successful add or delete, `loadStates()` is called again to refresh from the backend.

## ViewModel(s)

### StateViewModel (`viewModel/state_view_model.dart`)
Extends `ChangeNotifier`. Constructed with a `StateRepository` and a `CountryRepository`.

**State (getters):**
- `isLoading` (bool)
- `error` (String?)
- `query` (String)
- `states` (List<StateMaster>) — full unfiltered list
- `countries` (List<Country>) — loaded via `CountryRepository`, used for name resolution and the add-dialog picker
- `filteredStates` (List<StateMaster>) — `states` filtered (case-insensitive) by `query` against name, id, code, and the resolved country name

**Methods:**
- `countryNameOf(StateMaster state)` — looks up `_countries` for a matching `id == state.countryId`; falls back to `state.countryName` (if the backend sent it inline), then to `'—'`.
- `loadStates()` — sets `isLoading = true`, clears `error`, notifies; calls `_repository.fetchStates()`; catches `AppException` (sets `error` to its message) or any other error (generic "Something went wrong. Please try again." message); always resets `isLoading` and notifies in `finally`.
- `loadCountries()` — calls `_countryRepository.fetchCountries()`; on any error, silently sets `_countries = const []` (does not set the screen's `error` state); notifies either way.
- `setQuery(String value)` — updates `_query` and notifies.
- `addState(CreateStateRequest request)` → `Future<bool>` — clears `error`, notifies; calls `_repository.createState(request)`; on success calls `loadStates()` and returns `true`; on error sets `error` and returns `false`.
- `deleteState(int id)` → `Future<bool>` — same pattern, calling `_repository.deleteState(id)` then `loadStates()` on success.

## Repository / Service

### StateRepository (`repository/state_repository.dart`)
Constructed with a `StateService`.
- `fetchStates()` — calls `service.fetchStates()`, unwraps via `ResponseModelWrapper<dynamic>.fromJson`; throws `AppException(wrapper.message ?? 'Could not load states.', code: wrapper.code)` on failure; otherwise reads `wrapper.data?.result` (expects a `List`, else returns `const []`) and maps entries through `StateMaster.fromJson`.
- `createState(CreateStateRequest request)` — calls `service.createState(request)`, unwraps, throws `AppException('Could not create state.', ...)` on failure.
- `deleteState(int id)` — calls `service.deleteState(id)`, unwraps, throws `AppException('Could not delete state.', ...)` on failure.

### StateService (`services/state_service.dart`)
Constructed with `ApiService`. Pure HTTP, no parsing:
- `fetchStates()` — `GET OrganisationalApiConfig.stateAPI` (`/states`).
- `createState(request)` — `POST OrganisationalApiConfig.createStateAPI` (`/states/create`) with `data: request.toJson()`.
- `deleteState(id)` — `DELETE OrganisationalApiConfig.stateEndpoint(id)` (`/states/$id`).

## Models

### StateMaster (`models/state_master.dart`)
(Named `StateMaster`, not `State`, to avoid colliding with Flutter's `State` class.)
- `id` (int, required)
- `name` (String, required)
- `code` (String?) — e.g. `MH` for Maharashtra
- `countryId` (int, required) — the parent country's id
- `countryName` (String?) — convenience display field, used as a fallback when the country isn't found in the locally loaded country list
- `description` (String?)
- `isActive` (bool, default `true`)
- `icon` (IconData, default `Icons.map_rounded`) — UI-only, not from JSON
- `color` (Color, default `AppColors.primary`) — UI-only, not from JSON
- `fromJson` reads `id`, `name`, `code`, `countryId`, `countryName`, `description`, `isActive` from the backend `StateDTO` shape.
- `static const demo` — 6 hardcoded placeholder states (Maharashtra, Karnataka, Gujarat under India; California, Texas under United States; Dubai under UAE).

### CreateStateRequest (`models/create_state_request.dart`)
- `name` (String, required)
- `code` (String?)
- `countryId` (int, required)
- `description` (String?)
- `toJson()` always includes `name` and `countryId`; includes `code`/`description` only when non-null.

## Widgets

### StateAddDialog (`widgets/state_add_dialog.dart`)
Stateful dialog form with controllers for name, code, description, plus a selected `Country?` field. Contains a private `_UpperCaseTextFormatter` (uppercases the code field as typed). The country picker is an `Autocomplete<Country>`:
- Options are built from `StateViewModel.countries` (or `Country.demo` if empty), filtered by the typed text against country name and code.
- Selecting an option calls `setState(() => _country = country)`.
- The field's own validator requires a country to be selected ("Select a country").
- `optionsViewBuilder` renders a `Material`-elevated dropdown `ListView` of matching countries with name and code subtitle.
On submit, validates the form and pops a constructed `CreateStateRequest` (trimmed values, code uppercased/nulled if empty, `countryId` taken from the selected `Country`). Cancel pops with `null`.

### StateCard (`widgets/state_card.dart`)
Stateless row card for the narrow layout. Takes `state`, an optional `countryName` (resolved by the caller via `viewModel.countryNameOf`), and an optional `onDelete`. Shows the state's icon (tinted by `state.color`), name, a subtitle joining id/code/country name, optional description line, an Active/Inactive status badge, and — when `onDelete` is provided — a trailing delete icon button.
