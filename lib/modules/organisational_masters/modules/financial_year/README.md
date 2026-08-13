# financial_year/

Financial (fiscal) year master data, used to group accounting transactions.

Follows the self-contained module layout: `models/ services/ repository/
viewModel/ screens/ state/ widgets/`. Dates are exchanged with the backend as
`yyyy-MM-dd` strings and kept as-is on the model; the `utils/` helpers format
them for display and serialise `DateTime` values picked in the add dialog.
