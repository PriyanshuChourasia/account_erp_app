# Stock Category

## Purpose
Stock categories classify inventory items into a hierarchical tree (e.g. Electronics > Mobiles), independent of stock groups. Each category can have a parent category (its "Under"), forming a tree rooted at an implicit "Primary" node. This master lets a user browse, search, create and delete stock categories, and separately fetch the full category hierarchy as a tree structure.

## Architecture
- `models/stock_category.dart` — `StockCategory`, the flat DTO used for the list screen (includes UI-only `icon`/`color` and a `demo` fallback dataset).
- `models/stock_category_hierarchy.dart` — `StockCategoryHierarchy`, a separate tree-shaped DTO (with `children`) returned by the hierarchy/tree endpoint; not used by the current screen's UI but fetched by `StockCategoryRepository.fetchStockCategoryHierarchy()`.
- `models/create_stock_category_request.dart` — `CreateStockCategoryRequest`, the create-payload DTO.
- `services/stock_category_service.dart` — `StockCategoryService`, raw HTTP calls via `ApiService`.
- `repository/stock_category_repository.dart` — `StockCategoryRepository`, unwraps `ResponseModelWrapper` and throws `AppException`.
- `viewModel/stock_category_view_model.dart` — `StockCategoryViewModel`, a `ChangeNotifier` holding the list, loading/error state, and search query.
- `screens/stock_category_screen.dart` + `state/stock_category_screen_state.dart` — the list screen (`StockCategoryScreen` shell + `StockCategoryScreenState` body).
- `widgets/stock_category_card.dart` — `StockCategoryCard`, the row card for narrow layouts.
- `widgets/stock_category_create_form.dart` — `StockCategoryCreateForm`, a full-page create form pushed via `Navigator` — this is what the screen actually uses for "Add category".
- `widgets/stock_category_add_dialog.dart` — `StockCategoryAddDialog`, an `AlertDialog`-based create form functionally equivalent to the full-page form above. **It is not referenced anywhere in the app** (confirmed via a repo-wide search for `StockCategoryAddDialog` — only its own definition matches) — dead/unused code, superseded by `StockCategoryCreateForm`.

## Screens

### StockCategoryScreen (`screens/stock_category_screen.dart`)
**Purpose:** Thin `StatefulWidget` shell; delegates to `StockCategoryScreenState`.

**UI elements & actions:** None directly.

**Events & state changes:** None; stateless shell.

### StockCategoryScreenState (`state/stock_category_screen_state.dart`)
**Purpose:** Full-screen `Scaffold` ("Stock Categories") listing all stock categories with search, add, and delete.

**UI elements & actions:**
- Search `TextField` ("Search by name, code or ID...") — `onChanged` calls `viewModel.setQuery(value)`, filtering the displayed list live via `filteredStockCategories`.
- "Add category" `FilledButton.icon` — calls `_openAddDialog()`, which pushes `StockCategoryCreateForm` as a full page via `Navigator.push<CreateStockCategoryRequest>`. If a non-null result is popped, calls `context.read<StockCategoryViewModel>().addStockCategory(result)`.
- Responsive layout via `LayoutBuilder`: width ≥ 720 renders `_StockCategoryTable` (a `DataTable` with ID/Name/Code/Alias/Description/Status/delete-icon columns inside a `Card`); narrower renders a `ListView.separated` of `StockCategoryCard` rows.
- Each row/table row has a delete icon button (`Icons.delete_outline_rounded`) that calls `_confirmDelete(viewModel, id)`.
- `_confirmDelete` shows an `AlertDialog` ("Delete category?" / "This will remove the stock category from your master.") with Cancel/Delete actions; on confirm (`true`), calls `viewModel.deleteStockCategory(id)`.

**Events & state changes:**
- `initState` schedules `context.read<StockCategoryViewModel>().loadStockCategories()` via `WidgetsBinding.instance.addPostFrameCallback` (auto-loads on screen open).
- `viewModel.error != null` renders an inline red-tinted error banner above the list (icon + message), rather than a snackbar/dialog.
- `viewModel.isLoading` shows a centered `CircularProgressIndicator`; an empty filtered list shows `_EmptyState` ("No stock categories found").
- `_StatusBadge` renders Active/Inactive pill per category based on `isActive`.

## ViewModel(s)

### StockCategoryViewModel (`viewModel/stock_category_view_model.dart`)
Exposed state:
- `isLoading` (bool), `error` (String?), `query` (String), `stockCategories` (List<StockCategory>).
- `filteredStockCategories` — computed getter filtering `stockCategories` by `query` (case-insensitive) matching name, id, code, or alias.

Public methods:
- `loadStockCategories()` — sets `isLoading = true`, clears `error`, calls `_repository.fetchStockCategories()`, stores result in `_stockCategories`, catches `AppException` (sets `error` to its message) or any other error (generic "Something went wrong." message), always resets `isLoading = false` and notifies.
- `setQuery(String value)` — sets `_query` and notifies (drives live filtering).
- `addStockCategory(CreateStockCategoryRequest request)` — clears `error`, calls `_repository.createStockCategory(request)`, then reloads the list via `loadStockCategories()`; returns `true` on success, `false` on `AppException`/other error (setting `error`).
- `deleteStockCategory(int id)` — same pattern: calls `_repository.deleteStockCategory(id)`, reloads, returns success bool.

## Repository / Service

### StockCategoryRepository (`repository/stock_category_repository.dart`)
- `fetchStockCategories()` — calls `service.fetchStockCategories()`, wraps response in `ResponseModelWrapper`, throws `AppException('Could not load stock categories.')` on `!wrapper.success`; maps `wrapper.data.result` (expected `List`) to `List<StockCategory>` via `StockCategory.fromJson`; returns `[]` if `result` isn't a list.
- `fetchStockCategoryHierarchy()` — same pattern against `service.fetchStockCategoryHierarchy()`, mapping to `List<StockCategoryHierarchy>`; throws `AppException('Could not load stock hierarchy')` on failure.
- `createStockCategory(CreateStockCategoryRequest request)` — calls `service.createStockCategory(request)`, throws `AppException('Could not create stock category.')` on failure; no return value.
- `deleteStockCategory(int id)` — calls `service.deleteStockCategory(id)`, throws `AppException('Could not delete stock category.')` on failure.

### StockCategoryService (`services/stock_category_service.dart`)
- `fetchStockCategories()` — `GET InventoryApiConfig.stockCategoryListAPI` (`/stock_categories/list`).
- `fetchStockCategoryHierarchy()` — `GET InventoryApiConfig.stockCategoryTreeAPI` (`/stock_categories/all-category-tree`).
- `createStockCategory(request)` — `POST InventoryApiConfig.createStockCategoryAPI` (`/stock_categories/create`) with `request.toJson()`.
- `deleteStockCategory(id)` — `DELETE ApiConfig.stockCategoryEndpoint(id)` (`/stock-categories/{id}` — note this uses the **hyphenated** global `ApiConfig` path, not the underscored `InventoryApiConfig` prefix used by the other three calls).

## Models

### StockCategory (`models/stock_category.dart`)
Fields: `id` (int), `name` (String), `code` (String?), `alias` (String?), `description` (String?), `isActive` (bool, default true), `children` (List<StockCategory>?), `icon` (IconData, UI-only, default `Icons.category_rounded`), `color` (Color, UI-only, default `AppColors.primary`). Has `fromJson` and a static `demo` list of 4 placeholder categories (Electronics, Furniture, Consumables [inactive], Stationery).

### StockCategoryHierarchy (`models/stock_category_hierarchy.dart`)
Fields: `id` (int), `name` (String), `code` (String?), `alias` (String?), `parentId` (int?), `description` (String?), `isActive` (bool, default true), `children` (List<StockCategoryHierarchy>?). Has `fromJson` (recursively parses `children`) and `toJson` (omits null fields, matching backend `@JsonInclude(NON_NULL)`).

### CreateStockCategoryRequest (`models/create_stock_category_request.dart`)
Fields: `name` (required String), `code` (String?), `alias` (String?), `parentId` (int?), `description` (String?). `toJson()` omits null optional fields.

## Widgets

### StockCategoryCard (`widgets/stock_category_card.dart`)
Row card for narrow layouts: icon in a tinted container, name, a "id · code · aka alias" subtitle line, optional description line, an Active/Inactive status pill, and an optional delete `IconButton` (shown only if `onDelete` is provided).

### StockCategoryCreateForm (`widgets/stock_category_create_form.dart`)
The full-page form actually used by the screen for "Add category" (pushed via `Navigator.push`). Fields: Name (required, validated non-empty), Alias (optional), Code (optional, auto-uppercased via `_UpperCaseTextFormatter` + `FilteringTextInputFormatter` restricting to `[A-Za-z0-9_-]`), an "Under" `Autocomplete<_ParentOption>` field (options built from existing categories or `StockCategory.demo` if none loaded, plus a synthetic "Primary" root option with `id: null`), and a Description `TextFormField` (multiline). Layout adapts (`LayoutBuilder`) to put Alias/Code side-by-side on wide screens (≥720) or stacked on narrow. On Save, pops a `CreateStockCategoryRequest` with `parentId` set to the selected `_ParentOption.id` (null for Primary).

### StockCategoryAddDialog (`widgets/stock_category_add_dialog.dart`)
An `AlertDialog`-based equivalent of the create form (same fields, same validation, same "Under" autocomplete logic using an actual `StockCategory` "Primary" lookup rather than a synthetic option). **Dead code** — not referenced by the screen or anywhere else in the app; `StockCategoryCreateForm` is used instead.
