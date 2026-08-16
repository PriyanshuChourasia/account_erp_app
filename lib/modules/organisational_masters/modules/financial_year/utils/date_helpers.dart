/// Shared date helpers for the financial year module.
///
/// Kept free of Flutter widgets so both widgets and screen state can use them.
library;

const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats a [DateTime] as `dd MMM yyyy` (e.g. `01 Apr 2024`).
String formatFinancialDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')} '
    '${_monthNames[date.month - 1]} ${date.year}';

/// Formats a backend `yyyy-MM-dd` string for display. Returns `—` when
/// [value] is null, empty or not in the expected shape.
String formatFinancialDateString(String? value) {
  if (value == null || value.isEmpty) return '—';
  final parts = value.split('-');
  if (parts.length != 3) return value;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) return value;
  if (month < 1 || month > 12) return value;
  return '${day.toString().padLeft(2, '0')} '
      '${_monthNames[month - 1]} $year';
}

/// Converts a [DateTime] to the shape the backend expects on create.
///
/// `CreateFinancialYearDTO` declares `@JsonFormat(pattern = "dd-MM-yyyy")`, so
/// the request body must use `dd-MM-yyyy` even though the response
/// (`FinancialYearDTO`) serialises `LocalDate` as ISO `yyyy-MM-dd`.
String toFinancialDateString(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-${date.year}';
