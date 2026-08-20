# Terminal

## Purpose
A simulated, offline command-line terminal inside the app: the user types commands into a monospace input bar, and a small fixed set of built-in commands (`help`, `clear`, `echo`, `date`, `whoami`, `pwd`, `ls`, `calc`, `version`) produce output appended to a scrollback buffer styled like a dark terminal window. It is a novelty/utility tool with no real filesystem or shell behind it.

## Architecture
Sub-module under `lib/modules/utility/modules/terminal/`, with `models/`, `screens/`, `state/`, `viewModel/`, `widgets/` — no `services/`/`repository/`, since there is no backend involved.

- `models/terminal_line.dart` — `TerminalLine` (+ `TerminalLineKind` enum), a plain data holder for one line of scrollback output.
- `screens/terminal_screen.dart` — `TerminalScreen`, a minimal `StatefulWidget` shell delegating to `TerminalScreenState`.
- `state/terminal_screen_state.dart` — `TerminalScreenState`, builds the `Scaffold` with the welcome banner, scrollable output view, and the command input bar; owns the `ScrollController`, `TextEditingController`, and `FocusNode`.
- `viewModel/terminal_view_model.dart` — `TerminalViewModel` (`ChangeNotifier`), owns the scrollback buffer (`List<TerminalLine>`) and interprets/executes typed commands, including calling the shared `ExpressionEvaluator` for `calc`.
- `widgets/terminal_output_view.dart` — `TerminalOutputView`, renders the scrollback buffer as styled monospace text on a dark background.

Flow: `TerminalScreenState` reads/watches `TerminalViewModel` (via `provider`) → submitting text in the input bar calls `TerminalViewModel.submit(command)` → `submit` echoes the command into the buffer and dispatches to `_runCommand`, which appends output/error/info lines (calling `ExpressionEvaluator.tryEvaluate` for `calc`) → `TerminalScreenState` auto-scrolls to the bottom after each submission.

## Screens

### TerminalScreen (`lib/modules/utility/modules/terminal/screens/terminal_screen.dart`)
**Purpose:** Thin `StatefulWidget` shell; all UI and logic live in `TerminalScreenState`.

**UI elements & actions:** None directly.

**Events & state changes:** None directly; `createState()` returns `TerminalScreenState`.

### TerminalScreenState (`lib/modules/utility/modules/terminal/state/terminal_screen_state.dart`)
**Purpose:** Full-screen simulated terminal with an `AppBar` ("Terminal"), an optional welcome banner, a scrollable output pane, and a command input bar styled like a shell prompt.

**UI elements & actions:**
- Welcome banner (`_WelcomeBanner`) — shown only while `terminal.lines` is empty; static text: "Welcome to Account ERP terminal. Type `help` to see available commands."
- Output pane — a `TerminalOutputView` bound to `terminal.lines` and the screen's `_scrollController`, showing the full scrollback.
- Input bar (`_InputBar`) — a prompt label (`guest@account-erp:~$`) followed by a monospace `TextField` (`_textController`, hint "Type a command, e.g. help", `textInputAction: TextInputAction.send`). Submitting (pressing enter/send) calls `_onSubmitted(value)`, which calls `context.read<TerminalViewModel>().submit(value)`, clears the text field, and scrolls the output pane to the bottom.

**Events & state changes:**
- `dispose()` disposes `_scrollController`, `_textController`, and `_inputFocus`.
- `_scrollToBottom()` schedules a post-frame callback that animates the `ScrollController` to `maxScrollExtent` (200ms, ease-out) after each command submission, so new output stays visible.
- The welcome banner disappears permanently once the first command produces any output (buffer becomes non-empty).

## ViewModel(s)

### TerminalViewModel (`lib/modules/utility/modules/terminal/viewModel/terminal_view_model.dart`)
Purely local logic — no repository/service calls. Exposed state:
- `prompt` (String) — the constant shell prompt string `guest@account-erp:~$`.
- `lines` (List<TerminalLine>, unmodifiable) — the full scrollback buffer.

Public methods:
- `clearScreen()` — clears `_lines`. Notifies.
- `submit(String rawCommand)` — trims the input; appends an echoed `TerminalLine` (`"$prompt $command"`, kind `command`) to the buffer; if the trimmed command is empty, just notifies and returns; otherwise dispatches to `_runCommand(command)` and notifies.

Private: `_runCommand(String command)` — splits on whitespace, lower-cases the first token as the command name, joins the rest as `args`, and switches on the name:
- `help` — appends the static `_helpLines` block (list of available commands, `info`/`output` kinds).
- `clear` — calls `clearScreen()`.
- `echo` — appends `args` verbatim (empty line if no args).
- `date` — appends `DateTime.now().toString()`.
- `whoami` — appends `'guest'`.
- `pwd` — appends `'/home/guest'`.
- `ls` — appends the static fake listing `'documents/  downloads/  projects/'`.
- `version` — appends `'Account ERP terminal v${AppVersion.current}'` (from `lib/config/app_version.dart`).
- `calc` — if `args` is empty, appends a usage error (`error` kind: `"Usage: calc <expression>  e.g. calc (2+3)*4"`); otherwise calls `ExpressionEvaluator.tryEvaluate(args)` — on `null` appends an `'Invalid expression.'` error line, otherwise appends the formatted numeric result via `_formatNumber`.
- default (unknown command) — appends an `error`-kind line: `"$name: command not found. Type \`help\` for available commands."`.

`_formatNumber(double)` — same integer-vs-trimmed-decimal formatting logic as the calculator's `_formatResult`.

## Repository / Service
None — no `repository/` or `services/` layer in this sub-module; all behavior is local to `TerminalViewModel`, the shared `ExpressionEvaluator`, and `AppVersion.current`.

## Models

### TerminalLine (`lib/modules/utility/modules/terminal/models/terminal_line.dart`)
Plain data holder, no logic. Fields: `text` (String), `kind` (`TerminalLineKind`, default `output`). Static constant `TerminalLine.separator` — an empty-text line used as a blank spacer.

`TerminalLineKind` enum: `output` (regular command output), `command` (the echoed `$ command` line), `error` (unknown command / invalid input), `info` (informational banner, e.g. the `help` header).

## Widgets

### TerminalOutputView (`lib/modules/utility/modules/terminal/widgets/terminal_output_view.dart`)
Stateless. Renders the scrollback buffer (`lines`) inside a dark rounded container using `ListView.builder`, one `_LineView` per `TerminalLine`. Accepts an optional external `ScrollController` (the screen passes its own so it can programmatically scroll to bottom).

`_LineView` (private) — renders a single line: an empty-text line becomes an 8px spacer; otherwise renders monospace `RichText` colored by `kind` (`command` → light text with a colored `guest@account-erp:~$ ` prompt prefix rendered from the line's own text, `output` → light text, `info` → light blue, `error` → red).

Private terminal color palette (`_TerminalColors`, defined separately/identically in both `terminal_screen_state.dart` and `terminal_output_view.dart`) — dark background/surface, light text, green prompt, blue info, red error — intentionally local to the terminal so it can deviate from the app's light theme.
