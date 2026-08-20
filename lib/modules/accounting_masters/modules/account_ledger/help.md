# Account Ledger

## Purpose
Account Ledger is the master for individual ledger accounts — the actual named accounts a business posts transactions against, such as `Cash in Hand`, `Sundry Debtors`, or `Sales`. Each ledger is classified under an `AccountGroup` (e.g. `Cash in Hand` under `Current Assets`). This is the data layer for what would eventually be the day-to-day "chart of accounts" entries.

## Architecture
This sub-module currently has **only the data layer** — `models/`, `services/`, `repository/`, `viewModel/`. There is **no `screens/`, `state/`, or `widgets/` directory**, so it is not yet reachable from the UI: it is not one of the three cards on the `AccountingMastersScreen` index grid (see the domain-level `help.md`), and no route pushes to it anywhere in the codebase. There is also no `UpdateAccountLedgerRequest` model — only create and delete are supported at the data layer (no update capability exists yet, unlike `account_group`).

Files present:
- `models/account_ledger.dart` — `AccountLedger` (read model, includes UI-only `icon`/`color` fields and `demo` fallback data, plus a `groupName` display convenience field).
- `models/create_account_ledger_request.dart` — `CreateAccountLedgerRequest`.
- `services/account_ledger_service.dart` — `AccountLedgerService`.
- `repository/account_ledger_repository.dart` — `AccountLedgerRepository`.
- `viewModel/account_ledger_view_model.dart` — `AccountLedgerViewModel` (`ChangeNotifier`).

`AccountLedgerViewModel` has a cross-module dependency: it is constructed with both an `AccountLedgerRepository` and an `AccountGroupRepository` (from the `account_group` sub-module), so it can resolve and offer the list of account groups for display/selection purposes even though there's no form UI yet to consume it.

## Screens
None exist yet for this module — no `screens/`, `state/`, or `widgets/` files are present.

## ViewModel(s)

### AccountLedgerViewModel (`lib/modules/accounting_masters/modules/account_ledger/viewModel/account_ledger_view_model.dart`)
`ChangeNotifier` constructed with `AccountLedgerRepository` and `AccountGroupRepository`.

**State (getters):**
- `isLoading` (`bool`)
- `error` (`String?`)
- `query` (`String`, current search text)
- `accountLedgers` (`List<AccountLedger>`, unfiltered)
- `accountGroups` (`List<AccountGroup>`, loaded separately for resolving/display group names)
- `filteredAccountLedgers` — computed: filters `accountLedgers` by `query` (trimmed, lowercased) matching name, id (as string), alias, or the resolved group name (via `groupNameOf`).

**Methods:**
- `groupNameOf(AccountLedger ledger)` — looks up the ledger's `groupId` in the loaded `accountGroups` list and returns that group's `name`; falls back to the ledger's own `groupName` field (if the backend sent one), then to `'—'`.
- `loadAccountLedgers()` — sets `isLoading = true`, clears `error`, notifies; calls `_repository.fetchAccountLedgers()`; on `AppException` sets `error` to `error.message`; on any other exception sets `'Something went wrong. Please try again.'`; `finally` sets `isLoading = false` and notifies.
- `loadAccountGroups()` — calls `_accountGroupRepository.fetchAccountGroups()`; on any exception silently falls back to an empty list (`const []`, no error surfaced); notifies either way.
- `setQuery(String value)` — sets `_query` and notifies.
- `addAccountLedger(CreateAccountLedgerRequest request)` — clears `error`, notifies; calls `_repository.createAccountLedger(request)`; on success reloads the list and returns `true`; on `AppException` sets `error` and returns `false`; on other exception sets generic error and returns `false`.
- `deleteAccountLedger(int id)` — same pattern, calling `_repository.deleteAccountLedger(id)`.

Note: there is no `updateAccountLedger` method, consistent with the absence of an `UpdateAccountLedgerRequest` model.

## Repository / Service

### AccountLedgerRepository (`lib/modules/accounting_masters/modules/account_ledger/repository/account_ledger_repository.dart`)
- `fetchAccountLedgers()` — calls `service.fetchAccountLedgers()`, wraps the JSON in `ResponseModelWrapper`; throws `AppException(wrapper.message ?? 'Could not load account ledgers.', code: wrapper.code)` if `!wrapper.success`; otherwise maps `wrapper.data?.result` through `AccountLedger.fromJson`, returning `[]` if the result isn't a `List`.
- `createAccountLedger(CreateAccountLedgerRequest request)` — calls `service.createAccountLedger(request)`, unwraps, throws `AppException('Could not create account ledger.', ...)` on failure.
- `deleteAccountLedger(int id)` — calls `service.deleteAccountLedger(id)`, unwraps, throws `AppException('Could not delete account ledger.', ...)` on failure.

### AccountLedgerService (`lib/modules/accounting_masters/modules/account_ledger/services/account_ledger_service.dart`)
Raw HTTP calls via `ApiService`, no parsing:
- `fetchAccountLedgers()` — `GET AccountingApiConfig.accountLedgerAPI` (`/account_ledgers`).
- `createAccountLedger(request)` — `POST AccountingApiConfig.createAccountLedgerAPI` (`/account_ledgers/create`) with `request.toJson()` as body.
- `deleteAccountLedger(id)` — `DELETE AccountingApiConfig.accountLedgerEndpoint(id)` (`/account_ledgers/{id}`).

Note: there is no `updateAccountLedger` service method (no `PUT` call defined), matching the absence of update support in the repository and viewModel.

## Models

### AccountLedger (`models/account_ledger.dart`)
Fields: `id` (int), `name` (String), `alias` (String?), `description` (String?), `groupId` (int?, the parent account group), `groupName` (String?, display convenience — set only if the backend sends it directly), `isActive` (bool, default `true`), `icon` (IconData, UI-only, default `Icons.menu_book_rounded`), `color` (Color, UI-only, default `AppColors.primary`). `fromJson` parses `id`, `name`, `alias`, `description`, `groupId`, `groupName`, `isActive` from the backend `AccountLedgerDTO`; `icon`/`color` are not set from JSON. A static `demo` list of 5 sample ledgers (Cash in Hand, Sundry Debtors, Sundry Creditors, Sales, Salary Expense) exists as placeholder data, though nothing currently consumes it since there's no form UI.

### CreateAccountLedgerRequest (`models/create_account_ledger_request.dart`)
Fields: `name` (String, required), `alias` (String?), `description` (String?), `groupId` (int?, the parent account group). `toJson()` omits null `alias`/`description`/`groupId`.

## Widgets
None — no `widgets/` directory exists for this module.
