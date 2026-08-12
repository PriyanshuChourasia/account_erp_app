# inventory_masters/

Master data for the inventory domain (items, categories, units,
stock locations, etc.).

## Layout

- `modules/` — self-contained sub-modules (one per master):
  - `stock_group/` — stock groups used to classify inventory items
  - `stock_category/` — stock categories used to classify inventory items
  - `unit/` — units of measurement used to quantify items
  - planned: `item/`, `location/`
- `screens/` — top-level screens for this module:
  - `inventory_masters_screen.dart` — index screen listing the masters as
    tappable cards
- `widgets/` — widgets shared by the masters (e.g. `master_card.dart`)
- `utils/` — helpers local to the inventory domain.
