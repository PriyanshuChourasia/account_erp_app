# Calculator

## Purpose
A standard arithmetic calculator: a numeric keypad with digits, operators, decimal point, clear, and backspace, plus a two-line display showing the expression being typed and its evaluated result. It is entirely local/offline — no network calls.

## Architecture
Sub-module under `lib/modules/utility/modules/calculator/`, with `screens/`, `state/`, `viewModel/`, `widgets/` only — no `models/`, `services/`, or `repository/`, since there is no data to persist or fetch beyond the in-memory expression string.

- `screens/calculator_screen.dart` — `CalculatorScreen`, a minimal `StatefulWidget` shell delegating to `CalculatorScreenState`.
- `state/calculator_screen_state.dart` — `CalculatorScreenState`, builds the `Scaffold` with the display (`_Display`) and keypad (`_Keypad`), and wires keypad button callbacks to `CalculatorViewModel` methods.
- `viewModel/calculator_view_model.dart` — `CalculatorViewModel` (`ChangeNotifier`), owns the expression string, result string, and error message; evaluates expressions via the shared `ExpressionEvaluator` (`lib/modules/utility/utils/expression_evaluator.dart`).
- `widgets/calculator_button.dart` — `CalculatorButton`, the single reusable keypad key widget.

Flow: `CalculatorScreenState` reads/watches `CalculatorViewModel` (via `provider`) → button taps call `CalculatorViewModel` methods directly (`inputDigit`, `inputOperator`, `inputDecimal`, `calculate`, `deleteLast`, `clear`) → `calculate()` calls `ExpressionEvaluator.tryEvaluate` (pure local logic, no repository/service layer).

## Screens

### CalculatorScreen (`lib/modules/utility/modules/calculator/screens/calculator_screen.dart`)
**Purpose:** Thin `StatefulWidget` shell; all UI and logic live in `CalculatorScreenState`.

**UI elements & actions:** None directly.

**Events & state changes:** None directly; `createState()` returns `CalculatorScreenState`.

### CalculatorScreenState (`lib/modules/utility/modules/calculator/state/calculator_screen_state.dart`)
**Purpose:** Full-screen calculator with an `AppBar` ("Calculator"), an expression/result display, and a 5-row keypad.

**UI elements & actions (keypad, top-to-bottom, left-to-right):**
- Row 1: **AC** button — calls `_onClear()` → `viewModel.clear()`, resetting expression/result/error. **Backspace** icon button — calls `_onBackspace()` → `viewModel.deleteLast()`, removing the last character/operator. **×** and **÷** operator buttons — call `_onOperator('×')` / `_onOperator('÷')` → `viewModel.inputOperator(...)`.
- Rows 2–4: digit buttons **7 8 9**, **4 5 6**, **1 2 3** — each calls `_onDigit(d)` → `viewModel.inputDigit(d)`; each row ends with an operator button (**−**, **+**, **=**). **=** calls `_onEquals()` → `viewModel.calculate()`.
- Row 5: **0** (double-width) — calls `_onDigit('0')`. **.** (decimal point) — calls `_onDecimal()` → `viewModel.inputDecimal()`.
- Display (`_Display`): shows `calculator.error` (in the theme's error color) above the expression if present; shows `calculator.expression` (secondary text, right-aligned, single line, ellipsized) above the result; shows `calculator.result` large and bold, or `'0'` when empty.

**Events & state changes:**
- No `initState`/`dispose` beyond default `TextEditingController`-free widgets (this screen owns no controllers).
- All state changes are driven purely by `CalculatorViewModel` notifications via `context.watch<CalculatorViewModel>()` — no async loading/error states from a backend, since everything is synchronous and local.

## ViewModel(s)

### CalculatorViewModel (`lib/modules/utility/modules/calculator/viewModel/calculator_view_model.dart`)
Purely local logic — no repository or service calls. Exposed state:
- `expression` (String) — the display string being built, e.g. `"12 + 3 × 4"`.
- `result` (String) — the last computed result as a formatted string.
- `error` (String?) — an error message to show, or `null`.
- `hasExpression` (bool) — whether `expression` is non-empty.
- `hasResult` (bool) — true when `_justEvaluated` is true and `result` is non-empty (i.e., the displayed result matches the last `=` press, so the next digit starts fresh while the next operator reuses the result).

Public methods:
- `inputDigit(String digit)` — clears any error; if a result was just shown, starts a new expression with `digit` (clearing the old expression/result); otherwise appends `digit` to `expression`. Notifies.
- `inputDecimal()` — clears any error; if a result was just shown, starts a new expression `'0.'`; otherwise appends `.` to the current operand — refuses to add a second `.` to the same operand (checked via `_currentOperand()`), and prefixes with `0` when the operand is empty (e.g. after an operator).
- `inputOperator(String operator)` — clears any error; if a result was just evaluated, chains the operator onto the previous result (`"$_result $operator"`); otherwise appends the operator to the trimmed expression, replacing a trailing operator if one is already present (so pressing `+` then `-` replaces `+` with `-` rather than stacking). No-ops on an empty expression. Notifies.
- `calculate()` — clears any error; trims the expression; sets `error = 'Incomplete expression'` if empty or ending with an operator; otherwise calls `ExpressionEvaluator.tryEvaluate(trimmed)`; sets `error = 'Cannot compute that expression'` on `null`; otherwise formats the numeric result via `_formatResult` (integers shown without a decimal point; otherwise trimmed of trailing zeros) into `result`, sets `_justEvaluated = true`. Notifies.
- `deleteLast()` — clears any error; removes the trailing operator (and its surrounding space) if the expression ends with one, otherwise removes the last character; resets `_justEvaluated = false`. No-ops on an empty expression. Notifies.
- `clear()` — resets `expression`, `result`, `error` to empty/null and `_justEvaluated = false`. Notifies.

Private helpers: `_currentOperand()` (extracts the last operand token from the expression), `_endsWithOperator(String)` (checks for a trailing `+ - × ÷`), `_formatResult(double)` (formats a computed value as an integer when it's a whole number, otherwise a trimmed fixed-decimal string).

## Repository / Service
None — this sub-module has no `repository/` or `services/` layer; all logic is local to `CalculatorViewModel` and the shared `ExpressionEvaluator`.

## Models
None.

## Widgets

### CalculatorButton (`lib/modules/utility/modules/calculator/widgets/calculator_button.dart`)
Stateless single keypad key. Displays either a text `label` or a Material `icon`. `variant` (`CalculatorButtonVariant`: `number`, `operator`, `function`) controls coloring — `operator` keys use the primary color with white text/icon, `function` keys (AC, backspace) use a tinted secondary background, `number` keys are plain white. `expanded` (bool) makes the key span two grid columns (used for the `0` key). Wraps an `InkWell` that calls the supplied `onTap` callback.

Private helper widgets defined inline in `calculator_screen_state.dart` (not separately exported, but part of this sub-module's UI):
- `_Display` — renders the expression/result/error readout above the keypad.
- `_Keypad` — the full 5-row keypad grid, built from `CalculatorButton` instances.
- `_KeypadRow` — wraps a list of `CalculatorButton`s in a full-width `Row`.
