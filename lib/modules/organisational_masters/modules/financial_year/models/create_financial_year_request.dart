import '../utils/date_helpers.dart';

/// Request payload for creating a financial year.
///
/// Mirrors the backend `CreateFinancialYearDTO` record: `name` (required),
/// `code`, `startDate`/`endDate` (both required, sent as `dd-MM-yyyy`),
/// `isCurrent`. Nullable fields are omitted from JSON.
class CreateFinancialYearRequest {
  const CreateFinancialYearRequest({
    required this.name,
    required this.startDate,
    required this.endDate,
    this.code,
    this.isCurrent = false,
  });

  final String name;
  final String? code;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCurrent;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (code != null && code!.isNotEmpty) 'code': code,
        'startDate': toFinancialDateString(startDate),
        'endDate': toFinancialDateString(endDate),
        if (isCurrent) 'isCurrent': true,
      };
}
