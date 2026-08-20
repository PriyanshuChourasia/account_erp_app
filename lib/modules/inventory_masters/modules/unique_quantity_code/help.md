# Unique Quantity Code (UQC)

## Purpose
UQCs are the GST-mandated short codes (max 3 characters, e.g. `NOS` for Numbers, `KGS` for Kilograms, `LTR` for Litre) that describe the unit an item is measured in for GST reporting purposes. This master lets a user browse, search, create and edit UQCs — it is the one master in this domain that supports **update** rather than delete (there is no delete flow for UQCs). The `unit` sub-module's create dialog references UQCs so a `Unit` can be tagged with its GST UQC.

## Architecture
- `models/unique_quantity_code.dart` — `UniqueQuantityCode`, the DTO (includes UI-only `icon`/`color` and a `demo` fallback dataset).
- `models/create_unique_quantity_code_request.dart` — `CreateUniqueQuantityCodeRequest`, the create-payload DTO.
- `models/update_unique_quantity_code_request.dart` — `UpdateUniqueQuantityCodeRequest`, the update-payload DTO (carries `id`).
- `repository/unique_quantity_code_repository.dart` — `UniqueQuantityCodeRepository`, unwraps `ResponseModelWrapper`, throws `AppException`.
- `services/unique_quantity_code_service.dart` — `UniqueQuantityCodeService`, raw HTTP calls via `ApiService`.
- `viewModel/unique_quantity_code_view_model.dart` — `UniqueQuantityCodeViewModel`, a `ChangeNotifier` holding the list, loading/error state, and search query.
- `screens/unique_quantity_code_screen.dart` + `state/unique_quantity_code_screen_state.dart` — the list screen (`UniqueQuantityCodeScreen` shell + `UniqueQuantityCodeScreenState` body).
- `widgets/unique_quantity_code_card.dart` — `UniqueQuantityCodeCard`, the row card for narrow layouts (has an edit action, not delete).
- `widgets/unique_quantity_code_form_dialog.dart` — `UniqueQuantityCodeFormDialog`, a single dual-purpose dialog used for both create and edit, switching mode based on whether `initialUniqueQuantityCode` is passed.

## Screens

### UniqueQuantityCodeScreen (`screens/unique_quantity_code_screen.dart`)
**Purpose:** Thin `StatefulWidget` shell; delegates to `UniqueQuantityCodeScreenState`.

**UI elements & actions:** None directly.

**Events & state changes:** None; stateless shell.

### UniqueQuantityCodeScreenState (`state/unique_quantity_code_screen_state.dart`)
**Purpose:** Full-screen `Scaffold` ("UQCs") listing all UQCs with search, add, and edit (no delete).

**UI elements & actions:**
- Search `TextField` ("Search by name, code or ID...") — `onChanged` calls `viewModel.setQuery`, filtering via `filteredUniqueQuantityCodes` (matches name, id, or code).
- "Add UQC" `FilledButton.icon` — calls `_openForm()` with no argument, opening `UniqueQuantityCodeFormDialog` in create mode.
- Responsive layout via `LayoutBuilder`: width ≥ 720 renders `_UniqueQuantityCodeTable` — a **custom flex-row table** (not `DataTable`; built from `Container`/`Column`/`Row` with a pinned header, zebra striping via `Container` background on odd rows, and a `Divider`-separated `ListView.separated` body) with SL NO/NAME/CODE/ALIAS/DESCRIPTION/STATUS/edit-icon columns; narrower renders a `ListView.separated` of `UniqueQuantityCodeCard` rows.
- Each row/table row has an **edit** icon button (`Icons.edit_outlined`, not delete) that calls `_openForm(uqc)`, opening the dialog pre-filled in edit mode.
- `_openForm([uqc])`: shows `UniqueQuantityCodeFormDialog(initialUniqueQuantityCode: uqc)` via `showDialog<dynamic>`. On a non-null result, it type-checks: if the result `is UpdateUniqueQuantityCodeRequest`, calls `viewModel.updateUniqueQuantityCode(result)`; if `is CreateUniqueQuantityCodeRequest`, calls `viewModel.addUniqueQuantityCode(result)`.

**Events & state changes:**
- `initState` schedules `context.read<UniqueQuantityCodeViewModel>().loadUniqueQuantityCodes()` via post-frame callback (auto-loads on screen open).
- `viewModel.error != null` renders an inline red-tinted error banner above the list.
- `viewModel.isLoading` shows a centered `CircularProgressIndicator`; empty filtered list shows `_EmptyState` ("No UQCs found").
- `_StatusBadge` renders Active/Inactive; the table's CODE column renders the code in its own small pill/chip (`AppColors.background` container) rather than plain text, or `—` if absent.

## ViewModel(s)

### UniqueQuantityCodeViewModel (`viewModel/unique_quantity_code_view_model.dart`)
Exposed state:
- `isLoading` (bool), `error` (String?), `query` (String), `uqcs` (List<UniqueQuantityCode>).
- `filteredUniqueQuantityCodes` — filters by `query` matching name, id, or code (case-insensitive; no alias match, unlike the other masters' filters).

Public methods:
- `loadUniqueQuantityCodes()` — sets `isLoading = true`, clears `error`, calls `_repository.fetchUniqueQuantityCodes()`, stores into `_uqcs`; catches `AppException` (sets `error`) or generic error ("Something went wrong. Please try again."); resets `isLoading` and notifies in `finally`.
- `setQuery(String value)` — sets `_query`, notifies.
- `addUniqueQuantityCode(CreateUniqueQuantityCodeRequest request)` — clears `error`, calls `_repository.createUniqueQuantityCode(request)`, reloads via `loadUniqueQuantityCodes()` on success, returns bool.
- `updateUniqueQuantityCode(UpdateUniqueQuantityCodeRequest request)` — same pattern, calls `_repository.updateUniqueQuantityCode(request)`, reloads, returns bool.

There is no `deleteUniqueQuantityCode` method — this master has no delete capability anywhere in the stack (viewModel, repository, or service).

## Repository / Service

### UniqueQuantityCodeRepository (`repository/unique_quantity_code_repository.dart`)
- `fetchUniqueQuantityCodes()` — calls `service.fetchUniqueQuantityCodes()`, unwraps `ResponseModelWrapper`, throws `AppException('Could not load UQCs.')` on failure; maps `result` list to `List<UniqueQuantityCode>` via `.fromJson`; returns `[]` if not a list.
- `createUniqueQuantityCode(CreateUniqueQuantityCodeRequest request)` — calls `service.createUniqueQuantityCode(request)`, throws `AppException('Could not create UQC.')` on failure.
- `updateUniqueQuantityCode(UpdateUniqueQuantityCodeRequest request)` — calls `service.updateUniqueQuantityCode(request.id, request)`, throws `AppException('Could not update UQC.')` on failure.

### UniqueQuantityCodeService (`services/unique_quantity_code_service.dart`)
- `fetchUniqueQuantityCodes()` — `GET InventoryApiConfig.uniqueQuantityCodeAPI` (`/unique_quantity_codes`).
- `createUniqueQuantityCode(request)` — `POST InventoryApiConfig.createUniqueQuantityCodeAPI` (`/unique_quantity_codes/create`) with `request.toJson()`.
- `updateUniqueQuantityCode(id, request)` — `PUT InventoryApiConfig.uniqueQuantityCodeEndpoint(id)` (`/unique_quantity_codes/{id}`) with `request.toJson()`.

No delete endpoint exists on the service.

## Models

### UniqueQuantityCode (`models/unique_quantity_code.dart`)
Fields: `id` (int), `name` (String), `code` (String?, max 3 chars per GST UQC convention), `alias` (String?), `description` (String?), `isActive` (bool, default true), `icon` (IconData, UI-only, default `Icons.straighten_rounded`), `color` (Color, UI-only, default `AppColors.primary`). Has `fromJson` and a static `demo` list of 5 placeholder UQCs (Numbers/NOS, Kilograms/KGS, Litre/LTR, Meters/MTR, Boxes/BOX [inactive]).

### CreateUniqueQuantityCodeRequest (`models/create_unique_quantity_code_request.dart`)
Fields: `name` (required String), `code` (required String, max 3 chars), `alias` (String?), `description` (String?). `toJson()` includes `name`/`code` always, omits `alias`/`description` if null.

### UpdateUniqueQuantityCodeRequest (`models/update_unique_quantity_code_request.dart`)
Fields: `id` (required int, identifies the UQC being edited — not included in `toJson()`, only used to build the URL), `name` (required String), `code` (required String, max 3 chars), `alias` (String?), `description` (String?). `toJson()` mirrors the create request's shape (no `id` field).

## Widgets

### UniqueQuantityCodeCard (`widgets/unique_quantity_code_card.dart`)
Row card: icon in tinted container, name, "id · code · aka alias" subtitle, optional description, Active/Inactive pill, and an **edit** `IconButton` (`Icons.edit_outlined`) shown only if `onEdit` is provided — no delete action.

### UniqueQuantityCodeFormDialog (`widgets/unique_quantity_code_form_dialog.dart`)
Dual-purpose `AlertDialog` form for both create and edit, selected by whether `initialUniqueQuantityCode` is non-null (`isEditing`). Text controllers are pre-filled from the initial UQC's fields when editing. Fields: Name (required, validated non-empty), Alias (optional) and Code (required, validated non-empty, `maxLength: 3`, auto-uppercased via `_UpperCaseTextFormatter`, restricted to `[A-Za-z0-9]`, `counterText: ''` hides the character counter) side-by-side, and a Description field (3-line). Title and Save-button label switch between "Add UQC"/"Save" and "Edit UQC"/"Update" based on `isEditing`. On submit, if `initialUniqueQuantityCode` is set, pops an `UpdateUniqueQuantityCodeRequest` (carrying its `id`); otherwise pops a `CreateUniqueQuantityCodeRequest`.
