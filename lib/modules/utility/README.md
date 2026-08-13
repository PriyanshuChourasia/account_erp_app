# utility/

Client-side tools with no backend dependency.

Layout follows the self-contained module convention: an index screen
(`screens/`, `state/`) lists the tools as cards (`widgets/`), and each tool is
a sub-module under `modules/`:

- `modules/calculator/` — arithmetic calculator (viewModel-backed keypad).
- `modules/terminal/` — simulated command-line terminal.

Because these tools are pure client-side, they have no `services/` or
`repository/` layers. Shared logic (the arithmetic evaluator used by both the
calculator and the terminal's `calc` command) lives in `utils/`.
