# Dashboard

## Purpose
The dashboard is the app's home screen after sign-in: a persistent sidebar for navigating between the ERP's modules (Items, Accounting Masters, Inventory Masters, Organisational Masters, Utilities, and several not-yet-built sections), a header with a financial-year picker, and a home view showing summary stat cards and a "recent activity" panel. It is the shell that hosts every other module's screen inside its content area.

## Architecture
- **Models** (`models/dashboard_stat.dart`): `DashboardStat` — plain data class plus a hardcoded `demo` list; no `fromJson`/`toJson` (not API-backed yet).
- **Data** (`data/sidebar_menu.dart`): a second, apparently unused/stale `sidebarMenu` constant (see note under Widgets).
- **No services/ or repository/ populated yet** — `DashboardViewModel` currently uses in-memory demo data. A `TODO` in the view model explicitly says to add `DashboardService`/`DashboardRepository` and register them in `service_locator.dart` when the backend is ready.
- **ViewModel** (`viewModel/dashboard_view_model.dart`): `DashboardViewModel` — holds loading state and the list of stats.
- **Screens** (`screens/dashboard_screen.dart`): `DashboardScreen` — minimal `StatefulWidget` shell, receives `userName` and `onLogout` from the composition root (`AuthGate`), keeping the dashboard feature decoupled from the auth feature's internals.
- **State** (`state/dashboard_screen_state.dart`): `DashboardScreenState` — owns sidebar selection, builds the section router, the dashboard home view, and private helper widgets (`_SectionHeader`, `_PlaceholderView`, `_RecentActivityCard`).
- **Widgets** (`widgets/`): `Sidebar`, `sidebar_menu.dart` (the real, actively-used menu data + `sidebarMenuItems()`), `FinancialYearSelector`, `StatCard`.

Flow: `DashboardScreenState` → `DashboardViewModel` (demo data only, no repository yet) for the stat grid; `FinancialYearSelector` talks to `FinancialYearViewModel` (from `modules/organisational_masters/modules/financial_year/`, outside this module) for the year picker.

## Screens

### DashboardScreen (`screens/dashboard_screen.dart`) / DashboardScreenState (`state/dashboard_screen_state.dart`)
**Purpose:** The app's post-login home: sidebar navigation shell plus a dashboard summary view.

**UI elements & actions:**
- **Sidebar** (`Sidebar` widget, left, 240px wide, from `widgets/sidebar.dart`) — one tappable row per entry in `sidebarMenuItems()` (from `widgets/sidebar_menu.dart`): Dashboard, Items, Accounting Masters, Inventory Masters, Organisational Masters, Utilities, Invoices, Payments, Customers, Reports, Settings (all currently `is_visible: true`). Tapping an item calls `onNavigate(index)` → `_selectSection(index)` → `setState(_selectedIndex = index)`, which swaps the content area.
  - Sidebar's `_UserCard` at the bottom shows the user's initials (derived from `userName`) and a **Sign out** `IconButton` — calls `onLogout` prop, wired to `_confirmLogout()`.
- **Sign out flow** (`_confirmLogout()`): shows an `AlertDialog` ("Sign out?" / "You will need to sign in again to access your workspace.") with **Cancel** (pops `false`) and **Sign out** (`FilledButton`, pops `true`). If confirmed, calls `widget.onLogout?.call()` (which is `AuthViewModel.logout` passed down through `AuthGate`); `AuthGate` then swaps back to `LoginScreen` automatically — this screen does not navigate itself.
- **Section header** (`_SectionHeader`) — shows the currently selected section's label (from `_selectedLabel`, looked up in `sidebarMenuItems()`) and, on the right, the `FinancialYearSelector` widget.
- **Content area** — wrapped in a nested `Navigator` keyed by `_selectedIndex` (so switching sections resets any pushed sub-routes), rendering `_buildSection()`:
  - index `0` → dashboard home view (`_buildDashboard()`, default/fallback too).
  - index `1` → `ItemScreen` (from `modules/items`).
  - index `2` → `AccountingMastersScreen`.
  - index `3` → `InventoryMastersScreen`.
  - index `4` → `OrganisationalMastersScreen`.
  - index `5` → `UtilityScreen`.
  - any other index → `_PlaceholderView(label: _selectedLabel)` showing a construction icon and "`<label>` is coming soon" (covers Invoices, Payments, Customers, Reports, Settings — sidebar entries with no screen wired up yet, indices 6–10).
- **Dashboard home view** (`_buildDashboard()`):
  - Greeting text `"Hello, <userName ?? 'there'>"` and a subtitle.
  - Stat grid: while `dashboard.isLoading` shows a centered `CircularProgressIndicator`; otherwise a `GridView.count` of `StatCard`s (one per `DashboardViewModel.stats`), 4 columns on widths ≥700px, else 2 columns.
  - `_RecentActivityCard` — a static, hardcoded (non-interactive) list of 3 "recent activity" rows (invoice raised, payment received, monthly report generated) with icon/title/relative time. Explicitly a placeholder for real data.

**Events & state changes:**
- `initState()`: schedules a post-frame callback that calls `context.read<DashboardViewModel>().loadStats()` once mounted — this is what drives the stat grid's loading spinner.
- `_selectSection(index)` triggers `setState`, changing which section renders in the content `Navigator` and updating the header title.
- No `dispose()` override (nothing to clean up).
- Logout confirmation dialog uses `showDialog<bool>`; only a `true` result triggers `onLogout`.

## ViewModel(s)

### DashboardViewModel (`viewModel/dashboard_view_model.dart`)
`ChangeNotifier`, no constructor args (no repository wired in yet).

**State (getters):** `isLoading` (bool), `stats` (`List<DashboardStat>`).

**Methods:**
- `loadStats()` — sets `isLoading = true`, notifies; assigns `_stats = DashboardStat.demo` (hardcoded placeholder data — code comment explicitly says to swap this for `await _repository.fetchStats()` once a backend endpoint exists); sets `isLoading = false`, notifies. No exception handling because there is no real async/repository call yet.

## Repository / Service
None exist yet for this module. The view model's doc comment states the intended shape once the backend is connected: add `DashboardService` (raw HTTP) under `services/` and `DashboardRepository` (envelope unwrapping, throws `AppException`) under `repository/`, then register both in `lib/network/service_locator.dart`, following the same pattern as `AuthService`/`AuthRepository`.

## Models

- **DashboardStat** (`models/dashboard_stat.dart`): `title` (String), `value` (num), `icon` (IconData), `gradient` (`List<Color>`). No `fromJson`/`toJson` — not API-backed. Includes a static `demo` list of 4 stats: "Ledger entries" (1284), "Invoices" (96), "Reports" (12), "Pending approvals" (3), each with an `AppColors.gradient*` color pair and an icon.

## Widgets

- **Sidebar** (`widgets/sidebar.dart`): stateless, 240px-wide persistent nav rail. Renders `_BrandHeader` ("Account ERP" logo/title), a scrollable list of `_SidebarItem`s built from `sidebarMenuItems()` (highlights the selected index, swaps to the `selected_icon` when active), and `_UserCard` at the bottom (avatar initials, user name, sign-out button). Props: `selectedIndex`, `onNavigate`, `userName`, `onLogout`.
- **sidebar_menu.dart** (`widgets/sidebar_menu.dart`) — the live menu data actually used by `Sidebar` and `DashboardScreenState`. `sidebarMenu`: a `Map<String, dynamic>` of 11 entries (Dashboard, Items, Accounting Masters, Inventory Masters, Organisational Masters, Utilities, Invoices, Payments, Customers, Reports, Settings), each with `name`, `is_visible`, `route` (from `AppRoutes`), `icon`, `selected_icon`. `sidebarMenuItems()` returns the ordered, visible-only entries as a `List<Map<String, dynamic>>`.
- **StatCard** (`widgets/stat_card.dart`): stateless gradient card for one `DashboardStat` — gradient background (from `stat.gradient`), title row with an icon chip, and the formatted value (via `Formatters.formatNumber`, from `lib/utils/formatters.dart`) in large bold text.
- **FinancialYearSelector** (`widgets/financial_year_selector.dart`): stateful widget shown in the dashboard's section header. On first build (post-frame callback), if `FinancialYearViewModel.financialYears` is empty and not already loading, calls `loadFinancialYears()`. Renders:
  - A loading spinner + "add" button while loading with no years yet.
  - `_NoYearsLabel` if the list is empty after loading.
  - Otherwise a `PopupMenuButton<FinancialYear>` (`_SelectorButton` showing the currently selected year's name, or "Financial year" if none selected) listing all financial years with a checkmark on the selected one; selecting one calls `viewModel.selectFinancialYear`.
  - `_AddYearButton` (`IconButton`, "+") — opens `FinancialYearAddDialog` via `showDialog`; if the dialog returns a `CreateFinancialYearRequest`, calls `context.read<FinancialYearViewModel>().addFinancialYear(result)`.
  - Note: this widget depends on `FinancialYearViewModel` and related models/dialog from `modules/organisational_masters/modules/financial_year/`, outside the dashboard feature — it's the one place the dashboard module reaches into another module's state.

### Note on `data/sidebar_menu.dart` vs `widgets/sidebar_menu.dart`
There are two different files both defining a top-level `sidebarMenu` constant:
- `lib/features/dashboard/data/sidebar_menu.dart` — a minimal single-entry map (`Dashboard` only, no `icon`/`selected_icon` keys, hardcoded route string `/dashboard`). Nothing in the module imports this file (no references found).
- `lib/features/dashboard/widgets/sidebar_menu.dart` — the full 11-entry map with icons, used by both `Sidebar` and `DashboardScreenState`.
The `data/` version appears to be a stale/dead file left over from an earlier iteration; the `widgets/` version is the one actually driving the UI.
