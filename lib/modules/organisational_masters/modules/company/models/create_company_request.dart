import '../../address/models/create_address_request.dart';

/// Request payload for creating a company.
///
/// Mirrors the backend `CreateCompanyDTO` record: `name` and `mobileNo` are
/// mandatory; `financialYearId` (UUID string) / `bookCommencingFrom`
/// (ISO `yyyy-MM-dd`) are enforced by this form; everything else is optional
/// and omitted from JSON when null.
class CreateCompanyRequest {
  const CreateCompanyRequest({
    required this.name,
    this.parentId,
    this.code,
    this.telephoneNo,
    required this.mobileNo,
    this.faxNo,
    this.email,
    this.website,
    required this.mailingName,
    this.baseCurrencyId,
    this.numberingSystemId,
    required this.financialYearId,
    required this.bookCommencingFrom,
    this.address,
  });

  final String name;

  /// UUID of the parent company, if any.
  final String? parentId;

  /// Short company code, e.g. `ACME`.
  final String? code;

  /// Landline number, e.g. `+91 22 1234 5678`.
  final String? telephoneNo;

  /// Primary contact number.
  final String mobileNo;
  final String? faxNo;
  final String? email;

  /// e.g. `https://acme.example.com`.
  final String? website;

  /// Mailing name shown on printed documents.
  final String mailingName;

  /// UUID of the base currency, once currency master exists.
  final String? baseCurrencyId;

  /// UUID of the numbering system, once that master exists.
  final String? numberingSystemId;

  /// UUID of the financial year the company's books start in.
  final String financialYearId;

  /// Books-commencing date as ISO `yyyy-MM-dd`.
  final String bookCommencingFrom;
  final CreateAddressRequest? address;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (parentId != null) 'parentId': parentId,
    if (code != null) 'code': code,
    if (telephoneNo != null) 'telephoneNo': telephoneNo,
    'mobileNo': mobileNo,
    if (faxNo != null) 'faxNo': faxNo,
    if (email != null) 'email': email,
    if (website != null) 'website': website,
    'mailingName': mailingName,
    if (baseCurrencyId != null) 'baseCurrencyId': baseCurrencyId,
    if (numberingSystemId != null) 'numberingSystemId': numberingSystemId,
    'financialYearId': financialYearId,
    'bookCommencingFrom': bookCommencingFrom,
    if (address != null) 'address': address!.toJson(),
  };
}
