# modules/

Self-contained inventory master sub-modules.

Each sub-module follows the architecture guide's layout:
`models/ services/ repository/ viewModel/ screens/ state/ widgets/`

Implemented masters:

- `stock_group/` — stock groups (`/stock-groups` API)
- `stock_category/` — stock categories (`/stock-categories` API)
- `unit/` — units of measurement (`/units` API)
- `unique_quantity_code/` — GST unit quantity codes (`/uqcs` API)
- `stock_item/` — inventory items (`/stock-items` API). Lean scaffold: name,
  alias, code, description, stock group/category/unit links. GST/HSN and
  opening-balance fields are not modelled yet.

Planned masters: `location/`.
