# Inventory Masters (domain)

## Purpose
`inventory_masters` is the domain that groups all inventory-related master data used elsewhere in the ERP (stock items, ledgers, vouchers, etc.). It does not hold business logic of its own beyond presenting an index of the available masters and routing into each one. The domain-level files here are shared across all five sub-modules: the index/listing screen, a shared card widget, and the domain's own API endpoint constants.

## Architecture
- `configs/inventory_api_config.dart` — `InventoryApiConfig`, a private-constructor class of `static const` endpoint path strings/functions used by some (not all) sub-modules' services.
- `screens/inventory_masters_screen.dart` — `InventoryMastersScreen`, a `StatefulWidget` shell that just points to `InventoryMastersScreenState`.
- `state/inventory_masters_screen_state.dart` — `InventoryMastersScreenState`, the actual index screen body: a static list of master descriptors and a grid of tappable cards that navigate into each sub-module's screen.
- `widgets/master_card.dart` — `MasterCard`, a `StatelessWidget` tile used only by the index screen (not the individual master list screens, which use their own per-module row cards).

There is no `models/`, `services/`, `repository/`, or `viewModel/` at the domain level — the index screen is purely navigational and holds no async state.

## Screens

### InventoryMastersScreen (`lib/modules/inventory_masters/screens/inventory_masters_screen.dart`)
**Purpose:** Thin `StatefulWidget` shell. Per the module's StatefulWidget-split convention, all logic lives in `InventoryMastersScreenState`; this file just wires `createState()`.

**UI elements & actions:** None directly — delegates entirely to its state class.

**Events & state changes:** None; stateless shell.

### InventoryMastersScreenState (`lib/modules/inventory_masters/state/inventory_masters_screen_state.dart`)
**Purpose:** Renders the index/listing screen of inventory masters — a grid of cards, one per master, that the user taps to open that master's own screen. This widget is embedded as a body inside a parent scaffold/nav shell (it returns a `Padding`/`Column`, not a `Scaffold`).

**UI elements & actions:**
- A static `_masters` list (a list of Dart records with `title`, `subtitle`, `icon`, `color`) drives the grid: **Stock Group**, **Stock Category**, **Unit**, **UQC**, **Stock Item** (in that order). A trailing comment (`// Add more masters here: Location, ...`) marks where future masters would be added.
- `GridView.extent` (max cross-axis extent 300, aspect ratio 1.35) lays out one `MasterCard` per master.
- Tapping a `MasterCard` calls `_openMaster(index)`, which switches on the index and pushes the corresponding screen via `Navigator.of(context).push(MaterialPageRoute(...))`:
  - index 0 → `StockGroupScreen`
  - index 1 → `StockCategoryScreen`
  - index 2 → `UnitScreen`
  - index 3 → `UniqueQuantityCodeScreen`
  - index 4 → `StockItemScreen`

**Events & state changes:** No async loading, no error/empty states — this screen is pure static navigation. No `initState`/`dispose` overrides.

## ViewModel(s)
None at the domain level.

## Repository / Service
None at the domain level. `configs/inventory_api_config.dart`'s `InventoryApiConfig` defines endpoint path constants consumed by some sub-modules' `*Service` classes (see each sub-module's help.md):
- `stockGroupAPI` = `/stock_groups`, `createStockGroupAPI` = `/stock_groups/create` — defined but **not** actually used by `stock_group`'s service, which instead uses the hyphenated paths from the global `ApiConfig` (`/stock-groups`, `/stock-groups/create`). This underscored variant appears to be dead/unused.
- `createUnitAPI` = `/units/create` — used by `UnitService.fetchUnits()` (a GET against the "create" path; see the `unit` sub-module's help.md for this quirk).
- `stockCategoryAPI` = `/stock_categories`, `stockCategoryListAPI` = `/stock_categories/list`, `createStockCategoryAPI` = `/stock_categories/create`, `stockCategoryTreeAPI` = `/stock_categories/all-category-tree` — used by `stock_category`'s service.
- `uniqueQuantityCodeAPI` = `/unique_quantity_codes`, `createUniqueQuantityCodeAPI` = `/unique_quantity_codes/create`, `uniqueQuantityCodeEndpoint(id)` = `/unique_quantity_codes/{id}` — used by `unique_quantity_code`'s service.

## Models
None at the domain level.

## Widgets

### MasterCard (`lib/modules/inventory_masters/widgets/master_card.dart`)
A `StatelessWidget` tile: an icon in a tinted rounded container, a title, a subtitle, and a trailing chevron, wrapped in a `Card`/`InkWell` that calls the supplied `onTap`. Used only by `InventoryMastersScreenState`'s grid — each sub-module has its own separate row-card widget for its own list screen (e.g. `StockGroupCard`, `StockCategoryCard`), which are distinct from this one.

## Sub-modules

- **`modules/stock_category/`** — Hierarchical categories used to classify stock items (parent/child tree, e.g. Electronics > Mobiles). See [stock_category/help.md](modules/stock_category/help.md).
- **`modules/stock_group/`** — Flat/hierarchical groups used to classify stock items and control quantity/GST behavior at the group level. See [stock_group/help.md](modules/stock_group/help.md).
- **`modules/stock_item/`** — The individual inventory products themselves, classified under a group, category and unit. See [stock_item/help.md](modules/stock_item/help.md).
- **`modules/unique_quantity_code/`** — GST-mandated Unit Quantity Codes (UQC) such as NOS, KGS, LTR, used to tag units of measurement for GST reporting. See [unique_quantity_code/help.md](modules/unique_quantity_code/help.md).
- **`modules/unit/`** — Units of measurement (simple or compound) used to quantify stock items, each optionally mapped to a UQC. See [unit/help.md](modules/unit/help.md).
