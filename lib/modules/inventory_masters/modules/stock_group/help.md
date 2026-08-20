# Stock Group

## Purpose
Stock groups classify inventory items into broad buckets (e.g. Trading Goods, Raw Materials, Finished Goods), and — unlike stock categories — carry two extra behavioral flags per group: whether the group should maintain quantities, and whether GST details can be set/altered at the group level. Like stock categories, groups can be nested under a parent group. This master lets a user browse, search, create and delete stock groups.

## Architecture
- `models/stock_group.dart` — `StockGroup`, the DTO (includes UI-only `icon`/`color` and a `demo` fallback dataset).
- `repository/stock_group_repository.dart` — `StockGroupRepository`, unwraps `ResponseModelWrapper`, throws `AppException`.
- `services/stock_group_service.dart` — `StockGroupService`, raw HTTP calls via `ApiService`.
- `viewModel/stock_group_view_model.dart` — `StockGroupViewModel`, a `ChangeNotifier` holding the list, loading/error state, and search query.
- `screens/stock_group_screen.dart` + `state/stock_group_screen_state.dart` — the list screen (`StockGroupScreen` shell + `StockGroupScreenState` body).
- `widgets/stock_group_card.dart` — `StockGroupCard`, the row card for narrow layouts.
- `widgets/stock_group_add_dialog.dart` — `StockGroupAddDialog`, the `AlertDialog`-based create form, actively used by the screen (unlike the equivalent dialog in `stock_category`, this one **is** wired up).

Note: unlike `stock_category`, there is no separate create-request model class — the repository's `createStockGroup` takes named parameters directly and builds the JSON map inline.

## Screens

### StockGroupScreen (`screens/stock_group_screen.dart`)
**Purpose:** Thin `StatefulWidget` shell; delegates to `StockGroupScreenState`.

**UI elements & actions:** None directly.

**Events & state changes:** None; stateless shell.

### StockGroupScreenState (`state/stock_group_screen_state.dart`)
**Purpose:** Full-screen `Scaffold` ("Stock Groups") listing all stock groups with search, add, and delete.

**UI elements & actions:**
- Search `TextField` ("Search by name, code or ID...") — `onChanged` calls `viewModel.setQuery`, filtering via `filteredStockGroups`.
- "Add group" `FilledButton.icon` — calls `_openAddDialog()`, which shows `StockGroupAddDialog` via `showDialog<({...})>` (a Dart record type covering all the create fields). If a non-null result is returned, calls `context.read<StockGroupViewModel>().addStockGroup(...)` with each field spread from the record.
- Responsive layout via `LayoutBuilder`: width ≥ 720 renders `_StockGroupTable` (a `DataTable` with ID/Name/Code/Alias/Description/Quantities/GST/Status/delete-icon columns, where Quantities and GST columns show a green check icon via `_CheckCell` when the flag is true, or `—` when false); narrower renders a `ListView.separated` of `StockGroupCard` rows.
- Each row has a delete icon button that calls `_confirmDelete(viewModel, id)`.
- `_confirmDelete` shows an `AlertDialog` ("Delete group?") with Cancel/Delete; on confirm, calls `viewModel.deleteStockGroup(id)`.

**Events & state changes:**
- `initState` has the auto-load `WidgetsBinding.instance.addPostFrameCallback(... loadStockGroups())` call **commented out** — unlike every other master screen in this domain, `StockGroupScreen` does **not** automatically load its list on open. The list only populates once something else triggers `loadStockGroups()` (e.g. `StockItemScreenState.initState`, which loads stock groups if empty as a dependency for its own classification dropdown) or the user manually triggers a reload path.
- `viewModel.error != null` renders an inline red-tinted error banner above the list.
- `viewModel.isLoading` shows a centered `CircularProgressIndicator`; empty filtered list shows `_EmptyState` ("No stock groups found").
- `_StatusBadge` renders Active/Inactive; `_CheckCell` renders the two boolean flags in the table.

## ViewModel(s)

### StockGroupViewModel (`viewModel/stock_group_view_model.dart`)
Exposed state:
- `isLoading` (bool), `error` (String?), `query` (String), `stockGroups` (List<StockGroup>).
- `filteredStockGroups` — filters by `query` matching name, id, code, or alias (case-insensitive).

Public methods:
- `loadStockGroups()` — sets `isLoading = true`, clears `error`, calls `_repository.fetchStockGroups()`, stores into `_stockGroups`; catches `AppException` (sets `error` to message) or generic error ("Something went wrong. Please try again."); resets `isLoading = false` and notifies in `finally`.
- `setQuery(String value)` — sets `_query`, notifies.
- `addStockGroup({name, code, alias, parentId, description, shouldAddQuantities = false, setAlterGstDetail = false})` — clears `error`, calls `_repository.createStockGroup(...)` with all params, reloads via `loadStockGroups()` on success, returns bool.
- `deleteStockGroup(int id)` — calls `_repository.deleteStockGroup(id)`, reloads, returns bool.

## Repository / Service

### StockGroupRepository (`repository/stock_group_repository.dart`)
- `fetchStockGroups()` — calls `service.fetchStockGroups()`, unwraps `ResponseModelWrapper`, throws `AppException('Could not load stock groups.')` on failure; maps `result` list to `List<StockGroup>` via `StockGroup.fromJson`; returns `[]` if not a list.
- `createStockGroup({required name, code, alias, parentId, description, shouldAddQuantities = false, setAlterGstDetail = false})` — builds a JSON map inline using Dart's `?key: value` null-aware map-entry syntax (omits `alias`/`code`/`description`/`parentId` if null), calls `service.createStockGroup(map)`, throws `AppException('Could not create stock group.')` on failure.
- `deleteStockGroup(int id)` — calls `service.deleteStockGroup(id)`, throws `AppException('Could not delete stock group.')` on failure.

### StockGroupService (`services/stock_group_service.dart`)
- `fetchStockGroups()` — `GET ApiConfig.stockGroupsEndpoint` (`/stock-groups`).
- `createStockGroup(Map<String, dynamic> data)` — `POST ApiConfig.stockGroupCreateEndpoint` (`/stock-groups/create`) with `data`.
- `deleteStockGroup(int id)` — `DELETE ApiConfig.stockGroupEndpoint(id)` (`/stock-groups/{id}`).

All three use the global hyphenated `ApiConfig` endpoints, not `InventoryApiConfig`'s underscored `stockGroupAPI`/`createStockGroupAPI` constants (which appear unused).

## Models

### StockGroup (`models/stock_group.dart`)
Fields: `id` (int), `name` (String), `code` (String?), `alias` (String?), `description` (String?), `isActive` (bool, default true), `shouldAddQuantities` (bool, default false), `setAlterGstDetail` (bool, default false), `icon` (IconData, UI-only, default `Icons.folder_rounded`), `color` (Color, UI-only, default `AppColors.primary`). Has `fromJson` and a static `demo` list of 5 placeholder groups (Primary [inactive, root], Trading Goods, Raw Materials, Finished Goods, Consumables [inactive]).

There is no separate create-request DTO in this module — `createStockGroup` on the repository takes individual named parameters.

## Widgets

### StockGroupCard (`widgets/stock_group_card.dart`)
Row card: icon in tinted container, name, "id · code · aka alias" subtitle, optional description, Active/Inactive pill, an additional "Qty" pill shown only when `shouldAddQuantities` is true, and an optional delete `IconButton`.

### StockGroupAddDialog (`widgets/stock_group_add_dialog.dart`)
`AlertDialog`-based create form, actively used by the screen. Fields: Name (required), Code (optional, auto-uppercased, restricted to `[A-Za-z0-9_-]`), Alias (optional), an "Under" `Autocomplete<StockGroup>` (options from existing groups or `StockGroup.demo`; defaults to the "Primary" group if present, else the first group, once loaded post-frame), two `SwitchListTile`s ("Maintain quantities" defaulting to `true`, "Set/alter GST details" defaulting to `false`), and a Description field. On Save, pops a Dart record `({name, alias, code, description, parentId, shouldAddQuantities, setAlterGstDetail})` consumed directly by `_openAddDialog` in the screen state.
