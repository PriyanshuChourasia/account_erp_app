# Utility

## Purpose
The Utility domain is an index/hub for small, client-side-only tools that don't need the backend. It shows a grid of tool cards; tapping one navigates to that tool's own screen. It currently hosts two sub-modules: a Calculator and a simulated Terminal.

## Architecture
This is a domain directory (`lib/modules/utility/`) with its own domain-level `screens/`, `state/`, `utils/`, `widgets/`, plus two sub-modules under `lib/modules/utility/modules/`. Because every tool here is pure client-side logic, there is no `models/`, `services/`, or `repository/` layer at the domain level, and no `ChangeNotifier` viewModel for the index screen itself (it's static data + navigation).

Domain-level files:
- `screens/utility_screen.dart` — `UtilityScreen`, a minimal `StatefulWidget` shell delegating to `UtilityScreenState`.
- `state/utility_screen_state.dart` — `UtilityScreenState`, renders the grid of tool cards and handles navigation into each sub-module's screen.
- `widgets/utility_card.dart` — `UtilityCard`, the tappable card widget used for each tool in the grid.
- `utils/expression_evaluator.dart` — `ExpressionEvaluator`, a pure, dependency-free arithmetic expression parser/evaluator shared by both the calculator (`CalculatorViewModel`) and the terminal's `calc` command (`TerminalViewModel`).

Flow: `UtilityScreenState` holds a static list of `(title, subtitle, icon, color)` records describing each tool → renders one `UtilityCard` per entry in a `GridView.extent` → tapping a card calls `_openUtility(index)`, which pushes a `MaterialPageRoute` to `CalculatorScreen` (index 0) or `TerminalScreen` (index 1).

## Screens

### UtilityScreen (`lib/modules/utility/screens/utility_screen.dart`)
**Purpose:** Thin `StatefulWidget` shell; all UI and logic live in `UtilityScreenState`.

**UI elements & actions:** None directly.

**Events & state changes:** None directly; `createState()` returns `UtilityScreenState`.

### UtilityScreenState (`lib/modules/utility/state/utility_screen_state.dart`)
**Purpose:** Index screen listing available utility tools as cards in a grid, with a "Handy tools for your day-to-day work." subtitle above.

**UI elements & actions:**
- A static `_utilities` list of two tool descriptors: Calculator ("Perform quick arithmetic calculations", `Icons.calculate_rounded`, blue) and Terminal ("Command-line simulator with a few handy commands", `Icons.terminal_rounded`, teal). A code comment marks where future utilities (Unit Converter, Stopwatch, ...) would be added.
- One `UtilityCard` per entry, laid out in a `GridView.extent` (max cross-axis extent 300, aspect ratio 1.35). Tapping a card calls `_openUtility(index)`.
- `_openUtility(0)` pushes `MaterialPageRoute` → `CalculatorScreen`. `_openUtility(1)` pushes `MaterialPageRoute` → `TerminalScreen`.

**Events & state changes:** No loading/error/empty states (purely static data); no listeners or lifecycle logic beyond the default `build`.

## ViewModel(s)
None at the domain level — the index screen has no dynamic/persisted state, only a static list and navigation. See the sub-module help files for `CalculatorViewModel` and `TerminalViewModel`.

## Repository / Service
None — this domain and both its sub-modules are client-side only (no backend calls).

## Models
None at the domain level. See `terminal/help.md` for `TerminalLine`.

## Widgets

### UtilityCard (`lib/modules/utility/widgets/utility_card.dart`)
Stateless, tappable card: icon in a tinted rounded container, title, subtitle (both single-line, ellipsized), and a trailing chevron. Wraps content in `InkWell` and calls the supplied `onTap` callback when tapped.

## Shared utility

### ExpressionEvaluator (`lib/modules/utility/utils/expression_evaluator.dart`)
Not a widget, but domain-shared logic used by both sub-modules — see each sub-module's help.md for how it's consumed. Static method `ExpressionEvaluator.tryEvaluate(String input)`:
- Normalizes display glyphs `×`→`*`, `÷`→`/`, `−`→`-`, strips spaces.
- Returns `null` for an empty/malformed expression instead of throwing.
- Internally uses a private recursive-descent `_Parser` supporting `+ - * /`, parentheses, unary minus, and decimal numbers, following the grammar `expr := term (('+'|'-') term)*`, `term := factor (('*'|'/') factor)*`, `factor := number | '-' factor | '(' expr ')'`.
- Division by zero, trailing operators, double dots, unexpected characters, and unclosed parentheses all surface as a caught `FormatException`, converted to a `null` return.

## Sub-modules
- [Calculator](modules/calculator/help.md) — arithmetic keypad calculator, viewModel-backed, no models/services/repository.
- [Terminal](modules/terminal/help.md) — simulated command-line terminal with a small built-in command set including `calc`.
