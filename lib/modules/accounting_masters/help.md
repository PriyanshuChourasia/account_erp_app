# Accounting Masters

## Purpose
`lib/modules/accounting_masters/` is the domain that owns the accounting-side master data for the ERP: account groups, account natures, account ledgers and voucher types. It provides one shared index screen that lists these masters as tappable cards and routes into each sub-module's own screen. The domain also holds the shared API endpoint configuration and a small set of widgets/state used only at the domain (not sub-module) level.

## Architecture
The domain-level files are:

- `configs/accounting_api_config.dart` — `AccountingApiConfig`, a static class of endpoint path constants for every sub-module (account groups, account natures, account ledgers, voucher types).
- `screens/accounting_masters_screen.dart` — `AccountingMastersScreen`, a `StatefulWidget` shell that defers all logic to its `State` class (StatefulWidget split pattern used throughout this codebase).
- `state/accounting_masters_screen_state.dart` — `AccountingMastersScreenState`, builds the grid of master cards and handles navigation into each sub-module screen.
- `widgets/master_card.dart` — `MasterCard`, a generic tappable card widget used by the index screen (not specific to any one sub-module, hence it lives at the domain level rather than inside a sub-module's `widgets/`).
- `utils/` — currently empty except for a `README.md` describing its intended purpose (helpers local to the accounting domain, e.g. ledger formatting, party-code generation, tax calculations); no code exists here yet.

This domain has no models, services, repositories or viewModels of its own — those all live inside the four sub-modules, since the index screen holds no persisted state and makes no API calls itself.

## Screens

### AccountingMastersScreen (`lib/modules/accounting_masters/screens/accounting_masters_screen.dart`)
**Purpose:** Entry point for the accounting masters area. Shows a grid of cards, one per available master, so the user can pick which master to manage.

**UI elements & actions:**
- The screen itself is just a thin `StatefulWidget` wrapper; all behavior is implemented in `AccountingMastersScreenState` (see below).

**Events & state changes:**
- No `initState`/`dispose` logic of its own — none needed since it holds no async state.

### AccountingMastersScreenState (`lib/modules/accounting_masters/state/accounting_masters_screen_state.dart`)
**Purpose:** Renders the descriptive header text and a responsive grid (`GridView.extent`, max cross-axis extent 300, aspect ratio 1.35) of `MasterCard`s for each configured master, and handles navigating to the tapped master's screen.

**UI elements & actions:**
- A static `_masters` list defines three cards, each a record with `title`, `subtitle`, `icon`, `color`:
  - **Account Group** — "Group ledgers under assets, liabilities, income & expenses" (`Icons.account_tree_rounded`, purple `#7C3AED`).
  - **Account Nature** — "Classify accounts by their nature" (`Icons.category_rounded`, teal `#0D9488`).
  - **Voucher Type** — "Classify vouchers such as payment, receipt and journal" (`Icons.receipt_long_rounded`, blue `#1D4ED8`).
  - Note: **Account Ledger** is *not* in this list yet — it has no screen/state/widgets built and is not reachable from the index (see the account_ledger help.md for details). A trailing comment (`// Add more masters here: Ledger, ...`) confirms this is intentional/pending.
- Tapping a `MasterCard` calls `_openMaster(index)`, which switches on the index and pushes a `MaterialPageRoute` to the corresponding screen:
  - index 0 → `AccountGroupScreen`
  - index 1 → `AccountNatureScreen`
  - index 2 → `VoucherTypeScreen`

**Events & state changes:**
- Purely presentational; no loading/error state, no listeners, no `initState`/`dispose` overrides. All navigation is synchronous `Navigator.push` calls with no return-value handling.

## Widgets

### MasterCard (`lib/modules/accounting_masters/widgets/master_card.dart`)
A `StatelessWidget` card used only by the index screen. Takes `title`, `subtitle`, `icon`, `color`, and `onTap`. Renders a `Card` with an `InkWell` (tap target for the whole card), a colored icon chip (icon tinted with 12% alpha of `color` as background), title/subtitle text (both single-line, ellipsized), and a trailing chevron (`Icons.chevron_right_rounded`). Purely presentational — the caller supplies the `onTap` callback (used by `AccountingMastersScreenState._openMaster`).

## Configs

### AccountingApiConfig (`lib/modules/accounting_masters/configs/accounting_api_config.dart`)
Static endpoint-path constants consumed by each sub-module's `*Service` class:

| Master | List | Create | Single-item (`id`) |
|---|---|---|---|
| Account Group | `/account_groups` | `/account_groups/create` | `accountGroupEndpoint(id)` → `/account_groups/{id}` |
| Account Nature | `/account_natures` | `/account_natures/create` | `accountNatureEndpoint(id)` → `/account_natures/{id}` |
| Account Ledger | `/account_ledgers` | `/account_ledgers/create` | `accountLedgerEndpoint(id)` → `/account_ledgers/{id}` |
| Voucher Type | `/voucher_types` | `/voucher_types/create` | `voucherTypeEndpoint(id)` → `/voucher_types/{id}` |

The single-item endpoint is reused for both `PUT` (update) and `DELETE` calls by the sub-modules that support them.

## Sub-modules

- **[account_group](modules/account_group/help.md)** — Hierarchical grouping of ledgers under a parent group and an account nature (e.g. Sundry Debtors under Current Assets). Full CRUD (create, update, delete) with a dedicated full-page form.
- **[account_ledger](modules/account_ledger/help.md)** — Individual ledger accounts (e.g. Cash, Sales) classified under an account group. Models/service/repository/viewModel exist (fetch, create, delete) but there is no screen/state/widgets yet — it is not wired into any UI or the index grid.
- **[account_nature](modules/account_nature/help.md)** — Classifies accounts by nature (Asset, Liability, Income, Expense, Equity). Create and delete only, via an add dialog and a searchable list/table.
- **[voucher_type](modules/voucher_type/help.md)** — Classifies accounting vouchers (Payment, Receipt, Journal, Sales, Purchase). Create and delete only, via an add dialog and a searchable list/table with an auto-uppercased code field.
