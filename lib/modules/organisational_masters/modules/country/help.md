# Country

## Purpose
Maintains the master list of countries the organisation operates in or transacts with — a simple reference list (name, ISO code, alias, description, active status) used elsewhere in the app (for example, as the parent lookup for states). Users can view, search, add, and delete countries from this screen.

## Architecture
Follows the standard module layering:

- `models/country.dart` — `Country`, the plain Dart model with `fromJson` and demo seed data.
- `models/create_country_request.dart` — `CreateCountryRequest`, the create-payload model with `toJson`.
- `services/country_service.dart` — `CountryService`, raw HTTP calls via `ApiService`.
- `repository/country_repository.dart` — `CountryRepository`, unwraps `ResponseModelWrapper` and throws `AppException`.
- `viewModel/country_view_model.dart` — `CountryViewModel` (`ChangeNotifier`), all UI state.
- `screens/country_screen.dart` — `CountryScreen`, the `StatefulWidget` shell.
- `state/country_screen_state.dart` — `CountryScreenState`, the screen's logic (split out per the StatefulWidget pattern).
- `widgets/country_add_dialog.dart` — `CountryAddDialog`, the add-country form dialog.
- `widgets/country_card.dart` — `CountryCard`, a row widget for narrow layouts.

Data flow: `CountryScreenState` → `CountryViewModel` → `CountryRepository` → `CountryService` → `ApiService`. `CountryRepository` is also reused directly by the **state** sub-module's `StateViewModel` to populate the country picker/lookup there (see `modules/state/help.md`).

## Screens

### CountryScreen (`screens/country_screen.dart`) / CountryScreenState (`state/country_screen_state.dart`)
**Purpose:** Lists all countries, lets the user search, add a new country, and delete an existing one. Renders as a table on wide screens (≥720px) and a card list on narrow screens.

**UI elements & actions:**
- Search `TextField` ("Search by name, code or ID...") — `onChanged` calls `viewModel.setQuery(value)`, which filters the in-memory list live (no network call).
- "Add country" `FilledButton.icon` — calls `_openAddDialog()`, which opens `CountryAddDialog` via `showDialog<CreateCountryRequest>`. If the dialog returns a non-null request, calls `context.read<CountryViewModel>().addCountry(result)`.
- Delete action (icon button, per row/card, tooltip "Delete country") — calls `_confirmDelete(viewModel, id)`, which shows an `AlertDialog` ("Delete country?" / "This will remove the country from your master.") with Cancel/Delete actions; on confirm, calls `viewModel.deleteCountry(id)`.
- Wide layout (`_CountryTable`, `LayoutBuilder` with `constraints.maxWidth >= 720`): a `DataTable` with columns ID, Name, Code, Alias, Description, Status (`_StatusBadge`, Active/Inactive), and a trailing delete icon button per row.
- Narrow layout: `ListView.separated` of `CountryCard` widgets, each with its own delete icon button (see Widgets below).
- Empty state (`_EmptyState`): shown when the filtered list is empty — icon, "No countries found", and a hint to search differently or add a country.
- Error banner: shown above the list when `viewModel.error != null` — a red-tinted container with an error icon and the error message text.

**Form validation (in `CountryAddDialog`):**
- Name is required (`validator` rejects empty/whitespace-only input with "Enter a country name").
- ISO code field: input restricted to `[A-Za-z0-9_-]` via `FilteringTextInputFormatter`, auto-uppercased as typed via a custom `_UpperCaseTextFormatter`, and re-uppercased/trimmed on submit; optional.
- Alias and description are optional free text (description supports up to 3 lines).

**Events & state changes:**
- `initState` schedules (`WidgetsBinding.instance.addPostFrameCallback`) a call to `context.read<CountryViewModel>().loadCountries()` once the widget is mounted, so the list loads on first build.
- Loading state: `viewModel.isLoading` shows a centered `CircularProgressIndicator` in place of the list/table.
- After a successful add or delete, the view model reloads the full list from the backend (see ViewModel below) so the screen reflects the latest server state.

## ViewModel(s)

### CountryViewModel (`viewModel/country_view_model.dart`)
Extends `ChangeNotifier`. Constructed with a `CountryRepository`.

**State (getters):**
- `isLoading` (bool)
- `error` (String?)
- `query` (String) — current search text
- `countries` (List<Country>) — full unfiltered list
- `filteredCountries` (List<Country>) — `countries` filtered (case-insensitive) by `query` against name, id (as string), code, and alias

**Methods:**
- `loadCountries()` — sets `isLoading = true`, clears `error`, notifies; calls `_repository.fetchCountries()`; on `AppException` sets `error` to the exception's message, on any other error sets a generic "Something went wrong. Please try again." message; always sets `isLoading = false` and notifies in `finally`.
- `setQuery(String value)` — updates `_query` and notifies (drives `filteredCountries`).
- `addCountry(CreateCountryRequest request)` → `Future<bool>` — clears `error`, notifies; calls `_repository.createCountry(request)`; on success calls `loadCountries()` (refresh) and returns `true`; on `AppException`/other error sets `error` and returns `false`.
- `deleteCountry(int id)` → `Future<bool>` — same pattern as `addCountry`, calling `_repository.deleteCountry(id)` then `loadCountries()` on success.

## Repository / Service

### CountryRepository (`repository/country_repository.dart`)
Constructed with a `CountryService`.
- `fetchCountries()` — calls `service.fetchCountries()`, wraps the raw JSON in `ResponseModelWrapper<dynamic>.fromJson`; throws `AppException(wrapper.message ?? 'Could not load countries.', code: wrapper.code)` if `!wrapper.success`; otherwise reads `wrapper.data?.result` (expected to be a `List`, else returns `const []`) and maps each `Map<String, dynamic>` entry through `Country.fromJson`.
- `createCountry(CreateCountryRequest request)` — calls `service.createCountry(request)`, unwraps, throws `AppException('Could not create country.', ...)` on failure; no return value on success.
- `deleteCountry(int id)` — calls `service.deleteCountry(id)`, unwraps, throws `AppException('Could not delete country.', ...)` on failure.

### CountryService (`services/country_service.dart`)
Constructed with `ApiService`. Pure HTTP, no parsing:
- `fetchCountries()` — `GET OrganisationalApiConfig.countryAPI` (`/countries/list`).
- `createCountry(request)` — `POST OrganisationalApiConfig.createCountryAPI` (`/countries/list/create`) with `data: request.toJson()`.
- `deleteCountry(id)` — `DELETE OrganisationalApiConfig.countryEndpoint(id)` (`/countries/list/$id`).

## Models

### Country (`models/country.dart`)
- `id` (int, required)
- `name` (String, required)
- `code` (String?) — ISO 3166-1 alpha-2 code, e.g. `IN`
- `alias` (String?)
- `description` (String?)
- `isActive` (bool, default `true`)
- `icon` (IconData, default `Icons.public_rounded`) — UI-only, not from JSON
- `color` (Color, default `AppColors.primary`) — UI-only, not from JSON
- `fromJson` reads `id`, `name`, `code`, `alias`, `description`, `isActive` (`== true` check) from the backend `CountryDTO` shape; `icon`/`color` are not populated from JSON (left at defaults).
- `static const demo` — 5 hardcoded placeholder countries (India, United States, United Kingdom, United Arab Emirates, Singapore) used elsewhere as fallback/demo data (e.g. by the state module's country picker when the live list is empty).

### CreateCountryRequest (`models/create_country_request.dart`)
- `name` (String, required)
- `code` (String?)
- `alias` (String?)
- `description` (String?)
- `toJson()` always includes `name`; includes `code`/`alias`/`description` only when non-null, so the backend's `@NotBlank` validation applies only to `name`.

## Widgets

### CountryAddDialog (`widgets/country_add_dialog.dart`)
Stateful dialog form (`Form` + `GlobalKey<FormState>`) with controllers for name, code, alias, description. Contains a private `_UpperCaseTextFormatter` (a `TextInputFormatter` that uppercases input as typed, used on the code field). On submit, validates the form and, if valid, pops the dialog with a constructed `CreateCountryRequest` (trimmed values; empty optional fields become `null`; code is uppercased). Cancel pops with `null`.

### CountryCard (`widgets/country_card.dart`)
Stateless row card for the narrow (mobile) layout. Shows the country's icon (tinted by `country.color`), name, a subtitle joining id/code/alias, optional description line, an Active/Inactive status badge, and — when `onDelete` is provided — a trailing delete icon button.
