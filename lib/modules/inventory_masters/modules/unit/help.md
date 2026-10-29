# Unit

## Purpose
Units of measurement (e.g. Piece, Kilogram, Meter, Liter, Box, Dozen) quantify inventory items. A unit can be `simple` (measures an item directly) or `compound` (expressed in terms of base unit(s) with a conversion factor/operator — e.g. "1 Dozen = 12 Piece"), and each unit can optionally be tagged with a GST UQC (from the `unique_quantity_code` sub-module) describing its GST reporting code. This master lets a user browse, search, create, and delete units.

## Architecture
- `models/unit.dart` — `Unit`, the DTO (includes UI-only `icon`/`color` and a `demo` fallback dataset).
- `models/stock_unit_type.dart` — `StockUnitType`, a `simple`/`compound` enum with wire-value serialization helpers, shared by both `Unit` and `CreateStockUnitRequest`.
- `models/create_stock_unit_request.dart` — `CreateStockUnitRequest`, the create-payload DTO (mirrors the backend `CreateStockUnitRequestDTO`).
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
- Search `TextField` ("Search by name, symbol or ID...") — `onChanged` calls `viewModel.setQuery`, filtering via `filteredUnits` (matches name, id, or symbol; case-insensitive).
- "Add unit" `FilledButton.icon` — calls `_openAddDialog()`, which shows `UnitAddDialog` via `showDialog<CreateStockUnitRequest>`. On a non-null result, calls `context.read<UnitViewModel>().addUnit(result)`.
- Responsive layout via `LayoutBuilder`: width ≥ 720 renders `_UnitTable` (a `DataTable` with ID/Name/Symbol/Status/delete-icon columns inside a `Card`); narrower renders a `ListView.separated` of `UnitCard` rows.
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
- `filteredUnits` — filters by `query` matching name, id, or symbol (case-insensitive; no alias match here — `Unit` doesn't get matched on alias despite having one).

Public methods:
- `loadUnits()` — sets `isLoading = true`, clears `error`, calls `_repository.fetchUnits()`, stores into `_units`; catches `AppException` (sets `error`) or generic error ("Something went wrong. Please try again."); resets `isLoading` and notifies in `finally`.
- `setQuery(String value)` — sets `_query`, notifies.
- `addUnit(CreateStockUnitRequest request)` — clears `error`, calls `_repository.createUnit(request)`, reloads via `loadUnits()` on success, returns bool.
- `deleteUnit(String id)` — calls `_repository.deleteUnit(id)`, reloads, returns bool.

## Repository / Service

### UnitRepository (`repository/unit_repository.dart`)
- `fetchUnits()` — calls `service.fetchUnits()`, unwraps `ResponseModelWrapper`, throws `AppException('Could not load units.')` on failure; maps `result` list to `List<Unit>` via `.fromJson`; returns `[]` if not a list.
- `createUnit(CreateStockUnitRequest request)` — calls `service.createUnit(request)`, throws `AppException('Could not create unit.')` on failure.
- `deleteUnit(String id)` — calls `service.deleteUnit(id)`, throws `AppException('Could not delete unit.')` on failure.

### UnitService (`services/unit_service.dart`)
- `fetchUnits()` — `GET InventoryApiConfig.unitListAPI` (`/units/list`).
- `createUnit(CreateStockUnitRequest request)` — `POST InventoryApiConfig.createUnitAPI` (`/units/create`) with `request.toJson()`.
- `deleteUnit(String id)` — `DELETE InventoryApiConfig.unitEndpoint(id)` (`/units/{id}`).

## Models

### Unit (`models/unit.dart`)
Fields: `id` (String, UUID), `name` (String), `alias` (String?), `symbol` (String?), `unitType` (StockUnitType?), `uqcId` (String?, links to a `unique_quantity_code`), `primaryUnitId` (String?), `secondaryUnitId` (String?), `conversionFactor` (double?), `decimalPlaces` (int?), `isActive` (bool, default true), `icon` (IconData, UI-only, default `Icons.square_foot_rounded`), `color` (Color, UI-only, default `AppColors.primary`). Has `fromJson` and a static `demo` list of 6 placeholder units (Piece/PCS, Kilogram/KGS, Meter/MTR, Liter/LTR, Box/BOX, Dozen/DZN [inactive]).

### StockUnitType (`models/stock_unit_type.dart`)
Enum: `simple` (wireValue `'simple'`), `compound` (wireValue `'compound'`). Static `fromWire(String? value)` parses back from the wire value, returning `null` if unmatched.

### CreateStockUnitRequest (`models/create_stock_unit_request.dart`)
Fields: `name` (required String), `symbol` (String?), `alias` (String?), `unitType` (StockUnitType?), `uqcId` (String?), `primaryUnitId` (String?), `secondaryUnitId` (String?), `conversionFactor` (double?), `decimalPlaces` (int?), `active` (bool?). `toJson()` always includes `name`; all other fields are included only if non-null, with `unitType` serialized via `.wireValue`.

## Widgets

### UnitCard (`widgets/unit_card.dart`)
Row card: icon in tinted container, name, "id · symbol" subtitle (no alias/description shown here), Active/Inactive pill, optional delete `IconButton`.

### UnitAddDialog (`widgets/unit_add_dialog.dart`)
`AlertDialog`-based create form. Fields: Name (required, validated non-empty), Symbol (optional, auto-uppercased, restricted to `[A-Za-z0-9_-]`), an `Active` switch (defaults to true), a `DropdownButtonFormField<StockUnitType>` "Unit type" (defaults to `StockUnitType.simple`, options are the two enum values shown uppercased), a UQC `Autocomplete<UniqueQuantityCode>` field (optional, displaying "`code` — `name`", sourced from `UniqueQuantityCodeViewModel.uqcs` or `UniqueQuantityCode.demo` if empty). When the unit type is `compound`, a primary-unit picker, an optional secondary-unit picker and a conversion-factor field are shown; all three are hidden for `simple`. An optional decimal-places field (0–4) is also collected. On Save, pops a `CreateStockUnitRequest`.
