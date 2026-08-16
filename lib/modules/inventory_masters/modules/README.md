# modules/

Self-contained inventory master sub-modules.

Each sub-module follows the architecture guide's layout:
`models/ services/ repository/ viewModel/ screens/ state/ widgets/`

Implemented masters:

- `stock_group/` — stock groups (`/stock-groups` API)
- `stock_category/` — stock categories (`/stock-categories` API)
- `unit/` — units of measurement (`/units` API)
- `uqc/` — GST unit quantity codes (`/uqcs` API)

Planned masters: `item/`, `location/`.
