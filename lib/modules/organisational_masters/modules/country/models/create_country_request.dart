/// Request payload for creating a country.
///
/// Mirrors the backend `CreateCountryDTO` record. Nullable fields are omitted
/// from JSON so the backend's `@NotBlank` validation only applies to the
/// required ones.
class CreateCountryRequest {
  const CreateCountryRequest({
    required this.name,
    this.alias,
    required this.iso2Code,
    required this.iso3Code,
    required this.numericCode,
    required this.phoneCode,
    required this.currencyCode,
    required this.currencyName,
    this.region,
    this.subRegion,
  });

  final String name;
  final String? alias;

  /// ISO 3166-1 alpha-2 country code, e.g. `IN` (exactly 2 characters).
  final String iso2Code;

  /// ISO 3166-1 alpha-3 country code, e.g. `IND` (exactly 3 characters).
  final String iso3Code;

  /// ISO 3166-1 numeric code, e.g. `356` (exactly 3 characters).
  final String numericCode;

  /// International dialling code, e.g. `+91`.
  final String phoneCode;

  /// ISO 4217 currency code, e.g. `INR` (exactly 3 characters).
  final String currencyCode;
  final String currencyName;
  final String? region;
  final String? subRegion;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (alias != null) 'alias': alias,
    'iso2Code': iso2Code,
    'iso3Code': iso3Code,
    'numericCode': numericCode,
    'phoneCode': phoneCode,
    'currencyCode': currencyCode,
    'currencyName': currencyName,
    if (region != null) 'region': region,
    if (subRegion != null) 'subRegion': subRegion,
  };
}
