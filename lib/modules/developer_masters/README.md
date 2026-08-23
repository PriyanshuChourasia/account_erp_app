# developer_masters/

Master data for developer-facing configuration (e.g. API keys, webhooks,
environments — to be defined as sub-modules are added).

## Layout

- `modules/` — self-contained sub-modules, each with the standard layout:
  `models/ services/ repository/ viewModel/ screens/ state/ widgets/`
- `screens/` — top-level screens for this module (the index/dashboard screen
  that groups the masters).
- `state/` — the index screen's `State` class (StatefulWidget split pattern).
- `widgets/` — widgets shared by the masters.
- `utils/` — helpers local to the developer domain.

No sub-modules exist yet — this is currently a scaffold, following the same
pattern as `organisational_masters/` and `accounting_masters/`.
