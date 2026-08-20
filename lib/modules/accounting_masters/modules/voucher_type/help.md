# Voucher Type

## Purpose
Voucher Type is the master for classifying accounting vouchers — the transaction documents used to record entries, such as `Payment`, `Receipt`, `Journal`, `Sales`, or `Purchase`. Each voucher type has a short code (e.g. `PAY`) that is automatically uppercased. This module supports listing, searching, creating and deleting voucher types, but not editing an existing one.

## Architecture
- `models/voucher_type.dart` — `VoucherType` (read model, includes UI-only `icon`/`color`; no `demo` fallback list, unlike the other three masters).
- `models/create_voucher_type_request.dart` — `CreateVoucherTypeRequest`.
- `services/voucher_type_service.dart` — `VoucherTypeService`, raw HTTP via `ApiService` and `AccountingApiConfig`.
- `repository/voucher_type_repository.dart` — `VoucherTypeRepository`, unwraps `ResponseModelWrapper`, throws `AppException`.
- `viewModel/voucher_type_view_model.dart` — `VoucherTypeViewModel` (`ChangeNotifier`).
- `screens/voucher_type_screen.dart` — `VoucherTypeScreen` (StatefulWidget shell).
- `state/voucher_type_screen_state.dart` — `VoucherTypeScreenState` (all screen logic).
- `widgets/voucher_type_add_dialog.dart` — `VoucherTypeAddDialog` (create-only dialog form).
- `widgets/voucher_type_card.dart` — `VoucherTypeCard` (mobile list row).

There is no `UpdateVoucherTypeRequest` model and no update method anywhere in this module's stack — only create and delete are supported, mirroring the `account_nature` module's structure closely (same table/card/dialog pattern). A module-local `README.md` (`modules/voucher_type/README.md`) briefly documents this as "Voucher type master data (payment, receipt, journal, sales, purchase, …)" following the standard layout.

## Screens

### VoucherTypeScreen (`lib/modules/accounting_masters/modules/voucher_type/screens/voucher_type_screen.dart`)
**Purpose:** Thin `StatefulWidget` shell; all logic lives in `VoucherTypeScreenState`.

**UI elements & actions:** None directly — delegates to its state class.

**Events & state changes:** None of its own.

### VoucherTypeScreenState (`lib/modules/accounting_masters/modules/voucher_type/state/voucher_type_screen_state.dart`)
**Purpose:** Lists all voucher types (searchable), and lets the user add or delete one. Renders a read-only custom table (`_VoucherTypeTable`, flex rows) on wide screens (≥720px) and a card list (`VoucherTypeCard`) on narrow screens.

**UI elements & actions:**
- **Search field** (`TextField`, hint "Search by name, code or ID...") — `onChanged` calls `viewModel.setQuery`, filtering by name, id, code, or description (case-insensitive substring match via `filteredVoucherTypes`).
- **"Add voucher type" button** (`FilledButton.icon`, add icon) — calls `_openAddDialog()`, which shows `VoucherTypeAddDialog` and, if it returns a `CreateVoucherTypeRequest`, calls `viewModel.addVoucherType(result)`.
- **Error banner** — shown when `viewModel.error != null`; red-tinted `Container` with error icon and message.
- **Loading state** — `CircularProgressIndicator` centered while `viewModel.isLoading`.
- **Empty state** (`_EmptyState`) — icon + "No voucher types found" + "Try a different search or add a new voucher type."
- **Wide-screen table** (`_VoucherTypeTable`) — bordered, rounded container with a pinned header (SL NO, NAME, CODE, DESCRIPTION columns) and a scrollable `ListView.separated` of `_VoucherTypeTableRow`s, zebra-striped. **Read-only** — the code comment explicitly notes "deleting only happens from the card view."
- **Narrow-screen list** (`ListView.separated` of `VoucherTypeCard`) — each card has a **Delete** icon button, calling `_confirmDelete(viewModel, voucherType.id)`. No edit action anywhere.
- **Delete confirmation dialog** — `AlertDialog` titled "Delete voucher type?" with body "This will remove the voucher type from your master." and Cancel/Delete actions; on confirm, calls `viewModel.deleteVoucherType(id)`.

**Events & state changes:**
- `initState` schedules a post-frame callback that calls `viewModel.loadVoucherTypes()` once mounted.
- No `dispose` override.
- All loading/error/list state comes from `VoucherTypeViewModel`, watched via `Provider`.

## ViewModel(s)

### VoucherTypeViewModel (`lib/modules/accounting_masters/modules/voucher_type/viewModel/voucher_type_view_model.dart`)
`ChangeNotifier` holding all UI state for this module.

**State (getters):**
- `isLoading` (`bool`)
- `error` (`String?`)
- `query` (`String`)
- `voucherTypes` (`List<VoucherType>`, unfiltered)
- `filteredVoucherTypes` — computed: filters by `query` (trimmed, lowercased) matching name, id (as string), code, or description.

**Methods:**
- `loadVoucherTypes()` — sets `isLoading = true`, clears `error`, notifies; calls `_repository.fetchVoucherTypes()`; on `AppException` sets `error` to `error.message`; on any other exception sets `'Something went wrong. Please try again.'`; `finally` sets `isLoading = false` and notifies.
- `setQuery(String value)` — sets `_query` and notifies.
- `addVoucherType(CreateVoucherTypeRequest request)` — clears `error`, notifies; calls `_repository.createVoucherType(request)`; on success reloads the list and returns `true`; on `AppException` sets `error` and returns `false`; on other exception sets generic error and returns `false`.
- `deleteVoucherType(int id)` — same pattern, calling `_repository.deleteVoucherType(id)`.

## Repository / Service

### VoucherTypeRepository (`lib/modules/accounting_masters/modules/voucher_type/repository/voucher_type_repository.dart`)
- `fetchVoucherTypes()` — calls `service.fetchVoucherTypes()`, wraps in `ResponseModelWrapper`; throws `AppException(wrapper.message ?? 'Could not load voucher types.', code: wrapper.code)` if `!wrapper.success`; otherwise maps `wrapper.data?.result` through `VoucherType.fromJson`, returning `[]` if not a `List`.
- `createVoucherType(CreateVoucherTypeRequest request)` — calls `service.createVoucherType(request)`, unwraps, throws `AppException('Could not create voucher type.', ...)` on failure.
- `deleteVoucherType(int id)` — calls `service.deleteVoucherType(id)`, unwraps, throws `AppException('Could not delete voucher type.', ...)` on failure.

### VoucherTypeService (`lib/modules/accounting_masters/modules/voucher_type/services/voucher_type_service.dart`)
Raw HTTP calls via `ApiService`, no parsing:
- `fetchVoucherTypes()` — `GET AccountingApiConfig.voucherTypeAPI` (`/voucher_types`).
- `createVoucherType(request)` — `POST AccountingApiConfig.createVoucherTypeAPI` (`/voucher_types/create`) with `request.toJson()` as body.
- `deleteVoucherType(id)` — `DELETE AccountingApiConfig.voucherTypeEndpoint(id)` (`/voucher_types/{id}`).

## Models

### VoucherType (`models/voucher_type.dart`)
Fields: `id` (int), `name` (String), `code` (String?, short code e.g. `PAY`), `description` (String?), `icon` (IconData, UI-only, default `Icons.receipt_long_rounded`), `color` (Color, UI-only, default `AppColors.primary`). `fromJson` parses `id`, `name`, `code`, `description` from the backend `VoucherTypeDTO`; `icon`/`color` are not set from JSON. No `demo` fallback list exists for this model (unlike `AccountGroup`, `AccountNature`, `AccountLedger`).

### CreateVoucherTypeRequest (`models/create_voucher_type_request.dart`)
Fields: `name` (String, required), `code` (String?), `description` (String?). `toJson()` omits `code` if null or empty, and omits `description` if null.

## Widgets

### VoucherTypeAddDialog (`widgets/voucher_type_add_dialog.dart`)
`StatefulWidget` `AlertDialog` for creating a new voucher type. Pops a `CreateVoucherTypeRequest` on save, or `null` on cancel.

**Fields & validation:**
- **Name** (`TextFormField`, autofocus, word capitalization, receipt icon prefix) — required; validator rejects empty/whitespace ("Enter a voucher type name").
- **Code** (`TextFormField`, character capitalization, tag icon prefix, optional) — input is restricted via `FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_-]'))` and auto-uppercased in real time by a custom `_UpperCaseTextFormatter` (a `TextInputFormatter` that forces the typed text to uppercase on every edit). On submit, empty text becomes `null`, otherwise it's trimmed and uppercased again defensively.
- **Description** (`TextFormField`, sentence capitalization, 3 lines, notes icon prefix, optional) — no validator; empty text becomes `null` on submit.
- **Cancel** button — pops with no result.
- **Save button** (`FilledButton.icon`) — calls `_submit()`, which validates then pops a `CreateVoucherTypeRequest` built from the three fields.

**dispose:** disposes all three `TextEditingController`s.

### VoucherTypeCard (`widgets/voucher_type_card.dart`)
Row card used in the narrow-screen list. Shows a colored icon chip (`voucherType.color`/`voucherType.icon`), name, a subtitle of `id · code {code}` (code part only if present), the description (if present, ellipsized), and an optional Delete icon button (only rendered when `onDelete` is supplied — no Edit button on this card).
