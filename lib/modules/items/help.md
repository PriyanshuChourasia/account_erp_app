# Items

## Purpose
The Items module is a product/service catalogue screen: it lists items (name, category, price, stock, unit), lets the user search across them, add a new item via a dialog, and delete an existing item with a confirmation prompt. It is currently backed by an in-memory demo list rather than the real backend.

## Architecture
This is a single flat module (`lib/modules/items/`), not nested under `modules/`. It has every layer of the standard stack:

- `models/item.dart` — `Item`, the plain data class.
- `services/item_service.dart` — `ItemService`, raw HTTP calls via `ApiService` (registered but **not currently used**).
- `repository/item_repository.dart` — `ItemRepository`, currently backed by an in-memory `List<Item>` seeded from `Item.demo` instead of calling `ItemService`. A TODO comment in the file says to swap this for real `ItemService` calls and unwrap the `ResponseModelWrapper` envelope, mirroring `AuthRepository`, once the backend is wired.
- `viewModel/item_view_model.dart` — `ItemViewModel` (`ChangeNotifier`), holds the item list, loading flag, and search query; calls only `ItemRepository`.
- `screens/item_screen.dart` — `ItemScreen`, a minimal `StatefulWidget` shell that delegates to `ItemScreenState`.
- `state/item_screen_state.dart` — `ItemScreenState`, builds the search bar, "Add item" button, item list/empty state, and drives the add/delete dialogs.
- `widgets/item_add_dialog.dart` — `ItemAddDialog`, the add-item form dialog.
- `widgets/item_card.dart` — `ItemCard`, the row widget for a single item.

Flow: `ItemScreenState` reads `ItemViewModel` (via `provider`) → `ItemViewModel` calls `ItemRepository` methods (`fetchItems`, `createItem`, `deleteItem`) → `ItemRepository` currently mutates its own in-memory list (real backend calls via `ItemService` are wired in the service layer but not yet invoked by the repository).

## Screens

### ItemScreen (`lib/modules/items/screens/item_screen.dart`)
**Purpose:** Thin `StatefulWidget` shell; all UI and logic live in `ItemScreenState`.

**UI elements & actions:** None directly — see `ItemScreenState` below.

**Events & state changes:** None directly; `createState()` returns `ItemScreenState`.

### ItemScreenState (`lib/modules/items/state/item_screen_state.dart`)
**Purpose:** The catalogue screen: a search field, an "Add item" button, and a scrollable list of items with delete affordance.

**UI elements & actions:**
- Search `TextField` ("Search by name, category or ID...") — `onChanged` calls `viewModel.setQuery(value)`, which filters the list live by name/category/ID (case-insensitive substring match).
- "Add item" `FilledButton.icon` — calls `_openAddItemDialog()`, which shows `ItemAddDialog` as a dialog; on a non-null result it calls `viewModel.addItem(name:, category:, price:, stock:)`.
- Each list row is an `ItemCard` with a delete `IconButton` (rendered when `onDelete` is supplied) — tapping it calls `_confirmDelete(viewModel, item.id)`, which shows an `AlertDialog` ("Delete item?" / "This will remove the item from your catalogue.") with Cancel/Delete actions; confirming (`true`) calls `viewModel.deleteItem(id)`.
- List is rendered with `ListView.separated` (10px gaps between rows).

**Events & state changes:**
- `initState` schedules a post-frame callback that calls `context.read<ItemViewModel>().loadItems()` once the widget is mounted, populating the initial list.
- While `viewModel.isLoading` is true, a `CircularProgressIndicator` is shown instead of the list.
- When `viewModel.filteredItems` is empty (no data, or search matches nothing), an `_EmptyState` widget is shown ("No items found" / "Try a different search or add a new item.").
- No dispose logic beyond the default (no controllers owned directly by this state class).

## ViewModel(s)

### ItemViewModel (`lib/modules/items/viewModel/item_view_model.dart`)
Wraps an `ItemRepository`. Exposed state:
- `isLoading` (bool) — true while `loadItems()` is in flight.
- `query` (String) — current search text.
- `items` (List<Item>) — the full unfiltered list as last loaded.
- `filteredItems` (List<Item>) — `items` filtered by `query` against `name`, `category`, and `id` (lowercase, trimmed, substring match); returns `items` unchanged when the query is empty.

Public methods:
- `loadItems()` — sets `isLoading = true`, notifies, awaits `_repository.fetchItems()`, stores the result in `_items`, sets `isLoading = false`, notifies again.
- `setQuery(String value)` — updates `_query` and notifies (drives `filteredItems`).
- `addItem({name, category, price, stock})` — generates a new id as `ITM-<count+1 padded to 3 digits>`, builds an `Item`, calls `_repository.createItem(item)`, appends it to the local `_items` list, notifies.
- `deleteItem(String id)` — calls `_repository.deleteItem(id)`, removes the matching item from local `_items`, notifies.

## Repository / Service

### ItemRepository (`lib/modules/items/repository/item_repository.dart`)
Currently demo-backed (not calling `ItemService`):
- `fetchItems()` — returns an unmodifiable copy of the in-memory `_items` list (seeded from `Item.demo`).
- `createItem(Item item)` — appends `item` to the in-memory list.
- `deleteItem(String id)` — removes the item with matching `id` from the in-memory list.

A code comment marks this as a TODO: swap the in-memory list for real `ItemService` calls and unwrap the `ResponseModelWrapper` envelope (mirroring `AuthRepository`), once the backend is wired.

### ItemService (`lib/modules/items/services/item_service.dart`)
Raw HTTP calls via `ApiService` (constructed with it, not yet invoked by the repository):
- `fetchItems()` — `GET ApiConfig.itemsEndpoint`.
- `createItem(Item item)` — `POST ApiConfig.itemsEndpoint` with `item.toJson()` as the body.
- `deleteItem(String id)` — `DELETE ApiConfig.itemEndpoint(id)`.

## Models

### Item (`lib/modules/items/models/item.dart`)
Fields: `id` (String), `name` (String), `category` (String), `price` (double), `stock` (int), `unit` (String, default `'pcs'`), `icon` (IconData, default `Icons.shopping_bag_rounded`), `color` (Color, default `AppColors.primary`).
- `Item.fromJson(json)` — parses `id`, `name` (default `''`), `category` (default `'General'`), `price` (default `0`), `stock` (default `0`), `unit` (default `'pcs'`); does not parse `icon`/`color` from JSON (they keep their constructor defaults).
- `toJson()` — serializes `id`, `name`, `category`, `price`, `stock`, `unit` (not `icon`/`color`).
- `Item.demo` — a static list of 5 sample items (Office Chair, Wireless Keyboard, USB-C Hub, Desk Lamp, Steel Filing Cabinet) used as placeholder data until the backend is wired.

## Widgets

### ItemAddDialog (`lib/modules/items/widgets/item_add_dialog.dart`)
Stateful form dialog for creating a new item. Fields: item name (required, non-empty), category (optional, defaults to `'General'` when blank), price (numeric keyboard, digits+`.` only, validated as a non-negative parseable double), stock (numeric keyboard, digits only, validated as a parseable int). "Save" calls `_submit()`, which validates the form and pops a record `({name, category, price, stock})`; "Cancel" pops `null`.

### ItemCard (`lib/modules/items/widgets/item_card.dart`)
Stateless row widget showing an item's icon (in a tinted container using `item.color`), name, `id · category` subtitle, formatted price (`₹` + `Formatters.formatAmount`), and stock count. Stock count is shown in the error color and bolded when `stock <= 10` (low-stock highlight). Renders an optional trailing delete `IconButton` when `onDelete` is provided.
