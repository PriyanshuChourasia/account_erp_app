# accounting_masters/

Master data for the accounting domain (ledgers, accounts, parties,
units, tax rates, etc.).

## Layout

- `modules/` — self-contained sub-modules (one per master, e.g. `ledger/`,
  `party/`, `account/`), each with the standard layout:
  `models/ services/ repository/ viewModel/ screens/ state/ widgets/`
- `screens/` — top-level screens for this module (e.g. an index screen that
  groups the masters).
- `widgets/` — widgets shared by the masters.
- `utils/` — helpers local to the accounting domain.
