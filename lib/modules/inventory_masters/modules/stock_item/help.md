# Stock Item

## Purpose
Stock items are the individual inventory products actually stocked and traded (e.g. "A4 Copier Paper", "Wireless Mouse") — the leaf-level master that everything else (stock group, stock category, unit) classifies. This is explicitly a "lean scaffold": only identity fields (name, alias, code, description) and classification links (stock group, stock category, unit) are modelled; GST/HSN codes, opening balances, godowns and batch tracking are not yet implemented. This master lets a user browse, search, create and delete stock items, and displays each item's resolved group/category/unit names.

## Architecture
- `models/stock_item.dart` — `StockItem`, the DTO (includes UI-only `icon`/`color` and a `demo` fallback dataset).
- `repository/stock_item_repository.dart` — `StockItemRepository`, unwraps `ResponseModelWrapper`, throws `AppException`.
- `services/stock_item_service.dart` — `StockItemService`, raw HTTP calls via `ApiService`.
- `viewModel/stock_item_view_model.dart` — `StockItemViewModel`, a `ChangeNotifier` holding the list, loading/error state, and search query.
- `screens/stock_item_screen.dart` + `state/stock_item_screen_state.dart` — the list screen (`StockItemScreen` shell + `StockItemScreenState` body). This state class also reads and, if needed, triggers loads on the sibling `StockGroupViewModel`, `StockCategoryViewModel`, and `UnitViewModel` (from the `stock_group`, `stock_category`, and `unit` sub-modules) so it can resolve and display human-readable names for an item's `stockGroupId`/`stockCategoryId`/`unitId`.
- `widgets/stock_item_card.dart` — `StockItemCard`, the row card for narrow layouts.
- `widgets/stock_item_add_dialog.dart` — `StockItemAddDialog`, the `AlertDialog`-based create form, used by the screen.

Like `stock_group`, there is no separate create-request model — the repository's `createStockItem` takes named parameters directly.

## Screens

### StockItemScreen (`screens/stock_item_screen.dart`)
**Purpose:** Thin `StatefulWidget` shell; delegates to `StockItemScreenState`.

**UI elements & actions:** None directly.

**Events & state changes:** None; stateless shell.

### StockItemScreenState (`state/stock_item_screen_state.dart`)
**Purpose:** Full-screen `Scaffold` ("Stock Items") listing all stock items with search, add, and delete, showing each item's classification (group/category/unit) resolved to display names.

**UI elements & actions:**
- Search `TextField` ("Search by name, code or ID...") — `onChanged` calls `viewModel.setQuery`, filtering via `filteredStockItems`.
- "Add item" `FilledButton.icon` — calls `_openAddDialog()`, which shows `StockItemAddDialog` via `showDialog<({...})>` (a record covering name/alias/code/description/stockGroupId/stockCategoryId/unitId). On non-null result, calls `context.read<StockItemViewModel>().addStockItem(...)`.
- Responsive layout via `LayoutBuilder`: width ≥ 720 renders `_StockItemTable` (`DataTable` with ID/Name/Code/Group/Category/Unit/Status/delete-icon columns, where Group/Category/Unit cells are resolved via local `groupName`/`categoryName`/`unitName` lookup closures against the watched sibling viewModels' lists — falling back to `—` if unresolved); narrower renders a `ListView.separated` of `StockItemCard` rows (which do not show group/category/unit, only name/code/alias/description/status).
- Each row has a delete icon button that calls `_confirmDelete(viewModel, id)`.
- `_confirmDelete` shows an `AlertDialog` ("Delete item?") with Cancel/Delete; on confirm, calls `viewModel.deleteStockItem(id)`.

**Events & state changes:**
- `initState` (post-frame callback): calls `context.read<StockItemViewModel>().loadStockItems()` unconditionally, then checks each of `StockGroupViewModel`, `StockCategoryViewModel`, `UnitViewModel` — if that viewModel's list is empty **and** it isn't already loading, triggers its respective `load...()` method. This means opening the Stock Item screen can cascade into loading stock groups, stock categories, and units if they haven't been loaded elsewhere yet (notably relevant since `StockGroupScreen` itself doesn't auto-load — see stock_group's help.md).
- `viewModel.error != null` renders an inline red-tinted error banner above the list.
- `viewModel.isLoading` shows a centered `CircularProgressIndicator`; empty filtered list shows `_EmptyState` ("No stock items found").
- `_StatusBadge` renders Active/Inactive.

## ViewModel(s)

### StockItemViewModel (`viewModel/stock_item_view_model.dart`)
Exposed state:
- `isLoading` (bool), `error` (String?), `query` (String), `stockItems` (List<StockItem>).
- `filteredStockItems` — filters by `query` matching name, id, code, or alias (case-insensitive).

Public methods:
- `loadStockItems()` — sets `isLoading = true`, clears `error`, calls `_repository.fetchStockItems()`, stores into `_stockItems`; catches `AppException` (sets `error`) or generic error ("Something went wrong. Please try again."); resets `isLoading` and notifies in `finally`.
- `setQuery(String value)` — sets `_query`, notifies.
- `addStockItem({required name, alias, code, description, stockGroupId, stockCategoryId, unitId})` — clears `error`, calls `_repository.createStockItem(...)`, reloads via `loadStockItems()` on success, returns bool.
- `deleteStockItem(int id)` — calls `_repository.deleteStockItem(id)`, reloads, returns bool.

## Repository / Service

### StockItemRepository (`repository/stock_item_repository.dart`)
- `fetchStockItems()` — calls `service.fetchStockItems()`, unwraps `ResponseModelWrapper`, throws `AppException('Could not load stock items.')` on failure; maps `result` list to `List<StockItem>` via `StockItem.fromJson`; returns `[]` if not a list.
- `createStockItem({required name, alias, code, description, stockGroupId, stockCategoryId, unitId})` — builds a JSON map inline (null-aware `?key: value` entries omit unset optional fields), calls `service.createStockItem(map)`, throws `AppException('Could not create stock item.')` on failure.
- `deleteStockItem(int id)` — calls `service.deleteStockItem(id)`, throws `AppException('Could not delete stock item.')` on failure.

### StockItemService (`services/stock_item_service.dart`)
- `fetchStockItems()` — `GET ApiConfig.stockItemsEndpoint` (`/stock-items`).
- `createStockItem(Map<String, dynamic> data)` — `POST ApiConfig.stockItemCreateEndpoint` (`/stock-items/create`) with `data`.
- `deleteStockItem(int id)` — `DELETE ApiConfig.stockItemEndpoint(id)` (`/stock-items/{id}`).

## Models

### StockItem (`models/stock_item.dart`)
Fields: `id` (int), `name` (String), `alias` (String?), `code` (String?), `description` (String?), `stockGroupId` (int?), `stockCategoryId` (int?), `unitId` (int?), `isActive` (bool, default true), `icon` (IconData, UI-only, default `Icons.inventory_2_rounded`), `color` (Color, UI-only, default `AppColors.primary`). Has `fromJson` and a static `demo` list of 4 placeholder items (A4 Copier Paper, Wireless Mouse, Steel Sheet 2mm, Office Chair [inactive]).

No separate create-request DTO — `createStockItem` on the repository takes named parameters.

## Widgets

### StockItemCard (`widgets/stock_item_card.dart`)
Row card: icon in tinted container, name, "id · code · aka alias" subtitle, optional description, Active/Inactive pill, optional delete `IconButton`. Does not show group/category/unit (only the wide-screen table does).

### StockItemAddDialog (`widgets/stock_item_add_dialog.dart`)
`AlertDialog`-based create form. Fields: Name (required, validated non-empty), Code (optional, auto-uppercased, restricted to `[A-Za-z0-9_-]`), Alias (optional), then a "Classification" section with three `Autocomplete` fields — Stock group (`Autocomplete<StockGroup>`), Stock category (`Autocomplete<StockCategory>`), Unit (`Autocomplete<Unit>`, displaying "`code` — `name`") — each sourced from the corresponding sibling viewModel's list (falling back to that module's `.demo` data if empty), and a Description field (3-line, `minLines`/`maxLines: 3`).
- `initState` (post-frame): triggers `loadStockGroups`/`loadStockCategories`/`loadUnits` on the respective sibling viewModels if each is empty and not already loading — the same lazy-load pattern used by the screen itself, so this also runs redundantly if the dialog is opened from the item screen (which already triggers those loads).
- On Save, pops a record `({name, alias, code, description, stockGroupId, stockCategoryId, unitId})` consumed by `_openAddDialog` in the screen state.
