# Stock Item

## Purpose
Stock items are the individual inventory products actually stocked and traded (e.g. "A4 Copier Paper", "Wireless Mouse") — the leaf-level master that everything else (stock group, stock category, unit) classifies. This is explicitly a "lean scaffold": only identity fields (name, alias, code, description) and classification links (stock group, stock category, unit) are modelled; GST/HSN codes, opening balances, godowns and batch tracking are not yet implemented. This master lets a user browse, search, create, and delete stock items, and displays each item's resolved group/category/unit names.

## Architecture
- `models/stock_item.dart` — `StockItem`, the DTO (includes UI-only `icon`/`color` and a `demo` fallback dataset).
- `models/stock_item_type.dart` — `StockItemType`, a `goods`/`service` enum with wire-value serialization helpers, mirroring the backend `StockItemTypeEnum`.
- `models/type_of_supply.dart` — `TypeOfSupply`, a `goods`/`services`/`capitalGoods` enum with wire-value serialization helpers, mirroring the backend `TypeOfSupplyEnum`.
- `models/create_stock_item_request.dart` — `CreateStockItemRequest`, the create-payload DTO (mirrors the backend `CreateStockItemDTO`).
- `repository/stock_item_repository.dart` — `StockItemRepository`, unwraps `ResponseModelWrapper`, throws `AppException`.
- `services/stock_item_service.dart` — `StockItemService`, raw HTTP calls via `ApiService`.
- `viewModel/stock_item_view_model.dart` — `StockItemViewModel`, a `ChangeNotifier` holding the list, loading/error state, search query, and the multi-step create-form state (`currentStep`, `draft`, `goToStep`, `next`, `back`).
- `screens/stock_item_screen.dart` + `state/stock_item_screen_state.dart` — the list screen (`StockItemScreen` shell + `StockItemScreenState` body). This state class also reads and, if needed, triggers loads on the sibling `StockGroupViewModel`, `StockCategoryViewModel`, and `UnitViewModel` (from the `stock_group`, `stock_category`, and `unit` sub-modules) so it can resolve and display human-readable names for an item's `stockGroupId`/`stockCategoryId`/`unitId`.
- `widgets/stock_item_card.dart` — `StockItemCard`, the row card for narrow layouts.
- `widgets/stock_item_add_dialog.dart` — `StockItemAddDialog`, the multi-step create wizard, used by the screen.

## Screens

### StockItemScreen (`screens/stock_item_screen.dart`)
**Purpose:** Thin `StatefulWidget` shell; delegates to `StockItemScreenState`.

**UI elements & actions:** None directly.

**Events & state changes:** None; stateless shell.

### StockItemScreenState (`state/stock_item_screen_state.dart`)
**Purpose:** Full-screen `Scaffold` ("Stock Items") listing all stock items with search, add, and delete, showing each item's classification (group/category/unit) resolved to display names.

**UI elements & actions:**
- Search `TextField` ("Search by name, code or ID...") — `onChanged` calls `viewModel.setQuery`, filtering via `filteredStockItems`.
- "Add item" `FilledButton.icon` — calls `_openAddDialog()`, which shows `StockItemAddDialog` via `showDialog<CreateStockItemRequest>`. On non-null result, calls `context.read<StockItemViewModel>().addStockItem(result)`.
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
- `currentStep` (int) — index of the multi-step create form (`0` = Details, `1` = Classification, `2` = Pricing & stock).
- `draft` (CreateStockItemRequest) — the mutable draft backing the multi-step create form.
- `stepCount` (int) — number of wizard steps (3).

Public methods:
- `loadStockItems()` — sets `isLoading = true`, clears `error`, calls `_repository.fetchStockItems()`, stores into `_stockItems`; catches `AppException` (sets `error`) or generic error ("Something went wrong. Please try again."); resets `isLoading = false` and notifies in `finally`.
- `setQuery(String value)` — sets `_query`, notifies.
- `goToStep(int step)`, `next()`, `back()` — mutate and notify the wizard step state.
- `addStockItem(CreateStockItemRequest request)` — clears `error`, calls `_repository.createStockItem(request)`, reloads via `loadStockItems()` on success, returns bool.
- `deleteStockItem(String id)` — calls `_repository.deleteStockItem(id)`, reloads, returns bool.

## Repository / Service

### StockItemRepository (`repository/stock_item_repository.dart`)
- `fetchStockItems()` — calls `service.fetchStockItems()`, unwraps `ResponseModelWrapper`, throws `AppException('Could not load stock items.')` on failure; maps `result` list to `List<StockItem>` via `StockItem.fromJson`; returns `[]` if not a list.
- `createStockItem(CreateStockItemRequest request)` — calls `service.createStockItem(request)`, throws `AppException('Could not create stock item.')` on failure.
- `deleteStockItem(String id)` — calls `service.deleteStockItem(id)`, throws `AppException('Could not delete stock item.')` on failure.

### StockItemService (`services/stock_item_service.dart`)
- `fetchStockItems()` — `GET InventoryApiConfig.stockItemAPI` (`/stock_items`).
- `createStockItem(CreateStockItemRequest request)` — `POST InventoryApiConfig.createStockItemAPI` (`/stock_items/create`) with `request.toJson()`.
- `deleteStockItem(String id)` — `DELETE InventoryApiConfig.stockItemEndpoint(id)` (`/stock_items/{id}`).

## Models

### StockItem (`models/stock_item.dart`)
Fields: `id` (String, UUID), `name` (String), `alias` (String?), `code` (String?), `description` (String?), `stockItemType` (StockItemType?), `typeOfSupply` (TypeOfSupply?), `stockGroupId` (String?), `stockCategoryId` (String?), `unitId` (String?), `altUnitId` (String?), `gstRate`/`purchasePrice`/`sellingPrice`/`openingQuantity`/`openingValue`/`currentQuantity`/`reorderLevel`/`minimumStock`/`maximumStock` (double?), `barcode`/`hsn`/`sac`/`manufacturePartNo`/`articleNo`/`sku` (String?), `brandId` (int?), `isActive` (bool, default true), `icon` (IconData, UI-only, default `Icons.inventory_2_rounded`), `color` (Color, UI-only, default `AppColors.primary`). Has `fromJson` and a static `demo` list of 4 placeholder items (A4 Copier Paper, Wireless Mouse, Steel Sheet 2mm, Office Chair [inactive]).

### CreateStockItemRequest (`models/create_stock_item_request.dart`)
Mirrors the backend `CreateStockItemDTO`. Fields: `name` (required), `code`/`alias`/`description` (String?), `stockItemType` (StockItemType?), `typeOfSupply` (TypeOfSupply?), `stockGroupId`/`stockCategoryId` (String?, UUID), `unitId` (String, required, UUID), `altUnitId` (String?, UUID), `gstRate`/`purchasePrice`/`sellingPrice`/`openingQuantity`/`openingValue`/`currentQuantity`/`reorderLevel`/`minimumStock`/`maximumStock` (double?), `barcode`/`hsn`/`sac`/`manufacturePartNo`/`articleNo`/`sku` (String?), `brandId` (int?), `active` (bool?, default true). `toJson()` omits null fields.

### StockItemType (`models/stock_item_type.dart`)
Enum: `goods` (wireValue `'goods'`), `service` (wireValue `'service'`). Static `fromWire(String? value)` parses back from the wire value, returning `null` if unmatched.

### TypeOfSupply (`models/type_of_supply.dart`)
Enum: `goods` (wireValue `'goods'`), `services` (wireValue `'services'`), `capitalGoods` (wireValue `'capital_goods'`). Static `fromWire(String? value)` parses back from the wire value, returning `null` if unmatched.

## Widgets

### StockItemCard (`widgets/stock_item_card.dart`)
Row card: icon in tinted container, name, "id · code · aka alias" subtitle, optional description, Active/Inactive pill, optional delete `IconButton`. Does not show group/category/unit (only the wide-screen table does).

### StockItemAddDialog (`widgets/stock_item_add_dialog.dart`)
Multi-step wizard dialog (`AlertDialog`-based):
- Step 0 — Details: name (required, validated), code, alias, description, barcode, HSN/SAC, manufacture part no, article no/SKU, brand ID.
- Step 1 — Classification: stock item type, type of supply, stock group, stock category, unit (required), alternate unit.
- Step 2 — Pricing & stock: active switch, GST rate, purchase/selling price, opening quantity/value, current quantity, reorder level, minimum/maximum stock.

The wizard reads and writes the draft only through the `StockItemViewModel` (`currentStep`, `draft`, `goToStep`, `next`, `back`). Navigation: Back (when past step 0) / Cancel / Next-or-Save. On Save it pops a `CreateStockItemRequest` (from the draft) consumed by `_openAddDialog` in the screen state.
