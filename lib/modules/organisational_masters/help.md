# Organisational Masters

## Purpose
This domain groups the master data that describes an organisation's operating context: the countries and states/regions it operates in, and the fiscal (financial) years its accounting transactions are grouped by. It provides a single index screen from which each of these masters is opened.

## Architecture
The domain level itself has no models/services/repository/viewModel — those live per sub-module. It contributes:

- `configs/organisational_api_config.dart` — `OrganisationalApiConfig`, the static class holding every REST endpoint path used by the three sub-modules (countries, states, financial years).
- `screens/organisational_masters_screen.dart` — `OrganisationalMastersScreen`, a `StatefulWidget` shell (per the StatefulWidget-split pattern) whose state lives in `state/organisational_masters_screen_state.dart`.
- `state/organisational_masters_screen_state.dart` — `OrganisationalMastersScreenState`, the index/listing screen's logic.
- `widgets/master_card.dart` — `MasterCard`, a domain-shared tappable card widget used to represent each master on the index grid.

### `OrganisationalApiConfig` (`configs/organisational_api_config.dart`)
Static endpoint constants, grouped by master:
- Countries: `countryAPI` (`/countries/list`), `createCountryAPI` (`$countryAPI/create`), `countryEndpoint(id)` (`$countryAPI/$id`, used for delete).
- States: `stateAPI` (`/states`), `createStateAPI` (`$stateAPI/create`), `stateEndpoint(id)` (`$stateAPI/$id`, used for delete).
- Financial years: `financialYearAPI` (`/financial-years`), `createFinancialYearAPI` (`$financialYearAPI/create`), and `updateFinancialYearCurrentAPI` (`$financialYearAPI/current`) for marking a year as the organisation's current fiscal year.

Each sub-module's `*Service` class imports this file rather than growing the global `ApiConfig`, per the project's per-domain config convention.

## Screens

### OrganisationalMastersScreen (`screens/organisational_masters_screen.dart`)
**Purpose:** Index/landing screen for the organisational masters domain — a grid of cards, one per master, that the user taps to drill into that master's own screen.

The widget itself is just the `StatefulWidget` shell; all logic is in `OrganisationalMastersScreenState`.

**UI elements & actions:**
- A `GridView.extent` (max cross-axis extent 300, aspect ratio 1.35) rendering one `MasterCard` per entry in the static `_masters` list (Country, State, Financial Year).
- Tapping a `MasterCard` calls `_openMaster(index)`, which pushes (via `Navigator.of(context).push` with `MaterialPageRoute`) the corresponding screen:
  - index 0 → `CountryScreen`
  - index 1 → `StateScreen`
  - index 2 → `FinancialYearScreen`
- A static intro line ("Manage your organisational master data.") above the grid.

**Events & state changes:**
- No network calls or loading/error states at this level — it's purely a static navigation menu. `_masters` is a compile-time constant list of `(title, subtitle, icon, color)` records; a comment marks where future masters (District, City, ...) would be added.

## Widgets

### MasterCard (`widgets/master_card.dart`)
Stateless, domain-shared card used only by `OrganisationalMastersScreenState`'s grid (and structurally similar to other domains' index cards). Displays an icon in a tinted rounded container, a title, a subtitle, and a trailing chevron; the whole card is wrapped in `InkWell` and invokes the `onTap` callback passed in by the caller. Takes `title`, `subtitle`, `icon`, `color`, `onTap`.

## Sub-modules

- **country** — maintains the list of countries (name, ISO code, alias, description). See `modules/country/help.md`.
- **state** — maintains states/regions, each linked to a parent country. See `modules/state/help.md`.
- **financial_year** — maintains fiscal years (name, code, start/end dates) and which one is the organisation's current year for transactions. See `modules/financial_year/help.md`.
