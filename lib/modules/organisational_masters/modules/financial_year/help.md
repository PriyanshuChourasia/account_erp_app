# Financial Year

## Purpose
Maintains the master list of financial (fiscal) years used to group accounting transactions — each with a name, optional code, a start/end date period, and a flag for which one is the organisation's currently active fiscal year. Users can view, search, add new financial years, and mark one as current.

## Architecture
Follows the standard module layout, plus a `utils/` folder for date formatting/serialisation helpers:

- `models/financial_year.dart` — `FinancialYear`, the plain Dart model with `fromJson`.
- `models/create_financial_year_request.dart` — `CreateFinancialYearRequest`, the create-payload model with `toJson`.
- `services/financial_year_service.dart` — `FinancialYearService`, raw HTTP calls via `ApiService`.
- `repository/financial_year_repository.dart` — `FinancialYearRepository`, unwraps `ResponseModelWrapper` and throws `AppException`.
- `viewModel/financial_year_view_model.dart` — `FinancialYearViewModel` (`ChangeNotifier`), all UI state, including which year is currently "selected" in the app.
- `screens/financial_year_screen.dart` — `FinancialYearScreen`, the `StatefulWidget` shell.
- `state/financial_year_screen_state.dart` — `FinancialYearScreenState`, the screen's logic.
- `utils/date_helpers.dart` — free functions (no Flutter widget dependency) for formatting/parsing/serialising dates, shared by both the widgets and the screen state.
- `widgets/financial_year_add_dialog.dart` — `FinancialYearAddDialog`, the add-financial-year form dialog with date pickers.
- `widgets/financial_year_card.dart` — `FinancialYearCard`, a row widget for narrow layouts.
- `README.md` — short module note confirming this same layout and that dates are exchanged with the backend as `yyyy-MM-dd` strings, kept as-is on the model, with `utils/` handling display formatting and `DateTime` serialisation for the add dialog.

Data flow: `FinancialYearScreenState` → `FinancialYearViewModel` → `FinancialYearRepository` → `FinancialYearService` → `ApiService`.

## Screens

### FinancialYearScreen (`screens/financial_year_screen.dart`) / FinancialYearScreenState (`state/financial_year_screen_state.dart`)
**Purpose:** Lists all financial years, lets the user search, add a new one, and mark a year as the current fiscal year. Renders as a custom flex-row table on wide screens (≥760px) and a card list on narrow screens.

**UI elements & actions:**
- Search `TextField` ("Search by name, code, ID or dates...") — `onChanged` calls `viewModel.setQuery(value)`, filtering in-memory by name, id, code, start date string, or end date string.
- "Add financial year" `FilledButton.icon` — calls `_openAddDialog()`, opening `FinancialYearAddDialog` via `showDialog<CreateFinancialYearRequest>`; on a non-null result, calls `context.read<FinancialYearViewModel>().addFinancialYear(result)`.
- "Set as current" action — a star icon button (`Icons.star_outline_rounded`, tooltip "Set as current year") shown per row/card for any year that is not already current; calls `_setCurrent(viewModel, id)`, which looks up the matching `FinancialYear`, shows an `AlertDialog` ("Set as current year?" / "<name> will become the fiscal year used for transactions.") with Cancel/"Set current" actions, and on confirm calls `viewModel.setCurrentFinancialYear(year, true)`. Years that are already current show a filled star icon (`Icons.star_rounded`) instead of a button.
- Wide layout (`_FinancialYearTable`, custom `Container`/`Column`/`ListView.separated` built from flex rows rather than `DataTable` — matching the pattern used by account_nature/UQC tables — with a pinned header): columns SL NO, NAME, CODE (badge), PERIOD (`start → end`, formatted via `formatFinancialDateString`), STATUS (`_CurrentBadge` "Current" or `—`), and a trailing star toggle.
- Narrow layout: `ListView.separated` of `FinancialYearCard` widgets, each showing a `_CurrentBadge` next to the name when current, and a star toggle otherwise (`onSetCurrent` passed as `null` when already current, disabling the action).
- Empty state (`_EmptyState`): icon, "No financial years found", hint to search differently or add a new financial year.
- Error banner: shown above the list when `viewModel.error != null`.

**Form validation & behavior (in `FinancialYearAddDialog`):**
- Start date and end date are picked via `showDatePicker` (`_pickStartDate`/`_pickEndDate`); picking a start date auto-suggests an end date one typical Apr–Mar fiscal year later (`_suggestEndDate`) if end isn't already set, and vice versa (`_suggestStartDate`) when picking an end date first.
- Picking either date also auto-fills the Name and Code fields (only if still empty) following the `FY 2024-25` / `FY2425` convention, based on which Apr–Mar fiscal year the picked date falls in (`_suggestNameAndCode`).
- On submit (`_submit`): form validation runs first (name required — "Enter a financial year name"); then checks both dates are set (`_dateError = 'Start and end dates are required.'` if not) and that end is not before start (`_dateError = 'End date must be after the start date.'`); the date error is shown as inline text below the date fields.
- Code field: optional, restricted to `[A-Za-z0-9_-]`, auto-uppercased via `_UpperCaseTextFormatter`, re-uppercased/trimmed on submit.
- "Set as current year" `SwitchListTile` — toggles `_isCurrent`, included in the submitted request's `isCurrent` field.
- On successful validation, pops a `CreateFinancialYearRequest` built from the trimmed name, optional code, the two `DateTime`s, and `isCurrent`.

**Events & state changes:**
- `initState` schedules a post-frame callback calling `context.read<FinancialYearViewModel>().loadFinancialYears()` once mounted.
- Loading state: `viewModel.isLoading` shows a centered `CircularProgressIndicator`.
- After a successful add, `loadFinancialYears()` is called again to refresh. After successfully setting a year current, `loadFinancialYears()` refreshes and the view model also updates its local "selected" year (see ViewModel below).

## ViewModel(s)

### FinancialYearViewModel (`viewModel/financial_year_view_model.dart`)
Extends `ChangeNotifier`. Constructed with a `FinancialYearRepository`.

**State (getters):**
- `isLoading` (bool)
- `error` (String?)
- `query` (String)
- `financialYears` (List<FinancialYear>) — full unfiltered list
- `selectedFinancialYear` (FinancialYear?) — the year currently selected in the app header/context, resolved by internal `_selectedYearId` against `_financialYears`; `null` until a list has loaded or if the list is empty
- `filteredFinancialYears` (List<FinancialYear>) — `financialYears` filtered (case-insensitive) by `query` against name, id, code, startDate string, and endDate string

**Methods:**
- `selectFinancialYear(FinancialYear year)` — sets `_selectedYearId` to `year.id` (no-op and no notify if already selected) and notifies listeners.
- `loadFinancialYears()` — sets `isLoading = true`, clears `error`, notifies; calls `_repository.fetchFinancialYears()`; on success calls the private `_ensureSelection()`; catches `AppException` (sets `error` to its message) or any other error (generic message); always resets `isLoading` and notifies in `finally`.
- `_ensureSelection()` (private) — keeps the current selection if it's still present in the reloaded list; otherwise falls back to the year flagged `isCurrent`, and if none is current, falls back to the first year in the list (or `null` if the list is empty).
- `setQuery(String value)` — updates `_query` and notifies.
- `addFinancialYear(CreateFinancialYearRequest request)` → `Future<bool>` — clears `error`, notifies; calls `_repository.createFinancialYear(request)`; on success calls `loadFinancialYears()` and returns `true`; on `AppException`/other error sets `error` and returns `false`.
- `setCurrentFinancialYear(FinancialYear year, bool current)` → `Future<bool>` — clears `error`, notifies; calls `_repository.updateCurrentFinancialYear(year.id, current)`; on success calls `loadFinancialYears()`, and if `current` is `true` also calls `selectFinancialYear(year)`; returns `true`. On error, sets `error` and returns `false`.

## Repository / Service

### FinancialYearRepository (`repository/financial_year_repository.dart`)
Constructed with a `FinancialYearService`.
- `fetchFinancialYears()` — calls `service.fetchFinancialYears()`, unwraps via `ResponseModelWrapper<dynamic>.fromJson`; throws `AppException(wrapper.message ?? 'Could not load financial years.', code: wrapper.code)` on failure; otherwise reads `wrapper.data?.result` (expects a `List`, else returns `const []`) and maps entries through `FinancialYear.fromJson`.
- `createFinancialYear(CreateFinancialYearRequest request)` — calls `service.createFinancialYear(request)`, unwraps, throws `AppException('Could not create financial year.', ...)` on failure.
- `updateCurrentFinancialYear(int id, bool current)` — calls `service.updateCurrentFinancialYear(id, current)`, unwraps, throws `AppException('Could not update financial year.', ...)` on failure.

### FinancialYearService (`services/financial_year_service.dart`)
Constructed with `ApiService`. Pure HTTP, no parsing:
- `fetchFinancialYears()` — `GET OrganisationalApiConfig.financialYearAPI` (`/financial-years`).
- `createFinancialYear(request)` — `POST OrganisationalApiConfig.createFinancialYearAPI` (`/financial-years/create`) with `data: request.toJson()`.
- `updateCurrentFinancialYear(id, current)` — `GET OrganisationalApiConfig.updateFinancialYearCurrentAPI` (`/financial-years/current`) with `queryParameters: {'id': id, 'current': current}`. (Note: implemented as a `GET` with query params rather than a `PUT`/`POST`.)

## Models

### FinancialYear (`models/financial_year.dart`)
- `id` (int, required)
- `name` (String, required)
- `code` (String?) — short fiscal-year code, e.g. `FY2425`
- `startDate` (String?) — `yyyy-MM-dd`, e.g. `2024-04-01`
- `endDate` (String?) — `yyyy-MM-dd`
- `isCurrent` (bool, default `false`) — whether this is the fiscal year currently in use for transactions
- `icon` (IconData, default `Icons.calendar_month_rounded`) — UI-only, not from JSON
- `color` (Color, default `AppColors.primary`) — UI-only, not from JSON
- `fromJson` reads `id`, `name`, `code`, `startDate`, `endDate`, `isCurrent` from the backend `FinancialYearDTO` shape. No `demo` list on this model (unlike `Country`/`StateMaster`).

### CreateFinancialYearRequest (`models/create_financial_year_request.dart`)
- `name` (String, required)
- `code` (String?)
- `startDate` (DateTime, required)
- `endDate` (DateTime, required)
- `isCurrent` (bool, default `false`)
- `toJson()` always includes `name`; includes `code` only if non-null and non-empty; serialises `startDate`/`endDate` via `toFinancialDateString` (from `utils/date_helpers.dart`) to `dd-MM-yyyy` strings (matching the backend's `CreateFinancialYearDTO` `@JsonFormat(pattern = "dd-MM-yyyy")`); includes `isCurrent` only when `true`.

## Utils

### date_helpers.dart (`utils/date_helpers.dart`)
Free functions, no Flutter widget dependency, shared by the screen state and widgets:
- `formatFinancialDate(DateTime date)` — formats a `DateTime` as `dd MMM yyyy` (e.g. `01 Apr 2024`) using a local `_monthNames` list.
- `formatFinancialDateString(String? value)` — formats a backend `yyyy-MM-dd` string for display in the same `dd MMM yyyy` form; returns `'—'` for null/empty input, and returns the raw `value` unchanged if it doesn't parse as `yyyy-MM-dd` (wrong part count, non-numeric parts, or an out-of-range month).
- `toFinancialDateString(DateTime date)` — converts a `DateTime` to `dd-MM-yyyy`, the format the backend's create endpoint expects (distinct from the `yyyy-MM-dd` format the read endpoint returns).

## Widgets

### FinancialYearAddDialog (`widgets/financial_year_add_dialog.dart`)
Stateful dialog form with controllers for name and code, plus `_startDate`/`_endDate` (`DateTime?`), `_isCurrent` (bool), and `_dateError` (String?) fields. Contains a private `_UpperCaseTextFormatter` (uppercases the code field as typed) and a private `_DatePickerField` widget (an `InkWell`-wrapped `InputDecorator` that opens a date picker on tap and displays the chosen date via `formatFinancialDate`, or "Select" if unset). Implements the date auto-suggestion and name/code auto-fill behavior described under Screens above. On submit, pops a `CreateFinancialYearRequest`; Cancel pops `null`.

### FinancialYearCard (`widgets/financial_year_card.dart`)
Stateless row card for the narrow layout. Shows the year's icon (tinted by `financialYear.color`), name (with an inline `_CurrentBadge` "Current" pill when `isCurrent`), a subtitle joining id/code/period (start → end, via `formatFinancialDateString`), and a trailing control: a filled star icon (non-interactive) if current, or a star-outline `IconButton` calling `onSetCurrent` otherwise (button omitted entirely if `onSetCurrent` is `null`).
