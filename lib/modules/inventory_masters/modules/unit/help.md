# Unit

## Purpose
Units of measurement (e.g. Piece, Kilogram, Meter, Liter, Box, Dozen) quantify inventory items. A unit can be `simple` (measures an item directly) or `compound` (expressed in terms of one or two base units with a conversion factor/operator — e.g. "1 Dozen = 12 Piece"), and each unit can optionally be tagged with a GST UQC (from the `unique_quantity_code` sub-module) describing its GST reporting code. This master lets a user browse, search, create, and delete units.

## Architecture
- `models/unit.dart` — `Unit`, the DTO (includes UI-only `icon`/`color` and a `demo` fallback dataset).
- `models/stock_unit_type.dart` — `StockUnitType`, a `simple`/`compound` enum with wire-value serialization helpers, shared by both `Unit` and `CreateUnitRequest`.
- `models/create_unit_request.dart` — `CreateUnitRequest`, the create-payload DTO (superset of the `Unit` model's editable fields).
- `repository/unit_repository.dart` — `UnitRepository`, unwraps `ResponseModelWrapper`, throws `AppException`.
- `services/unit_service.dart` — `UnitService`, raw HTTP calls via `ApiService`.
- `viewModel/unit_view_model.dart` — `UnitViewModel`, a `ChangeNotifier` holding the list, loading/error state, and search query.
- `screens/unit_screen.dart` + `state/unit_screen_state.dart` — the list screen (`UnitScreen` shell + `UnitScreenState` body).
- `widgets/unit_card.dart` — `UnitCard`, the row card for narrow layouts.
- `widgets/unit_add_dialog.dart` — `UnitAddDialog`, the `AlertDialog`-based create form, which reads/loads the `unique_quantity_code` sub-module's `UniqueQuantityCodeViewModel` to populate its UQC picker.

## Screens

### UnitScreen (`screens/unit_screen.dart`)
**Purpose:** Thin `StatefulWidget` shell; delegates to `UnitScreenState`.

**UI elements & actions:** None directly.

**Events & state changes:** None; stateless shell.

### UnitScreenState (`state/unit_screen_state.dart`)
**Purpose:** Full-screen `Scaffold` ("Units") listing all units with search, add, and delete.

**UI elements & actions:**
- Search `TextField` ("Search by name, code or ID...") — `onChanged` calls `viewModel.setQuery`, filtering via `filteredUnits` (matches name, id, or code).
- "Add unit" `FilledButton.icon` — calls `_openAddDialog()`, which shows `UnitAddDialog` via `showDialog<CreateUnitRequest>`. On a non-null result, calls `context.read<UnitViewModel>().addUnit(result)`.
- Responsive layout via `LayoutBuilder`: width ≥ 720 renders `_UnitTable` (a `DataTable` with ID/Name/Code/Description/Status/delete-icon columns inside a `Card`); narrower renders a `ListView.separated` of `UnitCard` rows.
- Each row has a delete icon button that calls `_confirmDelete(viewModel, id)`.
- `_confirmDelete` shows an `AlertDialog` ("Delete unit?" / "This will remove the unit from your master.") with Cancel/Delete; on confirm, calls `viewModel.deleteUnit(id)`.

**Events & state changes:**
- `initState` has the auto-load callback (`... loadUnits()`) **commented out**, same as `StockGroupScreenState` — `UnitScreen` does not automatically load its list on open. The list only populates via another trigger (e.g. `StockItemScreenState.initState`, which loads units if empty as a dependency for its own classification dropdown, or `UnitAddDialog`/`StockItemAddDialog` loading UQCs — note those load *UQCs*, not units; nothing else in this domain proactively loads units besides the stock-item screen).
- `viewModel.error != null` renders an inline red-tinted error banner above the list.
- `viewModel.isLoading` shows a centered `CircularProgressIndicator`; empty filtered list shows `_EmptyState` ("No units found").
- `_StatusBadge` renders Active/Inactive.

## ViewModel(s)

### UnitViewModel (`viewModel/unit_view_model.dart`)
Exposed state:
- `isLoading` (bool), `error` (String?), `query` (String), `units` (List<Unit>).
- `filteredUnits` — filters by `query` matching name, id, or code (case-insensitive; no alias match here — `Unit` doesn't get matched on alias despite having one).

Public methods:
- `loadUnits()` — sets `isLoading = true`, clears `error`, calls `_repository.fetchUnits()`, stores into `_units`; catches `AppException` (sets `error`) or generic error ("Something went wrong. Please try again."); resets `isLoading` and notifies in `finally`.
- `setQuery(String value)` — sets `_query`, notifies.
- `addUnit(CreateUnitRequest request)` — clears `error`, calls `_repository.createUnit(request)`, reloads via `loadUnits()` on success, returns bool.
- `deleteUnit(int id)` — calls `_repository.deleteUnit(id)`, reloads, returns bool.

## Repository / Service

### UnitRepository (`repository/unit_repository.dart`)
- `fetchUnits()` — calls `service.fetchUnits()`, unwraps `ResponseModelWrapper`, throws `AppException('Could not load units.')` on failure; maps `result` list to `List<Unit>` via `.fromJson`; returns `[]` if not a list.
- `createUnit(CreateUnitRequest request)` — calls `service.createUnit(request)`, throws `AppException('Could not create unit.')` on failure.
- `deleteUnit(int id)` — calls `service.deleteUnit(id)`, throws `AppException('Could not delete unit.')` on failure.

### UnitService (`services/unit_service.dart`)
- `fetchUnits()` — `GET InventoryApiConfig.createUnitAPI` (`/units/create`). **Note:** this GET call targets the same path constant (`createUnitAPI`) that is documented as the "create" endpoint — there is no separate `unitsListAPI`/similar constant in `InventoryApiConfig`, so the fetch and the create-endpoint reference the identically-named `/units/create` string, even though `createUnit()` below posts through the differently-named `ApiConfig.unitCreateEndpoint` (also `/units/create`). Both resolve to the same literal path string but via two different config classes.
- `createUnit(CreateUnitRequest request)` — `POST ApiConfig.unitCreateEndpoint` (`/units/create`) with `request.toJson()`.
- `deleteUnit(int id)` — `DELETE ApiConfig.unitEndpoint(id)` (`/units/{id}`).

## Models

### Unit (`models/unit.dart`)
Fields: `id` (int), `name` (String), `alias` (String?), `description` (String?), `code` (String?), `unitType` (StockUnitType?), `uqcId` (int?, links to a `unique_quantity_code`), `operator` (String?, arithmetic operator linking `baseUnit1Id`/`baseUnit2Id` for compound units), `baseUnit1Id` (int?), `baseUnit2Id` (int?), `conversionFactor` (double?), `decimalPlaces` (int?), `isActive` (bool, default true), `icon` (IconData, UI-only, default `Icons.square_foot_rounded`), `color` (Color, UI-only, default `AppColors.primary`). Has `fromJson` and a static `demo` list of 6 placeholder units (Piece/PCS, Kilogram/KG, Meter/MTR, Liter/LTR, Box/BOX, Dozen/DZN [inactive]).

### StockUnitType (`models/stock_unit_type.dart`)
Enum: `simple` (wireValue `'simple'`), `compound` (wireValue `'compound'`). Static `fromWire(String? value)` parses back from the wire value, returning `null` if unmatched.

### CreateUnitRequest (`models/create_unit_request.dart`)
Fields: `name` (required String), `alias` (String?), `description` (String?), `code` (String?), `unitType` (StockUnitType?), `uqcId` (int?), `primaryUnitId` (int?), `secondaryUnitId` (int?), `conversionFactor` (double?), `decimalPlaces` (int?). Note the field names `primaryUnitId`/`secondaryUnitId` here diverge from `Unit`'s `baseUnit1Id`/`baseUnit2Id` — same concept, different naming between the create-request DTO and the fetched-entity DTO. `toJson()` always includes `name`; all other fields are included only if non-null, with `unitType` serialized via `.wireValue`.

## Widgets

### UnitCard (`widgets/unit_card.dart`)
Row card: icon in tinted container, name, "id · code" subtitle (no alias shown here, unlike other masters' cards), optional description, Active/Inactive pill, optional delete `IconButton`.

### UnitAddDialog (`widgets/unit_add_dialog.dart`)
`AlertDialog`-based create form. Fields: Name (required, validated non-empty), Code (optional, auto-uppercased, restricted to `[A-Za-z0-9_-]`), a `DropdownButtonFormField<StockUnitType>` "Unit type" (defaults to `StockUnitType.simple`, options are the two enum values shown uppercased), a UQC `Autocomplete<UniqueQuantityCode>` field (optional, displaying "`code` — `name`", sourced from `UniqueQuantityCodeViewModel.uqcs` or `UniqueQuantityCode.demo` if empty), and a Description field (3-line).
- `initState`: if the `UniqueQuantityCodeViewModel`'s `uqcs` list is empty and not already loading, schedules `loadUniqueQuantityCodes()` via post-frame callback — this dialog is what typically triggers UQC data to load in this domain.
- On Save, pops a `CreateUnitRequest` with `unitType` and `uqcId` set from the selections. Note this dialog does not expose `primaryUnitId`/`secondaryUnitId`/`conversionFactor`/`decimalPlaces` fields (compound-unit-specific fields), even though `CreateUnitRequest` supports them — those are not yet wired into the UI.
